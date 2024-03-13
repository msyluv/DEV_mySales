/**
 * @description       : JS helper of showLogisticOpptyCount Aura cmp 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-01
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-06-06   d.ashish@samsung.com   Initial Version
 * 1.1   2023-09-01   anish.jain@partner.samsung.com   Task - (Logistics) BO Matrix Enhancement - MS 286
**/
({
	getBOCount : function(component, event, helper){
		var action = component.get('c.getCount');
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            component.set('v.list',response.getReturnValue());
            console.log('RHQvarList'+'v.list');
        });
        $A.enqueueAction(action);
	},
    getUserCountries : function(component, event, helper){
		var action = component.get('c.getUserDetail');
        action.setCallback(this, function(response) {
            console.log(response.getReturnValue());
            console.log(response.getReturnValue().User_RHQ__c);
            var RHQvar =  response.getReturnValue().User_RHQ__c;
            console.log('RHQvar'+RHQvar);
            if(RHQvar != null && RHQvar != '' && RHQvar !='undefined'){
            if(RHQvar.includes('CHINA')) component.set('v.isChina',true);
            if(RHQvar.includes('KOREA')) component.set('v.isKorea',true);
            if(RHQvar.includes('EUROPE/CIS')) component.set('v.isEurope',true);
            if(RHQvar.includes('LATIN AMERICA')) component.set('v.isLA',true);
            if(RHQvar.includes('MEIA')) component.set('v.isMeia',true);
            if(RHQvar.includes('NORTH AMERICA')) component.set('v.isNA',true);
            if(RHQvar.includes('PACIFIC')) component.set('v.isPacific',true);
                console.log('my Log 1',component.get('v.allRHQ'));
                //Added by Anish - V 1.1
                if(component.get('v.isChina') && component.get('v.isKorea') && component.get('v.isEurope') && component.get('v.isLA') && component.get('v.isMeia') && component.get('v.isNA') && component.get('v.isPacific')){
                   component.set('v.allRHQ',true); 
                }
            console.log('my Log',component.get('v.allRHQ'));
            console.log(component.get('v.isChina'));
            console.log(component.get('v.isKorea'));
            console.log(component.get('v.isEurope'));
            console.log(component.get('v.isLA'));
            console.log(component.get('v.isMeia'));
            console.log(component.get('v.isNA'));
            console.log(component.get('v.isPacific'));
            }
        });
        $A.enqueueAction(action);
	}
    
})