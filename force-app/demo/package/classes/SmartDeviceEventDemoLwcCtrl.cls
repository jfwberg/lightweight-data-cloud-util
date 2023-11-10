@SuppressWarnings('PMD.ApexDoc')
public with sharing class SmartDeviceEventDemoLwcCtrl {

    @AuraEnabled
    public static string createSmartEvent(String device, String action){
        try {
            // Create a new platform event
            EventBus.publish(new Smart_Device_Event__e(
                Action__c        = 'Switch State',
                Event_Date__c    = Date.today(),
                Device_Type__c   = Device,
                Status_Code__c   = (action == 'on') ? 1 : 0,
                Status_Reason__c = 'Switched device "'+device+'" to state "'+action+'"',
                Timestamp__c     = Datetime.now()
            ));

            // Return the success message
            return 'Successfully updated the state for device "'+device+'" to "'+action+'"';
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static void createHistoryRecordsFromEvent(Smart_Device_Event__e[] records){
        
        // This will create a copy in the local table so we can cross check
        Smart_Device_Event_History__c[] historyRecords = new Smart_Device_Event_History__c[]{};

        for(Smart_Device_Event__e record : records){
            historyRecords.add(new Smart_Device_Event_History__c(
                Action__c       = record.Action__c,
                Event_Date__c   = record.Event_Date__c,
                Device_Type__c  = record.Device_Type__c,
                Status_Code__c  = record.Status_Code__c,
                Status_Reason__c= record.Status_Reason__c,
                Timestamp__c    = record.Timestamp__c,
                EventUuid__c    = record.EventUuid,
                ReplayId__c     = record.ReplayId
            ));
        }
        insert historyRecords;
    }
}