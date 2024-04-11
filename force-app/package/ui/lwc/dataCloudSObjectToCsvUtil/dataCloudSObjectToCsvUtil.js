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

// Modals
import cmModal              from 'c/cmModal';
import textModal            from 'c/textModal';
import ldtModal             from 'c/ldtModal';
import multiLdtModal        from 'c/multiLdtModal';

// Apex methods for setup
import getDcNamedCredentialOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcNamedCredentialOptions";
import getMtdConfigOptions         from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getMetadataInfo             from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";
import generateQueryFromMapping    from "@salesforce/apex/DataCloudUtilLwcCtrl.generateQueryFromMapping";

// Apex Methods for result handling
import getSoqlQueryTable from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryTable";
import getSoqlQueryCsv   from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryCsv";
import getSoqlQueryRaw   from "@salesforce/apex/DataCloudUtilLwcCtrl.getSoqlQueryRaw";


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

    // Local class codemirror options
    codemirrorLoaded	= false;

    // CodeMirror configuration
    codemirrorTheme	    	  = 'default';
    codemirrorMode	    	  = 'text/x-sql';
    codemirrorValue	    	  = 'SELECT Id, Name, TrialExpirationDate, CreatedDate, CreatedBy.Name FROM Organization LIMIT 1';
    codemirrorSize	      	  = {width : '100%', height: 250};
    codemirrorDisabled        = false;
    codemirrorClass           = "cm";
    codemirrorSave            = () => {
        this.handleSendDataStream();
    };
    codemirrorLoadingComplete = () => {
        this.codemirrorLoaded = true;
        this.getCmTa().size   = {width : '100%', height: 365};
    }

   
    // Indicate this is a tooling query
    tooling = false;

    // Output as either csv or LWC data table
    resultFormat = 'csv';
    resultFormatOptions = [
        {label : 'Lightning - Datatable', value:'table'},
        {label : 'CSV',                   value:'csv'  },
        {label : 'Raw API Response',      value:'raw'  }
    ];


    /** **************************************************************************************************** **
     **                                            GETTER METHODS                                            **
     ** **************************************************************************************************** **/
    // Disabled when not loaded yet from apex
    get ncDisabled(){
        return !this.ncOptionsLoaded;
    }

    get mdtConfigDisabled(){
        return !this.mdtConfigOptionsLoaded;
    }   
       
    // Disable buttons
    get actionDisabled(){
        return !this.mdtConfigSelected;
    }

    // Method to get the CodeMirror Textarea Child component
    getCmTa(){
        return this.template.querySelector('c-cm-textarea');
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        this.handleGetDcNamedCredentialOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetDcNamedCredentialOptions(){
        try{
            this.loading = true;
            getDcNamedCredentialOptions()
                .then((apexResponse) => {
                    this.ncOptions      = apexResponse;
                    this.ncOptionsLoaded= true;
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


    handleGetMdtOptions(){
        try{
            getMtdConfigOptions({namedCredentialName : this.ncName})
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


    handleGetMetadataInfo(){
        try{
            this.loading = true;
            getMetadataInfo({
                mdtConfigName  : this.mdtConfigRecord
            })
            .then((apexResponse) => {
                this.handleOpenMappingModal(apexResponse);
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


    handleGenerateQueryFromMapping(){
        try{
            generateQueryFromMapping({
                mdtConfigName : this.mdtConfigRecord
            })
            .then((apexResponse) => {
                this.codemirrorValue = apexResponse;
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

   
    handleGetSoqlQueryTable(){
        try{
            this.loading = true;
            getSoqlQueryTable({
                query         : this.getCmTa().value,
                tooling       : this.tooling
            })
            .then((apexResponse) => {
                this.handleOpenSoqlResultTableModal(apexResponse);
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


    handleGetSoqlQueryCsv(){
        try{
            this.loading = true;
            getSoqlQueryCsv({
                mdtConfigName : this.mdtConfigRecord,
                query         : this.getCmTa().value,
                tooling       : this.tooling
            })
            .then((apexResponse) => {
                this.handleOpenSoqlResultCsvModal(apexResponse);
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


    handleGetSoqlQueryRaw(){
        try{
            this.loading = true;
            getSoqlQueryRaw({
                query         : this.getCmTa().value,
                tooling       : this.tooling
            })
            .then((apexResponse) => {
                this.handleOpenSoqlResultRawModal(apexResponse);
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
    handleChangeNcName(event) {
        try{
            // On a change reset the metadata settings
            this.mdtConfigSelected      = false;
            this.mdtConfigOptionsLoaded = false;
            this.mdtConfigOptions       = [];
            this.mdtConfigRecord        = '';
            
            // Update named credential
            this.ncName           = event.detail.value;
            this.ncOptionSelected = true;

        }catch(error){
            handleError(error);
        }

        // Get the org's data graph options
        this.handleGetMdtOptions();
    }

    // Set the config record name and update the table
    handleChangeMtdConfig(event) {
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
        this.handleGenerateQueryFromMapping();
    }

    handlechangeResultFormat(event) {
        this.resultFormat = event.detail.value;
    }

    handleChangeTooling(event){
        this.tooling = event.detail.checked;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickExecuteQuery(){
        try{
            switch (this.resultFormat) {
                case 'table':{
                    this.handleGetSoqlQueryTable();
                }
                break;
                
                case 'csv':{
                    this.handleGetSoqlQueryCsv();
                }
                break;

                case 'raw':{
                    this.handleGetSoqlQueryRaw();
                }
                break;
            }
        }catch(error){
            handleError(error);
        }
    }

    handleClickShowMapping(){
        this.handleGetMetadataInfo();
    }

    handleClickHelp(){
        this.handleOpenHelpModal() ;
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the mapping modal
     */
    async handleOpenMappingModal(apexResponse){
        try{
            multiLdtModal.open({
                header    : "Data Cloud Configuration Metadata Details",
                tableList : apexResponse,
                size      : 'medium'
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


    /**
     * Open results in a Table format
     */
    handleOpenSoqlResultTableModal(apexResponse){
        try{
            ldtModal.open({
                size   : 'large',
                header : "SOQL - Query Results - LDT",
                ldt    : apexResponse
            }); 
        }catch(error){
            handleError(error);
        }
    }

    /**
     * Open results in a CSV format
     */
    handleOpenSoqlResultCsvModal(apexResponse){
        try{
            cmModal.open({
                // Modal info
                size             : 'large',
                header           : 'SOQL - Query Results - CSV',
                value            : apexResponse,
                mode             : 'csv',
                disabled         : false,
                
                // Download info
                fileName         : 'SOQL',
                fileExtension    : '.csv',
                fileMimeType     : 'text/csv; charset=utf-8;',
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
     * Open results in a RAW format
     */
    handleOpenSoqlResultRawModal(apexResponse){
        try{
            cmModal.open({
                // Modal info
                size             : 'large',
                header           : 'SOQL - Query Results - RAW',
                value            : apexResponse,
                mode             : 'application/json',
                disabled         : false,
                
                // Download info
                fileName         : 'SOQL',
                fileExtension    : '.json',
                fileMimeType     : 'application/json; charset=utf-8;',
                includeTimestamp : true,
                
                // Button visibillity
                copyButton       : true,
                downloadButton   : true,
                prettifyButton   : true,
                closeButton      : true
            });
        }catch(error){
            handleError(error);
        }
    }
}