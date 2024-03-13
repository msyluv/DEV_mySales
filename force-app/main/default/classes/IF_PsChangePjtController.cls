/**
 * @description       : 사업기회에 대한 변경 프로젝트 코드를 가져오기
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-25
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-24-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   12-10-2020   seonju.jin@dkbmc.com               Header KOKRS 추가
 * 1.2   2021-08-25   seonju.jin@dkbmc.com               IT_SERVICE ZZTECH_YN 추가
**/
public class IF_PsChangePjtController {
    private static final String INTERFACE_ID = 'IF-050';
    private static final String APEX_CLASS   = 'IF_PsChangePjtController';
    private static final String METHOD_NAME  = 'changePjt';
    
    @AuraEnabled
    public static Map<String,Object> changePjt(InputClass input){
        String guId = IF_Util.generateGuid();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            system.debug('request : '+resMap.get('Request'));
            system.debug('response : '+resMap.get('Response'));
            
            system.debug('resMap:' + ((resMap.get('HttpResponse') == null) ? 'httpresponse null' : resMap.get('HttpResponse')));

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            returnMap.put('StatusCode',res.getStatusCode());
            returnMap.put('IF_MSG',String.valueOf(resMap.get('IF_MSG')));
            returnMap.putAll( (Map<String,Object>) JSON.deserializeUntyped(res.getBody()));

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        
        /** 
         * 2020-12-09 | seonju.jin@dkbmc.com
         * CalloutException으로 log정보 returnMap에 추가하여 직접 로그 생성하도록 수정
         * */
        returnMap.put('INTERFACE_LOG', ifLog);
        //log.createLog(ifLog);
        return returnMap;
    }

    public class InputClass{
        @AuraEnabled
        public IS_HEADER IS_HEADER;
        @AuraEnabled
        public List<IT_SERVICE> IT_SERVICE;
        @AuraEnabled
        public List<IT_SOLUTION> IT_SOLUTION;
    }
    public class IS_HEADER{
        @AuraEnabled
        public String ZZORDER_ID; //BO코드
        @AuraEnabled
        public String DESCRIPTION; //BO 명
        @AuraEnabled
        public String BUKRS; //회사 코드
        @AuraEnabled
        public String KOKRS; //회사 코드 defaultValue T100
        @AuraEnabled
        public String MAIN_FKSTL; //수주부서 코스트센터코드
        @AuraEnabled
        public String MAIN_AKSTL; //매출부서 코스트센터코드
        @AuraEnabled
        public String ORIGIN_CUSTOMER; //원청사 고객번호
        @AuraEnabled
        public String CUSTOMER; //고객번호
        @AuraEnabled
        public String SALES_PLFAZ; //사전영업 시작일 
        @AuraEnabled
        public String SALES_PLSEZ; //사전영업 종료일 
        @AuraEnabled
        public String PLFAZ; //프로젝트 시작일 
        @AuraEnabled
        public String PLSEZ; //프로젝트 종료일 
        @AuraEnabled
        public String CONTRACT_EXP_DATE; //수주예상일 
        @AuraEnabled
        public String ZZSALEMP_CNO; //영업담당자 사번
        @AuraEnabled
        public String ZZPROPOSAL_PM_CNO; //제안PM 사번
        @AuraEnabled
        public String ZZBIZ_LEVEL; //사업등급
        @AuraEnabled
        public String ZZSUBS_PJT; //사내대체프로젝트코드 
    }
    public class IT_SERVICE{
        @AuraEnabled
        public String SERVICE_WBS; //서비스 WBS 코드
        @AuraEnabled
        public String SERVICE; //서비스코드
        @AuraEnabled
        public String SERVICE_NAME; //서비스명
        @AuraEnabled
        public String SUB_FKSTL; //매출부서
        @AuraEnabled
        public String SUB_AKSTL; //수주부서
        @AuraEnabled
        public String OPTION; //삭제여부
        @AuraEnabled
        public String NUMBER_INT; //Item Number
        @AuraEnabled
        public String ZZSERVICE_REP_X; //대표 서비스 구분값
        @AuraEnabled
        public String ZZTECH_YN;        //Tech. Attribute
    }
    public class IT_SOLUTION{
        @AuraEnabled
        public String SERVICE_CODE; //서비스 WBS 코드
        @AuraEnabled
        public String SOLUTION_CODE; //솔루션 WBS 코드
        @AuraEnabled
        public String SOLUTION; //솔루션 코드
        @AuraEnabled
        public String SOLUTION_NAME; //솔루션 명
        @AuraEnabled
        public String GUBUN; //1 : Labor, 2: HW&SW, 3: 도입 솔루션, 4: 자사 솔루션
        @AuraEnabled
        public String OPTION; //변경여부
        @AuraEnabled
        public String NUMBER_INT; //Item Number
        @AuraEnabled
        public String ZZORDER_TYPE_S; //사업속성(솔루션)
        @AuraEnabled
        public String ZZBIZ_TYPE_S; //사업유형(솔루션)
        @AuraEnabled
        public String ZZWBS_CLASS_S; //수익인식기준(솔루션)
    }

}