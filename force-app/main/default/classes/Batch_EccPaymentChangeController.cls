/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-10-11
 * @last modified by  : atul.k1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   02-05-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0   2021-08-05   seonju.jin@dkbmc.com               If-042 배치 호출추가
 * 1.1   2022-08-01   hyunhak.roh@dkbmc.com				 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
 * 1.2   2023-10-11   atul.k1@samsung.com				 'Exception Handling first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, In the case of a collaborative BO, the head office (T100) can only select the following currencies (EUR, GBP, JPY, SGD, USD)'
**/
global class Batch_EccPaymentChangeController implements DataBase.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts { // , schedulable
    // Batch_KnoxApprovalDetailController 배치의 후속배치 (별도의 스케줄러 x)
    private static final String INTERFACE_ID = 'IF-093';
    private static final String APEX_CLASS   = 'Batch_EccPaymentChangeController';
    private IF_Log log = new IF_Log();
    public List<Solution__c> gSolutionList = new List<Solution__c>();
    public List<Opportunity> gOpptyList = new List<Opportunity>();
    public Map<String,Object> gOpptyMap = new Map<String,Object>();
    public Map<String,Object> gSolMap = new Map<String,Object>();
    public List<KnoxApproval__c> approvalList = new List<KnoxApproval__c>();
    public List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();
   

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> statusTarget = new Set<String> { '2', '3', '4' };
        String query = 'SELECT id, WFOBJECT__c, MISID__c, Status__c, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c FROM KnoxApproval__c';
        query += ' WHERE Opportunity__c != null and MISID__c != null and syncFlag__c = \'Y\' and ( Status__c in: statusTarget) ';

        //2022-08-01, hyunhak.roh@dkbmc.com, 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
        query += ' AND syncFlag__c != \'X\' ';
        query += ' AND Opportunity__c != null And OpportunityActivity__c != null '; //2021.07.05 seonju.jin / Opportunity, OpportunityActivity 없는경우 제외
        query += ' AND Opportunity__r.StageName != \'Z08\'';                        //2021.07.05 seonju.jin / Cleansed 데이터 제외
        //2022.09.28 SDZ 도 전송하도록 변경.
        //query += ' AND (NOT Opportunity__r.OpportunityCode__c  LIKE \'SDZ%\')';     //2021.07.05 seonju.jin / Opportunity Code SDZ 제외

        Set<String> migIdSet = new Set<String>();
        Organization org = [ SELECT Id, IsSandBox FROM Organization];
        if( org.IsSandbox){
            migIdSet.add('kjh5925.kim@samsung.com.sds.qa');
        }else {
            migIdSet.add('mig01@samsung.com');
            migIdSet.add('mig02@partner.samsung.com');
        }

        //마이그 데이터 제외
        query += ' AND (CreatedBy.UserName NOT IN :migIdSet ';

        //2021.07.05 seonju.jin / 마이그 데이터중 법인통합 데이터는 결재 가능
        query += ' OR (CreatedBy.UserName IN :migIdSet AND Opportunity__r.IsEdited__c = true AND Opportunity__r.IsCostCenterMerge__c = true))';
        
                
        // 마이그 데이터 제외
        /* Organization org = [ SELECT Id, IsSandBox FROM Organization];
        if( org.IsSandbox){

            query += ' AND CreatedBy.EmployeeNumber NOT IN ( \'15925\', \'32604\') ';
        }else { // 마이그 데이터 제외

            query += ' AND CreatedBy.UserName NOT IN ( \'mig01@samsung.com\', \'mig02@partner.samsung.com\') ';
        } */
        
        query +=' order by CreatedDate DESC';

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<KnoxApproval__c> objList) {
        system.debug('Execute Batch_EccPaymentChangeController --------------------');
        String guId     = IF_Util.generateGuid();
        try{
            for(KnoxApproval__c obj : objList){
            
                Map<String, Object> returnMap = new Map<String, Object>{
                    'Opportunity_Map' => null,
                    'Solution_Map' => null,
                    'INTERFACE_LOG' => null
                };
                /*
                Integer start = System.Now().millisecond();
                while(System.Now().millisecond()< start+3000){ 
                    
                }*/
                //IF Data Mapping & Callout 
                // returnMap.putAll(IF_EccPaymentProgChangeController.IF093_Callout(obj.id,obj.Status__c,true));
                returnMap.putAll(IF_EccPaymentProgChangeController.IF093_Callout(obj, obj.Status__c, true)); // 2021-11-08 / KnoxApproval 자체를 전달하도록 변경
                
                if(returnMap.get('INTERFACE_LOG') != null) ifLogList.add( (IF_Log.InterfaceLog) returnMap.get('INTERFACE_LOG') );
                if(returnMap.get('Opportunity_Map') != null) gOpptyMap.putAll( (Map<String,Object>) returnMap.get('Opportunity_Map') );
                if(returnMap.get('Solution_Map') != null) gSolMap.putAll( (Map<String,Object>) returnMap.get('Solution_Map') );
                //2021.02.23 추가 by Soohong.Kim
                if(returnMap.get('Approval') != null ) approvalList.add( (KnoxApproval__c) returnMap.get('Approval') );
                //Object ifLogObj = returnMap.get( 'INTERFACE_LOG');
                //if( ifLogObj   != null)  ifLogList.add( ( IF_Log.InterfaceLog)ifLogObj);
            }
        }catch(Exception e){
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.message : '+e.getMessage());
            ifLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, '', '', '', e));
        }
    }

    global void finish(Database.BatchableContext bc) {
    try{
        for(IF_Log.InterfaceLog ifLog : ifLogList){
            ifLog.ApexName = APEX_CLASS;
            ifLog.ApexMethod = 'execute';
            //log.createLog(ifLog);
        }
        log.createLog(ifLogList);
        for(String key : gOpptyMap.keySet()){
            system.debug('oppty in batch : '+gOpptyMap.get(key));
            gOpptyList.add( (Opportunity) gOpptyMap.get(key) );
        }
        for(String key : gSolMap.keySet()){
            gSolutionList.add( (Solution__c) gSolMap.get(key) );
        }

        System.debug('gOpptyList:' + gOpptyList);
        /* V 1.2 Start*/
        //if(gOpptyList.size()>0) update gOpptyList;
        if(gOpptyList.size()>0) Database.update(gOpptyList,false);
        /* V 1.2 End*/
        if(gSolutionList.size()>0) upsert gSolutionList;

        //2021.02.23 추가 by Soohong.Kim
        if(approvalList.size()>0) update approvalList;
        
        // 2021.08.06 IF-042 callout 추가
        Set<Id> opptyIdSet = new Set<Id>();
        for(Opportunity oppty : gOpptyList){
            opptyIdSet.add(oppty.Id);
        } 
        system.debug('calloutDashboardInfo opptyIdSet:' + opptyIdSet);
        if(opptyIdSet.size()> 0) database.executeBatch(new Batch_LsDashboardController(opptyIdSet), 50);
    }
        /* V 1.2 Start*/
        catch(Exception e){
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.stackTrace : '+e.getStackTraceString());
            system.debug('e.getMessage : '+e.getMessage());
            ifLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, IF_Util.generateGuid(), APEX_CLASS, 'Finsih Catch', '', '',e));
            log.createLog(ifLogList); 
        }
         /* V 1.2 End*/
        // 2021-12-29 / IF-093 배치작업 완료 15분 후 다시 실행(스캐쥴로 실행되는 경우에만 해당, IF-133 후속으로 IF-093이 호출되는 경우는 제외)
        /*
        if(System.isScheduled()){
            List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_EccPaymentChangeController'];
            for(CronTrigger obj : schJobList){
                System.abortJob(obj.id);
            }
    
            Integer iMin = Datetime.now().minute()+15;
            if(iMin >= 60) iMin -=60;
            String min = String.valueOf(iMin);
            System.schedule('Batch_EccPaymentChangeController', '0 '+min+' * * * ? *' , new Batch_EccPaymentChangeController());
        }
        */
    }

    /*
    public void execute(SchedulableContext sc) {
        database.executebatch(new Batch_EccPaymentChangeController());
    }
    */
}