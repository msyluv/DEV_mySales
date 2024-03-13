@isTest
public class ServiceSolutionMig_Test {
    static Master_Service__c master_service;
    static Master_Solution__c master_solution;
    static BizAttribute__c master_attribute;
    static CostCenter__c costCenter;
    static SvcSolBizAttr__c svcSolBizAttr;
    
    static Company__c compnay;
    static Account account;
    static User user;
    static Employee__c emp;

    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct;
    static Service__c service, service_del;
    static Solution__c solution;

    static{

        MasterActivity__c mastrtAct1_HQ = new MasterActivity__c(
            TransactionName__c=Utils.getPicklistOptionType('MasterActivity__c','TransactionName__c')[0].get('value')
            , Stage__c='Z01',Order__c=1
            , IsRequiredKnoxApproval__c=false
            , Position__c='1',IsImportant__c=true,IsRequired__c=true
            , ObjectApiName__c='Opportunity',IsActive__c=true,Type__c='HQ'
        );
        insert mastrtAct1_HQ;


        costCenter = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-11331'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
        );
        insert costCenter;

        compnay = new Company__c (
            Name                = 'T100 - Name'
            , CompanyCode__c    = 'T100'
            , EPCompanyCode__c  = 'EP1'
            , CurrencyIsoCode   = 'KRW'
            , Country__c        = 'Korea, Republic of'
        );
        insert compnay;

        account = new Account(
            Name = 'Test Account',
            AccountNumber = '123123',
            MDGCheck__c = true
        );
        insert account;

        Profile p = [SELECT id FROM Profile WHERE name = 'System Administrator' OR name = '시스템 관리자'];
        user = new User(
            Alias = 'standt1', Email='user0001@ss-sds.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='ko_KR', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
            UserName='user0001@ss-sds.com', Division = 'TW',
            EmployeeNumber = '123455'
        );
        insert user;

        emp = new Employee__c(
            Name = 'Test Emp',
            EvMailAddr__c = 'logiUser' + '@samsung.com',
            EvUniqID__c = 'epId2',            
            EvEmpNO__c = '123454'
        );
        insert emp;

        Date today = System.today();
        Date revenueStartDate = today.addDays(1);
        Date revenueEndDate = today.addDays(10);
        oppty = new Opportunity(
            Name = 'Test Oppty',
            CloseDate = System.today(),
            StageName = 'Z01',
            SalesDepartment__c = costCenter.Id,
            cPrimarySalesDepartment__c = costCenter.Id,
            OpportunityCode__c = 'SDS-20191510',
            cOriginAcc__c = account.Id,
            ProposalPM__c = emp.Id,
            BusinessLevel__c = 'C',
            cRevenueStartDate__c = revenueStartDate,
            cRevenueEndDate__c = revenueEndDate,
            BiddingMethod__c = 'BID001',
            Amount = 11000
        );
        insert oppty;

        Date firstDayOfMonth = System.today().toStartOfMonth();
        Date lastDayOfMonth = firstDayOfMonth.addDays(Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month()) - 1);
        opptyAct = new Opportunity_Activity__c(
            ExtID__c = oppty.Id + '_ZP21',
            WhatId__c = oppty.Id,
            StartDate__c = firstDayOfMonth,
            EndDate__c = lastDayOfMonth
        );
        insert opptyAct;
        
        master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000026'
        );
        insert master_service;

        master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;

        master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S109'
        );
        insert master_attribute;

        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            Use__c = true
        );
        insert svcSolBizAttr;

        service = new Service__c(
            Opportunity__c = oppty.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service;

        service_del = new Service__c(
            Opportunity__c = oppty.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 20,
            Changed__c = true,
            SendSAP__c = true,
            sDeletionFlag__c = true
        );
        insert service_del;

        solution = new Solution__c(
            Opportunity__c = oppty.Id,
            Service__c = service.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
            );
        insert solution;

        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c( 
                Status__c= 'In Progress'
                , DueDate__c=System.today()
                , TransactionName__c=OpportunityActivityHelper.ACT_CODE_REVIEW_BO
                , WhatId__c=oppty.Id);

        insert opptyAct;
    }
    
    @isTest
    public static void test_method_01(){
        ServiceSolutionMig.saveMigData(oppty.Id, '{"ET_MESSAGE": [{"TYPE": "S","MESSAGE": "Success","LOG_NO": null,"LOG_MSG_NO": "000000","MESSAGE_V1": null,"MESSAGE_V2": null,"MESSAGE_V3": null,"MESSAGE_V4": null,"PARAMETER": null,"ROW": 0,"FIELD": null,"SYSTEM": null}], "ET_WBS_INFO": [{"PSPID": "SMC21197281A000","PSPID_OUTPUT": "SMC-21197281-A0","POSID": "SMC21197281A000","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000000","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": null},{"PSPID": "SMC21197281A000","PSPID_OUTPUT": "SMC-21197281-A0","POSID": "SMC21197281A001","ZZSOLUTION": null,"SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMC21197281A000","PSPID_OUTPUT": "SMC-21197281-A0","POSID": "SMC21197281A00111","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMC21197281A000","PSPID_OUTPUT": "SMC-21197281-A0","POSID": "SMC21197281A00121","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMC21197281A000","PSPID_OUTPUT": "SMC-21197281-A0","POSID": "SMC21197281A00131","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMA21197281A000","PSPID_OUTPUT": "SMA-21197281-A0","POSID": "SMA21197281A000","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000000","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": null},{"PSPID": "SMA21197281A000","PSPID_OUTPUT": "SMA-21197281-A0","POSID": "SMA21197281A001","ZZSOLUTION": null,"SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMA21197281A000","PSPID_OUTPUT": "SMA-21197281-A0","POSID": "SMA21197281A00111","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMA21197281A000","PSPID_OUTPUT": "SMA-21197281-A0","POSID": "SMA21197281A00121","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"},{"PSPID": "SMA21197281A000","PSPID_OUTPUT": "SMA-21197281-A0","POSID": "SMA21197281A00131","ZZSOLUTION": "30000032","SERVICE": "20000012","NUMBER_INT": "0000000010","LOEVM": null,"SOLUTION_OWNER": "T100-11975","ZZORDER_TYPE_S": "S135"}],"ET_PJT_CODE_A": ["SMA21197281A000"],"ET_PJT_CODE_C": ["SMC21197281A000"]}');
    }
}