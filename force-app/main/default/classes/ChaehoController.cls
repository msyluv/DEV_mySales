/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : chae_ho.yang@samsung.com
**/
public with sharing class ChaehoController {

    public DevPractice__c dev = new DevPractice__c();

    public ChaehoController() {

    }

    public void createData() {
        dev.Name = '안녕하세요!양채호';
        insert dev;
    }

    
    public void updateData() {
        DevPractice__c dev = [SELECT Id, name from DevPractice__c
                                where name = 'Hello!'];

        dev.name = '내꺼로';
        update dev;
    }

}