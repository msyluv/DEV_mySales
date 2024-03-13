/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-19
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                        Modification
 * 1.0   2020-12-22   ghkil@partner.samsung.com     Initial Version
 * 1.1   2020-12-23   ghkil@partner.samsung.com     return Type Class에서 Map으로 변경
 * 1.2   2020-12-29   kilhwan@partner.samsung.com   Header 제거
**/
global class IF_EccProjectStatusCheckContrller {

    private static final String INTERFACE_ID = 'IF-056';
    private static final String APEX_CLASS   = 'IF_EccProjectStatusCheckContrller';
    private static final String METHOD_NAME  = 'calloutProjectStatusCheck';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    public IF_EccProjectStatusCheckContrller() {    }
    
    @AuraEnabled
    public static Map<String, Object> calloutProjectStatusCheck(String inputJsonData){

        String guId = IF_Util.generateGuid();

        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {
            system.debug('StartTime IF_EccProjectStatusCheckContrller whole class'+datetime.now());
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputClass outHeader = (OutputClass) JSON.deserialize(inputJsonData, OutputClass.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');
             system.debug('StartTime IF_EccProjectStatusCheckContrller'+datetime.now());
            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));
           

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');
            system.debug('EndTime IF_EccProjectStatusCheckContrller'+datetime.now());
            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            }else{
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }  
            system.debug('EndTime IF_EccProjectStatusCheckContrller whole'+datetime.now());
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            /** 
             * 2020-12-09 | younghoon.kim@dkbmc.com
             * CalloutException으로 log정보 returnMap에 추가하여 직접 로그 생성하도록 수정
             * */
            //ifLog.createLog(interfaceLog);            
            result.put('INTERFACE_LOG', interfaceLog);
        }
        return result;        
    }

    public class OutputClass{

        @AuraEnabled
        public String IV_BUKRS;         // Company Code / Opportunity, CompanyCode__c, Company Code
        @AuraEnabled
        public String IV_ZZORDER_ID;    // BO코드 / Opportunity, OpportunityCode__c, 사업기회코드
        @AuraEnabled
        public String IV_PS_TYPE;       // 프로세스 타입 / Opportunity, ActivityStatus__c, Current BO Activity Status
        @AuraEnabled
        public String IV_PSPID;         // 프로젝트코드 / Project__c, ProjectCode__c, Project Code
        @AuraEnabled
        public String IV_PJTCHK;        // Character Field Length 1 / "X"
    }
}