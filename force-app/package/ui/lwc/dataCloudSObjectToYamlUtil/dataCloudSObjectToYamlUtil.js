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
import {handleError}        from 'c/dataCloudUtils';
import {openHelpModal}      from 'c/dataCloudUtils';

// Modals
import yamlModal            from 'c/dataCloudYamlModal';

// Apex methods
import getSObjectOptions    from "@salesforce/apex/DataCloudUtilLwcCtrl.getSObjectOptions";
import getSObjectFieldInfo  from "@salesforce/apex/DataCloudUtilLwcCtrl.getSObjectFieldInfo";

const columns = [
    { label: 'Source field (Salesforce)', fieldName: 'source'  },
    { label: 'Salesforce field Type',     fieldName: 'sfFtype' },
    { label: 'Custom field?',             fieldName: 'custom', type : 'boolean' },
    { label: 'Target field (Data Cloud)', fieldName: 'target'  },
    { label: 'Data Cloud Field Type',     fieldName: 'dcFtype' }
];

// Main class
export default class DataCloudSObjectToYamlUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Bulk job column details
    data = [];
    columns = columns;

    // If set to true the labels and api names are inverted
    invertLabel     = true

    // True when the options have been loaded on init
    optionsLoaded   = false;

    // True when an sOject has been selected from the picklist
    sObjectSelected = false;
    
    // Config record picklist details
    sObjectName;
    sObjectOptions = [];

    // Data table details
    selectedData = [];
    currentlySelectedData = [];
    
    // Disable buttons
    get inputsEnabled(){
        return !this.optionsLoaded;
    }

    // Disable buttons
    get actionsEnabled(){
        return !this.sObjectSelected;
    }

    // create object
    get sObjectInputLabel(){
        return (this.invertLabel) ? 'sObject API Name' : 'sObject Label';
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        // Start with getting the metadata configurations
        this.handleGetSObjectOptions();
    }

    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetSObjectOptions(){
        try{
            this.loading = true;
            getSObjectOptions({invertLabel : this.invertLabel})
                .then((result) => {
                    
                    // Clone array
                    let ar = JSON.parse(JSON.stringify(result));

                    // Sort the result by label in JS,
                    // The results are an unsorted mess that come back from apex for some reason
                    this.sObjectOptions = ar.sort(this.compare);
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.optionsLoaded = true;
                    this.loading=false;
                });
        }catch(error){
            handleError(error);
            this.loading=false; 
        }
    }


    handleGetSObjectFieldInfo(){
        try{
            this.loading = true;
            getSObjectFieldInfo({sObjectName : this.sObjectName})
                .then((result) => {
                    this.data = result;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
                    this.optionsLoaded = true;
                    this.loading=false;
                });
        }catch(error){
            handleError(error);
            this.loading=false; 
        }
    }


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    // Set the config record name and update the table
    handleChangeSObject(event) {
        this.data = [];
        this.sObjectName = event.detail.value;
        this.sObjectSelected = true;
        this.handleGetSObjectFieldInfo();
    }

    handleChangeInvertLabel(event){
        this.invertLabel = event.detail.checked;
        this.handleGetSObjectOptions();
    }



    handleRowSelection(event) {
        this.currentlySelectedData = event.detail.selectedRows;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickCreateYaml(){
        this.handleOpenYamlModal();
    }
    
    handleClickHelp(){
        openHelpModal(
            'Tool to generate a YAML file based on an sObject and selected number of fields. This YAML can be used to create a new ingestion API Connector in the Data Cloud Setup.'
        );
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    async handleOpenYamlModal () {
        yamlModal.open({
            sObjectName : this.sObjectName,
            currentlySelectedData: this.currentlySelectedData,
            size: 'medium',
        });
    }


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    // Sort by label
    compare(a,b) {
        if (a.label < b.label){
            return -1;
        }
        if (a.label > b.label){
            return 1;
        }
        return 0;
    }
}