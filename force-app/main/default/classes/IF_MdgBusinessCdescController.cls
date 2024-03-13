/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-17-2021
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-26   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-11-26   kilhwan.an@partner.samsung.com   - null  예외 처리 추가
 * 1.2   2020-12-07   ghkil@partner.samsung.com   Relation 없는 Data Skip을 위해 IF_Flag 관리
 * 1.3   2020-12-07   kilhwan@partner.samsung.com null 값 데이터 skip
 * 1.4   2020-01-20   kilhwan@partner.samsung.com SPRAS__c 값 key 추가
**/
@RestResource(urlMapping = '/IF109CDESC/*')
global class IF_MdgBusinessCdescController {

    private static final String INTERFACE_ID = 'IF-109CDESC';
    private static final String APEX_CLASS   = 'IF_MdgBusinessCdescController';
    private static final String METHOD_NAME  = 'saveBusinessMaster';    

    private static final Boolean DEBUG_FLAG = true;

    public IF_MdgBusinessCdescController() { }

    @HttpPost
    global Static void saveBusinessMaster() {

        String guId = IF_Util.generateGuid();  

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';

        outHeader.DATA.add(outClass);

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

        // 데이터 파싱
        String inputJsonData = reqBody.toString();//.escapeJava();
        ifLog.addLog('HttpRequest : ' + inputJsonData);

        // 전체 받기
        Map<String, Object> rootMap = (Map<String, Object>)JSON.deserializeUntyped(inputJsonData);
        ifLog.addLog('데이터 파싱 시작');
        system.debug(rootMap);

        // Data부분 필터
        List<Object> dataList = (List<Object>)rootMap.get('DATA');
        ifLog.addLog('데이터 부분 필터');
        system.debug(dataList);

        integer i = 0;
        String dataType = 'ClassDesc';

        List<MDGBusinessMaster__c> saveBusinessList = new List<MDGBusinessMaster__c>();

        for (Object data : dataList) {
            i = i + 1;
            Map<String, Object> dataMap = (Map<String, Object>)data;
            system.debug('dataMap : ' + dataMap);
        
            // BUSINESS 객체 저장
            MDGBusinessMaster__c saveBusiness = new MDGBusinessMaster__c();

            saveBusiness.CLASS__c       = Util_String.nvlStr( dataMap.get('CLASS'));  // Class number
            if( saveBusiness.CLASS__c == '') continue;
        
            saveBusiness.ExternalId__c  = dataType + '|' + (String)dataMap.get('CLASS') + '|' + (String)dataMap.get('SPRAS'); // ExternalId (데이터 타입 + CLASS + SPRAS)
            saveBusiness.IFType__c      = dataType;                                     // 데이터 타입
            saveBusiness.Name           = Util_String.nvlStr( dataMap.get('CLASS'));    // Class number
            saveBusiness.SPRAS__c       = Util_String.nvlStr( dataMap.get('SPRAS'));    // Language Key
            saveBusiness.KLAGR__c       = Util_String.nvlStr( dataMap.get('KLAGR'));    // Class Group
            saveBusiness.KSCHL__c       = Util_String.nvlStr( dataMap.get('KSCHL'));    // Keywords (사업 대분류 이름, 서비스 이름, 솔루션 이름)
            saveBusiness.NORMB__c       = Util_String.nvlStr( dataMap.get('NORMB'));    // Industry Standard Description
            saveBusiness.IFFlag__c      = 'I';                                          // 인터페이스 Flag (최초 처리 시 Insert의 I, Batch(Batch_MdgBusinessController) 처리 후 Complete의 C, Skip의 S )            
            
            saveBusinessList.add(saveBusiness);
        }

        // 1) 해당정보 반영
        Savepoint sp = Database.setSavepoint();
        ifLog.addLog('Data 반영 시작');

        try {                                                        

            // BUSINESS 정보 반영
            upsert saveBusinessList ExternalId__c; 
            if (DEBUG_FLAG) ifLog.addLog('BUSINESS 정보 반영 완료 : ' + saveBusinessList.size());

            // 2) 성공 로그 데이터
            outHeader.TOTAL_COUNT    = saveBusinessList.size(); // BUSINESS 데이터 기준
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  
                        
        } catch (Exception e) {

            // 2) 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);                  
        }

        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT;        // 처리 결과
        @AuraEnabled
        public String EV_MESG;          // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }
    public class OutputClass{
    }    
}