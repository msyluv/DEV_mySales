/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-11-16
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   kilhwan.an@partner.samsung.com   Initial Version
**/
public with sharing class IF_EccReceivOutContractController {

    private final String INTERFACE_ID = 'IF-018';
    private final String APEX_CLASS   = 'IF_EccReceivOutContractController';
    private final String METHOD_NAME  = 'receiveOutContract';
    
    public List<TT_RESULTOutputClass> receiveOutContract( List<InputHeader> inputHeader) {


        // guid
        String       guId    = IF_Util.generateGuid();

        /////////////////////// 업무 로직 처리 ////////////////////////





        /////////////////////////////////////////////////////////////

        // 데이터 전송
        String              jsonData= JSON.serialize( inputHeader);
        IF_Callout          call    = new IF_Callout( INTERFACE_ID);
        Map<String, Object> resMap  = call.httpCallout( jsonData, '');
        String  respVal = String.valueOf( resMap.get( 'Response'));
        List<TT_RESULTOutputClass>  outputList = ( List<TT_RESULTOutputClass>)JSON.deserialize( respVal, List<OutputHeader>.class);
        
        // 로그기록

        IF_Log.InterfaceLog ifLog   = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, 'POST', jsonData, respVal);
        IF_Log              log     = new IF_Log();
        log.createLog(ifLog);

        ///////////////////// 화면 혹은 BIZ 로직 처리 //////////////




        /////////////////////////////////////////////////////////
        return outputList;
    }

    public class InputHeader{

               
        List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public String IV_PURPOSE; // 'S' : 수주품의,  'P' : 실행,  'C' : 법인
        @AuraEnabled
        public String IV_PSPID;  // 프로젝트코드
        @AuraEnabled
        public String IV_YYYYMM; // Period to analyze - month
    }

    // 변경 될수 있음
    public class OutputHeader{

        @AuraEnabled
        public List<TT_RESULTOutputClass> TT_RESULT;
    }


    public class TT_RESULTOutputClass{
     
        @AuraEnabled
        public String PSPID;  // 프로젝트 코드
        @AuraEnabled
        public String RFQ_NO; // 견적번호
        @AuraEnabled
        public String BANFN;  // Purchase Requisition Number
        @AuraEnabled
        public String POSID;  // Child Code
        @AuraEnabled
        public String PS_PSP_PNR; // Work Breakdown Structure Element (WBS Element)
        @AuraEnabled
        public String START_DT; // 계약기간 시작일  : 
        @AuraEnabled
        public String END_DT;   // 종료일 
        @AuraEnabled
        public String IO_CD;    // 내외자구분 
        @AuraEnabled
        public Decimal PRICE;    // supply price
        @AuraEnabled
        public Decimal PRICE_I;  // Providing Price ( Foreign Capital )
        @AuraEnabled
        public String WAERS;    // Currency Key
        @AuraEnabled
        public String WAERS_EN; // Currency Key
        @AuraEnabled
        public String GUBUN;    // 외주비 구분
        @AuraEnabled
        public String EBELN;    // Purchasing Document Number
        @AuraEnabled
        public String BSART;    // Order Type (Purchasing)
        @AuraEnabled
        public String VERSI;    // 버젼(ZA0)
        @AuraEnabled
        public String ZZ_CONNM; // Contract Name
        @AuraEnabled
        public String LIFNR;    // Account Number of Vendor or Creditor
        @AuraEnabled
        public String NAME1;    // Name 1
        @AuraEnabled
        public String ZZ_CONFT; // 계약기간/인수요청일(FROM)
        @AuraEnabled
        public String ZZ_CONTT; // 계약기간
        @AuraEnabled
        public Decimal MONTH_AMT; // 당월실행금액
        @AuraEnabled
        public Decimal ICMS;
        @AuraEnabled
        public Decimal IPI;
        @AuraEnabled
        public Decimal ICMS_ST;
        @AuraEnabled
        public Decimal PIS;
        @AuraEnabled
        public Decimal COFINS;
        @AuraEnabled
        public Decimal ISS;
        @AuraEnabled
        public Decimal IRRF;
        @AuraEnabled
        public Decimal CSLL;
        @AuraEnabled
        public Decimal INSS;

        @AuraEnabled
        public List<TT_SLAVEOutputClass> TT_SLAVE;
    }

    public class TT_SLAVEOutputClass{

        @AuraEnabled
        public String EBELN; // Purchasing Document Number
        @AuraEnabled
        public String PS_PSP_PNR; // Work Breakdown Structure Element (WBS Element)
        @AuraEnabled
        public String SYSTEM_ID; // 시스템 ID
        @AuraEnabled
        public String YYYYMM;   // 대상년월 
        @AuraEnabled
        public String MONTH_AMT; // 월(차수)발생금액
        @AuraEnabled
        public String WAERS;     // Currency Key
    }
    
}