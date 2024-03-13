/**
 * @description       : 
 * @author            : jiiiiii.park@partner.samsung.com.sds.dev
 * @group             : 
 * @last modified on  : 2024-02-11
 * @last modified by  : divyam.gupta@samsung.com  
 * Modifications Log 
 * Ver   Date         Author                                     Modification
 * 1.0   2020-11-27   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
 * 1.1   2021-01-08   leehyo                                     Record Lock(Approval.Lock) 기능 분리, Opportunity Record Lock : 수주 품의(ZP82) Activity만 적용하도록 변경
 * 1.2   2021-03-09   Soohong0.kim@partner.samsung.com           setOpptyActivityStatus 메소드에 가장 최근에 생성된 Approval의 Status 로 매핑하는 로직 추가
 * 1.3   2021-03-17   Junghwa.Kim@dkbmc.com                      결제 상태가 상신중, 승인이 아닐경우 수전위 Record Unlock 처리
 * 1.4   2021-03-25   seonju.jin@dkbmc.com                       단품/계약대행, 자회사/법인 마감 기준 변경 setOpptyStatusWon로직 추가
 * 1.4   2021-03-25   leehyo                                     [협업 BO 최초 수주품의 Activity 제어] syncCopyKnoxApproval 추가 : 법인 협업 기회의 수주품의 최초 결재 시 복제한 본사 KnoxApproval 결재 상태값 동기화 처리
 * 1.5   2021-07-05   seonju.jin@dkbmc.com                       Opportunity Stage 업데이트 Cleansed 제외처리
 * 1.6   2022-03-31   hyunhak.roh@dkbmc.com                      BO_실주중도종결_정보전송
 * 1.7   2022-05-27   hyunhak.roh@dkbmc.com                      Drop/Lost 품의 시 Lock 처리
 * 1.8   2022-06-10   hyunhak.roh@dkbmc.com                      BO 금액 0으로 변경 품의 완결 처리조건 -> 수주완료(Won) 조건 제외
 * 1.9   2022-07-18   minhye.park@dkbmc.com                      가장 최근에 생성된 레코드 판별기준: MISID__c -> CreatedDate로 변경
 * 2.0   2023-02-21   gitesh.s@samsung.com                       Added End Date for Drop Activity and Opportunity when Amount = 0(MySales -134)
 * 2.1   2023-09-20   divyam.gupta@samsung.com                   Add the LostResult record for amount 0 dropped case(MySales -300)
 * 2.2   2023-10-16   divyam.gupta@samsung.com                   Mysales-321 change in condition when opportunity activity status changes to 'N/A'.
 * 2.3   2023-10-30   divyam.gupta@samsung.com                   Mysales-343 Put If-Logs inside knox approval of drop /lost functionality.
 * 2.4   11-05-2023   anish.jain@partner.samsung.com             MySales - 216
 * 2.5   2024-01-16   divyam.gupta@samsung.com                   Remove Reference of field LostReason__c and LostReasonLogistics__c where field value was set to 'A1Z0000002ZT04' Suggested by Mrs. Sumin.
 * 2.6   2024-02-05	  sarthak.j1@samsung.com		             MYSALES-415 point 2. 
 * 2.7   2024-02-13	  anish.jain@partner.samsung.com 		     Check contract approval processing for collaboration BO  MYSALES-409 
 * 2.8   2024-02-19   anish.jain@partner.samsung.com             BO Review Approval Issue Check (MS-418) 
 * 2.9   2024-02-21   divyam.gupta@samsung.com                   Mysales-449 (IT) Contract Approval Logic Change.

**/
trigger KnoxApprovalTrigger on KnoxApproval__c (after insert, after update) {
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    System.debug('@@@@@@@@@@@@@@@@@@@@@@ trSwitch : ' + trSwitch);
    Boolean AllSwitch = trSwitch.All__c;
    Boolean MigSwitch = trSwitch.Migration__c; // Data Migration 시 제외할 로직인 경우 true
    Boolean CollaboApproval = trSwitch.CollaboApproval__c;
    Boolean FakeTest = trSwitch.FakeTest__c;
     // V 2.3 Divyam
    List<IF_Log__c> oppIfLog = new List<IF_Log__c>();   
    if(AllSwitch) {
        System.debug(' ■ [' + Trigger.operationType + '] KnoxApprovalTrigger');

        switch on trigger.operationType{
            when AFTER_INSERT{
                if(!MigSwitch) {
                    setOpptyActivityStatus(Trigger.new, null);
                    setRecordLock(Trigger.new, null);
                    // sendLsDashBoard(Trigger.new, null);
                }
            }
            when AFTER_UPDATE {
                if(!MigSwitch) {
                    setOpptyActivityStatus(Trigger.new, Trigger.oldMap);
                    setRecordLock(Trigger.new, Trigger.oldMap);
                    System.debug('KnoxApprovalTrigger_Entry');
                    if(CollaboApproval) syncStatusCollaboKnoxApproval(Trigger.new, Trigger.oldMap);
                    updateOpptyLostStageAfterSync(Trigger.new, Trigger.oldMap);
                    // sendLsDashBoard(Trigger.new, Trigger.oldMap);
                }
            }
        }
    }
    
    //Added by Anish - v 2.7
        if(oppIfLog.size()>0){
            insert oppIfLog;
           }

    /**
     * Knox Approval 진행중 상태값인 경우 Record Lock 처리
     * Knox Approval 진행중 상태값이 아닌 경우 Record Unlock 처리
     */
    private static void setRecordLock(List<KnoxApproval__c> objList, Map<Id, KnoxApproval__c> oldMap) {
        System.debug('Method Entry@');
        String oppidlog =''; //Added by Anish - v 2.7
        String Apex_Methodname = 'setRecordLock'; //Added by Anish - v 2.7
        String guId     = IF_Util.generateGuid(); //Added by Anish - v 2.7
        
        try{  //Added by Anish - v 2.7
        Set<String> knoxActivityIdSet = new Set<String>(); 
        for(KnoxApproval__c knox : objList){
            if(knox.OpportunityActivity__c != null){
                knoxActivityIdSet.add(knox.OpportunityActivity__c);
            }
            //Added by Anish - v 2.7
            if(knox.Opportunity__c != null )
             oppidlog+= knox.Opportunity_Code__c + ', ';  
        }
        Map<Id, Opportunity_Activity__c> opptyActCodeMap = new Map<Id, Opportunity_Activity__c>([
            SELECT Id, Name, Status__c, StartDate__c, EndDate__c, WhatId__c,TransactionName__c ,LostType__c, LostReason__c, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c
            FROM Opportunity_Activity__c 
            WHERE Id =: knoxActivityIdSet]); //Added by Anish - v 2.7
            System.debug('opptyActCodeMap@ ' + opptyActCodeMap);

        // Record Lock 대상 Activity Set 
        Set<String> LOCK_TARGET_ACTIVITY_SET = new Set<String>{ OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
        // 2022-05-27, hyunhak.roh@dkbmc.com, Drop/Lost 품의 시 Lock 처리
                                                                , OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY
                                                                , OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY };
            
            
        System.debug('### KnoxApprovalTrigger :: setRecordLock :: LOCK_TARGET_ACTIVITY_SET = ' + LOCK_TARGET_ACTIVITY_SET);

        for(KnoxApproval__c knox : objList){
            Boolean isChangedStatus = (oldMap == null) ? true : (knox.Status__c != oldMap.get(knox.Id).Status__c);
                
            System.debug('### KnoxApprovalTrigger :: setRecordLock :: isChangedStatus = ' + isChangedStatus);
            if(isChangedStatus) {
                
                System.debug('### KnoxApprovalTrigger :: setRecordLock :: knox.Status__c = ' + knox.Status__c);
                
                
                if(knox.Status__c == KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS) { // 결재 진행
                    
                    System.debug('### KnoxApprovalTrigger :: setRecordLock :: knox.BizReview__c = ' + knox.BizReview__c);
                    // [Biz Review] Record Lock
                    if(knox.BizReview__c != null){
                        Approval.lock(knox.BizReview__c, false);
                    }
    
                    // [Opportunity] Record Lock
                    if(knox.Opportunity__c != null && knox.OpportunityActivity__c != null){      
                        String opptyActCode = opptyActCodeMap.get(knox.OpportunityActivity__c).TransactionName__c;
                        if(LOCK_TARGET_ACTIVITY_SET.contains(opptyActCode)) { // (2020-01-08) 수주품의 Approval 만 Record Lock 처리
                            Approval.lock(knox.Opportunity__c, false);
                        }
                    } 
    
                } else { // 결재 진행이 아닐 시
                    
                    System.debug('### KnoxApprovalTrigger :: setRecordLock :: knox.Opportunity__c = ' + knox.Opportunity__c);
                    
                    String opptyActCode = opptyActCodeMap.get(knox.OpportunityActivity__c).TransactionName__c;
                    if(knox.Opportunity__c != null){
                        // 2022-05-27, hyunhak.roh@dkbmc.com, Drop/Lost 품의 시 Lock 처리
                        // 결재 완결이면서, Activity Drop/Lost 인 경우, Lock 처리
                        if(     knox.Status__c == KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                           &&   (   opptyActCode == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY
                                 || opptyActCode == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY )   ){
                            //
                            Approval.lock(knox.Opportunity__c, false);
                        }
                        else {
                            System.debug('### KnoxApprovalTrigger :: setRecordLock :: Opportunity__c = ' + knox.Opportunity__c);
                            Approval.unlock(knox.Opportunity__c, false);                        
                        }
                    }
                }

                // 2021-03-17 결제 상태가 상신중, 승인이 아닐경우 수전위 Record Unlock 처리
                if(knox.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS && knox.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED && knox.BizReview__c != null){
                    System.debug('### KnoxApprovalTrigger :: setRecordLock :: BizReview__c = ' + knox.BizReview__c);
                    Approval.unlock(knox.BizReview__c, false);
                }
            }
        }
             

        if(FakeTest) fakeTest(objList);
        }
        //Added by Anish - v 2.7
        catch (Exception e) {
            System.debug('e : '+ e);
            System.debug('e.getStackTraceString() :  '+e.getStackTraceString());
            System.debug('e.getLineNumber() : '+e.getLineNumber());
              createInterfaceLog2(guId,Apex_Methodname,oppidlog,e);

        } 
        
    }

    /**
     * Knox Approval 상신 상태값에 따라 Opportunity Activity Status 변경
     * Knox Approval 완결 시 Opportunity Field Update
     */
    private static void setOpptyActivityStatus(List<KnoxApproval__c> objList, Map<Id, KnoxApproval__c> oldMap) {
        System.debug('Method Entry@');
       // V 2.3 Divyam 
       String oppidlog ='';
        String Apex_Methodname = 'setOpptyActivityStatus';
        String guId     = IF_Util.generateGuid();
        //Added by Anish - v 2.7
        Map<String,Opportunity_Activity__c> logoppmap = new Map<String,Opportunity_Activity__c>();
        try {   //Added by Anish - v 2.7
        Map<String, Opportunity_Activity__c> opptyActUpdateMap = new Map<String, Opportunity_Activity__c>();
        Map<String, Opportunity> opptyUpdateMap = new Map<String, Opportunity>();
        
        Set<String> knoxActivityIdSet = new Set<String>(); 
        for(KnoxApproval__c knox : objList){
            if(knox.OpportunityActivity__c != null){
                knoxActivityIdSet.add(knox.OpportunityActivity__c);
                // V 2.3 Divyam
                 if(knox.Opportunity__c != null )
                  oppidlog+= knox.Opportunity__c + ', ';  
            }
        }

        Map<Id, Opportunity_Activity__c> opptyActMap = new Map<Id, Opportunity_Activity__c>([
            SELECT  Id, Name, Status__c, StartDate__c, EndDate__c, WhatId__c,TransactionName__c ,LostType__c, LostReason__c,WhatId__r.OpportunityCode__c,WhatId__r.CompanyCode__c,WhatId__r.RecordType.Name , WhatId__r.VRB_Account_Change__c
            FROM    Opportunity_Activity__c 
            WHERE   Id =: knoxActivityIdSet]); //Added by Anish - v 2.7, 2.8
        System.debug('opptyActMap Ani: ' + opptyActMap);
        
        List<KnoxApproval__c> prevKnoxList = [SELECT Id, Name, OpportunityActivity__c, Opportunity__c, Opportunity_Code__c, Status__c, CreatedDate, MISID__c
                                          FROM KnoxApproval__c 
                                          WHERE OpportunityActivity__c in: knoxActivityIdSet 
                                          AND MISID__c LIKE 'SDSSFDC%'
                                          order by CreatedDate desc]; //Added by Anish - v 2.7

        /**
        * 사업기회 수주품의(최초) 결재 승인 후 상태 마감(WON)으로 변경대상 Oppty Ids (수주품의 Activity 시에만 업데이트 필수)
        */
        Set<Id> opptyWonIdSet = opptyAutoWonIdSet(objList, oldMap); 
        //Set<Id> opptyFirstClosedateSet = opptyfirstClosedateSet(objList, oldMap);
        Datetime dt_2021_12 = Datetime.newInstanceGmt(2021, 12, 01);
        Datetime dt_2022 = Datetime.newInstanceGmt(2022, 01, 01);
        Set<Id> sendMailIdSet = new Set<Id>();
        
        //2022-03-31, BO_실주중도종결_정보전송
        Set<Id> setDropLostBoActId = new Set<Id>();
        
        // [S] For Trigger.obj 
        for(KnoxApproval__c obj : objList){
            KnoxApproval__c oldKnoxApproval = oldMap == null ? null : oldMap.get(obj.id);            
            String approvalStatus = obj.Status__c;
            // Trigger.new 객체가 OpportunityActivity__c 객체 기준으로 가장 최근에 생성된 레코드가 아닌 경우 Activity Update Logic Pass
            Boolean isNewestApprovalFlag = true;

            for(KnoxApproval__c prevKnox : prevKnoxList){
                if(prevKnox.OpportunityActivity__c == obj.OpportunityActivity__c){
                    if(String.isBlank(obj.MISID__c)){
                        isNewestApprovalFlag = false;
                        System.debug(' # obj.MISID__c isBlank ');
                        System.debug(' # isNewestApprovalFlag ' + isNewestApprovalFlag);
                        break;
                    }else{
                        //2022.07.18 가장 최근에 생성된 레코드 판별기준: MISID__c -> CreatedDate로 변경
                        if(prevKnox.CreatedDate > obj.CreatedDate ){
                        //if(prevKnox.MISID__c > obj.MISID__c ){
                       
                            System.debug('### KnoxApprovalTrigger :: setOpptyActivityStatus :: prevKnox.CreatedDate:' + prevKnox.CreatedDate);
                            System.debug('### KnoxApprovalTrigger :: setOpptyActivityStatus :: obj.CreatedDate:' + obj.CreatedDate);
                            isNewestApprovalFlag = false;
                            System.debug(' # isNewestApprovalFlag ' + isNewestApprovalFlag);
                            /*
                            //2022.02.18  prevKnox의 createDated가 2021년 12월 생성 데이터, MISID SDSSFDC2022건에 대해 결재 완결시 메일 발송 하도록 추가.
                            String misid = prevKnox.MISID__c;
                            if(oldKnoxApproval != null && prevKnox.CreatedDate >= dt_2021_12 && prevKnox.CreatedDate < dt_2022){
                                Boolean changeStatus = (obj.Status__c == KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED && oldKnoxApproval.Status__c != obj.Status__c);  //status 완결로 변경될 때
                                if(misid.contains('SDSSFDC2022') && changeStatus){  //메일 발송할 Id add
                                     System.debug('prevKnox의 createDated가 2021년 12월 생성 데이터, MISID SDSSFDC2022건에 대해 결재 완결시 메일 발송 하도록 추가.'); sendMailIdSet.add(obj.Id);
                                }
                            }
                            */
                            break;
                        }
                    }
                    /* if(prevKnox.Id > obj.Id) {
                        isNewestApprovalFlag = false;
                        System.debug(' # isNewestApprovalFlag ' + isNewestApprovalFlag);
                        break;
                    } */
                }
            }
            
            //Added by Anish - v 2.7 
            if(obj.OriginKnoxApproval__c != null){
            createInterfaceLog('setOpptyActivityStatus','BO Code : ' + obj.Opportunity_Code__c + ' , isNewestApprovalFlag : ' + isNewestApprovalFlag,obj.Opportunity__c,'S'); //Added by Anish - v 2.7 
            }
           
            if(!isNewestApprovalFlag) {
                continue;
            }
            
            if(obj.OpportunityActivity__c == null){
                continue;
            }
            
            // 결재 후처리 I/F Batch에서 syncFlag__c 만을 업데이트 하는 경우, 이미 해당 로직이 진행되었기 때문에 Logic Pass 처리
            if(oldKnoxApproval == null) { // INSERT
                if(obj.syncFlag__c == 'Y') {
                    continue;
                }
            } else { // UPDATE
                if(oldKnoxApproval.syncFlag__c != 'Y' && obj.syncFlag__c == 'Y') {
                    createInterfaceLog('setOpptyActivityStatus','BO Code : ' + obj.Opportunity_Code__c + ' , Current Sync Flag is (Y) so cannot proceed further',obj.Opportunity__c,'S'); //Added by Anish - v 2.7
                    continue;
                }

                // 상태값이 바뀌지 않은 경우 Logic Pass

                if(oldKnoxApproval.Status__c == obj.Status__c) {

                    //상신이 완료될때 Activity Status가 업데이트되지 않은 경우가 있어 상태값이 2인경우는 아래 로직 수행하도록 pass
                    if(obj.Status__c != '2'){   
                        continue; 
                    }
                }
            }
             
            Opportunity_Activity__c targetOpptyAct = opptyActMap.get(obj.OpportunityActivity__c);
            createInterfaceLog('setOpptyActivityStatus','BO Code : ' + obj.Opportunity_Code__c + ' ,Company Code : '  + targetOpptyAct.WhatId__r.CompanyCode__c + ' , Target Opportunity Activity Entered into the function with Status : ' + targetOpptyAct.Status__c,obj.Opportunity__c,'S'); //Added by Anish - v 2.7
            //START V 2.3 Divyam
            Opportunity_Activity__c oppact = targetOpptyAct;
            logoppmap.put(oppact.WhatId__c,oppact);
            // END V 2.3
            Opportunity opp = new Opportunity();
            String opptyActivityStatus = '';
            String opptyChangeApprovalStatus = approvalStatus;
            //2022-08-08 수주품의 액티비티 상태 표시 상세화
            switch on approvalStatus {
                when null{ // knox상태 선택안함
                    //V 2.2 Divyam
                      if(targetOpptyAct.Status__c == null){
                    opptyActivityStatus = 'N/A';
                      }
                } 
                when '-3', '-2', '-1'{ // knox 결재 시작안함
                    opptyActivityStatus = 'Not Started';
                }
                when  '0', '1'{ // 1. Knox 결재 진행중
                    opptyActivityStatus = 'In Progress';
                    
                    //Added by Anish - v 2.8
                    if(targetOpptyAct.TransactionName__c == 'ZP21'){
                        System.debug('ZP21 Entry');
                        // [사업등급 변경 결재] Opportunity Activity
                        if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                            opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                        } else {
                            opp = new Opportunity();
                        }
                        opp.Id = targetOpptyAct.WhatId__c;
                        System.debug('ZP21 finale :'+ targetOpptyAct.WhatId__r.VRB_Account_Change__c);
                        if(targetOpptyAct.WhatId__r.VRB_Account_Change__c == true){
                        opp.VRB_Account_Change__c = false; 
                        opptyUpdateMap.put(opp.Id,opp);
                        }
                    }
                    
                }
                when  '2', '5', '6'{ // 2. Knox 결재 완결
                    opptyActivityStatus = 'Completed';
                   
                    // Knox 결재 완료 시, Opportunity Activity 완료일자 업데이트
                    targetOpptyAct.EndDate__c = System.today();
                    if(targetOpptyAct.StartDate__c > targetOpptyAct.EndDate__c ) targetOpptyAct.StartDate__c = targetOpptyAct.EndDate__c;
                     
                    // Knox 결재 완료 시, Opportunity Field Update 
                    if(targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL){ 
                        Boolean bUpdateBO = false;
                        
                        if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                            opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                        } else {
                            opp = new Opportunity();
                            opp.Id = targetOpptyAct.WhatId__c;
                        }
                        /*
                        if(opptyFirstClosedateSet.contains(targetOpptyAct.WhatId__c)){
                            opp.FirstCloseDate__c = Date.today();
                            bUpdateBO = true;
                        } 
                            */
                        // [수주 품의] Opportunity Activity
                        if(opptyWonIdSet.contains(targetOpptyAct.WhatId__c)) { 
                            /* seonju.jin@dkbmc.com | 2021-03-26 
                            * 사업기회 수주품의(최초) 결재 승인 후 상태 마감(WON)으로 변경 (after)*/  
                            opp.StageName = OpportunityActivityHelper.OPP_STAGE_WON;
                            bUpdateBO = true;
                        }
                        if(bUpdateBO) opptyUpdateMap.put(opp.Id,opp);                        
                        
                    } else if(targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY
                        || targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY){ 
                        // [Drop / Lost] Opportunity Activity
                        if(targetOpptyAct.LostType__c == 'Z07' || targetOpptyAct.LostType__c =='Z06'){ // 선택한 Lost Type
                            
                            if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                                opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                            } else {
                                opp = new Opportunity();
                            }
                            opp.Id = targetOpptyAct.WhatId__c;
                            opp.StageName = targetOpptyAct.LostType__c;
                            
                    
                            //2022-05-27, hyunhak.roh@dkbmc.com, Drop/Lost 품의 시, BO Status 처리
                            //LostType => Z06 : OPP_STAGE_LOST(Status : E0004)
                            //LostType => Z07 : OPP_STAGE_DROP(Status : E0007)
                            opp.OpportunityStatus__c = (targetOpptyAct.LostType__c == OpportunityActivityHelper.OPP_STAGE_LOST) ? 'E0004' : 'E0007';
                            //V 2.5
                            if(targetOpptyAct.WhatId__r.RecordType.Name != 'HQ'){
                            opp.LostReasonLogistics__c= targetOpptyAct.LostReason__c;
                            }
                            opptyUpdateMap.put(opp.Id,opp);
                            
                            
                            //2022-03-31, BO_실주중도종결_정보전송
                            System.debug('### KnoxApprovalTrigger :: setOpptyActivityStatus :: targetOpptyAct.Id = ' + targetOpptyAct.Id);
                            setDropLostBoActId.add(targetOpptyAct.Id);

                            //System.debug('### [Drop / Lost] setDropLostBoActId, Add ###');
                        }

                    }else if(targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_AGENCY_CONTRACT_EXCEPTION){ 
                        // [계약 대행 예외] Opportunity Activity
                        if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                            opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                        } else {
                            opp = new Opportunity();
                        }
                        opp.Id = targetOpptyAct.WhatId__c;
                        opp.AgencyContractException__c = true;
                        opptyUpdateMap.put(opp.Id,opp);
                        
                    }else if(targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST){
                        // [사업등급 변경 결재] Opportunity Activity
                        if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                            opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                        } else {
                            opp = new Opportunity();
                        }
                        opp.Id = targetOpptyAct.WhatId__c;
                        opp.ChangeApprovalBusinessLevel__c = obj.RequestBusinessLevel__c; // update 속성품의 완료 후, 변경된 사업등급 요청값
                        opptyUpdateMap.put(opp.Id,opp);
                    }
                }
                //Added by Anish - v 2.4
                when  '3'{ // 3. Knox 결재 반려
                    if(targetOpptyAct.TransactionName__c == 'ZP21'){
                    opptyActivityStatus = 'In Progress';
                    }
                    else{
                     opptyActivityStatus = 'Rejected';   
                    }

                }
                when  '4'{ // 4. Knox 결재 상신취소
                    if(targetOpptyAct.TransactionName__c == 'ZP21'){
                    opptyActivityStatus = 'In Progress';
                    }
                    else{
                     opptyActivityStatus = 'Cancelled';   
                    }
                }
                //Added by Anish - v 2.4
            }

            /**
             * Knox 상태에 따른 Oppty, Oppty Act 결재 상태 Field Update
             */
            // Opportunity Activity 상태값 Update
            if(!String.isBlank(opptyActivityStatus)){
                targetOpptyAct.Status__c = opptyActivityStatus;
            }
            createInterfaceLog('setOpptyActivityStatus','BO Code : ' + obj.Opportunity_Code__c + ' ,Company Code : '  + targetOpptyAct.WhatId__r.CompanyCode__c + ' , Target Opportunity Activity Status updated to : ' + targetOpptyAct.Status__c,obj.Opportunity__c,'S'); //Added by Anish - v 2.7
            // Opportunity 사업등급 변경 품의 승인 상태 값 Update (사업등급 변경 결재 시)
            if (targetOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_CHANGE_APPROVAL_REQUEST){  // [사업등급 변경 결재]
                if(opptyUpdateMap.containsKey(targetOpptyAct.WhatId__c)) {
                    opp = opptyUpdateMap.get(targetOpptyAct.WhatId__c);
                } else {
                    opp = new Opportunity();
                }
                opp.Id = targetOpptyAct.WhatId__c;
                opp.ChangeApprovalStatus__c = opptyChangeApprovalStatus;
                opptyUpdateMap.put(opp.Id,opp);
            }
            
            
            opptyActUpdateMap.put(targetOpptyAct.Id,targetOpptyAct);
            
        }

        
            List<Opportunity> opptyUpdateList = new List<Opportunity>(opptyUpdateMap.values());
            List<Opportunity_Activity__c> opptyActUpdateList = new List<Opportunity_Activity__c>(opptyActUpdateMap.values());
            System.debug('KnoxApprovalTrigger.opptyUpdateList.size() : ' + opptyUpdateList.size());
            System.debug('KnoxApprovalTrigger.opptyActUpdateList.size() : ' + opptyActUpdateList.size());
            // V 2.3 Divyam START
            if(opptyUpdateList.size() > 0){
                Map<String,String> lostresultcodemap = new Map<String,String>();
                List<LostResult__c> lostresultlist =[Select id, LostTypeCode__c,Opportunity__c from LostResult__c where Opportunity__c  In :opptyUpdateMap.keyset()];
                system.debug('lostresultlist'+lostresultlist);
                for(LostResult__c lsr :lostresultlist){
                    if(lostresultcodemap.containsKey(lsr.Opportunity__c)){
                        String losttypecode = lostresultcodemap.get(lsr.Opportunity__c);
                        losttypecode+= ', ' + lsr.LostTypeCode__c ;  
                        lostresultcodemap.put(lsr.Opportunity__c,losttypecode);
                    }
                    else {
                        String losttypecode = lsr.LostTypeCode__c;
                        lostresultcodemap.put(lsr.Opportunity__c,losttypecode);
                        
                    }
                }
                
                Map<String,String> logmap = new Map<String,String>();
                for(Opportunity opp1 :opptyUpdateList){
                    if(logoppmap.containskey(opp1.Id)){
                        
                        Opportunity_Activity__c oppaact = logoppmap.get(opp1.Id);
                        String losttypecode;
                        String losttype = '';
                        if(oppaact.LostType__c != null){
                            losttype = oppaact.LostType__c;
                        }
                        if(lostresultcodemap.containskey(opp1.Id)){
                            losttypecode = lostresultcodemap.get(opp1.Id);
                        }
                        String logData1 = '';
                        logData1 += '\n'+ '1. Opportunity Code :' + oppaact.WhatId__r.OpportunityCode__c +'(' +oppaact.WhatId__r.CompanyCode__c +')' + ', Id :' + oppaact.WhatId__c ;
                        logData1 += '\n' + '2. Type and Transaction :'+losttype +'(' +oppaact.TransactionName__c +')';
                        logData1 += '\n' + '3. Set Stage value to '+opp1.StageName;  
                        if(oppaact.TransactionName__c == 'ZPZ1' || oppaact.TransactionName__c == 'ZPZ2'){
                            logData1 += '\n' + '4. Set Status value to '+opp1.OpportunityStatus__c;   
                            logData1 += '\n' + '5. Set Drop/Lost reason value to '+losttypecode;  
                        }
                        logData1 += '\n';
                        logmap.put(opp1.Id,logData1);
                    }
                } 
                Database.SaveResult[] lsr = Database.Update(opptyUpdateList, false);
                system.debug('listafterupdate'+opptyUpdateList);
                system.debug('Saveresultlist'+lsr);
                integer i=0;
                for(Database.SaveResult sv : lsr){
                    system.debug('svid' +sv.getId());
                    String logData2 ='';
                    String Statuscode = 'S';
                    
                    if(sv.isSuccess()){
                        String oppid = opptyUpdateList.get(i).Id;
                        logData2 = logmap.get(oppid);
                        logData2 += '\n' + 'Success ';
                        createInterfaceLog('setOpptyActivityStatus',logData2,oppid,Statuscode);
                        
                    }
                    else{
                        String oppid = opptyUpdateList.get(i).Id;
                        logData2 = logmap.get(oppid);
                        for(Database.Error err : sv.getErrors()){
                            logData2 += '\n' + 'Error: '+ err ;
                        }
                        Statuscode = 'E';
                        createInterfaceLog('setOpptyActivityStatus',logData2,oppid,Statuscode);
                    }
                    i++;
                    
                }  
                // V 2.3 END
                
            }
            
            if(opptyActUpdateList.size() > 0){
                
                Database.Update(opptyActUpdateList, false);
                
                
                
                //2022-03-31, BO_실주중도종결_정보전송
                if(setDropLostBoActId.size() > 0){                    
                    System.debug('### KnoxApprovalTrigger :: setOpptyActivityStatus :: opptyActUpdateList = ' + opptyActUpdateList);
                    System.debug('### KnoxApprovalTrigger :: setOpptyActivityStatus :: setDropLostBoActId = ' + setDropLostBoActId);
                    
                    //Database.executeBatch(new Batch_SendDropLostInfo(setDropLostBoActId), 50); // Commented out as part of v-2.6
                    //System.debug('### [Drop / Lost] setDropLostBoActId, Happend~~!! ###'); 
                }
            }
            
            
        } catch (Exception e) {
            System.debug('e : '+ e);
            System.debug('e.getStackTraceString() :  '+e.getStackTraceString());
            System.debug('e.getLineNumber() : '+e.getLineNumber());
            //V 2.3 Divyam
              createInterfaceLog2(guId,Apex_Methodname,oppidlog,e);

        }   
              
        //if(sendMailIdSet.size() > 0) SendActCompleteEmail.sendKnoxMail(sendMailIdSet);
        
    }
    /*
    private static Set<Id> opptyfirstClosedateSet(List<KnoxApproval__c> objList, Map<Id,KnoxApproval__c> oldMap){
        
        Set<Id> firstClosedateOpptyIdSet = new Set<Id>();

        Set<String> opptyIdSet = new Set<String>();
        for(KnoxApproval__c knox : objList){
            if(oldMap == null || String.isBlank(knox.Opportunity__c) || String.isBlank(knox.OpportunityActivity__c) ) continue;  // insert Pass
            if(oldMap.get(knox.Id).Status__c == knox.Status__c) continue;  // Status 가 바뀌지 않은 경우 Pass
            if(knox.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED) continue;   // 완료가 아닌 경우
            opptyIdSet.add(knox.Opportunity__c);
        }
        
        // 사업기회 정보 조회
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT Id, Name, OpportunityStatus__c , AgencyContract__c, AgencyContractException__c, CompanyCode__c, StageName FROM Opportunity WHERE Id IN :opptyIdSet and FirstCloseDate__c = null]);
        
        // 최초 수주품의 완료된 knox Approval 정보 조회
        List<AggregateResult> knoxApprovalList =  [
                SELECT Opportunity__c 
                FROM KnoxApproval__c 
                WHERE Opportunity__c = :opptyIdSet
                  AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                  AND Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                  AND Opportunity__r.FirstCloseDate__c = null
                GROUP BY Opportunity__c 
                HAVING COUNT(Status__c) = 1         ];
        
        for(AggregateResult knox: knoxApprovalList){
            Opportunity oppty = opptyMap.get((String)knox.get('Opportunity__c'));
            System.debug('### KnoxApprovalTrigger :: opptyfirstClosedateSet :: oppty =' +oppty);
            firstClosedateOpptyIdSet.add(oppty.Id);
            
        }
        return firstClosedateOpptyIdSet;
    }
    */
   
    /**
    * @description 사업기회 수주품의(최초) 결재 승인 후 상태 마감(WON)으로 변경 (after)
    * @author seonju.jin@dkbmc.com | 2021-03-25 
    * @param List<KnoxApproval__c> objList
    * @return Set<Id> opptyIdSet  Opportunity Won로 변경할 oppty Id Set
    **/
    private static Set<Id> opptyAutoWonIdSet(List<KnoxApproval__c> objList, Map<Id,KnoxApproval__c> oldMap){
        /**
         * 수주품의(최초) 결재 승인 후 상태 마감(WON) 변경 기준
         * 1. 단품 사업기회(입력된 솔루션의 사업속성(BizAttribute)가 S124, S125로 구성된 Oppty)
         * 2. 계약대행 사업기회(계약대행 check X , 계약 대행 예외 check false인 사업기회)
         * 3. 자회사/해외법인 사업기회의 경우
         */
        System.debug('Method Entry@');
        String oppidlog =''; //Added by Anish - v 2.7
        String Apex_Methodname = 'opptyAutoWonIdSet'; //Added by Anish - v 2.7
        String guId     = IF_Util.generateGuid(); //Added by Anish - v 2.7

        Map<String,Opportunity_Activity__c> logoppmap = new Map<String,Opportunity_Activity__c>(); //Added by Anish - v 2.7
        Set<Id> wonUpdateOpptyIdSet = new Set<Id>();
        Set<Opportunity> wonUpdateOpptySet = new Set<Opportunity>();   //Added by Anish - v 2.7
        try{  //Added by Anish - v 2.7

            Set<String> opptyIdSet = new Set<String>();
            //Added by Anish - v 2.7
            Map<String,String> knoxCode = new Map<String,String>();
        for(KnoxApproval__c knox : objList){
            if(oldMap == null || String.isBlank(knox.Opportunity__c) || String.isBlank(knox.OpportunityActivity__c) ) continue;  // insert Pass
            if(oldMap.get(knox.Id).Status__c == knox.Status__c) continue;  // Status 가 바뀌지 않은 경우 Pass
            if(knox.Status__c != KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED) continue;   // 완료가 아닌 경우
            
            opptyIdSet.add(knox.Opportunity__c);
            //Added by Anish - v 2.7
            if(knox.Opportunity__c != null )
            oppidlog+= knox.Opportunity_Code__c + ', '; 
            knoxCode.put(knox.Opportunity__c,knox.Opportunity_Code__c);
        }
        
        // 사업기회 정보 조회
        Map<Id, Opportunity> opptyMap = new Map<Id, Opportunity>([SELECT Id, Name, OpportunityStatus__c , AgencyContract__c, AgencyContractException__c, CompanyCode__c, StageName FROM Opportunity WHERE Id IN :opptyIdSet]);

        // 최초 수주품의 완료된 knox Approval 정보 조회
        List<AggregateResult> knoxApprovalList =  [
                SELECT Opportunity__c 
                FROM KnoxApproval__c 
                WHERE Opportunity__c = :opptyIdSet
                  AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                  AND Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                GROUP BY Opportunity__c 
                HAVING COUNT(Status__c) = 1         ]; 

        //최초 수주품의 완료된 사업기회 recordId List
        Set<String> opptyIdList = new Set<String>();  
        for(AggregateResult knox: knoxApprovalList){
            opptyIdList.add((String)knox.get('Opportunity__c'));
        }
        
        /*단품 사업기회 찾기*/
        List<Solution__c> solutionList = [SELECT Id, Name, Opportunity__c, BizAttribute__c, BizAttribute__r.Code__c FROM Solution__c WHERE Opportunity__c IN :opptyIdList AND SendSAP__c = true AND DeletionFlag__c = false ORDER BY Opportunity__c];
        Map<String,Boolean> OpptySolBizMap = new Map<String,Boolean>();

        for(String Id: opptyIdList){
            Integer solutionCnt = 0;       // SAP전송 된 솔루션 갯수
            Integer notSigleBiz = 0;       // 단품유형(S124, S125)이 아닌 bizAatribute 갯수
            for(Solution__c sol: solutionList){
                if(Id == sol.Opportunity__c){
                    solutionCnt ++;
                    if(sol.BizAttribute__r.Code__c != 'S124' && sol.BizAttribute__r.Code__c != 'S125'){
                        notSigleBiz++;
                    }
                }
            }

            if(solutionCnt > 0){
                if(notSigleBiz == 0) OpptySolBizMap.put(Id,true);  //단품유형만 있는 솔루션
                else OpptySolBizMap.put(Id,false);
            }else{
                //전송된 솔루션갯수가 0이면 update 하지않음.
                OpptySolBizMap.put(Id,false);
            }
        }
        
        /* 사업기회 stageName update */
        Boolean stageUpdate = false;

        for(AggregateResult knox: knoxApprovalList){
            Opportunity oppty = opptyMap.get((String)knox.get('Opportunity__c'));
            if(oppty.StageName == OpportunityActivityHelper.OPP_STAGE_CLEANSED) continue;   //2021.07.05 seonju.jin / StageName Cleansed(Z08) 제외

            //1. 단품 사업기회
            if(OpptySolBizMap.containsKey(oppty.Id)){
                if(OpptySolBizMap.get(oppty.Id)) stageUpdate = true;
            }
            
            //2. 계약대행 사업기회
            if(oppty.AgencyContract__c && !oppty.AgencyContractException__c){
                stageUpdate = true;
            }
            
            //3. 자회사/해외법인 사업기회의 경우
            if(oppty.CompanyCode__c != 'T100'){
                stageUpdate = true;
            }
            
            // Won 업데이트 할 사업기회 대상 Id Add
            if(stageUpdate){
                wonUpdateOpptyIdSet.add(oppty.Id);
                wonUpdateOpptySet.add(oppty);
            }

        }
          
            
        //사업기회 stageName Won할 대상인 Knox Approval Id Set 반환
        return wonUpdateOpptyIdSet;
        }
        //Added by Anish - v 2.7
        catch (Exception e) {
            System.debug('e : '+ e);
            System.debug('e.getStackTraceString() :  '+e.getStackTraceString());
            System.debug('e.getLineNumber() : '+e.getLineNumber());
              createInterfaceLog2(guId,Apex_Methodname,oppidlog,e);
            
              return wonUpdateOpptyIdSet;
        }  
        
    }

    /**
    * @description  [후처리 if-093 이후 로직] 수주품의 결재 후 처리시 결재금액 0원 -> Lost 처리
    * @author hj.lee@dkbmc.com | 2021-03-31 
    * @param objList 
    * @param oldMap 
    **/
    private static void updateOpptyLostStageAfterSync(List<KnoxApproval__c> objList, Map<Id,KnoxApproval__c> oldMap){
        /**
         * [VOC] 수주완료(Won) 이후, 수주변경 품의를 수행하는데, 이때 수주금액이 0원일 경우,
         * - 단계: Lost 로 반영,
         * - 상태: Lost 로 반영.
         * - 중도종결/실주 Activity : 완결처리
         */
        System.debug('Method Entry@');
        String oppidlog =''; //Added by Anish - v 2.7
        String Apex_Methodname = 'updateOpptyLostStageAfterSync'; //Added by Anish - v 2.7
        String guId     = IF_Util.generateGuid(); //Added by Anish - v 2.7
       
        Map<String,Opportunity_Activity__c> logoppmap = new Map<String,Opportunity_Activity__c>(); //Added by Anish - v 2.7
        try{  //Added by Anish - v 2.7
        Set<String> lostUpdateOpptyIdSet = new Set<String>();
        /**
         * [구현 조건]
         * 1) Opportunity Stage Name 'Won' 인 경우
         * 2) Opportunity Activity Contract Approval (수주변경 품의 결재 시)
         * 3) 결재 상태값 수신 이후(결재 상태값 '2', '3', '4', 에 대해서 후처리 진행 됨), 후처리 로직(if-093)이 진행되었을때 (진행 기준 SyncFlag = 'S'), I/F 받은 금액이 0 인 경우
         */
        Set<String> opptyIdSet = new Set<String>();

        //2022-05-27, hyunhak.roh@dkbmc.com, BO 수주완료(Won) 상태에서 금액 0으로 변경 품의 완결 시 처리
        //'Lost'가 아닌 'Drop' 처리
        //사유 반영 : Biz. Withdrawal (사업 참여 취소) - A1Z0000002ZT04
        //2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
        Map<Id,Boolean> confirmOppty = new Map<Id,Boolean>();
        for(KnoxApproval__c knox : objList){
            System.debug('# ActivityTransactionName__c : ' + knox.ActivityTransactionName__c);            
            if(oldMap == null || String.isBlank(knox.Opportunity__c) || String.isBlank(knox.OpportunityActivity__c) ) continue;
            if(knox.ActivityTransactionName__c != OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL) continue; // 수주품의가 아닌경우 Pass
            if(oldMap.get(knox.Id).syncFlag__c == knox.syncFlag__c) continue;  // 후처리 IF Status 가 바뀌지 않은 경우 Pass
            if(knox.syncFlag__c != 'S') continue; // 후처리 IF 성공 플래그 'S' 가 아닌 경우
            if(knox.Status__c == '2'){ //2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
                confirmOppty.put(knox.Opportunity__c,true);
            }else{
                confirmOppty.put(knox.Opportunity__c,false);
            }
            opptyIdSet.add(knox.Opportunity__c);
            // Added by Anish - v 2.7 
                 if(knox.Opportunity__c != null )
                  oppidlog+= knox.Opportunity_Code__c + ', ';  
            
        }
        
         // 수주 품의이고, Stage가 Won, Amount 값이 0인 KnoxApproval Oppty List 찾기
         List<AggregateResult> knoxApprovalList = [
            SELECT  Opportunity__c 
            FROM    KnoxApproval__c 
            WHERE   Opportunity__c = :opptyIdSet
                    AND OpportunityActivity__r.TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                    //2022-06-10, hyunhak.roh@dkbmc.com, BO 금액 0으로 변경 품의 완결 처리조건 -> 수주완료(Won) 조건 제외
                    //AND Opportunity__r.StageName = : OpportunityActivityHelper.OPP_STAGE_WON
                    AND Opportunity__r.Amount = 0
                    AND Status__c = '2'//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
            GROUP BY Opportunity__c ];
        
        // 변경 품의 recordId List
        Set<String> opptyIdList = new Set<String>();  
        for(AggregateResult knox: knoxApprovalList){
            lostUpdateOpptyIdSet.add((String)knox.get('Opportunity__c'));
        }

        // Opportunity 의 단계를 'LOST' 로 업데이트
        List<Opportunity> updateLostOpptyTargetList = new List<Opportunity>();
        for(String opptyId : lostUpdateOpptyIdSet) {
            Opportunity oppty = new Opportunity();
            oppty.Id = opptyId;
            //oppty.StageName = OpportunityActivityHelper.OPP_STAGE_LOST; // Lost Update
            //2022-05-27, hyunhak.roh@dkbmc.com, BO 수주완료(Won) 상태에서 금액 0으로 변경 품의 완결 시 처리
            //2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
            if(confirmOppty.get(oppty.Id)) 
                oppty.StageName = OpportunityActivityHelper.OPP_STAGE_DROP; // Drop Update
            //2022-06-10, hyunhak.roh@dkbmc.com 추가
            oppty.ActivityStatus__c         = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
            // V 2.5
            //oppty.LostReasonLogistics__c  = 'A1Z0000002ZT04';     //사유 반영 : Biz. Withdrawal (사업 참여 취소) - A1Z0000002ZT04
            // v2.0 - Gitesh Saini
            oppty.ZPZ2_EndDate__c = System.today();
            // v2.0
            updateLostOpptyTargetList.add(oppty);
        }

        // 기존에 등록된 Drop or Lost Activity 찾기
        Set<String> dropLostActString = new Set<String>{ OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY, 
                                                         OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY };
        List<Opportunity_Activity__c> dropListOpptyActList  = [
            SELECT  Id, WhatId__c, TransactionName__c, ExtId__c
            FROM    Opportunity_Activity__c
            WHERE   WhatId__c = :opptyIdSet
                    AND TransactionName__c IN :dropLostActString
        ];
        Map<String, Opportunity_Activity__c> dropListOpptyActMap = new Map<String, Opportunity_Activity__c>();
        for(Opportunity_Activity__c opptyAct : dropListOpptyActList) {
            String uniqueKey = opptyAct.WhatId__c + opptyAct.TransactionName__c;
            dropListOpptyActMap.put(uniqueKey, opptyAct);
        }
        // Opportunity Activity Lost Activity 완료상태로 업데이트
        List<Opportunity_Activity__c> upsertLostOpptyActTargetList = new List<Opportunity_Activity__c>();
         // V 2.1 Added by Divyam Gupta
        Map<Id,Opportunity_Activity__c> oppactmap = new Map<Id,Opportunity_Activity__c>();
        
        for(Opportunity oppty : updateLostOpptyTargetList){
            String lostKey = oppty.Id + OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY;
            String dropKey = oppty.Id + OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
            // Lost Activity 있으면 해당 Activity를 완결처리
            if(dropListOpptyActMap.containsKey(lostKey) && confirmOppty.get(oppty.Id)){//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
                Opportunity_Activity__c lostActivity = dropListOpptyActMap.get(lostKey);
                lostActivity.Status__c = 'Completed';
                //lostActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_LOST;
                //2022-05-27, hyunhak.roh@dkbmc.com, BO 수주완료(Won) 상태에서 금액 0으로 변경 품의 완결 시 처리
                lostActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP;
                //V 2.5 
                //lostActivity.LostReason__c = 'A1Z0000002ZT04';    //사유 반영 : Biz. Withdrawal (사업 참여 취소) - A1Z0000002ZT04
                upsertLostOpptyActTargetList.add(lostActivity);
                 // V 2.1 Added by Divyam Gupta
                oppactmap.put(lostActivity.Id,lostActivity);
                // V 2.9 Divyam Gupta
                //break;
            }
            if(dropListOpptyActMap.containsKey(dropKey) && confirmOppty.get(oppty.Id)){//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
                // Drop Activity 가 있으면 해당 Activity의 Transaction Name, LostType을 변경
                Opportunity_Activity__c dropActivity = dropListOpptyActMap.get(dropKey);
                dropActivity.Status__c = 'Completed';
                //dropActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_LOST;
                //dropActivity.TransactionName__c = OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY;
                //2022-05-27, hyunhak.roh@dkbmc.com, BO 수주완료(Won) 상태에서 금액 0으로 변경 품의 완결 시 처리
                dropActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP;
                dropActivity.TransactionName__c = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
                // V 2.5
               // dropActivity.LostReason__c = 'A1Z0000002ZT04';    //사유 반영 : Biz. Withdrawal (사업 참여 취소) - A1Z0000002ZT04
                // v2.0 - Gitesh Saini
                dropActivity.EndDate__c = oppty.ZPZ2_EndDate__c;
                // v2.0
                upsertLostOpptyActTargetList.add(dropActivity);
                 // V 2.1 Added by Divyam Gupta
                oppactmap.put(dropActivity.Id,dropActivity);
                // V 2.9 Divyam Gupta
                //break;
            }
            // Drop, Lost Activity 모두 없는 경우 생성
            if(!dropListOpptyActMap.containsKey(lostKey) && !dropListOpptyActMap.containsKey(dropKey) && confirmOppty.get(oppty.Id)) {//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
                Opportunity_Activity__c lostActivity = new Opportunity_Activity__c();
                lostActivity.WhatId__c = oppty.Id;//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선
                lostActivity.Status__c = 'Completed';
                //lostActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_LOST;
                //lostActivity.TransactionName__c = OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY;
                //2022-05-27, hyunhak.roh@dkbmc.com, BO 수주완료(Won) 상태에서 금액 0으로 변경 품의 완결 시 처리
                lostActivity.LostType__c = OpportunityActivityHelper.OPP_STAGE_DROP;
                lostActivity.TransactionName__c = OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY;
                //V 2.5
                //lostActivity.LostReason__c = 'A1Z0000002ZT04';    //사유 반영 : Biz. Withdrawal (사업 참여 취소) - A1Z0000002ZT04
                lostActivity.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(lostActivity);
                // v2.0 - Gitesh Saini
                lostActivity.EndDate__c = oppty.ZPZ2_EndDate__c;
                // v2.0
                upsertLostOpptyActTargetList.add(lostActivity);
                // V 2.9 Divyam Gupta
               // break;
            }
        }

        
            if(updateLostOpptyTargetList.size() > 0){
                Database.SaveResult[] lsr = Database.Update(updateLostOpptyTargetList, false); // Added by Anish - v 2.7
                // Added by Anish - v 2.7
                integer i=0;
                for(Database.SaveResult sv : lsr){
                    system.debug('svid' +sv.getId());
                    String logData2 ='';
                    String Statuscode = 'S';
                    
                    if(sv.isSuccess()){
                        String oppid = updateLostOpptyTargetList.get(i).Id;
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c != null && updateLostOpptyTargetList.get(i).CompanyCode__c != null){
                        logData2 = 'BO Code : ' + updateLostOpptyTargetList.get(i).OpportunityCode__c + ' ,' + 'Company Code : ' + updateLostOpptyTargetList.get(i).CompanyCode__c;
                        }
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c != null && updateLostOpptyTargetList.get(i).CompanyCode__c == null){
                        logData2 = 'BO Code : ' + updateLostOpptyTargetList.get(i).OpportunityCode__c;
                        }
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c == null && updateLostOpptyTargetList.get(i).CompanyCode__c != null){
                        logData2 = 'Company Code : ' + updateLostOpptyTargetList.get(i).CompanyCode__c;
                        }
                        logData2 += '\n' + 'Success ';
                        createInterfaceLog('updateOpptyLostStageAfterSync',logData2,oppid,Statuscode);
                        
                    }
                    else{
                        String oppid = updateLostOpptyTargetList.get(i).Id;
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c != null && updateLostOpptyTargetList.get(i).CompanyCode__c != null){
                        logData2 = 'BO Code : ' + updateLostOpptyTargetList.get(i).OpportunityCode__c + ' ,' + 'Company Code : ' + updateLostOpptyTargetList.get(i).CompanyCode__c;
                        }
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c != null && updateLostOpptyTargetList.get(i).CompanyCode__c == null){
                        logData2 = 'BO Code : ' + updateLostOpptyTargetList.get(i).OpportunityCode__c;
                        }
                        if(updateLostOpptyTargetList.get(i).OpportunityCode__c == null && updateLostOpptyTargetList.get(i).CompanyCode__c != null){
                        logData2 = 'Company Code : ' + updateLostOpptyTargetList.get(i).CompanyCode__c;
                        }
                        for(Database.Error err : sv.getErrors()){
                            logData2 += '\n' + 'Error: '+ err ;
                        }
                        Statuscode = 'E';
                        createInterfaceLog('updateOpptyLostStageAfterSync',logData2,oppid,Statuscode);
                    }
                    i++;
                    
                }  
            }
            if(upsertLostOpptyActTargetList.size() > 0){
                Database.Upsert(upsertLostOpptyActTargetList, Opportunity_Activity__c.Fields.ExtId__c, false);//2022-09-13, yeongju.baek@dkbmc.com, 완결 상태가 아님에도 Drop 처리되는 로직 개선 
               // V 2.1 Added by Divyam Gupta
               dropActivtyLostResultRecCreation.addLostResultforDrop(upsertLostOpptyActTargetList,oppactmap);
                    
                
            }
            
        } catch (Exception e) {
            System.debug('e : '+ e);
            System.debug('e.getStackTraceString() :  '+e.getStackTraceString());
            System.debug('e.getLineNumber() : '+e.getLineNumber());
            createInterfaceLog2(guId,Apex_Methodname,oppidlog,e); //Added by Anish - v 2.7
        }
        
        
    }


    /**
    * @description  [협업 BO 최초 수주품의 Activity 제어] 법인 협업 기회의 수주품의 최초 결재 시 복제한 본사 KnoxApproval 결재 상태값 동기화 처리 
    * @author hj.lee@dkbmc.com | 2021-03-25 
    * @param newList 
    * @param oldMap 
    **/
    private static void syncStatusCollaboKnoxApproval(List<KnoxApproval__c> newList, Map<Id,KnoxApproval__c> oldMap){
        System.debug('Method Entry@');
        String oppidlog =''; //Added by Anish - v 2.7
        String Apex_Methodname = 'syncStatusCollaboKnoxApproval'; //Added by Anish - v 2.7
        String guId     = IF_Util.generateGuid(); //Added by Anish - v 2.7
        
        Map<String,Opportunity_Activity__c> logoppmap = new Map<String,Opportunity_Activity__c>(); //Added by Anish - v 2.7
        try{  //Added by Anish - v 2.7
        System.debug('syncStatusCollaboKnoxApproval');
        List<KnoxApproval__c> updateCopyKnoxApprovalList = new List<KnoxApproval__c>();
        Map<String, KnoxApproval__c> copyKnoxApprovalMap = new Map<String, KnoxApproval__c>(); // Map<originKnoxId, copyKnox obj>
        List<KnoxApproval__c> copyKnoxApprovalList = [SELECT Id, OriginKnoxApproval__c, Status__c ,Opportunity__c ,Opportunity__r.OpportunityCode__c, Opportunity__r.CompanyCode__c, OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c, OriginKnoxApproval__r.Opportunity__r.CompanyCode__c
                                                      FROM   KnoxApproval__c 
                                                      WHERE  OriginKnoxApproval__c IN :newList]; //Added by Anish - v 2.7
        for(KnoxApproval__c copyKnox : copyKnoxApprovalList) {
            copyKnoxApprovalMap.put(copyKnox.OriginKnoxApproval__c, copyKnox);
        }
        
       
        for(KnoxApproval__c newKnox : newList){
            System.debug('1)OriginalKnoxApproval 이 아닌 경우');
            if(!copyKnoxApprovalMap.containsKey(newKnox.Id)) 
            { continue; }// OriginalKnoxApproval 이 아닌 경우 Pass
            System.debug('2)상태값이 바뀌지 않은 경우');
            if(newKnox.Status__c == oldMap.get(newKnox.Id).Status__c) {
                continue;
            } // 상태값이 바뀌지 않은 경우 Pass
            System.debug('3)newKnox.Opportunity__c blank');
            if(String.isBlank(newKnox.Opportunity__c)) continue;
            System.debug('4)newKnox.OpportunityActivity__c blank');
            if(String.isBlank(newKnox.OpportunityActivity__c)) continue;
            System.debug('pass');

            KnoxApproval__c copyKnox = copyKnoxApprovalMap.get(newKnox.Id);
            copyKnox.Status__c = newKnox.Status__c;
            updateCopyKnoxApprovalList.add(copyKnox);
            // Added by Anish - v 2.7 
            if(newKnox.Opportunity__c != null )
                  oppidlog+= newKnox.Opportunity_Code__c + ', ';  
        }

        if(updateCopyKnoxApprovalList.size() > 0) {            
            //2022.02.23 협업 결재 상태 refresh 할 때, 101에러로 future메소드로 변경함.
            //수정 전 로직
            // Added by Anish - v 2.7
            Database.SaveResult[] lsr = Database.update(updateCopyKnoxApprovalList,false);
            
                // Added by Anish - v 2.7
                integer i=0;
                for(Database.SaveResult sv : lsr){
                    system.debug('svid' +sv.getId());
                    String logData2 ='';
                    String Statuscode = 'S';
                    
                    if(sv.isSuccess()){
                        String oppid = updateCopyKnoxApprovalList.get(i).Opportunity__c;
                        if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c != null){
                        logData2  = 'BO Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c + ' ,' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c == null){
                        logData2  = 'BO Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c ;
                        }
                        if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c == null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c != null){
                        logData2  = 'Company Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c != null){
                        logData2 += '\n' + 'BO Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c + ' ,' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c == null){
                        logData2 += '\n' + 'BO Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c == null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c != null){
                        logData2 += '\n' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c;
                        }
                        logData2 += '\n' + 'Success ';
                        createInterfaceLog('syncStatusCollaboKnoxApproval',logData2,oppid,Statuscode);
                        
                    }
                    else{
                        String oppid = updateCopyKnoxApprovalList.get(i).Opportunity__c;
                         if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c != null){
                        logData2  = 'BO Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c + ' ,' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c == null){
                        logData2  = 'BO Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c ;
                        }
                        if(updateCopyKnoxApprovalList.get(i).Opportunity__r.OpportunityCode__c == null && updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c != null){
                        logData2  = 'Company Code : ' + updateCopyKnoxApprovalList.get(i).Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c != null){
                        logData2 += '\n' + 'BO Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c + ' ,' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c != null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c == null){
                        logData2 += '\n' + 'BO Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c;
                        }
                        if(updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.OpportunityCode__c == null && updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c != null){
                        logData2 += '\n' + 'Company Code : ' + updateCopyKnoxApprovalList.get(i).OriginKnoxApproval__r.Opportunity__r.CompanyCode__c;
                        }
                        for(Database.Error err : sv.getErrors()){
                            logData2 += '\n' + 'Error: '+ err ;
                        }
                        Statuscode = 'E';
                        createInterfaceLog('syncStatusCollaboKnoxApproval',logData2,oppid,Statuscode);
                    }
                    i++;
                    
                }  

            //수정 후 로직
            //KnoxApprovalHelper.updateCollaboApproval(JSON.serialize(updateCopyKnoxApprovalList));
        }
        }
        catch (Exception e) {
            System.debug('e : '+ e);
            System.debug('e.getStackTraceString() :  '+e.getStackTraceString());
            System.debug('e.getLineNumber() : '+e.getLineNumber());
              createInterfaceLog2(guId,Apex_Methodname,oppidlog,e); //Added by Anish - v 2.7

        } 
        
    }

    /**
    * @description 변경된 상태가 완결일 때 IF-042 신대시보드 전송
    * @author seonju.jin@dkbmc.com | 2021-08-04 
    * @param List<KnoxApproval__c> newList 
    * @param Map<Id KnoxApproval__c> oldMap 
    **/
    // private static void sendLsDashBoard(List<KnoxApproval__c> newList, Map<Id,KnoxApproval__c> oldMap){
    //     Set<Id> opptyIdSet = new Set<Id>();
    //     for(KnoxApproval__c newKnox : newList){
    //         if(oldMap != null){
    //             if(newKnox.Status__c == oldMap.get(newKnox.Id).Status__c) continue;     // 상태값이 바뀌지 않은 경우 Pass
    //         }

    //         if(newKnox.Status__c == KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED){
    //             opptyIdSet.add(newKnox.Opportunity__c);
    //         }
            
    //     }
    //     //callout IF-042
    //     if(opptyIdSet.size() > 0) IF_LsDashboardController.calloutDashboardInfo(opptyIdSet);
    // }

    private static void fakeTest(List<KnoxApproval__c> newList){
        Integer i = 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;        
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
        i += 0;
    }
       //START V 2.3 Divyam
       private static void createInterfaceLog(String apexMethod, String logMessage, String oppid, String Statuscode){
        IF_Log__c log = new IF_Log__c();
        log.ApexName__c = 'KnoxApprovalTrigger';
        log.ApexMethod__c =  apexMethod;
        log.InterfaceId__c = 'APPROVAL_RESULT';
        log.LogText__c = logMessage;
        log.StatusCode__c = Statuscode;
        log.LogType__c = 'Trigger';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        log.RequestMessage__c = oppid;
        System.debug( 'knoxApprovalTrigger Log creation'+ log);
        oppIfLog.add(log);
    }
    private static void createInterfaceLog2(String guid, String apexmethod,String OpporId,Exception e) {
        IF_Log__c log = new IF_Log__c();
        log.InterfaceId__c = 'APPROVAL_RESULT';
        log.InterfaceGuid__c = guid;
        log.ApexMethod__c = apexmethod;
        log.ApexName__c = 'KnoxApprovalTrigger';
        log.RequestMessage__c = OpporId;
        log.StatusCode__c = 'E';
        log.LogType__c = 'Trigger';
        log.EndDatetime__c  = System.now();
        log.StartDatetime__c = System.now();
        log.ExceptionType__c = e.getTypeName();
        log.ErrorMessage__c = e.getMessage();
        log.StackTrace__c = e.getStackTraceString();
          oppIfLog.add(log);
    
        }
    // END V 2.3
}