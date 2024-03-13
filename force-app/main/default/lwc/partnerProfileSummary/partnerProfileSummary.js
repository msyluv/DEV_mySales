/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-29-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
import { LightningElement, wire, track, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getUserProfile from '@salesforce/apex/UserInformation.getUserInformation';
import getPartnerProfileSummary from '@salesforce/apex/PartnerProfileSummaryController.partnerProfileSummary';

export default class PartnerProfileSummary extends NavigationMixin(LightningElement) {

    reAuthCnt;
    businessAmountSum;
    partnerBenefit;

    @track currentUser;
    cursorDefault = false;
    userId = USER_ID;

    @wire(getUserProfile, { recId: '$userId' })
    currentUserProfile({data, error}) {
        if(data) {
            this.currentUser = data.Name;
        }
        if(error) {
            console.error(error);
        }
    }
    
    @wire(getPartnerProfileSummary, { recId: '$userId' })
    partnerProfileSummaryHandler({data, error}) {
        if(data) {
            for (let key in data) {
                console.log('key:'+key+'data:'+data[key]);
                if(key=='reAuthCnt'){
                    this.reAuthCnt = data[key].toLocaleString('en');
                }else if(key=='businessAmountSum'){
                    this.businessAmountSum = data[key].toLocaleString('en');
                }else if(key=='partnerBenefit'){
                    this.partnerBenefit = data[key].toLocaleString('en');
                }
            }
        }
        if(error) {
            console.error(error);
        }
    }
}