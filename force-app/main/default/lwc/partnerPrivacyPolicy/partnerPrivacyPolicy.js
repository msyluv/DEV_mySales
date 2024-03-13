import { LightningElement, wire, api } from 'lwc';
import getPartnerPrivacyPolicyVersion from '@salesforce/apex/PartnerPrivacyPolicyController.getPartnerPrivacyPolicyVersion';

export default class PartnerPrivacyPolicy extends LightningElement {

    @api selectedVersion;
    versionDetail = [];
    versionOptions = [];
    mapData = [];

    @wire(getPartnerPrivacyPolicyVersion)
    versionPicklist({data, error}) {
        if(data) {
            this.versionOptions = data;
            for (let key in data) {
                this.mapData.push({ key: key, versionId: data[key].Version__c, id: data[key].Id, detail: data[key].T_C_Detail__c });
            }
            this.versionOptions = this.mapData;
            this.versionDetail = this.versionOptions[0].detail;
        }
        if(error) {
            console.error(error);
        }
    }

    handleVersion(event) {
        this.selectedVersion = event.target.value;
        this.versionDetail = this.versionOptions[this.selectedVersion].detail;
    }
}