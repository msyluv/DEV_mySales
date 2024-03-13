/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-23-2022
 * @last modified by  : zenith21c@test.com
**/
import { LightningElement, wire, api } from 'lwc';
import getPartnerBusinessList from '@salesforce/apex/PartnerBusinessListController.getPartnerBusinessList';
import PARTNER_BUSINESS from '@salesforce/schema/Partner_Business_Management__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PARTNER_BUSINESS_LABEL from '@salesforce/label/c.PARTNER_BUSINESS_LABEL';
import VIEW_ALL from '@salesforce/label/c.VIEW_ALL';
import { NavigationMixin } from 'lightning/navigation';

export default class PartnerBusinessList extends NavigationMixin(LightningElement) {

    partnerBusinessList = [];
    listTile = PARTNER_BUSINESS_LABEL;
    viewAll = VIEW_ALL;
    listViewUrl;

    @api objectApiName;

    @wire(getObjectInfo, { objectApiName: PARTNER_BUSINESS })
    partnerBusinessLabels;
    get businessCode() {
        return this.partnerBusinessLabels.data.fields.Name.label;
    }
    get projectName() {
        return this.partnerBusinessLabels.data.fields.Project_Name__c.label;
    }
    get partnerSales() {
        return this.partnerBusinessLabels.data.fields.Partner_Sales__c.label;
    }
    get scheduledServiceOpeningDate() {
        return this.partnerBusinessLabels.data.fields.Scheduled_Service_Opening_Date__c.label;
    }

    getFilterName() {
        //mspdev : DEV
        //qa-sds-msp : QA
        //partner-network.samsungsds.com : PROD
        var baseUrlCompare = window.location.origin;
        var mode = '';
        if ((baseUrlCompare).includes('mspdev')) {mode = 'DEV';};
        if ((baseUrlCompare).includes('qa-sds-msp')) {mode = 'QA';};
        if ((baseUrlCompare).includes('partner-network.samsungsds.com')) {mode = 'PROD';};
        var filterName = '';

        if (mode == 'DEV') {filterName = '00B0w000002Z2YwEAK';}
        if (mode == 'QA') {filterName = '00B1s000001GVZNEA4';}
        if (mode == 'PROD') {filterName = '';}
        
        return filterName;
    }


    @wire(getPartnerBusinessList)
    partnerBusinessHandler(result) {
        const { data, error } = result;
        if(data) {
            let recordUrl, businessCode, projectName, partnerSales, formattedServiceDate;
            console.log(data);
            this.partnerBusinessList = data.map(newpartnerBusinessList => {
                recordUrl = `/s/detail/${newpartnerBusinessList.Id}`;
                businessCode = newpartnerBusinessList.Name;
                projectName = newpartnerBusinessList.Project_Name__c;
                partnerSales = newpartnerBusinessList.Partner_Sales__c;
                formattedServiceDate = (new Date(newpartnerBusinessList.Scheduled_Service_Opening_Date__c)).toLocaleDateString('ko-KR')
                return {...newpartnerBusinessList, recordUrl, businessCode, projectName, partnerSales, formattedServiceDate}
            });
            console.log(this.partnerBusinessList);
        }
        if(error) {
            console.error(error);
        }
    }

    connectedCallback() {
        var fname = this.getFilterName();
        this.partnerBusinessListView = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Partner_Business_Management__c',
                actionName: 'list'
            },
            state: {
                filterName: fname
            }
        };
        this[NavigationMixin.GenerateUrl](this.partnerBusinessListView)
            .then(listViewUrl => this.listViewUrl = listViewUrl);
    }

    handleListView(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate](this.partnerBusinessListView);
    }
}