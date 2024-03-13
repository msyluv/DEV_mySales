/*
* @description       : 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  :  05/06/2023
* @last modified by  : saurav.k@partner.samsung.com 
* Modifications Log 
* Ver     Date             Author                         Modification 
* 1.0   05/06/2023      saurav.k@partner.samsung.com      Initial Version(Report&Dahboard Reference Page Development)-MySales -217
*/
@isTest(SeeAllData='true')
public class reportDasboardReference_test {
    @isTest
    static void testRefController() {
        User u = [Select Id,Profile.Name from user Where Profile.Name =: 'System Administrator' limit 1];
          Ref_repdash_count__c LISTcust1 = new Ref_repdash_count__c();
        LISTcust1.Name = 'Admin';  
        LISTcust1.Information_Type_count__c	= 1;
        insert LISTcust1;
        Ref_repdash_count__c settings = Ref_repdash_count__c.getInstance();
        List<Ref_repdash_count__c> LISTcust = Ref_repdash_count__c.getall().values();
        String Refernce = 'Ref\\_%';		               
        List<Report> listofReports = [SELECT Id,Name,DeveloperName,FolderName,Description,CreatedDate from Report 
                                      WHERE DeveloperName LIKE : Refernce];
        List<Dashboard> listofDashboards = [SELECT Id,Title, DeveloperName,FolderName,Description,CreatedDate from Dashboard 
                                            WHERE Folder.DeveloperName LIKE : Refernce];                
        reportDasboardReference rb = new reportDasboardReference();
        Test.startTest();
        rb.getReportRefData();
        Test.stopTest();
        
    }
}