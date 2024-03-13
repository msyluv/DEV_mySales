@isTest class OpportunityPopupController_Test {
	static OpportunityNotice__c notice; 
    static String docId;
    
    static {
    	notice = new OpportunityNotice__c(
            NoticeKR__c = '가나다라',
            NoticeEN__c = 'abcd'
        );
        insert notice;

        ExternalDataSource eds = [SELECT Id FROM ExternalDataSource WHERE DeveloperName = 'EFSS_Vault' LIMIT 1];
        ContentVersion cv = new ContentVersion(
            ContentLocation = 'E',
            Origin = 'H',
            OwnerId = UserInfo.getUserId(),
            Title = 'filename', 
            PathOnClient = 'filename',
            ExternalDataSourceId = eds.Id,
            ExternalDocumentInfo1 = 'vault://0123456789abcdef',
            ExternalDocumentInfo2 = '0123456789abcdef'
        );
        insert cv;
        docId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;    
    }
    
    @IsTest
    private static void test_method_1() {
        list<String> fileIds = new list<String>();
        fileIds.add('0123456789abcdef');

        Test.startTest();

        String body = '';
            body += '{';
            body += '"id" : "0123456789abcdef",';
            body += '"domain" : "vault-stg.efss.asmsung.net",';
            body += '"secKey" : "0123456789abcdef"';
            body += '}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(body));
        system.debug(OpportunityPopupController.getVaultAuthToken('file-view', fileIds));

        Test.stopTest();
    }
    
	@IsTest
    private static void test_method_2() {
        Test.startTest();
        OpportunityPopupController.getInfo('Notice');
        OpportunityPopupController.getVaultFileId(docId);
        OpportunityPopupController.getUserIPAddress();
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        String responseBody = '';

        public MockHttpResponseGenerator(String responseBody){
            this.responseBody = responseBody;
        }

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            system.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            res.setBody(responseBody);
            res.setStatusCode(200);
            return res;
        }
    }
}