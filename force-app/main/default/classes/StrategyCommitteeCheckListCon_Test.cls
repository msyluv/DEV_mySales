/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-25
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12-17-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class StrategyCommitteeCheckListCon_Test {
    //static TriggerSwitch__c trSwitch;
    static User adminUser;
    static Profile adminpf;
    static OpptyCodeSetting__c ocs;
    static Account acc;
    static Opportunity opp;
    static Biz_Review__c bizReview;
    static List<Answer__c> alist;
    static {
        /*
        trSwitch = new TriggerSwitch__c(
            All__c = true,
            Opportunity__c = true,
            OpportunityCodeSetting__c = true,
            SetupOwnerId = UserInfo.getProfileId()
        );        
        insert trSwitch;

        */
        
        adminpf =  [SELECT Id FROM Profile WHERE (Name = 'System Administrator' OR Name = '시스템 관리자') LIMIT 1];
        
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
        );       
        insert adminUser;
        
        ocs = new OpptyCodeSetting__c(CodeSetting__c = true);
        insert ocs;

        acc = new Account(
            Name = 'a_name'
        );
        
        insert acc;
        
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
            CloseDate = Utils.getCurDatetime().date().addDays(1)
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
        bizReview = new Biz_Review__c(Description__c = 'test', Version__c = 1, Opportunity__c = opp.Id, Status__c = 'Confirm');
        insert bizReview;
        for(Integer i=0; i<50; i++){
            Integer cat1 = Integer.valueOf(((Math.random() * (Category1ple.size() - 0)) + 0));
            Integer cat2 = Integer.valueOf(((Math.random() * (Category2ple.size() - 0)) + 0));
            Integer RD = Integer.valueOf(((Math.random() * (ReviewDivisionple.size() - 0)) + 0));
            questionList.add(new Question__c(AnswerUser__c = adminUser.Id, BOBizReview__c = bizReview.Id, Category1__c = String.valueOf(Category1ple[cat1]), Category2__c =  String.valueOf(Category2ple[cat2]), Question__c = 'test', QuestionDetail__c = 'test', ReviewDivision__c =  String.valueOf(ReviewDivisionple[RD]), UserAnswer__c = '', PMAnswer__c = '', UserEvaluationBasis__c = '', PMEvaluationBasis__c = ''));
        }
        
        List<Biz_Review__c> brList = new List<Biz_Review__c>();
        for(Integer i=0; i<50; i++){
            brList.add(new Biz_Review__c(Description__c = 'test', Version__c = i+1, Opportunity__c = opp.Id, Status__c = 'Confirm'));
        }
        insert brList;
        for(Biz_Review__c b : brList){
            Integer cat1 = Integer.valueOf(((Math.random() * (Category1ple.size() - 0)) + 0));
            Integer cat2 = Integer.valueOf(((Math.random() * (Category2ple.size() - 0)) + 0));
            Integer RD = Integer.valueOf(((Math.random() * (ReviewDivisionple.size() - 0)) + 0));
            questionList.add(new Question__c(AnswerUser__c = adminUser.Id, BOBizReview__c = b.Id, Category1__c = String.valueOf(Category1ple[cat1]), Category2__c =  String.valueOf(Category2ple[cat2]), Question__c = 'test', QuestionDetail__c = 'test', ReviewDivision__c =  String.valueOf(ReviewDivisionple[RD]), UserAnswer__c = '', PMAnswer__c = '', UserEvaluationBasis__c = '', PMEvaluationBasis__c = ''));
        }
        
        insert questionList;
        alist = new List<Answer__c>();
        for(Question__c q : questionList){
            for(Integer i=0; i<5; i++){
                 alist.add(new Answer__c(Answer__c = 'test', AnswnerGroupCode__c = 'A', Score__c = i, BOQuestion__c = q.Id, No__c = (i+1), AnswerType__c = '주관식', ShortAnswer__c = 5, ShortAnswerPM__c = 5));
            }
        }
        insert alist;
    }
    @isTest
    public static void StrategyCommitteeCheckListController(){
        System.runAs(adminUser) {
            StrategyCommitteeCheckListController.getInit('', '', true);
            StrategyCommitteeCheckListController.getQuestionList(bizReview.Id);
            StrategyCommitteeCheckListController.updateAnswer(alist);
            StrategyCommitteeCheckListController.getMoreData(10,'', '', true);
            StrategyCommitteeCheckListController.getPickVal();
        }
    }
}