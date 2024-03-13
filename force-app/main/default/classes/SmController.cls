/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   07-10-2023   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class SmController {

    public DevPractice__c dev = new DevPractice__c();

    public SmController() {

    }

    public void createData() {
        dev.Name = 'Hello!';
        insert dev;
    }
}