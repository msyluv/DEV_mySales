/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 01-20-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   01-14-2021   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this,
            selType = component.get("v.selType"),
            accountId = component.get("v.accountId"),
            existing = component.get("v.existing");
        
        if(accountId != ''){
            component.set("v.hasAccount", true);
        }
        component.set("v.existMap", self.list2map(existing));
		self.queryPerson( component, selType, accountId, "" );
    },

    list2map: function(lst){
        var mtmp = {};
        if(lst.length > 0){
            lst.forEach(function(el, idx, arr){
                mtmp[el.Id] = el.Name;
            });
        }
        return mtmp;
    },

    queryPerson: function(component, selType, accountId, searchText){
        var self = this;
        component.set("v.showSpinner", true);
		self.apex(component, 'queryPerson', {
                selType : selType,
                accountId : accountId,
                searchText : searchText
            })
            .then(function(result){
                console.log('queryPerson : ', result);
                component.set("v.available", result);
                self.makeTargetOption(component);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
	},

    makeTargetOption: function(component){
        console.log('make available option');
		var available = component.get("v.available"),
        	existMap = component.get("v.existMap"),
        	ownerId = component.get("v.ownerId"),
    		opts=[];
    	if(available.length > 0){
            available.forEach(function(el, idx, arr){
                if((el.Id in existMap) != true && el.Id != ownerId)
                	opts.push({"class": "optionClass", label: el.Name, value: el.Id})
            });
		}
    	component.set("v.options", opts);
	},




    addAttendee: function(component, event) {
        console.log('add new attendee to event');
        var self = this,
            persons = component.find("listbox").get("v.value"),
            eventId = component.get("v.eventId");
        console.log('selected', persons)
        if(persons.length > 0){
            component.set("v.showSpinner", true);
            self.apex(component, 'addEventAttendee', {
                    eventId : eventId,
                    persons : persons
                })
                .then(function(result){
                    console.log('addEventAttendee : ', result);
                    component.set("v.showSpinner", false);
                    component.find("overlayLib").notifyClose();
                })
                .catch(function(errors){
                    self.errorHander(errors);
                    component.set("v.showSpinner", false);
                });
        }
	},

    onChangeType: function(component, event){
        var self = this,
            accountId = component.get("v.accountId"),
            selType = event.getSource().get("v.value");
        component.set("v.selType", selType);
		console.log('onchange search with type change', selType);
		self.queryPerson( component, selType, accountId, '' );
    },

    onChangeSearch: function(component, event){
        var self = this,
            accountId = component.get("v.accountId"),
            selType = component.get("v.selType"),
            searchText = event.getSource().get("v.value");
		console.log('onchange search with text', searchText);
		self.queryPerson( component, selType, accountId, searchText );
    },
    
    apex : function(component, apexAction, params){
        /**
         * calling rule
        self.apex(component, 'method1', {})
            .then(function(result1){
                console.log('handlw with result1');
                return self.apex(component, 'method2', {});
            })
            .then(function(result2){
                console.log('handlw with result2');
            });
         */
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

    errorHandler : function(errors){
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
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
    },
})