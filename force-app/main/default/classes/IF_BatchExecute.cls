/**
 * @description       : 지터빗 네트워크 작업으로인해 사용유저 프로필 업데이트, 배치 수동 실행하기 위한 controller
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-07-30
 * @last modified by  : seonju.jin@dkbmc.com
**/
public class IF_BatchExecute {

    @AuraEnabled
    public static Map<String,Object> getInfo(){

        Map<String, Object> returnMap = new Map<String, Object>{
            'isAdminProfile' => false,
            'Target_UpdateProfile' => null,
            'CronTriggerList' => null
        };

        //로그인 유저 프로필 Admin 여부
        returnMap.put('isAdminProfile',Utils.isAdmin());

        //업데이트할 Profile 정보 가져오기 Object: BackupProfile__c
        List<BackupProfile__c> targetList = [SELECT Id, Name
                                                , User__c               //User
                                                , User__r.Name          //User
                                                , User__r.Profile.Name  //User
                                                , User__r.ProfileId     //User
                                                , BackupProfileId__c    //User backup Profile
                                                // , IsRestoreSuccess__c
                                                // , RestoreDateTime__c
                                                // , UpdateErrMsg__c
                                            FROM BackupProfile__c ];
        returnMap.put('BackupProfileList',targetList);

        //CronTrigger 정보 가져오기
        List<CronTrigger> cronTriggerList = [SELECT Id, CronJobDetailId, CronJobDetail.Name, NextFireTime, PreviousFireTime, State, StartTime, EndTime, CronExpression, TimesTriggered FROM CronTrigger];
        returnMap.put('CronTriggerList',CronTriggerList);

        return returnMap;
    }

    @AuraEnabled
    public static List<BackupProfile__c> updateRestoreUserProfile(){
        system.debug('updateRestoreUserProfile');
        List<BackupProfile__c> targetList = [SELECT Id, Name , User__c , BackupProfileId__c/* , RestoreDateTime__c,IsRestoreSuccess__c, UpdateErrMsg__c */ FROM BackupProfile__c];

        //key: UserId , Value: User
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE IsActive= true AND (NOT Profile.Name Like '%Admin%')]);

        List<User> updateUserList = new List<User>();
        //유저 프로필 원복
        for(BackupProfile__c target: targetList){
            User user = userMap.get(target.User__c);        //유저정보 가져오기
            user.ProfileId = Id.valueOf(target.BackupProfileId__c);
            updateUserList.add(user);
        }

        // Map<Id,String> errResultMap = new Map<Id,String>();
        Database.SaveResult[] srList = DataBase.update( updateUserList, false);
        // for (Database.SaveResult sr : srList) {
        //     if (!sr.isSuccess()) {
        //         // Operation failed, so get all errors              
        //         String errMsg ='';  
        //         for(Database.Error err : sr.getErrors()) {
        //             System.debug(err.getStatusCode() + ': ' + err.getMessage());
        //             errMsg += err.getStatusCode() + ': ' + err.getMessage();
        //         }
        //         errResultMap.put(sr.getId(), errMsg);
        //     }
        // }

        // List<BackupProfile__c> updateTargetList = new List<BackupProfile__c>();
        // for(BackupProfile__c target: targetList){
        //     BackupProfile__c updatetarget = (BackupProfile__c)target.clone(true);
        //     updatetarget.RestoreDateTime__c = DateTime.now();
        //     // updatetarget.UpdateErrMsg__c = errResultMap.get(target.User__c);
        //     updateTargetList.add(updatetarget);
        // }

        // if(updateTargetList.size() > 0) update updateTargetList;
        return [SELECT Id, Name , User__c , BackupProfileId__c/* , RestoreDateTime__c,IsRestoreSuccess__c, UpdateErrMsg__c */ FROM BackupProfile__c];
    }

    @AuraEnabled
    public static void IFbatchExecute(){

        //배치 실행
        //IF-133
        // system.debug('if-133 배치 실행');
        // List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_KnoxApprovalDetailController'];
        // for(CronTrigger obj : schJobList){
        //     System.abortJob(obj.id);
        // }

        // DataBase.executeBatch(new Batch_KnoxApprovalDetailController('') );

        //IF-135
        // system.debug('if-135 배치 실행');
        // List<CronTrigger> schJobList2 = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'Batch_EccUpdateStatusController'];
        // for(CronTrigger obj : schJobList2){
        // System.abortJob(obj.id);
        // }

        // Database.executebatch(new Batch_EccUpdateStatusController(''));
        //IF-141

        // system.debug('if-141 배치 실행');
        // IF_EloquaLeaderInfoController.setSchedule();
        return;
    }

    @AuraEnabled
    public static List<CronTrigger> getCronTriggerList(){
        return [SELECT Id, CronJobDetailId, CronJobDetail.Name, NextFireTime, PreviousFireTime, State, StartTime, EndTime, CronExpression, TimesTriggered FROM CronTrigger];
    }
    @AuraEnabled
    public static List<BackupProfile__c> getBackupProfileList(){
        return [SELECT Id, Name , User__c , BackupProfileId__c/* , RestoreDateTime__c,IsRestoreSuccess__c, UpdateErrMsg__c */ FROM BackupProfile__c ];
    }


    @AuraEnabled
    public static List<BackupProfile__c> updateReadOnlyProfile(){
        system.debug('updateReadOnlyProfile');
        //profile backup

        List<User> userList;
        if(Utils.getIsSandbox()){
            userList = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE IsActive= true AND (NOT Profile.Name Like '%Admin%') LIMIT 2];

        }else{
            userList = [SELECT Id, Name, ProfileId, Profile.Name FROM User WHERE IsActive= true AND (NOT Profile.Name Like '%Admin%')];
        }
        system.debug(userList);

        // List<BackupProfile__c> backupProfileList = new List<BackupProfile__c>();
        // for(User user : userList){
        //     BackupProfile__c backup = new BackupProfile__c(
        //         BackupProfileId__c = user.ProfileId,
        //         User__c = user.Id
        //     );

        //     backupProfileList.add(backup);
        // }
        // insert backupProfileList;

        //update ReadOnlyProfile
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name = 'Custom_ReadOnly' LIMIT 1];


        List<User> userUpdateList = new List<User>();
        if(profileList.size() == 0){
            throw new AuraHandledException('Custom_ReadOnly 프로필이 없습니다.');
        }else{
            Profile profile = ProfileList.get(0);

            //update User Profile
            for(User user : userList){
                user.ProfileId = profile.Id;

                userUpdateList.add(user);
                system.debug('user' + user);
            }
        }
        if(!Test.isRunningTest()) update userUpdateList;

        return [SELECT Id, Name , User__c , BackupProfileId__c/* , RestoreDateTime__c,IsRestoreSuccess__c, UpdateErrMsg__c */ FROM BackupProfile__c];
    }

}