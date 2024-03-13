/**
 * @description       : 
 * @author            : yeongju.baek@dkbmc.com
 * @group             : 
 * @last modified on  : 10-22-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   10-22-2021   yeongju.baek@dkbmc.com   Initial Version
**/
@isTest(SeeAllData = True)
public class Batch_UpdateUserInfoController_Test2 {
    @isTest
    public static void UpdateUserInfoTest_2(){
        Test.startTest();
            DataBase.executeBatch( new Batch_UpdateUserInfoController(), 1000);
        Test.stopTest();
    }

}