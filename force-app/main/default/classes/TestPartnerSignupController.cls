/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-15-2022
 * @last modified by  : zenith21c@test.com
**/
@isTest
private class TestPartnerSignupController {
    
    
    @testSetup static void setup() {
        // Create common test accounts
        
        for(integer i =0 ; i<3 ; i++){
            Partner_T_C_Master__c rec =new Partner_T_C_Master__c();
            
            rec.isActive__c  = true;
            rec.Apply_Date__c = date.today();
            rec.T_C_Use__c = 'Sign Up';
            rec.Cannot_Uncheck__c = false;
            rec.isMandatory__c = true;
            rec.Name = 'test data';
            rec.T_C_Detail__c = 'this is sample data';
            if(i ==0){
                rec.T_C_Type__c = 'Cross-border Transfer of Personal Information';
            }
            if(i ==1){
                rec.T_C_Type__c = 'Collection and Use of Personal Information';
            }
            if(i ==2){
                rec.T_C_Type__c = 'Terms of Service';
            }
            
            insert rec;
        }
    }


    static testMethod void testgetData(){
        
        List<Partner_T_C_Master__c> pT = new list<Partner_T_C_Master__c>();
       
        pT = [select id, T_C_Detail__c , T_C_Type__c, T_C_Use__c from Partner_T_C_Master__c where isActive__c =true and T_C_Use__c = 'Sign up'];
        List<String> pTIds = new list<String>();
        for(Partner_T_C_Master__c pp : pT){
            pTIds.add(pp.id);
        }
        PartnerSignupRequestFormController.getData();
        String returnVar = PartnerSignupRequestFormController.isDuplicate('testtesttest@test.com');
        
        system.assertEquals('NA', returnVar);
        
        String Idrec = PartnerSignupRequestFormController.createPsrRec('Company Name', 'First Name', 'Last Name', '010-1234-1234', 'testtesttest@test.com');
        system.assertEquals(Idrec, Idrec);
        PartnerSignupRequestFormController.createRelatedTnCRec(Idrec, pTIds);
    }
}