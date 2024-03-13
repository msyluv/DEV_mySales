/**
* @description       : Test class to cover functionality of IF_DemandCallOutAPIController Apex class.
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 08-04-2022
* @last modified by  : akash.g@samsung.com
* Modifications Log 
* Ver   Date         Author                    Modification
* 1.0   08-04-2022   akash.g@samsung.com       Initial Version 
**/
@isTest
public class IF_DemandCallOutAPIControllerTest {

    @isTest
    static void restServiceCatchTest() {
        Test.startTest();
       	Sales_Lead__c salesLead = new Sales_Lead__c();
        salesLead.Name = 'Test Lead 1';
        salesLead.LeadChannel__c = 'Demand';
        salesLead.LeadStage__c = 'Cold';
        salesLead.LeadType__c = '32';
        salesLead.LeadStatus__c = 'In Process';
        insert salesLead;
        salesLead.LeadStatus__c = 'Close';
        salesLead.CloseReason__c = 'Close reason';
        salesLead.CustomerContactDate__c =  System.today();
        update saleslead;
        
        Test.stopTest();
    }
    
}