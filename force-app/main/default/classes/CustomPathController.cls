/**
* @description       : This class is used for partner status check requests coming form the guest user.
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 03-02-2022
* @last modified by  : zenith21c@test.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   02-16-2022   rakshit.s@samsung.com   Initial Version
**/

public class CustomPathController {
    
    @AuraEnabled
    public static messageWrapper getCurrentStatus(String EmailInput , String EnrollmentNumberInput){
        messageWrapper mW = new messageWrapper();
        String getStatus = '';
        If(String.isNotBlank(EmailInput) && String.isNotBlank(EnrollmentNumberInput)){
            
            List<Partner_Enrollment_Request__c> rec = new List<Partner_Enrollment_Request__c>();
            
            rec = [select id, status__c,Final_Review_Status__c from Partner_Enrollment_Request__c where Work_Email__c=: EmailInput and Name=: EnrollmentNumberInput limit 1];
            
            if(rec!=null && rec.size()>0 ){
                
                //getStatus = rec[0].status__c;
                
                if(rec[0].Final_Review_Status__c == 'Negotiated' || rec[0].Final_Review_Status__c == 'Rejected'){
                    
                    if(rec[0].Final_Review_Status__c == 'Negotiated'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[7];
                        mW.isWarning = false;
                        mW.picklistValue = null;
                        mW.isFinalReviewStatus = true;
                    }
                    
                    else if(rec[0].Final_Review_Status__c == 'Rejected'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[8];
                        mW.isWarning = false;
                        mW.picklistValue = null;
                        mW.isFinalReviewStatus = true;
                        
                    }
                    
                }
                
                else{
                    
                    if(rec[0].status__c =='Submitted'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[6];
                        mW.isWarning = false;
                        mW.picklistValue = 'Submitted';
                        mW.isFinalReviewStatus = false;
                    }
                    
                    else if(rec[0].status__c == 'In Review'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[5];
                        mW.isWarning = false;
                        mW.picklistValue = 'In Review';
                        mW.isFinalReviewStatus = false;
                    }
                    
                    else if(rec[0].status__c == 'Done Review'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[4];
                        mW.isWarning = false;
                        mW.picklistValue = 'Done Review';
                        mW.isFinalReviewStatus = false;
                        
                    }
                    
                    else if(rec[0].status__c == 'Request Additional Info'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[3];
                        mW.isWarning = false;
                        mW.picklistValue = 'Request Additional Info';
                        mW.isFinalReviewStatus = false;
                    }
                    
                    else if(rec[0].status__c == 'Assignment of Negotiator'){
                        mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[2];
                        mW.isWarning = false;
                        mW.picklistValue = 'Assignment of Negotiator';
                        mW.isFinalReviewStatus = false;
                    }
                }
                
            }
            
            else{
                mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[1];
                mW.isWarning = true;
                mW.picklistValue = '';
                mW.isFinalReviewStatus = false;
            }
            
            
        }
        
        else {
            
            //   mw.getStatus = 'Please Provide the Required Inputs before Search.';
            mw.getStatus = System.Label.partner_enrollment_status_messages_label.split(',')[0];
            mW.isWarning = true;
        }
        
        return mW;
    }
    
    @AuraEnabled
    public static Partner_Enrollment_Request__c getFormData(String EmailInput , String EnrollmentNumberInput){
        
        Partner_Enrollment_Request__c reqToUpdate = new Partner_Enrollment_Request__c();
        
        reqToUpdate = [Select toLabel(Status__c), Reviewer__c,name,id,Submitted_Date__c,Partner_Type__c,Subject__c,Company_Fax__c,Company_Name__c, Mobile_Phone__c,Company_Phone__c,Company_Website__c,Description__c,Work_Email__c,First_Name__c,Last_Name__c,Partner_ID__c from Partner_Enrollment_Request__c where Work_Email__c =: EmailInput OR Name =:EnrollmentNumberInput];
        
        if(reqToUpdate!=null) return reqToUpdate;
        else return null;
        
    }
    
    
    public class messageWrapper{
        
        @AuraEnabled
        public boolean isWarning{get;set;}
        
        @AuraEnabled
        public string getStatus{get;set;}
        
        @AuraEnabled
        public string picklistValue{get;set;}
        
        @AuraEnabled
        public boolean isFinalReviewStatus{get;set;}
    }
    
}