/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 03-19-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-12-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@isTest
public class MdgAccountController_Test {
    
    @TestSetup
    static void setData(){
       
        MDGAccount__c mAcc = new MDGAccount__c();
        mAcc.Type__c = 'A';
        mAcc.BP_HEADER__c = 'test';
        mAcc.isBatch__c = 'N';
        mAcc.NAME1__c = 'test';
        mAcc.ExternalId__c = 'test1';
        insert mAcc;

        MDGAccount__c sales = new MDGAccount__c();
        sales.Type__c = 'S';
        sales.BP_HEADER__c = 'test';
        sales.AWAHR__c = '1';
        sales.ANTLF__c = '1';
        sales.LPRIO__c = '1';
        sales.isBatch__c = 'N';
        sales.ExternalId__c = 'test2';
        insert sales;
    }
    private static testMethod void test01() {
        Test.startTest();
        List<MdgAccount__c> accList = [Select Id, Name, ANTLF__c, AUFSD__c, AWAHR__c, BP_HEADER__c, BZIRK__c, CITY1__c, CITY2__c, COUNTRY__c, FAKSD__c, FAX_NUMBER__c, INCO1__c, INCO2__c, KALKS__c, KDGRP__c, KONDA__c, KTGRD__c, KUNNR__c, KURST__c, KZAZU__c, LAND1__c, LIFSD__c, LOEVM__c, LPRIO__c, NAME1__c, NAME2__c, PLTYP__c, POST_CODE1__c, REGION__c, SPART__c, STCD1__c, STCD2__c, STCD3__c, STCD4__c, STREET__c, TEL_NUMBER__c, URI_ADDR__c, VKBUR__c, VKORG__c, VSBED__c, VTWEG__c, WAERS__c, ZTERM__c, ZZJ_1KFRE__c, ZZKDGRP_C__c, ZZNSTKUNL1_T__c, ZZNSTKUNL1__c, ZZNSTKUNL2_T__c, ZZNSTKUNL2__c, ZZNSTKUNL3_T__c, ZZNSTKUNL3__c, ZZSHIPPER__c, ZZTOBUSL1_EN__c, ZZTOBUSL1_KO__c, ZZTOBUSL2_EN__c, ZZTOBUSL2_KO__c, mLOEVM__c, ExternalId__c, Type__c, ZZTOBUSL1__c, ZZTOBUSL2__c, isBatch__c  From MdgAccount__c Where Type__c = 'A'];
        List<MdgAccount__c> salesList = [Select Id, Name, ANTLF__c, AUFSD__c, AWAHR__c, BP_HEADER__c, BZIRK__c, CITY1__c, CITY2__c, COUNTRY__c, FAKSD__c, FAX_NUMBER__c, INCO1__c, INCO2__c, KALKS__c, KDGRP__c, KONDA__c, KTGRD__c, KUNNR__c, KURST__c, KZAZU__c, LAND1__c, LIFSD__c, LOEVM__c, LPRIO__c, NAME1__c, NAME2__c, PLTYP__c, POST_CODE1__c, REGION__c, SPART__c, STCD1__c, STCD2__c, STCD3__c, STCD4__c, STREET__c, TEL_NUMBER__c, URI_ADDR__c, VKBUR__c, VKORG__c, VSBED__c, VTWEG__c, WAERS__c, ZTERM__c, ZZJ_1KFRE__c, ZZKDGRP_C__c, ZZNSTKUNL1_T__c, ZZNSTKUNL1__c, ZZNSTKUNL2_T__c, ZZNSTKUNL2__c, ZZNSTKUNL3_T__c, ZZNSTKUNL3__c, ZZSHIPPER__c, ZZTOBUSL1_EN__c, ZZTOBUSL1_KO__c, ZZTOBUSL2_EN__c, ZZTOBUSL2_KO__c, mLOEVM__c, ExternalId__c, Type__c, ZZTOBUSL1__c, ZZTOBUSL2__c, isBatch__c  From MdgAccount__c Where Type__c = 'S'];
        MdgAccountController.updateAccountByMdg(accList,null);
        MdgAccountController.updateSalesAreaByMdg(salesList);

        Test.stopTest();
    }
}