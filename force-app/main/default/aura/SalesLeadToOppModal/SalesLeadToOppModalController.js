/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-09-30
 * @last modified by  : younghoon.kim@dkbmc.com
**/
({
    init : function(component, event, helper) {
        helper.convertCheck(component, event);
    },

    convertCacenlBtn : function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    recordSelectedEventHandler : function(component, event, helper) {
        var recordFromEvent = event.getParam("recordByEvent");
        component.set('v.selectedOwner', recordFromEvent.Id);
        helper.getRecordType(component, event, helper, recordFromEvent.ProfileId, recordFromEvent.Id);
    },

    selectRT : function(component, event, helper){
        component.set('v.SelectRT', component.find('recordType').get('v.value'));
    },

    convertBtn : function(component, event, helper){
        var SalesLeadList = component.get('v.SalesLeadList');
        var OppList = [];
        for(var i=0; i<SalesLeadList.length; i++){
            var api = SalesLeadList[i].oppApi;
            var val = SalesLeadList[i].oppValue
            OppList.push({
                'Api' : api,
                'Value' : val
            })
        }
        OppList.push({
            'Api' : 'RecordTypeId',
            'Value' : component.get('v.SelectRT')
        })
        helper.convert(component, event, OppList);
    }
})