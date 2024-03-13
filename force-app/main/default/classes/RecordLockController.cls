/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-01-26
 * @last modified by  : hj.lee@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-10   hj.lee@dkbmc.com   Initial Version
**/
public with sharing class RecordLockController {
    
    @AuraEnabled
    public static String initComponent(String recordId){
        try {
           
            Map<String, Object> responseMap = new Map<String, Object>();

            List<PermissionSetAssignment> modifyAllUserList =  [
                SELECT AssigneeId FROM PermissionSetAssignment
                WHERE PermissionSet.PermissionsModifyAllData = true 
                AND AssigneeId = :UserInfo.getUserId()
            ];

            responseMap.put('isLocked', Approval.isLocked(recordId));
            responseMap.put('canModifyAll', !modifyAllUserList.isEmpty());

            return JSON.serialize(responseMap);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void lockRecord(String recordId){
        Approval.lock(recordId);
    }

    @AuraEnabled
    public static void unlockRecord(String recordId){
        Approval.unlock(recordId);
    }
    
}