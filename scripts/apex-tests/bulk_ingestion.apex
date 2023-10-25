// Convert to query table when it works
String csvFile = 'Action,Device_Type,EventUuid,ReplayId,Status_Code,Status_Reason,Timestamp\n';
csvFile +='"Switch State","Lightbulk","[RANDOM]","45" ';

try{
    
    
    utl.Dc.ingestBulkCsvDataInDataCloud(
        'Smart_Device_Event_Configuration',
        'upsert',
        new String[]{csvFile}
    );
    


    //utl.Dc.createIngestionBulkJob('Smart_Device_Event_Configuration', '48e45136-67f6-4cfc-bfbf-36f65862456e', 'upsert');


}catch(Exception e){
    System.debug(e.getMessage());
}