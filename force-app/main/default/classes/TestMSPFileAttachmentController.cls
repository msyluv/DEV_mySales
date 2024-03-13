/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-31-2022
 * @last modified by  : gitesh.s@samsung.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   08-31-2022   gitesh.s@samsung.com    Added Community Login Profile
**/
@isTest
private class TestMSPFileAttachmentController {
    
    static testMethod void testAttachments()
    {
        /*  Account acc=new Account(Name='Acme Inc');
insert acc;*/
        
        
        
        
        Partner_Notice__c pn = new partner_notice__c(Subject__c = 'test class' , StartDate__c = Date.valueOf('2022-01-04') ,EndDate__c = Date.valueOf('2022-01-04') //,Contents__c ='test class sample' 
        );
        
        insert pn;
        
        Account a= new Account(name='Test Account');
        insert a;
        a.isPartner = true;
        update a;
        PartnerFundRequest pp = new PartnerFundRequest();
        pp.ChannelPartnerId = a.id;
        pp.RequestedAmount = 10;
        pp.title = 'test';
        insert pp;
       
        Contact c = New Contact(LastName = 'Test', AccountID = a.id);
        insert c;
        User newUser = createPartnerUser(c.id);
        system.runAs(newUser) {
            // statements to be executed by this test user.
            MSpFileAttachmentController.getAttachments(pn.id);
        }
        //cdl
        //Create Document
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Document';
        cv.PathOnClient = 'TestDocument.pdf';
        cv.VersionData = Blob.valueOf('Test Content');
        cv.IsMajorVersion = true;
        Insert cv;
        
        //running before inserting attachment so as to replicate no attachment scenario.
        MSpFileAttachmentController.getAttachments(pn.id);
        //Get Content Documents
        List<Id> docList = new list<id>();
        Id conDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
        docList.add(conDocId);
        //Create ContentDocumentLink 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = pn.Id;
        cdl.ContentDocumentId = conDocId;
        cdl.shareType = 'V';
        Insert cdl;
        //cdl ends
        
        MSpFileAttachmentController.getAttachments(pn.id);
        MSpFileAttachmentController.deleteAttachmentAction(conDocId);
        MSpFileAttachmentController.clearUploadAction(docList);
        
        system.runAs(newUser){
            MSpFileAttachmentController.getAttachments(pp.id);
            
        }
    }
    
    private static user createPartnerUser(ID cId){
        Profile p = [Select ID, Name from Profile Where Name = 'Partner Community Manager'];
        
        user u = New User(
            UserName = 'test_' + math.random() + '@test.com',
            FirstName = 'Test-First',
            LastName = 'Test-Last',
            Alias = 'test',
            email = 'test' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US', 
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = cId
            
        );
        
        User mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];

        System.runAs(mspAdmin){
            insert u;
        }
        
        return u;
        
        
    }
    
    /*Ver 1.0 Added Community Login Profile*/
    private static user createPartnerUserLoginProfile(ID cId){

        Profile loginProfile = [Select ID, Name from Profile Where Name = 'Partner Community Login Manager'];
        
        user loginUser = New User(
            UserName = 'test_new' + math.random() + '@test.com',
            FirstName = 'TestNew-First',
            LastName = 'TestNew-Last',
            Alias = 'testnew',
            email = 'testnew' + math.random() + '@test.com',
            CommunityNickName = string.valueOf(math.random()).substring(0,6),
            ProfileId = loginProfile.Id,
            TimeZoneSidKey = 'America/New_York', 
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8', 
            LanguageLocaleKey = 'en_US',
            ContactID = cId
            
        );
        
        User mspAdmin = [Select Id From User Where Profile.Name='MSP Admin' and isActive=true Limit 1];

        System.runAs(mspAdmin){
            insert loginUser;
        }
        
        return loginUser;
        
        
    }
}