String ingestionApiName  = 'JST_Test_Ingestion_API_03';
String ingestionApiLabel = 'JST Test Ingestion API 03';

String connectorName     = 'JST_Test_Connector_03';
String connectorLabel    = 'JST Test Connector 03';
String connectorPrefix   = 'TC3';

String objectName        = 'JST_Test_Object_03';
String objectLabel       = 'JST Test Object 03';

/**
 * 02) Create the DcMetadata.DataConnectorIngestApi object
 */
DcMetadata.DataConnectorIngestApi dataConnectorIngestApi = new DcMetadata.DataConnectorIngestApi(ingestionApiName, ingestionApiLabel);


/**
 * 02) Create the DcMetadata.DataSource object
 */
DcMetadata.DataSource dataSource = new DcMetadata.DataSource(connectorName, connectorLabel, connectorPrefix);


/**
 * 02) Create the DcMetadata.ExternalDataConnector object with the 
 */
DcMetadata.ExternalDataTranObject externalDataTranObject = new DcMetadata.ExternalDataTranObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.ExternalDataTranField('Test_Text_Field',     'Test_Text_Field',       objectName, 'textField',     connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Number_Field',   'Test_Number_Field',     objectName, 'numberField',   connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Date_Field',     'Test_Date_Field',       objectName, 'dateField',     connectorName ))
    .addField(new DcMetadata.ExternalDataTranField('Test_Date_Time_Field','Test_Date_Time_Field',  objectName, 'datetimeField', connectorName ))
;

DcMetadata.ExternalDataConnector externalDataConnector = new DcMetadata.ExternalDataConnector(ingestionApiName,connectorName,connectorLabel);

DcMetadata.ExternalDataConnector externalDataConnectorWithObjects = new DcMetadata.ExternalDataConnector(ingestionApiName,connectorName,connectorLabel)
    .addObject(externalDataTranObject)
;


/**
 * 03) Create the DcMetadata.DataSourceObject object 
 */
DcMetadata.DataSourceObject dataSourceObject = new DcMetadata.DataSourceObject(objectName, objectLabel, connectorName)
    .addField(new DcMetadata.DataSourceField('Test_Text_Field',     'Test Text Field',       objectName, 'textField'     ))
    .addField(new DcMetadata.DataSourceField('Test_Number_Field',   'Test Number Field',     objectName, 'numberField'   ))
    .addField(new DcMetadata.DataSourceField('Test_Date_Field',     'Test Date Field',       objectName, 'dateField'     ))
    .addField(new DcMetadata.DataSourceField('Test_Date_Time_Field','Test Date Time Field',  objectName, 'datetimeField' ))
;


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
 * 04) Create the DcMetadata.Custom object 
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



System.debug('----------- CREATE INGESTION API ---------');
//System.debug(createIngestionApi(dataConnectorIngestApi).getResponse().getBody());

System.debug('----------- CREATE DATA SOURCE ---------');
//System.debug(createDataSource(dataSource).getResponse().getBody());

System.debug('----------- CREATE EXTERNAL DATA CONNECTOR API ---------');
//System.debug(createExternalDataConnector(externalDataConnector).getResponse().getBody());

System.debug('----------- CREATE MKT DATA TRAN OBJECT ---------');
//System.debug(createMkDataTranObject(mktDataTranObject).getResponse().getBody());

System.debug('----------- CREATE EXTERNAL DATA TRAN OBJECT ---------');
//System.debug(createExternalDataTranObject(externalDataConnectorWithObjects).getResponse().getBody());

System.debug('----------- CREATE DATA SOURCE OBJECT ---------');
//System.debug(createDataSourceObject(dataSourceObject).getResponse().getBody());

System.debug('----------- CREATE DATA LAKE OBJECT ---------');
//System.debug(createDataLakeObject(dataLakeObject).getResponse().getBody());

System.debug('----------- CREATE DATA STREAM DEFINITION ---------');
//System.debug(createDataStreamDefinition().getResponse().getBody());
System.debug('--------------------');



/**
 * @description Method to create an ingestion API
 */
utl.Soap createIngestionApi(DcMetadata.DataConnectorIngestApi dcia){
    
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            dcia.getMdtName(),
            dcia.getMdtMap()
        )
        .call()
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
        .call()
    ;
}

utl.Soap createExternalDataTranObject(DcMetadata.ExternalDataConnector edc){   
    return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            edc.getMdtName(),
            edc.getMdtMap()
        )
        .call()
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
        .call()
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
        .call()
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
        .call()
    ;
}


utl.Soap createDataLakeObject(DcMetadata.CustomObject dlo){
     return new utl.MdtWsdl('upsertMetadata')
        .addCredMetadata(
            dlo.getMdtName(),
            dlo.getMdtMap()
        )
        .call()
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
        .call()
    ;
}

