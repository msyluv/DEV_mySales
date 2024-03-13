/**
 * @description       : Knox 메일 취소
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 01-21-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-11-16   hj.lee@dkbmc.com   Initial Version
**/
public with sharing class KnoxEmailCancelController {
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    
    @AuraEnabled
    public static Map<String,Object> cancelKnoxEmail(String jsonParam) {        
        Map<String, Object> resMap = new Map<String, Object>();  
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam); 
        Map<String, Object> knoxEmailMap = (Map<String, Object>)paramMap.get('KnoxEmail__c');
        //KnoxEmail__c knoxEmailObj = (KnoxEmail__c)Utils.mapToSObject('KnoxEmail__c', knoxEmailMap);
        KnoxEmail__c knoxEmailObj = new KnoxEmail__c();
        knoxEmailObj.Id             = (String)knoxEmailMap.get('Id');
        knoxEmailObj.MailId__c      = (String)knoxEmailMap.get('MailId__c');
        knoxEmailObj.ToAddress__c   = (String)knoxEmailMap.get('ToAddress__c');
        knoxEmailObj.CcAddress__c   = (String)knoxEmailMap.get('CcAddress__c');
        knoxEmailObj.BccAddress__c  = (String)knoxEmailMap.get('BccAddress__c');
        
        try{            
            // [IF] Input Param
            List<IF_KnoxEmailCancelController.InputClass> inputList = new List<IF_KnoxEmailCancelController.InputClass>();
            IF_KnoxEmailCancelController.InputClass input = new IF_KnoxEmailCancelController.InputClass();
            input.sfdcId = knoxEmailObj.Id;
            input.mailId = knoxEmailObj.MailId__c;

            Employee__c emp = Utils.getLoginEmployeeData(UserInfo.getUserId());
            input.userId = emp.EvMailAddr__c.split('@')[0];

            List<String> recipients = new List<String>();
            if(String.isNotBlank(knoxEmailObj.ToAddress__c)) {
                recipients.addAll(knoxEmailObj.ToAddress__c.split(','));
            } 
            if(String.isNotBlank(knoxEmailObj.CcAddress__c)) {
                recipients.addAll(knoxEmailObj.CcAddress__c.split(','));
            } 
            if(String.isNotBlank(knoxEmailObj.BccAddress__c)) {
                recipients.addAll(knoxEmailObj.BccAddress__c.split(','));
            }
            input.recipients = recipients;
            
            
            // [IF] Call out
            Map<String, Object> knoxResponse = IF_KnoxEmailCancelController.cancelMail(input);
            system.debug(knoxResponse);

            String knoxResponseResult = (String)knoxResponse.get('result');
            if(knoxResponseResult == RES_RESULT_ERROR){
                Map<String, Object> errorDetail = (Map<String, Object>)knoxResponse.get('errorDetail');
                resMap.put('RESULT',RES_RESULT_ERROR);
                resMap.put('Message', (String)errorDetail.get('errorMessage'));

            } else {
                resMap.put('RESULT',RES_RESULT_SUCCESS);
                List<Object> knoxResponseData = (List<Object>)knoxResponse.get('data');                
                // [CallBack Class]
                updateEmailStatus(knoxEmailObj);
            }

        } catch(Exception e) {
            resMap.put('RESULT', RES_RESULT_ERROR);
            resMap.put('Message',e.getMessage());
            resMap.put('Trace',e.getStackTraceString());
        }
        return resMap;
    }

    public static void updateEmailStatus(KnoxEmail__c knoxEmailObj) {
        System.debug('knoxEmailObj ' + knoxEmailObj);
        knoxEmailObj.Status__c = 'Cancel';
        UPDATE knoxEmailObj;
    }
}