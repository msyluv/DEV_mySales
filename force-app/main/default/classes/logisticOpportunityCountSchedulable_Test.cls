/**
 * @description       : Test class of logisticOpportunityCountSchedulable 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-06-07
 * @last modified by  : d.ashish@samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-06-07   d.ashish@samsung.com   Initial Version
**/
@isTest
public class logisticOpportunityCountSchedulable_Test {
    @testsetup
    static void createBoMatrix(){
        //SJOSHI start: Updated below 1 line, changed EUROPE to EUROPE/CIS as per requirement
        List<String> clist = new List<String>{'CHINA','EUROPE/CIS','KOREA','LATIN AMERICA','MEIA','NORTH AMERICA','PACIFIC'};
        //SJOSHI end
            List<BO_Matrix_cnt__c> mylist = new list<BO_Matrix_cnt__c>();
        for(integer i=0; i<7;i++){
            for(integer j=0;j<7;j++){
                mylist.add(new BO_Matrix_cnt__c(From_RHQ__c=clist[i], To_RHQ__c =clist[j], Count__c=0)); 
            }
        }
        insert mylist;
    }
    
    @isTest
    public static void testlogisticOpportunityCountSchedulable(){
        String schedmon5am = '0 00 05 ? * 2';  //Every Monday, 5AM
        logisticOpportunityCountSchedulable SC = new logisticOpportunityCountSchedulable(); 
        System.schedule('Schedule logisticOpportunityCountSchedulable - Monday 5AM', schedmon5am, SC);
    }
}