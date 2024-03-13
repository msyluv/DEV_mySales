/**
 * @description       : Share record with community users
 * @author            : gitesh.s@samsung.com
 * @group             : 
 * @last modified on  : 12-12-2022
 * @last modified by  : gitesh.s@smsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   12-12-2022   gitesh.s@samsung.com   Initial Version
**/
trigger SCPAccountSharing on SCP_Account__c (after insert) {
    if(trigger.isInsert){
        List<SCP_Account__Share> SCP_AccountShare  = new List<SCP_Account__Share>();
 
        SCP_Account__Share partnerShare;

        String partnerId;

        Map<Id, Id> scpAccounts = new Map<Id, Id>();

        for(SCP_Account__c scp : trigger.new) {
            scpAccounts.put(scp.Partner__c, scp.Id);
        }
 
        Map<Id, User> communityUsers = new Map<Id, User>(
            [SELECT Id, Name, AccountId FROM User WHERE ContactId IN (SELECT Id FROM Contact WHERE AccountId IN :scpAccounts.keySet())]
        );

        for(Id id : communityUsers.keySet()) {
            partnerId = communityUsers.get(id).AccountId;
            
            partnerShare = new SCP_Account__Share();

            partnerShare.ParentId = scpAccounts.get(partnerId);

            partnerShare.UserOrGroupId = id;

            partnerShare.AccessLevel = 'read';

            partnerShare.RowCause = Schema.SCP_Account__Share.RowCause.SCP_Partner_Share__c;

            SCP_AccountShare.add(partnerShare);
        }

        Database.SaveResult[] lsr = Database.insert(SCP_AccountShare,false);
    }
}