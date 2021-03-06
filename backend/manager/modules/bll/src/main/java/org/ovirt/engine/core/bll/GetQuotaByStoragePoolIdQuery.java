package org.ovirt.engine.core.bll;

import javax.inject.Inject;

import org.ovirt.engine.core.bll.context.EngineContext;
import org.ovirt.engine.core.common.queries.IdQueryParameters;
import org.ovirt.engine.core.dao.QuotaDao;

public class GetQuotaByStoragePoolIdQuery<P extends IdQueryParameters> extends QueriesCommandBase<P> {
    @Inject
    private QuotaDao quotaDao;

    public GetQuotaByStoragePoolIdQuery(P parameters, EngineContext engineContext) {
        super(parameters, engineContext);
    }

    @Override
    protected void executeQueryCommand() {
        getQueryReturnValue().setReturnValue(quotaDao.getQuotaByStoragePoolGuid(getParameters().getId()));
    }
}
