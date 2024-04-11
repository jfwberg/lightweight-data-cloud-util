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
import {handleError}         from 'c/util';
import {removePreAndPostFix} from 'c/util';

// Modals
import cmModal              from 'c/cmModal';
import textModal            from 'c/textModal';

// Apex methods
import getSObjectOptions    from "@salesforce/apex/DataCloudUtilLwcCtrl.getSObjectOptions";
import getSObjectFieldInfo  from "@salesforce/apex/DataCloudUtilLwcCtrl.getSObjectFieldInfo";

// Mapping for the YAML
const FIELD_TYPE_MAPPING = {
    "booleanField"  : "boolean",
    "dateField"     : "string\n          format: date",
    "dateTimeField" : "string\n          format: date-time",
    "emailField"    : "string\n          format: email",
    "numberField"   : "number",
    "phoneField"    : "string\n          format: phone",
    "percentField"  : "string\n          format: percent",
    "textField"     : "string",
    "urlField"      : "string\n          format: url",    
};

// Main class
export default class DataCloudSObjectToYamlUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // The yaml file that is to be generated
    yamlData = '';

    // Result modal codemirror theme
    codemirrorResultTheme = 'default';

    // Lightning output table, set default to prevent error message
    ldt = {keyField : 'source'};

    // If set to true the labels and api names are inverted
    invertLabel     = true

    // True when the options have been loaded on init
    optionsLoaded   = false;

    // True when an sOject has been selected from the picklist
    sObjectSelected = false;
    
    // Config record picklist details
    sObjectName;
    sObjectOptions = [];

    // Rows that are selected for a specific object (All objects)
    // Contains only the records keys
    selectedRows = {};

    // All selected rows for all objects + data, YAML is created based on this
    currentlySelectedRows = {};

    // List of selected rows in the current visible object only, not all data
    visibleSelectedRows = [];
    
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
        this.handleGetSObjectOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetSObjectOptions(){
        try{
            this.loading = true;
            getSObjectOptions({invertLabel : this.invertLabel})
                .then((apexResponse) => {
                    
                    // Clone array
                    let ar = JSON.parse(JSON.stringify(apexResponse));

                    // Sort the result by label in JS,
                    // The results are an unsorted mess that come back from apex for some reason
                    this.sObjectOptions = ar.sort(this.compare);

                    // Options loaded is true
                    this.optionsLoaded = true;
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
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
                .then((apexResponse) => {
                    // Update the data table
                    this.ldt = apexResponse;

                    // Pre-populate the data table for different objects, needs to run after the data table has been refreshed
                    // Reset view when you move to an object that has not been added yet
                    this.visibleSelectedRows = this.selectedRows.hasOwnProperty(this.sObjectName) ? JSON.parse(JSON.stringify(this.selectedRows[this.sObjectName])) : [];
                })
                .catch((error) => {
                    handleError(error);
                })
                .finally(()=>{
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
        try{
            this.data = [];
            this.sObjectName = event.detail.value;
            this.sObjectSelected = true;
            this.handleGetSObjectFieldInfo();
        }catch(error){
            handleError(error);
        }
    }

    
    handleChangeInvertLabel(event){
        this.invertLabel = event.detail.checked;
        this.handleGetSObjectOptions();
    }


    handleRowSelection(event) {
        // Add the records to the currently selected data
        this.currentlySelectedRows[this.sObjectName] = JSON.parse(JSON.stringify(event.detail.selectedRows));

        // Add ids to the selected rows
        this.selectedRows[this.sObjectName] = JSON.parse(JSON.stringify(event.detail.selectedRows)).map(a => a.source);  
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickCreateYaml(){
        this.handleOpenYamlModal();
    }
    
    handleClickHelp(){
        this.handleOpenHelpModal() ;
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    handleOpenYamlModal(){
        try{
            // Generate the YAML
            this.generateYaml();

            // Open the generated YAML in a modal
            cmModal.open({
                            
                // Modal info
                size             : "small",
                header           : "YAML Creation Result",
                value            : this.yamlData,
                mode             : "text/x-yaml",
                theme            : this.codemirrorResultTheme,
                disabled         : false,
   
                // Download info
                fileName         : 'YAML',
                fileExtension    : '.yaml',
                fileMimeType     : 'text/x-yaml; charset=utf-8;',
                includeTimestamp : true,

                // Button visibillity
                copyButton       : true,
                downloadButton   : true,
                prettifyButton   : false,
                closeButton      : true
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
                header  : "Data Cloud - sObject to YAML Utility - Help",
                content : "Tool to generate a YAML file based on one or multiple sObjects and their selected fields. This YAML can be used to create a new Ingestion API Connector in the Data Cloud Setup. Note that namespace prefixs and any postfixes like __c or __mdt will be removed from object and field names and there is no duplicate check. So if you have Name and Name__c you're going to have to update the YAML manually.",
                size    : 'small'
            });
        }catch(error){
            handleError(error);
        }
    }


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    /**
     * Method to generate a YAML for a object/field list mapping
     */
    generateYaml(){
        try{
            // Set the base string for the yaml data
            this.yamlData='openapi: 3.0.3\ncomponents:\n  schemas:\n';

            // Add objects
            for (let sObjectName in this.currentlySelectedRows){
                
                // Remove objects without any fields
                if(this.currentlySelectedRows[sObjectName].length > 0){
                    
                    // Clean object name from pre and postfixes
                    this.yamlData += '    ' + removePreAndPostFix(sObjectName) + ':\n      type: object\n      properties:\n';

                    // Create the field info
                    for (let index = 0; index < this.currentlySelectedRows[sObjectName].length; index++) {
                        const element = this.currentlySelectedRows[sObjectName][index];
                        this.yamlData += '        '   + removePreAndPostFix(element.target) + ':\n';
                        this.yamlData += '          type: ' + FIELD_TYPE_MAPPING[element.dcFtype] + '\n';
                    }
                }
            }
        }catch(error){
            handleError(error);
        }
    }

  
    /**
     * Method to sort an array by label
     */
    compare(a,b){
        try{
            if (a.label < b.label){
                return -1;
            }
            if (a.label > b.label){
                return 1;
            }
            return 0;
        }catch(error){
            handleError(error);
        }
    }
}