/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-04-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-29-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_MdgAccountSenderController_Test {
    //IF-052
    private static testMethod void IF_MdgAccountSenderControllerTest() {

        Test.startTest();

        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());
        IF_MdgAccountSenderController.InputClass inptCls = new IF_MdgAccountSenderController.InputClass();
        inptCls.ADRESS  = new List<IF_MdgAccountSenderController.Address>();
        inptCls.KNA1    = new List<IF_MdgAccountSenderController.Kna1>();

        
        IF_MdgAccountSenderController.Address  adrCls = new IF_MdgAccountSenderController.Address();
        //adrCls.BillingAddressState      = 'Seoul';
        adrCls.BillingAddressCity1       = '송파구';
        adrCls.BillingAddressStreet     = '올림픽로35길 130 123(신천동)';
        adrCls.BillingAddressPostalCode = '05504';
        adrCls.BillingAddressCountry    = 'Korea, Republic of';
        adrCls.Name                     = '1222_MGD_Test_9';
        adrCls.Region                   = 'kr';

        IF_MdgAccountSenderController.Kna1  kna1Cls = new IF_MdgAccountSenderController.Kna1();
        kna1Cls.CreatedById      = '24790';
        kna1Cls.mCountry         = 'KR';
        kna1Cls.CorporateNumber  = '1237896502';
        kna1Cls.mDomesticForeign = 'Int';
        kna1Cls.mCEOName         = 'Test';
        kna1Cls.mBizTypeL1Code   = 'L01';
        kna1Cls.mBizTypeL2Code   = 'L100';
        

        inptCls.ADRESS.add ( adrCls);
        inptCls.KNA1.add   ( kna1Cls);

        Map<String, Object> resultMap = IF_MdgAccountSenderController.send( inptCls);
        Integer statusCode  = Util_String.nvlInt( resultMap.get( 'StatusCode'));
        System.assertEquals( statusCode, 200);

        Test.stopTest();
    }
}