# Lightweight - Data Cloud Util
A lightweight set of Data Cloud utilities

## Dependencies
order
- test
- rest
- json
- authprovider (optional but recommended)
- auth provider util(optional)


## Custom Metadata Configuration


## Method Signatures
```java
/**
 * UTILITY METHODS
 */
// Method to get all the metadata including child records basedon ont he API Name
utl__Data_Cloud_Ingestion_API_Configuration__mdt configRecord = utl.Dc.getMetadataRecord(String mdtConfigName);

// Method to create an ordered set of column names from a Data Cloud Metadata response
Set<String> columns = getOrderedColumnNamesFromMetadata( Map<String,Object> metadataMap);

/**
 * STREAMING INGESTION API METHODS
 */
// Method to synchronously call the ingest API with the records and the config from the metadata record
utl.Dc.streamRecordsToDataCloud(sObject[] records, String mdtConfigName);

// Method to asynchronously call the ingest API, in this case due to the "future" nature of callout
// we are required to serialize the sObjects using JSON.serialize(sObject[] records)
// Use this on (platform event) triggers
utl.Dc.streamRecordsToDataCloudAsync(String serializedRecords, String mdtConfigName);

/**
 * BULK INGESTION API METHODS
 */
// Method to orchestrate the bulk API ingestion from start to finish in a single transaction
// !! This is very limited in what it can handle is size and exists for test purposes only !!
utl.Dc.ingestBulkCsvDataInDataCloud(String mdtConfigName, String operation, String[] csvFiles);

// Method to create a new bulk ingestion job, return the Id on success
// Valid operation are 'upsert' or 'delete'
String jobId = utl.Dc.createIngestionBulkJob(String mdtConfigName, String correlationId, String operation);

// Method to add a CSV to the ingestion job
utl.Dc.addCsvToIngestionBulkJob(String mdtConfigName, String correlationId, String jobId, String csvData);

// Method to update the ingestion job state to 'UploadComplete' or 'Aborted'
utl.Dc.updateIngestionBulkJobState(String mdtConfigName, String correlationId, String jobId, String state);

// Method to delete a bulk job
utl.Dc.deleteIngestionBulkJob(String mdtConfigName, String correlationId, String jobId);
```

## Example 01 - Stream Data Async from a trigger on a platform event
```java
trigger SmartDeviceEventTrigger on Smart_Device_Event__e (after insert) {
    // Stream the data to data cloud
    utl.Dc.streamRecordsToDataCloudAsync(
        JSON.serialize(trigger.new),
        'Smart_Device_Event_Configuration'
    );
}
```

## Example 02 - Stream Data Directly from Apex
```java
// Create any list of the SAME objects
sObject[] records = new sObject[]{ 
    new Smart_Device_Event__e(
        Action__c        = 'Switch State',
        Device_Type__c   ='Lightbulb',
        Status_Code__c   = 1,
        Status_Reason__c = 'Switched On (1)',
        Timestamp__c     = Datetime.now()
    )
};

// Stream the data to data cloud instantly (note from triggers or platform vents it needs to be async)
utl.Dc.streamRecordsToDataCloud(
    records,
    'Smart_Device_Event_Configuration'
);

```
