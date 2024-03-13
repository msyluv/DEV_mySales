/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : zenith21c@test.com
**/
import { LightningElement, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import USER_ID from '@salesforce/user/Id';
import getReconsentTCList from '@salesforce/apex/PartnerSignupReconsentController.getReconsentTCList';

export default class Footer extends NavigationMixin(LightningElement) {
    
    updatedTCNames;
    partnerTCNames;
    userReconsentNames;
    refreshedList;
    userId = USER_ID;
    refreshed = false;

    @wire(getReconsentTCList, { recId: '$userId' })
    getReconsentTCData(result) {
        this.refreshedList = result;
        const {data, error} = result;
        if(data) {
            this.refresh();
            this.userReconsentNames = data;
            console.log('Updated Reconsent Terms Available!');
            console.log(data);
            this.navigateToPartnerSignupReconsentForce();
        }
        if(error) {
            this.userReconsentNames = '';
            console.error(error);
        }
    }

    @api
    refresh() {
        return refreshApex(this.refreshedList); 
    }

    renderedCallback() {
        console.log('Footer is rendered');
    }

    navigateToPartnerSignupReconsentForce() {
        if(this.userReconsentNames.length != 0) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'Partner_Signup_Reconsent__c'
                }
            });
        }
        else {
            console.log('Agreed to updated terms!');
        }
    }

    navigateToPartnerPrivacyPolicy(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Partner_Privacy_Policy__c'
            }
        });
    }

    navigateToTermsOfService(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Terms_of_Service__c'
            }
        });
    }
}