/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : Data Lake 전송용 데이터를 생성해주는 Batch
 * @last modified on  : 2024-01-19
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-07-08   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2023-03-12   anish.jain@partner.samsung.com  MySales-147
 * 1.2   2024-01-19   sarthak.j1@samsung.com          Opportunity - new 'Probability' Field Creation -> MYSALES-416
**/
global class Batch_OpportunityForDataLake implements DataBase.Batchable<SObject>{
    // DataLake용 데이터를 사업기회의 조건이 필요한경우 추가
    global String oppty_where = '';
    global String oppty_order = '';
    global String oppty_limit = '';

    global Batch_OpportunityForDataLake(){  

    }

    global DataBase.QueryLocator start(DataBase.BatchableContext BC){
        String query_RESULT = '';
        String query_SELECT = 'SELECT ';
        String query_FROM   = ' FROM Opportunity';
        String query_WHERE  = ' WHERE ';
        String query_ORDER  = ' ORDER BY ';
        String query_LIMIT  = ' LIMIT ';
        
        // 대상 사업기회 조회
        query_SELECT += '  Id ' +		
                        ', OpportunityCode__c ' +                                                        // 사업 기회 Code
                        ', RecordType.DeveloperName ' +                                                  // RecordType 구분
                        ', Name ' +                                                                      // 사업기회명
                        ', StageName ' +                                                                 // 단계
                        ', ActivityStatus__c ' +                                                         // Current BO Activity Status
                        ', Type ' +                                                                      // 사업기회 유형
                        ', toLabel(Type) TypeLabel ' +                                                   // 사업기회 유형명
                        ', Account.AccountNumber ' +                                                     // Contract Account
                        ', cOriginAcc__r.AccountNumber ' +                                               // 원청사 고객
                        ', Owner.EmployeeNumber ' +                                                      // 소유자 (영업 대표)
                        ', Owner.Name ' +                                                                // 소유자 (영업 대표)
                        ', ProposalPM__r.EvSapEmpNO__c ' +                                               // 제안 PM
                        ', ProposalPM__r.EvHName__c ' +                                                  // 제안 PM
                        ', GroupInternal__c ' +                                                          // 그룹 내 사업 여부
                        ', KoreaDomestic__c ' +                                                          // 국내/해외 여부
                        ', Amount ' +                                                                    // 예상금액
                        ', CurrencyIsoCode ' +                                                           // 사업 기회 금액의 통화
                        ', CloseDate ' +                                                                 // 예상수주일자
                        ', cRevenueStartDate__c ' +                                                      // (계약)매출 시작일
                        ', cRevenueEndDate__c ' +                                                        // (계약)매출 종료일
                        ', CompanyCode__c ' +                                                            // Company Code
                        ', IsDeleted ' +                                                                 // 삭제 여부
                        ', CreatedDate ' +                                                               // Opportunity 등록일
                        ', CreatedBy.EmployeeNumber ' +                                                  // Opportunity 등록자 사번
                        ', LastModifiedDate ' +                                                          // Opportunity 수정일
                        ', LastModifiedBy.EmployeeNumber ' +                                             // Opportunity 수정자 사번
                        ', BusinessType__c ' +                                                           // 사업 유형
                        ', tolabel(BusinessType__c) BusinessTypeLabel ' +                                // 사업 유형명
                        ', cOriginAcc__r.Name ' +                                                        // 원청사 고객명
                        ', Account.Name ' +                                                              // 고객사명
                        ', Probability_new__c ' +                                                        // 확도 -->[Changed Probability to Probability_new__c] v-1.2
                        ', Probability ' +                                                               // 확도 -->[Added back Probability for additional requirement] v-1.2
            			', Opportunity_Review_Confirm_New__c ' +                                         // [Added to resolve test class error] v-1.2
                        ', VRBMethod__c ' +                                                              // VRB 유형
                        ', Description ' +                                                               // 사업기회 개요
                        ', Collaboration__c ' +                                                          // 법인 협업 여부
                        ', IsOriginal__c ' +                                                             // 
                        ', OpportunityStatus__c ' +                                                      // Opportunity Status
                        ', toLabel(OpportunityStatus__c) OpportunityStatusLabel ' +                      // Opportunity Status 명
                        ', SalesDepartment__r.CostCenter__c ' +                                          // 수주 사업그룹 코스트센터 코드
                        ', cPrimarySalesDepartment__r.CostCenter__c ' +                                  // 주 매출 부서 코스트센터 코드
                        ', BusinessLevel__c ' +                                                          // 사업 등급
                        ', BiddingMethod__c ' +                                                          // 입찰 방식
                        ', Account.Owner.EmployeeNumber ' +                                              // 고객오너(영업대표)
                        ', Account.Owner.Name ' +                                                        // 고객오너(영업대표) 명
                        ', BizTeamAttributes01__c ' +                                                    // 사업팀 정의 속성01
                        ', BizTeamAttributes02__c ' +                                                    // 사업팀 정의 속성02
                        ', BizTeamAttributes03__c ' +                                                    // 사업팀 정의 속성03
                        ', BizTeamAttributes04__c ' +                                                    // 사업팀 정의 속성04
                        ', LogisticsCustomerType__c ' +                                                  // 물류 고객 구분
                        ', toLabel(LogisticsCustomerType__c) LogisticsCustomerTypeLabel ' +              // 물류 고객 구분명
                        ', LogisticsBizDevelopmentType__c ' +                                            // 사업 개발 유형
                        ', toLabel(LogisticsBizDevelopmentType__c) LogisticsBizDevelopmentTypeLabel ' +  // 사업 개발 유형명
                        ', SalesRegion__c ' +                                                            // 수주 권역
                        ', SalesOrganization__r.Region__c ' +                                            // 수주 권역 코드
                        ', SalesOrganization__c ' +                                                      // 수주 거점
                        ', SalesOrganization__r.Code__c ' +                                              // 수주 거점 코드
                        ', DeliveryRegion__c ' +                                                         // 매출 권역
                        ', DeliveryOrganization__r.Region__c ' +                                         // 매출 권역 코드
                        ', DeliveryOrganization__c ' +                                                   // 매출 거점
                        ', DeliveryOrganization__r.Code__c ' +                                           // 매출 거점 코드
                        ', LogisticsBizType__c ' +                                                       // 물류 서비스 범위
                        ', toLabel(LogisticsBizType__c) LogisticsBizTypeLabel ' +                        // 물류 서비스 범위명
                        ', LogisticsServiceType__c ' +                                                   // 물류 서비스 영역
                        ', toLabel(LogisticsServiceType__c) LogisticsServiceTypeLabel ' +                // 물류 서비스 영역명
                        ', BiddingDeadline__c ' +                                                        // 입찰 마감일
                        ', LBSExceptionType__c ' +                                                       // 예외 LBS 유형 확인
                        ', SubIndusrty__c ' +                                                            // 하위 업종 구분
                        ', toLabel(SubIndusrty__c) SubIndusrtyLabel ' +                                  // 하위 업종 구분명
                        ', Owner.FederationIdentifier ' +                                                // 소유자 (영업 대표)의 EP ID
                        ', CreatedBy.FederationIdentifier ' +                                            // Created By ID의 EP ID
                        ', LastModifiedBy.FederationIdentifier ' +                                       // Last Modified By ID의 EP ID
                        ', ResourcePreInput__c ' +                                                       // 선투입 여부
                        ', Reuse__c ' +                                                                  // 재활용 필요성 여부
                        ', ReuseReason__c ' +                                                            // 재활용 필요성 여부 사유
                        ', ColCompanyCode__c ' +                                                         // 협업 법인 코드 (협업 BO의 Company Code)
                        ', FinalBusinessLevel__c ' +
                        ', AgencyContract__c	' +                                                      // 계약 대행 여부
                        ', AgencyContractException__c ' +                                                // 계약 대행 예외 처리 여부
                        ', BusinessType2__c ' +                                                          // 사업유형2
                        ', DealBreak__c ' +                                                              // Deal Break
                        ', Construction__c ' +                                                           // 건설 여부
                        ', LegalReviewNo__c ' +                                                          // 법무 검토 번호
                        ', MigData__c ' +                                                                // 마이그 데이터
                        ', IsEdited__c '+                                                                // 수정여부
                        ', Opportunity_Review_VRB_Type_Confirm__c ' + 
                        ', Opportunity_Review_Exception__c ' +                                           // 사업심의유형 변경여부
                        ', Opportunity_Review_Exception_Modifier__r.FederationIdentifier ' +             // 사업심의유형 변경자
                        ', Opportunity_Review_Confirm__c ' +                                             // BO 점검 확정여부
                        ', LostReasonLogistics__c ' +                                                    // 물류 중도종결사유
                        ', GlobalCustomer__c ' +
        				', FirstCloseDate__c ' +                                                         // 최초수주예상일자
                        //Added by Anish-V1.1
                        ', Competitors__c ' + 
                        ', mGroupAccNameL1__c ' + 
                        ', mGroupAccNameL2__c ' + 
                        ', mGroupAccNameL3__c ' +
                        ', CollaborationBOId__r.Name  ' + 
                        ', OurRole__c ' + 
                        ', Security__c ' + 
                        ', Urgency__c ' 
            ;                                                          

        query_RESULT = query_SELECT + query_FROM;

        if(oppty_where != ''){
            query_WHERE += oppty_where;
            query_RESULT += query_WHERE;
        }

        if(oppty_order != ''){
            query_ORDER += oppty_order;
            query_RESULT += query_ORDER;
        }

        if(oppty_limit != ''){
            query_LIMIT += oppty_limit;
            query_RESULT += query_LIMIT;
        }

        Database.QueryLocator returnScope = DataBase.getQueryLocator(query_RESULT);

        return returnScope;
    }
    
    global void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){
        IF_EccOpportunityController.OutputHeader outHeader = IF_EccOpportunityController.getOpportunityDetailInfo(scopeList);
        
        // IF-125의 형태로 Data Lake 오브젝트에 저장
        try{
            List<IF_EccOpportunityController.OutputClass> outClassList = outHeader.OPPORTUNITY;
            if(outClassList.size() > 0){
                List<DataLakeDummy__c> dlDummyList = new List<DataLakeDummy__c>();
                for(IF_EccOpportunityController.OutputClass outClass : outClassList){
                    DataLakeDummy__c dlDummy = new DataLakeDummy__c();
                    dlDummy.OPPORTUNITY_ID__c           = outClass.OPPORTUNITY_ID;                   // Opportunity ID
                    dlDummy.ORDER_ID__c                 = outClass.ORDER_ID;                         // 사업기회 ID <-- 사업 기회 Code
                    dlDummy.ORDER_NAME__c               = outClass.ORDER_NAME;                       // BO 명 <-- 사업기획명
                    dlDummy.SALES_PHASE__c              = outClass.SALES_PHASE;                      // BOM 단계 <-- 단계
                    dlDummy.ZZSTATUS__c                 = outClass.ZZSTATUS;                         // BO Activity Status
                    dlDummy.ORDER_TYPE__c               = outClass.ORDER_TYPE;                       // 사업유형 <-- 사업기회 유형
                    dlDummy.SALES_DEPT_CODE__c          = outClass.SALES_DEPT_CODE;                  // 수주부서 인사코드 <-- 수주 사업그룹 인사코드
                    dlDummy.DEVELOP_DEPT_CODE__c        = outClass.DEVELOP_DEPT_CODE;                // 매출부서 인사코드 <-- 주 매출 부서 인사코드
                    dlDummy.COMPANY_ID__c               = outClass.COMPANY_ID;                       // 고객사 코드 <-- Contract Account
                    dlDummy.ORIGINAL_COMPANY_ID__c      = outClass.ORIGINAL_COMPANY_ID;              // 원청사 코드 <-- 원청사 고객
                    dlDummy.SALES_EMP_NO__c             = outClass.SALES_EMP_NO;                     // 영업대표사번 <-- 소유자 (영업 대표)
                    dlDummy.SALES_EMP_NAME__c           = outClass.SALES_EMP_NAME;                   // 영업대표명 <-- 소유자 (영업 대표)
                    dlDummy.PROPOSAL_EMP_NO__c          = outClass.PROPOSAL_EMP_NO;                  // 제안PM사번 <-- 제안 PM
                    dlDummy.PROPOSAL_EMP_NAME__c        = outClass.PROPOSAL_EMP_NAME;                // 제안PM명 <-- 제안 PM
                    dlDummy.IN_OUT_TYPE__c              = outClass.IN_OUT_TYPE;                      // 그룹내/그룹외 <-- 그룹 내 사업 여부
                    dlDummy.DOM_ABR_TYPE__c             = outClass.DOM_ABR_TYPE;                     // 국내/해외 <-- 국내/해외 여부
                    dlDummy.ORDER_AMT__c                = outClass.ORDER_AMT;                        // 계약 수주액 <-- 예상금액
                    dlDummy.CURRENCY_CODE__c            = outClass.CURRENCY_CODE;                    // 계약 통화 <-- 사업 기회 금액의 통화
                    dlDummy.DU_ORDER_DATE__c            = outClass.DU_ORDER_DATE;                    // 예상수주일자 <-- 예상수주일자
                    dlDummy.CONTRACT_TERM_FROM__c       = outClass.CONTRACT_TERM_FROM;               // 계약기간 시작일 <-- (계약)매출 시작일
                    dlDummy.CONTRACT_TERM_TO__c         = outClass.CONTRACT_TERM_TO;                 // 계약기간 종료일 <-- (계약)매출 종료일
                    dlDummy.COMPANY__c                  = outClass.COMPANY;                          // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
                    dlDummy.SAP_COMPANY__c              = outClass.SAP_COMPANY;                      // 회사코드 <-- Company Code
                    dlDummy.LOCAL_CURRENCY_CODE__c      = outClass.LOCAL_CURRENCY_CODE;              // 로컬 통화 <-- Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode
                    dlDummy.FLAG__c                     = outClass.FLAG;                             // 삭제여부 <-- 삭제 여부
                    dlDummy.REG_DATE__c                 = outClass.REG_DATE;                         // BO 등록일 <-- Opportunity 등록일
                    dlDummy.REG_EMP_NO__c               = outClass.REG_EMP_NO;                       // BO 등록자 사번 <-- Opportunity 등록자 사번
                    dlDummy.UPDATE_DATE__c              = outClass.UPDATE_DATE;                      // BO 최종 수정일 <-- Opportunity 수정일
                    dlDummy.UPDATE_EMP_NO__c            = outClass.UPDATE_EMP_NO;                    // BO 최종 수정자 사번 <-- Opportunity 수정자 사번
                    dlDummy.BIZ_TYPE__c                 = outClass.BIZ_TYPE;                         // 사업 유형 <-- 사업 유형
                    dlDummy.BIZ_TYPE_NM__c              = outClass.BIZ_TYPE_NM;                      // 사업 유형명 <-- 사업 유형명
                    dlDummy.ORGIN_ACCOUNT_DESC__c       = outClass.ORGIN_ACCOUNT_DESC;               // 원청사 고객명
                    dlDummy.PROBABILITY__c              = outClass.PROBABILITY;                      // 확도 <-- 확도
                    dlDummy.ZZSALESSTR__c               = outClass.ZZSALESSTR;                       // 수주전략세션 수행 여부 <-- Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리
                    dlDummy.BO_OVERVIEW__c              = outClass.BO_OVERVIEW;                      // 개요 <-- 사업기회 개요
                    dlDummy.ZZCOOPER__c                 = outClass.ZZCOOPER;                         // 협업여부(Collaboration) <-- 법인 협업 여부
                    dlDummy.BO_STATUS__c                = outClass.BO_STATUS;                        // BO status(Drop, Hold, In process, Lose, Win) <-- Opportunity Status
                    dlDummy.LOCAL_ORDER_AMT__c          = outClass.LOCAL_ORDER_AMT;                  // 계약 수주액(로컬 통화) <-- Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산
                    dlDummy.SALES_DEPT_COST_CENTER__c   = outClass.SALES_DEPT_COST_CENTER;           // 수주부서 코스트센터 코드 <-- 수주 사업그룹 코스트센터 코드
                    dlDummy.DEVELOP_DEPT_COST_CENTER__c = outClass.DEVELOP_DEPT_COST_CENTER;         // 매출부서 코스트센터 코드 <-- 주 매출 부서 코스트센터 코드
                    dlDummy.BO_CLASS__c                 = outClass.BO_CLASS;                         // 사업기회 등급 <-- 사업 등급
                    dlDummy.BID_METHOD__c               = outClass.BID_METHOD;                       // 입찰 방식 <-- 입찰 방식
                    dlDummy.AM_EMP_NO__c                = outClass.AM_EMP_NO;                        // AM사번 <-- 고객오너(영업대표)
                    dlDummy.AM_EMP_NAME__c              = outClass.AM_EMP_NAME;                      // AM명 <-- 고객오너(영업대표)명
                    dlDummy.COMPANY_ACCOUNT_DESC__c     = outClass.COMPANY_ACCOUNT_DESC;             // 고객사 명
                    dlDummy.TECH_PROP__c                = outClass.TECH_PROP;                        // 제안서 여부 <-- Submit Proposal
                    dlDummy.ZZVRB_FQ_T__c               = outClass.ZZVRB_FQ_T;                       // VRB Method Description <-- VRB 유형
                    dlDummy.UDATE_ZP21__c               = outClass.UDATE_ZP21;                       // 사기검(BO Review) <-- Review Opportunity
                    dlDummy.UDATE_VRB__c                = outClass.UDATE_VRB;                        // VRB(Gate Review) <-- BO Approval Result(ZP52, 사업기회 검토)
                    dlDummy.UDATE_LOSE__c               = outClass.UDATE_LOSE;                       // LOSE_END_DATE <-- Report Lost Opportunity
                    dlDummy.UDATE_DROP__c               = outClass.UDATE_DROP;                       // DROP_END_DATE <-- Abort Opportunity, Drop Opportunity, Hold Opportunity
                    dlDummy.EXEC_PM_NO__c               = outClass.EXEC_PM_NO;                       // 실행PM 사번 <- 제안 PM (2020-12-28 추가)
                    dlDummy.INPUT_P__c                  = outClass.INPUT_P;                          // 선투입 <- 선투입 여부 (X(True) / _(False)) (2020-12-28 추가)
                    dlDummy.BIZ_FROM_DT__c              = outClass.BIZ_FROM_DT;                      // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가)
                    dlDummy.BIZ_TO_DT__c                = outClass.BIZ_TO_DT;                        // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가)
                    dlDummy.SALES_COST_CD__c            = outClass.SALES_COST_CD;                    // 원가귀속부서 <-- 사업팀 정의 속성01
                    dlDummy.CGUBUN_ID__c                = outClass.CGUBUN_ID;                        // 거점코드 <-- 사업팀 정의 속성02
                    dlDummy.BO_LBS_CLASS__c             = outClass.BO_LBS_CLASS;                         // RLBS산업유형코드 <-- 사업팀 정의 속성03
                    dlDummy.KEY_ACCOUNT_YN__c           = outClass.KEY_ACCOUNT_YN;                   // 키어카운트여부 <-- 사업팀 정의 속성04
                    dlDummy.BIG_ACCOUNT_YN__c           = outClass.BIG_ACCOUNT_YN;                   // 빅어카운트여부 <-- Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"
                    dlDummy.SFDC_URL__c                 = outClass.SFDC_URL;                         // Opportunity 링크URL <-- URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view
                    dlDummy.AccountNumber__c            = outClass.AccountNumber;                    // MDG 고객코드 <-- Contract Account
                    dlDummy.SHPR_CCD__c                 = outClass.SHPR_CCD;                         // 화주구분코드 <-- 물류 고객 구분
                    dlDummy.RLBS_PJT_TCD__c             = outClass.RLBS_PJT_TCD;                     // 사업 개발 유형 <-- 사업 개발 유형
                    dlDummy.SALES_AREA_CCD__c           = outClass.SALES_AREA_CCD;                   // 수주 권역 <-- 수주 권역
                    dlDummy.SALES_PRNT_ORG_CD__c        = outClass.SALES_PRNT_ORG_CD;                // 수주 거점 <-- 수주 거점
                    dlDummy.DLVRY_AREA_CCD__c           = outClass.DLVRY_AREA_CCD;                   // 매출 권역 <-- 매출 권역
                    dlDummy.DLVRY_PRNT_ORG_CD__c        = outClass.DLVRY_PRNT_ORG_CD;                // 매출 거점 <-- 매출 거점
                    dlDummy.RLBS_BIZ_TCD__c             = outClass.RLBS_BIZ_TCD;                     // 물류 서비스 범위 <-- 물류 서비스 범위
                    dlDummy.RLBS_SVC_TCD__c             = outClass.RLBS_SVC_TCD;                     // 물류 서비스 영역 <-- 물류 서비스 영역
                    dlDummy.BID_EST_DTM__c              = outClass.BID_EST_DTM;                      // 입찰 마감일 <-- 입찰 마감일
                    dlDummy.LBS_Exception_Type__c       = outClass.LBS_Exception_Type;               // 예외 :LBS 유형 확인 <-- 예외 LBS 유형 확인
                    dlDummy.RLBS_IND_TCD__c             = outClass.RLBS_IND_TCD;                     // 물류 업종 <-- 하위 업종 구분
                    dlDummy.USER_ID__c                  = outClass.USER_ID;                          // 소유자 (영업 대표) <-- 소유자 (영업 대표)의 EP ID
                    dlDummy.INS_PERSON_ID__c            = outClass.INS_PERSON_ID;                    // Created By ID <-- Created By ID의 EP ID
                    dlDummy.UPD_PERSON_ID__c            = outClass.UPD_PERSON_ID;                    // Last Modified By ID <-- Last Modified By ID의 EP ID
                    dlDummy.REUSE__c                    = outClass.REUSE;                            // 재활용필요성여부 (2021-01-28 추가)
                    dlDummy.REUSE_REASON__c             = outClass.REUSE_REASON;                     // 재활용필요성여부 사유 (2021-01-28 추가)
                    dlDummy.BO_RECORD_TYPE__c           = outClass.BO_RECORD_TYPE;                   // 사업유형 레코드 타입 (HQ:10, Logistic:20) (2021-02-08 추가)
                    dlDummy.ZZACONT__c                  = outClass.ZZACONT;                          // 계약대행 여부 (2021-02-19 추가)
                    dlDummy.ZZACONT_EX__c               = outClass.ZZACONT_EX;                       // 계약대행 예외처리 여부 (2021-02-19 추가)
                    dlDummy.BusinessType2__c            = outClass.BusinessType2;                    // 사업유형2 (2021-03-03 추가)
                    dlDummy.DealBreak__c                = outClass.DealBreak;                        // Deal Break (2021-03-03 추가, X(True) / ''(False))
                    dlDummy.Construction__c             = outClass.Construction;                     // 건설 여부 (2021-03-03 추가, X(True) / ''(False))
                    dlDummy.LegalReviewNo__c            = outClass.LegalReviewNo;                    // 법무 검토 번호 (2021-03-03 추가)
                    dlDummy.ORDER_AMT_KRW__c            = outClass.ORDER_AMT_KRW;                    // KRW로 환상된 예상금액 (2021-03-17 추가)
                    dlDummy.VRB_TYPE_MODI__c            = outClass.VRB_TYPE_MODI;                    //사업심의유형 변경여부
                    dlDummy.VRB_TYPE_MODI_ID__c         = outClass.VRB_TYPE_MODI_ID;                 //사업심의유형 변경자
                    dlDummy.BO_CONFIRM_YN__c            = outClass.BO_CONFIRM_YN;                    //BO점검 확정여부
                    dlDummy.Lost_Reason_CD__c           = outClass.Lost_Reason_CD;                   // 실주 사유코드
                    dlDummy.Lost_Reason_Desc__c         = outClass.Lost_Reason_Desc;                 // 실주 사유 Description
                    dlDummy.Drop_Reason_CD__c           = outClass.Drop_Reason_CD;                   // 중도종결 사유코드
                    dlDummy.Drop_Reason_Desc__c         = outClass.Drop_Reason_Desc;                 // 중도종결 사유 Description
    
                    dlDummyList.add(dlDummy);
                }
                //if(dlDummyList.size() > 0) insert dlDummyList;
                if(dlDummyList.size() > 0){
                    IF_Log  log = new IF_Log();
                    String guId  = IF_Util.generateGuid();
                    IF_Log.InterfaceLog infLog = new IF_Log.InterfaceLog( 'DATALAKE_Batch', guId, 'Batch_OpportunityForDataLake', 'execute', '', '');

                    Database.SaveResult[] srList = DataBase.insert( dlDummyList, false);
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

    global void finish(DataBase.BatchableContext BC){
        
    }
}