@isTest
private class TestCusotmPathController {
    
    @testSetup static void setup() {
        
        for(integer i=0; i<8; i++){
            Partner_Enrollment_Request__c cc = new Partner_Enrollment_Request__c();
            
            if(i == 0){
                cc.status__c = 'Negotiated';
                cc.Final_Review_Status__c = 'Negotiated';
            }
            
            if(i ==1){
                cc.status__c = 'Rejected';
                cc.Final_Review_Status__c = 'Rejected';
            }
            
            if(i ==2){
                cc.status__c = 'Submitted';
            }
            if(i ==3){
                cc.status__c = 'In Review';
            }
            if(i ==4){
                cc.status__c = 'Done Review';
            }
            if(i ==5){
                cc.status__c = 'Request Additional Info';
            }
            
            if(i ==6){
                cc.status__c = 'Request Additional Info';
            }
            
            if(i ==7){
                cc.status__c = ' Assignment of Negotiator';
            }
            
            cc.Work_Email__c = 'testclass@test.com';
            //cc.Name = 'testNAME';
            insert cc;
            
            
        }
        
        
    }
    
    static testMethod void testData(){
        
       List<Partner_Enrollment_Request__c>  pp = new List<Partner_Enrollment_Request__c>();
        
        pp = [select id, status__c,Final_Review_Status__c , Work_Email__c, Name from Partner_Enrollment_Request__c];
        for(Partner_Enrollment_Request__c cc : pp){
            system.debug('pp----->' + cc.status__c);
            custompathcontroller.getCurrentStatus('testclass@test.com', cc.name);
        }
    }
}