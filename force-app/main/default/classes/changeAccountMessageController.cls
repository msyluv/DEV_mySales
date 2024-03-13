/**
 * @description       : Implement Change Account functionlity.
 * @author            : akash.g@samsung.com
 * @group             : 
 * @last modified on  : 2022-05-26
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2022-05-26   akash.g@samsung.com   Initial Version
**/
public class changeAccountMessageController {
    /**
     *  Implement Change Account functionlity.It Calls from ChangeAccountMessage Aura component.
     */
    @AuraEnabled
    public static Boolean initFunction(Id theId){
        Boolean IschangeAccount = [Select id,Is_Change_Account__c from opportunity where id =: theId].Is_Change_Account__c;
        return IschangeAccount;
    }
}