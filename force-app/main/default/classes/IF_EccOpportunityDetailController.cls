/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-01-19
 * @last modified by  : sarthak.j1@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-12-11   ghkil@partner.samsung.com         Initial Version
 * 1.1   2020-12-28   ghkil@partner.samsung.com         Department__c 조회 시 Key값(CostCenter + 99991231 + CompanyCode)에 맞게 수정
 * 1.2   2021-01-06   ghkil@partner.samsung.com         최종 Opportunity Activity ID 가져오기 보완 및 Opportunity StageName의 단계코드, 단계명 항목 조정
 * 1.3   2021-01-13   ghkil@partner.samsung.com         Master_Service__c의 Code__c, Master_Solution__c의 Code__c, BizAttribute__c의 Code__c로 처리 보완
 * 1.4   2021-01-14   ghkil@partner.samsung.com         금액(Decimal Type) 표기 과학적(지수)표기 되지 않도록 처리
 * 1.5   2021-01-26   kilhwan.an@partner.samsung.com    사업 기회명 ( Description => Name으로 변경)
 * 1.6   2021-01-28   ghkil@partner.samsung.com         Service__c, Solution__c 임시저장 기능 관련 Service__c, Solution__c 조회 조건 추가
 * 1.7   2021-01-15   ghkil@partner.samsung.com         Project__c 조회 조건 추가 (OpporutnityId)
 * 1.8   2021-02-17   ghkil@partner.samsung.com         BusinessLevel__c을 FinalBusinessLevel__c로 변경
 * 1.9   2021-02-17   ghkil@partner.samsung.com         ZZKOKRS_H 전달값 수정(cPrimarySalesDepartment__r.Company__r.CompanyCode__c)
 * 2.0   2021-02-17   ghkil@partner.samsung.com         RESP_NO_NAME의 이름을 Employee__c의 Name으로 변경
 * 2.1   2021-02-22   ghkil@partner.samsung.com         USER_STAT_PROC  항목(Status Profile)  매핑 수정 (Opportunity, OpportunityStatus__c, Current BO Activity Status, 주의:Picklist Value값으로 제공)
 * 2.2   2021-02-26   ghkil@partner.samsung.com         ZZCOOPER 항목값 조건 (Collaboration__c && IsOriginal__c)로 조정, STATUS 항목 OpportunityStatus__c로 변경, USER_STAT_PROC 항목 OpportunityStatus__c 의 필드값로 변경
 * 2.3   2021-03-03   ghkil@partner.samsung.com         ZZCOOPER(법인 협업 여부), ZZINPUT_P(선투입여부), ZZPUBLIC_H2(공사유무), ZZACONT(계약대행), ZZACONT_EX(계약대행 예외처리 여부)DML False값 '_'에서 ''로 변경
 * 2.4   2021-03-16   ghkil@partner.samsung.com         TXT30(OpportunityData.StageName)에서 한글텍스트 제외
 * 2.5   2021-03-18   ghkil@partner.samsung.com         ZZLOORDER_AMT((SDS)예상수주액) 구하는 환율 기준 개선 (분기별 환율 적용)
 * 2.6   2021-04-14   kilhwan.an@partner.samsung.com    Department=> CostCenter 기준으로 처리 ( ZZDEVELOP_CELL_DEC, ZZSALES_CELL_DEC)
 * 2.7   2023-03-27   gitesh.s@samsung.com              Changed EvEmpNO__c to EvSapEmpNO__c(MySales-155)
 * 2.8   2024-01-19   sarthak.j1@samsung.com            Opportunity - new 'Probability' Field Creation -> MYSALES-416
**/
@RestResource( urlMapping= '/IF114/*')
global class IF_EccOpportunityDetailController {

    private static final String INTERFACE_ID = 'IF-114';
    private static final String APEX_CLASS   = 'IF_EccOpportunityDetailController';
    private static final String METHOD_NAME  = 'getOpportunityDetailInfo';

    private static final Boolean DEBUG_FLAG = true;

    public IF_EccOpportunityDetailController() { }

    @HttpPost
    global static void getOpportunityDetailInfo(){

        String guId = IF_Util.generateGuid();

        OutputHeader outHeader   = new OutputHeader();
        outHeader.TOTAL_COUNT    = 0;
        outHeader.EV_RESULT      = 'S';
        outHeader.EV_MESG        = '';

        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;

        RestResponse rep = RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        if( reqBody == null ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        }
        if (DEBUG_FLAG) ifLog.addLog('클라이언트 데이터 수신');

        // 데이터 파싱
        String inputJsonData = reqBody.toString();//.escapeJava();
        system.debug('inputJsonData : ' + inputJsonData);
        ifLog.addLog('HttpRequest : ' + inputJsonData);        
        InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
        system.debug('inputHeader : ' + inputHeader);        
        List<InputClass> inputDataList = inputHeader.DATA;
        system.debug('inputDataList : ' + inputDataList);
        if( inputDataList == null && inputDataList.size() != 0 ) {
            rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
            return;
        } 
        if (DEBUG_FLAG) ifLog.addLog('데이터 파싱');

        // 1) 해당정보 조회
        try {                                                        

            // Opportunity 정보 조회를 위한 OpportunityCode 적재
            Set<String> OpportunityCodeSet = new Set<String>();     // Opportunity 정보 조회를 위한 OpportunityCode Set
            for (InputClass inputData : inputDataList) {
                OpportunityCodeSet.add(inputData.PJTCODE);
            }
            system.debug('OpportunityCodeSet : ' + OpportunityCodeSet);

            // Opportunity 조회
            // v2.7 - Gitesh Saini
            List<Opportunity> selectOpportunityList = [
                Select  Id                                                      // 사업기회ID
                        , Name                                                  // 사업기회명
                        , Amount                                                // 예상금액 
                        //, Probability                                           // 확도  --> [Commented out] v-2.8
                        , Probability_new__c									// --> [Added] v-2.8
                        , Description                                           // 사업기회명
                        , SalesDepartment__r.CostCenter__c                      // 수주사업그룹
                        , cPrimarySalesDepartment__r.CostCenter__c              // 주 매출 부서
                        , KoreaDomestic__c                                      // 국내/해외 여부
                        , VRBMethod__c                                          // VRB 유형
                        , GroupInternal__c                                      // 그룹 내 사업 여부
                        , OpportunityCode__c                                    // 사업기회 Code
                        , CurrencyIsoCode                                       // 사업 기회 금액의 통화
                        , BiddingMethod__c                                      // 입찰 방식
                        , BusinessLevel__c                                      // 사업 등록
                        , cPrimarySalesDepartment__r.Company__c                 // Controlling Area (cPrimarySalesDepartment__r에 해당하는 CostCenter__c의 Company__c)
                        , cPrimarySalesDepartment__r.Company__r.CompanyCode__c  // Controlling Area (cPrimarySalesDepartment__r에 해당하는 CostCenter__c의 Company__c)
                        , CompanyCode__c                                        // Company Code
                        , Collaboration__c                                      // 법인 협업 여부
                        , IsOriginal__c
                        , ResourcePreInput__c                                   // 선투입 여부
                        , Construction__c                                       // 공사 수행 여부
                        , LegalReviewNo__c                                      // 법무 검토 번호
                        , CollaborationBOId__c                                  // 협업 BO ID (Salesforce BO)
                        , OpportunityStatus__c                                  // Opportunity Status
                        , toLabel(OpportunityStatus__c) OpportunityStatusLabel  // Opportunity Status 명
                        , StageName                                             // 단계                        
                        , BusinessType__c                                       // 사업 유형
                        , AgencyContract__c                                     // 계약 대행 여부
                        , AgencyContractException__c                            // 계약 대행 예외 처리 여부
                        , CloseDate                                             // 예상수주일자
                        , cRevenueStartDate__c                                  // (계약)매출 시작일
                        , cRevenueEndDate__c                                    // (계약)매출 종료일
                        , ProposalPM__r.EvSapEmpNO__c                              // 제안PM 사번
                        , ProposalPM__r.EvHName__c                              // 제안PM 성명
                        , Owner.EmployeeNumber                                  // 소유자 (영업 대표) 사번
                        , Owner.Name                                            // 소유자 (영업 대표) 성명
                        , cOriginAcc__r.AccountNumber                           // 원청사 고객번호
                        , cOriginAcc__r.Name                                    // 원청사 고객명
                        , Account.AccountNumber                                 // 고객번호
                        , Account.Name                                          // 고객명
                        , CreatedDate                                           // Opporunity 최초등록일
                        , ProposalRegistrationDate__c                           // 제안서 등록 일자
                        , ActivityStatus__c                                     // Current BO Activity Status
                        , toLabel(ActivityStatus__c) ActivityStatusLabel        // Current BO Activity Status의 Label
                        , FinalBusinessLevel__c
           		        , RecordType.DeveloperName                                      // 레코드 유형(2022-08-23 추가)
                From    Opportunity
                Where   OpportunityCode__c IN :OpportunityCodeSet
            ];
            // v2.7
            Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>();       // 서비스 조회를 위한 Opportunity 적재
            Set<String> collaborationBoIdSet = new Set<String>();                   // 협업 Opportunity 조회를 위한 CollaborationBOId__c 항목 Set 적재
            Set<String> companyCodeSet = new Set<String>();                         // Company__c 조회를 위한 CompanyCode__c 항목 Set 적재
            Set<String> employeeNumberSet = new Set<String>();                      // Employee__c 조회를 위한 EmployeeNumber 항목 Set 적재
            Set<Date> closeDateSet = new Set<Date>();
            for (Opportunity opportunityData : selectOpportunityList) {
                opportunityMap.put(opportunityData.Id, opportunityData);
                collaborationBoIdSet.add(opportunityData.CollaborationBOId__c);
                companyCodeSet.add(opportunityData.CompanyCode__c);
                employeeNumberSet.add(opportunityData.Owner.EmployeeNumber);
                closeDateSet.add(opportunityData.CloseDate);                        // 환율정보 조회를 위한 CloseDate Set 적재
            }

            // 최종 Opportunity Activity ID 가져오기
            List<Opportunity> recentlyOppActivityList = [
                Select  Id
                        , Name
                        , ( Select  Id
                                    , Name
                                    , TransactionName__c
                                    , Status__c
                                    , CreatedDate
                                    , WhatId__c
                            From    BO_Activity__r 
                            Where   Status__c = 'Completed' 
                            Order by CreatedDate Desc Limit 1)  
                From Opportunity 
                Where Id in :opportunityMap.keySet()
            ];
            system.debug('recentlyOppActivityList : ' + recentlyOppActivityList);
            Map<Id, Id> recentlyOppActivityMap = new Map<Id, Id>();
            for (Opportunity opportunityData : recentlyOppActivityList) {
                if (opportunityData.BO_Activity__r.size() > 0) {
                    recentlyOppActivityMap.put(opportunityData.Id, opportunityData.BO_Activity__r[0].Id);
                }
            }

            // 협업 Opportunity 정보 가져오기
            List<Opportunity> collaborationOpportunityList = [
                Select  Id
                        , SalesDepartment__r.CostCenter__c          // (협업)수주사업그룹
                        , CompanyCode__c                            // (협업)Company Code
                        , cPrimarySalesDepartment__r.CostCenter__c  // (협업)주 매출 부서
                        , Amount	                                // (협업)예상금액
                        , CurrencyIsoCode                           // (협업)통화
                From    Opportunity
                Where   Id IN :collaborationBoIdSet
            ];
            Map<Id, Opportunity> collaboratoinOpportunityMap = new Map<Id, Opportunity>();
            for (Opportunity collaborationOpp : collaborationOpportunityList) {
                collaboratoinOpportunityMap.put(collaborationOpp.Id, collaborationOpp);
            }

            // Opportunity Activity 정보 가져오기
            List<Opportunity_Activity__c> oppActivityList = [
                Select  Id
                        , WhatId__r.Id
                        , TransactionName__c
                        , Description__c
                        , Status__c
                        , DueDate__c
                        , StartDate__c
                        , EndDate__c
                From    Opportunity_Activity__c
                Where   WhatId__c IN :opportunityMap.keySet()
            ];
            Map<String, Opportunity_Activity__c> opportunityActivityMap = new Map<String, Opportunity_Activity__c>();           // Opportunity_Activity__c 조회용 Map
            for (Opportunity_Activity__c oppActivityData : oppActivityList) {
                opportunityActivityMap.put(oppActivityData.WhatId__r.Id + oppActivityData.TransactionName__c, oppActivityData);
            }

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

            // 환율정보(DatedConversionRate) 조회
            Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
            Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
            Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

            // Service__c 정보 조회 
            List<Service__c> selectServiceList = [
                Select  Id
                        , Opportunity__c
                        , Opportunity__r.Id
                        , Opportunity__r.CompanyCode__c
                        , ItemNumber__c                             // Number
                        , Service__c                                // Service
                        , Service__r.Code__c                        // Master_Service__c의 Code__c
                        , Service__r.Name                           // 서비스 이름 (Master_Service__c의 Name)
                        , DeliveryDepartment__r.CostCenter__c       // DeliveryDepartment의 Cost Center Code
                        , DeliveryDepartment__c                     // DeliveryDepartment로 Department의 EKText__c 가져오기
                        , SalesDepartment__r.CostCenter__c          // SalesDepartment의 Cost Center Code
                        , SalesDepartment__c                        // SalesDepartment로 Department의 EKText__c 가져오기
                From    Service__c
                Where   Opportunity__c IN :opportunityMap.keySet()
                And     SendSAP__c = true
                And     DeletionFlag__c = false                
            ];
            Map<Id, Service__c> serviceIdMap = new Map<Id, Service__c>();       // 솔루션 조회를 위한 Service__c ID와 Service__c 적재
            Set<String> serviceCostCenterExternalIdSet = new Set<String>();     // Department__c 조회를 위한 DeliveryDepartment, SalesDepartment의 Cost Center Code 적재
            for (Service__c serviceData : selectServiceList) {
                serviceIdMap.put(serviceData.Id, serviceData);
                // serviceCostCenterExternalIdSet.add(serviceData.DeliveryDepartment__r.CostCenter__c + '99991231' + serviceData.Opportunity__r.CompanyCode__c);   // Department__c의 Key는 3개로 ExternalId__c로 조회
                // serviceCostCenterExternalIdSet.add(serviceData.SalesDepartment__r.CostCenter__c + '99991231' + serviceData.Opportunity__r.CompanyCode__c);      // Department__c의 Key는 3개로 ExternalId__c로 조회
                serviceCostCenterExternalIdSet.add(serviceData.DeliveryDepartment__r.CostCenter__c);
                serviceCostCenterExternalIdSet.add(serviceData.SalesDepartment__r.CostCenter__c);
            }

            // Solution__c 정보 조회
            List<Solution__c> selectSolutionList = [
                Select  Id
                        , Opportunity__r.Id                                 // Solution__c의 Opportunity Id
                        , Service__r.Opportunity__r.Id                      // Service__c의 Opportunity Id
                        , ItemNumber__c                                     // Number
                        , Service__c                                        // BO Service
                        , Service__r.Service__r.Code__c                     // Service Code (Master_Service__c)
                        , Service__r.Service__r.Name                        // Service Name (Master_Service__c)
                        , Solution__c                                       // Solution
                        , Solution__r.Code__c                               // Solution Code (Master_Solution__c)
                        , Solution__r.Name                                  // Solution Name (Master_Solution__c)
                        , SolutionType__c                                   // Solution Type
                        , BusinessType__c                                   // Business Type
                        , Service__r.DeliveryDepartment__r.CostCenter__c    // Service의 Delivery Department에 대한 CostCenter
                        , Service__r.SalesDepartment__r.CostCenter__c       // Service의 Sales Department에 대한 CostCenter
                        , DeliveryDepartment__c                             // Delivery Department
                        , SalesDepartment__c                                // Sales Department
                        , BizAttribute__c                                   // Biz. Attribute
                        , BizAttribute__r.Code__c                           // bizAttribute__c의 Code__c
                        , WBSClass__c                                       // WBS Class
                        , WBSCode__c                                        // WBS Code
                        , ProjectCode__c                                    // Project Code
                From    Solution__c
                Where   Service__c IN :serviceIdMap.keySet()
                And     SendSAP__c = true
                And     DeletionFlag__c = false
                And 	Service__r.SendSAP__c = true
                And 	Service__r.DeletionFlag__c = false                
            ];
            Set<Id> solutionIdSet = new Set<Id>();
            Map<Id, Solution__c> solutionMap = new Map<Id, Solution__c>();
            Set<String> projectCodeSet = new Set<String>();
            for (Solution__c solutionData : selectSolutionList) {
                solutionIdSet.add(solutionData.Id);
                solutionMap.put(solutionData.Id, solutionData);
                projectCodeSet.add(solutionData.ProjectCode__c);
            }

            // Project__c 정보 조회
            List<Project__c> projectList = [
                Select  Id
                        , Name
                        , Opportunity__c
                        , ProjectCode__c
                        , ProjectType__c 
                From    Project__c
                Where   Opportunity__c IN :opportunityMap.keySet()
                And     ProjectCode__c IN :projectCodeSet
            ];
            Map<String, Project__c> projectCodeMap = new Map<String, Project__c>();
            for (Project__c projectData : projectList) {
                projectCodeMap.put(projectData.Opportunity__c + projectData.ProjectCode__c, projectData);
            }                        
       
            // Employee__c에서 Name 가져오기
            // v2.7 - Gitesh Saini
            List<Employee__c> employeeList = [
                Select  Id
                        , Name
                        , EvSapEmpNO__c
                From    Employee__c
                Where   EvSapEmpNO__c IN :employeeNumberSet
            ];
            Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
            for (Employee__c employeeData : employeeList) {
                employeeMap.put(employeeData.EvSapEmpNO__c, employeeData);
            }
            // v2.7
            // 조회 정보 전달할 Class에 매핑
            outHeader.ET_OPPORT_H = new List<OUTPUT_ET_OPPORT_H>();
            outHeader.ET_PARTNER = new List<OUTPUT_ET_PARTNER>();
            outHeader.ET_TEXT = new List<OUTPUT_ET_TEXT>();
            outHeader.ET_DATE = new List<OUTPUT_ET_DATE>();
            outHeader.ET_SERVICE = new List<OUTPUT_ET_SERVICE>();
            outHeader.ET_SOLUTION = new List<OUTPUT_ET_SOLUTION>();
            outHeader.ET_STATUS = new List<OUTPUT_ET_STATUS>();
            outHeader.ET_VRB_PARTNER = new List<OUTPUT_ET_VRB_PARTNER>();

            List<OUTPUT_ET_OPPORT_H> outEtOpportHList = new List<OUTPUT_ET_OPPORT_H>();
            List<OUTPUT_ET_PARTNER> outEtPartnerList = new List<OUTPUT_ET_PARTNER>();
            List<OUTPUT_ET_TEXT> outEtTextList = new List<OUTPUT_ET_TEXT>();
            List<OUTPUT_ET_DATE> outEtDateList = new List<OUTPUT_ET_DATE>();
            List<OUTPUT_ET_SERVICE> outEtServiceList = new List<OUTPUT_ET_SERVICE>();
            List<OUTPUT_ET_SOLUTION> outEtSolutionList = new List<OUTPUT_ET_SOLUTION>();
            List<OUTPUT_ET_STATUS> outEtStatusList = new List<OUTPUT_ET_STATUS>();
            List<OUTPUT_ET_VRB_PARTNER> outEtVrbPartnerList = new List<OUTPUT_ET_VRB_PARTNER>();

            String flagTrue = '10';     // True
            String flagFalse = '20';    // False
            String flagSapTrue = 'X';   // True
            String flagSapFalse = '';   // False

            // Opportunity 정보 Class에 매핑
            for (Opportunity OpportunityData : selectOpportunityList) {

                // OUTPUT_ET_OPPORT_H Class(Table)
                OUTPUT_ET_OPPORT_H outEtOpportunity = new OUTPUT_ET_OPPORT_H();

                outEtOpportunity.GUID               = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtOpportunity.OBJECT_ID          = recentlyOppActivityMap.get(OpportunityData.Id);                           // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
                Decimal expRevenue = 0;
                if (OpportunityData.Amount != null) {
                    expRevenue = OpportunityData.Amount;
                }
                outEtOpportunity.EXP_REVENUE        = expRevenue.setScale(2, System.RoundingMode.HALF_UP).toPlainString();      // 예상매출액 (Opportunity, Amount, 예상금액)                
                outEtOpportunity.PROBABILITY        = String.valueOf(OpportunityData.Probability_new__c);                       // 성공 확률 (Opportunity, Probability, 확도) -->[Changed Probability to Probability_new__c] v-2.8
                outEtOpportunity.DESCRIPTION        = OpportunityData.Name;                                                     // Transaction Description (Opportunity, Description, 사업기회명)
                outEtOpportunity.ZZSALES_C_NAME_M   = OpportunityData.SalesDepartment__r.CostCenter__c;                         // (Primary) Sales Dept (Opportunity, SalesDepartment__c의 cost center, 수주사업그룹)
                outEtOpportunity.ZZDEV_C_NAME_M     = OpportunityData.cPrimarySalesDepartment__r.CostCenter__c;                 // 개발부서코드 (Opportunity, cPrimarySalesDepartment__c의 cost center, 주 매출 부서)
                outEtOpportunity.ZZDOM_ABR_TYPE     = OpportunityData.KoreaDomestic__c == True ? flagTrue : flagFalse;          // 국내/해외 (Opportunity, KoreaDomestic__c, 국내/해외 여부), (True : 10, False : 20)
                outEtOpportunity.ZZVRB_FQ           = OpportunityData.VRBMethod__c;                                             // VRB Method (Opportunity, VRBMethod__c, VRB 유형)
                outEtOpportunity.ZZIN_OUT_TYPE      = OpportunityData.GroupInternal__c == True ? flagTrue : flagFalse;          // 그룹내/외 (Opportunity, GroupInternal__c, 그룹 내 사업 여부), (True : 10, False : 20)
                outEtOpportunity.ZZORDER_ID         = OpportunityData.OpportunityCode__c;                                       // 사업코드(프로젝트) (Opportunity, OpportunityCode__c, 사업 기회 Code)
                Decimal zzorderAmt = 0;
                if (OpportunityData.Amount != null) {
                    zzorderAmt = OpportunityData.Amount;
                }
                outEtOpportunity.ZZORDER_AMT        = zzorderAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();      // (SDS)예상수주액 (Opportunity, Amount, 예상금액)
                outEtOpportunity.ZZFLD00000B        = OpportunityData.CurrencyIsoCode;                                          // (SDS)예상수주액 (Curr.) (Opportunity, CurrencyIsoCode, 사업 기회 금액의 통화)
                outEtOpportunity.ZZBIDDING_TYPE     = OpportunityData.BiddingMethod__c;                                         // 입찰방식 (Opportunity, BiddingMethod__c, 입찰 방식)
                outEtOpportunity.ZZBIZ_LEVEL        = OpportunityData.FinalBusinessLevel__c;                                    // 사업등급 (Opportunity, FinalBusinessLevel__c, 사업 등급)
                outEtOpportunity.ZZKOKRS_H          = OpportunityData.cPrimarySalesDepartment__r.Company__r.CompanyCode__c;     // Controlling Area (Opportunity, cPrimarySalesDepartment__c, cPrimarySalesDepartment__c에 해당하는 Cost center의 CostCenter__c)
                outEtOpportunity.ZZBUKRS_H          = OpportunityData.CompanyCode__c;                                           // Company Code (Opportunity, CompanyCode__c, Company Code)
                String zzCooper = flagSapFalse;
                //&& OpportunityData.IsOriginal__c
                if (OpportunityData.Collaboration__c) {
                    zzCooper = flagSapTrue;
                }
                outEtOpportunity.ZZCOOPER           = zzCooper;                                                                 // 협업여부 (Opportunity, Collaboration__c & IsOriginal__c, 법인 협업 여부, (X(True) / ''(False))
                outEtOpportunity.ZZINPUT_P          = OpportunityData.ResourcePreInput__c == True ? flagSapTrue : flagSapFalse; // 선투입여부 (Opportunity, ResourcePreInput__c, 선투입 여부), (X(True) / ''(False))
                outEtOpportunity.ZZPUBLIC_H2        = OpportunityData.Construction__c == True ? flagSapTrue : flagSapFalse;     // 공사유무 (Opportunity, Construction__c, 공사 수행 여부, (X(True) / ''(False))
                String ZzCooperDept = null;
                String ZzCooperCorp = null;
                String ZzcooperSales = null;
                String ZzcoopOrdAmt = null;
                String ZzFld00005d = null;
                if (OpportunityData.CollaborationBOId__c != null) {
                    ZzCooperDept = collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).SalesDepartment__r.CostCenter__c;
                    ZzCooperCorp = collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).CompanyCode__c;
                    ZzcooperSales = collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).cPrimarySalesDepartment__r.CostCenter__c;
                    Decimal ordAmt = 0;
                    if (collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).Amount != null) {
                        ordAmt = collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).Amount;
                    }
                    ZzcoopOrdAmt = ordAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                    ZzFld00005d = collaboratoinOpportunityMap.get(OpportunityData.CollaborationBOId__c).CurrencyIsoCode;
                }
                outEtOpportunity.ZZCOOPERDEPT       = ZzCooperDept;                                                             // 협업주수주부서 (Opportunity, SalesDepartment__c, (협업)수주사업그룹, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
                outEtOpportunity.ZZCOOPERCORP       = ZzCooperCorp;                                                             // 협업법인 (Opportunity, CompanyCode__c, BO코드기준으로 다른 (협업)Opportunity ID 데이터)                
            
            //##2022-08-23 minhye.park@dkbmc.com LegalReviewNo 물류일 시 Null 추가----------------------------------
            // 사업유형 레코드 타입 (HQ/Logistic)
            if( OpportunityData.RecordType.DeveloperName  == 'HQ'){
                outEtOpportunity.ZZJUD_REVIEW_NO = OpportunityData.LegalReviewNo__c;                                         // 법무검토번호 (Opportunity, LegalReviewNo__c, 법무 검토 번호)
            }else{
                outEtOpportunity.ZZJUD_REVIEW_NO = null;
            }
                
                
               //outEtOpportunity.ZZJUD_REVIEW_NO    = OpportunityData.LegalReviewNo__c;                                         // 법무검토번호 (Opportunity, LegalReviewNo__c, 법무 검토 번호) 
                outEtOpportunity.ZZHQSLSDEPT        = null;                                                                     // HQ Business Unit (Null 값으로 제공)
                outEtOpportunity.ZZCON_H            = null;                                                                     // 컨소시엄유무 (Null 값으로 제공)
                outEtOpportunity.ZZMAINPRJ          = null;                                                                     // 선행프로젝트여부 (Null 값으로 제공)
                outEtOpportunity.ZZCOOPERSALES      = ZzcooperSales;                                                            // 협업주매출부서 (Opportunity, cPrimarySalesDepartment__c, (협업)주 매출 부서, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
                outEtOpportunity.ZZCOOPORD_AMT      = ZzcoopOrdAmt;                                                             // 협업 수주총액 (Opportunity, Amount, 예상금액, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
                outEtOpportunity.ZZFLD00005D        = ZzFld00005d;                                                              // 협업 수주총액 (Curr.) (Opportunity, Currency, 통화, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
                String ZzvrbChYn = 'N';
                if (opportunityActivityMap.get(OpportunityData.Id + 'ZP52') != null) {
                    if (opportunityActivityMap.get(OpportunityData.Id + 'ZP52').Status__c == 'Completed') {
                        ZzvrbChYn = 'Y';
                    }
                }
                outEtOpportunity.ZZVRB_CH           = ZzvrbChYn;                                                                // VRB체크 (Review BO(ZP52)이고 status = "Completed"면 "Y" 아니면 "N")
                outEtOpportunity.ZZOPPTNUMBER       = null;                                                                     // 협업프로젝트번호 (Null 값으로 제공(사용안함))
                outEtOpportunity.ZZREF_GUID         = OpportunityData.CollaborationBOId__c;                                     // Relation GUID (Opportunity, CollaborationBOId__c, 협업 BO ID (Salesforce BO), BO코드기준으로 다른 (협업)Opportunity ID 데이터)
                outEtOpportunity.CURR_PHASE         = OpportunityData.StageName;                                                // Sales Stage (계산값?, Opportunity, StageName)
                outEtOpportunity.ZZMO_PRJ_X         = null;                                                                     // 모프로젝트 여부 (Null 값으로 제공)
                outEtOpportunity.ZZBIZ_TYPE         = OpportunityData.BusinessType__c;                                          // 사업유형 (Opportunity, BusinessType__c, 사업 유형)
                outEtOpportunity.ZZSALES_TYPE       = null;                                                                     // Sales Type (Null 값으로 제공)
                outEtOpportunity.ZZACONT            = OpportunityData.AgencyContract__c == True ? flagSapTrue : flagSapFalse;   // 계약대행 (Opportunity, AgencyContract__c, 계약 대행 여부), (X(True) / ''(False)
                outEtOpportunity.ZZACONT_EX         = OpportunityData.AgencyContractException__c == True ? flagSapTrue : flagSapFalse;  // 계약대행 예외처리 여부 (Opportunity, AgencyContractException__c, 계약 대행 예외 처리 여부), (X(True) / ''(False)
                outEtOpportunity.ZZDOM_ABR_ACCNT    = OpportunityData.KoreaDomestic__c == True ? flagTrue : flagFalse;          // 고객사 국내/외 (Opportunity, KoreaDomestic__c, 국내/해외 여부 (Ture : 10, False : 20))
                outEtOpportunity.ZZIN_OUT_ACCNT     = OpportunityData.GroupInternal__c == True ? flagTrue : flagFalse;          // 고객사 그룹내/외 (Opportunity, GroupInternal__c, 그룹 내 사업 여부 (Ture : 10, False : 20)
                outEtOpportunity.ZZEXPECT_DATE      = Util_String.convertDateString(OpportunityData.CloseDate);                 // 예상수주일 (Opportunity, CloseDate, 예상수주일자)
                outEtOpportunity.ZDEVELOPTIME_FR    = Util_String.convertDateString(OpportunityData.cRevenueStartDate__c);      // 개발시작일 (Opportunity, cRevenueStartDate__c, (계약)매출 시작일)
                outEtOpportunity.ZDEVELOPTIME_TO    = Util_String.convertDateString(OpportunityData.cRevenueEndDate__c);        // 개발종료일 (Opportunity, cRevenueEndDate__c, (계약)매출 종료일)
                Decimal calculationResult = 0;
                String CompanyCurrencyIsoCode = null;
                if (companyMap.get(OpportunityData.CompanyCode__c) != null) {
                    CompanyCurrencyIsoCode = companyMap.get(OpportunityData.CompanyCode__c).CurrencyIsoCode;
                }
                // (SDS)예상수주액 계산 개선 (2021-03-18)
                if (conversionRateMap.get(OpportunityData.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                    if (OpportunityData.CurrencyIsoCode == CompanyCurrencyIsoCode) {
                        calculationResult = OpportunityData.Amount == null ? 0 : OpportunityData.Amount;
                    } else {

                        String fromIsoCode = OpportunityData.CurrencyIsoCode;
                        String toIsocode = CompanyCurrencyIsoCode;
                        Date startDate = quarterDateMap.get(OpportunityData.CloseDate);
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

                        if( Util_String.nvlDec( OpportunityData.Amount) > 0){
    
                            calculationResult = IF_Util.calculationCurrency(    fromIsoCode
                                                                                , OpportunityData.Amount
                                                                                , toIsoCode
                                                                                , fromUsdRate
                                                                                , toUsdRate  );
                        }
                        // calculationResult = IF_Util.calculationCurrency(    OpportunityData.CurrencyIsoCode, 
                        //                                                     OpportunityData.Amount, 
                        //                                                     CompanyCurrencyIsoCode, 
                        //                                                     conversionRateMap.get(OpportunityData.CurrencyIsoCode).ConversionRate, 
                        //                                                     conversionRateMap.get(CompanyCurrencyIsoCode).ConversionRate
                        //                                                 );
                    }
                }
                // outEtOpportunity.ZZLOORDER_AMT      = Util_String.nvlDec( calculationResult).setScale(2, System.RoundingMode.HALF_UP).toPlainString();// (SDS)예상수주액 (계산값, Opportunity Amount를 Campany CurrencyIsoCode로 환산)
                outEtOpportunity.ZZLOORDER_AMT      = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();// (SDS)예상수주액 (계산값, Opportunity Amount를 Campany CurrencyIsoCode로 환산)

                outEtOpportunity.ZZFLD000081        = CompanyCurrencyIsoCode;                                                   // (SDS)예상수주액 (Curr.) (Company, CurrencyIsoCode, 통화, Opportunity의 Company Code와 Company__c의 Company Code를 확인해서 CurrencyIsoCode)

                outEtOpportHList.add(outEtOpportunity);

                // ET_PARTNER Class(Table)
                OUTPUT_ET_PARTNER outEtPartner = new OUTPUT_ET_PARTNER();

                outEtPartner.GUID                   = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtPartner.OBJECT_ID              = recentlyOppActivityMap.get(OpportunityData.Id);                           // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
                // v2.7 - Gitesh Saini
                outEtPartner.PROPOSAL_PM            = OpportunityData.ProposalPM__r.EvSapEmpNO__c;                                 // 제안PM 사번 (Opportunity, ProposalPM__c, 제안 PM)
                // v2.7
                outEtPartner.PROPOSAL_PM_NAME       = OpportunityData.ProposalPM__r.EvHName__c;                                 // 제안PM 성명 (Opportunity, ProposalPM__c, 제안 PM)
                outEtPartner.RESP_NO                = OpportunityData.Owner.EmployeeNumber;                                     // 영업담당자 사번 (Opportunity, OwnerId, 소유자 (영업 대표))
                String ownerName = null;
                if (employeeMap.get(OpportunityData.Owner.EmployeeNumber) != null) {
                    ownerName = employeeMap.get(OpportunityData.Owner.EmployeeNumber).Name;
                }
                
                outEtPartner.RESP_NO_NAME           = ownerName;                                                            // 영업담당자 성명 (Opportunity, OwnerId, 소유자 (영업 대표))
                outEtPartner.OR_CUSTOMER_NO         = OpportunityData.cOriginAcc__r.AccountNumber;                              // 원청사 고객번호 (Opportunity, cOriginAcc__c, 원청사 고객)
                outEtPartner.OR_CUSTOMER_NO_NAME    = OpportunityData.cOriginAcc__r.Name;                                       // 원청사 고객명 (Opportunity, cOriginAcc__c, 원청사 고객)
                outEtPartner.CUSTOMER_NO            = OpportunityData.Account.AccountNumber;                                    // 고객번호 (Opportunity, AccountId, Contract Account)
                outEtPartner.CUSTOMER_NO_NAME       = OpportunityData.Account.Name;                                             // 고객명 (Opportunity, AccountId, Contract Account) 

                outEtPartnerList.add(outEtPartner);

                // ET_TEXT Class(Table)
                OUTPUT_ET_TEXT outEtText = new OUTPUT_ET_TEXT();

                outEtText.GUID                      = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtText.OBJECT_ID                 = recentlyOppActivityMap.get(OpportunityData.Id);                           // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
                outEtText.TDLINE                    = OpportunityData.Description;                                              // Text Line (Opportunity, Description, 사업기회개요)

                outEtTextList.add(outEtText);

                // ET_DATE Class(Table)
                OUTPUT_ET_DATE outEtDate = new OUTPUT_ET_DATE();

                outEtDate.GUID                      = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtDate.OBJECT_ID                 = recentlyOppActivityMap.get(OpportunityData.Id);                           // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
                outEtDate.ZOPPTREG_DATE             = Util_String.convertDateString(OpportunityData.CreatedDate, 'Asia/Seoul');   // 사업등록일 (Opportunity, CeatedDate, 최초등록일)
                outEtDate.ZBIZPLAN                  = Util_String.convertDateString(OpportunityData.CloseDate);                 // 수주예상일 (Opportunity, CloseDate, 예상수주일자)
                outEtDate.ZDEVELOPTIME_FR           = Util_String.convertDateString(OpportunityData.cRevenueStartDate__c);      // 프로젝트기간(FROM) (Opportunity, cRevenueStartDate__c, (계약)매출 시작일)
                outEtDate.ZDEVELOPTIME_TO           = Util_String.convertDateString(OpportunityData.cRevenueEndDate__c);        // 프로젝트기간(TO) (Opportunity, cRevenueEndDate__c, (계약)매출 종료일)
                String ZProposeExpl = null;
                if (opportunityActivityMap.get(OpportunityData.Id + 'ZP61') != null) {
                    ZProposeExpl = Util_String.convertDateString(opportunityActivityMap.get(OpportunityData.Id + 'ZP61').EndDate__c);
                }
                outEtDate.ZPROPOSEEXPL              = ZProposeExpl;                                                             // 제안일 (Opportunity_Activity__c, EndDate__c, 종료일자 (BO Activity 견적/제안 제출 시, 종료일 ['Submit Proposal' => 'ZP61']))
                String ZProposakReq = null;
                String ZProposakAppr = null;
                if (opportunityActivityMap.get(OpportunityData.Id + 'ZP52') != null) {
                    ZProposakReq = Util_String.convertDateString(opportunityActivityMap.get(OpportunityData.Id + 'ZP52').StartDate__c);
                    ZProposakAppr = Util_String.convertDateString(opportunityActivityMap.get(OpportunityData.Id + 'ZP52').EndDate__c);
                }
                outEtDate.ZPROPOSAL_REQ             = ZProposakReq;                                                             // VRB요청일자 (Opportunity_Activity__c, StartDate__c, 시작 일자 (BO Activity VRB 시, 시작일자 ['Review BO' => 'ZP52']))
                outEtDate.ZPROPOSAL_APPR            = ZProposakAppr;                                                            // VRB승인일자 (Opportunity_Activity__c, EndDate__c, 종료 일자 (BO Activity VRB 시, 종료일자 ['Review BO' => 'ZP52']))
                String ApprDate = null;
                if (opportunityActivityMap.get(OpportunityData.Id + 'ZPZ1') != null) {
                    ApprDate = Util_String.convertDateString(opportunityActivityMap.get(OpportunityData.Id + 'ZPZ1').EndDate__c);
                }
                outEtDate.APPR_DATE                 = ApprDate;                                                                 // 실주일자 (Opportunity_Activity__c, EndDate__c, 종료 일자 (BO Activity VRB 시, 종료일자 ['Review BO' => 'ZPZ1']))

                outEtDateList.add(outEtDate);

                // ET_STATUS Class(Table)
                OUTPUT_ET_STATUS outEtStatus = new OUTPUT_ET_STATUS();

                outEtStatus.GUID                    = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                Map<String, String> stageNameMap = new Map<String, String>{
                    'Z01' => 'Identified',
                    'Z02' => 'Validated',
                    'Z03' => 'Qualified',
                    'Z04' => 'Solutioned',
                    'Z05' => 'Closed/Won',
                    'Z06' => 'Closed/Lost',
                    'Z07' => 'Closed/Drop'
                };
                outEtStatus.STATUS                  = OpportunityData.OpportunityStatus__c;                                     // Object status (Opportunity, OpportunityStatus__c, 2021-02-26 변경)
                outEtStatus.USER_STAT_PROC          = String.valueOf(OpportunityData.get('OpportunityStatusLabel'));            // Status Profile (Opportunity, OpportunityStatus__c의 필드값, 주의:Picklist Value값으로 제공, 2021-02-26 수정)
                outEtStatus.TXT30                   = stageNameMap.get(OpportunityData.StageName);                              // Stage 코드 (계산값, Opportunity, StageName, 단계)

                outEtStatusList.add(outEtStatus);

                // ET_VRB_PARTNER Class(Table)
                OUTPUT_ET_VRB_PARTNER outEtVrbPartner = new OUTPUT_ET_VRB_PARTNER();

                outEtVrbPartner.GUID                = OpportunityData.Id;                                                       // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtVrbPartner.OBJECT_ID           = recentlyOppActivityMap.get(OpportunityData.Id);                           // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
                outEtVrbPartner.PROCESS_TYPE        = OpportunityData.VRBMethod__c;                                             // VRB 유형 (Opportunity, VRBMethod__c, VRB 유형)
                outEtVrbPartner.PARTNER_FCT         = null;                                                                     // Partner Function (Null 값으로 제공)
                outEtVrbPartner.PARTNER_NO          = null;                                                                     // Business Partner Number (Null 값으로 제공)
                outEtVrbPartner.PARTNER_NAME        = null;                                                                     // Search Help Field 1 (Name 1/Last Name) (Null 값으로 제공)

                outEtVrbPartnerList.add(outEtVrbPartner);
            }

            outHeader.ET_OPPORT_H = outEtOpportHList;
            outHeader.ET_PARTNER = outEtPartnerList;
            outHeader.ET_TEXT = outEtTextList;
            outHeader.ET_DATE = outEtDateList;
            outHeader.ET_STATUS = outEtStatusList;
            outHeader.ET_VRB_PARTNER = outEtVrbPartnerList;

            // Service 정보 Class에 매핑
            // List<Department__c> departmentList = [
            //     Select  Id
            //             , EKText__c
            //             , Kostl__c
            //     From    Department__c
            //     Where   ExternalId__c IN :serviceCostCenterExternalIdSet
            // ];
            // Map<String, Department__c> departmentMap = new Map<String, Department__c>();
            // for (Department__c departmentData : departmentList) {
            //     departmentMap.put(departmentData.Kostl__c, departmentData);
            // }

            List<CostCenter__c> costList = [
                SELECT Id
                      ,Name
                      ,CostCenter__c
                      ,L_ORGEH__c
                FROM   CostCenter__c
                WHERE  CostCenter__c IN :serviceCostCenterExternalIdSet
            ];
    
            Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
            for( CostCenter__c ct : costList){
    
                costMap.put( ct.CostCenter__c, ct);
            }            

            for (Service__c serviceData : selectServiceList) {
                OUTPUT_ET_SERVICE outEtService = new OUTPUT_ET_SERVICE();

                outEtService.GUID                   = serviceData.Opportunity__c;                                                   // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtService.OBJECT_ID              = recentlyOppActivityMap.get(serviceData.Opportunity__c);                       // Transaction ID (Opportunity, ActivityStatus__c, Current BO Activity Status)
                outEtService.NUMBER_INT             = String.valueOf(serviceData.ItemNumber__c);                                    // Item Number in Document (Service__c, ItemNumber__c, Nember)
                outEtService.ZZSERVICE_CLASS        = serviceData.Service__r.Code__c;                                               // 서비스 (Service__c, Service__c, Service) --> Master_Service__c의 Code__c로 처리
                outEtService.ZZSERVICE_CLASS_NM     = serviceData.Service__r.Name;                                                  // Keywords (Service__c, Service__c, Lookup(Master_Service__c)의 Name서비스 이름)
                outEtService.ZZDEVELOP_CELL_N       = serviceData.DeliveryDepartment__r.CostCenter__c;                              // 매출셀코드(CostCenter) (DeliveryDepartment의 Cost Center Code)
                // String zzdevelopCellDec = null;
                // if (departmentMap.get(serviceData.DeliveryDepartment__r.CostCenter__c) != null) {
                //     zzdevelopCellDec = departmentMap.get(serviceData.DeliveryDepartment__r.CostCenter__c).EKText__c;
                // }
                // outEtService.ZZDEVELOP_CELL_DEC     = zzdevelopCellDec;                                                             // General Name ( DeliveryDepartment로 Department의 EKText__c 가져오기)
                // outEtService.ZZSALES_CELL_NAM       = serviceData.SalesDepartment__r.CostCenter__c;                                 // 수주셀코드(CostCenter) (SalesDepartment의 Cost Center Code)
                // String zzsalesCellDec = null;
                // if (departmentMap.get(serviceData.SalesDepartment__r.CostCenter__c) != null) {
                //     zzsalesCellDec = departmentMap.get(serviceData.SalesDepartment__r.CostCenter__c).EKText__c;
                // }
                // outEtService.ZZSALES_CELL_DEC       = zzsalesCellDec;                                                               // General Name (SalesDepartment로 Department의 EKText__c 가져오기)
                
                String zzdevelopCellDec = null;
                if (costMap.get(serviceData.DeliveryDepartment__r.CostCenter__c) != null) {
                    zzdevelopCellDec = costMap.get(serviceData.DeliveryDepartment__r.CostCenter__c).Name;
                }
                outEtService.ZZDEVELOP_CELL_DEC     = zzdevelopCellDec;                                                             // General Name ( DeliveryDepartment로 Department의 EKText__c 가져오기)
                outEtService.ZZSALES_CELL_NAM       = serviceData.SalesDepartment__r.CostCenter__c;                                 // 수주셀코드(CostCenter) (SalesDepartment의 Cost Center Code)
                String zzsalesCellDec = null;
                if (costMap.get(serviceData.SalesDepartment__r.CostCenter__c) != null) {
                    zzsalesCellDec = costMap.get(serviceData.SalesDepartment__r.CostCenter__c).Name;
                }
                outEtService.ZZSALES_CELL_DEC       = zzsalesCellDec;                                                               // General Name (SalesDepartment로 Department의 EKText__c 가져오기)
             
                outEtServiceList.add(outEtService);
            }

            outHeader.ET_SERVICE = outEtServiceList;

            // Solution 정보 Class에 매핑
            for (Solution__c solutionData : selectSolutionList) {
                OUTPUT_ET_SOLUTION outEtSolution = new OUTPUT_ET_SOLUTION();

                outEtSolution.GUID                  = solutionData.Service__r.Opportunity__r.Id;                                    // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
                outEtSolution.OBJECT_ID             = recentlyOppActivityMap.get(solutionData.Service__r.Opportunity__r.Id);        // Transaction ID (Opportunity, ActivityStatus__c, Current BO Activity Status)
                outEtSolution.NUMBER_INT            = String.valueOf(solutionData.ItemNumber__c);                                   // Item Number in Document (Solution__c, ItemNumber__c, Nember)
                outEtSolution.ZZSERVICE_CLASS       = solutionData.Service__r.Service__r.Code__c;                                   // 서비스 (Solution__c, Service__c, BO Service) --> Master_Service__c의 Code__c로 처리
                outEtSolution.ZZSERVICE_CLASS_NM    = solutionData.Service__r.Service__r.Name;                                      // Keywords (Service__c와 Master_Service__c의 Code을 Join하여 Lookup(Master_Service__c)의 Name)
                outEtSolution.ZZSOLUTION            = solutionData.Solution__r.Code__c;                                             // 솔루션 (Solution__c, Solution__c, Solution) --> Master_Solution__c의 Code__c로 처리
                outEtSolution.ZZSOLUTION_NM         = solutionData.Solution__r.Name;                                                // Keywords (Solution__c와 Master_Solution__c의 Code을 Join하여 Lookup(Master_Solution__c)의 Name)
                outEtSolution.ZZSOLUTION_CASE       = solutionData.SolutionType__c;                                                 // [CRM] Soution Type (Solution__c, SolutionType__c, Solution Type)
                // outEtSolution.ZZDEVELOP_CELL_N      = solutionData.Service__r.DeliveryDepartment__r.CostCenter__c;                  // 매출셀코드(CostCenter) (Solution__c, DeliveryDepartment__c, 확인필요)
                // String zzdevelopCellDec2 = null;
                // if (departmentMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c) != null) {
                //     zzdevelopCellDec2 = departmentMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c).EKText__c;
                // }
                // outEtSolution.ZZDEVELOP_CELL_DEC    = zzdevelopCellDec2;                                                            // 매출부서명 (Solution__c, DeliveryDepartment__c, 확인필요)
                // outEtSolution.ZZSALES_CELL_NAM      = solutionData.Service__r.SalesDepartment__r.CostCenter__c;                     // 수주셀코드(CostCenter) (Solution__c, SalesDepartment__c, 확인필요)
                // String zzsalesCellDec2 = null;
                // if (departmentMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c) != null) {
                //     zzsalesCellDec2 = departmentMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c).EKText__c;
                // }

                outEtSolution.ZZDEVELOP_CELL_N      = solutionData.Service__r.DeliveryDepartment__r.CostCenter__c;                  // 매출셀코드(CostCenter) (Solution__c, DeliveryDepartment__c, 확인필요)
                String zzdevelopCellDec2 = null;
                if (costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c) != null) {
                    zzdevelopCellDec2 = costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c).Name;
                }
                outEtSolution.ZZDEVELOP_CELL_DEC    = zzdevelopCellDec2;                                                            // 매출부서명 (Solution__c, DeliveryDepartment__c, 확인필요)
                outEtSolution.ZZSALES_CELL_NAM      = solutionData.Service__r.SalesDepartment__r.CostCenter__c;                     // 수주셀코드(CostCenter) (Solution__c, SalesDepartment__c, 확인필요)
                String zzsalesCellDec2 = null;
                if (costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c) != null) {
                    zzsalesCellDec2 = costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c).Name;
                }
                outEtSolution.ZZSALES_CELL_DEC      = zzsalesCellDec2;                                                              // 수주부서명 (Solution__c, SalesDepartment__c, 확인필요)
                outEtSolution.ZZBIZ_TYPE_S          = solutionData.BusinessType__c;                                                 // 사업유형(솔루션) (Solution__c, BusinessType__c, Business Type)
                outEtSolution.ZZORDER_TYPE_S        = solutionData.BizAttribute__r.Code__c;                                         // 사업속성(솔루션) (Solution__c, BizAttribute__c) --> bizAttribute__c의 Code__c로 처리
                outEtSolution.ZZWBS_CLASS_S         = solutionData.WBSClass__c;                                                     // 수익인식기준(솔루션) (Solution__c, WBSClass__c)
                String ZzextCodeA = null;
                String ZzextCodeB = null;
                if (projectCodeMap.get(solutionData.Opportunity__r.Id + solutionData.projectCode__c) != null) {
                    if (projectCodeMap.get(solutionData.Opportunity__r.Id + solutionData.projectCode__c).ProjectType__c == 'Sales Project') {
                        ZzextCodeA = solutionData.projectCode__c;
                    } else if (projectCodeMap.get(solutionData.Opportunity__r.Id + solutionData.projectCode__c).ProjectType__c == 'Execute Project') {
                        ZzextCodeB = solutionData.projectCode__c;
                    }
                }
                outEtSolution.ZZEXT_CODE_A          = ZzextCodeA;                                                                   // 프로젝트 코드 (Project__c, ProjectCode__c, ProjectType__c가 'Sales Project'인 것)
                outEtSolution.ZZEXT_CODE_C          = ZzextCodeB;                                                                   // 프로젝트 코드 (Project__c, ProjectCode__c, ProjectType__c가 'Execute Project'인 것)                

                outEtSolutionList.add(outEtSolution);
            }

            outHeader.ET_SOLUTION = outEtSolutionList;

            // 성공 로그 데이터
            outHeader.TOTAL_COUNT    = selectOpportunityList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);

            if (DEBUG_FLAG) ifLog.addLog('데이터 조회 완료');

        } catch (Exception e) {

            // 에러 로그 데이터
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            String sendData          = JSON.serialize(outHeader);

            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);    
        }

        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
    
    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;     // 토탈카운트
        @AuraEnabled
        public Integer PAGE_COUNT;      // 페이지당 전송 건수
        @AuraEnabled
        public Integer PAGE_NUM;        // 현재페이지
        @AuraEnabled
        public List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public String PJTCODE;                              // BO 코드 (Opportunity, OpportunityCode__c, 사업 기회 Code)
    }

    // 전달 값: JitterBit
    public class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;                         // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT;                            // 처리 결과
        @AuraEnabled
        public String EV_MESG;                              // 처리 메세지
        @AuraEnabled
        public List<OUTPUT_ET_OPPORT_H> ET_OPPORT_H;        // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_PARTNER> ET_PARTNER;          // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_TEXT> ET_TEXT;                // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_DATE> ET_DATE;                // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_SERVICE> ET_SERVICE;          // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_SOLUTION> ET_SOLUTION;        // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_STATUS> ET_STATUS;            // 데이터 포멧
        @AuraEnabled
        public List<OUTPUT_ET_VRB_PARTNER> ET_VRB_PARTNER;  // 데이터 포멧        
    }
    public class OUTPUT_ET_OPPORT_H {

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String EXP_REVENUE;                          // 예상매출액 (Opportunity, Amount, 예상금액)
        public String PROBABILITY;                          // 성공 확률 (Opportunity, Probability, 확도)
        public String DESCRIPTION;                          // Transaction Description (Opportunity, Description__c, 사업기회명)
        public String ZZSALES_C_NAME_M;                     // (Primary) Sales Dept (Opportunity, SalesDepartment__c, 수주사업그룹)
        public String ZZDEV_C_NAME_M;                       // 개발부서코드 (Opportunity, cPrimarySalesDepartment__c, 주 매출 부서)
        public String ZZDOM_ABR_TYPE;                       // 국내/해외 (Opportunity, KoreaDomestic__c, 국내/해외 여부)
        public String ZZVRB_FQ;                             // VRB Method (Opportunity, VRBMethod__c, VRB 유형)
        public String ZZIN_OUT_TYPE;                        // 그룹내/외 (Opportunity, GroupInternal__c, 그룹 내 사업 여부)
        public String ZZORDER_ID;                           // 사업코드(프로젝트) (Opportunity, OpportunityCode__c, 사업 기회 Code)
        public String ZZORDER_AMT;                          // (SDS)예상수주액 (Opportunity, Amount, 예상금액)
        public String ZZFLD00000B;                          // (SDS)예상수주액 (Curr.) (Opportunity, CurrencyIsoCode, 사업 기회 금액의 통화)
        public String ZZBIDDING_TYPE;                       // 입찰방식 (Opportunity, BiddingMethod__c, 입찰 방식)
        public String ZZBIZ_LEVEL;                          // 사업등급 (Opportunity, FinalBusinessLevel__c, 사업 등급)
        public String ZZKOKRS_H;                            // Controlling Area (Opportunity, cPrimarySalesDepartment__c, cPrimarySalesDepartment__c에 해당하는 Cost center의 CostCenter__c)
        public String ZZBUKRS_H;                            // Company Code (Opportunity, CompanyCode__c, Company Code)
        public String ZZCOOPER;                             // 협업여부 (Opportunity, Collaboration__c, 법인 협업 여부, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZINPUT_P;                            // 선투입여부 (Opportunity, ResourcePreInput__c, 선투입 여부)
        public String ZZPUBLIC_H2;                          // 공사유무 (Opportunity, Construction__c, 공사 수행 여부)
        public String ZZCOOPERDEPT;                         // 협업주수주부서 (Opportunity, SalesDepartment__c, 수주사업그룹, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZCOOPERCORP;                         // 협업법인 (Opportunity, Company__c, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZJUD_REVIEW_NO;                      // 법무검토번호 (Opportunity, LegalReviewNo__c, 법무 검토 번호)
        public String ZZHQSLSDEPT;                          // HQ Business Unit (Null 값으로 제공)
        public String ZZCON_H;                              // 컨소시엄유무 (Null 값으로 제공)
        public String ZZMAINPRJ;                            // 선행프로젝트여부 (Null 값으로 제공)
        public String ZZCOOPERSALES;                        // 협업주매출부서 (Opportunity, cPrimarySalesDepartment__c, 주 매출 부서, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZCOOPORD_AMT;                        // 협업 수주총액 (Opportunity, Amount, 예상금액, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZFLD00005D;                          // 협업 수주총액 (Curr.) (Opportunity, Currency, 통화, BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String ZZVRB_CH;                             // VRB체크 (Review BO(ZP52)이고 status = "Completed"면 "Y" 아니면 "N")
        public String ZZOPPTNUMBER;                         // 협업프로젝트번호 (Null 값으로 제공(사용안함))
        public String ZZREF_GUID;                           // Relation GUID (Opportunity, CollaborationBOId__c, 협업 BO ID (Salesforce BO), BO코드기준으로 다른 (협업)Opportunity ID 데이터)
        public String CURR_PHASE;                           // Sales Stage (계산값, Opportunity, StageName)
        public String ZZMO_PRJ_X;                           // 모프로젝트 여부 (Null 값으로 제공)
        public String ZZBIZ_TYPE;                           // 사업유형 (Opportunity, BusinessType__c, 사업 유형)
        public String ZZSALES_TYPE;                         // Sales Type (Null 값으로 제공)
        public String ZZACONT;                              // 계약대행 (Opportunity, AgencyContract__c, 계약 대행 여부)
        public String ZZACONT_EX;                           // 계약대행 예외처리 여부 (Opportunity, AgencyContractException__c, 계약 대행 예외 처리 여부)
        public String ZZDOM_ABR_ACCNT;                      // 고객사 국내/외 (Opportunity, KoreaDomestic__c, 국내/해외 여부 (Ture - 10, False - 20))
        public String ZZIN_OUT_ACCNT;                       // 고객사 그룹내/외 (Opportunity, GroupInternal__c, 그룹 내 사업 여부 (Ture - 10, False - 20)
        public String ZZEXPECT_DATE;                        // 예상수주일 (Opportunity, CloseDate, 예상수주일자)
        public String ZDEVELOPTIME_FR;                      // 개발시작일 (Opportunity, cRevenueStartDate__c, (계약)매출 시작일)
        public String ZDEVELOPTIME_TO;                      // 개발종료일 (Opportunity, cRevenueEndDate__c, (계약)매출 종료일)
        public String ZZLOORDER_AMT;                        // (SDS)예상수주액 (계산값, Opportunity Amount를 Campany currency 로 환산)
        public String ZZFLD000081;                          // (SDS)예상수주액 (Curr.) (Company, CurrencyIsoCode, 통화, Opportunity의 Company Code와 Company의 Company Code를 확인해서 Currency)        
    }
    public class OUTPUT_ET_PARTNER {

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String PROPOSAL_PM;                          // 제안PM 사번 (Opportunity, ProposalPM__c, 제안 PM)
        public String PROPOSAL_PM_NAME;                     // 제안PM 성명 (Opportunity, ProposalPM__c, 제안 PM)
        public String RESP_NO;                              // 영업담당자 사번 (Opportunity, OwnerId, 소유자 (영업 대표))
        public String RESP_NO_NAME;                         // 영업담당자 성명 (Opportunity, OwnerId, 소유자 (영업 대표))
        public String OR_CUSTOMER_NO;                       // 원청사 고객번호 (Opportunity, cOriginAcc__c, 원청사 고객)
        public String OR_CUSTOMER_NO_NAME;                  // 원청사 고객명 (Opportunity, cOriginAcc__c, 원청사 고객)
        public String CUSTOMER_NO;                          // 고객번호 (Opportunity, AccountId, Contract Account)
        public String CUSTOMER_NO_NAME;                     // 고객명 (Opportunity, AccountId, Contract Account)        
    }               
    public class OUTPUT_ET_TEXT {               

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String TDLINE;                               // Text Line (Opportunity, Description, 사업기회개요)
    }
    public class OUTPUT_ET_DATE {

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String ZOPPTREG_DATE;                        // 사업등록일 (Opportunity, CeatedDate, 최초등록일)
        public String ZBIZPLAN;                             // 수주예상일 (Opportunity, CloseDate, 예상수주일자)
        public String ZDEVELOPTIME_FR;                      // 프로젝트기간(FROM) (Opportunity, cRevenueStartDate__c, (계약)매출 시작일)
        public String ZDEVELOPTIME_TO;                      // 프로젝트기간(TO) (Opportunity, cRevenueEndDate__c, (계약)매출 종료일)
        public String ZPROPOSEEXPL;                         // 제안일 (Opportunity_Activity__c, EndDate__c, 종료일자 (BO Activity 견적/제안 제출 시, 종료일 ['Submit Proposal' => 'ZP61']))
        public String ZPROPOSAL_REQ;                        // VRB요청일자 (Opportunity_Activity__c, StartDate__c, 시작 일자 (BO Activity VRB 시, 시작일자 ['Review BO' => 'ZP52']))
        public String ZPROPOSAL_APPR;                       // VRB승인일자 (Opportunity_Activity__c, EndDate__c, 종료 일자 (BO Activity VRB 시, 종료일자 ['Review BO' => 'ZP52']))
        public String APPR_DATE;                            // 실주일자 (Opportunity_Activity__c, EndDate__c, 종료 일자 (BO Activity VRB 시, 종료일자 ['Review BO' => 'ZPZ1']))
    }               
    public class OUTPUT_ET_SERVICE {                

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String NUMBER_INT;                           // Item Number in Document (Service__c, ItemNumber__c, Nember)
        public String ZZSERVICE_CLASS;                      // 서비스 (Service__c, Service__c, Service)
        public String ZZSERVICE_CLASS_NM;                   // Keywords (Service__c, Service__c, Lookup(Master_Service__c)의 Name)
        public String ZZDEVELOP_CELL_N;                     // 매출셀코드(CostCenter) (Service__c, DeliveryDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c)
        public String ZZDEVELOP_CELL_DEC;                   // General Name (Service__c, DeliveryDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c를 통해 Department__c의 EKText__c)
        public String ZZSALES_CELL_NAM;                     // 수주셀코드(CostCenter) (Service__c, SalesDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c)
        public String ZZSALES_CELL_DEC;                     // General Name (Service__c, SalesDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c를 통해 Department__c의 EKText__c)
    }               
    public class OUTPUT_ET_SOLUTION {               

        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String NUMBER_INT;                           // Item Number in Document (Solution__c, ItemNumber__c, Nember)
        public String ZZSERVICE_CLASS;                      // 서비스 (Solution__c, Service__c, BO Service)
        public String ZZSERVICE_CLASS_NM;                   // Keywords (Solution__c, Service__c, Lookup(Master_Service__c)의 Name)
        public String ZZSOLUTION;                           // 솔루션 (Solution__c, Solutionc__c, Solution)
        public String ZZSOLUTION_NM;                        // Keywords (Solution__c, Solutionc__c, Lookup(Master_Solution__c)의 Name)
        public String ZZSOLUTION_CASE;                      // [CRM] Soution Type (Solution__c, SolutionType__c, Solution Type)
        public String ZZDEVELOP_CELL_N;                     // 매출셀코드(CostCenter) (Solution__c, DeliveryDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c)
        public String ZZDEVELOP_CELL_DEC;                   // 매출부서명 (Solution__c, DeliveryDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c를 통해 Department__c의 EKText__c)
        public String ZZSALES_CELL_NAM;                     // 수주셀코드(CostCenter) (Solution__c, SalesDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c)
        public String ZZSALES_CELL_DEC;                     // 수주부서명 (Solution__c, SalesDepartment__c, 코스트센터코드, Lookup(CostCenter__c)의 CostCenter__c를 통해 Department__c의 EKText__c)
        public String ZZBIZ_TYPE_S;                         // 사업유형(솔루션) (Solution__c, BusinessType__c, Business Type)
        public String ZZORDER_TYPE_S;                       // 사업속성(솔루션) (Solution__c, BizAttribute__c, Biz. Attribute)
        public String ZZWBS_CLASS_S;                        // 수익인식기준(솔루션) (Solution__c, WBSClass__c, WBS Class)
        public String ZZEXT_CODE_A;                         // 프로젝트 코드 (Project, Project Code, 프로젝트 코드, Opportunity__c와 연관되고 Project Type="Sales Project")
        public String ZZEXT_CODE_C;                         // 프로젝트 코드 (Project, Project Code, 프로젝트 코드, Opportunity__c와 연관되고 Project Type="Execute Project")
    }               
    public class OUTPUT_ET_STATUS {             
                    
        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String STATUS;                               // Stage 코드 (계산값, Opportunity, StageName, 단계)
        public String USER_STAT_PROC;                       // Status Profile (Opportunity, OpportunityStatus__c, Current BO Activity Status, 주의:Picklist Value값으로 제공)
        public String TXT30;                                // Object status (Opportunity, StageName, 단계명)
    }                   
    public class OUTPUT_ET_VRB_PARTNER {                
                    
        public String GUID;                                 // GUID of a CRM Order Object (Opportunity, Id, 사업기획 ID)
        public String OBJECT_ID;                            // Transaction ID (Opportunity Activity, Opportunity Activity ID, 최종 Opportunity Activity Id)
        public String PROCESS_TYPE;                         // VRB 유형 (Opportunity, VRBMethod__c, VRB 유형)
        public String PARTNER_FCT;                          // Partner Function (Null 값으로 제공)
        public String PARTNER_NO;                           // Business Partner Number (Null 값으로 제공)
        public String PARTNER_NAME;                         // Search Help Field 1 (Name 1/Last Name) (Null 값으로 제공)
    }    
}