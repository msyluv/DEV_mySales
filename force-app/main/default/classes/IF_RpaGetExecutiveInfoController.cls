/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-21
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-12-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   2021-04-21   raeganja@partner.samsung.com       acct.AccountNumber -> acct.Id 로 변경
**/
@RestResource( UrlMapping='/IF025/*')
global class IF_RpaGetExecutiveInfoController  implements Schedulable{
    private static final String INTERFACE_ID = 'IF-025';
    private static final String APEX_CLASS   = 'IF_RpaGetExecutiveInfoController';
    private static final String METHOD_NAME  = 'getExecutiveInfo';

    @HttpPost
    global static OutputHeader receiveExecutiveInfo(){

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

            // 사업자 번호 기준으로 Account 정보를 읽어옴
            // Map<String,Id> accMap  = new Map<String,Id>();
            List<Object>        dataList      = (List<Object>)bodyMap.get('IT_DATA');
            Set<String>         accCorpNumSet = new Set<String>();
            Map<String, List<Map<String, Object>>> excInfoMap    = new Map<String, List<Map<String, Object>>>();
            for(Object obj : dataList) {

                Map<String,Object> objMap = (Map<String,Object>) obj;
                String custRegNo = objMap.get('BizRegNo') + '';
                accCorpNumSet.add( custRegNo);

                List<Map<String, Object>> objListMap = excInfoMap.get(custRegNo);
                if(objListMap == null){
                    objListMap = new List<Map<String, Object>>();
                } 
                
                objListMap.add(objMap);
                
                excInfoMap.put( custRegNo, objListMap);
            }

            // 데이터 등록 처리
            List<Account> accList = [SELECT id, CorporateNumber__c, AccountNumber From Account where CorporateNumber__c in :accCorpNumSet];
            List<ExecutiveInformation__c> executiveList = new List<ExecutiveInformation__c>();
            for(Account acct : accList){               

                //Map<String, Object> objMap = (Map<String, Object>)excInfoMap.get( acct.CorporateNumber__c);
                List<Map<String, Object>> objListMap = (List<Map<String, Object>>)excInfoMap.get( acct.CorporateNumber__c);

                for(Map<String, Object> objMap : objListMap){
                    ExecutiveInformation__c executive = new ExecutiveInformation__c( );

                    String bizRegNo                     = Util_String.nvlStr(objMap.get('BizRegNo'));
                    String infoSource                   = Util_String.nvlStr(objMap.get('InfoSource'));
                    String seqNo                        = Util_String.nvlStr(objMap.get('SeqNo'));
                    String execName                     = Util_String.nvlStr(objMap.get('ExecName'));
                    String gender                       = Util_String.nvlStr(objMap.get('Gender'));
                    String birthDay                     = Util_String.nvlStr(objMap.get('BirthDay'));
                    String jobTitle                     = Util_String.nvlStr(objMap.get('JobTitle'));
                    String registeredExecutive          = Util_String.nvlStr(objMap.get('RegisteredExecutive'));
                    String workingType                  = Util_String.nvlStr(objMap.get('WorkingType'));
                    String jobDescription               = Util_String.nvlStr(objMap.get('JobDescription'));
                    String description                  = Util_String.nvlStr(objMap.get('Description'));
                    String stockHolder                  = Util_String.nvlStr(objMap.get('StockHolder'));
                    String employmentPeriod             = Util_String.nvlStr(objMap.get('EmploymentPeriod'));
                    String expirationDay                = Util_String.nvlStr(objMap.get('ExpirationDay'));

                    executive.BizRegNo__c               = bizRegNo;
                    executive.Account__c                = acct.Id;
                    executive.InfoSource__c             = infoSource;
                    executive.SeqNo__c                  = seqNo;
                    executive.ExecName__c               = execName;
                    executive.Gender__c                 = gender;
                    executive.BirthDay__c               = birthDay;
                    executive.JobTitle__c               = jobTitle;
                    executive.RegisteredExecutive__c    = registeredExecutive;
                    executive.WorkingType__c            = workingType;
                    executive.JobDescription__c         = jobDescription;
                    executive.Description__c            = description;
                    executive.StockHolder__c            = stockHolder;
                    executive.EmploymentPeriod__c       = employmentPeriod;
                    executive.ExpirationDay__c          = expirationDay;
                    //Account(Master-Detail) 매핑 키값 확인 필요
                    //executive.Account__c = '';


                    //Upsert 를 위한 Key값
                    //executive.ExternalId__c     = acct.AccountNumber + '_' + bizRegNo +'_'+ infoSource +'_'+ seqNo;
                    executive.ExternalId__c     = acct.Id + '_' + bizRegNo +'_'+ infoSource +'_'+ seqNo;
                    executiveList.add(executive);
                }
            }

            upsert executiveList ExternalId__c;
            outHeader.TOTAL_COUNT = executiveList.size();

            // 로그 객체 생성
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        } catch(Exception e){

            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }

        log.createLog( infLog);
        return outHeader;
    }

    // Callout 처리
    @Future( Callout=true)
    global static void getExecutiveInfo( String reqDate){

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

        Date   toDt     = Date.today().addDays( -1);
        String regDate  = Util_String.convertDateString( toDt);
        getExecutiveInfo ( regDate);
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