/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-10-27
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2022-06-14   akash.g@samsung.com              Add simulation button functionality
 * 1.2   2022-09-24   akash.g@samsung.com              Change CCBS Link for production. 
 * 1.3   2023-06-23   chae_ho.yang@samsung.com         modify SCP Price Simulation Link
 * 1.4.  2023-07-05.  rakshit.s@samsung.com.           SCP Quotation Activity Box Delayed Disable Fix.
 * 1.5   2023-10-27   gitesh.s@samsung.com             SCP Quotation Activity color change (MYSALES-339)
**/
({
    TOAST_MSG_TIME : 10000,
    
    init : function(component, event) {
        this.setIsDisabledClick(component, event);
        this.setBoxClass(component, event);
    },
    
    setIsDisabledClick  : function(component, event) {
        // v.isDisabledClick Setting
        //V1.1 -> Add simulation button functionality 
        console.log('Name==>'+component.get('v.activityItem.MasterAct.TransactionName__c'));
        if(component.get('v.activityItem.MasterAct.TransactionName__c') != 'XP99'){
            var masterActDisabledOption = component.get('v.activityItem.MasterAct.IsDisabledAfterCompleted__c');
            
            var boActStatus = component.get('v.activityItem.BoAct.Status__c') ? component.get('v.activityItem.BoAct.Status__c') :  '';
            var hasEditAccess = component.get('v.hasEditAccess');
             
            // window.console.log('Transaction Name : ' + component.get('v.activityItem.MasterAct.TransactionName__c'));
            // window.console.log('masterActDisabledOption : ' + masterActDisabledOption);
            // window.console.log('boActStatus : ' + boActStatus);
            // window.console.log('hasEditAccess : ' + hasEditAccess);
            if(masterActDisabledOption && boActStatus == 'Completed') {
                // window.console.log('Disabled 1');
                component.set('v.isDisabledClick', true);
               
            }
            if(!hasEditAccess && !boActStatus) {
                // window.console.log('Disabled 2');
                component.set('v.isDisabledClick', true);
                
            }
        }else{
            console.log('opprecincoming-->' + JSON.stringify(component.get('v.oppValues'))); 
            /*var opportunityID = component.get('v.parentId');
            console.log('opportunityID**' + opportunityID);
            var action = component.get("c.checkOppCSPMSPValue"); 
            action.setParams({ oppId : opportunityID });
        	action.setCallback(this,function(actionResult){	
                var state = actionResult.getState();
                var isSimulationEnabled = actionResult.getReturnValue();
                console.log('isSimulationEnabled **' + isSimulationEnabled);
                if(state == "SUCCESS"){
                    if(isSimulationEnabled == 'true'){
                        component.set('v.isDisabledClick', false);
                    }else{
                        component.set('v.isDisabledClick', true);
                        var classColection= 'slds-var-p-bottom_xx-small slds-box ';
                        classColection += ' cannot-access-box';
                        component.set('v.classCollection' , classColection);
                    }
                }
			});
			$A.enqueueAction(action);*/
            //added for 1.4 by @rakshit.s@samsung.com START.
            this.isSandbox(component, event);
            var resultOp = component.get('v.oppValues');
            var hasCMBiz = resultOp.CMBizType__c;
            console.log('resultOp' + JSON.stringify(resultOp));
            console.log('hasCMBiz' + resultOp.CMBizType__c);
            if(resultOp.CMBizType__c!== undefined){
                
                var valueFromOp = resultOp.CMBizType__c;
                
                if(valueFromOp == 'CSP_SCP'){
                    component.set('v.isDisabledClick', false);
                }
                
                else{
                    component.set('v.isDisabledClick', true);
                    component.set('v.isAccessible',false);
                    var classColection= 'slds-var-p-bottom_xx-small slds-box ';
                    classColection += ' cannot-access-box';
                    component.set('v.classCollection' , classColection);
                }
                
            }
            
            else{
                console.log('nocmbizblock');
                component.set('v.isDisabledClick', true);
                component.set('v.isAccessible',false);
                var classColection= 'slds-var-p-bottom_xx-small slds-box ';
                classColection += ' cannot-access-box';
                component.set('v.classCollection' , classColection);
            }
            
            //added for 1.4 by @rakshit.s@samsung.com END.
        }
    },
    
    setBoxClass : function(component, event) {
        var classColection= 'slds-var-p-bottom_xx-small slds-box ';
        var isImportant = component.get('v.activityItem.MasterAct.IsImportant__c');
        var isRequired = component.get('v.activityItem.MasterAct.IsRequired__c');
        var boStatus = component.get('v.activityItem.BoAct.Status__c');
        var isAccessible = component.get('v.isAccessible');
        
        var isDisabledClick = component.get('v.isDisabledClick');
        //v1.5 - Gitesh Saini (MYSALES-339)
        var scpResult = component.get('v.scpSimList');
        var quotStatus = scpResult.quotStat__c;
        var resultOp = component.get('v.oppValues');
        var hasCMBiz = resultOp.CMBizType__c;
        //v1.5 - Gitesh Saini

        if(isImportant){
            classColection += 'attr_important';
        }else{
            if(isRequired){
                classColection += 'attr_required';
            }
        }
        
        //v1.5 - Gitesh Saini (MYSALES-339)
        if(component.get('v.activityItem.MasterAct.TransactionName__c') == 'XP99' && hasCMBiz == 'CSP_SCP') {
            if (quotStatus == 'QS') {
                classColection += ' stat_completed';
            } 
            else if (quotStatus == 'QC' || quotStatus == 'QD') {
                classColection += ' stat_progress';
            }
        }
        //v1.5 - Gitesh Saini
        
        switch(boStatus){
            case 'Not Started':
                classColection += ' stat_notStarted';
                break;
            case 'In Progress':
                classColection += ' stat_progress';
                break;
            case 'Completed':
                classColection += ' stat_completed';
                break;
            case 'N/A':
                classColection += ' stat_na';
                break;
                /*
 				* 2022-08-08 수주품의 액티비티 상태 표시 상세화
				*/
            case 'Rejected':
                classColection += ' stat_cancelled';
                break;
            case 'Cancelled':
                classColection += ' stat_cancelled';
                break;
        }
        
        // window.console.log('isAccessible : ' + isAccessible);
        if(!isAccessible){
            classColection += ' cannot-access-box';
        }
        
        if(isDisabledClick){
            classColection += ' disabled-box';
        }else{
            classColection += ' activity-box';
        }
        
        // window.console.log('classColection : ' + classColection);
        component.set('v.classCollection' , classColection);
    },
    
    // v 1.3
    isSandbox : function(component) {
        var action = component.get('c.isSandbox');
        var isSandbox;
        action.setCallback(this, function(response){
            var state = response.getState();   
            if(state == "SUCCESS"){
                isSandbox = response.getReturnValue();
                if (isSandbox) {
                    component.set('v.isSandbox', true);
                } else {
                    component.set('v.isSandbox', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    /**
	 * Activity 상태값 확인
	 * @param {*} component 
	 * @param {*} event 
	 */
    checkStatusActivity : function(component, event) {
        //V1.1 -> Add simulation button functionality 
        if(component.get('v.activityItem.MasterAct.TransactionName__c') != 'XP99'){
            var self = this;
            
            component.set('v.showSpinner',true);
            
            var activityItem = component.get('v.activityItem');
            
            var apexAction = 'checkStatusActivity',
                apexParams = { jsonData : JSON.stringify(activityItem) };
            
            self.apex(component, apexAction, apexParams)
            .then((result) => {		
                var resultObj = JSON.parse(result);
                console.log('[RES] resultObj', resultObj);
                
                if (resultObj.canNewActivity) {
                self.newActivityModal(component, event);
            } else {
                  self.showToast(component, 'warning', 'dismissible','', resultObj.msg); 
        }
        
        // 새 Opportunity Activity 생성 가능 여부
        /*
                    switch (resultObj.canNewActivity) {
                        case 'CAN' :				// 새 Activity 창 호출 (호출 시 Activity 생성됨)
                            self.newActivityModal(component, event);
                            break;
    
                        case 'CANNOT_PASS_CLOSED_DATE' :  // Not Closed Stage인 경우, Close Date 경과 시
                            self.showToast(component, 'warning', 'dismissible','', $A.get('$Label.c.OPPTYACT_MSG_009')); // Close Date가 경과되어 Activity를 진행할 수 없습니다.
                            break;
    
                        case 'CANNOT_REQ_PREV_ACTIVITY' :  // 선행 Activity 미완료 시
                            self.showToast(component, 'warning', 'dismissible','', $A.get('$Label.c.OPPTYACT_MSG_003')); // 선행 Activity가 완료되지 않았습니다.
                            break;
    
                        case 'CANNOT_REQ_COLLABO_ACTIVITY' : // 협업 Oppty Activity 미완료 시
                            self.showToast(component, 'warning', 'dismissible','', $A.get('$Label.c.OPPTYACT_MSG_004')); // 협업 Opportunity의 사업기회 검토가 완료되지 않아 진행이 불가능합니다.
                            break;
    
                        case 'CANNOT_LOGI_ACT_ACCESS' : //  [Opportunity Logistics Record Type] 사업기회 단계,필드에 따른 Activity 접근 여부 확인
                            self.showToast(component, 'warning', 'dismissible','', $A.get('$Label.c.OPPTYACT_MSG_005')); // 현재 기회 단계에서 해당 Activity에 접근할 수 없습니다.
                            break;	
    
                        default:
                            self.showToast(component, 'error', 'sticky','', 'Invalid status value. Please contact your administrator.'); // 잘못된 상태값입니다. 관리자에게 문의하십시오.
                            break;
                    } 
                    */
        
    })
    .catch((errors) => {
    self.errorHander(errors);
})
.finally(()=>{
    component.set('v.showSpinner',false);
});
}else{
    // v 1.3 isSandbox 추가
    var isSandbox = component.get('v.isSandbox');
    console.log('isSandbox**' + isSandbox);
    var opportunityID = component.get('v.parentId');
    console.log('opportunityID**' + opportunityID);
    var action = component.get("c.fetchOppDataForSimulation"); 
    action.setParams({ oppId : opportunityID });
action.setCallback(this,function(actionResult){	
    var state = actionResult.getState();
    var oppData = actionResult.getReturnValue();
    
    if(state == "SUCCESS" && oppData != null){
        var compCode = oppData.CompanyCode__c;
        var oppCode = oppData.OpportunityCode__c;
        var oppName = oppData.Name;
        var oppName1 = oppName.replace('&','%26');
        oppName1 = oppName1.replace('#','%23');
        console.log('oppName1@@' + oppName1);
        var ownerId = oppData.Owner.Email;
        var ownerName = ownerId.substring(0, ownerId.indexOf('@') + ''.length);
        var accountId = oppData.Account.AccountNumber;
        var token;
        if (isSandbox) token = $A.get('$Label.c.CCBS_QA_TOKEN');
        else token = $A.get('$Label.c.CCBS_PRD_TOKEN');
        
        // V 2.4 remove URL Parameter BO Name
        var link = 'CompanyCode='+compCode+'&OppCode='+oppCode+'&UserID='+ownerName+'&AccountID='+accountId+'&token='+token;
        var urlEvent = $A.get("e.force:navigateToURL");
        //V1.2.Change CCBS Link for production.
        //V1.3 Link variation
        var url;
        if (isSandbox) {
            url = 'http://70.225.20.91:7000/cloud/scp?' + encodeURI(link);
        } else {
            url = 'http://70.225.5.8:7000/cloud/scp?' + encodeURI(link);
        }
        urlEvent.setParams({
            "url": url
        });
        urlEvent.fire();
        component.set("v.dbClickProhibition", false);
    }
});
$A.enqueueAction(action);    
}
},
    
    /**
	 * 새 Activity를 생성하는 Component 호출
	 * @param {} component 
	 * @param {*} event 
	 */
        newActivityModal : function(component, event) {
            // newActivity Component Modal
            var self = this;
            var opptyId = component.get('v.parentId');
            // var refreshEvt = component.getEvent("opportunityActivityPanelRefreshEvent");
            var componentName = 'opportunityActivityNew';
            var attributeParams = {
                'parentId' : opptyId
                , 'activityItem' : component.get('v.activityItem')
                , 'isPendingKnoxApproval' : component.get('v.isPendingKnoxApproval')
            };
            var cssClass = 'slds-modal_large';
            var closeCallback = function() {
                component.set("v.dbClickProhibition", false);
                // self.callCloseCallback(component, opptyId);
                
                /** component를 생성한 Component가 Refresh 되면 Callback함수가 undefined가 되는 이슈로, refresh는 Save시 작동하도록 수정 */
                // refreshEvt.fire();
            };
            
            self.showComponentModal(component, componentName, attributeParams, cssClass, closeCallback);  
        },
            
            /**
	 * 2021-01-08 MinGyoon Woo
	 * apexParams에 opptyId가 undefined로 전달되는 것을 해결하기 위하여
	 * callback 함수를 별도 메소드로 구성함.
	 * @param {*} component 
	 * @param {*} opptyId 
	 */
        callCloseCallback : function(component, opptyId){
            var self = this,
                refreshEvt = component.getEvent("opportunityActivityPanelRefreshEvent"),
                action = component.get('c.deleteTempOpportunityActivity'),
                apexParams = {
                    'opptyId' : opptyId
                };
            
            if(action) {
                action.setParams( apexParams );
                self.directApex(action)
                .then((result) => {
                    console.log('callCloseCallback: deleteTempOpportunityActivity');
                })
                    .catch((errors) => {
                    self.errorHander(errors);
                });
                }
                    
                    refreshEvt.fire();
                },
                    
                    errorHander : function(errors){
                        var self = this;
                        if(Array.isArray(errors)){
                            errors.forEach(function(err){
                                self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , err.message);
                            });
                        } else {
                            console.log(errors);
                            console.log(errors.toString());
                            self.showToast(null, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') , 'Unknown error in javascript controller/helper.');
                        }
                    },
                    
                    apex : function(component, apexAction, params){
                        return new Promise( $A.getCallback( function( resolve, reject ) {
                            var action = component.get("c."+apexAction+"");
                            action.setParams( params );
                            
                            console.log('@ apex.action ', apexAction);
                            console.log('@ apex.params ', params);
                            
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
                    
                    directApex : function(action){
                        console.log('{ opportunityActivityBoxHelper.directApex }');
                        return new Promise( $A.getCallback( function( resolve, reject ) {
                            // var action = component.get("c."+apexAction+"");
                            // action.setParams( params );
                            
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
                    
                    /**
	 * 
	 * @param {*} component 
	 * @param {*} componentName 
	 * @param {*} attributeParams 
	 * @param {*} cssClass 
	 * @param {*} closeCallback 
	 */
                    showComponentModal : function(component, componentName, attributeParams, cssClass, closeCallback) {        
                        $A.createComponent('c:' + componentName
                                           , attributeParams
                                           , function(content, status, errorMessage) {
                                               if (status === "SUCCESS") {
                                                   component.find('overlayLib').showCustomModal({
                                                       body: content,
                                                       showCloseButton: false,
                                                       cssClass: cssClass,
                                                       closeCallback: closeCallback
                                                   })
                                               } else if (status === "ERROR") {
                                                   console.log("Error: " + errorMessage);
                                               }
                                           });
                        component.set('v.showSpinner',false);
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
                        switch (type.toLowerCase()) {
                            case 'error':
                                mode = 'sticky';
                                break;
                            case 'warning':
                                mode = 'sticky';
                                break;
                            case 'success':
                                mode = 'dismissible';
                                duration = 5000;
                                break;
                        }
                        
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