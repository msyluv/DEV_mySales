/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-11-28
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-23-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   11-28-2020   kilhwan.an@partner.samsung.com
 * - Trigger 실행시 Rest Api 호출
 * - 처리조건 확인 필요
 * - 입력 일시 Format 확인 필요 : 20121223235959
 * - Opportunity 아래의 Account 목록(??)
 **/
global class Batch_ApsOpptyCopyController implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private static final String INTERFACE_ID = 'IF-094';
    private static final String APEX_CLASS   = 'Batch_ApsOpptyCopyController';
    private static final String METHOD_NAME  = 'Batch';

    // private IF_Log.BatchLog batchLog     = null;
    // private IF_Log ifLog = new IF_Log();

    private static final Boolean DEBUG_FLAG  = true;

    String guId = IF_Util.generateGuid();

    IF_Log iflog = new IF_Log();
    IF_Log.BatchLog batchLog;
    List<String> errorMsgList = new List<String>();        

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String queryString;

        try {
            queryString =   'SELECT ' + 
                                    ' Id, ' + 
                                    ' OwnerId, ' + 
                                    ' Name, ' + 
                                    ' StageName, ' +  
                                    ' Type, ' +  
                                    ' LogisticsCustomerType__c, ' +  
                                    ' cRevenueStartDate__c, ' +  
                                    ' cRevenueEndDate__c, ' +  
                                    ' IsDeleted, ' +  
                                    ' CreatedById, ' +  
                                    ' CreatedDate, ' + 
                                    ' LastModifiedById, ' +
                                    ' LastModifiedDate ' +
                            'FROM Opportunity ';

            if (DEBUG_FLAG) ifLog.addLog(queryString);
            if (DEBUG_FLAG) ifLog.addLog('처리 대상 조회');
            system.debug('처리 대상 조회');

            // batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Start', 0);
        }catch(Exception e){
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Start', 0, 0, e);
        }

        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> objList) {
        system.debug('raw data size : '+objList.size());
        sendOpportunity( JSON.serialize( objList));
        // try{        
        //     IF_Callout call = new IF_Callout(INTERFACE_ID);
        //     for(Opportunity obj : objList){
        //         InputClass input = new InputClass();

        //         input.PRVS_ID = obj.id;
        //         input.USER_ID = obj.OwnerId;
        //         input.BIZ_OPTNT_NM = obj.Name;
        //         input.PRVS_SCD = obj.StageName;
        //         input.APS_BIZ_CCD = obj.Type;
        //         input.SHPR_CCD = obj.LogisticsCustomerType__c;
        //         input.CNTRT_STAT_DATE = String.valueOf(obj.cRevenueStartDate__c);
        //         input.CNTRT_END_DATE = String.valueOf(obj.cRevenueEndDate__c);
        //         input.DEL_YN = String.valueOf(obj.IsDeleted);
        //         input.INS_PERSON_ID = obj.CreatedById;
        //         input.INS_DTM = String.valueOf(obj.CreatedDate);
        //         input.UPD_PERSON_ID = obj.LastModifiedById;
        //         input.UPD_DTM = String.valueOf(obj.LastModifiedDate);

        //         String jsonBody = JSON.serialize(input);
        //         Map<String,Object> resMap = call.httpCallout(jsonBody, '');
        //     }
        //     batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', objList.size());
        // }catch(Exception e){
        //     batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', 0, 0, e);    
        // }
        // ifLog.createLog( batchLog);
    }

    global void finish(Database.BatchableContext bc) {
        ifLog.createLog( batchLog);
    }

    global void execute(SchedulableContext sc) {
        database.executebatch(new Batch_ApsOpptyCopyController(), 100);
    }


    /**
    * @description Opportunity 데이터 전송
    * @author kilhwan.an@partner.samsung.com | 2020-11-28 
    * @param jsonData 
    **/
    global void sendOpportunity( String jsonData){

        try{        
            IF_Callout        call    = new IF_Callout(INTERFACE_ID);
            List<Opportunity> objList = ( List<Opportunity>)JSON.deserialize( jsonData, List<Opportunity>.class);


            // EPID 확인
            // Map<String, User> uMap = new Map<String, User>();

            Set<Id> userIdSet = new Set<Id>();
            for( Opportunity obj : objList){

                userIdSet.add( obj.OwnerId);
                userIdSet.add( obj.CreatedById);
                userIdSet.add( obj.LastModifiedById);
            }

            // 사용자 정보 Knox EPID 확인
            Map<Id, User> userMap = new Map<Id, User>([

                SELECT Id
                     , FederationIdentifier 
                FROM   User
                WHERE  Id IN :userIdSet
            ]);

            
            for(Opportunity obj : objList){

                InputClass input = new InputClass();

                input.PRVS_ID        = obj.id;                              // PRSID
                input.USER_ID        = userMap.get( obj.OwnerId).FederationIdentifier; // Knox EPID    ** 
                input.BIZ_OPTNT_NM   = obj.Name;                            // 사업기회명
                input.PRVS_SCD       = obj.StageName;                       // PRS상태코드
                input.APS_BIZ_CCD    = obj.Type;                            // APS사업구분코드 
                input.SHPR_CCD       = obj.LogisticsCustomerType__c;        // 화주구분코드 **
                input.CNTRT_STAT_DATE= String.valueOf(obj.cRevenueStartDate__c); // ??
                input.CNTRT_END_DATE = String.valueOf(obj.cRevenueEndDate__c);   // ??
                input.DEL_YN         = String.valueOf(obj.IsDeleted);
                input.INS_PERSON_ID  = userMap.get( obj.CreatedById).FederationIdentifier;      // 입력자ID : Knox EPID **
                input.INS_DTM        = String.valueOf(obj.CreatedDate);     // 입력일시  ??=> 20121223235959
                input.UPD_PERSON_ID  = userMap.get( obj.LastModifiedById).FederationIdentifier; // 수정자ID : Knox EPID **
                input.UPD_DTM        = String.valueOf(obj.LastModifiedDate);// 수정일시  ??=> 20121223235959

                //String jsonBody = JSON.serialize(input);
                //Map<String,Object> resMap = call.httpCallout(jsonBody, '');
            }

            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', objList.size());
        }catch(Exception e){
            batchLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Batch Excute', 0, 0, e);    
        }        
    }

    global class InputClass{
        public String PRVS_ID;
        public String USER_ID;
        public String BIZ_OPTNT_NM;
        public String PRVS_SCD;
        public String APS_BIZ_CCD;
        public String SHPR_CCD;
        public String CNTRT_STAT_DATE;
        public String CNTRT_END_DATE;
        public String DEL_YN;
        public String INS_PERSON_ID;
        public String INS_DTM;
        public String UPD_PERSON_ID;
        public String UPD_DTM;
    }

}