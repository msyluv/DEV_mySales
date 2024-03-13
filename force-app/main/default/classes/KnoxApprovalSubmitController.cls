/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-10   dongyoung.kim@dkbmc.com   Initial Version
 * 1.1   2021-03-26   hj.lee@dkbmc.com          [협업 BO 최초 수주품의 Activity 제어] copyCollaboContractApproval 로직 추가 
 * 1.2   2021-04-21   hj.lee@dkbmc.com          결재 상신 시 Opportunity Owner 를 기안자로 하여 상신 (AS-IS : 로그인 유저)
 * 1.3   2021-05-26   hj.lee@dkbmc.com          [IF-079] Knox 상신 호출시, 명시적인 오류가 아닌 경우 Record 저장하도록 변경 (response {"result" : "fail"} 받은 경우 제외)
 * 1.4   2022-08-01   hyunhak.roh@dkbmc.com     결재건 Delete 부분에 대해 케이스를 구분하는 param을 추가하고 해당 로그를 남김
 * 1.5   2023-05-20   anish.jain@partner.samsung.com     Add Log for checking abnormal Knox Approval - MS 198
 * 1.6   2023-08-24   anish.jain@partner.samsung.com     Add Log for checking Knox Approval error (status is null) - MS 283
 * 1.7   2023-10-17   atul.k1@samsung.com   Mysales-318  
 * 1.8   2023-10-23   anish.jain@partner.samsung.com   Mysales-315 
 * 1.9   2023-11-08   vikrant.ks@samsung.com    Save attachment on mySales when raising bo review approval(Mysales-350) Part of MS-216
 * 2.0   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
public class KnoxApprovalSubmitController {
    
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    public static String RES_RESULT_TEMP_SAVE = 'tempsave';
    public static String APPROVAL_STATUS_PENDING = '1';
    public static String opptyCode; //Added by Anish - v 1.5
    public static String oppCC; //Added by Anish - v 1.5
    public static String oppActTN; //Added by Anish - v 1.5

    /**
    * initComponent Method
    * @description  현재 Opportunity에서 임시 저장된 Approval 정보를 불러오는 Method
    * @param        opptyId : 현재 Opportunity의 RecordId
    * @return       Map<String, Object> resMap
    *               resMap.knoxApproval 현재 Opportunity에서 요청된 Approval 정보
    *               resMap.UserKnoxInfo 접속한 User의 Employee 정보
    **/
    @AuraEnabled
    public static Map<String,Object> initComponent(Id recordId, String temp, Boolean isInit, String opptyactId, String MISID) {
        System.debug('**** KnoxApprovalSubmitController.initComponent()');        
        System.debug('# recordId : ' + recordId);
        System.debug('# UserInfo.getUserId() : ' + UserInfo.getUserId());
        
        List<Object> tempLabelList = new List<Object>();

        Opportunity_Activity__c opptyAct = [SELECT Id, WhatId__c, WhatId__r.OwnerId, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c, TransactionName__c FROM Opportunity_Activity__c WHERE id = :opptyactId LIMIT 1];  //Modified by Anish - v 1.5
        String opptyId = opptyAct.WhatId__c;
        String opptyOwnerId = opptyAct.WhatId__r.OwnerId;
      
        System.debug('# opptyOwnerId : ' + opptyOwnerId);

        // [2021-04-12 수정] Profile 에서 Opportunity Edit 권한이 없는경우, Opportunity Team Member Edit Access 권한이 있어도 Profile Object 권한 우선으로 HasEditAccess 권한이 없음
        // Opportunity Team Member 권한 체크 추가
        Boolean isEdit_Object = [SELECT RecordId, HasEditAccess  FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId].HasEditAccess;
        List<OpportunityTeamMember> opptyTeamMembers = [
            SELECT  OpportunityAccessLevel 
            FROM    OpportunityTeamMember  
            WHERE   UserId = :UserInfo.getUserId() 
                    AND OpportunityId = :opptyId
                    AND (OpportunityAccessLevel = 'Edit' or OpportunityAccessLevel = 'All')
        ];
        Boolean isEdit_TeamMember = (opptyTeamMembers.size() > 0);
        Boolean isEdit = (isEdit_Object || isEdit_TeamMember);

        Map<String, Profile> adminProflieMap = new Map<String, Profile>([SELECT  Id
                                                                        FROM    Profile
                                                                        WHERE   Name Like '%System Admin%' or Name = '시스템 관리자' OR Name = 'PI (Biz. Owner)']);
        Boolean isAdminProfile = adminProflieMap.containsKey(UserInfo.getProfileId());

        // Label에 등록된 Test Date 일자까지 모든 유저에게 Admin 권한을 줌 (결재선 삭제 가능함)
        Date today = Date.today();
        Date testDate = Util_String.convertStringHyphenFormatToDate(System.Label.COMM_VAL_TEST_DATE);
        if(today <= testDate) { 
            isAdminProfile = true;
        }
        
        Map<String,Object> resMap = new Map<String,Object>();  
        if(!isEdit){
            resMap.put('IsEdit', false);
        }else{           
            resMap = new Map<String,Object>(getChangeData(temp, recordId, opptyactId));
            // V1.7 MySales-318
            string userLang = UserInfo.getLanguage();
            if(isInit){
                String sqlCondition = UserInfo.getLanguage();
                Id recId = (Id)recordId;
                String obj = String.valueOf( recId.getSObjectType() );  
                            
                String tempName = 'KnoxApproval_OpportunityActivity_' + opptyAct.TransactionName__c;
                System.debug('tempName : ' + tempName);
                String sql = 'SELECT id, DeveloperName, Subject, HtmlValue FROM EmailTemplate ';
                        sql += 'WHERE DeveloperName = \'' + tempName + '\' AND IsActive = true  ORDER BY Name';

                List<EmailTemplate> templist = Database.query(sql);
                for(EmailTemplate et :templist){
                    Map<String, String> te = new Map<String, String>();
                    te.put('label', et.Subject);
                    te.put('value', et.DeveloperName);
                    tempLabelList.add(te);
                }  
            }
            
            resMap.put('IsEdit', true);
            // resMap.put('isApproval', System.Approval.isLocked(recordId)); 
            resMap.put('isApproval', false); // (2021-01-05 수정) Oppty Record Approval.Lock 상태여도 상신 가능
            resMap.put('isAdminProfile', isAdminProfile);
            resMap.put('TemplateList', tempLabelList);
            // V1.7 MySales-318
            resMap.put('CurrentUserlang', userLang);
            // [2021-04-21 수정] 결재 상신 시 Opportunity Owner 를 기안자로 하여 상신 (AS-IS : 로그인 유저)
            // resMap.put('UserKnoxInfo', Utils.getLoginEmployeeData(UserInfo.getUserId()) );
            resMap.put('UserKnoxInfo', Utils.getLoginEmployeeData(UserInfo.getUserId()) ); //Added by Anish - v 2.0
        }
        return resMap;
    }         
    
    /**
    * initComponent Method
    * @description  전송 전 Approval 저장
    **/
    @AuraEnabled
    public static KnoxApproval__c insertApproval(Map<String, Object> approval, String opptyactId) {   //Modified by Anish - v 1.5
        KnoxApproval__c knox = new KnoxApproval__c(); //Added by Anish - v 1.5
        try {     //Shifted Try Block - Anish - V 1.6
        Opportunity_Activity__c opptyAct = [SELECT Id, WhatId__c, WhatId__r.OwnerId, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c, TransactionName__c FROM Opportunity_Activity__c WHERE id = :opptyactId LIMIT 1];  //Added by Anish - v 1.5
        opptyCode = opptyAct.WhatId__r.OpportunityCode__c; //Added by Anish - v 1.5
        oppCC = opptyAct.WhatId__r.CompanyCode__c;   //Added by Anish - v 1.5
        oppActTN = opptyAct.TransactionName__c;    //Added by Anish - v 1.5
        
            for(String key : approval.keySet()){
                System.debug(key + ' : ' + approval.get(key));
            }
            KnoxApproval__c app = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', approval);
            app.ExecutionTime__c = System.Now();    // Added by Anish - v 1.8
    
            Insert app;
            
            knox = [SELECT Id, Name, Status__c, Opportunity__c, Opportunity__r.OpportunityCode__c, Opportunity__r.CompanyCode__c, OpportunityActivity__c, OpportunityActivity__r.TransactionName__c, BizReview__c, ApprovedId__c, Opinion__c, Description__c, syncFlag__c, HTML__c, TemplateName__c , Template__c, MISID__c FROM KnoxApproval__c WHERE Id = :app.Id]; //Modified by Anish - v 1.5
            createInterfaceLog3('insertApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + knox.syncFlag__c + ', Status : ' + knox.Status__c + '\n' + '1. Insert KnoxApproval : Success , Id : ' + knox.Id , 'S'); //Added by Anish - v 1.5
            return knox;

        } catch (Exception e) {
            createInterfaceLog3('insertApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + knox.syncFlag__c + ', Status : ' + knox.Status__c + '\n' + '1. Insert KnoxApproval : Failed, detailed fail message :' +e.getStackTraceString()  + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 1.5
            throw new AuraHandledException(e.getMessage());
        }
    }
     
    
    @AuraEnabled
    public static void deleteApproval(Id approvalId, String deleteFlag) {
        KnoxApproval__c rowKnoxApproval = new KnoxApproval__c(); //Shifted by Anish - V 1.6
        try{ //Added by Anish - V 1.6
        String strLogFlag = '';
        System.debug('### KnoxApprovalSubmitController, deleteApproval, deleteFlag = ' + deleteFlag);
        
        System.debug('### KnoxApprovalSubmitController, deleteApproval, KnoxApproval__c Completed.');
        rowKnoxApproval = [SELECT Id, Opportunity__r.CompanyCode__c,OpportunityActivity__r.TransactionName__c, Opportunity__r.OpportunityCode__c,syncFlag__c,Status__c FROM KnoxApproval__c WHERE id = :approvalId LIMIT 1]; //Added by Anish - v 1.6
        
        //로그 상세.
        strLogFlag = rowKnoxApproval.Opportunity__r.OpportunityCode__c + ', ' + deleteFlag;
        
        //Status__c 값이 null 또는 '' 이면 IF-079 실패로 Status값이 InProgress 로 변경되지 않음. 삭제처리함.
        if(rowKnoxApproval.Status__c == null || rowKnoxApproval.Status__c == ''){
            strLogFlag += ', Deleted';
            
            DELETE rowKnoxApproval;
        }
        
        //2022-08-01, hyunhak.roh@dkbmc.com, 결재건 Delete 부분에 대해 케이스를 구분하는 param을 추가하고 해당 로그를 남김
        String INTERFACE_ID = 'KNOXAPPROVALSUBMIT_DELETE';
        String APEX_CLASS   = 'KnoxApprovalSubmitController';
        String METHOD_NAME  = 'deleteApproval';
        
        String guId = IF_Util.generateGuid();
        
        Map<String,Object> ifLogMap = new Map<String,Object>{
            'IF_Log' => null
        };
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        
        ifLogMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, strLogFlag, 'KnoxApprovalSubmitController, deleteApproval'));
        
        IF_Log.InterfaceLog ifChkLog = (IF_Log.InterfaceLog)ifLogMap.get('IF_Log');
        ifLogList.add(ifChkLog);
        
        System.debug('### KnoxApprovalSubmitController, deleteApproval, ifLogList = ' + ifLogList);
        
        IF_Log log = new IF_Log();
        for(IF_Log.InterfaceLog ifLog : ifLogList){
            System.debug('### KnoxApprovalSubmitController, deleteApproval = ' + ifLog);
            log.createLog(ifLog);
        }
        }
        //Start- Added by Anish - V 1.6
        catch(exception e){
         createInterfaceLog3('insertApproval', 'BO_CODE : '+rowKnoxApproval.Opportunity__r.OpportunityCode__c + ', COMPANY_CODE : ' + rowKnoxApproval.Opportunity__r.CompanyCode__c+ ', TR : ' + rowKnoxApproval.OpportunityActivity__r.TransactionName__c + ', SyncFlag : ' + rowKnoxApproval.syncFlag__c + ', Status : ' + rowKnoxApproval.Status__c + '\n' + '1. Delete KnoxApproval : Failed, detailed fail message :' +e.getStackTraceString()  + ' Message : ' + e.getMessage() , 'F'); 
         throw new AuraHandledException(e.getMessage());   
        }
        //End- Added by Anish - V 1.6
    }

    /**
    * saveApproval Method
    * @description  JSON형태로 전달받은 Approval의 정보를 저장하는 메서드
    * @param        jsonParam - JSON형태로 전달받은 Approval의 정보
    * @return       Map<String, Object> resMap
    *               resMap.RESULT           IF 결과 성공 KnoxApprovalParam.SUCCESS, 실패 KnoxApprovalParam.ERROR
    *               resMap.knoxApproval     성공시 Approval 정보를 리턴
    *               resMap.knoxApprover     성공시 ApproverList 정보를 리턴
    *               resMap.Message          실패시 에러메세지를 리턴
    *               resMap.Trace            실패시 에러 Trace를 리턴
    **/
    @AuraEnabled
    public static Map<String,Object> requestApproval(String jsonParam, List<Map<String, Object>> fileList, String tempalteName, String approvalHTML, Boolean isSuccessCollaboValid, String collaboApprovalTypeCode, String opptyactId) { //Modified by Anish - v 1.5
        Map<String,Object> resMap = new Map<String,Object>(); //Shifted by Anish - V 1.6
        KnoxApproval__c approval = new KnoxApproval__c(); //Added by Anish - v 1.5 //Shifted by Anish - V 1.6
        try{ //Shifted by Anish - V 1.6
        System.debug('****************** requestApproval ******************* ');
        system.debug('### KnoxApprovalSubmitController :: requestApproval :: isSuccessCollaboValid = ' + isSuccessCollaboValid);
        System.debug('jsonParam : ' + jsonParam);
        Opportunity_Activity__c opptyAct = [SELECT Id, WhatId__c, WhatId__r.OwnerId, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c, TransactionName__c FROM Opportunity_Activity__c WHERE id = :opptyactId LIMIT 1];  //Added by Anish - v 1.5
        opptyCode = opptyAct.WhatId__r.OpportunityCode__c; //Added by Anish - v 1.5
        oppCC = opptyAct.WhatId__r.CompanyCode__c;   //Added by Anish - v 1.5
        oppActTN = opptyAct.TransactionName__c;    //Added by Anish - v 1.5
        
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
 
        
        System.debug('paramMap : ' + paramMap);
        //Map<String, Object> recordInfo = (Map<String, Object>)paramMap.get('RecordInfo');
        
            Map<String, Object> apMap = (Map<String, Object>)paramMap.get('KnoxApproval');
            approval = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', apMap); //Modified by Anish - v 1.5
          
            System.debug(' knox approval :  ' + approval);
            List<KnoxApprover__c> approverList = Utils.mapToSObjectList('KnoxApprover__c', (List<Object>)paramMap.get('ApproverList'));
            
            // [2021-04-21 수정] 결재 상신 시 Opportunity Owner 를 기안자로 하여 상신 (AS-IS : 로그인 유저)
            // Employee__c requester = Utils.getLoginEmployeeData(UserInfo.getUserId());
            String opptyOwnerId = [SELECT OwnerId FROM Opportunity WHERE Id = :approval.Opportunity__c LIMIT 1].OwnerId;
            
            Employee__c requester = Utils.getLoginEmployeeData(UserInfo.getUserId()); //Added by Anish - v 2.0
            approval.Id = String.valueOf(apMap.get('Id'));
            approval.Status__c = KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS; // 상태값 진행
            
            // Knox Approval Helper Call
            Id recordId = (Id) approval.ApprovedId__c;
            System.debug('### recordId : ' + recordId);
            if(!String.isBlank(recordId)) {
                String objectName =String.valueOf(recordId.getSObjectType());
                System.debug('objectName : ' + objectName);
                approval.objAPIName__c = objectName;
            }
            
            tempalteName = tempalteName.replaceAll(' ','_');

            String orgUrl = '<br><p>' + Label.APPR_MSG_MORE_DETAIL + '</p>';
            orgUrl += '<a href="' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + approval.ApprovedId__c + '" target="_blank">' + System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + approval.ApprovedId__c + '</a>';
         
            approval.Description__c = '';

            // [❗❗] 결재상신 중 ' 문자가 있는 경우 Error , I/F 데이터 중 싱글쿼터를 더블쿼터로 변경하여 보냄
            // approvalHTML = approvalHTML.replace('\'', '\"');
            // approval.Opinion__c = approval.Opinion__c.replace('\'', '\"');

            approval.HTML__c = approvalHTML;
            //approval.Opinion__c += orgUrl;
            Datetime dt = Utils.getCurDatetime();
            String strDateTime = dt.formatGMT('YYYYMMddHHmmss');

            //2021.06.01 수정 - 본문조회(preview) 시 만들어지는 MISID를 사용해야한다. 바로 상신 진행할 때만 MISID 생성
            System.debug('MISID 생성여부:' +  String.isNotEmpty(approval.MISID__c));
            if(String.isEmpty(approval.MISID__c)){
                approval.MISID__c = Utils.makeMisId(dt);    // 외부 시스템용 결재 ID 생성
                System.debug('MISID 생성:' + approval.MISID__c);
            }
            // [IF] Input Param
            // 1. Approval 정보
            IF_KnoxApprovalSubmitController.InputClass inputParam = new IF_KnoxApprovalSubmitController.InputClass();
            inputParam.contents         = approvalHTML; //  결재 본문 Html Body
            inputParam.contentsType     = 'HTML';            
            inputParam.docSecuType      = 'PERSONAL';            // fix
            inputParam.notifyOption     = '0';                   // 통보옵션 (knox default : 0) [0 : 통보자통보 , 1 : 모두통보]
            inputParam.urgYn            = 'N';
            inputParam.sbmDt            = strDateTime;           // 상신일시 20190524145033 
            inputParam.timeZone         = 'GMT+0';
            inputParam.docMngSaveCode   = '0';                   // 문서관리저장코드 [0 : 문서관리저장안함  , 1 : 문서관리저장함]
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
                , '0'       // 기안자 seq : 0
                , '0'
                , '0'
                // [2021-01-18 변경] SFDX → Knox 결재 시 Knox에서 편집할 수 없도록 결재자 권한 제거
                , 'N'
                , 'N'
                , 'N' 
                , approval.Opinion__c
            );
            aplnsList.add(requesterApln);

            // 2-2. Approver (결재자 및 통보자)
            for(KnoxApprover__c approver : approverList){
                IF_KnoxApprovalSubmitController.aplns aplns = new IF_KnoxApprovalSubmitController.aplns(
                    approver.EvUniqID__c
                    , approver.EvMailAddr__c.split('@')[0]
                    , approver.EvMailAddr__c
                    , String.valueOf((Integer)approver.Index__c)
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

            // 기안자 KnoxApprover__c Object Record 추가
            KnoxApprover__c requesterApprover = new KnoxApprover__c(
                Index__c = 0
                , Name = requester.Name
                , EvEName__c = requester.EvEName__c
                , ApproverType__c = '0'
                , EvSdeptNM__c = requester.EvSdeptNM__c
                , EvSdeptENM__c = requester.EvSdeptENM__c
                , EvMailAddr__c = requester.EvMailAddr__c
                , Employee__c = requester.Id
                , EvUniqID__c = requester.EvUniqID__c
                , IsChangeLine__c = false
                , IsEditText__c = false
                , IsArbitraryDecision__c = false
                , IsGetApprovalLine__c = false
                , Status__c = '0'
                // , Opinion__c = approval.Opinion__c
            );
            approverList.add(requesterApprover);
            
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
            System.debug(' ##### Start IF_KnoxApprovalSubmitController ' );
            
            Map<String, Object> approvalResponse = IF_KnoxApprovalSubmitController.approvalSubmit(inputParam);
            createInterfaceLog3('requestApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + approval.syncFlag__c + ', Status : ' + 'Processing' + '\n' + '2. Before Request IF-079 Id : ' + approval.Id + ' ,MISID : ' + approval.MISID__c , 'S'); //Added by Anish - v 1.5
            System.debug('========================= approvalResponse =========================');
            System.debug('##### ' + approvalResponse);
            System.debug('==================================================');

            // 2020-12-30 StatusCode 체크 추가
            /*
            if(approvalResponse.get('StatusCode') != 200){
                Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)approvalResponse.get('errorDetail');
                System.debug(' approvalResponseErrorDetail : ' + (String)approvalResponseErrorDetail.get('errorMessage'));

                resMap.put('RESULT', RES_RESULT_ERROR);
                resMap.put('Message', (String)approvalResponseErrorDetail.get('errorMessage'));
                return resMap;
            }
            */

            if(approvalResponse.get('StatusCode') != 200 || test.isRunningTest()){
                /**
                 * [2021-05-26]  Knox 상신 I/F 호출시, 명시적인 response Error가 아닌 경우에도 Record 저장하도록 변경 (response {"result" : "fail"} 받은 경우 제외)
                 *  Knox 시스템에서 결재가 생성되었으나, jitterbit에서 성공메시지를 주지 않는 이슈로 인해 Salesforce에서 이력을 남기기위해 Record 저장하도록 함
                 */
                // [2021-08-24 주석] System.debug('[Temporary Save] The result value of the "if-079" interface was not received normally.');
                // [2021-08-24 주석] resMap.put('RESULT', RES_RESULT_TEMP_SAVE);
                // [2021-08-24 주석] saveApproval(recordId, approval, approverList, isSuccessCollaboValid, collaboApprovalTypeCode);

                /**
                 * [2021-08-24] JitterBit에서 성공메시지를 주지않는 이슈가 해결되었다고하여 Record를 저장하지 않도록 수정
                 */
                Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)approvalResponse.get('errorDetail');
                //System.debug(' approvalResponseErrorDetail : ' + (String)approvalResponseErrorDetail.get('errorMessage'));
                
                resMap.put('RESULT', RES_RESULT_ERROR);
                if(approvalResponseErrorDetail != null && approvalResponseErrorDetail.containsKey('errorMessage') ){    //Added by Anish - v 1.5
                resMap.put('Message', (String)approvalResponseErrorDetail.get('errorMessage'));
                }
                createInterfaceLog3('requestApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + approval.syncFlag__c + ', Status : ' + 'Processing' + '\n' + '3. After Request IF-079 : Failed, Id : ' + approval.Id + ' ,MISID : ' + approval.MISID__c + ' ,detailed fail message : '+ resMap.get('Message')  , 'F'); //Added by Anish - v 1.5

            } else {
                String approvalResponseResult = (String)approvalResponse.get('result');
                
                // Pass Component Result Response Map
                if(approvalResponseResult == RES_RESULT_ERROR){ 
                    System.debug('### KNOX ERROR');
                    Map<String, Object> approvalResponseErrorDetail = (Map<String,Object>)approvalResponse.get('errorDetail');
                    System.debug(' approvalResponseErrorDetail : ' + (String)approvalResponseErrorDetail.get('errorMessage'));

                    resMap.put('RESULT', RES_RESULT_ERROR);
                    resMap.put('Message', (String)approvalResponseErrorDetail.get('errorMessage'));
                    createInterfaceLog3('requestApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + approval.syncFlag__c + ', Status : ' + 'Processing' + '\n' + '3. After Request IF-079 : Failed, Id : ' + approval.Id + ' ,MISID : ' + approval.MISID__c + ' ,detailed fail message : '+ resMap.get('Message')  , 'F'); //Added by Anish - v 1.5

                }else if(approvalResponseResult == RES_RESULT_SUCCESS){
                    System.debug('### KNOX SUCCESS');
                    resMap.put('RESULT', RES_RESULT_SUCCESS);
                    
                    saveApproval(recordId, approval, approverList, isSuccessCollaboValid, collaboApprovalTypeCode);
                    createInterfaceLog3('requestApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + approval.syncFlag__c + ', Status : ' + 'Processing' + '\n' + '3. After Request IF-079 : Success, Id : ' + approval.Id + ' ,MISID : ' + approval.MISID__c , 'S'); //Added by Anish - v 1.5
                }
            }

        }catch(Exception e){
            createInterfaceLog3('requestApproval', 'BO_CODE : '+opptyCode + ', COMPANY_CODE : ' + oppCC + ', TR : ' + oppActTN + ', SyncFlag : ' + approval.syncFlag__c + ', Status : ' + 'Processing' + '\n' + '3. After Request IF-079 : Failed, Id : ' + approval.Id + ' ,MISID : ' + approval.MISID__c + ' ,detailed fail message : '+ e.getStackTraceString()  + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 1.5
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            resMap.put('RESULT', RES_RESULT_ERROR);
            resMap.put('Message',e.getMessage());
            resMap.put('Trace',e.getStackTraceString());
        }
        return resMap;
    }

    /**
     * 성공 후 saveApprroval 데이터 저장
    **/
    @AuraEnabled
    public static void saveApproval(Id recordId, KnoxApproval__c approval, List<KnoxApprover__c> approverList, Boolean isSuccessCollaboValid, String collaboApprovalTypeCode) {
        System.debug('****************** saveApproval ******************* ');
        System.debug(' isSuccessCollaboValid : ' + isSuccessCollaboValid);
        System.debug(' collaboApprovalTypeCode : ' + collaboApprovalTypeCode);
        System.debug('****************** saveApproval ******************* ');        

        // SavePoint 지정
        Savepoint sp = Database.setSavepoint();
        /**
         * Setting Knox Approval Lookup
         */
        try {
            String sObjectName = recordId.getSObjectType().getDescribe().getName();
            System.debug('sObjectName : ' + sObjectName);
            
            approval.Status__c = APPROVAL_STATUS_PENDING; // 상태값 진행중 처리
            if(sObjectName == 'Biz_Review__c') {
                approval.BizReview__c = recordId;
            }
            if(approval.objAPIName__c == 'Opportunity') {
                approval.Opportunity__c = approval.approvedId__c;
            }

            for(KnoxApprover__c approver : approverList){
                approver.KnoxApproval__c = approval.Id;
                approver.ExternalId__c = approval.MISID__c   + '_' + approver.EvUniqID__c;
            }
            approval.RecordTypeId = KnoxApproval__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Origin').getRecordTypeId(); 
            system.debug(' approval.RecordTypeId : ' +  approval.RecordTypeId);
            UPDATE approval;
            INSERT approverList;

            // 임시 저장 데이터 삭제
            List<tempKnoxApproval__c> tempApprovalList = [SELECT Id FROM tempKnoxApproval__c WHERE RecordId__c = :recordId];
            if(tempApprovalList.size() > 0) {
                DELETE tempApprovalList;
            }

            /**
             * ────────── 법인 + 본사 동시 상신 로직 ──────────
             */
            //수정 전 로직
            /*
            if(isSuccessCollaboValid) {
                Opportunity oppty = [SELECT Id, CollaborationBOId__c FROM Opportunity WHERE Id = :recordId];
                // [Insert Knox Approval] 법인의 최초 수주 품의 완결 전 인 경우, 법인의 Knox Approval-Knox Approver 를 복사하여 본사 Knox Approval 을 생성
                System.debug( ' ## Original Approval : ' +  approval);
                System.debug( ' ## Original Approval.Id : ' +  approval.Id);
                Id collaboApprovalId = copyCollaboContractApproval(oppty.CollaborationBOId__c, collaboApprovalTypeCode, approval);
                callout_if135(collaboApprovalId); // copy knox 결재중 처리
            }
            */
            
            // 수정 후 로직
             if(isSuccessCollaboValid) {
                Opportunity oppty = [SELECT Id, CollaborationBOId__c FROM Opportunity WHERE Id = :recordId];
                // [Insert Knox Approval] 법인의 최초 수주 품의 완결 전 인 경우, 법인의 Knox Approval-Knox Approver 를 복사하여 본사 Knox Approval 을 생성
                System.debug( ' ## Original Approval : ' +  approval);
                System.debug( ' ## Original Approval.Id : ' +  approval.Id);
                //Id collaboApprovalId = copyCollaboContractApproval(oppty.CollaborationBOId__c, collaboApprovalTypeCode, approval);
                Id collaboActId = getCollaboOpptyActId(oppty.CollaborationBOId__c);
                KnoxApproval__c copyKnoxApproval = approval.clone();
                copyKnoxApproval.OriginKnoxApproval__c = approval.Id;   // 원본 Knox Approval Lookup
                copyKnoxApproval.Id = null;                             // 복사를 위한 Id null 
                copyKnoxApproval.RecordTypeId = KnoxApproval__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Copy').getRecordTypeId();// Copy Record Type
                copyKnoxApproval.Opportunity__c = oppty.CollaborationBOId__c;
                copyKnoxApproval.OpportunityActivity__c = collaboActId;            
                copyKnoxApproval.WFOBJECT__c = collaboApprovalTypeCode;     // Approval Type Code
                System.debug(' ## copyKnoxApproval : ' + copyKnoxApproval);

                System.enqueueJob(new AsyncSaveCollaboApproval(copyKnoxApproval));
            } 
            

            callout_if135(approval.Id); // origin knox 결재중 처리
            
        } catch (Exception e) {          
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');  
            Database.rollback(sp);
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    /**
    * initComponent Method
    * @description  Approval 정보를 임시 저장하는 Method
    * @param        opptyId : 현재 Opportunity의 RecordId
    * @return       Map<String, Object> resMap
    *               resMap.knoxApproval 현재 Opportunity에서 요청된 Approval 정보
    *               resMap.UserKnoxInfo 접속한 User의 Employee 정보
    **/
    @AuraEnabled
    public static void tempSaveApproval(String recordId, String jsonParam, List<Map<String, Object>> fileList, String opptyactId) {
        System.debug('****************** tempSaveApproval ******************* ');
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam);
        TempKnoxApproval__c approval = (TempKnoxApproval__c)Utils.mapToSObject('TempKnoxApproval__c', (Map<String, Object>)paramMap.get('KnoxApproval'));
        List<TempKnoxApprover__c> approverList = Utils.mapToSObjectList('TempKnoxApprover__c', (List<Object>)paramMap.get('ApproverList'));

        List<Opportunity_Activity__c> op = [SELECT id, TransactionName__c FROM Opportunity_Activity__c WHERE id = :opptyactId LIMIT 1];
        String tempName = 'KnoxApproval_OpportunityActivity_' + op[0].TransactionName__c;
        

        List<TempKnoxApproval__c> temp = [SELECT id 
                                          FROM TempKnoxApproval__c 
                                          WHERE RecordId__c = :recordId AND OwnerId = :UserInfo.getUserId() 
                                          AND TemplateName__c = :approval.TemplateName__c AND ActivityId__c = :opptyactId];

        if(temp.size() > 0){
            FileUploadController.delTheFile(temp[0].Id);
            approval.Id = temp[0].Id;
            DELETE [select id from TempKnoxApprover__c where TempKnoxApproval__c = :temp[0].Id];

        }
        System.debug('opptyactId : ' + opptyactId);
        System.debug('recordId : ' + recordId);
        System.debug('jsonParam : ' + jsonParam);
        System.debug('approverList' + approverList);

        approval.TemplateName__c = tempName;
        approval.RecordId__c = recordId;
        approval.ActivityId__c = opptyactId;
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
        }
        INSERT approverList;

        System.debug('insert Ok');
    }

    /*
    * @Name             : getChangeData
    * @author           : Jonggil Kim, 2019/06/26
    * @Description      : template HTML을 반환함.
    */
    @AuraEnabled
    public static Map<String,Object> getChangeData(String tempName, Id recordId, String opptyactId) {
        String actTransactionCode = '';
        String actTransactionLabel = '';
        String actLostType = '';

        System.debug('tempName : ' + tempName);
        System.debug('UserInfo.getUserId() : ' + UserInfo.getUserId());
        System.debug('recordId : ' + recordId);
        System.debug('opptyactId : ' + opptyactId);
        Map<String,Object> resMap = new Map<String,Object>(); 
        KnoxApproval__c approval = new KnoxApproval__c();
        List<KnoxApprover__c> approverList = new List<KnoxApprover__c>();
        List<Map<String, Object>> files = new List<Map<String, Object>>();
        Boolean isTemp = false;

        List<Opportunity_Activity__c> op = [SELECT id, toLabel(TransactionName__c) toLabel_TransactionName__c, toLabel(LostType__c) toLabel_LostType__c,  TransactionName__c FROM Opportunity_Activity__c WHERE id = :opptyactId LIMIT 1];
        tempName = 'KnoxApproval_OpportunityActivity_' + op[0].TransactionName__c;
        actTransactionCode = String.valueOf(op[0].TransactionName__c);
        actTransactionLabel = String.valueOf(op[0].get('toLabel_TransactionName__c'));
        actLostType = String.valueOf(op[0].get('toLabel_LostType__c'));
        //actTransactionCode == 'ZPZ2' ,actTransactionCode == 'ZPZ1'
        System.debug('tempName------------' + tempName);

        List<TempKnoxApproval__c> temp = [SELECT id, Name, Opinion__c, TemplateName__c, Template__c, Description__c, ActivityId__c
                                          FROM TempKnoxApproval__c 
                                          WHERE RecordId__c = :recordId AND OwnerId = :UserInfo.getUserId() AND TemplateName__c = :tempName AND ActivityId__c = :opptyactId];
        
        if(temp.size() > 0 ){
            isTemp = true;
            approval.Name =  temp[0].Name;
            approval.Description__c =  temp[0].Description__c;
            
            //approval.HTML__c =  temp[0].Description__c;
            approval.Opinion__c =  temp[0].Opinion__c;
            approval.TemplateName__c = temp[0].TemplateName__c;
            approval.Template__c = temp[0].Template__c;
            System.debug('Email Template >> ' + temp[0].Template__c );
            List<TempKnoxApprover__c> tempapper = [SELECT Index__c, Name, EvEName__c, ApproverType__c, EvSdeptNM__c, EvSdeptENM__c, EvMailAddr__c, Employee__c, EvUniqID__c, IsChangeLine__c, IsEditText__c, IsArbitraryDecision__c, IsGetApprovalLine__c
                                                    FROM TempKnoxApprover__c   
                                                    WHERE TempKnoxApproval__c = :temp[0].id 
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
                teapp.IsGetApprovalLine__c = tem.IsGetApprovalLine__c;

                approverList.add(teapp);
            }

            files = FileUploadController.getFile(temp[0].id);
        }else{
            String description = '';
            //String Opinion = '';
            //TempKnoxApproval__c TKA = [SELECT id, Opinion__c FROM TempKnoxApproval__c WHERE RecordId__c =: recordId];
            //Opinion = TKA.Opinion__c;
            if(tempName != '-'){
                List<EmailTemplate> emptList = [SELECT id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName = :tempName LIMIT 1];    
                System.debug('emptList size : ' + emptList.size());
                if(emptList.size() > 0) {
                    
                    String htmlValue = emptList[0].HtmlValue;
                    
                    Opportunity_Activity__c opptyAct = [SELECT toLabel(TransactionName__c) toLabel_TransactionName__c, toLabel(LostType__c) toLabel_LostType__c 
                    FROM Opportunity_Activity__c WHERE Id =: opptyactId];
                    System.debug(String.valueOf(opptyAct.get('toLabel_TransactionName__c')));
                    htmlValue = htmlValue.replace('${Opportunity_Activity__c.TransactionName__c}', String.valueOf(opptyAct.get('toLabel_TransactionName__c')) );
                    htmlValue = htmlValue.replace('${Opportunity_Activity__c.LostType__c}', String.valueOf((opptyAct.get('toLabel_LostType__c') == null) ? '' : opptyAct.get('toLabel_LostType__c')) );
                    
                    System.debug(htmlValue);
                    List <Messaging.RenderEmailTemplateBodyResult> resList =  Messaging.renderEmailTemplate (null, recordId, new List<String>{htmlValue});
                    
                    description = resList[0].getMergedBody();
                    approval.Template__c = emptList[0].Subject;
                
                System.debug('Email Template >> ' + emptList[0] );
                }

            }                        
            resMap.put('Description', description);
            //resMap.put('Opinion', Opinion);
            
        }
        System.debug('approval >> ' + approval );
        resMap.put('knoxApproval', approval);
        resMap.put('knoxApprover', approverList);
        resMap.put('FileList', files);
        resMap.put('isTemp', isTemp);
        resMap.put('actTransactionLabel', actTransactionLabel);
        resMap.put('actTransactionCode', actTransactionCode);
        resMap.put('actLostType', actLostType);

        return resMap;
    }

    /**
     * [협업 BO 최초 수주품의 Activity 제어] 법인+본사 수주품의 Activity 결재이력에서 최초 수주품의 이력 조회 가능
     * 법인의 최초 수주 품의 완결 전 인 경우, 법인의 Knox Approval 를 복사하여 본사 Knox Approval 을 생성
     * @param   collaboOpptyId              본사 Oppty Id
     * @param   collaboApprovalTypeCode     본사 Oppty Approval Type Code
     * @param   originApproval              법인 original approval
     */
    public static String copyCollaboContractApproval(Id collaboOpptyId, String collaboApprovalTypeCode, KnoxApproval__c originApproval) {
        system.debug(' *************** copyCollaboContractApproval ***************');
        try {
            // [수주품의 Activity 확인] 본사 협업 Oppty 에 수주품의 Activity 가 없는 경우 
            String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
            Opportunity_Activity__c contractApprovalOpptyAct;            
            List<Opportunity_Activity__c> contractApprovalOpptyActList = [
                SELECT  Id
                FROM    Opportunity_Activity__c
                WHERE   WhatId__c = :collaboOpptyId
                        AND TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
            ];
            if(contractApprovalOpptyActList.size() == 0) {
                contractApprovalOpptyAct = new Opportunity_Activity__c(
                    WhatId__c = collaboOpptyId,
                    TransactionName__c = ACT_CODE_CONTRACT_APPROVAL
                );
                insert contractApprovalOpptyAct;
            } else {
                contractApprovalOpptyAct = contractApprovalOpptyActList[0];
                // opptyActContractApproval.Status__c = 'In Progress'; // 진행 처리를 생성 시 칠지, Knox Approval 에서 칠지..
                // update opptyActContractApproval;
            }

            // [Knox Approval 복사            
            KnoxApproval__c copyKnoxApproval = originApproval.clone();
            System.debug(' ## originApproval : ' + originApproval);
            copyKnoxApproval.OriginKnoxApproval__c = originApproval.Id; // 원본 Knox Approval Lookup
            copyKnoxApproval.Id = null; // 복사를 위한 Id null 
            copyKnoxApproval.RecordTypeId = KnoxApproval__c.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Copy').getRecordTypeId();// Copy Record Type
            copyKnoxApproval.Opportunity__c = collaboOpptyId;
            copyKnoxApproval.OpportunityActivity__c = contractApprovalOpptyAct.Id;            
            copyKnoxApproval.WFOBJECT__c = collaboApprovalTypeCode; // Approval Type Code
            insert copyKnoxApproval;

            // List<KnoxApprover__c> copyKnoxApproverList = originApproverList;
            // for(KnoxApprover__c approver : copyKnoxApproverList){
            //     approver.KnoxApproval__c = copyKnoxApproval.Id;
            // }
            // if(copyKnoxApproverList.size() > 0) insert copyKnoxApproverList;
            
            return copyKnoxApproval.Id;
        } catch (Exception e){
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            return e.getMessage();
            // throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * [@futrue CallOut] 결재 상신 완료 시 결재중 처리 인터페이스 호출 
     * [IF-135] Approval MISID__c 정보를 Ecc로 전송
     * - 조건 (1) Transaction Activity Target : 사전영업자원요청, 수전위,수주품의, 변경품의 
     *        (2) Project 가 있는 경우
     */
    public static void callout_if135(Id knoxApprovalId){
        KnoxApproval__c approval = [SELECT  Id, WFOBJECT__c, MISID__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c
                                    FROM    KnoxApproval__c 
                                    WHERE   Id = :knoxApprovalId];
        List<Project__c> prjList = [SELECT  Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c 
                                    FROM    Project__c 
                                    WHERE   Opportunity__c = :approval.Opportunity__c];
        Boolean requireSendEccFlag = (OpportunityActivityHelper.OPPACT_TARGET_SET_IF135.contains(approval.OpportunityActivity__r.TransactionName__c) || approval.OpportunityActivity__r.TransactionName__c == 'ZP21') && (prjList.size() > 0);  //Added by Anish-v 2.0
        if(requireSendEccFlag) {
            Batch_EccUpdateStatusController.InputClass input_if135 = new Batch_EccUpdateStatusController.InputClass();
            input_if135.IV_WFOBJECT       = approval.WFOBJECT__c;                                   // 결재유형코드
            input_if135.IV_OBJECTKEY      = approval.MISID__c;                                      // 트랙젠션 ID
            input_if135.IV_ZZORDER_ID     = approval.Opportunity__r.OpportunityCode__c;             // BO 코드
            input_if135.IV_PROCESS_TYPE   = approval.OpportunityActivity__r.TransactionName__c;     // 액티비티 ID
            input_if135.IV_BUKS           = approval.Opportunity__r.CompanyCode__c;                 // 회사코드
            input_if135.IV_STATUS         = 'A3';                                                   // 결재상태
            List<Batch_EccUpdateStatusController.IT_PROJECT> itPrjList = new List<Batch_EccUpdateStatusController.IT_PROJECT>();
            for(Project__c prj : prjList){
                if(approval.Opportunity__c == prj.Opportunity__c){
                    Batch_EccUpdateStatusController.IT_PROJECT itPrj = new Batch_EccUpdateStatusController.IT_PROJECT();
                    itPrj.OPPORTUNITY = prj.Opportunity__r.OpportunityCode__c;
                    itPrj.PROJECTTYPE = prj.ProjectType__c;
                    itPrj.PROJECTCODE = prj.ProjectCode__c;
                    itPrj.DESCRIPTION = prj.Description__c;
                    itPrj.DELETIONFLAG = prj.DeletionFlag__c == true ? 'X':'';
                    itPrjList.add(itPrj);
                }
            }
            input_if135.IT_PROJECT = itPrjList;
             // [@futrue CallOut] IF-135
            // Start- Added by Anish-v 2.0
            if(approval.OpportunityActivity__r.TransactionName__c == 'ZP21'){
               approval.syncFlag__c = 'Y';
               update approval;
            }
            else{
            Batch_EccUpdateStatusController.syncApproval(JSON.serialize(input_if135));
            }
            // End- Added by Anish-v 2.0
        }
    }
    
    /**
    * @description 협업 사업기회 activity 생성
    * @author seonju.jin@dkbmc.com | 2022-01-04 
    * @param Id collaboOpptyId 
    * @return Id 
    **/
    public static Id getCollaboOpptyActId(Id collaboOpptyId){
        system.debug(' *************** createCollaboOpptyAct ***************');
        Id actId;
        try{
            // [수주품의 Activity 확인] 본사 협업 Oppty 에 수주품의 Activity 가 없는 경우 
            String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
            Opportunity_Activity__c contractApprovalOpptyAct;            
            List<Opportunity_Activity__c> contractApprovalOpptyActList = [
                SELECT  Id
                FROM    Opportunity_Activity__c
                WHERE   WhatId__c = :collaboOpptyId
                        AND TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
            ];
            if(contractApprovalOpptyActList.size() == 0) {
                contractApprovalOpptyAct = new Opportunity_Activity__c(
                    WhatId__c = collaboOpptyId,
                    TransactionName__c = ACT_CODE_CONTRACT_APPROVAL
                );
                insert contractApprovalOpptyAct;
            } else {
                contractApprovalOpptyAct = contractApprovalOpptyActList[0];
                // opptyActContractApproval.Status__c = 'In Progress'; // 진행 처리를 생성 시 칠지, Knox Approval 에서 칠지..
                // update opptyActContractApproval;
            }

            actId = contractApprovalOpptyAct.Id;
        }catch(Exception e){
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
        }

        return actId;
    }
    
    public class AsyncSaveCollaboApproval implements Queueable, Database.AllowsCallouts {
        private KnoxApproval__c approval;

        public AsyncSaveCollaboApproval(KnoxApproval__c approval){
            this.approval = approval;
        }

        public void execute(QueueableContext context) {
            saveKnoxApproval();
        }

        private void saveKnoxApproval(){
            upsert approval;
            callout_if135(approval.Id); // copy knox 결재중 처리
        }
    }
    
      //Added by Anish - v 1.5
    public static void createInterfaceLog3(String apexMethod,String logMessage,String statusCode ){

        try{
        System.debug( 'CHECK_KNOXAPPROVAL entry');
            IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'KnoxApprovalSubmitController';
                log.ApexMethod__c =  apexMethod;
                log.InterfaceId__c = 'CHECK_KNOXAPPROVAL';
                log.LogText__c = logMessage;
                log.StatusCode__c = statusCode;
                log.LogType__c = 'Interface';
                log.EndDatetime__c  = System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'CHECK_KNOXAPPROVAL creation'+ log);
                insert log;
        }catch(Exception e){
            System.debug( 'CHECK_KNOXAPPROVAL msg'+ e.getMessage());
        }
    }
    
    //Added by Anish - V 1.6
    @AuraEnabled
    public static void createInterfaceLog(String apexMethod,String logMessage,String statusCode, Id oppId ){

        try{
        Opportunity_Activity__c opptyAct = [SELECT Id, WhatId__c, WhatId__r.OwnerId, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c, TransactionName__c FROM Opportunity_Activity__c WHERE id = :oppId LIMIT 1];
        System.debug( 'ERROR_KNOXAPPROVAL entry');
            IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'KnoxApprovalSubmitController';
                log.ApexMethod__c =  apexMethod;
                log.InterfaceId__c = 'CHECK_KNOXAPPROVAL';
                log.LogText__c = logMessage + ' BO_CODE : '+opptyAct.WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyAct.WhatId__r.CompanyCode__c + ', TR : ' + opptyAct.TransactionName__c;
                log.StatusCode__c = statusCode;
                log.LogType__c = 'Interface';
                log.EndDatetime__c  = System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'ERROR_KNOXAPPROVAL creation'+ log);
                insert log;
        }catch(Exception e){
            System.debug( 'ERROR_KNOXAPPROVAL msg'+ e.getMessage());
        }
    }
    
    //V1.9 Start
    
    public static String getUserIPAddress() {
		System.debug('●●●● getUserIPAddress ●●●●');
		String localIp = '';
		if(!Test.isRunningTest()){
            localIp = Auth.SessionManagement.getCurrentSession().get('SourceIp');
		} else {
			localIp = '203.244.212.21';
		}
		System.debug('localIp : ' + localIp);
		return localIp;
	}

    @AuraEnabled
    public static Object getVaultAuthToken(String apiType, list<String> fileIds, String platform) {
		System.debug('●●●● getVaultAuthToken ●●●●');
		System.debug('apiType : ' + apiType);
		System.debug('fileIds : ' + fileIds);
		System.debug('platform : ' + platform);
		map<String, Object> token = new map<String, Object>();
		Boolean hasFiles = false;
		String endpoint = Label.EFSS_VAULT_AUTHURL + '/vault/sds/sfdc/otp?api=' + apiType;
		System.debug('endpoint : ' + endpoint);
		String sourceIp = getUserIPAddress();
		
		if(apiType == 'file-download' || apiType == 'file-multi-download' || apiType == 'file-view' || apiType == 'file-delete')
			hasFiles = true;

		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + Label.EFSS_VAULT_AUTHKEY);
		req.setHeader('Client-Type', platform);
		req.setHeader('Client-Addr', sourceIp);

		if(hasFiles){
			req.setHeader('Content-Type', 'application/json');
			if(fileIds == null || fileIds.isEmpty()) throw new CustomException('no files');
			list<String> files = new list<String>();
			for(String fileId : fileIds){
				files.add(fileId);
			}
			map<String, list<String>> mapBody = new map<String, list<String>>();
			mapBody.put('fileIds', files);
			// system.debug(JSON.serialize(mapBody));
			req.setBody(JSON.serialize(mapBody));
		}
		System.debug('req : ' + req);
		HttpResponse res = http.send(req);
		System.debug('res : ' + res);
		if(res.getStatusCode() == 200){
			token = (map<String, Object>) JSON.deserializeUntyped(res.getBody());
			System.debug('tokengenrated:' + token);
		} else {
			throw new CustomException('{"status":'+ String.valueOf(res.getStatusCode()) +', "message":'+ res.getStatus() +'}');
		}	
        return token;
	}
    
    @AuraEnabled
    public static String saveVaultId3Content(String filename){
        return 'true';
    }

    @AuraEnabled
    public static Boolean saveVaultId2Content(String recordId, String vaultId, String filename){
		system.debug('Inside valut apex');
        try {
            system.debug('Inside valut apex try');
			String ExternalSourceId = [SELECT Id FROM ExternalDataSource WHERE DeveloperName = 'EFSS_Vault' LIMIT 1].Id;
			system.debug('Knox Approval id: '+ recordId);
            ContentVersion cv = new ContentVersion(
				ContentLocation = 'E',
				Origin = 'H',
				OwnerId = UserInfo.getUserId(),
				Title = filename,
				PathOnClient = filename,
				ExternalDataSourceId = ExternalSourceId,
				ExternalDocumentInfo1 = 'vault://' + vaultId,
				ExternalDocumentInfo2 = vaultId,
				FirstPublishLocationId = recordId
			);
            			
			insert cv;
            system.debug('filerecord created'+cv);
            
            /*Id cont = [select ContentDocumentId from ContentVersion where id =: cv.Id].ContentDocumentId;
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = recordId;
        	cdl.ContentDocumentId = cont;
        	cdl.shareType = 'V';
            cdl.visibility = 'AllUsers';
        	insert cdl;
            
            system.debug('filerecordlink created'+cdl);*/

			return true;	
		} catch(Exception ex){
            //system.debug('Errorduringsave'+ex.getMessage());
			throw new AuraHandledException(ex.getMessage());
		}
    }
	@AuraEnabled
    public static list<ContentDocumentLink> getRelatedFiles(String recordId){       
          return  [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, 
                    ContentDocument.FileExtension, ContentDocument.ContentModifiedDate
                FROM ContentDocumentLink WHERE LinkedEntityId = :recordId and ContentDocument.FileExtension !='snote' ORDER BY ContentDocument.ContentModifiedDate DESC];  //Added by Anish - v 1.1       
    }																																									   //Added orderby - v 1.2
	public class CustomException extends Exception {}
    //V1.9 End
}