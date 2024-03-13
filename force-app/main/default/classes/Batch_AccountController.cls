/**
 * @description       : MDGAccount__c(Dummy Object) 에서 Account 정보를 Upsert
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-25-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-18-2020   soohong0.kim@partner.samsung.com   Initial Version
**/

//Test Class -> Batch_AccountMdgController_Test
global class Batch_AccountController implements  Database.StateFul, Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private final String APEX_CLASS      = 'Batch_AccountController';
    private IF_Log.BatchLog batchLog     = null;
    private List<IF_Log.BatchLog> batchLogList = new List<IF_Log.BatchLog>();
    private List<Account> uAccList = new List<Account>();
    private List<MDGAccount__c> uMdgList = new List<MDGAccount__c>();
    private IF_Log ifLog = new IF_Log();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, ';
        query+='SystemModstamp, LastActivityDate, ANTLF__c, AUFSD__c, AWAHR__c, BP_HEADER__c, BZIRK__c, CITY1__c, CITY2__c, COUNTRY__c, FAKSD__c, ';
        query+='FAX_NUMBER__c, INCO1__c, INCO2__c, KALKS__c, KDGRP__c, KONDA__c, KTGRD__c, KUNNR__c, KURST__c, KZAZU__c, LAND1__c, LIFSD__c, LOEVM__c, ';
        query+='LPRIO__c, NAME1__c, NAME2__c, PLTYP__c, POST_CODE1__c, REGION__c, SPART__c, STCD1__c, STCD2__c, STCD3__c, STCD4__c, STREET__c, TEL_NUMBER__c, ';
        query+='URI_ADDR__c, VKBUR__c, VKORG__c, VSBED__c, VTWEG__c, WAERS__c, ZTERM__c, ZZJ_1KFRE__c, ZZKDGRP_C__c, ZZNSTKUNL1_T__c, ZZNSTKUNL1__c, ';
        query+='ZZNSTKUNL2_T__c, ZZNSTKUNL2__c, ZZNSTKUNL3_T__c, ZZNSTKUNL3__c, ZZSHIPPER__c, ';
        query+=' mLOEVM__c, ExternalId__c, Type__c, ZZTOBUSL1__c, ZZTOBUSL2__c, isBatch__c, ZZCREDL_C__c ';
        query+=' FROM MDGAccount__c where Type__c = \'A\' AND isBatch__c = \'N\' ';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<MDGAccount__c> objList) {

        system.debug('raw data size : '+objList.size());
        
        String guId     = IF_Util.generateGuid();
        List<Account> accList = new List<Account>();
        SavePoint sp = DataBase.setSavePoint();
        try{
            
            // 고객 생성 매핑
            List<MDGAccount__c> mdgAcctList = new List<MDGAccount__c>();
            for(MDGAccount__c obj : objList){

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
                acc.mLoevm__c           = obj.mLoevm__c == 'X' ? true : false;
                acc.mBizLoan__c         = obj.ZZCREDL_C__c;
                acc.ExternalId__c       = obj.BP_HEADER__c;
                acc.MDGCheck__c = true;
                accList.add(acc);
                
                //MDGAccount 오브젝트 레코드에 Batch 완료 Flag Update 처리
                obj.isBatch__c = 'Y';

                uMdgList.add(obj);
                uAccList.add(acc);

            }
        
            
          
            
            batchLog = new IF_Log.BatchLog('', guId, APEX_CLASS, 'Batch Excute', accList.size());
        }catch(Exception e){

            batchLog = new IF_Log.BatchLog('', guId, APEX_CLASS, 'Batch Excute', 0, 0, e);    
            DataBase.rollback(sp);
        }

        batchLogList.add(batchLog);
    }

    global void finish(Database.BatchableContext bc) {
        //Log생성
        for(IF_Log.BatchLog obj :batchLogList){
            obj.ApexMethod = 'execute';
            ifLog.createLog( obj );
        }

        // upsert 처리
        upsert uAccList ExternalId__c;
        update uMdgList;
        //  후속 배치: 매출 부서( SalesArea)
        DataBase.executeBatch( new Batch_AccountSalesAreaController(), 200);
    }

    global void execute(SchedulableContext sc) {
        database.executebatch(new Batch_AccountController(), 100);
    }

}