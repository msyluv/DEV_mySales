/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-05
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-12-08   ghkil@partner.samsung.com         Initial Version
 * 1.1   2021-03-05   kilhwan.an@partner.samsung.com    true=>X 로 처리
**/
@RestResource( UrlMapping='/IF033/*')
global class IF_EccResourcePreInputController {

    private static final String INTERFACE_ID = 'IF-033';
    private static final String APEX_CLASS   = 'IF_EccResourcePreInputController';
    private static final String METHOD_NAME  = 'setResourcePreInput';

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static void setResourcePreInput(){

        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.DATA           = new List<OutputClass>();
        OutputClass outClass     = new OutputClass();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RETURN      = '0';
        outHeader.EV_MESSAGE     = '';
        
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

            // 입력 데이터 확인 후 Map 적재
            Map<String, String> opportunityMap = new Map<String, String>();
            for (InputClass inClass : inputDataList) {
                opportunityMap.put(inClass.IV_PROJECT, inClass.IV_INPUT_P);
            }

            // update Data 조회
            List<Opportunity> updateOpportunityList = [
                Select  Id, 
                        OpportunityCode__c,
                        ResourcePreInput__c
                From    Opportunity
                Where   OpportunityCode__c = :opportunityMap.keySet()
            ];

            // 데이터 Update
            for (Opportunity updateData : updateOpportunityList) {

                if (opportunityMap.get(updateData.OpportunityCode__c).toUpperCase() == 'X') {
                    updateData.ResourcePreInput__c = true;
                }
                else if (opportunityMap.get(updateData.OpportunityCode__c).toUpperCase() != 'X') {
                    updateData.ResourcePreInput__c = false;
                }
            }

            update updateOpportunityList;

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = updateOpportunityList.size();
            outHeader.EV_RETURN      = '0';
            outHeader.EV_MESSAGE     = IF_Util.RESULT_MESSAGE_SUCCESS;
            sendData                 = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  

        }catch( Exception e){
            Database.rollback(sp);

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RETURN      = '1';
            outHeader.EV_MESSAGE     = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
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

    //  넘어온값
    public class InputClass{

        @AuraEnabled
        public String IV_PROJECT;       // 사업코드(프로젝트)
        @AuraEnabled
        public String IV_INPUT_P;       // 선투입여부
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 전체 데이터 건수
        @AuraEnabled
        public String EV_RETURN;        // 처리 결과
        @AuraEnabled
        public String EV_MESSAGE;       // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA;  // 데이터 포멧
    }
    public class OutputClass{

    }
}