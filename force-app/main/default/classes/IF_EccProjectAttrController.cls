/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-04
 * @last modified by  : wonjune.oh@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-13   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2020-11-24   ghkil@partner.samsung.com        Json Fomat에 맞춰 bypass 형태로 수정 (Output 항목 중 예약어가 있어 Map으로 처리함))
 * 1.2   2020-12-23   ghkil@partner.samsung.com        return Type Class에서 Map으로 변경
 * 1.3   2021-02-02   ghkil@partner.samsung.com        ZZPS_TYPE 항목 추가 (값이 없는 경우 값 구해서 처리)
 * 1.4   2021-02-03   kilhwan.an@partner.samsung.com   ZZPS_TYPE 조건 형식 변경    
**/
public with sharing class IF_EccProjectAttrController {

    private static final String INTERFACE_ID = 'IF-009';
    private static final String APEX_CLASS   = 'IF_EccProjectAttrController';
    private static final String METHOD_NAME  = 'calloutSendProjectAttrInfo';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    
    @AuraEnabled
    public static Map<String, Object> calloutSendProjectAttrInfo(String inputJsonData){

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

            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성'); 

            List<Object> itDataList = new List<Object>();
            for (OUTPUT_IT_DATA outputItData : outHeader.IT_DATA) {
                Map<String, Object> itDataMap = new Map<String, Object>();

                itDataMap.put('CLASS_SFDC'   , outputItData.CLASS_SFDC);        // 솔루션코드 (MGD 솔루션체계에서 정의된 솔루션 코드)
                itDataMap.put('ZZORDER_TYPE' , outputItData.ZZORDER_TYPE);      // 사업속성 (CRM 속성코드)
                itDataMap.put('ZOPPT_TYPE'   , outputItData.ZOPPT_TYPE);        // 사업유형 (TI:구축형, TD:판매형, TS:서비스형)
                itDataMap.put('ZZWBS_CLASS'  , outputItData.ZZWBS_CLASS);       // 수익인식기준 (SI, SC, SM)
                itDataMap.put('ZZUSEYN'      , outputItData.ZZUSEYN);           // 불용여부 (N:미사용)
                
                system.debug('outputItData : ' + outputItData);
                system.debug('outputItData.ZZPS_TYPE : ' + outputItData.ZZPS_TYPE);

                String zzpsType = null;
                if (Util_String.nvlStr( outputItData.ZZPS_TYPE) != '') {
                    zzpsType = outputItData.ZZPS_TYPE;
                } else {
                    Integer classSfdc = Integer.valueOf(outputItData.CLASS_SFDC);
                    String zzwbsType = String.valueOf(outputItData.ZZWBS_CLASS);
                    String zzorderType = String.valueOf(outputItData.ZZORDER_TYPE);

                    if (classSfdc >= 30000076 && classSfdc <= 30000081) {
                        if (zzwbsType == 'SI') {
                            if (zzorderType == 'S144' || zzorderType == 'S145') {
                                zzpsType = 'SI3';
                            } else {
                                zzpsType = 'SI2';
                            }
                        } else if (zzwbsType == 'SM') {
                            zzpsType = 'SM2';
                        } else if (zzwbsType == 'SC') {
                            zzpsType = 'SC7';
                        }
                    } else if (classSfdc >= 30000027 && classSfdc <= 30000032) {
                        if (zzwbsType == 'SI') {
                            zzpsType = 'SI4';
                        } else if (zzwbsType == 'SM') {
                            if (zzorderType == 'S149') {
                                zzpsType = 'SM5';
                            } else {
                                zzpsType = 'SM3';
                            }
                        } else if (zzwbsType == 'SC') {
                            if (zzorderType == 'S122') {
                                zzpsType = 'SC3';
                            } else if (zzorderType == 'S124' || zzorderType == 'S125') {
                                zzpsType = 'SC4';
                            } else if (zzorderType >= 'S131' && zzorderType <= 'S134') {
                                zzpsType = 'SC6';
                            }
                        }
                    } else {
                        if (zzwbsType == 'SI') {
                            zzpsType = 'SI1';
                        } else if (zzwbsType == 'SM') { 
                            if (outputItData.ZZORDER_TYPE == 'S149') {
                                zzpsType = 'SM4';
                            } else {
                                zzpsType = 'SM1';
                            }
                        } else if (zzwbsType == 'SC') {
                            if (outputItData.ZZORDER_TYPE == 'S122') {
                                zzpsType = 'SC1';
                            } else if (zzorderType == 'S124' || zzorderType == 'S125') {
                                zzpsType = 'SC2';
                            } else if (zzorderType >= 'S131' && zzorderType <= 'S134') {
                                zzpsType = 'SC5';
                            } else if (zzorderType == 'S156') {
                                zzpsType = 'SC8';
                            }
                        }
                    }
                }
                itDataMap.put('ZZPS_TYPE'    , zzpsType);                       // PS Type (2021-02-22 추가)

                itDataList.add(itDataMap);                
            }

            List<Object> itOrderTypeList = new List<Object>();
            for (OUTPUT_IT_ORDER_TYPE outputItOrderType : outHeader.IT_ORDER_TYPE) {
                Map<String, Object> itOrderTypeMap = new Map<String, Object>();

                itOrderTypeMap.put('SPRAS'          , outputItOrderType.SPRAS);             // 언어 (고정값:EN)
                itOrderTypeMap.put('ZZORDER_TYPE'   , outputItOrderType.ZZORDER_TYPE);      // 사업속성
                itOrderTypeMap.put('ZZORDER_TYPE_T' , outputItOrderType.ZZORDER_TYPE_T);    // 사업속성내역
                itOrderTypeMap.put('ZZUSERYN'       , outputItOrderType.ZZUSERYN);          // 불용여부(N:미사용)

                itOrderTypeList.add(itOrderTypeMap);                
            }

            // JSON FORMAT 형식 : 변경 사항 유의
            Map<String, Object> outputHeaderMap = new Map<String, Object>();
            outputHeaderMap.put('IT_DATA'       , itDataList);
            outputHeaderMap.put('IT_ORDER_TYPE' , itOrderTypeList);
            
            // 데이터 전송
            result = ifCallout.httpCallout(JSON.serialize(outputHeaderMap), '');
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

            ifLog.createLog(interfaceLog);
        }
        return result;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader {
    
        @AuraEnabled
        public List<OUTPUT_IT_DATA> IT_DATA;
        @AuraEnabled
        public List<OUTPUT_IT_ORDER_TYPE> IT_ORDER_TYPE;
    }
    public class OUTPUT_IT_DATA{

        @AuraEnabled
        public String CLASS_SFDC;       // 솔루션코드 (MGD 솔루션체계에서 정의된 솔루션 코드)
        @AuraEnabled
        public String ZZORDER_TYPE;     // 사업속성 (CRM 속성코드)
        @AuraEnabled
        public String ZOPPT_TYPE;       // 사업유형 (TI:구축형, TD:판매형, TS:서비스형)
        @AuraEnabled
        public String ZZWBS_CLASS;      // 수익인식기준 (SI, SC, SM)
        @AuraEnabled
        public String ZZUSEYN;          // 불용여부 (N:미사용)
        @AuraEnabled
        public String ZZPS_TYPE;        // PS Type (2021-02-22 추가)
    }
    public class OUTPUT_IT_ORDER_TYPE{

        @AuraEnabled
        public String SPRAS;            // 솔루션코드 (MGD 솔루션체계에서 정의된 솔루션 코드)
        @AuraEnabled
        public String ZZORDER_TYPE;     // 사업속성
        @AuraEnabled
        public String ZZORDER_TYPE_T;   // 사업속성명 
        @AuraEnabled
        public String ZZUSERYN;         // 불용여부 (N:미사용)        
    }
}