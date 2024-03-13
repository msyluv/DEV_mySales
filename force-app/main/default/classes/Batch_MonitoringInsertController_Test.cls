/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 10-27-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-27-2021   yeongju.baek@dkbmc.com   Initial Version
**/
@isTest(SeeAllData = false)
public class Batch_MonitoringInsertController_Test {
    static IF_Log__c log1;

    static {
        List<IF_Log__c> logList = new List<IF_Log__c>();
        log1 = new IF_Log__c(
            StartDatetime__c = Datetime.now().addDays(-3),
            EndDatetime__c = Datetime.now().addDays(-2),
            InterfaceId__c = 'IF-133',
            LogType__c = 'Interface',
            ExceptionType__c = 'System.TypeException',
            ErrorMessage__c = 'Invalid conversion from runtime type String to System.HttpResponse',
            ApexName__c = 'Batch_KnoxApprovalDetailController',
            ApexMethod__c = 'execute',
            CreatedDate = Datetime.now().addDays(-1),
            StatusCode__c = 'E'
        );
        logList.add(log1);
        insert logList;
    }
    @isTest
    public static void MonitoringInsertController_Test1(){
        Test.startTest();
        List<IF_Log__c> logList = [SELECT StartDatetime__c, EndDatetime__c, InterfaceId__c, LogType__c, ExceptionType__c, ErrorMessage__c,Name, ApexName__c, ApexMethod__c from IF_Log__c  where CreatedDate = YESTERDAY and StatusCode__c !='S'];
        System.debug('LogList@ : '+logList);
        System.debug('LogList@ : '+logList.size());
        DataBase.executeBatch( new Batch_MonitoringInsertController(), logList.size());
        
        Test.stopTest();
    }

}