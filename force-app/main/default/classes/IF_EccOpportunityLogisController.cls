/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-03-12
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-01-26   ghkil@partner.samsung.com         Initial Version (Batch_EccOpportunityLogisController와 같은 기능을 하는 Callout)
 * 1.1   2021-01-28   ghkil@partner.samsung.com         REUSE, REUSE_REASON 항목 추가, ORGIN_ACCOUNT, CONTACT_ACCOUNT 항목 삭제
 * 1.2   2021-02-01   ghkil@partner.samsung.com         영업대표명(SALES_EMP_NAME), 고객오너(영업대표명)(AM_EMP_NAME)의 보여주는 항목명을 Employee__c의 EvHName__c로 변경
 * 1.3   2021-02-02   kilhwan.an@partner.samsung.com    영업대표명(SALES_EMP_NAME), 고객오너(영업대표명)(AM_EMP_NAME)의 보여주는 항목명에서 IF_USER인경우 IF_USER로 처리
 * 1.4   2021-02-08   ghkil@partner.samsung.com         인사부서코드(수주부서 인사코드, 매출부서 인사코드)를 가져올 때 수주/매출 코스트센터를 가지고 Department에서 가져옴 (CompanyCode__c 조건 제외)
 * 1.5   2021-02-08   ghkil@partner.samsung.com         BO_RECORD_TYPE(사업유형 레코드 타입) 항목 추가
 * 1.6   2021-02-09   kilhwan.an@partner.samsung.com    BO_CLASS2 => BO_LBS_CLASS
 * 1.7   2021-02-16   ghkil@partner.samsung.com         CONTACTTEXT 항목 제거
 * 1.8   2021-02-17   ghkil@partner.samsung.com         BusinessLevel__c을 FinalBusinessLevel__c로 변경
 * 1.9   2021-02-19   ghkil@partner.samsung.com         ZZACONT(계약대행 여부), ZZACONT_EX(계약대행 예외처리 여부) 항목 추가
 * 1.10  2021-02-23   kilhwan.an@partner.samsung.com    opportunity 안에 매출원가 로직 추가
 * 1.11  2021-02-24   ghkil@partner.samsung.com         BIZ_FROM_DT, BIZ_TO_DT, BO_RECORD_TYPE, COUNTRYTEXT, EXEC_PM_NO, INPUT_P, REUSE, REUSE_REASON, UDATE_STRSE, ZZACONT, ZZACONT_EX 항목 제외
 * 1.12  2021-03-05   kilhwan.an@partner.samsung.com    마이그데이터 수정시 전송 조건 추가 
 * 1.21  2021-03-10   ghkil@partner.samsung.com         Multi PickList인 RLBS_BIZ_TCD(RLBS 사업유형코드), RLBS_SVC_TCD(RLBS 서비스유형코드) 항목의 구분자를 ";"에서 ","로 변경
 * 1.41  2021-04-14   kilhwan.an@partner.samsung.com    CostCenter 기준으로 인사 부서코드 가져오기
 * 1.41  2021-04-14   kilhwan.an@partner.samsung.com    CONTACTTEXT 한수동 프로님의 요청으로 전송
 * 2.0	 2024-03-12	  sarthak.j1@samsung.com            Apply new Probability Field to Logistics -> MYSALES-470
**/
global class IF_EccOpportunityLogisController implements Queueable , DataBase.AllowsCallouts{

    private static final String INTERFACE_ID = 'IF-094';
    private static final String APEX_CLASS   = 'IF_EccOpportunityLogisController'; 
    private static final String METHOD_NAME  = 'calloutOpportunityLogisInfo';

    private static Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)
    
    private static final String PROPOSAL_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Submit Proposal');     // 견적/제안 제출(ZP61)
    private static final String REVIEW_OPP_ACTIVITY_CODE = IF_Util.OPPORTUNITY_ACTIVITY.get('Review BO');           // 사업기회 검토(ZP21)
    private static final String VRB_ACTIVITY_CODE        = IF_Util.OPPORTUNITY_ACTIVITY.get('Request Committee Approval');  // 수전위 품의(ZP62)  --> 1.8 정의서 내용
    private static final String LOST_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Lost Opportunity');    // 실주 보고(ZPZ1)
    private static final String ABORT_OPP_ACTIVITY_CODE  = IF_Util.OPPORTUNITY_ACTIVITY.get('Abort Opportunity');   // 사업 포기(XPX1)
    private static final String DROP_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Drop Opportunity');    // 사업 중도 종결(ZPZ2)
    private static final String HOLD_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Hold Opportunity');    // 사업 Hold(ZAC1)
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();
    private static String DEFAULT_EPID = 'D090304084954C600591';

    private static IF_Log ifLog;
    private static IF_Log.InterfaceLog interfaceLog;
    private static List<String> errorMsgList = new List<String>();

    private List<String> selectIdList;

    public IF_EccOpportunityLogisController( List<String> selectIdList) {    

        this.selectIdList = selectIdList;
    }

    public static String QUERY_STRING = 'Select Id ' +
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
        								'		, Probability_new__c ' +									// -->[Added Probability_new__c as per v-2.0]
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
                                        'From   Opportunity ' +                                        
                                        'Where  EPCompanyCode__c != null ' +
        								'AND    ( ( MigData__c = false ) OR ( MigData__c = true and IsEdited__c = true) ) ' + // 2021-02-02 / younghoon.kim / Migration Data는 SAP으로 전송하지않도록 조건 추가
                                        'AND    RecordType.DeveloperName = \'Logistics\' ';

    public void execute(QueueableContext context) {

        calloutOpportunityLogisInfo2 ( this.selectIdList);
    }

    @Future(callout=true)
    public static void calloutOpportunityLogisInfo(List<String> selectIdList){        
        calloutOpportunityLogisInfo2( selectIdList);
    }

    public static void calloutOpportunityLogisInfo2(List<String> selectIdList){        

        Map<String, Object> result = new Map<String, Object>();

        String reqMsg = '';
        String resMsg = '';

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // *************************************
        // Opportunity Logistics 기본정보 조회
        // *************************************
        String queryString = QUERY_STRING + ' And    Id IN :selectIdList ';

        Organization org = [ SELECT Id, isSandBox FROM Organization];
        if( org.IsSandbox && org.Id != '00D1s0000008pnsEAA'){       // Dev Id 제외 (00D1s0000008pnsEAA)
            // 10, 50, 100, 200, 300, 400, 500
            //queryString = queryString + ' AND CreatedById = \'0051s000000zvP1AAI\' ' ;
            queryString += ' ORDER BY Systemmodstamp DESC LIMIT 10 ';
        }            
        queryString = queryString + 'ALL ROWS ';
        System.debug( 'queryString::::' + queryString);

        List<Opportunity> scopeList = Database.query(queryString);
        
        if (DEBUG_FLAG) ifLog.addLog('scopeList.size() : ' + scopeList.size());
        system.debug('처리 대상 : ' + scopeList.size());
                
        // *************************************
        // Opportunity Logistics 상세정보 정보 가져오기
        // *************************************
        OutputHeader outHeader = getOpportunityLogisDetailInfo(scopeList);

        MigOppCode__c errorOppty = new MigOppCode__c();

        // *************************************
        // Interface 통신
        // *************************************        
        try {            
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            // OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            // ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                // ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            } else {
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);

                if(scopeList.size()> 0){
                    errorOppty.Name = scopeList[0].Id;
                    errorOppty.OpportunityCode__c = scopeList[0].OpportunityCode__c;
                    errorOppty.Send_Check__c = false;
                    errorOppty.InterfaceId__c = 'IF-094ERROR';
                }
            }
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);

            if(scopeList.size()> 0){
                errorOppty.Name = scopeList[0].Id;
                errorOppty.OpportunityCode__c = scopeList[0].OpportunityCode__c;
                errorOppty.Send_Check__c = false;
                errorOppty.InterfaceId__c = 'IF-094ERROR';
            }
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);

            if(errorOppty.InterfaceId__c == 'IF-094ERROR') insert errorOppty;
        }

        // return result;
    }

    public static OutputHeader getOpportunityLogisDetailInfo(List<Opportunity> scopeList) {

        // *************************************
        // Opportunity 상세정보 정보 가져오기
        // *************************************
        // Opportunity 데이터 적재
        Map<String, Opportunity> OpportunityMap = new Map<String, Opportunity>();
        // Set<String> costCenterExternalIdSet = new Set<String>();
        Set<String> costCenterCodeSet = new Set<String>();
        Set<String> companyCodeSet = new Set<String>();
        Set<String> employeeNumberSet = new Set<String>();
        Set<Date> closeDateSet = new Set<Date>();
        for (Opportunity oppData : scopeList) {
            OpportunityMap.Put(oppData.Id, oppData);                                // Opportunity 데이터 
            // costCenterExternalIdSet.add(oppData.SalesDepartment__r.CostCenter__c + '99991231' + oppData.CompanyCode__c);            // Department정보 가져올 costCenterExternalIdSet 적재 (수주 사업그룹)
            // costCenterExternalIdSet.add(oppData.cPrimarySalesDepartment__r.CostCenter__c + '99991231' + oppData.CompanyCode__c);    // Department정보 가져올 costCenterExternalIdSet 적재 (주 매출부서)
            costCenterCodeSet.add(oppData.SalesDepartment__r.CostCenter__c);        // Department정보 가져올 costCenterExternalIdSet 적재 (수주 사업그룹)
            costCenterCodeSet.add(oppData.cPrimarySalesDepartment__r.CostCenter__c);// Department정보 가져올 costCenterExternalIdSet 적재 (주 매출부서)            
            companyCodeSet.add(oppData.CompanyCode__c);                             // Company정보 가져올 companyCodeSet 적재
            employeeNumberSet.add(oppData.Owner.EmployeeNumber);                    // Employee정보 가져올 employeeNumberSet 적재 (소유주(영업대표))
            employeeNumberSet.add(oppData.Account.Owner.EmployeeNumber);            // Employee정보 가져올 employeeNumberSet 적재 (고객오너(영업대표))
            closeDateSet.add(oppData.CloseDate);                                    // 환율정보 조회를 위한 CloseDate Set 적재
        }

        System.debug(':::111::::::::::');

        // 부서 정보 가져오기
//        List<Department__c> deptList = [
//            Select  Id
//                    , Kostl__c
//                    , Abtel__c
//            From    Department__c
//            Where  Kostl__c IN :costCenterCodeSet
//        ];
//        Map<String, Department__c> deptMap = new Map<String, Department__c>();
//        for(Department__c dept : deptList){
//            deptMap.put(dept.Kostl__c, dept);
//        }

        List<CostCenter__c> costList = [
            SELECT Id
                  ,CostCenter__c
                  ,L_ORGEH__c
            FROM   CostCenter__c
            WHERE  CostCenter__c IN :costCenterCodeSet
        ];

        Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
        for( CostCenter__c ct : costList){

            costMap.put( ct.CostCenter__c, ct);
        }

        // 각 Activity별 날짜정보 가져오기
        List<Opportunity_Activity__c> oppActivityList = [
            Select  Id, 
                    TransactionName__c,                             // Opportunity Activity Code
                    tolabel(TransactionName__c) TransactionName,    // Opportunity Activity Name
                    Status__c,                                      
                    DueDate__c,                                     // 완료 예정일자 (RFP 계획일자)
                    StartDate__c,                                   // 시작일자
                    EndDate__c,                                     // 종료일자
                    WhatId__c                                       // Opportunity Id
            From    Opportunity_Activity__c 
            Where   TransactionName__c in (:PROPOSAL_ACTIVITY_CODE, :REVIEW_OPP_ACTIVITY_CODE, :VRB_ACTIVITY_CODE, :LOST_OPP_ACTIVITY_CODE, :ABORT_OPP_ACTIVITY_CODE, :DROP_OPP_ACTIVITY_CODE, :HOLD_OPP_ACTIVITY_CODE)
            And     WhatId__c In :OpportunityMap.KeySet()
        ];
        // system.debug('oppActivityList.size() : ' + oppActivityList.size());
        Map<String, Opportunity_Activity__c> oppActivityMap = new Map<String, Opportunity_Activity__c>();
        for (Opportunity_Activity__c oppActivityData : oppActivityList) {
            oppActivityMap.put(oppActivityData.WhatId__c + oppActivityData.TransactionName__c, oppActivityData);
        }

        System.debug(':::2222::::::::::');

        // Company 정보 가져오기
        List<Company__c> companyList = [
            Select  Id, 
                    CompanyCode__c,
                    Name,
                    Country__c,
                    CurrencyIsoCode,
                    EPCompanyCode__c,
                    Headquarter__c,
                    CompanyFullName__c
            From    Company__c
            Where   CompanyCode__c IN :companyCodeSet
        ];
        Map<String, Company__c> companyMap = new Map<String, Company__c>();
        for (Company__c companyData : companyList) {
            companyMap.put(companyData.CompanyCode__c, companyData);
        }

        // Employee__c 정보 가져오기 (이름)
        List<Employee__c> employeeList = [
            Select  Id
                    , EvHName__c
                    , EvEmpNO__c
            From    Employee__c
            Where   EvEmpNO__c IN :employeeNumberSet
        ];
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
        for (Employee__c employeeData : employeeList) {
            employeeMap.put(employeeData.EvEmpNO__c, employeeData);
        }

        System.debug(':::3333::::::::::');

        // 매출 원가 처리 로직 : 2021-02-23
        // RevenueScheduleOpportunity__c 조회
        List<RevenueScheduleOpportunity__c> revenueScheduleOpportunityList = [
            Select  Id
                    , Name
                    , CurrencyIsoCode
                    , Parent__c
                    , Parent__r.OpportunityCode__c
                    , Description__c
                    , Revenue__c
                    , ScheduleDate__c 
            From    RevenueScheduleOpportunity__c
            Where   Parent__c IN :OpportunityMap.KeySet()
        ];

        System.debug( 'Parent__c::::' + OpportunityMap);
        System.debug( 'revenueScheduleOpportunityList::::' + revenueScheduleOpportunityList);

        Map<String, List<OutputClass2>> revMap = new Map<String, List<OutputClass2>>();
        for (RevenueScheduleOpportunity__c revenueData : revenueScheduleOpportunityList) {

            OutputClass2 outClass2 = new OutputClass2();
            outClass2.Parent            = revenueData.Parent__c;                                                            // Opportunity ID
            outClass2.Name              = revenueData.Name;                                                                 // No.
            outClass2.CurrencyIsoCode   = revenueData.CurrencyIsoCode;                                                      // Currency Code
            outClass2.Revenue           = revenueData.Revenue__c.setScale(2, System.RoundingMode.HALF_UP).toPlainString();  // 매출액(분할금액)
            outClass2.ScheduleDate      = Util_String.convertDateString(revenueData.ScheduleDate__c);                       // 매출일(분할일자)
            outClass2.ORDER_ID          = revenueData.Parent__r.OpportunityCode__c;                                         // BO 코드

            System.debug( 'data.OPPORTUNITY_ID::::' + outClass2.Parent);

            List<OutputClass2>   outList = revMap.get( outClass2.Parent);
            if( outList == null) {
                outList = new List<OutputClass2>();
            }
            outList.add( outClass2);

            revMap.put( outClass2.Parent, outList);
        }

        // 환율정보(DatedConversionRate) 조회
        Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
        Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
        Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

        // system.debug('환율정보 : ' + conversionRateMap );
        // Request Data 만들기
        Map<String, Object> outputHeaderMap = new Map<String, Object>();
        List<Map<String, Object>> outputDataList = new List<Map<String, Object>>();
        List<OutputClass> dataList = new List<OutputClass>();

        String flagTrue = '10';
        String flagFalse = '20';
        String flagSapTrue = 'X';
        String flagSapFalse = '_';

        System.debug( 'scopeList:::' + scopeList);

        for (Opportunity oppData : scopeList) {

            OutputClass data = new OutputClass();
            Map<String, Object> outputDataMap = new Map<String, Object>();

            data.OPPORTUNITY_ID             = oppData.Id;
            data.ORDER_ID                   = oppData.OpportunityCode__c;
            data.ORDER_NAME                 = oppData.Name;
            data.SALES_PHASE                = oppData.StageName;
            data.ZZSTATUS                   = oppData.ActivityStatus__c;      // Current BO Activity Status
            data.ORDER_TYPE                 = oppData.Type;
            String salesDeptCode = null;
//            if (deptMap.get(oppData.SalesDepartment__r.CostCenter__c) != null) {
//                salesDeptCode = String.valueOf(deptMap.get(oppData.SalesDepartment__r.CostCenter__c).Abtel__c);
//            }

            if (costMap.get(oppData.SalesDepartment__r.CostCenter__c) != null) {
                salesDeptCode = String.valueOf(costMap.get(oppData.SalesDepartment__r.CostCenter__c).L_ORGEH__c);
            }
            data.SALES_DEPT_CODE            = salesDeptCode;
            String developDeptCode = null;
//            if (deptMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c) != null) {
//                developDeptCode = String.valueOf(deptMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c).Abtel__c);
//            }

            if (costMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c) != null) {
                developDeptCode = String.valueOf(costMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c).L_ORGEH__c);
            }
            data.DEVELOP_DEPT_CODE          = developDeptCode;
            data.COMPANY_ID                 = oppData.Account.AccountNumber;
            data.ORIGINAL_COMPANY_ID        = oppData.cOriginAcc__r.AccountNumber;
            data.SALES_EMP_NO               = oppData.Owner.EmployeeNumber;                                     // 소유주(영업대표)
            String salesEmpName = null;     // (2021-02-01 Employee__c의 EvHName__c로 변경)
            if( oppData.Owner.Name == 'IF_USER'){
                salesEmpName = oppData.Owner.Name;
            }else if (employeeMap.get(oppData.Owner.EmployeeNumber) != null) {
                salesEmpName = employeeMap.get(oppData.Owner.EmployeeNumber).EvHName__c;
            }
            //2021-05-11
            //소유주명 20자리 자르기
            if(salesEmpName != null && salesEmpName.length() > 50){
                salesEmpName = salesEmpName.substring(0,50);
            }
            data.SALES_EMP_NAME             = salesEmpName;                                                     // 소유주(영업대표)명           
            data.PROPOSAL_EMP_NO            = oppData.ProposalPM__r.EvSapEmpNO__c;                              // 제안PM
            data.PROPOSAL_EMP_NAME          = oppData.ProposalPM__r.EvHName__c;                                 // 제안PM명
            data.IN_OUT_TYPE                = oppData.GroupInternal__c == true ? flagTrue : flagFalse;          // 그룹 내 사업 여부 (10 : 그룹내 / 20 : 그룹외) 
            data.DOM_ABR_TYPE               = oppData.KoreaDomestic__c == true ? flagTrue : flagFalse;          // 국내/해외 여부 (10 : 국내 / 20 : 해외)
            Decimal orderAmt = 0;
            if (oppData.Amount != null) {
                orderAmt = oppData.Amount;
            }
            data.ORDER_AMT                  = orderAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();// 예상금액
            data.CURRENCY_CODE              = oppData.CurrencyIsoCode;                                          // 사업 기회 금액의 통화
            data.DU_ORDER_DATE              = Util_String.convertDateString(oppData.CloseDate);                 // 예상수주일자
            data.CONTRACT_TERM_FROM         = Util_String.convertDateString(oppData.cRevenueStartDate__c);      // (계약)매출 시작일
            data.CONTRACT_TERM_TO           = Util_String.convertDateString(oppData.cRevenueEndDate__c);        // (계약)매출 종료일
            String CompanyEPCompanyCode = null;
            String CompanyCurrencyIsoCode = null;
            if (companyMap.get(oppData.CompanyCode__c) != null) {
                CompanyEPCompanyCode   = companyMap.get(oppData.CompanyCode__c).EPCompanyCode__c;
                CompanyCurrencyIsoCode = companyMap.get(oppData.CompanyCode__c).CurrencyIsoCode;
            }
            data.COMPANY                    = CompanyEPCompanyCode;                                             // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
            data.SAP_COMPANY                = oppData.CompanyCode__c;                                           // Company Code
            data.LOCAL_CURRENCY_CODE        = CompanyCurrencyIsoCode;                                           // 로컬 통화 (Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode)
            data.FLAG                       = oppData.IsDeleted == true ? 'D' : 'I';                            // 삭제 여부 (삭제된거면 D, 아니면 I)
            data.REG_DATE                   = Util_String.convertDateString( oppData.CreatedDate, 'Asia/Seoul'); // Opportunity 등록일
            data.REG_EMP_NO                 = oppData.CreatedBy.EmployeeNumber;                                 // Opportunity 등록자 사번
            data.UPDATE_DATE                = Util_String.convertDateString( oppData.LastModifiedDate, 'Asia/Seoul'); // Opportunity 등록일
            data.UPDATE_EMP_NO              = oppData.LastModifiedBy.EmployeeNumber;                            // Opportunity 수정자 사번
            data.BIZ_TYPE                   = oppData.BusinessType__c;                                          // 사업유형
            data.BIZ_TYPE_NM                = String.valueOf(oppData.get('BusinessTypeLabel'));                 // 사업유형명
            // data.COUNTRYTEXT                = 'SFDC 해당사항 없음';                                           // SFDC 해당사항 없음
            data.ORGIN_ACCOUNT_DESC         = oppData.cOriginAcc__r.Name;                                       // 원청사 고객명
            // data.ORGIN_ACCOUNT              = oppData.cOriginAcc__r.AccountNumber;                              // 원청사 고객번호 (2021-01-28 삭제)
            if( oppData.Account != null){
                data.CONTACTTEXT            = oppData.Account.Name;                                             // 고객사명 (2021-02-16 삭제)
            }else {
                data.CONTACTTEXT            = '';                                                   // 고객사명 (2021-02-16 삭제)
            }
            // data.CONTACT_ACCOUNT            = oppData.Account.AccountNumber;                                    // 고객사 고객번호 (2021-01-28 삭제)
            data.PROBABILITY                = String.valueOf(oppData.Probability_new__c);                              // 확도 //--> Changed 'Probability' to 'Probability_new__c' as part of v-2.0
            String zzslesstrYn = '';
            // if (oppActivityMap.get(oppData.Id + 'ZP61') != null) {
            //     zzslesstrYn = 'X';
            // }
            data.ZZSALESSTR                 = zzslesstrYn;                                                      // 수주전략세션 수행 여부 (Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리)
            data.BO_OVERVIEW                = oppData.Description;                                              // 사업기획 개요
            String zzCooper = 'N';
            //&& oppData.IsOriginal__c
            if (oppData.Collaboration__c ) {
                zzCooper = 'Y';
            }
            data.ZZCOOPER                   = zzCooper;                                                         // 법인 협업 여부
            // data.BO_STATUS                  = oppData.get( 'OpportunityStatusLabel') + '';                      // Opportunity Status 명
            data.BO_STATUS                  = oppData.OpportunityStatus__c;                                   // Opportunity Status
            // 계약 수주액(로컬 통화) 계산 개선 (2021-03-18)
            Decimal calculationResult = 0;
            if (conversionRateMap.get(oppData.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                if (oppData.CurrencyIsoCode == CompanyCurrencyIsoCode) {
                    calculationResult = oppData.Amount == null ? 0 : oppData.Amount;
                } else {

                    String fromIsoCode = oppData.CurrencyIsoCode;
                    String toIsocode = CompanyCurrencyIsoCode;
                    Date startDate = quarterDateMap.get(oppData.CloseDate);
                    Decimal fromUsdRate = 0;
                    Decimal toUsdRate = 0;

                    if (conversionPastRateMap.get(fromIsoCode + startDate) != null) {
                        fromUsdRate = conversionPastRateMap.get(fromIsoCode + startDate).ConversionRate;
                    } else {
                        fromUsdRate = conversionRateMap.get(fromIsoCode).ConversionRate;
                    }

                    if (conversionPastRateMap.get(toIsoCode + startDate) != null) {
                        toUsdRate = conversionPastRateMap.get(toIsoCode + startDate).ConversionRate;
                    } else {
                        toUsdRate = conversionRateMap.get(toIsoCode).ConversionRate;
                    }

                    if( Util_String.nvlDec( oppData.Amount) > 0){
                        calculationResult = IF_Util.calculationCurrency(fromIsoCode
                                                                        , oppData.Amount
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate  );
                    }
                    // calculationResult = IF_Util.calculationCurrency(    oppData.CurrencyIsoCode
                    //                                                     , oppData.Amount
                    //                                                     , CompanyCurrencyIsoCode
                    //                                                     , conversionRateMap.get(oppData.CurrencyIsoCode).ConversionRate
                    //                                                     , conversionRateMap.get(CompanyCurrencyIsoCode).ConversionRate  );
                }
            }
            if (calculationResult == null) {
                calculationResult = 0;
            }
            data.LOCAL_ORDER_AMT            = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();   // 계약 수주액(로컬 통화) (Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산)                
            data.SALES_DEPT_COST_CENTER     = oppData.SalesDepartment__r.CostCenter__c;                         // 수주 사업그룹
            data.DEVELOP_DEPT_COST_CENTER   = oppData.cPrimarySalesDepartment__r.CostCenter__c;                 // 주 매출 부서
            data.BO_CLASS                   = oppData.FinalBusinessLevel__c;                                    // 사업 등급
            data.BID_METHOD                 = oppData.BiddingMethod__c;                                         // 입찰 방식
            data.AM_EMP_NO                  = oppData.Account.Owner.EmployeeNumber;                             // 고객오너(영업대표)    
            String amEmpName = null;     // (2021-02-01 Employee__c의 EvHName__c로 변경)
            if( oppData.Account.Owner.Name == 'IF_USER'){

                amEmpName = oppData.Account.Owner.Name;
            }else if (employeeMap.get(oppData.Account.Owner.EmployeeNumber) != null) {
                amEmpName = employeeMap.get(oppData.Account.Owner.EmployeeNumber).EvHName__c;
            }

            //2021-05-11
            //고객오너명 20 자리까지 자르기
            if(amEmpName != null && amEmpName.length() > 20) {
                amEmpName = amEmpName.substring(0, 20);
            } 
            data.AM_EMP_NAME                = amEmpName;                                                        // 고객오너(영업대표)명            
            data.COMPANY_ACCOUNT_DESC       = oppData.Account.Name;                                             // 고객명
            // TECH_PROP값은 Submit Proposal(ZP61, 견적/제안 제출)의 Opportunity_Activity__c의 Status 가 "Completed"이면 "Y", 아니면 "N"으로 처리
            String techProp = 'N';
            if (oppActivityMap.get(oppData.Id + PROPOSAL_ACTIVITY_CODE) != null) {
                techProp = oppActivityMap.get(oppData.Id + PROPOSAL_ACTIVITY_CODE).Status__c == 'Completed' ? 'Y' : 'N';  
            }
            data.TECH_PROP = techProp;                                                                          // 제안서 여부
            data.ZZVRB_FQ_T = oppData.VRBMethod__c;                                                             // VRB 유형
            // UDATE_ZP21값은 Review BO(ZP21, 사업기회 검토)의 Opportunity_Activity__c의 EndDate__c
            String updatZp21 = null;
            if (oppActivityMap.get(oppData.Id + REVIEW_OPP_ACTIVITY_CODE) != null) {
                updatZp21 = Util_String.convertDateString(oppActivityMap.get(oppData.Id + REVIEW_OPP_ACTIVITY_CODE).EndDate__c);
            }
            data.UDATE_ZP21 = updatZp21;                                                                        // BO Activity 사업기회검토 시 종료일자
            // UDATE_VRB값은 BO Approval Result(ZP21, 사업심의 결과 입력)의 Opportunity_Activity__c의 EndDate__c
            String updateVrb = null;
            if (oppActivityMap.get(oppData.Id + VRB_ACTIVITY_CODE) != null) {
                updateVrb = Util_String.convertDateString(oppActivityMap.get(oppData.Id + VRB_ACTIVITY_CODE).EndDate__c);
            }
            data.UDATE_VRB = updateVrb;                                                                         // BO Activity VRB/수전세 시 종료일자, 사업심의 결과 입력
            // data.UDATE_STRSE = 'SFDC 해당사항 없음';  // Strategy_Session_End_Date  <-- SFDC 해당사항 없음
            String updateLose = null;
            if (oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE) != null) {
                updateLose = Util_String.convertDateString(oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE).DueDate__c);
            }
            data.UDATE_LOSE = updateLose;
            String updateDrop = null;
            if (oppActivityMap.get(oppData.Id + ABORT_OPP_ACTIVITY_CODE) != null) {
                updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + ABORT_OPP_ACTIVITY_CODE).EndDate__c); // Abort Opportunity
            }                   
            if (oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE) != null) {   
                updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE).EndDate__c);  // Drop Opportunity
            }
            if (oppActivityMap.get(oppData.Id + HOLD_OPP_ACTIVITY_CODE) != null) {  
                updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + HOLD_OPP_ACTIVITY_CODE).EndDate__c);  // Hold Opportunity
            }
            data.UDATE_DROP                 = updateDrop;
            // data.EXEC_PM_NO                 = oppData.ProposalPM__r.EvSapEmpNO__c;                                               // 실행PM 사번 <- 제안 PM (2020-12-28 추가), (2021-02-24 제외)
            // data.INPUT_P                    = oppData.ResourcePreInput__c == true ? flagSapTrue : flagSapFalse;                  // 선투입 <- 선투입 여부 (X(True) / _(False)) (2020-12-28 추가), (2021-02-24 제외)
            // data.BIZ_FROM_DT                = Util_String.convertDateString(oppData.cRevenueStartDate__c);                       // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가), (2021-02-24 제외)
            // data.BIZ_TO_DT                  = Util_String.convertDateString(oppData.cRevenueEndDate__c);                         // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가), (2021-02-24 제외)
            data.SALES_COST_CD              = oppData.BizTeamAttributes01__c;
            data.CGUBUN_ID                  = oppData.BizTeamAttributes02__c;
            data.BO_LBS_CLASS               = oppData.BizTeamAttributes03__c;
            data.KEY_ACCOUNT_YN             = oppData.BizTeamAttributes04__c;
            // Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"으로 처리
            String bigAccountYn = 'N';
            Decimal bigAccountLimit = 3000000000.00;
            if (oppData.CurrencyIsoCode == 'KRW') {
                if (oppData.Amount >= bigAccountLimit) {
                    bigAccountYn = 'Y';
                }   
            } else {
                // 원화로 환율 변환하여 비교(계산 개선 (2021-03-18))
                String fromIsoCode2 = oppData.CurrencyIsoCode;
                String toIsocode2 = 'KRW';
                Date startDate2 = quarterDateMap.get(oppData.CloseDate);
                Decimal fromUsdRate2 = 0;
                Decimal toUsdRate2 = 0;

                if (conversionPastRateMap.get(fromIsoCode2 + startDate2) != null) {
                    fromUsdRate2 = conversionPastRateMap.get(fromIsoCode2 + startDate2).ConversionRate;
                } else {
                    fromUsdRate2 = conversionRateMap.get(fromIsoCode2).ConversionRate;
                }

                if (conversionPastRateMap.get(toIsoCode2 + startDate2) != null) {
                    toUsdRate2 = conversionPastRateMap.get(toIsoCode2 + startDate2).ConversionRate;
                } else {
                    toUsdRate2 = conversionRateMap.get(toIsoCode2).ConversionRate;
                }

                Decimal convertAmount;
                if( Util_String.nvlDec( oppData.Amount) > 0){
                    convertAmount = IF_Util.calculationCurrency(fromIsoCode2
                                                                , oppData.Amount
                                                                , toIsoCode2
                                                                , fromUsdRate2
                                                                , toUsdRate2 );
                }
                // convertAmount = IF_Util.calculationCurrency(    oppData.CurrencyIsoCode
                //                                                 , oppData.Amount
                //                                                 , 'KRW'
                //                                                 , conversionRateMap.get(oppData.CurrencyIsoCode).ConversionRate
                //                                                 , conversionRateMap.get('KRW').ConversionRate   );

                if (convertAmount >= bigAccountLimit) {
                    bigAccountYn = 'Y';
                }
            }
            data.BIG_ACCOUNT_YN             = bigAccountYn;                                                                     // 빅어카운트여부 (Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N")
            data.CELLO_URL                  = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/' + oppData.Id + '/view';  // Opportunity 링크URL (URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view)
            data.AccountNumber              = oppData.Account.AccountNumber;                                                    // Contract Account (MDG 고객코드)
            data.SHPR_CCD                   = oppData.LogisticsCustomerType__c;                                                 // 물류 고객 구분
            data.RLBS_PJT_TCD               = oppData.LogisticsBizDevelopmentType__c;                                           // 사업 개발 유형
            data.SALES_AREA_CCD             = oppData.SalesOrganization__r.Region__c;                                           // 수주 권역 코드
            data.SALES_PRNT_ORG_CD          = oppData.SalesOrganization__r.Code__c;                                             // 수주 거점 코드
            // data.SALES_AREA_CCD             = oppData.SalesRegion__c;                                                        // 수주 권역
            // data.SALES_PRNT_ORG_CD          = oppData.SalesOrganization__c;                                                  // 수주 거점
            data.DLVRY_AREA_CCD             = oppData.DeliveryOrganization__r.Region__c;                                        // 매출 권역 코드
            data.DLVRY_PRNT_ORG_CD          = oppData.DeliveryOrganization__r.Code__c;                                          // 매출 거점 코드
            // data.DLVRY_AREA_CCD             = oppData.DeliveryRegion__c;                                                     // 매출 권역
            // data.DLVRY_PRNT_ORG_CD          = oppData.DeliveryOrganization__c;                                               // 매출 거점
            if (oppData.LogisticsBizType__c != null) {
                data.RLBS_BIZ_TCD               = oppData.LogisticsBizType__c.replaceAll(';', ',');                             // 물류 서비스 범위 (Mulit PickList 구분자 ";"을 ","로 변경)
            } else {
                data.RLBS_BIZ_TCD               = oppData.LogisticsBizType__c;                                                  // 물류 서비스 범위 (값 없을때 그대로 처리)
            }
            if (oppData.LogisticsServiceType__c != null) {
                data.RLBS_SVC_TCD               = oppData.LogisticsServiceType__c.replaceAll(';', ',');                         // 물류 서비스 영역 (Mulit PickList 구분자 ";"을 ","로 변경)
            } else {
                data.RLBS_SVC_TCD               = oppData.LogisticsServiceType__c;                                              // 물류 서비스 영역 (값 없을때 그대로 처리)
            }
            data.BID_EST_DTM                = Util_String.convertDateString(oppData.BiddingDeadline__c);                        // 입찰 마감일
            data.LBS_Exception_Type         = oppData.LBSExceptionType__c;                                                      // 예외 LBS 유형 확인
            data.RLBS_IND_TCD               = oppData.SubIndusrty__c;                                                           // 하위 업종 구분
            data.USER_ID                    = oppData.Owner.FederationIdentifier;                                               // 소유자 (영업 대표)의 EP ID
            data.INS_PERSON_ID              = Util_String.nvlStr( oppData.CreatedBy.FederationIdentifier, DEFAULT_EPID);        // Created By ID의 EP ID
            data.UPD_PERSON_ID              = Util_String.nvlStr( oppData.LastModifiedBy.FederationIdentifier, DEFAULT_EPID);   // Last Modified By ID의 EP ID
            data.COMPETITORS                = oppData.Competitors__c;                                                           //경쟁사명
            data.LOST_REASON                = oppData.LostReasonLogistics__c;                                                   //AR 실주 사유
            // data.REUSE                      = oppData.Reuse__c == true ? 'Y' : 'N';                                          // 재활용 필요성 여부 (2021-01-28 추가), (2021-02-24 제외)
            // data.REUSE_REASON               = oppData.ReuseReason__c;                                                        // 재활용 필요성 여부 사유 (2021-01-28 추가), (2021-02-24 제외)
            // 사업유형 레코드 타입 (HQ:10, Logistic:20) (2021-02-08 추가), (2021-02-24 제외)
            // if( oppData.RecordType.DeveloperName  == 'HQ'){
            //     data.BO_RECORD_TYPE = '10';
            // }else{
            //     data.BO_RECORD_TYPE = '20';
            // }
            // data.ZZACONT                    = oppData.AgencyContract__c == true ? 'X' : '';                                     // 계약대행 여부 (2021-02-19 추가), (2021-02-24 제외)
            // data.ZZACONT_EX                 = oppData.AgencyContractException__c == true ? 'X' : '';                            // 계약대행 예외처리 여부 (2021-02-19 추가), (2021-02-24 제외)
            
            // 2021-02-23 json 구조 변경
            data.REVENUE_SCHEDULE_OPPORTUNITY = new List<OutputClass2>();
            System.debug('data.OPPORTUNITY_ID::::' + data.OPPORTUNITY_ID);
            List<OutputClass2> out2List = revMap.get( data.OPPORTUNITY_ID);
            if( out2List != null) {
                data.REVENUE_SCHEDULE_OPPORTUNITY.addAll( out2List);
            }
            
            dataList.add(data);
        }

        OutputHeader outHeader = new OutputHeader();
        outHeader.OPPORTUNITY  = dataList;
        /*
        // Output Data 적재
        outHeader.OPPORTUNITY = dataList;

        // RevenueScheduleOpportunity__c 조회
        List<RevenueScheduleOpportunity__c> revenueScheduleOpportunityList = [
            Select  Id
                    , Name
                    , CurrencyIsoCode
                    , Parent__c
                    , Parent__r.OpportunityCode__c
                    , Description__c
                    , Revenue__c
                    , ScheduleDate__c 
            From    RevenueScheduleOpportunity__c
            Where   Parent__c IN :OpportunityMap.KeySet()
            ORDER BY Parent__c
        ];

        List<OutputClass2> dataList2 = new List<OutputClass2>();
        for (RevenueScheduleOpportunity__c revenueData : revenueScheduleOpportunityList) {
            OutputClass2 outClass2 = new OutputClass2();

            outClass2.Parent            = revenueData.Parent__c;                                                            // Opportunity ID
            outClass2.Name              = revenueData.Name;                                                                 // No.
            outClass2.CurrencyIsoCode   = revenueData.CurrencyIsoCode;                                                      // Currency Code
            outClass2.Revenue           = revenueData.Revenue__c.setScale(2, System.RoundingMode.HALF_UP).toPlainString();  // 매출액(분할금액)
            outClass2.ScheduleDate      = Util_String.convertDateString(revenueData.ScheduleDate__c);                       // 매출일(분할일자)
            outClass2.ORDER_ID          = revenueData.Parent__r.OpportunityCode__c;                                         // BO 코드

            dataList2.add(outClass2);
        }
        outHeader.REVENUE_SCHEDULE_OPPORTUNITY = dataList2;
        */

        return outHeader;
    }

    public class OutputHeader{

        @AuraEnabled
        public List<OutputClass> OPPORTUNITY;
    }

    public class OutputClass{
        
        @AuraEnabled
        public String OPPORTUNITY_ID;                   // Opportunity ID
        @AuraEnabled
        public String ORDER_ID;                         // 사업기회 ID <-- 사업 기회 Code
        @AuraEnabled
        public String ORDER_NAME;                       // BO 명 <-- 사업기획명
        @AuraEnabled
        public String SALES_PHASE;                      // BOM 단계 <-- 단계
        @AuraEnabled
        public String ZZSTATUS;                         // BO Activity Status
        @AuraEnabled
        public String ORDER_TYPE;                       // 사업유형 <-- 사업기회 유형
        @AuraEnabled
        public String SALES_DEPT_CODE;                  // 수주부서 인사코드 <-- 수주 사업그룹 인사코드
        @AuraEnabled
        public String DEVELOP_DEPT_CODE;                // 매출부서 인사코드 <-- 주 매출 부서 인사코드
        @AuraEnabled
        public String COMPANY_ID;                       // 고객사 코드 <-- Contract Account
        @AuraEnabled
        public String ORIGINAL_COMPANY_ID;              // 원청사 코드 <-- 원청사 고객
        @AuraEnabled
        public String SALES_EMP_NO;                     // 영업대표사번 <-- 소유자 (영업 대표)
        @AuraEnabled
        public String SALES_EMP_NAME;                   // 영업대표명 <-- 소유자 (영업 대표)
        @AuraEnabled
        public String PROPOSAL_EMP_NO;                  // 제안PM사번 <-- 제안 PM
        @AuraEnabled
        public String PROPOSAL_EMP_NAME;                // 제안PM명 <-- 제안 PM
        @AuraEnabled
        public String IN_OUT_TYPE;                      // 그룹내/그룹외 <-- 그룹 내 사업 여부
        @AuraEnabled
        public String DOM_ABR_TYPE;                     // 국내/해외 <-- 국내/해외 여부
        @AuraEnabled
        public String ORDER_AMT;                        // 계약 수주액 <-- 예상금액
        @AuraEnabled
        public String CURRENCY_CODE;                    // 계약 통화 <-- 사업 기회 금액의 통화
        @AuraEnabled
        public String DU_ORDER_DATE;                    // 예상수주일자 <-- 예상수주일자
        @AuraEnabled
        public String CONTRACT_TERM_FROM;               // 계약기간 시작일 <-- (계약)매출 시작일
        @AuraEnabled
        public String CONTRACT_TERM_TO;                 // 계약기간 종료일 <-- (계약)매출 종료일
        @AuraEnabled
        public String COMPANY;                          // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
        @AuraEnabled
        public String SAP_COMPANY;                      // 회사코드 <-- Company Code
        @AuraEnabled
        public String LOCAL_CURRENCY_CODE;              // 로컬 통화 <-- Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode
        @AuraEnabled
        public String FLAG;                             // 삭제여부 <-- 삭제 여부
        @AuraEnabled
        public String REG_DATE;                         // BO 등록일 <-- Opportunity 등록일
        @AuraEnabled
        public String REG_EMP_NO;                       // BO 등록자 사번 <-- Opportunity 등록자 사번
        @AuraEnabled
        public String UPDATE_DATE;                      // BO 최종 수정일 <-- Opportunity 수정일
        @AuraEnabled
        public String UPDATE_EMP_NO;                    // BO 최종 수정자 사번 <-- Opportunity 수정자 사번
        @AuraEnabled
        public String BIZ_TYPE;                         // 사업 유형 <-- 사업 유형
        @AuraEnabled
        public String BIZ_TYPE_NM;                      // 사업 유형명 <-- 사업 유형명
        // @AuraEnabled
        // public String COUNTRYTEXT;                      // Country text <-- SFDC 해당사항 없음, (2021-02-24 제외)
        @AuraEnabled
        public String ORGIN_ACCOUNT_DESC;               // 원청사 고객명
        // @AuraEnabled
        // public String ORGIN_ACCOUNT;                    // 원청사 고객사 고객번호    (2021-01-28 중복 필드로 삭제)
        @AuraEnabled
        public String CONTACTTEXT;                      // Main Contact <-- 고객사명 (2021-02-16 삭제)
        // @AuraEnabled
        // public String CONTACT_ACCOUNT;                  // 고객사 고객번호  (2021-01-28 중복 필드로 삭제)
        @AuraEnabled
        public String PROBABILITY;                      // 확도 <-- 확도
        @AuraEnabled
        public String ZZSALESSTR;                       // 수주전략세션 수행 여부 <-- Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리
        @AuraEnabled
        public String BO_OVERVIEW;                      // 개요 <-- 사업기회 개요
        @AuraEnabled
        public String ZZCOOPER;                         // 협업여부(Collaboration) <-- 법인 협업 여부
        @AuraEnabled
        public String BO_STATUS;                        // BO status(Drop, Hold, In process, Lose, Win) <-- Opportunity Status
        @AuraEnabled
        public String LOCAL_ORDER_AMT;                  // 계약 수주액(로컬 통화) <-- Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산
        @AuraEnabled
        public String SALES_DEPT_COST_CENTER;           // 수주부서 코스트센터 코드 <-- 수주 사업그룹 코스트센터 코드
        @AuraEnabled
        public String DEVELOP_DEPT_COST_CENTER;         // 매출부서 코스트센터 코드 <-- 주 매출 부서 코스트센터 코드
        @AuraEnabled
        public String BO_CLASS;                         // 사업기회 등급 <-- 사업 등급
        @AuraEnabled
        public String BID_METHOD;                       // 입찰 방식 <-- 입찰 방식
        @AuraEnabled
        public String AM_EMP_NO;                        // AM사번 <-- 고객오너(영업대표)
        @AuraEnabled
        public String AM_EMP_NAME;                      // AM명 <-- 고객오너(영업대표)명
        @AuraEnabled
        public String COMPANY_ACCOUNT_DESC;             // 고객사 명
        @AuraEnabled
        public String TECH_PROP;                        // 제안서 여부 <-- Submit Proposal
        @AuraEnabled
        public String ZZVRB_FQ_T;                       // VRB Method Description <-- VRB 유형
        @AuraEnabled
        public String UDATE_ZP21;                       // 사기검(BO Review) <-- Review Opportunity
        @AuraEnabled
        public String UDATE_VRB;                        // VRB(Gate Review) <-- BO Approval Result(ZP52, 사업기회 검토)
        // @AuraEnabled
        // public String UDATE_STRSE;                      // Strategy_Session_End_Date  <-- SFDC 해당사항 없음, (2021-02-24 제외)
        @AuraEnabled
        public String UDATE_LOSE;                       // LOSE_END_DATE <-- Report Lost Opportunity
        @AuraEnabled
        public String UDATE_DROP;                       // DROP_END_DATE <-- Abort Opportunity, Drop Opportunity, Hold Opportunity
        // @AuraEnabled
        // public String EXEC_PM_NO;                       // 실행PM 사번 <- 제안 PM (2020-12-28 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String INPUT_P;                          // 선투입 <- 선투입 여부 (X(True) / _(False)) (2020-12-28 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String BIZ_FROM_DT;                      // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String BIZ_TO_DT;                        // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가), (2021-02-24 제외)
        @AuraEnabled
        public String SALES_COST_CD;                    // 원가귀속부서 <-- 사업팀 정의 속성01
        @AuraEnabled
        public String CGUBUN_ID;                        // 거점코드 <-- 사업팀 정의 속성02
        @AuraEnabled
        public String BO_LBS_CLASS;                     // RLBS산업유형코드 <-- 사업팀 정의 속성03
        @AuraEnabled
        public String KEY_ACCOUNT_YN;                   // 키어카운트여부 <-- 사업팀 정의 속성04
        @AuraEnabled
        public String BIG_ACCOUNT_YN;                   // 빅어카운트여부 <-- Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"
        @AuraEnabled
        public String CELLO_URL;                        // Opportunity 링크URL <-- URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view
        @AuraEnabled
        public String AccountNumber;                    // MDG 고객코드 <-- Contract Account
        @AuraEnabled
        public String SHPR_CCD;                         // 화주구분코드 <-- 물류 고객 구분
        @AuraEnabled
        public String RLBS_PJT_TCD;                     // 사업 개발 유형 <-- 사업 개발 유형
        @AuraEnabled
        public String SALES_AREA_CCD;                   // 수주 권역 <-- 수주 권역
        @AuraEnabled
        public String SALES_PRNT_ORG_CD;                // 수주 거점 <-- 수주 거점
        @AuraEnabled
        public String DLVRY_AREA_CCD;                   // 매출 권역 <-- 매출 권역
        @AuraEnabled
        public String DLVRY_PRNT_ORG_CD;                // 매출 거점 <-- 매출 거점
        @AuraEnabled
        public String RLBS_BIZ_TCD;                     // 물류 서비스 범위 <-- 물류 서비스 범위
        @AuraEnabled
        public String RLBS_SVC_TCD;                     // 물류 서비스 영역 <-- 물류 서비스 영역
        @AuraEnabled
        public String BID_EST_DTM;                      // 입찰 마감일 <-- 입찰 마감일
        @AuraEnabled
        public String LBS_Exception_Type;               // 예외 :LBS 유형 확인 <-- 예외 LBS 유형 확인
        @AuraEnabled
        public String RLBS_IND_TCD;                     // 물류 업종 <-- 하위 업종 구분
        @AuraEnabled
        public String USER_ID;                          // 소유자 (영업 대표) <-- 소유자 (영업 대표)의 EP ID
        @AuraEnabled
        public String INS_PERSON_ID;                    // Created By ID <-- Created By ID의 EP ID
        @AuraEnabled
        public String UPD_PERSON_ID;                    // Last Modified By ID <-- Last Modified By ID의 EP ID
        // @AuraEnabled
        // public String REUSE;                            // 재활용필요성여부 (2021-01-28 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String REUSE_REASON;                     // 재활용필요성여부 사유 (2021-01-28 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String BO_RECORD_TYPE;                   // 사업유형 레코드 타입 (HQ:10, Logistic:20) (2021-02-08 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String ZZACONT;                          // 계약대행 여부 (2021-02-19 추가), (2021-02-24 제외)
        // @AuraEnabled
        // public String ZZACONT_EX;                       // 계약대행 예외처리 여부 (2021-02-19 추가), (2021-02-24 제외)        
        @AuraEnabled
        public List<OutputClass2> REVENUE_SCHEDULE_OPPORTUNITY;   // 매출 원가 여부 (2021-02-23 추가)
        @AuraEnabled
        public String COMPETITORS;                         //경쟁사
        @AuraEnabled
        public String LOST_REASON;                         //AR 실주 사유
 
    }
    public class OutputClass2{
        
        @AuraEnabled
        public String Parent;                           // Opportunity ID
        @AuraEnabled
        public String Name;                             // No.
        @AuraEnabled
        public String CurrencyIsoCode;                  // Currency Code
        @AuraEnabled
        public String Revenue;                          // 매출액(분할금액)
        @AuraEnabled
        public String ScheduleDate;                     // 매출일(분할일자)
        @AuraEnabled
        public String ORDER_ID;                         // BO 코드
    }    
}