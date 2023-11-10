# Lightweight - Data Cloud Util
A lightweight set of Data Cloud utilities to ingest or query data directly from your Salesforce org.

## Blog
Platform Events (near Real-time event streaming) https://medium.com/@justusvandenberg/stream-platform-events-directly-from-salesforce-into-data-cloud-using-the-ingestion-api-7068f6787fde

## Dependency - Package Info
The following package need to be installed first before installing this package.
If you use the *managed package* you need to installed the managed package dependency and if you use the *unlocked version* you need to use the unlocked dependency.
| Info | Value |
|---|---|
|Name|Lightweight - Apex Unit Test Util v2|
|Version|2.3.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007oePIAQ*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007og1IAA*
|Github URL | https://github.com/jfwberg/lightweight-apex-unit-test-util-v2
| | |
|Name|Lightweight - Apex REST Util|
|Version|0.10.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007FOvIAM*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007FVNIA2*
|Github URL | https://github.com/jfwberg/lightweight-apex-rest-util 
| | |
|Name|Lightweight - Apex JSON Util|
|Version|0.4.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000008cL3IAI*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000008cMfIAI*
|Github URL | https://github.com/jfwberg/lightweight-apex-json-util 

## Optional Dependencies (!! Still recommended !!)
This package is built to be used with a custom Data Cloud Auth Provider. The auth provider utility is highly recommended for error handling.
| Info | Value |
|---|---|
|Name|Lightweight - Data Cloud Auth Provider|
|Version|0.3.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007slFIAQ*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007stJIAQ*
|GIT URL                  | https://github.com/jfwberg/lightweight-data-cloud-auth-provider
| | |
|Name|Lightweight - Auth Provider Util v2|
|Version|0.6.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP30000007t1NIAQ*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP30000007tB3IAI*
|GIT URL                  | https://github.com/jfwberg/lightweight-auth-provider-util

## Package Info
| Info | Value |
|---|---|
|Name|Lightweight - Apex Data Cloud Util|
|Version|0.1.0-1|
|Managed Installation URL | */packaging/installPackage.apexp?p0=04tP3000000AIoTIAW*
|Unlocked Installation URL| */packaging/installPackage.apexp?p0=04tP3000000AIq5IAG* 

## Custom Metadata Configuration
In order to callout to the Data Cloud Ingestion API you will need to create a configuration record for each Ingestion API Connector you want to connect to.
This object links the Data Cloud Named Credential, Ingestion API Connector and target object name together.

In the field mapping metadata you can specify a mapping between sObject fields and the target fields to create a declarative ingestion API field mapping.

###  utl__Data_Cloud_Ingestion_API_Configuration__mdt
This objects holds the configuration for a specific ingestion API connector.

|Field Name|Description|
|---|---|
|utl__Ingestion_API_Connector_Name__c     | The ingestion API connector Name
|utl__Ingestion_API_Target_Object_Name__c | The ingestion API Target Object Name
|utl__Named_Credential_Name__c            | The Data Cloud Name Credential Name, this needs to be a named credential that directly connects to the Data Cloud API.
|utl__Salesforce_Named_Credential_Name__c | The Named Credential Name for the Org that hosts data Cloud (This is for future use and not required yet)
|utl__sObject_Name__c                     | The primary SObject name that is related to the target object. This is fully optional and used for header generation mainly.

### utl__Data_Cloud_Ingestion_API_Field_Mapping__mdt
This objects holds the mapping between an sObject source and target. Technically it doesnt have to be an sObject but it is the main function.
This mapping in used int he utility functions to create a mapping between the source and target field and is especially required for platform events.

|Field Name|Description|
|---|---|
|utl__Data_Cloud_Field_Type__c                 | The field type in data data cloud, valid values are: "textField", "numberField", "dateField", "dateTimeField" or "uuidField". The uuidField is a textField but used to generate test data.
|utl__Data_Cloud_Ingestion_API_Configuration__c| Lookup to the parent configuration record
|utl__Source__c                                | The sObject field name to map
|utl__Target__c                                | The Data Cloud Object field name to map to


## Method Signatures
### Utility methods
```java
/**
 * UTILITY METHODS
 */
// Method to get all the metadata including child records based on on the API Name
utl__Data_Cloud_Ingestion_API_Configuration__mdt configRecord = utl.Dc.getMetadataRecord(String mdtConfigName);

// Method to create an ordered set of column names from a Data Cloud (query) Metadata response
Set<String> columns = utl.Dc.getOrderedColumnNamesFromMetadata(Map<String,Object> metadataMap);

// Method to get the metadata configuration labels and names in a ready to use LWC picklist format
List<Map<String,String>> mdtOptions = utl.Dc.getConfigMetadataRecordsPicklistOptions();

```


### Query methods
```java
/**
 * QUERY API v2 METHODS
 */
// Method to execute a Data Cloud SQL query
utl.Rst callout = utl.Dc.executeQuery(String mdtConfigName, String query);

```


### Streaming ingestion methods
```java
/**
 * STREAMING INGESTION API METHODS
 */
// Method to asynchronously call the ingest API, in this case due to the "future" nature of callout
// we are required to serialize the sObjects using JSON.serialize(sObject[] records)
// Use this on (platform event) triggers
utl.Dc.streamRecordsToDataCloudAsync(String mdtConfigName, String serializedRecords);


// Method to synchronously call the ingest API with the records and the config from the metadata record
utl.Dc.streamRecordsToDataCloud(String mdtConfigName, sObject[] records);

// Method to synchronously call the ingest API with the records and the config from the metadata record
// This method takes a list of object maps as the record parameter
utl.Dc.streamRecordsToDataCloud(String mdtConfigName, List<Map<String,Object>> records);

// Method to call the ingestion API with a custom generated payload and the option to test the payload
// against the payload validation endpoint
utl.Dc.streamDataToDataCloud(String mdtConfigName, String payload, Boolean isTest)

// Method to generate a mapping between source and target object that can be used with the
// streaming API
Map<String,String> fieldMapping = utl.Dc.createFieldMapping(Data_Cloud_Ingestion_API_Field_Mapping__mdt[] fieldMappingRecords);

// Method to generate an ingestion API payload based on a mapping taking a list of SObjects as input
String payload = utl.Dc.createIngestStreamPayload(sObject[] records, Map<String,String> fieldMapping, Boolean prettyPrint);

// Method to generate an ingestion API payload based on a mapping taking a list of object maps as input
String payload = utl.Dc.createIngestStreamPayload(List<Map<String,Object>> records, Map<String,String> fieldMapping, Boolean prettyPrint);

```


### Bulk ingestion methods
```java
/**
 * BULK INGESTION API METHODS
 */
// Method to orchestrate the bulk API ingestion from start to finish in a single transaction
// !! This is very limited in what it can handle is size and exists for test purposes only !!
utl.Dc.ingestBulkCsvDataInDataCloud(String mdtConfigName, String operation, String[] csvFiles);

// Method to get a list of all Bulk ingestion jobs for a certain Ingestion API Connector
List<Map<String,Object>> jobTable = utl.Dc.getBulkIngestionJobs(String mdtConfigName);

// Method to get all info for a specific job
Map<String,Object> jobInfo = utl.Dc.getBulkIngestionJobDetails(String mdtConfigName, String jobId);

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


## Examples
### Example 01 - Stream Data Async from a trigger on a platform event
```java
trigger SmartDeviceEventTrigger on Smart_Device_Event__e (after insert) {
    // Stream the data to data cloud
    utl.Dc.streamRecordsToDataCloudAsync(
        'Smart_Device_Event_Configuration',
        JSON.serialize(trigger.new)
    );
}
```

### Example 02 - Stream Data Directly from Apex
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
    'Smart_Device_Event_Configuration',
    records
);

```