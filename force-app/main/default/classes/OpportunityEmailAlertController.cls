/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-12-31
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   12-30-2020   Junghwa.Kim@dkbmc.com   Initial Version
 * 1.1   2021-07-01   seonju.jin@dkbmc.com    PRS_Stage_Change_Email 물류 메일링 관련 확인(조치) 요청
**/
public class OpportunityEmailAlertController {
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    
    //물류 이메일 템플릿
    public static String STAGE_CHANGE = 'PRS_Stage_Change_Email';
    public static String CONTRACT_START = 'Contract_notification_Email';
    public static String CREDIT_RATING = 'Credit_rating_notification_Email';

    //물류 이메일 레포트
    public static String CONT_START = 'Contract_notification_Email_Report';
    public static String CREDIT_RATING_D14 = 'Credit_Rating_Notification_Email_D141';
    public static String CREDIT_RATING_D21 = 'Credit_Rating_Notification_Email_D211';

    //본사 이메일 템플릿
    public static String VRB_REVIEW_EMAIL = 'VRBReviewEmail';
    public static String VRB_EMAIL = 'VRBEmail';

    public static Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public static Map<String, Report> reportMap = getReportMap();

    public static FunctionSwitch__c funSW = FunctionSwitch__c.getInstance(UserInfo.getUserId()); 
    public static Boolean EmailSend = funSW.KnoxEmailSend__c;

    // Opportunity 물류
    public static Map<String, String> getEmailTemplateMap(Opportunity opp, EmailTemplate temp) {
        System.debug('temp Name : ' + temp.DeveloperName);
        Map<String, String> bodyMap = new Map<String, String>();
        String subject = String.valueOf(temp.Subject);
        String body = String.valueOf(temp.HtmlValue).replace('\r\n', '');
        String url = '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/';

        Date closeDate = opp.CloseDate;
        Date today = Date.today();
        
        String closeDateStr = DateToStr(closeDate, '-');
        String stageChangeDateStr = DateToStr(closeDate.addDays(21), '-');
        
        if(temp.DeveloperName == STAGE_CHANGE) {    // BO Stage 변경 Alert 후 미변경시 강제 상태 전환
            String branchName = String.isBlank(opp.SalesOrganization__r.Name) ? '' : opp.SalesOrganization__r.Name ;
            subject = subject.replace('{!Sales Branch}', (String.isBlank(opp.SalesOrganization__r.Name) ? '' : '['+ opp.SalesOrganization__r.Name + ']'));

            String nameStr = (String.isBlank(opp.Name) ? '' : opp.Name) + (String.isBlank(branchName) ? '' : ' of ' + branchName);
            body = body.replace('{!Name1}', nameStr);
            body = body.replace('{!Name2}', (String.isBlank(opp.Name) ? '' : opp.Name));
            body = body.replace('{!Id}', opp.OpportunityCode__c);   //20210701 OpportunityCode__c 추가
            body = body.replace('{!stageChangeDate}', stageChangeDateStr);
            body = body.replace('{!AccountId}', (String.isBlank(opp.Account.Name) ? '' : opp.Account.Name));
            body = body.replace('{!Owner}', (String.isBlank(opp.Owner.Name) ? '' : opp.Owner.Name));
            body = body.replace('{!CloseDate}', closeDateStr);

            if(opp.StageName == 'Z04') body = body.replace('{!Status}', 'Lost');
            if(opp.StageName == 'Z03' || opp.StageName == 'Z02' || opp.StageName == 'Z01') body = body.replace('{!Status}', 'Drop');
            url += String.valueOf(opp.Id);
            url += '" target="_blank">Link to Opportunity </a>';
        } else if(temp.DeveloperName == CONTRACT_START){    //매출시작일 2주 전 계약 미진행건 Alert
            url += reportMap.get(CONT_START).Id;
            url += '" target="_blank">Link to Report </a>';
        } else if(temp.DeveloperName == CREDIT_RATING){     //매출시작일 3주 전 신용평가 미요청건 Alert
            if(today.addDays(21) == opp.cRevenueStartDate__c) url += reportMap.get(CREDIT_RATING_D21).Id;
            else url += reportMap.get(CREDIT_RATING_D14).Id;
            url += '" target="_blank">Link to Report </a>';
        }

        System.debug('url:' + url);

        bodyMap.put('subject', subject);
        bodyMap.put('body', body.replace('{!URL}',url));
        bodyMap.put('recordId' ,opp.Id);

        return bodyMap;
    }

    public static Map<String, Report> getReportMap(){
        List<string> reportDevNmList = new List<String>{
            CONT_START, CREDIT_RATING_D14, CREDIT_RATING_D21
        };

        Map<String,Report> reportMap = new Map<String,Report>{
            CONT_START => new Report(),
            CREDIT_RATING_D14 => new Report(),
            CREDIT_RATING_D21 => new Report()
        };

        try {
            List<Report> lr = [SELECT Id, Name, FolderName, DeveloperName FROM Report WHERE FolderName = 'Opportunity Email Reports' AND DeveloperName IN :reportDevNmList];

            for(Report report : lr){
                reportMap.put(report.DeveloperName, report);
            }
        } catch (Exception e) {
            System.debug(e);
        }

        return reportMap;
    }

    public static Map<String, Object> getSalesTeamUser(Set<String> opptId) {

        Map<String, Object> returnMap = new Map<String, Object>();

        for(OpportunityTeamMember ot : [SELECT Id, OpportunityId, UserId FROM OpportunityTeamMember WHERE OpportunityId IN :opptId]){
            List<String> otList = (List<String>)(returnMap.get(ot.OpportunityId) == null ?  new List<String>() : returnMap.get(ot.OpportunityId));
            otList.add(ot.UserId);
            returnMap.put(ot.OpportunityId, otList); 
        }

        return returnMap;
    }

    public static Map<String, Object> getOrgManagerUser(Set<String> opptId) {
        Map<String, Object> returnMap = new Map<String, Object>();

        for(Opportunity opp : [SELECT Id, DeliveryOrganization__r.BranchManager__c, SalesOrganization__r.BranchManager__c FROM Opportunity WHERE Id IN :opptId]){
            List<String> ManagerList = new List<String>();
            if(opp.DeliveryOrganization__c != null && opp.DeliveryOrganization__r.BranchManager__c != null) ManagerList.add(opp.DeliveryOrganization__r.BranchManager__c);
            if(opp.SalesOrganization__c != null && opp.SalesOrganization__r.BranchManager__c != null) ManagerList.add(opp.SalesOrganization__r.BranchManager__c);
            
            returnMap.put(opp.Id, ManagerList); 
        }

        return returnMap;
    }

    public static Map<String, Object> getUserEmailList(List<String> oppIdList, Set<String> optyIdSet, Map<String, String> ownerUserMap, String emailTemp) {
        System.debug('====================getUserEmailList=====================');
        Map<string, Object> returnMap = new Map<String, Object>();
        Map<string, Object> userListMap = new Map<String, Object>();
        List<String> allUser = new List<String>();

        Map<String, Object> salesTeamUser = optyIdSet.size() > 0 ? getSalesTeamUser(optyIdSet) : new Map<String, Object>();
        Map<String, Object> orgManagerUser = optyIdSet.size() > 0 ? getOrgManagerUser(optyIdSet) : new Map<String, Object>();

        for(String s : oppIdList){
            List<String> UserList = new List<String>();

            if(ownerUserMap.get(s) != null) UserList.add(ownerUserMap.get(s));
            if(salesTeamUser.get(s) != null && emailTemp == STAGE_CHANGE) UserList.addAll((List<String>)salesTeamUser.get(s));
            // if(orgManagerUser.get(s) != null && emailTemp != CREDIT_RATING) UserList.addAll((List<String>)orgManagerUser.get(s));  // Stage 변경건에 대해 부서장 추가 요청시 사용
            if(orgManagerUser.get(s) != null && emailTemp == CONTRACT_START) UserList.addAll((List<String>)orgManagerUser.get(s));  // Stage 변경건에 대해 부서장 추가 요청시 제거

            allUser.addAll(UserList);
            userListMap.put(s, UserList);
        }

        Map<String, String> userMap = new Map<String, String>();
        for(User u : [SELECT Id, FederationIdentifier FROM USER WHERE Id IN :allUser]){
            System.debug('user : ' + u);
            System.debug('userFederationIdentifier : ' + u.FederationIdentifier);
            userMap.put(u.Id, u.FederationIdentifier);
        }
        Map<String, String> empMap = new Map<String, String>();
        System.debug('====================emailToList=====================');
        for(Employee__c e : [SELECT Id, EvUniqID__c, EvMailAddr__c FROM Employee__c WHERE EvUniqID__c IN :userMap.values()]){
            System.debug('employee : ' + e.EvMailAddr__c);
            if(isSandbox && e.EvMailAddr__c.contains('stage')) empMap.put(e.EvUniqID__c, e.EvMailAddr__c);          
            if(!isSandbox) empMap.put(e.EvUniqID__c, e.EvMailAddr__c);
            //empMap.put('M210604062833C6V6804', 'kj78.yu@partner.samsung.com');
        }

        for(String s : oppIdList){
            List<String> mailList = new List<String>();
            List<String> UserList = (List<String>)userListMap.get(s);
            for(String us : UserList){
                mailList.add(empMap.get(userMap.get(us)));
            }

            // ↓ 2021-12-31 / [물류] 한수동 프로 휴직으로 인해 주석처리
            // mailList.add('surong.han@samsung.com'); // 2021-05-25 물류 이메일 수신자 목록중 대상에 한수동프로 추가 요청시 삭제처리

            returnMap.put(s, mailList);
        }

        return returnMap;
    }

    public static String DateToStr(Date convertDate, String split) {
        String yyyy = String.valueOf(convertDate.year());
        String mm = convertDate.month() < 10 ? ('0' + convertDate.month()) : String.valueOf(convertDate.month());
        String dd = convertDate.day() < 10 ? ('0' + convertDate.day()) : String.valueOf(convertDate.day());
        String dateStr = yyyy + split + mm + split + dd;
        return dateStr;
    }

    public static String getReport(String devName) {
        try {
            System.debug('getTemplate devName : ' + devName);
            List<Report> lr = [SELECT Id, Name, FolderName, DeveloperName FROM Report];
            System.debug(lr.size());
            Report report = [SELECT Id, Name, FolderName, DeveloperName FROM Report WHERE FolderName = 'Opportunity Email Reports' AND DeveloperName = :devName LIMIT 1];

            return String.valueOf(report.Id);
        } catch (Exception e) {
            System.debug(e);
            return '';
        }
    }

    // Opportunity 본사
    @future(callout = true)
    public static void StrategyCommitteeRequestEmailSend(String recordId) {
        System.debug('::::::::::StrategyCommitteeRequestEmailSend::::::::::');
        System.debug(recordId);
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :VRB_EMAIL LIMIT 1];
        VRBRequest__c br = [SELECT Id, Opportunity_Activity__c, VRBDueDate__c, Opportunity__c, VRBRequester__c, OwnerId, Name FROM VRBRequest__c WHERE Id = :recordId];
        Opportunity opp = [SELECT Id, OpportunityCode__c, Name, Description FROM Opportunity WHERE Id = :br.Opportunity__c];
        Opportunity_Activity__c oa = [SELECT Id, toLabel(TransactionName__c) toLabel_TransactionName__c FROM Opportunity_Activity__c WHERE Id =: br.Opportunity_Activity__c];
        
        System.debug('1');
        //System.debug(temp);
        List<String> toList = new List<String>();
        // toList.add('dong00.kim@stage.partner.samsung.com');

        List<String> epidList = new List<String>();
        for(User u : [SELECT Id, FederationIdentifier FROM User WHERE Id = :br.OwnerId OR Id = :br.VRBRequester__c]){
            epidList.add(String.valueOf(u.FederationIdentifier));
        }
        System.debug('2');
        for(Employee__c e : [SELECT Id, EvUniqID__c, EvMailAddr__c FROM Employee__c WHERE EvUniqID__c IN :epidList]){
            if(isSandbox && e.EvMailAddr__c.contains('stage')) toList.add(e.EvMailAddr__c);
            
            if(!isSandbox) toList.add(e.EvMailAddr__c);
        }
        String oppcode = (opp.OpportunityCode__c == null ? '' : opp.OpportunityCode__c);
        String oppdesc = (opp.Description == null ? '' : opp.Description);
        String body = String.valueOf(temp.HtmlValue);
        body = body.replace('{!Biz_Review__c.ConfirmDate__c}', DateToStr(Date.today(), '. '));
        body = body.replace('{!Opportunity.OpportunityCode__c}', oppcode);
        body = body.replace('{!Opportunity.Name}',opp.Name);
        body = body.replace('{!DeadLine}', DateToStr(Date.valueOf(br.VRBDueDate__c), '. '));
        body = body.replace('{!Opportunity.Link}', System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + br.Opportunity__c);
        body = body.replace('{!Biz_Review__c.Link}', System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + br.Id);
        
        // [&VRB&해당 Activity명&VRB checklist assessment request]&BO code&BO Description
        // [{!Name} {!ActivityName} checklist assessment request]{!OppCode}{!OppDescription}
        String subject = temp.Subject;
        subject = subject.replace('{!Name}', br.Name);
        subject = subject.replace('{!OppCode}', oppcode);

        System.debug(':::::::::::::subject:::::::::::::');
        System.debug(subject);

        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();

        //System.debug(body);
        System.debug(':::::::::::::TOList:::::::::::::');
        for(String s : toList){
            System.debug(s);
        }
        system.debug('### StrategyCommitteeRequestEmailSend :: toList = '+ toList);
        system.debug('### StrategyCommitteeRequestEmailSend :: body = '+ body);
        if(!Test.isRunningTest()) sendKnoxEmail(Id.valueOf(recordId), toList, ccList, bccList, subject, body, efileList, nfileList, false);
        
    }
    @future(callout = true)
    public static void StrategyCommitteeReviewEmailSend(String recordId, List<String> toListUser) {
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :VRB_REVIEW_EMAIL LIMIT 1];
        String optyId = String.valueOf([SELECT Id, Opportunity__c FROM Biz_Review__c WHERE Id = :recordId].Opportunity__c);
        Biz_Review__c br = [SELECT Id, Opportunity__c, Name, DeadLine__c FROM Biz_Review__c WHERE Id = :recordId];
        VRBRequest__c vrb = [SELECT Id, Opportunity_Activity__c FROM VRBRequest__c WHERE Biz_Review__c = :recordId];
        Opportunity opp = [SELECT Id, OpportunityCode__c, Description FROM Opportunity WHERE Id =: br.Opportunity__c];
        Opportunity_Activity__c oa = [SELECT Id, toLabel(TransactionName__c) toLabel_TransactionName__c FROM Opportunity_Activity__c WHERE Id =: vrb.Opportunity_Activity__c];
        
        List<String> toList = new List<String>();

        Opportunity opty = [SELECT Id, ProposalPM__c, OpportunityCode__c, Name, Description FROM Opportunity WHERE Id = :br.Opportunity__c];
        List<String> epidList = new List<String>();
        for(User u : [SELECT Id, FederationIdentifier FROM User WHERE Id IN :toListUser]){
            epidList.add(String.valueOf(u.FederationIdentifier));
        }
        for(Employee__c e : [SELECT Id, EvUniqID__c, EvMailAddr__c FROM Employee__c WHERE EvUniqID__c IN :epidList OR Id = :opty.ProposalPM__c]){
            toList.add(e.EvMailAddr__c);
        }
        String body = String.valueOf(temp.HtmlValue).replace('\r\n', '');
        String subject = String.valueOf(temp.Subject);

        String bourl =  System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + opty.Id;
        String vrburl =  System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + recordId;
        String sendDate = DateToStr(Date.today(), '. ');
        String deadLine = DateToStr(br.DeadLine__c, '. ');
        String optyCode = opty.OpportunityCode__c == null ? '' : opty.OpportunityCode__c;
        String optyDesc = opty.Description == null ? '' : opty.Description;
        String optyName = opty.Name == null ? '' : opty.Name;

        body = body.replace('{!SendDate}', sendDate);
        body = body.replace('{!BOCode}', optyCode);
        body = body.replace('{!BOName}', optyName);
        body = body.replace('{!DeadLine}', deadLine);
        body = body.replace('{!BOUrl}', bourl);
        body = body.replace('{!VRBUrl}', vrburl);
        System.debug('::::: body :::::');
        //System.debug(body);

        System.debug('::::: subject :::::');
        
        // [&VRB& 해당 Activity명&VRB checklist assessment request]&BO code&BO Description
        subject = subject.replace('{!Name}', br.Name);
        subject = subject.replace('{!OppCode}', optyCode);
        System.debug(subject);

        List<String> ccList = new List<String>();
        List<String> bccList = new List<String>();
        List<Map<String, Object>> efileList = new List<Map<String, Object>>();
        List<Map<String, String>> nfileList = new List<Map<String, String>>();

        //System.debug(body);
        Map<String,Object> mailReturnMap = new Map<String,Object>();
        if(!Test.isRunningTest()) sendKnoxEmail(Id.valueOf(recordId), toList, ccList, bccList, subject, body, efileList, nfileList, false);
        
    }
    /**
	* sendKnoxEmail   Method
    * @description    이메일 발송
    * @Id             대상 SObject 레코드 Id
    * @toList         받는 사람 
    * @ccList         참조자
    * @bccList        숨은 참조자
    * @subject        제목
    * @description    보내는 내용
    * @efileList      파일목록
    * @return         String Knox 이메일 객체 결과 정보
	*
    **/

    public static Map<String,Object> sendKnoxEmail( Id recordId, List<String> toList, List<String> ccList, 
                                            List<String> bccList ,String subject,  String description, 
                                             List<Map<String, Object>> efileList, List<Map<String, String>> nfileList, Boolean isMulti){

        Map<String,Object> resMap = new Map<String,Object>();

        Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();

        bodyMap.subject = subject;
        bodyMap.contents = description;
        // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
        bodyMap.contentType = 'HTML';
        // doSecuType : 1) PERSONAL : 개인, 2) OFFICIAL : 공문
        bodyMap.docSecuType = 'PERSONAL';
        bodyMap.sfdcId = recordId;

        // 2021-02-05 InputClass isMulti val 추가
        bodyMap.isMulti = isMulti;
        System.debug('isMulti : ' + isMulti);
        System.debug('before : ' + senderEmployee.EvMailAddr__c);
        
        // ↓ 2021-12-31 / [물류] 한수동 프로 휴직으로 인해 발신인 변경 (smart_logis@samsung.com -> mysales@samsung.com)
        if(!isSandbox) senderEmployee.EvMailAddr__c = 'mysales@samsung.com';
        else senderEmployee.EvMailAddr__c = 'yeoguri.kim@stage.partner.samsung.com';
        
        System.debug('============sendknoxemail============');
        System.debug('after : ' + senderEmployee.EvMailAddr__c);
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        bodyMap.sender = sender;

        // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        for(String t : toList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
            System.debug('TO : ' + r);
            recipientsList.add(r);
        }

        for(String t : ccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'CC');
            System.debug('CC : ' + r);
            recipientsList.add(r);
        }

        for(String t : bccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'BCC');
            System.debug('BCC : ' + r);
            recipientsList.add(r);
        }
        bodyMap.recipients = recipientsList;

        List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
        for(Map<String, Object> file : efileList){
            System.debug(file.get('file'));
            IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments('file', String.valueOf(file.get('name')), String.valueOf(file.get('fileContents')));
            System.debug('attachments : ' + attachments);
            attachmentsList.add(attachments);
        }
        bodyMap.attachments = attachmentsList;

        System.debug('bodyMap : ' + bodyMap);

        Map<String,Object> response = new Map<String, Object>();
        if(!Test.isRunningTest()){
            if(EmailSend){
                response = IF_KnoxEmailSendController.send(bodyMap);

                if(isMulti){
                    // IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog) response.get('INTERFACE_LOG');
                    // IF_Log log = new IF_Log();
                    // log.createLog(ifLog);
                    resMap.put('INTERFACE_LOG', response.get('INTERFACE_LOG'));
                }
            }
        } else {
            response.put('result', RES_RESULT_SUCCESS);
            response.put('mailId', 'testMailId');
        }
        System.debug(response);
                                                 
        for(String s : response.keySet()){
            System.debug('keyVal : ' + s);
        }

        String responseResult = String.valueOf(response.get('result') == null ? '' : response.get('result'));
        System.debug(responseResult);
        if(responseResult == RES_RESULT_ERROR){
            resMap.put('result', RES_RESULT_ERROR);
            
            Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)response.get('errorDetail');
            resMap.put('Message', String.valueOf(approvalResponseErrorDetail.get('errorMessage')));

        }else if(responseResult == RES_RESULT_SUCCESS){
            resMap.put('result', RES_RESULT_SUCCESS);

            String knoxEmailId = String.valueOf(response.get('mailId'));
            if(isMulti){
                resMap.put('KnoxEmail', KnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId));
            } else {
                insertKnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId);
            }
        }
        return resMap;
    }

    /**
     * KnoxEmail 레코드별 전송
     */
    public static Map<String,Object> sendKnoxEmailMulti(Employee__c senderEmployee, Id recordId, List<String> toList, List<String> ccList, 
                                            List<String> bccList ,String subject,  String description, 
                                             List<Map<String, Object>> efileList, List<Map<String, String>> nfileList){

        Map<String,Object> resMap = new Map<String,Object>();

        // Employee__c senderEmployee = Utils.getLoginEmployeeData(UserInfo.getUserId());
        IF_KnoxEmailSendController.InputClass bodyMap = new IF_KnoxEmailSendController.InputClass();

        bodyMap.subject = subject;
        bodyMap.contents = description;
        bodyMap.contentType = 'HTML';       // contentType : 1) TEXT : 텍스트, 2) MIME : 마임, 3) HTML : HTML
        bodyMap.docSecuType = 'PERSONAL';   // doSecuType : 1) PERSONAL : 개인, 2) OFFICIAL : 공문
        bodyMap.sfdcId = recordId;
        bodyMap.isMulti = true;
        
        System.debug('============sendknoxemail============');
        System.debug('after : ' + senderEmployee.EvMailAddr__c);
        IF_KnoxEmailSendController.Sender sender = new IF_KnoxEmailSendController.Sender(senderEmployee.EvMailAddr__c.split('@')[0], senderEmployee.EvMailAddr__c);
        bodyMap.sender = sender;

        // recipientType : 1) 수신 : TO, 2) 참조 : CC, 3) 비밀참조 : BCC
        List<IF_KnoxEmailSendController.Recipients> recipientsList = new List<IF_KnoxEmailSendController.Recipients>();
        for(String t : toList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'TO');
            System.debug('TO : ' + r);
            recipientsList.add(r);
        }

        for(String t : ccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'CC');
            System.debug('CC : ' + r);
            recipientsList.add(r);
        }

        for(String t : bccList){
            IF_KnoxEmailSendController.Recipients r = new IF_KnoxEmailSendController.Recipients(t, 'BCC');
            System.debug('BCC : ' + r);
            recipientsList.add(r);
        }
        bodyMap.recipients = recipientsList;

        List<IF_KnoxEmailSendController.Attachments> attachmentsList = new List<IF_KnoxEmailSendController.Attachments>();
        for(Map<String, Object> file : efileList){
            System.debug(file.get('file'));
            IF_KnoxEmailSendController.Attachments attachments = new IF_KnoxEmailSendController.Attachments('file', String.valueOf(file.get('name')), String.valueOf(file.get('fileContents')));
            System.debug('attachments : ' + attachments);
            attachmentsList.add(attachments);
        }
        bodyMap.attachments = attachmentsList;
        System.debug('bodyMap : ' + bodyMap);

        Map<String,Object> response = new Map<String, Object>();
        if(!Test.isRunningTest()){
            if(EmailSend){
                response = IF_KnoxEmailSendController.send(bodyMap);
                resMap.put('INTERFACE_LOG', response.get('INTERFACE_LOG'));
            }
        } else {
            response.put('result', RES_RESULT_SUCCESS);
            response.put('mailId', 'testMailId');
        }
        System.debug(response);
        for(String s : response.keySet()){
            System.debug('keyVal : ' + s);
        }

        String responseResult = String.valueOf(response.get('result') == null ? '' : response.get('result'));
        System.debug(responseResult);
        if(responseResult == RES_RESULT_ERROR){
            resMap.put('result', RES_RESULT_ERROR);
            
            Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)response.get('errorDetail');
            resMap.put('Message', String.valueOf(approvalResponseErrorDetail.get('errorMessage')));

        }else if(responseResult == RES_RESULT_SUCCESS){
            resMap.put('result', RES_RESULT_SUCCESS);

            String knoxEmailId = String.valueOf(response.get('mailId'));
            resMap.put('KnoxEmail', KnoxEmailObj(recordId, senderEmployee.Id, toList, ccList, bccLIst, subject, description, knoxEmailId));
        }
        return resMap;
    }


    public static void insertKnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
                                    String subject,  String description, String knoxEmailId){
        KnoxEmail__c knoxEmail = new KnoxEmail__c(
            RecordId__c = recordId
            , Sender__c = senderEmpId
            , ToAddress__c = String.join(toList, ',')
            , CcAddress__c = String.join(ccList, ',')
            , BccAddress__c = String.join(bccList, ',')
            , Name = subject
            , HtmlBody__c = description
            , MailId__c = knoxEmailId
            , Status__c = 'Send'
        );

        if(recordId != null) {
            String objApiName =String.valueOf(recordId.getSObjectType()); 
            if(objApiName == 'Opportunity') knoxEmail.Opportunity__c = recordId;
        }

        insert knoxEmail;
    }

    public static KnoxEmail__c KnoxEmailObj(Id recordId, String senderEmpId, List<String> toList, List<String> ccList, List<String> bccList,
                                    String subject,  String description, String knoxEmailId){
        KnoxEmail__c knoxEmail = new KnoxEmail__c(
            RecordId__c = recordId
            , Sender__c = senderEmpId
            , ToAddress__c = String.join(toList, ',')
            , CcAddress__c = String.join(ccList, ',')
            , BccAddress__c = String.join(bccList, ',')
            , Name = subject
            , HtmlBody__c = description
            , MailId__c = knoxEmailId
            , Status__c = 'Send'
        );

        if(recordId != null) {
            String objApiName =String.valueOf(recordId.getSObjectType()); 
            if(objApiName == 'Opportunity') knoxEmail.Opportunity__c = recordId;
        }

        return knoxEmail;
    }
}