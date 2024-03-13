/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 02-04-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
public class AccountLinkController { 
    @AuraEnabled
    public static Map<String, Object> getAccountId(String accNo){
        Map<String, String> rtnMap = new Map<String, String>();
        List<Account> ids = [select id from account where AccountNumber=:accNo];
        rtnMap.put('cnt', String.valueOf(ids.size()));
        if(ids.size()==1){
            rtnMap.put('id', String.valueOf(ids[0].id));
        }
        return rtnMap;
    }
}