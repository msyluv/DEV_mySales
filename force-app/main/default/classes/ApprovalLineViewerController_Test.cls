@isTest
private class ApprovalLineViewerController_Test {
    static User user;
    static Employee__c emp;
    static Employee__c pathlist_emp1;
    static Employee__c pathlist_emp2;
    static Employee__c pathlist_emp3;
    static Account mdgAcc;
    static Company__c comp;
    static CostCenter__c cc;
    static Opportunity oppty;
    static Opportunity_Activity__c opptyAct1;
    static Opportunity_Activity__c opptyAct2;

    static{
        user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs (admin) {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
			list<User> userList = new list<User>();
			user = new User(Alias = 'standt1', Email='user0001@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0001@samsung.com', FederationIdentifier='16241');
			insert user;
        }

        List<Employee__c> empList = new List<Employee__c>();
        emp = Utils_TestDataFactory.createEmployee('TestEmp1', 'EPID1');
        emp.EvUniqID__c    = '16241';
        emp.EvSapBukrs__c  = 'T100';
        emp.EvAcubeID__c = 'SDS123';
        update emp;

        pathlist_emp1 = new Employee__c(
            Name = '김원만',
            EvUniqID__c = '16241',
            EvEmpNO__c = '12354',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '1',
            EvAcubeID__c = 'SDS123'
        );
        empList.add(pathlist_emp1);

        pathlist_emp2 = new Employee__c(
            Name = '이승준',
            EvUniqID__c = 'C6031379',
            EvEmpNO__c = '31379',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '1',
            EvAcubeID__c = 'SDS125'
        );
        empList.add(pathlist_emp2);

        pathlist_emp3 = new Employee__c(
            Name = '허용석',
            EvUniqID__c = 'C6017093',
            EvEmpNO__c = '17093',
            EvSapBukrs__c = 'T100',
            EvStatus__c = '6',
            EvAcubeID__c = 'SDS126'
        );
        empList.add(pathlist_emp3);

        insert empList;

		RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        mdgAcc = new Account(
			Name = 'Test MDG Account',
            AccountNumber = 'M1234567',
            mDomesticForeign__c = '20',
            mCountry__c = 'US',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
       	);
        insert mdgAcc;
        
        comp = new Company__c(
            Name = 'Test Company',
            CompanyCode__c = 'T100'
        );
        insert comp;
        
        cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Text2__c = '테스트'
        );
        insert cc;
        
        RecordType hqRcdType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        oppty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            StageName = 'Z01', 
            AccountId = mdgAcc.Id, 
            OwnerId = user.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            CloseDate = Date.today(),
            OpportunityCode__c = 'SDS-21123450'
        );
        insert oppty;

        List<Opportunity_Activity__c> opptyActList = new List<Opportunity_Activity__c>();
        opptyAct1 = new Opportunity_Activity__c(
            WhatId__c = oppty.id,
            TransactionName__c = 'ZP32',
            ExtId__c = oppty.id + '_ZP32',
            StartDate__c = Date.today(),
            EndDate__c = Date.today(),
            DueDate__c = Date.today()
        );
        opptyActList.add(opptyAct1);

        opptyAct2 = new Opportunity_Activity__c(
            WhatId__c = oppty.id,
            TransactionName__c = 'ZP82',
            ExtId__c = oppty.id + '_ZP82',
            StartDate__c = Date.today(),
            EndDate__c = Date.today(),
            DueDate__c = Date.today()
        );
        opptyActList.add(opptyAct2);

        insert opptyActList;
    }

	@isTest static void test_method_1() {
        Test.startTest();
        ApprovalLineViewerController.defaultSetting();
        Test.stopTest();
    }

    @isTest static void test_method_2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        ApprovalLineViewerController.getKnoxApproval(oppty.OpportunityCode__c, 'preSales');
        Test.stopTest();
    }

    @isTest static void test_method_3() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        ApprovalLineViewerController.getKnoxApproval(oppty.OpportunityCode__c, 'contract');
        Test.stopTest();
    }

    @isTest static void test_method_4() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new IF_Callout_TestMock());
        ApprovalLineViewerController.getKnoxApproval(oppty.OpportunityCode__c, 'contractChange');
        ApprovalLineViewerController.dummyMethod();
        Test.stopTest();
    }
}