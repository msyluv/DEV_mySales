/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-18
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-23   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-11-24   ghkil@partner.samsung.com   Json Format에 맞춰 bypass 형태로 수정
 * 1.2   2020-12-23   ghkil@partner.samsung.com   return Type Class에서 Map으로 변경
**/
public class IF_EccOpportunityInfoController {
    public IF_EccOpportunityInfoController() { }

    private static final String INTERFACE_ID = 'IF-015';
    private static final String APEX_CLASS   = 'IF_EccOpportunityInfoController';
    private static final String METHOD_NAME  = 'getOpportunityInfo';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    @AuraEnabled
    public static Map<String, Object> getOpportunityInfo(String inputJsonData){        

        String guId = IF_Util.generateGuid();

        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log iflog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Task단에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Task단에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            if (DEBUG_FLAG) ifLog.addLog('result : '  + result);

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

            ifLog.createLog(interfaceLog);
        }
        return result;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{
     
        @AuraEnabled
        public String IV_ROSEQ;         // 조직변경 진행번호
        @AuraEnabled
        public String IV_HQ_FLAG;       // HQ: Y, Others: N
        @AuraEnabled
        public List<OUTPUT_TT_OPPORT_H> TT_OPPORT_H; 
    }
    public class OUTPUT_TT_OPPORT_H {

        @AuraEnabled
        public String GUBUN;            // CRM 사업기회 Header(H), Items(I) 구분자 (Item Number이 0 = "H", 0<> "I")
        @AuraEnabled
        public String BUKRS;            // 회사코드 (CompanyCode__c, Company Code)
        @AuraEnabled
        public String ZZORDER_ID;       // BO코드 (OpportunityCode__c, 사업 기회 Code)
        @AuraEnabled
        public String DESCRIPTION;      // BO명 (Name, 사업기회명)
        @AuraEnabled
        public String PARTNER;          // 영업담당자 사번 (OwnerId, 소유자 (영업 대표))
        @AuraEnabled
        public String NAME_LAST;        // 영업담당자명 (EvHName__c, 소유자 (영업 대표)명)
        @AuraEnabled
        public String NUMBER_INT;       // Item number (ItemNumber__c, Item Number)
        @AuraEnabled
        public String ZZSERVICE;        // 서비스코드 (Service__c, Lookup(Maseter Service))
        @AuraEnabled
        public String ZZSERVICE_DESC;   // 서비스명 (Service__c, Lookup(Maseter Service))
        // @AuraEnabled
        // public String ZZSLSDIVISION;     // 변경전, 수주부서 사업부 코스트센터 코드 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZSLSDIVISION_NM; // 변경전, 수주부서 사업부 명 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZSLSTEAM;     // 변경전, 수주부서 팀 코스트센터 코드 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZSLSTEAM_NM;  // 변경전, 수주부서 팀 명 (SFDC 사용하지 않음)
        @AuraEnabled
        public String ZZSLSDEPT_B;      // 변경전, 수주부서 코스트센터 코드 (SalesDepartment__c, 수주 사업그룹, Lookup(CostCenter) CostCenter__c.CostCenter__c)
        @AuraEnabled
        public String ZZSLSDEPT_B_DESC; // 변경전, 수주부서 명 (SalesDepartment__c, 수주 사업그룹, Lookup(CostCenter) CostCenter__c.Name)
        @AuraEnabled
        public String ZZDLVDEPT_B;      // 변경전, 매출부서 코스트센터 코드 (cPrimarySalesDepartment__c, 주 매출 부서, Lookup(CostCenter) CostCenter__c.CostCenter__c)
        @AuraEnabled
        public String ZZDLVDEPT_B_DESC; // 변경전, 매출부서 명 (cPrimarySalesDepartment__c, 주 매출 부서, Lookup(CostCenter) CostCenter__c.Name)
        // @AuraEnabled
        // public String ZZSLSDEPT_A; // 변경후, 수주 코스트센터 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZSLSDEPT_A_DESC; // 변경후, 수주 코스트센터 명 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZDLVDEPT_A; // 변경후, 매출 코스트센터 (SFDC 사용하지 않음)
        // @AuraEnabled
        // public String ZZDLVDEPT_A_DESC; // 변경후, 수주 코스트센터 명 (SFDC 사용하지 않음)
    }
}