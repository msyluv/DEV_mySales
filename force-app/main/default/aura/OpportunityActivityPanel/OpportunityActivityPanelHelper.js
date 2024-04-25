/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-03-20
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-05   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2023-10-27   gitesh.s@samsung.com             SCP Quotation Activity color change (MYSALES-339)
 * 1.2   2023-11-15   atul.k1@samsung.com              Add Link Button on Opportunity main (MYSALES-358)
 * 1.3   2024-01-30   atul.k1@samsung.com              Task - (IT) Add TXP link Button in BO Activity (MYSALES-421)
 * 1.4   2024-03-20   vikrant.ks@samsung.com           Task - (IT) Add BO Priority Check List Button in BO Activity (MYSALES-468)
**/
({
    DEBUG : true,

    doInit : function(component, event, isDelTempAct) {
        if(isDelTempAct == null) isDelTempAct=true;
        
        var self = this;
        component.set('v.showSpinner', true);

        var action = component.get("c.initComponent");
        action.setParams({
            'recordId': component.get('v.recordId'),
            'isDelTempAct' : isDelTempAct
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {     //success
                
                var result = response.getReturnValue(); 
                self.log('result', result);
                
                component.set('v.oppty',result['oppty']);
                component.set('v.isSubsidiary',result.isSubsidiary); // V 1.3 MYSALES-421
                component.set('v.isSandbox',result['isSandbox']); // V 1.4 MYSALES-468
                component.set('v.recordTypeDevName',result['recordTypeDevName']);
                component.set('v.hasEditAccess',result['hasEditAccess']);
                component.set('v.canClickSwitch',result['canClickSwitch']);
                // v1.1 - Gitesh Saini (MYSALES-339)
                component.set("v.scpSimList",result['scpList']);
                // v1.1 - Gitesh Saini
                component.set('v.activityItemList',result['panelList']['1']);
                component.set('v.activityItemListDetail',result['panelList']['2']);
                //V 1.2 MYSALES-358 Start
                if(result['oppty'].Opportunity_Review_VRB_Type_Confirm__c == '10' || result['oppty'].Opportunity_Review_VRB_Type_Confirm__c == '20' || result['oppty'].Opportunity_Review_VRB_Type_Confirm__c == '21'){
                    component.set('v.VRBTypeConfirm',true);
                }
                //V 1.2 MYSALES-358 End
                //V 1.4 MYSALES-468 Start
                if(result['oppty'].Collaboration__c == true){
                    component.set('v.isCollaboration',true);
                }
                //V 1.4 MYSALES-468 End
                // component.set('v.activityItemList',result['1']);
                // component.set('v.activityItemListDetail',result['2']);
                
            }//INCOMPLETE
            else if (state == "INCOMPLETE") {    
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == "ERROR") { 
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }

            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },

    refresh : function(component, event){
        var self = this;
        var isDelTempAct = true;
        self.doInit(component, event, isDelTempAct);
        $A.get('e.force:refreshView').fire();
    },

    refreshWithoutDelete : function(component, event){
        var self = this;
        var isDelTempAct = false;
        self.doInit(component, event, isDelTempAct);
    },

    revers : function(targetlist){
        var templist =[]
        for(var i=targetlist.length-1;i>=0;i--){
            templist[targetlist.length-1-i] = targetlist[i];
        }
        return templist;
    },

    apex : function(component, apexAction, params){
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

    errorHander : function(errors){
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
    
    /**
	 * 
	 * @param {*} component 
	 * @param {*} componentName 
	 * @param {*} attributeParams 
	 * @param {*} cssClass 
	 * @param {*} closeCallback 
	 */
	showComponentModal : function(component, componentName, attributeParams, headerName, cssClass, closeCallback) {        
        $A.createComponent('c:' + componentName
            , attributeParams
            , function(content, status, errorMessage) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
                        header: headerName,
						body: content,
						showCloseButton: true,
						cssClass: cssClass,
						closeCallback: closeCallback
					})
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
        });
	},

    log : function(msg, object) {
        var objectToJSONObject = object ? JSON.parse(JSON.stringify(object)) : object;
        if(this.DEBUG) console.log(msg, objectToJSONObject);
    },
    
    /**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
        if(type == 'error') mode = 'sticky';
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
			type : type,
			mode : mode,
			title: title,
			message : message,
			duration : duration
		});
		toastEvent.fire();
	}

})