
import { api }        from 'lwc';
import LightningAlert from 'lightning/alert';
import LightningModal from 'lightning/modal';
import addCsv         from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.addCsv";


export default class DataCloudAddCsvModal extends LightningModal  {

    @api config;
    
    // Loading indicator for the spinner
    loading = false;
    
    // The CSV string that will be loaded
    csvData;


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
     handleChangeCsvData(event){
        this.csvData = event.target.value;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickAddCsv() {
        try{
            this.loading = true;

            addCsv({
                mdtConfigName : this.config.mdtConfigRecord,
                jobId         : this.config.jobId,
                csvData       : this.csvData
            })
            .then((result) => {
                
                this.close('ok');
            })
            .catch((error) => {
                this.handleError(error.body.message);
                
                // Disable buttons on fault state
                this.mdtConfigSelected = false;
            })
            .finally(()=>{
                this.loading = false;
            });
            
        }catch(error){
            this.handleError(error.message);
        }
    }

    handleClickClose() {
        this.close();
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