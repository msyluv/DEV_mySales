/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-23-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
import { LightningElement, wire, track, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getUserProfile from '@salesforce/apex/UserInformation.getUserInformation';
import getFundInformation from '@salesforce/apex/FundOverviewController.getFundInformation';

export default class FundOverview extends NavigationMixin(LightningElement) {
    @api fundAllocationAvailable;
    @api fundRequestSubmittedAndApproved;
    @api fundClaimApproved;
    @api fundClaimPaid;

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
    @wire(getFundInformation, { recId: '$userId' })
    fundInformationHandler(result) {
        const { data, error } = result;
        if(data) {
            for(var key in data){
                console.log('[key]:'+key+'[data]:'+data[key]);
            }
            this.fundAllocationAvailable = data.fundAllocationAvailable.toLocaleString('en');                     
            this.fundRequestSubmittedAndApproved = data.fundRequestSubmittedAndApproved.toLocaleString('en');
            this.fundClaimApproved = data.fundClaimApproved.toLocaleString('en');
            this.fundClaimPaid = data.fundClaimPaid.toLocaleString('en');
        }
        if(error) {
            console.error(error);
        }
    }



    getFilterName(num) {
        //mspdev : DEV
        //qa-sds-msp : QA
        //partner-network.samsungsds.com : PROD
        var baseUrlCompare = window.location.origin;
        var mode = '';
        if ((baseUrlCompare).includes('mspdev')) {mode = 'DEV';};
        if ((baseUrlCompare).includes('qa-sds-msp')) {mode = 'QA';};
        if ((baseUrlCompare).includes('partner-network.samsungsds.com')) {mode = 'PROD';};
        var filterName = '';
        //FundRequest
        if (num == '1') {
            if (mode == 'DEV') {filterName = '00B1s0000012KvzEAE';}
            if (mode == 'QA') {filterName = '00B1s000001GV1BEAW';}
            if (mode == 'PROD') {filterName = '';}
        }
        //FundClaim
        else if (num == '2') {
            if (mode == 'DEV') {filterName = '00B1s0000012Kw1EAE';}
            if (mode == 'QA') {filterName = '00B1s000001GV1DEAW';}
            if (mode == 'PROD') {filterName = '';}
        }
        
        return filterName;
    }

    requestSubmittedAndApproved(){
        

    }


    get dynamicCursor() {
        if(this.currentUser == 'Partner Community Member' || this.currentUser == 'Partner Community Login Member') {
            this.cursorDefault = true;
        }
        return this.cursorDefault ? 'cursor_default' : '';
    }

    navigateToFundRequest(event) {
        if(this.currentUser == 'Partner Community Member' || this.currentUser == 'Partner Community Login Member') {
            console.log('Cant Access');
        }
        else {
            event.preventDefault();
            event.stopPropagation();
            var filter = this.getFilterName(1);
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'PartnerFundRequest',
                    actionName: 'list',
                    url: window.location.origin
                },
                state: {
                    filterName: filter
                }
            });
        }
    }

    navigateToFundClaim(event) {
        if(this.currentUser == 'Partner Community Member' || this.currentUser == 'Partner Community Login Member') {
            console.log('Cant Access');
        }
        else {
            event.preventDefault();
            event.stopPropagation();
            var filter = this.getFilterName(2);
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: 'PartnerFundClaim',
                    actionName: 'list',
                    url: window.location.origin
                },
                state: {
                    filterName: filter
                }
            });
        }
    }
}