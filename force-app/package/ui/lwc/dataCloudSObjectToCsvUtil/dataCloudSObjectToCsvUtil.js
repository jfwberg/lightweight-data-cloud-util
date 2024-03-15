/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { LightningElement } from "lwc";

// Custom Utils
import {handleError}        from 'c/util';
import textModal            from 'c/textModal';

// Modals
import mappingModal         from 'c/dataCloudMappingModal';
import previewModal         from 'c/dataCloudQueryPreviewModal';
import csvResultModal       from 'c/dataCloudCsvResultModal';

// Apex methods
import getMtdConfigOptions      from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import generateQueryFromMapping from "@salesforce/apex/DataCloudUtilLwcCtrl.generateQueryFromMapping";


// Main class
export default class DataCloudSObjectToCsvUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

    // The query we are going to test
    query;

    // Indicate this is a tooling query
    tooling = false;

    // Disable buttons
    get buttonsEnabled(){
        return !this.mdtConfigSelected;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        // Start with getting the metadata configurations
        this.handleGetMdtOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetMdtOptions(){
        try{
            getMtdConfigOptions()
                .then((apexResponse) => {
                    this.mdtConfigOptions = apexResponse;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            handleError(error); 
        }
    }

    handleGenerateQueryFromMapping(){
        try{
            generateQueryFromMapping({
                mdtConfigName : this.mdtConfigRecord
            })
            .then((apexResponse) => {
                this.query = apexResponse;
                this.template.querySelector(".ta").value = apexResponse;
            })
            .catch((error) => {
                handleError(error);
            })
            .finally(()=>{
                this.mdtConfigOptionsLoaded = true;
                this.loading = false;
            });
        }catch(error){
            handleError(error); 
        }
    }

   
    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    // Set the config record name and update the table
    handleChangeMtdConfig(event) {
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
        this.handleGenerateQueryFromMapping();
    }

    handleChangeQuery(){
        this.query = this.template.querySelector(".ta").value;
    }

    handleChangeTooling(event){
        this.tooling = event.detail.checked;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickPreview(){
        this.handleOpenQueryPreviewModal();
    }

    handleClickGenerateCsv(){
        this.handleOpenCsvResultModal();
    }

    handleClickShowMapping(){
        this.handleOpenMappingModal({
            mdtConfigRecord : this.mdtConfigRecord
        });
    }

    handleClickHelp(){
        this.handleOpenHelpModal() ;
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the CSV result modal
     */
    async handleOpenCsvResultModal(){
        try{
            csvResultModal.open({
                config: {
                    mdtConfigName : this.mdtConfigRecord,
                    query         : this.query,
                    tooling       : this.tooling
                },
                size: 'large',
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open the query preview modal
     */
    async handleOpenQueryPreviewModal(){
        try{
            previewModal.open({
                config: {
                    mdtConfigName : this.mdtConfigRecord,
                    query         : this.query,
                    tooling       : this.tooling
                },
                size: 'large',
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open the mapping modal
     */
    async handleOpenMappingModal(config){
        try{
            mappingModal.open({
                config: config,
                size: 'small',
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open the help modal
     */
    handleOpenHelpModal(){
        try{
            textModal.open({
                header  : "Data Cloud - sObject to CSV Utility - Help",
                content : "Tool to generate a CSV from a query that allows from sub queries and parent relationships. When a metadata record is selected the mapping is used to update the column headers to the target column names.",
                size    : 'small'
            });
        }catch(error){
            handleError(error);
        }
    }
}