/**
* @description       : This class is used for partner enrollment requests coming form the guest user.
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 07-28-2022
* @last modified by  : ukhyeon.lee@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   02-01-2022   rakshit.s@samsung.com   Initial Version
**/
public without sharing class PartnerEnrollmentRequestFormController {
    
    @AuraEnabled(cacheable = true)
    public static TnCData getData(){
        TnCData tN= new TnCData();
        List<Partner_T_C_Master__c> tnCList = new List<Partner_T_C_Master__c>();
        tnCList = [select id, T_C_Detail__c , T_C_Type__c, T_C_Use__c from Partner_T_C_Master__c where isActive__c =true and T_C_Use__c = 'Enrollment'];
        
        for(Partner_T_C_Master__c pT : tnCList){
            if(pT.T_C_Type__c == 'Collection and Use of Personal Information'){
                tN.collectPersonalInfo = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            
            else if(pT.T_C_Type__c == 'Cross-border Transfer of Personal Information'){
                tN.crossBorderTransfer = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            
            else if(pT.T_C_Type__c == 'Terms of Service'){
                tN.termsOfService = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            else if(pT.T_C_Type__c == 'Fourteen years'){
                tN.fourteenYearsOld = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
        }
        return tN;
    }
    
    @AuraEnabled
    public static emailValidity isDuplicate(String UserID , String emailEnteredVal , boolean isEditContext){
        system.debug('valuess->>' + UserID + 'String' + emailEnteredVal);
        
        
        boolean userAlreadyPresent = false;
        emailValidity eVwrap = new emailValidity();
        if(isEditContext){
            eVwrap.userAlreadyPresent = false;
            eVwrap.duplicateEntity = 'AVAILABLE';
        }
        else{
            
            
            if(String.isNotBlank(UserID)){
                List<user> u = new List<user>();
                u = [select id, username from user where username=: UserId and isActive=true];            
                if( (u!=null && u.size()>0 ) || test.isRunningTest()){
                    eVwrap.userAlreadyPresent = true;
                    eVwrap.duplicateEntity = 'USER ';
                }
                
                List<Partner_Enrollment_Request__c> sList   = new list<Partner_Enrollment_Request__c>();
                sList = [SELECT Id,Status__c FROM Partner_Enrollment_Request__c  WHERE Partner_ID__c = :UserId OR Work_Email__c = :emailEnteredVal ];
                
                if( (sList!=null && sList.size()>0 ) || test.isRunningTest()){
                    eVwrap.userAlreadyPresent = true;
                    eVwrap.duplicateEntity = 'PER';
                }
                
                else{
                    eVwrap.userAlreadyPresent = false;
                    eVwrap.duplicateEntity = 'AVAILABLE';
                }
                
            }
        }
        return eVwrap;
        
    }
    
    @AuraEnabled()
    public static insertedInfo createPerRec(String partnerId , String pType, String sub,String emailEntered, String phone,String description,string fname, string lname, string website,string fax, string cName, string cphone, boolean isEditContext){
        
        
        insertedInfo iFrec = new insertedInfo();
        Partner_Enrollment_Request__c pN = new Partner_Enrollment_Request__c();
        IF(!isEditContext){
            pN.status__c = 'Submitted';
            pN.Submitted_Date__c = date.today();
            pN.Partner_Type__c = pType;
            pN.Subject__c = sub;
            pN.Company_Fax__c = fax;
            pn.Company_Name__c = cName;
            pN.Mobile_Phone__c = phone;
            pn.Company_Phone__c = cphone;
            pn.Company_Website__c = website;
            pn.Description__c = description;
            pn.Work_Email__c = emailEntered;
            pn.First_Name__c = fname;
            pn.Last_Name__c = lname;
            pn.Partner_ID__c = partnerId;
            
            INSERT pN;

            Partner_Enrollment_Request__c per = [SELECT Id, Name, Work_Email__c, OwnerId FROM Partner_Enrollment_Request__c WHERE Id=:pN.Id LIMIT 1];
            sendMailToAdmin(per);
            sendMailToUser(per.Id);
        }
        
        else{
            Partner_Enrollment_Request__c reqToUpdate = new Partner_Enrollment_Request__c();
            
            reqToUpdate = [Select id,Submitted_Date__c,Partner_Type__c,Subject__c,Company_Fax__c,Company_Name__c, Mobile_Phone__c,Company_Phone__c,Company_Website__c,Description__c,Work_Email__c,First_Name__c,Last_Name__c,Partner_ID__c from Partner_Enrollment_Request__c where Work_Email__c =: emailEntered];
            
            If(reqToUpdate!=null){
                
                reqToUpdate.Partner_Type__c = pType;
                reqToUpdate.Subject__c = sub;
                reqToUpdate.Company_Fax__c = fax;
                reqToUpdate.Company_Name__c = cName;
                reqToUpdate.Mobile_Phone__c = phone;
                reqToUpdate.Company_Phone__c = cphone;
                reqToUpdate.Company_Website__c = website;
                reqToUpdate.Description__c = description;
                reqToUpdate.Work_Email__c = emailEntered;
                reqToUpdate.First_Name__c = fname;
                reqToUpdate.Last_Name__c = lname;
                
                update reqToUpdate;
                
            }
        }
        
        if(pN!=null) iFrec.insertedid = pN.id;
        
        
        //        iFrec.insertedNumber = insertedRec.Name;
        system.debug('name-->' + iFrec);
        return iFrec;
        
        
    }
    
    
    @AuraEnabled
    public static string createRelatedTnCRec(String perecId , List<String> tnCList){
        List<Partner_Enrollment_T_C_Agreement__c> pEtc = new List<Partner_Enrollment_T_C_Agreement__c>();
        
        
        for(String tncidVal: tncList){
            Partner_Enrollment_T_C_Agreement__c pE = new Partner_Enrollment_T_C_Agreement__c();
            pE.isAgree__c = true;
            pE.Partner_Enrollment__c = perecId.replaceAll('"', '');
            pE.Agreement_Date__c = Date.today();
            pE.Partner_T_C_Name__c = tncidVal.replaceAll('"', '');
            pEtc.add(pE);
        }
        
        
        insert pEtc;
        
        Partner_Enrollment_Request__c insertedRec = new Partner_Enrollment_Request__c();
        insertedRec = [Select id,Name from Partner_Enrollment_Request__c where Id=: perecId limit 1];
        
        return insertedRec.name;
    }
    
    @AuraEnabled
    public static void sendMailToAdmin(Partner_Enrollment_Request__c pN)
    {
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Enrollment_Request_Admin' LIMIT 1];
        String contents = String.valueOf(emailTemplate.htmlValue);
        
        if(Utils.getIsSandbox()){
            contents = contents.replace('{!url}', 'https://sdssfa--qa.lightning.force.com/lightning/o/Partner_Enrollment_Request__c/list?filterName=all');
        } else{
            contents = contents.replace('{!url}', 'https://sdssfa.lightning.force.com/lightning/o/Partner_Enrollment_Request__c/list?filterName=all');
        }
                
        Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_adm LIMIT 1].Id;
        Id toId1 = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_sds LIMIT 1].Id;
        Id toId2 = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_adm LIMIT 1].Id;
        Set<Id> toIds = new Set<Id>{toId1,toId2};
                
        PartnerEmailSender.emailSendAction(pN.id, sendId, toIds, null, null, emailTemplate.Subject, contents);
    }

    @AuraEnabled
    @future (callout=true)
    public static void sendMailToUser(Id pNId)
    {     
        Partner_Enrollment_Request__c pN = [SELECT Id, Name, Work_Email__c, OwnerId FROM Partner_Enrollment_Request__c WHERE Id=:pNId LIMIT 1];
        EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Enrollment_Request_User' LIMIT 1];
        String contents = String.valueOf(emailTemplate.htmlValue);
        
        contents = contents.replace('{!requestNo}', pN.Name);
        Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        contents = contents.replace('{!url}', communityUrl + '/partner-enrollment-request-status?language=ko');
         
        String toAddrs='';
        String ccAddrs='';    
        String bccAddrs='';  
        //Sender
        User sendUser = [SELECT Id, Email FROM User WHERE Email =:System.Label.partner_email_sds LIMIT 1];
    
        //RecipientsList
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        //1. To 
        recipientsList.add(new IF_KnoxEmailSendController.Recipients(pN.Work_Email__c, 'TO'));
        toAddrs+=pN.Work_Email__c+',';
        
        
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(sendUser.Email.split('@')[0], sendUser.Email);      
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
        bodyMap.subject = emailTemplate.Subject;
        bodyMap.contents = contents;
        bodyMap.contentType = 'HTML';
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = pN.Id;
        bodyMap.recipients = recipientsList;
        bodyMap.sender = sender;
        bodyMap.isMulti = true;        
        
        system.debug('subject : ' + bodyMap.subject);
        system.debug('contents : ' + bodyMap.contents);
        system.debug('sfdcId : ' + bodyMap.sfdcId);
        system.debug('sender : ' + sender);
        system.debug('isMulti : ' + bodyMap.isMulti);
        system.debug(toAddrs);
        system.debug(ccAddrs);
        system.debug(bccAddrs);
        
        Map<String,Object> response = new Map<String, Object>();
        try{
            response = IF_KnoxEmailSendController.send(bodyMap);
            if(Integer.valueof(response.get('StatusCode'))==200){
                KnoxEmail__c knoxemail = new KnoxEmail__c(RecordId__c = pn.Id, ToAddress__c = toAddrs.removeEnd(','), BccAddress__c = bccAddrs.removeEnd(','), Name = emailTemplate.Subject, HtmlBody__c = contents, Status__c = 'Send');                
                insert knoxemail;
                system.debug('Send true');
            }  else{
                system.debug('Send false');
            }
        } catch (Exception e){
            system.debug(e.getStackTraceString());
            system.debug('Send error');
        }     
    }
    

    public class TnCData{
        
        @AuraEnabled
        public string collectPersonalInfo{get;set;}
        @AuraEnabled
        public string crossBorderTransfer{get;set;}
        @AuraEnabled
        public string termsOfService{get;set;}
        @AuraEnabled
        public string fourteenYearsOld{get;set;}
        @AuraEnabled
        public List<string> recId =  new List<String>();
        
    }
    
    public class emailValidity{
        
        @AuraEnabled
        public boolean userAlreadyPresent{get;set;}
        @AuraEnabled
        public string duplicateEntity{get;set;}
        
        
    }
    
    public class insertedInfo{
        
        @AuraEnabled
        public String insertedId{get;set;}    
        @AuraEnabled
        public String insertedNumber{get;set;}
    }
}