/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-22
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author             Modification
 * 1.0   2020-12-10   hj.lee@dkbmc.com   Initial Version
**/
@isTest
public class Utils_Test {
	static Profile profile =  Utils_TestDataFactory.getProfile('System Admin');
    static User user = Utils_TestDataFactory.createUserFull(profile, 'testUser'+System.now().millisecond()+'@samsung.com', 'test1');
    static Employee__c emp1 = Utils_TestDataFactory.createEmployee('TestEmp1', 'testEpId1');
    static Account acc = Utils_TestDataFactory.createAccount('TestAcc');
    @isTest static void utils() {
        Employee__c emp = Utils.getLoginEmployeeData(user.Id);
        // String tzi = Utils.getTimezoneId();

        // Integer offset = Utils.getTimezoneOffset(tzi, System.now());
        // Integer offset1 = Utils.getTimezoneOffset(System.now());

        // Map<String,Object> pickLableValue = Utils.getPickValueFieldLabel('Account');
        String mmId = String.valueof(acc.Id);
        Set<Id> mmIdLst = new Set<Id>();
        mmIdLst.add(acc.Id);
        // sObject obj = Utils.getObjectInfoFromRecordId(mmId);
        // sObject objS = Utils.getObjectAllFieldQuerySingle('Account',mmId);
        // List<sObject> objM = Utils.getObjectAllFieldQueryMulti('Account',mmIdLst);
        // Map<String,Object> objInfo = Utils.getObjectInfoFromRecordIdReturnMapType(mmId);
        // List<Object> allObj = Utils.getAllObjectInfo();
        Datetime curDatetime = Utils.getCurDatetime().date();
        Integer randomInteger = Utils.getRandomInteger();
        // List<Account> accList = (List<Account>)Utils.queryObject('Account', '');
        
        Map<String,Object> opptyMap = new Map<String,Object>();        
        opptyMap.put('Amount', 123);
        opptyMap.put('Probability', 20);
		Opportunity oppty = (Opportunity)Utils.mapToSObject('Opportunity', opptyMap);
        
        List<Map<String,Object>> mapList = new List<Map<String,Object>>();
        mapList.add(opptyMap);
        List<Opportunity> opptyList = Utils.mapToSObjectList('Opportunity', mapList);
        Utils.getCelloParameters();
        Utils.retrieveFieldList('Account');
        Utils.getQueryWithoutRichText('Account','');
        Utils.queryObjectWithoutRichText('Account','');
        Utils.getAllPicklistOptionType('Account');
        Utils.getObjectLabel('Account');
        Utils.makeMisId(Datetime.now());
        Utils.conversionToDate('2020-01-01');
        Utils.getFieldLabel('Account');
        Utils.getListViewId('Account','Name');

        acc.cStatus__c = '00';
        update acc;
        Utils.getPicklistMap('Account','cStatus__c');
        Utils.roundUpAmount(1.11,'KRW');
        Utils.roundUpAmount(1.11,'other');
        List<String> ownerIds = new List<String>();
        ownerIds.add(user.id);

        Utils.addCalendarViews(ownerIds,'Task','My','test','test','test','2021-01-02');        
        Utils.getDependentPicklistValues(Opportunity.LostReasonLogistics__c);
        Utils.getDependentPicklist(Opportunity.LostReasonLogistics__c);
        Utils.getQueryAddSelect('Opportunity', 'Account.AccountNumber', '', true);
        Utils.sleep(100);

        Utils.getUserDateFormat();
        Utils.getUserDateTimeFormat();
        Utils.isAdmin();
        system.debug(Utils.getIsSandbox());

        String epId = [SELECT FederationIdentifier FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].FederationIdentifier;
        Utils.getEmployeeData(epId, new Set<String>{'EvKostl__c','EvDept__c'} , null);
        Utils.getEmployeeData(epId);
        Utils.getEmployeeMap(new Set<String>{epId});
    }
}