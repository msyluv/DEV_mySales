/**
 * @description       : WBS 삭제전 가능여부 체크하기
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-27
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-23   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-11-24   ghkil@partner.samsung.com         Json Format에 맞춰 bypass 형태로 수정
 * 1.2   2020-12-23   ghkil@partner.samsung.com         return Type Class에서 Map으로 변경
 * 1.3   2021-08-25   seonju.jin@dkbmc.com               IT_SERVICE ZZTECH_YN 추가
**/
public class IF_EccWbsDeleteController {
    public IF_EccWbsDeleteController() { }

    private static final String INTERFACE_ID = 'IF-058';
    private static final String APEX_CLASS   = 'IF_EccWbsDeleteController';
    private static final String METHOD_NAME  = 'calloutWbsDelete';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    
    @AuraEnabled
    public static Map<String, Object> calloutWbsDelete(String inputJsonData){    

        String guId = IF_Util.generateGuid();

        Map<String, Object> result = new Map<String, Object>();

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log iflog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
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

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            }else{
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            /** 
             * 2020-12-09 | seonju.jin@dkbmc.com
             * CalloutException으로 log정보 returnMap에 추가하여 직접 로그 생성하도록 수정
             * */
            //ifLog.createLog(interfaceLog);            
            result.put('INTERFACE_LOG', interfaceLog);
        }
        return result;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public List<OUTPUT_IT_SERVICE> IT_SERVICE; 
        @AuraEnabled
        public List<OUTPUT_IT_SOLUTION> IT_SOLUTION;
    }

    public class OUTPUT_IT_SERVICE{
        
        @AuraEnabled
        public String SERVICE_CODE;     // 서비스 WBS 코드 (WBS__c, WBS Code)
        @AuraEnabled
        public String SERVICE;          // 서비스 코드 (WBS__c, Service Code)
        @AuraEnabled
        public String SERVICE_NAME;     // 서비스 명 (Service__c, Service__r.Name)
        @AuraEnabled
        public String SUB_FKSTL;        // 매출부서 (Service__c, Sales Department)
        @AuraEnabled
        public String SUB_AKSTL;        // 수주부서 (Service__c, Delivery Department)
        @AuraEnabled
        public String OPTION;           // 변경여부 (Service__c, DeletionFlag__c)
        @AuraEnabled
        public Integer NUMBER_INT;      // Item Number (Service__c, ItemNumber__c)
        @AuraEnabled
        public String ZZSERVICE_REP_X;  // 대표 서비스 구분값 (Service__c, ItemNumber__c) / [SFDC] BO Service Object에서 Numer_int 가 제일 작은것을 "X"로 표시해서 제공함
        @AuraEnabled
        public String ZZTECH_YN;        //Tech. Attribute
    }

    public class OUTPUT_IT_SOLUTION{

        @AuraEnabled
        public String SERVICE_CODE;     // 서비스 WBS 코드 (서비스에 대한 WBS__c, WBS Code)
        @AuraEnabled
        public String SOLUTION_CODE;    // 솔루션 WBS코드 (솔류션에 대한 WBS__c	WBS Code)
        @AuraEnabled
        public String SOLUTION;         // 솔루션 코드 (WBS__c, Solution Code)
        @AuraEnabled
        public String SOLUTION_NAME;    // 솔루션 명 (솔루션 코드에 대한 Solution__c, Solutionc__r.Name)
        @AuraEnabled
        public String GUBUN;            // 1 : Labor, 2: HW&SW, 3: 도입 솔루션, 4: 자사 솔루션" (Solution__c, SolutionType__c)
        @AuraEnabled
        public String OPTION;           // D : DELETE, C:CHANGE, I:CREATE (WBS__c, Deletion Flag)
        @AuraEnabled
        public Integer NUMBER_INT;      // Item Number in Document (WBS__c, Item Number)
        // @AuraEnabled
        // public String SORT;          // SORT (용역 / HW / SW)                ? 예약어
        @AuraEnabled
        public String ZZORDER_TYPE_S;   // 사업속성(솔루션) (SvcSolBizAttr__c, BizAttribute__c)
        @AuraEnabled
        public String ZZBIZ_TYPE_S;     // 사업유형(솔루션) (SvcSolBizAttr__c, BusinessType__c)
        @AuraEnabled
        public String ZZWBS_CLASS_S;    // 수익인식기준(솔루션) (SvcSolBizAttr__c, WBSClass__c, WBS Class (수익인식기준))
    }    
}