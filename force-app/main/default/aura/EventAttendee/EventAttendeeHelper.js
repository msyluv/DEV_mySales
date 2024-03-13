/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-20-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-18-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component) {
        var self = this,
            eventId = component.get("v.recordId");

        component.set("v.showSpinner", true);
		self.apex(component, 'queryEventInfo', { eventId : eventId })
            .then(function(result){
                console.log('queryEventInfo : ', result);
                component.set("v.ownerId", result.OwnerId);
                component.set("v.accountId", result.AccountId);
                self.getEventAttendee(component, eventId);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
    },

    getEventAttendee : function(component, eventId) {
        var self = this;
        component.set("v.showSpinner", true);
		self.apex(component, 'queryEventAttendee', { eventId : eventId })
            .then(function(result){
                console.log('queryEventAttendee : ', result);
                component.set("v.attendee", result);
                if(result.length > 0){
                    var existing = [];
                    result.forEach(function(element, index, array){
                        var o = {};
                        o.Id = element.Relation.Id;
                        o.Name = element.Relation.Name;
                        existing.push(o);
                    });
                    console.log('make existing');
                    component.set("v.existing", existing);
                }
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
    },
    
    reloadAttendee : function(component, event) {
        console.log('event fired from child for reload attendee');
        var self = this,
            eventId = component.get("v.recordId");
        self.getEventAttendee(component, eventId);
    },

    clickAdd : function(component) {
        var self = this;
        component.set("v.showSpinner", true);
		self.apex(component, 'queryUserId', { })
            .then(function(result){
                console.log('queryUserId : ', result);
                if(component.get("v.ownerId") != result){
                    alert('Are you sure join to this event?');
                    self.addMySelf(component, result);
                } else {
                    self.openModal(component);
                }
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
    },

    addMySelf: function(component, uid){
        var self = this,
            persons = [],
            eventId = component.get("v.recordId");
        persons.push(uid);
        component.set("v.showSpinner", true);
		self.apex(component, 'addEventAttendee', {
                eventId : eventId,
                persons : persons
            })
            .then(function(result){
                console.log('addEventAttendee : ', result);
                self.getEventAttendee(component, eventId);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
    },

    openModal: function(component){
        var self = this,
            eventId = component.get("v.recordId"),
            existing = component.get("v.existing"),
            ownerId = component.get("v.ownerId"),
            accountId = component.get("v.accountId"),
            modalBody,
            modalFooter;

        $A.createComponents([
            ["c:eventAddAttendeeBody", { 
                "eventId" : eventId, 
                "existing" : existing, 
                "ownerId" : ownerId, 
                "accountId" : accountId 
            }],
            ["c:eventAddAttendeeFooter", { "onadd" : component.getReference("c.addAttendee") }]
        ],
        function(components, status, errorMessage){
            if(status === "SUCCESS"){
                modalBody = components[0];
                modalFooter = components[1];
                component.set("v.modalBody", modalBody);
                component.find('overlayLib').showCustomModal({
                    header : 'Add Attendee',
                    body : modalBody,
                    footer : modalFooter,
                    showCloseButton : true,
                    cssClass : "slds-modal_x-small",
                    closeCallback : function(){
                        self.reloadAttendee(component, eventId);
                    }
                })
            }
        });
    },

    /**
     * Common Functions
     */
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
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
			var msg = $A.get("Unknown APEX/Javascript Error!");
            self.showMyToast('error', msg)
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},
})