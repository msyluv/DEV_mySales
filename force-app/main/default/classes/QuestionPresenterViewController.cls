/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-04-12
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   11-20-2020   Junghwa.Kim@dkbmc.com   Initial Version
**/
public without sharing class QuestionPresenterViewController {
    
    @AuraEnabled
    public static Map<String, Object> getOpportunityId(String recordId){
        Map<String, Object> returnMap = new Map<String, Object>();

        Id id = recordId;
        String objName = id.getSobjectType().getDescribe().getName();
        System.debug(objName);
        returnMap.put('objName', objName);
        if(objName == 'Opportunity') {
            returnMap.put('oppId', recordId);
        } else if(objName == 'VRBRequest__c') {
            List<VRBRequest__c> vrb = [SELECT Id, Opportunity__c, Biz_Review__c FROM VRBRequest__c WHERE Id = :recordId LIMIT 1];
            
            
            if(vrb.size() > 0){
                if(vrb[0].Biz_Review__c != null){
                    Biz_Review__c br = [SELECT Id, Status__c FROM Biz_Review__c WHERE Id = :vrb[0].Biz_Review__c];
                    if(br.Status__c == 'Confirm') {
                        returnMap.put('isEdit', false);
                        returnMap.put('oppId', String.valueOf(vrb[0].Opportunity__c));
                        returnMap.put('status', 'Confirm');
                        return returnMap;
                    }
                }
                
                if(vrb[0].Opportunity__c == null){
                    returnMap.put('oppId', 'OppIdIsNull');
                } else {
                    returnMap.put('oppId', String.valueOf(vrb[0].Opportunity__c));
                }

                if(vrb[0].Biz_Review__c == null){
                    returnMap.put('isEdit', false);
                } else {
                    returnMap.put('isEdit', true);
                    returnMap.put('bizRivewId', String.valueOf(vrb[0].Biz_Review__c));
                }
            }
        }
        return returnMap;
    }

    public class MasterQuestionWrapper{
        @AuraEnabled
        public String Id {get; set;}
        @AuraEnabled
        public String Name {get; set;}
        @AuraEnabled
        public String Category1 {get; set;}
        @AuraEnabled
        public String Category2 {get; set;}
        @AuraEnabled
        public Decimal DealBreakScore {get; set;}
        @AuraEnabled
        public Boolean IsKeyQuestion {get; set;}
        @AuraEnabled
        public String QuestionDetail {get; set;}
        @AuraEnabled
        public String Question {get; set;}
        @AuraEnabled
        public String ReviewDivision {get; set;} 
        @AuraEnabled
        public Boolean Selected {get; set;}

        public MasterQuestionWrapper(Master_Question__c m){
            this.Id = m.Id;
            this.Name = m.Name;
            this.Category1 = m.Category1__c;
            this.Category2 = m.Category2__c;
            this.DealBreakScore = m.DealBreakScore__c;
            this.IsKeyQuestion = m.IsKeyQuestion__c;
            this.QuestionDetail = m.QuestionDetail__c;
            this.Question = m.Question__c;
            this.ReviewDivision = m.ReviewDivision__c; 
            this.Selected = true;
        }

        public MasterQuestionWrapper(String Id, String Name, String Category1, String Category2, Decimal DealBreakScore, Boolean IsKeyQuestion, String QuestionDetail, String Question, String ReviewDivision, Boolean Selected){
            this.Id = Id;
            this.Name = Name;
            this.Category1 = Category1;
            this.Category2 = Category2;
            this.DealBreakScore = DealBreakScore;
            this.IsKeyQuestion = IsKeyQuestion;
            this.QuestionDetail = QuestionDetail;
            this.Question = Question;
            this.ReviewDivision = ReviewDivision; 
            this.Selected = Selected;
        }


    }
    
    @AuraEnabled
    public static List<MasterQuestionWrapper> getInit(String objName, String oppId, String recordId){
        List<MasterQuestionWrapper> returnVal = new List<MasterQuestionWrapper>();
        Boolean koreaDomestic = [SELECT Id, KoreaDomestic__c FROM Opportunity WHERE Id =: oppId LIMIT 1].KoreaDomestic__c;
        if(objName == 'Opportunity'){
            returnVal = getMasterQuestionNew(koreaDomestic);
        } else if(objName == 'VRBRequest__c'){
            VRBRequest__c brList = [SELECT Id, Biz_Review__c FROM VRBRequest__c WHERE Id = :recordId];
            if(brList.Biz_Review__c != null){
                returnVal = getMasterQuestionOld(brList.Biz_Review__c, getMasterQuestionNew(koreaDomestic));
            } else {
                returnVal = getMasterQuestionNew(koreaDomestic);
            }
        }
        
        return returnVal;
    }

    @AuraEnabled
    public static List<MasterQuestionWrapper> getMasterQuestionNew(Boolean koreaDomestic){
        List<Master_Question__c> MQList = new List<Master_Question__c>();
        if(koreaDomestic){
            // 국내사업
            MQList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                      FROM Master_Question__c 
                      WHERE BusinessDivision__c = 'KoreaDomestic'
                      // ORDER BY Category1__c ASC, Category2__c ASC];
                      ORDER BY ReviewDivision__c DESC];
        } else {
            // 해외사업
            MQList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                      FROM Master_Question__c 
                      // ORDER BY Category1__c ASC, Category2__c ASC];
                      ORDER BY ReviewDivision__c DESC];
        }
        List<String> Category1= new List<String>();
        List<String> Category2= new List<String>();

		Schema.DescribeFieldResult Category1Result = Master_Question__c.Category1__c.getDescribe();
		List<Schema.PicklistEntry> Category1ple = Category1Result.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : Category1ple){
			Category1.add(pickListVal.getLabel());
		}     
		Schema.DescribeFieldResult Category2Result = Master_Question__c.Category2__c.getDescribe();
		List<Schema.PicklistEntry> Category2ple = Category2Result.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : Category2ple){
			Category2.add(pickListVal.getLabel());
        }
        
        List<MasterQuestionWrapper> returnList = new List<MasterQuestionWrapper>();

        //String cat1 = '';
        //String cat2 = '';
        for(Master_Question__c m : MQList){
            System.debug(m.Question__c);
            
            MasterQuestionWrapper mqw = new MasterQuestionWrapper(m);
            returnList.add(mqw);
        }

        return returnList;
    }

    @AuraEnabled
    public static List<MasterQuestionWrapper> getMasterQuestionOld(String bizReviewId, List<MasterQuestionWrapper> mqwList){


        List<Question__c> QList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                                   FROM Question__c 
                                   WHERE BOBizReview__c = :bizReviewId
                                   ORDER BY ReviewDivision__c DESC];

        Map<String, Question__c> QuestionMap = new Map<String, Question__c>();
        System.debug('=====================Question__c======================');
        for(Question__c q : QList){
            String keyVal = q.Category1__c + ':' + q.Category2__c + ':' + q.Question__c + ':' + q.ReviewDivision__c;
            System.debug(keyVal);
            QuestionMap.put(keyVal, q);
        }

        List<MasterQuestionWrapper> returnVal = new List<MasterQuestionWrapper>();
        String C1;
        String C2;
        System.debug('=====================MasterQuestionWrapper======================');
        for(MasterQuestionWrapper m : mqwList){
            if(m.Category1 != ''){
                C1 = m.Category1;
            }
            if(m.Category2 != ''){
                C2 = m.Category2;
            }
            String keyVal = C1 + ':' + C2 + ':' + m.Question + ':' + m.ReviewDivision;
            System.debug((QuestionMap.get(keyVal) != null) + ' : ' + keyVal);
            Boolean isCheck = false;
            if(QuestionMap.get(keyVal) != null){
                isCheck = true;
            }
            MasterQuestionWrapper mqw = new MasterQuestionWrapper(m.Id, m.Name, m.Category1, m.Category2, m.DealBreakScore, m.IsKeyQuestion, m.QuestionDetail, m.Question, m.ReviewDivision, isCheck);
            returnVal.add(mqw);
        }
        return returnVal;
    }

    public class QuestionDetail{
        @AuraEnabled
        public String isSuccess  {get; set;}
        @AuraEnabled
        public String BizRivewId {get; set;}
        @AuraEnabled
        public Question__c question {get; set;}
        @AuraEnabled
        public List<Answer__c> answerList {get; set;}
        @AuraEnabled
        public List<QuestionDetail> questionDetailList {get; set;}
        @AuraEnabled
        public String Description {get; set;}

        public QuestionDetail(String isSuccess, String BizRivewId){
            this.isSuccess = isSuccess;
            this.BizRivewId = BizRivewId;
        }
        
        public QuestionDetail(Question__c question, List<Answer__c> answerList){
            this.question = question;
            this.answerList = answerList;
        }

        public QuestionDetail(List<QuestionDetail> questionDetailList, String isSuccess, String BizRivewId, String Description){
            this.questionDetailList = questionDetailList;
            this.isSuccess = isSuccess;
            this.BizRivewId = BizRivewId;
            this.Description = Description;
        }
    }

    @AuraEnabled
    public static QuestionDetail getQuestionDetail(List<String> recordList, String oppId, Boolean isEdit, String bizRivewId, String recordId){
        Biz_Review__c br = new Biz_Review__c();
        List<Question__c> QList = new List<Question__c>();
        Map<String, List<Answer__c>> AMap = new Map<String, List<Answer__c>>();
        List<QuestionDetail> qdlist;
        QuestionDetail AnswerMap;
        try {
            if(isEdit){
                System.debug('isEdit : true');

                List<Master_Question__c> MQList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c, ScoreStandard__c
                                                   FROM Master_Question__c 
                                                   WHERE Id IN :recordList 
                                                   ORDER BY ReviewDivision__c DESC];
				System.debug('MQList size : ' + MQList.size());
                br = [SELECT Id, Opportunity__c, Version__c, Description__c, StrategyCommitteeMethod__c FROM Biz_Review__c WHERE Id = :bizRivewId];
                QList = [SELECT Id, BOBizReview__c, AnswerUser__c, AnswerUser__r.Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                         FROM Question__c 
                         WHERE BOBizReview__c = :bizRivewId];

                Map<String, List<String>> QMap = new Map<String, List<String>>();
                for(Master_Question__c q : MQList){
                    String key = q.ReviewDivision__c + '-' + q.Question__c;
                    List<String> IdList;
                    if(QMap.get(key) == null){
                        IdList = new List<string>();
                    } else {
                        IdList = QMap.get(key);
                    }
                    String idx = String.valueOf(q.Id) + '-MQ';
                    IdList.add(idx);
                    QMap.put(key, IdList);
                }
                for(Question__c q : QList){
                    String key = q.ReviewDivision__c + '-' + q.Question__c;
                    List<String> IdList;
                    if(QMap.get(key) == null){
                        IdList = new List<string>();
                    } else {
                        IdList = QMap.get(key);
                    }
                    String idx = String.valueOf(q.Id) + '-Q';
                    IdList.add(idx);
                    QMap.put(key, IdList);
                }

                List<String> delList = new List<String>();
                List<String> addList = new List<String>();
                for(List<String> s : QMap.values()){
                    if(s.size() == 1){
                        String id = s[0].split('-')[0];
                        String type = s[0].split('-')[1];
                        if(type == 'MQ'){
                            addList.add(id);
                        } else {
                            delList.add(id);
                        }
                    }
                }

                if(delList.size() > 0) delete [SELECT Id FROM Question__c WHERE Id IN :delList];
                
                if(addList.size() > 0){
                    List<Master_Question__c> RMQList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c, ScoreStandard__c
                                                       FROM Master_Question__c 
                                                       WHERE Id IN :addList 
                                                       ORDER BY ReviewDivision__c DESC];
                    List<Master_Answer__c> RMAList = [SELECT Id, MasterQuestion__c, Answer__c, AnswerGroupCode__c, Score__c, AnswerType__c, No__c
                                                     FROM Master_Answer__c 
                                                     WHERE MasterQuestion__c IN :addList];

                    insertQuestion(RMQList, RMAList, String.valueOf(br.Id));
                }

                List<Question__c> RQList = [SELECT Id, BOBizReview__c, AnswerUser__c, AnswerUser__r.Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                                            FROM Question__c
                                            WHERE BOBizReview__c = :bizRivewId
                                            ORDER BY ReviewDivision__c DESC];

                for(Answer__c a : [SELECT BOQuestion__c, Answer__c, AnswnerGroupCode__c, DealBreak__c, IsChecked__c, Score__c FROM Answer__c WHERE BOQuestion__c IN :RQList]) {
                    List<Answer__c> AList;
                    if(AMap.get(String.valueOf(a.BOQuestion__c)) == null){
                        AList = new List<Answer__c>();
                    } else {
                        AList = AMap.get(a.BOQuestion__c);
                    }
                    AList.add(a);
                    AMap.put(String.valueOf(a.BOQuestion__c), AList);
                }
                qdlist = new List<QuestionDetail>();
                for(Question__c q : RQList){
                    List<Answer__c> al = AMap.get(q.Id);
                    QuestionDetail qd = new QuestionDetail(q, al);
                    qdlist.add(qd);
                }
                AnswerMap = new QuestionDetail(qdlist, 'true', String.valueOf(br.Id), String.valueOf(br.Description__c));
            } else {
                System.debug('isEdit : else');

				System.debug('recordList size : ' + recordList.size());
                List<Master_Question__c> MQList = [SELECT Id, Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c, ScoreStandard__c
                                                   FROM Master_Question__c 
                                                   WHERE Id IN :recordList 
                                                   ORDER BY ReviewDivision__c DESC];
				System.debug('MQList size : ' + MQList.size());
                List<Master_Answer__c> MAList = [SELECT Id, MasterQuestion__c, Answer__c, AnswerGroupCode__c, Score__c, AnswerType__c, No__c
                                                 FROM Master_Answer__c 
                                                 WHERE MasterQuestion__c IN :recordList];

                List<Biz_Review__c> versionCheck = [SELECT Id, Version__c FROM Biz_Review__c WHERE Opportunity__c =:oppId ORDER BY Version__c DESC LIMIT 1];
                List<VRBRequest__c> record = [SELECT Id, VRBMethod__c, VRBDueDate__c, Costplanningreadiness__c, OriginalPriceVersion__c FROM VRBRequest__c WHERE Id =: recordId LIMIT 1];
                System.debug(record.size());
                if(record.size() > 0){
                    br.Opportunity__c = oppId;
                    br.StrategyCommitteeMethod__c = record[0].VRBMethod__c == null ? '' : record[0].VRBMethod__c;
                    br.Status__c = 'Draft';
                    br.Version__c = versionCheck.size() == 0 ? 1 : (versionCheck[0].Version__c + 1);
                    br.DeadLine__c = record[0].VRBDueDate__c == null ? Date.today() : record[0].VRBDueDate__c;
                    br.Costplanningreadiness__c = record[0].Costplanningreadiness__c == null ? '' : record[0].Costplanningreadiness__c;
                    br.OriginalPriceVersion__c = record[0].OriginalPriceVersion__c == null ? '' : record[0].OriginalPriceVersion__c;
                    insert br;
                    Map<String, Question__c> qmap = new Map<String, Question__c>();
                    System.debug('insertQuestion before');

                    insertQuestion(MQList, MAList, String.valueOf(br.Id));

                    System.debug('insertQuestion after : ' + br.Id);
                        
                    VRBRequest__c vrb = record[0];
                    vrb.Biz_Review__c = br.Id;
                    update vrb;
                }

                List<Question__c> RQList = [SELECT Id, BOBizReview__c, AnswerUser__c, AnswerUser__r.Name, Category1__c, Category2__c, DealBreakScore__c, IsKeyQuestion__c, QuestionDetail__c, Question__c, ReviewDivision__c 
                                            FROM Question__c
                                            WHERE BOBizReview__c = :br.Id
                                            ORDER BY ReviewDivision__c DESC];

                for(Answer__c a : [SELECT BOQuestion__c, Answer__c, AnswnerGroupCode__c, DealBreak__c, IsChecked__c, Score__c FROM Answer__c WHERE BOQuestion__c IN :RQList]) {
                    List<Answer__c> AList;
                    if(AMap.get(String.valueOf(a.BOQuestion__c)) == null){
                        AList = new List<Answer__c>();
                    } else {
                        AList = AMap.get(a.BOQuestion__c);
                    }
                    AList.add(a);
                    AMap.put(String.valueOf(a.BOQuestion__c), AList);
                }
                qdlist = new List<QuestionDetail>();
                for(Question__c q : RQList){
                    List<Answer__c> al = AMap.get(q.Id);
                    QuestionDetail qd = new QuestionDetail(q, al);
                    qdlist.add(qd);
                }
                AnswerMap = new QuestionDetail(qdlist, 'true', String.valueOf(br.Id), String.valueOf(br.Description__c));
            }
        } catch (Exception e) {
            if(!isEdit){
                try {
                    delete br;
                } catch (Exception a) {
                    System.debug(a);
                }
            }
            AnswerMap = new QuestionDetail(String.valueOf(e), '');
            System.debug(e);
        }
        
        return AnswerMap;
    }

    public static void insertQuestion (List<Master_Question__c> MQList, List<Master_Answer__c> MAList, String bizId){

        List<Question__c> QList = new List<Question__c>();
        Map<String, Question__c> qmap = new Map<String, Question__c>();
        for(Master_Question__c m : MQList){
            String keyVal = m.Category1__c + ':' + m.Category2__c + ':' + m.Question__c + ':' + m.ReviewDivision__c;
            System.debug(keyVal);
            Question__c q = new Question__c();
            q.Category1__c = m.Category1__c;
            q.Category2__c = m.Category2__c;
            q.DealBreakScore__c = m.DealBreakScore__c;
            q.IsKeyQuestion__c = m.IsKeyQuestion__c;
            q.QuestionDetail__c = m.QuestionDetail__c;
            q.Question__c = m.Question__c;
            q.ReviewDivision__c = m.ReviewDivision__c;
            q.BOBizReview__c = bizId;
            q.ScoreStandard__c = m.ScoreStandard__c;
            
            qmap.put(m.Id, q);
            QList.add(q);
            //System.debug(q);
        }
        insert QList;

        Map<Id, Question__c> QListMap = new Map<Id, Question__c>(QList);

        for(Master_Question__c m : MQList){
            Question__c q =  qmap.get(m.Id);
            if(QListMap.get(q.Id) != null){
                qmap.put(m.Id,QListMap.get(q.Id));
            }
        }
        List<Answer__c> AList = new List<Answer__c>();
        for(Master_Answer__c m : MAList){
            Answer__c a = new Answer__c();
            Question__c q = qmap.get(m.MasterQuestion__c);
            a.BOQuestion__c = q.Id;
            a.Answer__c = m.Answer__c;
            a.AnswnerGroupCode__c = m.AnswerGroupCode__c;
            a.Score__c = m.Score__c;
            a.AnswerType__c = m.AnswerType__c;
            a.No__c = m.No__c;
            
            AList.add(a);
        }
        insert AList;
    }

    @AuraEnabled
    public static string deleteTemplate(String tempId, Boolean isEdit){
        try {
            Biz_Review__c br = [SELECT Id FROM Biz_Review__c WHERE Id =: tempId];
            if(!isEdit){
                delete br;
            }
        } catch (Exception e) {
            return String.valueOf(e);
        }
        return '';
    }

    @AuraEnabled
    public static String updateAnswerUser(List<Object> objList, String recordId, Boolean isEdit, String bizRivewId, String Description){
        List<Question__c> questionList = new List<Question__c>();
        try {
            for(Object o : objList){
                Map<String, Object> questionMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(o));
                //System.debug('***** updateAnswerUser *****');
                //System.debug(questionMap);

                Map<String, Object> qmap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(questionMap.get('question')));
                //System.debug(qmap);

                Question__c q = new Question__c();
                
                if(qmap.get('Id') != null && qmap.get('Id') != ''){
                    q.Id = String.valueOf(qmap.get('Id'));
                }
                if(qmap.get('AnswerUser__c') != null && qmap.get('AnswerUser__c') != ''){
                    q.AnswerUser__c = String.valueOf(qmap.get('AnswerUser__c'));
                }
                if(qmap.get('Category1__c') != null && qmap.get('Category1__c') != ''){
                    q.Category1__c = String.valueOf(qmap.get('Category1__c'));
                }
                if(qmap.get('Category2__c') != null && qmap.get('Category2__c') != ''){
                    q.Category2__c = String.valueOf(qmap.get('Category2__c'));
                }
                if(qmap.get('DealBreakScore__c') != null && qmap.get('DealBreakScore__c') != ''){
                    q.DealBreakScore__c = Decimal.valueOf(Double.valueOf(qmap.get('DealBreakScore__c')));
                }
                if(qmap.get('IsKeyQuestion__c') != null && qmap.get('IsKeyQuestion__c') != ''){
                    q.IsKeyQuestion__c = Boolean.valueOf(qmap.get('IsKeyQuestion__c'));
                }
                if(qmap.get('QuestionDetail__c') != null && qmap.get('QuestionDetail__c') != ''){
                    q.QuestionDetail__c = String.valueOf(qmap.get('QuestionDetail__c'));
                }
                if(qmap.get('Question__c') != null && qmap.get('Question__c') != ''){
                    q.Question__c = String.valueOf(qmap.get('Question__c'));
                }
                if(qmap.get('ReviewDivision__c') != null && qmap.get('ReviewDivision__c') != ''){
                    q.ReviewDivision__c = String.valueOf(qmap.get('ReviewDivision__c'));
                }
                System.debug(q);
                questionList.add(q);
            }
            
            Id id = recordId;
            String objName = id.getSobjectType().getDescribe().getName();
            if(objName == 'VRBRequest__c' && !isEdit){
                VRBRequest__c obj = [SELECT Id, Biz_Review__c FROM VRBRequest__c WHERE Id = :recordId];
                obj.Biz_Review__c = bizRivewId;
                update obj;
            }
            if(bizRivewId != null && !String.isBlank(Description)){
                Biz_Review__c br = [SELECT Id, Description__c FROM Biz_Review__c WHERE Id = :bizRivewId];
                br.Description__c = Description;
                update br;
            }
            upsert questionList;

            return 'SUCCESS';
        } catch (Exception e) {
            System.debug(e);
            return String.valueOf(e);
        }
    }
    
    @AuraEnabled
    public static void checkListConfirm(String bizReviewId){
        System.debug('::::::::::checkListConfirm:::::::::::');
        Biz_Review__c br =  [SELECT Id, Name, Status__c, ConfirmDate__c, Opportunity__c FROM Biz_Review__c WHERE Id = :bizReviewId]; 
        br.Status__c = 'Confirm';
        br.ConfirmDate__c = System.now();
        Set<String> AnswerUserIdSet = new Set<String>(); 
        for(Question__c q : [SELECT Id, AnswerUser__c FROM Question__c WHERE BOBizReview__c = :bizReviewId]){
            AnswerUserIdSet.add(q.AnswerUser__c);
        }
        
        System.debug('::::::::::PMIdSet:::::::::::');
        // get PM User Id
        Set<String> PMIdSet = new Set<String>();
        for(Opportunity opp : [SELECT Id, ProposalPM__r.EvUniqID__c FROM Opportunity WHERE Id =: br.Opportunity__c]){
            if(opp.ProposalPM__r.EvUniqID__c != null){
                PMIdSet.add(String.valueOf(opp.ProposalPM__r.EvUniqID__c));
            }
        }
        System.debug('::::::::::PMUserIdSet:::::::::::');
        
        Set<String> PMUserIdSet = new Set<String>();
        if(PMIdSet.size() > 0){
            for(User u : [SELECT Id FROM User WHERE FederationIdentifier IN :PMIdSet]){
                PMUserIdSet.add(u.Id);
            }
        }

        CustomNotificationType notificationType = [SELECT Id, DeveloperName 
                                                    FROM CustomNotificationType 
                                                    WHERE DeveloperName='Strategy_Committee_Notification'];
        
        // Create a new custom notification
        Messaging.CustomNotification notification = new Messaging.CustomNotification();          // Answer User ver
        Messaging.CustomNotification notificationPM = new Messaging.CustomNotification();        // PM User ver
 
        // Set the contents for the notification
        notification.setTitle(System.Label.STRATEGY_COMMITTEE_LAB_NOTIFICATION_TITLE);
        notificationPM.setTitle(System.Label.STRATEGY_COMMITTEE_LAB_NOTIFICATION_TITLE + ' (PM)');

        String bodyStr =  System.Label.STRATEGY_COMMITTEE_LAB_NOTIFICATION_BODY;
        bodyStr = bodyStr.replace('%RecordId%', String.valueOf(br.Name));

        notification.setBody(bodyStr);
        notificationPM.setBody(bodyStr);
 
        // Set the notification type and target
        notification.setNotificationTypeId(notificationType.Id);
        notificationPM.setNotificationTypeId(notificationType.Id);


        // 2021-02-19 notification url 상세페이지에서 탭으로 변경
        // notification.setTargetId(bizReviewId);
        // notificationPM.setTargetId(bizReviewId);
        String PageRef = '{ type: \'standard__webPage\', attributes: { url: \'/lightning/n/Strategy_Committee_CheckList\' } }';
        notification.setTargetPageRef(PageRef);
        notificationPM.setTargetPageRef(PageRef);
        
        // Actually send the notification
        String Etype = '';
        try {
            Etype = 'user answer start';
            System.debug(Etype);
            notification.send(AnswerUserIdSet);
            Etype = 'user answer end';
            System.debug(Etype);
            if(PMUserIdSet.size() > 0){
                Etype = 'user PM start';
                System.debug(Etype);
                notificationPM.send(PMUserIdSet);
                Etype = 'user PM end';
                System.debug(Etype);
            }
        }
        catch (Exception e) {
            System.debug('Problem sending notification ( ' + Etype + ' ) : ' + e.getMessage());
        }
        List<String> toList = new List<String>();
        toList.addAll(AnswerUserIdSet);
        toList.addAll(PMUserIdSet);
        
        if(!Test.isRunningTest()) OpportunityEmailAlertController.StrategyCommitteeReviewEmailSend(bizReviewId, toList);
        
        update br;
        
        upsertTeamMember(AnswerUserIdSet, br.Opportunity__c);
    }

    @AuraEnabled
    public static List<MasterQuestionWrapper> getNewChecklist(String oppId){
        List<MasterQuestionWrapper> returnVal = new List<MasterQuestionWrapper>();
        System.debug(oppId);
        try {
            Boolean koreaDomestic = [SELECT Id, KoreaDomestic__c FROM Opportunity WHERE Id =: oppId LIMIT 1].KoreaDomestic__c;
            returnVal = getMasterQuestionNew(koreaDomestic);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnVal;
    }

    @AuraEnabled
    public static List<Object> getPickVal(){
        List<Object> returnVal = new List<Object>();
        try {
            Schema.DescribeFieldResult schemaResult = Master_Question__c.ReviewDivision__c.getDescribe();

            List<Schema.PicklistEntry> ReviewDivisionple = schemaResult.getPicklistValues();
            for( Schema.PicklistEntry pickListVal : ReviewDivisionple){
                Map<String, String> picmap = new Map<String, String>();
                picmap.put('value', pickListVal.getValue());
                picmap.put('label', pickListVal.getLabel());
                returnVal.add(picmap);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnVal;
    }

    public static void upsertTeamMember(Set<String> AnswerUserIdSet, Id OpptyId){
        System.debug('upsertTeamMember');
        system.debug('### upsertTeamMember = ');
        try {
            List<OpportunityTeamMember> otList = new List<OpportunityTeamMember>();
            for(String s : AnswerUserIdSet){
                OpportunityTeamMember ot = new OpportunityTeamMember();
                ot.UserId = Id.valueOf(s);
                ot.TeamMemberRole = 'Strategy Committee Member';
                ot.OpportunityAccessLevel = 'Read';
                ot.OpportunityId = opptyId;
                String ExternalId = ot.TeamMemberRole + '_' + String.valueOf(s) + '_' + String.valueOf(opptyId);
                ot.ExternalId__c = ExternalId;
                System.debug('Opportunity TeamMember : ' + ot);
                otList.add(ot);
            }

            if(otList.size() > 0) upsert otList ExternalId__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}