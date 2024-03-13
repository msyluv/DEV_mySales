/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-11
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-11-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@RestResource( UrlMapping='/IF022/*')
global class IF_RpaGetAccountInfoController implements Schedulable{
    private static final String INTERFACE_ID = 'IF-022';
    private static final String APEX_CLASS   = 'IF_RpaGetAccountInfoController';
    private static final String METHOD_NAME  = 'getAccountInfo';


    // 데이터 비동기 처리 : 대량의 데이터 처리:
    @HttpPost
    global static OutputHeader receiveAccountInfo(){

        // 로그 정보
        String              guId      = IF_Util.generateGuid();
        OutputHeader        outHeader = new OutputHeader();
        IF_Log              log       = new IF_Log();
        IF_Log.InterfaceLog infLog    = null;

        // RequestBody 데이터 확인
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        RestResponse rep= RestContext.response;
        rep.addHeader('Content-Type', 'application/json');

        try{

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;

            // 데이터 존재 하는지 여부 확인
            Map<String,Object> bodyMap =( Map<String, Object>) JSON.deserializeUntyped( reqBody.toString());
            if( bodyMap == null){

                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';

                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }           

            // 사업자 등록 번호 기준으로 Account 데이터를 가져옴
            List<Object> dataList      = (List<Object>)bodyMap.get('IT_DATA');
            
            Set<String>  accCorpNumSet = new Set<String>();
            Map<String, Object> acctMap= new Map<String, Object>();
            for(Object obj : dataList) {
                
                Map<String,Object> objMap = (Map<String,Object>) obj;
                
                String custRegNo = objMap.get('CorporateNumber') + '';

                

                accCorpNumSet.add( custRegNo);
                acctMap.put( custRegNo, objMap);
            }

            // 고객사 정보 읽어오기
            List<Account> acctList = [
                SELECT Id
                      ,CorporateNumber__c
                      ,eInfoSource__c
                      ,eAccName__c
                      ,eAccNameE__c
                      ,eCEOName__c
                      ,eAddress__c
                      ,ePhoneNum__c
                      ,eFaxNum__c
                      ,eHomepage__c
                      ,eCorporateNum__c
                      ,eEstablishmentDate__c
                      ,eIndustryCode__c
                      ,eUpdateDateB__c
                FROM   Account
                WHERE  CorporateNumber__c IN :accCorpNumSet
            ];
            system.debug('acctList : ' + acctList.size());
            // 기존 고객에 rpa 데이터 update 처리 할지 update가 아니라면? 별도의 table로 처리 할지 확인 필요
            List<Account> upAcctList = new List<Account>();
            for( Account acc : acctList){

                String custRegNo    = acc.CorporateNumber__c;
                Map<String, Object> objMap = (Map<String,Object>)acctMap.get( custRegNo);

                String corpNumber= Util_String.nvlStr( objMap.get('CorporateNumber'));
                String dataSource= Util_String.nvlStr( objMap.get('eInfoSource'));
                String custKName = Util_String.nvlStr( objMap.get('eAccName'));
                String custEName = Util_String.nvlStr( objMap.get('eAccNameE'));
                String ceoName   = Util_String.nvlStr( objMap.get('eCEOName'));
                String address   = Util_String.nvlStr( objMap.get('eAddress'));
                String phoneNo   = Util_String.nvlStr( objMap.get('ePhoneNum'));
                String faxNo     = Util_String.nvlStr( objMap.get('eFaxNum'));
                String homePage  = Util_String.nvlStr( objMap.get('eHomepage'));
                String jurirNo   = Util_String.nvlStr( objMap.get('eCorporateNum'));
                String estDate   = Util_String.nvlStr(objMap.get('eEstablishmentDate'));
                String industCode= Util_String.nvlStr( objMap.get('eIndustryCode'));
                String upDateDt  = Util_String.nvlStr(objMap.get('eUpdateDateB'));

                // 기존 데이터가 없는 경우만 update 처리: 확인 필요
                // 현재 별도의 table이 없이 Account에서 처리 되고 있음
                // Key 값은 사업자 등록번호 + DataSource 이럴 경우 DataSource값은 하나만 가져 가야 하나?
                
                acc.CorporateNumber__c      = corpNumber;
                acc.eInfoSource__c          = dataSource;
                acc.eAccName__c             = custKName;
                acc.eAccNameE__c            = custEName;
                acc.eCEOName__c             = ceoName;
                acc.eAddress__c             = address;
                acc.ePhoneNum__c            = phoneNo;
                acc.eFaxNum__c              = faxNo;
                acc.eHomepage__c            = homePage;
                acc.eCorporateNum__c        = jurirNo;
                acc.eEstablishmentDate__c   = estDate;
                acc.eIndustryCode__c        = industCode;
                acc.eUpdateDateB__c         = upDateDt;
                // if( String.isBlank(acc.CorporateNumber__c))     acc.CorporateNumber__c      = corpNumber;
                // if( String.isBlank(acc.eInfoSource__c))         acc.eInfoSource__c          = dataSource;
                // if( String.isBlank(acc.eAccName__c))            acc.eAccName__c             = custKName;
                // if( String.isBlank(acc.eAccNameE__c))           acc.eAccNameE__c            = custEName;
                // if( String.isBlank(acc.eCEOName__c))            acc.eCEOName__c             = ceoName;
                // if( String.isBlank(acc.eAddress__c))            acc.eAddress__c             = address;
                // if( String.isBlank(acc.ePhoneNum__c))           acc.ePhoneNum__c            = phoneNo;
                // if( String.isBlank(acc.eFaxNum__c))             acc.eFaxNum__c              = faxNo;
                // if( String.isBlank(acc.eHomepage__c))           acc.eHomepage__c            = homePage;
                // if( String.isBlank(acc.eCorporateNum__c))       acc.eCorporateNum__c        = jurirNo;
                // if( String.isBlank(acc.eEstablishmentDate__c )) acc.eEstablishmentDate__c   = estDate;
                // if( String.isBlank(acc.eIndustryCode__c))       acc.eIndustryCode__c        = industCode;
                // if( String.isBlank(acc.eUpdateDateB__c))        acc.eUpdateDateB__c         = upDateDt;
            }

            update acctList;
            outHeader.TOTAL_COUNT = acctList.size();

            // 로그 객체 생성
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        }catch( Exception e){

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }

        log.createLog( infLog);

        return outHeader;
    }

    // Callout 처리
    @Future( Callout=true)
    global static void getAccountInfo( String reqDate){

        // 로그 변수
        String      guId = IF_Util.generateGuid();
        IF_Callout  call = new IF_Callout( INTERFACE_ID);
        IF_Log      log  = new IF_Log();
        IF_Log.InterfaceLog ifLog;

        // 검색할 년월일, json 변환
        Map<String,String> reqMap = new Map<String,String>();
        reqMap.put('Search_Date' , reqDate);
        String jsonBody = JSON.serialize(reqMap);

        try{

            // callout
            Map<String, Object> rtnMap = call.httpCallout(jsonBody, '');
            String statusCode = rtnMap.get( 'StatusCode') + '';
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, jsonBody, 'Async(' + statusCode + ')');
        }catch( Exception e){

            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, jsonBody, 'Async',e);
        }
        log.createLog( ifLog);
    }

    global void execute( SchedulableContext SC){

        Date   toDt = Date.today().addDays( -1);
        String regDate  = Util_String.convertDateString(toDt);
        getAccountInfo ( regDate);
    }


    // 전달 값: JitterBit
    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }

    public class OutputClass{ }

}