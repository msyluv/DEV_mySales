/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-25
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12-11-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
public without sharing class StrategyCommitteeCheckListController {

    public class initWrapper {
        
        @AuraEnabled
        public Id Id {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Opportunity {get; set;}
        @AuraEnabled
        public String Description {get; set;}
        @AuraEnabled
        public Integer Version {get; set;}
        @AuraEnabled
        public String Status {get; set;}
        @AuraEnabled
        public String Url {get; set;}
        @AuraEnabled
        public String oppUrl {get; set;}
        @AuraEnabled
        public Integer IsAnswerCount {get; set;}
        @AuraEnabled
        public Integer IsPMAnswerCount {get; set;}
        @AuraEnabled
        public Integer TotalQuestionCount {get; set;}
        @AuraEnabled
        public Date ConfirmDate {get; set;}
        @AuraEnabled
        public Boolean isCreater {get; set;}
        @AuraEnabled
        public Boolean isPm {get; set;}
        @AuraEnabled
        public Boolean isLock {get; set;}
        @AuraEnabled
        public List<initWrapper> initWrapper {get; set;}
        @AuraEnabled
        public Integer size {get; set;}
        @AuraEnabled
        public Boolean isAdmin {get; set;}
        @AuraEnabled
        public String Manager {get; set;}
        @AuraEnabled
        public String Decision {get; set;}
        @AuraEnabled
        public Date DeadLine {get; set;}

        public initWrapper(Biz_Review__c br, Boolean isCreater, Boolean isPm, Boolean isLock) {
            this.Id = br.Id;
            this.Name = String.valueOf(br.Name);
            this.Opportunity = String.valueOf(br.Opportunity__r.Name) + (br.Opportunity__r.OpportunityCode__c == null ? '' : ' (' + String.valueOf(br.Opportunity__r.OpportunityCode__c) + ')');
            this.Description = String.valueOf(br.Description__c);
            this.Version = Integer.valueOf(br.Version__c);
            this.Status = String.valueOf(br.Status__c);
            this.Url = '/lightning/r/Biz_Review__c/'+ String.valueOf(br.Id) + '/view';
            this.oppUrl = '/lightning/r/Opportunity/' + String.valueOf(br.Opportunity__c) + '/view';
            this.IsAnswerCount = Integer.valueOf(br.IsAnswerCount__c);
            this.IsPMAnswerCount = Integer.valueOf(br.IsPMAnswerCount__c);
            this.TotalQuestionCount = Integer.valueOf(br.TotalQuestionCount__c);
            this.ConfirmDate = Date.valueOf(br.ConfirmDate__c);
            this.isCreater = isCreater;
            this.isPm = isPm;
            this.isLock = isLock;
            this.Manager = br.CreatedBy.Name;
            this.Decision = br.Decision__c == null ? '' : br.Decision__c;
            this.DeadLine = Date.valueOf(br.DeadLine__c);
        } 

        public initWrapper(List<initWrapper> initWrapper, Integer size, Boolean isAdmin){
            this.initWrapper = initWrapper;
            this.size = size;
            this.isAdmin = isAdmin;
        }
    }

    @AuraEnabled
    public static initWrapper getInit(String deadline, String decision, Boolean isApproval){
        String userId = String.valueOf(UserInfo.getUserId());

        String pfid = String.valueOf(UserInfo.getProfileId());
        Profile pf = [SELECT Id, Name FROM Profile WHERE Id = :pfid];
        String pfName = String.valueOf(pf.Name);
        Boolean isAdmin = false;
        if(pfName == '시스템 관리자' || pfName == 'System Administrator') isAdmin = true;
        System.debug('isAdmin : ' + isAdmin);

        // get employee
        User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :userId LIMIT 1];
        System.debug('User Id : ' + u + 'getInit============================');

        Set<String> empSet = new Set<String>();
        System.debug('employee============================getInit');
        for(Employee__c e : [SELECT Id, EvUniqID__c FROM Employee__c WHERE EvUniqID__c = :u.FederationIdentifier]){
            System.debug(e);
            empSet.add(e.Id);
        }
        Set<String> oppSet = new Set<String>();
        System.debug('Opportunity============================getInit');
        for(Opportunity o : [SELECT Id FROM Opportunity WHERE ProposalPM__c IN :empSet]){
            System.debug(o);
            oppSet.add(o.Id);
        }

        Set<String> bizReviewIdSet = new Set<String>();
        Map<String, String> pmMap = new Map<String, String>();
        System.debug('Biz_Review__c============================getInit');
        for(Biz_Review__c o : [SELECT Id, Opportunity__c FROM Biz_Review__c WHERE CreatedById = :userId OR Opportunity__c IN :oppSet]){
            System.debug(o);
            bizReviewIdSet.add(o.Id);
            if(oppSet.contains(o.Opportunity__c)) pmMap.put(String.valueOf(o.Id), 'true');
        }
        List<Question__c> qlist = [SELECT BOBizReview__c, AnswerUser__c FROM Question__c WHERE AnswerUser__c = :userId];
        System.debug('Biz_Review__c============================getInit');
        for(Question__c o : qlist){
            System.debug(o);
            bizReviewIdSet.add(o.BOBizReview__c);
        }

        // 2021-02-26 Strategy Committe Request 오브젝트 Requester, Owner 내용 추가
        Map<String, Boolean> requestCheck = new Map<String, Boolean>();
        for(VRBRequest__c v : [SELECT Id, Biz_Review__c, VRBRequester__c FROM VRBRequest__c WHERE VRBOwner__c = :userId OR VRBRequester__c =: userId]){
            System.debug(v);
            bizReviewIdSet.add(v.Biz_Review__c);
            if(v.VRBRequester__c == userId) requestCheck.put(String.valueOf(v.Biz_Review__c), true);
        }

        if(isApproval){
            Set<String> removeSet = bizReviewIdSet;
            for(KnoxApproval__c app : [SELECT Id, BizReview__c FROM KnoxApproval__c WHERE Status__c = '2' AND BizReview__c IN :bizReviewIdSet]){
                removeSet.remove(String.valueOf(app.BizReview__c));
            }
            bizReviewIdSet = removeSet;
        }
        String selectQuery = 'SELECT Id, Name, CreatedDate, CreatedById, Opportunity__r.Name, LastModifiedDate, IsPMAnswerCount__c, Opportunity__r.OpportunityCode__c, DeadLine__c, ';
        selectQuery += ' Description__c, Version__c, Status__c, IsAnswerCount__c, TotalQuestionCount__c, ConfirmDate__c, CreatedBy.Name, toLabel(Decision__c) ';
        String fromQuery = ' FROM   Biz_Review__c ';
        String whereQuery = ' WHERE  Id IN :bizReviewIdSet ';
        whereQuery += ' AND Status__c = \'Confirm\' ';
        String orderbyQuery = ' ORDER BY ConfirmDate__c DESC, Opportunity__c ASC, Version__c DESC ';
        String limitQuery = ' LIMIT 50 ';

        String searchQuery = '';
        if(String.isNotBlank(deadline)) searchQuery += ' AND (DeadLine__c = LAST_N_MONTHS:' + deadline + ' OR DeadLine__c = THIS_MONTH) ';
        
        if(String.isNotBlank(decision)) searchQuery += ' AND Decision__c = \'' + decision + '\' ';
        
        if(String.isNotBlank(searchQuery)) whereQuery += searchQuery;

        List<Biz_Review__c> bizReviewList = Database.Query(selectQuery + fromQuery + whereQuery + orderbyQuery + limitQuery);
        
        selectQuery = 'SELECT Id ';
        limitQuery = ' LIMIT 2000 ';
        List<Biz_Review__c> totallist = Database.Query(selectQuery + fromQuery + whereQuery + limitQuery);
        Integer totalSize = totallist.size();

        /*
        List<Biz_Review__c> bizReviewList = [SELECT Id, Name, CreatedDate, CreatedById, Opportunity__r.Name, LastModifiedDate, IsPMAnswerCount__c, Opportunity__r.OpportunityCode__c, DeadLine__c,
                                                    Description__c, Version__c, Status__c, IsAnswerCount__c, TotalQuestionCount__c, ConfirmDate__c, CreatedBy.Name, toLabel(Decision__c)
                                             FROM   Biz_Review__c
                                             WHERE  Id IN :bizReviewIdSet
                                                AND Status__c = 'Confirm'
                                             ORDER BY ConfirmDate__c DESC, Opportunity__c ASC, Version__c DESC
                                             LIMIT 50];

        List<AggregateResult> totallist = [SELECT COUNT(Id)
                                           FROM   Biz_Review__c
                                           WHERE  Id IN :bizReviewIdSet
                                              AND Status__c = 'Confirm'];
        */

        List<initWrapper> returnList = new List<initWrapper>();
        System.debug('Biz_Review__c============================getInit');
        System.debug(bizReviewList.size());
        Integer idx = 1;
        String LastQuestion = '';
        for(Biz_Review__c br : bizReviewList){
            System.debug(br);
            System.debug(br.Opportunity__r.Name);
            System.debug(br.Opportunity__r.OpportunityCode__c);
            Boolean isCreater = false;
            Boolean isPm = false;
            Boolean isLock = Approval.isLocked(br.Id);
            
            if(br.CreatedById == userId || requestCheck.get(br.Id) != null) isCreater = true;
            System.debug('isCreater1 : ' + isCreater);
            // if(br.CreatedById == userId) isCreater = true;

            //if(!isCreater){
                for(Question__c q : qlist){
                    if(br.Id == q.BOBizReview__c && q.AnswerUser__c == userId){
                        System.debug(q.Id);
                        isCreater = false;
                    }
                }
                System.debug('isCreater2 : ' + isCreater);
            //}
            if(pmMap.get(String.valueOf(br.Id)) != null){
                isPm = true;
                isCreater = false;
            }
            System.debug('isCreater3 : ' + isCreater);

            initWrapper iw = new initWrapper(br, isCreater, isPm, isLock);
            
            returnList.add(iw);
        }

        return new initWrapper(returnList, totalSize, isAdmin);
    }

    @AuraEnabled
    public static List<initWrapper> getMoreData(Integer offset, String deadline, String decision, Boolean isApproval){
        String userId = String.valueOf(UserInfo.getUserId());
        
        // get employee
        User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :userId LIMIT 1];
        System.debug('User Id : ' + u + 'getMoreData============================');

        Set<String> empSet = new Set<String>();
        System.debug('employee============================getMoreData');
        for(Employee__c e : [SELECT Id, EvUniqID__c FROM Employee__c WHERE EvUniqID__c = :u.FederationIdentifier]){
            System.debug(e);
            empSet.add(e.Id);
        }
        Set<String> oppSet = new Set<String>();
        System.debug('Opportunity============================getMoreData');
        for(Opportunity o : [SELECT Id FROM Opportunity WHERE ProposalPM__c IN :empSet]){
            System.debug(o);
            oppSet.add(o.Id);
        }

        Set<String> bizReviewIdSet = new Set<String>();
        Map<String, String> pmMap = new Map<String, String>();
        System.debug('Biz_Review__c============================getMoreData');
        for(Biz_Review__c o : [SELECT Id, Opportunity__c FROM Biz_Review__c WHERE CreatedById = :userId OR Opportunity__c IN :oppSet]){
            System.debug(o);
            bizReviewIdSet.add(o.Id);
            if(oppSet.contains(o.Opportunity__c)) pmMap.put(String.valueOf(o.Id), 'true');
        }
        List<Question__c> qlist = [SELECT BOBizReview__c, AnswerUser__c FROM Question__c WHERE AnswerUser__c = :userId];
        System.debug('Biz_Review__c============================getMoreData');
        for(Question__c o : qlist){
            System.debug(o);
            bizReviewIdSet.add(o.BOBizReview__c);
        }

        // 2021-02-26 Strategy Committe Request 오브젝트 Requester, Owner 내용 추가
        Map<String, Boolean> requestCheck = new Map<String, Boolean>();
        for(VRBRequest__c v : [SELECT Id, Biz_Review__c, VRBRequester__c FROM VRBRequest__c WHERE VRBOwner__c = :userId OR VRBRequester__c =: userId]){
            System.debug(v);
            bizReviewIdSet.add(v.Biz_Review__c);
            if(v.VRBRequester__c == userId) requestCheck.put(String.valueOf(v.Biz_Review__c), true);
        }

        
        if(isApproval){
            Set<String> removeSet = bizReviewIdSet;
            for(KnoxApproval__c app : [SELECT Id, BizReview__c FROM KnoxApproval__c WHERE Status__c = '2' AND BizReview__c IN :bizReviewIdSet]){
                removeSet.remove(String.valueOf(app.BizReview__c));
            }
            bizReviewIdSet = removeSet;
        }
        String selectQuery = 'SELECT Id, Name, CreatedDate, CreatedById, Opportunity__r.Name, LastModifiedDate, IsPMAnswerCount__c, Opportunity__r.OpportunityCode__c, DeadLine__c, ';
        selectQuery += ' Description__c, Version__c, Status__c, IsAnswerCount__c, TotalQuestionCount__c, ConfirmDate__c, CreatedBy.Name, toLabel(Decision__c) ';
        String fromQuery = ' FROM   Biz_Review__c ';
        String whereQuery = ' WHERE  Id IN :bizReviewIdSet ';
        whereQuery += ' AND Status__c = \'Confirm\' ';
        String orderbyQuery = ' ORDER BY ConfirmDate__c DESC, Opportunity__c ASC, Version__c DESC ';
        String limitQuery = ' LIMIT 50 ';
        String OffsetQuery = ' OFFSET ' + offset;

        String searchQuery = '';
        if(String.isNotBlank(deadline)) searchQuery += ' AND (DeadLine__c = LAST_N_MONTHS:' + deadline + ' OR DeadLine__c = THIS_MONTH) ';
        
        if(String.isNotBlank(decision)) searchQuery += ' AND Decision__c = \'' + decision + '\' ';
        
        if(String.isNotBlank(searchQuery)) whereQuery += searchQuery;

        List<Biz_Review__c> bizReviewList = Database.Query(selectQuery + fromQuery + whereQuery + orderbyQuery + limitQuery + OffsetQuery);
/*
        List<Biz_Review__c> bizReviewList = [SELECT Id, Name, CreatedDate, CreatedById, Opportunity__r.Name, LastModifiedDate, IsPMAnswerCount__c, Opportunity__r.OpportunityCode__c, 
                                                    Description__c, Version__c, Status__c, IsAnswerCount__c, TotalQuestionCount__c, ConfirmDate__c
                                             FROM   Biz_Review__c
                                             WHERE  Id IN :bizReviewIdSet
                                                AND Status__c = 'Confirm'
                                             ORDER BY ConfirmDate__c DESC, Opportunity__c ASC, Version__c DESC
                                             LIMIT 50
                                             OFFSET :offset];
*/
        List<initWrapper> returnList = new List<initWrapper>();
        System.debug('Biz_Review__c============================getMoreData');
        System.debug(bizReviewList.size());
        Integer idx = 1;
        String LastQuestion = '';
        for(Biz_Review__c br : bizReviewList){
            System.debug(br);
            Boolean isCreater = false;
            Boolean isPm = false;
            Boolean isLock = Approval.isLocked(br.Id);
            
            if(br.CreatedById == userId || requestCheck.get(br.Id) != null) isCreater = true;
            System.debug('isCreater1 : ' + isCreater);
            // if(br.CreatedById == userId) isCreater = true;

            //if(!isCreater){
                for(Question__c q : qlist){
                    if(br.Id == q.BOBizReview__c && q.AnswerUser__c == userId){
                        isCreater = false;
                    }
                }
                System.debug('isCreater2 : ' + isCreater);
            //}
            if(pmMap.get(String.valueOf(br.Id)) != null){
                isPm = true;
                isCreater = false;
            }
            System.debug('isCreater3 : ' + isCreater);

            initWrapper iw = new initWrapper(br, isCreater, isPm, isLock);
            
            returnList.add(iw);
        }

        return returnList;
    }

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
        public Boolean isPm {get; set;}
        @AuraEnabled
        public Map<String, String> answerTypeMap {get; set;}
        @AuraEnabled
        public List<questionWrapper> questionWrapperList {get; set;}
        @AuraEnabled
        public Integer idx {get; set;}
        @AuraEnabled
        public Map<String, String> BasisMap {get; set;}
        
        public questionWrapper(Question__c question, List<Answer__c> answerList, Integer idx, Map<String, String> BasisMap) {
            this.question = question;
            this.answerList = answerList;
            this.idx = idx;
            this.BasisMap = BasisMap;
        } 

        public questionWrapper(List<questionWrapper> questionWrapperList, Biz_Review__c bizReview, Integer totalScore, Integer totalPMScore, Map<String, String> answerTypeMap, Boolean isPm) {
            this.questionWrapperList = questionWrapperList;
            this.bizReview = bizReview;
            this.totalScore = totalScore;
            this.totalPMScore = totalPMScore;
            this.answerTypeMap = answerTypeMap;
            this.isPm = isPm;
        }
    }
    
    @AuraEnabled
    public static questionWrapper getQuestionList(String Id){
        String userId = UserInfo.getUserId();
        Biz_Review__c bizReview = [SELECT Id, Description__c, TotalQuestionCount__c, IsAnswerCount__c, Version__c, CreatedById, Opportunity__c
                                   FROM Biz_Review__c 
                                   WHERE Id =: Id 
                                   LIMIT 1];
        Boolean isPm = false;
        List<Question__c> questionList = new List<Question__c>();

        User u = [SELECT Id, FederationIdentifier FROM User WHERE Id = :userId];
        List<Employee__c> empList = [SELECT Id FROM Employee__c WHERE EvUniqID__c = :u.FederationIdentifier];
        Opportunity opp = [SELECT Id, ProposalPM__c FROM Opportunity WHERE Id =: bizReview.Opportunity__c];
        if(empList.size() > 0 && empList[0].Id == opp.ProposalPM__c) {
            // Strategy Committee PM용
            System.debug('isPm');
            questionList = [SELECT Id, IsAnswer__c, Category1__c, Category2__c, IsKeyQuestion__c, DealBreakScore__c, Question__c, QuestionDetail__c, ReviewDivision__c, ShortAnswerScore__c, IsPMAnswer__c, PMShortAnswerScore__c, PMScore__c, Score__c, TotalScore__c, TotalPMScore__c
                            FROM   Question__c 
                            WHERE  BOBizReview__c = :Id
                            ORDER BY Category1__c ASC, Category2__c ASC];
            isPm = true;
        } else {
            // Strategy Committee 답변자용
            System.debug('isAnswer');
            questionList = [SELECT Id, IsAnswer__c, Category1__c, Category2__c, IsKeyQuestion__c, DealBreakScore__c, Question__c, QuestionDetail__c, ReviewDivision__c, ShortAnswerScore__c, IsPMAnswer__c, PMShortAnswerScore__c, PMScore__c, Score__c, TotalScore__c, TotalPMScore__c
                            FROM   Question__c 
                            WHERE  BOBizReview__c = :Id 
                            AND    AnswerUser__c = :userId
                            ORDER BY Category1__c ASC, Category2__c ASC];
        }
        
        List<Answer__c> answerList = [SELECT Id, Answer__c, IsPMChecked__c, ShortAnswer__c, ShortAnswerPM__c, IsChecked__c, AnswnerGroupCode__c, DealBreak__c, Score__c, BOQuestion__c, No__c, AnswerType__c,
                                             EvaluationDepartmentEvaluationBasis__c, ProposalPMEvaluationBasis__c
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

        Integer idx = 0;
        String lastQuestion = '';
        Map<String, Integer> idxMap = new Map<String, Integer>(); 
        List<questionWrapper> questionWrapperList = new List<questionWrapper>();
        for(Question__c q : questionList){
            questionWrapper qw;
            totalScore += Integer.valueOf(q.TotalScore__c);
            totalPMScore += Integer.valueOf(q.TotalPMScore__c);
            List<Answer__c> al = answerMap.get(q.Id);
            String UserBasis = '';
            String PMBasis = '';
            for(Answer__c a : al) {
                //if(a.IsChecked__c){
                    UserBasis = a.EvaluationDepartmentEvaluationBasis__c;
                //}
                //if(a.IsPMChecked__c){
                    PMBasis = a.ProposalPMEvaluationBasis__c;
                //}
            }
            Map<String, String> BasisMap = new Map<String, String>();
            BasisMap.put('User', UserBasis);
            BasisMap.put('PM', PMBasis);
            if(idxMap.get(q.Question__c) == null){
                idx = idx + 1;
                idxMap.put(q.Question__c, idx);
                qw = new questionWrapper(q, al, idx, BasisMap);
            } else {
                qw = new questionWrapper(q, al, idxMap.get(q.Question__c), BasisMap);
            }
            
            questionWrapperList.add(qw);            
        }

        Map<String, String> answerTypeMap = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Answer__c.AnswerType__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry p : ple){
            answerTypeMap.put(p.getValue(), p.getLabel());
        } 

        questionWrapper returnVal = new questionWrapper(questionWrapperList, bizReview, totalScore, totalPMScore, answerTypeMap, isPm);

        return returnVal;
    }
    
    @AuraEnabled
    public static Map<String, String> updateAnswer(List<sObject> objList){
        Map<String, String> returnMap = new Map<String, String>();
        try {
            /*
            List<Answer__c> oldAns = [SELECT Id, Answer__c, IsChecked__c, AnswnerGroupCode__c, DealBreak__c, Score__c, BOQuestion__c, No__c, AnswerType__c
                                          FROM Answer__c 
                                          WHERE Id IN :objList];
            Map<String, String> scoreMap = new Map<String, String>();
            for(Answer__c a : oldAns){
                scoreMap.put(a.Id, String.valueOf(a.Score__c));
            }
			*/
            Set<String> questionSet = new Set<String>();
            for(sObject o :objList){
                //System.debug(o);
                if(o.get('AnswerType__c') == '주관식'){
                    if(o.get('ShortAnswer__c') != null){
                        o.put('IsChecked__c', true);
                    }
                    if(o.get('ShortAnswerPM__c') != null){
                        o.put('IsPMChecked__c', true);
                    }
                }
                questionSet.add(String.valueOf(o.get('BOQuestion__c')));
            }
            update objList;
            updateQuestion(objList, questionSet);
            returnMap.put('isSuccess', 'success');
            returnMap.put('title', 'SUCCESS');
            returnMap.put('message', System.Label.STRATEGY_COMMITTEE_MSG_SUCCESS_UPDATE);
        } catch (Exception e) {
            returnMap.put('isSuccess', 'error');
            returnMap.put('title', 'FAIL');
            returnMap.put('message', String.valueOf(e));
        }
        return returnMap;
    }

    // 2021-03-04 Question__c 에 답변자 및 PM 선택답변 기록
    public static void updateQuestion(List<sObject> objList, Set<String> questionSet){
        List<Question__c> QList = [SELECT Id, PMAnswer__c, UserAnswer__c, Question__c, UserEvaluationBasis__c, PMEvaluationBasis__c FROM Question__c WHERE Id IN :questionSet];
        Map<String, String> userAnswerMap = new Map<String, String>();
        Map<String, String> PMAnswerMap = new Map<String, String>();
        Map<String, String> userBasisMap = new Map<String, String>();
        Map<String, String> PMBasisMap = new Map<String, String>();
        for(sObject s : objList){
            Answer__c a = (Answer__c) s;
            System.debug(a.IsChecked__c);
            String Useranswer = '';
            String PManswer = '';
            if(a.IsChecked__c){
                if(userAnswerMap.get(a.BOQuestion__c) == null){
                    Useranswer = a.Answer__c.stripHtmlTags();
                } else {
                    Useranswer = userAnswerMap.get(String.valueOf(a.BOQuestion__c)) + '\n';
                    Useranswer += a.Answer__c.stripHtmlTags();
                }

                if(!String.isBlank(a.EvaluationDepartmentEvaluationBasis__c) && userBasisMap.get(a.BOQuestion__c) == null) userBasisMap.put(a.BOQuestion__c, a.EvaluationDepartmentEvaluationBasis__c);

                userAnswerMap.put(String.valueOf(a.BOQuestion__c), Useranswer);
            }

            if(a.IsPMChecked__c){
                if(PMAnswerMap.get(a.BOQuestion__c) == null){
                    PManswer = a.Answer__c.stripHtmlTags();
                } else {
                    PManswer = PMAnswerMap.get(String.valueOf(a.BOQuestion__c)) + '\n';
                    PManswer += a.Answer__c.stripHtmlTags();
                }

                if(!String.isBlank(a.ProposalPMEvaluationBasis__c) && PMBasisMap.get(a.BOQuestion__c) == null) PMBasisMap.put(a.BOQuestion__c, a.ProposalPMEvaluationBasis__c);

                PMAnswerMap.put(String.valueOf(a.BOQuestion__c), PManswer);
            }

        }

        for(Question__c q : QList){

            q.UserAnswer__c = '';
            q.PMAnswer__c = '';

            //User, PM 선택답변 입력
            if(userAnswerMap.get(String.valueOf(q.Id)) != null) q.UserAnswer__c = userAnswerMap.get(String.valueOf(q.Id));
            if(PMAnswerMap.get(String.valueOf(q.Id)) != null) q.PMAnswer__c = PMAnswerMap.get(String.valueOf(q.Id));
            
            //User, PM 평가근거 입력
            if(userBasisMap.get(String.valueOf(q.Id)) != null) q.UserEvaluationBasis__c = userBasisMap.get(String.valueOf(q.Id));
            if(PMBasisMap.get(String.valueOf(q.Id)) != null) q.PMEvaluationBasis__c = PMBasisMap.get(String.valueOf(q.Id));
        }
        update QList;
    }

    @AuraEnabled
    public static Map<String, Object> getPickVal(){
        /*
        [
        {'label': '전체 기간', 'value': ''},
        {'label': '6개월', 'value': '6'},
        {'label': '1년', 'value': '12'},
        {'label': '2년', 'value': '24'},
        {'label': '3년', 'value': '36'},
        ]

        [
        {'label': 'None', 'value': ''},
        {'label': 'Participation', 'value': 'Participation'},
        {'label': 'Nonparticipation', 'value': 'Nonparticipation'},
        {'label': 'Deferral', 'value': 'Deferral'},
        ]
         */
        Map<String, Object> returnVal = new Map<String, Object>();
        try {
            List<Object> li1 = new List<Object>();
            Schema.DescribeFieldResult DecisionResult = Biz_Review__c.Decision__c.getDescribe();
            List<Schema.PicklistEntry> Decisionple = DecisionResult.getPicklistValues();
            Map<String, String> none = new Map<String, String>();
            none.put('label', System.Label.STRATEGY_COMMITTEE_LAB_ALL);
            none.put('value', '');
            li1.add(none);
            for( Schema.PicklistEntry p : Decisionple){
                System.debug(p);
                Map<String, String> obj = new Map<String, String>();
                obj.put('label', p.getLabel());
                obj.put('value', p.getValue());
                li1.add(obj);
            }
            returnVal.put('decision', li1);

            List<Object> li2 = new List<Object>();
            String label = System.label.STRATEGY_COMMITTEE_LAB_DEADLINE_PICK;
            List<String> piclist = label.split(',');
            for(String s : piclist){
                Map<String, String> obj = new Map<String, String>();
                if(String.isBlank(s.replaceAll('[^0-9]', ''))){
                    obj.put('label', s);
                    obj.put('value', '');
                } else {
                    obj.put('label', s.trim());
                    Integer month = Integer.valueOf(s.replaceAll('[^0-9]', ''));
                    obj.put('value', String.valueOf(month == 6 ? month : month*12));
                }
                li2.add(obj);
                System.debug(obj);
            }
            returnVal.put('deadline', li2);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnVal;
    }
}