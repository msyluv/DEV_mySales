/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-10-24
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   12-24-2020   woomg@dkbmc.com   Initial Version
 * 1.1   2022-10-11   kajal.c@samsung.com  CP Review Activity Added.
 * 1.2   2023-10-24   divyam.gupta@samsung.com Mysales-331 (Logistics) CP Review logic change.
**/
({
    doInit : function(component){
        /**START ->Added By kajal**/
        var menuName= component.get("v.menu");
        var lbsCode = component.get("v.lbsCode");
        var oppCode = component.get("v.oppsID");
        var self = this;
        console.log('menuName Values**='+ menuName);
        console.log('lbsCode Values**='+ lbsCode);
        console.log('oppCode = ' + oppCode);
        if(menuName == "WKS_LOGICP_REG" && lbsCode == "FIN"){
            console.log('Exception Logic Entry@@');
            component.set("v.showSpinner", true);
            self.apex(component, 'getExceptionBoolean', { 
                opptyID : oppCode, 
            })
            .then(function(result){
                console.log('result## Value ->', result);
                component.set("v.getExceptionBooleanValue", result);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
        };
        /**END ->Added By kajal**/
        var config = {
            'WKS_TS_REG' : {
                'height' : 280,
                'width' : 680
            },
            'WKS_LBS_REG' : {
                'height' : 750,
                'width' : 1240
            },
            'WKS_CRAS_REG' : {
                'height' : 630,
                'width' : 1040
            },
            /**2022.10.14 yeongju.baek@dkbmc.com Request AP(APS) Activity
             와 연계된 Link의 파라미터 변경**/
            'APS_AP_REQ_INFO_NEW' : {
                'height' : 800,
                'width' : 1280
            },
            /**V1.1- START Added by kajal- CP Review Activity Added**/
            'WKS_LOGICP_REG' : {
                'height' : 750,
                'width' : 1240
            },
            /**V1.1- END**/
        };
        component.set("v.config", config);
    },

    callCelloMenu : function(component, event){            
        console.log('call Cello Page');
        var self = this, 
            menu = component.get("v.menu"),
            lbsType = component.get("v.lbsType"),
            lbsCode = component.get("v.lbsCode"),
            opptyId = component.get("v.opptyId"),
            billToId = component.get("v.billToId"),
            config = component.get("v.config"),
            /**V1.1- START Added by kajal- CP Review Activity Added**/
            Transactionname = component.get("v.transactionName"),
            options = '';

            options = 'width=' + config[menu].width + ',height=' + config[menu].height;
            //options += ',menubar=no,resizable=no,scrollbars=no,status=no,titlebar=no,toolbar=no';
            
        if(menu == "" || opptyId == ""){
            self.showMyToast("error", "You must assign menu name and BO Id to Cello button");
            return null;
        }
        //START V 1.2 Changes by Divyam
        var rvtype ='';
        if(Transactionname == '2.4.4'){
            if(component.get("v.popUpWindowRedirect") == true){
               rvtype = 'SELF';
            }
            else {
                  rvtype = 'REGL';
            }
        }
        if(Transactionname == '2.3.1'){
             rvtype = 'REGL';
        }
        
        console.log('rvtypeval',rvtype);
         console.log('menuname',menu);
        //END V 1.2
        component.set("v.showSpinner", true);
        self.apex(component, 'getCelloParameters', { 
                menuname : menu, 
                lbsType : lbsType, 
                lbsCode : lbsCode, 
                boId : opptyId,
                billToId : billToId ,
                rvType  : rvtype
            })
            .then(function(result){
                console.log('encrypt data ->', result);
                if(result != null){
                    var url = $A.get("$Label.c.CELLO_MENU_URL");
                    url += "?p0=" + result["p0"] + "&p2=" + result["p2"] + "&p3=" + result["p3"];
                    /**V1.1- START Added by kajal- CP Review Activity Added**/
                    if(Transactionname == '2.4.5.' || Transactionname == '2.3.1' || Transactionname== '2.4.4'){
                    window.open(url, '_blank',  "toolbar=yes,scrollbars=yes,resizable=yes,top=150,left=300,width=600,height=300");  // kajal
                    }
                    else{
                    window.open(url, '_blank', options);
                    }
                    /**V1.1- Stop Added by kajal- CP Review Activity Added**/
                    // var urlEvent = $A.get("e.force:navigateToURL");
                    // urlEvent.setParams({
                    //     "url": url
                    // });
                    // urlEvent.fire();
                }
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
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