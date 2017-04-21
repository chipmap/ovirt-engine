CREATE OR REPLACE FUNCTION CreateLabel (
    v_label_id UUID,
    v_label_name VARCHAR(50),
    v_readonly BOOLEAN,
    v_vms uuid[],
    v_hosts uuid[]
    )
RETURNS VOID AS $PROCEDURE$
DECLARE
   o uuid;
BEGIN
    INSERT INTO labels (
        label_id,
        label_name,
        read_only
        )
    VALUES (
        v_label_id,
        v_label_name,
        v_readonly
        );

    -- Insert VM references
    FOREACH o IN ARRAY v_vms
    LOOP
        INSERT INTO labels_map (
            label_id,
            vm_id
            )
        VALUES (
            v_label_id,
            o
            );
    END LOOP;

    -- Insert host references
    FOREACH o IN ARRAY v_hosts
    LOOP
        INSERT INTO labels_map (
            label_id,
            vds_id
            )
        VALUES (
            v_label_id,
            o
            );
    END LOOP;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateLabel (
    v_label_id UUID,
    v_label_name VARCHAR(50),
    v_readonly BOOLEAN,
    v_vms uuid[],
    v_hosts uuid[]
    )
RETURNS VOID
    --The [tags] table doesn't have a timestamp column. Optimistic concurrency logic cannot be generated
    AS $PROCEDURE$
DECLARE
   o uuid;
BEGIN
    UPDATE labels
    SET label_name = v_label_name,
        read_only = v_readonly
    WHERE label_id = v_label_id;

    DELETE FROM labels_map
    WHERE label_id = v_label_id;

    -- Insert VM references
    FOREACH o IN ARRAY v_vms
    LOOP
        INSERT INTO labels_map (
            label_id,
            vm_id
            )
        VALUES (
            v_label_id,
            o
            );
    END LOOP;

    -- Insert host references
    FOREACH o IN ARRAY v_hosts
    LOOP
        INSERT INTO labels_map (
            label_id,
            vds_id
            )
        VALUES (
            v_label_id,
            o
            );
    END LOOP;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DeleteLabel (v_label_id UUID)
RETURNS VOID AS $PROCEDURE$

BEGIN
    DELETE
    FROM labels
    WHERE label_id = v_label_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetAllLabels ()
RETURNS SETOF labels_map_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT labels_map_view.*
    FROM labels_map_view;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetLabelById (v_label_id UUID)
RETURNS SETOF labels_map_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT labels_map_view.*
    FROM labels_map_view
    WHERE label_id = v_label_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetLabelByIds (v_label_ids UUID[])
RETURNS SETOF labels_map_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT labels_map_view.*
    FROM labels_map_view
    WHERE label_id = ANY(v_label_ids);
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetLabelByName (v_label_name varchar(50))
RETURNS SETOF labels_map_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT labels_map_view.*
    FROM labels_map_view
    WHERE label_name = v_label_name;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetLabelsByReferencedIds (v_entity_ids UUID[])
RETURNS SETOF labels_map_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT labels_map_view.*
    FROM labels_map_view
    WHERE vm_ids::uuid[] && v_entity_ids
        OR vds_ids::uuid[] && v_entity_ids;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION AddVmToLabels (
    v_vm_id UUID,
    v_labels uuid[]
)
RETURNS VOID AS $PROCEDURE$
DECLARE
    o uuid;
BEGIN
    INSERT INTO labels_map (
        label_id,
        vm_id
    )
    SELECT unnest(v_labels), v_vm_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION AddHostToLabels (
    v_host_id UUID,
    v_labels uuid[]
)
RETURNS VOID AS $PROCEDURE$
DECLARE
    o uuid;
BEGIN
    INSERT INTO labels_map (
        label_id,
        vds_id
    )
    SELECT unnest(v_labels), v_host_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateLabelsForVm (
    v_vm_id UUID,
    v_labels uuid[]
)
RETURNS VOID AS $PROCEDURE$
BEGIN
    -- Remove existing entries for the VM
    DELETE FROM labels_map
    WHERE vm_id = v_vm_id;

    -- Add the current entries for the VM
    PERFORM
        AddVmToLabels(v_vm_id, v_labels);
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateLabelsForHost (
    v_host_id UUID,
    v_labels uuid[]
)
RETURNS VOID AS $PROCEDURE$
BEGIN
    -- Remove existing entries for the host
    DELETE FROM labels_map
    WHERE vds_id = v_host_id;

    -- Add the current entries for the host
    PERFORM
        AddHostToLabels(v_host_id, v_labels);
END;$PROCEDURE$
LANGUAGE plpgsql;
