/**
* @description       : test class to cover functionality of 'UserActiveLogInsertion' Apex class.
* @author            : akash.g@samsung.com
* @group             : 
* @last modified on  : 08-02-2023
* @last modified by  : kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author                           Modification
* 1.0   09-02-2022   akash.g@samsung.com           Initial Version
* 1.1   08-02-2023   kajal.c@samsung.com           MySales -123 coverage
**/
@isTest
public class UserActiveLogInsertionTest {
   @isTest
    private static void userCreation() { // Contract Approval 
        Profile pf = [Select id from profile where name = 'System Administrator'];
        User u =  Utils_TestDataFactory.createUserByName(pf,'Testing1@Samsung.test');        
    }
 /** V1.1 START -- Kajal--**/
    @isTest
    private static void userUpdate() { 
        Profile pf = [Select id from profile where name = 'System Administrator'];
        User u =  Utils_TestDataFactory.createUserByName(pf,'Testing1345@Samsung.test');
        u.CompanyCode__c = 'T500';
        update u;
    }
     /** V1.1 END -- Kajal--**/
}