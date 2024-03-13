/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-16-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   02-16-2021   woomg@dkbmc.com   Initial Version
**/
@isTest
private class ContactDetailController_Test {
    static Contact con;

    static{
        con = new Contact(LastName='Test', FirstName='User', OwnerId=UserInfo.getUserId());
        insert con;
    }

    @IsTest
    private static void testMethodOne() {
        Test.startTest();
        system.debug(ContactDetailController.checkContactOwner(con.Id));
        try {
            system.debug(ContactDetailController.checkContactOwner(null));
        } catch(Exception e){
            //
        }
        Test.stopTest();
    }
}