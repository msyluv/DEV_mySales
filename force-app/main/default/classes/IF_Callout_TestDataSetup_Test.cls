/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-21
 * @last modified by  : ghkil@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   01-08-2021   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class IF_Callout_TestDataSetup_Test {
    public IF_Callout_TestDataSetup_Test() {    }

    @isTest
    static void test() {
        IF_Callout_TestDataSetup.dataSetup();
        IF_Callout_TestDataSetup.mdgBusinessMasterInsert( 1);
    }
}