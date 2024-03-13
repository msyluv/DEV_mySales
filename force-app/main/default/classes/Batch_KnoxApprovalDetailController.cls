/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 10-23-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Execute Script Code : database.executebatch(new Batch_KnoxApprovalDetailController(), 20);
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-18-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   02-09-2021   soohong0.kim@partner.samsung.com   Start Query Paging 처리 및 Finish recursion 처리 ( KnoxApproval__c 레코드 사이즈가 많을것으로 예상되어 Paging 처리 함)
 * 1.2   03-05-2021   kilhwan.an@partner.samsung.com     querySize 계산, 마이그 제외 조건 추가
 * 1.3   03-26-2021   soohong0.kim@partner.samsung.com   getDetail Method Parameter 변경 (KnoxApproval__c 의 ID 추가)
 * 1.4   04-13-2021   kilhwan.anpartner.samsung.com      마이그 조건 제외추가
 * 1.5   04-20-2021   hyojinn.lee@partner.samsung.com    Utils.sleep System.isBatch() 조건 추가
 * 1.6   05-09-2022   kj78.yu@partner.samsung.com        20건 수행후 배치 재등록 기능 삭제. 일괄 조회후 20건씩 execute batch(일반적 방식)으로 변경.
 * 1.7   2022-08-01   hyunhak.roh@dkbmc.com				 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
 * 1.8   10-23-2023   anish.jain@partner.samsung.com     MS-318
**/
public class Batch_KnoxApprovalDetailController implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts, schedulable {
    private static final String INTERFACE_ID = 'IF-133';
    private static final String APEX_CLASS   = 'Batch_KnoxApprovalDetailController';
    private static final String METHOD_NAME  = 'getDetail';
    public IF_Log.InterfaceLog ifLog;
    List<KnoxApprover__c> approverList;
    List<KnoxApproval__c> approvalList;
    List<IF_Log.InterfaceLog> ifLogList;
    private static String guId = IF_Util.generateGuid();
    
    public Batch_KnoxApprovalDetailController(){
        system.debug('### Batch_KnoxApprovalDetailController :: constructor ');        
        approverList = new List<KnoxApprover__c>();
        approvalList = new List<KnoxApproval__c>();
        ifLogList = new List<IF_Log.InterfaceLog>();
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        Set<String> actList = OpportunityActivityHelper.OPPACT_TARGET_SET_IF135;
        /*
        if(lastId == ''){
            //query = 'SELECT id, Status__c, MISID__c FROM KnoxApproval__c where ( OpportunityActivity__r.TransactionName__c NOT IN (\'ZP32\', \'ZP62\', \'ZP82\', \'ZPG1\') and MISID__c != null and Status__c != \'2\' ) or ( OpportunityActivity__r.TransactionName__c IN (\'ZP32\', \'ZP62\', \'ZP82\', \'ZPG1\') and syncFlag__c = \'Y\' and MISID__c != null and Status__c != \'2\' ) order by id asc limit '+limitNo;
            query = 'SELECT id, Status__c, MISID__c FROM KnoxApproval__c where ( ( OpportunityActivity__r.TransactionName__c NOT IN: actList and syncFlag__c != \'S\' and MISID__c != null and Status__c != \'2\' ) or ( OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'Y\' and MISID__c != null and Status__c != \'2\' ) ) and OriginKnoxApproval__c = null ';
        } 
        else{
            //query = 'SELECT id, Status__c, MISID__c FROM KnoxApproval__c where ( OpportunityActivity__r.TransactionName__c NOT IN (\'ZP32\', \'ZP62\', \'ZP82\', \'ZPG1\') and MISID__c != null and Status__c != \'2\' ) or ( OpportunityActivity__r.TransactionName__c IN (\'ZP32\', \'ZP62\', \'ZP82\', \'ZPG1\') and syncFlag__c = \'Y\' and MISID__c != null and Status__c != \'2\' ) and id >: lastId order by id asc limit '+limitNo;
            query = 'SELECT id, Status__c, MISID__c FROM KnoxApproval__c where ( ( OpportunityActivity__r.TransactionName__c NOT IN: actList and syncFlag__c != \'S\' and MISID__c != null and Status__c != \'2\' ) or ( OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'Y\' and MISID__c != null and Status__c != \'2\' ) ) and OriginKnoxApproval__c =null and id >: lastId ';
        }
		*/
        
        query = 'SELECT id, Status__c, MISID__c FROM KnoxApproval__c where ( ( OpportunityActivity__r.TransactionName__c NOT IN: actList and syncFlag__c != \'S\' and MISID__c != null and Status__c != \'2\' ) or ( OpportunityActivity__r.TransactionName__c IN: actList and syncFlag__c = \'Y\' and MISID__c != null and Status__c != \'2\' ) ) and OriginKnoxApproval__c = null ';
        //2022-08-01, hyunhak.roh@dkbmc.com, 'X' flag에 대한 로직 추가 : IF-133, IF-093 대상으로 잡히지 않도록 확인 및 조치
        query += ' AND syncFlag__c != \'X\' ';        
        query += ' AND CreatedDate = LAST_N_DAYS:30 ';
        query += ' AND Opportunity__c != null And OpportunityActivity__c != null '; //2021.07.05 seonju.jin / Opportunity, OpportunityActivity 없는경우 제외
        query += ' AND Opportunity__r.StageName != \'Z08\' ';                       //2021.07.05 seonju.jin / Cleansed 데이터 제외
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
        query += ' ORDER BY ExecutionTime__c ASC nulls first LIMIT 160'; //Added by Anish - v 1.8
        //query += ' ORDER BY Id, CreatedDate ASC LIMIT '+limitNo;  
        
        system.debug('### Batch_KnoxApprovalDetailController :: start :: query = ' + query);

        return DataBase.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<KnoxApproval__c> objList) {        
        system.debug('### Batch_KnoxApprovalDetailController :: execute :: objList = ' + objList);
        
        String guId;
        Map<String,Object> resMap = new Map<String,Object>();
        try{
            for(KnoxApproval__c obj : objList){
                guId = IF_Util.generateGuid();
                InputClass input = new InputClass();
                input.apInfId = obj.MISID__c;
                
                resMap = getDetail(input, obj.id);
                
                //DML은 Finish 에서 처리
                if(resMap.get('Approval') != null){
                    obj.Status__c =  ((KnoxApproval__c) resMap.get('Approval')).Status__c;
                   ((KnoxApproval__c) resMap.get('Approval')).ExecutionTime__c = System.Now();  //Added by Anish - v 1.8
                    approvalList.add( (KnoxApproval__c) resMap.get('Approval') );
                } 
                
                if(resMap.get('Approver') != null) approverList.addAll( (List<KnoxApprover__c>) resMap.get('Approver') );
                //if(resMap.get('IF_Log') != null) ifLogList.add( (IF_Log.InterfaceLog) resMap.get('IF_Log') );
                if(resMap.get('IF_Log') != null) ifLogList.addAll( (List<IF_Log.InterfaceLog>) resMap.get('IF_Log') );
           }
        }catch(Exception e){
            ifLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')),e));
        }
    }

    /**
	* getDetail Method
    * @description  Approval Detail 정보를 조회하는 Method
    * @param        input : InputClass 
    * @return       Map<String, Object> returnMap
	**/
    @AuraEnabled
    public static Map<String,Object> getDetail(InputClass input, String sfdcId){
        //Log list
        List<IF_Log.InterfaceLog> chkIfLogList = new List<IF_Log.InterfaceLog>();
        
        //기안자 정보
        List<KnoxApprover__c> knoxAprList = [
            SELECT  Id, Employee__c, Employee__r.EvUniqID__c, Employee__r.Knox_Server_Location__c
            FROM    KnoxApprover__c 
            WHERE   KnoxApproval__c  = :sfdcId
            AND     ApproverType__c  = '0'
            LIMIT   1
        ];

        //기안자의 Location 정보. Location 정보에 따라 Knox 결재 Server 호출 지역이 변경됨.
        if( knoxAprList.size() > 0){
            input.serverlocation = knoxAprList.get(0).Employee__r.Knox_Server_Location__c;
            if(input.serverlocation == null) input.serverlocation = 'KR';
        }else {            
            input.serverlocation = 'KR';
        }
        //탐색할 Location 정보. Emp 기준으로 Location 탐색함. Emp 정보에 Location 정보가 정확하지 않아 실패시 다른 Location 탐색.        
        Map<String, String> mapLinkedLoc = new Map<String, String> {'KR' => 'US', 'US' => 'GB','GB' => 'KR'};
        
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
            'Approval' => null,
            'Approver' => null,
            'IF_Log' => null,
            'StatusCode' => null
        };
               
        List<KnoxApproval__c> approval = [Select id, Status__c from KnoxApproval__c where id =: sfdcId limit 1];
        
        Boolean isBreak = false;	//IF 성공시(Location 찾았을시) Loop 중지.         
        
        try{            
            for(Integer i = 0 ; i < mapLinkedLoc.size() ; i++){
                List<KnoxApprover__c> approverList = new List<KnoxApprover__c>(); 
                
                system.debug('### Batch_KnoxApprovalDetailController :: getDetail :: serverlocation = ' + input.serverlocation);
                
                String jsonBody = JSON.serialize(input);
                if(System.isBatch()) Utils.sleep(500);
                resMap = call.httpCallout(jsonBody, '');
                System.debug('### Batch_KnoxApprovalDetailController :: getDetail :: request : '+resMap.get('Request'));
                System.debug('### Batch_KnoxApprovalDetailController :: getDetail :: response : '+resMap.get('Response'));
                
                HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
                if(res.getStatusCode() == 200){
    
                    returnMap.put('StatusCode',res.getStatusCode());
                    Map<String,Object> dataMap = (Map<String,Object>) ( (Map<String,Object>) JSON.deserializeUntyped(res.getBody()) ).get('data') ;
                    //IF 결과 Status
                    returnMap.put('result',  ( (Map<String,Object>) JSON.deserializeUntyped(res.getBody()) ).get('result') );
                    
                    //KnoxApproval__c.status__c 필드 매핑 처리
                    if(String.valueOf(returnMap.get('result')) == 'success' ){
                        //List<KnoxApproval__c> approval = [Select id, Status__c from KnoxApproval__c where id =: sfdcId limit 1];
                        if(dataMap.get('status') != null && approval.size()>0 ){
                            approval[0].Status__c = String.valueOf(dataMap.get('status'));
                            returnMap.put('Approval',approval[0]);
                        }
    
                        for(Object aplns : (List<Object>) dataMap.get('aplns')){
                            Map<String,Object> aplnsMap = (Map<String,Object>) aplns;
                            KnoxApprover__c approver = new KnoxApprover__c();
                            String strDlgAprEpid = ''; 		//대리결재자 Epid
                            if(aplnsMap.get('actPrssDt') != null)         approver.actPrssDt__c           = Util_String.convertStringDateTime( String.valueOf(aplnsMap.get('actPrssDt')) );
                            if(aplnsMap.get('docOpenDt') != null)         approver.docOpenDt__c           = Util_String.convertStringDateTime( String.valueOf(aplnsMap.get('docOpenDt')) );
                            if(aplnsMap.get('docArvDt') != null)          approver.docArvDt__c            = Util_String.convertStringDateTime( String.valueOf(aplnsMap.get('docArvDt')) );
                            if(aplnsMap.get('opinion') != null)           approver.Opinion__c             = String.valueOf(aplnsMap.get('opinion'));
                            if(aplnsMap.get('epId') != null)              approver.EvUniqID__c            = String.valueOf(aplnsMap.get('epId'));
                            if(aplnsMap.get('emailAddress') != null)      approver.EvMailAddr__c          = String.valueOf(aplnsMap.get('emailAddress'));
                            if(aplnsMap.get('seq') != null)               approver.Index__c               = Integer.valueOf( aplnsMap.get('seq') );
                            if(aplnsMap.get('role') != null)              approver.ApproverType__c        = String.valueOf(aplnsMap.get('role'));
                            if(aplnsMap.get('aplnStatsCode') != null)     approver.Status__c              = String.valueOf(aplnsMap.get('aplnStatsCode'));
                            if(aplnsMap.get('arbPmtYn') != null)          approver.IsArbitraryDecision__c = String.valueOf(aplnsMap.get('arbPmtYn')) == 'Y' ? true : false;
                            if(aplnsMap.get('aplnMdfyPmtYn') != null)     approver.IsChangeLine__c        = String.valueOf(aplnsMap.get('aplnMdfyPmtYn')) == 'Y' ? true : false;
                            if(aplnsMap.get('contentsMdfyPmtYn') != null) approver.IsEditText__c          = String.valueOf(aplnsMap.get('contentsMdfyPmtYn')) == 'Y' ? true : false;
                            if(aplnsMap.get('name') != null)              approver.Name                   = String.valueOf(aplnsMap.get('name'));
                            //결재 라인에 대리 결재자 추가로, 동일 결재자가 2명이 되는 경우 발생하는 에러방지를 위해 ExternalId__c 값에 추가.
                            if(aplnsMap.get('dlgAprEpid') != null)        strDlgAprEpid                   = '_' + String.valueOf(aplnsMap.get('dlgAprEpid'));	
                            if(approval.size()>0) approver.KnoxApproval__c = approval[0].id;
                            approver.ExternalId__c = String.valueOf(dataMap.get('apInfId'))   + '_' + String.valueOf(aplnsMap.get('epId')) + strDlgAprEpid;
                            approverList.add(approver);
                        }
                        returnMap.put('Approver',approverList);
                        chkIfLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
                        
                        isBreak = true;
                    }else{	//IF return 값이 Success 가 아닐시.
                        chkIfLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
                    }
                }else{	//getStatusCode, 200 아닌 경우                
                    chkIfLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
                }
                
                if(isBreak)	break;
                
                //Location 정보를 변경.
                String strNextLoc = mapLinkedLoc.get(input.serverlocation);            
                input.serverlocation = strNextLoc;
            }            
        }catch(Exception e){
            chkIfLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), resMap.get('Exception') +'|' + String.valueOf(resMap.get('Response')),e) );
            System.debug('line : '+e.getLineNumber());
            System.debug('e : '+e);
        }
        
        returnMap.put('IF_Log', chkIfLogList);        
        
        return returnMap;
    }

    public void finish(Database.BatchableContext bc) {
        //로그 생성 -> Trigger 에서 Batch 호출로 인해 Chain 처리
        system.debug('### Batch_KnoxApprovalDetailController :: execute :: finish ');
        
        
        try{
            if(approvalList.size()>0) Database.Update(approvalList, false);
            if(approverList.size()>0){
                Schema.SObjectField keys = KnoxApprover__c.Fields.ExternalId__c;
                Database.upsert(approverList, keys, false);
            }
            
            //Batch Chain -> Next IF-093
            database.executeBatch(new Batch_EccPaymentChangeController(), 10);
            
            //IF-133 배치가 수행중이면 강제 종료.
            List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_KnoxApprovalDetailController'];
            for(CronTrigger obj : schJobList){
                System.abortJob(obj.id);
            }
            
            //IF-133 배치 종료후, 10분후 다시 IF-133 배치 수행.
            Integer iMin = Datetime.now().minute() + 5;
            if(iMin >= 60) iMin -=60;
            String min = String.valueOf(iMin);
            System.schedule('Batch_KnoxApprovalDetailController', '0 '+min+' * * * ? *' , new Batch_KnoxApprovalDetailController());
            
        }catch(Exception e){
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.stackTrace : '+e.getStackTraceString());
            system.debug('e.getMessage : '+e.getMessage());
            ifLogList.add(new IF_Log.InterfaceLog(INTERFACE_ID, IF_Util.generateGuid(), APEX_CLASS, METHOD_NAME, '', '',e));
        }finally{            
            System.debug('### Batch_KnoxApprovalDetailController, ifLogList : ' + ifLogList); 
            
            new IF_Log().createLog(ifLogList);            
        }
    }

    public void execute(SchedulableContext sc) {
        database.executebatch(new Batch_KnoxApprovalDetailController(), 20);
    }
    
    public class InputClass{
        @AuraEnabled
        public String apInfId;
        @AuraEnabled
        public String serverlocation;
    }
}