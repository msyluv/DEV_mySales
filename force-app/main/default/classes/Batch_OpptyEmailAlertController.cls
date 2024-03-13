/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-12-31
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-01-20   Junghwa.Kim@dkbmc.com   Initial Version
 * 1.1   2021-07-01   seonju.jin@dkbmc.com    PRS_Stage_Change_Email 물류 메일링 관련 확인(조치) 요청
**/
global class Batch_OpptyEmailAlertController implements Database.StateFul, Database.Batchable<sObject>, Database.AllowsCallouts {
    public final String STAGE_CHANGE = 'PRS_Stage_Change_Email';                 // BO Stage 변경 Alert 후 미변경시 강제 상태 전환
    public final String CONTRACT_START = 'Contract_notification_Email';          // 매출시작일 2주 전 계약 미진행건 Alert
    public final String CREDIT_RATING = 'Credit_rating_notification_Email';      // 매출시작일 3주 전 신용평가 미요청건 Alert
    public final String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'Logistics' AND SobjectType = 'Opportunity' LIMIT 1].Id);

    public String EMAIL_TEMP = '';
    private static List<string> pricingGroup = System.Label.EMAIL_USER_PRICING_GROUP.replaceAll(' ' , '').split(',');
    private static List<string> logisticsGroup = System.Label.EMAIL_USER_LOGISTICS_GROUP.replaceAll(' ' , '').split(',');

    private static Date sendDate = Date.today();

    public static Map<String,Object> mailresult = new Map<String,Object>(); 

    private List<Opportunity> updateOppList = new List<Opportunity>();
    private List<IF_Log.InterfaceLog> ifLog = new List<IF_Log.InterfaceLog>();
    private List<KnoxEmail__c> KnoxEmailList = new List<KnoxEmail__c>();
    public Boolean stageChangeFlag = true; // EMAIL_TEMP 이 STAGE_CHANGE인경우 Stage 값 변경 플래그
    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

    global Database.QueryLocator start(Database.BatchableContext BC){
        String selectQuery = 'SELECT Id, Name, CloseDate, AccountId, Account.Name, Owner.Name, cLeadID__r.Name, StageName, OwnerId, DeliveryRegion__c, SalesRegion__c, cRevenueStartDate__c, SalesOrganization__c, SalesOrganization__r.Name, OpportunityCode__c  ';
        String fromQuery = ' FROM Opportunity ';
        String whereQuery = '';

        System.debug('EMAIL_TEMP : ' + EMAIL_TEMP);
        
        // Stage : Z04(Solutioned), Z01(Idendified), Z02(Validated), Z03(Qualified)

        if(EMAIL_TEMP == STAGE_CHANGE) {
            whereQuery = ' WHERE ((CloseDate = ';
            whereQuery += OpportunityEmailAlertController.DateToStr(sendDate.addDays(-7), '-');
            whereQuery += ' AND StageName IN (\'Z01\', \'Z02\', \'Z03\', \'Z04\')) '; 
            whereQuery += ' OR (CloseDate = ';
            whereQuery += OpportunityEmailAlertController.DateToStr(sendDate.addDays(-14), '-');
            whereQuery += ' AND StageName IN (\'Z01\', \'Z02\', \'Z03\', \'Z04\')) '; 
            whereQuery += ' OR (CloseDate = ';
            whereQuery += OpportunityEmailAlertController.DateToStr(sendDate.addDays(-21), '-');
            whereQuery += ' AND StageName IN (\'Z01\', \'Z02\', \'Z03\', \'Z04\'))) '; 
        }
        
        if(EMAIL_TEMP == CONTRACT_START) {
            // 2021-05-25 기준변경 Sales 또는 Delivery Region : KOREA --> Sales 또는 Delivery Region : 글로벌사업팀, Cello Square사업팀, 스마트운영혁신팀 
            // whereQuery = ' WHERE (((DeliveryOrganization__r.Region__c = \'H\' OR SalesOrganization__r.Region__c = \'H\') ';
            whereQuery = ' WHERE (((SalesRegion__c IN (\'글로벌사업팀\', \'Cello Square사업팀\', \'스마트운영혁신팀\') OR DeliveryRegion__c IN (\'글로벌사업팀\', \'Cello Square사업팀\', \'스마트운영혁신팀\')) ';
            whereQuery += ' AND (StageName = \'Z04\' OR StageName = \'Z05\' OR StageName = \'Z06\')';
            whereQuery += ' AND cRevenueStartDate__c = NEXT_N_DAYS:14)';
            whereQuery += ' AND (LegalReviewNo__c = \' \' OR LegalReviewNo__c = null)) ';
        }

        if(EMAIL_TEMP == CREDIT_RATING) {
            whereQuery = ' WHERE (StageName = \'Z01\' ';
            whereQuery += ' AND LogisticsCustomerType__c = \'EXTAC\' ';  
            whereQuery += ' AND (LBSExceptionType__c = \'08\' OR LBSExceptionType__c = \'01\') ';
            whereQuery += ' AND (cRevenueStartDate__c = NEXT_N_DAYS:14 OR cRevenueStartDate__c = ';
            whereQuery += OpportunityEmailAlertController.DateToStr(sendDate.addDays(21), '-');
            whereQuery += ' )) ';
        }

        if(String.isBlank(whereQuery)) {
            throw new OpptyEmailAlertControllerException('whereQuery is Null');
        } else {
            whereQuery += ' AND RecordTypeId = \'' + recordTypeId + '\' ';
        }
        String query = selectQuery + fromQuery + whereQuery;
        if(EMAIL_TEMP == CONTRACT_START) {
            query += ' ORDER BY SalesOrganization__c DESC';
        }
        if(EMAIL_TEMP == CREDIT_RATING) {
            query += ' ORDER BY OwnerId DESC';
        }
        System.debug('111==>'+selectQuery);
        System.debug('222==>'+fromQuery);
        System.debug('333==>'+whereQuery);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :EMAIL_TEMP LIMIT 1];
        // tolist : opp Owner, Sales Org Delivery Org Branch Manager, Oppty Team
        Set<String> optyIdSet = new Set<String>();
        List<String> oppIdList = new List<String>();
        Map<String, String> ownerUserMap = new Map<String, String>();
        Map<String, Object> templateMap = new Map<String, Object>();
        Map<String, Object> oppIdMap = new Map<String, Object>();
        
        //메일 발신자
        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        // ↓ 2021-12-31 / [물류] 한수동 프로 휴직으로 인해 발신인 변경 (smart_logis@samsung.com -> mysales@samsung.com)
        if(!isSandbox) senderEmployee.EvMailAddr__c = 'mysales@samsung.com';
        else senderEmployee.EvMailAddr__c = 'yeoguri.kim@stage.partner.samsung.com';

        System.debug('============================Batch_OpptyEmailAlertController execute ===================');
        for(sobject s : scope){
            Opportunity opp = (Opportunity) s;
            System.debug('Opp Result'+opp);
            if(opp.CloseDate == sendDate.addDays(-7) || opp.CloseDate == sendDate.addDays(-14))oppIdList.add(opp.Id);
            if(EMAIL_TEMP == STAGE_CHANGE){
                //영업대표, sales team
                optyIdSet.add(opp.Id);

                if(opp.CloseDate == sendDate.addDays(-21)){
                    System.debug('Opp.id ======> '+opp.Id);
                    System.debug('before : ' + opp.StageName);

                    if(opp.StageName == 'Z03' || opp.StageName == 'Z02' || opp.StageName == 'Z01') System.debug('stage change');

                    if(opp.StageName == 'Z04') opp.StageName = 'Z06';
                    // 2021-03-15 Stage Value ZPZ2 -> Z07 으로 변경
                    if(opp.StageName == 'Z03' || opp.StageName == 'Z02' || opp.StageName == 'Z01') opp.StageName = 'Z07';
                    System.debug('after : ' + opp.StageName);
                    updateOppList.add(opp);
                }else{

                }
                
            }
            
            if(EMAIL_TEMP == CONTRACT_START){
                optyIdSet.add(opp.Id);
                List<String> oppIdMapList = oppIdMap.get(String.valueOf(opp.SalesOrganization__c)) == null ? new List<String>() : (List<String>)oppIdMap.get(String.valueOf(opp.SalesOrganization__c));
                oppIdMapList.add(opp.Id);
                oppIdMap.put(String.valueOf(opp.SalesOrganization__c), oppIdMapList);
            }
            
            if(EMAIL_TEMP == CREDIT_RATING) { 
                optyIdSet.add(opp.Id);
                List<String> oppIdMapList = oppIdMap.get(String.valueOf(opp.OwnerId)) == null ? new List<String>() : (List<String>)oppIdMap.get(String.valueOf(opp.OwnerId));
                oppIdMapList.add(opp.Id);
                oppIdMap.put(String.valueOf(opp.OwnerId), oppIdMapList);
            }
            Map<String, String> tempMap = OpportunityEmailAlertController.getEmailTemplateMap(opp, temp);
            
            ownerUserMap.put(opp.Id, opp.OwnerId);

            templateMap.put(opp.Id, tempMap);
        }

        // 2021-05-25 물류 이메일 수신자 목록중 대상에 한수동프로 추가 삭제요청시 OpportunityEmailAlertController.getUserEmailList 의 내용중 mailList.add('surong.han@samsung.com'); 제거
        Map<String, Object> UserEmail = OpportunityEmailAlertController.getUserEmailList(oppIdList, optyIdSet, ownerUserMap, EMAIL_TEMP); 
        //if(opp.CloseDate == sendDate.addDays(-7) || opp.CloseDate == sendDate.addDays(-14)){
            if(oppIdMap.isEmpty()){

                for(String s : oppIdList){
                    Map<String, String> tempMap = (Map<String, String>)templateMap.get(s);
                    // List<String> toList = UserEmail.get(s) == null ? new List<String>() : (List<String>)UserEmail.get(s);
                    List<String> toList = new List<String>();
                    //----------------------------------STAGE_CHANGE 테스트---------------------------------------------
                    /* if(Test.isRunningTest() || isSandbox){
                        if(EMAIL_TEMP == STAGE_CHANGE) toList = UserEmail.get(s) == null ? new List<String>() : (List<String>)UserEmail.get(s);
                        else toList.add('yeongju.baek@stage.partner.samsung.com');
                    }   */
                    //----------------------------------STAGE_CHANGE 테스트---------------------------------------------
                    if(Test.isRunningTest() || isSandbox) toList.add('atul.k1@samsung.com'); // 테스트 이메일 발송 //yeongju.baek@stage.partner.samsung.com
                    else toList = UserEmail.get(s) == null ? new List<String>() : (List<String>)UserEmail.get(s);
                    
                    // if(EMAIL_TEMP == CONTRACT_START){
                    //     if(pricingGroup.size() > 0) toList.addAll(pricingGroup); 
                    //     if(logisticsGroup.size() > 0) toList.addAll(logisticsGroup);
                    // }

                    List<String> ccList = new List<String>();
                    List<String> bccList = new List<String>();
                    List<Map<String, Object>> efileList = new List<Map<String, Object>>();
                    List<Map<String, String>> nfileList = new List<Map<String, String>>();
                    
                    // if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmail(Id.valueOf(s), toList, ccList, bccList, String.valueOf(tempMap.get('subject')), String.valueOf(tempMap.get('body')), efileList, nfileList, true);
                    if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, Id.valueOf(s), toList, ccList, bccList, String.valueOf(tempMap.get('subject')), String.valueOf(tempMap.get('body')), efileList, nfileList);
                    if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                    if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));
                }
            } else{
                for(String s : oppIdMap.keySet()){
                    List<String> oppIdLi = (List<String>) oppIdMap.get(s);

                    Map<String, String> tempMap = new Map<String, String>();
                    String recordId = '';
                    Set<String> setToList = new Set<String>();

                    for(String oppId : oppIdLi){
                        // Map<String, String> tempMap = (Map<String, String>)templateMap.get(s);
                        // List<String> toList = UserEmail.get(s) == null ? new List<String>() : (List<String>)UserEmail.get(s);
                        tempMap = (Map<String, String>)templateMap.get(oppId);
                        setToList.addAll(UserEmail.get(oppId) == null ? new List<String>() : (List<String>)UserEmail.get(oppId));
                        // List<String> toList = new List<String>();
                        // toList.add('yeoguri.kim@stage.partner.samsung.com');
            
                        /*
                        for(String ts : toList){
                            System.debug('toList : ' + ts);
                        }
                        */
                        // if(EMAIL_TEMP == CONTRACT_START){
                        //     if(pricingGroup.size() > 0) toList.addAll(pricingGroup);
                        //     if(logisticsGroup.size() > 0) toList.addAll(logisticsGroup);
                        // }
                        recordId = s;
                    }
                    List<String> toList = new List<String>();
                    //----------------------------------STAGE_CHANGE 테스트---------------------------------------------
                    if(Test.isRunningTest() || isSandbox){
                        if(EMAIL_TEMP == STAGE_CHANGE) toList.addAll(setToList);
                        else toList.add('yeongju.baek@stage.partner.samsung.com');
                    }  
                    //----------------------------------STAGE_CHANGE 테스트---------------------------------------------

                    //if(Test.isRunningTest() || isSandbox) toList.add('yeongju.baek@stage.partner.samsung.com');// 테스트 이메일 발송
                    else toList.addAll(setToList);
                    
                    // toList.addAll(setToList);
                    // toList.add('yeoguri.kim@stage.partner.samsung.com');
                    
                    if(EMAIL_TEMP == CONTRACT_START){
                        // if(pricingGroup.size() > 0) toList.addAll(pricingGroup);  // 2021-05-25 수신자목록중 프라이싱그룹 제거
                       if(logisticsGroup.size() > 0) toList.addAll(logisticsGroup); 
                    }
                    List<String> ccList = new List<String>();
                    List<String> bccList = new List<String>();
                    List<Map<String, Object>> efileList = new List<Map<String, Object>>();
                    List<Map<String, String>> nfileList = new List<Map<String, String>>();
                    
                    // if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmail(recordId, toList, ccList, bccList, String.valueOf(tempMap.get('subject')), String.valueOf(tempMap.get('body')), efileList, nfileList, true);
                    if(!Test.isRunningTest()) mailresult = OpportunityEmailAlertController.sendKnoxEmailMulti(senderEmployee, recordId, toList, ccList, bccList, String.valueOf(tempMap.get('subject')), String.valueOf(tempMap.get('body')), efileList, nfileList);
                    if(mailresult.get('INTERFACE_LOG') != null) ifLog.add((IF_Log.InterfaceLog)mailresult.get('INTERFACE_LOG'));
                    if(mailresult.get('KnoxEmail') != null) KnoxEmailList.add((KnoxEmail__c)mailresult.get('KnoxEmail'));
                }
            }
            System.debug('ifLog.size() : ' + ifLog.size());
            System.debug('KnoxEmailList.size() : ' + KnoxEmailList.size());
            System.debug('updateOppList.size() : ' + updateOppList.size());
            System.debug('getQueryLimit():' + Limits.getQueries() + '/' + Limits.getLimitQueries());
            System.debug('getQueryLimit():' + Limits.getSoslQueries() + '/' + Limits.getLimitSoslQueries());
        //}
    }

    global void finish(Database.BatchableContext BC){
        System.debug('::::::::::' + EMAIL_TEMP + 'batch finish::::::::::');
        System.debug('ifLog.size() : ' + ifLog.size());
        if(ifLog.size() > 0){
            IF_Log log = new IF_Log();
            log.createLog(ifLog);
        }

        System.debug('KnoxEmailList.size() : ' + KnoxEmailList.size());
        if(KnoxEmailList.size() > 0) insert KnoxEmailList;

        System.debug('updateOppList.size() : ' + updateOppList.size());
        System.debug('stageChangeFlag : ' + stageChangeFlag);
        if(stageChangeFlag && updateOppList.size() > 0) update updateOppList;

        if(EMAIL_TEMP == STAGE_CHANGE){
            Batch_OpptyEmailAlertController bo = new Batch_OpptyEmailAlertController();
            bo.EMAIL_TEMP = CONTRACT_START;
            bo.stageChangeFlag = stageChangeFlag;
            DataBase.executeBatch( bo, 50);
        }
        if(EMAIL_TEMP == CONTRACT_START){
            Batch_OpptyEmailAlertController bo = new Batch_OpptyEmailAlertController();
            bo.EMAIL_TEMP = CREDIT_RATING;
            bo.stageChangeFlag = stageChangeFlag;
            DataBase.executeBatch( bo, 50);
        }
        
    }

    public class OpptyEmailAlertControllerException extends Exception {}
    /*
    배치 데이터 조회
String recordTypeId = String.valueOf([SELECT Id FROM RecordType WHERE DeveloperName = 'Logistics' AND SobjectType = 'Opportunity' LIMIT 1].Id);
Date sendDate = Date.today();

String selectQuery = 'SELECT Id, Name, CloseDate, AccountId, Account.Name, Owner.Name, cLeadID__r.Name, StageName, OwnerId, DeliveryRegion__c, SalesRegion__c, cRevenueStartDate__c  ';
String fromQuery = ' FROM Opportunity ';
String whereQuery1 = '';
String whereQuery2 = '';
String whereQuery3 = '';

whereQuery1 = ' WHERE ((CloseDate = ';
whereQuery1 += OpportunityEmailAlertController.DateToStr(sendDate.addDays(-14), '-');
whereQuery1 += ' AND StageName IN (\'Z01\', \'Z02\', \'Z03\', \'Z04\')) '; 
whereQuery1 += ' OR (CloseDate = ';
whereQuery1 += OpportunityEmailAlertController.DateToStr(sendDate.addDays(-21), '-');
whereQuery1 += ' AND StageName IN (\'Z01\', \'Z02\', \'Z03\', \'Z04\'))) '; 

whereQuery2 = ' WHERE (((SalesRegion__c IN (\'글로벌사업팀\', \'Cello Square사업팀\', \'스마트운영혁신팀\') OR DeliveryRegion__c IN (\'글로벌사업팀\', \'Cello Square사업팀\', \'스마트운영혁신팀\')) ';
whereQuery2 += ' AND (StageName = \'Z04\' OR StageName = \'Z05\' OR StageName = \'Z06\')';
whereQuery2 += ' AND cRevenueStartDate__c = NEXT_N_DAYS:14)';
whereQuery2 += ' AND (LegalReviewNo__c = \' \' OR LegalReviewNo__c = null)) ';

whereQuery3 = ' WHERE (StageName = \'Z01\' ';
whereQuery3 += ' AND LogisticsCustomerType__c = \'EXTAC\' ';  
whereQuery3 += ' AND (LBSExceptionType__c = \'08\' OR LBSExceptionType__c = \'01\') ';
whereQuery3 += ' AND (cRevenueStartDate__c = NEXT_N_DAYS:14 OR cRevenueStartDate__c = ';
whereQuery3 += OpportunityEmailAlertController.DateToStr(sendDate.addDays(21), '-');
whereQuery3 += ' )) ';

String recordtype = ' AND RecordTypeId = \'' + recordTypeId + '\' ';

System.debug('++++++++++WHERE QUERY1++++++++++');
System.debug('WHERE QUERY : ' + whereQuery1);
System.debug('상태변경');
for(Opportunity o : Database.query(selectQuery + fromQuery + whereQuery1 + recordtype)){
    if(o.CloseDate == sendDate.addDays(-14)) System.debug('-14' + o);
    else if(o.CloseDate == sendDate.addDays(-21)) System.debug('-21' + o);
    else System.debug('none' + o);
}
System.debug('++++++++++WHERE QUERY2++++++++++');
System.debug('WHERE QUERY : ' + whereQuery2);
System.debug('매출시작일 2주전');
for(Opportunity o : Database.query(selectQuery + fromQuery + whereQuery2 + recordtype + ' ORDER BY SalesOrganization__c DESC')){
    System.debug(o);
}
System.debug('++++++++++WHERE QUERY3++++++++++');
System.debug('WHERE QUERY : ' + whereQuery3);
System.debug('신용평가 미진행건');
for(Opportunity o : Database.query(selectQuery + fromQuery + whereQuery3 + recordtype + ' ORDER BY OwnerId DESC')){
    if(o.cRevenueStartDate__c == sendDate.addDays(21)) System.debug('21' + o);
    else if(o.cRevenueStartDate__c <= sendDate.addDays(14)) System.debug('14' + o);
    else System.debug('none' + o);
}
    */
}