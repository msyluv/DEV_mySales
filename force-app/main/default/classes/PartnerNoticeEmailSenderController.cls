/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-05-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public class PartnerNoticeEmailSenderController {

    @AuraEnabled    
    public static Map<String,Object> getEmailInfo(String recordId){
        Map<String,Object> resultMap = new Map<String,Object>();
        String result = 'S';
        String message = '';
        try{
            List<Partner_Notice__c> pnList = [SELECT Id, Email_Send_Subject__c, Email_Send_Count__c, Active_InActive__c, Last_Email_Sent_Date__c, Owner.Name, Owner.Email FROM Partner_Notice__c WHERE Id=:recordId];
            if(!pnList.isEmpty()){
                resultMap.put('Email_Send_Subject__c', pnList[0].Email_Send_Subject__c);
                resultMap.put('Email_Send_Count__c', pnList[0].Email_Send_Count__c);
                resultMap.put('Active_InActive__c', pnList[0].Active_InActive__c);
                resultMap.put('Last_Email_Sent_Date__c',  string.valueOf(pnList[0].Last_Email_Sent_Date__c));
                resultMap.put('Email_Sender',  pnList[0].Owner.Name + '(' + pnList[0].Owner.Email+')');
            }
        } catch(Exception e){
            result = 'E';
            message = System.Label.PARTNER_NOTICE_EMAIL_ERROR_RETRIEVAL + ' : ' + e.getMessage();
            System.debug(message);
        }
        
        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);

        return resultMap;
    }

    @AuraEnabled
    public static Map<String, Object> sendEmailAndUpdateCount(String recordId, String emailSendSubject){
        Map<String,Object> resultMap = new Map<String,Object>();
        String result = 'E';
        String message = System.Label.PARTNER_NOTICE_EMAIL_ERROR_MESSAGE;

        List<Partner_Notice__c> pnList = [SELECT Id, Contents__c, OwnerId, Email_Send_Subject__c, Email_Send_Count__c, Active_InActive__c FROM Partner_Notice__c WHERE Id=:recordId];
        if(!pnList.isEmpty()){
            Partner_Notice__c pn = pnList[0];
            pn.Email_Send_Subject__c = emailSendSubject;
            if(pn.Email_Send_Count__c == null){
                pn.Email_Send_Count__c=0;
            }
            pn.Email_Send_Count__c+=1;
            pn.Last_Email_Sent_Date__C = System.now();
            
            try{                
                EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Notice_Email' LIMIT 1];
                String contents = String.valueOf(emailTemplate.htmlValue);

                Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                contents = contents.replace('{!url}', communityUrl + '/detail/' + pn.id);
                contents = contents.replace('{!contents}',  pn.Contents__c);
                       Id sendId = pn.OwnerId;
                       //   Id sendId = '0051s000003wl1eAAA';
                Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE (Profile.Name='MSP Admin' OR UserType='PowerPartner') AND Email!=Null AND isActive=TRUE])).keySet();
             //    Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE (Profile.Name='MSP Admin' OR UserType='PowerPartner') AND (Username ='testpartnerprofile4@samsung.com.sds.qa' OR Username = 'member@check.com') AND Email!=Null AND isActive=TRUE])).keySet();
                   
                Map<String, Object> returnMap =  PartnerEmailSender.emailSendActionDirect(pn.id, sendId, null, null, bccIds, System.Label.PARTNER_NOTICE_EMAIL_SUBJECT_PREFIX + ' ' + pn.Email_Send_Subject__c, contents);
                
                if(returnMap.get('RESULT')=='S'){
                    update pn;    
                    result = 'S';
                    message =System.Label.PARTNER_NOTICE_EMAIL_SUCCESS_MESSAGE; 
                }                                
            }catch(Exception e){
                message = System.Label.PARTNER_NOTICE_EMAIL_ERROR_MESSAGE + ' : ' + e.getMessage();
                System.debug(message);
            }             
        } 

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);
        
        system.debug(result +',' +message);

        return resultMap;
    }    
}