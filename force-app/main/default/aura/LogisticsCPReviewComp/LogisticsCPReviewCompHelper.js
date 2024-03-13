/**
* @description       : Rest API Callout to Interact with Cello system
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2023-10-05
* @last modified by  : divyam.gupta@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-10-19   Kajal.c@samsung.com   Initial Version
* 1.1   2023-07-25   Kajal.c@samsung.com   Added changes related to Mysales-266
* 1.2   2023-10-05   divyam.gupta@samsung.com   Mysales-313 (Logistics) CP Review URL error modify.

**/
({
    getLogisticsData : function(component,event) {
        
        var action = component.get("c.getLogisticsCPReviewData");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.MasterLogisticsCPReviewList", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    updateFinalStatus : function(component,event) {
        console.log('Akash@@1');
        	var self = this;
        	var opptyId = component.get("v.oppId");
        console.log('Akash@@2' + opptyId);
        	component.set("v.showSpinner", true);
            self.apex(component, 'updateOpp', { 
                        boId : opptyId
                     })
                    .then(function(result){
                            console.log('Akash@@3');
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                          console.log('Akash@@4');
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    });  
    },
    close : function(component, event) {
        component.find('overlayLib1').notifyClose();
       },
    
     
    urlRedirect : function(component, event) {
        console.log('call Cello Page');
        var self = this;
        var config = {
            'WKS_LOGICP_REG' : {
                'height' : 750,
                'width' : 1240
            },
        };
       /** var lbsType = component.get("v.lbsType"),
            opptyId = component.get("v.oppId"),
            billToId = component.get("v.billToId"); **/
         //V 1.2 Divyam 
           var lbsType = component.get("v.lbsType"),
            opptyId = component.get("v.oppcode"),
            billToId = component.get("v.billToId");
        console.log('Log1');
        var options = 'width=' + config['WKS_LOGICP_REG'].width + ',height=' + config['WKS_LOGICP_REG'].height;
                      
    
        console.log('Log2');
        component.set("v.showSpinner", true);
        console.log('test1##');
        self.apex(component, 'getURL',{
            lbsType : lbsType, 
            boId : opptyId,
            billToId : billToId 
        })
        .then(function(result){
            console.log('encrypt data ->', result);
            if(result != null){
                var url = $A.get("$Label.c.CELLO_MENU_URL");
                url += "?p0=" + result["p0"] + "&p2=" + result["p2"] + "&p3=" + result["p3"];
                window.open(url, '_blank',options);
            }
            component.set("v.showSpinner", false);
        })
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });
    },
    
      ConfirmValueSet : function(component, event) {
        var self = this;
        var opptyId = component.get("v.oppId");
        var Confirmdata = component.get("v.isconfirmValue");
        self.apex(component, 'IsConfirmData', { 
                        boId : opptyId,
                        IsConfirm   : Confirmdata
                     })
                  .then(function(result){
                      console.log('result data ->', result);
                        
                    })
                    .catch(function(errors){
                        console.log('error data ->', errors);
                    });
        
   },
    
    saveLogisticsYesorNO : function(component,event){
        var self = this;
        var opptyId = component.get("v.oppId");
        var LevelOne = component.get("v.Level1");
        var LevelTwo = component.get("v.Level2");
        var LevelThree = component.get("v.Level3");
        var LevelFour = component.get("v.Level4");
        console.log('divyam-->');
         self.apex(component, 'updateAndInsertLogisticsYesorNo', { 
                        boId : opptyId,
                        L1   : LevelOne,
                        L2   : LevelTwo,
                        L3   : LevelThree,
                        L4   : LevelFour
                     })
                    .then(function(result){
                            console.log('Record insert');
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    });
        self.EnableConfirm(component);
        
    },
    
    getLevelData  : function(component,event){
        var self = this;
        var opptyId = component.get("v.oppId");
         self.apex(component, 'getLevelvalue', { 
                        boId : opptyId
                     })
                    .then(function(result){
                        if(result != null && result != '' && result!= undefined){
                            var resultval = result[0];
                            //**********V1.1  Added by kajal Set Cargoes value ****************//
                            /**
                            var cargoespsottrim = resultval.Cargoes__c;
                            if(cargoespsottrim != null && cargoespsottrim != '' && cargoespsottrim!=undefined){
                            component.set("v.cargoesValue",cargoespsottrim);
                            } **/
                            component.set("v.isconfirmValue",resultval.IsConfirm__c);
                            if(resultval.IsConfirm__c == true){
                                component.set("v.isdisabled",true);
                           }
                            console.log('result is @@' , result);
                            var LevelOneval = resultval.Level1__c;
                            if(LevelOneval == 'No'){
                                component.set("v.Level1",'No');
                                component.set("v.Popup1",true);
                                console.log('init pop1' , component.get("v.Popup1"));
                                component.set("v.selectedLevelOneNo",true);
                            }
                            if(LevelOneval == 'Yes'){
                                component.set("v.Level1",'Yes');
                                component.set("v.Popup1",true);
                                component.set("v.selectedLevelOneYes",true);
                            }
                            if(LevelOneval == 'Need to review'){
                                component.set("v.Level1",'Need to review');
                                component.set("v.Popup1",true);
                                component.set("v.selectedLevelOneNeed",true);
                            }
                            var LevelTwoval = resultval.Level2__c;
                            if(LevelTwoval == 'No'){
                                component.set("v.Level2",'No');
                                component.set("v.Popup2",true);
                                component.set("v.selectedLevelTwoNo",true);
                            }
                            if(LevelTwoval == 'Yes'){
                                component.set("v.Level2",'Yes');
                                component.set("v.Popup2",true);
                                component.set("v.selectedLevelTwoYes",true);
                            }
                            if(LevelTwoval == 'Need to review'){
                                component.set("v.Level2",'Need to review');
                                component.set("v.Popup2",true);
                                component.set("v.selectedLevelTwoNeed",true);
                            }
                            var LevelThreeval = resultval.Level3__c;
                            if(LevelThreeval == 'No'){
                                component.set("v.Level3",'No');
                                component.set("v.Popup3",true);
                                component.set("v.selectedLevelThreeNo",true);
                            }
                            if(LevelThreeval == 'Yes'){
                                component.set("v.Level3",'Yes');
                                component.set("v.Popup3",true);
                                component.set("v.selectedLevelThreeYes",true);
                            }
                            if(LevelThreeval == 'Need to review'){
                                component.set("v.Level3",'Need to review');
                                component.set("v.Popup3",true);
                                component.set("v.selectedLevelThreeNeed",true);
                            }
                            var LevelFourval = resultval.Level4__c;
                            if(LevelFourval == 'No'){
                                component.set("v.Level4",'No');
                                component.set("v.Popup4",true);
                                component.set("v.selectedLevelFourNo",true);
                            }
                            if(LevelFourval == 'Yes'){
                                component.set("v.Level4",'Yes');
                                component.set("v.Popup4",true);
                                component.set("v.selectedLevelFourYes",true);
                            }
                         
                            
                        }
                          self.EnableConfirmOne(component);
                        
                            console.log('Record insert');
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    }); 
    },
    
    EnableConfirm : function(component){
        let showpopup1=component.get("v.Popup1");
        let showpopup2=component.get("v.Popup2");
        let showpopup3=component.get("v.Popup3");
        let showpopup4=component.get("v.Popup4");
       
        console.log('showpopup4' + showpopup4);
        if(showpopup1 == true && showpopup2 == true && showpopup3 == true && showpopup4 == true){
            component.set("v.confirmEnable",false);
            
        }
    },
    
    EnableConfirmOne : function(component){
        let showpopup1=component.get("v.Popup1");
        let showpopup2=component.get("v.Popup2");
        let showpopup3=component.get("v.Popup3");
        let showpopup4=component.get("v.Popup4");
        let disableAfterConfirm = component.get("v.disableAfterConfirm");
        console.log('showpopup4' + showpopup4);
        if(showpopup1 == true && showpopup2 == true && showpopup3 == true && showpopup4 == true){
            component.set("v.confirmEnable",false);
            
             
            
        }
    },
    //**********V1.1  Added by kajal --> START ****************//
    /**
    savecargoes : function(component){
        console.log('savecargoes called');
         var self = this;
        var SaveCargoes = $A.get("$Label.c.Savecargoesmessage");
        var errorlabel = $A.get("$Label.c.CargoesErrormessage");
        var specialCharError = $A.get("$Label.c.SpecialCharactersError");
        let Cargoesvalbeforetrim=component.get("v.cargoesValue"); 
        let Cargoesval = Cargoesvalbeforetrim.trim();
        component.set('v.cargoesValue',Cargoesval);
         if(Cargoesval == ''|| Cargoesval == undefined){
          self.showMyToast('error', $A.get("$Label.c.CargoesErrormessage"));
         }else{
        
        var regurwexp = ['^','.','*','-','@','!','#','$','%','&','(',')','_','+','[',']','|','~','=','`','{','}',':',';','<','>','?','/',' '];
        var detailval1 = Cargoesval.replace(/[\r\n]+/gm,"");
        var matchvar = '';
        var matchvar1 = '';
        console.log('regurwexp',regurwexp.length);
        for(let k=0;k < detailval1.length;k++  ){
           for(let j=0 ; j < regurwexp.length; j++){
               if(detailval1[k] == regurwexp[j]){
                  matchvar = matchvar + regurwexp[j];
                               break;
                           }
                       }
                          console.log('matchvar',matchvar);

                    }
        if(matchvar == detailval1 ){
           self.showMyToast('error', $A.get("$Label.c.SpecialCharactersError"));  
        }
        else{
        var opptyId = component.get("v.oppId");
            if(opptyId != '' && opptyId != null && opptyId != undefined){
         self.apex(component, 'saveCargoesvalue', { 
                        boId : opptyId,
                        Cargoesvalue : Cargoesval
                     }).then(function(result){
                        if(result != null && result != '' && result!= undefined){
                            console.log('result called@@@' , result);
                            var resultval = result;
                           if(result == 'Success'){
                              self.showMyToast('Success', $A.get("$Label.c.Savecargoesmessage"));
                              //component.set('v.cargoesval',true);
                            }
                        }
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        //component.set("v.showSpinner", false);
                    });
            } }}},
            **/
    //**********V1.1 END ****************//

    getOppData  : function(component,event){
        var self = this;
        var opptyId = component.get("v.oppId");
         self.apex(component, 'getOppData', { 
                        boId : opptyId
                     })
                    .then(function(result){
                        if(result != null && result != '' && result!= undefined){
                            var resultval = result[0];
                            var FinStatus = resultval.Opportunity_Logistics_CPReviewStatus_FIN__c;
                            // Start V 1.2 Divyam 
                            var opprcode = resultval.OpportunityCode__c;
                            component.set("v.oppcode",opprcode);
                            // End V 1.2
                            if(FinStatus == 'CNFM'){
                                component.set("v.isdisabled",true);
                                component.set("v.confirmEnable",true);
                            }
                        }
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    }); 
    },
     //**********V1.1  Added by kajal --> START ****************//
     /**
      getoptactivtyStatus  : function(component,event){
        var self = this;
        var opptyId = component.get("v.oppId");
         self.apex(component, 'getoptactivtyStatus', { 
                        boId : opptyId
                     })
                    .then(function(result){
                        if(result != null && result != '' && result!= undefined){
                            var resultval = result[0].Status__c;
                            console.log('resultstatus-->',resultval);
                            component.set('v.oppactsatus',resultval);
                            
                            if(resultval == 'Completed'){
                                component.set('v.cargoesdisable',true);
                                component.set('v.cargoessavedisable',true);
                            }
                               
                        }
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    }); 
    },
      **/
     //**********V1.1 END ****************//
    
    //**********V1.1  Added by kajal --> START ****************//
    /**
    checkcargovalue : function(component,event){
         var errorlabel = $A.get("$Label.c.CargoesErrormessage");
        var self = this;
        component.set("v.cargoesval",false);
        var opptyId = component.get("v.oppId");
        
         self.apex(component, 'getLevelvalue', { 
                        boId : opptyId
                     })
         
                    .then(function(result){
                        if(result != null && result != '' && result!= undefined){
                            var resultval = result[0];
                            if(resultval.Cargoes__c != '' && resultval.Cargoes__c != undefined){
                            component.set("v.cargoesValue1",resultval.Cargoes__c);
                            }
                           if(component.get('v.cargoesValue1') == ''  || (component.get('v.cargoesValue') == '' ||  component.get('v.cargoesValue') == null) || component.get('v.cargoesValue') != component.get('v.cargoesValue1') ){
                                                         console.log('cargoesbolval',component.get('v.cargoesval'));
                         self.showMyToast('error',errorlabel);
                             }
                            else {
                                  
                                self.handleconfirmyes(component,event);
                            }
                                           
                        }
                        else {
                            self.showMyToast('error',errorlabel);
                        }
                        component.set("v.showSpinner", false);
                    })
                    .catch(function(errors){
                        self.errorHander(errors);
                        component.set("v.showSpinner", false);
                    });
        
        
        
    },
    **/
    //**********V1.1 END ****************//
    /**
    handleconfirmyes : function(component,event){
        var level1 = component.get("v.Level1");
        var level2 = component.get("v.Level2");
        var level3 = component.get("v.Level3");
        var level4 = component.get("v.Level4");
        if(level1 == 'No' && level2 =='No' && level3 == 'No' && level4 == 'No'){
         component.set("v.confirmpopup",true);
         component.set("v.isdisabled",true);
        }
        else{
           this.urlRedirect(component, event);
           component.set("v.isconfirmValue",true);
           this.ConfirmValueSet(component, event);
           component.set("v.isdisabled",true);
        }
    }
    **/
    
    
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
    }
    
    
    
})