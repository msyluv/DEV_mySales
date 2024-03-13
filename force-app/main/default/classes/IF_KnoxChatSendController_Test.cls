/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-11-23
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_KnoxChatSendController_Test {
    private static testMethod void IF_KnoxChatSendController_Test() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        List<String> inputList = new List<String>();
        inputList.add('oldman.sea');
        inputList.add('wonjun98.lee');
        inputList.add('TEST_20210728_001 (복사본) (복사본) (복사본)');
        inputList.add('SDS-21769740');
        inputList.add('이상혁');
        inputList.add('이원준');
        inputList.add('oldman.sea@stage.samsung.com');
        inputList.add('wonjun98.lee@stage.samsung.com');
        Datetime now = Datetime.now();
        String strDate = now.format('MMdd', 'Asia/Seoul');
		String strTime = now.format('HH:mm:ss', 'Asia/Seoul');
        inputList.add(strDate+' '+strTime);
        inputList.add('description');
        inputList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/0061s000006gmeAAAQ/view');
        IF_KnoxChatSendController.sendBOOwnerChangeChat(inputList);

        inputList = new List<String>();
        inputList.add('oldman.sea');
        inputList.add('wonjun98.lee');
        inputList.add('0217_이준호_SalesLead_Test_1');
        inputList.add('이상혁');
        inputList.add('이원준');
        inputList.add('oldman.sea@stage.samsung.com');
        inputList.add('wonjun98.lee@stage.samsung.com');
        strDate = now.format('MMdd', 'Asia/Seoul');
		strTime = now.format('HH:mm:ss', 'Asia/Seoul');
        inputList.add(strDate+' '+strTime);
        inputList.add('description');
        inputList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/a0P1s000001cmjxEAA/view');
        IF_KnoxChatSendController.sendLeadOwnerChangeChat(inputList);
        
        Test.stopTest();
    } 

    private static testMethod void IF_KnoxChatSendController_Test2() {
        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_KnoxChatSendController.getBOChangeAdaptiveCardContent('', '', '', '', '', '', '', '', '');
        IF_KnoxChatSendController.getLeadChangeAdaptiveCardContent('', '', '', '', '', '', '', '');

        List<String> inputList = new List<String>();
        inputList.add('oldman.sea');
        inputList.add('wonjun98.lee');
        inputList.add('TEST_20210728_001 (복사본) (복사본) (복사본)');
        inputList.add('SDS-21769740');
        inputList.add('이상혁');
        inputList.add('이원준');
        inputList.add('oldman.sea@stage.samsung.com');
        inputList.add('wonjun98.lee@stage.samsung.com');
        Datetime now = Datetime.now();
        String strDate = now.format('MMdd', 'Asia/Seoul');
		String strTime = now.format('HH:mm:ss', 'Asia/Seoul');
        inputList.add(strDate+' '+strTime);
        inputList.add('description');
        inputList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Opportunity/0061s000006gmeAAAQ/view');
        IF_KnoxChatSendController.sendBOOwnerChangeChat2(inputList);

        inputList = new List<String>();
        inputList.add('oldman.sea');
        inputList.add('wonjun98.lee');
        inputList.add('0217_이준호_SalesLead_Test_1');
        inputList.add('이상혁');
        inputList.add('이원준');
        inputList.add('oldman.sea@stage.samsung.com');
        inputList.add('wonjun98.lee@stage.samsung.com');
        strDate = now.format('MMdd', 'Asia/Seoul');
		strTime = now.format('HH:mm:ss', 'Asia/Seoul');
        inputList.add(strDate+' '+strTime);
        inputList.add('description');
        inputList.add('https://sdssfa--qa.lightning.force.com/lightning/r/Sales_Lead__c/a0P1s000001cmjxEAA/view');
        IF_KnoxChatSendController.sendLeadOwnerChangeChat2(inputList);
        
        Test.stopTest();
    }    
}