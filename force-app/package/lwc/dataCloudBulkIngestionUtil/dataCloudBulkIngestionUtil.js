// Lightning stuff
import   LightningAlert     from 'lightning/alert';
import { LightningElement } from "lwc";

// Modals
import mappingModal         from 'c/dataCloudMappingModal';
import jobDetailsModal      from 'c/dataCloudJobDetailsModal';
import addCsvModal          from 'c/dataCloudAddCsvModal';

// Apex methods
import getMtdConfigOptions  from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getConfigMetadataRecordsPicklistOptions";
import getIngestionJobTable from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.getIngestionJobTable";
import newJob               from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.newJob";
import abortJob             from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.abortJob";
import completeJob          from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.completeJob";
import deleteJob            from "@salesforce/apex/DataCloudBulkIngestionUtilLwcCtrl.deleteJob";

// Actions for the bulk jobs
const actions = [
    { label: 'Details', name: 'details' },
    { label: 'Add CSV', name: 'csv'     },
    { label: 'Complete',name: 'complete'},
    { label: 'Abort',   name: 'abort'   },
    { label: 'Delete',  name: 'delete'  }
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


export default class DataCloudBulkIngestionUtil extends LightningElement {

    // Loading indicator for the spinner
    loading = false;

    // Bulk job column details
    jobTableData = [];
    columns = columns;

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
                        jobId : row.id
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
            newJob( {mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully created a new bulk job with Id : "' + result +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message); 
        }
    }
    

    handleAbort(jobId){
        try{
            this.loading = true;
            abortJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully ABORTED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }


    handleDelete(jobId){
        try{
            this.loading = true;
            deleteJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully DELETED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }


    handleComplete(jobId){
        try{
            this.loading = true;
            completeJob({mdtConfigName : this.mdtConfigRecord, jobId : jobId})
                .then((result) => {
                    LightningAlert.open({
                        message: 'Succesfully COMPLETED the a bulk job with Id : "' + jobId +'"',
                        label: 'Success',
                        theme : 'success'
                    });
                    
                    // Update the job table after creation
                    this.handleGetIngestionJobTable();
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
        }
    }
    

    handleGetMdtOptions(){
        try{
            getMtdConfigOptions()
                .then((result) => {
                    this.mdtConfigOptions = result;
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                })
                .finally(()=>{
                    this.mdtConfigOptionsLoaded = true;
                });
        }catch(error){
            this.handleError(error.message); 
        }
    }


    handleGetIngestionJobTable(){
        try{
            this.loading = true;
            getIngestionJobTable({mdtConfigName : this.mdtConfigRecord})
                .then((result) => {
                    this.jobTableData = result;
                    console.log(this.jobTableData);
                })
                .catch((error) => {
                    this.handleError(error.body.message);
                    
                    // Disable buttons on fault state
                    this.mdtConfigSelected = false;
                })
                .finally(()=>{
                    this.loading = false;
                });
        }catch(error){
            this.handleError(error.message);
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

    handleClickRefresh(){
        this.handleGetIngestionJobTable();
    }

    handleClickShowMapping(){
        this.handleOpenMappingModal({
            mdtConfigRecord : this.mdtConfigRecord
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
        }).then((result) => {
            
        });
    }


    /**
     * Open the Job Details Modal
     */
    async handleOpenJobDetailsModal (config) {
        jobDetailsModal.open({
            config: config,
            size: 'small',
        }).then((result) => {
            
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


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleError(msg){
        LightningAlert.open({
            message: 'An unexpected error occurred: ' + msg,
            label  : 'Error',
            theme : 'error'
        }); 
    }
}