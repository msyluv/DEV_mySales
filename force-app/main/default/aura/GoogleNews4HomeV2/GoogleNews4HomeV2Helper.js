/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 12-18-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-13-2020   woomg@dkbmc.com   Initial Version
**/
({
    doInit : function(component, event) {
        var self = this;
        self.getContents(component);
    },

    callSetup : function(component, event){
        var self = this,
            modalBody,
            modalFooter;
        $A.createComponents([
                ["c:googleNewsKeywordConfig",{}],
                ["c:googleNewsKeywordConfigFooter",{
                    onsubmit : component.getReference("c.submitFromChild")
                }]
            ],
            function(contents, status, errorMessage){
                if(status === "SUCCESS"){
                    var title = $A.get("$Label.c.GOOGLENEWS_KEYWORD_TITLE");
                    modalBody = contents[0];
                    modalFooter = contents[1];
                    component.set("v.modalbody", modalBody);
                    
                    component.find("overlayLib").showCustomModal({
                        header: title,
                        body : modalBody,
                        footer : modalFooter,
                        showCloseButton: true,
                        cssClass: 'childModal',
                        closeCallback: function(){
                            self.getContents(component);
                        }
                    });
                } else if(status === "INCOMPLETE"){
                    self.showMyToast("error", "Server issue or client is offline.");
                } else if(status === "ERROR"){
                    self.showMyToast("error", "Unknown error!");
                }
            }
        );
    },

    getContents : function(component){
        console.log('### getContents');
        
        var req = new XMLHttpRequest();
        var url = "https://news.google.com/rss/search?q=SAMSUNG+SDS&hl=en-US&gl=US&ceid=US:en";
        req.open("GET", url, true);
        //req.setRequestHeader("Access-Control-Allow-Origin", "https://news.google.com");
        //req.setRequestHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS, DELETE");
        //req.setRequestHeader("Access-Control-Max-Age", "3600");
        //req.setRequestHeader("Access-Control-Allow-Headers", "x-requested-with");
        //req.setRequestHeader("Access-Control-Allow-Origin", "*");
        
        req.onreadystatechange = function(){
            if(req.status === 200){
                //console.log('it responded, file deleted.');
                resolve(req.response);
            } else {
                //console.log('request error ', req.response);
                reject(Error(req.statusText));
            }
        };
        req.onerror = function(e){
            console.log('onerror -> ',e);
            var msg = 'error';
            reject(Error("Status : "+ req.status + msg));
        };
        req.send();
        
        
        
        
        
        /*
        console.log('Query Google News Feed');
        var self = this;
        component.set("v.showSpinner", true);
        self.apex(component, 'getContents4Home', {})
            .then(function(result){
                console.log('getContents4Home -> ', result);
                if(result != null && result.length > 0) component.set("v.hasNews", true);
                component.set("v.googleNews", result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHandler(errors);
                component.set("v.showSpinner", false);
            });
            */
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