/**
 * @author            : akash.g@samsung.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2023-10-31
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-12-01   akash.g@samsung.com       Initial Version
 * 1.1	 2023-10-30	  sarthak.j1@samsung.com   	UserEmployee Management function enhancement -> MYSALES-338
**/
({
    doInit : function(component, event) {
		var self = this;

		self.apex(component, 'getLicenceDetail', { 
			}).then(function(result){
				window.console.log('result : ', result);
				var licence = result;
           		component.set('v.totalLicence',licence.TotalLicence);
            	component.set('v.usedLicence',licence.UsedLicence);
            	component.set('v.remainedLicence',licence.RemainedLicence);
				}).catch(function(errors){
				self.errorHandler(errors);
			});

	},
    
    getEmployeeResult : function(component, event) {
        var enteredEmail = component.get('v.enteredEmail');		
        window.console.log('enteredEmail : ', enteredEmail);
        var self = this;
        self.apex(component, 'getEmployeeResult', {
            emailValue : enteredEmail
        }).then(function(result){
            component.set('v.showSpinner',false);
            if(result.EmpInfo != '' && result.EmpInfo != null && result.EmpInfo != undefined){
                var empInfo = JSON.parse(result.EmpInfo);
                if(empInfo.numberOfEmployee == '1'){
                    var profileList = JSON.parse(result.Profile);
                    var roleList = JSON.parse(result.Role);
                    component.set('v.empInfo',empInfo);
                    component.set('v.profileList',profileList); 
                    component.set('v.roleList',roleList); 
                    component.set('v.empName', empInfo.name);
                    component.set('v.email',empInfo.email);
                    component.set('v.compCode',empInfo.compCode);
                    component.set('v.compName',empInfo.compName);
                    component.set('v.title', empInfo.title);
                    component.set('v.SAPEmpNumber',empInfo.SAPEmpNumber);
                    component.set('v.deptName',empInfo.deptName);
                    component.set('v.epId',empInfo.epId);
                    component.set('v.showTable',true);
                    // Start v 1.1 (MYSALES-338)
                    component.set('v.showTable2',false);
                    component.set('v.userCompDetail',false);
					// End v 1.1 (MYSALES-338)
                    component.set('v.userListSize',empInfo.userListSize);
                    component.set('v.lastNameCreateUser',empInfo.name);
                    if(empInfo.userListSize == '1'){
                        if(component.get('v.editMode') == true){
                            component.find("ProfileId").set("v.value",empInfo.profileName);
                            component.find("RoleId").set("v.value",empInfo.roleName);
                        }else{
                            component.set('v.selectedProfile1',empInfo.profileName);
                            component.set('v.selectedRole1',empInfo.roleName);
                        }
                        component.set('v.lastNameUpdateUser',empInfo.lastName);
                        component.set('v.firstNameUpdateUser',empInfo.firstName);
                        component.set('v.isActive1',empInfo.isUserActive);
                        component.set('v.isMFA1',empInfo.isMFA);
                        component.set('v.userId',empInfo.userId);
                      }
                }
                // Start v 1.1 (MYSALES-338)
				else if(empInfo.numberOfEmployee == '2' && empInfo.diffCompCode == 'Y'){
                    var profileList = JSON.parse(result.Profile);
                    var roleList = JSON.parse(result.Role);
                    var companyCodesList = JSON.parse(result.CompanyCodes);
                    component.set('v.companyCodesList',companyCodesList);
                    component.set('v.empInfo',empInfo);
                    component.set('v.profileList',profileList); 
                    component.set('v.roleList',roleList); 
                    component.set('v.empName', empInfo.name);
                    component.set('v.email',empInfo.email);
                    component.set('v.compCode',empInfo.compCode);
                    component.set('v.compName',empInfo.compName);
                    component.set('v.title', empInfo.title);
                    component.set('v.SAPEmpNumber',empInfo.SAPEmpNumber);
                    component.set('v.deptName',empInfo.deptName);
                    component.set('v.epId',empInfo.epId);
                    //---2nd Employee Info Start------
                    component.set('v.empName2', empInfo.name2);
                    component.set('v.email2',empInfo.email2);
                    component.set('v.compCode2',empInfo.compCode2);
                    component.set('v.compName2',empInfo.compName2);
                    component.set('v.title2', empInfo.title2);
                    component.set('v.SAPEmpNumber2',empInfo.SAPEmpNumber2);
                    component.set('v.deptName2',empInfo.deptName2);
                    component.set('v.epId2',empInfo.epId2);                    
                    //---2nd Employee Info End------
                    component.set('v.showTable',true);
                    component.set('v.showTable2',true);
                    component.set('v.userListSize',empInfo.userListSize);
                    component.set('v.lastNameCreateUser',empInfo.name);
                    component.set('v.userCompDetail',true);
                    if(empInfo.userListSize == '1'){
                        if(component.get('v.editMode') == true){
                            component.find("ProfileId").set("v.value",empInfo.profileName);
                            component.find("RoleId").set("v.value",empInfo.roleName);
                        }else{
                            component.set('v.selectedProfile1',empInfo.profileName);
                            component.set('v.selectedRole1',empInfo.roleName);
                        }
                        component.set('v.lastNameUpdateUser',empInfo.lastName);
                        component.set('v.firstNameUpdateUser',empInfo.firstName);
                        component.set('v.isActive1',empInfo.isUserActive);
                        component.set('v.isMFA1',empInfo.isMFA);
                        component.set('v.userId',empInfo.userId);
                        component.set('v.userCompCode',empInfo.userCompCode);
                        component.set('v.userCompName',empInfo.userCompName);   
                      }
                }
				// End v 1.1 (MYSALES-338)     
				// Start v 1.1 (MYSALES-338)  
				// Added condition after &&         
                else if(empInfo.numberOfEmployee == '2' && empInfo.diffCompCode == 'N'){
                // End v 1.1 (MYSALES-338)    
                    self.showMyToast('error', $A.get("$Label.c.More_than_one_employee"));
                	component.set('v.showTable',false);
                    // Start v 1.1 (MYSALES-338)
                    component.set('v.showTable2',false);
                    component.set('v.userCompDetail',false);
                    // End v 1.1 (MYSALES-338)
                }
            }
            else{
                self.showMyToast('error', $A.get("$Label.c.NoEmployeeMsg"));
                component.set('v.showTable',false);
                // Start v 1.1 (MYSALES-338)
                component.set('v.showTable2',false);
                component.set('v.userCompDetail',false);
                // End v 1.1 (MYSALES-338)
            }
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.loading', false);
        });
        
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
        
    showToast : function(type, message){
            console.log('message:' + message);
            var toastEvent = $A.get("e.force:showToast");
            var mode = (type == 'success') ? 'pester' : 'sticky';
            toastEvent.setParams({
                "type" : type,
                "message": message,
                "mode": mode,
                "duration": 5000
            });
            toastEvent.fire();
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
    
    createUserHelper : function(component, event){
        var self = this;
        var selectedProfile = component.get('v.selectedProfile') ;
        var selectedRole = component.get('v.selectedRole') ;
        var firstName = component.get('v.firstNameCreateUser') ;
        var lastName = component.get('v.lastNameCreateUser') ;
        var isActive = component.get('v.isActive');
        var isMFA = component.get('v.isMFA');
        var empInfo = component.get('v.empInfo');
        // Start v 1.1 (MYSALES-338)
        var selectedCompCode = component.get('v.selectedCompCode'); 
        var userCompDetail = component.get('v.userCompDetail');
        var empCompName1 = component.get('v.compName');
        var empCompName2 = component.get('v.compName2');
        var empCompCode1 = component.get('v.compCode');
        var empCompCode2 = component.get('v.compCode2');
        var compName = '';
        var updUsrCompDetFrmEmp = true; // variable to check if User Company details need to be updated from Employee Info in case of single Employee with searched Email. 
        if(userCompDetail == true){
            updUsrCompDetFrmEmp = false;
            if(selectedCompCode == empCompCode1){
                compName = empCompName1;
            }
            if(selectedCompCode == empCompCode2){
                compName = empCompName2;
            } 
        }   
		// End v 1.1 (MYSALES-338)        
        self.apex(component, 'createUserFun', {
            selectedProfile : selectedProfile,
            roleName : selectedRole,
            isActive : isActive,
            isMFA : isMFA,
            empInfo : empInfo,
            firstName : firstName,
            lastName : lastName,
            // Start v 1.1 (MYSALES-338)
            selectedCompCode : selectedCompCode,
            compName : compName,
            updUsrCompDetFrmEmp: updUsrCompDetFrmEmp
            // End v 1.1 (MYSALES-338)
        }).then(function(result){
            component.set('v.showSpinner',false);
            self.showToast('success',$A.get("$Label.c.UserCreateSuccessMsg"));
            component.set('v.editMode',false);
            component.set('v.showButton',false);
            self.getEmployeeResult(component, event);
            self.doInit(component, event);
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner',false);
        });
        

    },
    
    updateUserHelper : function(component, event){
        var profile = component.get('v.selectedProfile1');
        var role = component.get('v.selectedRole1');
        var active = component.get('v.isActive1');
        var mfa = component.get('v.isMFA1');
        var lastName = component.get('v.lastNameUpdateUser');
        var userId = component.get('v.userId');
        var self = this;
        // Start v 1.1 (MYSALES-338)
        var userCompDetail = component.get('v.userCompDetail');
        var compCode = component.get('v.userCompCode');
        var empCompName1 = component.get('v.compName');
        var empCompName2 = component.get('v.compName2');
        var empCompCode1 = component.get('v.compCode');
        var empCompCode2 = component.get('v.compCode2');
        var compName = '';
        var updUsrCompDetFrmEmp = true; // variable to check if User Company details need to be updated from Employee Info in case of single Employee with searched Email.
        var empInfo = component.get('v.empInfo');
        if(userCompDetail == true){
            updUsrCompDetFrmEmp = false;
            if(compCode == empCompCode1){
                compName = empCompName1;
            }
            if(compCode == empCompCode2){
                compName = empCompName2;
            }
        }
        // End v 1.1 (MYSALES-338)
        self.apex(component, 'updateUser', {
            selectedProfile : profile,
            roleName : role,
            isActive : active,
            isMfa : mfa,
            userId : userId,
            firstName : component.get('v.firstNameUpdateUser'),
            lastName : lastName,
            // Start v 1.1 (MYSALES-338)
            compCode : compCode,
            compName : compName,
            updUsrCompDetFrmEmp: updUsrCompDetFrmEmp,
            empInfo : empInfo
            // End v 1.1 (MYSALES-338)
        }).then(function(result){
            component.set('v.showSpinner',false);
            self.showToast('success',$A.get("$Label.c.UserUpdateSuccessMsg"));
            component.set('v.editMode',false);
            if(result == true){
                console.log('MFA Value');
            	component.set('v.isMFA1',false);    
            }
            component.set('v.showButton',false);
            // Start v 1.1 (MYSALES-338)
            self.getEmployeeResult(component, event);
            // End v 1.1 (MYSALES-338)
            self.doInit(component, event);
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner',false);
        });
    },
    
    resetPasswordHelper : function(component, event){
        var userId = component.get('v.userId');
        console.log('user ID **' + userId);
        var self = this;
        self.apex(component, 'resetPswrd', {
            uId : userId
        }).then(function(result){
            console.log('result**');
            self.doInit(component, event);
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner',false);
        });

    }
    
})