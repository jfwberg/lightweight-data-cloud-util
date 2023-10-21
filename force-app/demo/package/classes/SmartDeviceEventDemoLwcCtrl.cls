public with sharing class SmartDeviceEventDemoLwcCtrl {

    @AuraEnabled
    public static string createSmartEvent(String device, String action){
        try {
            // Create a new platform event
            EventBus.publish(new Smart_Device_Event__e(
                Action__c        = 'Switch State',
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
}