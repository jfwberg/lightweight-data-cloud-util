public with sharing class DataCloudBulkIngestionUtilLwcCtrl {
    
    @AuraEnabled
    public static List<Map<String,String>>  getConfigMetadataRecordsPicklistOptions(){
        try {            
            return utl.Dc.getConfigMetadataRecordsPicklistOptions();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Map<String,Object>> getIngestionJobTable(String mdtConfigName){
        try {
            return utl.Dc.getBulkIngestionJobs(mdtConfigName);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String newJob(String mdtConfigName){
        try {
            return utl.Dc.createIngestionBulkJob(mdtConfigName, utl.Rst.guid(), 'upsert');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean abortJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.updateIngestionBulkJobState(mdtConfigName, utl.Rst.guid(), jobId, 'Aborted');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean completeJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.updateIngestionBulkJobState(mdtConfigName, utl.Rst.guid(), jobId, 'UploadComplete');
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Boolean deleteJob(String mdtConfigName, String jobId){
        try {
            utl.Dc.deleteIngestionBulkJob(mdtConfigName, utl.Rst.guid(), jobId);
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}