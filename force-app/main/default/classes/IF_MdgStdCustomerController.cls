/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-19
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-30   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-12-30   ghkil@partner.samsung.com   동일 정보 요청 시 처리되도록 보완
**/
@RestResource( UrlMapping='/IF117/*')
global class IF_MdgStdCustomerController {

    private static final String INTERFACE_ID = 'IF-117';
    private static final String APEX_CLASS   = 'IF_MdgStdCustomerController';
    private static final String METHOD_NAME  = 'regStandardCustomer';

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static void regStandardCustomer() {

        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';
        
        String sendData;

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        RestResponse rep = RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        if( reqBody == null ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }      

        // 입력 받은 데이터
        String inputJsonData = reqBody.toString();
        system.debug('inputJsonData : ' + inputJsonData);
        InputHeader       inputHeader  =  ( InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
        List<InputClass> inputDataList = inputHeader.DATA;
        if (inputDataList == null || inputDataList.size() == 0) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }
        if (DEBUG_FLAG) ifLog.addLog('데이터 수신');
               
        // 해당정보 반영
        Savepoint sp = Database.setSavepoint();
        ifLog.addLog('Data 반영 시작');

        try {

            //  데이터 매핑
            List<StandardCustomer__c> saveStandardCustomerList = new List<StandardCustomer__c>();
            Map<String, InputClass> insertInputClassMap = new Map<String, InputClass>();  // 요청 데이터 중복 체크용
            Integer upsertCount = 0;
            for (InputClass inClass : inputDataList) {

                StandardCustomer__c saveStandardCustomer = new StandardCustomer__c();
         
                // 중복 건 있으면 먼저 반영 후 먼저 반영한 List, Map 초기화 후 다시 진행
                if (insertInputClassMap.get(inClass.ZZNStKun) != null) {
                    
                    upsert saveStandardCustomerList Name;
                    upsertCount = upsertCount + saveStandardCustomerList.size();

                    saveStandardCustomerList.clear();
                    insertInputClassMap.clear();
                }
                insertInputClassMap.put(inClass.ZZNStKun, inClass);       // 중복 체크용 Map에 적재

                saveStandardCustomer.Name           = inClass.ZZNStKun;     // Standard Customer (New)
                saveStandardCustomer.LAND1__c       = inClass.Land1;        // Country Key
                saveStandardCustomer.ZZSTLEVEL__c   = inClass.ZZStLevel;    // Standard Customer Level
                saveStandardCustomer.ZZHSTLEVEL__c  = inClass.ZZHstLevel;   // Standard Customer Higher Level
                saveStandardCustomer.ZZSTCNAME1__c  = inClass.ZZStcName1;   // Standard Customer Name (Korean)
                saveStandardCustomer.ZZSTCNAME2__c  = inClass.ZZStcName2;   // Standard Customer Name (English)
                saveStandardCustomer.ZZSTCDESC__c   = inClass.ZZStcDesc;    // Standard Customer Description
                saveStandardCustomer.ZZDEL__c       = inClass.ZZDel;        // Deletion Flag

                saveStandardCustomerList.add(saveStandardCustomer);
            }

            upsert saveStandardCustomerList Name; // Name으로 External Id 처리
            upsertCount = upsertCount + saveStandardCustomerList.size();

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = upsertCount;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                  = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  

        }catch( Exception e){
            
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);               
        }finally{

            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
     
    }

    // Jitterbit에서 수신한 Data
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;
        @AuraEnabled
        public Integer PAGE_COUNT;
        @AuraEnabled
        public Integer PAGE_NUM;        
        @AuraEnabled
        public List<InputClass> DATA;
    }
    public class InputClass{

        @AuraEnabled
        public String ZZNStKun;             // Standard Customer (New)
        @AuraEnabled
        public String Land1;                // Country Key
        @AuraEnabled
        public String ZZStLevel;            // Standard Customer Level
        @AuraEnabled
        public String ZZHstLevel;           // Standard Customer Higher Level
        @AuraEnabled
        public String ZZStcName1;           // Standard Customer Name (Korean)
        @AuraEnabled
        public String ZZStcName2;           // Standard Customer Name (English)
        @AuraEnabled
        public String ZZStcDesc;            // Standard Customer Description
        @AuraEnabled
        public String ZZDel;                // Deletion Flag
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;         // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT;            // 처리 결과
        @AuraEnabled
        public String EV_MESG;              // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA;      // 데이터 포멧
    }
    public class OutputClass{

    }
}