/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains the Data Cloud LWC Controller Methods
 */
@SuppressWarnings('PMD.ExcessivePublicCount, PMD.CyclomaticComplexity, PMD.ApexDoc')
public with sharing class DataCloudUtilLwcCtrl {

    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Mapping between field soap types and data cloud field types, used for YAML generation
    private final static Map<Schema.SOAPType,String> SOAP_TYPE_DATA_CLOUD_DATA_TYPE_MAP = new Map<Schema.SOAPType,String>{
        SOAPType.anytype      => 'textField',
        SOAPType.base64binary => 'textField',
        SOAPType.Boolean      => 'textField',
        SOAPType.Date         => 'dateField',
        SOAPType.DateTime     => 'dateTimeField',
        SOAPType.Double       => 'numberField',
        SOAPType.ID           => 'textField',
        SOAPType.Integer      => 'numberField',
        SOAPType.String       => 'textField',
        SOAPType.Time         => 'dateField',
        SOAPType.Address      => 'textField'
    };

    // Mapping between sObjectField SoapTypes and lightning datatable types 
    private final static Map<Schema.SOAPType,String> SOAP_TYPE_LDT_DATA_TYPE_MAP = new Map<Schema.SOAPType,String>{
        SOAPType.anytype      => 'text',
        SOAPType.base64binary => 'text',
        SOAPType.Boolean      => 'boolean',
        SOAPType.Date         => 'date',
        SOAPType.DateTime     => 'date',
        SOAPType.Double       => 'number',
        SOAPType.ID           => 'text',
        SOAPType.Integer      => 'number',
        SOAPType.String       => 'text',
        SOAPType.Time         => 'date',
        SOAPType.Address      => 'text'
    };

    // Mapping between data cloud query types and lightning datatable types
    private final static Map<String,String> DATA_CLOUD_DATA_TYPE_LDT_DATA_TYPE_MAP = new Map<String,String>{
        'CHAR'                          => 'text',
        'VARCHAR'                       => 'text',
        'STRING'                        => 'text',
        'BLOB'                          => 'text',
        'DATE'                          => 'date',
        'DATE_TIME'                     => 'date',
        'TIMESTAMP'                     => 'date',
        'TIMESTAMP WITH TIME ZONE'      => 'date',
        'TIMESTAMP WITH LOCAL TIME ZONE'=> 'date',
        'DECIMAL'                       => 'number',
        'NUMBER'                        => 'number',
        'INT'                           => 'number',
        'INTEGER'                       => 'number'
    };


    /** **************************************************************************************************** **
     **                                    CUSTOM METADATA AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static List<Map<String,String>>  getMtdConfigOptions(String namedCredentialName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION'); 

            // Return the metadata configuration picklist options
            return Dc.getConfigMetadataRecordsPicklistOptions(namedCredentialName);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Map<String, Object>> getMetadataInfo(String mdtConfigName, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Create the configuration table
            utl.Ldt configTable = new utl.Ldt()
                .setupKeyValue()
                .addKeyValuePair('Configuration Record Name',       record.DeveloperName)
                .addKeyValuePair('Salesforce Named Credential',     record.Salesforce_Named_Credential_Name__c)
                .addKeyValuePair('Data Cloud Named Credential',     record.Named_Credential_Name__c)
                .addKeyValuePair('Salesforce sObject Name',         record.sObject_Name__c)
                .addKeyValuePair('Ingestion API Connector Name',    record.Ingestion_API_Connector_Name__c)
                .addKeyValuePair('Ingestion API Target Object Name',record.Ingestion_API_Target_Object_Name__c)
                .addKeyValuePair('Data Lake Object Name',           record.Data_Lake_Object_Name__c)
            ;

            // Create the configuration table
            utl.Ldt mappingTable = new utl.Ldt()
                .setKeyField('source')
                .addColumn(new utl.Ldt.Col('Source Field (Salesforce)', 'source', 'text'))
                .addColumn(new utl.Ldt.Col('Target Field (Data Cloud)', 'target', 'text'))
                .addColumn(new utl.Ldt.Col('Field Type (Data Cloud)',   'ftype',  'text'))
                .addColumn(new utl.Ldt.Col('Is Primary Key',            'isPk',   'boolean'))
                .addColumn(new utl.Ldt.Col('Is Event Time Field',       'isEt',   'boolean'))
            ;
	        
            // Add mapping data
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                mappingTable.addRow(
                    new Map<String,Object>{
                        'source' => mapping.Source__c,
                        'target' => mapping.Target__c,
                        'ftype'  => mapping.Data_Cloud_Field_Type__c,
                        'isPk'   => (Boolean) mapping.Is_Primary_Key__c,
                        'isEt'   => (Boolean) mapping.Is_Event_Time_Field__c 
                    });
            }

            // Return the combined
            return new List<Map<String, Object>>{
                new Map<String, Object>{
                    'key'    => '1',
                    'header' => 'Configuration Details',
                    'ldt'    => configTable
                },
                new Map<String, Object>{
                    'key'    => '2',
                    'header' => 'Mapping Details',
                    'ldt'    => mappingTable
                }
            };
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                     BULK INGESTION AURA METHODS                                      **
     ** **************************************************************************************************** **/

     // FIX the start comma if the first value is an empty value

    @AuraEnabled
    public static String getCsvPlaceholder(String mdtConfigName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Sample data
            String header = '';
            String data   = '';

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                header+=',' + mapping.Target__c;
            }

            // Add linebreak and remove the starting comma
            header+='\n';
            header = header.removeStart(',');

            // Create some sample data lines
            for(Integer i=0;i<5;i++){
                String line = '';
                
                // Add each fields
                for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                    line += (String.isNotBlank(line) ? ',' : '' ) + generateSampleData(mapping.Data_Cloud_Field_Type__c);
                }
                
                // Add the line to the data
                data+= line + '\n';
            }

            // Use the utility to generate an ingestion stream payload
            return header + data;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static utl.Ldt getJobInfo(String namedCredentialName, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Output a key/value table with the job details
            return new utl.Ldt()
                .setupKeyValue()
                .setData(
                    new utl.JsnTbl()
                        .create(Dc.getBulkIngestionJobDetails(namedCredentialName,jobId))
                        .getKeyValuePairData()
                )
            ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static utl.Ldt getIngestionJobTable(String namedCredentialName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Create a lightning data table
            return new utl.Ldt()
                .setKeyField('id')
                .addColumn(new utl.Ldt.Col('Created Date',  'createdDate', 'date'))
                .addColumn(new utl.Ldt.Col('Job Id',        'id',          'text'))
                .addColumn(new utl.Ldt.Col('Operation',     'operation',   'text'))
                .addColumn(new utl.Ldt.Col('Object',        'object',      'text'))
                .addColumn(new utl.Ldt.Col('Job State',     'state',       'text'))
                .addColumn(
                    new utl.Ldt.Col(null, null)
                        .setType('action')
                        .setTypeAttributes(
                            new utl.Ldt.TypeAttributes()
                                .setMenuAlignment('auto')
                                .addRowAction(new utl.Ldt.RowAction('Details',      'details'   ))
                                .addRowAction(new utl.Ldt.RowAction('Add CSV Data', 'csv'       ))
                                .addRowAction(new utl.Ldt.RowAction('Upload CSV',   'uploadCsv' ))
                                .addRowAction(new utl.Ldt.RowAction('Complete',     'complete'  ))
                                .addRowAction(new utl.Ldt.RowAction('Abort',        'abort'     ))
                                .addRowAction(new utl.Ldt.RowAction('Delete',       'delete'    ))
                        ) 
                )
                .setData(Dc.getBulkIngestionJobs(namedCredentialName))
            ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String newJob(String mdtConfigName, String jobType){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Create the ingestion job
            return Dc.createIngestionBulkJob(mdtConfigName, utl.Rst.guid(), jobType);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean abortJob(String namedCredentialName, String jobId){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Update the job status
            Dc.updateIngestionBulkJobState(namedCredentialName, jobId, jobId, 'Aborted');

            // return true when all is good
            return true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean completeJob(String namedCredentialName, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Update the bulk job status
            Dc.updateIngestionBulkJobState(namedCredentialName, jobId, jobId, 'UploadComplete');

            // return true when all is good
            return true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean deleteJob(String namedCredentialName, String jobId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Delete the ingestion bulk job
            Dc.deleteIngestionBulkJob(namedCredentialName, jobId, jobId);

            // return true when all is good
            return true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean addCsv(String namedCredentialName, String jobId, String csvData){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Add CSV data
            Dc.addCsvToIngestionBulkJob(namedCredentialName, jobId, jobId, csvData);

            // return true when all is good
            return true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean addCsvFromFile(String namedCredentialName, String jobId, String documentId, String contentVersionId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Send the file content to Data Cloud
            Dc.addCsvToIngestionBulkJob(
                namedCredentialName,
                jobId,
                jobId,
                [SELECT VersionData FROM ContentVersion WHERE Id = :contentVersionId WITH USER_MODE LIMIT 1]?.VersionData?.toString()
            );
            
            // return true when all is good
            return true;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean deleteDocument(String documentId){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Delete the uploaded document (finally doesnt work well with AuraHandled Exceptions)
            delete as user [SELECT Id FROM ContentDocument WHERE Id = :documentId LIMIT 1];
            
            // return true when all is good
            return true;

        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    

    /** **************************************************************************************************** **
     **                                  STREAMING INGESTION AURA METHODS                                    **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getStreamingPlaceholder(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Dummy data place holder
            Map<String,Object> placeholder = new Map<String,Object>();

            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                placeholder.put(mapping.Source__c, generateSampleData(mapping.Data_Cloud_Field_Type__c));
            }

            // Use the utility to generate an ingestion stream payload
            return Dc.createIngestStreamPayload(
                new List<Map<String,Object>>{placeholder},
                Dc.createFieldMapping(record.Data_Cloud_Ingestion_API_Field_Mappings__r),
                true
            );

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean sendDataStream(String mdtConfigName, String payload){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Stream records
            Dc.streamDataToDataCloud(mdtConfigName, payload, false);

            // return true when all is good
            return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Boolean testDataStream(String mdtConfigName, String payload){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // TEST the streaming of records
            Dc.streamDataToDataCloud(mdtConfigName, payload, true);
            
            // return true when all is good
            return true;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                     GENERATE YAML AURA METHODS                                       **
     ** **************************************************************************************************** **/
    @AuraEnabled(cacheable=true)
    public static List<Map<String,Object>>  getSObjectOptions(Boolean invertLabel){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');


            // List of select options
            List< Map<String,Object>> options = new List< Map<String,Object> >();

            /**
             * This method will get all sObject that are not like a share or feed
             * and that are queryable
             */
            for(SObjectType result : Schema.getGlobalDescribe().values()){

                DescribeSObjectResult sdr = result.getDescribe(SObjectDescribeOptions.DEFERRED);

                if(sdr.associateEntityType == null && sdr.isQueryable()){
                    options.add(new Map<String,Object>{
                        'label' => (invertLabel) ? sdr.name + ' - (' + sdr.label +')' : sdr.label + ' - (' + sdr.name +')',
                        'value' =>  sdr.name
                    });
                }
            }

            // Return a list of options
            return options;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static utl.Ldt getSObjectFieldInfo(String sObjectName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Input validation
            if(Type.forName('Schema.' + sObjectName) == null){
                throw new Dc.DataCloudUtilException(String.format('sObject of type "{0}" does not exist in the metadata', new String[]{sObjectName}));
            }

            // Creat the output data table
            utl.Ldt ldt = new utl.Ldt()
                .setKeyField('source')
                .setHideCheckboxColumn(false)
                .addColumn(new utl.Ldt.Col('Source field (Salesforce)', 'source', 'text'    ))
                .addColumn(new utl.Ldt.Col('Salesforce field Type',     'sfFtype','text'    ))
                .addColumn(new utl.Ldt.Col('Custom field?',             'custom', 'boolean' ))
                .addColumn(new utl.Ldt.Col('Target field (Data Cloud)', 'target', 'text'    ))
                .addColumn(new utl.Ldt.Col('Data Cloud Field Type',     'dcFtype','text'    ))
            ;

            // Get the describe for the fields
            DescribeSObjectResult sdr = ((sObject) Type.forName('Schema.' + sObjectName).newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);

            // Iterate the fields and add the results to an output table
            for(SObjectField field : sdr.fields.getMap().values()){

                DescribeFieldResult sfr = field.getDescribe();

                ldt.addRow(new Map<String,Object>{
                    'source'  => sfr.name,
                    'sfFtype' => String.valueOf(sfr.SoapType),
                    'custom'  => sfr.custom,
                    'target'  => sfr.name,
                    'dcFtype' => SOAP_TYPE_DATA_CLOUD_DATA_TYPE_MAP.get(sfr.SoapType)
                });
            }

            // Return the data
            return ldt;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                   DATA CLOUD QUERY AURA METHODS                                      **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static utl.Ldt getDcQueryTable(String namedCredentialName, String query, String apiVersion){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Setup the output datatable
            utl.Ldt ldt = new utl.Ldt()
                .setKeyField('ldtKey')
                .setHideCheckboxColumn(true)
                .setShowRowNumberColumn(false)
            ;

            // Create a list to hold the column names
            Set<String> columnNames = new Set<String>{};

            // Create a list to hold the key column
            Integer[] ldtKeyColumn = new Integer[]{};

            // Cast the response as an object so we can get both the data and metadata
            Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(
                Dc.executeQuery(namedCredentialName, query, apiVersion)
                    .getResponse()
                    .getBody()
            );

            // Populate unique keys for the LDT
            for(Integer i=0, max= (Integer) response.get('rowCount'); i<max;i++){
                ldtKeyColumn.add(i+1);
            }

            // Create the columns
            for(Dc.FieldMetadata fmdt : Dc.getFieldMetadata(utl.Jsn.getObjectMap('metadata', response), false)){
                
                // Create the initial column based on the type mapping
                utl.Ldt.Col col = new utl.Ldt.Col(
                        fmdt.name, 
                        apiVersion == 'v1' ? fmdt.name : String.valueOf(fmdt.placeInOrder),
                        DATA_CLOUD_DATA_TYPE_LDT_DATA_TYPE_MAP.get(fmdt.type)
                    )
                    .setInitialWidth(fmdt.name.length() < 10 ? 120 : fmdt.name.length() * 12)
                ;

                // Format the date time fields
                if(fmdt.type == 'TIMESTAMP WITH TIME ZONE'){
                    if(apiVersion=='v1'){
                        col.setTypeAttributes(
                            new utl.Ldt.TypeAttributes()
                                .setDay('2-digit')
                                .setYear('numeric')
                                .setMonth('numeric')
                                .setHour('2-digit')
                                .setMinute('2-digit')
                                .setSecond('2-digit')
                        );
                    }else{
                        // In API v2 the timestamp cannot be handled, so change it into text
                        col.setType('text');
                    }
                }

                // Add the column
                ldt.addColumn(col);
            }

            // Return the table
            return ldt.setData(
                new utl.JsnTbl()
                    .create(utl.Jsn.getObjectList('data', response))
                    .updateColumnNames(columnNames)
                    .upsertColumnData('ldtKey', ldtKeyColumn, columnNames.size())
                    .getKeyValueData()
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String getDcQueryCsv(String namedCredentialName, String query, String apiVersion){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

           // Cast the response as an object so we can get both the data and metadata
            Map<String,Object> response = (Map<String,Object>) JSON.deserializeUntyped(
                Dc.executeQuery(namedCredentialName, query, apiVersion)
                    .getResponse()
                    .getBody()
            );

            // Create a datatable
            return new utl.JsnTbl()
                .create(utl.Jsn.getObjectList('data',response))
                .updateColumnNames(
                    Dc.getOrderedColumnNamesFromMetadata(
                        utl.Jsn.getObjectMap('metadata', response),
                        true // remove postfix
                    )
                )
                .getCsvString()
            ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String getDcQueryRaw(String namedCredentialName, String query, String apiVersion){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');
            
            // Return the raw response body
            return Dc.executeQuery(namedCredentialName, query, apiVersion)
                .getResponse()
                .getBody();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String getQueryPlaceholder(String mdtConfigName, String fieldSelection){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Create a query 
            String query = 'SELECT ';
           
            // Add mapping details
            for(Data_Cloud_Ingestion_API_Field_Mapping__mdt mapping : record.Data_Cloud_Ingestion_API_Field_Mappings__r){
                switch on fieldSelection {
                    when 'pk'{
                        if(mapping.Is_Primary_Key__c){
                            query+=(query == 'SELECT ' ? '' : ', ') + mapping.Target__c + '__c';
                        }
                    }
                    when 'pket'{
                        if(mapping.Is_Primary_Key__c || mapping.Is_Event_Time_Field__c){
                            query+=(query == 'SELECT ' ? '' : ', ') + mapping.Target__c + '__c';
                        }
                    }
                    when else {
                        query+=(query == 'SELECT ' ? '' : ', ') + mapping.Target__c + '__c'; 
                    }
                }
            }
            
            // Use the utility to generate a sample query
            return query + ' FROM ' + record.Data_Lake_Object_Name__c + ' LIMIT 100';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    /** **************************************************************************************************** **
     **                                       DATA GRAPH AURA METHODS                                        **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static List<Map<String,String>>  getDcNamedCredentialOptions(){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Return the named credential picklist options
            return Dc.getDataCloudNamedCredentialPicklistOptions();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static List<Map<String,String>> getDataGraphOptions(String namedCredentialName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // List containing the output picklist options
            List<Map<String,String>> output = new List<Map<String,String>>();

            // Get the metadata an convert names into list
            for(Map<String,Object> dataGraphMetadata : Dc.getAllDataGraphMetadata(namedCredentialName)){
                output.add(new Map<String,String>{
                    'label' => (String) dataGraphMetadata.get('developerName'),
                    'value' => (String) dataGraphMetadata.get('developerName')
                });
            }

            // Return the named credential picklist options
            return output;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Map<String,Object> getDataGraphDetails(String namedCredentialName, String dataGraphName){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Key counter for LWC
            Integer key = 0;

            // Data tables for the output
            List<Map<String, Object>> dataTables = new List<Map<String, Object>>();

            // Fetch the detailed metadata
            Map<String,Object> dgMdt = Dc.getDetailedDataGraphMetadata(namedCredentialName, dataGraphName);

            // List containing the output pk options
            List<Map<String,String>> pkOptions = new List<Map<String,String>>();

            // Create a the picklist values for key fields
            for(Object o : utl.Jsn.getObjectList('object.fields', dgMdt)){
                Map<String,Object> om = (Map<String,Object>) o;
                if(om.get('keyCol') == 'true'){
                    pkOptions.add(new Map<String,String>{
                        'label' => (String) om.get('developerName'),
                        'value' => (String) om.get('developerName')
                    });
                }
            }

            // Add overview table to the output
            dataTables.add(
                new Map<String, Object>{
                    'key'    => key++,
                    'header' => 'Overview Table',
                    'ldt'    => new utl.Ldt()
                    .setupKeyValue()
                    .setData(
                        new utl.JsnTbl()
                            .setAttributeFilter(new Set<String>{'object'})
                            .create(dgMdt)
                            .getKeyValuePairData()
                        )
                }
            );
            
            // Add primary object table
            dataTables.add(
                new Map<String, Object>{
                    'key'    => key++, 
                    'header' => 'Primary Object Details',
                    'ldt'    =>  new utl.Ldt()
                        .setupKeyValue()
                        .setData(
                            new utl.JsnTbl()
                                .setAttributeFilter(new Set<String>{'relatedObjects', 'fields', 'recencyCriteria'})
                                .create(utl.Jsn.getObjectMap('object',dgMdt))
                                .getKeyValuePairData()
                            )
                }
            );

            // Primary Object fields
            dataTables.add(
                new Map<String, Object>{ 
                    'key'    => key++,
                    'header' => 'Primary Object Fields',
                    'ldt'    => addFieldColumns(
                        new utl.Ldt()
                            .setData(
                                new utl.JsnTbl()
                                    .setAttributeFilter(new Set<String>{'relatedObjects', 'fields'})
                                    .create(utl.Jsn.getObjectList('object.fields', dgMdt))
                                    .getKeyValueData()
                            )
                    )
                }
            );
                
            // Add related table
            for(Object o : utl.Jsn.getObjectList('object.relatedObjects', dgMdt)){
                dataTables.add(
                    new Map<String, Object>{ 
                        'key'    => key++,
                        'header' => 'Related Object Details - ' + ((Map<String, Object>) o ).get('developerName'),
                        'ldt'    => new utl.Ldt()
                            .setupKeyValue()
                            .setData(
                                new utl.JsnTbl()
                                    .setAttributeFilter(new Set<String>{'relatedObjects','fields'})
                                    .create((Map<String, Object>) o )
                                    .getKeyValuePairData()
                                )
                    }
                );
   
                dataTables.add(
                    new Map<String, Object>{ 
                        'key'    => key++,
                        'header' => 'Related Object Fields - ' + ((Map<String, Object>) o ).get('developerName'),
                        'ldt'    => addFieldColumns(
                            new utl.Ldt()
                                .setData(
                                    new utl.JsnTbl()
                                        .create(utl.Jsn.getObjectList('fields', (Map<String, Object>) o))
                                        .getKeyValueData()
                                )
                        )
                    }
                );
            }

            // Return all the details
            return new Map<String,Object>{
                'dataTables' => dataTables,
                'pkOptions'  => pkOptions
            };

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static Object getDataGraph(String namedCredentialName, String dataGraphName, String dataGraphRecordId, String resultFormat){
        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            switch on resultFormat {
                
                when 'table' {
                    
                    utl.JsnTbl jsnTbl = getDataGraphJsnTable(namedCredentialName, dataGraphName, dataGraphRecordId);

                    // Add the columns
                    utl.Ldt ldt = new utl.Ldt();
                    for(String columnName : jsnTbl.getColumnNames()){
                        ldt.addColumn(new utl.Ldt.Col(columnName,columnName));
                    }
                    return ldt.setData(jsnTbl.getKeyValueData());
                    
                }

                when 'csv' {
                    return getDataGraphJsnTable(namedCredentialName, dataGraphName, dataGraphRecordId).getCsvString();
                }

                when 'keyvalue' {
                    return new utl.Ldt()
                        .setupKeyValue()
                        .setData(getDataGraphJsnTable(namedCredentialName, dataGraphName, dataGraphRecordId).getKeyValuePairData())
                    ;
                }

                when 'jsonblob' {
                    return Dc.getDataGraphJsonBlob(namedCredentialName, dataGraphName, dataGraphRecordId);
                }

                when 'raw' {
                    return Dc.getDataGraph(namedCredentialName, dataGraphName, dataGraphRecordId);
                }

                when else {
                   throw new Dc.DataCloudUtilException('Invalid response format'); 
                }
            }

        }catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    private static utl.JsnTbl getDataGraphJsnTable(String namedCredentialName, String dataGraphName, String dataGraphRecordId){
       return new utl.JsnTbl()
            .create(
                (Map<String,Object>) JSON.deserializeUntyped(
                    Dc.getDataGraphJsonBlob(namedCredentialName, dataGraphName, dataGraphRecordId)
                )
            )
        ;
    }




    /** **************************************************************************************************** **
     **                                      SOQL QUERY AURA METHODS                                         **
     ** **************************************************************************************************** **/
    @AuraEnabled
    public static String getSoqlQueryCsv(String mdtConfigName, String query, Boolean tooling){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Map to hold the mappings
            Map<String,String> mapping = new Map<String,String>();

            if(mdtConfigName != null){
                // Create the mapping
                mapping = Dc.createFieldMapping(Dc.getMetadataRecord(mdtConfigName).Data_Cloud_Ingestion_API_Field_Mappings__r);
            }

            // Execute the query
            utl.JsnTbl table = executeSoqlQuery(query, tooling);
            table.updateColumnNames(mapping);

            // Return the table as CSV
            return table.getCsvString();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled
    public static String getSoqlQueryRaw(String mdtConfigName, String query, Boolean tooling){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Map to hold the mappings
            Map<String,String> mapping = new Map<String,String>();

            if(mdtConfigName != null){
                // Create the mapping
                mapping = Dc.createFieldMapping(Dc.getMetadataRecord(mdtConfigName).Data_Cloud_Ingestion_API_Field_Mappings__r);
            }

            // Execute the query and return the result
            return new utl.Rst(true)
                .setEndpoint(((tooling) ? '/tooling/' : '' ) +  '/query?q=' + EncodingUtil.urlEncode(query,'UTF-8'))
                .setMethod('GET')
                .call()
                .getResponse()
                .getBody()
            ;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static utl.Ldt getSoqlQueryTable(String mdtConfigName, String query, Boolean tooling){

        try{
            // Force an exception for testing purposes
            utl.Tst.forceException('AURA_EXCEPTION');

            // Extract the object name from the Query String
            String sObjectName = query?.toLowerCase()?.split('from')[1].trim()?.substringBefore(' ');

            // Input validation
            if(Type.forName('Schema.' + sObjectName) == null){
                throw new Dc.DataCloudUtilException(String.format('sObject of type "{0}" does not exist in the metadata', new String[]{sObjectName}));
            }

            // Get the describe field result for the sObject
            DescribeSObjectResult sdr = ((sObject) Type.forName('Schema.' + sObjectName).newInstance()).getSObjectType().getDescribe(SObjectDescribeOptions.DEFERRED);

            // Execute the query
            utl.JsnTbl jsnTbl = executeSoqlQuery(query, tooling);

            // Create the configuration table
            utl.Ldt ldt = new utl.Ldt()
                .setData(jsnTbl.getKeyValueData())
            ;

            // Create the columns, get the name, label and field type from the metadata
            for(String columnName : jsnTbl.getColumnNames()){
                
                // If the field exists in the metadata create a tailored column
                if(sdr.fields.getMap().containsKey(columnName.toLowerCase())){
                    
                    // Describe the field
                    DescribeFieldResult sfr = sdr.fields.getMap().get(columnName.toLowerCase()).getDescribe();

                    // Setup the column config
                    utl.Ldt.Col col = new utl.Ldt.Col(  
                        sfr.getLabel(),
                        sfr.getName(),
                        SOAP_TYPE_LDT_DATA_TYPE_MAP.get(sfr.getSoapType())
                    );

                    // Add the date time formatting
                    if(sfr.getSoapType() == SOAPType.DateTime){
                        col.setTypeAttributes(
                            new utl.Ldt.TypeAttributes()
                                .setDay('2-digit')
                                .setYear('numeric')
                                .setMonth('numeric')
                                .setHour('2-digit')
                                .setMinute('2-digit')
                                .setSecond('2-digit')
                        );
                    }

                    // Add the column
                    ldt.addColumn(col);
                }else{
                    // Default text column
                    ldt.addColumn(new utl.Ldt.Col(columnName,columnName,'text'));
                }
            }

            // Return the lightning data table
            return ldt;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled
    public static String generateQueryFromMapping(String mdtConfigName){
        try{
           // Force an exception for testing purposes
           utl.Tst.forceException('AURA_EXCEPTION');

            // Query the record
            Data_Cloud_Ingestion_API_Configuration__mdt record = Dc.getMetadataRecord(mdtConfigName);

            // Return the query string
            String query = 'SELECT ';
                   query+= String.join(Dc.createFieldMapping(record.Data_Cloud_Ingestion_API_Field_Mappings__r).keySet(),', ');
                   query+= ' FROM ' + record.sObject_Name__c + ' ORDER BY CreatedDate DESC LIMIT 2000';

            // Return the query string
            return query;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage() + e.getStackTraceString());
        }
    }


    /** **************************************************************************************************** **
     **                                       PRIVATE SUPPORT METHODS                                        **
     ** **************************************************************************************************** **/
    @TestVisible
    private static utl.JsnTbl executeSoqlQuery(String query, Boolean tooling){

        // Input validation
        if(String.isBlank(query)){
            throw new Dc.DataCloudUtilException('SOQL Query cannot be empty');
        }

        // Execute the query
        utl.Rst callout = new utl.Rst(true)
            .setEndpoint(((tooling) ? '/tooling/' : '' ) +  '/query?q=' + EncodingUtil.urlEncode(query,'UTF-8'))
            .setMethod('GET')
            .call()
        ;

        // Create a datatable
        utl.JsnTbl table = new utl.JsnTbl()
            .setAttributeFilter(new Set<String>{'attributes', 'done', 'totalSize'})
            .setListNameFilter(new Set<String>{'records'})
            .create(utl.Jsn.getObjectList('records',(Map<String,Object>)JSON.deserializeUntyped(callout.getResponse().getBody())))
        ;

        // Return the output as a CSV string
        return table;
    }


    /**
     * @description Method to add Data Cloud Field columns to a LDT based on Data Graph Metadata
     */
    private static utl.Ldt addFieldColumns(utl.Ldt ldt){
        return ldt 
            .addColumn(new utl.Ldt.Col('developerName',     'developerName'))
            .addColumn(new utl.Ldt.Col('ssot__Id__c',       'ssot__Id__c'))
            .addColumn(new utl.Ldt.Col('lookupCol',         'lookupCol'))
            .addColumn(new utl.Ldt.Col('length',            'length'))
            .addColumn(new utl.Ldt.Col('dataType',          'dataType'))
            .addColumn(new utl.Ldt.Col('keyCol',            'keyCol'))
            .addColumn(new utl.Ldt.Col('keyQualifierName',  'keyQualifierName'))
            .addColumn(new utl.Ldt.Col('usageTag',          'usageTag'))
            .addColumn(new utl.Ldt.Col('ciFieldType',       'ciFieldType'))
            .addColumn(new utl.Ldt.Col('isProjected',       'isProjected'))
        ;
    }


    /**
     * @description Method for generating sample data based on the data type
     */
    @TestVisible
    private static Object generateSampleData(String dataType){
        switch on dataType {
            when 'numberField' {
                return Integer.valueof((Math.random() * 1000000));
            }
            when 'dateField' {
                return Date.today().addDays(Integer.valueof((Math.random() * 100)));
            }
            when 'dateTimeField' {
                return Datetime.now()
                        .addDays(   Integer.valueof((Math.random() * 100)))
                        .addHours(  Integer.valueof((Math.random() * 100)))
                        .addMinutes(Integer.valueof((Math.random() * 100)))
                        .addSeconds(Integer.valueof((Math.random() * 100)))
                ;
            }
            when 'uuidField' {
                return utl.Rst.guid();
            }
            when 'urlField' {
                return 'https://' + (String.valueOf(EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,10)) + '.example.com') .escapeCsv();
            }
            when 'emailField' {
                return (String.valueOf(EncodingUtil.convertToHex(crypto.generateAesKey(128)).substring(0,10)) + '@example.com').escapeCsv(); 
            }
            when 'phoneField' {
                return '078-' + Integer.valueof((Math.random() * 10000));
            }
            when 'booleanField'{
                return (Math.mod(Integer.valueof((Math.random() * 10000)), 2) == 0) ? 'false' : 'true';
            }
            when 'percentField' {
                return Decimal.valueof((Math.random() * 100000)).setScale(2);
            }
        }
        // Add return to please the compiler
        return String.valueOf(EncodingUtil.convertToHex(crypto.generateAesKey(192)).substring(0,15)).escapeCsv();
    }
}