/**
 * SIMPLE EXAMPLE 
 */
// Query callout to named credential with error handling
utl.Rst callout = new utl.Rst('UKTA_DC_ORG', true)
    .setHandleSfEndpoint(false)
    .setEndpoint('/api/v2/query')
    .setMethod('POST')
    .setBody('{"sql" : "SELECT ssot__Id__c, ssot__Name__c, ssot__Number__c, ssot__AccountTypeId__c, ssot__BillContactAddressId__c, ssot__CreatedDate__c, ssot__DataSourceId__c, ssot__DataSourceObjectId__c FROM ssot__Account__dlm LIMIT 1"}')
    .call()
;

System.debug(callout.getResponse().getBody());

// Create a datatable
utl.JsnTbl table = new utl.JsnTbl()
	.setAttributeFilter(new Set<String>{'startTime','endTime','rowCount','queryId','done','metadata','nextBatchId'})
	.setListNameFilter(new Set<String>{'data'})
    .create(JSON.deserializeUntyped(callout.getResponse().getBody()))
	.updateColumnNames(new Set<String>{'Id','Name','Number','Account Type Id','Billing Address Id','Created Date','Data Source Id','Data Source Object'})
;

// Data table output in the console
System.debug('\n' + table.getConsoleString());