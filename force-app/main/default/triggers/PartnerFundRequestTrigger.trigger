/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 07-18-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
trigger PartnerFundRequestTrigger on PartnerFundRequest (after update, before update) {
    
    if(Trigger.isAfter) {
        for(PartnerFundRequest pF : trigger.new){
            if((trigger.oldmap.get(pF.id).Status != trigger.newMap.get(pF.id).Status) && trigger.newMap.get(pF.id).Status == 'Submitted') {
                EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Request_Submit_Email' LIMIT 1];
                String contents = String.valueOf(emailTemplate.htmlValue);
                //TO-Do : Contents replace
                Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                contents = contents.replace('{!PartnerFundRequest.Link}', communityUrl + '/detail/' + pF.id);
                
                Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_adm LIMIT 1].Id;
                Set<Id> toIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
                
                PartnerEmailSender.emailSendAction(pF.id, sendId, toIds, null, null, emailTemplate.Subject, contents);
                
            }
            
            else if((trigger.oldmap.get(pF.id).Status != trigger.newMap.get(pF.id).Status) && trigger.newMap.get(pF.id).Status == 'Approved') {
                EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Request_Approved_Email' LIMIT 1];
                String contents = String.valueOf(emailTemplate.htmlValue);
                //TO-Do : Contents replace
                Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                contents = contents.replace('{!PartnerFundRequest.Link}', communityUrl + '/detail/' + pF.id);

                Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_sds LIMIT 1].Id;
                Set<Id> toIds = new Set<Id>{pf.OwnerId};
                Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
            
                PartnerEmailSender.emailSendAction(pF.id, sendId, toIds, null, bccIds, emailTemplate.Subject, contents);
            }
            
            else if((trigger.oldmap.get(pF.id).Status != trigger.newMap.get(pF.id).Status) && trigger.newMap.get(pF.id).Status == 'Rejected') {
                EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Request_Rejected_Email' LIMIT 1];
                String contents = String.valueOf(emailTemplate.htmlValue);
                //TO-Do : Contents replace
                Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                contents = contents.replace('{!PartnerFundRequest.Link}', communityUrl + '/detail/' + pF.id);

                Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_sds LIMIT 1].Id;
                Set<Id> toIds = new Set<Id>{pf.OwnerId};
                Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
                
                PartnerEmailSender.emailSendAction(pF.id, sendId, toIds, null, bccIds, emailTemplate.Subject, contents);
            }
        }
    }

    //public List<String> emailIdString = new List<String>();
    //String profileName = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()].Name;
    
    // for(User partneruser : partnerUserEmail){
    //     emailIdString.add(String.valueOf(partneruser.email));
    // }

    // if(Trigger.isBefore && Trigger.isUpdate) {
    //     for(PartnerFundRequest pfr : trigger.new) {
    //         if(pfr.Status == 'Draft' && profileName == 'MSP Admin') {
    //             pfr.addError('You cannot update this record in draft!');
    //         }
    //     }
    // }

    // String email = [SELECT Id, Email FROM User WHERE Id =: UserInfo.getUserId()].Email;

    // if(Trigger.isAfter) {
    //     for(PartnerFundRequest pfr : trigger.new) {

    //         if((trigger.oldMap.get(pfr.Id).Status != pfr.Status) && pfr.Status == 'Submitted') {
    //             PartnerFundRequestSubmissionEmail.emailSubmittedForApproval(pfr.Id, 'Partner_Fund_Request_Submission_Email', null);
    //         }
            
    //         else if((trigger.oldMap.get(pfr.Id).Status != pfr.Status) && pfr.Status == 'Approved') {
    //             PartnerFundRequestSubmissionEmail.emailSubmittedForApproval(pfr.Id, 'Partner_Fund_Request_Approved_Email', email);
    //         }
            
    //         else if((trigger.oldMap.get(pfr.Id).Status != pfr.Status) && pfr.Status == 'Rejected') {
    //             PartnerFundRequestSubmissionEmail.emailSubmittedForApproval(pfr.Id, 'Partner_Fund_Request_Rejected_Email', email);
    //         }
    //     }
    // }
}