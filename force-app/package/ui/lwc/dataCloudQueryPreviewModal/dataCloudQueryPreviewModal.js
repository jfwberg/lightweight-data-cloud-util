/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api }         from 'lwc';
import LightningModal  from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/dataCloudUtils';

// Apex methods
import getSoqlQueryTable from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryTable";


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
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query,
                tooling       : this.config.tooling
            })
            .then((result) => {
                this.data = result.data;
                for (let index = 0; index < result.columns.length; index++){
                    this.columns.push({ 
                        label        : result.columns[index].columnLabel,
                        fieldName    : result.columns[index].columnName,
                        initialWidth : result.columns[index].columnLabel.length < 10 ? 120 : (result.columns[index].columnLabel.length * 12)
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