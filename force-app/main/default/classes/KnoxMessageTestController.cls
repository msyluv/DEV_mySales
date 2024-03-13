/**
 * @description       :
 * @author            : ukhyeon.lee@samsung.com
 * @group             :
 * @last modified on  : 12-06-2021
 * @last modified by  : zenith21c@test.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   06-21-2021   ukhyeon.lee@samsung.com   Initial Version
**/
public class KnoxMessageTestController {

    //암호화+압축+base64인코딩
    @AuraEnabled
    public static Map<String, Object> goEncryptClass(String inputDatas){
        Map<String,Object> resultMap = new Map<String,Object>();

        //기본 성공메세지
        String result = 'S';
        String message = 'goEncrypt success.';// Opportunity information update success.

        try{
            // //화면에서 전달한 입력값
            // List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
            // Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);

            // String key = (String)inputData.get('key');
            // String origin = (String)inputData.get('origin');

            // String[] keyArr = key.split('');
            
            // String keyStr = '';
            // String ivStr = '';

            // for(Integer i=0; i<64; i++){
            //     keyStr += keyArr[i];
            // }
            // Blob keyb = EncodingUtil.convertFromHex(keyStr);


            // for(Integer i=64; i<96; i++){
            //     ivStr += keyArr[i];                
            // }
            // Blob ivb = EncodingUtil.convertFromHex(ivStr);

            // Blob data = Blob.valueOf(origin);
            // Blob encryptedData = Crypto.encrypt('AES256', keyb, ivb, data);
            // String encoded = EncodingUtil.base64Encode(encryptedData);
            // Blob decrpytedData = Crypto.decrypt('AES256', keyb, ivb, encryptedData);
            // String decStr = decrpytedData.toString();

            // resultMap.put('origin', origin);
            // resultMap.put('encryptedData', encryptedData);
            // resultMap.put('encoded', encoded);
            // resultMap.put('decrpytedData', decrpytedData);
            // resultMap.put('decStr', decStr);

            // String tid = 'TID-000001';
            // String templateContents = getChatTemplate(tid);
            // resultMap.put('template', templateContents);

            // templateContents = 'oldOwnerIdxxxxxxxxxxxxxxLinkAddressxxxxxxxxxx';

            // Map<String, String> inputMap = new Map<String, String>();
            // inputMap.put('oldOwnerId', '1111111111');
            // inputMap.put('LinkAddress', '222222222222222222222');
            
            // resultMap.put('convertedResult', convertTemplate(inputMap, templateContents));


            List<String> inputVarList = new List<String>();
            inputVarList.add('wonjun98.lee');
            inputVarList.add('wonjun98.lee');
            inputVarList.add('111');
            inputVarList.add('222');
            inputVarList.add('333');
            inputVarList.add('444');
            inputVarList.add('555');
            inputVarList.add('666');
            inputVarList.add('777');
            inputVarList.add('888');
            //inputVarList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/0061s000006j6iDAAQ/view');
            inputVarList.add('https://sdssfa--qa.my.salesforce.com/services/apexrest/KnoxMessage/doSomething');
            resultMap.put('xxxxxx', IF_KnoxChatSendController.sendBOOwnerChangeChat2(inputVarList));


            inputVarList = new List<String>();
            inputVarList.add('wonjun98.lee');
            inputVarList.add('wonjun98.lee');
            inputVarList.add('111');
            inputVarList.add('222');
            inputVarList.add('333');
            inputVarList.add('444');
            inputVarList.add('555');
            inputVarList.add('666');
            inputVarList.add('777');
            //inputVarList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/a0P1s000001t0mcEAA/view');
            inputVarList.add('https://sdssfa--qa.my.salesforce.com/services/apexrest/KnoxMessage/doSomething');
            
            resultMap.put('xxxxxx222', IF_KnoxChatSendController.sendLeadOwnerChangeChat2(inputVarList));
            
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
        }

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);

        return resultMap;
    }

    public static String convertTemplate(Map<String, String> convertMap, String origin){
        if (convertMap!=null && !convertMap.isEmpty()){
            Set<String> keySet = convertMap.keySet();
            List<String> keyList = new List<String>();
            keyList.addAll(keySet);

            for(String key : keyList){
                String val = convertMap.get(key);
                origin = origin.replaceAll(key, val);
            }
        }

        return origin;
    }

    public static String getChatTemplate(String templateId){
        ChatTemplate__c template = [select Name
                                    , Platform__c
                                    , TemplateType__c
                                    , Template__c
                                 from ChatTemplate__c
                                where Name = :templateId
                                limit 1];
        String result = '';
        result = template.Template__c;
        
        if( result!=null && result!='null' && result != ''){
            result = result.replaceAll('&quot;', '"');
        }

        return result;
    }

    
    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    // ----------------------------------------------------------------------------------------
    // Jitterbit 호출 관련 --------------------------------------------------------------------
    private static final String APEX_CLASS   = 'KnoxMessageTestController';
    
    private static final String METHOD_NAME_145  = 'createKnoxChatRoomRequest';
    private static final String INTERFACE_ID_145 = 'IF-145';

    private static final String METHOD_NAME_146  = 'doKnoxChatRequest';
    private static final String INTERFACE_ID_146 = 'IF-146';

    private static final String METHOD_NAME_147  = 'getKnoxRegKeyValue';
    private static final String INTERFACE_ID_147 = 'IF-147';

    private static final String METHOD_NAME_148  = 'getChatSenderInfo';
    private static final String INTERFACE_ID_148 = 'IF-148';

    private static final String METHOD_NAME_149  = 'getChatReceiverInfo';
    private static final String INTERFACE_ID_149 = 'IF-149';

    private static final String METHOD_NAME_150  = 'getAES256Key';
    private static final String INTERFACE_ID_150 = 'IF-150';

    
    @AuraEnabled
    public static Map<String,Object> sendKnoxAppCardMessage(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'sendKnoxAppCardMessage success.';
        
        //화면에서 전달한 입력값
        List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
        if (inputList != null && inputList.size()>0){
            Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);
        }


        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        Map<String,Object> ifResultMap = new Map<String, Object>();

        try{
            IF_Log log;
            IF_Log.InterfaceLog ifLog;
            String guId = '';
            String jsonBody = '';
            IF_Callout call;
            HttpResponse res;

            //-------------------------------------------------------------------
            //[1]IF-147 reg
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_147);
            guId = generateUid();

            InputClass_147 input_147 = new InputClass_147();
            
            jsonBody = JSON.serialize(input_147);
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_147, guId, APEX_CLASS, METHOD_NAME_147, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            Integer deviceServerID = Integer.valueOf(ifResultMap.get('deviceServerID'));
            returnMap.put('147_IF_Result_deviceServerID', deviceServerID);
            returnMap.put('147_StatusCode',res.getStatusCode());
            returnMap.put('147_IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            

            //-------------------------------------------------------------------
            //[1]IF-148 info
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_148);
            guId = generateUid();

            InputClass_148_singleIdList inputClass_148_singleIdList = new InputClass_148_singleIdList();
            inputClass_148_singleIdList.singleID = 'mysales';
            InputClass_148 input_148 = new InputClass_148();
            input_148.singleIdList = new List<InputClass_148_singleIdList>();
            input_148.singleIdList.add(inputClass_148_singleIdList);
            input_148.deviceServerID = deviceServerID;//1000259729;
    
            jsonBody = JSON.serialize(input_148);
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_148, guId, APEX_CLASS, METHOD_NAME_148, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            List<Object> userDeviceList = new List<Object>();
            userDeviceList = ((List<Object>)ifResultMap.get('userDeviceList'));
            String if148SingleId = String.valueOf(((Map<String, Object>)userDeviceList.get(0)).get('singleID'));
            String if148UserId = String.valueOf(((Map<String, Object>)userDeviceList.get(0)).get('userID'));
            returnMap.put('148_IF_Result_singleId', if148SingleId);
            returnMap.put('148_IF_Result_userID', if148UserId);
            returnMap.put('148_StatusCode',res.getStatusCode());
            returnMap.put('148_IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            

            //-------------------------------------------------------------------
            //[1]IF-149 loginId
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_149);
            guId = generateUid();

            InputClass_149_singleIdList receiver1 = new InputClass_149_singleIdList();
            receiver1.singleID = 'oldman.sea';
            InputClass_149_singleIdList receiver2 = new InputClass_149_singleIdList();
            receiver2.singleID = 'wonjun98.lee';
            InputClass_149 input_149 = new InputClass_149();
            input_149.singleIdList = new List<InputClass_149_singleIdList>();
            input_149.singleIdList.add(receiver1);
            input_149.singleIdList.add(receiver2);
            input_149.deviceServerID = deviceServerID;//1000259729;
    
            jsonBody = JSON.serialize(input_149);
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_149, guId, APEX_CLASS, METHOD_NAME_149, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            Map<String, Object> userSearchResult = new Map<String, Object>();
            userSearchResult.putAll((Map<String, Object>)ifResultMap.get('userSearchResult'));
            List<Object> searchResultList = new List<Object>();
            searchResultList = ((List<Object>)userSearchResult.get('searchResultList'));
            String IF_149_Result_receiverUserId1 = String.valueOf(((Map<String, Object>)searchResultList.get(0)).get('userID'));
            String IF_149_Result_receiverUserId2 = String.valueOf(((Map<String, Object>)searchResultList.get(1)).get('userID'));

            String IF_148_Result_singleId = String.valueOf(((Map<String, Object>)userDeviceList.get(0)).get('singleID'));
            returnMap.put('149_IF_Result_receiverUserId1', IF_149_Result_receiverUserId1);
            returnMap.put('149_IF_Result_receiverUserId2', IF_149_Result_receiverUserId2);
            returnMap.put('149_StatusCode',res.getStatusCode());
            returnMap.put('149_IF_MSG',String.valueOf(resMap.get('IF_MSG')));            
            
            //-------------------------------------------------------------------
            //[1]IF-150 getKeys
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_150);
            guId = generateUid();
    
            InputClass_150 input_150 = new InputClass_150();
            input_150.deviceServerID = deviceServerID;
        
            jsonBody = JSON.serialize(input_150);
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_150, guId, APEX_CLASS, METHOD_NAME_150, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            returnMap.put('150_IF_AES256Key', String.valueOf(ifResultMap.get('key')));
            returnMap.put('150_StatusCode_150',res.getStatusCode());
            returnMap.put('150_IF_MSG_150',String.valueOf(resMap.get('IF_MSG')));
            


            //-------------------------------------------------------------------
            //[1]IF-145 creatChatRoom
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_145);
            guId = generateUid();
            String chatType = '2';
            String receiver = String.valueOf(returnMap.get('149_IF_Result_receiverUserId1'))
                            + ','
                            + String.valueOf(returnMap.get('149_IF_Result_receiverUserId2'));
            String origin = '{'
                      + '\'requestId\':\'' + guId +'\'' + ','
                      + '\'chatroomTitle\':\'mySales\','
                      + '\'chatType\':\'' + chatType +'\'' + ','
                      + '\'receivers\':[' + receiver +']'
                      + '}';

            
            String AES256Key = String.valueOf(returnMap.get('150_IF_AES256Key'));
            Blob encrypted = doEncryptAndEncode(AES256Key, origin);
            String encoded = EncodingUtil.base64Encode(encrypted);
            jsonBody = '("'+encoded+'")';
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_145, guId, APEX_CLASS, METHOD_NAME_145, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            returnMap.put('145_StatusCode',res.getStatusCode());
            returnMap.put('145_IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            String jitterbitMessage = String.valueOf(resMap.get('Response'));
            returnMap.put('145_jitterbitMessage', jitterbitMessage);
            
            String decrpytedStr = doDecryptAndDecode(AES256Key, EncodingUtil.base64Decode(jitterbitMessage));
            returnMap.put('145_decryptedStr', decrpytedStr);
            Map<String,Object> resultMap145 = (Map<String,Object>) JSON.deserializeUntyped(decrpytedStr);
            String chatRoomId = String.valueOf(resultMap145.get('chatroomId'));
            returnMap.put('145_chatRoomId', chatRoomId);



            //-------------------------------------------------------------------
            //[1]IF-146 chatRequest
            log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_146);
            guId = generateUid();
            origin = getBOChangeAdaptiveCardContent(chatRoomId);

            encrypted = doEncryptAndEncode(AES256Key, origin);
            encoded = EncodingUtil.base64Encode(encrypted);
            jsonBody = '("'+encoded+'")';
            resMap = call.httpCallout(jsonBody, '');
            res = (HttpResponse)resMap.get('HttpResponse');
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));

            returnMap.put('146_StatusCode',res.getStatusCode());
            returnMap.put('146_IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            jitterbitMessage = String.valueOf(resMap.get('Response'));
            returnMap.put('146_jitterbitMessage', jitterbitMessage);

            

        }
        catch(Exception e){
            result = 'E';
            message = 'sendKnoxAppCardMessage ERROR : ' + e.getMessage();            
        }

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        return returnMap;
    }

    //IF-147_reg(Knox 인증key 조회)
    @AuraEnabled
    public static Map<String,Object> getKnoxRegKeyValue(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'getKnoxRegKey success.';
        String jitterbitMessage = '';

        // //jitterbit 입력값으로 변환
        // //List<IF_KnoxEmailCancelController.InputClass> inputList = new List<IF_KnoxEmailCancelController.InputClass>();
        // InputClass_147 input_147 = new InputClass_147();
        
        // IF_Callout call = new IF_Callout(INTERFACE_ID_147);
        // IF_Log log = new IF_Log();
        // IF_Log.InterfaceLog ifLog;
        // Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        // String guId = generateUid();
        // try{
        //     String jsonBody = JSON.serialize(input_147);
        //     resMap = call.httpCallout(jsonBody, '');
        //     HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
        //     returnMap.put('StatusCode',res.getStatusCode());
        //     returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
        //     returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            
        //     ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_147, guId, APEX_CLASS, METHOD_NAME_147, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
            
        // }catch(Exception e){
        //     result = 'E';
        //     message = 'ERROR : ' + e.getMessage();
            

        //     ifLog = new IF_Log.InterfaceLog(METHOD_NAME_147, guId, APEX_CLASS, METHOD_NAME_147, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        // }
        // log.createLog(ifLog);



        String name = '';
        String owner = '';

        Sales_Lead__c s = [select Id
                                , Name
                                , OwnerId
                                , Owner.Name
                                , Description__c
                                , LeadDescription__c
                                , CreatedDate
                                , CustomerContactDate__c
                                , Sales_Alert_Date__c 
                            from Sales_Lead__c
                            where LeadStatus__c != 'Close'
                            and CustomerContactDate__c = null
                            and Lead__c != null
                            and id = 'a0P1s000001s5R5EAI'];
        

        List<Sales_Lead__c> scopeList = new List<Sales_Lead__c>();

        scopeList.add(s);
        try{
            for( Sales_Lead__c sale : scopeList){
            
                    sale.Sales_Alert_Date__c = Datetime.now();
                    //--------------------------------------------------------------------
                    //사업리드 48시간 후에 고객컨택 일시 미등록시 알람
                    try{
                        String ownerId = sale.ownerId;
                        String salesLeadName = sale.Name;
                        String salesLeadOwner = '';
                        String salesLeadDescription = sale.Description__c;
                        String ownerEmail = '';
                        String salesLeadCreateDate = '2021-11-11 15:02:22';
                        String replyDeadline = '2021-11-13 15:02:22';
                        String linkAddress = '';                
                        Boolean isSandbox = Utils.getIsSandbox();

                        User salesUser = [SELECT Id, LastName, FirstName, Email, FederationIdentifier
                                            FROM User
                                        WHERE id = :ownerId];
                        Employee__c salesEmployee = salesUser.FederationIdentifier != '' ? Utils.getEmployeeData(salesUser.FederationIdentifier) : null;
                        
                        salesLeadOwner = salesUser.LastName + salesUser.FirstName;
                        if(salesEmployee != null) ownerEmail = salesEmployee.EvMailAddr__c;

                        if(String.isNotBlank(ownerEmail)){
                            ownerId = ownerEmail.left(ownerEmail.indexOf('@'));
                        }
                        
                        //QA
                        if(isSandbox){
                            //linkAddress = 'https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/'+sale.Id+'/view';
                            linkAddress = 'https://sdssfa--qa.my.salesforce.com/services/apexrest/KnoxMessage/doSomething';
                        }
                        //REAL
                        else{
                            linkAddress = 'https://sdssfa.lightning.force.com/lightning/r/Sales_Lead__c/'+sale.Id+'/view';
                        }
                        /* ------------------------------------------------------------------------- */
                        /* Jitterbit 통해 Knox Rest API 호출 시작 */
                        Map<String, String> inputMap = new Map<String, String>();
                        inputMap.put('ownerId', 'wonjun98.lee');
                        inputMap.put('salesLeadName', salesLeadName);
                        inputMap.put('salesLeadOwner', salesLeadOwner);
                        inputMap.put('ownerEmail', ownerEmail);
                        inputMap.put('salesLeadDescription', salesLeadDescription);
                        inputMap.put('salesLeadCreateDate', salesLeadCreateDate);
                        inputMap.put('replyDeadline', replyDeadline);
                        inputMap.put('linkAddress', linkAddress);
                        IF_KnoxChatSendController.sendSalesLeadLateAlarmChat(inputMap);
                        /* Jitterbit 통해 Knox Rest API 호출 종료*/
                        /* ------------------------------------------------------------------------- */   
                    }
                    catch(Exception e){
                        System.debug('Batch_SalesLeadEmail.cls -> KnoxChat e.getMessage : ' + e.getMessage());
                    }
                    //--------------------------------------------------------------------

            }
            
        }catch(Exception e){
            System.debug('Batch_SalesLeadEmail.cls222 -> KnoxChat e.getMessage : ' + e.getMessage());
        }finally{
          
        }
        

        

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        
        return returnMap;
    }


    //IF-148_info(Knox 대화 송신자의 기기(단말) 사용정보 조회)
    @AuraEnabled
    public static Map<String,Object> getChatSenderInfo(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'getChatSenderInfo success.';
        String jitterbitMessage = '';

        //jitterbit 입력값으로 변환
        InputClass_148_singleIdList inputClass_148_singleIdList = new InputClass_148_singleIdList();
        inputClass_148_singleIdList.singleID = 'mysales';
        InputClass_148 input_148 = new InputClass_148();
        input_148.singleIdList = new List<InputClass_148_singleIdList>();
        input_148.singleIdList.add(inputClass_148_singleIdList);
        input_148.deviceServerID = 1000259729;

        IF_Callout call = new IF_Callout(INTERFACE_ID_148);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        String guId = generateUid();
        try{            
            String jsonBody = JSON.serialize(input_148);
            resMap = call.httpCallout(jsonBody, '');
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_148, guId, APEX_CLASS, METHOD_NAME_148, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
            
			log.addLog('StatusCode : E');
            ifLog = new IF_Log.InterfaceLog(METHOD_NAME_148, guId, APEX_CLASS, METHOD_NAME_148, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        
        return returnMap;
    }


    //IF-149_loginId(Knox 대화 수신자의 정보조회)
    @AuraEnabled
    public static Map<String,Object> getChatReceiverInfo(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'getChatReceiverInfo success.';
        String jitterbitMessage = '';

        //jitterbit 입력값으로 변환
        InputClass_149_singleIdList receiver1 = new InputClass_149_singleIdList();
        receiver1.singleID = 'oldman.sea';
        InputClass_149_singleIdList receiver2 = new InputClass_149_singleIdList();
        receiver2.singleID = 'wonjun98.lee';
        InputClass_149 input_149 = new InputClass_149();
        input_149.singleIdList = new List<InputClass_149_singleIdList>();
        input_149.singleIdList.add(receiver1);
        input_149.singleIdList.add(receiver2);
        input_149.deviceServerID = 1000259729;

        IF_Callout call = new IF_Callout(INTERFACE_ID_149);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        String guId = generateUid();
        try{            
            String jsonBody = JSON.serialize(input_149);
            resMap = call.httpCallout(jsonBody, '');
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_149, guId, APEX_CLASS, METHOD_NAME_149, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_149, guId, APEX_CLASS, METHOD_NAME_149, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        
        return returnMap;
    }


    //IF-150_getKeys(Knox 대화전송시 AES256 암호화에 사용할 key와 iv값을 조회)
    @AuraEnabled
    public static Map<String,Object> getAES256Key(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'getAES256Key success.';
        String jitterbitMessage = '';

        Integer deviceServerID = 0;
        //화면에서 전달한 입력값
        List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
        if (inputList != null && inputList.size()>0){
            Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);
            deviceServerID = Integer.valueOf(inputData.get('deviceServerId'));
        }

        //jitterbit 입력값으로 변환
        InputClass_150 input_150 = new InputClass_150();
        input_150.deviceServerID = deviceServerID;

        IF_Callout call = new IF_Callout(INTERFACE_ID_150);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        String guId = generateUid();
        try{            
            String jsonBody = JSON.serialize(input_150);
            resMap = call.httpCallout(jsonBody, '');
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_150, guId, APEX_CLASS, METHOD_NAME_150, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_150, guId, APEX_CLASS, METHOD_NAME_150, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        
        return returnMap;
    }
    

    //Knox 대화방 생성 요청
    @AuraEnabled
    public static Map<String,Object> createKnoxChatRoomRequest(String inputDatas){
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        //기본 성공메세지
        String result = 'S';
        String message = 'createChatRoomRequest success.';
        String jitterbitMessage = '';

        //화면에서 입력받은 변수들
        List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
        Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);
        
        String requestId = generateUid();
        String chatType = '2';
        String receiver = '840967548745814017';//oldman.sea
        String origin = '{'
                      + '\'requestId\':\'' + requestId +'\'' + ','
                      + '\'chatroomTitle\':\'mySales\','
                      + '\'chatType\':\'' + chatType +'\'' + ','
                      + '\'receivers\':[' + receiver +']'
                      + '}';

        String key = 'ef7671179ddb8dceb95324811f46053722ed54b1ae849d7c0aac199e9cb63ce4b052521901f2eb5a7de3c5da8232e7e1';
        Blob encrypted = doEncryptAndEncode(key, origin);
        String decryptedCheck = doDecryptAndDecode(key, encrypted);
        String encoded = EncodingUtil.base64Encode(encrypted);
        returnMap.put('salesforceEncode', encoded);

        //jitterbit 입력값으로 변환
        InputClass_145 input_145 = new InputClass_145();
        input_145.deviceServerID = 1000259729;
        input_145.requestInfo = encoded;

        String guId = generateUid();
        IF_Callout call = new IF_Callout(INTERFACE_ID_145);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        

        try{
            String jsonBody = '("'+encoded+'")';//JSON.serialize(input_145);\
            returnMap.put('jsonBody', jsonBody);
            resMap = call.httpCallout(jsonBody, '');
            returnMap.put('jsonBody', jsonBody);
        
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            jitterbitMessage = String.valueOf(resMap.get('Response'));
            returnMap.put('jitterbitMessage', jitterbitMessage);

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_145, guId, APEX_CLASS, METHOD_NAME_145, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
           
            jitterbitMessage = String.valueOf(resMap.get('Response'));
            returnMap.put('decryptedCheck', decryptedCheck);

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_145, guId, APEX_CLASS, METHOD_NAME_145, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        returnMap.put('decryptedCheck', decryptedCheck);
        returnMap.put('jitterbitMessage', jitterbitMessage);

        return returnMap;
    }

    
    //Knox 채팅 전송
    @AuraEnabled
    public static Map<String,Object> doKnoxChatRequest(String inputDatas){
        //기본 성공메세지
        String result = 'S';
        String message = 'doKnoxChatRequest success.';
        String jitterbitMessage = '';

        //화면에서 입력받은 변수들
        // List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
        // Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);
        
        String requestId = generateUid();
        String chatroomId = '128525765072461824';
        String msgType = '19';//0:일반 text, 19:adaptive card
        String msgId = generateUid();
        
        String origin = getBOChangeAdaptiveCardContent(chatroomId);
                
        //key값
        String key = 'ef7671179ddb8dceb95324811f46053722ed54b1ae849d7c0aac199e9cb63ce4b052521901f2eb5a7de3c5da8232e7e1';
        Blob encrypted = doEncryptAndEncode(key, origin);
        String decryptedCheck = doDecryptAndDecode(key, encrypted);
        String encoded = EncodingUtil.base64Encode(encrypted);
        
        //jitterbit 입력값으로 변환
        InputClass_146 input_146 = new InputClass_146();
        input_146.requestInfo = encoded;
        input_146.deviceServerID = 1000259729;
            
        String guId = generateUid();
        IF_Callout call = new IF_Callout(INTERFACE_ID_146);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{
            String jsonBody = '("'+encoded+'")';//JSON.serialize(input_146);
            //jsonBody = '("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")';
            resMap = call.httpCallout(jsonBody, '');
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            jitterbitMessage = String.valueOf(resMap.get('Response'));
            returnMap.put('requestInfo',encoded);

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
            returnMap.put('decryptedCheck', decryptedCheck);
            
            jitterbitMessage = String.valueOf(resMap.get('Response'));

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);

        returnMap.put('RESULT', result);
        returnMap.put('MESSAGE', message);
        returnMap.put('jitterbitMessage', jitterbitMessage);
        returnMap.put('decryptedCheck', decryptedCheck);

        return returnMap;
    }



    //AES256 key와 원문String을 인자로 입력받아 암호화하여 리턴한다
    @AuraEnabled
    public static Blob doEncryptAndEncode(String key, String origin){
        String[] keyArr = key.split('');            
        String keyStr = '';
        String ivStr = '';

        //key에서 key와 iv(initializing vector)를 분리한다
        for(Integer i=0; i<64; i++){
            keyStr += keyArr[i];
        }
        Blob keyb = EncodingUtil.convertFromHex(keyStr);

        for(Integer i=64; i<96; i++){
            ivStr += keyArr[i];                
        }
        Blob ivb = EncodingUtil.convertFromHex(ivStr);

        Blob data = Blob.valueOf(origin);
        Blob encryptedData = Crypto.encrypt('AES256', keyb, ivb, data);
        
        //decode & decrypt 방법
        // Blob decrpytedData = Crypto.decrypt('AES256', keyb, ivb, encryptedData);
        // String decStr = decrpytedData.toString();

        return encryptedData;
    }


    //AES256 key와 암호화 된 Blob을 인자로 입력받아 복호화하여 리턴한다
    @AuraEnabled
    public static String doDecryptAndDecode(String key, Blob encryptedData){
        String[] keyArr = key.split('');            
        String keyStr = '';
        String ivStr = '';

        //key에서 key와 iv(initializing vector)를 분리한다
        for(Integer i=0; i<64; i++){
            keyStr += keyArr[i];
        }
        Blob keyb = EncodingUtil.convertFromHex(keyStr);

        for(Integer i=64; i<96; i++){
            ivStr += keyArr[i];                
        }
        Blob ivb = EncodingUtil.convertFromHex(ivStr);
        Blob decrpytedData = Crypto.decrypt('AES256', keyb, ivb,  encryptedData);
        String decStr = decrpytedData.toString();

        return decStr;
    }

    
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //--------------------------------------------------------------------------
    //IF-145 -------------------------------------------------------------------
    //INPUT : IF-145_createChatRoomRequest(Knox 대화방 개설)
    public class InputClass_145{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public String requestInfo;
    }

    //OUTPUT : IF-145_createChatRoomRequest(Knox 대화방 개설)
    public class OutputClass_145{
        @AuraEnabled
        public String result;
    }
    //  ------------------------------------------------------------------------



    //IF-146 -------------------------------------------------------------------
    //INPUT : IF-146_chatRequest(Knox 채팅메세지 전송)
    public class InputClass_146{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public String requestInfo;
    }

    //OUTPUT : IF-146_chatRequest(Knox 채팅메세지 전송)
    public class OutputClass_146{
        @AuraEnabled
        public String result;
    }
    //  ------------------------------------------------------------------------




    //IF-147 -------------------------------------------------------------------
    //INPUT : IF-147_reg(Knox 인증key 조회)
    public class InputClass_147{       
    }

    //OUTPUT : IF-147_reg(Knox 인증key 조회)
    public class OutputClass_147{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public Integer userID;
    }
    //  ------------------------------------------------------------------------




    //IF-148 -------------------------------------------------------------------
    //INPUT : IF-148_info(Knox 대화 송신자의 기기(단말) 사용정보 조회)
    public class InputClass_148{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public List<InputClass_148_singleIdList> singleIdList;
    }
    public class InputClass_148_singleIdList{
        @AuraEnabled
        public String singleId;
    }

    //OUTPUT : IF-148_info(Knox 대화 송신자의 기기(단말) 사용정보 조회)
    public class OutputClass_148{
        @AuraEnabled
        public List<OutputClass_148_userDeviceList> userDeviceList;
    }
    public class OutputClass_148_userDeviceList{
        @AuraEnabled
        public Integer userID;
        @AuraEnabled
        public String singleID;
    }
    //  ------------------------------------------------------------------------




    //IF-149 -------------------------------------------------------------------
    //INPUT : IF-149_loginId(Knox 대화 수신자의 정보조회)
    public class InputClass_149{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public List<InputClass_149_singleIdList> singleIdList;
    }
    public class InputClass_149_singleIdList{
        @AuraEnabled
        public String singleId;
    }

    //OUTPUT : IF-149_loginId(Knox 대화 수신자의 정보조회)
    public class OutputClass_149{
        @AuraEnabled
        public List<OutputClass_149_userSearchResult> userSearchResult;
    }
    public class OutputClass_149_userSearchResult{
        @AuraEnabled
        public List<OutputClass_149_searchResultList> searchResultList;
    }
    public class OutputClass_149_searchResultList{
        @AuraEnabled
        public Integer userID;
        @AuraEnabled
        public String singleId;
    }
    //  ------------------------------------------------------------------------



    //IF-150 -------------------------------------------------------------------
    //INPUT : IF-150_getKeys(Knox 대화전송시 AES256 암호화에 사용할 key와 iv값을 조회)
    public class InputClass_150{     
        @AuraEnabled
        public Integer deviceServerID;
    }

    //OUTPUT : IF-150_getKeys(Knox 대화전송시 AES256 암호화에 사용할 key와 iv값을 조회)
    public class OutputClass_150{
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String channelauthkey;
    }
    //  ------------------------------------------------------------------------



    public static String generateUid() {
		Datetime now = Datetime.now();
		String strDate = now.format('MMdd', 'Asia/Seoul');
		String strTime = now.format('HHmmss', 'Asia/Seoul');

		Integer randomNum = (Math.random() * 10000).intValue();
		String randomStr = String.valueOf(randomNum).leftPad(4, '0');

		return strDate + strTime + randomStr;
	}


    public static String getBOChangeAdaptiveCardContent(String chatroomId){
        long currentTimeMillis = Datetime.now().getTime();
	    long currentTimeMillis2 = Datetime.now().getTime();
	    String temp1 = '{\'requestId\':' + currentTimeMillis + ',\'chatroomId\':\'' + chatroomId + '\',\'chatMessageParams\':[{\'msgType\':\'19\',\'msgId\':'+currentTimeMillis2+','
						+  '\'chatMsg\':';
		String temp2 = '}]}';

	    String bodyTemp =
                    '{\\\"adaptiveCards\\\":'
                    + '\\\"'//start of adaptiveCards
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"AdaptiveCard\\\\\",'
                    +'\\\\\"$schema\\\\\":\\\\\"http://adaptivecards.io/schemas/adaptive-card.json\\\\\",'
                    +'\\\\\"version\\\\\":\\\\\"1.3\\\\\",'
                    +'\\\\\"body\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Container\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"SAMSUNGSDSmySales\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"size\\\\\":\\\\\"Medium\\\\\",'
                    +'\\\\\"weight\\\\\":\\\\\"Bolder\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"auto\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Image\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"24px\\\\\",'
                    +'\\\\\"height\\\\\":\\\\\"24px\\\\\",'
                    +'\\\\\"style\\\\\":\\\\\"Person\\\\\",'
                    +'\\\\\"url\\\\\":\\\\\"https://ktaproxy.samsung.net/appbridge/images/ic_profile_default.png\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"stretch\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"현대엘리베이터ERP구축\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"weight\\\\\":\\\\\"Bolder\\\\\",'
                    +'\\\\\"color\\\\\":\\\\\"Accent\\\\\",'
                    +'\\\\\"size\\\\\":\\\\\"Large\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"verticalContentAlignment\\\\\":\\\\\"Center\\\\\",'
                    +'\\\\\"spacing\\\\\":\\\\\"Medium\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"ExtraLarge\\\\\",'
                    +'\\\\\"separator\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"사업기회소유자변경안내\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"spacing\\\\\":\\\\\"Large\\\\\",'
                    +'\\\\\"weight\\\\\":\\\\\"Bolder\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"사업기회(BusinessOpportunity)의소유자(Owner)가변경되었습니다.\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\",'
                    +'\\\\\"color\\\\\":\\\\\"Attention\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Container\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"112px\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"사업기회명\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\":true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"stretch\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"현대엘리베이터ERP구축\\\\\",'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"112px\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"사업기회코드\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\":true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"stretch\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"SDS-21771020\\\\\",'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\":true'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"112px\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"변경전소유자\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\":true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"stretch\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"이욱현(ukhyeon.lee@samsung.com)\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\":true'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"112px\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"변경후소유자\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"사업기회개요\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"소유자변경일자\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"isSubtle\\\\\":true,'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\":\\\\\"stretch\\\\\",'
                    +'\\\\\"items\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"이상혁(oldman.sea@samsung.com)\\\\\",'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"ERP시스템구축사업\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\":\\\\\"2021-09-30PM15:14:45\\\\\",'
                    +'\\\\\"wrap\\\\\":true,'
                    +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"None\\\\\"'
                    +'}'
                    +']'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\":\\\\\"Large\\\\\",'
                    +'\\\\\"style\\\\\":\\\\\"emphasis\\\\\",'
                    +'\\\\\"bleed\\\\\":true'
                    +'}'
                    +'],'
                    +'\\\\\"backgroundImage\\\\\":{},'
                    +'\\\\\"actions\\\\\":['
                    +'{'
                    +'\\\\\"type\\\\\":\\\\\"Action.OpenUrl\\\\\",'
                    +'\\\\\"title\\\\\":\\\\\"해당BO바로가기\\\\\",'
                    +'\\\\\"style\\\\\":\\\\\"positive\\\\\",'
                    +'\\\\\"url\\\\\":\\\\\"https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/0061s000006j6iDAAQ/view\\\\\"'
                    +'}'
                    +']'
                    +'}'
                    +'\\\"'//end of adaptiveCards
                    +'}';
	    String origin = temp1 + '\'' + UNCOMPRESSED_TAG + bodyTemp + '\'' + temp2;

	    return origin;
	}

    private static String UNCOMPRESSED_TAG = '<!-- {\\\"COMMAND\\\":\\\"SNDCL\\\", \\\"SNDCL\\\":{\\\"KND\\\":\\\"CLDT\\\"}} -->';
}