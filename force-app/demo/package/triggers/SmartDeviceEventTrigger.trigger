trigger SmartDeviceEventTrigger on Smart_Device_Event__e (after insert) {

    // Stream the data to data cloud
    utl.Dc.streamRecordsToDataCloudAsync(
        'Smart_Device_Event_Streaming',
        JSON.serialize(trigger.new)
    );

    // Create history records
    SmartDeviceEventDemoLwcCtrl.createHistoryRecordsFromEvent(trigger.new);
}