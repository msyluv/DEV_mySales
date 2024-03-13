/**
* @author            : akash.g@samsung.com
* @group             :
* @description       : Apex class for UserEmployeeManagementScreen Aura component.
* @last modified on  : 2024-01-30
* @last modified by  : atul.k1@samsung.com
* Modifications Log
* Ver   Date         Author                    Modification
* 1.0   2021-12-01   akash.g@samsung.com       Initial Version
* 1.1   2022-01-06   akash.g@samsung.com       Modified Version
* 1.2	2023-10-27	 sarthak.j1@samsung.com    UserEmployee Management function enhancement -> MYSALES-338
* 1.3	2024-01-30	 atul.k1@samsung.com       Mobile Permission Set Add -> MYSALES-420
**/
global with sharing class UserEmployeeManagementScreenController {
    
    @AuraEnabled
    public static returnLicence getLicenceDetail(){
        UserLicense uL = [select TotalLicenses, UsedLicenses from UserLicense where name = 'Salesforce' Limit 1];
        returnLicence lic = new returnLicence();
        lic.TotalLicence = uL.TotalLicenses.format();
        lic.UsedLicence = uL.UsedLicenses.format();
        lic.RemainedLicence = (uL.TotalLicenses - uL.UsedLicenses).format();
        return lic;    
    }
    
    @AuraEnabled
    public static Map<String, String> getEmployeeResult(String emailValue){
        List<Employee__c> empList = [select name, EvMailAddr__c, EvSapBukrs__c, EvCompNM__c, EvTitleJikChakNM__c,
                                     EvSapEmpNO__c, EvSdeptNM__c, EvUniqID__c,CurrencyIsoCode from Employee__c
                                     where EvMailAddr__c =: emailValue AND (Status__c != 'R' AND Status__c != '퇴사')];         
        Map<String, String> rtnmap = new Map<String,String>();
        returnObject retObj = new returnObject();
        try{
            if(empList.size() == 1){
                // Start v 1.2 (MYSALES-338)
                // Updated User Query with Company Code and Company Name fields
                List<User> userList = [select Id,Profile.name, UserRole.Name,firstName, lastName ,IsActive, CompanyCode__c,CompanyName from user where email =: emailValue];
                // End v 1.2 (MYSALES-338)
                Employee__c emp = empList[0];
                retObj.name = emp.Name;
                retObj.email = emp.EvMailAddr__c;    
                retObj.compCode = emp.EvSapBukrs__c;  
                retObj.compName = emp.EvCompNM__c;  
                retObj.title = emp.EvTitleJikChakNM__c;  
                retObj.SAPEmpNumber = emp.EvSapEmpNO__c;  
                retObj.deptName = emp.EvSdeptNM__c ;  
                retObj.epId = emp.EvUniqID__c;
                if(emp.EvSapBukrs__c == 'T100'){
                    retObj.langLocalKey = 'ko';
                    retObj.currencyISOCode = 'KRW';
                }else{
                    retObj.langLocalKey = 'en_US';
                    retObj.currencyISOCode = 'USD';
                }
                retObj.numberOfEmployee = '1';
                retObj.userListSize = userList.size();
                if(userList.size() == 1){
                    retObj.profileName = userList[0].Profile.name;
                    retObj.roleName = userList[0].UserRole.Name;
                    retObj.firstName = userList[0].firstName;
                    retObj.lastName = userList[0].lastName;
                    retObj.isUserActive = userList[0].IsActive;
                    retObj.userId = userList[0].Id;
                    Integer listSize = checkMFAPermission(userList[0].ID);
                    if(listSize == 1){
                        retObj.isMFA =  true;   
                    }else if(listSize == 0){
                        retObj.isMFA =  false; 
                    }
                    // Start v 1.2 (MYSALES-338)
                    retObj.userCompCode = userList[0].CompanyCode__c;
                    retObj.userCompName = userList[0].CompanyName;
                    // End v 1.2 (MYSALES-338)
                }
                rtnmap.put('EmpInfo',JSON.serialize(retObj));
                List<String> ProfileNameList= getAllProfileNames();
                List<String> RoleNameList= getAllRoleNames();
                rtnMap.put('Profile', JSON.serialize(ProfileNameList));
                rtnMap.put('Role',JSON.serialize(RoleNameList));
                // Start v 1.2 (MYSALES-338)
                //List<String> CompanyCodeList= getCompanyCodes();
                //rtnMap.put('CompanyCodes',JSON.serialize(CompanyCodeList));
                // End v 1.2 (MYSALES-338)
            }
            // Start v 1.2 (MYSALES-338)
            else if(empList.size() > 1 && (empList[0].EvSapBukrs__c != empList[1].EvSapBukrs__c)){
                List<User> userList = [select Id,Profile.name, UserRole.Name,firstName, lastName ,IsActive,CompanyCode__c,CompanyName from user where email =: emailValue];
                Employee__c emp = empList[0];
                retObj.name = emp.Name;
                retObj.email = emp.EvMailAddr__c;    
                retObj.compCode = emp.EvSapBukrs__c;  
                retObj.compName = emp.EvCompNM__c;  
                retObj.title = emp.EvTitleJikChakNM__c;  
                retObj.SAPEmpNumber = emp.EvSapEmpNO__c;  
                retObj.deptName = emp.EvSdeptNM__c ;  
                retObj.epId = emp.EvUniqID__c;
                if(emp.EvSapBukrs__c == 'T100'){
                    retObj.langLocalKey = 'ko';
                    retObj.currencyISOCode = 'KRW';
                }else{
                    retObj.langLocalKey = 'en_US';
                    retObj.currencyISOCode = 'USD';
                }
                retObj.numberOfEmployee = '2';
                retObj.diffCompCode = 'Y';               
                //-----2nd Employee Info Start---------------
                Employee__c emp2 = empList[1];
                retObj.name2 = emp2.Name;
                retObj.email2 = emp2.EvMailAddr__c;    
                retObj.compCode2 = emp2.EvSapBukrs__c;  
                retObj.compName2 = emp2.EvCompNM__c;  
                retObj.title2 = emp2.EvTitleJikChakNM__c;  
                retObj.SAPEmpNumber2 = emp2.EvSapEmpNO__c;  
                retObj.deptName2 = emp2.EvSdeptNM__c ;  
                retObj.epId2 = emp2.EvUniqID__c;
                if(emp.EvSapBukrs__c == 'T100'){
                    retObj.langLocalKey2 = 'ko';
                    retObj.currencyISOCode2 = 'KRW';
                }else{
                    retObj.langLocalKey2 = 'en_US';
                    retObj.currencyISOCode2 = 'USD';
                }             
                //-----2nd Employee Info End---------------
                retObj.userListSize = userList.size();
                if(userList.size() == 1){
                    retObj.profileName = userList[0].Profile.name;
                    retObj.roleName = userList[0].UserRole.Name;
                    retObj.firstName = userList[0].firstName;
                    retObj.lastName = userList[0].lastName;
                    retObj.isUserActive = userList[0].IsActive;
                    retObj.userId = userList[0].Id;
                    Integer listSize = checkMFAPermission(userList[0].ID);
                    if(listSize == 1){
                        retObj.isMFA =  true;   
                    }else if(listSize == 0){
                        retObj.isMFA =  false; 
                    }
                    retObj.userCompCode = userList[0].CompanyCode__c;
                    retObj.userCompName = userList[0].CompanyName;                    
                }
                rtnmap.put('EmpInfo',JSON.serialize(retObj));
                List<String> ProfileNameList= getAllProfileNames();
                List<String> RoleNameList= getAllRoleNames();
                rtnMap.put('Profile', JSON.serialize(ProfileNameList));
                rtnMap.put('Role',JSON.serialize(RoleNameList)); 
                //List<String> CompanyCodeList= getCompanyCodes();
                //rtnMap.put('CompanyCodes',JSON.serialize(CompanyCodeList));
                List<String> CompanyCodeList = new List<String>();
                if(empList[0].EvSapBukrs__c != null)
                {
                    CompanyCodeList.add(empList[0].EvSapBukrs__c);
                }
                if(empList[1].EvSapBukrs__c != null)
                {
                    CompanyCodeList.add(empList[1].EvSapBukrs__c);
                }
                rtnMap.put('CompanyCodes',JSON.serialize(CompanyCodeList));
            }
            // End v 1.2 (MYSALES-338)
            // Start v 1.2 (MYSALES-338)
            // Added condition after '&&'
            else if(empList.size() > 1 && (empList[0].EvSapBukrs__c == empList[1].EvSapBukrs__c)){
                // End v 1.2 (MYSALES-338)
                retObj.numberOfEmployee = '2';
                // Start v 1.2 (MYSALES-338)
                retObj.diffCompCode = 'N';
                // End v 1.2 (MYSALES-338)
                rtnmap.put('EmpInfo',JSON.serialize(retObj));
            }
        }catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getLineNumber()+':'+e.getMessage());
            
        }
        return rtnMap;
    }
    
    private static List<String> getAllProfileNames(){
        //V1.1 : Fix for profiles list : Add filter UserLicense.Name = 'Salesforce' in below query .
        List<Profile> profileList = new List<Profile>();
        List<String> profileNameList = new List<String>();
        
        String currentUserProflieName = [SELECT Id, Name FROM Profile WHERE Id=:userinfo.getProfileId() LIMIT 1].Name;
        system.debug('currentUserProflieName >> ' + currentUserProflieName);
        
        if(currentUserProflieName == 'Service Desk Agency'){
            profileList = [Select name from Profile where UserLicense.Name = 'Salesforce' And 
                           (name != 'System Administrator' AND name != '시스템 관리자' AND name != 'Custom System Administrator'
                            AND name != 'End User' AND name != 'Executive Sponsor' AND name != 'FileCheck' AND name != 'Interface Admin' 
                            AND name != 'Minimum Access - Salesforce' AND name != 'Read Only' AND name != 'Service Agent' AND name != 'Service Desk Agency' 
                            AND name != 'Service Supervisor' AND name != 'Contract Manager' AND name != '계약 관리자' 
                            AND name != 'Marketing User' AND name != '마케팅 사용자' AND name != '솔루션 관리자' AND name != 'Solution Manager' 
                            AND name != '표준 사용자' AND name != 'Standard User') order by name];
        }else{
            profileList = [Select name from Profile where UserLicense.Name = 'Salesforce' order by name];
        }
        for(Profile pro: profileList){
            profileNameList.add(pro.name);
        }
        system.debug('profileNameList >>' + profileNameList);
        return profileNameList;
    }
    
    private static List<String> getAllRoleNames(){
        List<UserRole> roleList = [Select Name from UserRole order by Name];
        List<String> roleNameList = new List<String>();
        for(UserRole role: roleList){
            roleNameList.add(role.Name);
        }
        return roleNameList;
        
    }
    @AuraEnabled
    // Start v 1.2 (MYSALES-338)
    // Updating function with company code, compName, updUsrCompDetFrmEmp parameters
    public static Id createUserFun(String selectedProfile, String roleName , Boolean isActive ,Boolean isMFA ,returnObject empInfo , String firstName, String lastName, String selectedCompCode, String compName, Boolean updUsrCompDetFrmEmp){
    //End v 1.2 (MYSALES-338)    
        Id profileId = [Select id from profile where name =: selectedProfile][0].Id;
        Id roleId = [Select id from UserRole where Name =: roleName][0].Id;
        Boolean IsSandbox = [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1].IsSandbox;
        List<User> userNameList = new List<User>();
        if(!IsSandbox){
            userNameList =  [Select id from user where userName =: empInfo.email Limit 1];
        }
        try{
            User user = new user();
            user.lastname = lastName;
            user.FirstName = firstName;
            user.email = empInfo.email;
            // Start v 1.2 (MYSALES-338)
            if(updUsrCompDetFrmEmp == true){
                user.CompanyCode__c = empInfo.compCode;
                user.CompanyName = empInfo.compName;
            }
            else{
                if(updUsrCompDetFrmEmp == false){
                    user.CompanyCode__c = selectedCompCode;
                    user.CompanyName = compName;
                }
            }
            // End v 1.2 (MYSALES-338)
            user.Title = empInfo.title;
            user.EmployeeNumber = empInfo.SAPEmpNumber;
            user.Department = empInfo.deptName;
            user.FederationIdentifier = empInfo.epId;
            if(IsSandbox){
                user.Username = empInfo.email + '.sds.qa';
            }else{
                if(userNameList.size() == 1){
                    user.Username = empInfo.email + '.sds';
                }else{
                    user.Username = empInfo.email;
                }
            }
            user.IsActive = isActive;
            user.UserRoleId = roleId;
            user.ProfileId = profileId;
            user.CurrencyIsoCode = empInfo.currencyISOCode;
            user.DefaultCurrencyIsoCode  = empInfo.currencyISOCode;
            user.LanguageLocaleKey = empInfo.langLocalKey;
            user.LocaleSidKey = 'ko';
            user.TimeZoneSidKey = 'Asia/Seoul';
            user.EmailEncodingKey = 'UTF-8';
            if(empInfo.name.length() >=4){
                user.Alias = empInfo.name.substring(0, 4);  
            }else{
                user.Alias = empInfo.name;
            }
            insert user;
            if(user.IsActive && isMFA){
                MFAPermissionSetUserUpdate(user.Id,'Insert');    
            }
            //MySales-420 V 1.3
            if(user.IsActive){
               MobileSecurityPermissionSetUserUpdate(user.Id,'Insert'); 
            }
            //MySales-420 V 1.3
            return user.Id;
        }catch(Exception e){
            throw new AuraHandledException('Error Exception happend'+e.getMessage());
        }
    }
    private static void MFAPermissionSetUserUpdate(Id userID, String Type){
        system.debug('userID **' + userID);
        if(Type == 'Insert'){
            List<PermissionSet> MFAPermissionSetList = [select id from PermissionSet where name = 'MFA'];
            ID MFAPermissionSetID;
            if(MFAPermissionSetList.size() == 1){
                MFAPermissionSetID = MFAPermissionSetList[0].Id;
                system.debug('MFAPermissionSetID **' + MFAPermissionSetID);
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = MFAPermissionSetID, AssigneeId = userID);
                if(psa != null){
                    insert psa; 
                    sendingEmail(userID);
                }
            }
            
        }else if(Type == 'Remove'){
            PermissionSetAssignment PSetAssign = [Select id from PermissionSetAssignment where 
                                                  AssigneeId =: userID AND permissionset.name = 'MFA'];
            Delete PSetAssign;
        }
        
    }
    //MySales-420 V 1.3 start
     private static void MobileSecurityPermissionSetUserUpdate(Id userID, String Type){
        system.debug('userID **' + userID);
        if(Type == 'Insert'){
            List<PermissionSet> MobileSecurityPermissionSetList = [select id from PermissionSet where name = 'Mobile_Security'];
            ID MobileSecurityPermissionSetID;
            if(MobileSecurityPermissionSetList.size() == 1){
                MobileSecurityPermissionSetID = MobileSecurityPermissionSetList[0].Id;
                system.debug('MobileSecurityPermissionSetID **' + MobileSecurityPermissionSetID);
                PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = MobileSecurityPermissionSetID, AssigneeId = userID);
                if(psa != null){
                    insert psa; 
                    //sendingEmail(userID);
                }
            }
            
        }else if(Type == 'Remove'){
            PermissionSetAssignment PSetAssign = [Select id from PermissionSetAssignment where 
                                                  AssigneeId =: userID AND permissionset.name = 'Mobile_Security'];
            Delete PSetAssign;
        }
        
    }
    private static Integer checkMobile_SecurityPermission(ID userID){
        List<PermissionSetAssignment> Mobile_SecurityPSetAssignList = [Select id from PermissionSetAssignment where 
                                                        AssigneeId =: userID AND permissionset.name = 'Mobile_Security'];
        system.debug('Atul' + Mobile_SecurityPSetAssignList.size());
        return Mobile_SecurityPSetAssignList.size();
    }
    //MySales-420 V 1.3 End
    private static Integer checkMFAPermission(ID userID){
        List<PermissionSetAssignment> PSetAssignList = [Select id from PermissionSetAssignment where 
                                                        AssigneeId =: userID AND permissionset.name = 'MFA'];
        system.debug('Akash3' + PSetAssignList.size());
        return PSetAssignList.size();
    }
    @AuraEnabled
    // Start v 1.2 (MYSALES-338)
    // Added 'compCode', 'compName', 'updUsrCompDetFrmEmp', 'empInfo' parameters in method
    public static Boolean updateUser(String selectedProfile, String roleName , Boolean isActive, Boolean isMfa , String userId , String firstName , String lastName, String compCode, String compName, Boolean updUsrCompDetFrmEmp, returnObject empInfo){
    // End v 1.2 (MYSALES-338)   
        try{
            Boolean MFACheckBox = false;
            // Start v 1.2 (MYSALES-338)
            // modifying User query with CompanyCode__c and CompanyName fields
            User u = [Select id,isActive,CompanyCode__c,CompanyName from user where id =: userId Limit 1];
            // End v 1.2 (MYSALES-338)
            u.ProfileId = [select id from Profile where Name =: selectedProfile].Id;
            system.debug('roleName**' + roleName);
            List<UserRole> role = [select id from UserRole where Name =: roleName];
            if(role.size() > 0){
                u.UserRoleId = role[0].ID;
            }
            // Start v 1.2 (MYSALES-338)
     		if(updUsrCompDetFrmEmp == true){
                u.CompanyCode__c = empInfo.compCode;
                u.CompanyName = empInfo.compName;
            }
            else{
                if(updUsrCompDetFrmEmp == false){
                    u.CompanyCode__c = compCode;
                    u.CompanyName = compName;
                }
            }
            // End v 1.2 (MYSALES-338)
            u.IsActive = isActive;
            u.FirstName = firstName;
            u.LastName = lastName;
            update u;
            if(isMfa && u.IsActive == true){
                Integer listSize = checkMFAPermission(u.ID);
                if(listSize == 0){
                    MFAPermissionSetUserUpdate(u.Id,'Insert');  
                }
            }else if(!isMfa){
                Integer listSize = checkMFAPermission(u.ID);
                if(listSize == 1){
                    MFAPermissionSetUserUpdate(u.Id,'Remove'); 
                }
            }else if(isMfa && u.IsActive == false){
                MFACheckBox = true;
                Integer listSize = checkMFAPermission(u.ID);
                if(listSize == 1){
                    MFAPermissionSetUserUpdate(u.Id,'Remove'); 
                }
            }
            //MYSALES-420 V1.3 Start
            if(u.IsActive == true){
                Integer listSize = checkMobile_SecurityPermission(u.ID);
                if(listSize == 0){
                    MobileSecurityPermissionSetUserUpdate(u.Id,'Insert');
                }
                
            }
            else if(u.IsActive == false){
                Integer listSize = checkMobile_SecurityPermission(u.ID);
                if(listSize == 1){
                    MobileSecurityPermissionSetUserUpdate(u.Id,'Remove');
                }
                
            }
            
            //MYSALES-420 V1.3 End
            return MFACheckBox;
        }
        catch(Exception e){
            throw new AuraHandledException('Error Exception happend test'+e.getMessage());
        }
    }
    @AuraEnabled
    public static void resetPswrd(String uId){
        system.debug('user ID **' + uId);
        if(uId != null){
            System.resetPassword(uId, true);  
        }
    }
    @future
    private static void sendingEmail(Id userID)
    {
        ID ToID = [Select id,email from user where ID =: userID LIMIT 1].ID;
        ID TempID = [Select id from EmailTemplate where DeveloperName = 'MFA_Template' LIMIT 1].ID;
        ID fromAddressID = [SELECT Id FROM OrgWideEmailAddress where displayName = 'mysales@samsung.com' LIMIT 1].ID;
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        if(ToID != null && TempID != null){
            semail.setTargetObjectId(ToID);
            semail.setSaveAsActivity(false);
            semail.setTemplateId(TempID);
            if(fromAddressID != null){
            	semail.setOrgWideEmailAddressId(fromAddressID);     
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{semail});
         }
    } 
    global class returnObject {
        @AuraEnabled
        global String name {get; set;}
        @AuraEnabled
        global String email {get; set;}
        @AuraEnabled
        global String compCode {get; set;}
        @AuraEnabled
        global String compName {get; set;}
        @AuraEnabled
        global String title {get; set;}
        @AuraEnabled
        global String SAPEmpNumber {get; set;}
        @AuraEnabled
        global String deptName {get; set;}
        @AuraEnabled
        global String epId {get; set;}
        @AuraEnabled
        global String currencyISOCode {get; set;}
        @AuraEnabled
        global String langLocalKey {get; set;}
        @AuraEnabled
        global Integer userListSize {get; set;}
        @AuraEnabled
        global String profileName {get; set;}
        @AuraEnabled
        global String roleName {get; set;}
        @AuraEnabled
        global String firstName {get; set;}
        @AuraEnabled
        global String lastName {get; set;}
        @AuraEnabled
        global Boolean isUserActive {get; set;}
        @AuraEnabled
        global String userId {get; set;}
        @AuraEnabled
        global String numberOfEmployee {get; set;}
        @AuraEnabled
        global Boolean isMFA {get; set;}
        // Start v 1.2 (MYSALES-338)
        @AuraEnabled
        global String name2 {get; set;}
        @AuraEnabled
        global String email2 {get; set;}
        @AuraEnabled
        global String compCode2 {get; set;}
        @AuraEnabled
        global String compName2 {get; set;}
        @AuraEnabled
        global String title2 {get; set;}
        @AuraEnabled
        global String SAPEmpNumber2 {get; set;}
        @AuraEnabled
        global String deptName2 {get; set;}
        @AuraEnabled
        global String epId2 {get; set;}
        @AuraEnabled
        global String currencyISOCode2 {get; set;}
        @AuraEnabled
        global String langLocalKey2 {get; set;}
        @AuraEnabled
        global String diffCompCode {get; set;}
        @AuraEnabled
        global String userCompCode {get; set;}
        @AuraEnabled
        global String userCompName {get; set;}
        // End v 1.2 (MYSALES-338)
    }
    global class returnLicence{
        @AuraEnabled
        global String TotalLicence {get; set;}
        @AuraEnabled
        global String UsedLicence {get; set;}
        @AuraEnabled
        global String RemainedLicence {get; set;}
    }
}