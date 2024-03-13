/**
 * @description       : 퇴사자 혹은 장기 미사용자 처리 (User Inactive 및 개인정보 마스킹 처리)
 *                      마스킹이 필요한 개인정보 -> FirstName, LastName, Alias, Email, Username (Email의 경우 마스킹 처리 불가능)
 *                      Active 사용자를 대상으로 퇴사자 혹은 30일 이상 미접속자를 InActive
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-05-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-17   dongyoung.kim@dkbmc.com   Initial Version
 * 2.0   2021-05-24   younghoon.kim@dkbmc.com   비활성화 로직 수정
**/
global class Batch_UserActiveChangeController implements Database.Batchable<sObject>{
    /*
        [Employee Status]
        No  Status              Inactive Target
        1   Active
        2   Retiree/pensioner   √
        3   Early retiree       √
        4   Interns
        5   Terminated          √
        6   Inactive Employees  √
        7   Temp/Seasonal
        8   Expatriate
        9   External employee
        B   Non-holders (PS)
        C   Holders (PS)
    */
	
	global Integer recordsProcessed = 0;
	 
    global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, EvStatus__c, EvUniqID__c FROM Employee__c WHERE EvStatus__c IN (\'2\', \'3\', \'5\', \'6\')';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Employee__c> scope) {
        Set<String> epIdSet = new Set<String>();

        for(Employee__c e : scope){
            epIdSet.add(e.EvUniqID__c);
        }

        List<User> updateUserList = new List<User>();
        List<User> targetUserList = [SELECT Id 
                                          , Name 
                                          , FirstName 
                                          , LastName 
                                          , Alias 
                                          , UserName 
                                          , Email 
                                          , IsActive 
                                          , LastLoginDate
                                          , FederationIdentifier
                                       FROM User 
                                      WHERE IsActive = true
                                        AND (FederationIdentifier =: epIdSet OR LastLoginDate < LAST_N_DAYS:30)];

        if(targetUserList.size() > 0){
            for(User user : targetUserList){
                user.IsActive = false;
                user.FirstName = '***';
                user.LastName = '***';
                user.Username = user.Username + '.invalid';
                user.Alias = '***';

                updateUserList.add(user);

                /**
                    Q1. Email 변경하기
                    Setup -> Administration -> Users에서 Email을 직접 변경하는 경우 "Generate new password and notify user immediately" 옵션을 체크하고 변경하면
                    Email Confirm없이 Email 수정이 가능함 / 하지만 이를 Apex에서 하는 방법이 없음
                    https://trailblazers.salesforce.com/answers?id=9063A000000E5LRQA0
                    https://trailblazer.salesforce.com/ideaView?id=08730000000l1EyAAI -> 해당 내용에 대한 Case

                    2020-10-27 추가
                    Email Change Verification을 Disable하는 방법이 있었음
                    그냥은 안되고 Salesforce에 Case를 등록해서 해당 기능을 열어달라고 요청해야함
                    https://help.salesforce.com/articleView?id=000324664&type=1&mode=1 -> 관련 내용
                    
                    현재 Case 등록한 상태

                    Email Change Verification을 Disable하기위해서는 해당 기능이 필요한 User들의 정보 및 요청문서를 Salesforce에 전달해야함.
                    해당 내용이 불가능하기 때문에 이메일 마스킹 내용은 보류(추후 이슈화 예정)
                    
                    Integer endNum_email = (user.Email).indexOf('@');
                    String targetString_email = (user.Email).substring(0, endNum_email);
                    String newEmail = (user.Email).replace(targetString_email, '***');
                    user.Email = newEmail;
                /**/

                /**
                    Q1. Username의 경우도 마스킹처리가 필요한지 확인 필요
                    Q2. 마스킹 처리가 필요한 경우 중복방지 대책 필요

                    2020-10-27 추가
                    Username의 경우 중복방지를 위해서 시간-분-초@samsung.com.invalid로 변경
                    -> 시간-분-초 의 경우에도 중복이 발생할수 있어 Millitime으로 변경

                    Integer endNum_userName = (user.Username).indexOf('@');
                    String targetString_userName = (user.Username).substring(0, endNum_userName);
                    String newUsername = (user.Username).replace(targetString_userName, String.valueOf(System.currentTimeMillis())) + '.invalid';
                    user.Username = newUsername;
                /**/
            }
            
            System.debug('updateUserList :' + updateUserList);
            if(updateUserList.size() > 0){
                try{
                    update updateUserList;
                }catch(Exception e){
                    System.debug('ERROR : ' + e.getMessage());
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        List<User> userList = [SELECT Id, Name, IsActive FROM User WHERE Name LIKE '%Test%'];
        System.debug('userList.size() : ' + userList.size());
        System.debug('userList : ' + userList);
    }
    
}