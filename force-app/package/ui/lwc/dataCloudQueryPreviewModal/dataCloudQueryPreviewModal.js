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
import {handleError}   from 'c/util';

// Apex methods
import getSoqlQueryTable from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryTable";


// Main class
export default class DataCloudQueryPreviewModal extends LightningModal  {

    // Configuration
    @api config;
    
    // Loading indicator for the spinner
    loading = false;

    // Indicator the table has successfully been initialized
    loaded = false;
    
    // Lightning datatable
    ldt = {};


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        this.handleGetSoqlQueryTable();
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
            .then((apexResponse) => {
                this.ldt = apexResponse;
                this.loaded = true;
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