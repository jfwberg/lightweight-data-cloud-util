// Lightning stuff
import { api }               from 'lwc';
import LightningModal        from 'lightning/modal';

// Custom Utils
import {handleError}         from 'c/dataCloudUtils';
import {copyTextToClipboard} from 'c/dataCloudUtils';

// Apex methods
import getSoqlQueryCsv       from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getSoqlQueryCsv";


// Main class
export default class DataCloudCsvResultModal extends LightningModal  {

    // Configuration
    @api config;

    // Loading indicator for the spinner
    loading = false;

    // Copy button style
    variant = 'brand';
    
    // Visibility getter
    get csvVisible(){
        return !this.loading;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            this.handleGetSoqlQueryCsv();
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
     handleGetSoqlQueryCsv(){
        try{
            this.loading = true;
            getSoqlQueryCsv({
                query   : this.config.query,
                tooling : this.config.tooling
            })
            .then((result) => {
                this.csvData = result;
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }

    handleClickCopy(){
        try{
            // Execute copy
            copyTextToClipboard(this.template.querySelector('.csvData').innerHTML);

            // Change color to green
            this.variant = 'success';
        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);
        }
    }
}