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
import {handleError}       from 'c/util';

// Modals
import cmModal             from 'c/cmModal';
import textModal           from 'c/textModal';
import ldtModal            from 'c/ldtModal';
import multiLdtModal       from 'c/multiLdtModal';


// Apex methods for setup
import getDcNamedCredentialOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcNamedCredentialOptions";
import getMtdConfigOptions         from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getQueryPlaceholder         from "@salesforce/apex/DataCloudUtilLwcCtrl.getQueryPlaceholder";
import getMetadataInfo             from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";

// Apex methods for query results
import getDcQueryCsv       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryCsv";
import getDcQueryTable     from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryTable";
import getDcQueryRaw       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryRaw";

// Main class
export default class DataCloudQueryUtil extends LightningElement {

    // Loading indicator
    loading = false;

    // Named Credentials picklist details / button indicators
    ncName;
    ncOptions;
    ncOptionsLoaded  = false;
    ncOptionSelected = false;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions;

    // CodeMirror Always set some default values
    codemirrorClass     = 'ta';
    codemirrorLoaded	= false;
    codemirrorMode		= 'text/x-sql';
    codemirrorSize		= {width : '100%', height: 250};
    codemirrorTheme		= 'default';
    codemirrorValue		= '';
    
    // Output as either csv or LWC data table
    resultFormat = 'table';
    resultFormatOptions = [
        {label : 'Lightning - Datatable', value:'table'},
        {label : 'CSV',                   value:'csv'  },
        {label : 'Raw API Response',      value:'raw'  }
    ];

    // Specify what API version you 
    queryApiVersion = 'v1';
    queryApiVersionOptions = [
        {label : 'v2', value:'v2'},
        {label : 'v1', value:'v1'}
    ];

    // Specify what fields are getting auto generated
    fieldSelection = 'all';
    fieldSelectionOptions = [
        {label : 'All',                       value :'all'},
        {label : 'Primary Key Only',          value :'pk'},
        {label : 'Primary Key and EventTime', value :'pket'}
    ];


    /** **************************************************************************************************** **
     **                                            GETTER METHODS                                            **
     ** **************************************************************************************************** **/
    // Disabled when not loaded yet from apex
    get dcNcDisabled(){
        return !this.ncOptionsLoaded;
    }

    // Disable buttons
    get executeButtonDisabled(){
        return !this.ncOptionSelected;
    }

    // Disable buttons
    get metadataButtonDisabled(){
        return !this.mdtConfigSelected;
    }

    // Disable metadata when no NC is selected or the options are not loaded
    get metadataConfigInputDisabled(){
        return !this.ncOptionSelected;
    }

    // Disable metadata when no NC is selected or the options are not loaded
    get fieldSelectionInputDisabled(){
        return !this.mdtConfigSelected;
    }

    get codemirrorDisabled(){
        return !this.ncOptionSelected;
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

    //connectedCallback(){
        //this.handleGetMdtOptions();
    //}


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
            this.loading = true;
            getMtdConfigOptions({
                namedCredentialName : this.ncName
            })
                .then((apexResponse) => {
                    this.mdtConfigOptions = apexResponse;
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
            this.loading = true;
            getQueryPlaceholder({
                mdtConfigName  : this.mdtConfigRecord,
                fieldSelection : this.fieldSelection
            })
            .then((apexResponse) => {
                this.getCmTa().value = apexResponse;
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


    handleGetDcQueryTable(){
        try{
            this.loading = true;
            getDcQueryTable({
                namedCredentialName : this.ncName,
                query               : this.getCmTa().value,
                apiVersion          : this.queryApiVersion
            })
            .then((apexResponse) => {
                this.handleOpenDcResultTableModal(apexResponse);
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


    handleGetDcQueryCsv(){
        try{
            this.loading = true;
            getDcQueryCsv({
                namedCredentialName : this.ncName,
                query               : this.getCmTa().value,
                apiVersion          : this.queryApiVersion
            })
            .then((apexResponse) => {
                this.handleOpenDcResultCsvModal(apexResponse);
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


    handleGetDcQueryRaw(){
        try{
            this.loading = true;
            getDcQueryRaw({
                namedCredentialName : this.ncName,
                query               : this.getCmTa().value,
                apiVersion          : this.queryApiVersion
            })
            .then((apexResponse) => {
                this.handleOpenDcResultRawModal(apexResponse);
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
            this.mdtConfigSelected = false;
            this.mdtConfigOptionsLoaded = false;
            this.mdtConfigOptions = [];
            this.mdtConfigRecord = '';
            
            // Update named credential
            this.ncName           = event.detail.value;
            this.ncOptionSelected = true;

            // Extract the code mirror
            let cm = this.template.querySelector('.' + this.codemirrorClass)
                
            // Update the sizing
            cm.setDisabled(false);

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
        this.handleGetQueryPlaceholder();
    }

    
    handlechangeResultFormat(event) {
        this.resultFormat = event.detail.value;
    }


    handlechangeQueryApiVersion(event) {
        this.queryApiVersion = event.detail.value;
    }


    handlechangeFieldSelection(event) {
        this.fieldSelection = event.detail.value;
        this.handleGetQueryPlaceholder();
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickExecuteQuery(){
        try{
            switch (this.resultFormat) {
                case 'table':{
                    this.handleGetDcQueryTable();
                }
                break;
                
                case 'csv':{
                    this.handleGetDcQueryCsv();
                }
                break;

                case 'raw':{
                    this.handleGetDcQueryRaw();
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
     * Open the Mapping Modal
     */
    handleOpenMappingModal(apexResponse){
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
                header  : "Data Cloud - Query Utility - Help",
                content : "Tool to generate a table view or CSV from a Data Cloud SQL Query. The query is executed against the Data Cloud named credential as specified in the metadata configuration that is selected.",
                size    : 'small'
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open results in a Table format
     */
    handleOpenDcResultTableModal(apexResponse){
        try{
            ldtModal.open({
                size   : 'large',
                header : "Data Cloud - Query Results - LDT",
                ldt    : apexResponse
            }); 
        }catch(error){
            handleError(error);
        }
    }

    
    /**
     * Open results in a CSV format
     */
    handleOpenDcResultCsvModal(apexResponse){
        try{
            cmModal.open({
                // Modal info
                size             : "large",
                header           : "Data Cloud - Query Results - CSV",
                value            : apexResponse,
                mode             : "csv",
                theme            : this.codemirrorTheme,
                disabled         : false,
                
                // Download info
                fileName         : 'DC_Query',
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
    handleOpenDcResultRawModal(apexResponse){
        try{
            cmModal.open({
                // Modal info
                size             : "large",
                header           : "Data Cloud - Query Results - RAW",
                value            : apexResponse,
                mode             : "application/json",
                theme            : this.codemirrorTheme,
                disabled         : false,
                
                // Download info
                fileName         : 'DC_Query',
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

    // Actions that run once the code mirror windows has been loaded and added to the DOM
    handleCodemirrorLoaded(){
        // Set the loaded value to true
        this.codemirrorLoaded = true;      
    }


    handleCodemirrorSave(){
        this.createTable();
    }

    // Handle any updates in case the theme changes
    handleThemeChange(event) {
        this.codemirrorTheme = event.detail;
    }
}