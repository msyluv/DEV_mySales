/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-05-04
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-04-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if(device != "DESKTOP"){
            component.set('v.isMobile',true);
        }

        helper.doInit(component, event);
    },

    onRender : function(component, event, helper) {
        console.log('child onRender');
        if(component.find("contentBody") != undefined && component.get("v.firstRender")){
            component.set("v.firstRender", false)
            helper.setWindowSize(component);
        }
    },

    selectDate : function(component, event, helper){
        var reportDate = event.getSource().get("v.value");
        component.set("v.reportDate", reportDate);
        helper.getContents(component);
    },

    clickReport : function(component, event, helper) {
        var recordId = event.currentTarget.id;
        console.log('click!', recordId);
        helper.callEditModal(component, recordId);
    },

    clickPreview : function(component, event, helper) {
        var records = component.get("v.selectedReports");

        if(records.length < 1){
            helper.showMyToast('warning', $A.get('$Label.c.WEEKLYREPORT_MSG_0004'));
        }else{
            helper.callPreviewModal(component);
        }
    },

    clickSendEmail : function(component, event, helper) {
        console.log('send from footer');
        var previewBody = component.get("v.previewBody");
        previewBody.clickSend();
    },

    saveFromChild : function(component, event){
        console.log('save from footer');
        var editBody = component.get("v.editBody");
        editBody.clickSave();
    },

    clickFullScreen : function(component, event, helper){
        var msg = $A.get('$Label.c.WEEKLY_ISSUE_REPORT_FULLSCREEN');
        helper.showMyToast('warning', msg);
    },

    allSelect : function(component, event, helper){
        const allCheck = component.find("allCheckReport");

        var checkReport = component.find("checkReport");

        if(!checkReport) return;

        if(allCheck.get("v.checked")){
            [].concat(checkReport).forEach(checkReport => checkReport.set("v.checked", true));

            var weeklyReports = component.get('v.weeklyReports');
            component.set('v.selectedReports', weeklyReports);
        }else{
            [].concat(checkReport).forEach(checkReport => checkReport.set("v.checked", false));
            component.set('v.selectedReports', []);
        }
    },

    columnSelect: function(component, event, helper) {
        component.set('v.selectedReports', []);

        var checkReport = component.find("checkReport");
        var selectedReports = [];
        
        for (var i=0; i<checkReport.length; i++) {
            if (checkReport[i].get("v.checked")) {
                selectedReports.push(checkReport[i].get('v.value'));
            }
        }

        component.set('v.selectedReports', selectedReports);
    }
})