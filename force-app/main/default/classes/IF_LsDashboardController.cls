/**
* @description       : 사업기회 현황 중, 대시보드로 서비스/솔루션 정보 송신
* @author            : ghkil@partner.samsung.com
* @group             : 
* @last modified on  : 2023-20-04
* @last modified by  : saurav.k@partner.samsun.com 
* Modifications Log 
* Ver   Date         Author                            Modification
* 1.0   2021-01-27   ghkil@partner.samsung.com         Initial Version
* 1.1   2021-01-28   ghkil@partner.samsung.com         Service__c, Solution__c 임시저장 기능 관련 Service__c, Solution__c 조회 조건 추가
* 1.2   2021-01-29   ghkil@partner.samsung.com         solutionAmtLocal(솔루션 Local 금액) 기준 변경 (Opportutnity의 Amount에서 Solution__c의 Amout로 변경, Solution__c의 Amount가 없는 경우 1/N 계산된 기준으로 처리)
* 1.3   2021-02-18   ghkil@partner.samsung.com         SOLUTION_OWNER_L 매핑 정보 수정 (EKText__c -> Abtel__c)
* 1.4   2021-03-18   ghkil@partner.samsung.com         solutionAmtLocal(Solution Local 통화로 환산) 구하는 환율 기준 개선 (분기별 환율 적용)
* 1.5   2021-04-14   kilhwan.an@partner.samsung.com    Department__c => CostCenter 기준으로 처리 BO_SERVICE: ZZSALES_CELL_L, ZZDEVELOP_CELL_L, BO_SOLUTION: ZZSALES_CELL_L, ZZDEVELOP_CELL_L, SOLUTION_OWNER, SOLUTION_OWNER_L
* 1.6   2021-08-04   seonju.jin@dkbmc.com              Oppty 기준으로 서비스/솔루션 전송하도록 수정 | 서비스,솔루션 IF 필드 -> 화면 기준 데이터로 변경 | SOLUTION_OWNER 필드 없을 시  Solution Update 에러 수정
* 1.7   2021-08-06   seonju.jin@dkbmc.com              solutionAmt 수정(수주품의 전까지 솔루션금액=사업기회금액/솔루션갯수 , 수주품의 후에는 솔루션금액 그대로 전송)
* 1.8   2021-09-01   seonju.jin@dkbmc.com              ZZTECH_YN 추가
* 2.0   2023-20-04   saurav.k@partner.samsung.com       (MySales -171) -IF-042(Send Service/Solution Info to Legacy) modification
**/
public class IF_LsDashboardController {
    
    private static final String INTERFACE_ID = 'IF-042';
    private static final String APEX_CLASS   = 'IF_LsDashboardController';
    private static final String METHOD_NAME  = 'CalloutDashboardInfo';
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;
    
    private static String guId = IF_Util.generateGuid();
    
    private static IF_Log ifLog;
    private static IF_Log.InterfaceLog interfaceLog;
    private static List<String> errorMsgList = new List<String>();
    
    public IF_LsDashboardController() { }
    
    //2021.07.29 seonju.jin@dkbmc.com IF 필드 -> 화면 기준 데이터로 변경
    public static String QUERY_STRING = 'Select Id ' +       
        '       , Opportunity__r.Id ' +                     // 사업기회ID
        '       , Opportunity__r.OpportunityCode__c ' +     // 사업기회Code
        '       , Opportunity__r.Name ' +                   // 사업기회명
        '       , ItemNumber__c ' +                         // Item Number
        '       , sService__c ' +                           // 마스터 서비스 Id
        '       , sService__r.Name ' +                      // 서비스명
        '       , sService__r.Code__c ' +                   // 서비스코드
        '       , Service__c ' +                            // 마스터 서비스 Id
        '       , Service__r.Name ' +                       // 서비스명
        '       , Service__r.Code__c ' +                    // 서비스코드
        '       , Opportunity__r.CompanyCode__c ' +         // Company Code
        '       , Opportunity__r.EPCompanyCode__c ' +       // EPCompanyCode__c
        '       , Opportunity__r.CloseDate ' +
        '       , sSalesDepartment__r.CostCenter__c ' +     // 수주부서 코스트센터
        '       , sDeliveryDepartment__r.CostCenter__c ' +  // 개발부서 코스트센터
        '       , SalesDepartment__r.CostCenter__c ' +      // 수주부서 코스트센터
        '       , DeliveryDepartment__r.CostCenter__c ' +   // 개발부서 코스트센터
        '       , LastModifiedDate '+                       // 서비스 최종수정일
        '       , SendSAP__c '+                             // SAP 전송여부
        '       , TechAttribute__c ' +                       // Tech Attribute
        
        'From   Service__c ' + 
        //'Where  SendSAP__c = true ' +    
        'WHERE    sDeletionFlag__c = false And SendSAP__c = true ';//2.0(MySales-171)
    
    @Future(callout=true)
    public static void calloutDashboardInfo(Set<Id> OpptyIdSet){        
        
        Map<String, Object> result = new Map<String, Object>();
        
        String reqMsg = '';
        String resMsg = '';
        
        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
        
        String queryString = QUERY_STRING + 'And    Opportunity__c IN :OpptyIdSet ';
        queryString += ' ORDER BY Opportunity__c';
        
        List<Service__c> scopeList = Database.query(queryString);
        
        if (DEBUG_FLAG) ifLog.addLog('처리 대상 : ' + scopeList.size());
        
        // *************************************
        // Dashboard 상세정보 정보 가져오기
        // *************************************
        OutputHeader outHeader = getDashboardDetailInfo(scopeList);
        
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
                
                if (DEBUG_FLAG) ifLog.addLog('Response Body : ' + hRes.getBody());
                
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            } else {
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
    }
    
    public static OutputHeader getDashboardDetailInfo(List<Service__c> scopeList) {
        
        // *************************************
        // Dashboard 상세정보 정보 가져오기
        // *************************************
        // 1. Service Data Map에 적재
        Map<Id, Service__c> serviceMap = new Map<Id, Service__c>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<String> costCenterExternalIdSet = new Set<String>();
        for (Service__c serviceData : scopeList) {
            serviceMap.put(serviceData.Id, serviceData);                        // Service Data Map에 적재
            opportunityIdSet.add(serviceData.Opportunity__r.Id);                // 사업기회ID Set에 적재
            // costCenterExternalIdSet.add(serviceData.SalesDepartment__r.CostCenter__c + '99991231' + serviceData.Opportunity__r.CompanyCode__c);    // 수주부서 코스트센터 Set에 적재
            // costCenterExternalIdSet.add(serviceData.DeliveryDepartment__r.CostCenter__c + '99991231' + serviceData.Opportunity__r.CompanyCode__c); // 개발부서 코스트센터 Set에 적재
            
            costCenterExternalIdSet.add(serviceData.sSalesDepartment__r.CostCenter__c);    // 수주부서 코스트센터 Set에 적재
            costCenterExternalIdSet.add(serviceData.sDeliveryDepartment__r.CostCenter__c); // 개발부서 코스트센터 Set에 적재
        }
        
        
        // 2. Solution Data 가져오기
        List<Solution__c> solutionList = [
            Select  Id 
            , Service__r.Opportunity__r.Id                      // 사업기회ID
            , Service__r.Opportunity__r.OpportunityCode__c      // 사업기회Code
            , Service__r.Opportunity__r.Name                    // 사업기회명
            , Service__r.ItemNumber__c                          // Item Number
            , Service__r.Service__r.Code__c                     // 서비스 코드
            , Service__r.SalesDepartment__r.CostCenter__c       // 수주부서 코스트센터
            , Service__r.DeliveryDepartment__r.CostCenter__c    // 개발부서 코스트센터                        
            , Service__r.sService__r.Code__c                     // 서비스 코드
            , Service__r.sSalesDepartment__r.CostCenter__c       // 수주부서 코스트센터
            , Service__r.sDeliveryDepartment__r.CostCenter__c    // 개발부서 코스트센터                        
            , Service__c
            , sSolution__r.Code__c                               // 솔루션 코드
            , sSolution__r.Name                                  // 솔루션명
            , Solution__r.Code__c                               // 솔루션 코드
            , Solution__r.Name                                  // 솔루션명
            , Service__r.Opportunity__r.CompanyCode__c          // Company Code
            , Service__r.Opportunity__r.EPCompanyCode__c        // EPCompanyCode__c
            , LastModifiedDate                                  // 솔루션 최종수정일
            , Service__r.Opportunity__r.Amount                  // 솔루션 금액 (Opportunity 기준)
            , Service__r.Opportunity__r.CurrencyIsoCode         // 솔루션 통화 (Opportunity 기준)
            , Service__r.Opportunity__r.CloseDate
            , Amount__c                                         // 솔루션 금액
            , CurrencyIsoCode                                   // 솔루션 통화
            , OwnerDept__r.CostCenter__c                        
            , WBSCode__c
            , SendSAP__c                                        // SAP 전송 여부            		
            From    Solution__c  
            Where   Service__c IN :serviceMap.keySet()
             And     SendSAP__c = true
            And     sDeletionFlag__c = false  //2.0(MySales-171)
            // And  Service__r.DeletionFlag__c = false            
        ];
        
        // 3. Solution Data Map에 적재
        Map<Id, Solution__c> solutionMap = new Map<Id, Solution__c>();
        Set<String> companyCodeSet = new Set<String>();
        Set<Date> closeDateSet = new Set<Date>();
        Set<String> solWbsCodeSet = new Set<String>();
        for (Solution__c solutionData : solutionList) {
            solutionMap.put(solutionData.Id, solutionData);                                 //  Service Data Map에 적재
            if(solutionData.SendSAP__c) solWbsCodeSet.add(solutionData.WBSCode__c);         // 솔루션에 맵핑된 WBSCode를 적재
            // costCenterExternalIdSet.add(solutionData.Service__r.SalesDepartment__r.CostCenter__c + '99991231' + solutionData.Service__r.Opportunity__r.CompanyCode__c);    // 수주부서 코스트센터 Set에 적재
            // costCenterExternalIdSet.add(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c + '99991231' + solutionData.Service__r.Opportunity__r.CompanyCode__c); // 개발부서 코스트센터 Set에 적재
            
            costCenterExternalIdSet.add(solutionData.Service__r.sSalesDepartment__r.CostCenter__c);    // 수주부서 코스트센터 Set에 적재
            costCenterExternalIdSet.add(solutionData.Service__r.sDeliveryDepartment__r.CostCenter__c); // 개발부서 코스트센터 Set에 적재
            companyCodeSet.add(solutionData.Service__r.Opportunity__r.CompanyCode__c);      // Company__c 조회를 위한 CompanyCode__c Set에 적재
            closeDateSet.add(solutionData.Service__r.Opportunity__r.CloseDate);             // 환율정보 조회를 위한 CloseDate Set 적재
        }
        
        // 4. WBS__c 정보 가져오기
        List<WBS__c> wbsList = [
            Select  Id
            , Name
            , ItemNumber__c
            , ItemNumberInt__c
            , ServiceCode__c
            , SolutionCode__c
            , OpportunityID__c
            , SolutionOwner__c
            , OpportunityID__r.CompanyCode__c
            From    WBS__c
            Where   OpportunityID__c IN :opportunityIdSet
            AND Name IN :solWbsCodeSet
            //AND SolutionCode__c != null
            AND WBSLevel__c  = '3'      //솔루션 WBSCode 만 조회
        ];
        
        Map<String, String> wbsSolutionOwnerMap = new Map<String, String>();
        for(WBS__c wbsData : wbsList){
            // wbsSolutionOwnerMap.put(wbsData.OpportunityID__c, wbsData.SolutionOwner__c);
            try{
                // String wbsItemNumber =  String.valueOf(wbsData.ItemNumberInt__c.intValue());
                //wbsSolutionOwnerMap.put(wbsData.OpportunityID__c + wbsItemNumber + wbsData.ServiceCode__c + wbsData.SolutionCode__c, wbsData.SolutionOwner__c);
                wbsSolutionOwnerMap.put(wbsData.Name, wbsData.SolutionOwner__c);
            }catch(Exception e){
                System.debug(e.getStackTraceString());
            }
            // costCenterExternalIdSet.add(wbsData.SolutionOwner__c + '99991231' + wbsData.OpportunityID__r.CompanyCode__c);
            
            costCenterExternalIdSet.add(wbsData.SolutionOwner__c);
        }
        
        // 5. 코스트센터 정보에 따른 Department__c 정보 가져오기 => CostCenter  기준으로 처리
        // List<Department__c> departmentList = [
        
        //     Select  Id
        //             , Kostl__c         // 코스트 센터
        //             , Abtel__c         // 부서
        //             , EKText__c        // 일반이름(E)
        //     From    Department__c
        //     Where   ExternalId__c IN :costCenterExternalIdSet
        // ];
        
        // Map<String, Department__c> departmentMap = new Map<String, Department__c>(); 
        // for( Department__c department : departmentList){
        //     departmentMap.put(department.Kostl__c, department);
        // }        
        
        List<CostCenter__c> costList = [
            SELECT Id
            ,CostCenter__c
            ,L_ORGEH__c
            FROM   CostCenter__c
            WHERE  CostCenter__c IN :costCenterExternalIdSet
        ];
        
        Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
        for( CostCenter__c ct : costList){
            
            costMap.put( ct.CostCenter__c, ct);
        }
        
        
        // 6. Company__c 정보 가져오기
        List<Company__c> companyList = [
            Select  Id
            , CompanyCode__c    // 회사코드
            , Country__c        // 국가
            , CurrencyIsoCode   // 표준 기능의 Currency
            , EPCompanyCode__c  // 인사 시스템 회사번호
            From    Company__c
            Where   CompanyCode__c IN :companyCodeSet
        ];
        Map<String, Company__c> companyMap = new Map<String, Company__c>();
        for (Company__c companyData : companyList) {
            companyMap.put(companyData.CompanyCode__c, companyData);
        }
        
        // 7. 환율정보(DatedConversionRate) 조회
        Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
        Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
        Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보
        
        // 8. Solution의 Service__r.Opportunity__r.Amount(솔루션 금액) 없는 것 확인하여 해당 Opportunity의 Solution 수량 가져오기
        List<AggregateResult> solutionAmountNullList = [
            Select  Service__r.Opportunity__r.Id opportunityId
            , count(Id) solutionCount
            From    Solution__c
            Where   (Amount__c = null or Amount__c = 0)
            And     Id IN :solutionMap.keySet()
            // And     SendSAP__c = true
            // And  DeletionFlag__c = false
            And     sDeletionFlag__c = false
            Group By Service__r.Opportunity__r.Id
        ];
        
        Map<String, Integer> solutionAmountNullMap = new Map<String, Integer>();
        for (AggregateResult data  : solutionAmountNullList) {
            solutionAmountNullMap.put(String.valueOf(data.get('opportunityId')), Integer.valueOf(data.get('solutionCount')));
        }
        System.debug('solutionAmountNullMap:' + solutionAmountNullMap);
        
        // 9. 데이터 처리
        // List<Map<String, Object>> outputList = new List<Map<String, Object>>();
        Map<String, Object> outputMap = new Map<String, Object>();
        
        // List<Object> serviceOutputList = new List<Object>();
        
        // 10. Output 정보 생성
        OutputHeader outHeader = new OutputHeader();
        
        // 11. 사업기회 수주품의 완료 여부 조회
        Set<Id> opptyCmplApprSet = new Set<Id>();           //수주품의 완결된 사업기회 Id 적재
        List<AggregateResult> knoxApprovalList =  [
            SELECT Opportunity__c 
            FROM KnoxApproval__c 
            WHERE Opportunity__c IN :opportunityIdSet
            AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
            AND Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
            GROUP BY Opportunity__c 
            HAVING COUNT(Status__c) >= 1  ];
        for(AggregateResult knox: knoxApprovalList){
            opptyCmplApprSet.add((Id)knox.get('Opportunity__c'));
        }
        
        // Service 정보
        List<OUTPUT_BO_SERVICE> outBoServiceList = new List<OUTPUT_BO_SERVICE>();
        
        for (Service__c serviceData : scopeList) {
            
            OUTPUT_BO_SERVICE outBoService = new OUTPUT_BO_SERVICE();
            
            outBoService.GUID               = serviceData.Opportunity__r.Id;                                                  // 사업기회ID
            outBoService.ZZORDER_ID         = serviceData.Opportunity__r.OpportunityCode__c;                                  // 사업기회Code
            outBoService.DESCRIPTION        = serviceData.Opportunity__r.Name;                                                // 사업기회명
            outBoService.NUMBERINT          = String.valueOf(Integer.valueOf(serviceData.ItemNumber__c));                     // Item Number                                                            // 서비스코드
            outBoService.KSCHL_SER          = serviceData.Service__r.Name;  //2.0-(MySales -171) (IF)                                                  // 서비스명
            outBoService.ZZBUKRS_H          = serviceData.Opportunity__r.CompanyCode__c;                                      // BO 회사코드 SAP코드
            outBoService.COMPANY            = serviceData.Opportunity__r.EPCompanyCode__c;                                    // BO 회사코드 인사코드
            
            outBoService.ZZSERVICE_CLASS    = serviceData.Service__r.Code__c;//2.0-(MySales -171)
            outBoService.ZZSALES_CELL_NAM   = serviceData.SalesDepartment__r.CostCenter__c;//2.0-(MySales -171)(IF) 
            outBoService.ZZDEVELOP_CELL_N   = serviceData.DeliveryDepartment__r.CostCenter__c;//2.0-(MySales -171)(IF) 
            
            outBoService.ZZTECH_YN          = (serviceData.TechAttribute__c) ? 'Y' : '';
            // String ZzSalesCellL = null;
            // if (departmentMap.get(serviceData.SalesDepartment__r.CostCenter__c) != null) {
            //     ZzSalesCellL = departmentMap.get(serviceData.SalesDepartment__r.CostCenter__c).Abtel__c;
            // }
            // outBoService.ZZSALES_CELL_L     = ZzSalesCellL;                                                                   // 수주부서 부서코드
            // String ZzDevelopCellL = null;
            // if (departmentMap.get(serviceData.DeliveryDepartment__r.CostCenter__c) != null) {
            //     ZzDevelopCellL = departmentMap.get(serviceData.DeliveryDepartment__r.CostCenter__c).Abtel__c;
            // }
            // outBoService.ZZDEVELOP_CELL_L   = ZzDevelopCellL;                                                                 // 매출부서 부서코드
            
            String ZzSalesCellL = null;
            if (costMap.get(serviceData.SalesDepartment__r.CostCenter__c) != null) {//2.0-(MySales -171)
                ZzSalesCellL = costMap.get(serviceData.SalesDepartment__r.CostCenter__c).L_ORGEH__c;//2.0-(MySales -171)
            }
            outBoService.ZZSALES_CELL_L     = ZzSalesCellL;                                                                   // 수주부서 부서코드
            String ZzDevelopCellL = null;
            if (costMap.get(serviceData.DeliveryDepartment__r.CostCenter__c) != null) {//2.0-(MySales -171)
                ZzDevelopCellL = costMap.get(serviceData.DeliveryDepartment__r.CostCenter__c).L_ORGEH__c;//2.0-(MySales -171)
            }
            outBoService.ZZDEVELOP_CELL_L   = ZzDevelopCellL;                                                                 // 매출부서 부서코드
            
            outBoService.AERDAT             = Util_String.convertDateString(serviceData.LastModifiedDate, 'Asia/Seoul');                    // 서비스 업데이트 일자
            
            outBoServiceList.add(outBoService);
        }
        
        // Solution 정보
        List<OUTPUT_BO_SOLUTION> outBoSolutionList = new List<OUTPUT_BO_SOLUTION>();
        Set<String> uniqueKey = New Set<String>(); //V2.0 - MySales 171
        for(Solution__c solutionData : solutionList){
            
            String comboKey = String.valueOf(solutionData.Service__r.Opportunity__r.Id) + String.valueOf(Integer.valueOf(solutionData.Service__r.ItemNumber__c)) + String.valueOf(solutionData.Solution__r.Code__c); // V2.0-MySales-171
            if(uniqueKey.isEmpty()){ //V2.0 - MySales 171
                
                uniqueKey.add(comboKey); //V2.0 - MySales 171
                
                OUTPUT_BO_SOLUTION outBoSolution = new OUTPUT_BO_SOLUTION();
                
                // Department__c wbsSolutionOwnerdepartment = departmentMap.get(wbsSolutionOwnerMap.get(solutionData.Service__r.Opportunity__r.Id + 
                //                                                                                         String.valueOf(Integer.valueOf(solutionData.Service__r.ItemNumber__c)).leftPad(10, '0') + 
                //                                                                                         solutionData.Service__r.Service__r.Code__c +
                //                                                                                         solutionData.Solution__r.Code__c
                //                                                                                     ));
                
                // CostCenter__c wbsSolutionOwnerCostCenter = costMap.get(wbsSolutionOwnerMap.get(solutionData.Service__r.Opportunity__r.Id + 
                //                                                                                         String.valueOf(Integer.valueOf(solutionData.Service__r.ItemNumber__c))/* .leftPad(10, '0') */ + 
                //                                                                                         solutionData.Service__r.Service__r.Code__c +
                //                                                                                         solutionData.Solution__r.Code__c
                //                                                                                     ));
                CostCenter__c wbsSolutionOwnerCostCenter = (solutionData.SendSAP__c ) ? costMap.get(wbsSolutionOwnerMap.get(solutionData.WBSCode__c)) : null;
                
                outBoSolution.GUID              = solutionData.Service__r.Opportunity__r.Id;                                                 // 사업기회ID
                outBoSolution.ZZORDER_ID        = solutionData.Service__r.Opportunity__r.OpportunityCode__c;                                 // 사업기회Code
                outBoSolution.DESCRIPTION       = solutionData.Service__r.Opportunity__r.Name;                                               // 사업기회명
                outBoSolution.NUMBERINT         = String.valueOf(Integer.valueOf(solutionData.Service__r.ItemNumber__c));                    // Item Number
                outBoSolution.ZZSERVICE_CLASS   = solutionData.Service__r.Service__r.Code__c; //2.0(MySales -171)(IF)                                               // 서비스코드
                outBoSolution.ZZSALES_CELL_NAM  = solutionData.Service__r.SalesDepartment__r.CostCenter__c; //2.0(MySales -171)(IF)                                // 수주부서 코스트센터(수주부서SAP코드)
                outBoSolution.ZZDEVELOP_CELL_N  = solutionData.Service__r.DeliveryDepartment__r.CostCenter__c;//2.0(MySales -171)(IF)
                
                // 개발부서 코스트센터(매출부서SAP코드)
                // String ZzSalesCellL = null;
                // if (departmentMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c) != null) {
                //     ZzSalesCellL = departmentMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c).Abtel__c;
                // }
                // outBoSolution.ZZSALES_CELL_L    = ZzSalesCellL;                                                                              // 수주부서 부서코드
                // String ZzDevelopCellL = null;
                // if (departmentMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c) != null) {
                //     ZzDevelopCellL = departmentMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c).Abtel__c;
                // }
                // outBoSolution.ZZDEVELOP_CELL_L  = ZzDevelopCellL; 
                // 매출부서 부서코드
                String ZzSalesCellL = null;
                if (costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c) != null) {//2.0(MySales -171)
                    ZzSalesCellL = costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c).L_ORGEH__c;//2.0(MySales -171)
                }
                outBoSolution.ZZSALES_CELL_L    = ZzSalesCellL;                                                                              // 수주부서 부서코드
                String ZzDevelopCellL = null;
                if (costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c) != null) {//2.0(MySales -171)
                    ZzDevelopCellL = costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c).L_ORGEH__c;//2.0(MySales -171)
                }
                outBoSolution.ZZDEVELOP_CELL_L  = ZzDevelopCellL;                                                                            // 매출부서 부서코드
                outBoSolution.ZZSOLUTION        = solutionData.Solution__r.Code__c;   //2.0(MySales -171)(IF)                                                       // 솔루션 코드
                outBoSolution.KSCHL_SOL         = solutionData.Solution__r.Name;     //2.0(MySales -171)(IF)                                                        // 솔루션
                // String kostl = null;    // 코스트센터코드
                // String ektext = null;   // 일반이름(E)
                // String abtel = null;    // 부서
                // if (wbsSolutionOwnerdepartment != null) {
                //     kostl   = wbsSolutionOwnerdepartment.Kostl__c;
                //     ektext  = wbsSolutionOwnerdepartment.EKText__c;
                //     abtel   = wbsSolutionOwnerdepartment.Abtel__c;
                // }
                
                String kostl = null;    // 코스트센터코드
                String abtel = null;    // 부서
                if (wbsSolutionOwnerCostCenter != null) {
                    kostl   = wbsSolutionOwnerCostCenter.CostCenter__c;
                    abtel   = wbsSolutionOwnerCostCenter.L_ORGEH__c;
                }
                outBoSolution.SOLUTION_OWNER   = kostl;                                                                                    // (손익기준)코스트센터 코드
                outBoSolution.SOLUTION_OWNER_L = abtel;                                                                                    // (손익기준)부서
                Decimal calculationResult = 0;
                String CompanyCurrencyIsoCode = null;
                if (companyMap.get(solutionData.Service__r.Opportunity__r.CompanyCode__c) != null) {
                    CompanyCurrencyIsoCode = companyMap.get(solutionData.Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;
                }
                // Solution의 Amount가 없으면 해당 Opportuniy의 Amount를 Opportuniy의 Solution 갯수로 1/N 처리
                // if (solutionData.Amount__c == null || solutionData.Amount__c == 0) {
                //     if (solutionData.Service__r.Opportunity__r.Amount == null || solutionData.Service__r.Opportunity__r.Amount == 0) {
                //         calculationSolutionAmt = 0;
                //     } else {
                //         if (solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id) != null) {
                //             calculationSolutionAmt = solutionData.Service__r.Opportunity__r.Amount / solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id);
                //         } else {
                //             calculationSolutionAmt = 0;
                //         }
                //     }
                // } else {
                //     calculationSolutionAmt = solutionData.Amount__c;
                // }
                // 2021.08.06 seonju.jin | 수주품의 전까지 솔루션금액=사업기회금액/솔루션갯수 , 수주품의 후에는 솔루션금액 그대로 전송
                Decimal calculationSolutionAmt = 0;
                if(opptyCmplApprSet.contains(solutionData.Service__r.Opportunity__r.Id)){
                    calculationSolutionAmt = (solutionData.Amount__c == null) ? 0 : solutionData.Amount__c;
                }else{
                    if (solutionData.Service__r.Opportunity__r.Amount == null || solutionData.Service__r.Opportunity__r.Amount == 0) {
                        calculationSolutionAmt = 0;
                    } else {
                        if (solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id) != null) {
                            calculationSolutionAmt = solutionData.Service__r.Opportunity__r.Amount / solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id);
                        } else {
                            calculationSolutionAmt = 0;
                        }
                    }
                }
                outBoSolution.solutionAmt       = calculationSolutionAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();         // 솔루션 금액
                outBoSolution.currency_SFDC     = solutionData.Service__r.Opportunity__r.CurrencyIsoCode;                                  // 통화                
                // Solution Local 통화로 환산 (2021-03-18 개선, 분기별 환율 적용)
                if (conversionRateMap.get(solutionData.Service__r.Opportunity__r.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                    if (conversionRateMap.get(solutionData.Service__r.Opportunity__r.CurrencyIsoCode) == conversionRateMap.get(CompanyCurrencyIsoCode)) {
                        calculationResult = calculationSolutionAmt;                             // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                    } else {
                        
                        String fromIsoCode = solutionData.Service__r.Opportunity__r.CurrencyIsoCode;
                        String toIsocode = CompanyCurrencyIsoCode;
                        Date startDate = quarterDateMap.get(solutionData.Service__r.Opportunity__r.CloseDate);
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
                        
                        calculationResult = IF_Util.calculationCurrency(    fromIsoCode
                                                                        , calculationSolutionAmt
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate
                                                                       );  // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                    }
                }
                if (calculationResult != null) {
                    outBoSolution.solutionAmtLocal  = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();           // 솔루션 Local 금액              
                } else {
                    outBoSolution.solutionAmtLocal  = '0.00';
                }
                outBoSolution.currencyLocal     = CompanyCurrencyIsoCode;                                                                   // Local 통화
                outBoSolution.ZZBUKRS_H         = solutionData.Service__r.Opportunity__r.CompanyCode__c;                                    // BO 회사코드 SAP코드
                outBoSolution.COMPANY           = solutionData.Service__r.Opportunity__r.EPCompanyCode__c;                                  // BO 회사코드 인사코드 [12.01 필드 삭제]                    
                outBoSolution.AERDAT            = Util_String.convertDateString(solutionData.LastModifiedDate, 'Asia/Seoul');                             // 솔루션 업데이트 일자
                
                outBoSolutionList.add(outBoSolution);
            }
            //Start- V2.0 - MySales 171
            if(!uniqueKey.isEmpty() && !uniqueKey.contains(comboKey)){
                uniqueKey.add(comboKey);
                OUTPUT_BO_SOLUTION outBoSolution = new OUTPUT_BO_SOLUTION();
                
                CostCenter__c wbsSolutionOwnerCostCenter = (solutionData.SendSAP__c ) ? costMap.get(wbsSolutionOwnerMap.get(solutionData.WBSCode__c)) : null;
                
                outBoSolution.GUID              = solutionData.Service__r.Opportunity__r.Id;                                                 // 사업기회ID
                outBoSolution.ZZORDER_ID        = solutionData.Service__r.Opportunity__r.OpportunityCode__c;                                 // 사업기회Code
                outBoSolution.DESCRIPTION       = solutionData.Service__r.Opportunity__r.Name;                                               // 사업기회명
                outBoSolution.NUMBERINT         = String.valueOf(Integer.valueOf(solutionData.Service__r.ItemNumber__c));                    // Item Number
                outBoSolution.ZZSERVICE_CLASS   = solutionData.Service__r.Service__r.Code__c;//2.0(MySales -171)(IF)                                                // 서비스코드
                outBoSolution.ZZSALES_CELL_NAM  = solutionData.Service__r.SalesDepartment__r.CostCenter__c;   //2.0(MySales -171) (IF)                               // 수주부서 코스트센터(수주부서SAP코드)
                outBoSolution.ZZDEVELOP_CELL_N  = solutionData.Service__r.DeliveryDepartment__r.CostCenter__c;    //2.0(MySales -171)(IF)                            // 개발부서 코스트센터(매출부서SAP코드)
                
                String ZzSalesCellL = null;
                if (costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c) != null) {//2.0(MySales -171)
                    ZzSalesCellL = costMap.get(solutionData.Service__r.SalesDepartment__r.CostCenter__c).L_ORGEH__c;//2.0(MySales -171)
                }
                outBoSolution.ZZSALES_CELL_L    = ZzSalesCellL;                                                                              // 수주부서 부서코드
                String ZzDevelopCellL = null;
                if (costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c) != null) {//2.0(MySales -171)
                    ZzDevelopCellL = costMap.get(solutionData.Service__r.DeliveryDepartment__r.CostCenter__c).L_ORGEH__c;//2.0(MySales -171)
                }
                outBoSolution.ZZDEVELOP_CELL_L  = ZzDevelopCellL;                                                                            // 매출부서 부서코드
                outBoSolution.ZZSOLUTION        = solutionData.Solution__r.Code__c; //2.0(MySales -171) (IF)                                                         // 솔루션 코드
                outBoSolution.KSCHL_SOL         = solutionData.Solution__r.Name;  //2.0(MySales -171)  (IF)                                                          // 솔루션
                
                String kostl = null;    // 코스트센터코드
                String abtel = null;    // 부서
                if (wbsSolutionOwnerCostCenter != null) {
                    kostl   = wbsSolutionOwnerCostCenter.CostCenter__c;
                    abtel   = wbsSolutionOwnerCostCenter.L_ORGEH__c;
                }
                outBoSolution.SOLUTION_OWNER   = kostl;                                                                                    // (손익기준)코스트센터 코드
                outBoSolution.SOLUTION_OWNER_L = abtel;                                                                                    // (손익기준)부서
                Decimal calculationResult = 0;
                String CompanyCurrencyIsoCode = null;
                if (companyMap.get(solutionData.Service__r.Opportunity__r.CompanyCode__c) != null) {
                    CompanyCurrencyIsoCode = companyMap.get(solutionData.Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;
                }
                
                Decimal calculationSolutionAmt = 0;
                if(opptyCmplApprSet.contains(solutionData.Service__r.Opportunity__r.Id)){
                    calculationSolutionAmt = (solutionData.Amount__c == null) ? 0 : solutionData.Amount__c;
                }else{
                    if (solutionData.Service__r.Opportunity__r.Amount == null || solutionData.Service__r.Opportunity__r.Amount == 0) {
                        calculationSolutionAmt = 0;
                    } else {
                        if (solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id) != null) {
                            calculationSolutionAmt = solutionData.Service__r.Opportunity__r.Amount / solutionAmountNullMap.get(solutionData.Service__r.Opportunity__r.Id);
                        } else {
                            calculationSolutionAmt = 0;
                        }
                    }
                }
                outBoSolution.solutionAmt       = calculationSolutionAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();         // 솔루션 금액
                outBoSolution.currency_SFDC     = solutionData.Service__r.Opportunity__r.CurrencyIsoCode;                                  // 통화                
                
                if (conversionRateMap.get(solutionData.Service__r.Opportunity__r.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                    if (conversionRateMap.get(solutionData.Service__r.Opportunity__r.CurrencyIsoCode) == conversionRateMap.get(CompanyCurrencyIsoCode)) {
                        calculationResult = calculationSolutionAmt;                             
                    } else {
                        
                        String fromIsoCode = solutionData.Service__r.Opportunity__r.CurrencyIsoCode;
                        String toIsocode = CompanyCurrencyIsoCode;
                        Date startDate = quarterDateMap.get(solutionData.Service__r.Opportunity__r.CloseDate);
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
                        
                        calculationResult = IF_Util.calculationCurrency(    fromIsoCode
                                                                        , calculationSolutionAmt
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate
                                                                       );  // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                    }
                }
                if (calculationResult != null) {
                    outBoSolution.solutionAmtLocal  = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();           // 솔루션 Local 금액              
                } else {
                    outBoSolution.solutionAmtLocal  = '0.00';
                }
                outBoSolution.currencyLocal     = CompanyCurrencyIsoCode;                                                                   // Local 통화
                outBoSolution.ZZBUKRS_H         = solutionData.Service__r.Opportunity__r.CompanyCode__c;                                    // BO 회사코드 SAP코드
                outBoSolution.COMPANY           = solutionData.Service__r.Opportunity__r.EPCompanyCode__c;                                  // BO 회사코드 인사코드 [12.01 필드 삭제]                    
                outBoSolution.AERDAT            = Util_String.convertDateString(solutionData.LastModifiedDate, 'Asia/Seoul');                             // 솔루션 업데이트 일자
                
                outBoSolutionList.add(outBoSolution);   
            }
            //End- V2.0 - MySales 171
        }
        
        // Output Data 적재
        outHeader.BO_SERVICE = outBoServiceList;
        outHeader.BO_SOLUTION = outBoSolutionList;
        
        return outHeader;
    }
    
    // 전달 값: JitterBit
    public class OutputHeader {
        
        @AuraEnabled
        public List<OUTPUT_BO_SERVICE> BO_SERVICE;
        @AuraEnabled
        public List<OUTPUT_BO_SOLUTION> BO_SOLUTION;
    }
    public class OUTPUT_BO_SERVICE{
        
        @AuraEnabled
        public String GUID;             // Opprotunity ID
        @AuraEnabled
        public String ZZORDER_ID;       // BO 코드
        @AuraEnabled
        public String DESCRIPTION;      // BO 명
        @AuraEnabled
        public String NUMBERINT;        // Item Number in Document
        @AuraEnabled
        public String ZZSERVICE_CLASS;  // SERVICE코드
        @AuraEnabled
        public String KSCHL_SER;        // SERVICE 명
        @AuraEnabled
        public String ZZBUKRS_H;        // BO 회사코드 SAP코드
        @AuraEnabled
        public String COMPANY;          // BO 회사코드 인사코드
        @AuraEnabled
        public String ZZSALES_CELL_NAM; // 수주부서SAP코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_N; // 매출부서SAP코드
        @AuraEnabled
        public String ZZSALES_CELL_L;   // 수주부서 부서코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_L; // 매출부서 부서코드
        @AuraEnabled
        public String AERDAT;           // 업데이터일자
        @AuraEnabled
        public String ZZTECH_YN;        // techAttribute
        
    } 
    public class OUTPUT_BO_SOLUTION{
        
        @AuraEnabled
        public String GUID;             // Opprotunity ID
        @AuraEnabled
        public String ZZORDER_ID;       // BO 코드
        @AuraEnabled
        public String DESCRIPTION;      // BO 명
        @AuraEnabled
        public String NUMBERINT;        // Item Number
        @AuraEnabled
        public String ZZSERVICE_CLASS;  // SERVICE코드
        @AuraEnabled
        public String ZZSALES_CELL_NAM; // 수주부서SAP코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_N; // 매출부서SAP코드
        @AuraEnabled
        public String ZZSALES_CELL_L;   // 수주부서 부서코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_L; // 매출부서 부서코드
        @AuraEnabled
        public String ZZSOLUTION;       // SOLUTION ID
        @AuraEnabled
        public String KSCHL_SOL;        // SOLUTION 명
        @AuraEnabled
        public String SOLUTION_OWNER;   // 솔루션 Owner(SAP)
        @AuraEnabled
        public String SOLUTION_OWNER_L; // 솔루션 Owner(Legacy)
        @AuraEnabled
        public String solutionAmt;      // 솔루션 금액
        @AuraEnabled
        public String currency_SFDC;    // 통화
        @AuraEnabled
        public String solutionAmtLocal; // 솔루션 Local 금액
        @AuraEnabled
        public String currencyLocal;    // Local 통화
        @AuraEnabled
        public String ZZBUKRS_H;        // BO 회사코드 SAP코드
        @AuraEnabled
        public String COMPANY;          // BO 회사코드 인사코드
        @AuraEnabled
        public String AERDAT;           // 업데이터일자
        
    } 
    
    // 받은 값 : Jitterbit 입력정보 (Request에 대한 Response)
    public class ReceiveHeader{
        
        @AuraEnabled
        public String EV_RESULT; // Message type: S Success, E Error, W Warning, I Info, A Abort
        @AuraEnabled
        public String EV_MESG;        
    }
    public class ReceiveClass{        
        
    }
}