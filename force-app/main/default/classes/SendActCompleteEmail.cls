/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-18
 * @last modified by  : seonju.jin@dkbmc.com
**/
public without sharing class SendActCompleteEmail {

    @future(callout=true)
    public static void sendKnoxMail(Set<Id> idSet){
        System.debug('future sendKnoxMail');
        Organization org = [ SELECT Id, IsSandBox FROM Organization];

        List<Object> logObjList = new List<Object>();
        List<KnoxApproval__c> approvalList = [SELECT Id, Name, Opportunity__c, Opportunity__r.OpportunityCode__c, MISID__c, CreatedById FROM KnoxApproval__c WHERE Id IN :idSet];
        List<String> toList = new List<String>();

        String toListStr = System.Label.MISID_EMAIL_TOLIST;
        toList = toListStr.split(',');      //수신자설정
        List<KnoxEmail__c> knoxEmailList = new List<KnoxEmail__c>();
        for(KnoxApproval__c knox : approvalList){
            try{

                List<Object> paramters = new List<Object>{knox.Opportunity__c, knox.Opportunity__r.OpportunityCode__c, knox.MISID__c};
                String emailcontent = '';
                try{
                    emailcontent = String.format(System.Label.MISID_EMAIL_CONTENT, paramters);
                }catch(Exception e){
                    System.debug(e.getMessage());
                    System.debug(e.getStackTraceString());
                    emailcontent = System.Label.MISID_EMAIL_CONTENT + '\r\n' + paramters.toString();
                }

                IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();
                bodyMap.isMulti = true;
                bodyMap.subject = System.Label.MISID_EMAIL_SUBJECT;
                bodyMap.contents = emailcontent;
                bodyMap.contentType = 'TEXT';   // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
                bodyMap.docSecuType = 'PERSONAL';
                bodyMap.sfdcId = knox.Id;
                IF_KnoxEmailSendController.Sender sender;

                //보내는 사람 설정
                String senderAddress = System.Label.MISID_EMAIL_SENDER;
                sender = new IF_KnoxEmailSendController.Sender(senderAddress.split('@')[0], senderAddress);
                bodyMap.sender = sender;
        
                // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
                List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
                for(String t : toList){
                    IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
                    recipientsList.add(r);
                }
        
                bodyMap.recipients = recipientsList;
                bodyMap.attachments = new List<IF_KnoxEmailSendController.Attachments>();
                Map<String,Object> response = new Map<String, Object>();
                if(!Test.isRunningTest()){
                    response = IF_KnoxEmailSendController.send(bodyMap);
                } else {
                    response.put('result', 'success');
                    response.put('mailId', 'testMailId');
                }
                logObjList.add(response.get('INTERFACE_LOG'));
        
                String responseResult = String.valueOf(response.get('result'));
                if(responseResult == 'success'){
                    String knoxEmailId = String.valueOf(response.get('mailId'));
                    KnoxEmail__c knoxEmail = new KnoxEmail__c(
                        RecordId__c = knox.Id
                        , ToAddress__c = String.join(toList, ',')
                        , Name = System.Label.MISID_EMAIL_SUBJECT
                        , HtmlBody__c = emailcontent
                        , MailId__c = knoxEmailId
                        , Status__c = 'Send'
                    );
                    knoxEmailList.add(knoxEmail);
                }
            }catch(Exception e){
                System.debug(e.getMessage());
                System.debug(e.getStackTraceString());
            }
        }

        if(logObjList.size() > 0) createInterfaceLog(logObjList);
        if(knoxEmailList.size() > 0) insert knoxEmailList;
    }


    public static void createInterfaceLog(List<Object> objList){
        for(Object logObj : objList){
            try{
                IF_Log log = new IF_Log();
                if(logObj != null){
                    IF_Log.InterfaceLog iflog_interfaceLog = (IF_Log.InterfaceLog)logObj;
                    log.createLog(iflog_interfaceLog);
                } 
            }catch(Exception e){
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
            }
        }
    }
}