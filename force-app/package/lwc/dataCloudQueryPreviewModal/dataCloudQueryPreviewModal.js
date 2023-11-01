// Lightning stuff
import { api }         from 'lwc';
import LightningModal  from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/dataCloudUtils';

// Apex methods
import getSoqlQueryTable from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getSoqlQueryTable";


// Main class
export default class DataCloudQueryPreviewModal extends LightningModal  {

    // Configuration
    @api config;
    
    // Loading indicator for the spinner
    loading = false;
    
    // Result from the query
    data = [];

    // Column data is retrieved from the LWC controller as it is dependend on the query result
    columns = [];

    get tableVisible(){
        return !this.loading;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            this.handleGetSoqlQueryTable();
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetSoqlQueryTable(){
        try{
            this.loading = true;
            getSoqlQueryTable({
                query   : this.config.query,
                tooling : this.config.tooling
            })
            .then((result) => {
                this.data = result.data;
                for (let index = 0; index < result.columns.length; index++){
                    this.columns.push({ 
                        label        : result.columns[index],
                        fieldName    : result.columns[index],
                        initialWidth : result.columns[index].length < 10 ? 120 : (result.columns[index].length * 12)
                    });
                }
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
}