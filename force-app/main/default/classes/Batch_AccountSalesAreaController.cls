/**
 * @description       : MDGAccount__c(Dummy Object) 에서 AccountSalesArea__c 정보를 Upsert
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 02-25-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-18-2020   soohong0.kim@partner.samsung.com   Initial Version
**/

//Test Class -> Batch_AccountMdgController_Test
global class Batch_AccountSalesAreaController implements Database.StateFul, Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable {
    private final String APEX_CLASS      = 'Batch_AccountSalesAreaController';
    private IF_Log.BatchLog batchLog     = null;
    private List<IF_Log.BatchLog> batchLogList = new List<IF_Log.BatchLog>();
    private List<AccountSalesArea__c> uSalesList = new List<AccountSalesArea__c>();
    private List<MDGAccount__c> uMdgList = new List<MDGAccount__c>();
    private IF_Log ifLog = new IF_Log();
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, ';
        query+='SystemModstamp, LastActivityDate, ANTLF__c, AUFSD__c, AWAHR__c, BP_HEADER__c, BZIRK__c, CITY1__c, CITY2__c, COUNTRY__c, FAKSD__c, ';
        query+='FAX_NUMBER__c, INCO1__c, INCO2__c, KALKS__c, KDGRP__c, KONDA__c, KTGRD__c, KUNNR__c, KURST__c, KZAZU__c, LAND1__c, LIFSD__c, LOEVM__c, ';
        query+='LPRIO__c, NAME1__c, NAME2__c, PLTYP__c, POST_CODE1__c, REGION__c, SPART__c, STCD1__c, STCD2__c, STCD3__c, STCD4__c, STREET__c, TEL_NUMBER__c, ';
        query+='URI_ADDR__c, VKBUR__c, VKORG__c, VSBED__c, VTWEG__c, WAERS__c, ZTERM__c, ZZJ_1KFRE__c, ZZKDGRP_C__c, ZZNSTKUNL1_T__c, ZZNSTKUNL1__c, ';
        query+='ZZNSTKUNL2_T__c, ZZNSTKUNL2__c, ZZNSTKUNL3_T__c, ZZNSTKUNL3__c, ZZSHIPPER__c,';
        query+=' mLOEVM__c, ExternalId__c, Type__c, isBatch__c ';
        query+=' FROM MDGAccount__c ';
        query+=' WHERE Type__c = \'S\' ';
        
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext bc, List<MDGAccount__c> objList) {

        system.debug('raw data size : '+objList.size());
        Map<String,String> keyMap = new Map<String,String>();
        List<AccountSalesArea__c> salesList = new List<AccountSalesArea__c>();
        String guId     = IF_Util.generateGuid();
        SavePoint sp = DataBase.setSavePoint();
        try{

            Set<String> accNo = new Set<String>();
            for(MDGAccount__c obj : objList){
                accNo.add(obj.BP_HEADER__c);
            }

            List<Account> accList = [select id, AccountNumber from account where AccountNumber in: accNo];
            for(Account obj : accList){
                keyMap.put(obj.AccountNumber,obj.id);
            }

            List<MDGAccount__c> mdgAcctList = new List<MDGAccount__c>();
            for(MDGAccount__c obj : objList){
                AccountSalesArea__c sales = new AccountSalesArea__c();
                sales.Name = obj.VKORG__c+obj.SPART__c+obj.VTWEG__c;
                sales.VKORG__c = obj.VKORG__c;
                sales.VTWEG__c = obj.VTWEG__c;
                sales.SPART__c = obj.SPART__c;
                sales.AWAHR__c = Decimal.valueOf(obj.AWAHR__c);
                sales.BZIRK__c = obj.BZIRK__c;
                sales.AUFSD__c = obj.AUFSD__c;
                sales.FAKSD__c = obj.FAKSD__c;
                sales.INCO1__c = obj.INCO1__c;
                sales.INCO2__c = obj.INCO2__c;
                sales.LIFSD__c = obj.LIFSD__c;
                sales.LOEVM__c = obj.LOEVM__c;
                sales.WAERS__c = obj.WAERS__c;
                sales.ZTERM__c = obj.ZTERM__c;
                sales.KALKS__c = obj.KALKS__c;
                sales.KDGRP__c = obj.KDGRP__c;
                sales.KTGRD__c = obj.KTGRD__c;
                sales.KURST__c = obj.KURST__c;
                sales.VKBUR__c = obj.VKBUR__c;
                sales.ANTLF__c = Decimal.valueOf(obj.ANTLF__c);
                sales.VSBED__c = obj.VSBED__c;
                sales.KZAZU__c = obj.KZAZU__c;
                sales.LPRIO__c = Decimal.valueOf(obj.LPRIO__c);
                sales.PLTYP__c = obj.PLTYP__c;
                sales.KONDA__c = obj.KONDA__c;
                sales.ExternalId__c = obj.ExternalId__c;
                sales.AccountId__c = keyMap.get(obj.BP_HEADER__c);
                
                //MDGAccount 오브젝트 레코드에 Batch 완료 Flag Update 처리
                obj.isBatch__c = 'Y';

                uSalesList.add(sales);
                uMdgList.add(obj);
            }
            
            
            
            batchLog = new IF_Log.BatchLog('', guId, APEX_CLASS, 'Batch Excute', salesList.size());
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
        upsert uSalesList ExternalId__c;
        update uMdgList;
    }

    global void execute(SchedulableContext sc) {
        database.executebatch(new Batch_AccountSalesAreaController(), 100);
    }

}