/* eslint-disable no-console */
/*
  @description       : 
  @author            : rakshit.s@samsung.com.sds.mspdev
  @group             : 
  @last modified on  : 02-17-2022
  @last modified by  : rakshit.s@samsung.com.sds.mspdev
*/
import { LightningElement, api, wire, track } from 'lwc';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import Partner_Enrollment_Request__c_OBJECT from '@salesforce/schema/Partner_Enrollment_Request__c';

import PICKLIST_FIELD from '@salesforce/schema/Partner_Enrollment_Request__c.Status__c';

import { getRecord } from 'lightning/uiRecordApi';
// import show toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
// import update record api
import { updateRecord } from 'lightning/uiRecordApi';
import getCurrentStatus from '@salesforce/apex/CustomPathController.getCurrentStatus';

const FIELDS = [
    'Partner_Enrollment_Request__c.Id',
    'Partner_Enrollment_Request__c.Status__c'
];

export default class CustomPathLwc extends LightningElement {

    @track selectedValue;
    @api recordId;
     @api emailentered = '';
     @api enrollmentnum = '';
     statusVal;
    @track showSpinner = false;

    @wire(getObjectInfo, { objectApiName: Partner_Enrollment_Request__c_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: PICKLIST_FIELD })
    picklistFieldValues;
   

    renderedCallback(){

        getCurrentStatus({
            EmailInput: this.emailentered,
            EnrollmentNumberInput: this.enrollmentnum
        })
        .then((result) => {
            console.log("success1111---->" + result.picklistValue);
            this.statusVal = result.picklistValue;

            
            

        })
        .catch((error) => {
           console.log('error path');
        });
    }

   
    get status() {
        return this.statusVal;
    }

  
    get picklistValues() {
        
       
               let itemsList = [];
            console.log('before console-->' + JSON.stringify(this.picklistFieldValues) );
          
            if (this.picklistFieldValues && this.picklistFieldValues.data && this.picklistFieldValues.data.values) {
                console.log('got picklist field data-->' + this.statusVal);
                let selectedUpTo = 0;
                for (let item in this.picklistFieldValues.data.values) {

                    if (Object.prototype.hasOwnProperty.call(this.picklistFieldValues.data.values, item)) {
                        let classList;
                        this.selectedValue = this.statusVal;
                        console.log('imp value--->' + this.picklistFieldValues.data.values[item].value);
                        console.log('comparison val-->' + this.selectedValue);
                        if (this.picklistFieldValues.data.values[item].value === this.selectedValue) {
                            classList = 'slds-path__item slds-is-current slds-is-active';
                            selectedUpTo++;
                        } else {
                            classList = 'slds-path__item slds-is-incomplete';
                        }

                        console.log('items-->' + item.label);

                        itemsList.push({
                            pItem: this.picklistFieldValues.data.values[item],
                            classList: classList
                        })
                    }
                }

               /* if (selectedUpTo > 0) {
                    for (let item = 0; item < selectedUpTo; item++) {
                        itemsList[item].classList = 'slds-path__item slds-is-complete';
                    }
                }*/
                console.log('im here = ' + this.selectedValue);
                return itemsList;
            }
        
        return null;
    }

  

}