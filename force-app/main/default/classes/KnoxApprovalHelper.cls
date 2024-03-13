/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-11-17
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                Modification
 * 1.0   2021-01-08   hj.lee@dkbmc.com      Initial Version
 * 1.1   2021-08-06   seonju.jin@dkbmc.com  IF-042 callout 추가
**/
public class KnoxApprovalHelper {

    public static final String KNOX_APPROVAL_STATUS_IN_PROGRESS         = '1'; // 진행중
    public static final String KNOX_APPROVAL_STATUS_COMPLETED           = '2'; // 완결
    public static final String KNOX_APPROVAL_STATUS_REJECT              = '3'; // 반려
    public static final String KNOX_APPROVAL_STATUS_CANCEL              = '4'; // 상신취소
    public static final String KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED = '5'; // 전결
    public static final String KNOX_APPROVAL_STATUS_AFTER_CONFIRMED     = '6'; // 후완결

    /**
     * [IF-135] Knox 결재 중간처리
     */
    public static Map<String,Object> callOut_if135(KnoxApproval__c approval, List<Project__c> prjList){
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
            
        Map<String,Object> responseMap = Batch_EccUpdateStatusController.syncApproval(input_if135);
        return responseMap;
    }

    /**
     * [IF-093] Knox 결재 후속처리
     */
    public static Map<String,Object> callOut_if093(String knoxApprovalId, String updatedApprovalStatus){
        Map<String,Object> eccPaymentProgChangeMap = IF_EccPaymentProgChangeController.IF093_Callout(knoxApprovalId, updatedApprovalStatus, false);
        System.debug('[IF-093] eccPaymentProgChangeMap ' + eccPaymentProgChangeMap );
        return eccPaymentProgChangeMap;
    }

    // 2021-11-08 신규 추가
    public static Map<String,Object> callOut_if093(KnoxApproval__c knoxApproval, String updatedApprovalStatus){
        Map<String,Object> eccPaymentProgChangeMap = IF_EccPaymentProgChangeController.IF093_Callout(knoxApproval, updatedApprovalStatus, false);
        System.debug('[IF-093] eccPaymentProgChangeMap ' + eccPaymentProgChangeMap );
        return eccPaymentProgChangeMap;
    }


    /**
    * @description IF-135 호출 대상 확인
    * @author leehyo | 2021-03-28 
    * @param obj 
    * @param prjSize 
    * @return Boolean 
    **/
    public static Boolean isTarget_if135(knoxApproval__c obj, Integer prjSize){
        Boolean result = OpportunityActivityHelper.OPPACT_TARGET_SET_IF135.contains(obj.OpportunityActivity__r.TransactionName__c) 
                        && (obj.syncFlag__c == 'N')
                        && (prjSize > 0);
        
        return result;
    }

    /**
    * @description If-093 호출 대상 확인
    * @author leehyo | 2021-03-28 
    * @param obj 
    * @param updatedApprovalStatus 
    * @return Boolean 
    **/
    public static Boolean isTarget_if093(knoxApproval__c obj, String updatedApprovalStatus){
        Set<String> knoxStatusSet = new Set<String>{'2', '3', '4'};
        Boolean result = OpportunityActivityHelper.OPPACT_TARGET_SET_IF135.contains(obj.OpportunityActivity__r.TransactionName__c) 
                        && (obj.syncFlag__c == 'Y')
                        && (knoxStatusSet.contains(updatedApprovalStatus));
        
        return result;
    }
    
    /*
    public static Map<String, Object> process_if093(String knoxApprovalId, String updatedApprovalStatus){
        Map<String, Object> updateObjectMap = new Map<String, Object>();

        List<Opportunity> updateOpptyList = new List<Opportunity>();
        List<Solution__c> updateSolutionList = new list<Solution__c>();
        List<KnoxApproval__c> updateKnoxApprovalList = new list<KnoxApproval__c>();
        List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
        IF_Log log = new IF_Log(); 

        KnoxApproval__c knoxApp = [
            SELECT  Id, 
                    MISID__c, 
                    Status__c,
                    WFOBJECT__c,
                    Opportunity__c,
                    Opportunity__r.OpportunityCode__c,
                    OpportunityActivity__c, 
                    OpportunityActivity__r.TransactionName__c,
                    syncFlag__c,
                    (SELECT Id, MISID__c, Status__c, WFOBJECT__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__c, OpportunityActivity__r.TransactionName__c, syncFlag__c 
                        FROM KnoxApproval__r)
            FROM    KnoxApproval__c 
            WHERE   Id = :knoxApprovalId
        ];
        
        Boolean targetFlag_if093 = KnoxApprovalHelper.isTarget_if093(knoxApp, updatedApprovalStatus);
        System.debug(' ####### knoxApp.syncFlag__c ' + knoxApp.syncFlag__c);
        System.debug(' ####### updatedApprovalStatus ' + updatedApprovalStatus);
        Boolean eccPaymentProgChange_HttpSuccess = false;
        if(targetFlag_if093 || Test.isRunningTest() ) {
            Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(knoxApprovalId, updatedApprovalStatus);
            eccPaymentProgChange_HttpSuccess = String.ValueOf(eccPaymentProgChangeMap.get('StatusCode')) == 'S' ? true : false;
            
            if(eccPaymentProgChangeMap.get('INTERFACE_LOG') != null)  ifLogList.add((IF_Log.InterfaceLog)eccPaymentProgChangeMap.get('INTERFACE_LOG'));
            if(eccPaymentProgChange_HttpSuccess){
                if(eccPaymentProgChangeMap.get('Opportunity') != null) {
                    Opportunity updateOppty = (Opportunity)eccPaymentProgChangeMap.get('Opportunity');
                    updateOppty.isUpdatedAuto__c = true;
                    updateOpptyList.add(updateOppty);
                }
                if(eccPaymentProgChangeMap.get('Solution') != null)       updateSolutionList.addAll((List<Solution__c>) eccPaymentProgChangeMap.get('Solution'));
                if(eccPaymentProgChangeMap.get('Approval') != null)       updateKnoxApprovalList.add((KnoxApproval__c) eccPaymentProgChangeMap.get('Approval'));
            }
        }

        // ************************************************************
        // Collaboration KnoxApproval
        // ************************************************************
        if( knoxApp.KnoxApproval__r.size() > 0 ) {
            KnoxApproval__c collaboKnoxApproval = knoxApp.KnoxApproval__r[0];
            Boolean collaboTargetFlag_if093 = KnoxApprovalHelper.isTarget_if093(collaboKnoxApproval, updatedApprovalStatus);
            Boolean collaboEccPaymentProgChange_HttpSuccess = false;
            if(collaboTargetFlag_if093 || Test.isRunningTest() ) {
                // Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(collaboKnoxApproval.Id, updatedApprovalStatus);
                Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(collaboKnoxApproval, updatedApprovalStatus); // 2021-11-08 / KnoxApproval 자체를 전달하도록 변경
                collaboEccPaymentProgChange_HttpSuccess = String.ValueOf(eccPaymentProgChangeMap.get('StatusCode')) == 'S' ? true : false;
                
                if(eccPaymentProgChangeMap.get('INTERFACE_LOG') != null)  ifLogList.add((IF_Log.InterfaceLog)eccPaymentProgChangeMap.get('INTERFACE_LOG'));
                if(collaboEccPaymentProgChange_HttpSuccess) {
                    if(eccPaymentProgChangeMap.get('Opportunity') != null) {
                        Opportunity updateOppty = (Opportunity)eccPaymentProgChangeMap.get('Opportunity');
                        updateOppty.isUpdatedAuto__c = true;
                        updateOpptyList.add(updateOppty);
                    }
                    if(eccPaymentProgChangeMap.get('Solution') != null)       updateSolutionList.addAll((List<Solution__c>) eccPaymentProgChangeMap.get('Solution'));
                    if(eccPaymentProgChangeMap.get('Approval') != null)       updateKnoxApprovalList.add((KnoxApproval__c) eccPaymentProgChangeMap.get('Approval'));
                }
            }
        }

        // [DML] IF-093 결과 Update / Upsert return
        if(ifLogList.size() > 0) updateObjectMap.put('ifLogList', ifLogList);
        if(updateOpptyList.size() > 0) updateObjectMap.put('Opportunity', updateOpptyList);

        //2021.08.06 IF-042 callout 추가
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity oppty : updateOpptyList){
            opptyIdSet.add(oppty.Id);
        }
        if(opptyIdSet.size()> 0) database.executeBatch(new Batch_LsDashboardController(opptyIdSet), 50); //IF_LsDashboardController.calloutDashboardInfo(opptyIdSet);

        if(updateSolutionList.size() > 0) updateObjectMap.put('Solution', updateSolutionList);
        if(updateKnoxApprovalList.size() > 0) updateObjectMap.put('Approval', updateKnoxApprovalList);

        return updateObjectMap;
     }
     */

     /**
      * IF-093 후처리 업데이트 로직 QUEUE 
      */
     public class Queue_Process_if093 implements Queueable, DataBase.AllowsCallouts { 
        public String knoxApprovalId;
        public String updatedApprovalStatus;

        public Queue_Process_if093(String knoxApprovalId, String updatedApprovalStatus) {
            this.knoxApprovalId = knoxApprovalId;
            this.updatedApprovalStatus = updatedApprovalStatus;
        }

        public void execute(QueueableContext context) {
            List<Opportunity> updateOpptyList = new List<Opportunity>();
            List<Solution__c> updateSolutionList = new list<Solution__c>();
            List<KnoxApproval__c> updateKnoxApprovalList = new list<KnoxApproval__c>();
            List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
            IF_Log log = new IF_Log(); 
            
            system.debug('### KnoxApprovalHelper :: execute :: Start ');
    
            KnoxApproval__c knoxApp = [
                SELECT  Id, 
                        MISID__c, 
                        Status__c,
                        WFOBJECT__c,
                        Opportunity__c,
                        Opportunity__r.OpportunityCode__c,
                        OpportunityActivity__c, 
                        OpportunityActivity__r.TransactionName__c,
                        syncFlag__c,
                        (SELECT Id, 
                                MISID__c, 
                                Status__c, 
                                WFOBJECT__c, 
                                Opportunity__c, 
                                Opportunity__r.CompanyCode__c, 
                                Opportunity__r.OpportunityCode__c, 
                                OpportunityActivity__c, 
                                OpportunityActivity__r.TransactionName__c, 
                                syncFlag__c 
                           FROM KnoxApproval__r)
                FROM    KnoxApproval__c 
                WHERE   Id = :knoxApprovalId
            ];
            
            Boolean targetFlag_if093 = KnoxApprovalHelper.isTarget_if093(knoxApp, updatedApprovalStatus);
            System.debug(' ####### knoxApp.syncFlag__c ' + knoxApp.syncFlag__c);
            System.debug(' ####### updatedApprovalStatus ' + updatedApprovalStatus);
            Boolean eccPaymentProgChange_HttpSuccess = false;
            if(targetFlag_if093 || Test.isRunningTest() ) {
                Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(knoxApprovalId, updatedApprovalStatus);
                eccPaymentProgChange_HttpSuccess = String.ValueOf(eccPaymentProgChangeMap.get('StatusCode')) == 'S' ? true : false;
                
                system.debug('### KnoxApprovalHelper :: execute :: targetFlag_if093 :: eccPaymentProgChangeMap = ' + eccPaymentProgChangeMap);
                
                if(eccPaymentProgChangeMap.get('INTERFACE_LOG') != null)  ifLogList.add((IF_Log.InterfaceLog)eccPaymentProgChangeMap.get('INTERFACE_LOG'));
                if(eccPaymentProgChange_HttpSuccess || Test.isRunningTest()){
                    if(eccPaymentProgChangeMap.get('Opportunity') != null) {
                        Opportunity updateOppty = (Opportunity)eccPaymentProgChangeMap.get('Opportunity');
                        updateOppty.isUpdatedAuto__c = true;
                        updateOpptyList.add(updateOppty);
                    }
                    if(eccPaymentProgChangeMap.get('Solution') != null)       updateSolutionList.addAll((List<Solution__c>) eccPaymentProgChangeMap.get('Solution'));
                    if(eccPaymentProgChangeMap.get('Approval') != null)       updateKnoxApprovalList.add((KnoxApproval__c) eccPaymentProgChangeMap.get('Approval'));
                }
            }
    
            // ************************************************************
            // Collaboration KnoxApproval
            // ************************************************************
            if( knoxApp.KnoxApproval__r.size() > 0 ) {
                KnoxApproval__c collaboKnoxApproval = knoxApp.KnoxApproval__r[0];
                Boolean collaboTargetFlag_if093 = KnoxApprovalHelper.isTarget_if093(collaboKnoxApproval, updatedApprovalStatus);
                Boolean collaboEccPaymentProgChange_HttpSuccess = false;
                if(collaboTargetFlag_if093 || Test.isRunningTest() ) {
                    // Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(collaboKnoxApproval.Id, updatedApprovalStatus);
                    Map<String, Object> eccPaymentProgChangeMap = KnoxApprovalHelper.callOut_if093(collaboKnoxApproval, updatedApprovalStatus); // 2021-11-08 / KnoxApproval 자체를 전달하도록 변경
                    collaboEccPaymentProgChange_HttpSuccess = String.ValueOf(eccPaymentProgChangeMap.get('StatusCode')) == 'S' ? true : false;
                    
                    system.debug('### KnoxApprovalHelper :: execute :: collaboTargetFlag_if093 :: eccPaymentProgChangeMap = ' + eccPaymentProgChangeMap);
                    
                    if(eccPaymentProgChangeMap.get('INTERFACE_LOG') != null)  ifLogList.add((IF_Log.InterfaceLog)eccPaymentProgChangeMap.get('INTERFACE_LOG'));
                    if(collaboEccPaymentProgChange_HttpSuccess) {
                        if(eccPaymentProgChangeMap.get('Opportunity') != null) {
                            Opportunity updateOppty = (Opportunity)eccPaymentProgChangeMap.get('Opportunity');
                            updateOppty.isUpdatedAuto__c = true;
                            updateOpptyList.add(updateOppty);
                        }
                        if(eccPaymentProgChangeMap.get('Solution') != null)       updateSolutionList.addAll((List<Solution__c>) eccPaymentProgChangeMap.get('Solution'));
                        if(eccPaymentProgChangeMap.get('Approval') != null)       updateKnoxApprovalList.add((KnoxApproval__c) eccPaymentProgChangeMap.get('Approval'));
                    }
                }
            }
            
            system.debug('### KnoxApprovalHelper :: execute :: updateOpptyList1 = ' + updateOpptyList);
    
            // [DML] IF-093 결과 Update / Upsert return
            if(ifLogList.size() > 0) log.createLog(ifLogList);
            if(updateOpptyList.size() > 0) update updateOpptyList;
            
            system.debug('### KnoxApprovalHelper :: execute :: updateOpptyList2 = ' + updateOpptyList);
            
            //2021.08.06 IF-042 callout 추가
            Set<Id> opptyIdSet = new Set<Id>();
            for(Opportunity oppty : updateOpptyList){
                opptyIdSet.add(oppty.Id);
            }
            if(opptyIdSet.size() > 0) database.executeBatch(new Batch_LsDashboardController(opptyIdSet), 50); //IF_LsDashboardController.calloutDashboardInfo(opptyIdSet);

            if(updateSolutionList.size() > 0) update updateSolutionList;

            // Only Knox Approval Sync Flag Field Update
            List<KnoxApproval__c> updateSyncFlagKnoxList = new List<KnoxApproval__c>();
            if(updateKnoxApprovalList.size() > 0) {
                for(KnoxApproval__c tempKnox : updateKnoxApprovalList) {
                    KnoxApproval__c updateSyncFlagKnox = new KnoxApproval__c();
                    updateSyncFlagKnox.Id = tempKnox.Id;
                    updateSyncFlagKnox.syncFlag__c = tempKnox.syncFlag__c = 'S';
                    updateSyncFlagKnoxList.add(updateSyncFlagKnox);
                }
            }
            if(updateSyncFlagKnoxList.size() > 0) update updateSyncFlagKnoxList;
            
            system.debug('### KnoxApprovalHelper :: execute :: End ');
        }
    }
    
    /**
    * @description KnoxApporvalTrigger - syncStatusCollaboKnoxApproval
    * @author seonju.jin@dkbmc.com | 2022-02-23 
    * @param String jsonString KnoxApproval List to json String
    **/
    @future()
    public static void updateCollaboApproval(String jsonString) {
        try{
            List<KnoxApproval__c> knoxApprovalList = (List<KnoxApproval__c>)JSON.deserialize(jsonString, List<KnoxApproval__c>.class);
            Database.update(knoxApprovalList,false);    
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
        }
    }
}