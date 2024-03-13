/**
 * @File Name          : Util_String.cls
 * @Description        :
 * @Author             : kilhwan.an@partner.samsung.com
 * @Group              :
 * @Last Modified By   : woomg@dkbmc.com
 * @Last Modified On   : 05-04-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    2020. 11. 12.   kilhwan.an@partner.samsung.com     Initial Version
**/
@isTest
private class Util_String_Test {

    private static testMethod void Util_StringTest(){

        System.assertEquals( Util_String.nvlStr( 'Test'), 'Test');
        System.assertEquals( Util_String.nvlDec( 0), 0);
        System.assertEquals( Util_String.nvlInt( 1), 1);
        System.assertEquals( Util_String.nvlInt( null, 2), 2);
        System.assertEquals( Util_String.nvlDob( 1), 1);
        System.assertEquals( Util_String.nvlStr( null,'Test'), 'Test');
        System.assertEquals( Util_String.nvlDec( null,1), 1);
        System.assertNotEquals( Util_String.convertStringDate( '9999-12-31'), null);
        System.assertNotEquals( Util_String.convertStringDateTime( '20210504123030'), null);
        System.assertNotEquals( Util_String.convertDateString( Date.today()), null);

        System.assertNotEquals( Util_String.convertDateString( Date.today(), 'Asia/seoul'), null);
        System.assertNotEquals( Util_String.convertDateTimeString( Date.today(), 'Asia/seoul'), null);
        Util_String.convertTimeZone(Datetime.now(), 'Asia/seoul');
    }
}