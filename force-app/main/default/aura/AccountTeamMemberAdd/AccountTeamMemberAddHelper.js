/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2021-02-03
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-12-01   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
**/
({
    helperInit : function(component, event, helper) {
        var close =  $A.get("e.force:closeQuickAction");
        var rcdId = component.get('v.recordId');
        var dvModule = $A.get( "$Browser.formFactor");
        var self = this;

        self.apex(component, 'defaultSetting', {
            recordId : rcdId
        }).then(function(result){
            // 모바일 체크 여부
            if( dvModule === "PHONE" || dvModule === "IPHONE"){
                component.set( "v.isMobile", "M");
                $A.get("e.force:closeQuickAction").fire();
                self.showMyToast('error', 'This feature does not support the mobile environment.');
            }else{
                component.set( "v.isMobile", "W");
                var permission = result.Permission;
                if(permission == 'false'){
                    self.showMyToast('error', $A.get( "$Label.c.ACCTEAM_MSG_0001")); // Do not have the permission
                    close.fire();
                }else{
                    var pickListValue = component.get('v.pickListValue');
                    pickListValue.TeamRole = JSON.parse(result.PickVal).TeamRole;
                    pickListValue.AccountAccess = JSON.parse(result.PickVal).AccountAccess;
                    component.set('v.pickListValue', pickListValue);

                    if(result.OldMember!=undefined){
                        var oldInfoList = JSON.parse(result.OldMember);
                        component.set('v.teamMemberInfoList',oldInfoList);
                    }
                }
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
        self.addAccTeamRecord(component, event);
    },

    addAccTeamRecord : function(component,event) {
        var teamMemberInfoList = component.get('v.teamMemberInfoList');
        teamMemberInfoList.push({
            'User': {},
            'Role': '',
            'AccountAccess': ''
        });
        component.set("v.teamMemberInfoList", teamMemberInfoList);
    },
  
    teamMemberSave : function(component, event) {
        var close =  $A.get("e.force:closeQuickAction");
        var self = this;

        var tmInfoList = component.get("v.teamMemberInfoList");
        var check = self.checkRequired(tmInfoList);

        if(check.isValid){
            self.apex(component, 'saveTeamMember', {
                recordId : component.get('v.recordId'),
                jsonTeamMemberInfo : JSON.stringify(tmInfoList)
            }).then(function(result){
                if(result.STATUS == 'SUCCESS'){
                    self.showMyToast('success', $A.get( "$Label.c.ACCTEAM_MSG_0002")); // Team member save success.
                    if(component.get('v.recordId') == result.REDIRECT){
                        close.fire();
                    }else{
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result.REDIRECT,
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }
                }
            }).catch(function(errors){
                self.errorHandler(errors);
            }).finally(function(){
                component.set('v.showSpinner', false);
            });
        }else{
            self.showMyToast('error', check.errorMSG);
        }
    },

    checkRequired : function(tmInfoList) {
        var result = {
            isValid : true,
            errorMSG : ''
        }
        if(tmInfoList.length > 0){
            for(var i = 0; i <= tmInfoList.length; i++){
                if(tmInfoList[i].User.Id == null || tmInfoList[i].Role == '' || tmInfoList[i].AccountAccess == ''){
                    result.isValid = false;
                    result.errorMSG = $A.get( "$Label.c.ACCTEAM_MSG_0003"); // Please enter a value
                    break;
                }else{
                    break;
                }
            }
        }
        return result;
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

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
	},

    showMyToast : function(type, msg) {
        var mode = 'sticky';
        if(type.toLowerCase() == 'success') mode = 'dismissible';

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 5000,
            mode: mode,
            message: msg
        });
        toastEvent.fire();
	}
})