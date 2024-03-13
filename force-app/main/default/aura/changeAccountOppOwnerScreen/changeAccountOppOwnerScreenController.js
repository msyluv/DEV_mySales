/**
 * @author            : divyam.gupta@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2022-09-02
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2022-08-17   Divyam.gupta@samsung.com      Initial Version
**/
({
    ChangeAccountOwner : function(component, event, helper) {
        component.set('v.attribute1',true)
        component.set('v.attribute2',false);
        component.set('v.showTable',false);
        component.set('v.editButtonAcc',false);
        component.set('v.showTableopp',false);
        component.set('v.editButtonOpp',false);
        component.set('v.EnterAccNumber','');
        component.set('v.EnterOpportunityCode','');
        component.set('v.selectedLookUpRecord','');
        component.set('v.SecondTableopp',false);
        component.set('v.selectedLookUpRecord1','');
    },
    ChangeOpportunityOwner : function(component, event, helper) {
        component.set('v.attribute2',true);
        component.set('v.attribute1',false);
        component.set('v.showTable',false);
        component.set('v.editButtonAcc',false);
        component.set('v.showTableopp',false);
        component.set('v.editButtonOpp',false);
        component.set('v.EnterAccNumber','');
        component.set('v.EnterOpportunityCode','');
        component.set('v.selectedLookUpRecord','');
        component.set('v.SecondTableopp',false);
        component.set('v.selectedLookUpRecord1','');
    },
    SearchAcc : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.getAccInfo(component,event);
        component.set('v.editButtonAcc',false);
    },
    searchOpp : function(component, event, helper) {
         component.set('v.showSpinner',true);
        component.set('v.showTableopp',false);
        component.set('v.Secondeditopp',false);
        component.set('v.ShowSecondTableopp',false);
        helper.getOppInfo(component,event);
      //  component.set('v.Firsteditopp',true);
       // component.set('v.Secondeditopp',true);
           component.set('v.showSpinner',false);

        component.set('v.editButtonOpp',false);
        component.set('v.SecondTableopp',false);
    },
    updateOwner : function(component, event, helper) {
        console.log('inside onchange');
        console.log('selected valll---->' + component.find('select').get('v.value'));
    },
    editActionAcc : function(component, event, helper) {
        component.set('v.editButtonAcc',true);
        component.set('v.editButtonOpp',false);
      //  helper.getAllUserName(component,event);
    },
    editActionOpp : function(component, event, helper) {
        component.set('v.editButtonOpp',true);
        component.set('v.editButtonAcc',false);
        component.set('v.SecondTableopp',false);
        component.set('v.Secondeditopp',false);
        // helper.getAllOppName(component,event);
    },
    editActionOpp1 : function(component, event, helper) {
        component.set('v.editButtonOpp',false);
        component.set('v.Firsteditopp',false);
        component.set('v.FirstTableopp',false);
        component.set('v.SecondTableopp',true);
        helper.getAllOppName(component,event);
    },
    ChangeOwnerAcc : function(component, event, helper) {
         component.set('v.showSpinner',true);
        helper.updateAcc(component,event);
         var userselect = component.get('v.noUserSelected');
        
        if(userselect == false){
        component.set('v.editButtonAcc',false);
        component.set('v.selectedLookUpRecord','');
        helper.getAccInfo(component,event);
        component.set('v.showSpinner',false);
        }

    },
    
    ChangeOwnerOpp : function(component, event, helper) {
        
        component.set('v.showSpinner',true);
        helper.updateOpp(component,event);
        var userselect = component.get('v.noUserSelected');

        
        if(userselect == false){
        component.set('v.attribute2',true);
        component.set('v.editButtonOpp',false);
        component.set('v.selectedLookUpRecord','');
        helper.getOppInfo(component,event);
        component.set('v.showSpinner',false);
        }


      //  component.set('v.Firsteditopp',true);
       // component.set('v.Secondeditopp',true);
    },
    
    ChangeOwnerOpp1 : function(component, event, helper) {
                
        component.set('v.showSpinner',true);
        helper.updateOpp1(component,event);
        var userselect = component.get('v.noUserSelected');
          if(userselect == false){

        component.set('v.attribute2',true);
        component.set('v.SecondTableopp',false);
        component.set('v.selectedLookUpRecord1','');
        helper.getOppInfo(component,event);
        component.set('v.showSpinner',false);
        // component.set('v.Firsteditopp',true);
        // component.set('v.Secondeditopp',true);
          }
    },
    CancelAll : function(component, event, helper) {
        if (confirm('Do You Really want to cancel?') == true) {
            component.set('v.showTable',false);
            component.set('v.editButtonAcc',false);
            component.set('v.attribute1',false);
            component.set('v.showTableopp',false);
            component.set('v.editButtonOpp',false);
            component.set('v.attribute2',false);
            component.set('v.EnterAccNumber','');
            component.set('v.EnterOpportunityCode','');
            component.set('v.selectedLookUpRecord','');
            component.set('v.SecondTableopp',false);
            component.set('v.selectedLookUpRecord1','');
            return true;
        }
        else {
            return false;
        }
    }
})