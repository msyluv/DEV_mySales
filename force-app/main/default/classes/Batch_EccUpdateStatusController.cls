/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-11-29
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   02-10-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   04-14-2021   kilhwan.anpartner.samsung.com      마이그 조건 제외추가
 * 1.2   07-06-2021   seonju.jin@dkbmc.com               쿼리 조건 수정
 * 1.3	 2022-08-01   hyunhak.roh@dkbmc.com				 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
 * 1.4   2023-01-02   kajal.c@samsung.com	             Added condition for IF-135 Related Logic Modification **/
public class Batch_EccUpdateStatusController implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable{
    private static final String INTERFACE_ID = 'IF-135';
    private static final String APEX_CLASS   = 'Batch_EccUpdateStatusController';
    private static final String METHOD_NAME  = 'syncApproval';
    public IF_Log.InterfaceLog ifLog;
    List<KnoxApproval__c> approvalList;
    List<IF_Log.InterfaceLog> ifLogList;
    //public String lastId = '';
    //public Integer querySize = 0;
    //public String limitNo = '50';
    
    
    public Batch_EccUpdateStatusController(){
		system.debug('### Batch_EccUpdateStatusController :: Const');        
        approvalList = new List<KnoxApproval__c>();
        ifLogList = new List<IF_Log.InterfaceLog>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Set<String> actList = OpportunityActivityHelper.OPPACT_TARGET_SET_IF135;
        String query = '';
        /*
        if(lastId == ''){
            query = 'SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE Status__c != \'2\' and OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'N\' and WFOBJECT__c != null and MISID__c != null ';
        } 
        else{
            query = 'SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE Status__c != \'2\' and OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'N\' and WFOBJECT__c != null and MISID__c != null and id >: lastId ';
        }
        */

        query = 'SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE Status__c IN (\'1\', \'3\', \'4\') and OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'N\' and WFOBJECT__c != null and MISID__c != null ';
        //2022-08-01, hyunhak.roh@dkbmc.com, 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
        query += ' AND syncFlag__c != \'X\' AND CreatedDate = LAST_N_DAYS:30 ';
        query += ' AND Opportunity__c != null And OpportunityActivity__c != null '; //2021.07.05 seonju.jin / Opportunity, OpportunityActivity 없는경우 제외
        query += ' AND Opportunity__r.StageName != \'Z08\'';                        //2021.07.05 seonju.jin / Cleansed 데이터 제외
        //2022.09.28 SDZ 도 전송하도록 변경.
        //query += ' AND (NOT Opportunity__r.OpportunityCode__c  LIKE \'SDZ%\')';     //2021.07.05 seonju.jin / Opportunity Code SDZ 제외


        Set<String> migIdSet = new Set<String>();
        Organization org = [ SELECT Id, IsSandBox FROM Organization];
        if( org.IsSandbox){
            migIdSet.add('kjh5925.kim@samsung.com.sds.qa');
        }else { // 마이그 데이터 제외
            migIdSet.add('mig01@samsung.com');
            migIdSet.add('mig02@partner.samsung.com');
        }

        //마이그 데이터 제외
        query += ' AND (CreatedBy.UserName NOT IN :migIdSet ';

        //2021.07.05 seonju.jin / 마이그 데이터중 법인통합 데이터는 결재 가능
        query += ' OR (CreatedBy.UserName IN :migIdSet AND Opportunity__r.IsEdited__c = true AND Opportunity__r.IsCostCenterMerge__c = true))';
        query += ' ORDER BY CreatedDate ';
        //query += ' order by id asc limit '+limitNo;
        //
        system.debug('### Batch_EccUpdateStatusController :: start :: query = ' + query); 
        
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<KnoxApproval__c> objList) { 
        
        system.debug('### Batch_EccUpdateStatusController :: execute :: objList = ' + objList); 
        
        String guId;
        Map<String,Object> resMap = new Map<String,Object>();
        try{
            for(KnoxApproval__c obj : objList){
                guId = IF_Util.generateGuid();
                //IF Data Mapping & Callout 
                resMap = IF135_Callout(obj.id,false);
                Map<String, Object> resBodyMap = (Map<String,Object>) JSON.deserializeUntyped(String.valueOf(resMap.get('Response')));
                //DML은 Finish 에서 처리
                if(String.valueOf(resMap.get('StatusCode')) == '200' && String.valueOf(resbodyMap.get('EV_RESULT')) == 'S'){
                    obj.syncFlag__c = 'Y';
                    approvalList.add(obj);
                } 
                
                if(resMap.get('IF_Log') != null) ifLogList.add( (IF_Log.InterfaceLog) resMap.get('IF_Log') );
                //lastId = obj.id;
           }

        }catch(Exception e){
            if(resMap.get('IF_Log') != null) ifLogList.add( (IF_Log.InterfaceLog) resMap.get('IF_Log') );
            else ifLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e));
        }
    }




    public static Map<String,Object> IF135_Callout(Id ApprovalId, Boolean isFuture){
        KnoxApproval__c obj = [SELECT Id, WFOBJECT__c, MISID__c, Opportunity__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c, Opportunity__r.CompanyCode__c, Status__c, syncFlag__c FROM KnoxApproval__c WHERE Id=:approvalId];
        List<Project__c> prjList = [SELECT Id, Opportunity__c, Opportunity__r.OpportunityCode__c, ProjectType__c, ProjectCode__c, Description__c, DeletionFlag__c FROM Project__c WHERE Opportunity__c =: obj.Opportunity__c];
        InputClass input = new InputClass();

        input.IV_WFOBJECT       = obj.WFOBJECT__c;                                   // 결재유형코드
        input.IV_OBJECTKEY      = obj.MISID__c;                                      // 트랙젠션 ID
        input.IV_ZZORDER_ID     = obj.Opportunity__r.OpportunityCode__c;             // BO 코드
        input.IV_PROCESS_TYPE   = obj.OpportunityActivity__r.TransactionName__c;     // 액티비티 ID
        input.IV_BUKS           = obj.Opportunity__r.CompanyCode__c;                 // 회사코드
        input.IV_STATUS         = 'A3';                                              // 결재상태
        List<IT_PROJECT> itPrjList = new List<IT_PROJECT>();
        for(Project__c prj : prjList){
            IT_PROJECT itPrj = new IT_PROJECT();
            itPrj.OPPORTUNITY = prj.Opportunity__r.OpportunityCode__c;
            itPrj.PROJECTTYPE = prj.ProjectType__c;
            itPrj.PROJECTCODE = prj.ProjectCode__c;
            itPrj.DESCRIPTION = prj.Description__c;
            itPrj.DELETIONFLAG = prj.DeletionFlag__c == true ? 'X':'';
            itPrjList.add(itPrj);
        }
        input.IT_PROJECT = itPrjList;

        Map<String,Object> returnMap = new Map<String,Object>();
        
        if(isFuture){ //Future Method로 처리해야 할 경우 (Future Method에서 IF_Log, Approval DML처리)
            syncApproval(JSON.serialize(input));
            return null;
        } else{ //Approval__c.syncFlag__c -> 'Y'로 변경 후 return 
            returnMap.putAll(syncApproval(input));
            if(returnMap.containsKey('Response')){
                Map<String, Object> resBodyMap = (Map<String,Object>) JSON.deserializeUntyped(String.valueOf(returnMap.get('Response')));
                if(String.valueOf(returnMap.get('StatusCode')) == '200' && String.valueOf(resbodyMap.get('EV_RESULT')) == 'S'){
                    obj.syncFlag__c = 'Y';
                    returnMap.put('Approval',obj);
                }
            }
        }
        
        return returnMap;
        
        
    }
    /**
    * syncApproval Method
    * @description  Approval MISID__c 정보를 Ecc로 전송하는 Method (배치용)
    * @param        input : InputClass 
    * @return       Map<String, Object> returnMap
    **/
    @AuraEnabled
    public static Map<String,Object> syncApproval(InputClass input){
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
            'IF_Log' => null,
            'StatusCode' => null
        };

        try{
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            System.debug('request : '+resMap.get('Request'));
            System.debug('response : '+resMap.get('Response'));
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            Map<String, Object> resBodyMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            if(res.getStatusCode() == 200){
                //IF 결과
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.put('Response', res.getBody() );
            }
            else{
                returnMap.put('StatusCode','E');
            }
            returnMap.put('IF_Log',new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
        }catch(Exception e){
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('HttpResponse')),e) );
            System.debug('line : '+e.getLineNumber());
            System.debug('e : '+e);
        }
        return returnMap;
    }
    



    /**
    * syncApproval Method
    * @description  Approval MISID__c 정보를 Ecc로 전송하는 Method (화면용)
    * @param        input : InputClass 
    * @return       Map<String, Object> returnMap
    **/
    @future(callout=true)
    public static void syncApproval(String input){
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog ifLog;
        Map<String,Object> resMap = new Map<String,Object>();

        try{
            resMap = call.httpCallout(input, '');
            System.debug('request : '+resMap.get('Request'));
            System.debug('response : '+resMap.get('Response'));
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            Map<String, Object> resBodyMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            Map<String, Object> reqMap = (Map<String,Object>) JSON.deserializeUntyped(input);
            if(res.getStatusCode() == 200){
                if(String.valueOf(resbodyMap.get('EV_RESULT')) == 'S'){
                    /**V1.4 --Kajal-- Added And condition for Status__c **/
                    KnoxApproval__c approval = [SELECT id, syncFlag__c FROM KnoxApproval__c 
                                                WHERE MISID__c =: String.valueOf(reqMap.get('IV_OBJECTKEY'))
                    AND Opportunity__r.CompanyCode__c =: String.valueOf(reqMap.get('IV_BUKS')) AND Status__c = '1'];
                    if(approval.syncFlag__c != 'Y'){
                        approval.syncFlag__c = 'Y';
                        update approval;
                    }
                }
            }
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        }catch(Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('HttpResponse')),e);
            System.debug('line : '+e.getLineNumber());
            System.debug('e : '+e);
        }
        IF_Log log = new IF_Log();
        ifLog.ApexName = 'Batch_EccUpdateStatusController_Future';
        log.createLog(ifLog);
    }

    public void finish(Database.BatchableContext bc) {
        //로그 생성 -> Trigger 에서 Batch 호출로 인해 Chain 처리        
        try{
            IF_Log log = new IF_Log();
            log.createLog(ifLogList);
            
            if(approvalList.size()>0) update approvalList;
            List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_EccUpdateStatusController'];
            for(CronTrigger obj : schJobList){
                System.abortJob(obj.id);
            }
            //String hour = String.valueOf(Datetime.now().hour()+1);
            
            //IF-135 배치 종료후, 10분후 다시 IF-135 배치 수행.
            Integer iMin = Datetime.now().minute() + 5;
            if(iMin >= 60) iMin -=60;
            String min = String.valueOf(iMin);
            System.schedule('Batch_EccUpdateStatusController', '0 '+min+' * * * ? *' , new Batch_EccUpdateStatusController());

            /*
            if(querySize > Integer.valueOf(limitNo) ){
                system.debug('----------------- batch recursion');
                database.executeBatch(new Batch_EccUpdateStatusController(lastId));
            }
            else{
                List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_EccUpdateStatusController'];
                for(CronTrigger obj : schJobList){
                    System.abortJob(obj.id);
                }
                //String hour = String.valueOf(Datetime.now().hour()+1);
                System.schedule('Batch_EccUpdateStatusController', '0 1 * * * ? *' , new Batch_EccUpdateStatusController('') );
            }
            */

        }catch(Exception e){
            System.debug('e : '+e);
            System.debug('e.stack trace'+e.getStackTraceString());
            System.debug('e.Line : '+e.getLineNumber());
        }
    }

    public void execute(SchedulableContext sc) {
        system.debug('### Batch_EccUpdateStatusController :: Scheduler :: execute'); 
        database.executebatch(new Batch_EccUpdateStatusController(), 20);
    }
    

    public class InputClass{

        @AuraEnabled
        public String IV_WFOBJECT;      // 결재유형코드
        @AuraEnabled
        public String IV_OBJECTKEY;     // 트랙젠션 ID
        @AuraEnabled
        public String IV_ZZORDER_ID;    // BO 코드
        @AuraEnabled
        public String IV_PROCESS_TYPE;  // 액티비티 ID
        @AuraEnabled
        public String IV_BUKS;          // 회사코드
        @AuraEnabled
        public String IV_STATUS;        // 결재상태
        @AuraEnabled
        public List<IT_PROJECT> IT_PROJECT;
    }
    public class IT_PROJECT{
        @AuraEnabled
        public String OPPORTUNITY;
        @AuraEnabled
        public String PROJECTTYPE;
        @AuraEnabled
        public String PROJECTCODE;
        @AuraEnabled
        public String DESCRIPTION;
        @AuraEnabled
        public String DELETIONFLAG;
    }

}