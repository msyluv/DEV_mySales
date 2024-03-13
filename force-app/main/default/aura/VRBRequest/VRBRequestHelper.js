/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-22
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-24   wonjune.oh@partner.samsung.com   Initial Version
 * 1.1   2021-01-28   Junghwa.Kim@dkbmc.com            sendEmail 추가
**/
({
    doInit : function(component, event) {

        var self = this;
        
        var action = component.get("c.initComponent");

        action.setParams({
            'parentActivityId': component.get('v.parentActivityId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {     //success
                
                var result = response.getReturnValue(); 
                for (var i = 0; i < result.length; i++) {
                    var row = result[i];
                    if (row.Owner) row.Owner = row.Owner.Name;
                    if (row.VRBRequester__c) row.VRBRequester__c = row.VRBRequester__r.Name;
                }

                component.set('v.data',result);
                this.tableset(component, event, helper);

            }//INCOMPLETE
            else if (state == "INCOMPLETE") {
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == "ERROR") {
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    getTeamMember : function(component, event){
        console.log('getTeamMember');
        var action = component.get("c.getTeamMemberList");
        console.log('test1');
        action.setParams({
            'oppId' : component.get('v.parentId')
        });
        console.log('test2');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == 'SUCCESS') {     //success
                var result = response.getReturnValue(); 
                console.log(result);
                var option = [];
                for(var i=0; i<result.length; i++){
                    // User.Division, User.Department, User.EmployeeNumber
                    console.log(result[i]);
                    var label = result[i].User.Name;
                    if(result[i].User.Department != undefined || result[i].User.EmployeeNumber != undefined){
                        label += ' (';
                        label += result[i].User.Department == undefined ? '' : result[i].User.Department;
                        if(result[i].User.Department != undefined && result[i].User.EmployeeNumber != undefined) label += ', ';
                        label += result[i].User.EmployeeNumber == undefined ? '' : result[i].User.EmployeeNumber;
                        label += ')';
                    }
                    var item = {
                        "label": label,
                        "value": result[i].UserId
                    }
                    option.push(item);
                }
                //component.set('v.teamMember', result);
                component.set('v.options', option);
            }//INCOMPLETE
            else if (state == 'INCOMPLETE') {    
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == 'ERROR') { 
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    tableset : function(component, event, helper) {
    
        var data = component.get('v.data');

		 for(var i=0; i< data.length; i++){
            
			if(data[i].Id != null){
				data[i].Id = '/lightning/r/VRBRequest__c/' + data[i].Id + '/view';
            }

            if(data[i].Biz_Review__c != null){
                data[i].Biz_Review__c = '/lightning/r/Biz_Review__c/' + data[i].Biz_Review__c + '/view';
                data[i].Biz_Review_Name = data[i].Biz_Review__r.Name;
            }
		}

        component.set('v.columns', [
            //{label: $A.get("$Label.c.OPPTYACT_LAB_STRATEGY_COMMITTEE_REQUEST"),fieldName: 'Id', type: 'url' , typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' }},
            {label: $A.get("$Label.c.OPPTYACT_LAB_STRATEGY_COMMITTEE_REQUEST"),fieldName: 'Name', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_STRATEGY_COMMITTEE"),fieldName: 'Biz_Review__c', type: 'url' , typeAttributes: { label: { fieldName: 'Biz_Review_Name' }, target: '_blank' }},
            // {label: $A.get("$Label.c.OPPTYACT_LAB_STRATEGY_COMMITTEE"),fieldName: 'Biz_Review_Name', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_BUSINESS_LEVEL"), fieldName: 'Business_Level__c', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_METHOD"), fieldName: 'VRBMethod__c' , type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_DUE_DATE"), fieldName: 'VRBDueDate__c', type: 'date'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_OWNER"), fieldName: 'Owner', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_REQUEST"), fieldName: 'VRBRequester__c', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_DESCRIPTION"), fieldName: 'Description__c', type: 'text'},
            {label: $A.get("$Label.c.OPPTYACT_LAB_CREATED_DATE"), fieldName: 'CreatedDate', type: 'date',
            typeAttributes:{
                year: "numeric",
                month: "2-digit",
                day: "2-digit",
                hour: "2-digit",
                minute: "2-digit",
                hour12: true
            }}
        ]);
    },

    getLabel : function(component,event){
        var action = component.get("c.getLabel");

        action.setParams({
            'apiName': 'VRBRequest__c'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {     //success
                
                var result = response.getReturnValue(); 

                component.set('v.fieldLabel',  result);
                component.set('v.objectLabel', result.ObjectLabel);
            }//INCOMPLETE
            else if (state == "INCOMPLETE") {    
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == "ERROR") { 
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    // 2021-01-28 sendEmail 추가
    sendEmail : function(component,event, helper){
        var action = component.get("c.sendKnoxEmail");

        action.setParams({
            'recordId': component.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {     //success
                console.log('knox Email send success');
            }//INCOMPLETE
            else if (state == "INCOMPLETE") {    
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == "ERROR") { 
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    /**
	 * 
	 * @param {*} component 
	 * @param {*} event 
	 */
	submit : function(component, event) {
        var userId = $A.get( "$SObjectType.CurrentUser.Id" );
        var fields = event.getParam('fields');        

        // [Date Type] input 가져오기
		var dateFields = component.find('dateFields'); // aura-id가 하나인경우 object , 아니면 array 로 반환됨
		console.log('!Array.isArray(dateFields) ', !Array.isArray(dateFields));
		if(!Array.isArray(dateFields)) { 
			dateFields = new Array(dateFields);   // object to array 
		}
		for(var i in dateFields){
			var dateName = dateFields[i].get('v.name');
			var dateValue = dateFields[i].get('v.value');
			var dateDisabled = dateFields[i].get('v.disabled');
			if(dateDisabled == false) {
				fields[dateName] = dateValue;
			}
		}
        
        fields.Business_Level__c = component.get('v.opportunityBizLevel');
        fields.VRBRequester__c = userId;
        fields.VRBOwner__c = component.get('v.selectOwner');
        //fields.OwnerId = fields.VRBOwner__c;
        fields.Opportunity__c =component.get('v.parentId');
        fields.Opportunity_Activity__c = component.get('v.parentActivityId');
       
        component.find('recordEditForm').submit(fields);
      
		component.set('v.showSpinner', true);
    },
    
    changeOwner : function(component, event, recordId) {
    
        var action = component.get("c.changeVRBOwner");
        action.setParams({
            'vrbRequestId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {     //success
				console.log('changeOwner Success! ');
                
            }//INCOMPLETE
            else if (state == "INCOMPLETE") {
                this.showToast(component, 'ERROR', 'dismissible','', $A.get('$Label.c.COMM_LAB_RESPONSE'));
            }//ERROR
            else if (state == "ERROR") {
                this.showToast(component, 'ERROR', 'dismissible', $A.get('$Label.c.COMM_LAB_ERROR') ,response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },

    close : function(component, event) {
		component.find('overlayLib').notifyClose();
    }, 
    log : function(msg, object) {
        var objectToJSONObject = object ? JSON.parse(JSON.stringify(object)) : object;
        if(this.DEBUG) console.log(msg, objectToJSONObject);
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
		var toastEvent = $A.get('e.force:showToast');
		toastEvent.setParams({
			type : type,
			mode : mode,
			title: title,
			message : message,
			duration : duration
		});
		toastEvent.fire();
    },
})