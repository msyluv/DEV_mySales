/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-05-13
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-02-22   Junghwa.Kim@dkbmc.com   Initial Version
**/
@isTest
public class Schedule_OpptyEmailAlertController_Test {
    @isTest
    public static void Schedule_OpptyEmailAlertControllerTest() {
        Test.startTest();
        Schedule_OpptyEmailAlertController so = new Schedule_OpptyEmailAlertController();
        so.stageChangeFlag = true; // false 일경우 Opportunity Stage 변경안함
        System.schedule('Batch_OpptyEmailAlertController', '0 0 3 * * ?', so);
        Test.stopTest();
    }
}