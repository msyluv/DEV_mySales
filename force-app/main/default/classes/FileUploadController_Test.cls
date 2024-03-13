/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-18
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-03-18   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class FileUploadController_Test {
    static Profile profile =  Utils_TestDataFactory.getProfile('System Administrator');
    static User user = Utils_TestDataFactory.createUserFull(profile, 'testUser@'+EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128))+'samsung.com', 'test1');
    static User user1 = Utils_TestDataFactory.createUserFull(profile, 'testUser2@'+EncodingUtil.ConvertTohex(Crypto.GenerateAESKey(128))+'samsung.com', 'test2');
	static Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'test1');
    static Employee__c emp2 = Utils_TestDataFactory.createEmployee('TestEmp2', 'test2');
    static Employee__c emp3 = Utils_TestDataFactory.createEmployee('TestEmp3', 'test3');
    static Account acc = Utils_TestDataFactory.createAccount('Test');    
    static List<Map<String, Object>> fileList;

    @isTest 
    static void saveTheFile() {
        Test.startTest();
        String fileName = 'testfile.txt';
        String base64Data = 'ZmlsZSB0ZXN0DQo=';
        String urlEncodedBase64Data = EncodingUtil.urlEncode(base64Data, 'UTF-8');
        String contentType = 'text/plain';
        Boolean bUrlEncoded = true;
        String iconName = contentType;
        Decimal filesize = base64Data.length();
        List<Map<String, Object>> fileList = new List<Map<String, Object>>();
        Map<String, Object>       fileMap  = new Map<String, Object>();
        fileMap.put( 'name'         , fileName);
        fileMap.put( 'fileContents' , base64Data);
        fileMap.put( 'iconName'     , iconName);
        fileMap.put( 'filesize'     , filesize);
        fileList.add( fileMap);

        FileUploadController.saveTheFile(acc.Id, fileName, urlEncodedBase64Data, contentType, filesize);
        FileUploadController.saveTheFile(bUrlEncoded, acc.Id, fileName, urlEncodedBase64Data, contentType, filesize);
        FileUploadController.saveTheFiles(acc.Id, fileList);

        List<Map<String, Object>> res = FileUploadController.getFile(acc.Id);

        System.assertEquals(res.size(), 3);

        FileUploadController.delTheFile(acc.Id);

        List<Attachment> att = [SELECT id FROM Attachment WHERE ParentId = :acc.Id];

        System.assertEquals(att.size(), 0);


        Test.stopTest();
    }
    
}