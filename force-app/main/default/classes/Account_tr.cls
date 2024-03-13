/**
 * @description       : 
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-02-15
 * @last modified by  : sarthak.j1@samsung.com
 * Ver   Date         Author                   Modification
 * 1.0   2022-03-22   younghoon.kim@dkbmc.com  Initial Version
 * 1.1	 2023-10-01	  akash.g@samsung.com      Added MSP_INFORMATION field (MySales - 109)
 * 1.2   2024-01-25   sarthak.j1@samsung.com  Sales Lead Enhancement -> MYSALES-413
 * 1.3 	 2024-02-15   sarthak.j1@samsung.com  Sales Lead - Internal/External field changing -> MYSALES-448
**/
public class Account_tr extends TriggerHandler{
	private static List<Account> newAccList;
    private static List<Account> oldAccList;
    private static Map<Id, Account> oldAccMap;

    // Opportunity Record Type ID
    public static String RT_ACCOUNT_SALESFORCE_ID   = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Salesforce').getRecordTypeId(); 
    public static String RT_ACCOUNT_MDG_ID          = Account.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();
            
    public Account_tr() {
        newAccList = (List<Account>)Trigger.new;
        oldAccList = (List<Account>)Trigger.old;
        oldAccMap = (Map<Id, Account>)Trigger.oldMap;        
    }
    public override void beforeInsert() {
        System.debug('### Account_tr beforeInsert ###');
    }    
    public override void beforeUpdate() {
        System.debug('### Account_tr beforeUpdate ###');
    }
    public override void beforeDelete() {
        System.debug('### Account_tr beforeDelete ###');

        checkDeleteAccount(oldAccList);
    }
    public override void afterInsert() {
        System.debug('### Account_tr afterInsert ###');

        callIF(newAccList, oldAccMap);
    }    
    public override void afterUpdate() {
        System.debug('### Account_tr afterUpdate ###');

        callIF(newAccList, oldAccMap);
        //Start v-1.2 [MYSALES-413]
        updateSalesLead(newAccList, oldAccMap);
        //End v-1.2 [MYSALES-413]
    }
    public override void afterDelete() {
        System.debug('### Account_tr afterDelete ###');
    }
    
    /**
    * @description  - Salesforce Record Type : Owner, Admin 만 삭제 가능 (Role 상위, Account Team은 삭제 불가능)
    *               - MDG Record Type        : 모든 사용자 삭제 불가능 (Admin 도 삭제 불가능)
    * @author       hj.lee@dkbmc.com | 2021-05-24 
    * @param        oldList 
    **/
    private static void checkDeleteAccount(List<Account> oldList) {
        try {
            Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id, Name, UserLicenseId, UserLicense.Name, UserType, Description 
                                                                FROM Profile 
                                                                WHERE Id = :UserInfo.getProfileId()]);
            String userProfileName = profileMap.get(UserInfo.getProfileId()).Name;
            Boolean isAdminProfile = userProfileName.contains('Admin') || userProfileName.contains('관리자');
            
            for(Account oldAcc : oldList){
                if (oldAcc.RecordTypeId == RT_ACCOUNT_SALESFORCE_ID) {
                    if( !(oldAcc.OwnerId == UserInfo.getUserId() || isAdminProfile) ) {
                        oldAcc.addError(System.Label.ACCT_MSG_0005); // 삭제 권한이 없습니다. 고객 소유자 및 관리자만 삭제가 가능합니다.
                    }
                } else if(oldAcc.RecordTypeId == RT_ACCOUNT_MDG_ID) {
                    oldAcc.addError(System.Label.ACCT_MSG_0004); // MDG 고객은 삭제가 불가능합니다.
    
                }
            }
        } catch(Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
            oldList[0].addError(e.getMessage());
        }
    }

    /**
    * @description 고객성향 전송 IF(IF-153, IF-154) 호출
    * @author younghoon.kim@dkbmc.com | 2022-05-23
    * @param List<Account> newAccList 
    * @param Map<Id Account> oldAccMap 
    * @note 
    * [↓ 고객 성향 필드]
    *  - Willingness to Innovate                       // Innovation__c
    *  - Innovation Comment                            // InnovationComment__c
    *  - SDS Preference                                // SDSPreference__c
    *  - SDS Preference Description                    // SDSPreferenceComment__c
    *  - Legal Conditions                              // LegalConditions__c
    *  - Legal Conditions Comment                      // LegalConditionsComment__c
    *  - Favorable Payment Terms                       // PaymentConditions__c
    *  - Favorable Payment Terms Description           // PaymentConditionsComment__c
    *  - Financial Health                              // FinacialHealth__c
    *  - Finacial Health Comment                       // FinacialHealthComment__c
    *  - Likelihood of Changing Requirements           // RequirementsChange__c
    *  - Likelihood of Changing Req. Description       // RequirementsChangeComment__c
    *  - Operating Margin Ratio                        // OperatingProfits__c
    *  - Operating Margin Ratio Description            // RateofOperatingprofitsComment__c
    *  - Delivery Risk                                 // ProjectRisk__c
    *  - Delivery Risk Description                     // ProjectRiskComment__c
    * 
    * [↓ IT 정보 필드]
    *  - IT Investment Cost                            // ITInvestmentCost__c
    *  - IT Operation Expense                          // ITOperationExpense__c
    *  - IT Summary                                    // ITSummary__c
    *  - PLM Summary                                   // PLMSummary__c
    *  - CRM Summary                                   // CRMSummary__c
    *  - MES Summary                                   // MESSummary__c
    *  - ERP Summary                                   // ERPSummary__c
    *  - AI Summary                                    // AISummary__c
    *  - SCM Summary                                   // SCMSummary__c
    *  - Infra Summary                                 // InfraSummary__c
    *  - Other Summary                                 // EtcSummary__c
    **/
    //V 1.1 ->Added MSP_INFORMATION field (MySales - 109)
    public static List<String> fieldList = new List<String>{ // 고객 성향 필드, IT정보 필드
            'Innovation__c'
            , 'InnovationComment__c'
            , 'SDSPreference__c'
            , 'SDSPreferenceComment__c'
            , 'LegalConditions__c'
            , 'LegalConditionsComment__c'
            , 'PaymentConditions__c'
            , 'PaymentConditionsComment__c'
            , 'FinacialHealth__c'
            , 'FinacialHealthComment__c'
            , 'RequirementsChange__c'
            , 'RequirementsChangeComment__c'
            , 'OperatingProfits__c'
            , 'RateofOperatingprofitsComment__c'
            , 'ProjectRisk__c'
            , 'ProjectRiskComment__c'
            , 'ITInvestmentCost__c'
            , 'ITOperationExpense__c'
            , 'ITSummary__c'
            , 'PLMSummary__c'
            , 'CRMSummary__c'
            , 'MESSummary__c'
            , 'ERPSummary__c'
            , 'AISummary__c'
            , 'SCMSummary__c'
            , 'InfraSummary__c'
            , 'EtcSummary__c'
            , 'isStrategicCustomer__c'
            , 'SharingholdRatio__c'
            , 'MSPInformation__c'
        };
            
    private static void callIF(List<Account> newAccList, Map<Id, Account> oldAccMap) {
        Set<Id> accSet = new Set<Id>(); // IF 전송 대상 Account Id Set        

        try {
            for(Account newAcc : newAccList){
                Account oldAcc = oldAccMap != null ? oldAccMap.get(newAcc.Id) : null;
                // 1. MDG Account 여부 체크
                if(newAcc.RecordTypeId == RT_ACCOUNT_MDG_ID){
                    // 2. IF 전송 필수값 체크 (ITInvestmentCost__c, Innovation__c, SDSPreference__c 중 1개 이상)
                    // => 기능 변경. 대상 필드중 변경이 발생하면 IF 전송 수행.
                    //if((String.isNotBlank(newAcc.ITInvestmentCost__c) || String.isNotBlank(newAcc.Innovation__c) || String.isNotBlank(newAcc.SDSPreference__c))){
                        // 3. 고객 성향 필드, IT 정보 필드 수정 여부 체크
                        
                        System.debug('### Account_tr :: callIF :: newAcc = ' + newAcc);
                        if(isChangeAccountField(newAcc, oldAcc, fieldList) && isExistValueAccountField(newAcc, fieldList)){
                            accSet.add(newAcc.Id);
                        }
                    //}
                }
            }
            if(!accSet.isEmpty()){
                DataBase.executeBatch(new Batch_AccountInfoC360(2, accSet), 200); // IF-153
                DataBase.executeBatch(new Batch_AccountInfoLegacy(2, accSet), 200); // IF-154
            }
        } catch(Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');
        }
    }

    /**
    * @description 필드값의 변경 여부 판단
    * @author younghoon.kim@dkbmc.com | 2022-06-21 
    * @param Account newAccount 
    * @param Account oldAccount 
    * @param List<String> targetFieldList 
    * @return Boolean 
    **/
    public static Boolean isChangeAccountField(Account rowAcc, Account rowOldAcc, List<String> listField){
        Boolean isChange = false;

        if(rowOldAcc != null){ // Insert인 경우 Old값이 없기때문에 제외
            for (String strField : listField) {
                if (rowAcc.get(strField) != rowOldAcc.get(strField)) {
                    isChange = true;
                    break;
                }
            }
        }else{
            isChange = true;
        }
        return isChange;
    }
    
    /**
    * @description 필드에 값 있는지 여부 확인
    * @author younghoon.kim@dkbmc.com | 2022-06-21 
    * @param Account newAccount 
    * @param Account oldAccount 
    * @param List<String> targetFieldList 
    * @return Boolean 
    **/
    public static Boolean isExistValueAccountField(Account rowAcc, List<String> listField){
        Boolean isExistVal = false;
        
        for (String strField : listField) {
            if('isStrategicCustomer__c'.equals(strField)){
                if(Boolean.valueOf(rowAcc.get(strField))){
                    isExistVal = true;
                	break;
                }
            }else if (String.isNotBlank(String.valueOf(rowAcc.get(strField)))) {
                isExistVal = true;
                break;
            }
        }
        
        return isExistVal;
    }
    
    //Start v-1.2 [MYSALES-413]
    public static void updateSalesLead(List<Account> newAccList, Map<Id, Account> oldAccMap){
        List<Sales_Lead__c> slList = new List<Sales_Lead__c>();
        Map<Id, Account> accToAccountMap = new Map<Id, Account>();
        //Set<Id> accIds = new Set<Id>();
        //Map<Id, Account> accGIMap;
        for(Account acc : newAccList){
            if(acc.mDomesticForeign__c != null && acc.mDomesticForeign__c != oldAccMap.get(acc.Id).mDomesticForeign__c){
                accToAccountMap.put(acc.Id, acc);
                //accIds.add(acc.Id);
            }
        }
        /*
        if(accIds.size() > 0){
            accGIMap = new Map<Id, Account>([SELECT Id, mDomesticForeign__c FROM Account WHERE Id IN: accIds]);
        }*/
        
        
        if(accToAccountMap.size() > 0){
            for(Sales_Lead__c sl : [SELECT Id, Internal_External__c, AccountId__c FROM Sales_Lead__c WHERE AccountId__c IN : accToAccountMap.keySet()]){
               		if(accToAccountMap.get(sl.AccountId__c).mDomesticForeign__c == '10'){
                    	sl.Internal_External__c = 'Internal';
                        slList.add(sl);      
                    }
                    if(accToAccountMap.get(sl.AccountId__c).mDomesticForeign__c == '20'){
                        sl.Internal_External__c = 'External';
                        slList.add(sl);
                    }
            }                                
        }
        
        if(slList.size() > 0){
            //Start v-1.3 [MYSALES-448]
			Sales_Lead_Update__c slUpdate = Sales_Lead_Update__c.getValues('UpdateLead');
    		slUpdate.Update_Through_Account__c = false;
            update slUpdate;
            //End v-1.3 [MYSALES-448]
            
            update slList;
            
            //Start v-1.3 [MYSALES-448]
            slUpdate.Update_Through_Account__c = true;
            update slUpdate;
            //End v-1.3 [MYSALES-448]
        }
    }
    //End v-1.2 [MYSALES-413]
}