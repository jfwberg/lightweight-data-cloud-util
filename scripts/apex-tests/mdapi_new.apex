String ingestionApiName  = 'JST_Test_Ingestion_API_04';
String ingestionApiLabel = 'JST Test Ingestion API 04';

String connectorName     = 'JST_Test_Connector_04';
String connectorLabel    = 'JST Test Connector 04';
String connectorPrefix   = 'TC4';

String objectName        = 'JST_Test_Object_04';
String objectLabel       = 'JST Test Object 04';

/**
 * 01) Create the DcMetadata.DataConnectorIngestApi object
 */
DcMetadata.DataConnectorIngestApi dataConnectorIngestApi = new DcMetadata.DataConnectorIngestApi(ingestionApiName, ingestionApiLabel);

/**
 * 02) Create the DcMetadata.DataSource object
 */
DcMetadata.DataSource dataSource = new DcMetadata.DataSource(connectorName, connectorLabel, connectorPrefix);

/**
 * 03) Create the DcMetadata.ExternalDataConnector object with the
 */
DcMetadata.ExternalDataConnector externalDataConnector = new DcMetadata.ExternalDataConnector(ingestionApiName,connectorName,connectorLabel);

/**
 * 04) Create the DcMetadata.MktDataTranObject object
 */
DcMetadata.MktDataTranObject mktDataTranObject = new DcMetadata.MktDataTranObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.MktDataTranField('Test_Text_Field',     'Test Text Field',       objectName, 'textField'     ))
    .addField(new DcMetadata.MktDataTranField('Test_Number_Field',   'Test Number Field',     objectName, 'numberField'   ))
    .addField(new DcMetadata.MktDataTranField('Test_Date_Field',     'Test Date Field',       objectName, 'dateField'     ))
    .addField(new DcMetadata.MktDataTranField('Test_Date_Time_Field','Test Date Time_Field',  objectName, 'datetimeField' ))
;

/**
 * 05) Create the DcMetadata.ExternalDataTranObject object
 */
DcMetadata.ExternalDataTranObject externalDataTranObject = new DcMetadata.ExternalDataTranObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.ExternalDataTranField('Test_Text_Field',     'Test_Text_Field',       objectName, 'textField',     connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Number_Field',   'Test_Number_Field',     objectName, 'numberField',   connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Date_Field',     'Test_Date_Field',       objectName, 'dateField',     connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Date_Time_Field','Test_Date_Time_Field',  objectName, 'datetimeField', connectorName ))
;

// 05) Create an external data connector with objects
DcMetadata.ExternalDataConnector externalDataConnectorWithObjects = new DcMetadata.ExternalDataConnector(ingestionApiName,connectorName,connectorLabel)
    .addObject(externalDataTranObject)
;

/**
 * 06) Create the DcMetadata.DataSourceObject object
 */
DcMetadata.DataSourceObject dataSourceObject = new DcMetadata.DataSourceObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.DataSourceField('Test_Text_Field',     'Test Text Field',       objectName, 'textField'     ))
    .addField(new DcMetadata.DataSourceField('Test_Number_Field',   'Test Number Field',     objectName, 'numberField'   ))
    .addField(new DcMetadata.DataSourceField('Test_Date_Field',     'Test Date Field',       objectName, 'dateField'     ))
    .addField(new DcMetadata.DataSourceField('Test_Date_Time_Field','Test Date Time Field',  objectName, 'datetimeField' ))
;


/**
 * 07) Create the DcMetadata.Custom object (Data Lake object)
 */
DcMetadata.CustomObject dataLakeObject = new DcMetadata.CustomObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.CustomField('Test_Text_Field',      'Test Text Field',       false, 'Text',     false, false ))
    .addField(new DcMetadata.CustomField('Test_Number_Field',    'Test Number Field',     false, 'Number',   false, false ))
    .addField(new DcMetadata.CustomField('Test_Date_Field',      'Test Date Field',       false, 'Date',     false, false ))
    .addField(new DcMetadata.CustomField('Test_Date_Time_Field', 'Test Date Time_Field',  false, 'DateTime', false, false ))
    .addField(new DcMetadata.CustomField('Primary_Key_Field',    'Primary Key Field',     false, 'Text',     false,  false ))
    .addField(new DcMetadata.CustomField('Record_Modified_Field','Record Modified Field', false, 'DateTime', false, true  ))
    .addField(new DcMetadata.CustomField('KQ_Primary_Key_Field', 'KQ_Primary_Key_Field',  true,  'Text',     true,  false ))
;


/**
 * 08) fix this
 */


/**
 * 09) Create the ObjectSourceTargetMap
 */
DcMetadata.ObjectSourceTargetMap objectSourceTargetMap = new DcMetadata.ObjectSourceTargetMap(connectorName, objectName)
    .addFieldMapping(new DcMetadata.FieldSourceTargetMap('Custom', false, connectorName+'_'+objectName, 'Test_Text_Field__c',      'Test_Text_Field'))
    .addFieldMapping(new DcMetadata.FieldSourceTargetMap('Custom', false, connectorName+'_'+objectName, 'Test_Number_Field__c',    'Test_Number_Field'))
    .addFieldMapping(new DcMetadata.FieldSourceTargetMap('Custom', false, connectorName+'_'+objectName, 'Test_Date_Field__c',      'Test_Date_Field'))
    .addFieldMapping(new DcMetadata.FieldSourceTargetMap('Custom', false, connectorName+'_'+objectName, 'Test_Date_Time_Field__c', 'Test_Date_Time_Field'))
;


System.debug('----------- CREATE INGESTION API ---------\n');
//System.debug('\n' + createIngestionApi(dataConnectorIngestApi).getRequest().getBody()+ '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE DATA SOURCE ---------\n');
//System.debug('\n' + createDataSource(dataSource).getRequest().getBody()+ '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE EXTERNAL DATA CONNECTOR API ---------\n');
//System.debug('\n' + createExternalDataConnector(externalDataConnector).getRequest().getBody()+ '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE MKT DATA TRAN OBJECT ---------\n');
//System.debug('\n' + createMkDataTranObject(mktDataTranObject).getRequest().getBody() + '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE EXTERNAL DATA TRAN OBJECT ---------\n');
//System.debug('\n' + createExternalDataTranObject(externalDataConnectorWithObjects).getRequest().getBody() + '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE DATA SOURCE OBJECT ---------\n');
//System.debug('\n' + createDataSourceObject(dataSourceObject).getRequest().getBody() + '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE DATA LAKE OBJECT ---------\n');
//System.debug('\n' + createDataLakeObject(dataLakeObject).getRequest().getBody() + '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE DATA STREAM DEFINITION ---------');
//System.debug('\n' + createDataStreamDefinition().getRequest().getBody() + '\n');
System.debug('--------------------\n');


System.debug('----------- CREATE OBJECT SOURCE TARGET MAP ---------');
System.debug( '\n\n' + createObjectSourceTargetMap(objectSourceTargetMap).getRequest().getBody() + '\n');
System.debug('--------------------\n');




/**
 * @description Method to create an ingestion API
 */
utl.Soap createObjectSourceTargetMap(DcMetadata.ObjectSourceTargetMap ostm){

    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            ostm.getMdtName(),
            ostm.getMdtMap()
        )
        .setupRequest()
    ;
}




/**
 * @description Method to create an ingestion API
 */
utl.Soap createIngestionApi(DcMetadata.DataConnectorIngestApi dcia){

    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            dcia.getMdtName(),
            dcia.getMdtMap()
        )
        .setupRequest()
    ;
}


/**
 * @description Method to create an ingestion API
 */
utl.Soap createExternalDataConnector(DcMetadata.ExternalDataConnector edc){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            edc.getMdtName(),
            edc.getMdtMap()
        )
        .setupRequest()
    ;
}

utl.Soap createExternalDataTranObject(DcMetadata.ExternalDataConnector edc){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            edc.getMdtName(),
            edc.getMdtMap()
        )
        .setupRequest()
    ;
}




/**
 * @description
 */
utl.Soap createMkDataTranObject(DcMetadata.MktDataTranObject kdto){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            kdto.getMdtName(),
            kdto.getMdtMap()
        )
        .setupRequest()
    ;
}



/**
 * @description Method to create an Data Source
 */
utl.Soap createDataSource(DcMetadata.DataSource ds){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            ds.getMdtName(),
            ds.getMdtMap()
        )
        .setupRequest()
    ;
}


/**
 * @description Method to create an ingestion API
 */
utl.Soap createDataSourceObject(DcMetadata.DataSourceObject dso){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            dso.getMdtName(),
            dso.getMdtMap()
        )
        .setupRequest()
    ;
}


utl.Soap createDataLakeObject(DcMetadata.CustomObject dlo){
     return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            dlo.getMdtName(),
            dlo.getMdtMap()
        )
        .setupRequest()
    ;
}


utl.Soap createDataStreamDefinition(){
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            'DataStreamDefinition',
            new Map<String,Object>{
                'fullName'                    => connectorName + '_' + objectName,
                'areHeadersIncludedInFile'    => false,
                'bulkIngest'                  => false,
                'creationType'                => 'Custom',
                'dataConnector'               => connectorName,
                'dataConnectorType'           => 'IngestApi',
                'dataPlatformDataSetItemName' => 'INGESTAPI',
                'dataSource'                  => connectorName,
                'isLimitedToNewFiles'         => false,
                'isMissingFileFailure'        => false,
                'masterLabel'                 => connectorLabel + '_' + objectLabel,
                'mktDataLakeObject'           => connectorName  + '_' + objectName + '__dll', // works but changing it to something else blows up
                'mktDataTranObject'           => connectorName  + '_' + objectName
            }
        )
        .setupRequest()
    ;
}

