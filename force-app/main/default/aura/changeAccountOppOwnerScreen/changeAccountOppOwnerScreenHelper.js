/**
 * @author            : divyam.gupta@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-09-02
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2022-08-22   Divyam.Gupta@samsung.com   Initial Version
**/
({
    getAccInfo: function(component,event){
        var enterdAcc = component.get('v.EnterAccNumber');
        var self=this;
        self.apex(component, 'getAccInfo', { accnumber: enterdAcc
                                           }).then(function(result){
            window.console.log('result : ', result);
            component.set('v.showSpinner',false);

            if(result.Validacc != null && result.Validacc != undefined){
                var accInfonotcol = JSON.parse(result.Validacc);
                component.set('v.eAccountName',accInfonotcol.Name);
                component.set('v.OwnerId',accInfonotcol.OwnerId);
                component.set('v.accOwnerName',accInfonotcol.Owner.Name);
                component.set('v.showTable',true);
            }
            else if(result.Accblank == 'Blank'){
                self.showMyToast('error', $A.get("$Label.c.OwnerAccErrorMsg"));
                component.set('v.showTable',false);
                component.set('v.editButtonAcc',false);
  
            }
            else if(result.error == null ){
                self.showMyToast('error', $A.get("$Label.c.OwnerAccErrorMsg"));
                component.set('v.showTable',false);
                component.set('v.editButtonAcc',false);
            }   
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
    
    getOppInfo: function(component,event){
        var enterdOpp = component.get('v.EnterOpportunityCode');
        window.console.log('enterdOpp : ',enterdOpp );
        var self=this;
        self.apex(component, 'getOppInfo', { opportunityCode: enterdOpp
                                           }).then(function(result){
            window.console.log('result of opportunity : ', result);
            if(result.NO_Collabaration != null && result.NO_Collabaration != undefined){
                var oppInfonotcol = JSON.parse(result.NO_Collabaration);
                component.set('v.OpportunityName',oppInfonotcol.Name);
                component.set('v.CompanyCode',oppInfonotcol.CompanyCode__c);
                component.set('v.SalesRep',oppInfonotcol.Owner.Name);
                component.set('v.showTableopp',true);  
                 component.set('v.Firsteditopp',true);

            }
            else if(result.HQ != null && result.HQ != undefined){
                var oppInfohq = JSON.parse(result.HQ);
                var oppInfocol = JSON.parse(result.Subsidiary);   
                component.set('v.OpportunityName',oppInfohq.Name);
                component.set('v.CompanyCode',oppInfohq.CompanyCode__c);
                component.set('v.SalesRep',oppInfohq.Owner.Name);
                component.set('v.OpportunityName1',oppInfocol.Name);
                component.set('v.CompanyCode1',oppInfocol.CompanyCode__c);
                component.set('v.SalesRep1',oppInfocol.Owner.Name);
                component.set('v.showTableopp',true);  
                component.set('v.ShowSecondTableopp',true);  
                component.set('v.Secondeditopp',true);  
                component.set('v.Firsteditopp',true);  


            }else if(result.error == null ){
                    self.showMyToast('error', $A.get("$Label.c.OwnerOppErrorMsg"));
                    component.set('v.showTableopp',false);
                    component.set('v.editButtonOpp',false);
                    component.set('v.SecondTableopp',false);
                }   
        }).catch(function(errors){
            self.errorHandler(errors);
        });
    },
   
    updateAcc: function(component,event){
        var enterdAcc1 = component.get('v.EnterAccNumber');
        var selectedUser = component.get('v.selectedLookUpRecord').Id;
        var self=this;
         if(selectedUser == null || selectedUser == '' || selectedUser == undefined){
             component.set('v.showSpinner',false);       
            self.showMyToast('error', $A.get("$Label.c.SelectuserError"));
            component.set('v.noUserSelected',true); 
         }
                else if(selectedUser != null && selectedUser != '' && selectedUser != undefined){
                    component.set('v.noUserSelected',false); 

         self.apex(component, 'updateAcc', {accnumber: enterdAcc1,
                                           searchUserAcc: selectedUser
                                          }).then(function(result){
            window.console.log('result after acc owner update : ', result);
            
            self.showMyToast('success',$A.get("$Label.c.OwnerUpdateSuccessMsg"));
            component.set('v.showTableopp',false);
            
        }).catch(function(errors){
            
            self.errorHandler(errors);
        });
                }
    },
    
    updateOpp: function(component,event){
        var enterdopp = component.get('v.EnterOpportunityCode');
        var enterccode = component.get('v.CompanyCode');
        
        var selectedOUser = component.get('v.selectedLookUpRecord').Id;
        window.console.log('result of selected user : ', selectedOUser);
        
         var self=this;

        if(selectedOUser == null || selectedOUser == '' || selectedOUser == undefined){
           component.set('v.showSpinner',false);       
          self.showMyToast('error', $A.get("$Label.c.SelectuserError"));
           component.set('v.noUserSelected',true); 



        }

        
        else if(selectedOUser != null && selectedOUser != '' && selectedOUser != undefined){
         component.set('v.noUserSelected',false); 

        self.apex(component, 'updateOpp', {oppcode: enterdopp,
                                           compcode :enterccode,
                                           searchUserOpp: selectedOUser
                                          }).then(function(result){
            self.showMyToast('success',$A.get("$Label.c.OwnerUpdateSuccessMsg"));
            
        }).catch(function(errors){
            
            self.errorHandler(errors);
        });
        }
       
    },
    
    updateOpp1: function(component,event){
        var enterdopp = component.get('v.EnterOpportunityCode');
        var enterccode = component.get('v.CompanyCode1');
        var selectedOUser = component.get('v.selectedLookUpRecord1').Id;
        
        var self=this;
         if(selectedOUser == null || selectedOUser == '' || selectedOUser == undefined){
             component.set('v.showSpinner',false);       
          self.showMyToast('error', $A.get("$Label.c.SelectuserError"));
           component.set('v.noUserSelected',true); 
         }
        else if(selectedOUser != null && selectedOUser != '' && selectedOUser != undefined){
           
           component.set('v.noUserSelected',false); 

        self.apex(component, 'updateOpp', {oppcode: enterdopp,
                                           compcode :enterccode,
                                           searchUserOpp: selectedOUser
                                          }).then(function(result){
            self.showMyToast('success',$A.get("$Label.c.OwnerUpdateSuccessMsg"));
            
        }).catch(function(errors){
            
            self.errorHandler(errors);
        });
        }
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
            duration: 10000,
            mode: 'sticky',
            message: msg
        });
        toastEvent.fire();
    }
    
    
})