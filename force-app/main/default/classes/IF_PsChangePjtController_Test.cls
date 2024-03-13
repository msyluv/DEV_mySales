/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-08-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-24-2020   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
private class IF_PsChangePjtController_Test {
    //IF-050
    private static testMethod void IF_PsChangePjtControllerTest() {
        Test.startTest();
        Test.setMock( HttpCalloutMock.class, new IF_Callout_TestMock());

        IF_PsChangePjtController.InputClass input = new IF_PsChangePjtController.InputClass();
        IF_PsChangePjtController.IS_HEADER header = new IF_PsChangePjtController.IS_HEADER();
        header.ZZORDER_ID       = 'SDS-20056210';
        header.DESCRIPTION      = '[(#)####] Test_change_service&solution';
        header.BUKRS            = 'T100';
        header.MAIN_FKSTL       = 'T100-11904';
        header.MAIN_AKSTL       = 'T100-12032';
        header.ORIGIN_CUSTOMER  = 'A0024399';
        header.CUSTOMER         = 'A0024399';
        header.SALES_PLFAZ      = '2021.10.31';
        header.SALES_PLSEZ      = null;
        header.PLFAZ            = '2020.11.01';
        header.PLSEZ            = '2021.10.31';
        header.CONTRACT_EXP_DATE= '2020.10.31';
        header.ZZSALEMP_CNO     = '15220';
        header.ZZPROPOSAL_PM_CNO= '15220';
        header.ZZBIZ_LEVEL      = 'C';
        header.ZZSUBS_PJT       = 'oppty Id';
        input.IS_HEADER         = header;
        
        IF_PsChangePjtController.IT_SERVICE service = new IF_PsChangePjtController.IT_SERVICE();
        List<IF_PsChangePjtController.IT_SERVICE> serviceList = new List<IF_PsChangePjtController.IT_SERVICE>();
        service.SERVICE_WBS     = 'SIC20056211A001';
        service.SERVICE         = '22000004';
        service.SERVICE_NAME    = '10 : Enterprise IoT';
        service.SUB_FKSTL       = 'T100-12042';
        service.SUB_AKSTL       = 'T100-12067';
        service.OPTION          = 'C';
        service.NUMBER_INT      = '10';
        service.ZZSERVICE_REP_X = 'X';
        serviceList.add(service);
        input.IT_SERVICE        = serviceList;
        
        IF_PsChangePjtController.IT_SOLUTION solution = new IF_PsChangePjtController.IT_SOLUTION();
        List<IF_PsChangePjtController.IT_SOLUTION> solutionList = new List<IF_PsChangePjtController.IT_SOLUTION>();
        solution.SERVICE_CODE   = 'SIC20056211A001';
        solution.SOLUTION_CODE  = 'SIC20056211A00132';
        solution.SOLUTION       = '30000085';
        solution.SOLUTION_NAME  = 'Brightics IoT';
        solution.GUBUN          = '4';
        solution.OPTION         = 'D';
        solution.NUMBER_INT     = '10';
        solution.ZZORDER_TYPE_S = 'S122';
        solution.ZZBIZ_TYPE_S   = 'TD';
        solution.ZZWBS_CLASS_S  = 'SC';
        solutionList.add(solution);
        input.IT_SOLUTION       = solutionList;
        
        Map<String, Object> returnMap = IF_PsChangePjtController.changePjt(input);
        Integer statusCode = Util_String.nvlInt( returnMap.get( 'StatusCode'));
        System.debug( '::::returnMap:' + returnMap);

        System.assertEquals( statusCode, 200);

        Test.stopTest();
    }
}