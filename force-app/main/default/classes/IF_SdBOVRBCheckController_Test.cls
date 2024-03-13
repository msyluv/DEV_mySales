/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 07-30-2021
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   07-21-2021   ukhyeon.lee@samsung.com   Initial Version
**/
@isTest
public class IF_SdBOVRBCheckController_Test {
    final static String REQUEST_URL = '/services/apexrest/WebService/IF143';    

    private static testMethod void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;        
        request.httpMethod = 'POST';

        IF_SdBOVRBCheckController.OutputHeader inputData = new IF_SdBOVRBCheckController.OutputHeader();
        inputData.ZZORDER_ID      = 'SDS-12345678';
        inputData.ZZBUKRS_H       = 'T100';
        inputData.BIZ_AMOUNT      = '100';
        inputData.CONSORTIUM_YN   = '';
        inputData.COMPLIANCE_1_YN = '';
        inputData.COMPLIANCE_2_YN = '';
        
        RestContext.request  = request;
        RestContext.response = response;

        try {
            IF_SdBOVRBCheckController.getBOVRBCheck(JSON.serialize(inputData));
        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }
}