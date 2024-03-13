/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 11-02-2022
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-06-15   younghoon.kim@dkbmc.com   Initial Version
**/
global class CostCenterMergeController {
    @AuraEnabled
    global static statusCheck defaultCheck(){
        User currentUser = [SELECT Id, Name, ProfileId FROM User WHERE Id =: UserInfo.getUserId()];
        System.debug('currentUser : ' + currentUser);

        List<AsyncApexJob> apexJobList = [SELECT Id, CreatedDate, CreatedById, CreatedBy.Name, JobType, ApexClassId, ApexClass.Name, Status, JobItemsProcessed, TotalJobItems, 
                                                 NumberOfErrors, CompletedDate, MethodName, ExtendedStatus, ParentJobId, LastProcessed, LastProcessedOffset 
                                            FROM AsyncApexJob 
                                           WHERE ApexClass.Name = 'Batch_CostCenterMerge' 
                                             AND JobType = 'BatchApex'
                                             AND Status != 'Completed'
                                             AND Status != 'Aborted'
                                             AND Status != 'Failed'
                                           ORDER BY CreatedDate DESC
                                           LIMIT 1];

        List<CostCenterMerge__c> ccmList = [SELECT Id, Name, CompanyCode_AsIs__c, OpptyCode_AsIs__c, Oppty_SalesDept_ToBe__c, Oppty_DeliveryDept_ToBe__c, Project__c, ProjectCode__c, 
                                                   ProjectDescription__c, WBS__c, WBSDescription__c, Svc_SalesDept_ToBe__c, Svc_DeliveryDept_ToBe__c, ItemNumber__c, Service__c, 
                                                   Solution__c, BizAttributeCode__c, IsComplete__c, Oppty_CodeFormat_ToBe__c 
                                              FROM CostCenterMerge__c 
                                             WHERE IsComplete__c = false
                                             ORDER BY CompanyCode_AsIs__c, OpptyCode_AsIs__c, WBS__c];

        statusCheck sc = new statusCheck();
        sc.isMigUser = (currentUser.Name).contains('Mig') ? true : false;
        System.debug('sc.isMigUser : ' + sc.isMigUser);
        System.debug('(currentUser.Name).contains(\'Mig\') : ' + (currentUser.Name).contains('Mig'));
        if(apexJobList.size() > 0){
            sc.isProceeding = true;
            sc.batchSize = apexJobList[0].JobItemsProcessed > 0 ? (apexJobList[0].TotalJobItems / apexJobList[0].JobItemsProcessed) * 10 : 0;
        }else{
            sc.isProceeding = false;
            sc.batchSize = 0;
        }
        sc.targetList = ccmList.size() > 0 ? ccmList : new List<CostCenterMerge__c>();

        return sc;
    }

    @AuraEnabled
    global static void batchStart(){
        Batch_CostCenterMerge batch = new Batch_CostCenterMerge();
        Database.executeBatch(batch, 1);
    }

    global class statusCheck {
        @AuraEnabled
        global Boolean isMigUser {get; set;}
        @AuraEnabled
        global Boolean isProceeding {get; set;}
        @AuraEnabled
        global Integer batchSize {get; set;}
        @AuraEnabled
        global List<CostCenterMerge__c> targetList {get; set;}
    }
}