/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-02-80
 * @last modified by  : atul.k1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-05   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2023-06-11   atul.k1@samsung.com              Task - (IT) Archtect Search button addition for HQ BO (MYSALES-349)
 * 1.2   2023-11-15   atul.k1@samsung.com              Add Link Button on Opportunity main (MYSALES-358)
 * 1.3   2024-02-08   atul.k1@samsung.com              Task - (IT) Add TXP link Button in BO Activity (MYSALES-421)
**/
({
    doInit : function(component, event, helper) {
        console.log('AcitivityPanel doInit!');
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event, true);
    },

    clickMaximize : function(component, event, helper){
        var maximize = component.get("v.maximize");
        component.set("v.maximize", maximize ? false : true);
    },

    refresh : function(component, event, helper){
        helper.refresh(component, event);
    },

    refreshWithoutDelete : function(component, event, helper){
        helper.refreshWithoutDelete(component, event);
    },

    popUpNoticeSendToSap : function(component, event, helper){
        var componentName = 'OpportunityNoticePopup';
		var attributeParams = {};
		var cssClass = 'slds-modal_medium';
		var closeCallback = function() {};
		
		helper.showComponentModal(component, componentName, attributeParams, $A.get("$Label.c.OPPTY_BTN_NOTICE"), cssClass, closeCallback);  
    },

    popUpGuide : function(component, event, helper){
        var componentName = 'OpportunityGuidePopup';
		var attributeParams = {};
		var cssClass = 'slds-modal_medium';
		var closeCallback = function() {};
		helper.showComponentModal(component, componentName, attributeParams, $A.get("$Label.c.OPPTY_BTN_GUIDE"), cssClass, closeCallback);  
    },

    handleOpenLink  : function(component, event) {
        console.warn('{ handleOpenLink }');
		var urlValue = event.getSource().get('v.value');
        var buttonId = event.getSource().getLocalId();
        
		var oppty = component.get('v.oppty');
        var opptyCode = oppty.OpportunityCode__c ? oppty.OpportunityCode__c : '';
        var companyCode = oppty.CompanyCode__c ? oppty.CompanyCode__c : '';
        var accountNumber = oppty.Account.AccountNumber ? oppty.Account.AccountNumber : '';
        console.log('# opptyCode', opptyCode);
        console.log('# companyCode', companyCode);
        console.log('# accountNumber', accountNumber);
		
        switch (buttonId) {
            case 'BR_CREATE': 
                urlValue = urlValue.replace("{!BO_Code}", opptyCode).replace("{!Company_Code}", companyCode);
				break;

			case 'WEEKLY_REPORT' :
                urlValue = urlValue.replace("{!BO_Code}", opptyCode);
				break;

            case 'C360' :  
                // ex) http://182.195.85.87/#/views/C360-test2/Customer360?P_CODE=A0130059&P_L4=A0130059&P_LV=LV4
                urlValue += '?';
                urlValue += 'P_CODE=' + accountNumber;
                urlValue += '&' + 'P_L4=' + accountNumber;
                urlValue += '&P_LV=LV4';
                break;
            // V 1.2 MYSALES-358 Start
            case 'STRATEGY_COMMITTEE' :
                urlValue = urlValue.replace('{0}',opptyCode);
				urlValue = urlValue.replace('{1}',companyCode);
				break;
                
            case 'CONTRACT_PL':	// 수주 원가 확정
				// urlValue = 'http://ieqh1201.sds.samsung.net:50000/irj/servlet/prt/portal/prtroot/controller.IViewController?type=GUI&param=System=SDS_ECC,TCode=ZLP3SDC2100C,AutoStart=TRUE,ApplicationParameter=';
				urlValue += 'P_BO=' + (opptyCode) + ';'
				urlValue += 'P_PSPID=;'
				urlValue += 'P_BUKRS=' + (companyCode) + ';'
				urlValue += 'P_STEP=S'
				break;
            // V 1.2 MYSALES-358 End
            // V 1.3 MYSALES-421 Start
            case 'BTN_TXP':
                var boCodeVal = opptyCode.split('-');
                urlValue = urlValue.replace("{!BO_NO}",boCodeVal[1].slice(0,-1));
				break;
            // V 1.3 MYSALES-421 End
        }
        
		console.log('## URL : ', urlValue);
        window.open(urlValue, '_blank');
	},
    // added by atul.k1@samsung.com- V 1.1 (MYSALES-349)
    handleOpenLinkArchitect : function(component, event) {
        var oppty = component.get('v.oppty');
        var opptyCode = oppty.OpportunityCode__c ? oppty.OpportunityCode__c : '';
        console.log('# opptyCode', opptyCode);
        var urlValue = event.getSource().get('v.value');
        urlValue = urlValue.replace("{!BO_Code}", opptyCode);
        console.log('# URL : ', urlValue);
        window.open(urlValue, '_blank');
     }
    // added by atul.k1@samsung.com- V 1.1 (MYSALES-349)
})