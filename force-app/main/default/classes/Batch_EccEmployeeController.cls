/**
 * @description       : SFDC 사용자별 ECC 권한정보 제공하기
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-07-15
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-03-19   raeganja@partner.samsung.com   Initial Version
 * 1.0.1 2021-05-04   raeganja@partner.samsung.com   EvSapUsrID__c 값이 null 인것 제외
**/
global class Batch_EccEmployeeController implements DataBase.Batchable<sObject>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable{
    private final String INTERFACE_ID    = 'IF-137';
    private final String APEX_CLASS      = 'Batch_EccEmployeeController';
    private final String METHOD_NAME     = 'Batch';

    private final Boolean DEBUG_FLAG = true;

    String guId = IF_Util.generateGuid();

    integer i = 0;
    
    public Batch_EccEmployeeController() {

    }

    public DataBase.QueryLocator start(DataBase.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String queryString;
        Database.QueryLocator returnScope;

        try{
            // ↓ 2021-05-31 김경남 프로 수정 요청 전 원본
            // queryString = 'SELECT Id, UserName, EmployeeNumber, UserRole.DeveloperName, Profile.Name From User Where IsActive = true and UserRole.Name != null and EmployeeNumber != null';
            
            // 2021-05-31 / 김경남 프로 요청 / 사용자 활성여부와 상관없이 UserRole과 EmployeeNumber만 존재하면 전송하는것으로 조건 변경
            queryString = 'SELECT Id, UserName, EmployeeNumber, UserRole.DeveloperName, Profile.Name From User Where UserRole.Name != null and EmployeeNumber != null';
            if( Test.isRunningTest()) queryString += ' LIMIT 1';
            
            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch( Exception e){
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }
        
        return returnScope;
    }

    public void execute(DataBase.BatchableContext BC, List<User> scopeList){
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        String reqMsg = '';
        String resMsg = '';

        i++;

        try {

            // User EmployeeNumber 데이터 적재
            Set<String> employeeNumberSet = new Set<String>();
            Set<String> roleDevNameSet    = new Set<String>();
            for (User userData : scopeList) {
                employeeNumberSet.add(userData.EmployeeNumber);
                roleDevNameSet.add( userData.UserRole.DeveloperName);
            }

            // Role_CostCenter__c에서 CostCenter__c 가져오기
            List<Role_CostCenter__c> roleCostCenterList = [
                SELECT  Id
                       ,OwnerId
                       ,Name
                       ,CostCenter__c 
                FROM    Role_CostCenter__c
                WHERE   Name IN :roleDevNameSet
            ];
            Map<String, Role_CostCenter__c> roleCostCenterMap = new Map<String, Role_CostCenter__c>();
            for (Role_CostCenter__c roleCostCenterData : roleCostCenterList) {
                roleCostCenterMap.put(roleCostCenterData.Name, roleCostCenterData);
            }
           
            // Employee__c에서 EvSapUsrID__c 가져오기
            List<Employee__c> employeeList = [
                SELECT  Id
                       ,Name
                       ,EvSapEmpNo__c
                       ,EvSapUsrID__c
                FROM    Employee__c
                WHERE   EvSapEmpNo__c IN :employeeNumberSet
            ];
            Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
            for (Employee__c employeeData : employeeList) {
                employeeMap.put(employeeData.EvSapEmpNo__c, employeeData);
            }

            // Request Data 만들어서 Callout 호출하기
            Map<String, Object> outputHeaderMap = new Map<String, Object>();
            List<Map<String, Object>> outputDataList = new List<Map<String, Object>>();
            for (User userData : scopeList) {
                Map<String, Object> outputRoleCostCenterMap = new Map<String, Object>();

                if( !userData.EmployeeNumber.isNumeric()) continue;
                outputRoleCostCenterMap.put('IV_EMPLOYEE_NO', userData.EmployeeNumber);

                String costCenter = null;
                if (roleCostCenterMap.get(userData.UserRole.DeveloperName) != null) {
                    costCenter = roleCostCenterMap.get(userData.UserRole.DeveloperName).CostCenter__c;
                }
                outputRoleCostCenterMap.put('IV_COSTCENTER', costCenter);

                if(userData.Profile.Name == 'System Administrator' || userData.Profile.Name == '시스템 관리자' || userData.Profile.Name == 'PI (Biz. Owner)'){
                    outputRoleCostCenterMap.put('IV_GUBUN', 'A');
                } else {
                    outputRoleCostCenterMap.put('IV_GUBUN', null);
                }

                // 2021-05-04 추가
                // EvSapUsrID__c 값이 null 인것 제외하기 위한 로직 추가
                String evSapUserId = null;
                if (employeeMap.get(userData.EmployeeNumber) != null) {
                    evSapUserId = employeeMap.get(userData.EmployeeNumber).EvSapUsrID__c;
                }
                if(costCenter != null && evSapUserId != null){
                    outputDataList.add(outputRoleCostCenterMap);                
                }
            }            
            outputHeaderMap.put('IT_DATA', outputDataList);

            if (DEBUG_FLAG) ifExcuteLog.addLog('전송 데이터 Create' + ' / [' + i + '] ' + outputHeaderMap);
            if (DEBUG_FLAG) ifExcuteLog.addLog('전송 데이터.Size()' + ' / [' + i + '] ' + outputDataList.size());            
            system.debug('전송 데이터 Create' + ' / [' + i + '] ' + outputHeaderMap);
            system.debug('JSON.serialize(outHeader) : ' + JSON.serialize(outputHeaderMap));

            // Callout 처리
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            Map<String, Object> result = ifCallout.httpCallout(JSON.serialize(outputHeaderMap), '');
            if (DEBUG_FLAG) ifExcuteLog.addLog('CallOut Result' + ' / [' + i + '] ' + result);
            system.debug('CallOut Result' + ' / ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            ifExcuteLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            ifExcuteLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            Map<String, Object> resBodyMap = (Map<String,Object>) JSON.deserializeUntyped(resMsg);

            if (resStatusCode != null && resStatusCode == 200 && String.valueOf(resbodyMap.get('EV_RETURN')) == 'S') {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog('Response Body : ' + hRes.getBody());

                // recHeader = (ReceiveHeader) JSON.deserialize(hRes.getBody(), ReceiveHeader.class); 
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'Batch_EccEmployeeController 호출', outputDataList.size());
            } else {
                if(String.valueOf(resbodyMap.get('EV_RETURN')) == 'E'){
                    ifExcuteLog.addLog('Return Error : ' + String.valueOf(resbodyMap.get('EV_MSG')));
                    excuteErrorMsgList.add('Return Error : ' + String.valueOf(resbodyMap.get('EV_MSG')));
                } else {
                    ifExcuteLog.addLog('Webservice call exception : ' + String.valueOf(result.get('Message')));
                    excuteErrorMsgList.add('Webservice call exception : ' + String.valueOf(result.get('Message')));
                }
                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'Batch_EccEmployeeController 호출', 0, 0, excuteErrorMsgList);
            }
        } catch (Exception e) {
            ifExcuteLog.addLog( 'Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Batch exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', 'Batch_EccEmployeeController 호출', 0, 0, e);

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

        DataBase.executeBatch( new Batch_EccEmployeeController(), 500);
    } 
}