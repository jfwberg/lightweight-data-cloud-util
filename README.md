# Lightweight - Data Cloud Util
A lightweight set of Data Cloud utilities

## Dependencies
order
- authprovideer
- auth provider util(optional)
- test
- rest



## Method Signatures
```java

// Method to get all the metadata including child records basedon ont he API Name
utl__Data_Cloud_Ingestion_API_Configuration__mdt configRecord = utl.Dc.getMetadataRecord(String mdtConfigName);

// Method to synchronously call the ingest API with the records and the config from the metadata record
utl.Dc.streamRecordsToDataCloud(sObject[] records, String mdtConfigName);

// Method to asynchronously call the ingest API, in this case due to the "future" nature of callout
// we are required to serialize the sObjects using JSON.serialize(sObject[] records)
// Use this on (platform event) triggers
utl.Dc.streamRecordsToDataCloudAsync(String serializedRecords, String mdtConfigName);
```

## Example 01 - Async from a trigger on a platform event
```java
trigger SmartDeviceEventTrigger on Smart_Device_Event__e (after insert) {
    // Stream the data to data cloud
    utl.Dc.streamRecordsToDataCloudAsync(
        JSON.serialize(trigger.new),
        'Smart_Device_Event_Configuration'
    );
}
```

## Example 02 - Directly from Apex
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
