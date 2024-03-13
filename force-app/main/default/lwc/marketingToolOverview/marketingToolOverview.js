/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-10-2022
 * @last modified by  : zenith21c@test.com
**/
import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class MarketingToolOverview extends NavigationMixin(LightningElement) {

    getFilter(num) {
        //mspdev : DEV
        //qa-sds-msp : QA
        //partner-network.samsungsds.com : REAL
        console.log('getFilter start!');
        var baseUrlCompare = window.location.origin;
        console.log('baseUrlCompare:'+baseUrlCompare);
        var mode = '';
        if ((baseUrlCompare).includes('mspdev')){mode = 'DEV';};
        if ((baseUrlCompare).includes('qa-sds-msp')){mode = 'QA';};
        if ((baseUrlCompare).includes('partner-network.samsungsds.com')){mode = 'REAL';};
        console.log('mode:'+mode);
        var filterName = '';
        //logoAndBrandGuidelineList
        if (num=='1') {
            if (mode=='DEV') {filterName = '00B0w000002ZCAaEAO';}
            if (mode=='QA')  {filterName = '00B1s000001GbOzEAK';}
            if (mode=='REAL'){filterName = '00B2w00000Ghl87EAB';}
        }
        //iconAndArchitectureDiagramList
        else if (num=='2') {
            if (mode=='DEV') {filterName = '00B0w000002ZCAfEAO';}
            if (mode=='QA')  {filterName = '00B1s000001GbOyEAK';}
            if (mode=='REAL'){filterName = '00B2w00000Ghl86EAB';}
        }
        //salesMaterialsList
        else if (num=='3') {
            if (mode=='DEV') {filterName = '00B0w000002ZCAkEAO';}
            if (mode=='QA')  {filterName = '00B1s000001GbP0EAK';}
            if (mode=='REAL'){filterName = '00B2w00000Ghl88EAB';}
        }
        //technicalMaterialList
        else if (num=='4') {
            if (mode=='DEV') {filterName = '00B0w000002ZCApEAO';}
            if (mode=='QA')  {filterName = '00B1s000001GbP1EAK';}
            if (mode=='REAL'){filterName = '00B2w00000Ghl89EAB';}
        }
        
        console.log('filterName:'+filterName);
        return filterName;
    }

    logoAndBrandGuidelineList(event) {        
        event.preventDefault();
        event.stopPropagation();
        console.log('logoAndBrandGuidelineList');
        var fn = this.getFilter('1');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Marketing_Tool__c',
                actionName: 'list',
                url: window.location.origin
            },
            state: {
                filterName: fn//'00B0w000002ZCAaEAO'
            }
        });
    }

    iconAndArchitectureDiagramList(event) {
        event.preventDefault();
        event.stopPropagation();
        var fn = this.getFilter('2');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Marketing_Tool__c',
                actionName: 'list',
                url: window.location.origin
            },
            state: {
                filterName: fn//'00B0w000002ZCAfEAO'
            }
        });
    }

    salesMaterialsList(event) {
        event.preventDefault();
        event.stopPropagation();
        var fn = this.getFilter('3');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Marketing_Tool__c',
                actionName: 'list',
                url: window.location.origin
            },
            state: {
                filterName: fn//'00B0w000002ZCAkEAO'
            }
        });
    }

    technicalMaterialList(event) {
        event.preventDefault();
        event.stopPropagation();
        var fn = this.getFilter('4');
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Marketing_Tool__c',
                actionName: 'list',
                url: window.location.origin
            },
            state: {
                filterName: fn//'00B0w000002ZCApEAO'
            }
        });
    }
}