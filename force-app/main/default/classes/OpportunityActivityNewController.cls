/**
 * @description       : Opportunity Activity 생성/수정 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-02-05
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-11-25   hj.lee@dkbmc.com   Initial Version
 * 1.1   2021-03-22   hj.lee@dkbmc.com   checkStatusActivity (Opportunity Stage "Closed Won" : 중도종결/실주 Activity 수행 불가)
 * 1.2   2021-03-22   hj.lee@dkbmc.com   initComponent (본사 협업 Oppty : "최초" 수주 품의 Activity 진행 불가 - [협업 BO 최초 수주품의 Activity 제어]) 
 * 1.3	 2022-05-03   hyunhak.roh@dkbmc.com			setIF155CallByOpptyActId, Drop/Lost 완결된 이후(=현재 완결 상태) Drop/Lost Activity에서 값 
 * 													변경 후 '저장(Save)' 버튼 실행 시 전송
 * 1.4   2022-05-24   akash.g@samsung.com  Add User Manual Button functionality in Service/Solution tab     
 * 1.5   2022-05-27   hyunhak.roh@dkbmc.com			BO Lock 상태에서 Drop/Lost Activity 필드 처리
 * 1.6   2022-06-14   akash.g@samsung.com           Add simulation button functionality 
 * 1.7   2022-09-29   hyunhak.roh@dkbmc.com	   		물류 - Auto Stage Update 관련 로직 추가 변경건
 * 1.8   2022-10-29   Kajal.c@samsung.com      Added logic error message logic for Bidding and Final LBS.
 * 1.9   2023-02-07   akash.g@samsung.com           Add 'T100' company code condition in case of 'SCP Price Simulation'(MySales- 112)
 * 2.0   2023-03-20   Kajal.c@samsung.com      Added condition for error message in case of credit assessment activity is disabled(Mysals-128)
 * 2.1   2023-03-31   Kajal.c@samsung.com      Added condition To remove error in some cases related to Mysales-156
 * 2.2   2023-05-12   divyam.gupta@samsung.com Added logic for tab Analysis of reason for Drop/Lost and Post Mortem Result...
 * 2.4   2023-06-23   chae_ho.yang@samsung.com   SCP Price Simulation Tab logic modification 
 * 2.5   2023-07-10   anish.jain@partner.samsung.com  mySales review opportunity tab block logic deletion for System Adminstrator
 * 2.6   2023-10-04   anish.jain@partner.samsung.com   Added changes related to Mysales-309
 * 2.7   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 2.8   2024-02-05	  sarthak.j1@samsung.com		   MYSALES-415 point 2. 
**/
public without sharing class OpportunityActivityNewController {
    public static final String OPPTYACT_STATUS_COMPLETED = 'Completed';
    
    // v2.4 added
    @AuraEnabled
    public static Boolean isSandbox() {
        return [SELECT Id, IsSandbox, Name FROM Organization LIMIT 1].IsSandBox;
    }

    @AuraEnabled
    public static String initComponent(String opptyId, String transactionName) {
        System.debug('### OpportunityActivityNewController :: initComponent :: opptyId = ' + opptyId + ', transactionName = ' + transactionName);
        
        String opptyActId = '';
        Boolean isPendingKnoxApproval = false;
        String knoxApprovalBoReviewStatus = ''; // Added by Anish -  2.7
        //Added by Anish- v 2.7
         Boolean oppApproved = false;
        //START V 2.2
        String OpptyActstatusval = '';
        //END V 2.2
        //2022-05-27, hyunhak.roh@dkbmc.com, BO Lock 상태에서 Drop/Lost Activity 필드 처리
        Boolean isDropLostLock = false;
        
        Boolean hasEditAccess = [SELECT   RecordId, HasEditAccess  
                                FROM     UserRecordAccess 
                                WHERE    UserId = :UserInfo.getUserId() 
                                    AND RecordId = :opptyId].HasEditAccess;
        //신규추가시작                                    
        Boolean isSubsidiary = false;    
        Boolean isNotHQ = false; //Anish- v 2.7
        String opptyStatus = ''; //Anish- v 2.7
        //신규추가종료
        Opportunity oppty = new Opportunity();
        User BOOwner = new User(); // APS 버튼 처리를 위한 Owner 정보
        List<Project__c> projectList;
        
        Map<String, String> opptyActFieldLabel = Utils.getFieldLabel('Opportunity_Activity__c');
        Boolean cannotProceedZP32 = false;
        Boolean cannotProceedZP32Null = false;
        Boolean cannotProceedZP82 = false;
        Boolean cannotProceedZP82Null = false;
		Boolean cannotProceedParticipation = false;
        Boolean cannotProceedDecision = false;
        Boolean creditAssessmentText = false;

        Map<String, Object> resultMap = new Map<String, Object>{
            'opportunityActivityId' => opptyActId,
            'opprtunityactstatus' => OpptyActstatusval,
            'isPendingKnoxApproval' => isPendingKnoxApproval,
            'hasEditAccess'         => hasEditAccess,
            'opportunity'           => oppty,
            'owner'           		=> BOOwner,
            'projectList'           => projectList,
            'fieldLabel'            => opptyActFieldLabel,
            //신규추가시작
            'isSubsidiary'          => isSubsidiary,
            'cannotProceedZP32'     => cannotProceedZP32,
            'cannotProceedZP32Null' => cannotProceedZP32Null,
            'cannotProceedZP82'     => cannotProceedZP82,
            'cannotProceedZP82Null' => cannotProceedZP82Null,
            'cannotProceedParticipation' => cannotProceedParticipation,
            'cannotProceedDecision'      => cannotProceedDecision,
            //신규추가종료			
            'isDropLostLock'		=> isDropLostLock,
                'knoxApprovalActivityForBOReview'  => knoxApprovalBoReviewStatus, //Anish- v 2.7
                'oppApproved' => oppApproved, //Anish- v 2.7
                'isNotHQ' => isNotHQ, //Anish- v 2.7
                'opptyAct' => opptyStatus //Anish- v 2.7
        };
        try {
             /**
             * Oppty 정보, 프로젝트 정보 반환
             */
            String opptySOQL = Utils.getQueryAddSelect('Opportunity', 'Account.AccountNumber, RecordType.DeveloperName, toLabel(XP63_VRB_APPROVAL_TYPE__c) xp63_VRB, toLabel(XP73_VRB_APPROVAL_TYPE__c) xp73_VRB', ' WHERE  Id = \'' + opptyId + '\'', false);
            oppty = (Opportunity)System.Database.query(opptySOQL)[0];
            projectList = [ SELECT  Id, ProjectCode__c 
                            FROM    Project__c 
                            WHERE   Opportunity__c = :opptyId
                                    AND ProjectCode__c != ''];

            BOOwner = [SELECT Id, Name, EPCompanyName__c FROM User WHERE Id =: oppty.OwnerId LIMIT 1];

            // Opportunity Activity 생성 후 반환
            // [2021-03-05 수정] Opportunity Id, Master Transaction Name 기준으로 실시간 데이터를 찾아옴
            /*
            Opportunity_Activity__c opptyAct = (Opportunity_Activity__c)JSON.deserialize(jsonData, Opportunity_Activity__c.class);
            List<Opportunity_Activity__c> checkOpptyAct = [
                SELECT Id 
                FROM   Opportunity_Activity__c 
                WHERE  Id = :opptyAct.Id
            ];
            */
            List<Opportunity_Activity__c> checkOpptyAct = [
                SELECT  Id,Status__c FROM    Opportunity_Activity__c 
                WHERE   WhatId__c = :opptyId
                        AND TransactionName__c = :transactionName
            ]; //Added by Anish - v 2.7

            // 통합 Code 인 MasterActivity Transaction Name 'Drop/Lost' 에 대한 예외 Oppty Act 찾기
            if(transactionName == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY){ 
                checkOpptyAct = [
                    SELECT  Id,Status__c FROM    Opportunity_Activity__c 
                    WHERE   WhatId__c = :opptyId
                            AND (TransactionName__c = :OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY 
                                 OR TransactionName__c = :OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY)
                ];
            }
            
            if(checkOpptyAct.size() == 0) {
                Opportunity_Activity__c opptyAct = new Opportunity_Activity__c(
                    WhatId__c = opptyId,
                    TransactionName__c = transactionName
                );
                if(hasEditAccess) opptyActId = createOpportunityActivity(opptyAct);
            } else {
                opptyActId = checkOpptyAct[0].Id;
                opptyStatus = checkOpptyAct[0].Status__c; //Added by Anish - v 2.7
            }
            //START V 2.2
            Opportunity_Activity__c OpptyActstatus = [
                SELECT  Status__c FROM    Opportunity_Activity__c 
                WHERE Id = :opptyActId];
            OpptyActstatusval = OpptyActstatus.Status__c;
            //END V 2.2

            /**
             * Activity에 진행중인 Knox Approval가 있는지 확인
             */
            //String knoxPendingStatus = '1';
            List<KnoxApproval__c> pendingApprovalList = [
                SELECT  Id, Status__c
                FROM    KnoxApproval__c
                WHERE   OpportunityActivity__c = :opptyActId
                        //AND Status__c = :knoxPendingStatus
                        AND Status__c IN (:KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS, :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED)
            ];
            
            
            
            if(pendingApprovalList.size() > 0){
                //
                String chkStatus = (String) pendingApprovalList[0].get('Status__c');	//KnoxApproval__c, 기준 OpportunityActivity__c 값은 1 row 인가??
                
                if(chkStatus == KnoxApprovalHelper.KNOX_APPROVAL_STATUS_IN_PROGRESS) {
                    isPendingKnoxApproval = true;
                }
                //2022-05-27, hyunhak.roh@dkbmc.com, BO Lock 상태에서 Drop/Lost Activity 필드 처리
                // 통합 Code 인 MasterActivity Transaction Name 'Drop/Lost' 에 대한 예외 Oppty Act 찾기
                if(transactionName == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY){ 
                	isDropLostLock = true;
                }
            }

            // 본사 협업 Oppty : "최초" 수주 품의 Activity 진행 불가 - [협업 BO 최초 수주품의 Activity 제어]
            String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
            // Boolean isHqCollaboOppty = oppty.Collaboration__c && oppty.CollaborationInOut__c == 'IN';
            Boolean isHqCollaboOppty = oppty.Collaboration__c && oppty.CompanyCode__c == 'T100'; // MIG DATA의 경우 CollaborationInOut__c 빈 데이터로 Company Code로 본사 협업 oppty 판단

            if(isHqCollaboOppty && (transactionName == ACT_CODE_CONTRACT_APPROVAL) ) {
                Id opptyOutId = oppty.CollaborationBOId__c; // 법인 협업 Oppty
                
                // 법인 협업 oppty의 최초 수주품의 완결 여부 확인
                List<KnoxApproval__c> opptyOutKnoxApprovalList = [
                    SELECT  Id
                    FROM    KnoxApproval__c
                    WHERE   Opportunity__c = :opptyOutId
                        AND OpportunityActivity__r.TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
                        AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                            OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                            OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                            )
                ];

                // 최초 품의가 완료 되지 않으면 본사 협업 Oppty는 수주 품의 Activity 불가능
                if(opptyOutKnoxApprovalList.size() == 0){
                    isPendingKnoxApproval = true;                    
                }
            }
            
            //Start-Added by Anish- v 2.7
            //Boolean oppApproved = false;
            if( (transactionName == OpportunityActivityHelper.ACT_CODE_REVIEW_BO) ){
                System.debug('oppty.OpportunityCode__c-----> '+ oppty.OpportunityCode__c);
                List<KnoxApproval__c> knoxRBOApprovalList = [
                        SELECT  Id,Status__c
                        FROM    KnoxApproval__c
                        WHERE   Opportunity__r.OpportunityCode__c = :oppty.OpportunityCode__c
                            AND OpportunityActivity__r.TransactionName__c = :transactionName AND Opportunity__c = : opptyId order by CreatedDate Desc
                            ];
                
                If(knoxRBOApprovalList.Size()>0){
                knoxApprovalBoReviewStatus = knoxRBOApprovalList[0].Status__c ;
                }
                
             List<Opportunity_Activity__c> oppAct = [Select Id,Status__c from Opportunity_Activity__c where WhatId__c =: opptyId and TransactionName__c = 'XP63' and Status__c ='Completed' LIMIT 1];
          
            if(oppAct.Size()>0){
               System.debug('AJ Entry');
               oppApproved = true;
            }
                
                if(oppty.CompanyCode__c != 'T100' && oppty.Collaboration__c == true){
                    isNotHQ = true;
                }
            }
            //Start-Added by Anish- v 2.7
            //신규추가시작
            //1. 수주품의단계 - 사업심의유형이 BO점검회의가 아닐경우
            //2. 사업유형1이 판매형/서비스형이 아닌경우
            //3. 기존 수주품의 이력이 있을경우 Pass(협업일 경우도 포함)
            //4-1. 법인 협업 BO : 법인의 BO점검결과가 없는경우 or '본사'의 입찰결정 품의결과 참여가 아닌경우
            //4-2. 자회사 아닌 BO: BO점검결과가 없는경우 or 입찰결정 품의결과가 참여가 아닌경우
             isSubsidiary = Utils.isSubsidiary(oppty.CompanyCode__c);
            if(transactionName == ACT_CODE_CONTRACT_APPROVAL && !'30'.equals(oppty.Opportunity_Review_VRB_Type_Confirm__c)){
                List<Opportunity> optyList = [SELECT Id, BusinessType__c FROM Opportunity WHERE OpportunityCode__c =:oppty.OpportunityCode__c];
                Boolean implementation =  false;
                for(Opportunity opty : optyList){
                    if('TI'==opty.BusinessType__c){
                        implementation = true;
                    }
                }
                if(implementation){
                    List<KnoxApproval__c> knoxApprovalList = [
                        SELECT  Id
                        FROM    KnoxApproval__c
                        WHERE   Opportunity__r.OpportunityCode__c = :oppty.OpportunityCode__c
                            AND OpportunityActivity__r.TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
                            AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                                OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                                )
                    ];
                    if(knoxApprovalList.isEmpty()){
                        if(oppty.Collaboration__c && !'T100'.equals(oppty.CompanyCode__c)){
                            Opportunity hqOppty = [ SELECT Id, XP73_VRB_APPROVAL_TYPE__c                                                     
                                                    FROM Opportunity
                                                    WHERE CompanyCode__c =: 'T100'
                                                    AND OpportunityCode__c = :oppty.OpportunityCode__c 
                                                    LIMIT 1];
                            
                            if(oppty.Opportunity_Review_VRB_Type_Confirm__c == null){
                                hasEditAccess = false;
                                cannotProceedZP82Null = true;  
                            } else if(!'10'.equals(hqOppty.XP73_VRB_APPROVAL_TYPE__c)){
                                hasEditAccess = false;
                                cannotProceedZP82 = true;  
                            }
                        } else if(!isSubsidiary){
                            if(oppty.Opportunity_Review_VRB_Type_Confirm__c==null){
                                hasEditAccess = false;
                                cannotProceedZP82Null = true;
                            } else if(!'10'.equals(oppty.XP73_VRB_APPROVAL_TYPE__c)){
                                hasEditAccess = false;
                                cannotProceedZP82 = true;                    
                            }
                        }
                    }
                }
            }
            
            //1. 자원요청단계- 사업심의유형이 BO점검회의가 아닐경우
            //2. 사업유형1이 판매형/서비스형이 아닌경우
            //2-1. 법인 협업 BO의 경우 법인의 BO점검결과가 없는경우
            //2-2. 법인 협업 BO의 경우 '본사'의 사업참여 or 임찰결정 품의결과 참여가 아닌경우
            //3-1. 자회사 아니면서 BO점검결과가 없는경우
            //3-2. 자회사 아니면서 사업참여 or 입찰결정 품의결과가 참여가 아닌경우
            if(transactionName == OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES && !'30'.equals(oppty.Opportunity_Review_VRB_Type_Confirm__c)){
                List<Opportunity> optyList = [SELECT Id, BusinessType__c FROM Opportunity WHERE OpportunityCode__c =:oppty.OpportunityCode__c];
                Boolean implementation =  false;
                for(Opportunity opty : optyList){
                    if('TI'==opty.BusinessType__c){
                        implementation = true;
                    }
                }
                if(implementation){
                    if(oppty.Collaboration__c && !'T100'.equals(oppty.CompanyCode__c)){
                        Opportunity hqOppty = [ SELECT Id, XP63_VRB_APPROVAL_TYPE__c, XP73_VRB_APPROVAL_TYPE__c, Opportunity_Review_VRB_Type_Confirm__c                                                     
                                                FROM Opportunity
                                                WHERE CompanyCode__c =: 'T100'
                                                AND OpportunityCode__c = :oppty.OpportunityCode__c 
                                                LIMIT 1];
                        if(oppty.Opportunity_Review_VRB_Type_Confirm__c == null){
                            hasEditAccess = false;
                            cannotProceedZP32Null = true;  
                        } else if(!'10'.equals(hqOppty.XP63_VRB_APPROVAL_TYPE__c) && !'10'.equals(hqOppty.XP73_VRB_APPROVAL_TYPE__c)){
                            hasEditAccess = false;
                            cannotProceedZP32 = true;  
                        }
                    } else if(!isSubsidiary){
                        if(oppty.Opportunity_Review_VRB_Type_Confirm__c==null){
                            hasEditAccess = false;
                            cannotProceedZP32Null = true;
                        } else if(!'10'.equals(oppty.XP63_VRB_APPROVAL_TYPE__c) && !'10'.equals(oppty.XP73_VRB_APPROVAL_TYPE__c)){
                            hasEditAccess = false;
                            cannotProceedZP32 = true;                    
                        }
                    }
                }
            }
            //수전위 Activity 선행 제어
            String ACT_CODE_REQUEST_STRATEGY_COMMITTEE_01 = OpportunityActivityHelper.ACT_CODE_REQUEST_STRATEGY_COMMITTEE_01;
            String ACT_CODE_COMMITTEE_COST_PLAN_01 = OpportunityActivityHelper.ACT_CODE_COMMITTEE_COST_PLAN_01;
            String ACT_CODE_REQUEST_COMMITTEE_APPROVAL_01 = OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL_01;
            String ACT_CODE_REQUEST_STRATEGY_COMMITTEE_02 = OpportunityActivityHelper.ACT_CODE_REQUEST_STRATEGY_COMMITTEE_02;
            String ACT_CODE_COMMITTEE_COST_PLAN_02 = OpportunityActivityHelper.ACT_CODE_COMMITTEE_COST_PLAN_02;
            String ACT_CODE_REQUEST_COMMITTEE_APPROVAL_02 = OpportunityActivityHelper.ACT_CODE_REQUEST_COMMITTEE_APPROVAL_02;

            //사업참여: 사업심의유형 없을경우 불가능
            if(transactionName == ACT_CODE_REQUEST_STRATEGY_COMMITTEE_01 || transactionName == ACT_CODE_COMMITTEE_COST_PLAN_01 || transactionName == ACT_CODE_REQUEST_COMMITTEE_APPROVAL_01){
                if(oppty.Opportunity_Review_VRB_Type_Confirm__c==null){
                    hasEditAccess = false;
                    cannotProceedParticipation = true;
                }
            }
            
            //입찰결정: 사업참여품의결과 "참여"가 아닌경우 불가능
            if(transactionName == ACT_CODE_REQUEST_STRATEGY_COMMITTEE_02 || transactionName == ACT_CODE_COMMITTEE_COST_PLAN_02 || transactionName == ACT_CODE_REQUEST_COMMITTEE_APPROVAL_02){
                if('10'!=oppty.XP63_VRB_APPROVAL_TYPE__c){
                    hasEditAccess = false;
                    cannotProceedDecision = true;
                }
            }
            resultMap = new Map<String, Object>{
                'opportunityActivityId' => opptyActId,
                'opprtunityactstatus' => OpptyActstatusval,
                'isPendingKnoxApproval' => isPendingKnoxApproval,
                'hasEditAccess'         => hasEditAccess,
                'opportunity'           => oppty,
                'owner'           		=> BOOwner,
                'projectList'           => projectList,
                'fieldLabel'            => opptyActFieldLabel,
                //신규추가시작
                'isSubsidiary'          => isSubsidiary,
                'cannotProceedZP82'         => cannotProceedZP82,
                'cannotProceedZP82Null' => cannotProceedZP82Null,
                'cannotProceedZP32'         => cannotProceedZP32,
                'cannotProceedZP32Null'   => cannotProceedZP32Null,
                'cannotProceedParticipation' => cannotProceedParticipation,
                'cannotProceedDecision'      => cannotProceedDecision,
                //신규추가종료
                'isDropLostLock'		=> isDropLostLock,
                'knoxApprovalActivityForBOReview'  => knoxApprovalBoReviewStatus,  //Anish- v 2.7
                    'oppApproved' => oppApproved, //Anish- v 2.7
                    'isNotHQ' => isNotHQ, //Anish- v 2.7
                    'opptyAct' => opptyStatus //Anish- v 2.7
            };

        } catch (Exception e) {
            system.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        
        System.debug('### OpportunityActivityNewController :: initComponent :: return = ' + JSON.serialize(resultMap));
        
        return JSON.serialize(resultMap);
    }

    @AuraEnabled
    public static String setIF155CallByOpptyActId(String opptyActId) {
        Map<String, Object> responseMap = new Map<String, Object>();
        String PARAM_opportunityActivity = 'opportunityActivity';
        
        System.debug('##### setIF155CallByOpptyActId, Start #####');
        
        /**
         * Oppty Act 정보 반환
         */
        try {
            Set<Id> setDropLostBoActId = new Set<Id>();
            
            List<Opportunity_Activity__c> returnOpptyActList = Utils.queryObjectWithoutRichText('Opportunity_Activity__c'
                                                                                                , 'WHERE  Id = \'' + opptyActId + '\'');
            if(returnOpptyActList.size() > 0) {
                
                for(Opportunity_Activity__c oppyActy : returnOpptyActList){
                    
                    //
                	if(oppyActy != null) {
                        
                        System.debug('### setIF155CallByOpptyActId :: oppyActy.EndDate__c = ' + oppyActy.EndDate__c);
                        
                        //
                        if(oppyActy.EndDate__c != null) {
                            
                            setDropLostBoActId.add(opptyActId);
                        
                            //System.debug('### setIF155CallByOpptyActId :: setOpptyActivityStatus :: opptyActUpdateList = ' + opptyActUpdateList);
                            System.debug('### setIF155CallByOpptyActId :: setDropLostBoActId = ' + setDropLostBoActId);
                            
                            //Database.executeBatch(new Batch_SendDropLostInfo(setDropLostBoActId), 50); // Commented out as part of v-2.8
                            System.debug('### [Drop / Lost] setIF155CallByOpptyActId, Happend~~!! ###');
                        }
                    }
                }
                responseMap.put('opportunityActivity', returnOpptyActList[0]);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        System.debug('##### setIF155CallByOpptyActId, End #####');
        return JSON.serialize(responseMap);
    }
    
    @AuraEnabled
    public static String getOpportunityActivity(String opptyActId) {
        
        System.debug('### OpportunityActivityNewController :: getOpportunityActivity :: opptyActId = ' + opptyActId);
        
        Map<String, Object> responseMap = new Map<String, Object>();
        String PARAM_opportunityActivity = 'opportunityActivity';
        /**
         * Oppty Act 정보 반환
         */
        try {
            List<Opportunity_Activity__c> returnOpptyActList = Utils.queryObjectWithoutRichText('Opportunity_Activity__c'
                                                                                                , 'WHERE  Id = \'' + opptyActId + '\'');
            if(returnOpptyActList.size() > 0) {
                responseMap.put('opportunityActivity', returnOpptyActList[0]);
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        
        System.debug('### OpportunityActivityNewController :: getOpportunityActivity :: return = ' + JSON.serialize(responseMap));
        
        return JSON.serialize(responseMap);
    }


    /**
     * Activity의 상태 확인
     */
    @AuraEnabled
    public static String checkStatusActivity(String jsonData) {
        
        System.debug('### OpportunityActivityNewController :: checkStatusActivity :: jsonData = ' + jsonData);
        
        OpportunityActivityPanelController.ActivityItem activityItem = (OpportunityActivityPanelController.ActivityItem)JSON.deserialize(jsonData, OpportunityActivityPanelController.ActivityItem.class);
        Boolean canNewActivity= false;
        
        String msg = '';
        List<String> msgList = new List<String>();
        Map<String, Object> responseMap = new Map<String, Object>{
            'canNewActivity' => canNewActivity,  // 생성 가능 여부
            'msg' => msg
        };
            
         User user = [SELECT Id, Name, ProfileId, Profile.Name, UserRoleId, UserRole.Name, LanguageLocaleKey, IsActive,Email FROM User WHERE Id =: Userinfo.getUserId()]; //Added by Anish- v 2.7
          
        //Start - Added by Anish - v 2.5   
        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name, UserLicenseId, UserLicense.Name, UserType, Description 
                                                                    FROM Profile 
                                                                    WHERE Id = :UserInfo.getProfileId()]);
        String userProfileName = profileMap.get(UserInfo.getProfileId()).Name;
        Boolean userProf = false;
        if(userProfileName == 'System Administrator' || userProfileName == 'Service Desk Agency' || userProfileName == '시스템 관리자'){
            userProf = true;
        }
        //End - Added by Anish - v 2.5   
        
        try {
            /**
             * Activity 생성이 가능한지 확인
             * [PRAM_CAN_NEW_ACT] 'canNewActivity'
             * 1. (가능) Activity 생성 가능
             * 2. (불가) Stage Not Closed 이고 Closed Date < Today 인경우 Activity 진행 불가능
             * 3. (불가) 선행 Activity 미완료 시
             * 4. (불가) 협업 Opportunity 인 경우, 협업을 요청한 법인 Oppty에서 사전기회검토 Activity 미완료 시
             * 5. (불가) 사업 기회 레코드 타입,사업기회 단계, 필드에 따른 Activity 접근 여부 확인
             * 6. (불가) 수주품의 Activity 완료: 중도종결/실주 Activity 수행 불가
             * 7. (불가) Opportunity Stage "Closed Won" : 중도종결/실주 Activity 수행 불가
             * 8. (불가) 신용평가 전에 Stage가 Qualified, Solutioned, Closed에 있는 모든 Activity를 수행하려고 할 경우 Alert 발생
             **/
            String PRAM_CAN_NEW_ACT = 'canNewActivity';

            Opportunity oppty = (Opportunity)Utils.queryObjectWithoutRichText('Opportunity'
                                , 'WHERE Id = ' + '\'' + activityItem.opptyId + '\'' 
                                + ' LIMIT 1')[0];
            Boolean isLogisticsRecordType = oppty.RecordTypeId == OpportunityActivityHelper.RT_OPPTY_LOGISTICS.Id;
            Boolean isHQRecordType        = oppty.RecordTypeId == OpportunityActivityHelper.RT_OPPTY_HQ.Id;
            
            MasterActivity__c masterAct = activityItem.MasterAct;
            String masterReqTransactionValue = masterAct.RequiredTransaction__c;

             // Opportunity Activity Transation Picklist Label Map
             List<Map<String, String>> opptyActNameLabelList = Utils.getPicklistOptionType('Opportunity_Activity__c','TransactionName__c');
             Map<String, String> opptActNameLabelMap = new Map<String, String>(); // <key : Api Name,  value : label>
             for(Integer i=0; i< opptyActNameLabelList.size(); i++){
                 opptActNameLabelMap.put(opptyActNameLabelList[i].get('value'), opptyActNameLabelList[i].get('label'));
             }

            // [2021-03-05] 실시간으로 체크하기 위해서 Query 결과 BoAct를 삽입
            //Opportunity_Activity__c opptyAct = activityItem.BoAct;
            List<Opportunity_Activity__c> opptyActList = (List<Opportunity_Activity__c>)Utils.queryObjectWithoutRichText('Opportunity_Activity__c'
                                    , 'WHERE WhatId__c = ' + '\'' + activityItem.opptyId + '\'' 
                                    + ' AND TransactionName__c = ' + ' \'' + activityItem.MasterAct.TransactionName__c + ' \''
                                    + ' LIMIT 1');

            // 통합 Code 인 MasterActivity Transaction Name 'Drop/Lost' 에 대한 예외 Oppty Act 찾기
            if(activityItem.MasterAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY) {
                opptyActList = (List<Opportunity_Activity__c>)Utils.queryObjectWithoutRichText('Opportunity_Activity__c'
                                    , 'WHERE WhatId__c = ' + '\'' + activityItem.opptyId + '\'' 
                                    + ' AND (TransactionName__c = ' + ' \'' + OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY + ' \'' 
                                    + '       OR TransactionName__c = ' + ' \'' + OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY + ' \')'
                                    + ' LIMIT 1');
            }
            if(opptyActList.size() > 0) {
                activityItem.BoAct = opptyActList[0];
                
            } else {
                activityItem.BoAct = null;
            }

            // 1. (가능) Activity 생성 가능  (변수 초기화)
            canNewActivity = true;
   
            // 2. (불가) Stage Not Closed 이고 Closed Date < Today 인경우 Activity 진행 불가능
            if(!opportunityActivityHelper.OPP_STAGE_CLOSED_SET.contains(oppty.StageName) && oppty.CloseDate < Date.Today() && !(activityItem.MasterAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY || activityItem.MasterAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY )) { //Added by Anish -2.6 
                // Close Date가 경과되어 Activity를 진행할 수 없습니다.
                if(userProf != true){                          //Added by Anish - v 2.5
                    system.debug('AkashanishTest2');
                msgList.add(System.Label.OPPTYACT_MSG_009); 
                canNewActivity = false;
                }
            }
            
            //2022-09-29, hyunhak.roh@dkbmc.com, BO 에 대한 모든 Activity 가져오기.	
            List<Opportunity_Activity__c> allOpptyActList = [	
                SELECT  Id, Status__c, TransactionName__c	
                FROM    Opportunity_Activity__c	
                WHERE   WhatId__c = :activityItem.opptyId	
          	];
            
            
            String chkType = '';
            if(isHQRecordType) {chkType = 'HQ';} else {chkType = 'Logistics';}
            List<MasterActivity__c> chkMasterActList = Utils.queryObjectWithoutRichText('MasterActivity__c'
                                     				, 'WHERE ObjectApiName__c	 = \'Opportunity\' AND IsActive__c = true AND Type__c = \'' + chkType + '\''
                                                    + ' ORDER BY Stage__c , Order__c'
                                                    );
            
            // 3. (불가) 선행 Activity 미완료
            // Label에 등록된 Test Date 일자이후 해당 Validation 이 적용되도록 함
            Date today = Date.today(); 
            Boolean CAFlag = false; //Added by Anish- v 2.7
            Date testDate = Util_String.convertStringHyphenFormatToDate(System.Label.COMM_VAL_PREACTVALID_AFTER_DATE);
            if(testDate < today) {
                if(String.isNotBlank(masterReqTransactionValue)) {
                    /*List<Opportunity_Activity__c> reqOpptyActList = [
                        SELECT  Id, Status__c 
                        FROM    Opportunity_Activity__c
                        WHERE   WhatId__c = :activityItem.opptyId
                                AND TransactionName__c = :masterReqTransactionValue 
                                AND Status__c = 'Completed'
                    ];*/
                    boolean isReqOpptyActList = false;
                    for(Opportunity_Activity__c reqOpptyAct : allOpptyActList){
                        if(		reqOpptyAct.TransactionName__c == masterReqTransactionValue
                        	&& 	reqOpptyAct.Status__c == 'Completed'  ){
							isReqOpptyActList = true;
                    	}
                    }

                    // (2021-03-23 수정) 선행 Activity 적용대상 Company Code 조건 추가
                    // 선행 Activity 적용 대상 Company Code 이 지정된 경우  Oppty Company Code가 포함된 경우 적용
                    String masterReqTransactionCompanyCode = Util_String.nvlStr(masterAct.RequiredTransactionCompanyCode__c);
                    String opptyCompanyCode = Util_String.nvlStr(oppty.CompanyCode__c);
                    System.debug(' # masterReqTransactionCompanyCode  ' + masterReqTransactionCompanyCode);
                    System.debug(' # opptyCompanyCode' + opptyCompanyCode);
                    

                    if(String.isNotBlank(masterReqTransactionCompanyCode)) {
                        if(String.isNotBlank(opptyCompanyCode) && masterReqTransactionCompanyCode.containsIgnoreCase(opptyCompanyCode)) {
                            //if(reqOpptyActList.size() == 0) {
                            if(!isReqOpptyActList) {
                                // 선행 Activity "{선행 Activity Label}"가 완료되지 않았습니다.
                                msgList.add(String.format(System.Label.OPPTYACT_MSG_003, new String[]{opptActNameLabelMap.get(masterReqTransactionValue)}));
                                canNewActivity = false;
                                CAFlag = true;  //Added by Anish- v 2.7
                            }

                        }
                    } else { // 선행 Activity 적용 대상 Company Code 없는 경우 모두 적용
                        //if(reqOpptyActList.size() == 0) {
                        if(!isReqOpptyActList) {
                            System.debug(' # masterReqTransactionCompanyCode Ani  ' + masterReqTransactionCompanyCode);
                            System.debug(' # opptyCompanyCode Ani' + opptyCompanyCode);
                            // 선행 Activity "{선행 Activity Label}"가 완료되지 않았습니다.
                            msgList.add(String.format(System.Label.OPPTYACT_MSG_003, new String[]{opptActNameLabelMap.get(masterReqTransactionValue)}));
                            canNewActivity = false;
                        }
                    }
                }                
            }
            
            //Start-Added by Anish- v 2.7 11.14 chae_ho.yang remark
             if(activityItem.MasterAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL ){
                 System.debug('Entry Validation Ani');
             List<Opportunity_Activity__c> opptyOutActivityCompleteList = [
                    SELECT  Status__c
                     FROM    Opportunity_Activity__c
                     WHERE   TransactionName__c = :OpportunityActivityHelper.ACT_CODE_REVIEW_BO
                         AND Status__c != 'Completed'
                         AND WhatId__c = :oppty.Id
                 ];
             if(opptyOutActivityCompleteList.Size()>0  && !CAFlag){
                 if(user.LanguageLocaleKey == 'ko'){
                 msgList.add(String.format(System.Label.OPPTYACT_MSG_003, new String[]{'사업기회 검토'})); 
                 }
                 else{
                 msgList.add(String.format(System.Label.OPPTYACT_MSG_003, new String[]{'Review Opportunity'}));    
                 }
                 canNewActivity = false;
             }
                 System.debug('Entry Validation Anis' + msgList);
             }
            //End-Added by Anish- v 2.7
            

            // 4. (불가) 본사 협업 Oppty (Collaboration In)인 경우,
            //        협업을 요청한 법인 Oppty (Collaboration Out)에서 사전기회검토 Activity 미완료 시 진행 불가능
            Boolean isHqCollaboOppty = oppty.Collaboration__c && oppty.CompanyCode__c == 'T100';    // MIG DATA의 경우 CollaborationInOut__c 빈 데이터로 Company Code로 본사 협업 oppty 판단
            if(isHqCollaboOppty){
                Id opptyOutId = oppty.CollaborationBOId__c; // 법인 협업 Oppty
                List<Opportunity_Activity__c> opptyOutActivityList = [
                    SELECT  Status__c
                    FROM    Opportunity_Activity__c
                    WHERE   TransactionName__c = :OpportunityActivityHelper.ACT_CODE_REVIEW_BO
                        AND Status__c = 'Completed'
                        AND WhatId__c = :opptyOutId
                ];
                
                // 협업BO, 본사에서 Drop/Lost 처리시에는 체크하지 않음.
                if(masterAct.TransactionName__c != OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY &&
                   masterAct.TransactionName__c != OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY){
                       if(opptyOutActivityList.size() == 0) {
                           // 협업 Opportunity의 사업기회 검토가 완료되지 않아 진행이 불가능합니다.
                           if(userProf != true){                       //Added by Anish - v 2.5  
                           msgList.add(System.Label.OPPTYACT_MSG_004); 
                           canNewActivity = false;
                           }
                       }                       
                   }
                
            }

            // 5. (불가) 사업 기회 레코드 타입,사업기회 단계, 필드에 따른 Activity 접근 여부 확인
            // [HQ 레코드 타입]
            if(isHQRecordType) {
                system.debug('');
                Boolean isAccessible = OpportunityActivityHelper.checkAccessHQActivity(oppty, activityItem);
                if(!isAccessible) { 
                    // 해당 Activity를 수행할 수 없습니다.
                    msgList.add(System.Label.OPPTYACT_MSG_014); 
                    canNewActivity = false;
                }
            }
            // [물류 레코드 타입]
            if(isLogisticsRecordType) {
                //Boolean isAccessible = OpportunityActivityHelper.checkAccessLogisticsActivity(oppty, activityItem);
               
               Boolean isAccessible = OpportunityActivityHelper.checkAccessLogisticsActivityV2(oppty, activityItem);
 
                if(!isAccessible) { 
                    // 현재 기회 단계에서 해당 Activity에 접근할 수 없습니다.
                    msgList.add(System.Label.OPPTYACT_MSG_005); 
                    canNewActivity = false;
                }
               
                 //KAJAL START V1.8
                if(activityItem.MasterAct.TransactionName__c == '2.4.5.'){
                    /** V2.1 Added by Kajal **/
                    if(oppty.LogisticsCustomerType__c == 'EXTAC' && oppty.LBSExceptionType__c == '11' 
                       && oppty.LogisticsBizDevelopmentType__c == '10'){
                           canNewActivity = true; 
                           /** V2.1 Kajal END  **/
                       }else if(oppty.LogisticsCustomerType__c != 'SECSET' && oppty.LogisticsCustomerType__c != 'SECDS' &&
                                (oppty.Opportunity_Logistics_CPReviewStatus_FIN__c == null || oppty.Opportunity_Logistics_CPReviewStatus_FIN__c == '')
                               ){
                                   msgList.add(System.Label.LOGISTICS_CPSTATUS_MSG_FIN);
                                   canNewActivity = false;
                               }else{
                                   canNewActivity = true;
                               }
                }else if(activityItem.MasterAct.TransactionName__c == '2.3.2.'){
                    if(oppty.LogisticsCustomerType__c != 'SECSET' && oppty.LogisticsCustomerType__c != 'SECDS' &&
                        (oppty.Opportunity_Logistics_CPReviewStatus_BID__c == null || oppty.Opportunity_Logistics_CPReviewStatus_BID__c == '')){
                           msgList.add(System.Label.LOGISTICS_CPSTATUS_MSG_BID);
                           canNewActivity = false;
                       }else{
                           canNewActivity = true;
                       }
                }
                //KAJAL END V1.8
            }
            

            // 6. (불가) 수주품의 Activity 완료: 중도종결/실주 Activity 수행 불가
            //         수주품의 Activity 완료전: 중도종결/실주 Activity 수행 가능            
            Set<String> dropLostActivity  = new Set<String>{OpportunityActivityHelper.ACT_CODE_DROP_OPPORTUNITY, OpportunityActivityHelper.ACT_CODE_LOST_OPPORTUNITY};
            if(dropLostActivity.contains(activityItem.MasterAct.TransactionName__c)) {
                List<Opportunity_Activity__c> contractApprovalCompletedList = [
                    SELECT  Id, Status__c 
                    FROM    Opportunity_Activity__c
                    WHERE   WhatId__c  = :activityItem.opptyId
                            AND TransactionName__c = :OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL
                            AND Status__c = 'Completed'
                ];

                if(contractApprovalCompletedList.size() > 0) {
                    // "{수주품의 Label}" Activity가 완료되어 수행할 수 없습니다.
                    msgList.add(String.format(System.Label.OPPTYACT_MSG_011, new String[]{opptActNameLabelMap.get(OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL)}));
                    canNewActivity = false;
                }
            }

            // 7. (불가) Opportunity Stage "Closed Won"일 시, 중도종결/실주 Activity 수행 불가            
            if(dropLostActivity.contains(activityItem.MasterAct.TransactionName__c) && oppty.StageName == OpportunityActivityHelper.OPP_STAGE_WON){
                List<Map<String, String>> opptyStagePicklist = Utils.getPicklistOptionType('Opportunity','StageName');
                Map<String, String> opptyStagePicklistMap = new Map<String, String>(); // <key : Api Name,  value : label>
                for(Integer i=0; i< opptyStagePicklist.size(); i++){
                    opptyStagePicklistMap.put(opptyStagePicklist[i].get('value'), opptyStagePicklist[i].get('label'));
                }
                String opptyStagePickLabel = opptyStagePicklistMap.get(oppty.StageName);
                String opptyStageFieldLabel = Utils.getFieldLabel('Opportunity').get('stagename');

                // "{Closed Won Label}" {StageName Field Label}에서 수행할 수 없습니다.
                msgList.add(String.format(System.Label.OPPTYACT_MSG_012, new String[]{ opptyStagePickLabel, opptyStageFieldLabel }) );   
                canNewActivity = false; 
            }

            // 8. (불가) 신용평가 전에 Stage가 Qualified, Solutioned, Closed에 있는 모든 Activity를 수행하려고 할 경우 Alert 발생
            //2022-09-29, hyunhak.roh@dkbmc.com, 물류 - Auto Stage Update 관련 로직 추가 변경건
            // "{0}" 엑티비티가 완료되지 않으면 진행 불가능합니다.
            if(isLogisticsRecordType) {
                boolean isBoActCreditAssenssment = false;
                //2022-12-06, hyunhak.roh@dkbmc.com, Customer Type => 'External(EXTAC)' 로직 추가
                if(oppty.LogisticsCustomerType__c == OpportunityActivityHelper.OPP_CUSTOMER_TYPE_EXTERNAL) {
                    for(MasterActivity__c msAct : chkMasterActList) {
                        if(	msAct.TransactionName__c == activityItem.MasterAct.TransactionName__c) {
                            if(		opportunityActivityHelper.OPP_STAGE_QUALIFIED == msAct.Stage__c
                                ||	opportunityActivityHelper.OPP_STAGE_SOLUTIONED == msAct.Stage__c
                                ||	opportunityActivityHelper.OPP_STAGE_CLOSED_SET.contains(msAct.Stage__c)) {
                                
                                for(Opportunity_Activity__c reqOpptyAct : allOpptyActList) {
                                    if(		reqOpptyAct.TransactionName__c == OpportunityActivityHelper.ACT_CODE_CREDIT_ASSESSMENT
                                       && 	reqOpptyAct.Status__c == 'Completed'  ) {
                                        isBoActCreditAssenssment = true;
                                    }
                                }
                            }
                            else {
                                isBoActCreditAssenssment = true;
                            }
                            /** V2.0--Added by Kajal **/
                                   if(oppty.LBSExceptionType__c == OpportunityActivityHelper.OPP_LBS_TYPE_SQUARE_PRODUCT &&
                                      (oppty.Type =='01' ||oppty.Type == '02' )){
                                         isBoActCreditAssenssment = true;
                                          
                                      } 
                            /**V2.0 End**/
                            break;
                        }
                    }
                    
                    if(!isBoActCreditAssenssment) {
                        msgList.add(String.format(System.Label.OPPTYACT_MSG_019, new String[]{opptActNameLabelMap.get(OpportunityActivityHelper.ACT_CODE_CREDIT_ASSESSMENT)}));
                        canNewActivity = false;
                    }
                }
            }

            if(msgList.size() > 0) { 
                msg = String.join(msgList, '; ');
            }
            responseMap = new Map<String, Object>{
                'canNewActivity' => canNewActivity,  
                'msg' => msg
            };
            
        } catch (Exception e) {            
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            throw new AuraHandledException(e.getMessage());
        }
        
        System.debug('### OpportunityActivityNewController :: checkStatusActivity :: return = ' + JSON.serialize(responseMap));

        return JSON.serialize(responseMap);
    }
    
    public static String createOpportunityActivity(Opportunity_Activity__c opptyAct) {
        
		System.debug('### FIND Drop Activity Create :: OpportunityActivityNewController :: createOpportunityActivity');
        
    
        opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
        opptyAct.Id = null;
        
        system.debug(opptyAct.ExtId__c);
        upsert opptyAct ExtId__c;
        //신규추가시작
        //입찰결정 요청 신규 생성시 Stage -> Qualified로 변경
        if('XP71'==opptyAct.TransactionName__c){
            Opportunity oppty = [SELECT Id, StageName FROM Opportunity WHERE Id=:opptyAct.WhatId__c LIMIT 1];
            oppty.StageName = 'Z03';
            update oppty;
        }
        //신규추가종료
        return opptyAct.Id;
    }

    /**
     * Opportunity Activity [Work Tab] 에서 완료 후 Event Handling 처리 
     */
    @AuraEnabled
    public static String upsertOpportunityActivity(String jsonData) {
        
        Opportunity_Activity__c opptyAct = (Opportunity_Activity__c)JSON.deserialize(jsonData, Opportunity_Activity__c.class);
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            String opptyActStatus = opptyAct.Status__c;
            String opptyActId = opptyAct.Id;
            opptyAct.Id = null; // upsert key 값으로 처리하기위해서 id null 처리
            
            // 상태 Update : 완료
            if(opptyActStatus == OPPTYACT_STATUS_COMPLETED) {        
                // 각 Activity Date가 비어있을 경우 today 입력
                if( String.isBlank(String.ValueOf(opptyAct.StartDate__c)) ) {
                    opptyAct.StartDate__c = Date.today();
                } else if (opptyAct.StartDate__c > Date.today()) {
                    opptyAct.StartDate__c = Date.today();
                }

                if( String.isBlank(String.ValueOf(opptyAct.DueDate__c)) ) opptyAct.DueDate__c = Date.today();
                if( String.isBlank(String.ValueOf(opptyAct.EndDate__c)) ) opptyAct.EndDate__c = Date.today();
            }
            opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
            //TODO : Lost Activity 존재시 Drop Activity 생성되지 않도록 체크.
            System.debug('### FIND Drop Activity Create :: OpportunityActivityNewController :: upsertOpportunityActivity :: ExtId__c = ' + opptyAct.ExtId__c);
            
            upsert opptyAct ExtId__c;
        } catch (Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            throw new AuraHandledException(e.getMessage());
        }

        return JSON.serialize(responseMap);
    }

    /**
     * Only Description Update
     */
    @AuraEnabled
    public static Boolean upsertActivityDescription(String jsonData) {
        System.debug('### FIND Drop Activity Create :: OpportunityActivityNewController :: upsertActivityDescription');
        
        Opportunity_Activity__c opptyAct = (Opportunity_Activity__c)JSON.deserialize(jsonData, Opportunity_Activity__c.class);
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean isSuccess;
        try {
            String opptyActId = opptyAct.Id;
            opptyAct.Id = null; // upsert key 값으로 처리하기위해서 id null 처리
            opptyAct.ExtId__c = OpportunityActivityHelper.generateOpportunityActivityExtKey(opptyAct);
            upsert opptyAct ExtId__c;

            isSuccess = true;
        } catch (Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            isSuccess = false;
            throw new AuraHandledException(e.getMessage());
        }

        return isSuccess;
    }

    
    /**
     * 임시로 생성된 Status 가 빈 값인 Oppty 삭제
     */
    @AuraEnabled
    public static void deleteTempOpportunityActivity(String opptyId) {
        try {
            List<Opportunity_Activity__c> delOpptyActList = [
                SELECT Id
                FROM Opportunity_Activity__c
                WHERE WhatId__c = :opptyId
                    AND Status__c = null
            ];
        
            if(!delOpptyActList.isEmpty()) DELETE delOpptyActList;

        } catch(Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
        }
    }
    /**
     * Add User Manual Button in Service/Solution tab. 
     */
    @AuraEnabled
    Public static ID openfile(){
        
        ID bbID;
        try{
            if(UserInfo.getLanguage() == 'ko'){
                bbID = [Select ID from BulletinBoard__c where Name = '사업참여 검토 프로세스(서비스솔루션 등록) 매뉴얼' Limit 1].ID;
            }
            else{
                bbID = [Select ID from BulletinBoard__c where Name = 'Review Opportunity process(Service/Solution registration) Manual' Limit 1].ID;
            }
            return bbID;
        }catch(Exception e){
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            return null;
        }
        
    }
    //V.1.6 -> Add simulation button functionality
    @AuraEnabled
    public static String checkOppCSPMSPValue(String oppId) {
        system.debug('oppId**' + oppId);
        //V1.9 - Add T100 condition in below soql (MySales 112)
        // List<Solution__c> solList = [select id from Solution__c where Opportunity__c =: oppId AND sSolution__r.Code__c = '32000092' 
        //                        		 And sSolution__r.Name = 'SCP' AND Opportunity__r.CspMspType__c = 'CSP' AND DeletionFlag__c= false AND
        //                              Opportunity__r.CompanyCode__c = 'T100'];

        // v2.4 - SCP Price Simulation Logic modification
        List<Opportunity> optyList = [select id from Opportunity where id =: oppId AND CMBizType__c = 'CSP_SCP'];

        String simulationEnabled = 'false';
        if(optyList.size() >= 1){
          simulationEnabled = 'true';  
        }else{
            simulationEnabled = 'false';
        }
        system.debug('simulationEnabled**' + simulationEnabled);
        return simulationEnabled;
    }
    //V.1.6 -> Add simulation button functionality
    @AuraEnabled
    public static opportunity fetchOppDataForSimulation(String oppId) {
        system.debug('oppId**' + oppId);
        opportunity opp = [Select CompanyCode__c,OpportunityCode__c,Name,Owner.Email,Account.AccountNumber from opportunity where Id =: oppId];
        system.debug('oppValue**' + opp);
        return opp;
    }

    //START V 2.2
    @AuraEnabled
    public static String checkoppactlostResultrcd(String opptId, String opptyActId){
        
        List<LostResult__c> lostrsltlist = [Select id, ApproveStatus__c,Rate__c from LostResult__c where LostActivity__c=: opptyActId  AND IsCheck__c=true]; 
        List<Opportunity_Activity__c> oppactivitylist = [Select id from Opportunity_Activity__c where WhatId__c =: opptId AND (TransactionName__c ='ZPZ1' OR TransactionName__c ='ZPZ2') AND Status__c != ''];
        Map<String, Object> resultMap = new Map<String, Object>{
            'opportunityActivity' => oppactivitylist,
                'lostResultval' => lostrsltlist
                };
                    return JSON.serialize(resultMap);
    }
    @AuraEnabled
    public static String delLostDropRecord(Id OppId, String Lostdroptypeval){
        String lostdroptype;
        List<LostResult__c> dellostres = new List<LostResult__c>();
        List<Lost_Countermeasure__c> dellostcountr = new List<Lost_Countermeasure__c>();
        if(Lostdroptypeval == 'Z06'){
        lostdroptype = 'Lost';
        }
        if(Lostdroptypeval == 'Z07'){
          lostdroptype = 'Drop';
 
        }
         dellostres = [select id from LostResult__c where Opportunity__c =: OppId AND  Master_LostType__r.Lost_Drop_Type__c !=:lostdroptype];
        dellostcountr = [select id from Lost_Countermeasure__c where Opportunity__c =: OppId AND  Master_LostType__r.Lost_Drop_Type__c !=:lostdroptype];
        if(dellostres.size() > 0){
            Delete dellostres;
        }
        if(dellostcountr.size() > 0){
            Delete dellostcountr;
        }
        return 'Deleted Successfully';
            }
    // END V 2.2
    
   
}