/**
 * @description       : 
 * @author            : anish.jain@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-12-30
 * @last modified by  : anish.jain@partner.samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   12-30-2022   anish.jain@partner.samsung.com   Initial Version
**/

global class MDG_AccountInfoUpdate implements Database.StateFul, Database.Batchable<sobject>, Database.AllowsCallouts, schedulable {
    
    private static final String APEX_CLASS = 'MDG_AccountInfoUpdate';
    private static final String Acc_Method = 'execute';
    private static IF_Log ifLog = new IF_Log();
    private static IF_Log.BatchLog batchLog = null;
    private static Datetime deadline = Datetime.now().addMinutes(-11);
    
    public MDG_AccountInfoUpdate(){
        
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        String queryString;
        Database.QueryLocator returnScope;
        queryString = 'select Id, Name,BP_HEADER__c, CITY1__c, CITY2__c, STREET__c, POST_CODE1__c, COUNTRY__c, REGION__c, NAME1__c,NAME2__c,TEL_NUMBER__c,FAX_NUMBER__c,URI_ADDR__c,STCD1__c,STCD2__c,STCD3__c,STCD4__c,ZZJ_1KFRE__c,ZZKDGRP_C__c,ZZSHIPPER__c,ZZTOBUSL1__c,ZZTOBUSL2__c,ZZNSTKUNL1__c,ZZNSTKUNL1_T__c,ZZNSTKUNL2__c,ZZNSTKUNL2_T__c,ZZNSTKUNL3__c,ZZNSTKUNL3_T__c,mLOEVM__c,ZZCREDL_C__c from MDGAccount__c';
        System.debug('Anish Test 0 :'+queryString);
        if(Test.isRunningTest()){
        queryString +=' where Type__c = \'A\' ';   
        }
        else{
        queryString +=' where Type__c = \'A\' AND (CreatedDate >= :deadline OR LastModifiedDate >= :deadline)';
        }
        System.debug('Anish Test 1 :'+queryString);
        returnScope = DataBase.getQueryLocator( queryString);
        System.debug('Anish Test 2 :'+returnScope);
        return returnScope;
    }
    
    global void execute(Database.BatchableContext BC, List<MDGAccount__c> scopeList){
        
           List<Account> upsertList = new List<Account>();
           List<MDGAccount__c> updateList = new List<MDGAccount__c>();
           String guId     = IF_Util.generateGuid();
           SavePoint sp = DataBase.setSavePoint();
        
        try{
           Id rdType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('MDG').getRecordTypeId();
        
         for(MDGAccount__c obj : scopeList){

                Account acc             = new Account();
                
                acc.AccountNumber       = obj.BP_HEADER__c;
                acc.cStatus__c          = '01';
                acc.mCity1__c           = obj.CITY1__c;
                acc.mCity2__c           = obj.CITY2__c;
                acc.mStreet__c          = obj.STREET__c;
                acc.mPostalCode__c      = obj.POST_CODE1__c;
                acc.mCountry__c         = obj.COUNTRY__c;
                acc.mRegion__c          = obj.REGION__c;
                acc.Name                = obj.NAME1__c;
                acc.mAccNameE__c        = obj.NAME2__c;
                acc.Phone               = obj.TEL_NUMBER__c;
                acc.Fax                 = obj.FAX_NUMBER__c;
                acc.Website             = obj.URI_ADDR__c;
                acc.mTaxNumber1__c      = obj.STCD1__c;
                acc.mTaxNumber2__c      = obj.STCD2__c;
                acc.CorporateNumber__c  = obj.STCD2__c;
                acc.mTaxNumber3__c      = obj.STCD3__c;
                acc.mTaxNumber4__c      = obj.STCD4__c;
                acc.mCEOName__c         = obj.ZZJ_1KFRE__c;
                acc.mDomesticForeign__c = obj.ZZKDGRP_C__c;
                acc.mShipper__c         = obj.ZZSHIPPER__c;
                acc.mBizTypeL1Code__c   = obj.ZZTOBUSL1__c;
                acc.mBizTypeL2Code__c   = obj.ZZTOBUSL2__c;
                acc.mGroupAccL1__c      = obj.ZZNSTKUNL1__c;
                acc.mGroupAccNameL1__c  = obj.ZZNSTKUNL1_T__c;
                acc.mGroupAccL2__c      = obj.ZZNSTKUNL2__c;
                acc.mGroupAccNameL2__c  = obj.ZZNSTKUNL2_T__c;
                acc.mGroupAccL3__c      = obj.ZZNSTKUNL3__c;
                acc.mGroupAccNameL3__c  = obj.ZZNSTKUNL3_T__c;
                acc.mLoevm__c           = obj.mLOEVM__c == 'X' ? true : false;
                acc.mBizLoan__c         = obj.ZZCREDL_C__c;
                acc.ExternalId__c       = obj.BP_HEADER__c;
                acc.RecordTypeId        = rdType;
                acc.MDGCheck__c         = true;

                upsertList.add(acc);
            }
            
            TriggerHandler.bypass('Account_tr');
        
            List<Database.upsertResult> uResults = new List<Database.upsertResult>();
            if(upsertList.size()>0){
                Schema.SObjectField keys = Account.Fields.ExternalId__c;
                Database.upsert(upsertList, keys, false);
                uResults = Database.upsert(upsertList, keys, false);
            }
            
            if(updateList.size()>0){
            update updateList;
            }
        
            TriggerHandler.clearBypass('Account_tr');
        
            Integer iSuccessCnt = 0;
            Integer iFailCnt = 0;
            List<String> listFail = new List<String>();
            for(Database.upsertResult result:uResults) {
                if (result.isSuccess()){
                    iSuccessCnt++;
                }else{
                    List<Database.Error> listErrors = result.getErrors();
                    for(Database.Error error : listErrors) {
                        listFail.add(error.getMessage());
                    }                  
                }
            }
            batchLog = new IF_Log.BatchLog('IF-111', guId, APEX_CLASS+'_'+Acc_Method, 'Batch Excute', JSON.serialize(upsertList), iSuccessCnt, upsertList.size() - iSuccessCnt, listFail);
        }
        
        catch(Exception e){

            batchLog = new IF_Log.BatchLog('IF-111', guId, APEX_CLASS+'_'+Acc_Method, 'Batch Excute', 0, 0, e);  
            DataBase.rollback(sp);
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
       ifLog.createLog(batchLog); 
    }
    
    public void execute(SchedulableContext sc) {
    DataBase.executeBatch( new MDG_AccountInfoUpdate(), 5);
    }
}