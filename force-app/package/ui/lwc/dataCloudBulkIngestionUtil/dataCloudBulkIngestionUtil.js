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
import textModal            from 'c/textModal';

// Modals
import mappingModal         from 'c/dataCloudMappingModal';
import jobDetailsModal      from 'c/dataCloudJobDetailsModal';
import addCsvModal          from 'c/dataCloudAddCsvModal';

// Apex methods
import getMtdConfigOptions  from "@salesforce/apex/DataCloudUtilLwcCtrl.getMtdConfigOptions";
import getIngestionJobTable from "@salesforce/apex/DataCloudUtilLwcCtrl.getIngestionJobTable";
import newJob               from "@salesforce/apex/DataCloudUtilLwcCtrl.newJob";
import abortJob             from "@salesforce/apex/DataCloudUtilLwcCtrl.abortJob";
import completeJob          from "@salesforce/apex/DataCloudUtilLwcCtrl.completeJob";
import deleteJob            from "@salesforce/apex/DataCloudUtilLwcCtrl.deleteJob";

/*
// Actions for the bulk jobs
const actions = [
    { label: 'Details',      name: 'details'  },
    { label: 'Add CSV Data', name: 'csv'      },
    { label: 'Upload CSV',   name: 'uploadCsv'},
    { label: 'Complete',     name: 'complete' },
    { label: 'Abort',        name: 'abort'    },
    { label: 'Delete',       name: 'delete'   }
];

// Columns for the bulk jobs
const columns = [
    { label: 'Created Date', fieldName: 'createdDate' },
    { label: 'Job Id',       fieldName: 'id' },
    { label: 'Operation',    fieldName: 'operation' },
    { label: 'Object',       fieldName: 'object' },
    { label: 'Job State',    fieldName: 'state' },
    { type: 'action', typeAttributes: { rowActions: actions, menuAlignment: 'auto' } }
];
*/

// Main class
export default class DataCloudBulkIngestionUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Bulk job datatable
    ldt = {};
    
    // Indicator to view the button
    mdtConfigOptionsLoaded = false;
    mdtConfigSelected      = false;

    // Config record picklist details
    mdtConfigRecord;
    mdtConfigOptions = [];

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
     **                                       TABLE ACTION HANDLERS                                          **
     ** **************************************************************************************************** **/
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'details':
                this.handleOpenJobDetailsModal({
                    mdtConfigRecord : this.mdtConfigRecord,
                    jobId : row.id
                });
            break;

            case 'csv':
                this.handleOpenAddCsvModal({
                        mdtConfigRecord : this.mdtConfigRecord,
                        jobId : row.id,
                        isUpload : false
                    });
            break;

            case 'uploadCsv':
                this.handleOpenAddCsvModal({
                        mdtConfigRecord : this.mdtConfigRecord,
                        jobId : row.id,
                        isUpload : true
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
    handleNew(){
        try{
            this.loading = true;
            newJob( {
                mdtConfigName : this.mdtConfigRecord,
                jobType       : 'upsert'
            })
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully created a new bulk UPSERT job with Id : "' + result +'"',
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
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully created a new bulk DELETE job with Id : "' + result +'"',
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
            abortJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
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
            deleteJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then(() => {
                    LightningAlert.open({
                        message: 'Succesfully DELETED the a bulk job with Id : "' + jobId +'"',
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


    handleComplete(jobId){
        try{
            this.loading = true;
            completeJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then(() => {
                    LightningAlert.open({
                        message: 'Succesfully COMPLETED the a bulk job with Id : "' + jobId +'"',
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
                });
        }catch(error){
            handleError(error);
            this.loading = false;
        }
    }


    handleGetIngestionJobTable(){
        try{
            this.loading = true;
            getIngestionJobTable({mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    console.log(JSON.stringify(result,null,4));
                    this.ldt = result;
                })
                .catch((error) => {
                    handleError(error);

                    // Disable buttons on fault state
                    this.mdtConfigSelected = false;
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
        this.jobTableData = [];
        this.mdtConfigRecord = event.detail.value;
        this.mdtConfigSelected = true;
        this.handleGetIngestionJobTable();
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
        this.handleOpenMappingModal({
            mdtConfigRecord : this.mdtConfigRecord
        });
    }

    handleClickHelp(){
        textModal.open({
            header : 'Data Cloud Bulk Ingestion Utility Help',
            content:'Tool to manage Bulk ingestion jobs based on a metadata configuration. Note that CSVs need to include all headers even if they are not used or it will result in an error.' +
                    '<br/> Add CSV will generate a sample file based on the target mapping.<br/>' +
                    '<ul>'+
                    '<li>Press <i>complete</i> to start the job when you have added all your CSVs</li>'+
                    '<li>You can only have 1 open or in progress job at a time: No matter if it is an upsert or delete operation</li>'+
                    '<li>You can only delete Aborted or Completed jobs</li>'+
                    '<li>You can only abort open jobs, once started you cannot abort the job</li>'+
                    '<li>Breaking any of these job status rules will all give the same error message: <li>"The request conflicts with current state of the target resource"</li> This is just the API so be aware of the different rules regarding the job states</li>' +
                    '<li>This app is built on Apex and all Governor limits are in place. Any CSV file over about 5MB will fail due to the callout limit.</li>' +
                    '</ul>'
        });
    }


    /** **************************************************************************************************** **
     **                                            MODAL METHODS                                             **
     ** **************************************************************************************************** **/
    /**
     * Open the Mapping Modal
     */
    async handleOpenMappingModal (config) {
        mappingModal.open({
            config: config,
            size: 'small',
        });
    }


    /**
     * Open the Job Details Modal
     */
    async handleOpenJobDetailsModal (config) {
        jobDetailsModal.open({
            config: config,
            size: 'small',
        });
    }


    /**
     * Open the CSV Modal, on successful addition of the CSV file refresh the table
     */
     async handleOpenAddCsvModal (config) {
        addCsvModal.open({
            config: config,
            size: 'medium',
        }).then((result) => {
            if(result === 'ok') {
                this.handleGetIngestionJobTable();
            }
        });
    }
}