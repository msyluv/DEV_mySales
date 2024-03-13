/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 03-19-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-23-2020   woomg@dkbmc.com   Initial Version
 * 1.1   07-27-2023   aditya.r2@samsung.com		Rounded the Summary
**/
({
    doInit : function(component, event) {
        console.log("Revenue Schedule doInit..");
        var self = this,
            recordId = component.get("v.recordId"),
            sObjectName = component.get("v.sObjectName");

        var getAmount = sObjectName == 'Sales_Lead__c' ? 'getSalesLeadAmount' : 'getOpportunityAmount',
            getSchedule = sObjectName == 'Sales_Lead__c' ? 'getSalesLeadSchedules' : 'getOpportunitySchedules';

        component.set("v.showSpinner", true);
        self.apex(component, getAmount, {
                recordId : recordId
            })
            .then(function(result){
                console.log('getAmount -> ', result);
                component.set("v.amount", result);
                console.log('Init Function Amount : '+ component.get("v.amount"));
                return self.apex(component, getSchedule, { recordId : recordId });
            })
            .then(function(result){
                console.log('getSchedules -> ', result);
                component.set("v.revenueSchedules", result);
                self.calcSummary(component);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    clickReset : function(component, event){
        var self = this,
            recordId = component.get("v.recordId"),
            sObjectName = component.get("v.sObjectName");

        var getAmount = sObjectName == 'Sales_Lead__c' ? 'getSalesLeadAmount' : 'getOpportunityAmount',
            getNewSchedule = sObjectName == 'Sales_Lead__c' ? 'getNewSalesLeadSchedules' : 'getNewOpportunitySchedules';

        component.set("v.showSpinner", true);
        self.apex(component, getAmount, {
                recordId : recordId
            })
            .then(function(result){
                console.log('getAmount -> ', result);
                component.set("v.amount", result);

                return self.apex(component, getNewSchedule, { recordId : recordId });
            })
            .then(function(result){
                console.log('getNewSchedules -> ', result);
                component.set("v.revenueSchedules", result);
                self.calcSummary(component);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
    },

    clickSave : function(component, event){
        var self = this,
            recordId = component.get("v.recordId"),
            sObjectName = component.get("v.sObjectName"),
            amount = component.get("v.amount"),
            summary = component.get("v.summary"),
            gap = amount - summary,
            records = component.get("v.revenueSchedules"),
            closeAction = $A.get("e.force:closeQuickAction");

        if(amount == summary){

            var action = sObjectName == 'Sales_Lead__c' ? 'saveSalesLeadSchedules' : 'saveOpportunitySchedules';

            component.set("v.showSpinner", true);
            self.apex(component, action, {
                    recordId : recordId,
                    records : records
                })
                .then(function(result){
                    console.log('saveSchedules -> ', result);
                    component.set("v.showSpinner", false);
                    closeAction.fire();
                })
                .catch(function(errors){
                    self.errorHandler(errors);
                    component.set("v.showSpinner", false);
                    closeAction.fire();
                });
    
        } else {
            var msg = $A.get("$Label.c.REVENUE_SCHEDULE_COMP_ERROR_DIFFERENCE");
            self.showMyToast("error", msg + " (" + self.numberWithComma(gap) + ")");
        }
    },

    calcSummary : function(component){
        var self = this,
            records = component.get("v.revenueSchedules"),
            amount = component.get("v.amount"),
            summary = 0.00,
            numMonth = 0;
        numMonth = records.length != undefined ? records.length : 0;
        component.set("v.numMonth", numMonth);
        records.forEach(function(item){
            summary +=  Number(parseFloat(item.Revenue__c));
            summary = (Number(Math.round(summary*100)/100));	// v1.1 MySales-262
        });

        component.set("v.summary", summary);
        component.set("v.gap", amount != 0 ? amount - summary : 0);
    },

    resetNull : function(event){
        var el = event.getSource();
        event.preventDefault();
        if(el.get("v.value") == "") el.set("v.value", "0");
    },

    numberWithComma : function(num){
        return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    },



    apex : function(component, apexAction, params){
        /**
         * calling rule
        self.apex(component, 'method1', {})
            .then(function(result1){
                console.log('handlw with result1');
                return self.apex(component, 'method2', {});
            })
            .then(function(result2){
                console.log('handlw with result2');
            });
         */
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},

})