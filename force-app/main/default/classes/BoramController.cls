/**
 * @description       : 
 * @author            : boram85.jung@samsung.com
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : boram85.jung@samsung.com
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   07-10-2023   boram85.jung@samsung.com   Initial Version
**/
public with sharing class BoramController {

    public DevPractice__c dev = new DevPractice__c();

    public BoramController() {

    }

    public void createData(){
        dev.Name = 'hihihihi_boram';
        insert dev;
    }

    public void updateData(){
        dev.Name = 'hihihihi_boram';
        DevPractice__c dev = [select id, name from DevPractice__c where name = 'hihihihi_boram'];
        dev.name = 'byebyebye_boram';
        update dev;
    }
}