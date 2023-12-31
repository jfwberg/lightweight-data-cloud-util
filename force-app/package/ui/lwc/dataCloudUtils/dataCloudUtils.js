/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    LWC JS Class
 */
// Lightning stuff
import   LightningAlert     from 'lightning/alert';

// Modals
import helpModal            from 'c/dataCloudHelpModal';

/** **************************************************************************************************** **
 **                                            MODAL METHODS                                             **
 ** **************************************************************************************************** **/
export function openHelpModal(content){
    helpModal.open({
        content: content,
        size: 'small',
    });
}


/** **************************************************************************************************** **
 **                                           SUPPORT METHODS                                            **
 ** **************************************************************************************************** **/
export function handleError(error){
        
    // If something really weird happens have a default message
    let msg = 'Unknown error message';

    // LWC Controller error
    if(error.body !== undefined){
        msg = 'Apex Controller Error : ' + error.body.message;
    
    // Javascript error
    }else if(error.message !==undefined){
        msg = 'Javascript Error : ' + error.message;
    }

    // Open the lightning alert;
    LightningAlert.open({
        message: msg,
        label: 'Error',
        theme : 'error'
    });
}


/**
 * Copied from github user gonzalezjesus and slightly modified for export
 * https://github.com/gonzalezjesus/sf-clips/blob/main/force-app/main/default/lwc/copyTextToClipboard/copyTextToClipboard.js
 * 
 * Import and invoke the copyTextToClipboard method passing the content you want to put in the clipboard as param. 
 * You can use "\n" to add line breaks to the text. You can also see an example this in the component "copyToClipboardBtn".
 */
export function copyTextToClipboard(content){
	
    // Create an input field with the minimum size and place in a not visible part of the screen
	let tempTextAreaField = document.createElement('textarea');
	tempTextAreaField.style = 'position:fixed;top:-5rem;height:1px;width:10px;';

	// Assign the content we want to copy to the clipboard to the temporary text area field
	tempTextAreaField.value = content;

	// Append it to the body of the page
	document.body.appendChild(tempTextAreaField);

	// Select the content of the temporary markup field
	tempTextAreaField.select();

	// Run the copy function to put the content to the clipboard
	document.execCommand('copy');

	// Remove the temporary element from the DOM as it is no longer needed
	tempTextAreaField.remove();
}


/**
 * Method to download a specific file
 */
export function handleDownload(template, fileName, fileExtension, mimeType, content, addTimestamp){

    // Setup download link
    let a = document.createElement('a');
    a.style.display = 'none';  
    a.setAttribute('download', fileName + ((addTimestamp) ? ('_' + new Date().toISOString().replace(/(\.\d{3})|[^\d]/g,''))  : '') + fileExtension);
    a.setAttribute('href', 'data:' + mimeType + ',' + encodeURIComponent(content));
    
    // Add, execute and remove from DOM
    template.appendChild(a);
    a.click();
    template.removeChild(a);
}