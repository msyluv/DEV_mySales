/**
 * @author            : akash.g@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-11-06
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-12-01   akash.g@samsung.com       Initial Version
 * 1.1   2022-01-03   akash.g@samsung.com       Fix for Profile & Role issue visible bydefault while creating other user.
 * 1.2   2023-11-06   sarthak.j1@samsung.com	UserEmployee Management function enhancement -> MYSALES-338
**/
({
    init : function(component, event, helper) {
        helper.doInit(component, event);
    },
    
	search : function(component, event, helper) {
        var email = component.get('v.enteredEmail');
        if(email == null || email == ''){
            helper.showMyToast('Error', $A.get("$Label.c.EmailAddressMandate"));
        }else{
            component.set('v.showSpinner',true);
            component.set('v.editMode',false);
            component.set("v.showButton", false);
            /**Fix for V1.1 :Profile & Role issue visible bydefault while creating other user.*/
            component.set("v.selectedRole",'');
            component.set("v.selectedProfile",''); 
            component.set("v.firstNameCreateUser",'');
            component.set("v.isActive",true);
            component.set("v.isMFA",true);
            helper.getEmployeeResult(component, event);
        }
    },
    
    createUser : function(component, event, helper) {
     var profile = component.get('v.selectedProfile');
     var role = component.get('v.selectedRole');
     var lastname = component.get('v.lastNameCreateUser');
     if((profile == null || role == null || lastname == null) || (profile == '' || role == '' || lastname == '')){
         	helper.showMyToast('Error', $A.get("$Label.c.Role_ProfileMandatoryErrorMsg"));
      }else{
          	component.set('v.showSpinner',true);
          	helper.createUserHelper(component,event);
         }
     },    
    // Start v 1.2 (MYSALES-338)
    // Method to create User when 2 Employee records with different Company Codes exist. 
    createUser1 : function(component, event, helper) {
     var profile = component.get('v.selectedProfile');
     var role = component.get('v.selectedRole');
     var lastname = component.get('v.lastNameCreateUser');
     var compCode = component.get('v.selectedCompCode');
     if((profile == null || role == null || lastname == null || compCode == null) || (profile == '' || role == '' || lastname == '' || compCode == '')){
         	helper.showMyToast('Error', $A.get("$Label.c.Role_Profile_LastName_CompanyCodeMandatoryErrorMsg"));
      }else{
          	component.set('v.showSpinner',true);
          	helper.createUserHelper(component,event);
         }
     },
    // Method to update User when 2 Employee records with different Company Codes exist.
    save1 : function(component, event, helper) {
        var compCode = component.get('v.userCompCode');
        if(compCode == null || compCode == ''){
            helper.showMyToast('Error', $A.get("$Label.c.Role_Profile_LastName_CompanyCodeMandatoryErrorMsg"));
       }else{
             component.set('v.showSpinner',true);
             helper.updateUserHelper(component,event);   
        }
    },
	// End v 1.2 (MYSALES-338)    
    save : function(component, event, helper) {
        component.set('v.showSpinner',true);
        helper.updateUserHelper(component,event);
    },
    cancelUpdateUser : function(component, event, helper) {
       	component.set('v.editMode',false);
        component.set('v.showButton',false);
        helper.getEmployeeResult(component,event);
    },
    cancelCreateUser : function(component, event, helper) {
       	component.set('v.editMode',false);
        component.set('v.showButton',false);
        component.set('v.isActive',true);
        component.set('v.isMFA',true);
        component.set('v.selectedProfile','');
        component.set('v.selectedRole','');
        component.set('v.firstNameCreateUser','');
    },
    
    editMode : function(component, event, helper) {
        component.set("v.showButton", true);
        component.set("v.editMode", true);
    },
    resetPassword : function(component, event, helper) {
        if (confirm($A.get("$Label.c.Reset_Passoword_Alert")) == true) {
            component.set('v.showSpinner',true);
          	helper.resetPasswordHelper(component,event);
        }
    },
    onActiveChange : function(component, event, helper) {
        if(component.get('v.isActive1')){
          component.set("v.isMFA1", true);  
        }
    }
})