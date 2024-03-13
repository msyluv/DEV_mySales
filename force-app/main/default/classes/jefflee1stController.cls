/**
 * @description       : 
 * @author            : oldman.sea@samsung.com
 * @group             : 
 * @last modified on  : 07-10-2023
 * @last modified by  : oldman.sea@samsung.com
**/
public with sharing class jefflee1stController {
    public jefflee1stController() {

    }

    public DevPractice__c dev = new DevPractice__c();

    public void createData(){

        dev.Name ='안녕하세요 이상혁님!!!';
        insert dev;
    }



}