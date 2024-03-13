/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-13-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-30   ghkil@partner.samsung.com   Initial Version
 * 2.0   2021-01-12   soohong0.kim@partner.samsung.com  전체 수정
**/
@isTest
public class IF_MdgAccountController_Test {

    // IF_MdgAccountController 테스트 클래스
    // INTERFACE_ID = 'IF-111';
    // APEX_CLASS   = 'IF_MdgAccountController';
    // METHOD_NAME  = 'saveAccountMaster';    

    final static String REQUEST_URL = '/services/apexrest/WebService/IF111';

    public IF_MdgAccountController_Test() {    }

    @TestSetup
    static void setData(){


    }

    @isTest
    static void restServiceTest() {
        Test.startTest();

        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = REQUEST_URL;
        request.httpMethod = 'POST';
        
        //BP
        IF_MdgAccountController.BP bp = new IF_MdgAccountController.BP();
        List<IF_MdgAccountController.BP> bpList = new List<IF_MdgAccountController.BP>();

        IF_MdgAccountController.ADRESS ADRESS = new IF_MdgAccountController.ADRESS();
        List<IF_MdgAccountController.ADRESS> adressList = new List<IF_MdgAccountController.ADRESS>();
        ADRESS.ADDRNUMBER = '1234';
        
        //ADRESS_ADRC
        IF_MdgAccountController.ADRESS_ADRC adress_adrc = new IF_MdgAccountController.ADRESS_ADRC();
        List<IF_MdgAccountController.ADRESS_ADRC> adress_adrcList = new List<IF_MdgAccountController.ADRESS_ADRC>();
        adress_adrc.NATION = 'test';
        adress_adrc.CITY1 = 'test';
        adress_adrc.CITY2 = 'test';
        adress_adrc.STREET = 'test';
        adress_adrc.POST_CODE1 = 'test';
        adress_adrc.COUNTRY = 'test';
        adress_adrc.LANGU = 'test';
        adress_adrc.REGION = 'test';
        adress_adrc.TRANSPZONE = 'test';
        adress_adrc.SORT1 = 'test';
        adress_adrc.SORT2 = 'test';
        adress_adrc.TAXJURCODE = 'test';
        adress_adrc.TIME_ZONE = 'test';
        adress_adrc.NAME1 = 'test';
        adress_adrc.NAME2 = 'test';
        adress_adrc.NAME3 = 'test';
        adress_adrc.NAME4 = 'test';
        adress_adrc.TITLE = 'test';
        adress_adrcList.add(adress_adrc);
        ADRESS.ADRC = adress_adrcList;

        //ADRESS_ADR2
        IF_MdgAccountController.ADRESS_ADR2 adress_adr2 = new IF_MdgAccountController.ADRESS_ADR2();
        List<IF_MdgAccountController.ADRESS_ADR2> adress_adr2List = new List<IF_MdgAccountController.ADRESS_ADR2>();
        adress_adr2.CONSNUMBER = 'test';
        adress_adr2.COUNTRY = 'test';
        adress_adr2.TEL_NUMBER = 'test';
        adress_adr2.TEL_EXTENS = 'test';
        adress_adr2.FLGDEFAULT = 'test';
        adress_adr2.R3_USER = 'test';
        adress_adr2List.add(adress_adr2);
        ADRESS.ADR2 = adress_adr2List;

        //ADRESS_ADR3
        IF_MdgAccountController.ADRESS_ADR3 adress_adr3 = new IF_MdgAccountController.ADRESS_ADR3();
        List<IF_MdgAccountController.ADRESS_ADR3> adress_adr3List = new List<IF_MdgAccountController.ADRESS_ADR3>();
        adress_adr3.CONSNUMBER = 'test';
        adress_adr3.COUNTRY = 'test';
        adress_adr3.FAX_NUMBER = 'test';
        adress_adr3.FAX_EXTENS = 'test';
        adress_adr3.FLGDEFAULT = 'test';
        adress_adr3List.add(adress_adr3);
        ADRESS.ADR3 = adress_adr3List;

        //ADRESS_ADR12
        IF_MdgAccountController.ADRESS_ADR12 adress_adr12 = new IF_MdgAccountController.ADRESS_ADR12();
        List<IF_MdgAccountController.ADRESS_ADR12> adress_adr12List = new List<IF_MdgAccountController.ADRESS_ADR12>();
        adress_adr12.CONSNUMBER = 'test';
        adress_adr12.URI_ADDR = 'test';
        adress_adr12.FLGDEFAULT = 'test';
        adress_adr12List.add(adress_adr12);
        ADRESS.ADR12 = adress_adr12List;

        //ADRESS_ADR6
        IF_MdgAccountController.ADRESS_ADR6 adress_adr6 = new IF_MdgAccountController.ADRESS_ADR6();
        List<IF_MdgAccountController.ADRESS_ADR6> adress_adr6List = new List<IF_MdgAccountController.ADRESS_ADR6>();
        adress_adr6.CONSNUMBER = 'test';
        adress_adr6.FLGDEFAULT = 'test';
        adress_adr6.SMTP_ADDR = 'test';
        adress_adr6List.add(adress_adr6);
        ADRESS.ADR6 = adress_adr6List;

        adressList.add(ADRESS);


        bp.BP_HEADER = 'test';
        bp.APPR = 'test';
        bp.BAD_COM = 'test';
        bp.ADRESS = adressList;

        //KNA1
        IF_MdgAccountController.KNA1 kna1 = new IF_MdgAccountController.KNA1();
        List<IF_MdgAccountController.KNA1> kna1List = new List<IF_MdgAccountController.KNA1>();
        kna1.KUNNR = 'test';
        kna1.AUFSD = 'test';
        kna1.LAND1 = 'test';
        kna1.LIFNR = 'test';
        kna1.LOEVM = 'test';
        kna1.NODEL = 'test';
        kna1.SPERR = 'test';
        kna1.STKZA = 'test';
        kna1.VBUND = 'test';
        kna1.FAKSD = 'test';
        kna1.KATR1 = 'test';
        kna1.KATR2 = 'test';
        kna1.KTOKD = 'test';
        kna1.LIFSD = 'test';
        kna1.NIELS = 'test';
        kna1.STCD1 = 'test';
        kna1.STCD2 = 'test';
        kna1.STCD3 = 'test';
        kna1.STCD4 = 'test';
        kna1.STKZN = 'test';
        kna1.STCEG = 'test';
        kna1.J_1KFTBUS = 'test';
        kna1.J_1KFTIND = 'test';
        kna1.BRSCH = 'test';
        kna1.ZZJ_1KFRE = 'test';
        kna1.ZZSTKUN = 'test';
        kna1.ZZBLINE = 'test';
        kna1.ZZDUNS = 'test';
        kna1.ZZSTRAS_C = 'test';
        kna1.ZZORT01_C = 'test';
        kna1.ZZVALEXP = 'test';
        kna1.ZZVALEXPT = 'test';
        kna1.ZZBIRTHD = 'test';
        kna1.ZZCREDL_C = 'test';
        kna1.ZZSALES = 'test';
        kna1.ZZADDINFO = 'test';
        kna1.ZZAPPCH = 'test';
        kna1.ZZCNAME3 = 'test';
        kna1.ZZOSTCD2_C = 'test';
        kna1.ZZKDGRP_C = 'test';
        kna1.ZZSHIPPER = 'test';
        kna1.ZZKTEXT = 'test';
        kna1.ZZAFF_NAME = 'test';
        kna1.ZZINIT_NAME = 'test';
        kna1.ZZINCOMPANY_CD = 'test';
        kna1.ZZIN_COMPANY = 'test';
        kna1.ZZDOMI_ABBR = 'test';
        kna1.ZZCOMPTYPE = 'test';
        kna1.ZZSECTOR = 'test';
        kna1.ZZTOBUSL1_KO = 'test';
        kna1.ZZTOBUSL1_EN = 'test';
        kna1.ZZTOBUSL2_KO = 'test';
        kna1.ZZTOBUSL2_EN = 'test';
        kna1.ZZTOBUSL1 = 'test';
        kna1.ZZTOBUSL2 = 'test';
        kna1.ZZNSTKUNL1 = 'test';
        kna1.ZZNSTKUNL1_T = 'test';
        kna1.ZZNSTKUNL2 = 'test';
        kna1.ZZNSTKUNL2_T = 'test';
        kna1.ZZNSTKUNL3 = 'test';
        kna1.ZZNSTKUNL3_T = 'test';
        
        //KNA1_KNB1
        IF_MdgAccountController.KNA1_KNB1 kna1_knb1 = new IF_MdgAccountController.KNA1_KNB1();
        List<IF_MdgAccountController.KNA1_KNB1> kna1_knb1List = new List<IF_MdgAccountController.KNA1_KNB1>();
        kna1_knb1.BUKRS = 'test';
        kna1_knb1.AKONT = 'test';
        kna1_knb1.FDGRV = 'test';
        kna1_knb1.LOEVM = 'test';
        kna1_knb1.SPERR = 'test';
        kna1_knb1.ZAHLS = 'test';
        kna1_knb1.ZTERM = 'test';
        kna1_knb1.ZUAWA = 'test';
        kna1_knb1.ZWELS = 'test';
        kna1_knb1.ZZFITYP_C = 'test';
        kna1_knb1List.add(kna1_knb1);
        kna1.KNB1 = kna1_knb1List;

        //KNA1_KNVV
        IF_MdgAccountController.KNA1_KNVV kna1_knvv = new IF_MdgAccountController.KNA1_KNVV();
        List<IF_MdgAccountController.KNA1_KNVV> kna1_knvvList = new List<IF_MdgAccountController.KNA1_KNVV>();
        kna1_knvv.VKORG = 'test';
        kna1_knvv.VTWEG = 'test';
        kna1_knvv.SPART = 'test';
        kna1_knvv.AWAHR = 'test';
        kna1_knvv.BZIRK = 'test';
        kna1_knvv.AUFSD = 'test';
        kna1_knvv.FAKSD = 'test';
        kna1_knvv.INCO1 = 'test';
        kna1_knvv.INCO2 = 'test';
        kna1_knvv.LIFSD = 'test';
        kna1_knvv.LOEVM = 'test';
        kna1_knvv.WAERS = 'test';
        kna1_knvv.ZTERM = 'test';
        kna1_knvv.KALKS = 'test';
        kna1_knvv.KDGRP = 'test';
        kna1_knvv.KTGRD = 'test';
        kna1_knvv.KURST = 'test';
        kna1_knvv.VKBUR = 'test';
        kna1_knvv.ANTLF = 'test';
        kna1_knvv.VSBED = 'test';
        kna1_knvv.KZAZU = 'test';
        kna1_knvv.LPRIO = 'test';
        kna1_knvv.PLTYP = 'test';
        kna1_knvv.KONDA = 'test';
        kna1_knvv.EIKTO = 'test';

        //KNA1_KNVV_KNVP
        IF_MdgAccountController.KNA1_KNVV_KNVP kna1_knvv_knvp = new IF_MdgAccountController.KNA1_KNVV_KNVP();
        List<IF_MdgAccountController.KNA1_KNVV_KNVP> kna1_knvv_knvpList = new List<IF_MdgAccountController.KNA1_KNVV_KNVP>();
        kna1_knvv_knvp.PARVW = 'test';
        kna1_knvv_knvp.PARZA = 'test';
        kna1_knvv_knvp.DEFPA = 'test';
        kna1_knvv_knvp.KNREF = 'test';
        kna1_knvv_knvp.KUNN2 = 'test';
        kna1_knvv_knvpList.add(kna1_knvv_knvp);
        kna1_knvv.knvp = kna1_knvv_knvpList;

        //KNA1_KNVV_KNVI
        IF_MdgAccountController.KNA1_KNVV_KNVI kna1_knvv_knvi = new IF_MdgAccountController.KNA1_KNVV_KNVI();
        List<IF_MdgAccountController.KNA1_KNVV_KNVI> kna1_knvv_knviList = new List<IF_MdgAccountController.KNA1_KNVV_KNVI>();
        kna1_knvv_knvi.ALAND = 'test';
        kna1_knvv_knvi.TATYP = 'test';
        kna1_knvv_knvi.TAXKD = 'test';
        kna1_knvv_knviList.add(kna1_knvv_knvi);
        kna1_knvv.knvi = kna1_knvv_knviList;

        //KNA1_KNVV_KNVK
        IF_MdgAccountController.KNA1_KNVV_KNVK kna1_knvv_knvk = new IF_MdgAccountController.KNA1_KNVV_KNVK();
        List<IF_MdgAccountController.KNA1_KNVV_KNVK> kna1_knvv_knvkList = new List<IF_MdgAccountController.KNA1_KNVV_KNVK>();
        kna1_knvv_knvk.NAMEV = 'test';
        kna1_knvv_knvk.NAME1 = 'test';
        kna1_knvv_knvk.PRSNR = 'test';

        //KNA1_KNVV_KNVK_ADR6
        IF_MdgAccountController.KNA1_KNVV_KNVK_ADR6 kna1_knvv_knvk_adr6 = new IF_MdgAccountController.KNA1_KNVV_KNVK_ADR6();
        List<IF_MdgAccountController.KNA1_KNVV_KNVK_ADR6> kna1_knvv_knvk_adr6List = new List<IF_MdgAccountController.KNA1_KNVV_KNVK_ADR6>();
        kna1_knvv_knvk_adr6.CONSNUMBER = 'test';
        kna1_knvv_knvk_adr6.PERSNUMBER = 'test';
        kna1_knvv_knvk_adr6.SMTP_ADDR = 'test';
        kna1_knvv_knvk_adr6.FLGDEFAULT = 'test';
        kna1_knvv_knvk_adr6List.add(kna1_knvv_knvk_adr6);

        kna1_knvv_knvk.ADR6 = kna1_knvv_knvk_adr6List;
        
        kna1_knvv_knvkList.add(kna1_knvv_knvk);
        kna1_knvv.knvk = kna1_knvv_knvkList;

        kna1_knvvList.add(kna1_knvv);
        kna1.knvv = kna1_knvvList;

        //KNA1_KNVI
        IF_MdgAccountController.KNA1_KNVI kna1_knvi = new IF_MdgAccountController.KNA1_KNVI();
        List<IF_MdgAccountController.KNA1_KNVI> kna1_knviList = new List<IF_MdgAccountController.KNA1_KNVI>();
        kna1_knvi.ALAND = 'test';
        kna1_knvi.TATYP = 'test';
        kna1_knvi.TAXKD = 'test';
        kna1_knviList.add(kna1_knvi);

        kna1.knvi = kna1_knviList;

        //KNA1_KNVK
        IF_MdgAccountController.KNA1_KNVK kna1_knvk = new IF_MdgAccountController.KNA1_KNVK();
        List<IF_MdgAccountController.KNA1_KNVK> kna1_knvkList = new List<IF_MdgAccountController.KNA1_KNVK>();
        kna1_knvk.NAMEV = 'test';
        kna1_knvk.NAME1 = 'test';
        kna1_knvk.PRSNR = 'test';
        
        IF_MdgAccountController.KNA1_KNVK_ADR6 kna1_knvk_adr6 = new IF_MdgAccountController.KNA1_KNVK_ADR6();
        List<IF_MdgAccountController.KNA1_KNVK_ADR6> kna1_knvk_adr6List = new List<IF_MdgAccountController.KNA1_KNVK_ADR6>();
        kna1_knvk_adr6.CONSNUMBER = 'test';
        kna1_knvk_adr6.PERSNUMBER = 'test';
        kna1_knvk_adr6.SMTP_ADDR = 'test';
        kna1_knvk_adr6.FLGDEFAULT = 'test';
        kna1_knvk_adr6List.add(kna1_knvk_adr6);

        kna1_knvk.ADR6 = kna1_knvk_adr6List;
        kna1_knvkList.add(kna1_knvk);
        kna1.KNVK = kna1_knvkList;

        kna1List.add(kna1);
        bp.KNA1 = kna1List;
        bpList.add(bp);
        IF_MdgAccountController.InputClass input = new IF_MdgAccountController.InputClass();
        input.BP = bpList;

        request.requestBody = Blob.valueOf(JSON.serialize(input));
        RestContext.request  = request;
        RestContext.response = response;


        try {

            IF_MdgAccountController.saveAccountMaster();

        } catch (Exception e) {
            system.debug(e);
        }        

        Test.stopTest();
    }    
}