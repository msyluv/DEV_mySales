/**
* @author            : anish.jain@partner.samsung.com
* @group             : 
* @last modified on  : 2024-03-05
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                          Modification
* 1.0   2023-11-24   anish.jain@partner.samsung.com  Initial Version -  (MS-365)
* 1.1   2024-03-05   vikrant.ks@samsung.com          Increased Coverage - (MySales-464)
**/

@isTest
private class Batch_CollabTeamMemberInfo_Test {
    
    static RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    static Opportunity opptyHQ2;
    static Opportunity CollaborationBo; 
    
    static {
        CollaborationBo = new Opportunity(
            Name = 'Collaboration Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'MSP', 
            SCPScale__c = 5000,
            ConversionType__c = 'Re-host',
            CMBizType__c= 'MSP_Integration',
            MSP_Amount__c = 2000,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = null,
            CloseDate = Date.today(),
            //Collaboration__c = true,
            //AccountId = acc.Id,
            cLeadID__c = NULL
        );
        insert CollaborationBo;
        opptyHQ2 = new Opportunity(
            Name = 'Test Opportunity',
            RecordTypeId = RT_OPPTY_HQ.Id,
            CspMspType__c = 'MSP', 
            SCPScale__c = 5000,
            ConversionType__c = 'Re-host',
            CMBizType__c= 'MSP_Integration',
            MSP_Amount__c = 2000,
            StageName = 'Z01',
            cPrimarySalesDepartment__c = null,
            CloseDate = Date.today(),
            CollaborationBOId__c= CollaborationBo.Id,
            //Collaboration__c = true,
            //AccountId = acc.Id,
            cLeadID__c = NULL
        );
    }
    
    @isTest static void test_method_1() {
        Test.startTest();
        insert opptyHQ2;
        Batch_CollabTeamMemberInfo Batch = new Batch_CollabTeamMemberInfo();
		String sch = '20 30 8 10 2 ?';
		String jobID = System.schedule('IF_Batch Job', sch, Batch);
        
        Test.stopTest();
    }
    
}