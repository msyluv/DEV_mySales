/**
 * @description       : 
 * @author            : rakshit.s@samsung.com.sds.mspdev
 * @group             : 
 * @last modified on  : 02-17-2022
 * @last modified by  : rakshit.s@samsung.com.sds.mspdev
**/
import { LightningElement, api } from 'lwc';
import getCurrentStatus from '@salesforce/apex/CustomPathController.getCurrentStatus';
import getFormData from '@salesforce/apex/CustomPathController.getFormData';
import partner_enrollment_status_fields_label from "@salesforce/label/c.partner_enrollment_status_fields_label";
import partner_enrollment_status_messages_label from "@salesforce/label/c.partner_enrollment_status_messages_label"; 
import partner_enrollment_status_heading_label from "@salesforce/label/c.partner_enrollment_status_heading_label";
import partner_enrollment_status_button_label from "@salesforce/label/c.partner_enrollment_status_button_label";
export default class PartnerEnrollmentStatus extends LightningElement {

    mainHeading = partner_enrollment_status_heading_label;
    emailLabel = partner_enrollment_status_fields_label.split(",")[0];
    enrollmentReqLabel = partner_enrollment_status_fields_label.split(",")[1];
    initializeButton = partner_enrollment_status_button_label.split(",")[0];
    searchButton = partner_enrollment_status_button_label.split(",")[1];
    editReviewButton = partner_enrollment_status_button_label.split(",")[2];



    @api emailVal='';
    @api reqVal='';
    messageVal='';
    isError = false;
    showPath = false;
    showFinalMessage = false;
    editMode = false;
    filledData = [];
    
    handleInitialize(){

        this.template.querySelector('[data-id="enrollmentInput"]').value = '';
        this.template.querySelector('[data-id="emailInput"]').value = '';
        this.showPath = false;
        this.showFinalMessage = false;
        this.emailVal = '';
        this.reqVal = '';
        
    }

    emailChangedHandler(event){

       this.emailVal = event.target.value;
    }

    reqNoAction(event){

        this.reqVal = event.target.value;
       
    }

    connectedCallback(){
        this.messageVal = 'You can check the current review <br> processing status by entering the email<br> address you entered when registering<br>enrollment and the enrollment request<br> number you received.';
        
    }

    handleSearch(){
        this.showPath = false;
        this.showFinalMessage = false;
        console.log('inside search');
        getCurrentStatus({
            EmailInput: this.emailVal,
            EnrollmentNumberInput: this.reqVal
        })
        .then((result) => {
            console.log("success---->" + JSON.stringify(result));

           
            this.messageVal = result.getStatus;
            if(result.hasOwnProperty('picklistValue') && result.isFinalReviewStatus == false){
                this.showPath = true;
            }
            
            else if(result.isFinalReviewStatus == true){
                this.showFinalMessage = true;
            }

            if(result.isWarning){
                this.isError = result.isWarning;
                this.showPath = false;
                this.showFinalMessage = true;
            }

            else{
                this.isError = false; 
            }
            

            
            

        })
        .catch((error) => {
           console.log('error' + JSON.stringify(error.body));
        });

    
    }

    handleEdit(){

        console.log('1st' +  this.emailVal + '2nd' +  this.reqVal);
        
       if(this.emailVal == '' || this.reqVal == '' ){

            this.showFinalMessage = true;
            this.isError = true;
            this.messageVal = partner_enrollment_status_messages_label.split(',')[0];
       }
        

       else{

       console.log('inside else');

        getFormData({
				EmailInput: this.emailVal,
            EnrollmentNumberInput: this.reqVal
			})
				.then((result) => {
                    result.EditContext = true;
                    if(result.Status__c == 'Assignment of Negotiator'){
                        result.completeReadOnly = true;
                        
                    }
                    else{
                        result.completeReadOnly = false;
                    }
                    console.log('inside current work' + result.Reviewer__c);
                    if(result.Status__c == '신청접수' && result.Reviewer__c === undefined){
                        result.Reviewer__c = '미배정';
                    }
                      this.filledData = result;
                     this.editMode =true;
					console.log('return-->' + JSON.stringify(result));

                      this.showFinalMessage = false;
            this.isError = false;
            this.messageVal = '';

				})
				.catch((error) => {
					this.error = error;
				});

        
    }
}
}