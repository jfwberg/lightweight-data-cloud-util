/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api }         from 'lwc';
import LightningModal  from 'lightning/modal';

// Custom Utils
import {handleError}   from 'c/util';

// Apex methods
import getMetadataInfo from "@salesforce/apex/DataCloudUtilLwcCtrl.getMetadataInfo";

// Columns for the bulk jobs
const recordColumns = [
    { label: 'Key',   fieldName: 'key'  },
    { label: 'Value', fieldName: 'value'}
];

// Columns for the bulk jobs
const mappingColumns = [ 
    { label: 'Source field (Salesforce)', fieldName: 'source' },
    { label: 'Target field (Data Cloud)', fieldName: 'target' },
    { label: 'Data Cloud Field Type',     fieldName: 'ftype'  },
    { label: 'Is Primary Key',            fieldName: 'isPk', type: 'boolean' },
    { label: 'Is Event Time Field',       fieldName: 'isEt', type: 'boolean' }
];

// Main class
export default class DataCloudMappingModal extends LightningModal {
    // Config
    @api config;

    // Spinner indicator
    loading = false;

    // Record table
    recordData = [];
    recordColumns = recordColumns;

    // Mapping table
    mappingData = [];
    mappingColumns = mappingColumns;


    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        try{
            this.loading = true;

            getMetadataInfo({
                mdtConfigName : this.config.mdtConfigRecord
            })
            .then((result) => {
                this.recordData  = result.recordData;
                this.mappingData = result.mappingData;
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
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }
}