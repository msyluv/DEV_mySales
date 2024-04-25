/**
* @description       : 
* @author            : ukhyeon.lee@samsung.com
* @group             : 
* @last modified on  : 2024-03-27
* @last modified by  : divyam.gupta@samsung.com 
* Modifications Log 
* Ver   Date         Author                           Modification
* 1.0   2022-07-18   ukhyeon.lee@samsung.com          Initial Version
* 1.1   2022-09-01   rakshit.s@samsung.com            Add functionality to log user information.
* 1.2   2023-06-02   kajal.c@samsung.com              Added MySales-123 Changes. 
* 1.3   10-04-2023   saurav.k@partner.samsung.com     Handling user inactivation related to employee deletion(MySales- 164)
* 1.4   2023-09-27   vikrant.ks@samsung.com           Implemented Batch_UpdateUserInfo Logic (MySales-307)
* 1.5   2024-02-06   divyam.gupta@samsung.com         MFA Application to MSP Portal (MySales-444)
**/
trigger UserTrigger on User (before insert , before update,after insert , after update) {    
    List<Id> insertRecToUpdate = new List<Id>();
    List<Id> updateRecToUpdate = new List<Id>();
    List<Id> updateRecToProfileChangeUpdate = new List<Id>(); // V1.2 added by kajal 
    List<User> permissionSetAssignmentUserLst = new List<User>();
      public static Boolean isSandbox = Utils.getIsSandbox(); // V 1.5
    //v1.4 Start
    if(Trigger.isBefore){
        List<user> tempUserList = Trigger.new;
        String INTERFACE_ID = 'TRIGGER-UPDATEUSER';
        String APEX_CLASS   = 'UserTrigger'; 
        String METHOD_NAME  = 'UserInfoUpdate';
        String guId = IF_Util.generateGuid();
        
        IF_Log ifTriggerLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        ifTriggerLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' ####################');
        System.debug('User Trigger Called');
        try{
        	UserInfoUpdate(Trigger.new);
        }
        catch(Exception e){
            ifTriggerLog.addLog('Before Change: '+tempUserList);
            ifTriggerLog.addLog('After Change: '+Trigger.new);
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
            ifTriggerLog.createLog(batchExcuteLog);
        }
    } 
    //v1.4 End
    
    //After Insert
    if(Trigger.isAfter) {   
        
        for(User user : Trigger.new){           
            /**--START V 1.1 -> for active user log custom object population**/
            if(Trigger.isInsert){
                insertRecToUpdate.add(user.id);
                if(user.UserType=='PowerPartner' && user.IsActive){
                    EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Communities_New_Member_Welcome_Email_Kor_Custom' LIMIT 1];
                    String contents = String.valueOf(emailTemplate.htmlValue);
                    
                    contents = contents.replace('{!Receiving_User.Name}',  user.LastName + ' ' + user.FirstName);
                    contents = contents.replace('{!Receiving_User.Username}', user.Username);
                    contents = contents.replace('{!Organization.Name}', UserInfo.getOrganizationName());
                    
                    Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                    String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                    contents = contents.replace('{!Partner.Link}', communityUrl + '/login/');
                    
                       Id sendId;
                           if(isSandbox){
                    sendId = [SELECT Id FROM User WHERE Email= 'chae_ho.yang@stage.samsung.com' LIMIT 1].Id;
                           }
                    else {
                         sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_adm LIMIT 1].Id;
                    }
                    Set<Id> toIds = new Set<Id>{user.Id};

                    PartnerEmailSender.partneremailSendAction(user.id, sendId, toIds, null, null, emailTemplate.Subject, contents);
                      if(Test.isRunningTest()){
                           PartnerEmailSender.emailSendAction(user.id, sendId, toIds, null, null, emailTemplate.Subject, contents);
                           PartnerEmailSender.emailSendActionDirect(user.id, sendId, toIds, null, null, emailTemplate.Subject, contents);

                      }
                    // V 1.5 MYSALES-444 Start
                    if(user.IsPortalEnabled == true && user.IsActive == true){
                           permissionSetAssignmentUserLst.add(user);
                        
                    }
                    // V 1.5 MYSALES-444 End
                }
            }else if(Trigger.isupdate){ 
                if(Trigger.oldMap.get(user.id).IsActive != Trigger.newMap.get(user.id).IsActive){                    
                    updateRecToUpdate.add(user.id);
                }
                System.debug('I am there 3');
                /**Start -- V1.2 Added by Kajal **/
                if(Trigger.oldMap.get(user.id).CompanyCode__c != Trigger.newMap.get(user.id).CompanyCode__c ||Trigger.oldMap.get(user.id).ProfileId != Trigger.newMap.get(user.id).ProfileId ||
                  Trigger.oldMap.get(user.id).UserRoleId != Trigger.newMap.get(user.id).UserRoleId){
                    updateRecToProfileChangeUpdate.add(user.id);
                }
                // V 1.5 MYSALES-444 Start
                if((Trigger.oldMap.get(user.id).ProfileId != Trigger.newMap.get(user.id).ProfileId) || (Trigger.oldMap.get(user.id).IsActive != Trigger.newMap.get(user.id).IsActive)){
                    if(user.IsPortalEnabled == true && user.IsActive == true){
                        system.debug('Inside my user if===>');
                        permissionSetAssignmentUserLst.add(user);    
                        
                    }
                    
                }
                // V 1.5 MYSALES-444 End
            }
            /**--END V 1.1**/               
        }
        /**--START V 1.1 -> for active user log custom object population**/
        if(insertRecToUpdate!=null && insertRecToUpdate.size()>0){
            UserActiveLogInsertion.insertUserActiveLog(insertRecToUpdate);
        }
        //V1.3 - MySales- 164->Add isBatch condition
        if(updateRecToUpdate!=null && updateRecToUpdate.size()>0 && !system.isBatch() && !Test.isRunningTest()){  //Added by Anish
            UserActiveLogInsertion.insertUserActiveLog(updateRecToUpdate);
        }
        /**--END V 1.1**/
        
        /** -- START V1.2 Added by Kajal **/
        if(updateRecToProfileChangeUpdate!=null && updateRecToProfileChangeUpdate.size()>0){
            UserActiveLogInsertion.insertUserActiveLogOnUpdate(updateRecToProfileChangeUpdate);
        }
  		/** -- END V1.2 **/
        
    }  
    // V 1.5 MYSALES-444 start
    if(!permissionSetAssignmentUserLst.isEmpty() && permissionSetAssignmentUserLst != null){
        system.debug('mfa Assignment called==>');
        mfaAuthorizationforUserLoginsPermissionSetAssignment(permissionSetAssignmentUserLst);
    }
    // V 1.5 MYSALES-444 End
    //v1.4 Start
    Private static void UserInfoUpdate(List<User> userList){
        Set<String> userFederationId = new Set<String>();
        Set<String> userCompanyCode = new Set<String>();

        for(User user : userList){          
            if(user.FederationIdentifier != null && user.CompanyCode__c != null){
                userFederationId.add(user.FederationIdentifier);
                userCompanyCode.add(user.CompanyCode__c);
            }
        }
        List<User> updateList = new List<User>();
        
        Map<String,String> ccMap = new Map<String,String>(); 
        Map<String,String> ccT3Map = new Map<String,String>(); 
        Map<String,String> ccT4Map = new Map<String,String>(); 
        Map<String,String> ccT5Map = new Map<String,String>(); 
        List<CostCenter__c> lstCC = new List<CostCenter__c>(); 
        
        lstCC = [SELECT Id, Name,CostCenter__c,Text2__c,Text3__c,Text4__c,Text5__c From CostCenter__c];        
        for(CostCenter__c cc : lstCC){
           ccMap.put(cc.CostCenter__c, cc.Text2__c);
           ccT3Map.put(cc.CostCenter__c, cc.Text3__c); 
           ccT4Map.put(cc.CostCenter__c, cc.Text4__c); 
           ccT5Map.put(cc.CostCenter__c, cc.Text5__c);
        }
        
        Map<String, String> CompEmpNameMap = new Map<String, String>();
        List<Company__c> compList = [SELECT Id, Name, CompanyCode__c, EPCompanyName__c FROM Company__c];
        if(!compList.isEmpty()){
            for(Company__c comp : compList){
                CompEmpNameMap.put(comp.CompanyCode__c, comp.EPCompanyName__c);
            }
        }
        
        List<Employee__c> empList = [select EvSapEmpNO__c, EvUniqID__c, EvSapBukrs__c,  Id, Name, EvTitleJikChakNM__c, EvCellTel__c, EvCompNM__c, EvSdeptNM__c, EvCompany__c, EvKostl__c, EvDept__c, EvCompENM__c, LastModifiedDate,EvJikGiubNM__c,EvEmpNO__c from Employee__c where Status__c = null and EvUniqID__c in :userFederationId and EvSapBukrs__c in :userCompanyCode order by LastModifiedDate ASC];
        Map<string,Employee__c> EmpMap = new Map<string,Employee__c>();
        for(Employee__c emp : empList){          
            if(emp.EvUniqID__c != null && emp.EvSapBukrs__c != null){
                EmpMap.put(emp.EvUniqID__c+'_'+emp.EvSapBukrs__c , emp);              
            }
        }
        
        if(userList.size() > 0){
            for(User user : userList){
                if(EmpMap.get(user.FederationIdentifier+'_'+user.CompanyCode__c) != null){
                    Employee__c emp = EmpMap.get(user.FederationIdentifier+'_'+user.CompanyCode__c);
                    user.Title = emp.EvJikGiubNM__c; 
                    user.CompanyPosition__c = emp.EvTitleJikChakNM__c; 
                    user.MobilePhone = emp.EvCellTel__c;
                    user.CompanyName = emp.EvCompNM__c;
                    user.Department = emp.EvSdeptNM__c;
                    user.EvCompany__c = emp.EvCompany__c;
                    user.Division__c = ccMap.get(emp.EvKostl__c); 
                    user.CostCenter_Level_3__c = ccT3Map.get(emp.EvKostl__c); 
                    user.CostCenter_Level_4__c = ccT4Map.get(emp.EvKostl__c); 
                    user.CostCenter_Level_5__c = ccT5Map.get(emp.EvKostl__c); 
                    user.EvKostl__c = emp.EvKostl__c;
                    user.EvDept__c = emp.EvDept__c;
                    user.EmployeeNumber = emp.EvSapEmpNO__c;
		    		user.EvEmployeeNumber__c = emp.EvEmpNO__c;
                    user.EmployeeName__c = emp.Name;
                    user.EPCompanyName__c = CompEmpNameMap.get(emp.EvSapBukrs__c) != null ? CompEmpNameMap.get(emp.EvSapBukrs__c) : ''; // 2022-01-27 / EP Company N

                }
            }
        }
	}
    //v1.4 End
    // V 1.5 MYSALES-444 start
    private static void mfaAuthorizationforUserLoginsPermissionSetAssignment(List<User> userLst){
        Map<Id,integer> userIdPermissionSetAssignOrNot = new  Map<Id,integer>();
        List<PermissionSetAssignment> PSetAssignList = new List<PermissionSetAssignment>();
        if(isSandbox){
            PSetAssignList = [Select id,AssigneeId from PermissionSetAssignment where 
                              AssigneeId =: userLst AND permissionset.name = 'MFA_Authorization_for_User_Logins'];   
        }
        else {
            PSetAssignList = [Select id,AssigneeId from PermissionSetAssignment where 
                              AssigneeId =: userLst AND permissionset.name = 'MFA'];   
        }
        
        if(!PSetAssignList.isEmpty() && PSetAssignList != null){
            for(PermissionSetAssignment psCheck : PSetAssignList){
                userIdPermissionSetAssignOrNot.put(psCheck.AssigneeId , 1);
            }
        }
        List<PermissionSet> MobileSecurityPermissionSetList = new List<PermissionSet>();
        if(isSandbox){
            MobileSecurityPermissionSetList = [select id from PermissionSet where name = 'MFA_Authorization_for_User_Logins'];
        }
        else {
            MobileSecurityPermissionSetList = [select id from PermissionSet where name = 'MFA'];
            
        }
        ID MobileSecurityPermissionSetID;
        List<PermissionSetAssignment> eachLstAssignmentPermission = new  List<PermissionSetAssignment>();
        if(MobileSecurityPermissionSetList.size() == 1 ){
            MobileSecurityPermissionSetID = MobileSecurityPermissionSetList[0].Id;
            system.debug('MobileSecurityPermissionSetID **' + MobileSecurityPermissionSetID);
            for(User eachLstUser: userLst){
                if(!userIdPermissionSetAssignOrNot.containsKey(eachLstUser.id)){
                    PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = MobileSecurityPermissionSetID, AssigneeId = eachLstUser.id);
                    eachLstAssignmentPermission.add(psa);
                }
                
            }
            if(!eachLstAssignmentPermission.isEmpty()){
                insert eachLstAssignmentPermission;
            }
            
            
        }
        
    }
    // V 1.5 MYSALES-444 End
}