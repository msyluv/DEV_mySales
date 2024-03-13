/**
* @description       : This is an Apex Test ClassClass that runs in order to  cover GroupHierarchyBOInfo. 
* @author            : rakshit.s@samsung.com
* @group             : 
* @date created  : 03-06-2023
* @last modified on : 05-18-2023
* @last modified by  : rakshit.s@samsung.com
* @Version: V1.0 (Initial Development)
* @version V2.0 Ability to send emails to multiple leaders (upto 10).
**/
@isTest
private class GroupHierarchyBOInfoTest {
    static User user;
    static User user2;
    static User user3;
    static Employee__c emp1;
    static CostCenter__c costCenterHQ;
    static CostCenter__c costCenterHQ2;
    static CostCenter__c costCenterHQ3;
    static CostCenter__c costCenterHQ4;
    static CostCenter__c costCenterHQ5;
    @testSetup static void setup() {
        
        
        costCenterHQ = new CostCenter__c(
            Name                = '기술전략팀(T100-11331)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-12579'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
        );
        insert costCenterHQ;
        
        costCenterHQ2 = new CostCenter__c(
            Name                = '기술전략팀(T100-11330)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-12346'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
        );
        insert costCenterHQ2;
        
        costCenterHQ3 = new CostCenter__c(
            Name                = 'aa기술전략팀(T100-11332)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = 'aa기술전략팀'
            , CostCenter__c     = 'T100-12345'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
        );
        insert costCenterHQ3;
        
        costCenterHQ4 = new CostCenter__c(
            Name                = '기술전략팀(T100-11333)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = '기술전략팀'
            , CostCenter__c     = 'T100-12347'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
        );
        insert costCenterHQ4;
        
        costCenterHQ5 = new CostCenter__c(
            Name                = 'ab기술전략팀(T100-11334)'
            , CurrencyIsoCode   = 'KRW'
            , CompanyCode__c    = 'T100'
            , CostCenterName__c = 'ab기술전략팀'
            , CostCenter__c     = 'T100-12349'
            , Node1__c          = 'T100'
            , Node2__c          = 'T100SB'
            , Node3__c          = 'T100SB1'
            , Node4__c          = 'T100SB13'
            , Node5__c          = 'T100SB131'            
            , ZZCheck__c        = true
        );
        insert costCenterHQ5;
        
        emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'rakshit.s');
        Account acc = new account(); 
        acc = Utils_TestDataFactory.createAccount('sample');
        //group_hierarchy__c gh = new group_hierarchy__c();
        //Utils_TestDataFactory.createOpportunity('testOpp' , acc.id);
        
        
        Profile pf = [SELECT Id,name FROM Profile where id='00e2w000002RvtEAAS'];
        Contact c = new Contact(LastName = 'Test', AccountId = acc.id);
        insert c;        
        user = new User(Alias = 'Test', Email='Testgroup@Test.com', 
                        EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                        LocaleSidKey='en_US', ProfileId = pf.Id, TimeZoneSidKey='Asia/Seoul',
                        EvKostl__c='T100-12345',
                        UserName='user0001@samsung.com');
        Insert user;
        
        user2 = new User(Alias = 'Test', Email='Testgroup@Test.com', 
                         EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = pf.Id, TimeZoneSidKey='Asia/Seoul',
                         EvKostl__c='T100-12346',
                         UserName='user0001aa@samsung.com');
        Insert user2;
        
        user3 = new User(Alias = 'Test', Email='Testgroup@Test.com', 
                         EmailEncodingKey='UTF-8', LastName='Test', FirstName='Test', LanguageLocaleKey='en_US', 
                         LocaleSidKey='en_US', ProfileId = pf.Id, TimeZoneSidKey='Asia/Seoul',
                         EvKostl__c='T100-12347',
                         UserName='userss0001aa@samsung.com');
        Insert user3;
        // system.debug('userinserteed' + user);
        System.runAs(user){
            Opportunity op = new opportunity();
            
            op.CloseDate = Date.today().addDays(6);
            op.Name = 'sample';
            op.StageName  = 'Z02';
            op.owner = user;
            // op.owner.EvKostl__c = 'T100-12345';
            insert op;
            //system.debug('opportunity inserted-->' + op.owner.EvKostl__c);
            Opportunity op1 = new opportunity();
            
            op1.CloseDate = Date.today().addDays(-10);
            op1.Name = 'sample';
            op1.StageName  = 'Z03';
            op1.owner = user;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op1;
            
            Opportunity op2 = new opportunity();
            
            op2.CloseDate = Date.today().addDays(-13);
            op2.Name = 'sample';
            op2.StageName  = 'Z04';
            op2.owner = user;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op2;
        }
        
        system.runAs(user2){
            Opportunity op3 = new opportunity();
            
            op3.CloseDate = Date.today().addDays(-13);
            op3.Name = 'sample';
            op3.StageName  = 'Z01';
            op3.owner = user2;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op3;  
            
            Opportunity op4 = new opportunity();
            
            op4.CloseDate = Date.today().addDays(+6);
            op4.Name = 'sample';
            op4.StageName  = 'Z01';
            op4.owner = user2;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op4;  
        }
        system.runAs(user3){
            Opportunity op5 = new opportunity();
            
            op5.CloseDate = Date.today().addDays(-13);
            op5.Name = 'sample';
            op5.StageName  = 'Z01';
            op5.owner = user3;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op5;  
            
            Opportunity op6 = new opportunity();
            
            op6.CloseDate = Date.today().addDays(+5);
            op6.Name = 'sample';
            op6.StageName  = 'Z01';
            op6.owner = user3;
            //op.owner.EvKostl__c = 'T100-12345';
            insert op6;  
        }
        
        group_hierarchy__c gh = new group_hierarchy__c();
        gh.Division_Cost_Center__c = costCenterHQ.id;
        gh.Type__c = 'Division';
        gh.Leader__c = emp1.id;
        // gh.DivisionCode__c = 'T100-12579'
        insert gh;
        
        group_hierarchy__c gh1 = new group_hierarchy__c();
        gh1.Team_Cost_Center__c  = costCenterHQ2.id;
        gh1.Type__c = 'Team';
        gh1.Leader__c = emp1.id;
        gh1.ParentDivision__c = 'T100-12';
        // gh1.TeamCode__c = 'T100-11474';
        insert gh1;
        
       /* group_hierarchy__c gh5 = new group_hierarchy__c();
        gh5.Team_Cost_Center__c  = costCenterHQ2.id;
        gh5.Type__c = 'Team';
        gh5.Leader__c = emp1.id;
        gh5.ParentDivision__c = 'T100-12';
        // gh1.TeamCode__c = 'T100-11474';
        insert gh5;*/
        
        group_hierarchy__c gh2 = new group_hierarchy__c();
        // gh.Division_Cost_Center__c = costCenterHQ.id;
        gh2.Type__c = 'Group';
        gh2.Leader__c = emp1.id;
        gh2.Group_Cost_Center__c  = costCenterHQ3.id;
        insert gh2;
        
        group_hierarchy__c gh3 = new group_hierarchy__c();
        // gh.Division_Cost_Center__c = costCenterHQ.id;
        gh3.Type__c = 'Group';
        gh3.Leader__c = emp1.id;
        gh3.Group_Cost_Center__c  = costCenterHQ4.id;
        insert gh3;
        
        group_hierarchy__c gh4 = new group_hierarchy__c();
        // gh.Division_Cost_Center__c = costCenterHQ.id;
        gh4.Type__c = 'Group';
        gh4.Leader__c = emp1.id;
        gh4.Group_Cost_Center__c  = costCenterHQ5.id;
        insert gh4;
    }
    
    
    @isTest static void testMethod2() {
        
        Test.startTest();
       // GroupHierarchyBOInfo.sendEmailToLeaders();
       String sch ='0 48 * * * ?';
        GroupHierarchyBoInfoScheduler gh = new GroupHierarchyBoInfoScheduler();
       System.schedule('Schedule to update Account Name', sch,gh);
        Test.stopTest();
        
    }
}