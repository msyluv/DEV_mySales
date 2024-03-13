/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-21-2022
 * @last modified by  : zenith21c@test.com
**/
import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import getPartnerTCAgreement from '@salesforce/apex/PartnerSignupReconsentController.getPartnerTCAgreement';
import updatePartnerTCAgreement from '@salesforce/apex/PartnerSignupReconsentController.updatePartnerTCAgreement';
import getReconsentTCList from '@salesforce/apex/PartnerSignupReconsentController.getReconsentTCList';

import partner_signup_request_header from "@salesforce/label/c.partner_signup_request_header";
import partner_signup_request_title from "@salesforce/label/c.partner_signup_request_title";
import partner_signup_request_tc from "@salesforce/label/c.partner_signup_request_tc";
import partner_signup_request_messages from "@salesforce/label/c.partner_signup_request_messages";

export default class PartnerSignupReconsentForm extends NavigationMixin(LightningElement) {

    updatedTCNames;
    partnerTCNames;
    userReconsentNames;
    updatedTerms = [];
    updatedTermsId = [];
    userId = USER_ID;
    viewTnC = false;
    submitData;
    continueFlow;
    refreshedList;

    mainHeading = partner_signup_request_header.split(",")[1];
    tnCSection = partner_signup_request_title.split(",")[1];
    reconsentText = partner_signup_request_title.split(",")[2];
    agreeAll = partner_signup_request_tc.split(",")[0];
    personalUse = partner_signup_request_tc.split(",")[1];
	crossTransfer = partner_signup_request_tc.split(",")[2];
	termsOfServ = partner_signup_request_tc.split(",")[3];
    viewDetail = partner_signup_request_tc.split(",")[4];
    toastmessage = partner_signup_request_messages.split(",")[12];

    
    @wire(getPartnerTCAgreement, { recId: '$userId' })
    partnerTCAgreement({data, error}) {
        if(data) {
            console.log('List of Updated Terms Available:');
            console.log(data);
            this.partnerTCNames = data;
        }
        if(error) {
            console.error(error);
        }
    }

    @wire(getReconsentTCList, { recId: '$userId' })
    getReconsentTCData(result) {
        this.refreshedList = result;
        const {data, error} = result;
        if(data) {
            this.userReconsentNames = data;
            if(this.userReconsentNames.length == 0) {
                this.closeReconsentForm();
            }
            console.log("List of terms not agreed to yet:");
            console.log(data);
            this.getNewTCs();
        }
        else if(error) {
            this.userReconsentNames = '';
            console.error(error);
        }
    }

    @api
    refresh() {
        return refreshApex(this.refreshedList); 
    }

    getNewTCs() {
        for(var i=0; i<this.userReconsentNames.length; i++) {
            this.updatedTerms.push(this.userReconsentNames[i]);
            this.updatedTermsId.push(this.userReconsentNames[i].Id);
        }
        this.updatedTerms = [...this.updatedTerms];
        this.updatedTermsId = [...this.updatedTermsId];
        
        console.log(this.updatedTerms);
    }

    agreeAllAction(event) {
		let i;
		let checkboxes = this.template.querySelectorAll('[data-id="check"]');

		for (i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = event.target.checked;
		}
	}

    termAndConditionsViewAction(event) {
        this.viewTnC = true;

        for(let i=0; i<this.updatedTerms.length; i++) {
            if(event.currentTarget.dataset.id === this.updatedTerms[i].T_C_Type__c) {
                this.tncContent = this.userReconsentNames[i].T_C_Detail__c;
			    this.tnCheading = this.userReconsentNames[i].Name;
            }
        }
    }

    closetncAgreementModal() {
		this.viewTnC = false;
	}

    updateAgreement() {
        this.submitData = false;
        this.continueFlow = true;
        this.validateTerms();
        if(this.submitData == true) {
            updatePartnerTCAgreement({
                partnerSignup: this.partnerTCNames[0].Partner_Signup__c,
                updatedList: this.updatedTermsId,
            }).then((result) => {
				console.log("Done!" + JSON.stringify(result));

                this.refresh();
				this.closeReconsentForm();
			})
			.catch((error) => {
				console.log('Didnt update');
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error creating record",
						message: error.body.message,
						variant: "error"
					})
				);
			});
        }
    }

    validateTerms() {
        let i;
        let checkboxes = this.template.querySelectorAll('[data-id="check"]');
        for (i = 0; i < checkboxes.length; i++) {
            if (!checkboxes[i].checked) {
                this.submitData = false;
                this.continueFlow = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: this.toastmessage,
                        variant: "error",
                        mode: "dismissable"
                    })
                );
                return;
            }
            else{
                if (this.continueFlow){
                    this.submitData = true;
                }
            }
        }        
    }

    closeReconsentForm() {
		this[NavigationMixin.Navigate]({
			type: 'comm__namedPage',
			attributes: {
				name: 'Home'
			},
		});
	}

    logoutLink() {
        this[NavigationMixin.Navigate]({
            type: 'comm__loginPage',
            attributes: {
                actionName: 'logout'
            },
        }); 
    }
    
}