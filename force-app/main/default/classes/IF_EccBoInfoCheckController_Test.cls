/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-10
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-28   ghkil@partner.samsung.com   Initial Version
 * 1.1   2021-02-04   ghkil@partner.samsung.com   정의서 2.4일 기준으로 변경 적용
 * 1.2   2021-02-04   ghkil@partner.samsung.com   정의서 2.8일 기준으로 항목 추가
 * 1.3   2023-12-14   atul.k1@samsung.com         IF-038 Modification related to billing authority (MYSALES-368)
**/
@isTest
public class IF_EccBoInfoCheckController_Test {
    
    // IF_EccBoInfoCheckController 테스트 클래스
    // INTERFACE_ID = 'IF-038';
    // APEX_CLASS   = 'IF_EccBoInfoCheckController';
    // METHOD_NAME  = 'getBoInfoCheck';

    final static String REQUEST_URL = '/services/apexrest/WebService/IF038';
    //V 1.3 Start
     static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    //V 1.3 End
    public IF_EccBoInfoCheckController_Test() {    }

    @TestSetup
    static void makeData(){
      
    }

    @isTest
    static void testTeamMemberRead() {
        Test.startTest();

        User salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , 'sales111@sales.com'
                , 'sales111_epid1');

        // System.runAs(salesRepHqUser1){
            IF_Callout_TestDataSetup.dataSetup();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = REQUEST_URL;
            request.httpMethod = 'POST';

            List<User> userInfo = [
                Select  Id
                        , EmployeeNumber
                From    User
                Where   UserName = 'sales111@sales.com'
            ];

            List<Opportunity> opportunityInfo = [
                Select  Id
                        , OpportunityCode__c
                        , CompanyCode__c
                From    Opportunity
            ];

            OpportunityTeamMember insertOpportunityTeamMember = new OpportunityTeamMember(
                UserId = userInfo[0].Id
                , OpportunityId = opportunityInfo[0].Id
                , OpportunityAccessLevel = 'Read'
            );
            Insert insertOpportunityTeamMember;

            system.debug('insertOpportunityTeamMember : ' + insertOpportunityTeamMember);

            String reqeustBody =    '{ ' +
                                    '   "IT_BO":[ ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "' + userInfo[0].EmployeeNumber + '", ' +
                                    '            "IV_ORDERID" : "' + opportunityInfo[0].OpportunityCode__c + '", ' +
                                    '            "IV_BUKS" : "' + opportunityInfo[0].CompanyCode__c + '" ' +
                                    '       } ' +
                                    '   ] ' +
                                    '}';

            request.requestBody = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        // }
        Test.stopTest();
    }

    @isTest
    static void testTeamMemberAll() {
        Test.startTest();

        User salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , 'sales111@sales.com'
                , 'sales111_epid1');

        // System.runAs(salesRepHqUser1){
            IF_Callout_TestDataSetup.dataSetup();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = REQUEST_URL;
            request.httpMethod = 'POST';

            List<User> userInfo = [
                Select  Id
                        , EmployeeNumber
                From    User
                Where   UserName = 'sales111@sales.com'
            ];

            List<Opportunity> opportunityInfo = [
                Select  Id
                        , OpportunityCode__c
                        , CompanyCode__c
                From    Opportunity
            ];

            OpportunityTeamMember insertOpportunityTeamMember = new OpportunityTeamMember(
                UserId = userInfo[0].Id
                , OpportunityId = opportunityInfo[0].Id
                , OpportunityAccessLevel = 'All'
            );
            Insert insertOpportunityTeamMember;

            system.debug('insertOpportunityTeamMember : ' + insertOpportunityTeamMember);

            String reqeustBody =    '{ ' +
                                    '   "IT_BO":[ ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "' + userInfo[0].EmployeeNumber + '", ' +
                                    '            "IV_ORDERID" : "' + opportunityInfo[0].OpportunityCode__c + '", ' +
                                    '            "IV_BUKS" : "' + opportunityInfo[0].CompanyCode__c + '" ' +
                                    '       } ' +
                                    '   ] ' +
                                    '}';

            request.requestBody = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        // }
        Test.stopTest();
    }

    @isTest
    static void testOwner() {
        Test.startTest();

        User salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
                , 'sales111@sales.com'
                , 'sales111_epid1');

        // System.runAs(salesRepHqUser1){
            IF_Callout_TestDataSetup.dataSetup();

            RestRequest request     = new RestRequest();
            RestResponse response   = new RestResponse();
            request.requestURI      = REQUEST_URL;
            request.httpMethod      = 'POST';

            List<User> userInfo = [
                Select  Id
                        , EmployeeNumber
                From    User
                Where   Id = :salesRepHqUser1.Id
            ];

            List<Opportunity> opportunityInfo = [
                Select  Id
                        , OpportunityCode__c
                        , CompanyCode__c
                        , Owner.UserName
                        , Owner.EmployeeNumber
                From    Opportunity
            ];

            String reqeustBody =    '{ ' +
                                    '   "IT_BO":[ ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "' + userInfo[0].EmployeeNumber + '", ' +
                                    '            "IV_ORDERID" : "' + opportunityInfo[0].OpportunityCode__c + '", ' +
                                    '            "IV_BUKS" : "' + opportunityInfo[0].CompanyCode__c + '" ' +
                                    '       } ' +
                                    '   ] ' +
                                    '}';

            request.requestBody  = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        // }
        Test.stopTest();
    }

    @isTest
    static void testAdmin() {
        Test.startTest();

        Profile pf = [SELECT Id FROM Profile WHERE Name IN ('System Administrator', '시스템 관리자') ];
                                
        User adminUser1 = Utils_TestDataFactory.createUser(pf);                

        User salesRepHqUser1 = Utils_TestDataFactory.createUserFull(
            Utils_TestDataFactory.getProfile('Sales Rep.(HQ)')
            , 'sales111@sales.com'
            , 'sales111_epid1');

        salesRepHqUser1.EmployeeNumber = 'Sales00001';
        update salesRepHqUser1;

        // System.runAs(salesRepHqUser1){
        System.runAs(adminUser1){            

            IF_Callout_TestDataSetup.dataSetup();

            RestRequest request     = new RestRequest();
            RestResponse response   = new RestResponse();
            request.requestURI      = REQUEST_URL;
            request.httpMethod      = 'POST';

            List<User> userInfo = [
                Select  Id
                      , EmployeeNumber
                From    User
                Where  Id = :adminUser1.Id
            ];

            List<Opportunity> opportunityInfo = [
                Select  Id
                        , OpportunityCode__c
                        , CompanyCode__c
                        , OwnerId
                        , Owner.UserName
                        , Owner.EmployeeNumber
                From    Opportunity
            ];

            String reqeustBody =    '{ ' +
                                    '   "IT_BO":[ ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "' + userInfo[0].EmployeeNumber + '", ' +
                                    '            "IV_ORDERID" : "' + opportunityInfo[0].OpportunityCode__c + '", ' +
                                    '            "IV_BUKS" : "' + opportunityInfo[0].CompanyCode__c + '" ' +
                                    '       } ' +
                                    '   ] ' +
                                    '}';

            request.requestBody  = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        }
        Test.stopTest();
    }

    @isTest
    static void testDataList() {
        Test.startTest();

        User adminUser2 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Support(HQ)')
                , 'admin222@admin.com'
                , 'admin222_epid1');
        //V 1.3 Start
        adminUser2.EmployeeNumber = '6754111';
        update adminUser2;
        // List<Account> accList = new List<Account>();
        /*Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true
        );
        insert acc;*/
        
     Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        
        Account acc = new Account( 
            Name = 'Test Account',
            MDGCheck__c = true,
            mDomesticForeign__c = '20'
        );
        insert acc;
        //wrapper insert
        
        //      Id HQRecId =  Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('HQ').getRecordTypeId(); //Schema.getGlobalDescribe().get('Opportunity').getDescribe().getRecordTypeInfosByName().get('HQ').getRecordTypeId();
        DateTime dt = DateTime.now().addDays(-7);
        
        Organization__c org = new Organization__c(name='SDSAE');
        insert org;
        Opportunity opptyHQ1 = new Opportunity(
            Name = 'Test Opportunity',
            //        RecordTypeId = HQRecId,
            SalesOrganization__c = org.id,
            amount=1356,
            //ProposalPM_User__c = migUser.Id, //Anish v-1.2
            MigData__c = True,  //Anish v-1.2
            //StageName = OpportunityActivityHelper.OPP_STAGE_IDENTIFIED,
            CloseDate = Date.today(),
            AccountId = acc.Id,
            cLeadID__c = NULL,
            ownerid = adminUser2.id,
            BO1stRegistrationDate__c = dt,
            StageName = 'Z05'
        );
      //  system.runAs(ulist[0]){
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
            opptyHQ1.RecordTypeId = HQRecId;
            opptyHQ1.SalesOrganization__c = org.id;
            opptyHQ1.amount=1356;
            opptyHQ1.SalesDepartment__c = costCenter1.Id;
            insert opptyHQ1;
      OpportunityTeamMember  opptyTeamMember = new OpportunityTeamMember(
            OpportunityId = opptyHQ1.Id,
            UserId = adminUser2.Id,
            //Name = 'TestEmp1',
            TeamMemberRole = 'Proposal PM'
        );
		
        insert opptyTeamMember;
        //V 1.3 End

        System.runAs(adminUser2){
            // IF_Callout_TestDataSetup.dataSetup();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = REQUEST_URL;
            request.httpMethod = 'POST';
            //V 1.3 Start
            List<Opportunity> opportunityInfo1 = [
                Select  Id
                        , OpportunityCode__c
                        , CompanyCode__c
                        , OwnerId
                        , Owner.UserName
                        , Owner.EmployeeNumber
                From    Opportunity where Name = 'Test Opportunity' LIMIt 1
            ];
            
            String reqeustBody =    '{ ' +
                                    '   "IT_BO":[ ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "06754111", ' +
                                    '            "IV_ORDERID" : "' + opportunityInfo1[0].OpportunityCode__c + '", ' +
                                    '            "IV_BUKS" : "T100" ' +
                                    '       }, ' +
                                    '       { ' +
                                    '            "IV_EMPLOYEE_NO": "22222", ' +
                                    '            "IV_ORDERID" : "22222", ' +
                                    '            "IV_BUKS" : "22222" ' +
                                    '       } ' +                                    
                                    '   ] ' +            
                                    '}';
            //V 1.3 End
            request.requestBody = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        }
        Test.stopTest();
    }

    @isTest
    static void testNoBody() {
        Test.startTest();

        User adminUser2 = Utils_TestDataFactory.createUserFull(
                Utils_TestDataFactory.getProfile('Sales Support(HQ)')
                , 'admin222@admin.com'
                , 'admin222_epid1');

        System.runAs(adminUser2){
            // IF_Callout_TestDataSetup.dataSetup();

            RestRequest request = new RestRequest();
            RestResponse response = new RestResponse();
            request.requestURI = REQUEST_URL;
            request.httpMethod = 'POST';

            String reqeustBody =    '{ ' +
                                    '}';

            request.requestBody = Blob.valueOf(reqeustBody);
            RestContext.request  = request;
            RestContext.response = response;
        
            try {

                IF_EccBoInfoCheckController.getBoInfoCheck();

            } catch (Exception e) {
                system.debug(e);
            }        
        }
        Test.stopTest();
    }
}