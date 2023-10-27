
// Lightning stuff
import { api }         from 'lwc';
import LightningAlert  from 'lightning/alert';
import LightningModal  from 'lightning/modal';

// Apex methods
import getMetadataInfo from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getMetadataInfo";


// Columns for the bulk jobs
const recordColumns = [
    { label: 'Key',   fieldName: 'key'  },
    { label: 'Value', fieldName: 'value'}
];

// Columns for the bulk jobs
const mappingColumns = [
    { label: 'Source field (Salesforce)', fieldName: 'source' },
    { label: 'Target field (Data Cloud)', fieldName: 'target'},
    { label: 'Data Cloud Field Type',     fieldName: 'ftype' }
];

getMetadataInfo
export default class DataCloudMappingModal extends LightningModal {
    // Config
    @api config;

    // Spinner indicator
    loading = false;

    // Record table
    recordData = [];
    recordColumns = recordColumns;

    // Mapping table
    mappingData = [];
    mappingColumns = mappingColumns;


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        try{
            this.loading = true;

            getMetadataInfo({
                mdtConfigName : this.config.mdtConfigRecord
            })
            .then((result) => {
                this.recordData  = result.recordData;
                this.mappingData = result.mappingData;
            })
            .catch((error) => {
                this.handleError(error.body.message);
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            this.handleError(error.message);
        }
    }


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }

    handleError(msg){
        LightningAlert.open({
            message: 'An unexpected error occurred: ' + msg,
            label: 'Error',
            theme : 'error'
        });
        this.loading = false;
    }
}