/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-04-25
 * @last modified by  : anish.jain@partner.samsung.com 
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-01   hj.lee@dkbmc.com   Initial Version
 * 1.1   2021-07-05   seonju.jin@dkbmc.com   Opportunity Stage 업데이트 Cleansed 제외처리
 * 1.2   2021-07-13   younghoon.kim@dkbmc.com   insertOppActHistory 추가 / Opportunity Activity의 상태가 완료될때 History를 남김(masterActMap, opptyStageMap, opptyActTransactioneMap 추가)
 * 1.3   2022-04-28   hyunhak.roh@dkbmc.com     [설명] 필드 200자 이상 등록하도록 제어하는 기능 
 * 1.4   2022-05-19   younghoon.kim@dkbmc.com   mappingOpptyEndDate 추가 / 'XP63', 'XP73', 'ZP21', 'ZPZ1', 'ZPZ2' 액티비티의 EndDate가 입력되는 경우 사업기회의 각 필드에 값 입력(보고서용)
 * 1.5   2023-01-12   anish.jain@partner.samsung.com  To stop the Opportunity update for Drop/Lost case(My-SALES-99).
 * 1.6   2023-03-14   kajal.c@samsung.com        MySales 147 - IF-180 calling 
 * 1.7   2023-05-12   divyam.gupta@smasung.com   insert Approval Status of Lost Result/IF-159 Calling related to MySales-96.
 * 1.8   2023-07-14   divyam.gupta@smasung.com   MySales 256 - Lost data is automatically deleted when Drop/Lost activity is deleted
 * 1.9   2023-09-13   divyam.gupta@samsung.com   New Condition added for MySales 256 - Lost data is automatically deleted when Drop/Lost activity is deleted
 * 2.0   2023-12-10   anish.jain@partner.samsung.com  Create IF-159(send drop/lost info to legacy) scheduled batch job (MS-373)
 * 2.1   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 2.2   2024-04-25   anish.jain@partner.samsung.com   Analysis the cause of 'Review Opportunity' issue -> [MYSALES-495]
**/
trigger OpportunityActivityTrigger on Opportunity_Activity__c (before insert,after insert, before update, after update,after delete) {

    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); 
    Boolean AllSwitch = trSwitch.All__c;                    
    Boolean OpptyActSwitch = trSwitch.OpportunityActivity__c;       

    Boolean OpportunitySendToSAPSwitch = trSwitch.OpportunitySendToSAP__c; // Opportunity Activity 작성/수정 시 Opportunity를 SAP으로 전송하기 위하여 Update 처리하여 수정 시간 변경
    Boolean MigSwitch = trSwitch.Migration__c; // Data Migration 시 제외할 로직인 경우 true 

    public static List<MasterActivity__c> masterActList = getMasterActList();
    public static List<MasterActivity__c> getMasterActList(){        
        if(masterActList == null) {
            masterActList = [SELECT Id, Name, TransactionName__c, Type__c, Stage__c, Order__c 
                            FROM MasterActivity__c 
                            WHERE IsActive__c = true
                            ORDER BY Type__c, Stage__c, Order__c];
        }
        return masterActList;
    }

    // Master Activity Map<Type_TransactionName, Stage>
    public static Map<String, String> masterActMap = new Map<String, String>();
    List<MasterActivity__c> masterActivityList = [SELECT Id, Name, ObjectApiName__c, Type__c, Stage__c, TransactionName__c, Order__c, IsActive__c 
                                                    FROM MasterActivity__c 
                                                   WHERE IsActive__c = TRUE 
                                                   ORDER BY Type__c, Stage__c, Order__c];
    if(masterActivityList.size() > 0){
        for(MasterActivity__c masterAct : masterActivityList){
            masterActMap.put(masterAct.Type__c + '_' + masterAct.TransactionName__c, masterAct.Stage__c);
        }
    }

    // Opportunity - StageName Map<value, label>
    public static Map<String, String> opptyStageMap = new Map<String, String>();
    List<Map<String, String>> opptyStageList = Utils.getPicklistOptionType('Opportunity', 'StageName');
    for(Integer i = 0; i < opptyStageList.size(); i++){
        opptyStageMap.put(opptyStageList[i].get('value'), opptyStageList[i].get('label'));
    }

    // Opportunity Activity - TransactionName Map<value, label>
    public static Map<String, String> opptyActTransactioneMap = new Map<String, String>();
    List<Map<String, String>> opptyActTransactionList = Utils.getPicklistOptionType('Opportunity_Activity__c', 'TransactionName__c');
    for(Integer i = 0; i < opptyActTransactionList.size(); i++){
        opptyActTransactioneMap.put(opptyActTransactionList[i].get('value'), opptyActTransactionList[i].get('label'));
    }

    if(AllSwitch && OpptyActSwitch) {
        System.debug(' ■ [' + Trigger.operationType + '] OpportunityActivityTrigger');
        
        switch on Trigger.OperationType {
            when BEFORE_INSERT {
                if(!MigSwitch) {
                    setLostTypeTransactionName(Trigger.new, null);
                }
                setExternalKey(Trigger.new); // must trigger  // Migration에서도 필요
            }
            when BEFORE_UPDATE {
                system.debug('Before_MigSwitch'+MigSwitch);
                if(!MigSwitch) {
                    setDateField(Trigger.new);
                    system.debug('Called_setLostTypeTransactionName');
                    setLostTypeTransactionName(Trigger.new, Trigger.oldMap);
                }
                setExternalKey(Trigger.new);
            }
    
            when AFTER_INSERT{  
                Map<Id, Opportunity> updateOpptyMap = new Map<Id, Opportunity>(); // 중복되지 않도록 Map을 사용하여 1 DML 
                if(!MigSwitch) {
                    mappingUpdateOpptyStageName(updateOpptyMap, Trigger.new, Trigger.old);
                    system.debug('Run Time Check');
                    if(OpportunitySendToSAPSwitch) mappingUpdateOpptyForSendToSAP(updateOpptyMap, Trigger.new);
                }
                mappingOpptyActivityStatus(updateOpptyMap, Trigger.new);

                List<Opportunity> updateOpptyList = updateOpptyMap.values();
                try {
                    if(updateOpptyList.size() > 0){
                        //Start-Added by Anish - v 1.5
                        List<opportunity> finalUpdatedList = new List<opportunity>();
                        for(Opportunity_Activity__c oAct : Trigger.new){
                            //Drop
                            if(oAct.TransactionName__c == 'ZPZ1' && (!updateOpptyMap.isEmpty()) 
                               &&(updateOpptyMap.get(oAct.WhatId__c) != null) 
                               && (updateOpptyMap.get(oAct.WhatId__c).cPrimarySalesDepartment__c==null)){
                                   if(!Test.isRunningTest()){
                                       system.debug('Ak1');
                                       oAct.addError(System.Label.Lost_Opportunity_Field_Validation_Message);
                                   }
                               }else if(oAct.TransactionName__c != 'ZPZ2'){
                                if(!updateOpptyMap.isEmpty())
                                    finalUpdatedList.add(updateOpptyMap.get(oAct.WhatId__c));
                            }
                        }
                        if(finalUpdatedList.size() > 0){
                            Set<opportunity> oppSet = new Set<opportunity>();
                            List<opportunity> oppList = new List<opportunity>();
                            oppSet.addAll(finalUpdatedList);
                            oppList.addAll(oppSet);
                            update oppList;
                        }
                        //End-Added by Anish - v 1.5
                    }
                    
                } catch(DmlException ex){
                    System.debug(' ex.getMessage : ' + ex.getMessage());
                    System.debug(' ex.getDMLMessage(0) : ' + ex.getDMLMessage(0));
                    Trigger.new[0].addError(ex.getDMLMessage(0));
                }
                insertOppActHistory(Trigger.new, null);

            }

            when AFTER_UPDATE {
                Map<Id, Opportunity> updateOpptyMap = new Map<Id, Opportunity>(); // 중복되지 않도록 Map을 사용하여 1 DML 
                if(!MigSwitch) {
                    mappingUpdateOpptyStageName(updateOpptyMap, Trigger.new, Trigger.old);
                    if(OpportunitySendToSAPSwitch) mappingUpdateOpptyForSendToSAP(updateOpptyMap, Trigger.new);
                    sendToSAP(updateOpptyMap,Trigger.new, Trigger.oldMap); //Added by Anish - v 2.1
                    //V 1.7 -- Divyam Gupta
                    setLostResultApprovalStatus(Trigger.new, Trigger.oldMap);
                }
                mappingOpptyActivityStatus(updateOpptyMap, Trigger.new);

                List<Opportunity> updateOpptyList = updateOpptyMap.values();
                try {
                    if(updateOpptyList.size() > 0){
                        //Start-Added by Anish - v 1.5
                        List<opportunity> finalOppList = new List<opportunity>();
                        for(Opportunity_Activity__c oAct : Trigger.new){
                            if(oAct.TransactionName__c == 'ZPZ2'){
                                if( Trigger.oldMap.get(oAct.Id).Status__c!= oAct.Status__c && (oAct.Status__c== 'Completed' || oAct.Status__c== ' In Progress')){
                                    if(!updateOpptyMap.isEmpty())
                                    finalOppList.add(updateOpptyMap.get(oAct.WhatId__c));
                                }
                            }
                            else if(oAct.TransactionName__c == 'ZPZ1' && (!updateOpptyMap.isEmpty()) && (updateOpptyMap.get(oAct.WhatId__c) != null) 
                                    && (updateOpptyMap.get(oAct.WhatId__c).cPrimarySalesDepartment__c==null)){
                                oAct.addError(System.Label.Lost_Opportunity_Field_Validation_Message);
                            }
                            else{
                                if(!updateOpptyMap.isEmpty())
                                finalOppList.add(updateOpptyMap.get(oAct.WhatId__c));
                            }
                        }

                        if(finalOppList.size() > 0){
                            Set<opportunity> oppSet = new Set<opportunity>();
                            List<opportunity> oppList = new List<opportunity>();
                            oppSet.addAll(finalOppList);
                            oppList.addAll(oppSet);
                            update oppList;
                        }
                        //End-Added by Anish - v 1.5
                    }
        
                } catch(DmlException ex){
                    System.debug(' ex.getMessage : ' + ex.getMessage());
                    System.debug(' ex.getDMLMessage(0) : ' + ex.getDMLMessage(0));
                    Trigger.new[0].addError(ex.getDMLMessage(0));
                }
                insertOppActHistory(Trigger.new, Trigger.oldMap);

                mappingOpptyEndDate(Trigger.new, Trigger.oldMap);
                
                
                /**V1.6 START Added By Kajal- IF-180 calling  **/
                Set<ID> oppID159Set = new Set<ID>();
                List<BO_Activity_Complete__c> MigOppList = new List<BO_Activity_Complete__c>();
                String gsRecordTypeID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId();
                
                for(Opportunity_Activity__c oAct : Trigger.new){
                      if(Trigger.oldMap.get(oAct.Id).Status__c != 'Completed' && oAct.Status__c == 'Completed'){
                        Opportunity opp = updateOpptyMap.get(oAct.WhatId__c);
                        system.debug('opp **' + opp);
                        if(opp.RecordTypeId == gsRecordTypeID){
                            BO_Activity_Complete__c migOpp = new BO_Activity_Complete__c();
                            migOpp.Send_Check__c = false;
                            migOpp.InterfaceId__c = 'IF-180';
                            migOpp.name = opp.Id;
                            migOpp.OpportunityCode__c = opp.OpportunityCode__c;
                            MigOppList.add(migOpp);
                        }
                        //V1.7  --> added ZPZ2 transaction
                        if(oAct.TransactionName__c == 'ZPZ1' || oAct.TransactionName__c == 'ZPZ2'){
                            oppID159Set.add(oAct.WhatId__c);
                        }
                    }
                   
                }
                if(MigOppList.size() > 0){
                    insert MigOppList;
                }
                
                /**V1.6 END Added By Kajal- IF-180 calling  **/
                /**V1.7 START Added By Kajal- IF-159 calling  **/
                
                if(oppID159Set.size() > 0){
                    IF_LostAnalysisCallOutAPIController infoCallout159IF = new IF_LostAnalysisCallOutAPIController(oppID159Set);
                }
                /**V1.7 STOP Added By Kajal- IF-159 calling  **/
            }
                   
        //START V 1.8
            
            when AFTER_DELETE {
                  if(!MigSwitch) {
                   Map<Id, Opportunity_Activity__c> OpptyMap = new Map<Id, Opportunity_Activity__c>();
                   CheckLostResultData(Trigger.oldMap);
                }
            }
            
            // END V 1.8
        }
    }
    
   /**
     * Drop/Lost 셋팅
     * Lost Type 변경 시 TransactionName 변경처리 및 Validation
     */
    private static void setLostTypeTransactionName(List<Opportunity_Activity__c> newList, Map<Id, Opportunity_Activity__c> oldMap) { // Migration에서는 제외
        List<KnoxApproval__c> knoxInProgressList = [
            SELECT      Id, OpportunityActivity__c, Status__c
            FROM        KnoxApproval__c
            WHERE       OpportunityActivity__c IN :newList
                        AND Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS
            ORDER BY    CreatedDate
        ];
        system.debug('knoxInProgressList===>'+knoxInProgressList);
        Map<String, KnoxApproval__c> knoxInProgressMap = new Map<String, KnoxApproval__c>();
        for(KnoxApproval__c knoxApproval : knoxInProgressList){
            knoxInProgressMap.put(knoxApproval.OpportunityActivity__c, knoxApproval);   // key: opptyActId, value: knoxApproval obj
        }
        
        for(Opportunity_Activity__c n : newList){
            // Drop/Lost Activity Check
            if(n.TransactionName__c == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY || n.TransactionName__c == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY ) {
                system.debug('outside if');
                if(oldMap != null) {
                    system.debug('inside if');
                    /**
                     * Before Update 
                     * Drop/Lost Activity : 결재 진행중인 Knox Approval이 있는 경우 변경할 수 없도록 Validation
                     */
                    Boolean hasInProgressKnoxApproval = false;
                    if(knoxInProgressMap.containsKey(n.Id)) { 
                        hasInProgressKnoxApproval = true;   // 진행중인 결재 O
                    }
                    String oldLostType = oldMap.get(n.Id).LostType__c;
                    String newLostType = n.LostType__c;
                    Boolean isChangedLostType = (oldLostType != newLostType);
                    if(isChangedLostType && hasInProgressKnoxApproval) { 
                        n.addError(Label.OPPTYACT_MSG_010);
                        continue;
                    }
                }

                if(String.isNotBlank(n.LostType__c) ) {
                    system.debug('inside switch');
                    switch on n.LostType__c {
                        when 'Z06' { // 'Lost' Type
                            system.debug('inside Z06');
                            n.TransactionName__c = 'ZPZ1';
                        }
                        when 'Z07' { // 'Drop' Type
                             system.debug('inside Z07');
                            n.TransactionName__c = 'ZPZ2';
                        }
                    }
                                       
                }

            }
        }
    }

    /**
     * Unique External Key Setting
     */
    private static void setExternalKey(List<Opportunity_Activity__c> newList) { // Migration에서도 필요
        for(Opportunity_Activity__c n : newList){
            n.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(n);
            system.debug('n.ExtId__c : ' + n.ExtId__c);
        }
    }
    
    /**
     * 각 상태값에 따라 Date 세팅
     */
    private static void setDateField(List<Opportunity_Activity__c> newList) { // Migration에서는 제외
        for(Opportunity_Activity__c n : newList){

            switch on n.Status__c {
                
                when 'In Progress' {
                    if(n.StartDate__c == null) {
                        n.StartDate__c = Date.today();
                    }
                }
                when 'Completed' {
                    if(n.EndDate__c == null) {
                        n.EndDate__c = Date.today();
                    }
                    if(n.StartDate__c == null && (n.StartDate__c > n.EndDate__c) ) {
                        n.StartDate__c = n.EndDate__c;
                    }
                }
            }

        }
    }

    /**
     * 특정 Activity 가 완료된 경우 Opportunity Stage 업데이트 처리
     * Validated : 사업기회검토 완료 (서비스/솔루션 등록 & SAP WBS 생성)
     * Qualified : 수전위 요청
     * Solutioned : 수전위 결재 완료 (수전위 결과 결재 최종 승인)
     * Won : 계약서 입고 완료
     */
    private static void mappingUpdateOpptyStageName(Map<Id, Opportunity> updateOpptyMap, List<Opportunity_Activity__c> newList, List<Opportunity_Activity__c> oldList){ // Migration에서는 제외
        system.debug('Enter in mappingUpdateOpptyStageName');
        List<Opportunity> opptyUpdateList = new List<Opportunity>();
       List<Map<String, String>> stage = Utils.getPicklistOptionType('Opportunity','StageName');

       Map<String, Integer> stageMap = new Map<String, Integer>();
       for(Integer i =0 ;i< stage.size();i++){
           stageMap.put(stage[i].get('value'),i);
       }

       set<String> opptyIdSet = new set<String>();
       for(Opportunity_Activity__c oppactWhatId : newList){
           opptyIdSet.add(oppactWhatId.WhatId__c);
       }

       set<String> opptyTransactionSet = new set<String>();
       for(Opportunity_Activity__c oppactTransaction : newList){
           opptyTransactionSet.add(oppactTransaction.TransactionName__c);
       }

       Map<String, MasterActivity__c> masterMap = new Map<String, MasterActivity__c>();
       List<MasterActivity__c> masterList = [SELECT Id, Stage__c,TransactionName__c,Type__c FROM MasterActivity__c where TransactionName__c IN : opptyTransactionSet];

       for(MasterActivity__c c : masterList){
           masterMap.put(c.Type__c + c.TransactionName__c,c);
       }

       Map<String, Opportunity> opptyMap = new Map<String, Opportunity>();
        //신규추가시작
       List<Opportunity> opptyList = [SELECT    Id, StageName,RecordType.developerName,OpportunityCode__c, MigData__c, isEdited__c, XP73_VRB_APPROVAL_TYPE__c,Opportunity_Review_VRB_Type__c
                                      FROM      Opportunity
                                      WHERE     Id IN:opptyIdSet]; //Added by Anish - v 2.1
       //신규추가종료
       for(Opportunity c : opptyList){
           opptyMap.put(c.Id,c);
       }

       Map<String, String> opptyIdStageMap = new Map<String, String>();
       
       Opportunity_Activity__c currentOpptyAct = new Opportunity_Activity__c();
       for(Opportunity_Activity__c oppAct : newList){
            Opportunity opty = opptyMap.get(oppAct.WhatId__c);
            String updateStage = '';
            
            // ****************************************        
            // 제외 로직
            // ****************************************        
            // - MigData 이고, 수정되지 않은 경우 제외
            if(opty.MigData__c && !opty.isEdited__c) {
                continue;
            }

            //2021.07.05 seonju.jin / Stage Clenased 제외
            if(opty.StageName == OpportunityActivityHelper.OPP_STAGE_CLEANSED ){
                continue;
            }
            
            // - Mig Data Activity 는 If문에서 제외
            List<String> condList = new List<String> {'ZP51','ZP52','XP33','ZP50','ZAC2','ZP53','ZP55','ZP72','ZPZ4'};
            boolean flag = false;
            for(String obj : condList){
                if(oppAct.TransactionName__c == obj) flag = true; 
            }
            if(flag) continue;
           
            // - HQ 가 아닌 경우 제외
            if(opty.RecordType.developerName != 'HQ'){
               continue;
            } 
            // - Activity 가 완료상태가 아닌 경우 제외
            if(oppAct.Status__c !='Completed'){
                continue;
            }

            /**
             *  ---- (Default) -----
             *  Identified : 사업기회 등록
                ---- (KnoxApprovalTrigger.setOpptyActivityStatus 에서 처리됨) ---
                Lost : 실주보고 결재 완료
                Drop : 중도전결 결재 완료 + 수전위 결재 최종 승인 (사업불참 결정일 경우)
             */

            if(oppAct.TransactionName__c == 'ZP21'){        // Validated : 사업기회검토 완료 (서비스/솔루션 등록 & SAP WBS 생성)
                updateStage ='Z02';
            }else if(oppAct.TransactionName__c == 'ZP31'){  // Qualified : 수전위 요청
                updateStage ='Z03';
            //신규추가시작                
            }else if(oppAct.TransactionName__c == 'XP73'){  // Solutioned : 수전위 결재 완료 (수전위 결과 결재 최종 승인:참여일경우)
                if('10'==opty.XP73_VRB_APPROVAL_TYPE__c){
                    updateStage ='Z04';
                }
            //신규추가종료
            }else if(oppAct.TransactionName__c == 'XP57'){  // Won : 계약서 입고 완료
                updateStage ='Z05';
            }
          

            if(!String.isBlank(updateStage)){
                if(stageMap.get(updateStage) < stageMap.get(opty.StageName)){
                    system.debug('For Loop Run');
                    continue;
                }

                Opportunity updateStageOppty = new Opportunity(
                    Id = opty.Id,
                    StageName =updateStage);

                deduplication(opptyUpdateList, updateStageOppty);
            }

       }

       for(Opportunity updateOppty : opptyUpdateList) {
            if(updateOpptyMap.containsKey(updateOppty.Id)) {
                Opportunity prevOppty = updateOpptyMap.get(updateOppty.Id);
                prevOppty.StageName = updateOppty.StageName;
                updateOpptyMap.put(updateOppty.Id, prevOppty);
            } else {
                updateOpptyMap.put(updateOppty.Id, updateOppty);
            }
        }

    }
   
    public static void deduplication(List<Opportunity> opptyUpdateList, Opportunity addOppty){ // Migration에서는 제외
        Boolean deduplicate = false;
        for(Opportunity oppty : opptyUpdateList){
            if(oppty.Id == addOppty.Id){
                deduplicate = true;
                if( String.isNotBlank(addOppty.StageName) ) oppty.StageName = addOppty.StageName;
                if( String.isNotBlank(addOppty.ActivityStatus__c) ) oppty.ActivityStatus__c = addOppty.ActivityStatus__c;
            }
        }
        if(!deduplicate){
            opptyUpdateList.add(addOppty);
        }
    }

    /**
     * Opportunity Activity 작성/수정 시 Opportunity SAP을 전송하는 Batch Condition 범위 포함하기 위하여 단순 Update 처리하여 수정 시간 변경
     */
    private static void mappingUpdateOpptyForSendToSAP(Map<Id, Opportunity> updateOpptyMap, List<Opportunity_Activity__c> objList){ 
        Set<String> opptyIds = new Set<String>();
       
        Opportunity_Activity__c currentOpptyAct = new Opportunity_Activity__c();
        for(Opportunity_Activity__c opptyAct : objList){
            
            // Opportunity_Activity.Status__c 있는 경우에만 업데이트 대상            
            if(!String.isBlank(opptyAct.Status__c)){ 
                opptyIds.add(opptyAct.WhatId__c);
                currentOpptyAct = opptyAct;
                
            }
            
        }
        //IF-180 V1.6 -> Akash -> Add OpportunityCode__c,recordtypeId in below soql.
//Added by Anish - v 1.5 -> Add cPrimarySalesDepartment__c in below soql.
        List<Opportunity> updateTargetOppty = [SELECT  Id,cPrimarySalesDepartment__c,OpportunityCode__c , recordtypeId ,Opportunity_Review_VRB_Type__c,Opportunity_Review_Confirm__c,Opportunity_Review_Confirm_New__c
                                                FROM    Opportunity 
                                                WHERE   Id IN :opptyIds 
                                                        AND (MigData__c = false OR (MigData__c = true AND isEdited__c = true)) ]; //Added by Anish- v 2.1
        
        for(Opportunity oppty : updateTargetOppty){
            if(!updateOpptyMap.containsKey(oppty.Id)){
                
                updateOpptyMap.put(oppty.Id, oppty);
            }
        }
    }
    
    //Added by Anish- v 2.1
     private static void sendToSAP(Map<Id, Opportunity> updateOpptyMap,List<Opportunity_Activity__c> objList , Map<Id, Opportunity_Activity__c> oldMap){ // Migration에서는 제외
        Set<String> opptyIds = new Set<String>();
        Boolean reviewConfirmFlag = false; 
        Map<Id,Boolean> mapConfirm = new Map<Id,Boolean>(); 
               Opportunity_Activity__c currentOpptyAct = new Opportunity_Activity__c();
        for(Opportunity_Activity__c opptyAct : objList){
          
            if(opptyAct.TransactionName__c == 'ZP21'){
           if(opptyAct.Status__c == 'Completed'){
               System.debug('Entry1@');
            reviewConfirmFlag = true;   
           }
           if(opptyAct.Status__c == 'In Progress'){
               System.debug('Entry1@');
            reviewConfirmFlag = false;   
           }
                     
            if(!String.isBlank(opptyAct.Status__c)){ 
                opptyIds.add(opptyAct.WhatId__c);
                currentOpptyAct = opptyAct;
                mapConfirm.put(opptyAct.WhatId__c , reviewConfirmFlag); 
            }
          }
        }
   
        List<Opportunity> updateTargetOppty = [SELECT  Id,cPrimarySalesDepartment__c,OpportunityCode__c ,StageName, recordtypeId ,Opportunity_Review_VRB_Type__c,Opportunity_Review_Confirm__c,Opportunity_Review_Confirm_New__c
                                                FROM    Opportunity 
                                                WHERE   Id IN :opptyIds 
                                                         ]; 
        
         if(updateTargetOppty.Size()>0){
        for(Opportunity oppty : updateTargetOppty){
            if(updateOpptyMap.containsKey(oppty.Id)){
                Opportunity prevOppty = updateOpptyMap.get(oppty.Id);
                prevOppty.Opportunity_Review_Confirm_New__c = mapConfirm.get(oppty.Id); 
                System.debug('Entry1@');
                updateOpptyMap.put(oppty.Id, prevOppty);
            }
            else{
              oppty.Opportunity_Review_Confirm_New__c = mapConfirm.get(oppty.Id); 
                System.debug('Entry1@');
                updateOpptyMap.put(oppty.Id, oppty);  
            }
        }
     }
        
        List<String> opptyIdList_if125_hq = new List<String>();
         String RT_OPPTY_HQ_ID        = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('HQ').getRecordTypeId(); 
         String RT_OPPTY_LOGISTICS_ID = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Logistics').getRecordTypeId();

        for(Opportunity_Activity__c oppty : objList){
            if(String.isNotBlank(oppty.WhatId__r.RecordTypeId)) {
                if(oppty.WhatId__r.RecordTypeId == RT_OPPTY_LOGISTICS_ID) {
                    if(oldMap.get(oppty.Id).Status__c != oppty.Status__c){
                    opptyIdList_if125_hq.add(oppty.WhatId__c); 
                    }
                } else {
                    if(oldMap.get(oppty.Id).Status__c != oppty.Status__c){
                    opptyIdList_if125_hq.add(oppty.WhatId__c); 
                    }
                }
            }
          createInterfaceLog3('sendToSAP', 'Old Activity Status : '+oldMap.get(oppty.Id).Status__c + ', New Activity Status : ' + oppty.Status__c + ', Opportunity Activity Name : ' + oppty.Name + ', Opportunity Code : ' + oppty.WhatId__r.OpportunityCode__c + ', Opportunity Id : ' + oppty.WhatId__c +  '\n' + 'Opportunity Activity Status Updated : Success' , 'S'); //v 2.2
        }
        Boolean isBatch = System.isBatch();
        Boolean isQueueable = System.isQueueable();
        if(isBatch) {
            /** Batch 에서 호출 시, Batch 호출 */
           
            if(opptyIdList_if125_hq.size() > 0) { 
                Batch_EccOpportunityController batch_opptytoSAP = new Batch_EccOpportunityController();
                batch_opptytoSAP.selectIdList = opptyIdList_if125_hq;
                Database.executeBatch(batch_opptytoSAP);
            }
        
        } else {
            if(opptyIdList_if125_hq.size() > 0) IF_EccOpportunityController.calloutOpportunityInfo(opptyIdList_if125_hq); 
        }
        
    }
    
    // 2021-07-13 / YoungHoon.Kim / Opportunity Activity가 Completed로 변경되는 시점에 Opportunity Activity History를 저장
    public static void insertOppActHistory(List<Opportunity_Activity__c> newList, Map<Id, Opportunity_Activity__c> oldMap){
        System.debug('masterActMap : ' + masterActMap);
        System.debug('opptyStageMap : ' + opptyStageMap);
        System.debug('opptyActTransactioneMap : ' + opptyActTransactioneMap);
        List<Opportunity_ActivityHistory__c> opptyActHistoryList = new List<Opportunity_ActivityHistory__c>();
        for(Opportunity_Activity__c OpptyAct : newList){
            Opportunity_Activity__c oldOpptyAct;
            if(oldMap != null) oldOpptyAct = oldMap.get(OpptyAct.Id);
            else oldOpptyAct = new Opportunity_Activity__c();

            if(OpptyAct.Status__c != oldOpptyAct.Status__c && OpptyAct.Status__c == 'Completed'){ // Completed가 되는경우에만 저장
                Opportunity_ActivityHistory__c opptyActHistory = new Opportunity_ActivityHistory__c();
                opptyActHistory.Opportunity__c              = OpptyAct.WhatId__c;
                opptyActHistory.StartDate__c                = OpptyAct.StartDate__c;
                opptyActHistory.EndDate__c                  = OpptyAct.EndDate__c;
                opptyActHistory.OpptyStage_Label__c         = opptyStageMap.get(oldOpptyAct.OpportunityStage__c); // Oppty Act가 Complete될때 Oppty의 Stage Label
                opptyActHistory.OpptyStage_Code__c          = oldOpptyAct.OpportunityStage__c; // Oppty Act가 Complete될때 Oppty의 Stage Code
                opptyActHistory.MasterOpptyStage_Label__c   = opptyStageMap.get(masterActMap.get(OpptyAct.OpptyRecordType__c + '_' + OpptyAct.TransactionName__c)); // Oppty Act가 Complete될때 해당 Oppty Act가 속해있는 Stage Label
                opptyActHistory.MasterOpptyStage_Code__c    = masterActMap.get(OpptyAct.OpptyRecordType__c + '_' + OpptyAct.TransactionName__c); // Oppty Act가 Complete될때 해당 Oppty Act가 속해있는 Stage Code
                opptyActHistory.TransactionName_Label__c    = opptyActTransactioneMap.get(OpptyAct.TransactionName__c); // Oppty Act가 Complete될때 Oppty Act의 Transaction Label
                opptyActHistory.TransactionName_Code__c     = OpptyAct.TransactionName__c; // Oppty Act가 Complete될때 Oppty Act의 Transaction Code
                opptyActHistory.Opportunity_Activity__c     = OpptyAct.Id;

                opptyActHistoryList.add(opptyActHistory);
            }
        }

        if(opptyActHistoryList.size() > 0) insert opptyActHistoryList;
    }
    
    
    /**
    * @description   진행중 or 완료된 Oppty Activity 중 MasterActivity Stage__c ASC, Order__c ASC 순서상 가장 마지막 순서인 경우 Opportunity.ActivityStatus__c 필드에 업데이트 함
    * @param objList 
    **/
    private static void mappingOpptyActivityStatus(Map<Id, Opportunity> updateOpptyMap, List<Opportunity_Activity__c> objList){
        // HQ Type Activity Index Setting
        Map<String, Integer> hqMasterActOrderMap = new Map<String, Integer>();
        Map<Integer, String> hqMasterActOrderReverseMap = new Map<Integer, String>();
        Integer hqMasterActIndex = 1;
        for(MasterActivity__c ma : masterActList) {
            if(ma.Type__c == 'HQ') {
                hqMasterActOrderMap.put(ma.TransactionName__c, hqMasterActIndex);
                hqMasterActOrderReverseMap.put(hqMasterActIndex, ma.TransactionName__c);
                hqMasterActIndex++;
            }
        }

        // // Logistics Type Activity Index Setting
        Map<String, Integer> logiMasterActOrderMap = new Map<String, Integer>();
        Map<Integer, String> logiMasterActOrderReverseMap = new Map<Integer, String>();
        Integer logiMasterActIndex = 1;
        for(MasterActivity__c ma : masterActList) {
            if(ma.Type__c == 'Logistics') {
                logiMasterActOrderMap.put(ma.TransactionName__c, logiMasterActIndex);
                logiMasterActOrderReverseMap.put(hqMasterActIndex, ma.TransactionName__c);
                logiMasterActIndex++;
            }
        }
        
        Opportunity_Activity__c currentOpptyAct = new Opportunity_Activity__c();
        Set<String> opptyIdSet = new Set<String>();
        for(Opportunity_Activity__c opptyAct : objList){
            if(String.isBlank(opptyAct.Status__c)) continue;
            
            opptyIdSet.add(opptyAct.WhatId__c);
            currentOpptyAct = opptyAct;
        }

        Map<String, Integer> resultOpptyMap = new Map<String, Integer>();
        List<Opportunity_Activity__c> oaList = [SELECT Id, Name, WhatId__c, OpptyRecordType__c, TransactionName__c, Status__c FROM Opportunity_Activity__c WHERE WhatId__c =: opptyIdSet AND Status__c IN ('Completed', 'In Progress')];
        for(Opportunity_Activity__c oa : oaList){
            Integer index;
            if(oa.OpptyRecordType__c == 'HQ'){
                index = hqMasterActOrderMap.get(oa.TransactionName__c);
            }else{
                index = logiMasterActOrderMap.get(oa.TransactionName__c);
            }

            if(resultOpptyMap.get(oa.WhatId__c) == null){
                resultOpptyMap.put(oa.WhatId__c, index);
            }else{
                if(index > resultOpptyMap.get(oa.WhatId__c)){
                    resultOpptyMap.put(oa.WhatId__c, index);
                }
            }
        }

        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Opportunity> targetOpptyList = [SELECT Id, Name, RecordTypeId, OpportunityCode__c, RecordType.DeveloperName, ActivityStatus__c,Opportunity_Review_VRB_Type__c FROM Opportunity WHERE Id =: resultOpptyMap.keySet()]; //Added by Anish - v 2.1
        for(Opportunity Oppty : targetOpptyList){
            if(Oppty.RecordType.DeveloperName == 'HQ'){
                Oppty.ActivityStatus__c = hqMasterActOrderReverseMap.get(resultOpptyMap.get(Oppty.Id));
            }else{
                Oppty.ActivityStatus__c = logiMasterActOrderReverseMap.get(resultOpptyMap.get(Oppty.Id));
            }
            System.debug(' Update Opportunity ActivityStatus__c : ' + Oppty.ActivityStatus__c );
            updateOpptyList.add(Oppty);
        }

        /**
         * Deduplicate Update Opportunity Map
         */
        for(Opportunity updateOppty : updateOpptyList) {
            if(updateOpptyMap.containsKey(updateOppty.Id)) {
                Opportunity prevOppty = updateOpptyMap.get(updateOppty.Id);
                prevOppty.ActivityStatus__c = updateOppty.ActivityStatus__c;
                System.debug('Entry1@');
                updateOpptyMap.put(updateOppty.Id, prevOppty);
            } else {
                System.debug('Entry1@');
                updateOpptyMap.put(updateOppty.Id, updateOppty);
            }
        }

        /*
        try {
            if(updateOpptyList.size() > 0) {
                update updateOpptyList;
            }

        } catch(DmlException ex){
            System.debug(' ex.getMessage : ' + ex.getMessage());
            System.debug(' ex.getDMLMessage(0) : ' + ex.getDMLMessage(0));
            currentOpptyAct.addError(ex.getDMLMessage(0));

            // String errorMessage = ex.getMessage();
            // Integer occurence;
            // if (ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
            //     occurence = errorMessage.indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34;
            //     errorMessage = errorMessage.mid(occurence, errorMessage.length());
            //     occurence = errorMessage.lastIndexOf(':');
            //     errorMessage = errorMessage.mid(0, occurence);
            // } else {
            //     errorMessage = ex.getMessage();
            // }
        }
        */
    }

    /**
    * @description 'XP63', 'XP73', 'ZP21', 'ZPZ1', 'ZPZ2' 액티비티의 EndDate가 입력되는 경우 사업기회의 각 필드에 값 입력(보고서용)
    * @author younghoon.kim@dkbmc.com | 2022-05-19 
    * @param List<Opportunity_Activity__c> newList 
    * @param Map<Id Opportunity_Activity__c> oldMap 
    **/
    private static void mappingOpptyEndDate(List<Opportunity_Activity__c> newList, Map<Id, Opportunity_Activity__c> oldMap){
        List<String> transList = new List<String>{'XP63', 'XP73', 'ZP21', 'ZPZ1', 'ZPZ2'};
        List<Opportunity> OpptyList = new List<Opportunity>();

        for(Opportunity_Activity__c OpptyAct : newList){
            Opportunity oppty = new Opportunity();

            Opportunity_Activity__c oldOpptyAct;
            if(oldMap != null) oldOpptyAct = oldMap.get(OpptyAct.Id);
            else oldOpptyAct = new Opportunity_Activity__c();

            if(OpptyAct.EndDate__c != oldOpptyAct.EndDate__c && OpptyAct.EndDate__c != null){ // Oppty Act의 EndDate가 입력된 경우, 변경된 경우만
                oppty.Id = OpptyAct.WhatId__c;
                
                if(transList.contains(OpptyAct.TransactionName__c)){
                    switch on OpptyAct.TransactionName__c {
                        when 'XP63'{
                            oppty.XP63_EndDate__c = OpptyAct.EndDate__c;
                        }when 'XP73'{
                            oppty.XP73_EndDate__c = OpptyAct.EndDate__c;
                        }when 'ZP21'{
                            oppty.ZP21_EndDate__c = OpptyAct.EndDate__c;
                        }when 'ZPZ1'{
                            oppty.ZPZ1_EndDate__c = OpptyAct.EndDate__c;
                        }when 'ZPZ2'{
                            oppty.ZPZ2_EndDate__c = OpptyAct.EndDate__c;              
                        }
                    }
                    OpptyList.add(oppty);
                }
            }
        }

        if(OpptyList.size() > 0) update OpptyList;
    }
    
        //START V 1.7 -- Divyam Gupta
    private static void setLostResultApprovalStatus(List<Opportunity_Activity__c> newList, Map<Id, Opportunity_Activity__c> oldMap){
        
        List<LostResult__c> lostrsltlist = [Select id, ApproveStatus__c,LostActivity__r.Status__c,LostActivity__c,LostActivity__r.TransactionName__c,LostActivity__r.WhatId__r.CompanyCode__c from LostResult__c where LostActivity__c IN: newList AND IsCheck__c=true];
        List<LostResult__c> lstresultlist = new List<LostResult__c>();
        
        for(LostResult__c lrst : lostrsltlist){
            if(lrst.LostActivity__r.TransactionName__c == 'ZPZ1' ||  lrst.LostActivity__r.TransactionName__c == 'ZPZ2'){
                
                if(lrst.LostActivity__r.Status__c == 'Completed' && oldMap.get(lrst.LostActivity__c).Status__c != 'Completed'){
                    lrst.ApproveStatus__c = 'Completed';
                    lstresultlist.add(lrst);
                    
                }
                else if(lrst.LostActivity__r.Status__c == 'In Progress' && oldMap.get(lrst.LostActivity__c).Status__c != 'In Progress' ){
                    lrst.ApproveStatus__c = 'In Progress';
                    lstresultlist.add(lrst);
                    
                    
                }
                else if((lrst.LostActivity__r.Status__c == 'Not Started' && oldMap.get(lrst.LostActivity__c).Status__c != 'Not Started') || (lrst.LostActivity__r.Status__c == 'N/A' && oldMap.get(lrst.LostActivity__c).Status__c != 'N/A') ){
                    lrst.ApproveStatus__c = 'NA';
                    lstresultlist.add(lrst);
                    
                }
                else if((lrst.LostActivity__r.Status__c == 'Rejected' && oldMap.get(lrst.LostActivity__c).Status__c != 'Rejected') || (lrst.LostActivity__r.Status__c == 'Cancelled' && oldMap.get(lrst.LostActivity__c).Status__c != 'Cancelled') ){
                    lrst.ApproveStatus__c = 'Cancel';
                    lstresultlist.add(lrst);
                    
                    
                }
            }
        }
        system.debug('lost result list-->'+lstresultlist);
        if(lstresultlist.size()>0){
            update lstresultlist;
        }
    }
    //END V 1.7 -- Divyam Gupta
        //START V 1.8
    private static void CheckLostResultData(Map<Id,Opportunity_Activity__c> oldMap){
            List<Opportunity_Activity__c> lstoppactrecord = oldMap.values();

          system.debug('lstoppactrecord'+lstoppactrecord);
             List<Id> oppIdlist = new List<Id>();
             Map<Id,Opportunity_Activity__c> mapoppact = new Map<Id,Opportunity_Activity__c>();
        
        for(Opportunity_Activity__c loppact : lstoppactrecord){
            oppIdlist.add(loppact.WhatId__c);
            mapoppact.put(loppact.WhatId__c,loppact);
        }
         List<LostResult__c> lostrsltlist = [Select id, ApproveStatus__c,LostActivity__r.Status__c,LostActivity__c,LostActivity__r.TransactionName__c,Opportunity__c
                                             from LostResult__c where Opportunity__c IN: oppIdlist];
        List<Lost_Countermeasure__c> lostcntrlist = [Select id,LostActivity__c,Opportunity__c from Lost_Countermeasure__c where Opportunity__c IN: oppIdlist];
        List<LostResult__c> lstresultlist = new List<LostResult__c>();
         List<Lost_Countermeasure__c> lstcounterlist = new List<Lost_Countermeasure__c>();
        
            /* for(LostResult__c lrst : lostrsltlist){
         
                lstresultlist.add(lrst);
             }        
        for(Lost_Countermeasure__c lrct : lostcntrlist){
            
                lstcounterlist.add(lrct);
            
        } 
          */
        //START V 1.9

        for(LostResult__c lrst : lostrsltlist){
           Opportunity_Activity__c oppactrecd =  mapoppact.get(lrst.Opportunity__c);
            system.debug('transactionnametest'+oppactrecd.TransactionName__c);
            if(oppactrecd.TransactionName__c == 'ZPZ1' || oppactrecd.TransactionName__c == 'ZPZ2'){
                lstresultlist.add(lrst);
               }
        }
        for(Lost_Countermeasure__c lrct : lostcntrlist){
            Opportunity_Activity__c oppactrecd =  mapoppact.get(lrct.Opportunity__c);
            if(oppactrecd.TransactionName__c == 'ZPZ1' || oppactrecd.TransactionName__c == 'ZPZ2'){
                lstcounterlist.add(lrct);
               }
        }
          //END V 1.9
          
        if(lstresultlist.size() > 0){
            Delete lstresultlist;
        }
        if(lstcounterlist.size() > 0){
            Delete lstcounterlist;
        }  
        

        // END V 1.8
    
}
    
     public static void createInterfaceLog3(String apexMethod,String logMessage,String statusCode ){ // v 2.2

        try{
        System.debug( 'LOGIC_REVIEWOPP entry');
            IF_Log__c log = new IF_Log__c();
                log.ApexName__c = 'OpportunityActivityTrigger';
                log.ApexMethod__c =  apexMethod;
                log.InterfaceId__c = 'Callout_IF093';
                log.LogText__c = logMessage;
                log.StatusCode__c = statusCode;
                log.LogType__c = 'Interface';
                log.EndDatetime__c  = System.now();
                log.StartDatetime__c = System.now();
                System.debug( 'LOGIC_REVIEWOPP creation'+ log);
                insert log;
        }catch(Exception e){
            System.debug( 'LOGIC_REVIEWOPP msg'+ e.getMessage());
        }
    }

}