/**
 * @description       : Company Average Login Generator
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-22
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-09-22   vikrant.ks@samsung.com   Initial Version(MySales 303)
**/
public class CompanyAverageLoginGeneratorController {
    
    @AuraEnabled
    public static Id executeBatchJob(String month,String year,String recordType,List<String> company,List<String> profile){
        Id batchJobId = Database.executeBatch(new Batch_CompanyAverageLoginGenerator(month,year,recordType,new Set<String>(company),new Set<String>(profile)),200);
        return batchJobId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }
}