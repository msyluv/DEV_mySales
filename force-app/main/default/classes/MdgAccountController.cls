/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2022-06-21
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-12-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   02-15-2021   kilhwan.an@partner.samsung.com     Account 사용 중단 필드를 checkbox 필드 변경, 신용 등급 신규 필드 추가
 * 1.2   06-20-2022   younghoon.kim@partner.samsung.com  IF-111을 통해 MDG Account를 생성, 수정하는 경우에는 트리거 로직 패스
**/
public class MdgAccountController {
    private static final String APEX_CLASS = 'MdgAccountController';
    private static final String Acc_Method = 'updateAccountByMdg';
    private static final String SalesArea_Method = 'updateSalesAreaByMdg';
    private static IF_Log ifLog = new IF_Log();
    private static IF_Log.BatchLog batchLog = null;
    private static List<IF_Log.BatchLog> logList = new List<IF_Log.BatchLog>();

    public static void updateSalesAreaByMdg(List<MDGAccount__c> objList){
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
                
                salesList.add(sales);
                obj.isBatch__c = 'Y';
                
            }

            upsert salesList ExternalId__c;
            //MDGAccount 오브젝트 레코드에 Batch 완료 Flag Update 처리
            update objList;

            batchLog = new IF_Log.BatchLog('IF-111', guId, APEX_CLASS+'_'+SalesArea_Method, 'Batch Excute', salesList.size());
        }catch(Exception e){
            batchLog = new IF_Log.BatchLog('IF-111', guId, APEX_CLASS+'_'+SalesArea_Method, 'Batch Excute', 0, 0, e); 
            DataBase.rollback(sp);
        }
        ifLog.createLog(batchLog);
    }
    public static void updateAccountByMdg(List<MDGAccount__c> objList, String AccountId){
        System.debug('### MdgAccountController :: updateAccountByMdg :: objList = ' + objList);
        System.debug('### MdgAccountController :: updateAccountByMdg :: AccountId = ' + AccountId);
        
        
        String guId     = IF_Util.generateGuid();
        List<Account> updateList = new List<Account>();
        List<Account> upsertList = new List<Account>();
        SavePoint sp = DataBase.setSavePoint();
        try{
            
            List<RecordType> rdTypeList = [ 
                SELECT ID
                      ,name
                      ,DeveloperName 
                FROM   RecordType 
                WHERE  SObjectType    = 'Account' 
                AND    isActive       = true 
                AND    DeveloperName  = 'MDG'
            ];

            // 고객 생성 매핑
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
                //acc.mLoevm__c           = obj.LOEVM__c;
                acc.mLoevm__c           = obj.mLOEVM__c == 'X' ? true : false;
                acc.mBizLoan__c         = obj.ZZCREDL_C__c;
                acc.ExternalId__c       = obj.BP_HEADER__c;
                acc.RecordTypeId        = rdTypeList.get( 0).Id;
                acc.MDGCheck__c         = true;
                /*
                if(AccountId != null && AccountId != '') {
                    acc.id = AccountId;
                    updateList.add(acc);
                }
                else{
                    upsertList.add(acc);
                }
                */
                upsertList.add(acc);
                obj.isBatch__c = 'Y';
            
            }
        
            TriggerHandler.bypass('Account_tr'); // 2022-06-20 / younghoon.kim / IF-111을 통해 MDG Account를 생성, 수정하는 경우에는 트리거 로직 패스
           
            List<Database.upsertResult> uResults = new List<Database.upsertResult>();
            if(upsertList.size()>0){
                Schema.SObjectField keys = Account.Fields.ExternalId__c;
                Database.upsert(upsertList, keys, false);
                uResults = Database.upsert(upsertList, keys, false);
            }
            
            TriggerHandler.clearBypass('Account_tr'); // 2022-06-20 / younghoon.kim / IF-111을 통해 MDG Account를 생성, 수정하는 경우에는 트리거 로직 패스

            //MDGAccount 오브젝트 레코드에 Batch 완료 Flag Update 처리          
            
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
            
        }catch(Exception e){

            batchLog = new IF_Log.BatchLog('IF-111', guId, APEX_CLASS+'_'+Acc_Method, 'Batch Excute', 0, 0, e);  
            DataBase.rollback(sp);
        }

        ifLog.createLog(batchLog);
    }

}