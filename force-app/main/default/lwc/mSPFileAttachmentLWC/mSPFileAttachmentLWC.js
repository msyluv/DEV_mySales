import { LightningElement, api } from 'lwc';
import getAttachments from '@salesforce/apex/MSPFileAttachmentController.getAttachments';

export default class MSPFileAttachmentLWC extends LightningElement {
    @api recordId;
    connectedCallback() {
        console.log('recordId-->' + recordId);
        getAttachments({ getAttachments: this.recordId })
            .then(result => {
                //this.contacts = result;
                //this.error = undefined;
                console.log('Success');
            })
            .catch(error => {
                this.error = error;
                this.contacts = undefined;
            });
      }
}