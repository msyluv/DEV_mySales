/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 11-29-2023
 * @last modified by  : chae_ho.yang@samsung.com
**/

public class IF_KnoxChatSendController {

    public static void sendBOOwnerChangeChat(List<String> inputList){
        String oldSingleId = inputList.get(0);
        String newSingleId = inputList.get(1);
        String opportunityName = inputList.get(2);
        String opportunityCode = inputList.get(3);
        String opportunityBeforeOwner = inputList.get(4);
        String opportunityAfterOwner = inputList.get(5);
        String oldOwnerEmail = inputList.get(6);
        String newOwnerEmail = inputList.get(7);
        String opportunityChangeDate = inputList.get(8);
        String opportunityDescription = inputList.get(9);
        String linkAddress = inputList.get(10);

        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('oldSingleId', oldSingleId);
        inputMap.put('newSingleId', newSingleId);
        inputMap.put('opportunityName', opportunityName);
        inputMap.put('opportunityCode', opportunityCode);
        inputMap.put('opportunityBeforeOwner', opportunityBeforeOwner);
        inputMap.put('opportunityAfterOwner', opportunityAfterOwner);
        inputMap.put('oldOwnerEmail', oldOwnerEmail);
        inputMap.put('newOwnerEmail', newOwnerEmail);
        inputMap.put('opportunityChangeDate', opportunityChangeDate);
        inputMap.put('opportunityDescription', opportunityDescription);
        inputMap.put('linkAddress', linkAddress);
		System.debug('oldSingleId' + oldSingleId);
        System.debug('newSingleId' + newSingleId);
        System.debug('opportunityName'+ opportunityName);
        System.debug('opportunityCode'+ opportunityCode);
        System.debug('opportunityBeforeOwner'+ opportunityBeforeOwner);
        System.debug('opportunityAfterOwner'+ opportunityAfterOwner);
        System.debug('oldOwnerEmail' + oldOwnerEmail);
        System.debug('newOwnerEmail' + newOwnerEmail);
        System.debug('opportunityChangeDate' + opportunityChangeDate);
        System.debug('opportunityDescription' + opportunityDescription);
        System.debug('linkAddress' + linkAddress);
        //TID-000001 : BO Owner 변경 알림 Knox Appcard 메세지
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000001', inputMap);
        
        // String appcardContentStr = getBOChangeAdaptiveCardContent(opportunityName
        //                                         ,opportunityCode
        //                                         ,opportunityBeforeOwner
        //                                         ,opportunityAfterOwner
        //                                         ,oldOwnerEmail
        //                                         ,newOwnerEmail
        //                                         ,opportunityCahngeDate
        //                                         ,opportunityDescription
        //                                         ,linkAddress);
		System.debug('#########################sendBOOwnerChangeChat##############################');
        System.debug('oldSingleId : '+ oldSingleId);
        System.debug('newSingleId : '+ newSingleId);
        System.debug('appcardContentStr : '+ appcardContentStr);
        System.debug('#########################sendBOOwnerChangeChat##############################');
        doChat(oldSingleId, newSingleId, appcardContentStr);
    }


    public static void sendLeadOwnerChangeChat(List<String> inputList){
        String oldSingleId = inputList.get(0);
        String newSingleId = inputList.get(1);
        String salesLeadName = inputList.get(2);
        String salesLeadBeforeOwner = inputList.get(3);
        String salesLeadAfterOwner = inputList.get(4);
        String oldOwnerEmail = inputList.get(5);
        String newOwnerEmail = inputList.get(6);
        String salesLeadChangeDate = inputList.get(7);
        String salesLeadDescription = inputList.get(8);
        String linkAddress = inputList.get(9);

        if (String.isBlank(salesLeadDescription)){
            salesLeadDescription = '.';
        }

        
        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('oldSingleId', oldSingleId);
        inputMap.put('newSingleId', newSingleId);
        inputMap.put('salesLeadName', salesLeadName);
        inputMap.put('salesLeadBeforeOwner', salesLeadBeforeOwner);
        inputMap.put('salesLeadAfterOwner', salesLeadAfterOwner);
        inputMap.put('oldOwnerEmail', oldOwnerEmail);
        inputMap.put('newOwnerEmail', newOwnerEmail);
        inputMap.put('salesLeadDescription', salesLeadDescription);
        inputMap.put('salesLeadChangeDate', salesLeadChangeDate);
        inputMap.put('linkAddress', linkAddress);

        //TID-000002 : Lead Owner 변경 알림 Knox Appcard 메세지
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000002', inputMap);
        // String appcardContentStr = getLeadChangeAdaptiveCardContent(salesLeadName
        //                                         ,salesLeadBeforeOwner
        //                                         ,salesLeadAfterOwner
        //                                         ,oldOwnerEmail
        //                                         ,newOwnerEmail
        //                                         ,salesLeadCahngeDate
        //                                         ,salesLeadDescription
        //                                         ,linkAddress);

        doChat(oldSingleId, newSingleId, appcardContentStr);
    }


    public static void sendMarketingLeadOwnerChangeChat(Map<String, String> inputMap){
        String oldSingleId = inputMap.get('oldSingleId');
        String newSingleId = inputMap.get('newSingleId');
        //TID-000003 : 마케팅리드 오너 변경 저장시 알람 전송
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000003', inputMap);
        
        doChat(oldSingleId, newSingleId, appcardContentStr);
    }

    
    public static void sendMarketingLeadConvertedToSalesLeadChat(Map<String, String> inputMap){
        String oldSingleId = inputMap.get('oldSingleId');
        String newSingleId = inputMap.get('newSingleId');
        //TID-000004 : 마케팅 → 사업리드 변환시 알람 전송
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000004', inputMap);
        
        doChat(oldSingleId, newSingleId, appcardContentStr);
    }

    
    public static void sendSalesLeadLateAlarmChat(Map<String, String> inputMap){
        String oldSingleId = inputMap.get('ownerId');
        String newSingleId = inputMap.get('ownerId');
        //TID-000005 : 사업리드 48시간 후에 고객컨택 일시 미등록시 알람
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000005', inputMap);
        
        doChat(oldSingleId, newSingleId, appcardContentStr);
    }

    
    @future(callout=true)
    public static void doChat(String receiveSingleId1, String receiveSingleId2, String appcardContent){
        String APEX_CLASS   = 'OpportunityTrigger';
        String METHOD_NAME_145  = 'createKnoxChatRoomRequest';
        String INTERFACE_ID_145 = 'IF-145';
        String METHOD_NAME_146  = 'doKnoxChatRequest';
        String INTERFACE_ID_146 = 'IF-146';
        String METHOD_NAME_147  = 'getKnoxRegKeyValue';
        String INTERFACE_ID_147 = 'IF-147';
        String METHOD_NAME_148  = 'getChatSenderInfo';
        String INTERFACE_ID_148 = 'IF-148';
        String METHOD_NAME_149  = 'getChatReceiverInfo';
        String INTERFACE_ID_149 = 'IF-149';
        String METHOD_NAME_150  = 'getAES256Key';
        String INTERFACE_ID_150 = 'IF-150';
        
        String strProgressIFID = '';
        String strProgressMethodName = '';

        Map<String,Object> ifResultMap = new Map<String, Object>();
        Map<String,Object> resMap = new Map<String,Object>();

        //IF_Log log;
        IF_Log.InterfaceLog ifLog;
        String guId = '';
        String jsonBody = '';
        IF_Callout call;
        HttpResponse res;
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();

        String appcardContent1 = appcardContent;
        String appcardContent2 = appcardContent;

        Boolean isSandbox = Utils.getIsSandbox();
        //Integer deviceServerID = 0;
            
        try{
            //-------------------------------------------------------------------
            //[1]IF-147 reg
            System.debug('[IF-147]Start');
            strProgressIFID = INTERFACE_ID_147;
            strProgressMethodName = METHOD_NAME_147;
            
            call = new IF_Callout(INTERFACE_ID_147);
            guId = generateUid();
            InputClass_147 input_147 = new InputClass_147();
            jsonBody = JSON.serialize(input_147);
           // resMap = call.httpCallout(jsonBody, '');
            resMap = call.httpKnoxCallout(jsonBody, ''); //Divyam 28nov

            res = (HttpResponse)resMap.get('HttpResponse');
            
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_147, guId, APEX_CLASS, METHOD_NAME_147, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));           
            
            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            Integer deviceServerID = Integer.valueOf(ifResultMap.get('deviceServerID'));
            ifLogList.add(ifLog);
           
            
             //QA
             if(isSandbox){
                deviceServerID = 1000429384;//QA, mysales 계정 기준(해당값 변경시 jitterbit에 if-145, if-146 고정값으로 알려줘야됨)
             }
             else{
				ifResultMap = new Map<String, Object>();
                ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                deviceServerID = Integer.valueOf(ifResultMap.get('deviceServerID'));
             }
            System.debug('#########################IF-147 end##############################');

            //-------------------------------------------------------------------
            //[1]IF-148 info
            //strProgressIFID = INTERFACE_ID_148;
            //strProgressMethodName = METHOD_NAME_148;
            
            // log = new IF_Log();
            // call = new IF_Callout(INTERFACE_ID_148);
            // guId = generateUid();

            // InputClass_148_singleIdList inputClass_148_singleIdList = new InputClass_148_singleIdList();
            // inputClass_148_singleIdList.singleID = 'mysales';
            // InputClass_148 input_148 = new InputClass_148();
            // input_148.singleIdList = new List<InputClass_148_singleIdList>();
            // input_148.singleIdList.add(inputClass_148_singleIdList);
            // input_148.deviceServerID = deviceServerID;//1000259729;

            // jsonBody = JSON.serialize(input_148);
            // resMap = call.httpCallout(jsonBody, '');
            // res = (HttpResponse)resMap.get('HttpResponse');
            // ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_148, guId, APEX_CLASS, METHOD_NAME_148, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            // ifLogList.add(ifLog);
            // ifResultMap = new Map<String, Object>();
            // ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            // List<Object> userDeviceList = new List<Object>();
            // userDeviceList = ((List<Object>)ifResultMap.get('userDeviceList'));
            // String if148SingleId = String.valueOf(((Map<String, Object>)userDeviceList.get(0)).get('singleID'));
            // String if148UserId = String.valueOf(((Map<String, Object>)userDeviceList.get(0)).get('userID'));
                                

            //-------------------------------------------------------------------
            //[1]IF-149 loginId
            //
            strProgressIFID = INTERFACE_ID_149;
            strProgressMethodName = METHOD_NAME_149;
            
            //log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_149);
            guId = generateUid();

            //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
            // InputClass_149_singleIdList receiver1 = new InputClass_149_singleIdList();
            // receiver1.singleID = receiveSingleId1;
            InputClass_149_singleIdList receiver2 = new InputClass_149_singleIdList();
            receiver2.singleID = receiveSingleId2;
            InputClass_149 input_149 = new InputClass_149();
            input_149.singleIdList = new List<InputClass_149_singleIdList>();
            // input_149.singleIdList.add(receiver1);
            input_149.singleIdList.add(receiver2);
            input_149.deviceServerID = deviceServerID;//1000259729;
			jsonBody = JSON.serialize(input_149);
           // resMap = call.httpCallout(jsonBody, '');
            resMap = call.httpKnoxCallout(jsonBody, ''); //Divyam 28nov
            res = (HttpResponse)resMap.get('HttpResponse');
                        

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_149, guId, APEX_CLASS, METHOD_NAME_149, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        	

            ifResultMap = new Map<String, Object>();
            ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
            Map<String, Object> userSearchResult = new Map<String, Object>();
            List<Object> searchResultList = new List<Object>();
            // String IF_149_Result_receiverUserId1 = '';
            String IF_149_Result_receiverUserId2 = '';

            if(Test.isRunningTest()){
                // IF_149_Result_receiverUserId1 = '840967548745814017';//oldman.sea
                // IF_149_Result_receiverUserId2 = '851034545723543553';//wonjun98.lee
            }
            else{
                userSearchResult.putAll((Map<String, Object>)ifResultMap.get('userSearchResult'));            
                searchResultList = ((List<Object>)userSearchResult.get('searchResultList'));
                // IF_149_Result_receiverUserId1 = String.valueOf(((Map<String, Object>)searchResultList.get(0)).get('userID'));
                IF_149_Result_receiverUserId2 = String.valueOf(((Map<String, Object>)searchResultList.get(0)).get('userID'));
                ifLogList.add(ifLog);
            }
            
            
            //-------------------------------------------------------------------
            //[1]IF-150 getKeys
            
            strProgressIFID = INTERFACE_ID_150;
            strProgressMethodName = METHOD_NAME_150;
            
            call = new IF_Callout(INTERFACE_ID_150);
            guId = generateUid();

            InputClass_150 input_150 = new InputClass_150();
            input_150.deviceServerID = deviceServerID;
        
            jsonBody = JSON.serialize(input_150);
            //resMap = call.httpCallout(jsonBody, '');
            resMap = call.httpKnoxCallout(jsonBody, ''); //Divyam 28nov
            String AES256Key = '';
            if(Test.isRunningTest()){
                AES256Key = System.Label.COMM_LAB_AES256KEY;
            }
            else{
                res = (HttpResponse)resMap.get('HttpResponse');
                
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_150, guId, APEX_CLASS, METHOD_NAME_150, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))); 
                
				ifResultMap = new Map<String, Object>();
                ifResultMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                AES256Key = String.valueOf(ifResultMap.get('key'));
                //AES256Key =System.Label.COMM_LAB_AES256KEY;
                ifLogList.add(ifLog);
            }
            


            //-------------------------------------------------------------------
            //[1]IF-145 creatChatRoom
            //chatType 5 : 1:1공지방
            
            strProgressIFID = INTERFACE_ID_145;
            strProgressMethodName = METHOD_NAME_145;
            
            //log = new IF_Log();
            call = new IF_Callout(INTERFACE_ID_145);
            String chatType = '5';
            String origin1 = '';
            String origin2 = '';
            String chatRoomId1 = '';
            String chatRoomId2 = '';
            String encoded1 = '';
            String encoded2 = '';

            guId = generateUid();
            // origin1 = '{'
            //             + '\'requestId\':\'' + guId +'\'' + ','
            //             + '\'chatType\':\'' + chatType +'\'' + ','
            //             + '\'receivers\':[' + String.valueOf(IF_149_Result_receiverUserId1) +']'
            //             + '}';

            guId = generateUid();
            origin2 = '{'
                        + '\'requestId\':\'' + guId +'\'' + ','
                        + '\'chatType\':\'' + chatType +'\'' + ','
                        + '\'receivers\':[' + String.valueOf(IF_149_Result_receiverUserId2) +']'
                        + '}';      
            
            //첫번째 수신자 용 1:1공지방 생성
            // Blob encrypted1 = doEncryptAndEncode(AES256Key, origin1);
            // encoded1 = EncodingUtil.base64Encode(encrypted1);
            // jsonBody = '("'+encoded1+'")';
            //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
            // resMap = call.httpCallout(jsonBody, '');
            // res = (HttpResponse)resMap.get('HttpResponse');
            // ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_145, guId, APEX_CLASS, METHOD_NAME_145, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            
            String jitterbitMessage = '';
            String decrpytedStr = '';
            Map<String,Object> resultMap145 = new Map<String,Object>();

            // if(!(Test.isRunningTest())){
                //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
                // jitterbitMessage = String.valueOf(resMap.get('Response'));
                // decrpytedStr = doDecryptAndDecode(AES256Key, EncodingUtil.base64Decode(jitterbitMessage));
                // resultMap145 = (Map<String,Object>) JSON.deserializeUntyped(decrpytedStr);
                // chatRoomId1 = String.valueOf(resultMap145.get('chatroomId'));
                // appcardContent1 = appcardContent1.replace('XYZCHATROOMIDXYZ', chatRoomId1);
            // }
            


            //두번째 수신자 용 1:1공지방 생성
            call = new IF_Callout(INTERFACE_ID_145);
            Blob encrypted2 = doEncryptAndEncode(AES256Key, origin2);
            encoded2 = EncodingUtil.base64Encode(encrypted2);
			//chae_ho.yang 23.11.29 siis 전환용 품질서버 로직 추가
            if (isSandbox) {
                InputClass_145 input_145 = new InputClass_145();
                input_145.deviceServerID = deviceServerID;
                input_145.BODY = encoded2;
                jsonBody = JSON.serialize(input_145);
            } else {
                jsonBody = '("'+encoded2+'")';
            }
            system.debug('encrypted : ' + jsonBody);
          //  resMap = call.httpCallout(jsonBody, '');
            resMap = call.httpKnoxCallout(jsonBody, ''); //Divyam 28nov
            res = (HttpResponse)resMap.get('HttpResponse');

            if(!(Test.isRunningTest())){
                jitterbitMessage = String.valueOf(resMap.get('Response'));
                decrpytedStr = doDecryptAndDecode(AES256Key, EncodingUtil.base64Decode(jitterbitMessage));
                resultMap145 = (Map<String,Object>) JSON.deserializeUntyped(decrpytedStr);
                chatRoomId2 = String.valueOf(resultMap145.get('chatroomId'));
                appcardContent2 = appcardContent2.replace('XYZCHATROOMIDXYZ', chatRoomId2);
                
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_145, guId, APEX_CLASS, METHOD_NAME_145, origin2, decrpytedStr);
                ifLogList.add(ifLog);
            }
            

            //-------------------------------------------------------------------
            //[1]IF-146 chatRequest

            //첫번째 수신자 채팅 전송
            // log = new IF_Log();
            // call = new IF_Callout(INTERFACE_ID_146);
            // guId = generateUid();
            
            //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
            // encrypted1 = doEncryptAndEncode(AES256Key, appcardContent1);
            // encoded1 = EncodingUtil.base64Encode(encrypted1);
            // jsonBody = '("'+encoded1+'")';            
            // resMap = call.httpCallout(jsonBody, '');

            // if(!(Test.isRunningTest())){
                //변경전 사용자에겐 안보내고, 변경후 사용자에게만 보내도록 함(2021.10.25)
                // res = (HttpResponse)resMap.get('HttpResponse');
                // ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            // }
            
            //두번째 수신자 채팅 전송
         
            strProgressIFID = INTERFACE_ID_146;
            strProgressMethodName = METHOD_NAME_146;
            
            
            call = new IF_Callout(INTERFACE_ID_146);
            guId = generateUid();
            
            encrypted2 = doEncryptAndEncode(AES256Key, appcardContent2);
            encoded2 = EncodingUtil.base64Encode(encrypted2);
            //chae_ho.yang 23.11.29 siis 전환용 품질서버 로직 추가
            if (isSandbox) {
                InputClass_146 input_146 = new InputClass_146();
                input_146.deviceServerID = deviceServerID;
                input_146.BODY = encoded2;
                jsonBody = JSON.serialize(input_146);
            } else {
                jsonBody = '("'+encoded2+'")';
            }
            //resMap = call.httpCallout(jsonBody, '');        	               
            resMap = call.httpKnoxCallout(jsonBody, ''); //Divyam 28nov

            String jitterbitMessage146 = '';
            String decrpytedStr146 = '';
            
            if(!(Test.isRunningTest())){
                res = (HttpResponse)resMap.get('HttpResponse');
                
                jitterbitMessage146 = String.valueOf(resMap.get('Response'));
                decrpytedStr146 = doDecryptAndDecode(AES256Key, EncodingUtil.base64Decode(jitterbitMessage146));
                
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID_146, guId, APEX_CLASS, METHOD_NAME_146, appcardContent2, decrpytedStr146);
                
                ifLogList.add(ifLog);
            }
            
        } catch(DmlException e){
            System.debug('KnoxChat e.getMessage : ' + e.getMessage());
            System.debug('KnoxChat e.getDMLMessage(0) : ' + e.getDMLMessage(0));
            
            ifLog = new IF_Log.InterfaceLog(strProgressIFID, guId, APEX_CLASS, strProgressMethodName,'','',e);
            ifLogList.add(ifLog);
        } catch(Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');            
            
            ifLog = new IF_Log.InterfaceLog(strProgressIFID, guId, APEX_CLASS, strProgressMethodName,'','',e);
            ifLogList.add(ifLog);
        }finally{
            new IF_Log().createLog(ifLogList);
        }
		
    }



    //AES256 key와 원문String을 인자로 입력받아 암호화하여 리턴한다
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

    //IF-145 -------------------------------------------------------------------
    //INPUT : IF-145 (Knox chatroom create)
    public class InputClass_145{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public String BODY;
    }

    //IF-146 -------------------------------------------------------------------
    //INPUT : IF-146 (Knox send message)
    public class InputClass_146{
        @AuraEnabled
        public Integer deviceServerID;
        @AuraEnabled
        public String BODY;
    }
    
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


    public static String getBOChangeAdaptiveCardContent(String opportunityName
                                                       ,String opportunityCode
                                                       ,String opportunityBeforeOwner
                                                       ,String opportunityAfterOwner
                                                       ,String oldOwnerEmail
                                                       ,String newOwnerEmail
                                                       ,String opportunityCahngeDate
                                                       ,String opportunityDescription
                                                       ,String linkAddress){
        String UNCOMPRESSED_TAG = '<!-- {\\\"COMMAND\\\":\\\"SNDCL\\\", \\\"SNDCL\\\":{\\\"KND\\\":\\\"CLDT\\\"}} -->';

        long currentTimeMillis = Datetime.now().getTime();
	    long currentTimeMillis2 = Datetime.now().getTime();
	    String temp1 = '{\'requestId\':' + currentTimeMillis + ',\'chatroomId\':\'XYZCHATROOMIDXYZ\',\'chatMessageParams\':[{\'msgType\':\'19\',\'msgId\':'+currentTimeMillis2+','
						+  '\'chatMsg\':';
		String temp2 = '}]}';

	    String bodyTemp =
                    '{\\\"adaptiveCards\\\":'
                    + '\\\"'//start of adaptiveCards
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"AdaptiveCard\\\\\",'
                    +'\\\\\"$schema\\\\\": \\\\\"http://adaptivecards.io/schemas/adaptive-card.json\\\\\",'
                    +'\\\\\"version\\\\\": \\\\\"1.3\\\\\",'
                    +'\\\\\"body\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Container\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"SAMSUNG SDS mySales\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"size\\\\\": \\\\\"Medium\\\\\",'
                    +'\\\\\"weight\\\\\": \\\\\"Bolder\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"24px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Image\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"24px\\\\\",'
                    +'\\\\\"height\\\\\": \\\\\"24px\\\\\",'
                    +'\\\\\"style\\\\\": \\\\\"Person\\\\\",'
                    +'\\\\\"url\\\\\": \\\\\"https://ktaproxy.samsung.net/appbridge/images/ic_profile_default.png\\\\\"'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"530px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityName + '\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"weight\\\\\": \\\\\"Bolder\\\\\",'
                    +'\\\\\"color\\\\\": \\\\\"Accent\\\\\",'
                    +'\\\\\"size\\\\\": \\\\\"Large\\\\\",'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'}'
                    +'],'
                    +'\\\\\"verticalContentAlignment\\\\\": \\\\\"Center\\\\\",'
                    +'\\\\\"spacing\\\\\": \\\\\"Medium\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"ExtraLarge\\\\\",'
                    +'\\\\\"separator\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회(Business Opportunity)의 소유자(Owner)가 변경되었습니다.\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"spacing\\\\\": \\\\\"Large\\\\\",'
                    +'\\\\\"weight\\\\\": \\\\\"Bolder\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Owner of Business Opportunity has changed)\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\",'
                    +'\\\\\"weight\\\\\": \\\\\"Bolder\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Container\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 명\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Business Opportunity Name)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityName + '\\\\\",'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 코드\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Business Opportunity Code)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityCode + '\\\\\",'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"separator\\\\\":true'                            
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 변경 전 소유자 \\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Owner Before)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityBeforeOwner + '(' + oldOwnerEmail +')\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"separator\\\\\":true'                            
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 변경 후 소유자 \\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Owner After)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityAfterOwner + '(' + newOwnerEmail + ')\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"separator\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 개요\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Description)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityDescription + '\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"separator\\\\\":true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"ColumnSet\\\\\",'
                    +'\\\\\"columns\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"200px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"사업기회 소유자 변경일자\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"isSubtle\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\",'
                    +'\\\\\"wrap\\\\\": true'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"(Change Date)\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"isSubtle\\\\\": true'
                    +'}'
                    +']'
                    +'},'
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Column\\\\\",'
                    +'\\\\\"width\\\\\": \\\\\"280px\\\\\",'
                    +'\\\\\"items\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"TextBlock\\\\\",'
                    +'\\\\\"text\\\\\": \\\\\"' + opportunityCahngeDate + '\\\\\",'
                    +'\\\\\"fontType\\\\\": \\\\\"Default\\\\\",'
                    +'\\\\\"wrap\\\\\": true,'
                    +'\\\\\"height\\\\\": \\\\\"auto\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"None\\\\\"'
                    +'}'
                    +'],'
                    +'\\\\\"separator\\\\\":true'
                    +'}'
                    +'],'
                    +'\\\\\"spacing\\\\\": \\\\\"Large\\\\\",'
                    +'\\\\\"style\\\\\": \\\\\"emphasis\\\\\",'
                    +'\\\\\"bleed\\\\\": true,'
                    +'\\\\\"separator\\\\\":true'
                    +'}'
                    +'],'
                    +'\\\\\"backgroundImage\\\\\": {},'
                    +'\\\\\"actions\\\\\": ['
                    +'{'
                    +'\\\\\"type\\\\\": \\\\\"Action.OpenUrl\\\\\",'
                    +'\\\\\"title\\\\\": \\\\\"해당 BO 바로가기\\\\\",'
                    +'\\\\\"style\\\\\": \\\\\"positive\\\\\",'
                    +'\\\\\"url\\\\\": \\\\\"' + linkAddress + '\\\\\"'
                    +'}'
                    +']'
                    +'}'
                    +'\\\"'//end of adaptiveCards
                    +'}';
	    String origin = temp1 + '\'' + UNCOMPRESSED_TAG + bodyTemp + '\'' + temp2;

	    return origin;
	}


    public static String getLeadChangeAdaptiveCardContent(String salesLeadName
                                                ,String salesLeadBeforeOwner
                                                ,String salesLeadAfterOwner
                                                ,String oldOwnerEmail
                                                ,String newOwnerEmail
                                                ,String salesLeadCahngeDate
                                                ,String salesLeadDescription
                                                ,String linkAddress){
            String UNCOMPRESSED_TAG = '<!-- {\\\"COMMAND\\\":\\\"SNDCL\\\", \\\"SNDCL\\\":{\\\"KND\\\":\\\"CLDT\\\"}} -->';

            long currentTimeMillis = Datetime.now().getTime();
            long currentTimeMillis2 = Datetime.now().getTime();
            String temp1 = '{\'requestId\':' + currentTimeMillis + ',\'chatroomId\':\'XYZCHATROOMIDXYZ\',\'chatMessageParams\':[{\'msgType\':\'19\',\'msgId\':'+currentTimeMillis2+','
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
                            +'\\\\\"text\\\\\":\\\\\"SAMSUNG SDS mySales\\\\\",'
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
                            +'\\\\\"width\\\\\":\\\\\"auto\\\\\",'
                            +'\\\\\"items\\\\\":['
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadName + '\\\\\",'
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
                            +'\\\\\"text\\\\\":\\\\\"사업리드 소유자 변경안내\\\\\",'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"wrap\\\\\":true,'
                            +'\\\\\"spacing\\\\\":\\\\\"Large\\\\\",'
                            +'\\\\\"weight\\\\\":\\\\\"Bolder\\\\\"'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"사업리드(Sales Lead)의 소유자(Owner)가 변경되었습니다.\\\\\",'
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
                            +'\\\\\"text\\\\\":\\\\\"사업리드 명\\\\\",'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"isSubtle\\\\\":true'
                            +'}'
                            +']'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                            +'\\\\\"width\\\\\":\\\\\"auto\\\\\",'
                            +'\\\\\"items\\\\\":['
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadName + '\\\\\",'
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
                            +'\\\\\"text\\\\\":\\\\\"변경 전 소유자\\\\\",'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"isSubtle\\\\\":true'
                            +'}'
                            +']'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                            +'\\\\\"width\\\\\":\\\\\"auto\\\\\",'
                            +'\\\\\"items\\\\\":['
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadBeforeOwner + '(' + oldOwnerEmail +')\\\\\",'
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
                            +'\\\\\"text\\\\\":\\\\\"변경 후 소유자\\\\\",'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"isSubtle\\\\\":true'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"사업리드 개요\\\\\",'
                            +'\\\\\"wrap\\\\\":true,'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"isSubtle\\\\\":true'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"소유자 변경일자\\\\\",'
                            +'\\\\\"wrap\\\\\":true,'
                            +'\\\\\"isSubtle\\\\\":true,'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                            +'}'
                            +']'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"Column\\\\\",'
                            +'\\\\\"width\\\\\":\\\\\"auto\\\\\",'
                            +'\\\\\"items\\\\\":['
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadAfterOwner + '(' + newOwnerEmail + ')\\\\\",'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\",'
                            +'\\\\\"wrap\\\\\":true'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadDescription + '\\\\\",'
                            +'\\\\\"wrap\\\\\":true,'
                            +'\\\\\"fontType\\\\\":\\\\\"Default\\\\\"'
                            +'},'
                            +'{'
                            +'\\\\\"type\\\\\":\\\\\"TextBlock\\\\\",'
                            +'\\\\\"text\\\\\":\\\\\"' + salesLeadCahngeDate + '\\\\\",'
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
                            +'\\\\\"title\\\\\":\\\\\"해당 Lead 바로가기\\\\\",'
                            +'\\\\\"style\\\\\":\\\\\"positive\\\\\",'
                            +'\\\\\"url\\\\\":\\\\\"' + linkAddress + '\\\\\"'
                            +'}'
                            +']'
                            +'}'
                            +'\\\"'//end of adaptiveCards
                            +'}';
            String origin = temp1 + '\'' + UNCOMPRESSED_TAG + bodyTemp + '\'' + temp2;
    
            return origin;                                   
    }
    public static String convertTemplate(String origin, Map<String, String> convertMap){
        if (convertMap!=null && !convertMap.isEmpty()){
            Set<String> keySet = convertMap.keySet();
            List<String> keyList = new List<String>();
            keyList.addAll(keySet);

            for(String key : keyList){
                if (key==null || String.isBlank(key)) key = '';
                String val = convertMap.get(key);
                if (val==null || String.isBlank(val)) val = '';
                origin = origin.replaceAll('@#@#' + key + '@#@#', val.replaceAll('[$"\\\']',''));
            }
        }

        return origin;
    }


    public static String getChatTemplate(String templateId, String lang){

        if (lang==null || lang==''){
            lang = 'ko_KR';
        }

        Integer cntCheck = [select count()
                            from ChatTemplate__c
                            where Name = :templateId
                            and Language__c = :lang
                            limit 1];

        if (cntCheck==null || cntCheck < 1){
            lang = 'ko_KR';
        }
        
        String result = '';

        if(Test.isRunningTest()){
            lang = 'ko_KR';
            result = 'NO TEMPLATE';
        }
        else{
            ChatTemplate__c template = [select Name
                                        , Platform__c
                                        , TemplateType__c
                                        , Template__c
                                    from ChatTemplate__c
                                    where Name = :templateId
                                    and Language__c = :lang
                                    limit 1];

            result = template.Template__c;
        }
        
        
        if( result!=null && result!='null' && result != ''){
            result = result.replaceAll('&quot;', '"');
            result = result.replaceAll('<p>', '');
            result = result.replaceAll('</p>', '');
        }

        return result;
    }


    public static String getKnoxAppcardMessageContents(String tid, Map<String, String> convertMap){
        String UNCOMPRESSED_TAG = '<!-- {\\\"COMMAND\\\":\\\"SNDCL\\\", \\\"SNDCL\\\":{\\\"KND\\\":\\\"CLDT\\\"}} -->';

        long currentTimeMillis = Datetime.now().getTime();
	    long currentTimeMillis2 = Datetime.now().getTime();
	    String temp1 = '{\'requestId\':' + currentTimeMillis + ',\'chatroomId\':\'XYZCHATROOMIDXYZ\',\'chatMessageParams\':[{\'msgType\':\'19\',\'msgId\':'+currentTimeMillis2+','
						+  '\'chatMsg\':';
		String temp2 = '}]}';

        String language = UserInfo.getLanguage();
	    String bodyTemp = getChatTemplate(tid, language);
        bodyTemp = convertTemplate(bodyTemp, convertMap);

	    String origin = temp1 + '\'' + UNCOMPRESSED_TAG + bodyTemp + '\'' + temp2;

	    return origin;
	}


    public static String sendBOOwnerChangeChat2(List<String> inputList){
        String oldSingleId = inputList.get(0);
        String newSingleId = inputList.get(1);
        String opportunityName = inputList.get(2);
        String opportunityCode = inputList.get(3);
        String opportunityBeforeOwner = inputList.get(4);
        String opportunityAfterOwner = inputList.get(5);
        String oldOwnerEmail = inputList.get(6);
        String newOwnerEmail = inputList.get(7);
        String opportunityChangeDate = inputList.get(8);
        String opportunityDescription = inputList.get(9);
        String linkAddress = inputList.get(10);

        if (String.isBlank(opportunityDescription)){
            opportunityDescription = '.';
        }

        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('oldSingleId', oldSingleId);
        inputMap.put('newSingleId', newSingleId);
        inputMap.put('opportunityName', opportunityName);
        inputMap.put('opportunityCode', opportunityCode);
        inputMap.put('opportunityBeforeOwner', opportunityBeforeOwner);
        inputMap.put('opportunityAfterOwner', opportunityAfterOwner);
        inputMap.put('oldOwnerEmail', oldOwnerEmail);
        inputMap.put('newOwnerEmail', newOwnerEmail);
        inputMap.put('opportunityChangeDate', opportunityChangeDate);
        inputMap.put('opportunityDescription', opportunityDescription);
        inputMap.put('linkAddress', linkAddress);

        //TID-000001 : BO Owner 변경 알림 Knox Appcard 메세지
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000001', inputMap);

        doChat(oldSingleId, newSingleId, appcardContentStr);

        return appcardContentStr;
    }



    public static String sendLeadOwnerChangeChat2(List<String> inputList){
        String oldSingleId = inputList.get(0);
        String newSingleId = inputList.get(1);
        String salesLeadName = inputList.get(2);
        String salesLeadBeforeOwner = inputList.get(3);
        String salesLeadAfterOwner = inputList.get(4);
        String oldOwnerEmail = inputList.get(5);
        String newOwnerEmail = inputList.get(6);
        String salesLeadChangeDate = inputList.get(7);
        String salesLeadDescription = inputList.get(8);
        String linkAddress = inputList.get(9);

        if (String.isBlank(salesLeadDescription)){
            salesLeadDescription = '.';
        }

        
        Map<String, String> inputMap = new Map<String, String>();
        inputMap.put('oldSingleId', oldSingleId);
        inputMap.put('newSingleId', newSingleId);
        inputMap.put('salesLeadName', salesLeadName);
        inputMap.put('salesLeadBeforeOwner', salesLeadBeforeOwner);
        inputMap.put('salesLeadAfterOwner', salesLeadAfterOwner);
        inputMap.put('oldOwnerEmail', oldOwnerEmail);
        inputMap.put('newOwnerEmail', newOwnerEmail);
        inputMap.put('salesLeadDescription', salesLeadDescription);
        inputMap.put('salesLeadChangeDate', salesLeadChangeDate);
        inputMap.put('linkAddress', linkAddress);
        inputMap.put('salesLeadOwner', 'salesLeadOwner');
        inputMap.put('ownerEmail', 'ownerEmail');
        inputMap.put('salesLeadCreateDate', 'salesLeadCreateDate');
        inputMap.put('replyDeadline', 'replyDeadline');
        


        inputMap.put('marketingLeadName', '마케팅 리드 명');
        inputMap.put('marketingLeadBeforeOwner', '마케팅리드전소유자');
        inputMap.put('marketingLeadAfterOwner', '마케팅리드 나중소유자');
        inputMap.put('marketingLeadDescription', '마케팅리드 데스크립션');
        inputMap.put('marketingLeadChangeDate', 'marketingLeadChangeDate');
        
        //TID-000002 : Lead Owner 변경 알림 Knox Appcard 메세지
        String appcardContentStr =  getKnoxAppcardMessageContents('TID-000002', inputMap);

        doChat(oldSingleId, newSingleId, appcardContentStr);

        appcardContentStr = getKnoxAppcardMessageContents('TID-000003', inputMap);
        doChat(oldSingleId, newSingleId, appcardContentStr);

        appcardContentStr = getKnoxAppcardMessageContents('TID-000004', inputMap);
        doChat(oldSingleId, newSingleId, appcardContentStr);

        appcardContentStr = getKnoxAppcardMessageContents('TID-000005', inputMap);
        doChat(oldSingleId, newSingleId, appcardContentStr);


        return appcardContentStr;
    }
}