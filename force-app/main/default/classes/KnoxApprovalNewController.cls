/**
 * @description       : 
 * @author            : sh.shin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-06-23
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   2020-10-22   sh.shin@dkbmc.com   Initial Version
**/
public class KnoxApprovalNewController {

    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    public static String APPROVAL_STATUS_PENDING = '1';

    /**
	* initComponent Method
    * @description  현재 Opportunity에서 임시 저장된 Approval 정보를 불러오는 Method
    * @param        opptyId : 현재 Opportunity의 RecordId
    * @return       Map<String, Object> resMap
    *               resMap.knoxApproval 현재 Opportunity에서 요청된 Approval 정보
    * 				resMap.UserKnoxInfo 접속한 User의 Employee 정보
	**/
    @AuraEnabled
    public static Map<String,Object> initComponent(Id recordId, String temp, Boolean isInit) {
        System.debug('NewKnoxApprovalController.initComponent()');        
        List<Object> tempLabelList = new List<Object>();        
        Boolean isEdit = [SELECT RecordId, HasEditAccess  FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId].HasEditAccess;
        Map<String,Object> resMap = new Map<String,Object>();  
        if(!isEdit){
            resMap.put('IsEdit', false);
        }else{           
            resMap = new Map<String,Object>(getChangeData(temp, recordId));
            
            if(isInit){
                String sqlCondition = UserInfo.getLanguage();
                Id recId = (Id)recordId;
                String obj =String.valueOf( recId.getSObjectType() );             
                //String tempName = + obj + 'ApprovalTemplate';

                String tempName = 'KnoxApproval_OpportunityActivity_ZPZ2';

                String sql = 'SELECT id, DeveloperName, Subject, Description,  HtmlValue FROM EmailTemplate ';
                        sql += 'WHERE DeveloperName = \'' + tempName + '\' AND IsActive = true  ORDER BY Name';
                       //sql += 'WHERE Description = \'' + tempName + '\' AND IsActive = true AND DeveloperName LIKE \'%' + sqlCondition + '\' ORDER BY Name';
                List<EmailTemplate> templist = Database.query(sql);
                /*
                if(templist.size() < 1){
                    templist = [SELECT id, DeveloperName, Subject, Description,  HtmlValue FROM EmailTemplate 
                                WHERE Description = :tempName AND IsActive = true AND DeveloperName LIKE '%en_US' ORDER BY Name  ];    
                }
                */
                for(EmailTemplate et :templist){
                    Map<String, String> te = new Map<String, String>();
                    te.put('label', et.Subject);
                    te.put('value', et.DeveloperName);
                    tempLabelList.add(te);
                }  
            }
                            
            resMap.put('IsEdit', true);
            resMap.put('isApproval', System.Approval.isLocked(recordId));            
            resMap.put('TemplateList', tempLabelList);                       
            resMap.put('UserKnoxInfo', Utils.getLoginEmployeeData(UserInfo.getUserId()) );
        }
        return resMap;
    }                      
    
    /**
	* initComponent Method
    * @description  전송 전 Approval 저장
	**/
    @AuraEnabled
    public static KnoxApproval__c insertApproval(Map<String, Object> approval) {

        for(String key : approval.keySet()){
            System.debug(key + ' : ' + approval.get(key));
        }
        KnoxApproval__c app = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', approval);

        System.debug('insertApproval >> ' + app);
        System.debug('1app : ' + app.Id);
        Insert app;
        System.debug('2app : ' + app.Id);
        //2021-01-11
        System.debug(app);
        return app;
    }
         
    
    @AuraEnabled
    public static void deleteApproval(Id approvalId) {
        delete [SELECT Id FROM KnoxApproval__c WHERE id = :approvalId];
    }

    /**
	* saveApproval Method
    * @description  JSON형태로 전달받은 Approval의 정보를 저장하는 메서드
    * @param        jsonParam - JSON형태로 전달받은 Approval의 정보
    * @return       Map<String, Object> resMap
    *               resMap.RESULT 			IF 결과 성공 KnoxApprovalParam.SUCCESS, 실패 KnoxApprovalParam.ERROR
    * 				resMap.knoxApproval 	성공시 Approval 정보를 리턴
    * 				resMap.knoxApprover 	성공시 ApproverList 정보를 리턴
    * 				resMap.Message 			실패시 에러메세지를 리턴
    * 				resMap.Trace 			실패시 에러 Trace를 리턴
	**/
    @AuraEnabled
    public static Map<String,Object> requestApproval(String jsonParam, List<Map<String, Object>> fileList, String tempalteName) {
        System.debug('****************** requestApproval ******************* ');
        System.debug('jsonParam : ' + jsonParam);
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
        System.debug('paramMap for loop=======================================');
            for(String a : paramMap.keySet()){
                System.debug(a + ' : ' + paramMap.get(a));
            }
            System.debug('paramMap for loop end====================================');
        System.debug('paramMap : ' + paramMap);
        //Map<String, Object> recordInfo = (Map<String, Object>)paramMap.get('RecordInfo');
        try{
            Map<String, Object> apMap = (Map<String, Object>)paramMap.get('KnoxApproval');
            System.debug('for loop=======================================');
            for(String a : apMap.keySet()){
                System.debug(a + ' : ' + apMap.get(a));
            }
            System.debug('for loop end====================================');
            KnoxApproval__c approval = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', apMap);
            System.debug(approval);
            System.debug(approval.ApprovedId__c);
            List<KnoxApprover__c> approverList = Utils.mapToSObjectList('KnoxApprover__c', (List<Object>)paramMap.get('ApproverList'));
            Employee__c requester = Utils.getLoginEmployeeData(UserInfo.getUserId());
            approval.Id = String.valueOf(apMap.get('Id'));
            // Knox Approval Helper Call
            Id recordId = (Id) approval.ApprovedId__c;
            System.debug('recordId : ' + recordId);
            String objectName =String.valueOf(recordId.getSObjectType());
            System.debug('objectName : ' + objectName);
            approval.objAPIName__c = objectName;
            tempalteName = tempalteName.replaceAll(' ','_');

            String orgUrl = '<br><p>' + Label.APPR_MSG_MORE_DETAIL + '</p>';
            orgUrl += '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + approval.ApprovedId__c + '" target="_blank">' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + approval.ApprovedId__c + '</a>';
            
            //approval.Description__c += orgUrl;
            //approval.HTML__c += orgUrl;
            Datetime dt = Utils.getCurDatetime();
            String strDateTime = dt.formatGMT('YYYYMMddHHmmss');
            approval.MISID__c = Utils.makeMisId(dt);
            
            // [IF] Input Param
            // 1. Approval 정보
            IF_KnoxApprovalSubmitController.InputClass inputParam = new IF_KnoxApprovalSubmitController.InputClass();
            inputParam.contents         = orgUrl;
            inputParam.contentsType     = 'HTML';            
            inputParam.docSecuType      = 'PERSONAL';        // fix
            inputParam.notifyOption     = '0';              // 통보옵션 (knox default : 0) [0 : 통보자통보 , 1 : 모두통보]
            inputParam.urgYn            = 'N';
            inputParam.sbmDt            = strDateTime;             // 상신일시 20190524145033 
            inputParam.timeZone         = 'GMT+0';
            inputParam.docMngSaveCode   = '0';            // 문서관리저장코드 [0 : 문서관리저장안함  , 1 : 문서관리저장함]
            inputParam.subject          = approval.Name;
            inputParam.sbmLang          = 'ko';                  // 상신언어 [ko : korean ja : japanese zh : chinese en : english]
            inputParam.importantYn      = 'N';
            inputParam.apInfId          = approval.MISID__c;     // 연계ID (32)

            // 2. Approver 상신자 리스트
            List<IF_KnoxApprovalSubmitController.aplns> aplnsList = new List<IF_KnoxApprovalSubmitController.aplns>();
            // 2-1. Approver Requester (기안자)
            IF_KnoxApprovalSubmitController.aplns requesterApln = new IF_KnoxApprovalSubmitController.aplns(
                requester.EvUniqID__c
                , requester.EvMailAddr__c.split('@')[0]
                , requester.EvMailAddr__c
                , '0'
                , '0'
                , '0'
                , 'N'
                , 'N'
                , 'N'
                , approval.Opinion__c
            );
            aplnsList.add(requesterApln);

            // 2-2. Approver (결재자 및 통보자)
            for(KnoxApprover__c approver : approverList){
                System.debug('approver');
                System.debug(approver);
                IF_KnoxApprovalSubmitController.aplns aplns = new IF_KnoxApprovalSubmitController.aplns(
                    approver.EvUniqID__c
                    , approver.EvMailAddr__c.split('@')[0]
                    , approver.EvMailAddr__c
                    , String.valueOf((Integer)approver.Index__c+1)
                    , approver.ApproverType__c
                    , approver.Status__c
                    // [2021-01-18 변경] SFDX → Knox 결재 시 Knox에서 편집할 수 없도록 결재자 권한 제거
                    //, approver.IsArbitraryDecision__c ? 'Y' : 'N'
                    //, approver.IsEditText__c ? 'Y' : 'N'
                    //, approver.IsChangeLine__c  ? 'Y' : 'N'
                    , 'N'
                    , 'N'
                    , 'N'
                    , null // Must Null
                );

                aplnsList.add(aplns);
            }
            
            inputParam.aplns = aplnsList;

            // [File List]
            List<IF_KnoxApprovalSubmitController.Attachments> attachments = new List<IF_KnoxApprovalSubmitController.Attachments>();
            IF_KnoxApprovalSubmitController.Attachments attach;
            for(Integer i=0; i < fileList.size(); i++){
                Map<String, Object> file = (Map<String, Object>)fileList[i];
                String contentType = (String)file.get('fileType');
                String fileName = (String)file.get('name');
                String contents = (String)file.get('fileContents');
                attach = new IF_KnoxApprovalSubmitController.Attachments(contentType, fileName, contents);
                attachments.add(attach);
                // [Insert attachment file]
                // Decimal filesize = Decimal.valueOf(String.valueOf(file.get('fileSize')));
                // String attachmentId = FileUploadController.saveTheFile(bUrlEncoded, approval.Id, fileName, fileCont, iconName, filesize);
            }
            if(attachments.size() > 0) {
                inputParam.attachments = attachments;
            }
                
            resMap.put('knoxApproval', approval);
            resMap.put('knoxApprover', approverList);
            System.debug('cont knoxApproval >> ' + approval);

            Map<String, Object> approvalResponse = IF_KnoxApprovalSubmitController.approvalSubmit(inputParam);
            String approvalResponseResult = (String)approvalResponse.get('result');

            // 2020-12-30 StatusCode 체크 추가
            if(approvalResponse.get('StatusCode') != 200){
                System.debug('KNOX ERROR');
                System.debug(approvalResponse.get('StatusCode'));
                resMap.put('RESULT', RES_RESULT_ERROR);
                Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)approvalResponse.get('errorDetail');
                System.debug(' approvalResponseErrorDetail : ' + (String)approvalResponseErrorDetail.get('errorMessage'));
                resMap.put('Message', (String)approvalResponseErrorDetail.get('errorMessage'));
                return resMap;
            }

            // Pass Component Result Response Map
            if(approvalResponseResult == RES_RESULT_ERROR){ 
                System.debug('KNOX ERROR');
                resMap.put('RESULT', RES_RESULT_ERROR);
                Map<String, String> approvalResponseErrorDetail = (Map<String,String>)approvalResponse.get('errorDetail');
                System.debug('@@@@@@@@@@@@@@@@@@@ : ' + (String)approvalResponseErrorDetail.get('errorMessage'));
                resMap.put('Message', (String)approvalResponseErrorDetail.get('errorMessage'));

            }else if(approvalResponseResult == RES_RESULT_SUCCESS){
                System.debug('KNOX SUCCESS');
                resMap.put('RESULT', RES_RESULT_SUCCESS);
                saveApproval(recordId, approval, approverList);
            }
        }catch(Exception e){
            
            resMap.put('Message',e.getMessage());
            resMap.put('Trace',e.getStackTraceString());
        }
        return resMap;
    }

    /**
	 * 성공 후 saveApprroval 데이터 저장
	**/
    @AuraEnabled
    public static void saveApproval(String recordId, KnoxApproval__c Knoxapproval, List<KnoxApprover__c> approverList) {
        System.debug(recordId + Knoxapproval + approverList);
        System.debug('****************** saveApproval ******************* ');
        // 상태값 진행중 처리

        Knoxapproval.Status__c = APPROVAL_STATUS_PENDING;
        if(Knoxapproval.objAPIName__c == 'Opportunity') {
            Knoxapproval.Opportunity__c = Knoxapproval.approvedId__c;
        }
        /*if(approval.objAPIName__c == 'Opportunity_Activity__c') {
            approval.Opportunity__c = approval.approvedId__c;
            approval.Opportunity_Activity__c = approval.approvedId__c;
        }*/

        for(KnoxApprover__c approver : approverList){
            approver.KnoxApproval__c = Knoxapproval.Id;
            approver.ExternalId__c = Knoxapproval.MISID__c   + '_' + approver.EvUniqID__c;
        }

        UPDATE Knoxapproval;
        INSERT approverList;

        // 임시 저장 데이터 삭제
        /*List<tempKnoxApproval__c> tempApprovalList = [SELECT Id FROM tempKnoxApproval__c WHERE RecordId__c = :recordId];
        if(tempApprovalList.size() > 0) {
            DELETE tempApprovalList;
        }*/

        List<Biz_Review__c> StrategyRecord = new List<Biz_Review__c>();
        StrategyRecord = [SELECT Id FROM Biz_Review__c WHERE Id = :recordId LIMIT 1];

        Approval.LockResult[] LockList = Approval.lock(StrategyRecord, false);

        List<Answer__c> AnswerRecord = [SELECT Id FROM Answer__c WHERE BOQuestion__r.BOBizReview__c =:recordId];
        
        Approval.lock(AnswerRecord, false);

    }
    
    /**
	* initComponent Method
    * @description  Approval 정보를 임시 저장하는 Method
    * @param        opptyId : 현재 Opportunity의 RecordId
    * @return       Map<String, Object> resMap
    *               resMap.knoxApproval 현재 Opportunity에서 요청된 Approval 정보
    * 				resMap.UserKnoxInfo 접속한 User의 Employee 정보
	**/
    @AuraEnabled
    public static void tempSaveApproval(String recordId, String jsonParam, List<Map<String, Object>> fileList) {
        System.debug('****************** tempSaveApproval ******************* ');
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
        TempKnoxApproval__c approval = (TempKnoxApproval__c)Utils.mapToSObject('TempKnoxApproval__c', (Map<String, Object>)paramMap.get('KnoxApproval'));
        List<TempKnoxApprover__c> approverList = Utils.mapToSObjectList('TempKnoxApprover__c', (List<Object>)paramMap.get('ApproverList'));

        List<TempKnoxApproval__c> temp = [select id from TempKnoxApproval__c where RecordId__c = :recordId and OwnerId = :UserInfo.getUserId() and TemplateName__c = :approval.TemplateName__c];

        if(temp.size() > 0){
            FileUploadController.delTheFile(temp[0].Id);
            approval.Id = temp[0].Id;
            DELETE [select id from TempKnoxApprover__c where TempKnoxApproval__c = :temp[0].Id];

        }
        System.debug('recordId : ' + recordId);
        System.debug('jsonParam : ' + jsonParam);
        System.debug('approverList' + approverList);

        approval.RecordId__c = recordId;

        UPSERT approval;
        System.debug('files = ' + fileList.size() + ' / ' + fileList);

        Boolean bUrlEncoded = false;
        for(Integer i=0; i < fileList.size(); i++){
            Map<String, Object> file = (Map<String, Object>) fileList[i];
           // Map<String, Object> fileinfo = (Map<String, Object>) file.get('file');

            String fileCont = (String) file.get('fileContents');

            String iconName = (String) file.get('iconName');
            String fileName = (String) file.get('name');            
            //String fileType = (String) fileinfo.get('type');            
            Decimal filesize = Decimal.valueOf(String.valueOf(file.get('fileSize')));
            
            String attachmentId = FileUploadController.saveTheFile(bUrlEncoded, approval.Id, fileName, fileCont, iconName, filesize);
            System.debug('attachmentId : ' + i + ' : ' + attachmentId);
        }
        
                    
        for(TempKnoxApprover__c approver : approverList){
            approver.TempKnoxApproval__c = approval.Id;
            //approver.ExternalId__c = approver.KnoxApproval__r.MISID__c   + '_' + approver.EvUniqID__c;
        }
        INSERT approverList;

        System.debug('insert Ok');
    }

    /*
    * @Name             : getChangeData
    * @author           : Jonggil Kim, 2019/06/26
    * @Description      : 해하는 Template HTML을 반환함.
    */
    @AuraEnabled
    public static Map<String,Object> getChangeData(String tempName, Id recordId) {
        Map<String,Object> resMap = new Map<String,Object>(); 
        KnoxApproval__c approval = new KnoxApproval__c();
        List<KnoxApprover__c> approverList = new List<KnoxApprover__c>();
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Boolean isTemp = false;
        
        List<TempKnoxApproval__c> temp = [SELECT id, Name, TemplateName__c, Template__c, Description__c, Opinion__c
                                          FROM TempKnoxApproval__c 
                                          WHERE RecordId__c = :recordId AND OwnerId = :UserInfo.getUserId() AND TemplateName__c = :tempName];
        Id recId = (Id)recordId;
        String obj =String.valueOf( recId.getSObjectType() ); 
        if(temp.size() > 0 ){
            isTemp = true;
            approval.Name =  temp[0].Name;
            //approval.Description__c =  temp[0].Description__c;
            approval.Opinion__c =  temp[0].Opinion__c;
            approval.TemplateName__c = temp[0].TemplateName__c;
            approval.Template__c = temp[0].Template__c;
            System.debug('Email Template >> ' + temp[0].Template__c );
            List<TempKnoxApprover__c> tempapper = [SELECT Index__c, Name, EvEName__c, ApproverType__c, EvSdeptNM__c, EvSdeptENM__c, EvMailAddr__c, Employee__c, EvUniqID__c, IsChangeLine__c, IsEditText__c, IsArbitraryDecision__c
                                                    FROM TempKnoxApprover__c WHERE TempKnoxApproval__c = :temp[0].id 
                                                    ORDER BY Index__c ASC, Name];
            
            for(TempKnoxApprover__c tem : tempapper){
                KnoxApprover__c teapp = new KnoxApprover__c();
                teapp.Index__c = tem.Index__c;
                teapp.Name = tem.Name;
                teapp.EvEName__c = tem.EvEName__c;
                teapp.ApproverType__c = tem.ApproverType__c;
                teapp.EvSdeptNM__c = tem.EvSdeptNM__c;
                teapp.EvSdeptENM__c = tem.EvSdeptENM__c;
                teapp.EvMailAddr__c = tem.EvMailAddr__c;
                teapp.Employee__c = (Id)tem.Employee__c;
                teapp.EvUniqID__c = tem.EvUniqID__c;
                teapp.IsChangeLine__c = tem.IsChangeLine__c;
                teapp.IsEditText__c = tem.IsEditText__c;
                teapp.IsArbitraryDecision__c = tem.IsArbitraryDecision__c;

                approverList.add(teapp);
            }

            files = FileUploadController.getFile(temp[0].id);
        }
        else{
            String description = '';
            //String Opinion = '';
            if(tempName != '-'){
                EmailTemplate empt = [SELECT id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :tempName LIMIT 1];
                List <Messaging.RenderEmailTemplateBodyResult> resList =  Messaging.renderEmailTemplate (null, recordId, new List<String>{empt.HtmlValue});   
                description = resList[0].getMergedBody();
                approval.Template__c = empt.Subject;

                System.debug('Email Template >> ' + empt );
            }                        
            resMap.put('Description', description);
            //resMap.put('Description', Opinion);
        }
        System.debug('approval >> ' + approval );
        resMap.put('knoxApproval', approval);
        resMap.put('knoxApprover', approverList);
        resMap.put('FileList', files);
        resMap.put('isTemp', isTemp);

        return resMap;
    }
    
    @AuraEnabled
    public static List<Biz_Review__c> getStrategyInfo(Id recordId){
        List<Biz_Review__c> StrategyInfo = [SELECT id, IsAnswerCount__c, IsPMAnswerCount__c, TotalQuestionCount__c, Decision__c
                                            FROM Biz_Review__c 
                                            WHERE id =: recordId];
        return StrategyInfo;
    }
    
    /*
    * @Name             : getTeamMembers
    * @author           : Jonggil Kim, 2019/06/26
    * @Description      : 해당 Object의 Team 정보를 반환함.
    */
    /*@AuraEnabled
    public static List<Object> getTeamMembers(Id recordId, List<String> EPIDList) {
        Boolean isOpportunity = false;
        Boolean isTrial = false;
        String CONST_NOTIFICATION = '9';
        List<Object> empMapList = new List<Object>();        
        String obj =String.valueOf( recordId.getSObjectType() ); 

        String userEPID = [SELECT Id, FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId()].FederationIdentifier;

        if(obj == 'Opportunity') isOpportunity = true;
        if(obj == 'TrialDemo__c') isTrial = true;
        
        if(obj.indexOf('__c') > -1 ){
            obj = obj.split('__c')[0]; 	
        }
        obj += 'TeamMember__c';
        String sqlCondition = ' NOT IN (';
        for(Integer i=0; i<EPIDList.size(); i++){
            sqlCondition += '\'' + EPIDList[i] + '\'';
            if(i != EPIDList.size()-1){
                sqlCondition += ',';
            }
        }
        if(EPIDList.size() <1) sqlCondition += '\'\'';
        sqlCondition += ')';
        String sql= '';

        if (isOpportunity) {            
            List<OpportunityTeamMember> opptyTeamList = [SELECT Id, OpportunityId, User.FederationIdentifier FROM OpportunityTeamMember WHERE OpportunityId = :recordId ];
                
            String sqlCondition2 = ' IN (';
            for(Integer i=0; i<opptyTeamList.size(); i++){
                sqlCondition2 += '\'' + opptyTeamList[i].User.FederationIdentifier + '\'';
                if(i != opptyTeamList.size()-1){
                    sqlCondition2 += ',';
                }
            }
            if(opptyTeamList.size() <1) sqlCondition2 += '\'\'';
            sqlCondition2 += ')';
            System.debug('Condition IN EPID > ' + sqlCondition2);

            sql = 'SELECT Id, Name, EvEName__c, EvSdeptENM__c, EvSdeptNM__c, EvUniqID__c, EvMailAddr__c ';
            sql += 'FROM Employee__c WHERE EvUniqID__c' + sqlCondition2  + ' AND EvUniqID__c' + sqlCondition + ' AND EvUniqID__c NOT IN (\'' + userEPID + '\')' ;
        }else if(isTrial){
            sql = 'SELECT Employee__c, Employee__r.EvEName__c, Employee__r.EvSdeptENM__c, Employee__r.Id, Employee__r.Name, Employee__r.EvSdeptNM__c, Employee__r.EvUniqID__c, Employee__r.EvMailAddr__c ';
            sql += 'FROM ' + obj + ' WHERE ParentId__c =\'' +recordId + '\' AND Employee__r.EvUniqID__c' + sqlCondition + 'AND Employee__r.EvUniqID__c NOT IN (\'' + userEPID + '\')' ;
        }else{
            sql = 'SELECT User__c, User__r.FederationIdentifier FROM ' + obj + ' WHERE ParentId__c =\'' +recordId + '\' AND User__r.FederationIdentifier' + sqlCondition + 'AND User__r.FederationIdentifier NOT IN (\'' + userEPID + '\')' ;
            List<sObject> userList = database.query(sql);

            String sqlCondition3 = ' IN (';
            for(Integer i=0; i<userList.size(); i++){
                User u = (User) userList[i].getSObject('User__r');
                sqlCondition3 += '\'' + u.FederationIdentifier + '\'';
                if(i != userList.size()-1){
                    sqlCondition3 += ',';
                }
            }
            if(userList.size() <1) sqlCondition3 += '\'\'';
            sqlCondition3 += ')';

            sql = 'SELECT Id, Name, EvEName__c, EvSdeptENM__c, EvSdeptNM__c, EvUniqID__c, EvMailAddr__c ';
            sql += 'FROM Employee__c WHERE EvUniqID__c' + sqlCondition3;

        }
        System.debug('sql > ' + sql);
        
        List<sObject> teamData = database.query(sql);            
    
        for(SObject te : teamData){
            
            Map<String, Object> empMap = new Map<String, Object>();                
            sObject emp = te;
            if (isTrial) {                  
                emp = te.getSObject('Employee__r');
            }

            empMap.put('Name', String.valueOf(emp.get('Name')));
            empMap.put('EvEName__c', String.valueOf(emp.get('EvEName__c')));
            empMap.put('EvSdeptENM__c', String.valueOf(emp.get('EvSdeptENM__c')));
            empMap.put('ApproverType__c', CONST_NOTIFICATION);
            empMap.put('EvSdeptNM__c', String.valueOf(emp.get('EvSdeptNM__c')));
            empMap.put('EvMailAddr__c', String.valueOf(emp.get('EvMailAddr__c')));
            empMap.put('Employee__c', String.valueOf(emp.get('Id')));
            empMap.put('EvUniqID__c', String.valueOf(emp.get('EvUniqID__c')));
            empMap.put('IsChangeLine__c', true);
            empMap.put('IsEditText__c', true);
            empMap.put('IsArbitraryDecision__c', false);
            empMap.put('RecpSt', 'TO');

            empMapList.add(empMap);
        }

        return empMapList;
    }*/

}