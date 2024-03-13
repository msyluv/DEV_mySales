/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 2024-03-12
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.1	 2024-03-12	  sarthak.j1@samsung.com            Apply new Probability Field to Logistics -> MYSALES-470
**/

public class Batch_EccOpptyLogiDummyInsert implements Database.Stateful,DataBase.Batchable<SObject>{
 
   
    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query_RESULT = 'Select Id ' +
                                        '	    , OpportunityCode__c ' +                                    // 사업 기회 Code
                                        '	    , RecordType.DeveloperName ' +                              // RecordType 구분                                        
                                        '	    , Name ' +                                                  // 사업기회명
                                        '	    , StageName ' +                                             // 단계
                                        '       , ActivityStatus__c ' +                                     // Current BO Activity Status
                                        '	    , Type ' +                                                  // 사업기회 유형
                                        '	    , Account.AccountNumber ' +                                 // Contract Account
                                        '	    , cOriginAcc__r.AccountNumber ' +                           // 원청사 고객
                                        '	    , Owner.EmployeeNumber ' +                                  // 소유자 (영업 대표)
                                        '	    , Owner.Name ' +                                            // 소유자 (영업 대표)
                                        '	    , ProposalPM__r.EvSapEmpNO__c ' +                           // 제안 PM
                                        '	    , ProposalPM__r.EvHName__c ' +                              // 제안 PM
                                        '	    , GroupInternal__c ' +                                      // 그룹 내 사업 여부
                                        '	    , KoreaDomestic__c ' +                                      // 국내/해외 여부
                                        '	    , Amount ' +                                                // 예상금액
                                        '	    , CurrencyIsoCode ' +                                       // 사업 기회 금액의 통화
                                        '	    , CloseDate ' +                                             // 예상수주일자
                                        '	    , cRevenueStartDate__c ' +                                  // (계약)매출 시작일
                                        '	    , cRevenueEndDate__c ' +                                    // (계약)매출 종료일
                                        '	    , CompanyCode__c ' +                                        // Company Code
                                        '	    , IsDeleted ' +                                             // 삭제 여부
                                        '	    , CreatedDate ' +                                           // Opportunity 등록일
                                        '	    , CreatedBy.EmployeeNumber ' +                              // Opportunity 등록자 사번
                                        '	    , LastModifiedDate ' +                                      // Opportunity 수정일
                                        '	    , LastModifiedBy.EmployeeNumber ' +                         // Opportunity 수정자 사번
                                        '	    , BusinessType__c ' +                                       // 사업 유형
                                        '	    , tolabel(BusinessType__c) BusinessTypeLabel ' +            // 사업 유형명
                                        '       , cOriginAcc__r.Name ' +                                    // 원청사 고객명
                                        '       , Account.Name ' +                                          // 고객사명
                                        '	    , Probability ' +                                           // 확도
            							'		, Probability_new__c ' +									// -->[Added Probability_new__c as per v-1.1]
                                        '	    , VRBMethod__c ' +                                          // VRB 유형
                                        '	    , Description ' +                                           // 사업기회 개요
                                        '	    , Collaboration__c ' +                                      // 법인 협업 여부
                                        '       , IsOriginal__c ' +                                         // 
                                        '	    , OpportunityStatus__c ' +                                  // Opportunity Status
                                        '	    , toLabel( OpportunityStatus__c) OpportunityStatusLabel ' + // Opportunity Status 명
                                        '	    , SalesDepartment__r.CostCenter__c ' +                      // 수주 사업그룹 코스트센터 코드
                                        '	    , cPrimarySalesDepartment__r.CostCenter__c ' +              // 주 매출 부서 코스트센터 코드
                                        '	    , BusinessLevel__c ' +                                      // 사업 등급
                                        '	    , BiddingMethod__c ' +                                      // 입찰 방식
                                        '       , Account.Owner.EmployeeNumber ' +                          // 고객오너(영업대표)
                                        '       , Account.Owner.Name ' +                                    // 고객오너(영업대표) 명
                                        '	    , BizTeamAttributes01__c ' +                                // 사업팀 정의 속성01
                                        '	    , BizTeamAttributes02__c ' +                                // 사업팀 정의 속성02
                                        '	    , BizTeamAttributes03__c ' +                                // 사업팀 정의 속성03
                                        '	    , BizTeamAttributes04__c ' +                                // 사업팀 정의 속성04
                                        '	    , LogisticsCustomerType__c ' +                              // 물류 고객 구분
                                        '	    , LogisticsBizDevelopmentType__c ' +                        // 사업 개발 유형
                                        '	    , SalesRegion__c ' +                                        // 수주 권역
                                        '	    , SalesOrganization__r.Region__c ' +                        // 수주 권역 코드
                                        '	    , SalesOrganization__c ' +                                  // 수주 거점
                                        '	    , SalesOrganization__r.Code__c ' +                          // 수주 거점 코드
                                        '	    , DeliveryRegion__c ' +                                     // 매출 권역
                                        '	    , DeliveryOrganization__r.Region__c ' +                     // 매출 권역 코드
                                        '	    , DeliveryOrganization__c ' +                               // 매출 거점
                                        '	    , DeliveryOrganization__r.Code__c ' +                       // 매출 거점 코드
                                        '	    , LogisticsBizType__c ' +                                   // 물류 서비스 범위
                                        '	    , LogisticsServiceType__c ' +                               // 물류 서비스 영역
                                        '	    , BiddingDeadline__c ' +                                    // 입찰 마감일
                                        '	    , LBSExceptionType__c ' +                                   // 예외 LBS 유형 확인
                                        '	    , SubIndusrty__c ' +                                        // 하위 업종 구분
                                        '       , Owner.FederationIdentifier ' +                            // 소유자 (영업 대표)의 EP ID
                                        '       , CreatedBy.FederationIdentifier ' +                        // Created By ID의 EP ID
                                        '       , LastModifiedBy.FederationIdentifier ' +                   // Last Modified By ID의 EP ID
                                        '       , ResourcePreInput__c ' +                                   // 선투입 여부
                                        '       , Reuse__c ' +                                              // 재활용 필요성 여부
                                        '       , ReuseReason__c ' +                                        // 재활용 필요성 여부 사유
                                        '       , ColCompanyCode__c ' +                                     // 협업 법인 코드 (협업 BO의 Company Code)                                        
                                        '       , FinalBusinessLevel__c ' +                                        
                                        '       , AgencyContract__c	' +                                     // 계약 대행 여부
                                        '       , AgencyContractException__c ' +                            // 계약 대행 예외 처리 여부
                                        '       , MigData__c ' +                                            // 마이그 데이터
                                        '       , IsEdited__c ' +                                           // 수정여부
                                        '       , LostReasonLogistics__c ' +                                // 실주사유
                                        '       , Competitors__c ' +                                        // 경쟁사
                                        'From   Opportunity ';                                        
        if (Test.isRunningTest()){
            query_RESULT += ' limit 1';
        }
        else{
            query_RESULT += 'Where  EPCompanyCode__c != null ';
            query_RESULT += 'AND    RecordType.DeveloperName = \'Logistics\' ';            
            query_RESULT += 'AND    ( ( MigData__c = false ) OR ( MigData__c = true and IsEdited__c = true) ) ';// 2021-02-02 / younghoon.kim / Migration Data는 SAP으로 전송하지않도록 조건 추가
        }

        Database.QueryLocator returnScope = DataBase.getQueryLocator(query_RESULT);

        return returnScope;
    }
    
    public void execute(Database.BatchableContext bc, List<sObject> scopeList){
        
        // IF-094의 형태로 Dummy 오브젝트에 저장
        try{
            
            IF_EccOpportunityLogisController.OutputHeader outHeader = IF_EccOpportunityLogisController.getOpportunityLogisDetailInfo((List<Opportunity>)scopeList);
            List<IF_EccOpportunityLogisController.OutputClass> outClassList = outHeader.OPPORTUNITY;
            if(outClassList.size() > 0){
                List<EccOpptyDataLogiDummy__c> eccOpptyDummyList = new List<EccOpptyDataLogiDummy__c>();
                for(IF_EccOpportunityLogisController.OutputClass outClass : outClassList){
                    EccOpptyDataLogiDummy__c eccOpptyDummy = new EccOpptyDataLogiDummy__c();
                    eccOpptyDummy.OPPORTUNITY_ID__c           = outClass.OPPORTUNITY_ID;           // Opportunity ID
                    eccOpptyDummy.ORDER_ID__c                 = outClass.ORDER_ID;                 // 사업기회 ID <-- 사업 기회 Code
                    eccOpptyDummy.ORDER_NAME__c               = outClass.ORDER_NAME;               // BO 명 <-- 사업기획명
                    eccOpptyDummy.SALES_PHASE__c              = outClass.SALES_PHASE;              // BOM 단계 <-- 단계
                    eccOpptyDummy.ZZSTATUS__c                 = outClass.ZZSTATUS;                 // BO Activity Status
                    eccOpptyDummy.ORDER_TYPE__c               = outClass.ORDER_TYPE;               // 사업유형 <-- 사업기회 유형
                    eccOpptyDummy.SALES_DEPT_CODE__c          = outClass.SALES_DEPT_CODE;          // 수주부서 인사코드 <-- 수주 사업그룹 인사코드
                    eccOpptyDummy.DEVELOP_DEPT_CODE__c        = outClass.DEVELOP_DEPT_CODE;        // 매출부서 인사코드 <-- 주 매출 부서 인사코드
                    eccOpptyDummy.COMPANY_ID__c               = outClass.COMPANY_ID;               // 고객사 코드 <-- Contract Account
                    eccOpptyDummy.ORIGINAL_COMPANY_ID__c      = outClass.ORIGINAL_COMPANY_ID;      // 원청사 코드 <-- 원청사 고객
                    eccOpptyDummy.SALES_EMP_NO__c             = outClass.SALES_EMP_NO;             // 영업대표사번 <-- 소유자 (영업 대표)
                    eccOpptyDummy.SALES_EMP_NAME__c           = outClass.SALES_EMP_NAME;           // 영업대표명 <-- 소유자 (영업 대표)
                    eccOpptyDummy.PROPOSAL_EMP_NO__c          = outClass.PROPOSAL_EMP_NO;          // 제안PM사번 <-- 제안 PM
                    eccOpptyDummy.PROPOSAL_EMP_NAME__c        = outClass.PROPOSAL_EMP_NAME;        // 제안PM명 <-- 제안 PM
                    eccOpptyDummy.IN_OUT_TYPE__c              = outClass.IN_OUT_TYPE;              // 그룹내/그룹외 <-- 그룹 내 사업 여부
                    eccOpptyDummy.DOM_ABR_TYPE__c             = outClass.DOM_ABR_TYPE;             // 국내/해외 <-- 국내/해외 여부
                    eccOpptyDummy.ORDER_AMT__c                = outClass.ORDER_AMT;                // 계약 수주액 <-- 예상금액
                    eccOpptyDummy.CURRENCY_CODE__c            = outClass.CURRENCY_CODE;            // 계약 통화 <-- 사업 기회 금액의 통화
                    eccOpptyDummy.DU_ORDER_DATE__c            = outClass.DU_ORDER_DATE;            // 예상수주일자 <-- 예상수주일자
                    eccOpptyDummy.CONTRACT_TERM_FROM__c       = outClass.CONTRACT_TERM_FROM;       // 계약기간 시작일 <-- (계약)매출 시작일
                    eccOpptyDummy.CONTRACT_TERM_TO__c         = outClass.CONTRACT_TERM_TO;         // 계약기간 종료일 <-- (계약)매출 종료일
                    eccOpptyDummy.COMPANY__c                  = outClass.COMPANY;                  // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
                    eccOpptyDummy.SAP_COMPANY__c              = outClass.SAP_COMPANY;              // 회사코드 <-- Company Code
                    eccOpptyDummy.LOCAL_CURRENCY_CODE__c      = outClass.LOCAL_CURRENCY_CODE;      // 로컬 통화 <-- Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode
                    eccOpptyDummy.FLAG__c                     = outClass.FLAG;                     // 삭제여부 <-- 삭제 여부
                    eccOpptyDummy.REG_DATE__c                 = outClass.REG_DATE;                 // BO 등록일 <-- Opportunity 등록일
                    eccOpptyDummy.REG_EMP_NO__c               = outClass.REG_EMP_NO;               // BO 등록자 사번 <-- Opportunity 등록자 사번
                    eccOpptyDummy.UPDATE_DATE__c              = outClass.UPDATE_DATE;              // BO 최종 수정일 <-- Opportunity 수정일
                    eccOpptyDummy.UPDATE_EMP_NO__c            = outClass.UPDATE_EMP_NO;            // BO 최종 수정자 사번 <-- Opportunity 수정자 사번
                    eccOpptyDummy.BIZ_TYPE__c                 = outClass.BIZ_TYPE;                 // 사업 유형 <-- 사업 유형
                    eccOpptyDummy.BIZ_TYPE_NM__c              = outClass.BIZ_TYPE_NM;              // 사업 유형명 <-- 사업 유형명
                    eccOpptyDummy.ORGIN_ACCOUNT_DESC__c       = outClass.ORGIN_ACCOUNT_DESC;       // 원청사 고객명
                    eccOpptyDummy.CONTACTTEXT__c              = outClass.CONTACTTEXT;              // Main Contact <-- 고객사명 (2021-02-16 삭제)
                    eccOpptyDummy.PROBABILITY__c              = outClass.PROBABILITY;              // 확도 <-- 확도
                    eccOpptyDummy.ZZSALESSTR__c               = outClass.ZZSALESSTR;               // 수주전략세션 수행 여부 <-- Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리
                    eccOpptyDummy.BO_OVERVIEW__c              = outClass.BO_OVERVIEW;              // 개요 <-- 사업기회 개요
                    eccOpptyDummy.ZZCOOPER__c                 = outClass.ZZCOOPER;                 // 협업여부(Collaboration) <-- 법인 협업 여부
                    eccOpptyDummy.BO_STATUS__c                = outClass.BO_STATUS;                // BO status(Drop, Hold, In process, Lose, Win) <-- Opportunity Status
                    eccOpptyDummy.LOCAL_ORDER_AMT__c          = outClass.LOCAL_ORDER_AMT;          // 계약 수주액(로컬 통화) <-- Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산
                    eccOpptyDummy.SALES_DEPT_COST_CENTER__c   = outClass.SALES_DEPT_COST_CENTER;   // 수주부서 코스트센터 코드 <-- 수주 사업그룹 코스트센터 코드
                    eccOpptyDummy.DEVELOP_DEPT_COST_CENTER__c = outClass.DEVELOP_DEPT_COST_CENTER; // 매출부서 코스트센터 코드 <-- 주 매출 부서 코스트센터 코드
                    eccOpptyDummy.BO_CLASS__c                 = outClass.BO_CLASS;                 // 사업기회 등급 <-- 사업 등급
                    eccOpptyDummy.BID_METHOD__c               = outClass.BID_METHOD;               // 입찰 방식 <-- 입찰 방식
                    eccOpptyDummy.AM_EMP_NO__c                = outClass.AM_EMP_NO;                // AM사번 <-- 고객오너(영업대표)
                    eccOpptyDummy.AM_EMP_NAME__c              = outClass.AM_EMP_NAME;              // AM명 <-- 고객오너(영업대표)명
                    eccOpptyDummy.COMPANY_ACCOUNT_DESC__c     = outClass.COMPANY_ACCOUNT_DESC;     // 고객사 명
                    eccOpptyDummy.TECH_PROP__c                = outClass.TECH_PROP;                // 제안서 여부 <-- Submit Proposal
                    eccOpptyDummy.ZZVRB_FQ_T__c               = outClass.ZZVRB_FQ_T;               // VRB Method Description <-- VRB 유형
                    eccOpptyDummy.UDATE_ZP21__c               = outClass.UDATE_ZP21;               // 사기검(BO Review) <-- Review Opportunity
                    eccOpptyDummy.UDATE_VRB__c                = outClass.UDATE_VRB;                // VRB(Gate Review) <-- BO Approval Result(ZP52, 사업기회 검토)
                    eccOpptyDummy.UDATE_LOSE__c               = outClass.UDATE_LOSE;               // LOSE_END_DATE <-- Report Lost Opportunity
                    eccOpptyDummy.UDATE_DROP__c               = outClass.UDATE_DROP;               // DROP_END_DATE <-- Abort Opportunity, Drop Opportunity, Hold Opportunity
                    eccOpptyDummy.SALES_COST_CD__c            = outClass.SALES_COST_CD;            // 원가귀속부서 <-- 사업팀 정의 속성01
                    eccOpptyDummy.CGUBUN_ID__c                = outClass.CGUBUN_ID;                // 거점코드 <-- 사업팀 정의 속성02
                    eccOpptyDummy.BO_LBS_CLASS__c             = outClass.BO_LBS_CLASS;             // RLBS산업유형코드 <-- 사업팀 정의 속성03
                    eccOpptyDummy.KEY_ACCOUNT_YN__c           = outClass.KEY_ACCOUNT_YN;           // 키어카운트여부 <-- 사업팀 정의 속성04
                    eccOpptyDummy.BIG_ACCOUNT_YN__c           = outClass.BIG_ACCOUNT_YN;           // 빅어카운트여부 <-- Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"
                    eccOpptyDummy.CELLO_URL__c                = outClass.CELLO_URL;                // Opportunity 링크URL <-- URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view
                    eccOpptyDummy.AccountNumber__c            = outClass.AccountNumber;            // MDG 고객코드 <-- Contract Account
                    eccOpptyDummy.SHPR_CCD__c                 = outClass.SHPR_CCD;                 // 화주구분코드 <-- 물류 고객 구분
                    eccOpptyDummy.RLBS_PJT_TCD__c             = outClass.RLBS_PJT_TCD;             // 사업 개발 유형 <-- 사업 개발 유형
                    eccOpptyDummy.SALES_AREA_CCD__c           = outClass.SALES_AREA_CCD;           // 수주 권역 <-- 수주 권역
                    eccOpptyDummy.SALES_PRNT_ORG_CD__c        = outClass.SALES_PRNT_ORG_CD;        // 수주 거점 <-- 수주 거점
                    eccOpptyDummy.DLVRY_AREA_CCD__c           = outClass.DLVRY_AREA_CCD;           // 매출 권역 <-- 매출 권역
                    eccOpptyDummy.DLVRY_PRNT_ORG_CD__c        = outClass.DLVRY_PRNT_ORG_CD;        // 매출 거점 <-- 매출 거점
                    eccOpptyDummy.RLBS_BIZ_TCD__c             = outClass.RLBS_BIZ_TCD;             // 물류 서비스 범위 <-- 물류 서비스 범위
                    eccOpptyDummy.RLBS_SVC_TCD__c             = outClass.RLBS_SVC_TCD;             // 물류 서비스 영역 <-- 물류 서비스 영역
                    eccOpptyDummy.BID_EST_DTM__c              = outClass.BID_EST_DTM;              // 입찰 마감일 <-- 입찰 마감일
                    eccOpptyDummy.LBS_Exception_Type__c       = outClass.LBS_Exception_Type;       // 예외 :LBS 유형 확인 <-- 예외 LBS 유형 확인
                    eccOpptyDummy.RLBS_IND_TCD__c             = outClass.RLBS_IND_TCD;             // 물류 업종 <-- 하위 업종 구분
                    eccOpptyDummy.USER_ID__c                  = outClass.USER_ID;                  // 소유자 (영업 대표) <-- 소유자 (영업 대표)의 EP ID
                    eccOpptyDummy.INS_PERSON_ID__c            = outClass.INS_PERSON_ID;            // Created By ID <-- Created By ID의 EP ID
                    eccOpptyDummy.UPD_PERSON_ID__c            = outClass.UPD_PERSON_ID;            // Last Modified By ID <-- Last Modified By ID의 EP ID
                    eccOpptyDummy.COMPETITORS__c              = outClass.COMPETITORS;              //경쟁사
                    eccOpptyDummy.LOST_REASON__c              = outClass.LOST_REASON;              //AR 실주 사유
    
                    eccOpptyDummyList.add(eccOpptyDummy);
                }
                //if(eccOpptyDummyList.size() > 0) insert eccOpptyDummyList;
                if(eccOpptyDummyList.size() > 0){
                    IF_Log  log = new IF_Log();
                    String guId  = IF_Util.generateGuid();
                    IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'EccOpptyLogiDummyInsert_Batch', guId, 'Batch_EccOpptyLogiDummyInsert', 'execute', '', '');

                    Database.SaveResult[] srList = DataBase.insert( eccOpptyDummyList, false);
                    for (Database.SaveResult sr : srList) {
                        if (!sr.isSuccess()) {
                            // Operation failed, so get all errors                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                System.debug('Opportunity fields that affected this error: ' + err.getFields());
                                log.addLog(err.getStatusCode() + ': ' + err.getMessage());
                                log.addLog('Opportunity fields that affected this error: ' + err.getFields());

                            }
                        }
                    }  
                    log.createLog( infLog);
                } 
            }
            
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
        }
    }

    public void finish(DataBase.BatchableContext BC){
        
    }
}