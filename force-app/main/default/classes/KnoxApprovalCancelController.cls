/**
 * @description       : Knox 결재 상신 취소
 *                      1. (if-135 호출 대상인 경우) 확인 후 if-135 호출  
 *                      2. 상신 취소 성공 호출 시 if-093 호출
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 06-16-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-11-13   hj.lee@dkbmc.com   Initial Version
 * 1.1   2021-03-26   hj.lee@dkbmc.com   [협업 BO 최초 수주품의 Activity 제어] Collabo 결재가 있는 경우, I/F 결재중처리 로직 호출
 * 1.2   2021-04-20   hj.lee@dkbmc.com   process_if093 : 결재후처리 (IF-93) futrue Method 분리
 * 1.3   2021-04-22   hj.lee@dkbmc.com   상신 취소 권한 변경 (Knox Approval Owner, Approver 기안자)
 * 1.4   2021-05-04   hj.lee@dkbmc.com   KnoxApprovalHelper.process_if093 : 결재후처리 (IF-93) Method 분리
**/
public class KnoxApprovalCancelController {
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';
    public static String APPROVAL_STATUS_CANCEL = '4';

    /**
    * @description  ecc 결재 전송 대상 액티비티인경우 IF-135 호출 후 결과 확인
    * @author       hj.lee@dkbmc.com | 2021-02-19 
    * @param        recordId 
    * @return       Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> initComponent(String recordId){
        Map<String, Object> validCheckMap = new Map<String, Object>();
        Boolean result = true;
        String msg = '';

        Map<String, Object> resultMap = new Map<String, Object>{
            'RESULT' => result,
            'MSG'    => msg
        };

        if(!Test.isRunningTest() &&true){
            // 06.15 결재 상신취소는 Knox 에서만 가능(이승우프로 요청) yeongju.baek@dkbmc.com 
            resultMap.put('RESULT', false);
            resultMap.put('MSG', System.Label.CAPP_MSG_0001); // Knox Poratal 에서 상신취소해주세요
            return resultMap;
        }
        
        
        
        List<KnoxApproval__c> updateKnoxApprovalList = new List<KnoxApproval__c>();
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log log = new IF_Log(); 
        
        try {
            KnoxApproval__c knoxApproval = [
                SELECT  Id
                        , ApprovedId__c
                        , OwnerId
                        , MISID__c
                        , Status__c
                        , WFOBJECT__c
                        , Opportunity__c
                        , Opportunity__r.OpportunityCode__c
                        , Opportunity__r.CompanyCode__c
                        , OpportunityActivity__c
                        , OpportunityActivity__r.WhatId__c
                        , OpportunityActivity__r.TransactionName__c
                        , syncFlag__c
                        , CreatedBy.UserName
                FROM    KnoxApproval__c 
                WHERE   Id = :recordId
            ];
            
            // ❌ Mig Data(Mig User 생성) 인 경우 상신취소 불가
            Set<String> migUserSet = new Set<String>{'mig01@samsung.com', 'mig02@partner.samsung.com'};
            if(migUserSet.contains(knoxApproval.CreatedBy.UserName)) {
                resultMap.put('RESULT', false);
                resultMap.put('MSG', System.Label.CAPP_MSG_0004); // 이관 데이터입니다. 상신취소를 할 수 없습니다.
                return resultMap;
            }

            // ❌ Knox Approval 상태가 진행중이 아닌 경우 상신취소 불가
            // 06.15 결재 상신취소는 Knox 에서만 가능
            if(knoxApproval.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS) {
                resultMap.put('RESULT', false);
                resultMap.put('MSG', System.Label.CAPP_MSG_0001); // Knox Poratal 에서 상신취소해주세요
                return resultMap;
            }

            // 기안자 (KnoxApprover) ApproverType__c = '0' (기안)
            String requesterEvUniqId = '';
            List<KnoxApprover__c> knoxApproverRequester = [
                SELECT  Id, Employee__c, Employee__r.EvUniqID__c
                FROM    KnoxApprover__c 
                WHERE   KnoxApproval__c = :knoxApproval.Id 
                        AND ApproverType__c = '0'
                LIMIT   1
            ];

            if(knoxApproverRequester.size() > 0) {
                requesterEvUniqId = knoxApproverRequester[0].Employee__r.EvUniqID__c;
            }

            // 기안자 (User)
            List<User> requesterUser = [
                SELECT  Id 
                FROM    User 
                WHERE   FederationIdentifier = :requesterEvUniqId
                LIMIT   1
            ];
            String requesterUserId = '';
            if(requesterUser.size() > 0) {
                requesterUserId = requesterUser[0].Id;
            }
            
            System.debug('## UserInfo.getUserId() :  ' + UserInfo.getUserId());
            System.debug('# (1) 소유자 knoxApproval.OwnerId ' + knoxApproval.OwnerId);
            System.debug('# (2) 기안자 requesterUserId ' + requesterUserId);

            // [2021-04-22] 상신취소 가능한 권한 (Knox Approval Owner, Knox Approver 기안자)
            // ❌ Login User가 Knox Approval Owner 또는 Knox Approver의 기안자가 아닌경우 불가
            if(! (UserInfo.getUserId() == knoxApproval.OwnerId || UserInfo.getUserId() == requesterUserId) ) {
                resultMap.put('RESULT', false);
                resultMap.put('MSG', System.Label.APPR_MSG_0016); // Knox 결재 소유자 또는 기안자만 상신 취소를 할 수 있습니다.
                return resultMap;
            }
            
            /**
             * - IF-135 조건에 해당되면 호출 후, 실패 결과 리턴 시 상신 취소 불가능
             * - 협업 BO Knox 결재 시 복사된 본사 협업 Knox Approval도 함께 호출
             * 
             * [IF-135] Approval MISID__c 정보를 Ecc로 전송
             * - 조건 (1) 호출 Activity Target 인 경우
             *        (2) Knox Approval Sync Flag 'N'
             *        (2) Project 가 있는 경우
             */
            List<Project__c> prjList = [SELECT  Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c 
                                        FROM    Project__c 
                                        WHERE   Opportunity__c = :knoxApproval.Opportunity__c];
            Boolean checkFlag_if135 = KnoxApprovalHelper.isTarget_if135(knoxApproval, prjList.size());
            System.debug('# checkFlag_if135 : ' + checkFlag_if135);
            
            if(checkFlag_if135 || Test.isRunningTest()) {
                Map<String, Object> resMap_if135 = KnoxApprovalHelper.callOut_if135(knoxApproval, prjList);
                if(resMap_if135.get('IF_Log') != null) ifLogList.add((IF_Log.InterfaceLog)resMap_if135.get('IF_Log'));

                String resBodyMapString_if135 = String.valueOf(resMap_if135.get('Response'));
                Map<String, Object> resBodyMap = (Map<String, Object>)JSON.deserializeUntyped(resBodyMapString_if135);

                if(Util_String.nvlStr(resMap_if135.get('StatusCode')) == '200' && Util_String.nvlStr(resbodyMap.get('EV_RESULT')) == 'S'){ 
                    result = true;
                    
                    // IF135 호출 성공 후 KnoxApproval Flag 업데이트
                    knoxApproval.syncFlag__c = 'Y';
                    updateKnoxApprovalList.add(knoxApproval);
                    
                } else {                    
                    result = false;
                    String msg_if135 = '';
                    if( resBodyMap.get('EV_MESS') != null ) {
                        msg_if135 = String.valueof(resBodyMap.get('EV_MESS'));
                    }
                    msg += System.Label.APPR_MSG_0030 + ' ';
                    msg += msg_if135;
                }
            }

            /**
             * Collabo Approval IF-135 호출
             */
            // Collabo Knox Approval 확인
            List<KnoxApproval__c> collaboKnoxApprovals = [
                SELECT  Id, 
                        MISID__c, 
                        Status__c,
                        WFOBJECT__c,
                        Opportunity__c,
                        Opportunity__r.OpportunityCode__c,
                        Opportunity__r.CompanyCode__c,
                        OpportunityActivity__c, 
                        OpportunityActivity__r.WhatId__c,
                        OpportunityActivity__r.TransactionName__c,
                        syncFlag__c
                FROM    KnoxApproval__c 
                WHERE   OriginKnoxApproval__c = :recordId
            ];
            if(collaboKnoxApprovals.size() > 0) {
                KnoxApproval__c collaboKnoxApproval = collaboKnoxApprovals[0];
                // [IF-135] 호출
                List<Project__c> collabo_prjList = [
                    SELECT  Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c 
                    FROM    Project__c 
                    WHERE   Opportunity__c = :collaboKnoxApproval.Opportunity__c
                ];

                Boolean collabo_if135_flag = KnoxApprovalHelper.isTarget_if135(collaboKnoxApproval, collabo_prjList.size());
                System.debug('# collabo_if135_flag : ' + collabo_if135_flag);
               if(collabo_if135_flag || Test.isRunningTest()) {
                   Map<String, Object> collaboResMap_if135 = KnoxApprovalHelper.callOut_if135(collaboKnoxApproval, collabo_prjList);
                   if(collaboResMap_if135.get('IF_Log') != null) ifLogList.add((IF_Log.InterfaceLog)collaboResMap_if135.get('IF_Log'));

                   String collaboResBodyMapString_if135 = String.valueOf(collaboResMap_if135.get('Response'));
                   Map<String, Object> collaboResBodyMap = (Map<String, Object>)JSON.deserializeUntyped(collaboResBodyMapString_if135);

                   if(Util_String.nvlStr(collaboResMap_if135.get('StatusCode')) == '200' && Util_String.nvlStr(collaboResBodyMap.get('EV_RESULT')) == 'S'){ 
                       result = true;
                       collaboKnoxApproval.syncFlag__c = 'Y';
                       updateKnoxApprovalList.add(collaboKnoxApproval);

                   } else {
                       result = false;
                       String msg_if135_EV_MESS = '';
                       if( collaboResBodyMap.get('EV_MESS') != null ) {
                        msg_if135_EV_MESS = String.valueof(collaboResBodyMap.get('EV_MESS'));
                       }
                       msg += ' ['+System.Label.VAPP_LAB_COLLABO_VALID_CHECK +'] '+System.Label.APPR_MSG_0030 + ' ';
                       msg += msg_if135_EV_MESS;
                   }
               }
           }

           if(updateKnoxApprovalList.size() > 0) update updateKnoxApprovalList;
           if(ifLogList.size() > 0) log.createLog(ifLogList);

            resultMap = new Map<String, Object>{                
                'RESULT' => result,
                'MSG'    => msg
            };

        } catch (Exception e) {
            System.debug(System.LoggingLevel.ERROR, e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return resultMap;
    }

    
    /**
	* cancelApproval Method
    * @description  JSON형태로 전달받은 Approval의 결재를 상신 취소하는 메서드
    * @param        jsonParam - JSON형태로 전달받은 Approval의 정보
    * @return       Map<String, Object> resMap
	**/
    @AuraEnabled
    public static Map<String,Object> cancelApproval(String jsonParam) {
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam); 
        Map<String, Object> app = (Map<String, Object>)paramMap.get('KnoxApproval');
        String comments = (String) paramMap.get('Comments');

        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Solution__c> updateSolutionList = new list<Solution__c>();
        List<KnoxApproval__c> updateKnoxApprovalList = new list<KnoxApproval__c>();
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log log = new IF_Log(); 

        try{            
            if(String.isBlank(comments)) { // 상신취소 의견 Blank
                resMap.put('RESULT', RES_RESULT_ERROR);
                resMap.put('Message', System.Label.CAPP_MSG_CANCELCOMMENTS); 

            } else {
                KnoxApproval__c approval = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', app);            
                approval.Cancel_Reason__c = comments;
                approval.Id =(String) app.get('Id');
                
                // [IF-078] Call out (상신취소)
                IF_KnoxApprovalCancelController.InputClass input = new IF_KnoxApprovalCancelController.InputClass();
                input.apInfId = approval.MISID__c;
                input.opinion = comments;

                Map<String,Object> knoxResponse = IF_KnoxApprovalCancelController.approvalCancel(input);
                IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog) knoxResponse.get('INTERFACE_LOG');
                ifLogList.add(ifLog);
                
                String knoxResponseResult = String.valueOf(knoxResponse.get('result'));

                if(knoxResponseResult == RES_RESULT_ERROR){ // [상신취소 오류]
                    
                    Map<String, Object> errorDetail = (Map<String, Object>)knoxResponse.get('errorDetail');
                    String errorMessage = String.valueOf(errorDetail.get('errorMessage'));
                    String detailMessages = String.valueOf( errorDetail.get('detailMessages') );
                    
                    String errorMsg = errorMessage;
                    if(errorMessage == '' || errorMessage == 'null' || errorMessage == null) {
                        errorMsg = detailMessages;
                    }

                    resMap.put('RESULT',RES_RESULT_ERROR);
                    resMap.put('Message', errorMsg);
                    
                } else {  // [상신취소 성공]
                                    
                    /**
                     * [IF-093] Call out - Knox 결재 후속 처리
                     */
                    // Map<String, Object> updateObjectMap = KnoxApprovalHelper.process_if093(approval.Id, APPROVAL_STATUS_CANCEL);
                    // if(updateObjectMap.containsKey('ifLogList')) {
                    //     ifLogList.addAll( (List<IF_Log.InterfaceLog>)updateObjectMap.get('ifLogList') );
                    // }

                    // [DML] 상신취소 update
                    approval.Status__c = APPROVAL_STATUS_CANCEL;
                    update approval;
                    System.debug(' # 상신취소 approval update ' );

                    // [QUEUE] IF-093 후처리
                    System.enqueueJob(new KnoxApprovalHelper.Queue_Process_if093(approval.Id, APPROVAL_STATUS_CANCEL));

                    // [DML] IF-093 결과 Update / Upsert
                    // if(updateObjectMap.containsKey('Opportunity')) {
                    //     update (List<Opportunity>)updateObjectMap.get('Opportunity');
                    //  }
                    // if(updateObjectMap.containsKey('Solution')) {
                    //     update (List<Solution__c>)updateObjectMap.get('Solution');
                    // }
                    // if(updateObjectMap.containsKey('Approval')) {
                    //     // Only Knox Approval Sync Flag Field Update
                    //     List<KnoxApproval__c> tempKnoxApprovalList = (List<KnoxApproval__c>)updateObjectMap.get('Approval');
                    //     List<KnoxApproval__c> updateSyncFlagKnoxList = new List<KnoxApproval__c>();
                    //     for(KnoxApproval__c tempKnox : tempKnoxApprovalList) {
                    //         KnoxApproval__c updateSyncFlagKnox = new KnoxApproval__c();
                    //         updateSyncFlagKnox.Id = tempKnox.Id;
                    //         updateSyncFlagKnox.syncFlag__c = tempKnox.syncFlag__c = 'S';
                    //         updateSyncFlagKnoxList.add(updateSyncFlagKnox);
                    //     }
                    //     if(updateSyncFlagKnoxList.size() > 0) update updateSyncFlagKnoxList;
                    // }
                         
                    resMap.put('RESULT',RES_RESULT_SUCCESS);
                }

                
            }
        } catch(DmlException e) {
            resMap.put('RESULT', RES_RESULT_ERROR);
            resMap.put('Message', e.getDMLMessage(0));            
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            
        } catch(Exception e) {
            resMap.put('RESULT', RES_RESULT_ERROR);
            resMap.put('Message',e.getMessage());
            resMap.put('Trace',e.getStackTraceString());
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
        } finally {
            // [DML] if log                
            log.createLog(ifLogList);
            
        }
        
        return resMap;
    }
}