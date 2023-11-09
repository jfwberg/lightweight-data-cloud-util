// Lightning stuff
import { api }           from 'lwc';
import LightningModal    from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/dataCloudUtils';

// Apex methods
import addCsv            from "@salesforce/apex/DataCloudUtilLwcCtrl.addCsv";
import getCsvPlaceholder from "@salesforce/apex/DataCloudUtilLwcCtrl.getCsvPlaceholder";

// Main class
export default class DataCloudAddCsvModal extends LightningModal  {

    @api config;
    
    // Loading indicator for the spinner
    loading = false;
    
    // The CSV string that will be loaded
    csvData;


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            this.loading = true;

            getCsvPlaceholder({
                mdtConfigName : this.config.mdtConfigRecord
            })
            .then((result) => {

                this.csvData = result;
            })
            .catch((error) => {
                handleError(error);
                
                // Disable buttons on fault state
                this.mdtConfigSelected = false;
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
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
     handleChangeCsvData(event){
        this.csvData = event.target.value;
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
     handleAddCsv() {
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
                handleError(error);
                
                // Disable buttons on fault state
                this.mdtConfigSelected = false;
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
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickAddCsv() {
        this.handleAddCsv();
    }

    handleClickClose() {
        this.close();
    }
}