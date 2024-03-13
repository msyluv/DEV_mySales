/**
 * @description       : 
 * @author            : wonjune.oh@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-07-12
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-01-05   wonjune.oh@partner.samsung.com   Initial Version
**/
@isTest
public with sharing class SvcSolBizAttrSendToEccController_Test {
    static {
        BizAttribute__c BizAttribute = new BizAttribute__c(Code__c ='S144', Description__c='SI/NI Implementation', Active__c=true);

        Master_Solution__c MasterSolution = new Master_Solution__c(Code__c = '30000004');
        
        insert BizAttribute;
        insert MasterSolution;
        
        SvcSolBizAttr__c svcsolBizAttr = new SvcSolBizAttr__c(BusinessType__c= 'TI', WBSClass__c='SI', Use__c = true, BizAttribute__c = BizAttribute.Id, Solution__c= MasterSolution.Id);
        
        insert svcsolBizAttr;
    }
    @isTest static void test_method() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new SvcSolBizAttrSendToEccControllerTestMok(200));

        SvcSolBizAttrSendToEccController.solBizAttrSendToEcc();

		Test.stopTest();
    }

    
    @isTest static void test_method2() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new SvcSolBizAttrSendToEccControllerTestMok(400));

        SvcSolBizAttrSendToEccController.solBizAttrSendToEcc();

		Test.stopTest();
    }

    public class SvcSolBizAttrSendToEccControllerTestMok implements HttpCalloutMock{
        private Integer statusCode = 200;
     
        public SvcSolBizAttrSendToEccControllerTestMok(Integer statusCode) { 
            this.statusCode = statusCode;
        }
    
        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            String body = '';
            if(statusCode == 200){
                body = '{ ' +
                             '   "ES_RTMSG": ' +
                             '   {  ' +
                             '        "TYPE": "S", ' +
                             '        "RTMSG": "Success" ' +
                             '    }, ' +
                             '   "IT_DATA": ' +
                             '   [  ' +
                             '      {  ' +
                             '        "SFDC_CLASS": null, '+
                             '        "ZZORDER_TYPE": "S149", '+
                             '        "ZOPPT_TYPE": null,   '+
                             '        "ZZWBS_CLASS": "SM",  ' +
                             '        "ZZUSEYN": "T",   '+
                             '        "ZZPS_TYPE": "SM4" '+
                             '      }  '+
                             '   ] '+
                             '      ' +
                             ' }';
            }else{
                body = '{ ' +
                '   "ES_RTMSG": ' +
                '   {  ' +
                '        "TYPE": "E", ' +
                '        "RTMSG": "Error" ' +
                '    }, ' +
                '   "IT_DATA":[]}';
            }
            response.setBody(body);
            response.setStatusCode(statusCode);
            return response; 
        }
    }
}