/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 10-21-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   10-21-2020   woomg@dkbmc.com   Initial Version
**/
@isTest  
private class MiniMETAClient_Test {
    
    @isTest
    private static void testMethod1(){

        MiniMETA.MetadataPort service = MiniMETAClient.createService();

        List<MiniMETA.Error> errors = new List<MiniMETA.Error>();
        MiniMETA.Error error = new MiniMETA.Error();
        error.statusCode = '201';
        error.message = 'error';
        error.fields = null;
        errors.add(error);

        MiniMETA.SaveResult result = new MiniMETA.SaveResult();
        result.fullName = 'Field Error';
        result.success = false;
        result.errors = errors;

        Test.startTest();
        MiniMETAClient.handleResults(result);
        Test.stopTest();

    }
}