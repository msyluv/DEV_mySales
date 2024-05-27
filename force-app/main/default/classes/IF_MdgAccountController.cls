/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-04-30
 * @last modified by  : waris.m@samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-11-10   ghkil@partner.samsung.com   Initial Version
 * 1.1   2021-02-15   kilhwan.an@partner.samsung.com   신용 등급 신규 필드 추가
 * 1.2   2022-12-28   anish.jain@partner.samsung.com   Changes made for scheduled batch run regarding the Account Information update after IF-111
 * 1.3   2024-04-05   vikrant.ks@samsung.com      Replaced condition for updating TEL_NUMBER__c field (obj3.CONSNUMBER == '001' condition with obj3.R3_USER == '1').(MySales-494)
 * 1.4   2024-04-30   waris.m@samsung.com              Changes added for  MYSALES-515 - Added a new Field 
 * 1.5   2024-05-20   d.ashish@samsung.com              Changes added for  MYSALES-533 - Added a new Field 
**/
@RestResource(urlMapping = '/IF111/*')
global class IF_MdgAccountController {

    private static final String INTERFACE_ID = 'IF-111';
    private static final String APEX_CLASS   = 'IF_MdgAccountController';
    private static final String METHOD_NAME  = 'saveAccountMaster';

    @HttpPost
    global static OutputHeader saveAccountMaster() {
        String guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        
        InputClass input = (InputClass)JSON.deserializeStrict(reqBody.toString(),InputClass.class);
        
       
        List<MDGAccount__c> accList = new List<MDGAccount__c>();
        List<MDGAccount__c> salesList = new List<MDGAccount__c>();
        String accNumber = '';
        OutputHeader outheader = new OutputHeader();
        String accountId = '';
        try{

            
            
            for(BP obj : input.BP){
                MDGAccount__c acc = new MDGAccount__c();
                acc.BP_HEADER__c = obj.BP_HEADER;
                accNumber = obj.BP_HEADER;
                accountId = obj.SFDCID;
                boolean isFirst = true;
                //acc.cStatus__c = '01'; I/F 로 insert 시 status == 1
                if(obj.ADRESS != null){
                    
                    for(ADRESS obj2 : obj.ADRESS){
                        if(obj2.ADRC != null && isFirst == true){
                            ADRESS_ADRC adr= obj2.ADRC[0];
                            acc.CITY1__c = adr.CITY1;
                            acc.CITY2__c = adr.CITY2;
                            acc.STREET__c = adr.STREET;
                            acc.POST_CODE1__c = adr.POST_CODE1;
                            acc.COUNTRY__c = adr.COUNTRY;
                            acc.REGION__c = adr.REGION;
                            acc.NAME1__c = adr.NAME1;
                            acc.NAME2__c = adr.NAME2;
                            isFirst = false;
                        }
                        /*
                        for(ADRESS_ADRC obj3 : obj2.ADRC){
                            //seq 확인 필요

                            acc.CITY1__c = obj2.ADRC[0].CITY1;
                            acc.CITY2__c = obj2.ADRC[0].CITY2;
                            acc.STREET__c = obj2.ADRC[0].STREET;
                            acc.POST_CODE1__c = obj2.ADRC[0].POST_CODE1;
                            acc.COUNTRY__c = obj2.ADRC[0].COUNTRY;
                            acc.REGION__c = obj2.ADRC[0].REGION;
                            acc.NAME1__c = obj2.ADRC[0].NAME1;
                            acc.NAME2__c = obj2.ADRC[0].NAME2;
                        }*/
                        if(obj2.ADR2 != null){
                            for(ADRESS_ADR2 obj3 : obj2.ADR2){
                                if(obj3.R3_USER == '1'){ //V1.3 Replaced obj3.CONSNUMBER == '001' condition with obj3.R3_USER == '1'
                                    acc.TEL_NUMBER__c = obj3.TEL_NUMBER;
                                }
                            }
                        }
                        if(obj2.ADR3 != null){
                            for(ADRESS_ADR3 obj3 : obj2.ADR3){
                                if(obj3.CONSNUMBER == '001'){
                                    acc.FAX_NUMBER__c = obj3.FAX_NUMBER;
                                }
                            }
                        }
                        if(obj2.ADR12 != null){
                            for(ADRESS_ADR12 obj3 : obj2.ADR12){
                                if(obj3.CONSNUMBER == '001'){
                                    acc.URI_ADDR__c = obj3.URI_ADDR;
                                }
                            }
                        }
                    }
                }
                
                if(obj.KNA1 != null){
                    KNA1 knaObj = obj.KNA1[0];
                    acc.STCD1__c = knaObj.STCD1;
                    acc.STCD2__c = knaObj.STCD2;
                    acc.STCD2__c = knaObj.STCD2;
                    acc.STCD3__c = knaObj.STCD3;
                    acc.STCD4__c = knaObj.STCD4;
                    acc.ZZJ_1KFRE__c = knaObj.ZZJ_1KFRE;
                    acc.ZZKDGRP_C__c = knaObj.ZZKDGRP_C;
                    acc.ZZSHIPPER__c = knaObj.ZZSHIPPER;

                    acc.ZZNSTKUNL1__c = knaObj.ZZNSTKUNL1;
                    acc.ZZNSTKUNL1_T__c = knaObj.ZZNSTKUNL1_T;
                    acc.ZZNSTKUNL2__c = knaObj.ZZNSTKUNL2;
                    acc.ZZNSTKUNL2_T__c = knaObj.ZZNSTKUNL2_T;
                    acc.ZZNSTKUNL3__c = knaObj.ZZNSTKUNL3;
                    acc.ZZNSTKUNL3_T__c = knaObj.ZZNSTKUNL3_T;
                    acc.ZZCREDL_C__c = knaObj.ZZCREDL_C;    // 2021.02.15 => 필드 추가 ( 신용 평가 등급 신규)
                    acc.ZZTOBUSL1__c = knaObj.ZZTOBUSL1;
                    acc.ZZTOBUSL2__c = knaObj.ZZTOBUSL2;
                    acc.ZZCHPAT__c   = knaObj.ZZCHPAT;     //Changes added for  MYSALES-515
                    acc.KTOKD__c = knaObj.KTOKD; //Changes for MYSALES-533 
                    acc.ExternalId__c = 'A_'+accNumber;
                    acc.Type__c = 'A'; // dummy object에 account 와 account sales area 데이터를 구분하기 위한 필드, A : Account, S : Account Sales Area
                    acc.mLOEVM__c = knaObj.LOEVM;
                    acc.isBatch__c = 'N';
                    if(knaObj.KNVV != null){
                        for(KNA1_KNVV obj3 : knaObj.KNVV){
                            //AccountSalesArea Object
                            MDGAccount__c sales = new MDGAccount__c();
                            
                            sales.VKORG__c = obj3.VKORG;
                            sales.VTWEG__c = obj3.VTWEG;
                            sales.SPART__c = obj3.SPART;
                            sales.AWAHR__c = obj3.AWAHR;
                            sales.BZIRK__c = obj3.BZIRK;
                            sales.AUFSD__c = obj3.AUFSD;
                            sales.FAKSD__c = obj3.FAKSD;
                            sales.INCO1__c = obj3.INCO1;
                            sales.INCO2__c = obj3.INCO2;
                            sales.LIFSD__c = obj3.LIFSD;
                            sales.LOEVM__c = obj3.LOEVM;
                            sales.WAERS__c = obj3.WAERS;
                            sales.ZTERM__c = obj3.ZTERM;
                            sales.KALKS__c = obj3.KALKS;
                            sales.KDGRP__c = obj3.KDGRP;
                            sales.KTGRD__c = obj3.KTGRD;
                            sales.KURST__c = obj3.KURST;
                            sales.VKBUR__c = obj3.VKBUR;
                            sales.ANTLF__c = obj3.ANTLF;
                            sales.VSBED__c = obj3.VSBED;
                            sales.KZAZU__c = obj3.KZAZU;
                            sales.LPRIO__c = obj3.LPRIO;
                            sales.PLTYP__c = obj3.PLTYP;
                            sales.KONDA__c = obj3.KONDA;
                            sales.BP_HEADER__c = accNumber;
                            sales.ExternalId__c = 'S_'+accNumber+'_'+obj3.VKORG+'_'+obj3.VTWEG+'_'+obj3.SPART;
                            sales.Type__c = 'S'; // dummy object에 account 와 account sales area 데이터를 구분하기 위한 필드, A : Account, S : Account Sales Area
                            sales.isBatch__c = 'N';
                            salesList.add(sales);
                        }
                    }
                    
                } 
               
                accList.add(acc);
                
            }
            
            upsert accList ExternalId__c;
            upsert salesList ExternalId__c;
            
            //실시간 처리를 위해 MDGAccount__c -> Account 로 데이터 매핑
            //MdgAccountController.updateAccountByMdg(accList,accountId);          //Commented by Anish - v 1.2
            //실시간 처리를 위해 MDGAccount__c -> AccountSalesArea__c 로 데이터 매핑
            MdgAccountController.updateSalesAreaByMdg(salesList);

            outheader.TOTAL_COUNT    = accList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
        }catch(Exception e){
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }

        
        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        log.createLog( infLog);
        return outHeader;
    }



    global class OutputHeader{
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        public String EV_RESULT = ''; // 처리 결과
        public String EV_MESG = ''; // 처리 메세지
    }
    public class InputHeader{
        public List<InputClass> DATA;
    }

    public class InputClass{
        public String TOTAL_COUNT;
        public String PAGE_COUNT;
        public String PAGE_NUM;
        public List<BP> BP;
    }
    public class BP{
        public String BP_HEADER;
        public String APPR;
        public String BAD_COM;
        public String SFDCID;
        public List<ADRESS> ADRESS;
        public List<KNA1> KNA1; 
    }
    public class ADRESS{
        public String ADDRNUMBER;
        public List<ADRESS_ADRC> ADRC;
        public List<ADRESS_ADR2> ADR2;
        public List<ADRESS_ADR3> ADR3;
        public List<ADRESS_ADR12> ADR12;
        public List<ADRESS_ADR6> ADR6;
    }
    public class ADRESS_ADR6{
        public String CONSNUMBER;
        public String SMTP_ADDR;
        public String FLGDEFAULT;
    }
    public class ADRESS_ADR12{
        public String CONSNUMBER;
        public String URI_ADDR;
        public String FLGDEFAULT;
    }
    public class ADRESS_ADR3{
        public String CONSNUMBER;
        public String COUNTRY;
        public String FAX_NUMBER;
        public String FAX_EXTENS;
        public String FLGDEFAULT;
    }
    public class ADRESS_ADR2{
        public String CONSNUMBER;
        public String COUNTRY;
        public String TEL_NUMBER;
        public String TEL_EXTENS;
        public String FLGDEFAULT;
        public String R3_USER;
    }
    public class ADRESS_ADRC{
        public String NATION;
        public String CITY1;
        public String CITY2;
        public String STREET;
        public String POST_CODE1;
        public String COUNTRY;
        public String LANGU;
        public String REGION;
        public String TRANSPZONE;
        public String SORT1;
        public String SORT2;
        public String TAXJURCODE;
        public String TIME_ZONE;
        public String NAME1;
        public String NAME2;
        public String NAME3;
        public String NAME4;
        public String TITLE;
    }
    public class KNA1{
        public String KUNNR; //AccountNumber ---> ADRESS 클래스와 필드 중복
        public String AUFSD;
        public String LAND1; //(m)Country ---> ADRESS 클래스와 필드 중복
        public String LIFNR;
        public String LOEVM;
        public String NODEL;
        public String SPERR;
        public String STKZA;
        public String VBUND;
        public String FAKSD;
        public String KATR1;
        public String KATR2;
        public String KTOKD;
        public String LIFSD;
        public String NIELS;
        public String STCD1;
        public String STCD2;
        public String STCD3;
        public String STCD4;
        public String STKZN;
        public String STCEG;
        public String J_1KFTBUS;
        public String J_1KFTIND;
        public String BRAN1;
        public String BRSCH;
        public String ZZJ_1KFRE;
        public String ZZSTKUN;
        public String ZZBLINE;
        public String ZZDUNS;
        public String ZZSTRAS_C;
        public String ZZORT01_C;
        public String ZZVALEXP;
        public String ZZVALEXPT;
        public String ZZBIRTHD;
        public String ZZCREDL_C;
        public String ZZSALES;
        public String ZZADDINFO;
        public String ZZAPPCH;
        public String ZZCNAME3;
        public String ZZOSTCD2_C;
        public String ZZKDGRP_C;
        public String ZZSHIPPER; // Account 에 필드 없음
        public String ZZKTEXT;
        public String ZZAFF_NAME;
        public String ZZINIT_NAME;
        public String ZZINCOMPANY_CD;
        public String ZZIN_COMPANY;
        public String ZZDOMI_ABBR;
        public String ZZCOMPTYPE;
        public String ZZSECTOR;
        public String ZZTOBUSL1_KO;
        public String ZZTOBUSL1_EN;
        public String ZZTOBUSL2_KO;
        public String ZZTOBUSL2_EN;
        public String ZZTOBUSL1;
        public String ZZTOBUSL2;
        public String ZZCHPAT; //New field 240425 for  MYSALES-515
        public String ZZNSTKUNL1;
        public String ZZNSTKUNL1_T;
        public String ZZNSTKUNL2;
        public String ZZNSTKUNL2_T;
        public String ZZNSTKUNL3;
        public String ZZNSTKUNL3_T;
        public List<KNA1_KNB1> KNB1; 
        public List<KNA1_KNVV> KNVV; 
        public List<KNA1_KNVI> KNVI;
        public List<KNA1_KNVK> KNVK; // class 정의 필요
    }
    public class KNA1_KNB1{
        public String BUKRS;
        public String AKONT;
        public String FDGRV;
        public String LOEVM;
        public String SPERR;
        public String ZAHLS;
        public String ZTERM;
        public String ZUAWA;
        public String ZWELS;
        public String ZZFITYP_C;
    }
    public class KNA1_KNVV{
        public String VKORG;
        public String VTWEG;
        public String SPART;
        public String AWAHR;
        public String BZIRK;
        public String AUFSD;
        public String FAKSD;
        public String INCO1;
        public String INCO2;
        public String LIFSD;
        public String LOEVM;
        public String WAERS;
        public String ZTERM;
        public String KALKS;
        public String KDGRP;
        public String KTGRD;
        public String KURST;
        public String VKBUR;
        public String ANTLF;
        public String VSBED;
        public String KZAZU;
        public String LPRIO;
        public String PLTYP;
        public String KONDA;
        public String EIKTO;
        public List<KNA1_KNVV_KNVP> KNVP;
        public List<KNA1_KNVV_KNVI> KNVI;
        public List<KNA1_KNVV_KNVK> KNVK;
    }
    public class KNA1_KNVV_KNVK{
        public String NAMEV;
        public String NAME1;
        public String PRSNR;
        public List<KNA1_KNVV_KNVK_ADR6> ADR6;
    }
    public class KNA1_KNVV_KNVK_ADR6{
        public String CONSNUMBER;
        public String PERSNUMBER;
        public String SMTP_ADDR;
        public String FLGDEFAULT;
    }

    public class KNA1_KNVV_KNVI{
        public String ALAND;
        public String TATYP;
        public String TAXKD;
    }
    public class KNA1_KNVV_KNVP{
        public String PARVW;
        public String PARZA;
        public String DEFPA;
        public String KNREF;
        public String KUNN2;
    }
    public class KNA1_KNVI{
        public String ALAND;
        public String TATYP;
        public String TAXKD;
    }
    public class KNA1_KNVK{
        public String NAMEV;
        public String NAME1;
        public String PRSNR;
        public List<KNA1_KNVK_ADR6> ADR6;
    }
    public class KNA1_KNVK_ADR6{
        public String CONSNUMBER;
        public String PERSNUMBER;
        public String SMTP_ADDR;
        public String FLGDEFAULT;
    }
}