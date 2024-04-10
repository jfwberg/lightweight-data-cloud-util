/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import   LightningAlert     from 'lightning/alert';
import { LightningElement } from "lwc";

// Custom Utils
import {handleError}        from 'c/util';

// Modals
import cmModal              from 'c/cmModal';
import textModal            from 'c/textModal';
import lLdtModal            from 'c/ldtModal';
import multiLdtModal        from 'c/multiLdtModal';
import addCsvModal          from 'c/dataCloudAddCsvModal';

// Apex methods
import getDcNamedCredentialOptions from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcNamedCredentialOptions";
import getMtdConfigOptions         from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getMetadataInfo             from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";
import getIngestionJobTable        from "@salesforce/apex/DataCloudUtilLwcCtrl.getIngestionJobTable";
import getJobInfo                  from "@salesforce/apex/DataCloudUtilLwcCtrl.getJobInfo";
import newJob                      from "@salesforce/apex/DataCloudUtilLwcCtrl.newJob";
import abortJob                    from "@salesforce/apex/DataCloudUtilLwcCtrl.abortJob";
import completeJob                 from "@salesforce/apex/DataCloudUtilLwcCtrl.completeJob";
import deleteJob                   from "@salesforce/apex/DataCloudUtilLwcCtrl.deleteJob";


// Main class
export default class DataCloudBulkIngestionUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Bulk job datatable
    ldt = {};
    
    // Named Credentials picklist details / button indicators
    ncName;
    ncOptions;
    ncOptionsLoaded  = false;
    ncOptionSelected = false;

    // Jobs table loaded
    jobTableLoaded;

    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

    // Disabled when not loaded yet from apex
    get dcNcDisabled(){
        return !this.ncOptionsLoaded;
    }

    // Disabled when not loaded yet from apex
    get mdtConfigDisabled(){
        return !this.mdtConfigOptionsLoaded;
    }

    get refreshButtonDisabled(){
        return !this.ncOptionSelected;
    }

    // Disable buttons
    get jobActionButtonsDisabled(){
        return !this.mdtConfigSelected;
    }

    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        this.handleGetDcNamedCredentialOptions();
    }


    /** **************************************************************************************************** **
     **                                       TABLE ACTION HANDLERS                                          **
     ** **************************************************************************************************** **/
    handleRowAction(event) {
        const action = event.detail.action;
        const row    = event.detail.row;
        switch (action.name) {
            case 'details':
                this.handleGetJobInfo(row.id);
            break;

            case 'csv':
                this.handleOpenAddCsvModal({
                    namedCredentialName : this.ncName,    
                    mdtConfigRecord     : this.mdtConfigRecord,
                    jobId               : row.id,
                    isUpload            : false
                });
            break;

            case 'uploadCsv':
                this.handleOpenAddCsvModal({
                    namedCredentialName : this.ncName,    
                    mdtConfigRecord     : this.mdtConfigRecord,
                    jobId               : row.id,
                    isUpload            : true
                });
            break;

            case 'complete':
                this.handleComplete(row.id);
            break;

            case 'abort':
                this.handleAbort(row.id);
            break;

            case 'delete':
                this.handleDelete(row.id);
            break;
        }
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
                    this.mdtConfigOptions       = apexResponse;
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


    handleGetJobInfo(jobId){
        try{
            this.loading = true;

            getJobInfo({
                namedCredentialName : this.ncName,
                jobId               : jobId
            })
            .then((apexResponse) => {
                this.handleOpenJobDetailsModal(apexResponse)
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


    handleNew(){
        try{
            this.loading = true;
            newJob( {
                mdtConfigName : this.mdtConfigRecord,
                jobType       : 'upsert'
            })
                .then((apexResponse) => {
                    LightningAlert.open({
                        message : 'Succesfully created a new bulk UPSERT job with Id : "' + apexResponse +'"',
                        label   : 'Success',
                        theme   : 'success'
                    });

                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
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
            this.loading = false;
        }
    }


    handleNewDelete(){
        try{
            this.loading = true;
            newJob( {
                mdtConfigName : this.mdtConfigRecord,
                jobType       : 'delete'
            })
                .then((apexResponse) => {
                    LightningAlert.open({
                        message : 'Succesfully created a new bulk DELETE job with Id : "' + apexResponse +'"',
                        label   : 'Success',
                        theme   : 'success'
                    });

                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
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
            this.loading = false;
        }
    }


    handleAbort(jobId){
        try{
            this.loading = true;
            abortJob({
                namedCredentialName : this.ncName,
                jobId               : jobId
            })
            .then(() => {
                LightningAlert.open({
                    message: 'Succesfully ABORTED the a bulk job with Id : "' + jobId +'"',
                    label: 'Success',
                    theme : 'success'
                });

                // Update the job table after creation
                this.handleGetIngestionJobTable();
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


    handleDelete(jobId){
        try{
            this.loading = true;
            deleteJob({
                namedCredentialName : this.ncName,
                jobId               : jobId
            })
            .then(() => {
                LightningAlert.open({
                    message : 'Succesfully DELETED the a bulk job with Id : "' + jobId +'"',
                    label   : 'Success',
                    theme   : 'success'
                });

                // Update the job table after creation
                this.handleGetIngestionJobTable();
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


    handleComplete(jobId){
        try{
            this.loading = true;
            completeJob({
                namedCredentialName : this.ncName,
                jobId               : jobId
            })
            .then(() => {
                LightningAlert.open({
                    message : 'Succesfully COMPLETED the a bulk job with Id : "' + jobId +'"',
                    label   : 'Success',
                    theme   : 'success'
                });

                // Update the job table after creation
                this.handleGetIngestionJobTable();
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


    handleGetIngestionJobTable(){
        try{
            this.loading = true;

            getIngestionJobTable({
                namedCredentialName : this.ncName
            })
            .then((apexResponse) => {
                this.ldt = apexResponse;
            })
            .catch((error) => {
                handleError(error);
            })
            .finally(()=>{
                this.loading = false;
                this.jobTableLoaded = true;
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

            // Clear the data table
            this.ldt = null;
            this.jobTableLoaded = false;


        }catch(error){
            handleError(error);
        }

        // Get he ingestion table
        this.handleGetIngestionJobTable();

        // Get the metadata configuration option
        this.handleGetMdtOptions();
    }


    // Set the config record name and update the table
    handleChangeMtdConfig(event) {
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickNew(){
        this.handleNew();
    }

    handleClickNewDelete(){
        this.handleNewDelete();
    }

    handleClickRefresh(){
        this.handleGetIngestionJobTable();
    }

    handleClickShowMapping(){
        this.handleGetMetadataInfo();
    }

    handleClickHelp(){
        this.handleOpenHelpModal();
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
     * Open the Job Details Modal
     */
    handleOpenJobDetailsModal(apexResponse){
        try{
            lLdtModal.open({
                size : 'small',
                header : 'Job Details',
                ldt : apexResponse
            });
        }catch(error){
            handleError(error);
        }
    }


    /**
     * Open the CSV Modal, on successful addition of the CSV file refresh the table
     */
    async handleOpenAddCsvModal(config){
        try{
            addCsvModal.open({
                config : config,
                size   : 'medium',
            }).then((response) => {
                if(response === 'ok') {
                    this.handleGetIngestionJobTable();
                }
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
                header :    'Data Cloud - Bulk Ingestion Utility - Help',
                content:    'Tool to manage Bulk ingestion jobs based on a metadata configuration. Note that CSVs need to include all headers even if they are not used or it will result in an error.' +
                            '<br/> Add CSV will generate a sample file based on the target mapping.<br/>' +
                            '<ul>'+
                            '<li>Press <i>complete</i> to start the job when you have added all your CSVs</li>'+
                            '<li>You can only have 1 open or in progress job at a time: No matter if it is an upsert or delete operation</li>'+
                            '<li>You can only delete Aborted or Completed jobs</li>'+
                            '<li>You can only abort open jobs, once started you cannot abort the job</li>'+
                            '<li>Breaking any of these job status rules will all give the same error message: <li>"The request conflicts with current state of the target resource"</li> This is just the API so be aware of the different rules regarding the job states</li>' +
                            '<li>This app is built on Apex and all Governor limits are in place. Any CSV file over about 5MB will fail due to the callout limit.</li>' +
                            '</ul>',
                size    :   'small'
            });
        }catch(error){
            handleError(error);
        }
    }
}