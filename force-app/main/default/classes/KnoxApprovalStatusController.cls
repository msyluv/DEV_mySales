/**
 * @description       : Knox 결재 상태 조회
 *                      1. (if-135 호출 대상인 경우) 확인 후 if-135 호출  
 *                      2. 상태값 성공 호출 시 if-093 호출
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-07-05
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-11-16   hj.lee@dkbmc.com   Initial Version
 * 1.1   2021-03-26   hj.lee@dkbmc.com   [협업 BO 최초 수주품의 Activity 제어] Collabo 결재가 있는 경우, I/F 결재중처리 로직 호출
 * 1.2   2021-05-04   hj.lee@dkbmc.com   KnoxApprovalHelper.process_if093 : 결재후처리 (IF-93) Method 분리
 * 1.3   2021-07-05   seonju.jin@dkbmc.com   법인통합대상(IsCostCenterMerge__c) 조회 가능, Cleansed데이터 불가 조건 추가
**/
public without sharing class KnoxApprovalStatusController {
    public static String RES_RESULT_SUCCESS = 'success';
    public static String RES_RESULT_ERROR = 'fail';

    /**
    * @description  ecc 결재 전송 대상 액티비티인경우 IF-135 호출 후 결과 확인
    * @author       hj.lee@dkbmc.com | 2021-02-19 
    * @param        recordId 
    * @return       Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> initComponent(String recordId){
        Boolean result = true;
        String msg = '';
        Map<String, Object> resultMap = new Map<String, Object>{
            'RESULT' => result,
            'MSG'    => msg
        };

        List<KnoxApproval__c> updateKnoxApprovalList = new List<KnoxApproval__c>();
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log log = new IF_Log(); 

        try {
            KnoxApproval__c knoxApproval = [
                SELECT  Id, 
                        MISID__c, 
                        Status__c,
                        WFOBJECT__c,
                        Opportunity__c,
                        Opportunity__r.OpportunityCode__c,
                        Opportunity__r.CompanyCode__c,
                        Opportunity__r.IsEdited__c,
                        Opportunity__r.IsCostCenterMerge__c,
                        OpportunityActivity__c, 
                        OpportunityActivity__r.WhatId__c,
                        OpportunityActivity__r.TransactionName__c,
                        syncFlag__c,
                        CreatedBy.UserName
                FROM    KnoxApproval__c 
                WHERE   Id = :recordId
            ];
            List<Project__c> prjList = [
                SELECT  Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c
                FROM    Project__c
                WHERE   Opportunity__c = :knoxApproval.OpportunityActivity__r.WhatId__c];
            	
            // ❌ Mig Data(Mig User 생성) 인 경우 상태조회 불가
            Set<String> migUserSet = new Set<String>{'mig01@samsung.com', 'mig02@partner.samsung.com'};
            if(migUserSet.contains(knoxApproval.CreatedBy.UserName)) {
                if(!knoxApproval.Opportunity__r.IsEdited__c ){  //
                    resultMap.put('RESULT', false);
                    resultMap.put('MSG', System.Label.SAPP_MSG_0002); // 이관 데이터입니다. 결재 상태 조회를 할 수 없습니다.
                    return resultMap;
                }
            }

            /**
             * [IF-135] Approval MISID__c 정보를 Ecc로 전송
             * - 조건 (1) Transaction Activity Target : 사전영업자원요청, 수전위,수주품의, 변경품의 
             *        (2) Project 가 있는 경우
             */
            Boolean checkFlag_if135 = KnoxApprovalHelper.isTarget_if135(knoxApproval, prjList.size());
            System.debug('# checkFlag_if135 : ' + checkFlag_if135);
            
            if(checkFlag_if135 || Test.isRunningTest()) {
                Map<String, Object> resMap_if135 = callOut_if135(knoxApproval, prjList);
                if(resMap_if135.get('IF_Log') != null) {
                    ifLogList.add((IF_Log.InterfaceLog)resMap_if135.get('IF_Log'));
                }

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
               if(collabo_if135_flag){
                   Map<String, Object> collaboResMap_if135 = callOut_if135(collaboKnoxApproval, collabo_prjList);
                   if(collaboResMap_if135.get('IF_Log') != null) {
                       ifLogList.add((IF_Log.InterfaceLog)collaboResMap_if135.get('IF_Log'));
                   }
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
    * @description 결재 상태값 가져오기
    * @author       hj.lee@dkbmc.com | 2021-02-19 
    * @param        jsonParam 
    * @return       Map<String, Object> 
    **/
    @AuraEnabled
    public static Map<String,Object> getKnoxApprovalStatus(String jsonParam) {        
        Map<String, Object> resultMap = new Map<String, Object>();  
        Map<String, Object> paramMap = (Map<String, Object>)JSON.deserializeUntyped(jsonParam); 
        Map<String, Object> knoxApprovalMap = (Map<String, Object>)paramMap.get('KnoxApproval');
        KnoxApproval__c knoxApprovalObj = (KnoxApproval__c)Utils.mapToSObject('KnoxApproval__c', knoxApprovalMap);        
        knoxApprovalObj.Id = (String)knoxApprovalMap.get('Id');
        
        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Solution__c> updateSolutionList = new list<Solution__c>();
        List<KnoxApproval__c> updateKnoxApprovalList = new list<KnoxApproval__c>();
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log log = new IF_Log(); 

        try{         
            Batch_KnoxApprovalDetailController.InputClass knoxInput = new Batch_KnoxApprovalDetailController.InputClass();
            knoxInput.apInfId = knoxApprovalObj.MISID__c;

            // [IF-133] Call out
            Map<String,Object> knoxResMap = Batch_KnoxApprovalDetailController.getDetail(knoxInput, knoxApprovalObj.Id);
            Integer resStatusCode     = Util_String.nvlInt(knoxResMap.get('StatusCode'));
            Boolean HttpSuccess       = resStatusCode <= 300;
            //IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)knoxResMap.get('IF_Log');
            //2022-06-27, hyunhak.roh@dkbmc.com, IF-133(knox에서 결재 상태 가져오기) 수행 로직 개선건
            ifLogList = (List<IF_Log.InterfaceLog>)knoxResMap.get('IF_Log');
            //ifLogList.add(ifLog);

            List<KnoxApprover__c> knoxApproverList = new List<KnoxApprover__c>();
            String updatedApprovalStatus = '';
            if(HttpSuccess) {   // HTTP SUCCESS
                String resResult = (String)knoxResMap.get('result');
                
                if(resResult == RES_RESULT_SUCCESS){ 
                    // [상태값 조회 성공]
                    if( knoxResMap.get('Approval') != null ) {
                        knoxApprovalObj = (KnoxApproval__c)knoxResMap.get('Approval');
                        updatedApprovalStatus = knoxApprovalObj.Status__c;
    
                        if( knoxResMap.get('Approver') != null ) {
                            knoxApproverList = (List<KnoxApprover__c>)knoxResMap.get('Approver');
                            System.debug(' # knoxApproverList: ' + knoxApproverList);
                        }
                    }

                    /**
                     * [IF-093 Call out] - Knox 결재 후속 처리
                     */
                    // Map<String, Object> updateObjectMap = KnoxApprovalHelper.process_if093(knoxApprovalObj.Id, updatedApprovalStatus);
                    // if(updateObjectMap.containsKey('ifLogList')) {
                    //     ifLogList.addAll( (List<IF_Log.InterfaceLog>)updateObjectMap.get('ifLogList') );
                    // }

                    // [DML] 결재 상태 가져오기 결과 (IF-133) update
                    knoxApprovalObj.Status__c = updatedApprovalStatus;
                    update knoxApprovalObj;
                    System.debug(' update knoxApprovalObj' );
                    if(knoxApproverList.size() > 0) upsert knoxApproverList ExternalId__c;

                    // [QUEUE] IF-093 후처리
                    System.enqueueJob(new KnoxApprovalHelper.Queue_Process_if093(knoxApprovalObj.Id, updatedApprovalStatus));

                    // [DML] IF-093 결과 Update / Upsert
                    // if(updateObjectMap.containsKey('Opportunity')) {
                    //     update (List<Opportunity>)updateObjectMap.get('Opportunity');
                    // }
                    //     if(updateObjectMap.containsKey('Solution')) {
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

                    resultMap.put('RESULT',RES_RESULT_SUCCESS);
                } else {
                    System.debug('===== Error =====' );
                    IF_Log.InterfaceLog errorIfLog = ( IF_Log.InterfaceLog)knoxResMap.get('IF_Log');
                    System.debug('# errorIfLog : ' + errorIfLog );
                    Map<String, Object> ResponseMsg = (Map<String, Object>)JSON.deserializeUntyped(errorIfLog.ResponseMsg);
                    Map<String, Object> errorDetail = (Map<String, Object>)ResponseMsg.get('errorDetail');
                    
                    resultMap.put('RESULT',RES_RESULT_ERROR);
                    resultMap.put('Message', (String)errorDetail.get('errorMessage'));
                }
            } else { // HTTP ERROR
                resultMap.put('RESULT', RES_RESULT_ERROR);
                resultMap.put('Message', 'KNOX HTTP ERROR ' + resStatusCode);
            }

        } catch(Exception e) {
            resultMap.put('RESULT', RES_RESULT_ERROR);
            resultMap.put('Message',e.getMessage());
            resultMap.put('Trace',e.getStackTraceString());
            
        } finally {
            // [DML] if log     
            if(ifLogList.size() > 0) log.createLog(ifLogList);
        }
        return resultMap;
    }

    /**
     * [IF-135] 결재 중간처리
     */
    public static Map<String,Object> callOut_if135(KnoxApproval__c approval, List<Project__c> prjList){
        Batch_EccUpdateStatusController.InputClass input_if135 = new Batch_EccUpdateStatusController.InputClass();
        input_if135.IV_WFOBJECT       = approval.WFOBJECT__c;                                           // 결재유형코드
        input_if135.IV_OBJECTKEY      = approval.MISID__c;                                              // 트랙젠션 ID
            input_if135.IV_ZZORDER_ID     = approval.Opportunity__r.OpportunityCode__c;                     // BO 코드
        input_if135.IV_PROCESS_TYPE   = approval.OpportunityActivity__r.TransactionName__c;             // 액티비티 ID
        input_if135.IV_BUKS           = approval.Opportunity__r.CompanyCode__c;                         // 회사코드
        input_if135.IV_STATUS         = 'A3';                                                           // 결재상태
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
            
        Map<String,Object> responseMap = Batch_EccUpdateStatusController.syncApproval(input_if135);
        return responseMap;
    }
}