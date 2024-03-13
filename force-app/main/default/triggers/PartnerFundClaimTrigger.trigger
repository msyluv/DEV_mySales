/**
* @description       : This trigger is used for trigger partner fund claim actions
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 07-20-2022
* @last modified by  : ukhyeon.lee@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   07-02-2022   rakshit.s@samsung.com   Initial Version
* 1.1   07-07-2022   ukhyeon.lee@samsung.com add recipientsList
**/
trigger PartnerFundClaimTrigger on PartnerFundClaim (after insert, after update) {
    
    switch on Trigger.operationType {
        
        when AFTER_UPDATE {
            for(PartnerFundClaim pF : trigger.new){
                if((trigger.oldmap.get(pF.id).status__c != trigger.newMap.get(pF.id).status__c) && trigger.newMap.get(pF.id).status__c == 'Submitted') {
                    EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Claim_Submit_Email' LIMIT 1];
                    String contents = String.valueOf(emailTemplate.htmlValue);
                    //TO-Do : Contents replace
                    Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                    String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                    contents = contents.replace('{!PartnerFundClaim.Link}', communityUrl + '/detail/' + pF.id);
                    
                    Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_adm LIMIT 1].Id;
                    Set<Id> toIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
                    
                    PartnerEmailSender.emailSendAction(pF.id, sendId, toIds ,null,null, emailTemplate.Subject, contents);
                    
                }
                
                else if((trigger.oldmap.get(pF.id).status__c != trigger.newMap.get(pF.id).status__c) && trigger.newMap.get(pF.id).status__c == 'Approved') {
                    EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Claim_Approved_Email' LIMIT 1];
                    String contents = String.valueOf(emailTemplate.htmlValue);
                    //TO-Do : Contents replace
                    Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                    String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                    contents = contents.replace('{!PartnerFundClaim.Link}', communityUrl + '/detail/' + pF.id);


                    Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_sds LIMIT 1].Id;
                    Set<Id> toIds = new Set<Id>{pf.OwnerId};
                    Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
                
                    PartnerEmailSender.emailSendAction(pF.id, sendId, toIds, null, bccIds, emailTemplate.Subject, contents);
                }
                
                else if((trigger.oldmap.get(pF.id).status__c != trigger.newMap.get(pF.id).status__c) && trigger.newMap.get(pF.id).status__c == 'Rejected') {
                    EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE DeveloperName ='Partner_Fund_Claim_Rejected_Email' LIMIT 1];
                    String contents = String.valueOf(emailTemplate.htmlValue);
                    //TO-Do : Contents replace
                    Site site = [SELECT Id FROM Site WHERE Name='Delivery1' LIMIT 1];
                    String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
                    contents = contents.replace('{!PartnerFundClaim.Link}', communityUrl + '/detail/' + pF.id);

                    Id sendId = [SELECT Id FROM User WHERE Email=:System.Label.partner_email_sds LIMIT 1].Id;
                    Set<Id> toIds = new Set<Id>{pf.OwnerId};
                    Set<Id> bccIds = (new Map<Id, User>([SELECT Id FROM User WHERE Email=:System.Label.partner_email_mkt])).keySet();
                    
                    PartnerEmailSender.emailSendAction(pF.id, sendId, toIds, null, bccIds, emailTemplate.Subject, contents);
                }
            }
        }
    }
}