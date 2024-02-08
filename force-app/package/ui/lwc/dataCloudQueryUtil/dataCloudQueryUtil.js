/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import {LightningElement}  from "lwc";

// Custom Utils
import {handleError}       from 'c/dataCloudUtils';
import {openHelpModal}     from 'c/dataCloudUtils';

// Modals
import queryResultModal    from 'c/dataCloudQueryResultModal';

// Apex methods
import getMtdConfigOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getQueryPlaceholder from "@salesforce/apex/DataCloudUtilLwcCtrl.getQueryPlaceholder";

// Main class
export default class DataCloudQueryUtil extends LightningElement {

    // The query
    query = '';

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions;

    // Output as either csv or LWC data table
    resultFormat = 'table';
    resultFormatOptions = [
        {label : 'Datatable', value:'table'},
        {label : 'CSV',       value:'csv'}
    ];


    /** **************************************************************************************************** **
     **                                            GETTER METHODS                                            **
     ** **************************************************************************************************** **/
    // Disable buttons
    get actionDisabled(){
        return !this.mdtConfigSelected;
    }

    get inputDisabled(){
        return !this.mdtConfigOptionsLoaded;
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
                    this.mdtConfigOptionsLoaded = true;
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


    handleGetQueryPlaceholder(){
        try{
            getQueryPlaceholder({mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    this.query = result;
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
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    // Set the config record name and update the table
    handleChangeMtdConfig(event) {
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;

        this.handleGetQueryPlaceholder();
    }

    handleChangeQuery(){
        this.query = this.template.querySelector(".ta").value;
    }

    handlechangeResultFormat(event) {
        this.resultFormat = event.detail.value;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickExecuteQuery(){
        this.handleOpenQueryResultModal();
    }

    handleClickHelp(){
        openHelpModal(
            'Tool to generate a table view or CSV from a Data Cloud SQL Query. The query is executed against the Data Cloud named credential as specified in the metadata configuration that is selected.'
        );
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    async handleOpenQueryResultModal() {
        queryResultModal.open({
            config: {
                mdtConfigName : this.mdtConfigRecord,
                resultFormat : this.resultFormat,
                query : this.query
            },
            size: 'large',
        });
    }
}