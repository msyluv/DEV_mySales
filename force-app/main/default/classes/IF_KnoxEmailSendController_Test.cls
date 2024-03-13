/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxEmailSendController_Test {
    private static testMethod void IF_KnoxEmailSendController_Test() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());


        IF_KnoxEmailSendController.InputClass reqClass = new IF_KnoxEmailSendController.InputClass();
        List<IF_KnoxEmailSendController.Recipients> recList = new List<IF_KnoxEmailSendController.Recipients>();
        List<IF_KnoxEmailSendController.Attachments> attList = new List<IF_KnoxEmailSendController.Attachments>();
        
        reqClass.subject     = 'test subject';
        reqClass.contents    = 'test content';
        reqClass.contentType = 'TEXT';
        reqClass.docSecuType = 'PERSONAL';
        reqClass.sfdcId      = 'test';
        reqClass.isMulti = true;
        reqClass.sender      = new IF_KnoxEmailSendController.Sender('hyojinn.lee','hyojinn.lee@stage.partner.samsung.com');
        recList.add(new IF_KnoxEmailSendController.Recipients('hyojinn.lee@stage.partner.samsung.com','TO'));
        reqClass.recipients = recList;
        
        attList.add(new IF_KnoxEmailSendController.Attachments('file','file1','buffer1'));
        attList.add(new IF_KnoxEmailSendController.Attachments('file','file2','buffer2'));
        attList.add(new IF_KnoxEmailSendController.Attachments('file','file3','buffer3'));
        reqClass.attachments = attList;
        
        Map<String, Object> returnMap = IF_KnoxEmailSendController.send(reqClass);
        

        Integer statusCode  = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);

        Test.stopTest();        
    }
    
    private static testMethod void IF_KnoxEmailSendController_Test2() {

        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
            
        String reqClass = '{"Request" : "System.HttpRequest[Endpoint=https://devapigateway.samsungsds.com/QAS/1.0/if075/sendMail, Method=POST], "Body" : {"subject":"[SDSLA_SL-SAO]Close date has already passed. Please update BO.","sfdcId":"0061s000005tIHDAA2","sender":{"userId":"yeoguri.kim","emailAddress":"yeoguri.kim@stage.partner.samsung.com"},"recipients":[{"recipientType":"TO","emailAddress":"yeoguri.kim@stage.partner.samsung.com"}],"isMulti":true,"docSecuType":"PERSONAL","contentType":"HTML","contents":"<p>Close date for [SDSLA_SL-SAO] Baruel [WH BPO] of SDSLA_SL-SAO has already passed.</p><p>Please update BO information if schedule has been changed.</p><p>BO stage will be automatically changed to after 2021-08-06.</p><p><br></p><p><br></p><p>□ Account Name : </p><p>□ BO Name(BO ID) : [SDSLA_SL-SAO] Baruel [WH BPO](BIZ21031713994)</p><p>□ Owner : Gomes Roberto</p><p>□ Close Date : 2021-07-16</p><p><br></p><p><br></p><p><a href=\"https://sdssfa--qa.my.salesforce.com/0061s000005tIHDAA2\" target=\"_blank\">Link to Opportunity </a></p><p><br></p>","attachments":[]}';
        IF_KnoxEmailSendController.send2(reqClass);
        Test.stopTest();    
    }
}