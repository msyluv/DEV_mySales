/**
* @description       : Rest API Callout to Interact with Cello system
* @author            : Kajal.c@samsung.com
* @group             : 
* @last modified on  : 2022-10-19
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   2022-10-19   Kajal.c@samsung.com   Initial Version
* 1.1   2023-07-25   Kajal.c@samsung.com   Added changes related to Mysales-266
**/
({
	doInit : function(component, event, helper) {
        var locale = $A.get("$Locale.language");
            console.log('the user lang:'+locale);
            if(locale == 'ko'){
                component.set("v.setLangEng",false);
                component.set("v.setLangKor",true);
            }
            else{
                component.set("v.setLangEng",true);
                component.set("v.setLangKor",false);
            }
         helper.getLogisticsData(component,event);
         helper.getLevelData(component,event);
        helper.getOppData(component,event);
        /** V1.1 Added By kajal **/
        //helper.getoptactivtyStatus(component,event);
	},
    handleCancel : function(component, event, helper) {
         component.set("v.Level1",'No');
         component.set("v.Popup1",true);
         helper.saveLogisticsYesorNO(component,event);
         component.set("v.selectedLevelOneNo",true);
         component.set("v.selectedLevelOneNeed",false);
         component.set("v.selectedLevelOneYes",false);
       
    },
    handleCancelPopup1 : function(component, event, helper) {
        component.set("v.Level2",'No');
        component.set("v.selectedLevelTwoNo",true);
        component.set("v.selectedLevelTwoNeed",false);
        component.set("v.selectedLevelTwoYes",false);
        component.set("v.Popup2",true);
        helper.saveLogisticsYesorNO(component,event);
 
    },
    handleCancelPopup2 : function(component, event, helper) {
         component.set("v.Level3",'No');
         component.set("v.selectedLevelThreeNo",true);
         component.set("v.selectedLevelThreeNeed",false);
         component.set("v.selectedLevelThreeYes",false);
         component.set("v.Popup3",true);
         helper.saveLogisticsYesorNO(component,event);
      
    },
    
    closeApprovalButtonModal : function(cmp,event,helper){
        cmp.set('v.showContractApprovalModal' , false);
        cmp.set('v.isContractApproval' , false);
        helper.close(cmp, event);
    },
    
    closeApprovalButtonModalNo : function(component,event,helper){
        component.set("v.Level4",'No');
        component.set("v.selectedLevelFourNo",true);
        component.set("v.selectedLevelFourYes",false);
        component.set("v.Popup4",true);
        helper.saveLogisticsYesorNO(component,event);
      
    },
    
    handleURLYes1 : function(component, event, helper){
         component.set("v.Level1",'Yes');
         component.set("v.selectedLevelOneNo",false);
         component.set("v.selectedLevelOneNeed",false);
         component.set("v.selectedLevelOneYes",true);
         component.set("v.Popup1",true);
         helper.saveLogisticsYesorNO(component,event);

         console.log('haldleURl1Yes@@ and Save logistics data');
        
        },
    handleURLYes2 : function(component, event, helper){
         component.set("v.Level2",'Yes');
         component.set("v.selectedLevelTwoNo",false);
         component.set("v.selectedLevelTwoNeed",false);
         component.set("v.selectedLevelTwoYes",true);
         component.set("v.Popup2",true);
         helper.saveLogisticsYesorNO(component,event);
      
                },
    handleURLYes3 : function(component, event, helper){
         component.set("v.Level3",'Yes');
         component.set("v.selectedLevelThreeNo",false);
         component.set("v.selectedLevelThreeNeed",false);
         component.set("v.selectedLevelThreeYes",true);
         component.set("v.Popup3",true);
         helper.saveLogisticsYesorNO(component,event);
       
        
        },
    handleURLYes4 : function(component, event, helper){
         component.set("v.Level4",'Yes');
         component.set("v.selectedLevelFourNo",false);
         component.set("v.selectedLevelFourYes",true);  
         component.set("v.Popup4",true);
         helper.saveLogisticsYesorNO(component,event);
               
        },
     handleURLNeed1 : function(component, event, helper){
         component.set("v.Level1",'Need to review');
         component.set("v.selectedLevelOneNo",false);
         component.set("v.selectedLevelOneNeed",true);
         component.set("v.selectedLevelOneYes",false);
         component.set("v.Popup1",true);
         helper.saveLogisticsYesorNO(component,event);
         
         console.log('haldleURl1Need@@ and Save logistics data');
      
        },
    handleURLNeed2 : function(component, event, helper){
         component.set("v.Level2",'Need to review');
         component.set("v.selectedLevelTwoNo",false);
         component.set("v.selectedLevelTwoNeed",true);
         component.set("v.selectedLevelTwoYes",false);
         component.set("v.Popup2",true);
         helper.saveLogisticsYesorNO(component,event);
},
    handleURLNeed3 : function(component, event, helper){
         component.set("v.Level3",'Need to review');
         component.set("v.selectedLevelThreeNo",false);
         component.set("v.selectedLevelThreeNeed",true);
         component.set("v.selectedLevelThreeYes",false);
         component.set("v.Popup3",true);
         helper.saveLogisticsYesorNO(component,event);
        },
    
     handleConfirm : function(component, event, helper){
        var level1 = component.get("v.Level1");
        var level2 = component.get("v.Level2");
        var level3 = component.get("v.Level3");
        var level4 = component.get("v.Level4");
        
        if(level1 == 'No' && level2 =='No' && level3 == 'No' && level4 == 'No'){
         component.set("v.confirmpopup",true);
         component.set("v.isdisabled",true);
        }
        else{
           helper.urlRedirect(component, event);
           component.set("v.isconfirmValue",true);
           helper.ConfirmValueSet(component, event);
           component.set("v.isdisabled",true);
        }},
    
      onConfirmYes : function(component, event, helper){
        helper.saveLogisticsYesorNO(component,event);
        helper.updateFinalStatus(component,event);
        component.set('v.showContractApprovalModal', false);
        component.set('v.isContractApproval', false);
        helper.close(component, event);
        helper.handleConfirm(component, event); 
      },
    
    /**
    savecargoes : function(component, event, helper){
        helper.savecargoes(component, event);
    },
    ChangeCargoes : function(component, event, helper){
          //let Cargoesvalbeforetrim=component.get("v.cargoesValue"); 
          //var detailval1 = Cargoesvalbeforetrim.replace(/[\r\n]+/gm,"");
          //component.set('v.cargoesValue', detailval1);
       // var domEvent = event.getParam("domEvent");
       //if(domEvent.keyCode === 13) {
            //domEvent.preventDefault();
            //console.log('Enter key was pressed. Cancelling form submission.');
       },
       **/
    
    close : function(component, event, helper) {
       console.log("Closingpopup");
       //component.set("v.isconfirmValue",true);
       //helper.ConfirmValueSet(component, event);
       component.set('v.confirmpopup', false);
	}
    
    /**
    handlesubmit : function(component, event, helper){
               console.log("Closingpopup33");
        event.preventDefault();
        

    }
    **/
    
})