/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-09
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-04-01   raeganja@partner.samsung.com   Initial Version
 * 1.0   2020-12-22   kilhwan.an@partner.samsung.com  INTERFACE_ID2=> INTERFACE_ID 필드명 변경
**/
global class Batch_CoCostCenterHieraController implements DataBase.Batchable<sObject>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable {
    private static final String INTERFACE_ID = 'IF-062';//Team 부서장 정보 가져오기
    private static final String APEX_CLASS   = 'Batch_CoCostCenterHieraController';
    private static final String METHOD_NAME  = 'Batch';


    private static final Boolean DEBUG_FLAG  = true;
    
    private Date  BATCH_CONDITION = null; // 배치 처리 조건

    private static integer i = 0;
    private static Integer batchSize = 0;

    private static String guId = IF_Util.generateGuid();

    public Batch_CoCostCenterHieraController() { }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String queryString;
        Database.QueryLocator returnScope;

        try {          
            queryString =   'SELECT ' + 
                            ' Id, ' + 
                            ' Name, ' + 
                            ' CompanyCode__c, ' +                             
                            ' CostCenter__c, ' + 
                            ' CostCenterName__c, ' + 
                            ' ClosingDate__c, ' + 
                            ' Node1__c, ' + 
                            ' Node2__c, ' + 
                            ' Node3__c, ' +  
                            ' Node4__c, ' +  
                            ' Node5__c, ' +  
                            ' Text1__c, ' +  
                            ' Text2__c, ' +  
                            ' Text3__c, ' +  
                            ' Text4__c, ' +  
                            ' Text5__c, ' + 
                            ' IsDeleted, ' +  
                            ' CreatedById, ' +  
                            ' CreatedDate, ' + 
                            ' LastModifiedById, ' +
                            ' LastModifiedDate ' +
                            'FROM CostCenter__c '; 


            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                            
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch(Exception e){
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }

        return returnScope;
    }    

    public void execute(DataBase.BatchableContext BC, List<CostCenter__c> selectList){
        
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        String reqMsg = '';
        String resMsg = '';

        ifExcuteLog.addLog('처리 대상 : ' + selectList.size());

        try {
            
            // 데이터 처리
            //Dept Manager 업데이트를 위한 추가 변수
            Map<String, Object> costCenterListMap   = new Map<String, Object>();            
            List<Object>        costCenterDataList  = new List<Object>();

            // Request Data 만들어서 Callout 호출하기
            for (CostCenter__c costCenterData : selectList) {
                //Dept Manager 업데이트를 위한 추가 로직                
                if(costCenterData.CostCenterName__c != null && !costCenterData.CostCenterName__c.startsWith('[CLSD') && !costCenterData.CostCenterName__c.startsWith('[Delete') && !costCenterData.CostCenterName__c.startsWith('[Temp') 
                && !costCenterData.CostCenterName__c.startsWith('[계획') && !costCenterData.CostCenterName__c.startsWith('[구코드') && !costCenterData.CostCenterName__c.startsWith('[더미')
                && !costCenterData.CostCenterName__c.startsWith('[페쇄') && !costCenterData.CostCenterName__c.startsWith('[폐쇄') && !costCenterData.CostCenterName__c.startsWith('(Mig)')){
                    Map<String, Object> costCenterMap   = new Map<String, Object>();

                    costCenterMap.put('KOSTL', costCenterData.CostCenter__c);

                    costCenterDataList.add(costCenterMap);
                }
            }

            //Dept Manager 업데이트를 위한 추가 로직
            costCenterListMap.put('IT_KOSTL_INFO', costCenterDataList);
            String costCenterJosnData = JSON.serialize( costCenterListMap);

            if (DEBUG_FLAG) ifExcuteLog.addLog('전송 데이터 Create' + ' / [' + i + '] ' + costCenterListMap);
            if (DEBUG_FLAG) ifExcuteLog.addLog('전송 데이터.Size()' + ' / [' + i + '] ' + costCenterDataList.size());            
            system.debug('전송 데이터 Create' + ' / [' + i + '] ' + costCenterListMap);
            system.debug('JSON.serialize(outHeader) : ' + JSON.serialize(costCenterListMap));
       
            // Callout 처리 
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            //OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifExcuteLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');            

            Map<String, Object> result = ifCallout.httpCallout(costCenterJosnData, '');
            // ifExcuteLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            if (DEBUG_FLAG) ifExcuteLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            if (DEBUG_FLAG) ifExcuteLog.addLog('Message : '     + String.valueOf(result.get('Message')));
        
            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('Response Body : ' + hRes.getBody());

                Map<String,Object>     returnMap = (Map<String,Object>) JSON.deserializeUntyped(hRes.getBody());
                List<Object>           dataList  = new List<Object>();
                Object                 mngInfoObj= returnMap.get('ET_MANAGER_INFO');
                Map<String,Object>     ctMap     = (Map<String,Object>)JSON.deserializeUntyped( costCenterJosnData);
                List<Object>           ctCenterLt= (List<Object>)ctMap.get( 'IT_KOSTL_INFO');
                if( mngInfoObj != null) dataList = (List<Object>)mngInfoObj;


                // if(dataList != null){
                    Map<String, Object> costCenterMap  = new Map<String, Object>();
                    Map<String, Id>     empMap         = new Map<String, Id>();
                    Set<String> costCenterSet          = new Set<String>();//Cost Center Set
                    Set<String> managerNoSet           = new Set<String>();//부서장 사번 Set
                    for(Object obj : dataList){
                        Map<String,Object> objMap = (Map<String,Object>) obj;

                        String evKostl = objMap.get('EV_KOSTL') + '';
                        // costCenterSet.add(evKostl);

                        String managerNo = String.valueOf(Util_String.nvlInt(objMap.get('EV_MANAGER_NO') + ''));
                        managerNoSet.add(managerNo);

                        costCenterMap.put(evKostl, objMap);
                    }
                    
                    for( Object ctCenterObj : ctCenterLt){

                        costCenterSet.add( ((Map<String, Object>)ctCenterObj).get( 'KOSTL') + '');
                    }

                    //Employee List 조회
                    List<Employee__c> empList = [Select Id, Name, EvSapEmpNO__c, EvKostl__c From Employee__c Where EvSapEmpNO__c IN :managerNoSet];

                    for(Employee__c emp : empList){
                        empMap.put(emp.EvSapEmpNO__c, emp.Id);
                    }

                    //CostCenter List 조회
                    List<CostCenter__c> costCenterList = [Select Id, Name, CostCenter__c, DeptManager__c From CostCenter__c Where CostCenter__c IN :costCenterSet];

                    //Dept Manager Update
                    for(CostCenter__c costCenter : costCenterList){

                        Object objCostMap = costCenterMap.get( costCenter.CostCenter__c);
                        Id     evManageId = null;
                        if( objCostMap != null){

                            Map<String,Object> objCostCenterMap = (Map<String,Object>) objCostMap;
                            Object evManageObj = objCostCenterMap.get( 'EV_MANAGER_NO');
                            evManageId  = empMap.get( Util_String.nvlInt( evManageObj) + '');
                        }
                        costCenter.DeptManager__c =  evManageId;                        
                    }

                    update costCenterList;
                // }

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, costCenterDataList.size());
            }else{
                ifExcuteLog.addLog('Webservice call exception : ' + String.valueOf(result.get('Message')));
                excuteErrorMsgList.add('Webservice call exception : ' + String.valueOf(result.get('Message')));

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }
        } catch (Exception e) {
            ifExcuteLog.addLog( 'Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Batch exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', APEX_CLASS + ' 호출', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            
        }

        ifExcutelog.createLog(batchExcuteLog);
    }

    public void finish(DataBase.BatchableContext BC){
        
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }

    // 스케줄 호출
    public void execute( SchedulableContext SC){

        DataBase.executeBatch( new Batch_CoCostCenterHieraController(), 500);
    } 
}