/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           March 2024
 * @copyright      (c) 2024 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import {LightningElement} from "lwc";

// Custom Utils
import {handleError}      from 'c/util';

// Custom Modals
import cmModal            from 'c/cmModal';
import ldtModal           from 'c/ldtModal';
import textModal          from 'c/textModal';
import multiLdtModal      from 'c/multiLdtModal';

// Apex methods
import getDcNamedCredentialOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcNamedCredentialOptions";
import getDataGraphOptions         from "@salesforce/apex/DataCloudUtilLwcCtrl.getDataGraphOptions";
import getDataGraphDetails         from "@salesforce/apex/DataCloudUtilLwcCtrl.getDataGraphDetails";
import getDataGraph                from "@salesforce/apex/DataCloudUtilLwcCtrl.getDataGraph";


// Main class
export default class DataCloudDataGraphUtil extends LightningElement {

    // Loading indicator
    loading = false;

    // Named Credentials picklist details / button indicators
    ncName;
    ncOptions;
    ncOptionsLoaded  = false;
    ncOptionSelected = false;

    // Data Graph Options
    dgName;
    dgOptions;
    dgOptionsLoaded  = false;
    dgOptionSelected = false;
    dgDetailsLoaded  = false;

    // Private key picklist handling
    pkName;
    pkOptions;
    pkOptionsLoaded  = false;
    pkOptionSelected = false;

    // Record id of the private key
    pkRecordId;

    // Output as either csv or LWC data table
    resultFormat = 'keyvalue';
    resultFormatOptions = [
        {label : 'LWC Data Table',      value:'table'     },
        {label : 'Key / Value Table',   value:'keyvalue'  },
        {label : 'JSON Blob',           value:'jsonblob'  },
        {label : 'CSV',                 value:'csv'       },
        {label : 'Raw API Response',    value:'raw'       }
    ];

    /** **************************************************************************************************** **
     **                                            GETTER METHODS                                            **
     ** **************************************************************************************************** **/
    // Disabled when not loaded yet from apex
    get dcNcDisabled(){
        return !this.ncOptionsLoaded;
    }

    // Disabled when no named credential is selected
    get dgDisabled(){
        return !this.ncOptionSelected;
    }

    // Disabled when no data graph option is selected
    get pkDisabled(){
        return !this.dgOptionSelected;
    }

    // Disabled when no primary key has been selected
    get pkRecordIdDisabled(){
        return !this.pkOptionSelected;
    }
    
    // Disabled when no primary key has been selected
    get executeDisabled(){
        return this.pkRecordId == null ||  this.pkRecordId  == undefined || this.pkRecordId.length <= 0;
    }

    // Disabled when no DG has been selected
    get metadataDisabled(){
        return !this.dgOptionSelected;
    }


    /** **************************************************************************************************** **
     **                                         DEPENDENCY HANDLERS                                          **
     ** **************************************************************************************************** **/
    resetDgFields(){
        try{
            this.dgName = null;;
            this.dgOptions = null;
            this.dgOptionsLoaded  = false;
            this.dgOptionSelected = false;
        }catch(error){
            handleError(error);
        }
    }


    resetPkFields(){
        try{
            this.pkName = null;
            this.pkOptions = null;
            this.pkOptionsLoaded  = false;
            this.pkOptionSelected = false;
        }catch(error){
            handleError(error);
        }
    }


    resetPkRecordIdFields(){
        try{
            this.pkRecordId = null;
        }catch(error){
            handleError(error);
        }
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


    handleGetDataGraphOptions(){
        try{
            this.loading = true;
            getDataGraphOptions({
                namedCredentialName  : this.ncName
            })
            .then((apexResponse) => {
                this.dgOptions      = apexResponse;
                this.dgOptionsLoaded= true;
                
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


    handleGetDataGraphDetails(){
        try{
            this.loading = true;
            getDataGraphDetails({
                namedCredentialName : this.ncName,
                dataGraphName       : this.dgName,
            })
            .then((apexResponse) => {
                // Set options and finish loaded
                this.pkOptions       = apexResponse.pkOptions;
                this.dataTables      = apexResponse.dataTables;
                this.dgDetailsLoaded = true;
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


    handleGetDataGraph(){
        try{
            this.loading = true;

            getDataGraph({
                namedCredentialName : this.ncName,
                dataGraphName       : this.dgName,
                dataGraphRecordId   : this.pkRecordId,
                resultFormat        : this.resultFormat
            })
            .then((apexResponse) => {
                switch (this.resultFormat) {
                    
                    case 'table':{
                        ldtModal.open({
                            header : 'Data Graph - Result - LWC Data Table',
                            ldt: apexResponse
                        });
                        break;
                    }

                    case 'keyvalue':{
                        ldtModal.open({
                            header : 'Data Graph - Result - Key/Value Pair Table',
                            ldt: apexResponse
                        });

                        break;
                    }

                    case 'jsonblob' : {
                        cmModal.open({
                            // Modal info
                            size             : 'small',
                            header           : 'Data Graph Execution Result',
                            value            : apexResponse,
                            mode             : 'application/json',
                            disabled         : false,
                            
                            // Download info
                            fileName         : 'DataGraph',
                            fileExtension    : '.json',
                            fileMimeType     : 'application/json; charset=utf-8;',
                            includeTimestamp : true,
                            
                            // Button visibillity
                            copyButton       : true,
                            downloadButton   : true,
                            prettifyButton   : true,
                            closeButton      : true
                        });

                        break;
                    }

                    case 'csv' : {
                        cmModal.open({
                            // Modal info
                            size             : 'small',
                            header           : 'Data Graph - Result - CSV Response',
                            value            : apexResponse,
                            mode             : 'csv',
                            disabled         : false,
                            
                            // Download info
                            fileName         : 'DataGraph',
                            fileExtension    : '.csv',
                            fileMimeType     : 'text/csv',
                            includeTimestamp : true,
                            
                            // Button visibillity 
                            copyButton       : true,
                            downloadButton   : true,
                            prettifyButton   : false,
                            closeButton      : true
                        });

                        break;
                    }
                    
                    case 'raw' : {
                        cmModal.open({
                            // Modal info
                            size             : 'small',
                            header           : 'Data Graph - Result - RAW API Response',
                            value            : apexResponse,
                            mode             : 'application/json',
                            disabled         : false,
                            
                            // Download info
                            fileName         : 'DataGraph',
                            fileExtension    : '.json',
                            fileMimeType     : 'application/json; charset=utf-8;',
                            includeTimestamp : true,
                            
                            // Button visibillity
                            copyButton       : true,
                            downloadButton   : true,
                            prettifyButton   : true,
                            closeButton      : true
                        });

                        break;
                    }
                }

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
            // Update named credential
            this.ncName           = event.detail.value;
            this.ncOptionSelected = true;

            // Reset the dependend fields
            this.resetDgFields();
            this.resetPkFields();
            this.resetPkRecordIdFields();

        }catch(error){
            handleError(error);
        }

        // Get the org's data graph options
        this.handleGetDataGraphOptions();
    }


    handleChangeDgName(event) {
        try{
            this.dgName           = event.detail.value;
            this.dgOptionSelected = true;

            // Reset the dependend fields
            this.resetPkFields();
            this.resetPkRecordIdFields();

        }catch(error){
            handleError(error);
        }

        // Get the data graph details
        this.handleGetDataGraphDetails();
    }


    handleChangePkName(event) {
        try{
            this.pkName           = event.detail.value;
            this.pkOptionSelected = true;

            // Reset the record Id field
            this.resetPkRecordIdFields();
        }catch(error){
            handleError(error);
        }
    }


    handleChangePkRecordId(event) {
        try{
            this.pkRecordId = event.detail.value;
        }catch(error){
            handleError(error);
        }
    }

    handlechangeResultFormat(event) {
        this.resultFormat = event.detail.value;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickHelp(){
        this.handleOpenHelpModal() ;
    }

    handleClickMetadata(){
        this.handleOpenMetadataModal();
    }

    handleClickExecute(){
        this.handleGetDataGraph();
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/    
    /**
     * Open the help modal
     */
    handleOpenHelpModal(){
        try{
            textModal.open({
                header  : "Data Cloud - Data Graph Utility - Help",
                content : "Tool to view all Data Graph Metadata and generate Graph API responses.",
                size    : 'small'
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open the help modal
     */
    handleOpenMetadataModal(){
        try{
            multiLdtModal.open({
                header    : "Detailed Data Graph Metadata",
                tableList : this.dataTables,
                size      : 'medium'
            });
        }catch(error){
            handleError(error);
        }
    }


    handleOpenExecuteModal(){
        try{
            
        }catch(error){
            handleError(error);
        }
    }
}