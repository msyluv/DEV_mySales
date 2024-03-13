/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-30
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-01-04   ghkil@partner.samsung.com         Initial Version
 * 1.1   2021-01-14   ghkil@partner.samsung.com         금액(Decimal Type) 표기 과학적(지수)표기 되지 않도록 처리
 * 1.2   2021-01-21   ghkil@partner.samsung.com         Batch 처리에 대한 Log 처리 수정 (Start, Excute, End 각각 나눠 기록)
 * 1.3   2021-02-02   ghkil@partner.samsung.com         IF-EccProjectInfoController 호출 부분 보완 (scope for문 밖에서 호출)
 * 1.4   2021-02-02   ghkil@partner.samsung.com         정의한 IV_PROCESS_TYPE값 반영
 * 1.5   2021-02-03   kilhwan.an@partner.samsung.com    batch migData__c 조건 추가
 * 1.6   2021-02-16   ghkil@partner.samsung.com         소유자 (영업 대표)의 이름을 Employee__c의 Name으로 변경
 * 1.7   2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
 * 1.8   2021-03-02   kilhwan.an@partner.samsung.com    Utils.sleep( 500);  추가
**/
// 주기 : 1시간 배치 (이전 1일치 수정된 BO 기준)
global class Batch_EccProjectInfoController implements DataBase.Batchable<SObject>, DataBase.stateful, DataBase.AllowsCallouts, Schedulable {

    private final String INTERFACE_ID = 'IF-004'; // IF-004 (IF_EccProjectInfoController을 호출하는 Batch)
    private final String APEX_CLASS   = 'Batch_EccProjectInfoController'; 
    private final String METHOD_NAME  = 'Batch';

    public static Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)

    private final Boolean DEBUG_FLAG = true;

    private Static List<Map<String, Object>> interfaceLogMapList = new List<Map<String, Object>>();

    String guId = IF_Util.generateGuid();

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        String queryString;
        Database.QueryLocator returnScope;

        // 기본 쿼리 검색
        try{

            if( BATCH_CONDITION == null) BATCH_CONDITION = Date.today().addDays( -1);

            queryString =   'Select Id ' +  	
                            '	    , OpportunityCode__c ' +                         // 사업 기회 Code
                            '	    , Name ' +                                       // 사업기회명
                            '	    , Owner.EmployeeNumber ' +                       // 소유자 (영업 대표)
                            '	    , Owner.Name ' +                                 // 소유자 (영업 대표)
                            '	    , Amount ' +                                     // 예상금액
                            '	    , CurrencyIsoCode ' +                            // 사업 기회 금액의 통화
                            '	    , CompanyCode__c ' +                             // Company Code
                            '	    , SalesDepartment__r.CostCenter__c ' +           // 수주 사업그룹 코스트센터 코드
                            '	    , cPrimarySalesDepartment__r.CostCenter__c ' +   // 주 매출 부서 코스트센터 코드
                            '       , ActivityStatus__c ' +                          
                            'From   Opportunity ' +
                            'Where  lastModifiedDate >= :BATCH_CONDITION '+
                            'AND    MigData__c        = false ';                // 마이그 대상 제외( 2021-02-03)

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
    
    public void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        try {

            // Opportunity 데이터 적재
            Map<String, Opportunity> OpportunityMap = new Map<String, Opportunity>();
            Set<String> employeeNumberSet = new Set<String>();
            for (Opportunity oppData : scopeList) {
                OpportunityMap.Put(oppData.Id, oppData);   // Opportunity 데이터
                employeeNumberSet.add(oppData.Owner.EmployeeNumber);
            }
            if (DEBUG_FLAG) ifExcuteLog.addLog('scopeList.size() : ' + scopeList.size());

            // Employee__c에서 Name 가져오기
            List<Employee__c> employeeList = [
                Select  Id
                        , Name
                        , EvEmpNo__c
                From    Employee__c
                Where   EvEmpNo__c IN :employeeNumberSet
            ];
            Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
            for (Employee__c employeeData : employeeList) {
                employeeMap.put(employeeData.EvEmpNO__c, employeeData);
            }

            // 프로젝트 정보 가져오기
            List<Project__c> projectList = [
                Select  Id
                        , Opportunity__c
                        , ProjectCode__c
                        , Name
                From    Project__c
                Where   Opportunity__c IN :OpportunityMap.keySet()
            ];
            Map<String, Project__c> projectMap = new Map<String, Project__c>();
            for (Project__c projectData : projectList) {
                projectMap.put(projectData.Opportunity__c, projectData);
            }

            // Request Data 만들어서 Callout 호출하기
            List<Map<String, Object>> outputMapList = new List<Map<String, Object>>();
            for (Opportunity oppData : scopeList) {
                Map<String, Object> outputMap = new Map<String, Object>();
                
                outputMap.put('IV_ZZORDER_ID', oppData.OpportunityCode__c);                         // B/O Code
                String ivPspid = null;
                if (projectMap.get(oppData.Id) != null) {
                    ivPspid = projectMap.get(oppData.Id).ProjectCode__c;
                }
                outputMap.put('IV_PSPID', ivPsPid);                                                 // Project Definition
                outputMap.put('IV_BUKRS', oppData.CompanyCode__c);                                  // Company Code
                outputMap.put('IV_PROCESS_TYPE', oppData.ActivityStatus__c);                        // Process type

                Map<String, Object> outputItProjMap = new Map<String, Object>();
                List<Map<String, Object>> outputDataList = new List<Map<String, Object>>();

                outputItProjMap.put('ZZORDER_ID', oppData.OpportunityCode__c);                      // 사업 기회 Code (BO코드)
                outputItProjMap.put('ZZBUKRS_H', oppData.CompanyCode__c);                           // Company Code (회사코드)
                
                outputItProjMap.put('PSPID', ivPspid);                                              // 프로젝트코드
                outputItProjMap.put('SALES_EMP_NO', oppData.Owner.EmployeeNumber);                  // 소유자 (영업 대표) (영업담당자 사번)
                String ownerName = null;
                if (employeeMap.get(oppData.Owner.EmployeeNumber) != null) {
                    ownerName = employeeMap.get(oppData.Owner.EmployeeNumber).Name;
                }                
                outputItProjMap.put('SALES_EMP_NAME', ownerName);                                   // 소유자 (영업 대표) (영업담당자 이름)
                // outputItProjMap.put('SALES_EMP_NAME', oppData.Owner.Name);                          // 소유자 (영업 대표) (영업담당자 이름)
                
                outputItProjMap.put('ZZSALES_C_NAME_M', oppData.SalesDepartment__r.CostCenter__c);  // 수주 사업그룹 코스트센터 코드 (영업수서코드)
                Decimal zzOrderAmt = 0;
                if (oppData.Amount != null) {
                    zzOrderAmt = oppData.Amount;
                }
                outputItProjMap.put('ZZORDER_AMT', zzOrderAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString());    // 예상금액 (예상수주액)

                outputDataList.add(outputItProjMap);
                outputMap.put('IT_PROJ', outputDataList);

                // // IF-004, IF_EccProjectInfoController 호출                
                // Batch_EccProjectInfoController.execCallout(JSON.serialize(outputMap), BC.getJobId());

                outputMapList.add(outputMap);
            }
            // IF-004, IF_EccProjectInfoController 호출                
            // Batch_EccProjectInfoController.execCallout(outputMapList, BC.getJobId());
            Batch_EccProjectInfoController.execCallout(outputMapList, guId);

            if (DEBUG_FLAG) ifExcuteLog.addLog('Request Data 만들어서 Callout 호출하기');

            // Callout Log 남기기
            List<IF_Log.Log> logList = new List<IF_Log.Log>();
            Integer errorCount = 0;
            List<String> errorList = new List<String>();            
            for (Map<String, Object> interfaceLog : interfaceLogMapList) {

                IF_Log.Log ifLogData = (IF_Log.Log)interfaceLog.values()[0];
                logList.add(ifLogData);

                List<IF_EccProjectInfoController.InputHeader> reponseList = new List<IF_EccProjectInfoController.InputHeader>();                
                if (ifLogData.StatusCode != 'S') {
                    errorCount ++;

                    errorList.add(  '[ ExceptionType : ' + ifLogData.ExceptionType == null || ifLogData.ExceptionType == '' ? '(없음)' : ifLogData.ExceptionType + 
                                    ' / ErrorMessage : ' + ifLogData.ErrorMessage == null || ifLogData.ErrorMessage ==  '' ? '(없음)' : ifLogData.ErrorMessage + 
                                    ' / StackTrace : ' + ifLogData.StackTrace == null || ifLogData.StackTrace == '' ? '(없음)' : ifLogData.StackTrace + 
                                    ']');
                }
            }
            IF_Log calloutIfLog = new IF_Log();
            calloutIfLog.createLog(logList);
            
            // (Batch Excute)로그 남기기 
            if (errorCount == 0) {
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'IF_EccProjectInfoController 호출',scopeList.size());
            } else {
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'IF_EccProjectInfoController 호출',scopeList.size() - errorCount, errorCount, errorList);                
            }

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);            
        } catch (Exception e) {
            ifExcuteLog.addLog( 'Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Batch exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'IF_EccProjectInfoController 호출', 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }
    
    public static void execCallout(String jsonData, String jobId){

        // new IF_EccProjectInfoController(true, jobId);

        IF_EccProjectInfoController.isBatch = true;
        IF_EccProjectInfoController.batchId = jobId;

        Map<String, Object> interfaceLogMap = IF_EccProjectInfoController.calloutProjectInfo(jsonData);

        interfaceLogMapList.add(interfaceLogMap);
    }    

    public static void execCallout(List<Map<String, Object>> outputMapList, String jobId){

        // new IF_EccProjectInfoController(true, jobId);

        IF_EccProjectInfoController.isBatch = true;
        IF_EccProjectInfoController.batchId = jobId;

        // Json 형식이 List가 아니어서 반복하여 호출하여 처리함
        for (Map<String, Object> outputMap : outputMapList) {

            Utils.sleep( 500);
            String jsonData = JSON.serialize(outputMap);
            Map<String, Object> interfaceLogMap = IF_EccProjectInfoController.calloutProjectInfo(jsonData);

            interfaceLogMapList.add(interfaceLogMap);
        }
    }   

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);


        List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_EccProjectInfoController'];
        for(CronTrigger obj : schJobList){
            System.abortJob(obj.id);
        }
        //String hour = String.valueOf(Datetime.now().hour()+1);
        System.schedule('Batch_EccProjectInfoController', '0 1 * * * ? *' , new Batch_EccProjectInfoController() );

    }

    // 스케줄 호출
    public void execute( SchedulableContext SC){

        DataBase.executeBatch( new Batch_EccProjectInfoController(), 100);
    }  
}