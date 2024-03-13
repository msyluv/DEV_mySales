/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-24
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-28   ghkil@partner.samsung.com   Initial Version
 * 
 * 
 * 


BaseURL: https://samsungsds.jitterbit.eu
- 임시 (본 장비구축 완료시 변경예정, 미정)

Path : /POC/1.0/if075/sendMail
 
- 임시 (본 장비구축 완료시 변경예정, 미정)
'- 양식 : /[PRD],[QAS],[DEV]/[Version]/[IF ID]/[Command]
  (예시) /PRD/1.0/if079/submitApproval
 

Method: Post
- 고정 (Post로만 제공하는 것으로 통일)
 

Header Authorization : Bearer bfd96dbb-20c4-4f28-97e7-7e59dd9d4949
 
- 임시 (본 장비구축 완료시 변경예정, 미정)
- PRD, QAS, DEV별 key 값만 변경

Content-Type : application/json

swaggerURL : https://apps.emea-west.jitterbit.com/api-manager/portals/samsungsds
 
- 임시 (본 장비구축 완료시 변경예정, 미정)
 

**/
public class IF_Knox073test {

    public IF_Config__mdt       ifConfig;
    public IF_SystemInfo__mdt   ifSystemInfo;
    private final Integer       CALLOUT_TIME = 110000;
    private static Boolean isSandbox = Utils.getIsSandbox();
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    /**
    * @description IF 정보
    * @author kilhwan.an@partner.samsung.com | 2020-11-05 
    * @param ifId 
    * @return List<IF_Config__mdt> 
    **/
    private List<IF_Config__mdt> getIFConfig( String ifId){

        // IF 정보
        List<IF_Config__mdt> ifConfig = [  

            SELECT Id
                  ,InterfaceId__c
                  ,Endpoint__c
                  ,AddHeader__c
                  ,CreateType__c
                  ,ContentType__c
                  ,Method__c 
                  ,SystemInfo__c
                  ,Version__c
            FROM   IF_Config__mdt 
            WHERE  InterfaceId__c = :ifId 
            LIMIT 1 
        ];
        return ifConfig;
    }

    /**
    * @description IF 시스템: Jitterbit , ...
    * @author kilhwan.an@partner.samsung.com | 2020-11-05 
    * @param systemInfo 
    * @return List<IF_SystemInfo__mdt> 
    **/
    private List<IF_SystemInfo__mdt> getSystemInfo( String systemInfo){

        // IF 환경 체크: 운영, 개발( POC,QAS,DEV,PRD)
        Organization org = [SELECT Id, IsSandbox FROM Organization LIMIT 1];
        
        String sysTail   = org.IsSandbox == true ? '_SAND' : '_PRD';
        // String extUrl    = URL.getSalesforceBaseUrl().toExternalForm();
        // if( org.IsSandbox == true){

        //     if( extUrl.indexOf( '--qa') > -1) sysTail = '_QAS';
        //     else sysTail = '_DEV';
        // }else{

        //     sysTail = '_PRD';
        // }


        systemInfo       = systemInfo + sysTail;


        if (DEBUG_FLAG) System.debug( 'systemInfo::::' + systemInfo);
        // IF 시스템 정보 : 대상 시스템
        List<IF_SystemInfo__mdt> ifSystemInfo = [

            SELECT Id
                  ,DeveloperName
                  ,IfUrl__c
                  ,UserName__c
                  ,Password__c
                  ,SecretToken__c
                  ,GrantType__c
                  ,ClientId__c
                  ,ClientSecret__c
                  ,Authorization__c
                  ,RemoteSite__c
            FROM   IF_SystemInfo__mdt
            WHERE  DeveloperName = :systemInfo
        ];

        if (DEBUG_FLAG) System.debug( 'ifSystemInfo::::' + ifSystemInfo);

        return ifSystemInfo;
    }

    /**
    * @description : Interface Id를 통해 infConfig 및 대상 시스템 설정
    * @author kilhwan.an@partner.samsung.com | 2020-11-05 
    * @param ifId : 인터페이스 아이디
    **/
    public IF_Knox073test( String ifId) {

        // IF-ID 정보
        List<IF_Config__mdt> ifConfigList = getIFConfig( ifId);
        if( ifConfigList.size() > 0) this.ifConfig = ifConfigList.get( 0);
        
        //  IF-HUB  정보
        List<IF_SystemInfo__mdt> ifSystemInfoList  = getSystemInfo( ifConfig.SystemInfo__c);
        if ( ifSystemInfoList.size() > 0) this.ifSystemInfo = ifSystemInfoList.get( 0);
    }

    /**
    * @description http callout method
    * @param bodyParm : 요청 파라미터
    * @param urlParam : 추가 URL
    * @return Map<String, Object> 
    **/
    public Map<String,Object> httpCallout( String bodyParam, String urlParam) {

        // 처리 결과 Result
        Map<String, Object> result = new Map<String, Object>{

            'StatusCode'    => '',
            'HttpResponse'  => '',
            'Log'           => '',
            'Message'       => '',
            'Exception'     => '',
            'ExceptionMsg'  => '',
            'Request'       => '',
            'Response'      => ''
        };

        String       calloutLog = '';
        String       debugCalloutLog = '';
        HttpRequest  request    = new HttpRequest();
        HttpResponse response   = new HttpResponse();
        Http         http       = new Http();
        try {

            // 추가 인증 Header 정보
            if( !String.isEmpty( this.ifConfig.AddHeader__c)){

                Map<String, Object> addHeaderMap = ( Map<String, Object>) JSON.deserializeUntyped( this.ifConfig.AddHeader__c);

                Set<String> headers = addHeaderMap.keySet();
                for(String  header : headers){

                    request.setHeader( header, String.valueOf(addHeaderMap.get(header)));
                }
            }

            // Authorization: 로그인 인증 정보
            if( !String.isEmpty( this.ifSystemInfo.Authorization__c)){

                request.setHeader( 'Authorization', this.ifSystemInfo.Authorization__c);
                system.debug('header_______' + this.ifSystemInfo.Authorization__c);
            }else if( this.ifConfig.SystemInfo__c == 'Salesforce'){ // 세일즈포스에서 자체 로그인 처리

                request.setHeader( 'Authorization', 'OAuth ' + UserInfo.getSessionId());

                if (DEBUG_FLAG) System.debug( ':::ddddddddd:::' + 'OAuth ' + UserInfo.getSessionId());
            }

            // Content-type : 전송 인코딩 방식
            if ( !String.isEmpty( this.ifConfig.ContentType__c)) {

                request.setHeader( 'Content-Type', this.ifConfig.ContentType__c);
            }

            // Method 방식
            if( !String.isEmpty( this.ifConfig.Method__c)){

                request.setMethod( this.ifConfig.Method__c.toUpperCase());
            }

            

            // 호출  url
            String fPrefix  = Util_String.nvlStr( ifSystemInfo.RemoteSite__c);
            if( fPrefix != '') fPrefix = '/' + fPrefix;
            String version  = ifConfig.Version__c;
            String url      = ifSystemInfo.IfUrl__c + fPrefix + '/' + version + ifConfig.Endpoint__c;
            if (DEBUG_FLAG) System.debug( 'Endpoint::::' + url);
            request.setEndpoint( EncodingUtil.urlDecode(url,'UTF-8').trim());            
            // 요청 파라미터 
            if( bodyParam != '') request.setBody( bodyParam);
            request.setTimeout( CALLOUT_TIME);
            calloutLog  = '{"Request" : "'+ String.valueOf( request) + ', "Body" : ' + String.valueOf( request.getBody());
            result.put('Request' , calloutLog);
            system.debug('Demand Request :' + calloutLog);
            response    = http.send( request);
            system.debug('response : '+response);
            debugCalloutLog += '"Response :"' + response + '\n';

            /*
            if(response == null || ( response.getStatusCode() != 200 && response.getStatusCode() != 202) ){
                Integer cnt = 0;
                do{
                    Utils.sleep(500);
                    response = http.send(request);
                    cnt++;
                    if(response != null && ( response.getStatusCode() == 200 || response.getStatusCode() == 202) ) ){
                        break;
                    }
                    
                }
                while(cnt < 3);
            }
            */
            calloutLog += '"Response" : "'+ String.valueOf( response) + '"}';
            debugCalloutLog += '"Response toString" : "'+ String.valueOf( response) + '"}';
            result.put('Response', String.valueOf( response.getBody()));

            result.put( 'StatusCode'  , response.getStatusCode());
            result.put( 'HttpResponse', response);

            // result.put( 'StatusCode'  , 400);
            if( response.getStatusCode() >= 300){

               result.put( 'IF_MSG', System.Label.IF_ADMIN_MSG_001);
            }else {
               result.put( 'IF_MSG' , '');
            }

            if (DEBUG_FLAG) system.debug('result : '+result);
			system.debug('Demand result :' + result);
        }catch(Exception e) {
			if (DEBUG_FLAG) system.debug('excepton : '+e);
            calloutLog += '{"Exception" : "'+e.getMessage()+'"}';
            debugCalloutLog += '{"Exception" : "'+e.getMessage() + ',' + e.getStackTraceString() + '"}';
            result.put('ExceptionMsg',e.getMessage());
            result.put('StatusCode'  , 500);
            result.put('Message'     , e.getMessage());
            result.put('Exception'   , e);
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
        }

        result.put('Log' , calloutLog);
        result.put('DEBUG_LOG' , debugCalloutLog);
        return result;
    }
    //knox calendar integration
	public Map<String,Object> httpKnoxCallout( String bodyParam, String urlParam) {

        // 처리 결과 Result
        Map<String, Object> result = new Map<String, Object>{

            'StatusCode'    => '',
            'HttpResponse'  => '',
            'Log'           => '',
            'Message'       => '',
            'Exception'     => '',
            'ExceptionMsg'  => '',
            'Request'       => '',
            'Response'      => ''
        };

        String       calloutLog = '';
        String       debugCalloutLog = '';
        HttpRequest  request    = new HttpRequest();
        HttpResponse response   = new HttpResponse();
        Http         http       = new Http();
        try {

            // 추가 인증 Header 정보
            if( !String.isEmpty( this.ifConfig.AddHeader__c)){

                Map<String, Object> addHeaderMap = ( Map<String, Object>) JSON.deserializeUntyped( this.ifConfig.AddHeader__c);

                Set<String> headers = addHeaderMap.keySet();
                for(String  header : headers){

                    request.setHeader( header, String.valueOf(addHeaderMap.get(header)));
                }
            }
            //Passing knox system id and authorization bearer in header
            if(isSandbox){
			request.setHeader('Authorization', Label.Sandbox_Knox_Bearer);
            request.setHeader('System-ID',Label.Sandbox_Knox_System_Id);
            }else{
            request.setHeader('Authorization', Label.Prod_Knox_Bearer);
            request.setHeader('System-ID',Label.Prod_Knox_System_Id);
            }
            system.debug('Knox_Authorization_______' + request.getHeader('Authorization'));
            system.debug('knox_systemid_______' + request.getHeader('System-ID'));
            // Authorization: 로그인 인증 정보
            if( !String.isEmpty( this.ifSystemInfo.Authorization__c)){

                request.setHeader( 'Authorization', this.ifSystemInfo.Authorization__c);
               // system.debug('header_______' + this.ifSystemInfo.Authorization__c);
            }else if( this.ifConfig.SystemInfo__c == 'Salesforce'){ // 세일즈포스에서 자체 로그인 처리

                request.setHeader( 'Authorization', 'OAuth ' + UserInfo.getSessionId());

                if (DEBUG_FLAG) System.debug( ':::ddddddddd:::' + 'OAuth ' + UserInfo.getSessionId());
            }

            // Content-type : 전송 인코딩 방식
            if ( !String.isEmpty( this.ifConfig.ContentType__c)) {

                request.setHeader( 'Content-Type', this.ifConfig.ContentType__c);
            }

            // Method 방식
            if( !String.isEmpty( this.ifConfig.Method__c)){

                request.setMethod( this.ifConfig.Method__c.toUpperCase());
            }

            

            // 호출  url
            String fPrefix  = Util_String.nvlStr( ifSystemInfo.RemoteSite__c);
            if( fPrefix != '') fPrefix = '/' + fPrefix;
            String version  = ifConfig.Version__c;
            //String url      = ifSystemInfo.IfUrl__c + fPrefix + '/' + version + ifConfig.Endpoint__c;
            String url      = ifSystemInfo.IfUrl__c + fPrefix  + ifConfig.Endpoint__c;
            if (DEBUG_FLAG) System.debug( 'Endpoint::::' + url);
           // passing knox api query in endpoint
            request.setEndpoint( EncodingUtil.urlDecode(url,'UTF-8').trim() + urlParam);            
            // 요청 파라미터 
            if( bodyParam != '') request.setBody( bodyParam);
            request.setTimeout( CALLOUT_TIME);
            calloutLog  = '{"Request" : "'+ String.valueOf( request) + ', "Body" : ' + String.valueOf( request.getBody());
            result.put('Request' , calloutLog);
            system.debug('Demand Request :' + calloutLog);
            response    = http.send( request);
            system.debug('response : '+response);
            debugCalloutLog += '"Response :"' + response + '\n';

            /*
            if(response == null || ( response.getStatusCode() != 200 && response.getStatusCode() != 202) ){
                Integer cnt = 0;
                do{
                    Utils.sleep(500);
                    response = http.send(request);
                    cnt++;
                    if(response != null && ( response.getStatusCode() == 200 || response.getStatusCode() == 202) ) ){
                        break;
                    }
                    
                }
                while(cnt < 3);
            }
            */
            calloutLog += '"Response" : "'+ String.valueOf( response) + '"}';
            debugCalloutLog += '"Response toString" : "'+ String.valueOf( response) + '"}';
            result.put('Response', String.valueOf( response.getBody()));

            result.put( 'StatusCode'  , response.getStatusCode());
            result.put( 'HttpResponse', response);

            // result.put( 'StatusCode'  , 400);
            if( response.getStatusCode() >= 300){

               result.put( 'IF_MSG', System.Label.IF_ADMIN_MSG_001);
            }else {
               result.put( 'IF_MSG' , '');
            }

            if (DEBUG_FLAG) system.debug('result : '+result);
			system.debug('Demand result :' + result);
        }catch(Exception e) {
			if (DEBUG_FLAG) system.debug('excepton : '+e);
            calloutLog += '{"Exception" : "'+e.getMessage()+'"}';
            debugCalloutLog += '{"Exception" : "'+e.getMessage() + ',' + e.getStackTraceString() + '"}';
            result.put('ExceptionMsg',e.getMessage());
            result.put('StatusCode'  , 500);
            result.put('Message'     , e.getMessage());
            result.put('Exception'   , e);
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
        }

        result.put('Log' , calloutLog);
        result.put('DEBUG_LOG' , debugCalloutLog);
        return result;
    }

}