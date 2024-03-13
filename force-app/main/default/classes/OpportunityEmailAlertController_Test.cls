/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-11-09
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-02-04   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class OpportunityEmailAlertController_Test {
    static String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'Logistics' AND SobjectType = 'Opportunity' LIMIT 1].Id);
    static Account acc;
    static Opportunity opp1;
    static Opportunity opp2;
    static Opportunity opp3;
    static Organization__c org;
    static User adminUser;
    static User logiUser;
    static Profile adminpf;
    static Profile logipf;
    static OpptyCodeSetting__c ocs;
    static Opportunity opp;
    static Biz_Review__c bizReview;
    static Master_Service__c svc;
    static Master_Solution__c sol;
    static CostCenter__c cc;
    static Service__c opp_svc;
    static Solution__c opp_sol;
    static Company__c comp;
    static Opportunity_Activity__c oppAct;
    static VRBRequest__C vrbrequest;
    static Employee__c emp;
    static {
        FunctionSwitch__c fnSwitch_default = new FunctionSwitch__c(
            KnoxEmailSend__c = true
        );
        insert fnSwitch_default;

        acc = new Account(
            Name = 'a_name',
            MDGCheck__c = true
        );
        insert acc;
        opp1 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z03',
            CloseDate = Date.today().addDays(-7),
            RecordTypeId = recordTypeId
        );
        insert opp1;
        opp2 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z04',
            cRevenueStartDate__c = Date.today().addDays(1),
            CloseDate = Date.today().addDays(-14),
            RecordTypeId = recordTypeId
        );
        insert opp2;
        opp2 = new Opportunity(
            Name = 'opportunity',
            AccountId = acc.Id,
            OpportunityCode__c = 'oppCode',
            ActivityStatus__c = 'ZAC4',
            StageName = 'Z01',
            LogisticsCustomerType__c = 'EXTAC',
            LBSExceptionType__c = '08',
            cRevenueStartDate__c = Date.today().addDays(1),
            CloseDate = Date.today().addDays(-21),
            RecordTypeId = recordTypeId
        );
        insert opp2;
        org = new Organization__c(
            Name = 'test',
            Region__c = 'H'
        );
        insert org;
        opp2.DeliveryOrganization__c = org.Id;
        update opp2;

        adminpf =  [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자' limit 1];
        logipf = [SELECT Id FROM Profile WHERE Name Like '%Logi%' LIMIT 1];   
        
        adminUser = new User(
            Alias = 'testUser'
            , Email = 'adminUser@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = adminpf.Id
            , UserName = 'adminUser@test.com.test'
            , FederationIdentifier = 'epId1'
            , FirstName = 'test'
        );
                                
        insert adminUser;
        logiUser = new User(
            Alias = 'testUser'
            , Email = 'logiUser@test.com.test'
            , EmailEncodingKey = 'UTF-8'
            , LastName = 'Testing'
            , LanguageLocaleKey = 'en_US'
            , LocaleSidKey = 'en_US'
            , EmployeeNumber = 'AC100000'
            , TimeZoneSidKey = 'Asia/Seoul'
            , ProfileId = logipf.Id
            , UserName = 'logiUser@test.com.test'
            , FederationIdentifier = 'epId2'
        );
                                
        insert logiUser;
        
        ocs = new OpptyCodeSetting__c(CodeSetting__c = true);
        //insert ocs;

        MasterActivity__c MA1 = new MasterActivity__c(Stage__c='Z01'
                                                           ,Order__c=1
                                                           ,Position__c='1'
                                                           ,IsImportant__c=true
                                                           , ObjectApiName__c='Opportunity'
                                                           ,IsActive__c=true
                                                           ,Type__c='HQ'
                                                           ,TransactionName__c = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value'));
        insert MA1;
        MasterActivity__c MA2 = new MasterActivity__c(Stage__c='Z01'
                                                           ,Order__c=1
                                                           ,Position__c='1'
                                                           ,IsImportant__c=true
                                                           , ObjectApiName__c='Opportunity'
                                                           ,IsActive__c=true
                                                           ,Type__c='HQ'
                                                           ,TransactionName__c = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value'));
        insert MA2;
        
        opp = new Opportunity(
            Name = 'a_name',
            AccountId = acc.Id,
            StageName = 'Qualification',
            CloseDate = Utils.getCurDatetime().date().addDays(1),
            OpportunityCode__c = 'test',
            owner = adminUser
        );
        
        insert opp;
        List<Question__c> questionList = new List<Question__c>();
        List<String> Category1= new List<String>();
        List<String> Category2= new List<String>();

		Schema.DescribeFieldResult Category1Result = Master_Question__c.Category1__c.getDescribe();
		List<Schema.PicklistEntry> Category1ple = Category1Result.getPicklistValues();
        
		Schema.DescribeFieldResult Category2Result = Master_Question__c.Category2__c.getDescribe();
		List<Schema.PicklistEntry> Category2ple = Category2Result.getPicklistValues();
        
		Schema.DescribeFieldResult ReviewDivisionResult = Master_Question__c.ReviewDivision__c.getDescribe();
		List<Schema.PicklistEntry> ReviewDivisionple = ReviewDivisionResult.getPicklistValues();
        bizReview = new Biz_Review__c(Description__c = 'test', Version__c = 1, Opportunity__c = opp.Id, DeadLine__c = Date.today());
        insert bizReview;
        for(Integer i=0; i<50; i++){
            Integer cat1 = Integer.valueOf(((Math.random() * (Category1ple.size() - 0)) + 0));
            Integer cat2 = Integer.valueOf(((Math.random() * (Category2ple.size() - 0)) + 0));
            Integer RD = Integer.valueOf(((Math.random() * (ReviewDivisionple.size() - 0)) + 0));
            questionList.add(new Question__c(BOBizReview__c = bizReview.Id, Category1__c = String.valueOf(Category1ple[cat1]), Category2__c =  String.valueOf(Category2ple[cat2]), Question__c = 'test', QuestionDetail__c = 'test', ReviewDivision__c =  String.valueOf(ReviewDivisionple[RD])));
        }
        insert questionList;
        
        List<Answer__c> alist = new List<Answer__c>();
        for(Question__c q : questionList){
            for(Integer i=0; i<5; i++){
                 alist.add(new Answer__c(Answer__c = 'test', IsChecked__c = true,  AnswnerGroupCode__c = 'A', Score__c = 4, BOQuestion__c = q.Id, No__c = (i+1)));
            }
        }
        insert alist;
        comp = new Company__c(
            Name = 'Test Company',
            CompanyCode__c = 'T100'
        );
        insert comp;
        svc = new Master_Service__c(
            Name = 'Test Service',
            Code__c = '200000010000'
        );
        insert svc;

        sol = new Master_Solution__c(
            Name = 'Test Solution', 
            Code__c = '300000010000', 
            Service__c = svc.Id
        );
        insert sol;

        cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Text2__c = '테스트'
        );
        insert cc;
        
        opp_svc = new Service__c(
            Service__c = svc.Id, 
            Opportunity__c = opp.Id
        );
        insert opp_svc;

        opp_sol = new Solution__c(
            Service__c = opp_svc.Id,
            Solution__c = sol.Id, 
            Opportunity__c = opp.Id
        );
        insert opp_sol;

        oppAct = new Opportunity_Activity__c( Status__c='Not Started', DueDate__c=System.today(), ExtId__c = opp.Id+'_'+Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value')
                                            ,WhatId__c=opp.Id, TransactionName__c = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value'));
        
        insert oppAct;

        vrbrequest = new VRBRequest__c(VRBMethod__c= '전사', VRBDueDate__c = System.today(), Opportunity__c = opp.Id ,Opportunity_Activity__c = oppAct.Id, Biz_Review__c = bizReview.Id);
        insert vrbrequest;

        emp = new Employee__c(
            Name = 'test', 
            EvUniqID__c = 'epId1', 
            EvMailAddr__c = 'test@tes.com'
        );
        insert emp;
    }

    @isTest
    public static void OpportunityEmailAlertControllerTest() {
        Test.startTest();
        List<String> tempNameList = new List<String>();
        tempNameList.add('PRS_Stage_Change_Email');
        tempNameList.add('Contract_notification_Email');
        tempNameList.add('Credit_rating_notification_Email');

        System.debug(opp);
        System.debug(opp.Owner);
        System.debug(opp.Owner.Name);
        for(EmailTemplate r : [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName IN: tempNameList LIMIT 3]){
            System.debug(r.DeveloperName);
            OpportunityEmailAlertController.getEmailTemplateMap(opp, r);
        }

        List<String> oppIdList = new List<String>();
        Set<String> optyIdSet = new Set<String>();
        Map<String, String> ownerUserMap = new Map<String, String>();
        for(Opportunity o : [SELECT Id, OwnerId FROM Opportunity]){
            oppIdList.add(String.valueOf(o.Id));
            optyIdSet.add(String.valueOf(o.Id));
            ownerUserMap.put(String.valueOf(o.Id), String.valueOf(o.OwnerId));
        }

        OpportunityEmailAlertController.getUserEmailList(oppIdList, optyIdSet, ownerUserMap, 'PRS_Stage_Change_Email');
        OpportunityEmailAlertController.StrategyCommitteeRequestEmailSend(String.valueOf(vrbrequest.Id));
        List<String> toListUser = new List<String>();
        toListUser.add(String.valueOf(adminUser.Id));
        toListUser.add(String.valueOf(logiUser.Id));
        OpportunityEmailAlertController.StrategyCommitteeReviewEmailSend(bizReview.Id, toListUser);
        System.runAs(adminUser){
            List<String> slist = new List<String>();
            slist.add('test@test.com');
            List<Map<String, Object>> efileList = new List<Map<String, Object>>();
            List<Map<String, String>> nfileList = new List<Map<String, String>>();
            //OpportunityEmailAlertController.sendKnoxEmail(String.valueOf(vrbrequest.Id), JSON.serialize(slist), JSON.serialize(slist), JSON.serialize(slist), 'subject', 'description', JSON.serialize(efileList), JSON.serialize(nfileList), false);
        
            OpportunityEmailAlertController.sendKnoxEmail(String.valueOf(vrbrequest.Id), slist, slist, slist, 'subject', 'description', efileList, nfileList, false);
            OpportunityEmailAlertController.sendKnoxEmail(String.valueOf(vrbrequest.Id), slist, slist, slist, 'subject', 'description', efileList, nfileList, true);
            OpportunityEmailAlertController.sendKnoxEmailMulti(emp, String.valueOf(vrbrequest.Id), slist, slist,slist, 'subject', 'description', efileList, nfileList);
        }
        Test.stopTest();
    }
}