/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-11-09
 * @last modified by  : kajal.c@samsung.com
 * Modifications Log 
 * Ver   Date         Author                                Modification
 * 1.0   12-01-2020   soohong0.kim@partner.samsung.com      Initial Version
 * 1.1   2021-03-18   ghkil@partner.samsung.com             SdsAmount((SDS)예상수주액) 구하는 환율 기준 개선 (분기별 환율 적용)
 * 1.2   2023-11-09   kajal.c@samsung.com  Changes related to MYSales-354. -- Part of MS - 216
**/
public class IF_SdGetApprovalLineController {
    private static final String INTERFACE_ID = 'IF-126';
    private static final String APEX_CLASS   = 'IF_SdGetApprovalLineController';
    private static final String METHOD_NAME  = 'getApprovalLine';
    
    @AuraEnabled
    public static Map<String,Object> getApprovalLine(Param param ){
        String guId = IF_Util.generateGuid();
        InputClass input = new InputClass();
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>();
        try{
            List<IT_DATE> itDateList = new List<IT_DATE>();
            List<User> userList = [select id, EmployeeNumber from User ];
            Map<String,String> userMap = new Map<String,String>();
            for(User obj : userList){
                userMap.put(obj.id, obj.EmployeeNumber);
            }

            
            // IS_OPPORTUNITY
            // V1.2 Added by kajal -->Opportunity_Review_Biz_Amount__c
            String query = 'SELECT Id, AccountId, Account.AccountNumber, Name, Amount, ExpectedRevenue, CurrencyIsoCode, OwnerId, SalesDepartment__r.CostCenter__c, StageName, ';
            query += 'cOriginAcc__c, cOriginAcc__r.AccountNumber,  ActivityStatus__c, cPrimarySalesDepartment__r.CostCenter__c, ProposalPM__c, ProposalPM__r.EvSapEmpNO__c, OpportunityCode__c, CompanyCode__c, ';
            query += 'BusinessType__c, KoreaDomestic__c, GroupInternal__c, BiddingMethod__c, AgencyContract__c, AgencyContractException__c, ';
            query += 'FinalBusinessLevel__c, Construction__c, Collaboration__c, CollaborationBOId__r.OpportunityCode__c, OpportunityStatus__c,  IF_ActivityCnt__c, ';
            query += 'LostReasonLogistics__c, CloseDate, cRevenueStartDate__c, cRevenueEndDate__c, CreatedDate, Opportunity_Review_Biz_Amount__c ';
            query += 'FROM Opportunity where id = \''+param.opptyId+'\'';
            Opportunity opp = Database.query(query);
            
            Set<Date> closeDateSet = new Set<Date>();
            closeDateSet.add(opp.CloseDate);                                        // 환율정보 조회를 위한 CloseDate Set 적재
            System.debug('KajalTest$% ' + param);
            IS_Input isInput = new IS_INPUT();
            isInput.corporationId = param.corporationId;
            System.debug('KajalTest' + param.factorType);
            isInput.approvalProcessId = param.factorType;
            isInput.userEmpNo   = param.userEmpNo;
            isInput.draftEmpNo  = param.userEmpNo;
            isInput.factor      = param.factor;
            isInput.pathlist    = param.pathlist;
            isInput.html        = param.html;
            isInput.apInfId     = param.apInfId;
            input.IS_INPUT      = isInput;

            IS_OPPORTUNITY isOpp = new IS_OPPORTUNITY ();
            isOpp.Id = opp.id;
            if(opp.AccountId != null){
                // Account acc = [select id, AccountNumber from Account where id =: opp.AccountId limit 1];
                isOpp.AccountId = opp.Account.AccountNumber; //acc.AccountNumber;
            }
            isOpp.Name = opp.Name;
            if(opp.CurrencyIsoCode == 'KRW'){ //통화가 한국인 경우 소수점 제거
                if(opp.Amount != null) isOpp.Amount = String.valueOf(opp.Amount).split('\\.')[0];
                if(opp.ExpectedRevenue != null) isOpp.ExpectedRevenue =  String.valueOf(opp.ExpectedRevenue).split('\\.')[0];
            }
            else{ //그 외 국가는 반올림 처리
                if(opp.Amount != null) isOpp.Amount = opp.Amount.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                if(opp.ExpectedRevenue != null) isOpp.ExpectedRevenue = opp.ExpectedRevenue.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
            }
            
            isOpp.CurrencyIsoCode = opp.CurrencyIsoCode;
            isOpp.OwnerId = userMap.get(opp.OwnerId);
            isOpp.SalesDepartment = opp.SalesDepartment__r.CostCenter__c;
            
            if(opp.cOriginAcc__c != null){
                Account acc = [select id, AccountNumber from Account where id =: opp.cOriginAcc__c limit 1];
                isOpp.cOriginAcc = opp.cOriginAcc__r.AccountNumber; //acc.AccountNumber;
            }
            isOpp.ActivityStatus = opp.ActivityStatus__c;
            isOpp.cPrimarySalesDepartment = opp.cPrimarySalesDepartment__r.CostCenter__c;
            if(opp.ProposalPM__c != null){
                // Employee__c emp = [select id, EvSapEmpNO__c from Employee__c where id =:opp.ProposalPM__c limit 1 ];
                isOpp.ProposalPM = opp.ProposalPM__r.EvSapEmpNO__c; //emp.EvSapEmpNO__c;
            }
            isOpp.OpportunityCode = opp.OpportunityCode__c;
            isOpp.CompanyCode = opp.CompanyCode__c;
            isOpp.BusinessType = opp.BusinessType__c;
            isOpp.KoreaDomestic = opp.KoreaDomestic__c == true ? '10' : '20';
            isOpp.GroupInternal = opp.GroupInternal__c == true ? '10' : '20';
            isOpp.BiddingMethod = opp.BiddingMethod__c;
            isOpp.AgencyContract = opp.AgencyContract__c == true ? 'X' : '';
            isOpp.AgencyContractException = opp.AgencyContractException__c == true ? 'X' : ''; 
            isOpp.BusinessLevel = opp.FinalBusinessLevel__c;
            isOpp.Construction = opp.Construction__c == true ? 'X' : '';
            isOpp.Collaboration = opp.Collaboration__c == true ? 'X' : '';
            isOpp.CollaborationBOId = opp.CollaborationBOId__r.OpportunityCode__c;
            isOpp.OpportunityStatus = opp.OpportunityStatus__c;
            //isOpp.Company = opp.Company__c; ->  필드 삭제
            // isOpp.Initial_approval = opp.IF_ActivityCnt__c > 0 ? 'X' : '';
            isOpp.Initial_approval = opp.IF_ActivityCnt__c > 0 ? '' : 'X';
            //2021-01-14 추가 by Soohong.kim
            isOpp.LostReasonLogistics = opp.StageName == 'Z07' ? opp.LostReasonLogistics__c : '';
            //2021-02-23 추가 by Soohong.kim
            isOpp.Stage = opp.StageName;
            isOpp.CloseDate = Util_String.convertDateString(opp.CloseDate);
            isOpp.cRevenueStartDate = Util_String.convertDateString(opp.cRevenueStartDate__c);
            isOpp.cRevenueEndDate = Util_String.convertDateString(opp.cRevenueEndDate__c);
            //V1.2 Start Added by kajal
            if(opp.CurrencyIsoCode == 'KRW'){
                if(opp.Opportunity_Review_Biz_Amount__c != null) isOpp.Biz_budget_amt = String.valueOf(opp.Opportunity_Review_Biz_Amount__c).split('\\.')[0];
            }
            else{
                if(opp.Opportunity_Review_Biz_Amount__c != null) isOpp.Biz_budget_amt = opp.Opportunity_Review_Biz_Amount__c.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
            }
            //V1.2 End

            //-------
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
                Where   CompanyCode__c =: opp.CompanyCode__c
            ];
            
            // 환율정보(DatedConversionRate) 조회
            Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
            Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
            Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

            Decimal calculationResult = 0;
            String CompanyCurrencyIsoCode = null;
            if(companyList.size()>0) CompanyCurrencyIsoCode = companyList[0].CurrencyIsoCode;

            if (conversionRateMap.get(opp.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                if (opp.CurrencyIsoCode == CompanyCurrencyIsoCode) {
                    calculationResult = opp.Amount;    
                } else {
                    // (SDS)예상수주액 계산 개선 (2021-03-18)
                    String fromIsoCode = opp.CurrencyIsoCode;
                    String toIsocode = CompanyCurrencyIsoCode;
                    Date startDate = quarterDateMap.get(opp.CloseDate);
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
                                                                        , opp.Amount
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate  );

                    // calculationResult = IF_Util.calculationCurrency(    opp.CurrencyIsoCode
                    //                                                     , opp.Amount
                    //                                                     , CompanyCurrencyIsoCode
                    //                                                     , conversionRateMap.get(opp.CurrencyIsoCode).ConversionRate
                    //                                                     , conversionRateMap.get(CompanyCurrencyIsoCode).ConversionRate  );
                }
            }
            isOpp.SdsAmount = Util_String.nvlDec( calculationResult).setScale(2, System.RoundingMode.HALF_UP).toPlainString();// (SDS)예상수주액 (계산값, Opportunity Amount를 Campany CurrencyIsoCode로 환산)

            isOpp.SdsCurrency = CompanyCurrencyIsoCode; // (SDS)예상수주액 (Curr.) (Company, CurrencyIsoCode, 통화, Opportunity의 Company Code와 Company__c의 Company Code를 확인해서 CurrencyIsoCode)
            input.IS_OPPORTUNITY = isOpp;

            // IS_ACTIVITY
            // [2021-05-04 수정] param.actId (Activity Id)가 있는 경우에 input parameter
            String actLostReason = '';
            if(String.isNotBlank(param.actId)){
                query = ' SELECT Id, TransactionName__c, WhatId__r.OpportunityCode__c, Description__c, DueDate__c, StartDate__c, EndDate__c, Status__c, toLabel(LostReason__c) labelReason ';
                query += ' FROM Opportunity_Activity__c ';
                query += ' WHERE id = \''+param.actId+'\'';
                Opportunity_Activity__c oppAct = Database.query(query);
                IS_ACTIVITY isActivity = new IS_ACTIVITY();
                isActivity.Id = oppAct.Id;
                isActivity.TransactionName = oppAct.TransactionName__c;
                isActivity.WhatId = oppAct.WhatId__r.OpportunityCode__c;
                isActivity.Description = oppAct.Description__c;
                isActivity.DueDate = Util_String.convertDateString(oppAct.DueDate__c);
                isActivity.ActualStartDate = Util_String.convertDateString(oppAct.StartDate__c);
                isActivity.ActualEndDate = Util_String.convertDateString(oppAct.EndDate__c);
                isActivity.OwnerId = userMap.get(opp.OwnerId);
                isActivity.Status = oppAct.Status__c;
                isActivity.LostReason = String.valueOf(oppAct.get('labelReason'));
                actLostReason = String.valueOf(oppAct.get('labelReason'));
                input.IS_ACTIVITY = isActivity;
            } else {
                input.IS_ACTIVITY = null;
            }

            //IT_ACTIVITY_LIST - 2021-01-14 추가 by Soohong.Kim
            query = ' SELECT Id, TransactionName__c, WhatId__r.OpportunityCode__c, Description__c, DueDate__c, StartDate__c, EndDate__c, Status__c, toLabel(LostReason__c) labelReason ';
            query += ' FROM Opportunity_Activity__c ';
            query += ' WHERE WhatId__c = \''+opp.id+'\' order by CreatedDate Desc ';
            List<Opportunity_Activity__c> oppActList = Database.query(query);
            List<IS_ACTIVITY> isActList = new List<IS_ACTIVITY>();
            for(Opportunity_Activity__c obj : oppActList){
                IS_ACTIVITY isAct = new IS_ACTIVITY();
                isAct.Id = obj.Id;
                isAct.TransactionName = obj.TransactionName__c;
                isAct.WhatId = obj.WhatId__r.OpportunityCode__c;
                isAct.Description = obj.Description__c;
                isAct.DueDate = Util_String.convertDateString(obj.DueDate__c);
                isAct.ActualStartDate = Util_String.convertDateString(obj.StartDate__c);
                isAct.ActualEndDate = Util_String.convertDateString(obj.EndDate__c);
                isAct.OwnerId = userMap.get(opp.OwnerId);
                isAct.Status = obj.Status__c;
                // isAct.LostReason = String.valueOf(oppAct.get('labelReason'));
                isAct.LostReason = actLostReason;
                
                isActList.add(isAct);
            }
            input.IT_ACTIVITY_LIST = isActList;
            
            // IT_Service
            query = ' SELECT Id, Service__r.Code__c, Opportunity__r.OpportunityCode__c, ItemNumber__c, SalesDepartment__r.CostCenter__c, DeliveryDepartment__r.CostCenter__c, DeletionFlag__c ';
            query += ' FROM Service__c ';
            query += ' WHERE Opportunity__c = \''+param.opptyId+'\' AND SendSAP__c = true AND DeletionFlag__c = false ';
            List<Service__c> serviceList = Database.query(query);
            List<IT_Service> itServiceList = new List<IT_Service>();
            Set<Id> svcIds = new Set<Id>();
            system.debug('serviceList : '+serviceList);
            for(Service__c obj : serviceList){
                svcIds.add(obj.id);
                IT_Service itService = new IT_Service();
                itService.Opportunity = obj.Opportunity__r.OpportunityCode__c;
                itService.ItemNumber = String.valueOf(obj.ItemNumber__c);
                itService.Service = obj.Service__r.Code__c;
                itService.SalesDepartment = obj.SalesDepartment__r.CostCenter__c;
                itService.DeliveryDepartment = obj.DeliveryDepartment__r.CostCenter__c;
                itService.DeletionFlag = obj.DeletionFlag__c == true ? 'X' : '';
                itServiceList.add(itService);
            }
            
            input.IT_Service = itServiceList;
            

            // IT_SOLUTION   
            query = ' SELECT Id, Service__c, Service__r.Service__r.Code__c, Solution__r.Code__c, ItemNumber__c, BizAttribute__c, BizAttribute__r.Code__c, SolutionType__c, SalesType__c, ';
            query += ' PLCStatus__c, DeletionFlag__c, ProjectCode__c ';
            query += ' FROM Solution__c ';
            query += ' WHERE Service__c in: svcIds AND SendSAP__c = true AND DeletionFlag__c = false ';
            List<Solution__c> solutionList = Database.query(query);
            // WBSClass, BusinessType 필드 구조변경 확인 필요
            //List<SvcSolBizAttr__c> bizAttr = [select id, WBSClass__c, BusinessType__c from SvcSolBizAttr__c where Solution__c =: solution.id limit 1];
            
            Map<String,SvcSolBizAttr__c> bizMap = new Map<String,SvcSolBizAttr__c>();
            
            List<IT_SOLUTION> itSolutionList = new List<IT_SOLUTION>();
            Set<Id> bizIds = new Set<Id>();
            Set<Id> mSolIds = new Set<Id>();

            for(Solution__c obj : solutionList){
                if(obj.BizAttribute__c != null) bizIds.add(obj.BizAttribute__c);
                if(obj.Solution__c != null) mSolIds.add(obj.Solution__c);
            }
            List<SvcSolBizAttr__c> bizAttrList = [SELECT id, WBSClass__c, BizAttribute__c, BusinessType__c, Solution__c FROM SvcSolBizAttr__c
                                                  WHERE BizAttribute__c in: bizIds or Solution__c in:mSolIds];
            for(Solution__c obj : solutionList){
                IT_SOLUTION itSolution = new IT_SOLUTION();
                //biz정보 매핑
                for(SvcSolBizAttr__c biz : bizAttrList){
                    if(biz.Solution__c == obj.Solution__c && biz.BizAttribute__c == obj.BizAttribute__c){
                        itSolution.WBSClass = biz.WBSClass__c;
                        itSolution.BusinessType = biz.BusinessType__c;
                        break;
                    }
                }
                
                itSolution.Service = obj.Service__r.Service__r.Code__c;
                itSolution.ItemNumber = String.valueOf(obj.ItemNumber__c);
                itSolution.ServiceCode = obj.Service__r.Service__r.Code__c;
                itSolution.SolutionCode = obj.Solution__r.Code__c;
                itSolution.BizAttribute = obj.BizAttribute__r.Code__c;
                itSolution.SolutionType = obj.SolutionType__c;
                itSolution.SalesType = obj.SalesType__c;
                itSolution.PLCStatus = obj.PLCStatus__c;
                if(obj.ProjectCode__c != null && obj.ProjectCode__c.mid(3,1) != null) itSolution.ProjectCodeA = obj.ProjectCode__c.mid(3,1) == 'A' ? obj.ProjectCode__c : null;
                if(obj.ProjectCode__c != null && obj.ProjectCode__c.mid(3,1) != null) itSolution.ProjectCodeC = obj.ProjectCode__c.mid(3,1) == 'C' ? obj.ProjectCode__c : null;
                itSolution.DeletionFlag = obj.DeletionFlag__c == true ? 'X' : '';
                itSolutionList.add(itSolution);
                
            }
            input.IT_SOLUTION = itSolutionList;

            // IT_WBS
            query = ' SELECT Id, Name, OpportunityID__r.OpportunityCode__c, ProjectCode__c, ProjectCodeOutput__c, SolutionCode__c, ';
            query += ' ServiceCode__c, ItemNumber__c, DeletionFlag__c, SolutionOwner__c ';
            query += ' FROM WBS__c ';
            query += ' WHERE OpportunityID__c = \''+param.opptyId+'\'';
            List<WBS__c> wbsList = Database.query(query);
            List<IT_WBS> itWbsList = new List<IT_WBS>();
            for(WBS__c obj : wbsList){
                IT_WBS itWbs = new IT_WBS();
                itWbs.OpportunityID = obj.OpportunityID__r.OpportunityCode__c;
                itWbs.ProjectCode = obj.ProjectCode__c;
                itWbs.ProjectCodeOutput = obj.ProjectCodeOutput__c;
                itWbs.WBSCode = obj.Name;
                itWbs.SolutionCode = obj.SolutionCode__c;
                itWbs.ServiceCode = obj.ServiceCode__c;
                itWbs.ItemNumber = obj.ItemNumber__c;
                itWbs.DeletionFlag = obj.DeletionFlag__c == 'Y' ? 'X' : '';
                itWbs.SolutionOwner = obj.SolutionOwner__c;
                itWbsList.add(itWbs);
            }
            input.IT_WBS = itWbsList;

            //IT_Project
            query = ' SELECT Id, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c ';
            query += ' FROM Project__c ';
            query += ' WHERE Opportunity__c = \''+param.opptyId+'\'';
            List<Project__c> projectList = Database.query(query);
            List<IT_Project> itProjectList = new List<IT_Project>();
            for(Project__c obj : projectList){
                IT_Project itProject = new IT_Project();
                itProject.Opportunity = obj.Opportunity__r.OpportunityCode__c;
                itProject.ProjectType = obj.ProjectType__c;
                itProject.ProjectCode = obj.ProjectCode__c;
                itProject.Description = obj.Description__c;
                itProject.DeletionFlag = obj.DeletionFlag__c == true ? 'X' : '';
                itProjectList.add(itProject);
            }
            input.IT_Project = itProjectList;
            
            

            //IS_CO_OPPORT
            //V1.2 added by Kajal -->Opportunity_Review_Biz_Amount__c
            if(opp.CollaborationBOId__c != null){
                query = ' SELECT Id, AccountId, Account.AccountNumber, Name, Amount, ExpectedRevenue, CurrencyIsoCode, OwnerId, Owner.EmployeeNumber, SalesDepartment__r.CostCenter__c, cOriginAcc__c, cOriginAcc__r.AccountNumber, ';
                query += ' ActivityStatus__c, cPrimarySalesDepartment__r.CostCenter__c, ProposalPM__c, ProposalPM__r.EvSapEmpNO__c, OpportunityCode__c, CompanyCode__c, BusinessType__c,  ';
                query += ' KoreaDomestic__c, GroupInternal__c, BiddingMethod__c, AgencyContract__c, AgencyContractException__c, FinalBusinessLevel__c, ';
                query += ' Construction__c, Collaboration__c, CollaborationBOId__r.OpportunityCode__c, OpportunityStatus__c, StageName, ';
                query += ' CloseDate, cRevenueStartDate__c, cRevenueEndDate__c, CreatedDate, Opportunity_Review_Biz_Amount__c ';
                query += ' FROM Opportunity ';
                query += ' WHERE id = \''+opp.CollaborationBOId__c+'\'';
                Opportunity coOpp = Database.query(query);
                IS_CO_OPPORT itCoOpp = new IS_CO_OPPORT();
                itCoOpp.Id = coOpp.Id;
                if(coOpp.AccountId != null){
                    // Account acc = [select id, AccountNumber from Account where id =: coOpp.AccountId limit 1];
                    itCoOpp.AccountId = coOpp.Account.AccountNumber; //acc.AccountNumber;
                }
                itCoOpp.Name = coOpp.Name;
                
                if(coOpp.CurrencyIsoCode == 'KRW'){ //통화가 한국인 경우 소수점 제거
                    if(coOpp.Amount != null)          itCoOpp.Amount = String.valueOf( coOpp.Amount).split('\\.')[0];
                    if(coOpp.ExpectedRevenue != null) itCoOpp.ExpectedRevenue =  String.valueOf( coOpp.ExpectedRevenue).split('\\.')[0];
                }
                else{ //그 외 국가는 반올림 처리

                    if(coOpp.Amount != null) itCoOpp.Amount = coOpp.Amount.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                    if(coOpp.ExpectedRevenue != null) itCoOpp.ExpectedRevenue = coOpp.ExpectedRevenue.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                }
                
                itCoOpp.CurrencyIsoCode = coOpp.CurrencyIsoCode;
                itCoOpp.OwnerId         = coOpp.Owner.EmployeeNumber;
                itCoOpp.SalesDepartment = coOpp.SalesDepartment__r.CostCenter__c;
                itCoOpp.Stage = coOpp.StageName;
                if(coOpp.cOriginAcc__c != null){
                    // Account acc = [select id, AccountNumber from Account where id =: coOpp.cOriginAcc__c limit 1];
                    itCoOpp.cOriginAcc = coOpp.cOriginAcc__r.AccountNumber; //acc.AccountNumber;
                } 
                itCoOpp.ActivityStatus = coOpp.ActivityStatus__c;
                itCoOpp.cPrimarySalesDepartment = coOpp.cPrimarySalesDepartment__r.CostCenter__c;
                if(coOpp.ProposalPM__c != null){
                    // Employee__c emp = [select id, EvSapEmpNO__c from Employee__c where id =:coOpp.ProposalPM__c limit 1 ];
                    itCoOpp.ProposalPM = coOpp.ProposalPM__r.EvSapEmpNO__c;  //emp.EvSapEmpNO__c;
                }
                itCoOpp.OpportunityCode = coOpp.OpportunityCode__c;
                itCoOpp.CompanyCode = coOpp.CompanyCode__c;
                itCoOpp.BusinessType = coOpp.BusinessType__c;
                itCoOpp.KoreaDomestic = coOpp.KoreaDomestic__c == true ? '10' : '20';
                itCoOpp.GroupInternal = coOpp.GroupInternal__c == true ? '10' : '20';
                itCoOpp.BiddingMethod = coOpp.BiddingMethod__c;
                itCoOpp.AgencyContract = coOpp.AgencyContract__c == true ? 'X' : '';
                itCoOpp.AgencyContractException = coOpp.AgencyContractException__c == true ? 'X' : '';
                itCoOpp.BusinessLevel = coOpp.FinalBusinessLevel__c;
                itCoOpp.Construction = coOpp.Construction__c == true ? 'X' : '';
                itCoOpp.Collaboration = coOpp.Collaboration__c == true ? 'X' : '';
                itCoOpp.CollaborationBOId = coOpp.CollaborationBOId__r.OpportunityCode__c;
                itCoOpp.OpportunityStatus = coOpp.OpportunityStatus__c;
                //V1.2 Start Added By kajal
                if(coOpp.CurrencyIsoCode == 'KRW'){
                    if(coOpp.Opportunity_Review_Biz_Amount__c != null) itCoOpp.Biz_budget_amt = String.valueOf( coOpp.Opportunity_Review_Biz_Amount__c).split('\\.')[0];
                }
                else{

                    if(coOpp.Opportunity_Review_Biz_Amount__c != null) itCoOpp.Biz_budget_amt = coOpp.Opportunity_Review_Biz_Amount__c.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                }
                //V1.2 --end
                input.IS_CO_OPPORT = itCoOpp;

                    
                
                
                //IT_DATE - 2021-02-23 추가 by Soohong.Kim
                //IS_CO_OPPORT
                List<Opportunity_Activity__c> coOppActList = [SELECT id, TransactionName__c, EndDate__c, StartDate__c, Status__c FROM Opportunity_Activity__c WHERE WhatId__c =: coOpp.id order by CreatedDate desc];
                if(coOppActList.size()>0){
                    
                    String ifCoActId = '';
                    for(Opportunity_Activity__c obj : coOppActList){
                        if(obj.Status__c == 'Completed'){
                            ifCoActId = obj.id;
                            break;
                        } 
                    }

                    IT_DATE itCoDate = new IT_DATE();
                    itCoDate.id = coOpp.id;
                    itCoDate.OpportunityActivityID = ifCoActId;
                    itCoDate.CreatedDate = Util_String.convertDateString(coOpp.CreatedDate, 'Asia/Seoul');
                    itCoDate.CloseDate = Util_String.convertDateString(coOpp.CloseDate);
                    itCoDate.cRevenueStartDate = Util_String.convertDateString(coOpp.cRevenueStartDate__c);
                    itCoDate.cRevenueEndDate = Util_String.convertDateString(coOpp.cRevenueEndDate__c);
                    
                    //Oppty 의 Activity TransactionName 의 존재유무에 따라 Activity의 StartDate__c, EndDate__c 로 Date 필드 매핑
                    Map<String,Opportunity_Activity__c> coActDateMap = new Map<String,Opportunity_Activity__c>{
                        'ZP61' => null,
                        'ZP52' => null,
                        'ZPZ1' => null
                    };
                    for(Opportunity_Activity__c obj : coOppActList){
                        coActDateMap.put(obj.TransactionName__c,obj);
                    }
                    if(coActDateMap.get('ZP61') != null) itCoDate.SubmitActualEndDate  = Util_String.convertDateString(coActDateMap.get('ZP61').EndDate__c);
                    if(coActDateMap.get('ZP52') != null) itCoDate.VRBActualStartDate   = Util_String.convertDateString(coActDateMap.get('ZP52').StartDate__c);
                    if(coActDateMap.get('ZP52') != null) itCoDate.VRBActualEndDate     = Util_String.convertDateString(coActDateMap.get('ZP52').EndDate__c);
                    if(coActDateMap.get('ZPZ1') != null) itCoDate.LostActualEndDate    = Util_String.convertDateString(coActDateMap.get('ZPZ1').EndDate__c);
                    itDateList.add(itCoDate);
                }
                // IT_CO_Service
                query = ' SELECT Id, Opportunity__c, Service__r.Code__c, Opportunity__r.OpportunityCode__c, ItemNumber__c, SalesDepartment__r.CostCenter__c, DeliveryDepartment__r.CostCenter__c, DeletionFlag__c ';
                query += ' FROM Service__c ';
                query += ' WHERE Opportunity__c = \''+coOpp.id+'\' AND SendSAP__c = true AND DeletionFlag__c = false ';
                List<Service__c> coServiceList = Database.query(query);
                List<IT_CO_Service> itCoServiceList = new List<IT_CO_Service>();
                for(Service__c obj : coServiceList){
                    IT_CO_Service itCoService = new IT_CO_Service();
                    itCoService.Opportunity = obj.Opportunity__r.OpportunityCode__c;
                    itCoService.ItemNumber = String.valueOf(obj.ItemNumber__c);
                    itCoService.Service = obj.Service__r.Code__c;
                    itCoService.SalesDepartment = obj.SalesDepartment__r.CostCenter__c;
                    itCoService.DeliveryDepartment = obj.DeliveryDepartment__r.CostCenter__c;
                    itCoService.DeletionFlag = obj.DeletionFlag__c == true ? 'X' : '';
                    itCoServiceList.add(itCoService);
                }
                input.IT_CO_Service = itCoServiceList;
            }
            
        
            //IT_DATE - 2021-02-23 추가 by Soohong.Kim
            //IS_OPPORTUNITY
            String ifActId = '';
            for(Opportunity_Activity__c obj : oppActList){
                if(obj.Status__c == 'Completed'){
                    ifActId = obj.id;
                    break;
                }
            }
            IT_DATE itDate = new IT_DATE();
            itDate.id = opp.id;
            itDate.OpportunityActivityID = ifActId;
            itDate.CreatedDate = Util_String.convertDateString(opp.CreatedDate);
            itDate.CloseDate = Util_String.convertDateString(opp.CloseDate);
            itDate.cRevenueStartDate = Util_String.convertDateString(opp.cRevenueStartDate__c);
            itDate.cRevenueEndDate = Util_String.convertDateString(opp.cRevenueEndDate__c);
        
            //Oppty 의 Activity TransactionName 에 따라 Activity의 StartDate__c, EndDate__c 로 Date 필드 매핑
            Map<String,Opportunity_Activity__c> actDateMap = new Map<String,Opportunity_Activity__c>{
                'ZP61' => null,
                'ZP52' => null,
                'ZPZ1' => null
            };
            for(Opportunity_Activity__c obj : oppActList){
                actDateMap.put(obj.TransactionName__c,obj);
            }
            if(actDateMap.get('ZP61') != null) itDate.SubmitActualEndDate  = Util_String.convertDateString(actDateMap.get('ZP61').EndDate__c);
            if(actDateMap.get('ZP52') != null) itDate.VRBActualStartDate   = Util_String.convertDateString(actDateMap.get('ZP52').StartDate__c);
            if(actDateMap.get('ZP52') != null) itDate.VRBActualEndDate     = Util_String.convertDateString(actDateMap.get('ZP52').EndDate__c);
            if(actDateMap.get('ZPZ1') != null) itDate.LostActualEndDate    = Util_String.convertDateString(actDateMap.get('ZPZ1').EndDate__c);
        
            itDateList.add(itDate);

            input.IT_DATE = itDateList;



            // IT_FACTOR 
            query = ' SELECT Id, Factor__c, Name, MultiCode__c ';
            query += ' FROM ApprovalFactor__c ';
            query += ' WHERE approvaltype__r.Type__c = \''+param.factorType+'\' AND isActive__c = true ';
            
            List<ApprovalFactor__c> factorList = Database.query(query);
            List<IT_FACTOR> itFactorList = new List<IT_FACTOR>();
            for(ApprovalFactor__c obj : factorList ){
                IT_FACTOR itFactor =  new IT_FACTOR();
                itFactor.name = obj.Factor__c;
                itFactor.multi = obj.MultiCode__c == true ? 'X' : '';
                itFactorList.add(itFactor);
            }
            
            input.IT_FACTOR = itFactorList;

            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            system.debug('request : '+resMap.get('Request'));
            system.debug('response : '+resMap.get('Response'));

            
            Integer statusCode = Util_String.nvlInt( resMap.get( 'StatusCode'));
            if( statusCode == 200){

                HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.putAll((Map<String,Object>) JSON.deserializeUntyped(res.getBody()));
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
            }else{

                List<String> errorMsgList = new List<String>();
                returnMap.put('StatusCode'  ,statusCode);
                errorMsgList.add('Communication Error : ' + resMap.get('Message') + ' / StatusCode : ' + statusCode);
                ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), errorMsgList);
            }
            returnMap.put('IF_MSG'      ,String.valueOf(resMap.get('IF_MSG')));
            system.debug('returnMap : ' +returnMap);
        
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e);
        }
        log.createLog(ifLog);
        return returnMap;
    }

    public class Param{
        @AuraEnabled
        public String corporationId; // 회사코드(T100)
        @AuraEnabled
        public String opptyId; // Opportunity Id (SFDC)
        @AuraEnabled
        public String actId; // Opportunity Activity Id (SFDC)
        @AuraEnabled
        public String factorType; // Factor 유형 (ApprovalFactor__c 오브젝트의 ApprovalType__r.Type__c 필드)
        @AuraEnabled
        public String userEmpNo; // 사용자 사번
        @AuraEnabled
        public String factor; // 결재 Factor 요청 (X or null)
        @AuraEnabled
        public String pathlist; // 결재라인 요청 (X or null)
        @AuraEnabled
        public String html;     // 결재본문 요청(X or null)
        @AuraEnabled
        public String apInfId;  // 2021.05.31 추가 연계 ID
    }

    public class InputClass{
        @AuraEnabled
        public IS_INPUT IS_INPUT;
        @AuraEnabled
        public IS_OPPORTUNITY IS_OPPORTUNITY ;
        @AuraEnabled
        public IS_ACTIVITY IS_ACTIVITY;
        @AuraEnabled
        public List<IS_ACTIVITY> IT_ACTIVITY_LIST;
        @AuraEnabled
        public List<IT_Service> IT_Service;
        @AuraEnabled
        public List<IT_SOLUTION> IT_SOLUTION;
        @AuraEnabled
        public List<IT_WBS> IT_WBS;
        @AuraEnabled
        public List<IT_Project> IT_Project;
        @AuraEnabled
        public List<IT_DATE> IT_DATE;
        @AuraEnabled
        public IS_CO_OPPORT IS_CO_OPPORT;
        @AuraEnabled
        public List<IT_CO_Service> IT_CO_Service;
        @AuraEnabled
        public List<IT_FACTOR> IT_FACTOR ;
    }
    public class IS_INPUT{
        @AuraEnabled
        public String corporationId; //SAP회사코드T604,T100등
        @AuraEnabled
        public String approvalProcessId; //업무코드
        @AuraEnabled
        public String userEmpNo; //사용자 사번
        @AuraEnabled
        public String draftEmpNo; //상신자 사번 (6272800 등)
        @AuraEnabled
        public String factor; //결재 Factor
        @AuraEnabled
        public String pathlist; //결재라인
        @AuraEnabled
        public String html; //결재본문
        @AuraEnabled
        public String apInfId; // 연계 ID        
    }
    public class IS_OPPORTUNITY {
        @AuraEnabled
        public String Id; //Opportunity ID
        @AuraEnabled
        public String AccountId; //Account
        @AuraEnabled
        public String Name; //Name
        @AuraEnabled
        public String Amount; //Amount
        @AuraEnabled
        public String ExpectedRevenue; //Expected Amount
        @AuraEnabled
        public String CurrencyIsoCode; //Opportunity Currency
        @AuraEnabled
        public String OwnerId; //Owner ID
        @AuraEnabled
        public String SalesDepartment; //Sales Department
        @AuraEnabled
        public String cOriginAcc; //Origin Account
        @AuraEnabled
        public String ActivityStatus; //Activity Status
        @AuraEnabled
        public String cPrimarySalesDepartment; //Primary Delivery Department
        @AuraEnabled
        public String ProposalPM; //Proposal PM
        @AuraEnabled
        public String OpportunityCode; //Opportunity Code
        @AuraEnabled
        public String CompanyCode; //Company Code
        @AuraEnabled
        public String BusinessType; //Business Type
        @AuraEnabled
        public String KoreaDomestic; //Korea Domestic
        @AuraEnabled
        public String GroupInternal; //Group Internal
        @AuraEnabled
        public String BiddingMethod; //Bidding Method
        @AuraEnabled
        public String AgencyContract; //Agency Contract
        @AuraEnabled
        public String AgencyContractException; //Agency Contract Exception
        @AuraEnabled
        public String BusinessLevel; //Business Level
        @AuraEnabled
        public String Construction; //Construction
        @AuraEnabled
        public String Collaboration; //Collaboration
        @AuraEnabled
        public String CollaborationBOId; //Collaboration BO Id
        @AuraEnabled
        public String OpportunityStatus; //Opportunity Status
        
        //@AuraEnabled
        //public String Company; //Company -> 필드 삭제
        @AuraEnabled
        public String Initial_approval; //Activity ZP82의 최초 품의 여부 (Y/N)
        //2021-01-14 추가
        @AuraEnabled
        public String LostReasonLogistics;

        //2021-02-23 추가
        @AuraEnabled
        public String Stage;
        @AuraEnabled
        public String CloseDate;
        @AuraEnabled
        public String cRevenueStartDate;
        @AuraEnabled
        public String cRevenueEndDate;
        @AuraEnabled
        public String SdsAmount;
        @AuraEnabled
        public String SdsCurrency;
        @AuraEnabled
        public String Biz_budget_amt; // V1.2 OpportunityReview Biz type --Added by kajal

    }
    public class IS_ACTIVITY {
        @AuraEnabled
        public String Id; //BO Activity ID
        @AuraEnabled
        public String TransactionName; //BO Activity Name
        @AuraEnabled
        public String WhatId; //Opportunity
        @AuraEnabled
        public String Description; //Description
        @AuraEnabled
        public String DueDate; //Due Date
        @AuraEnabled
        public String ActualStartDate; //Start Date
        @AuraEnabled
        public String ActualEndDate; //End Date
        @AuraEnabled
        public String OwnerId; //Owner
        @AuraEnabled
        public String Status; //Status
        @AuraEnabled
        public String LostReason;
    }
    public class IT_Service {
        @AuraEnabled
        public String Opportunity; //Opportunity
        @AuraEnabled
        public String ItemNumber; //Item Number
        @AuraEnabled
        public String Service; //Service
        @AuraEnabled
        public String SalesDepartment; //Sales Department
        @AuraEnabled
        public String DeliveryDepartment; //Delivery Department
        @AuraEnabled
        public String DeletionFlag; //Deletion Flag
    }
    public class IT_SOLUTION {
        @AuraEnabled
        public String Service; //BO Service
        @AuraEnabled
        public String ItemNumber; //Item Number
        @AuraEnabled
        public String ServiceCode; //Service의 Service Master의 Code
        @AuraEnabled
        public String SolutionCode; //Solution의 Solution Master의 Code
        @AuraEnabled
        public String BizAttribute; //Biz Attribute
        @AuraEnabled
        public String SolutionType; //Solution Type
        @AuraEnabled
        public String SalesType; //Sales Type
        @AuraEnabled
        public String PLCStatus; //PLC Status
        @AuraEnabled
        public String WBSClass; //WBS Class
        @AuraEnabled
        public String BusinessType; //Business Type
        @AuraEnabled
        public String DeletionFlag; //Deletion Flag
        //2021-02-23 추가
        @AuraEnabled
        public String ProjectCodeA;
        @AuraEnabled
        public String ProjectCodeC;
    }
    public class IT_WBS {
        @AuraEnabled
        public String OpportunityID; //Opportunity ID
        @AuraEnabled
        public String ProjectCode; //Project Code
        @AuraEnabled
        public String ProjectCodeOutput; //Project Code Output
        @AuraEnabled
        public String WBSCode; //WBS Code
        @AuraEnabled
        public String SolutionCode; //Solution Code
        @AuraEnabled
        public String ServiceCode; //Service Code
        @AuraEnabled
        public String ItemNumber; //Item Number
        @AuraEnabled
        public String DeletionFlag; //Deletion Flag
        @AuraEnabled
        public String SolutionOwner; //Solution Owner
    }
    public class IT_Project {
        @AuraEnabled
        public String Opportunity; //Opportunity
        @AuraEnabled
        public String ProjectType; //Project Type
        @AuraEnabled
        public String ProjectCode; //Project Code
        @AuraEnabled
        public String Description; //Description
        @AuraEnabled
        public String DeletionFlag; //Deletion Flag
    }
    //2021-02-23 추가
    public class IT_DATE{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String OpportunityActivityID;
        @AuraEnabled
        public String CreatedDate;
        @AuraEnabled
        public String CloseDate;
        @AuraEnabled
        public String cRevenueStartDate;
        @AuraEnabled
        public String cRevenueEndDate;
        @AuraEnabled
        public String SubmitActualEndDate;
        @AuraEnabled
        public String VRBActualStartDate;
        @AuraEnabled
        public String VRBActualEndDate;
        @AuraEnabled
        public String LostActualEndDate;
    }
    public class IS_CO_OPPORT {
        @AuraEnabled
        public String Id; //Opportunity ID
        @AuraEnabled
        public String AccountId; //Account
        @AuraEnabled
        public String Name; //Name
        @AuraEnabled
        public String Amount; //Amount
        @AuraEnabled
        public String ExpectedRevenue; //Expected Amount
        @AuraEnabled
        public String CurrencyIsoCode; //Opportunity Currency
        @AuraEnabled
        public String OwnerId; //Owner ID
        @AuraEnabled
        public String SalesDepartment; //Sales Department
        @AuraEnabled
        public String cOriginAcc; //Origin Account
        @AuraEnabled
        public String ActivityStatus; //Activity Status
        @AuraEnabled
        public String cPrimarySalesDepartment; //Primary Delivery Department
        @AuraEnabled
        public String ProposalPM; //Proposal PM
        @AuraEnabled
        public String OpportunityCode; //Opportunity Code
        @AuraEnabled
        public String CompanyCode; //Company Code
        @AuraEnabled
        public String BusinessType; //Business Type
        @AuraEnabled
        public String KoreaDomestic; //Korea Domestic
        @AuraEnabled
        public String GroupInternal; //Group Internal
        @AuraEnabled
        public String BiddingMethod; //Bidding Method
        @AuraEnabled
        public String AgencyContract; //Agency Contract
        @AuraEnabled
        public String AgencyContractException; //Agency Contract Exception
        @AuraEnabled
        public String BusinessLevel; //Business Level
        @AuraEnabled
        public String Construction; //Construction
        @AuraEnabled
        public String Collaboration; //Collaboration
        @AuraEnabled
        public String CollaborationBOId; //Collaboration BO Id
        @AuraEnabled
        public String OpportunityStatus; //Opportunity Status
        @AuraEnabled
        public String Company; //Company
        //2021-02-23 추가
        @AuraEnabled
        public String Stage;
        @AuraEnabled
        public String Biz_budget_amt; // V1.2 OpportunityReview Biz type --Added by kajal
    }
    public class IT_CO_Service{
        @AuraEnabled
        public String Opportunity; //Opportunity
        @AuraEnabled
        public String ItemNumber; //Item Number
        @AuraEnabled
        public String Service; //Service
        @AuraEnabled
        public String SalesDepartment; //Sales Department
        @AuraEnabled
        public String DeliveryDepartment; //Delivery Department
        @AuraEnabled
        public String DeletionFlag; //Deletion Flag
    }
    public class IT_FACTOR {
        @AuraEnabled
        public String name; //FACTOR NAME
        @AuraEnabled
        public String value; //FACTOR VALUE
        @AuraEnabled
        public String multi; //Multi Factor
    }
}