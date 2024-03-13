/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-05-10
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-24   younghoon.kim@dkbmc.com   Initial Version
**/
({
	helperInit : function(component, event, helper) {
		
		console.log('opptyId : ', component.get('v.opptyId'));
		console.log('opptyactId : ', component.get('v.opptyactId'));

		var action = component.get("c.getOpptActyInfo");
			
		action.setParams({
			opptyId : component.get("v.opptyId"),
			opptyactId : component.get("v.opptyactId")
		})
	
		action.setCallback(this,function(response){
			var state = response.getState();
			
			if(state === "SUCCESS"){
				var data = response.getReturnValue();
				console.log('KnoxApprovalHistory data', data);
				
				component.set("v.data", data);
				
				helper.statusPick(component, event, helper);
			}  	
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
			}			 
		});

		$A.enqueueAction(action);
	},

	statusPick : function(component, event, helper) {
		var action2 = component.get("c.getPickList");

		action2.setCallback(this,function(response){
			var state = response.getState();
			var pickMap = response.getReturnValue();
			if(state === "SUCCESS"){
				console.log('getApprovalInfo');
				
				var data = component.get('v.data');
				for(var i=0; i< data.length; i++){
					if(data[i].CreatedBy.Name != null){
						data[i].CreatedById = data[i].CreatedBy.Name;
					}
					if(data[i].Id != null){
						data[i].Id = '/lightning/r/KnoxApproval__c/' + data[i].Id + '/view';
					}
					if(pickMap[data[i].Status__c] != null){
						data[i].Status__c = pickMap[data[i].Status__c];
						// console.log(data[0].Status__c);	
						
					}
				}
				
				component.set('v.columns' ,[
					{label: $A.get("$Label.c.APPR_LAB_HISTORYNAME"), fieldName: 'Id', type:'url', typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
					{label: $A.get("$Label.c.APPR_LAB_HISTORYSTATUS"), fieldName: 'Status__c', type:'text'},
					{label: $A.get("$Label.c.CAPP_LAB_CANCELCOMMENTS"), fieldName: 'Cancel_Reason__c', type:'text'},
					{label: $A.get("$Label.c.APPR_LAB_HISTORYCREATEDBYNAME"), fieldName: 'CreatedById', type:'text'},
					{label: $A.get("$Label.c.APPR_LAB_HISTORYCREATEDDATE"), fieldName: "CreatedDate",type: "date", typeAttributes:{year: "numeric", month: "numeric", day: "numeric", hour: "numeric", minute: "numeric"}}
					// {label: $A.get("$Label.c.APPR_LAB_HISTORYCREATEDDATE"), fieldName: "CreatedDate",type: "date", typeAttributes:{year: "numeric", month: "long", day: "2-digit", hour: "2-digit", minute: "2-digit"}}
				]);
				
				component.set('v.data', data);
			}

		});
		$A.enqueueAction(action2);
	}
})