public with sharing class DcMetadata {

    // Constant
    private final static Map<String,String> DATA_TYPE_MAP = new Map<String,String>{
        'textField'     => 'S',
        'numberField'   => 'N',
        'dateField'     => 'D',
        'datetimeField' => 'F',
        'S'             => 'S',
        'N'             => 'N',
        'D'             => 'D',
        'F'             => 'F'
    };



    public class DataConnectorIngestApi{

        // Private Variables
        private String fullName;
        private String masterLabel;

        public DataConnectorIngestApi(String fullName, String masterLabel){
            this.fullName   = fullName;
            this.masterLabel= masterLabel;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'DataConnectorIngestApi';
        }

        public Map<String,Object> getMdtMap(){
            return new Map<String,Object>{
                'fullName'    => this.fullName,
                'masterLabel' => this.masterLabel,
                'sourceName'  => this.fullName
            };
        }
    }


    public class ExternalDataConnector{

        // Private Variables
        private String configurationName;
        private String fullName;
        private String masterLabel;
        private ExternalDataTranObject[] objects = new ExternalDataTranObject[]{};

        // Constructor
        public ExternalDataConnector(String configurationName, String fullName, String masterLabel){
            this.configurationName = configurationName;
            this.fullName          = fullName;
            this.masterLabel       = masterLabel;
        }

        // Method to add an object to the connector
        public ExternalDataConnector addObject(ExternalDataTranObject obj){
            this.objects.add(obj);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'ExternalDataConnector';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'                  => this.fullName,
                'dataConnectionStatus'      => 'Connected',
                'dataConnectorConfiguration'=> this.configurationName,
                'dataConnectorType'         => 'IngestApi',
                'dataPlatform'              => 'Ingest_Api',
                'externalDataTranObjects'   => new List<Map<String,Object>>(),
                'masterLabel'               => this.masterLabel
            };

            // Add each field map to the object map
            for(ExternalDataTranObject obj : this.objects){
                ((List<Map<String,Object>>) outputMap.get('externalDataTranObjects')).add(obj.getMdtMap());
            }

            // return the map
            return outputMap;
        }
    }


    public class ExternalDataTranObject{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String connectorName;
        private ExternalDataTranField[] fields = new ExternalDataTranField[]{};

        // Constructors
        public ExternalDataTranObject(String fullName, String masterLabel, String connectorName){
            this.fullName     = fullName;
            this.masterLabel  = masterLabel;
            this.connectorName= connectorName;
        }

        public ExternalDataTranObject addField(ExternalDataTranField field){
            this.fields.add(field);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'ExternalDataTranObject';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create the object map
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'                => this.fullName,
                'availabilityStatus'      => 'Available',
                'creationType'            => 'Custom',
                'externalDataTranFields'  => new List<Map<String,Object>>(),
                'masterLabel'             => this.masterLabel,
                'mktDataTranObject'       => this.connectorName + '_' + this.fullName,
                'objectCategory'          => 'Salesforce_SFDCReferenceModel_0_93.Related'
            };

            // Add each field map to the object map
            for(ExternalDataTranField field : this.fields){
                ((List<Map<String,Object>>) outputMap.get('externalDataTranFields')).add(field.getMdtMap());
            }

            return outputMap;
        }
    }


    public class ExternalDataTranField{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String objectName;
        private String dataType;
        private String connectorName;

        // Constructor
        public ExternalDataTranField(String fullName, String masterLabel, String objectName, String dataType, String connectorName){
            this.fullName      = fullName;
            this.masterLabel   = masterLabel;
            this.objectName    = objectName;
            this.dataType      = DATA_TYPE_MAP.containsKey(dataType) ? DATA_TYPE_MAP.get(dataType) : 'S' ;
            this.connectorName = connectorName;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'ExternalDataTranField';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){
            return new Map<String,Object>{
                'fullName'         => this.fullName,
                'creationType'     => 'Custom',
                'datatype'         => this.dataType,
                'externalName'     => this.fullName,
                'isDataRequired'   => false,
                'length'           => 0,
                'masterLabel'      => this.masterLabel,
                'mktDataTranField' => this.connectorName + '_' + this.objectName + '.' + this.fullName + '__c',
                'precision'        => 0,
                'primaryIndexOrder'=> 0,
                'scale'            => 0,
                'sequence'         => 0
            };
        }
    }


    public class DataSource implements IDataCloudMetadata{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String prefix;

        // Constructor
        public DataSource(String fullName, String masterLabel, String prefix){
            this.fullName   = fullName;
            this.masterLabel= masterLabel;
            this.prefix     = prefix;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'DataSource';
        }

        public Map<String,Object> getMdtMap(){
            return new Map<String,Object>{
                'fullName'    => this.fullName,
                'masterLabel' => this.masterLabel,
                'prefix'      => this.prefix
            };
        }
    }


    public class DataSourceObject implements IDataCloudMetadata{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String connectorName;
        private DataSourceField[] fields = new DataSourceField[]{};

        // Constructor
        public DataSourceObject(String fullName, String masterLabel, String connectorName){
            this.fullName     = fullName;
            this.masterLabel  = masterLabel;
            this.connectorName= connectorName;
        }

        public DataSourceObject addField(DataSourceField field){
            this.fields.add(field);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'DataSourceObject';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create the object map
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'                 => this.connectorName + '_' + this.fullName,
                'dataSource'               => this.connectorName,
                'externalRecordIdentifier' => connectorName + '_' + fullName,
                'dataSourceFields'         => new List<Map<String,Object>>(),
                'masterLabel'              => this.masterLabel
            };

            // Add each field map to the object map
            for(DataSourceField field : this.fields){
                ((List<Map<String,Object>>) outputMap.get('dataSourceFields')).add(field.getMdtMap());
            }
            return outputMap;
        }
    }


    public class DataSourceField implements IDataCloudMetadata{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String datatype;
        private String objectName;

        // Constant
        private final Map<String,String> DATA_TYPE_MAP = new Map<String,String>{
            'textField'     => 'S',
            'numberField'   => 'N',
            'dateField'     => 'D',
            'datetimeField' => 'F',
            'S'             => 'S',
            'N'             => 'N',
            'D'             => 'D',
            'F'             => 'F'
        };

        // Constructor
        public DataSourceField(String fullName, String masterLabel, String objectName, String dataType){
            this.fullName   = fullName;
            this.masterLabel= masterLabel;
            this.objectName = objectName;
            this.dataType   = DATA_TYPE_MAP.containsKey(dataType) ? DATA_TYPE_MAP.get(dataType) : 'S' ;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'DataSourceField';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){
            return new Map<String,Object>{
                'fullName'         => this.fullName,
                'datatype'         => this.dataType,
                'externalName'     => this.objectName + '.' + this.fullName,
                'masterLabel'      => this.masterLabel
            };
        }
    }



    public class MktDataTranObject implements IDataCloudMetadata{

        // Private Variables
        String fullName;
        String masterLabel;
        String connectorName;
        MktDataTranField[] fields = new MktDataTranField[]{};

        // Constructor
        public MktDataTranObject(String fullName, String masterLabel, String connectorName){
            this.fullName     = fullName;
            this.masterLabel  = masterLabel;
            this.connectorName= connectorName;
        }

        public MktDataTranObject addField(MktDataTranField field){
            this.fields.add(field);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'MktDataTranObject';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create the object map
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'          => this.connectorName + '_' + this.fullName,
                'connector'         => this.connectorName,
                'creationType'      => 'Custom',
                'dataSource'        => this.connectorName,
                'dataSourceObject'  => this.connectorName + '_' + this.fullName,
                'mktDataTranFields' => new List<Map<String,Object>>(),
                'masterLabel'       => this.masterLabel,
                'objectCategory'    => 'Salesforce_SFDCReferenceModel_0_93.Related'
            };

            // Add each field map to the object map
            for(MktDataTranField field : this.fields){
                ((List<Map<String,Object>>) outputMap.get('mktDataTranFields')).add(field.getMdtMap());
            }
            return outputMap;
        }
    }


    public class MktDataTranField implements IDataCloudMetadata{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String datatype;
        private String objectName;

        // Constructor
        public MktDataTranField(String fullName, String masterLabel, String objectName, String dataType){
            this.fullName   = fullName;
            this.masterLabel= masterLabel;
            this.objectName = objectName;
            this.dataType   = DATA_TYPE_MAP.containsKey(dataType) ? DATA_TYPE_MAP.get(dataType) : 'S' ;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'MktDataTranField';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){
            return new Map<String,Object>{
                'creationType'     => 'Custom',
                'fullName'         => this.fullName,
                'datatype'         => this.dataType,
                'externalName'     => this.objectName + '.' + this.fullName,
                'masterLabel'      => this.masterLabel
            };
        }
    }


    public class CustomObject implements IDataCloudMetadata{

        // Private Variables
        private String        fullName;
        private String        masterLabel;
        private String        connectorName;
        private CustomField[] fields = new CustomField[]{};

        // Constructor
        public CustomObject(String fullName, String masterLabel, String connectorName){
            this.fullName      = fullName;
            this.masterLabel   = masterLabel;
            this.connectorName = connectorName;

            // Create the fields required for each DLL
            this.createSystemFields();
        }

        public CustomObject addField(CustomField field){
            this.fields.add(field);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'CustomObject';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create a new map
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'      => this.connectorName + '_' + this.fullName + '__dll',
                'label'         => this.masterLabel,
                'fields'        => new List<Map<String,Object>>(),
                'mktDataLakeAttributes' => new Map<String,Object>{
                    'creationType'      => 'Custom',
                    'isEnabled'         => true,
                    'objectCategory'    => 'Salesforce_SFDCReferenceModel_0_93.Engagement'
                }
            };

            // Add each field map to the object map
            for(CustomField field : this.fields){
                ((List<Map<String,Object>>) outputMap.get('fields')).add(field.getMdtMap());
            }
            return outputMap;
        }

        // Each object requires the system fields to be added
        private void createSystemFields(){
            this.addField(new CustomField('DataSourceObject',     'Data Source Object',    true, 'Text',    false, false));
            this.addField(new CustomField('DataSource',           'Data Source',           true, 'Text',    false, false));
            this.addField(new CustomField('InternalOrganization', 'Internal Organization', true, 'Text',    false, false));
            this.addField(new CustomField('cdp_sys_PartitionDate','cdp_sys_PartitionDate', true, 'DateTime',false, false));
            this.addField(new CustomField('cdp_sys_SourceVersion','cdp_sys_SourceVersion', true, 'Text',    false, false));
        }
    }


    public class CustomField implements IDataCloudMetadata{

        // Private Variables
        private String  fullName;
        private String  masterLabel;
        private Boolean isSystem;
        private String  fieldType;
        private Boolean isKeyQualifier;
        private Boolean isRecordModified;

        // Constructor
        public CustomField(String fullName, String masterLabel, Boolean isSystem, String fieldType, Boolean isKeyQualifier, Boolean isRecordModified){
            this.fullName         = fullName;
            this.masterLabel      = masterLabel;
            this.isSystem         = isSystem;
            this.fieldType        = fieldType;
            this.isKeyQualifier   = isKeyQualifier;
            this.isRecordModified = isRecordModified;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'CustomField';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'           => this.fullName + '__c',
                'externalId'         => false,
                'isFilteringDisabled'=> false,
                'isNameField'        => false,
                'isSortingDisabled'  => false,
                'label'              => this.masterLabel,
                'required'           => false,
                'type'               => this.fieldType,
                'unique'             => false,
                'mktDataLakeFieldAttributes' => new Map<String,Object>{
                    'definitionCreationType' => this.isSystem ? 'System' : 'Custom',
                    'externalName'           => this.fullName,
                    'isRecordModified'       => false,
                    'isEventDate'           => isRecordModified, // Don't ask, update the name
                    'isInternalOrganization' => false,
                    'usageTag'               => isKeyQualifier ? 'KEY_QUALIFIER' : 'NONE'
                }
            };

            // For text fields add a length
            if(fieldType == 'Text'){
                outputMap.put('length', 60);
            }

            // For number fields add a length
            if(fieldType == 'Number'){
                outputMap.put('precision', 18);
                outputMap.put('scale',      6);
            }

            // If it's a key qualifier add the index
            if(isKeyQualifier){
               ((Map<String,Object>) outputMap.get('mktDataLakeFieldAttributes')).put('primaryIndexOrder', 1);
            }

            return outputMap;
        }
    }


    public class ObjectSourceTargetMap implements IDataCloudMetadata{

        // Private Variables
        private String fullName;
        private String masterLabel;
        private String creationType;
        private String sourceObjectName;
        private String targetObjectName;
        FieldSourceTargetMap[] fieldSourceTargetMaps = new FieldSourceTargetMap[]{};

        // Constructor
        public ObjectSourceTargetMap(String connectorName, String targetObjectName){
            this.sourceObjectName = connectorName + '_' + targetObjectName;
            this.targetObjectName = connectorName + '_' + targetObjectName + '__dll';

            this.fullName         = this.sourceObjectName + '_map_' + this.sourceObjectName;
            this.masterLabel      = this.sourceObjectName + '_map_' + this.sourceObjectName;
            this.creationType     = 'Custom';
            
            // move these fields to object constructor...
            this.addFieldMapping(new FieldSourceTargetMap('System', true, this.sourceObjectName, 'cdp_sys_PartitionDate__c', 'if(ISEMPTY(formulaField[\'Timestamp\'])) { null; } else { DAYPRECISION(formulaField[\'Timestamp\']); }'));
            this.addFieldMapping(new FieldSourceTargetMap('System', true, this.sourceObjectName, 'DataSource__c',            '\'' + connectorName         + '\'' ));
            this.addFieldMapping(new FieldSourceTargetMap('System', true, this.sourceObjectName, 'DataSourceObject__c',      '\'' + this.sourceObjectName + '\''));
        }

        

        // Method to add field mappings
        public ObjectSourceTargetMap addFieldMapping(FieldSourceTargetMap fieldMapping){
            this.fieldSourceTargetMaps.add(fieldMapping);
            return this;
        }

        // Method to get the metadata name
        public String getMdtName(){
            return 'ObjectSourceTargetMap';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create the output map
            Map<String,Object> outputMap = new Map<String,Object>{
                'fullName'              => this.fullName,
                'masterLabel'           => this.masterLabel,
                'creationType'          => this.creationType,
                'sourceObjectName'      => this.sourceObjectName,
                'targetObjectName'      => this.targetObjectName,
                'fieldSourceTargetMaps' => new List<Map<String,Object>>()
            };

            // Add child fields
            for(Integer i=0,max=this.fieldSourceTargetMaps.size();i<max;i++){
                ((List<Map<String,Object>>) outputMap.get('fieldSourceTargetMaps')).add(this.fieldSourceTargetMaps[i].getMdtMap());
            }
            return outputMap;
        }
    }



    public class FieldSourceTargetMap implements IDataCloudMetadata{
        
        // Private variables
        String  creationType;
        Boolean isSourceFormula;
        String  sourceField;
        String  sourceFormula;
        String  targetField;

        // Constructor
        public FieldSourceTargetMap(String creationType, Boolean isSourceFormula, String targetObjectName, String fieldName, String data){
            this.creationType    = creationType;
            this.isSourceFormula = isSourceFormula;
            this.sourceField     = (isSourceFormula) ? null : targetObjectName + '.' + fieldName;
            this.sourceFormula   = (isSourceFormula) ? data: null;
            this.targetField     = targetObjectName + '__dll.' + fieldName;
        }
    
        // Method to get the metadata name
        public String getMdtName(){
            return 'ObjectSourceTargetMap';
        }

        // Method to generate an object map
        public Map<String,Object> getMdtMap(){

            // Create the output map
            Map<String,Object> outputMap = new Map<String,Object>{
                'creationType'   => this.creationType,
                'isSourceFormula'=> this.isSourceFormula,
                'sourceField'    => this.sourceField,
                'sourceFormula'  => this.sourceFormula,
                'targetField'    => this.targetField
            };
            return outputMap;
        }

    }


    private interface IDataCloudMetadata{
        String getMdtName();
        Map<String,Object> getMdtMap();
    }
}