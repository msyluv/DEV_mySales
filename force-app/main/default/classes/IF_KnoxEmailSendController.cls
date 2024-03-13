/*
@Desc : IF_KnoxEmailSendController
@Author : Soohong.Kim
@Date : 2020. 11. 03
@Version : 1.0

@Method : 



@Modified : 
---------------------------------------------
NO | Date       | Modifier      | Description 
---------------------------------------------
1. | 2020.11.03 | Soohong.Kim   | 최초작성


*/


public class IF_KnoxEmailSendController {
    private static final String INTERFACE_ID = 'IF-075';
    private static final String APEX_CLASS   = 'IF_KnoxEmailSendController';
    private static final String METHOD_NAME  = 'send';

    @AuraEnabled    
    public static Map<String,Object> send(InputClass input){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{

            //input.contents = input.contents.replaceAll('\'', '\"');
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            String reqMsg = String.valueOf(resMap.get('Request'));
            String resMsg = String.valueOf(resMap.get('Response'));

            Integer resStatusCode = (Integer)resMap.get('StatusCode');
            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {

                System.debug( 'KKKKKK');
                HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            }else {

                List<String> errorMsgList = new List<String>();
                log.addLog('Communication Error : ' + String.valueOf(resMap.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(resMap.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            system.debug('returnMap : '+returnMap);
        
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, resMap.get('Request') + '', resMap.get('Response') + '',e);
        }
        
        // 화면단에서 여러건의 메일을 보낼 경우 Callout Exception 때문에 DML Object 를 ReturnMap으로 분리 후 화면에서 처리 - 2021.02.03 by Soohong.Kim
        if( input.isMulti){
            returnMap.put('INTERFACE_LOG', ifLog);
        } 
        else{
            log.createLog(ifLog);
        }

        return returnMap;
    } 
    
    /*
    public class SendMail implements Promise.Deferred, Promise.Done{
        @AuraEnabled
        public Map<String,Object> bodyMap;
        public SendMail(){

        }
        public SendMail(Map<String,Object> bodyMap) {
            this.bodyMap = bodyMap;
        }
        public Object resolve(Object incomingObject) {
            system.debug('incomingObject resolve : '+incomingObject);
            system.debug('bodyMap resolve : '+bodyMap);
            IF_Callout call = new IF_Callout(INTERFACE_ID);
            InputClass reqClass = new InputClass();
            List<Recipients> recList = new List<Recipients>();
            List<Attachments> attList = new List<Attachments>();
            
    
            reqClass.subject = String.valueOf(bodyMap.get('subject'));
            reqClass.contents = String.valueOf(bodyMap.get('contents'));
            reqClass.contentType = String.valueOf(bodyMap.get('contentType'));
            reqClass.docSecuType = String.valueOf(bodyMap.get('docSecuType'));
            reqClass.sfdcId = String.valueOf(bodyMap.get('sfdcId'));
            
            //reqClass.sender = new Sender('hyojinn.lee', 'hyojinn.lee@stage.partner.samsung.com');
            reqClass.sender = (Sender) bodyMap.get('sender');
            
            //recList.add(new Recipients('hyojinn.lee@stage.partner.samsung.com','TO'));
            

            //reqClass.recipients = recList;
            reqClass.recipients = (List<Recipients>) bodyMap.get('recipients');
    
            
            attList.add(new Attachments('file','file1','buffer1'));
            attList.add(new Attachments('file','file2','buffer2'));
            attList.add(new Attachments('file','file3','buffer3'));
            reqClass.attachments = attList;
            
            reqClass.attachments = (List<Attachments>) bodyMap.get('attachments');
    
            //bodyMap.put('test key','test value');
            String jsonBody = JSON.serialize(reqClass);
            Map<String,Object> resMap = call.httpCallout(jsonBody, '');
            return resMap;
        }

        public void done(Object incomingObject) {
            Map<String,Object> resMap = (Map<String,Object>) incomingObject;
            System.debug( 'incomingObject  done :' + resMap);
            //HttpResponse res = (HttpResponse)resMap;
            String guId = IF_Util.generateGuid();
            IF_Log.InterfaceLog ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
            
        }
        
    }
    */
    
    @future(callout=true)
    public static void send2(String inputStr){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{

            //input.contents = input.contents.replaceAll('\'', '\"');
            String jsonBody = inputStr;
            resMap = call.httpCallout(jsonBody, '');
            String reqMsg = String.valueOf(resMap.get('Request'));
            String resMsg = String.valueOf(resMap.get('Response'));

            Integer resStatusCode = (Integer)resMap.get('StatusCode');
            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {

                HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            }else {

                List<String> errorMsgList = new List<String>();
                log.addLog('Communication Error : ' + String.valueOf(resMap.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(resMap.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            system.debug('returnMap : '+returnMap);
        
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, resMap.get('Request') + '', resMap.get('Response') + '',e);
        }
        
        
        return;
    }

    public class CallHeader{

        /* : 기타 해더 정보
        public String TOTAL_COUNT    = '0';
        public String RESULT_MESSAGE = '';
        public String 
        */
        @AuraEnabled
        public List<InputClass> DATA;
    }


    /*
    public class CallClass{

        @AuraEnabled
        public String System_ID;
        @AuraEnabled
        public String userId;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String docSecuType;
        @AuraEnabled
        public String contents;
        @AuraEnabled
        public String contentType;
        @AuraEnabled
        public String sender; //JSON Object
        @AuraEnabled
        public String emailAddress;
        @AuraEnabled
        public String recipients; //JSON List
        @AuraEnabled
        public String recipientType;
        @AuraEnabled
        public String attachments;

    }
*/

    public class Sender{
        @AuraEnabled
        public String userId{get;set;}
        @AuraEnabled
        public String emailAddress{get;set;}

        public Sender(String userId, String emailAddress){
            this.userId = userId;
            this.emailAddress = emailAddress;
        }
    }
    public class Recipients{
        @AuraEnabled
        public String emailAddress{get;set;}
        @AuraEnabled
        public String recipientType{get;set;}

        public Recipients(String emailAddress, String recipientType){
            this.emailAddress = emailAddress;
            this.recipientType = recipientType;
        }
    }
    public class Attachments{
        @AuraEnabled
        public String contentType{get;set;}
        @AuraEnabled
        public String fileName{get;set;}
        @AuraEnabled
        public String contents{get;set;}

        public Attachments(String contentType, String fileName, String contents){
            this.contentType = contentType;
            this.fileName = fileName;
            this.contents = contents;
        }
    }
    public class InputClass{
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String contents;
        @AuraEnabled
        public String contentType;
        @AuraEnabled
        public String docSecuType;
        @AuraEnabled
        public String sfdcId;

        @AuraEnabled
        public Sender sender;
        @AuraEnabled
        public List<Recipients> recipients;
        @AuraEnabled
        public List<Attachments> attachments;

        //한 트랜잭션에서 여러건 보낼 경우 IF Log DML 처리로 인해 Callout Exception 이 떨어져서 확인을 위한 Flag
        @AuraEnabled
        public Boolean isMulti = false;

    }
}