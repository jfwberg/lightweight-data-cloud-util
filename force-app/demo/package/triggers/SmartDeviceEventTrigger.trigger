trigger SmartDeviceEventTrigger on Smart_Device_Event__e (after insert) {
    
    // Stream the data to data cloud
    utl.Dc.streamRecordsToDataCloudAsync(
        JSON.serialize(trigger.new),
        'Smart_Device_Event_Configuration'
    );

    // This will create a copy in the local table so we can cross check
    Smart_Device_Event_History__c[] historyRecords = new Smart_Device_Event_History__c[]{};

    for(Smart_Device_Event__e record: trigger.new){
        historyRecords.add(new Smart_Device_Event_History__c(
            Action__c = record.Action__c,
            Device_Type__c  = record.Device_Type__c,
            Status_Code__c = record.Status_Code__c,
            Status_Reason__c = record.Status_Reason__c,
            Timestamp__c = record.Timestamp__c,
            EventUuid__c = record.EventUuid,
            ReplayId__c = record.ReplayId
        ));
    }
    insert historyRecords;
}