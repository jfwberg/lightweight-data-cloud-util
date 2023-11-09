// Lightning stuff
import { LightningElement } from "lwc";

// Custom Utils
import {handleError}        from 'c/dataCloudUtils';
import {openHelpModal}      from 'c/dataCloudUtils';

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
                .then((result) => {
                    this.mdtConfigOptions = result;
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
            .then((result) => {
                this.query = result;
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
        openHelpModal(
            'Tool to generate a CSV from a query that allows from sub queries and parent relationships. When a metadata record is selected the mapping is used to update the column headers to the target column names.'
        );
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    async handleOpenCsvResultModal () {
        csvResultModal.open({
            config: {
                mdtConfigName : this.mdtConfigRecord,
                query         : this.query,
                tooling       : this.tooling
            },
            size: 'large',
        }).then((result) => {
            
        });
    }

    async handleOpenQueryPreviewModal () {
        previewModal.open({
            config: {
                mdtConfigName : this.mdtConfigRecord,
                query         : this.query,
                tooling       : this.tooling
            },
            size: 'large',
        }).then((result) => {
            
        });
    }

    async handleOpenMappingModal (config) {
        mappingModal.open({
            config: config,
            size: 'small',
        }).then((result) => {
            
        });
    }
}