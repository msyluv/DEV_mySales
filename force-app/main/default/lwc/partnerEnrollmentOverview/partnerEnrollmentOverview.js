import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PartnerEnrollmentOverview extends NavigationMixin(LightningElement) {

    navigatePartnerEnrollmentRequest(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Partner_Enrollment__c'
            }
        });
    }

    navigatePartnerEnrollmentStatusCheck(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                name: 'Partner_Enrollment_Request_Status__c'
            }
        });
    }
}