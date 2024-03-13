public class ReportSubscriptionInitiator {
    
    @AuraEnabled
    public static void scheduleEmailSubscription(String cronExp , List<Object> userEmails, String repId){
        
        system.debug('repId-->' + repId);        
        system.debug('cron-->' + cronExp);
        system.debug('emails-->' + JSON.serialize(userEmails));
        List<String> finalRecepientsEmail = new List<String>();
        for(object o : userEmails){
            finalRecepientsEmail.add(String.valueOf(o));
        }
        
        system.debug('finalList' + finalRecepientsEmail);
        
        String arg1Value = repId; // Replace 'YourArg1Value' with the actual value for arg1Value
        List<String> arg2Value = finalRecepientsEmail;
            
            // Create an instance of the ReportScheduler class with the arguments
            ReportScheduler scheduler = new ReportScheduler(arg1Value, arg2Value);
        System.schedule('My Report Scheduler Job from lwc', cronExp, scheduler);
         system.debug('done');
    }
    /*
8th table
SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity WHERE OwnerId = '0052w0000089yNjAAI' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CMBizType__c = 'CSP_SCP' AND CloseDate >= TODAY AND CloseDate <= Next_N_MONTHS:3

7th table
SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId = '0052w000008dbVKAAY' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND Account.mDomesticForeign__c = '20' AND CloseDate >= TODAY AND CloseDate <= Next_N_MONTHS:3


5th table 
SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId = '0052w000007R3NsAAK' AND XP6_CONDUCT_DATE__c > TODAY AND CloseDate >= TODAY AND CloseDate <= Next_N_MONTHS:2

4th table

SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId = '0052w0000089yYkAAI' AND XP7_CONDUCT_DATE__c > TODAY AND CloseDate >= TODAY AND CloseDate <= Next_N_DAYS:14

3rd table

SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId ='0052w0000089yXlAAI' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate >= TODAY AND CloseDate <= Next_N_DAYS:14

2nd table

SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId ='0052w000008A0EZAA0' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate < TODAY

1st table

SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId = '0052w0000089yNiAAI' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND BO1stRegistrationDate__c != null AND CloseDate >= THIS_YEAR AND CloseDate < NEXT_YEAR

6th table

SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
                             FROM Opportunity 
                             WHERE OwnerId ='0052w0000089yTjAAI' AND (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND CloseDate >= TODAY AND CloseDate <= Next_N_MONTHS:3


master merged query
SELECT Id, Amount, Name, OpportunityCode__c, ZP61_PROPOSAL_SUBMIT_DATE__c, ProposalPM__c, ProposalPM__r.Name, cOriginAcc__c, cOriginAcc__r.Owner.Name, cOriginAcc__r.Name, Opportunity_Review_VRB_Type_Confirm__c, toLabel(Opportunity_Review_VRB_Type_Confirm__c) toLabel_Opportunity_Review_VRB_Type_Confirm__c, Opportunity_Review_VRB_Type__c, toLabel(Opportunity_Review_VRB_Type__c) toLabel_Opportunity_Review_VRB_Type__c, StageName, toLabel(StageName) toLabel_StageName, BO1stRegistrationDate__c, CloseDate, XP7_CONDUCT_DATE__c, XP6_CONDUCT_DATE__c, Account.mDomesticForeign__c, CMBizType__c, AccountId, Account.Owner.Name, Account.Name, OriginAcc_BizTypeL1__c, BusinessLevel__c, RecordType.Name, Type 
FROM Opportunity 
WHERE 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        CMBizType__c = 'CSP_SCP' AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_MONTHS:3
    ) OR 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        Account.mDomesticForeign__c = '20' AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_MONTHS:3
    ) OR 
    (
        XP6_CONDUCT_DATE__c > TODAY AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_MONTHS:2
    ) OR 
    (
        XP7_CONDUCT_DATE__c > TODAY AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_DAYS:14
    ) OR 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_DAYS:14
    ) OR 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        CloseDate < TODAY
    ) OR 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        BO1stRegistrationDate__c != null AND 
        CloseDate >= THIS_YEAR AND 
        CloseDate < NEXT_YEAR
    ) OR 
    (
        (StageName = 'Z01' OR StageName = 'Z02' OR StageName = 'Z03' OR StageName = 'Z04') AND 
        CloseDate >= TODAY AND 
        CloseDate <= NEXT_N_MONTHS:3
    )
    AND OwnerId = 'Your_Owner_Id_Value_Here'

*/
    
}