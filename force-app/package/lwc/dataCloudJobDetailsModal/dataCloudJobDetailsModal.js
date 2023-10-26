
// Lightning stuff
import { api }        from 'lwc';
import LightningAlert from 'lightning/alert';
import LightningModal from 'lightning/modal';

// Apex methods
import getJobInfo     from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getJobInfo";

// Columns for the bulk jobs
const columns = [
    { label: 'Key',   fieldName: 'key'  },
    { label: 'Value', fieldName: 'value'}
];


export default class DataCloudJobDetailsModal extends LightningModal {
    
    // Config
    @api config;

    // Spinner indicator
    loading = false;

    // Table info
    data = [];
    columns = columns;


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        try{
            this.loading = true;

            getJobInfo({
                mdtConfigName : this.config.mdtConfigRecord,
                jobId         : this.config.jobId
            })
            .then((result) => {
                this.data = result;
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