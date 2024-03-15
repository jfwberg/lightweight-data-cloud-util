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
import {handleError}         from 'c/util';
import {handleDownload}      from 'c/util';
import {copyTextToClipboard} from 'c/util';


// Main class
export default class DataCloudYamlModal extends LightningModal {

    loading = false;

    // Copy button style
    variant         = 'brand';
    downloadVariant = 'brand';

    // Textarea modal
    @api label;
    @api content;
    @api disabled = false;

    // Download info
    @api template;
    @api fileName         = 'Unknown_File_Name';
    @api fileExtension    = '.txt';
    @api fileMimeType     = 'text/plain';
    @api includeTimestamp = false;


    /** **************************************************************************************************** **
     **                                        INPUT CHANGE HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleChangeContent(event){
        this.content = event.target.value;
    }


    handleClickClose() {
        this.close();
    }


    handleClickCopy() {
        try{
            this.loading = true;

            copyTextToClipboard(this.content);
            
            // Change color to green
            this.variant = 'success';

        }catch(error){
            // Change color to red
            this.variant = 'destructive';
            handleError(error);
        }finally{
            this.loading = false;
        }
    }


    handleClickDownload() {
        try{
            this.loading = true;

            handleDownload(
                this.template,
                this.fileName,
                this.fileExtension,
                this.fileMimeType,
                this.content,
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


    /** **************************************************************************************************** **
     **                                           SUPPORT METHODS                                            **
     ** **************************************************************************************************** **/
    handleClose(){
        this.close('ok');
    }
}