/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 02-27-2022
 * @last modified by  : zenith21c@test.com
**/

public  class PartnerSignupRequestFormController {
    
    @AuraEnabled(cacheable = true)
    public static TnCData getData(){
        TnCData tN= new TnCData();
        List<Partner_T_C_Master__c> tnCList = new List<Partner_T_C_Master__c>();
        tnCList = [select id
                        , T_C_Detail__c 
                        , T_C_Type__c
                        , T_C_Use__c
                     from Partner_T_C_Master__c
                    where isActive__c = true
                      and T_C_Use__c = 'Sign Up'];
        
        for(Partner_T_C_Master__c pT : tnCList){
            if(pT.T_C_Type__c == 'Collection and Use of Personal Information'){
                tN.collectPersonalInfo = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            
            else if(pT.T_C_Type__c == 'Cross-border Transfer of Personal Information'){
                tN.crossBorderTransfer = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            else if(pT.T_C_Type__c == 'Terms of Service'){
                tN.termsOfService = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
            else if(pT.T_C_Type__c == 'Fourteen years'){
                tN.fourteenYearsOld = pT.T_C_Detail__c;
                tN.recId.add(pT.id);
            }
        }
        return tN;
    }


    @AuraEnabled
    public static String isDuplicate(String emailEnteredVal){
        String userSignupStatus = 'NA';
        String s1 = emailEnteredVal + '.sdspartner';
        
        if(String.isNotBlank(emailEnteredVal)){            
            List<user> u = [SELECT id
                                 , Username
                              FROM User
                             WHERE Username = :s1
                               AND IsActive = true];//s1 = UserEmailEntered(emailEnteredVal) + .sdspartner
            if(u!=null && u.size()>0){
                userSignupStatus = 'Exist';
            }
           
            List<Partner_Signup_Request__c> sList  = [SELECT Status__c
                                                        FROM Partner_Signup_Request__c
                                                       WHERE (Partner_ID__c = :s1 OR User_Email__c = :emailEnteredVal)
                                                       ORDER BY Create_Date__c desc];//emailEnteredVal = UserEmailEntered(emailEnteredVal)
            
            if(sList!=null && sList.size()>0){
                Partner_Signup_Request__c temp = sList.get(0);
                
                if (temp.Status__c == 'Completed'){
                    userSignupStatus = 'Exist';
                }
                else{
                    userSignupStatus = 'Request';
                }
            }
        }

        return (userSignupStatus);
    }
    
    @AuraEnabled()
    public static String createPsrRec(String cName
                                    , String fname
                                    , String lname
                                    , String phone
                                    , String emailEntered
                                    ){
        Partner_Signup_Request__c psr = new Partner_Signup_Request__c();
        psr.Company_Name__c = cName;
        psr.First_Name__c = fname;
        psr.Last_Name__c = lname;
        psr.User_Email__c = emailEntered;
        psr.Partner_ID__c = emailEntered + '.sdspartner';
        psr.Mobile_Phone__c = phone;
        psr.status__c = 'Requested';
        psr.Create_Date__c = Date.today();

        insert psr;
        
        return psr.id;
    }
    
    @AuraEnabled
    public static void createRelatedTnCRec(String psrecId , List<String> tnCList){
        List<Partner_Signup_T_C_Agreement__c> pStc = new List<Partner_Signup_T_C_Agreement__c>();
        
        for(String tncidVal: tncList){
            Partner_Signup_T_C_Agreement__c pS = new Partner_Signup_T_C_Agreement__c();
            pS.isAgree__c = true;
            pS.Partner_Signup__c = psrecId.replaceAll('"', '');
            pS.Agreement_Date__c = Date.today();
            pS.Partner_T_C_Name__c = tncidVal.replaceAll('"', '');
            pStc.add(pS);
        }
        
        insert pStc;
    }
    
    public class TnCData{
        
        @AuraEnabled
        public string collectPersonalInfo{get;set;}
        @AuraEnabled
        public string crossBorderTransfer{get;set;}
        @AuraEnabled
        public string termsOfService{get;set;}
        @AuraEnabled
        public string fourteenYearsOld{get;set;}
        @AuraEnabled
        public List<string> recId =  new List<String>();
        
    }
}