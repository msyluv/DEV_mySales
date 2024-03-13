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
    doInit : function(component, event, helper) {
        var pickListValue = {
            'TeamRole' : [],
            'AccountAccess' : []
        }
        component.set('v.pickListValue', pickListValue);

        helper.helperInit(component, event);
    },

    addRow : function(component, event, helper) {
        helper.addAccTeamRecord(component, event);
    },

    removeRow: function(component, event, helper) {
        var target = event.target;
        var rowIndex = target.getAttribute("data-idx");

        var infoList = component.get("v.teamMemberInfoList");
        
        // setTimeout(() => {
            infoList.splice(rowIndex, 1);
            component.set("v.teamMemberInfoList", infoList);
        // }, 10); 
    },

    onchangeAction : function(component, event, helper){
    },

    cancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    saveTM : function(component, event, helper){
        component.set('v.showSpinner', true);
        helper.teamMemberSave(component, event);
    },
})