/**
 * @author            : younghoon.kim@dkbmc.com
 * @description       : [IF-154] 일 단위로 고객의 IT현황, 고객성향 데이터를 Legacy로 전송
 * @ schedule code : System.Schedule('Batch_AccountInfoLegacy', '0 0 8 * * ? *', new Batch_AccountInfoLegacy(2, new Set<Id>()));
 * @last modified on  : 2022-06-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-03-22   younghoon.kim@dkbmc.com  Initial Version
 * 1.1	 2022-04-27	  hyunhak.roh@dkbmc.com	   Account 고객성향 정보 전송 IF(IF-153, IF-154) 필드 추가
 * 1.2   2022-05-23   younghoon.kim@dkbmc.com  실시간 호출이 가능하도록 변수 변경 및 로직 수정
 * 1.3   2023-01-10   kajal.c@samsung.com      Added MSP_INFORMATION field (MySales - 109)
**/
public class Batch_AccountInfoLegacy implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable{
    private static final String INTERFACE_ID = 'IF-154';
    private static final String APEX_CLASS   = 'Batch_AccountInfoLegacy';
    private static final String METHOD_NAME  = 'sendAccountInfo';

    List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();

    private static Integer errorCount = 0;

    private Integer DAYS = 0;
    private Set<Id> TARGETIDSET = new Set<Id>();

    public Batch_AccountInfoLegacy(Integer days, Set<Id> TargetIdSet){
        System.debug('========== IF-154 ==========');
        System.debug('========== Batch_AccountInfoLegacy ==========');

        if(days != 0) this.DAYS = days;
        if(!TargetIdSet.isEmpty()) this.TARGETIDSET = TargetIdSet;
        System.debug('DAYS : ' + this.DAYS);
        System.debug('TARGETIDSET : ' + this.TARGETIDSET);
    }

    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('========== Batch start ==========');
        System.debug('DAYS : ' + this.DAYS);
        System.debug('TARGETIDSET : ' + this.TARGETIDSET);

        Set<Id> targetSet = new Set<Id>();

        string query_Select = 'SELECT Id ' + // 고객 mySales ID
                              '     , Name ' + // 고객사명
                              '     , IsDeleted ' + // 삭제여부
                              '     , AccountNumber ' + // 고객 번호
                              '     , mAccNameE__c ' + // 고객사명(EN)
                              '     , mBizLoan__c ' + // 여신등급
                              '     , ITInvestmentCost__c ' + // IT투자 비용(연간)
                              '     , ITOperationExpense__c ' + // IT운영 비용(연간)
                              '     , ITSummary__c ' + // 요약 정보
                              '     , CRMSummary__c ' + // CRM 시스템 정보
                              '     , MESSummary__c ' + // MES 시스템 정보
                              '     , PLMSummary__c ' + // PLM 시스템 정보
                              '     , ERPSummary__c ' + // ERP 시스템 정보
                              '     , SCMSummary__c ' + // SCM 시스템 정보
                              '     , InfraSummary__c ' + // 인프라 시스템 정보
                              '     , AISummary__c ' + // AI 시스템 정보
                              '     , MSPInformation__c ' + //V1.3 - MYSALES -109
                              '     , EtcSummary__c ' + // 기타 시스템 정보
                              '     , Innovation__c ' + // 혁신의지
                              '     , SDSPreference__c ' + // SDS 선호도
                              '     , LegalConditions__c ' + // 법무 계약조건 성향
                              '     , PaymentConditions__c ' + // 대금 지불 성향
                              '     , FinacialHealth__c ' + // 재무 건전성
                              '     , RequirementsChange__c ' + // 요구사항 변경 성향
                              '     , OperatingProfits__c ' + // SDS 영업이익율
                              '     , ProjectRisk__c ' + // PJT 실행 Risk
		// 2022-04-27, hyunhak.roh@dkbmc.com, Account 고객성향 정보 전송 IF(IF-153, IF-154) 필드 추가
							  '     , InnovationComment__c ' + // 혁신의지 설명
            				  '     , SDSPreferenceComment__c ' + // SDS 선호도 설명
            				  '     , LegalConditionsComment__c ' + // 법무 계약조건 성향 설명
            				  '     , PaymentConditionsComment__c ' + // 대금 지불 성향 설명
            				  '     , FinacialHealthComment__c ' + // 재무 건전성 설명
            				  '	    , RequirementsChangeComment__c ' + // 요구사항 변경 성향 설명
            				  '		, RateofOperatingprofitsComment__c ' + // SDS 영업이익율 설명
            				  '		, ProjectRiskComment__c ' + // PJT 실행 Risk 설명
                              '     , LastModifiedDate  ' + // 최종수정일자
            //2022-09-16, yeongju.baek@dkbmc.com, 전략고객 여부 필드 IF 전송 건
                              '     , isStrategicCustomer__c  ' + // 전략고객 여부
                              '     , SharingholdRatio__c  ' + // 지분율필드추가
                              '  FROM Account ';

        String query_Where = ' WHERE RecordType.Name = \'MDG\' '; // MDG Account만 대상

        if(!(this.TARGETIDSET).isEmpty()){
            targetSet = this.TARGETIDSET;
            query_Where += ' AND Id = :targetSet';
        }else{
            if(this.DAYS != 0) query_Where += ' AND LastModifiedDate >= LAST_N_DAYS:' + this.DAYS; // 최종 수정일 기준 n일 이내 고객정보만 전송 대상
        }

        String query_Order = ' ORDER BY LastModifiedDate DESC ';
        // String query_Limit = ' LIMIT 100 '; // for Test
        String query_Etc = ' ALL ROWS ';

        String query_String = query_Select + query_Where + query_Order + /* query_Limit + */query_Etc;
        System.debug('query_String : ' + query_String);

        return Database.getQueryLocator(query_String);
    }

    public void execute(Database.BatchableContext bc, List<Account> objList) {
        System.debug('========== Batch execute ==========');
        System.debug('Query Result Size : ' + objList.size());
        
        System.debug('### Batch_AccountInfoLegacy :: execute :: objList = ' + objList);

        Map<String, Object> resMap = new Map<String, Object>();
        List<ACCOUNT_INFO> accInfoList = new List<ACCOUNT_INFO>();
        try{
            for(Account acc : objList){
                if(Account_tr.isExistValueAccountField(acc, Account_tr.fieldList)){ // 대상 Account : IT 투자비용 or 혁신 의지 or SDS 선호도 정보가 있는 Account
                    ACCOUNT_INFO accInfo = new ACCOUNT_INFO();
                    accInfo.ACCOUNT_ID = acc.Id; // 고객 mySales ID
                    accInfo.ACCOUNT_NUMBER = acc.AccountNumber != null ? acc.AccountNumber : ''; // 고객 번호
                    accInfo.ACCOUNT_NAME = acc.Name; // 고객사명
                    accInfo.ACCOUNT_NAME_E = acc.mAccNameE__c != null ? acc.mAccNameE__c : ''; // 고객사명(EN)
                    accInfo.LOAN_GRADE = acc.mBizLoan__c != null ? acc.mBizLoan__c : ''; // 여신등급
                    accInfo.IT_INVEST_COST = acc.ITInvestmentCost__c != null ? acc.ITInvestmentCost__c : ''; // IT투자 비용(연간)
                    accInfo.IT_OPERATE_COST = acc.ITOperationExpense__c != null ? acc.ITOperationExpense__c : ''; // IT운영 비용(연간)
                    accInfo.IT_SUMMARY = acc.ITSummary__c != null ? acc.ITSummary__c : ''; // 요약정보
                    accInfo.CRM_SUMMARY = acc.CRMSummary__c != null ? acc.CRMSummary__c : ''; // CRM 시스템 정보
                    accInfo.MES_SUMMARY = acc.MESSummary__c != null ? acc.MESSummary__c : ''; // MES 시스템 정보
                    accInfo.PLM_SUMMARY = acc.PLMSummary__c != null ? acc.PLMSummary__c : ''; // PLM 시스템 정보
                    accInfo.ERP_SUMMARY = acc.ERPSummary__c != null ? acc.ERPSummary__c : ''; // ERP 시스템 정보
                    accInfo.SCM_SUMMARY = acc.SCMSummary__c != null ? acc.SCMSummary__c : ''; // SCM 시스템 정보
                    accInfo.INFRA_SUMMARY = acc.InfraSummary__c != null ? acc.InfraSummary__c : ''; // Infra 시스템 정보
                    accInfo.AI_SUMMARY = acc.AISummary__c != null ? acc.AISummary__c : ''; // AI 시스템 정보
                    accInfo.OTHER_SUMMARY = acc.EtcSummary__c != null ? acc.EtcSummary__c : ''; // 기타 시스템 정보
                    accInfo.MSP_INFORMATION =acc.MSPInformation__c != null ? acc.MSPInformation__c : '';//V1.3 - MYSALES -109
                    
                    Integer WILL_INNOVATE = scoreCalculation('Innovation__c', acc.Innovation__c);
                    Integer SDS_PREFER = scoreCalculation('SDSPreference__c', acc.SDSPreference__c);
                    Integer LEGAL_CONDITION = scoreCalculation('LegalConditions__c', acc.LegalConditions__c);
                    Integer PAYMENT_TERMS = scoreCalculation('PaymentConditions__c', acc.PaymentConditions__c);
                    Integer FINANCIAL_HEALTH = scoreCalculation('FinacialHealth__c', acc.FinacialHealth__c);
                    Integer CHANGE_REQ = scoreCalculation('RequirementsChange__c', acc.RequirementsChange__c);
                    Integer MARGIN_RATIO = scoreCalculation('OperatingProfits__c', acc.OperatingProfits__c);
                    Integer DELIVERY_RISK = scoreCalculation('ProjectRisk__c', acc.ProjectRisk__c);
                    Integer TOTAL_SCORE = (WILL_INNOVATE*2) + (SDS_PREFER*2) + (LEGAL_CONDITION*2) + (PAYMENT_TERMS*2) + (FINANCIAL_HEALTH*2) + (CHANGE_REQ*4) + (MARGIN_RATIO*2) + (DELIVERY_RISK*4);
                    
                    accInfo.WILL_INNOVATE = String.valueOf(WILL_INNOVATE); // 혁신의지
                    accInfo.SDS_PREFER = String.valueOf(SDS_PREFER); // SDS 선호도
                    accInfo.LEGAL_CONDITION = String.valueOf(LEGAL_CONDITION); // 법무 계약조건 성향
                    accInfo.PAYMENT_TERMS = String.valueOf(PAYMENT_TERMS); // 대금 지불 성향
                    accInfo.FINANCIAL_HEALTH = String.valueOf(FINANCIAL_HEALTH); // 재무 건전성
                    accInfo.CHANGE_REQ = String.valueOf(CHANGE_REQ); // 요구사항 변경 성향
                    accInfo.MARGIN_RATIO = String.valueOf(MARGIN_RATIO); // SDS 영업이익율
                    accInfo.DELIVERY_RISK = String.valueOf(DELIVERY_RISK); // PJT 실행 Risk
                    accInfo.TOTAL_SCORE = String.valueOf(TOTAL_SCORE); // 고객성향 총평점
                    accInfo.IS_DELETED = acc.IsDeleted == true ? 'D' : ''; // 삭제여부

                    // 2022-04-27, hyunhak.roh@dkbmc.com, Account 고객성향 정보 전송 IF(IF-153, IF-154) 필드 추가
                    accInfo.WILL_INNOVATE_DESC 		= acc.InnovationComment__c != null ? acc.InnovationComment__c : ''; // 혁신의지 설명
                    accInfo.SDS_PREFER_DESC 		= acc.SDSPreferenceComment__c != null ? acc.SDSPreferenceComment__c : ''; // SDS 선호도 설명
                    accInfo.LEGAL_CONDITION_DESC 	= acc.LegalConditionsComment__c != null ? acc.LegalConditionsComment__c : ''; // 법무 계약조건 성향 설명
                    accInfo.PAYMENT_TERMS_DESC 		= acc.PaymentConditionsComment__c != null ? acc.PaymentConditionsComment__c : ''; // 대금 지불 성향 설명
                    accInfo.FINANCIAL_HEALTH_DESC 	= acc.FinacialHealthComment__c != null ? acc.FinacialHealthComment__c : ''; // 재무 건전성 설명
                    accInfo.CHANGE_REQ_DESC 		= acc.RequirementsChangeComment__c != null ? acc.RequirementsChangeComment__c : ''; // 요구사항 변경 성향 설명
                    accInfo.MARGIN_RATIO_DESC 		= acc.RateofOperatingprofitsComment__c != null ? acc.RateofOperatingprofitsComment__c : ''; // SDS 영업이익율 설명
                    accInfo.DELIVERY_RISK_DESC 		= acc.ProjectRiskComment__c != null ? acc.ProjectRiskComment__c : ''; // PJT 실행 Risk 설명
                    accInfo.LAST_MODIFIED_DATE 		= acc.LastModifiedDate != null ? (Util_String.convertDateTimeString(acc.LastModifiedDate)).left(8) : ''; // 최종수정일자
                    accInfo.IS_STRATEGIC_CUSTOMER	= acc.isStrategicCustomer__c == true ? 'Y' : 'N'; //전략고객 여부 필드 IF 전송 건  
                    accInfo.SHARINGHOLD_RATIO	    = acc.SharingholdRatio__c != null ? acc.SharingholdRatio__c : ''; //지분율필드추가
                    
                    accInfoList.add(accInfo);
                }
            }
            System.debug('### Batch_AccountInfoLegacy :: execute :: accInfoList = ' + accInfoList);
    
            if(!accInfoList.isEmpty()) resMap = sendAccountInfo(accInfoList);
            IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)resMap.get('IF_Log');
            ifLogList.add(ifLog);
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }

    public void finish(Database.BatchableContext bc) { 
        System.debug('========== Batch finish ==========');
        try{
            IF_Log log = new IF_Log();
            for(IF_Log.InterfaceLog ifLog : ifLogList){
                log.createLog(ifLog);
            }
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }

    public void execute(SchedulableContext SC){
        System.debug('========== Schedule execute ==========');
        System.debug('DAYS : ' + DAYS);
        System.debug('TARGETIDSET : ' + TARGETIDSET);

        DataBase.executeBatch(new Batch_AccountInfoLegacy(DAYS, TARGETIDSET), 200);
    }

    @AuraEnabled    
    public static Map<String,Object> sendAccountInfo(List<ACCOUNT_INFO> accInfoList){
        System.debug('========== sendAccountInfo ==========');
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();

        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
            'IF_Log' => null,
            'StatusCode' => null
        };

        try{
            InputClass input = new InputClass();
            input.ACCOUNT_INFO = accInfoList;
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            System.debug('request : ' + resMap.get('Request'));
            System.debug('response : ' + resMap.get('Response'));

            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            if(res.getStatusCode() == 200){
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                System.debug('RESULT : ' + bodyMap.get('RESULT'));
                if(bodyMap.get('RESULT') != null && bodyMap.get('RESULT') == 'F'){
                    if(errorCount < 2){
                        errorCount += 1;
                        sendAccountInfo(accInfoList);
                    }
                }
                //IF 결과
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.put('Response', res.getBody());
            }
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
        }catch(Exception e){
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('HttpResponse')), e));
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
        return returnMap;
    }

    @AuraEnabled    
    public static Integer scoreCalculation(String fieldName, String targetValue){
        System.debug('fieldName : ' + fieldName);
        System.debug('targetValue : ' + targetValue);
        
        Integer score = 0;
        if(targetValue != null){
            if(targetValue.equals('매우높음') || targetValue.equals('매우좋음') || targetValue.equals('거의없음') || targetValue.equals('AAA, AA') || targetValue.equals('15%~')){
                score = 5;
            }else if(targetValue.equals('좋음') || targetValue.equals('없음') || targetValue.equals('A, BBB') || targetValue.equals('10%~')){
                score = 4;
            }else if(targetValue.equals('보통') || targetValue.equals('BB, B') || targetValue.equals('5%~')){
                score = 3;
            }else if(targetValue.equals('낮음') || targetValue.equals('많음') || targetValue.equals('CCC, CC') || targetValue.equals('0%~')){
                score = 2;
            }else if(targetValue.equals('매우낮음') || targetValue.equals('아주많음') || targetValue.equals('C이하') || targetValue.equals('~0%')){
                score = 1;
            }
        }

        System.debug('score : ' + score);
        return score;
    }

    public class InputClass{
        @AuraEnabled
        public List<ACCOUNT_INFO> ACCOUNT_INFO;
    }
    
    public class ACCOUNT_INFO{
        @AuraEnabled
        public String ACCOUNT_ID; // 고객 mySales ID
        @AuraEnabled
        public String ACCOUNT_NUMBER; // 고객 번호
        @AuraEnabled
        public String ACCOUNT_NAME; // 고객사명
        @AuraEnabled
        public String ACCOUNT_NAME_E; // 고객사명(EN)
        @AuraEnabled
        public String LOAN_GRADE; // 여신등급
        @AuraEnabled
        public String IT_INVEST_COST; // IT투자 비용(연간)
        @AuraEnabled
        public String IT_OPERATE_COST; // IT운영 비용(연간)
        @AuraEnabled
        public String IT_SUMMARY; // 요약정보
        @AuraEnabled
        public String CRM_SUMMARY; // CRM 시스템 정보
        @AuraEnabled
        public String MES_SUMMARY; // MES 시스템 정보
        @AuraEnabled
        public String PLM_SUMMARY; // PLM 시스템 정보
        @AuraEnabled
        public String ERP_SUMMARY; // ERP 시스템 정보
        @AuraEnabled
        public String SCM_SUMMARY; // SCM 시스템 정보
        @AuraEnabled
        public String INFRA_SUMMARY; // Infra 시스템 정보
        @AuraEnabled
        public String AI_SUMMARY; // AI 시스템 정보
        @AuraEnabled
        public String OTHER_SUMMARY; // 기타 시스템 정보
        @AuraEnabled
        public String WILL_INNOVATE; // 혁신의지
        @AuraEnabled
        public String SDS_PREFER; // SDS 선호도
        @AuraEnabled
        public String LEGAL_CONDITION; // 법무 계약조건 성향
        @AuraEnabled
        public String PAYMENT_TERMS; // 대금 지불 성향
        @AuraEnabled
        public String FINANCIAL_HEALTH; // 재무 건전성
        @AuraEnabled
        public String CHANGE_REQ; // 요구사항 변경 성향
        @AuraEnabled
        public String MARGIN_RATIO; // SDS 영업이익율
        @AuraEnabled
        public String DELIVERY_RISK; // PJT 실행 Risk
        @AuraEnabled
        public String TOTAL_SCORE; // 고객성향 총평점
        @AuraEnabled
        public String IS_DELETED; // 삭제여부
        //2022-04-27, hyunhak.roh@dkbmc.com, Account 고객성향 정보 전송 IF(IF-153, IF-154) 필드 추가
        @AuraEnabled
        public String WILL_INNOVATE_DESC; // 혁신의지 설명
        @AuraEnabled
        public String SDS_PREFER_DESC; // SDS 선호도 설명
        @AuraEnabled
        public String LEGAL_CONDITION_DESC; // 법무 계약조건 성향 설명
        @AuraEnabled
        public String PAYMENT_TERMS_DESC; // 대금 지불 성향 설명
        @AuraEnabled
        public String FINANCIAL_HEALTH_DESC; // 재무 건전성 설명
        @AuraEnabled
        public String CHANGE_REQ_DESC; // 요구사항 변경 성향 설명
        @AuraEnabled
        public String MARGIN_RATIO_DESC; // SDS 영업이익율 설명
        @AuraEnabled
        public String DELIVERY_RISK_DESC; // PJT 실행 Risk 설명
        @AuraEnabled
        public String LAST_MODIFIED_DATE; // 최종 수정일
        //2022-09-16, yeongju.baek@dkbmc.com, 전략고객 여부 필드 IF 전송 건
        @AuraEnabled
        public String IS_STRATEGIC_CUSTOMER; //전략고객 여부
        @AuraEnabled
        public String SHARINGHOLD_RATIO; //지분율필드추가
        @AuraEnabled
        public String MSP_INFORMATION;//V1.3 - MYSALES -109
    }
}