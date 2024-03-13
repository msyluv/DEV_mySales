/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   06-21-2021   ukhyeon.lee@samsung.com   Initial Version
 * 1.1   11-05-2023   anish.jain@partner.samsung.com  MySales - 216
**/

({
	init : function(component, event, helper) {
		console.log('OpportunityReviewMainController init Start');

        helper.helperinit(component, event);
	},
  
	cancel : function(component, event, helper){
        if (!helper.canClose(component, event)){
            return;
        }
		component.find("overlayLib").notifyClose();
    },
    
    //Added by Anish- v 1.1
    download : function(component, event, helper) {
		var cdId = component.get('v.contentDocumentId');
		window.console.log('cdId : ', cdId);
		if(cdId != '') helper.downloadFile(component, event, cdId);
		else 		   helper.showToast('error', 'There are no attachments.');
	},
    
    onRefresh: function(Component, event, helper){
        helper.helperinit(Component, event);
    },
    
    /*체크박스*/
    onCheck: function(component, event, helper) {
        helper.handleCheck(component, event);
        
    },

    //사업심의유형 변경 시
    checkReviewExc: function(component, event, helper) {
        if(component.get('v.isAdmin')){                                                                 //1. 어드민
            if(!component.get('v.opptyData_origin.Opportunity_Review_Exception__c')){                   //2. 사업심의유형이 예외가 아니었던 경우               
                var before  = component.get('v.opptyData.Opportunity_Review_VRB_Type_Confirm__c');      
                var after = event.getSource().get("v.value");
                 if(!$A.util.isUndefinedOrNull(before)){                                                  //3. 사업심의유형 확정값이 존재
                    if(before!==after){                                                                 //4.1 확정값 != 셀렉트 박스값
                        component.set('v.opptyData.Opportunity_Review_Exception__c', true);             //5. 사업심의유형 예외처리
                        component.set("v.isExcDisabled", false);             
                    } else{                                                                             //4.2 확정값 == 셀렉트 박스값
                        component.set('v.opptyData.Opportunity_Review_Exception__c', false);            //5. 사업심의유형 예외처리 X
                        component.set("v.isExcDisabled", true);
                    }      
                }            
            }
        }
    },
    

    //저장
    save : function(component, event, helper) {
        console.log('OpportunityReviewMainController save');
        helper.saveData(component, event);
    },

    //사업심의유형 조회
    retrieveCheckType : function(component, event, helper) {
       console.log('OpportunityReviewMainController retrieveBusinessCheckType');        
       helper.retrieveBusinessCheckType(component);
    },

     //사업심의유형 확정
     confirm : function(component, event, helper) {
        console.log('OpportunityReviewMainController confirm');
        helper.confirmData(component, event);
    }
})