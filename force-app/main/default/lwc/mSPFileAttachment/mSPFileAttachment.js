/**
 * @description       : 
 * @author            : rakshit.s@samsung.com
 * @group             : 
 * @last modified on  : 08-31-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.1   05-20-2022	  rakshit.s@samsung.com   Developed From Scratch in order to Replicate File Attachment.
 * 1.2   08-31-2022   gitesh.s@samsung.com    Added Community Login Profile
**/
import { LightningElement , api ,wire } from 'lwc';
import getAttachments from '@salesforce/apex/MSPFileAttachmentController.getAttachments';
import isguest from '@salesforce/user/isGuest';
import deleteAttachmentAction from '@salesforce/apex/MSPFileAttachmentController.deleteAttachmentAction';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import clearUploadAction from '@salesforce/apex/MSPFileAttachmentController.clearUploadAction';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import refreshComponentMock from '@salesforce/apex/MSPFileAttachmentController.refreshComponentMock';
import Id from '@salesforce/user/Id';
	
import File_Attachment_Label from '@salesforce/label/c.File_Attachment_Label';
import upload_button_label from '@salesforce/label/c.upload_button_label';



export default class MSPFileAttachment extends NavigationMixin(LightningElement) {
	currentUserId = Id;
	isGuestUser = isguest;
	@api recordId;
	@api usedInCommunity;
	attachmentData = [];
	@api myRecordId;
	//for enrollment edit action
	@api doNotAllowUploadForEnrollmentAction = false;
	createdDate;
	fileSize;
	fileType;
	sizeExtension;
	isPdf = false;
	allowUpload = false;
	sfdcBaseURL;
	imageURL;
	uploadAction = false;
	numberOfFiles;
	showSpinner = false;
	rendercomponent = false;
    showEmptyMessage =false;
	enableDelete = false;
	heading = File_Attachment_Label.split(',')[0];
	errorMessage = File_Attachment_Label.split(',')[1];
	uploadButtonlabel = upload_button_label;
	
	
	 @wire (refreshComponentMock) wireApex;

	connectedCallback() {
		console.log('inside connected callback');
		this.getCurrentAttachmentData();
		
    }

	
	handleUploadFinished(event) {
		const uploadedFiles = event.detail.files;
		console.log('inside file upload function' + JSON.stringify(event.detail.files.length));

		let idToDel = [];

		for(var i=0; i< event.detail.files.length; i++){
			console.log('inside loop');
			idToDel.push(event.detail.files[i].documentId);
		}
		console.log('ids to del->' + idToDel);

		let comparisonNum = 10-this.attachmentData.length;
		if(uploadedFiles.length > comparisonNum){

			clearUploadAction({
				incomingDocIds: idToDel
			})
			.then(result => {
				console.log('inside sucess after del');
                
			})
			.catch(error => {
				console.log('inside error-->' + JSON.stringify(error));
				this.error = error;
				//this.contacts = undefined;
			});
        
			const evt = new ShowToastEvent({
				title: 'Error',
				message: 'You cannot Upload more than 10 files/attachments.',
				variant: 'error',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
			event.detail.files = null;


		}

		else{
			this.getCurrentAttachmentData();
		this.uploadAction = false;
		}
        
    }

	formatBytes(bytes) {
		var sizes = ['B', 'KB', 'MB', 'gb', 'tb'];
		if (bytes == 0) return '0 Byte';
		var i = parseInt(Math.floor(Math.log(bytes) / Math.log(1024)));
		return Math.round(bytes / Math.pow(1024, i), 2) + ' ' + sizes[i];
	}

	navigateToFilesHome() {
		this[NavigationMixin.Navigate]({
			type: 'standard__recordRelationshipPage',
			attributes: {
				recordId: this.recordId,
				objectApiName: 'PartnerFundRequest',
				relationshipApiName: 'AttachedContentDocuments',
				actionName: 'view'
			},
		});
	}

	getCurrentAttachmentData() {

		var urlIndex = 0;
        this.showSpinner = true;
		this.myRecordId = this.recordId;
		this.sfdcBaseURL = window.location.origin;
		
		
		getAttachments({
				parentRecordId: this.recordId
			})
			.then(result => {
				console.log('result--->' + JSON.stringify(result));
				this.rendercomponent = result.rendercomponent;
				if(!result.hasOwnProperty('attachmentList')){
                   this.showEmptyMessage = true;
                    this.showSpinner = false;
					this.numberOfFiles ='';
					if(result.allowUpload){
						this.allowUpload = true;
					}
					 
                }
                else{
					if(this.showEmptyMessage == true){
						this.showEmptyMessage = false;
					}
				this.attachmentData = result.attachmentList;
                this.allowUpload = result.allowUpload;
				/*if(result.objName == 'PartnerFundRequest' || result.objName=='PartnerFundClaim'){
					this.enableDelete = true;
				}*/
				
					if (this.attachmentData.length > 10) {
					this.attachmentData = this.attachmentData.splice(0, 10);
					this.numberOfFiles = '(10+)'
				} else {
					this.numberOfFiles = '('+this.attachmentData.length+')';
				}
				
				/*else{
					if (this.attachmentData.length > 6) {
					this.attachmentData = this.attachmentData.splice(0, 6);
					this.numberOfFiles = '(6+)'
				} else {
					console.log('inside length setting block' + this.attachmentData.length);
					this.numberOfFiles = '('+this.attachmentData.length+')';
				}
				}*/
				
				for (const attachment of this.attachmentData) {
                    this.createdDate = attachment.CreatedDate.split('T')[0];
					
					let number = this.formatBytes(attachment.VersionData.split('(')[1].split(' ')[0]);

					this.fileSize = Math.round(number.split(' ')[0]);
					this.sizeExtension = number.split(' ')[1];
					
					attachment.ContentSize = this.formatBytes(Math.round(attachment.VersionData.split('(')[1].split(' ')[0]));
					attachment.CreatedDate = attachment.CreatedDate.split('T')[0];
					attachment.FileType = attachment.FileType.toLowerCase() === 'text' ? 'txt' : attachment.FileType.toLowerCase();
						//added the function so only the file owner gets to see the delete icon.
						//added by: rakshit.s@samsung.com
						//added date 26-05-2022
						console.log('the file owner id is--->' + attachment.OwnerId);
						console.log('the current user id is--->' + this.currentUserId);
						
					if(attachment.OwnerId == this.currentUserId || (this.isGuestUser && this.doNotAllowUploadForEnrollmentAction == false)){

						/*Ver 1.1 Added Community Login Profile*/
						if(result.profileName == 'Partner Community Manager' || result.profileName == 'Partner Community Login Manager'){

							if(this.allowUpload){
								attachment.isOwner = true;
							}
							else{
								attachment.isOwner = false;
							}
						}
						else{
								attachment.isOwner = true;
						}
						
					}

					else{
						attachment.isOwner = false;
					}
					

						
					

					//new logic for value end.


                    //switch
                    switch(attachment.FileType) {
                        case 'pdf':
                            attachment.isPdf = true;

                            attachment.fileURL = result.attachmentUrl[urlIndex];
                          break;
                        case 'csv':
                            attachment.isCsv = true;

						attachment.fileURL = result.attachmentUrl[urlIndex];
                            break;
                          case 'png' || 'jpg' || 'gif':
                            attachment.isImage = true;

						attachment.fileURL = result.attachmentUrl[urlIndex];
						attachment.imageURL = this.sfdcBaseURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb120by90&versionId=' + attachment.Id + '&operationContext=CHATTER&contentId=j&page=0';
                          break;
                        case 'log':
                            attachment.isUnknown = true;
                            attachment.fileURL = result.attachmentUrl[urlIndex];
                         break;
                          case 'txt':
                            attachment.isText = true;
						attachment.textURL = this.sfdcBaseURL + '/sfc/servlet.shepherd/version/renditionDownload?rendition=thumb120by90&versionId=' + attachment.Id + '&operationContext=CHATTER&contentId=j&page=0';
						attachment.fileURL = result.attachmentUrl[urlIndex];
                          break;
                        
                        default:
                            attachment.isUnknown = true;
                            attachment.fileURL = result.attachmentUrl[urlIndex];
                          // code block
                      }
                      
                 
					urlIndex++;
					this.createdDate = '';
				}
				console.log('updated result--->' + JSON.stringify(this.attachmentData));
                this.showSpinner = false;
				
				
            }
			})
			.catch(error => {
				console.log('inside error-->' + JSON.stringify(error));
				this.error = error;
				//this.contacts = undefined;
			});
        
	}

	handleUpload(event) {

console.log('upload button clicked --->' + console.log(event.detail));
		if(this.attachmentData.length >= 10){
			this.showErrorToast();
			//Event.stopPropagation();
		}
		else{
			this.uploadAction = 'true';
		
		}
		
		
	}

	previewFile(event) {

		//delete functionality added by @rakshit.s@samsung.com
		var buttonName = event.target.dataset.name;
		console.log('button name--->' + event.currentTarget.dataset.id + 'or-->' + event.target.dataset.id);
		if(event.target.closest("[data-id]").dataset.id == 'deleteButton'){
			console.log('perform delete action-->' + event.target.closest("[data-filter]").dataset.id);

			deleteAttachmentAction({
				recId: event.currentTarget.dataset.id
			})
			.then(result => {
				console.log('inside sucess after del');

				this.getCurrentAttachmentData();
				
				

                
			})
			.catch(error => {
				console.log('inside error-->' + JSON.stringify(error));
				this.error = error;
				//this.showErrorToast();
				//this.contacts = undefined;

				const evt = new ShowToastEvent({
			title: 'Error',
			message: 'You can only delete the files that you uploaded.',
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(evt);
			});
		}


		else{

		
		var docId = event.target.closest("[data-id]").dataset.id;
		var versionId = event.target.closest("[data-filter]").dataset.filter;
		let baseUrl = this.getBaseUrl();
		let fileDownloadUrl = baseUrl + 'sfc/servlet.shepherd/document/download/' + docId;
		if (!this.usedInCommunity) {
			this[NavigationMixin.Navigate]({
				type: 'standard__namedPage',
				attributes: {
					pageName: 'filePreview'
				},
				state: {
					selectedRecordId: docId
				}
			});
		} else if (this.usedInCommunity) {

			//let baseUrl='https://qa-sds-msp.cs113.force.com'+'/sfc/servlet.shepherd/document/download/'+versionId;
			//window.open(baseUrl);
/*this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: baseUrl
            }
        }, false );
			/*console.log('on click community->' + fileDownloadUrl);
			this[NavigationMixin.Navigate]({
				type: 'standard__webPage',
				attributes: {
					url: fileDownloadUrl
				}
			}, false);*/


			console.log('on click community->' + fileDownloadUrl);
			this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: fileDownloadUrl
                }
            }, false 
        );
		}

	}
	}

	getBaseUrl() {
		let baseUrl = 'https://' + location.host + '/';
		return baseUrl;
	}

    closeModal(){
        this.uploadAction =false;
    }

	showErrorToast() {
		const evt = new ShowToastEvent({
			title: 'Error',
			message: 'You cannot Upload more than 10 files/attachments.',
			variant: 'error',
			mode: 'dismissable'
		});
		this.dispatchEvent(evt);
	}

	

	
}