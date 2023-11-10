/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import { api }           from 'lwc';
import LightningModal    from 'lightning/modal';

// Main class
export default class DataCloudHelpModal extends LightningModal  {

    @api header  ='';
    @api content ='';
    
   
    /** **************************************************************************************************** **
     **                                        CLICK BUTTON HANDLERS                                         **
     ** **************************************************************************************************** **/
    handleClickClose() {
        this.close();
    }
}