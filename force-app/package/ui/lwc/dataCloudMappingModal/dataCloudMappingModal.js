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

// Main class
export default class DataCloudMappingModal extends LightningModal {
    // Config
    @api config;

    // Spinner indicator
    loading = false;

    // Indicated loading is complete
    loaded = false;

    // Map with header and Lightning datatable
    tableList = []
    

    /** **************************************************************************************************** **
     **                                         LIFECYCLE HANDLERS                                           **
     ** **************************************************************************************************** **/
    connectedCallback(){
        try{
            this.loading = true;

            getMetadataInfo({
                mdtConfigName : this.config.mdtConfigRecord
            })
            .then((apexResponse) => {
                this.tableList = apexResponse;
                this.loaded    = true;
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