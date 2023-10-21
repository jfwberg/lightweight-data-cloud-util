// Method to get all the metadata including child records basedon ont he API Name
utl__Data_Cloud_Ingestion_API_Configuration__mdt mdtRecord = utl.Dc.getMetadataRecord('Smart_Device_Event_Configuration');
System.debug(JSON.serializePretty(mdtRecord));

sObject[] records = new sObject[]{ 
    new Smart_Device_Event__e(
        Action__c        = 'Switch State',
        Device_Type__c   ='Lightbulb',
        Status_Code__c   = 1,
        Status_Reason__c = 'Switched On (1)',
        Timestamp__c     = Datetime.now()
    )
};

// Stream the data to data cloud
utl.Dc.streamRecordsToDataCloud(
    records,
    'Smart_Device_Event_Configuration'
);

EventBus.publish(records);

/**
 * WITH EXTRACTED AND SORTED HEADERS EXAMPLE
 * (add class with sort in future)
 *

// Query callout to named credential
utl.Rst callout = new utl.Rst('DC_ORG_01')
    .setEndpoint('/api/v2/query')
    .setMethod('POST')
    .setBody('{"sql" : "SELECT ssot__Id__c, ssot__Name__c, ssot__Number__c, ssot__AccountTypeId__c, ssot__BillContactAddressId__c, ssot__CreatedDate__c, ssot__DataSourceId__c, ssot__DataSourceObjectId__c FROM ssot__Account__dlm LIMIT 100"}')
    .call()
;

// Parse the top level map to split the data and metadata maps
Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(callout.getResponse().getBody());
Map<String,Object> metadataMap = utl.Jsn.getObjectMap('metadata',responseMap);

// Create a mapping between column index and column name
Map<Integer,String> columnIndexMap = new Map<Integer,String>();

// Create a new set for the column names
Set<String> columnNamesInOrder = new Set<String>{};

// Iterate the metadata to get the columns
for(String key : metadataMap.keySet()){
	columnIndexMap.put(
		(Integer) utl.Jsn.getObject('placeInOrder', (Map<String,Object>) metadataMap.get(key)),
		key
	);
}

// Create an ordered list
for(Integer i=0,max=columnIndexMap.size(); i<max;i++){
	columnNamesInOrder.add(columnIndexMap.get(i));
}

// Create a datatable
utl.JsnTbl table= new utl.JsnTbl()
    .create(utl.Jsn.getObjectList('data',responseMap))
	.updateColumnNames(columnNamesInOrder)
;

// Data table output in the console
System.debug(table.getConsoleString());
*/