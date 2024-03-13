/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-17
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2021-03-17   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class FeedItemTrigger_Test {

    @isTest 
    static void testFeedItem() {
        FeedItem fi = new FeedItem(
            Type = 'ContentPost'
        );
        Boolean flagInsertFail = false;
        try {
            insert fi;
        } catch (Exception e) {
            flagInsertFail = true;
        }
        system.assertEquals(true, flagInsertFail);
    }
}