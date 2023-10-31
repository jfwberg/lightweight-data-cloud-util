// Lightning stuff
import { api }        from 'lwc';
import LightningModal from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/dataCloudUtils';

// Apex methods
import getJobInfo     from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getJobInfo";

// Columns for the bulk jobs
const columns = [
    { label: 'Key',   fieldName: 'key'  },
    { label: 'Value', fieldName: 'value'}
];

// Main class
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
                handleError(error);
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }
}