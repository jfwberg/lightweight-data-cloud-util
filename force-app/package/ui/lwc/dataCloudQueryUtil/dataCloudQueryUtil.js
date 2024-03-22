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
import textModal           from 'c/textModal';
import textareaModal       from 'c/textareaModal';
import ldtModal            from 'c/ldtModal';
import multiLdtModal       from 'c/multiLdtModal';

// Apex methods for setup
import getMtdConfigOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getQueryPlaceholder from "@salesforce/apex/DataCloudUtilLwcCtrl.getQueryPlaceholder";
import getMetadataInfo     from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";

// Apex methods for query results
import getDcQueryCsv       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryCsv";
import getDcQueryTable     from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryTable";
import getDcQueryRaw       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryRaw";

// Main class
export default class DataCloudQueryUtil extends LightningElement {

    // Loading indicator
    loading = false;

    // The query
    query = '';

    // Metadata configuration tables
    mdtTableList;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions;

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
        this.handleGetMdtOptions();
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetMdtOptions(){
        try{
            this.loading = true;
            getMtdConfigOptions()
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
                this.query = apexResponse;
                this.template.querySelector(".ta").value = apexResponse;
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
                mdtConfigName : this.mdtConfigRecord,
                query         : this.query,
                apiVersion    : this.queryApiVersion
            })
            .then((apexResponse) => {
                this.handleOpenDcResultTableModal(apexResponse);
            })
            .catch((error) => {
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
                mdtConfigName : this.mdtConfigRecord,
                query         : this.query,
                apiVersion    : this.queryApiVersion
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
                mdtConfigName : this.mdtConfigRecord,
                query         : this.query,
                apiVersion    : this.queryApiVersion
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
            textareaModal.open({
                
                // Modal info
                size             : 'large',
                label            : 'Data Cloud - Query Results - CSV',
                content          : apexResponse,
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
            textareaModal.open({
                
                // Modal info
                size             : 'large',
                label            : 'Data Cloud - Query Results - RAW',
                content          : apexResponse,
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
}