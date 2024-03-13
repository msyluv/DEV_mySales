/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-29
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-27-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
public without sharing class QuestionOwnerViewController {
    
    public class questionWrapper {
        @AuraEnabled
        public Question__c question {get; set;}
        @AuraEnabled
        public List<Answer__c> answerList {get; set;}
        @AuraEnabled
        public Biz_Review__c bizReview {get; set;}
        @AuraEnabled
        public Integer totalScore {get; set;}
        @AuraEnabled
        public Integer totalPMScore {get; set;}
        @AuraEnabled
        public Boolean isCreater {get; set;}
        @AuraEnabled
        public Boolean isPm {get; set;}
        @AuraEnabled
        public Boolean isAnswered {get; set;}
        @AuraEnabled
        public Integer index {get; set;}
        @AuraEnabled
        public Map<String, String> answerTypeMap {get; set;}
        @AuraEnabled
        public List<questionWrapper> questionWrapperList {get; set;}
        @AuraEnabled
        public Map<String, String> BasisMap {get; set;}
        
        public questionWrapper(Integer index, Question__c question, List<Answer__c> answerList, Boolean isAnswered, Map<String, String> BasisMap) {
            this.question = question;
            this.answerList = answerList;
            this.isAnswered = isAnswered;
            this.index = index;
            this.BasisMap = BasisMap;
        } 

        public questionWrapper(List<questionWrapper> questionWrapperList, Biz_Review__c bizReview, Integer totalScore, Integer totalPMScore, Map<String, String> answerTypeMap, Boolean isCreater, Boolean isPm) {
            this.questionWrapperList = questionWrapperList;
            this.bizReview = bizReview;
            this.totalScore = totalScore;
            this.totalPMScore = totalPMScore;
            this.answerTypeMap = answerTypeMap;
            this.isCreater = isCreater;
            this.isPm = isPm;
        }
    }
    
    @AuraEnabled
    public static questionWrapper getQuestionList(String recordId){
        String userId = UserInfo.getUserId();
        Biz_Review__c bizReview = [SELECT Id, Description__c, TotalQuestionCount__c, IsAnswerCount__c, Version__c, CreatedById, Opportunity__c
                                   FROM Biz_Review__c 
                                   WHERE Id =: recordId 
                                   LIMIT 1];
        // Requester Owner 체크
        Map<String, Boolean> requestCheck = new Map<String, Boolean>();
        for(VRBRequest__c v : [SELECT Id, Biz_Review__c FROM VRBRequest__c WHERE Biz_Review__c = :recordId AND( VRBOwner__c = :userId OR VRBRequester__c =: userId )]){
            System.debug(v);
            requestCheck.put(String.valueOf(v.Biz_Review__c), true);
        }
        Boolean isCreater = false;
        Boolean isPm = false;
        List<Question__c> questionList = new List<Question__c>();
        if(userId == bizReview.CreatedById || requestCheck.get(recordId) != null){
            // Strategy Committee 요청자용
            System.debug('isCreater');
            questionList = [SELECT Id, IsAnswer__c, Category1__c, Category2__c, IsKeyQuestion__c, DealBreakScore__c, Question__c, QuestionDetail__c, ReviewDivision__c, ShortAnswerScore__c, IsPMAnswer__c, PMShortAnswerScore__c, PMScore__c, Score__c, TotalScore__c, TotalPMScore__c
                            FROM   Question__c 
                            WHERE  BOBizReview__c = :recordId 
                            // AND    CreatedById = :userId
                            ORDER BY Category1__c ASC, Category2__c ASC];
            isCreater = true;
        } else {
            User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :userId];
            List<Employee__c> empList = [SELECT Id FROM Employee__c WHERE EvUniqID__c = :u.FederationIdentifier];
            Opportunity opp = [SELECT Id, ProposalPM__c FROM Opportunity WHERE Id =: bizReview.Opportunity__c];
            if(empList.size() > 0 && empList[0].Id == opp.ProposalPM__c) {
                // Strategy Committee PM용
                System.debug('isPm');
                questionList = [SELECT Id, IsAnswer__c, Category1__c, Category2__c, IsKeyQuestion__c, DealBreakScore__c, Question__c, QuestionDetail__c, ReviewDivision__c, ShortAnswerScore__c, IsPMAnswer__c, PMShortAnswerScore__c, PMScore__c, Score__c, TotalScore__c, TotalPMScore__c
                                FROM   Question__c 
                                WHERE  BOBizReview__c = :recordId
                                ORDER BY Category1__c ASC, Category2__c ASC];
                isPm = true;
            } else {
                // Strategy Committee 답변자용
                System.debug('isAnswer');
                questionList = [SELECT Id, IsAnswer__c, Category1__c, Category2__c, IsKeyQuestion__c, DealBreakScore__c, Question__c, QuestionDetail__c, ReviewDivision__c, ShortAnswerScore__c, IsPMAnswer__c, PMShortAnswerScore__c, PMScore__c, Score__c, TotalScore__c, TotalPMScore__c
                                FROM   Question__c 
                                WHERE  BOBizReview__c = :recordId 
                                AND    AnswerUser__c = :userId
                                ORDER BY Category1__c ASC, Category2__c ASC];
            }
        }
        
        List<Answer__c> answerList = [SELECT Id, Answer__c, IsPMChecked__c, ShortAnswer__c, ShortAnswerPM__c, IsChecked__c, AnswnerGroupCode__c, DealBreak__c, Score__c, BOQuestion__c, No__c, AnswerType__c, EvaluationDepartmentEvaluationBasis__c, ProposalPMEvaluationBasis__c
                                      FROM Answer__c 
                                      WHERE BOQuestion__c IN :questionList
                                      ORDER BY No__c, Score__c ASC];
        
        Integer totalScore = 0;
        Integer totalPMScore = 0;
        Map<String, List<Answer__c>> answerMap = new Map<String, List<Answer__c>>();
        for(Answer__c a : answerList){
            // System.debug(a);
            List<Answer__c> al = new List<Answer__c>();
            if(answerMap.get(a.BOQuestion__c) != null) {
                al = answerMap.get(a.BOQuestion__c);
            }
            al.add(a);

            answerMap.put(a.BOQuestion__c, al);
        }
        Integer index = 0;
        String lastQuestion = '';
        List<questionWrapper> questionWrapperList = new List<questionWrapper>();
        for(Question__c q : questionList){
            totalScore += Integer.valueOf(q.TotalScore__c);
            totalPMScore += Integer.valueOf(q.TotalPMScore__c);
            List<Answer__c> al = new List<Answer__c>();
            if(answerMap.get(q.Id) != null){
                al = answerMap.get(q.Id);
            }
            Boolean Answered = false;
            Boolean isAnswered = false;
            Boolean isPmAnswered = false;
            Map<String, String> BasisMap = new Map<String, String>();
            for(Answer__c a : al){
                if(a.IsChecked__c){
                    isAnswered = true;
                }
                BasisMap.put('User', a.EvaluationDepartmentEvaluationBasis__c);
                if(a.IsPMChecked__c){
                    isPmAnswered = true;
                }
                BasisMap.put('PM', a.ProposalPMEvaluationBasis__c);
            }
            if(isCreater){
                if(isAnswered && isPmAnswered) Answered = true;
            } else {
                if(isPm && isPmAnswered) Answered = true;
                if(!isPm && isAnswered) Answered = true;
            }

            String question = q.Category1__c + q.Category2__c + q.Question__c;
            if(question != lastQuestion){
                index += 1;
            }
            questionWrapper qw = new questionWrapper(index, q, al, Answered, BasisMap);
            lastQuestion = question;
            questionWrapperList.add(qw);                   
        }

        Map<String, String> answerTypeMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Answer__c.AnswerType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry p : ple){
            answerTypeMap.put(p.getValue(), p.getLabel());
        } 

        questionWrapper returnVal = new questionWrapper(questionWrapperList, bizReview, totalScore, totalPMScore, answerTypeMap, isCreater, isPm);

        return returnVal;
    }
    /*
    @AuraEnabled
    public static Map<String, String> updateAnswer(List<sObject> objList){
        Map<String, String> returnMap = new Map<String, String>();
        try {
            
            // List<Answer__c> oldAns = [SELECT Id, Answer__c, IsChecked__c, AnswnerGroupCode__c, DealBreak__c, Score__c, BOQuestion__c, No__c, AnswerType__c
            //                               FROM Answer__c 
            //                               WHERE Id IN :objList];
            // Map<String, String> scoreMap = new Map<String, String>();
            // for(Answer__c a : oldAns){
            //     scoreMap.put(a.Id, String.valueOf(a.Score__c));
            // }
			
            for(sObject o :objList){
                if(o.get('AnswerType__c') == '주관식'){
                    if(o.get('ShortAnswer__c') != null){
                        o.put('IsChecked__c', true);
                    }
                    if(o.get('ShortAnswerPM__c') != null){
                        o.put('IsPMChecked__c', true);
                    }
                }
            }
            update objList;
            returnMap.put('isSuccess', 'success');
            returnMap.put('title', 'SUCCESS');
            returnMap.put('message', 'SUCCESS Strategy Committee Answer UPDATE');
        } catch (Exception e) {
            returnMap.put('isSuccess', 'error');
            returnMap.put('title', 'FAIL');
            returnMap.put('message', String.valueOf(e));
        }
        return returnMap;
    }
    */
}