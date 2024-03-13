/**
* @description       : 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  :  16-05-2023
* @last modified by  : saurav.k@partner.samsung.com 
* Modifications Log 
* Ver   Date         Author                        Modification 
* 1.0   16-05-2023   saurav.k@partner.samsung.com  Add Inactive Log to UserActive_Logs for user inactivated by leaving the company(MYSALES-203)
**/
public  class userInactiveLogInsertData implements Queueable{
    private static final String INTERFACE_ID = 'Quable-UserActive_Log'; 
    private static final String APEX_CLASS   = 'userInactiveLogInsertData'; 
    private static final String METHOD_NAME  = 'Execute';
    private static String guId = IF_Util.generateGuid();
    public List<Id> idofInactiveUser = new List<Id>();
    public userInactiveLogInsertData(list<Id> idofInActiveUser){
        this.idofInactiveUser = idofInActiveUser;
        
    }
    public void execute(QueueableContext context) {
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + context + ') 시작' + ' ####################');
        ifExcuteLog.addLog( '###################['+idofInactiveUser.size()+']################ Employee Update');
        List<UserActive_Logs__c> userInActiverecInsertionList = new list<UserActive_Logs__c>();
        List<User> listofInactiveUsers =[Select Id,IsActive,CompanyCode__c,Name,Email,Username,UserRole.Name,Profile.Name,
                                         CreatedDate,CreatedById,LastModifiedDate FROM User 
                                         WHERE Id IN: idofInactiveUser];
        for(User u : listofInactiveUsers){
            UserActive_Logs__c rec = new UserActive_Logs__c();
            rec.ChangedById__c = userinfo.getUserId();
            rec.Changeddate__c = u.LastModifiedDate ;
            rec.CompanyCode__c = u.CompanyCode__c;
            rec.UserId__c = u.Id;
            rec.Name__c = u.Name;
            rec.Email__c = u.Email;
            rec.UserName__c = u.Username;
            rec.UserCreatedDate__c = u.CreatedDate;
            rec.UserCreatedById__c = u.CreatedById;
            rec.Active__c = u.IsActive;
            userInActiverecInsertionList.add(rec);
        }
        if(userInActiverecInsertionList.size()>0){
             try{
                insert userInActiverecInsertionList; 
            }
            catch(DmlException e){
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
                                                         
        }
        ifExcuteLog.addLog( '###################['+userInActiverecInsertionList.size()+']################ Employee Updated');
        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + context + ') 종료' + ' ####################');
        
        //create Interface Log
        batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
        ifExcutelog.createLog(batchExcuteLog);
    }
}