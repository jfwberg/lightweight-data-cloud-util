/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api }               from 'lwc';
import LightningModal        from 'lightning/modal';

// Custom Utils
import {handleError}         from 'c/dataCloudUtils';
import {handleDownload}      from 'c/dataCloudUtils';
import {copyTextToClipboard} from 'c/dataCloudUtils';

// Apex methods
import getDcQueryCsv         from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryCsv";
import getDcQueryTable       from "@salesforce/apex/DataCloudUtilLwcCtrl.getDcQueryTable";


// Main class
export default class DataCloudQueryResultModal extends LightningModal  {

    // Configuration
    @api config;
    
    // Loading indicator for the spinner
    loading = false;

    // Copy button style
    variant         = 'brand';
    downloadVariant = 'brand';
    
    // The CSV string that will be loaded
    csvData;

    // Result from the query
    data;

    // Column data is retrieved from the LWC controller as it is dependend on the query result
    columns = [];

    // Define result type visibility for CSV
    get isCsv(){
        return this.config.resultFormat === 'csv'  && this.loading === false;
    }

    // Define result type visibility for an LWC Data table
    get isTable(){
        return this.config.resultFormat === 'table' && this.loading === false;
    }


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback() {
        try{
            // Handle CSV
            if(this.config.resultFormat === 'csv'){
                this.handleGetDcQueryCsv();
            
            // Handle data table
            }else if(this.config.resultFormat === 'table'){
                this.handleGetDcQueryTable();
            }
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
     handleChangeCsvData(event){
        this.csvData = event.target.value;
    }


    /** **************************************************************************************************** **
     **                                            APEX HANDLERS                                             **
     ** **************************************************************************************************** **/
    handleGetDcQueryCsv(){
        try{
            this.loading = true;
            getDcQueryCsv({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query
            })
            .then((result) => {
                this.csvData = result;
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }

    handleGetDcQueryTable(){
        try{
            this.loading = true;
            getDcQueryTable({
                mdtConfigName : this.config.mdtConfigName,
                query         : this.config.query
            })
            .then((result) => {

               
                this.data = result.data;

                for (let index = 0; index < result.columns.length; index++) {
                    this.columns.push({ 
                        label        : result.columns[index],
                        fieldName    : String(index),
                        initialWidth : result.columns[index].length < 10 ? 120 : (result.columns[index].length * 12)
                    });
                }

                
            })
            .catch((error) => {
                handleError(error);
                this.close();
            })
            .finally(()=>{
                this.loading = false;
            });
        }catch(error){
            handleError(error);
            this.loading = false;
            this.close();
        }
    }


    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }


    handleClickCopy(){
        try{
            // Execute copy
            copyTextToClipboard(this.csvData);

            // Change color to green
            this.variant = 'success';
        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);
        }
    }

    handleClickDownload() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                'Data_Cloud_Query',
                '.csv',
                'text/csv; charset=utf-8;',
                this.csvData,
                true
            );

            // change button color to green
            this.downloadVariant = 'success';

        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);

        }finally{
            this.loading = false;
        }
    }
}