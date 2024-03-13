/**
* @description       : 
* @author            : saurav.k@partner.samsung.com
* @group             : 
* @last modified on  : 2023-07-14
* @last modified by  : saurav.k@partner.samsung.com
* Modifications Log 
* Ver   Date         Author                         Modification
* 1.0   2020-12-01   saurav.k@partner.samsung.com   Initial Version
**/
@isTest()
public class ReferenceReportDashboardTrigger_test {
    
    static testMethod void testRefController() {
        TriggerSwitch__c tr = new TriggerSwitch__c();
        tr.All__c = True;
        insert tr;
        ReferenceReportDashboard__c ref_Board = new ReferenceReportDashboard__c();
        ref_Board.Name = 'Admin Only-001';
        ref_Board.Information__c = 'Admin Only';
        ref_Board.Type__c = 'Report';
        ref_Board.Shared_Range__c = '1';
        insert ref_Board;
        
        
    }
}