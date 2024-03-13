/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-09-27
 * @last modified by  : younghoon.kim@dkbmc.com
**/
({
    init : function(component, event, helper){
        helper.convertCheck(component, event);
    },
          
    convertBtn : function(component, event, helper){
        if(component.get('v.selectedOwner') == undefined){
            helper.showMyToast('Warning', $A.get("$Label.c.CONVERT_LAB_MSG07"));
            return;
        }
        var LeadList = component.get('v.LeadList');
        var SLList = [];
        for(var i=0; i<LeadList.length; i++){
            SLList.push({
                'Api' : LeadList[i].SLApi,
                'Value' : LeadList[i].SLValue
            })
        }
        SLList.push({
            'Api' : 'RecordTypeId',
            'Value' : component.get('v.recordType')
        })
        helper.convert(component, event, SLList);
    },
    
    convertCacenlBtn : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    recordSelectedEventHandler : function(component, event, helper){
        var recordFromEvent = event.getParam("recordByEvent");
        component.set('v.selectedOwner', recordFromEvent.Id);
        helper.getRecordType(component, event, recordFromEvent.ProfileId);
    }
})