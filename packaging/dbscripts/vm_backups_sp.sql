

----------------------------------------------------------------------
--  [vm_backups] Table
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION GetVmBackupByVmBackupId (v_backup_id UUID)
RETURNS SETOF vm_backups STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT *
    FROM vm_backups
    WHERE backup_id = v_backup_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION InsertVmBackup (
    v_backup_id UUID,
    v_from_checkpoint_id UUID,
    v_to_checkpoint_id UUID,
    v_vm_id UUID,
    v_phase TEXT,
    v__create_date TIMESTAMP WITH TIME ZONE
    )
RETURNS VOID AS $PROCEDURE$
BEGIN
    INSERT INTO vm_backups (
        backup_id,
        from_checkpoint_id,
        to_checkpoint_id,
        vm_id,
        phase,
        _create_date
        )
    VALUES (
        v_backup_id,
        v_from_checkpoint_id,
        v_to_checkpoint_id,
        v_vm_id,
        v_phase,
        v__create_date
        );
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateVmBackup (
    v_backup_id UUID,
    v_from_checkpoint_id UUID,
    v_to_checkpoint_id UUID,
    v_vm_id UUID,
    v_phase TEXT
    )
RETURNS VOID AS $PROCEDURE$
BEGIN
    UPDATE vm_backups
    SET backup_id = v_backup_id,
        from_checkpoint_id = v_from_checkpoint_id,
        to_checkpoint_id = v_to_checkpoint_id,
        vm_id = v_vm_id,
        phase = v_phase
    WHERE backup_id = v_backup_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DeleteVmBackup (v_backup_id UUID)
RETURNS VOID AS $PROCEDURE$
BEGIN
    DELETE
    FROM vm_backups
    WHERE backup_id = v_backup_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetAllFromVmBackups ()
RETURNS SETOF vm_backups STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT *
    FROM vm_backups;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetVmBackupsByVmId (v_vm_id UUID)
RETURNS SETOF vm_backups STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT *
    FROM vm_backups
    WHERE vm_id = v_vm_id;
END;$PROCEDURE$
LANGUAGE plpgsql;


----------------------------------------------------------------
-- [vm_backup_disk_map] Table
----------------------------------------------------------------------
CREATE OR REPLACE FUNCTION InsertVmBackupDiskMap (
    v_backup_id UUID,
    v_disk_id UUID
    )
RETURNS VOID AS $PROCEDURE$
BEGIN
    BEGIN
        INSERT INTO vm_backup_disk_map (
            backup_id,
            disk_id
            )
        VALUES (
            v_backup_id,
            v_disk_id
            );
    END;

    RETURN;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION UpdateVmBackupDiskMap (
    v_backup_id UUID,
    v_disk_id UUID,
    v_backup_url TEXT
    )
RETURNS VOID AS $PROCEDURE$
BEGIN
    UPDATE vm_backup_disk_map
    SET backup_id = v_backup_id,
        disk_id = v_disk_id,
        backup_url = v_backup_url
    WHERE backup_id = v_backup_id;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION DeleteAllVmBackupDiskMapByVmBackupId (v_backup_id UUID)
RETURNS VOID AS $PROCEDURE$
BEGIN
    BEGIN
        DELETE
        FROM vm_backup_disk_map
        WHERE backup_id = v_backup_id;
    END;

    RETURN;
END;$PROCEDURE$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION GetDisksByVmBackupId (v_backup_id UUID)
RETURNS SETOF images_storage_domain_view STABLE AS $PROCEDURE$
BEGIN
    RETURN QUERY

    SELECT images_storage_domain_view.*
    FROM   images_storage_domain_view
    JOIN   vm_backup_disk_map on vm_backup_disk_map.disk_id = images_storage_domain_view.image_group_id
    WHERE  images_storage_domain_view.active AND vm_backup_disk_map.backup_id = v_backup_id;
END;$PROCEDURE$
LANGUAGE plpgsql;
