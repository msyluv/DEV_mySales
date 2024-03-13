import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class EducationOverview extends NavigationMixin(LightningElement) {

    navigateToPartnerProgram(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Partnership_Guide__c',
                actionName: 'list'
            }
        });
    }
}