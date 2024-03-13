/**
* @description       : 
* @author            : yeongju.baek@dkbmc.com
* @group             : 
* @last modified on  :  16-05-2023
* @last modified by  : saurav.k@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                        Modification 
* 1.0   10-07-2021   yeongju.baek@dkbmc.com        Initial Version
* 1.0   29-08-2022   minhye.park@dkbmc.com         Initial Version
* 1.2   19-01-2023   akash.g@samsung.com           Add Batch Name to [InterfaceId] of IF_Log(MySales-105)
* 1.3   10-04-2023   saurav.k@partner.samsung.com  Handling user inactivation related to employee deletion(MySales- 164)
* 1.4   16-05-2023   saurav.k@partner.samsung.com  Add Inactive Log to UserActive_Logs for user inactivated by leaving the company(MYSALES-203)
**/
public class Batch_UpdateEmpStateController implements Database.StateFul, Database.Batchable<sobject>, Database.AllowsCallouts , schedulable{
    
    private static final String INTERFACE_ID = 'BATCH-UPDATEEMP'; //V 1.2- MYSALES: 105
    private static final String APEX_CLASS   = 'Batch_UpdateEmpStateController'; 
    private static final String METHOD_NAME  = 'Batch';
    private static Boolean isSandbox = Utils.getIsSandbox();
    private static String guId = IF_Util.generateGuid();
    List<User> inActiveUser = new List<User>();//V 1.3- MYSALES: 164
    public Batch_UpdateEmpStateController(){}
    
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');
        
        String queryString;
        queryString = 'SELECT Id, Status__c, EvCellTel__c, EvCompTel__c,EvMailAddr__c, LastModifiedDate from Employee__c';//V 1.3- MYSALES: 164 : Addeed Email Field
        queryString += ' Where Status__c = null and LastModifiedDate < LAST_N_DAYS:5'; //2022-08-29 매일 7:00AM 최종 업데이트 기록이 5일 이전인 임직원에 대해 'R' 처리 (minhye.park@dkbmc.com)
        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
        ifStartLog.createLog(batchStartLog);
        return DataBase.getQueryLocator( queryString);
    }
    
    public void execute(Database.BatchableContext BC, List<Employee__c> scopeList){
        System.debug('scopeList___' + scopeList);
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');
        ifExcuteLog.addLog( '###################['+scopeList.size()+']################ Employee Update');
        List<Employee__c> updateList = new List<Employee__c>();
        set<string> setofScopeEmail = new Set<String>();//V 1.3- MYSALES: 164
        Integer updateEmpCount = 0;
        if(scopeList.size() > 0){
            for( Employee__c emp : scopeList){
                ifExcuteLog.addLog( 'updateEmployee Id : ' + emp.Id + ', BeforeUpdateData : '+ String.valueOf(emp));
                emp.Status__c = 'R';
                emp.EvCellTel__c = null;
                emp.EvCompTel__c = null;
                setofScopeEmail.add(emp.EvMailAddr__c);//V 1.3- MYSALES: 164
                updateList.add(emp);
                updateEmpCount += 1;
            }           
        }
        ifExcuteLog.addLog( '###################['+updateList.size()+']################ Employee Updated');
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');
        
        //create Interface Log
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
        
        if(updateList.size() > 0) update updateList;        
        /**START- V 1.3- MYSALES: 164 **/
        Set<String> setofEmployeeMail = new Set<String>();
        Map<String, List<Employee__c>> emailVSEmployeeData = new Map<String, List<Employee__c>>();           
        List<Employee__c> listofEmployee = [Select Id,EvMailAddr__c,Status__c from Employee__c Where 
                                            EvMailAddr__c != Null AND EvMailAddr__c IN : setofScopeEmail];        
        if(listofEmployee.Size()>0){
            for(Employee__c emp :listofEmployee){
                if(emailVSEmployeeData.containsKey(emp.EvMailAddr__c)) {
                    List<Employee__c> listofEmployeeId = emailVSEmployeeData.get(emp.EvMailAddr__c);
                    listofEmployeeId.add(emp);
                    emailVSEmployeeData.put(emp.EvMailAddr__c, listofEmployeeId);
                }else{
                    List<Employee__c> listofEmployeeId = new List<Employee__c>();
                    listofEmployeeId.add(emp);
                    emailVSEmployeeData.put(emp.EvMailAddr__c, listofEmployeeId);
                }
                
            }            
        }
        if(listofEmployee.size()>0) {
            for(Employee__c emp2 : listofEmployee) {
                Boolean statusN = false;
                Boolean statusR = false;
                if(emailVSEmployeeData.containsKey(emp2.EvMailAddr__c)){
                    for(Employee__c emp3 : emailVSEmployeeData.get(emp2.EvMailAddr__c)){
                        if(emp3.status__c== Null || emp3.status__c== ''){
                            statusN  = true;                        
                        }
                        else if(emp3.status__c=='R'){
                            statusR = true;                        
                        }                   
                    }
                }
                if(!statusN  && statusR){
                    setofEmployeeMail.add(emp2.EvMailAddr__c);
                } 
                
              }
        }                                                                          
        if(setofEmployeeMail.size()>0){
            List<User> listofUser = [Select Id,Email from User Where Email IN : setofEmployeeMail AND IsActive = TRUE];     
            if(listofUser.Size()>0){
                for(User record: listofUser){
                    record.IsActive = false;
                    inActiveUser.add(record);
                }
            } 
            
        }  
        /**END- V 1.3- MYSALES: 164 **/
    }
    
    public void finish(DataBase.BatchableContext BC){
         if(inActiveUser.Size()>0){     //V 1.3- MYSALES: 164
             Database.update(inActiveUser, false);
         }                              //V 1.3- MYSALES: 164
        /*Start- V 1.4- MySales: 203 */
        List<Id> idofInActiveUser = new List<Id>();
        for(User u1 : inActiveUser){
            idofInActiveUser.add(u1.Id);
        }                        
        System.enqueueJob(new userInactiveLogInsertData(idofInActiveUser));               
        /*End- V 1.4- MySales: 203 */
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifFinishLog.createLog(batchFinishLog);
    }
    
    public void execute(SchedulableContext sc){
        DataBase.executeBatch( new Batch_UpdateEmpStateController(),500 );
    }
    
}