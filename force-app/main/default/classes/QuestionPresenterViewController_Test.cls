/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-02-08
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12-15-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class QuestionPresenterViewController_Test {
    
    static OpptyCodeSetting__c ocs;
    static Account acc;
    static Opportunity opp;
    static Biz_Review__c bizreview;
    static Master_Question__c masterQuestion;
    static Master_Answer__c masterAnswer;
    static Opportunity_Activity__c oppAct;
    static {
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
            StageName = 'Z01',
            CloseDate = Utils.getCurDatetime().date().addDays(1)
        );
        
        insert opp;
        
        masterQuestion = new Master_Question__c(Category1__c = 'Compliance', Category2__c = 'Compliance', Question__c = 'test', QuestionDetail__c = 'test', ReviewDivision__c = '개발전략그룹');
        insert masterQuestion;
        masterAnswer = new Master_Answer__c(MasterQuestion__c = masterQuestion.Id, Answer__c = 'test', AnswerGroupCode__c = 'A', No__c = 1, Score__c = 0);
        insert masterAnswer;
        oppAct = new Opportunity_Activity__c( Status__c='Not Started', DueDate__c=System.today(), ExtId__c = opp.Id+'_'+Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value')
                                            ,WhatId__c=opp.Id, TransactionName__c = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c')[0].get('value'));
        
        insert oppAct;

    }
	@isTest
    public static void QuestionPresenterViewController(){
        List<QuestionPresenterViewController.MasterQuestionWrapper> vrbMasterQuestionWrapperList = new List<QuestionPresenterViewController.MasterQuestionWrapper>();
        List<QuestionPresenterViewController.MasterQuestionWrapper> oppMasterQuestionWrapperList = new List<QuestionPresenterViewController.MasterQuestionWrapper>();
        QuestionPresenterViewController.getOpportunityId(opp.Id);
        oppMasterQuestionWrapperList = QuestionPresenterViewController.getInit('Opportunity', opp.Id, '');

        List<String> mqidList = new List<String>();
        mqidList.add(masterQuestion.Id);
        
        VRBRequest__C vrbrequest = new VRBRequest__c(VRBMethod__c= '전사', VRBDueDate__c = System.today(), Opportunity__c = opp.Id ,Opportunity_Activity__c = oppAct.Id);
        insert vrbrequest;
        QuestionPresenterViewController.QuestionDetail questionDetail = QuestionPresenterViewController.getQuestionDetail(mqidList, opp.Id, false, '', vrbrequest.Id);
        QuestionPresenterViewController.getOpportunityId(vrbrequest.Id);

        vrbMasterQuestionWrapperList = QuestionPresenterViewController.getInit('VRBRequest__c', opp.Id, vrbrequest.Id);
        System.debug('test class=======================');
        System.debug(questionDetail);
        System.debug(questionDetail.BizRivewId);
        vrbrequest.Biz_Review__c = questionDetail.BizRivewId;
        update vrbrequest;
        
        QuestionPresenterViewController.getOpportunityId(vrbrequest.Id);

        Id id = vrbrequest.Id;
        String objName = id.getSobjectType().getDescribe().getName();
        System.debug(objName);

        vrbMasterQuestionWrapperList = QuestionPresenterViewController.getInit('VRBRequest__c', opp.Id, vrbrequest.Id);

        System.debug(vrbrequest.Biz_Review__c);
        QuestionPresenterViewController.getQuestionDetail(mqidList, opp.Id, true, String.valueOf(vrbrequest.Biz_Review__c), '');
        QuestionPresenterViewController.updateAnswerUser(questionDetail.questionDetailList, vrbrequest.Id, true, vrbrequest.Biz_Review__c, 'Description');
        try {
            QuestionPresenterViewController.checkListConfirm(vrbrequest.Biz_Review__c);
        } catch (Exception e) {
            System.debug(e);
        }
        
        QuestionPresenterViewController.getOpportunityId(vrbrequest.Id);
        
        QuestionPresenterViewController.deleteTemplate(questionDetail.BizRivewId, false);
        
        QuestionPresenterViewController.getNewChecklist(String.valueOf(opp.Id));
        
        QuestionPresenterViewController.getPickVal();
    }
}