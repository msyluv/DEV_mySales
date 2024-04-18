/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-16-2020   woomg@dkbmc.com   Initial Version
 * 1.1   02-26-2024   vikrant.ks@samsung.com   MySales-447
**/
@isTest
private class CustomRelatedFilesController_Test {
    private static String   docId;

    static {
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
    private static void testMethod1() {
        list<String> fileIds = new list<String>();
        fileIds.add('0123456789abcdef');

        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        system.debug(CustomRelatedFilesController.getVaultAuthToken('file-view', fileIds, 'web'));

        Test.stopTest();
    }

    @IsTest
    private static void testMethod2() {
        Test.startTest();
        system.debug(CustomRelatedFilesController.isCreatable('Contact'));
        system.debug(CustomRelatedFilesController.getRelatedFiles(UserInfo.getUserId()));
        system.debug(CustomRelatedFilesController.saveVaultId2Content(UserInfo.getUserId(), '0123456789abcdef', 'filename.ext'));
        system.debug(CustomRelatedFilesController.getVaultFileId(docId));
        system.debug(CustomRelatedFilesController.checkDeletePermission(docId));
        system.debug(CustomRelatedFilesController.deleteContentDocument(docId));
        system.debug(CustomRelatedFilesController.getUserIPAddress());
        Test.stopTest();
    }

    @IsTest
    private static void testMethod3() {
        Test.startTest();
        try{
            system.debug(CustomRelatedFilesController.isCreatable(null));
        } catch(Exception e){}
        try{
            system.debug(CustomRelatedFilesController.saveVaultId2Content(UserInfo.getUserId(), '0123456789abcdef', null));
        } catch(Exception e){}
        try{
            system.debug(CustomRelatedFilesController.deleteContentDocument(null));
        } catch(Exception e){}
        try{
            system.debug(CustomRelatedFilesController.getVaultFileId(null));
        } catch(Exception e){}
        //V1.1 Start
        try{
            system.debug(CustomRelatedFilesController.DisableUploadButton(docId));
        } catch(Exception e){}
        //V1.1 End
        Test.stopTest();
    }

    //@IsTest
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Optionally, only send a mock response for a specific endpoint
            // and method.
            system.assertEquals('POST', req.getMethod());
            
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json; charset=utf-8');
            String body = '';
            body += '{';
            body += '"id" : "0123456789abcdef",';
            body += '"domain" : "vault-stg.efss.asmsung.net",';
            body += '"secKey" : "0123456789abcdef"';
            body += '}';
            
            res.setBody(body);
            res.setStatusCode(200);
            return res;
        }
    }
}