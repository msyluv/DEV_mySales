/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-04-25
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1	 2022-05-03   hyunhak.roh@dkbmc.com            Drop/Lost 완결된 이후(=현재 완결 상태) Drop/Lost Activity에서 값 													   변경 후 '저장(Save)' 버튼 실행 시 전송
 * 1.2   2022-05-24   akash.g@samsung.com              Add functionality of User Manual Button in Service/Solution tab.
 * 1.3   2022-10-17   divyam.gupta@samsung.com         Add new tab Analysis of Reason for Drop Lost and Postmortem Result..
 * 1.4   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 1.5   2024-02-19   anish.jain@partner.samsung.com   BO Review Approval Issue Check (MS-418)
 * 1.6   2024-04-25   anish.jain@partner.samsung.com   Analysis the cause of 'Review Opportunity' issue -> [MYSALES-495]

**/
({
    init : function(component, event, helper) {
            /*Anish-v 1.4 language check*/
        var locale = $A.get("$Locale.language");
            console.log('the user lang:'+locale);
            if(locale == 'ko'){
                component.set("v.setLangEng",false);
                component.set("v.setLangKor",true);
            }
            else{
                component.set("v.setLangEng",true);
                component.set("v.setLangKor",false);
            }
        /*Anish-v 1.4 End*/
        /* Device Check */
        var device = $A.get('$Browser.formFactor');
        if(device != 'DESKTOP'){
            component.set('v.isMobile', true);
        }
        helper.init(component, event);
        var TransactionActCode = component.get('v.activityItem.MasterAct.TransactionName__c');
        if(TransactionActCode == '2.3.1' || TransactionActCode == '2.4.4'){
            component.set('v.LogisticsStatusDisable', true);
        }
    },
 
    /**--START V Anish-v 1.4 ->  Knox Preview Tabs Visible On Certian Conditions. (handling of component event in order to refresh view)**/
    tempTest: function(cmp, event, helper){
       
        console.log('handled');
         var showKnox = event.getParam("isConfirmed");
        var isBORevivw = event.getParam("isBoReviewValue");
        var resultObj = cmp.get('v.resultObj');
        var updatedVrb = event.getParam("updatedVrb");  //Added by Anish-v 1.5
        var knoxApproved = event.getParam("knoxApproved");  //Added by Anish-v 1.5
        var knxStatus = event.getParam("knxStatus");  //Added by Anish-v 1.5
        console.log('showTabs temp Pending-->' + resultObj);
        var temp = event.getParam("updatedOppData");
        cmp.set('v.resultBOReviewOppObj' , temp);
        console.log('showTabs-->' + isBORevivw);
        console.log('showTabs temp updatedVrb-->' + updatedVrb);
        console.log('showTabs temp knoxApproved-->' + knoxApproved);
        console.log('showTabs temp knxStatus-->' + knxStatus);
        
        if(isBORevivw){
            
            console.log('inside bo review value');
            cmp.set('v.isBoReviewTab' , true);
            cmp.set('v.MasterAct_IsRequiredKnoxApproval',true);
            //Added by Anish-v 1.5
            if(updatedVrb == true){
                console.log('updatedVrb12-->');
              cmp.set('v.isPendingKnoxApproval' , false);  
            }
            if(updatedVrb == false){
                console.log('updatedVrb34-->');
                if(knoxApproved == true){
                    if(knxStatus == '3' || knxStatus == '4'){
                        console.log('updatedVrb345-->');
              cmp.set('v.isPendingKnoxApproval' , false);  
                    }
                    else{
                        console.log('updatedVrb3456-->');
              cmp.set('v.isPendingKnoxApproval' , true);           
                    }
                }
                if(knoxApproved == false){
              cmp.set('v.isPendingKnoxApproval' , false); 
                }
            }
            if(showKnox){  
                cmp.set('v.isConfirmed' , true);
            }
        } 
        
        else{
            
            
            console.log('inside hiding tabs');
            cmp.set('v.isBoReviewTab' , false);
            cmp.set('v.MasterAct_IsRequiredKnoxApproval',false);
        }
        
       /* cmp.set('v.isBoReviewTab' , true);
        cmp.set('v.MasterAct_IsRequiredKnoxApproval',true);*/
        
         // helper.init(cmp,event);

    },    
    
        //v 1.6
    tabTest: function(cmp, event, helper){
       
        console.log('handled tabTest');
         var showKnox = event.getParam("isImplementation");
        console.log('handled tabTest showKnox',showKnox);
            if(showKnox){
         cmp.set('v.MasterAct_IsRequiredKnoxApproval',false);
            }
    }, 
     
    ShowKnoxTabs: function(cmp, event, helper) {
        console.log('from component event refreshed');
        console.log('oppData' + cmp.get('v.resultObj'));
        var showKnox = event.getParam("isConfirmed");
        var isBORevivw = event.getParam("isBoReviewValue");
        var resultObj = cmp.get('v.resultObj');
        var temp = event.getParam("updatedOppData");
        cmp.set('v.resultBOReviewOppObj' , temp);
        console.log('showTabs-->' + isBORevivw);
      
        if(isBORevivw){
            
            console.log('inside bo review value');
            cmp.set('v.isBoReviewTab' , true);
            cmp.set('v.MasterAct_IsRequiredKnoxApproval',true);
            
            if(showKnox){
                cmp.set('v.isConfirmed' , true);
            }
        } 
        
        else{
            
            
            console.log('inside hiding tabs');
            cmp.set('v.isBoReviewTab' , false);
            cmp.set('v.MasterAct_IsRequiredKnoxApproval',false);
        }
        
       /* cmp.set('v.isBoReviewTab' , true);
        cmp.set('v.MasterAct_IsRequiredKnoxApproval',true);*/
        
         // helper.init(cmp,event);
        
    },
    /**--END V Anish-v 1.4 ->  Knox Preview Tabs Visible On Certian Conditions. (handling of component event in order to refresh view)**/
    
    handleLoad : function(component, event, helper) { 
        helper.setSelectedStatus(component, event, '');
    },
    
    handleSubmit : function(component, event, helper) {
        event.preventDefault();       // stop the form from submitting
         /**--START V 1.3 Change by Divyam gupta--**/
        helper.handlelostdropPopup(component,event);
         if(component.get('v.MasterAct_TransactionName') == 'ZPZ2' || component.get('v.MasterAct_TransactionName') =='ZPZ1'){
        if(component.get('v.handleYeslostDropTypeVal') == false ) {
        helper.submit(component,event);
        }
         }
        /**--END V 1.3 --**/
        else {
                 helper.submit(component,event);

        }
         
    },
    //  /**--START V 1.3 Change by Divyam gupta--**/
     closeModal : function(component, event, helper){
            component.set("v.handlelostDropTypeVal",false);


},
    handleYes :  function(component, event, helper){
           component.set("v.handlelostDropTypeVal",false);

               event.preventDefault();  
               helper.delteLostDropRecord(component,event);
               helper.submit(component,event);

    },
        /**--END V 1.3 --**/
    
    handleSuccess : function(component, event, helper) {

        component.set('v.showSpinner', false);

        var record = event.getParam("response");
        helper.log('[#] SUCCESS record', record);
        
        component.set('v.recordId', record.id);
        var Stagevalue = component.get('v.Activity_LostType');
        window.console.log('the value of stage', Stagevalue);
        var checkcompcode = component.get('v.oppCompanyCode');
        if(Stagevalue == 'Z06' || Stagevalue == 'Z07'){
            helper.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS') , $A.get('$Label.c.Dtrop_Lost_Activity_Success_Msg') ); // 성공적으로 저장되었습니다.
            
        }
        else {
            helper.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS') , $A.get('$Label.c.COMM_MSG_0002') ); // 성공적으로 저장되었습니다.
        }
        //2022-05-03, hyunhak.roh@dkbmc.com, Drop/Lost 완결된 이후(=현재 완결 상태) Drop/Lost Activity에서 값
        //									 변경 후 '저장(Save)' 버튼 실행 시 전송
        helper.setIF155CallByOpptyActId(component, event);
        
        helper.getOpportunityActivity(component, event);
        helper.refresh(component, event);
    },
    
    handleError : function(component, event, helper) {
        component.set('v.showSpinner', false);
        
        var evtParams = event.getParams();
        helper.log('[handleError] evtParams', evtParams);
        
        var errorMessage = event.getParam("message");
        var errorMessageArr = [];
        
        var recordErrors = evtParams.output.errors;
        var fieldErrors = evtParams.output.fieldErrors;
        
        // helper.showToast(component, 'warning', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), errorMessage); 
        
        // Record Error
        if(recordErrors) {
            for(var i in recordErrors) {
                var errMsg = recordErrors[i].message;
                errorMessageArr.push(errMsg); 
            }
        }
        
        // Field Error 
        if(fieldErrors) {
            for(var fieldName in fieldErrors) {
                //2022-04-28, hyunhak.roh@dkbmc.com, [설명] 필드 200자 이상 등록하도록 제어하는 기능
                //Error 메세지 Toast 형식은 제외 처리
                //if(fieldName != 'Description__c') {
                var fieldErrorList = fieldErrors[fieldName];
                for(var i in fieldErrorList){
                    var errMsg = fieldErrorList[i].fieldLabel + ' : ' + fieldErrorList[i].message;
                    errorMessageArr.push(errMsg);                
                }
                //}
            }
        }
        
        if(errorMessageArr.length > 0){
            var errorMessageString = errorMessageArr.join(', ');
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), errorMessageString); 
        }
        
    },
    
    handleChangeStatus : function(component, event, helper) { 
        helper.setSelectedStatus(component, event, event.getParam('value'));
    },
    
    handleChangeLostPicklist : function(component, event, helper) {        
        var auraId = event.getSource().getLocalId();
        switch (auraId) {
            case 'LostType':
                helper.setLostType(component, event, event.getParam('value'));
                break;
                
            case 'LostReason':
                helper.setLostReason(component, event, event.getParam('value'));
                break;
        }
        
    },
    
    handleOpenLink : function(component, event, helper) {
        helper.handleOpenLink(component, event);
    },
    
    updateOpportunityActivity : function(component, event, helper) {
        helper.updateOpportunityActivity(component, event);
    },
    
    onSelectTabSet : function(component, event, helper){
        helper.onSelectTabSet(component, event);
    },
    
    cancel : function(component, event, helper) {
        helper.close(component, event);
    },
    
    refresh : function(component, event, helper) {
        helper.refresh(component, event);
    },
    
    selectApprovalTab : function(component, event, helper) {
        component.set('v.isSelectedApprovalTab', true);
    },    
    changeDesc : function(component, event, helper) {
        component.set('v.showDescErrMsg', false);
    },    
    openUserManualFile : function (cmp,event){
        var action = cmp.get("c.openfile"); 
        action.setCallback(this,function(actionResult) {
            var state = actionResult.getState();
            var id = actionResult.getReturnValue();
            if (id != null && id != '' && id != undefined && state == "SUCCESS"){
                var navService = cmp.find("navService");
                var pageReference = {
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: id,
                        actionName: 'view'
                    }
                };
                event.preventDefault();
                const handleUrl = (url) => {
                    window.open(url);
                    console.log(component.get("v.recordId"))
                };
                    const handleError = (error) => {
                    console.log(error);
                };
                    navService.generateUrl(pageReference).then(handleUrl, handleError);
                }
                });
                    $A.enqueueAction(action);
                },
                    
                })