/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-30
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-11   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-11-24   ghkil@partner.samsung.com         Json Fomat에 맞춰 bypass 형태로 수정
 * 1.2   2020-11-24   ghkil@partner.samsung.com         인터페이스정의서 변경에 따른 수정 (항목 추가) 
 * 1.3   2020-11-28   kilhwan.an@partner.samsung.com    POST1 (프로젝트명 추가)
 * 1.4   2020-12-23   ghkil@partner.samsung.com         return Type Class에서 Map으로 변경
 * 1.5   2021-01-21   ghkil@partner.samsung.com         Batch Log 처리를 위한 보완 (Batch에서 호출할 경우 return값 변경 전달)
 * 1.6   2021-03-02   kilhwan.an@partner.samsung.com    isBatch, batchId public 변경    
**/
global class IF_EccProjectInfoController {

    private static final String INTERFACE_ID = 'IF-004';
    private static final String APEX_CLASS   = 'IF_EccProjectInfoController';
    private static final String METHOD_NAME  = 'calloutProjectInfo';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    public static Boolean isBatch = false;
    public static String  batchId = null;
    public IF_EccProjectInfoController() { }

    public IF_EccProjectInfoController(Boolean batchType, String jobId) {
        isBatch = batchType;
        batchId = jobId;
    }

    @AuraEnabled
    public static Map<String, Object> calloutProjectInfo(String inputJsonData){

        String guId = IF_Util.generateGuid();

        Map<String, Object> result = new Map<String, Object>();

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            // OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            // if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');
            // result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            result = ifCallout.httpCallout(inputJsonData, '');
            ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                if (isBatch) {
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME + '(' + batchId + ')', reqMsg, resMsg);
                } else {
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
                }
            } else {
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                if (isBatch) {
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME + '(' + batchId + ')', reqMsg, resMsg, errorMsgList);
                } else {
                    interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
                }
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            if (isBatch) {
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME + '(' + batchId + ')', reqMsg, resMsg, e);
            } else {
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
            }
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            if (isBatch == false) {
                ifLog.createLog(interfaceLog);
            } else {
                result.clear();
                result.put('interfaceLog', interfaceLog);
            }
        }

        return result;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public String IV_ZZORDER_ID;    // B/O Code / OpportunityCode__c, 사업 기회 Code
        @AuraEnabled
        public String IV_PSPID;         // Project Definition / ProjectCode__c, Project Code
        @AuraEnabled
        public String IV_BUKRS;         // Company Code / CompanyCode__c, Company Code        
        @AuraEnabled
        public String IV_PROCESS_TYPE;  // Process type / ActivityStatus__c, Current BO Activity Status
        @AuraEnabled
        public List<OUTPUT_IT_PROJ> IT_PROJ;
    }
    public class OUTPUT_IT_PROJ{        
        
        @AuraEnabled
        public String ZZORDER_ID;       // BO코드 (OpportunityCode__c, 사업 기회 Code)
        @AuraEnabled
        public String ZZBUKRS_H;        // 회사코드 (CompanyCode__c, Company Code)
        @AuraEnabled
        public String PSPID;            // 프로젝트코드 (ProjectCode__c, Project Code)
        @AuraEnabled
        public String SALES_EMP_NO;     // 영업담당자 사번 (Opportunity Owner ID_Name, 사번	소유자 (영업 대표) 사번)
        @AuraEnabled
        public String SALES_EMP_NAME;   // 영업담당자 이름 (Opportunity Owner ID_Name, 소유자 (영업 대표) 이름)
        @AuraEnabled
        public String ZZSALES_C_NAME_M; // 영업부서코드(SALES DEPT)	(Opportunity, Sales Department, 수주 사업그룹)
        @AuraEnabled
        public String ZZORDER_AMT;      // 예상수주액 (Opportunity Amount, 예상금액)
    }

    // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response) / Batch_EccProjectInfoController에서 사용
    public class InputHeader{

        @AuraEnabled
        public String EV_RESULT;        // Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled
        public List<INPUT_IT_PROJ> IT_PROJ;        
    }
    public class INPUT_IT_PROJ{    

        @AuraEnabled
        public String ZZORDER_ID;       // BO코드 (OpportunityCode__c, 사업 기회 Code)
        @AuraEnabled
        public String ZZBUKRS_H;        // 회사코드 (CompanyCode__c, Company Code)
        @AuraEnabled
        public String PSPID;            // 프로젝트코드 (ProjectCode__c, Project Code)
        @AuraEnabled
        public String SALES_EMP_NO;     // 영업담당자 사번 (Owner ID, 소유자 (영업 대표))
        @AuraEnabled
        public String SALES_EMP_NAME;   // 영업담당자 이름 (Owner ID_Name, 소유자 (영업 대표) 이름)
        @AuraEnabled
        public String ZZSALES_C_NAME_M; // 영업부서코드(SALES DEPT) (Sales Department, 수주 사업그룹)
        @AuraEnabled
        public String ZZORDER_AMT;      // 예상수주액 (Amount, 예상금액)
    }
}