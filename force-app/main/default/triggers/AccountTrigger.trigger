/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-06-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-05-24   hj.lee@dkbmc.com          Initial Version
 * 1.1   2022-05-23   younghoon.kim@dkbmc.com   callIF 추가 / 고객성향 전송 IF(IF-153, IF-154) 호출
 * 1.2   2022-06-16   younghoon.kim@dkbmc.com   Trigger 호출 후 로직 수행방식 변경 (Account_tr 추가)
**/
trigger AccountTrigger on Account (before insert, before delete, after insert, after update) {
    TriggerSwitch__c trSwitch = TriggerSwitch__c.getInstance(UserInfo.getUserId()); // Current User 기준으로 Custom Setting 가져옴
    Boolean AllSwitch = trSwitch.All__c;
    Boolean MigSwitch = trSwitch.Migration__c; // Data Migration 시 제외할 로직인 경우 true

    if(AllSwitch) {
        if(!MigSwitch) new Account_tr().run();
    }
}