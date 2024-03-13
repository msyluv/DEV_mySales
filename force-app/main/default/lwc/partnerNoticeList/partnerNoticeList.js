import { LightningElement, wire, api } from 'lwc';
import getPartnerNoticeList from '@salesforce/apex/PartnerNoticeListController.getPartnerNoticeList';
import PARTNER_NOTICE from '@salesforce/schema/Partner_Notice__c';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import PARTNER_NOTICE_LABEL from '@salesforce/label/c.PARTNER_NOTICE_LABEL';
import VIEW_ALL from '@salesforce/label/c.VIEW_ALL';
import { NavigationMixin } from 'lightning/navigation';

export default class PartnerNoticeList extends NavigationMixin(LightningElement) {

    partnerNoticeList = [];
    listTile = PARTNER_NOTICE_LABEL;
    viewAll = VIEW_ALL;
    listViewUrl;

    @api objectApiName;

    @wire(getObjectInfo, { objectApiName: PARTNER_NOTICE })
    partnerNoticeLabels;
    get noticeNumber() {
        return this.partnerNoticeLabels.data.fields.Name.label;
    }
    get subject() {
        return this.partnerNoticeLabels.data.fields.Subject__c.label;
    }
    get startDate() {
        return this.partnerNoticeLabels.data.fields.StartDate__c.label;
    }
    get endDate() {
        return this.partnerNoticeLabels.data.fields.EndDate__c.label;
    }
    @wire(getPartnerNoticeList)
    partnerNoticeHandler(result) {
        const { data, error } = result;
        if(data) {
            let recordUrl, formattedStartDate, formattedEndDate;
            console.log(data);
            this.partnerNoticeList = data.map(newPartnerNoticeList => {
                recordUrl = `/s/detail/${newPartnerNoticeList.Id}`;
                formattedStartDate = (new Date(newPartnerNoticeList.StartDate__c)).toLocaleDateString('ko-KR');
                formattedEndDate = (new Date(newPartnerNoticeList.EndDate__c)).toLocaleDateString('ko-KR')
                return {...newPartnerNoticeList, recordUrl, formattedStartDate, formattedEndDate}
            });
            console.log(this.partnerNoticeList);
        }
        if(error) {
            console.error(error);
        }
    }

    connectedCallback() {
        this.partnerNoticeListView = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Partner_Notice__c',
                actionName: 'list'
            },
            state: {
                filterName: '00B0w000002Z5SlEAK'
            }
        };
        this[NavigationMixin.GenerateUrl](this.partnerNoticeListView)
            .then(listViewUrl => this.listViewUrl = listViewUrl);
    }

    handleListView(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate](this.partnerNoticeListView);
    }
}