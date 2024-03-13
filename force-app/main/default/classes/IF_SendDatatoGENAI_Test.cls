/**
* @description       : Test Class (IF-200)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-01-05 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-01-05   vikrant.ks@samsung.com   Initial Version(MySales 400)
**/
@isTest
public class IF_SendDatatoGENAI_Test {
    
    final static String REQUEST_URL = '/services/apexrest/IF200';
    private static Boolean isSandbox = Utils.getIsSandbox();
    
    @TestSetup
    static void setData(){        
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
            mDomesticForeign__c = '20',
            mBizTypeL1Code__c = 'L200',
            mBizTypeL2Code__c = 'L202'
            
        );
        insert acc;
        Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        DateTime dt = DateTime.now().addDays(-6);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        Opportunity opptyHQ3 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().adddays(-5),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z03',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            BusinessLevel__c = 'S'
            //       CMBizType__c = 'CSP_SCP'
        );
        Opportunity oppcloned;
        Opportunity oppcloned1; 
        Company__c cmp = new Company__c(
            Name = 'comp',
            CompanyCode__c = 'T100'
        );
        insert cmp;
        Employee__c emp = new Employee__c(
            Name = 'testUser',
            EvMailAddr__c = 'SysAdminTestuser@samsung.com',
            EvUniqID__c = 'k123456789',
            Knox_Id__c = 'knoxId5',
            EvKostl__c = 'T604-11331'
        );
        insert emp;
        
        CostCenter__c costCenter1 = new CostCenter__c(
            Name                = '기술전략팀(T604-11331)'
            , DeptManager__c    = emp.Id
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , Company__c = cmp.Id
            , CostCenter__c     = 'T604-11331'
            , Node1__c          = 'T604'
            , Node2__c          = 'T604SB'
            , Node3__c          = 'T604SB1'
            , Node4__c          = 'T604SB13'
            , Node5__c          = 'T604SB131'
            , ZZCheck__c = true
        );
        insert costCenter1; 
        opptyHQ3.RecordTypeId = HQRecId;
        opptyHQ3.SalesOrganization__c = org.id;
        opptyHQ3.amount=1356;
        opptyHQ3.SalesDepartment__c = costCenter1.Id;
        
        insert opptyHQ3;
        
        oppcloned= new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = HQRecId,
            OpportunityCode__c='SDS-22131801',
            SalesOrganization__c = org.id,
            amount=1356,
            SalesDepartment__c = costCenter1.Id,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().addyears(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z03',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            BusinessLevel__c = 'S'
            //         CompanyCode__c = 'T100'
            //       CMBizType__c = 'CSP_SCP'
        );
        oppcloned1= new Opportunity(
            Name = 'Test Opportunity1',
            RecordTypeId = HQRecId,
            OpportunityCode__c='SDS-22131801',
            SalesOrganization__c = org.id,
            amount=100000,
            SalesDepartment__c = costCenter1.Id,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today().addyears(-2),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z03',
            XP7_CONDUCT_DATE__c =Date.today().adddays(2),
            XP6_CONDUCT_DATE__c=Date.today().adddays(2),
            BusinessLevel__c = 'S'
            //         CompanyCode__c = 'T100'
            //       CMBizType__c = 'CSP_SCP'
        );
        
        insert oppcloned;
        insert oppcloned1;
        CostCenter__c invalidCC = new CostCenter__c(
            Name = 'Test Cost Center', CurrencyIsoCode = 'KRW', CompanyCode__c = 'T100', 
            CostCenterName__c = 'Test Cost Center', CostCenter__c = 'T100-11332', Node1__c = 'T100', 
            Node2__c = 'T100SB', Node3__c = 'T100SB1', Node4__c = 'T100SB13', Node5__c = 'T100SB131', 
            ClosingDate__c = System.today().addDays(2), ZZCheck__c = false
        );
        insert invalidCC;
        
        Master_Service__c master_service = new Master_Service__c(
            Name = 'Test Master Service',
            Code__c = '20000024'
        );
        insert master_service;
        
        Master_Solution__c master_solution = new Master_Solution__c(
            Name = 'Test Master Solution',
            Code__c = '30000135'
        );
        insert master_solution;
        
        BizAttribute__c master_attribute = new BizAttribute__c(
            Name = 'Test Master Attribute',
            Code__c = 'S109'
        );
        insert master_attribute;
        CostCenter__c costCenter = new CostCenter__c(
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
        SvcSolBizAttr__c svcSolBizAttr =  new SvcSolBizAttr__c(
            BizAttribute__c = master_attribute.Id,
            BusinessType__c = 'TI',
            Solution__c = master_solution.Id,
            WBSClass__c = 'SM',
            PSType__c = 'SM1',
            Use__c = true
        );
        insert svcSolBizAttr;
        
        
        Service__c service = new Service__c(
            Opportunity__c = opptyHQ3.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service;
        Solution__c solution = new Solution__c(
            Opportunity__c = opptyHQ3.Id,
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
        
        Service__c service1 = new Service__c(
            Opportunity__c = oppcloned.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service1;
        Solution__c solution1 = new Solution__c(
            Opportunity__c = oppcloned.Id,
            Service__c = service1.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert solution1;
        
        Service__c service2 = new Service__c(
            Opportunity__c = oppcloned.Id,
            sService__c = master_service.Id,
            sDeliveryDepartment__c = costCenter.Id,
            sSalesDepartment__c  = costCenter.Id,
            ItemNumber__c = 10,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert service2;
        Solution__c solution2 = new Solution__c(
            Opportunity__c = oppcloned.Id,
            Service__c = service1.Id,
            sBizAttribute__c = master_attribute.Id,
            sSolution__c = master_solution.Id,
            sPSType__c = svcSolBizAttr.PsType__c,
            sWBSClass__c = svcSolBizAttr.WBSClass__c,
            sBusinessType__c = svcSolBizAttr.BusinessType__c,
            Changed__c = true,
            sDeletionFlag__c = false
        );
        insert solution2;
        
        String oppId = (String)opptyHQ3.Id;
        
        Opportunity oppt1=[select id, companycode__c,RecordType.Name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,closedate from opportunity where id =: opptyHQ3.Id];
        system.debug('Ashish Test class oppt1::::'+oppt1);
        
        Opportunity oppt=[select id, companycode__c,RecordType.Name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,closedate from opportunity where id =: oppcloned.Id];
        system.debug('Ashish Test class oppt::::'+oppt);
        
        Map<Id,Opportunity> matchedoppLst = new Map<Id,Opportunity>([Select Id, companycode__c,OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,Opportunity_Review_Confirm__c, (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c='ZP61' and status__c='Completed') , ProposalPM__c,RepresentativePM__c,ProposalPM__r.name,RepresentativePM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c,BusinessLevel__c,name,closedate,convertcurrency(amount),StageName,toLabel(StageName) toLabel_StageName From Opportunity where   BusinessLevel__c ='S'  and RecordType.Name = 'HQ'   and CompanyCode__c = 'T100' and  id in (SELECT opportunity__c from service__c where sService__r.Name in ('Test Master Service')  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in ('Test Master Solution')  AND sDeletionFlag__c = false) LIMIT 50000]); //and closedate = LAST_N_YEARS:5  RecordType.Name = 'HQ' and CompanyCode__c = 'T100' and and id in (SELECT opportunity__c from service__c where sService__r.Name in ('Test Master Service')  AND sDeletionFlag__c = false) and id in (SELECT opportunity__c from solution__c where sSolution__r.Name in ('Test Master Solution')  AND sDeletionFlag__c = false)
        system.debug('Ashish Test class::::'+matchedoppLst);
        
        Opportunity opptyHQ = new Opportunity(
            Name = 'Test Opportunity',
            OpportunityCode__c='SDS-12345678',
            //        RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            //AccountId = acc.Id,
            cLeadID__c = NULL,
            BO1stRegistrationDate__c = dt
            //           StageName = 'Z05'
        );
        insert opptyHQ;
    }
    @isTest
    public static void TestMethod1(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='{"Opportunitycode":"SDS-22131801"}';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod2(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='{}';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod3(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='{"Opportunitycode":""}';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod4(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='{"Opportunitycode":"SDS-2201"}';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod5(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='[{"Opportunitycode":"SDS-22012345678901"},{"Opportunitycode":"SDS-22012345678901"}]';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
    @isTest
    public static void TestMethod6(){
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;   
        request.httpMethod = 'POST';
        
        String reqeustBody ='{"Opportunitycode":"SDS-12345678"}';
        request.requestBody = Blob.valueOf(reqeustBody);
        RestContext.request  = request;
        RestContext.response = response;
        
        try {
            
            IF_SendDatatoGENAI.SendDatatoGENAI();
            
        } catch (Exception e) {
            system.debug(e);
        }        
        Test.stopTest();
    }
}