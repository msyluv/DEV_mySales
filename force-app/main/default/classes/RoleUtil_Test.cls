/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 11-03-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   11-03-2020   woomg@dkbmc.com   Initial Version
**/
@isTest
private class RoleUtil_Test {
	
	@isTest static void test_method_one() {
        
        /*
        // test the output in system debug with role Id
        Id roleId = '00E90000000pMaP';
        RoleNodeWrapper startNodeWithRoleId = RoleUtil.getRootNodeOfUserTree(roleId);
        String strJsonWithRoleId = JSON.serialize(startNodeWithRoleId);
        system.debug(strJsonWithRoleId);
        */
        //system.debug('****************************************************');

        // now test the output in system debug with userId
        Id userId = UserInfo.getUserId() ;
        /*
        RoleNodeWrapper startNodeWithUserId = RoleUtil.getRootNodeOfUserTree(userId);
        String strJsonWithUserId = JSON.serialize(startNodeWithUserId);
        system.debug(strJsonWithUserId);
        */
        
        // test whether all subordinates get added
        //Id userId = '005900000011xZv';
        String str = RoleUtil.getTreeJSON(userId, true);
        //List<User> tmpUsrList = RoleUtil.getAllSubordinates('00E90000000pMaP');
        //system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%tmpUsrList:' + tmpUsrList);
	}
}