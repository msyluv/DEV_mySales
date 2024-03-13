/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-11-18
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event){
        var self = this;

        //=================================================
        component.set("v.showSpinner", true);
        Promise.all([ 
            self.setOptionsVal(component),
            self.getUserRoleId(component),
            self.renderTree(component, event)
        ])
        .then(() => {
            component.set("v.showSpinner", false);
        })
        .catch((errors) => {
            self.errorHander(errors);
        });
        //=================================================
        // OR (위 아래 둘중의 하나... 같은 동작임)
        //=================================================
       
        //self.sampleCall(component, event);
        //=================================================
    },

	getUserRoleId : function(component) {
        var self = this,
            Ids = new Array();
        self.apex(component, 'getUserRoleId', {})
        .then((result) => {
            var SetId = result;
        	Ids.push(SetId.UserOrRoleId);
            component.set("v.roleOrUserIds", Ids);
            component.set("v.isRoleId", SetId.isRoleId);
            component.set("v.roleOrUserId", SetId.UserOrRoleId);
        })
        .catch((errors) => {
            self.errorHander(errors);
        });
	},

    renderTree: function(component, event) {
        var self = this,
            roleId = component.get("v.roleOrUserId"),
            includeUser = component.get("v.includeUser");
        
        self.apex(component, 'getUserRoles', {
            roleOrUserId: roleId,
			includeUser: includeUser
        })
        .then((result) => {
            var jsonString = result;
            component.set("v.roleTree", JSON.parse(jsonString));
        })
        .catch((errors) => {
            self.errorHander(errors);
        });        
    },

    sampleCall : function(component, event){
        var self = this,
            Ids = new Array();

        component.set("v.showSpinner", true);
        self.apex(component, 'getUserRoleId', {})
        .then((result) => {
            var SetId = result;
        	Ids.push(SetId.UserOrRoleId);
            component.set("v.roleOrUserIds", Ids);
            component.set("v.isRoleId", SetId.isRoleId);
            component.set("v.roleOrUserId", SetId.UserOrRoleId);
            var roleId = component.get("v.roleOrUserId"),       // SetId.UserOrRoleId
                includeUser = component.get("v.includeUser");
            return self.apex(component, 'getUserRoles', {
                roleOrUserId: roleId,
                includeUser: includeUser
            });
        })
        .then((result) => {
            var jsonString = result;
            component.set("v.roleTree", JSON.parse(jsonString));

            component.set("v.showSpinner", false);
        })
        .catch((errors) => {
            self.errorHander(errors);
        });

    },

    resetEvents : function(component){
        var Ids = new Array();
        var rid = component.get("v.selectedKey");
        Ids.push(rid);
		var cal = component.find("fullCalendar");
 		cal.resetEvents(Ids, component.get("v.isRoleId"),  component.get('v.checkedValue'));
    },
    
    renderCalendar : function(component) {
        var cal = component.find("fullCalendar");
        cal.resetEvents(component.get("v.roleOrUserIds"), component.get("v.isRoleId"), component.get('v.checkedValue'));
        // cal.resetEvents(component.get("v.roleOrUserIds"), component.get("v.isRoleId"), component.get('v.checked'));
    },
    
    initCalednar: function(component){
        var self = this,
            Ids = new Array();
        self.apex(component, 'getUserRoleId', {})
        .then((result) => {
            var SetId = result;
        	Ids.push(SetId.UserOrRoleId);
            component.set("v.roleOrUserIds", Ids);
            component.set("v.isRoleId", SetId.isRoleId);
            component.set("v.roleOrUserId", SetId.UserOrRoleId);
            self.renderCalendar(component);
        })
        .catch((errors) => {
            self.errorHander(errors);
        });
    },

    /* set Checkbox Event Type */
    setOptionsVal: function(component){
        component.set('v.options',[
            {'label':'Event', 'value':'Event'},
            {'label':'Task', 'value':'Task'},
            {'label':'Account Plan', 'value':'Account Plan'},
            {'label':'Opportunity Activity', 'value':'Opportunity Activity'},
        ]);

        var optionsVal = ['Event','Task','Account Plan','Opportunity Activity'];
        component.set('v.checkedValue',optionsVal);

        var checked = {
            'Event' : true,
            'Task' : true,
            'AccPlan' : true,
            'OpptyAct' : true
        }
        component.set('v.checked',checked);
    },

    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showMyToast('error', 'Unknown error in javascript controller/helper.')
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},
})