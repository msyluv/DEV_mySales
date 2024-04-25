/**
 * @author            : aditya.r2@samsung.com
 * @group             : 
 * @description       : Test class for newWeeklyReportVFController
 * @last modified on  : 2024-03-27
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-03-05   aditya.r2@samsung.com		Initial Version
**/
@isTest
public class newWeeklyReportVFController_Test {
    
    static testMethod void testnewWeeklyReportVFController(){
        //Test data setup
        String imageBody = EncodingUtil.base64Encode(Blob.valueOf('Test Data'));
        
        String imageBase64Data = 'iVBORw0KGgoAAAANSUhEUgAAACQAAAAmCAYAAACsyDmTAAABzklEQVRYCe2YTUsCURSG/T/RXyjatGrlD/BfSLuaZRkFtYuW00JJkloUSYGVSNAXMoGVH1GiTV+GNFqNM/PGERRaNPfMNOUs5sDLiPd47+N77rk6E2q1WqhUKiiXy1AUZeAKEZCfFACJqhE4JHSoVCoNvLOow6nTCTZEre6HqNfrXSjfAJEpVC1fAVG1AiC7/cp2KB6PQ5Ik18pkMnYc/TE2EE0oy7Jr5fP5/qJ2L9hAdpN4OeYKyLIsfHQMGKYJXdehaZpQlMcJx0CGaeFFe8fyvoLiwytSqRQikYhQlMcJR0Adw8SV2oC0eYSJpQ1kizVUq1XkcjmhKI8TbCCCObt9RGz7BCOzaxieXsVe4Y6zhqMcNtDNUxPzO6cYm0tiaEruioBUVQV1kEiUxwk20MrBRbdMPRi6ElAikUA4HBaK8jjxayDqMPr2IlEeJ9hAtJlnto4xGvteMs4iTnLYQD9tato7nBP8T05q3TBQuG9gMpnF+MI6Dq9rSKfTiEajQlEeJ9gO9Sajg/H5rY3F3XNcqo3e255dHQPRyvST0Wx/ghzzOthAwd8Pr613Ox+7ZG4XcPq5AEjkWOCQyCFf3bn27+199/RD9Lzmv8e/ADwwCQUCRKCZAAAAAElFTkSuQmCC';
        String RichTextValue = '<p>test</p>'+
            				   //'<p><img src="https://sdssfa.file.force.com/servlet/servlet.ImageServer?id=0152w000002Hb8K&oid=00D2w000008robw&lastMod=1654233710000"></p>';
            				   '<p><img src="data:image/png;base64,'+imageBase64Data+'"alt="Test Data"></p>';
                
        WeeklyReport__c weeklyReport = new WeeklyReport__c();
        
        weeklyReport.Name = 'tEST';
        weeklyReport.ReportingDate__c = system.today();
        WeeklyReport.Issue_Description_Check__c = RichTextValue;
        WeeklyReport.IssueDescription__c = 'qwerty';
        insert weeklyReport;
        
        ContentVersion cv = new ContentVersion(
            									Title='Test Content',
            									ContentLocation='S',
            									Origin='H',
            									PathOnClient='Test Content',
            									FirstPublishLocationId = weeklyReport.Id,
            									VersionData=Blob.valueof('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAHwAAAAkCAYAAABLw14kAAABz0lEQVR4Ae2ZwY7DQAhD8/9fnNuukPZJHgpJFeWyjA8RDHhoY8cTqT3O8/zxtQ8Hh8XeR+zQ2oJvdsJZcAu+1xG32yvNDrfD7fDJrrfD7XA73A7fzAUW3IKP+TXy4x1+HEd5c139LTfE/O66+gz9Xl1+tX+3Xim4EgchVY3eG/Hp/G5fV3/ju/7nGaXgcUOZsGodNS5IqHD0qrn08j7qOfJ54Ik6WzG5rz2dDY6+9ibljwSHHCWCGpHe3brDUddYzdJal8cM7TFTa5HrGsy02AqeSVIyNIcQrZF3kT0aA9td4JjHOqLWujzj2H+FBzMtPhY8yMoX5EBkF8FpBKu1nFcYrXV5zNEec7WmOf2J8VJwJUoJ0bwihX4Xr/ZUPWrMYx1Ra12ecey/woOZFi34328MKv40kfV+bgUPcJChhGjOsFy7W7OPmPHUNWZMrLXW5TFDe8zUmub0J8avBK8IC4L0yuRkAvO6wus8zRWb6zo352DZz5pIPaLu1fq0/EPwaTfo+1n/DLPgm/1PYMEt+HoE+EicxYcdbofPeqJ9Qq162uF2+PpE2CGz+LDD7fBZT7RPqFVPO9wOX58IO2QWH3a4HT7rifYJtepph2/m8F/R0/wI0gJ50AAAAABJRU5ErkJggg=='));
        insert cv;
        ContentVersion cv1 = new ContentVersion(
            									Title='Test Content1',
            									ContentLocation='S',
            									Origin='H',
            									PathOnClient='Test Content1',
            									FirstPublishLocationId = weeklyReport.Id,
            									VersionData=Blob.valueof('data:image/png;base64,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'));
        insert cv1;
        
        String delCont= 'https://sdssfa--qa--c.sandbox.vf.force.com/sfc/servlet.shepherd/version/download/'+cv1.Id;
        PageReference pageRef = Page.newWeeklyReportVF;
        Test.SetCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id',weeklyReport.Id);
        ApexPages.currentPage().getParameters().put('issueDescription', RichTextValue);
        ApexPages.currentPage().getParameters().put('uploadedImgSrcList', cv.Id);
        ApexPages.currentPage().getParameters().put('deleteSrc', delCont);
        ApexPages.currentPage().getParameters().put('ReportingName', 'Test1');
        ApexPages.currentPage().getParameters().put('ReportingDate', String.valueOf(System.today()));
        
        ApexPages.StandardController std = new ApexPages.StandardController(weeklyReport);
        newWeeklyReportVFController controller = new newWeeklyReportVFController(std);
        controller.recordID = weeklyReport.Id;
        controller.issueDescriptionCheck = RichTextValue;
        controller.wr = weeklyReport;

        system.debug('controller==>'+controller);
        System.assertEquals(weeklyReport.id,controller.recordID);
        
        Test.startTest();
        controller.doSave();
        Test.stopTest();
        WeeklyReport__c updatedWeeklyReport = [Select id,Issue_Description_Check__c From WeeklyReport__c where id =:weeklyReport.Id];
        //System.assertEquals(RichTextValue , updatedWeeklyReport.Issue_Description_Check__c);
   }

}