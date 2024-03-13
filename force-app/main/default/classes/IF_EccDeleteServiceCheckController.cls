/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-12-30
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2020-12-23   ghkil@partner.samsung.com   return Type Class에서 Map으로 변경
**/

/*  테스트 데이터
IF_EccDeleteServiceCheckController bb = new IF_EccDeleteServiceCheckController();
IF_EccDeleteServiceCheckController.ParamClass kk = new IF_EccDeleteServiceCheckController.ParamClass();
kk.projectCode	 = 'SCA07000285A000';
kk.serviceCode	 = null;

System.debug( 'zzzz:' + bb.deleteServiceCheck( JSON.serialize( kk)));
*/

public class IF_EccDeleteServiceCheckController {
    
    private static final String INTERFACE_ID = 'IF-034';
    private static final String APEX_CLASS   = 'IF_EccDeleteServiceCheckController';
    private static final String METHOD_NAME  = 'deleteServiceCheck';

    /**
    * @description 서비스 삭제가능 여부 체크하기 
    * @author kilhwan.an@partner.samsung.com | 2020-11-16 
    * @param params   ParamClass값을  json으로 변환
    * @return List<Object> 
    **/
    @AuraEnabled
    public static Map<String, Object> deleteServiceCheck( String params){

        Map<String, Object> resMap;

        IF_Log       log      = new IF_Log();
        String       guId     = IF_Util.generateGuid();
        // OutputHeader outHeader= null;
        IF_Log.InterfaceLog ifLog   = null;
        try{

            ParamClass paramCls= (ParamClass) JSON.deserialize( params, ParamClass.class);
            InputClass inClass = new InputClass();
            inClass.IV_PSPID   = paramCls.projectCode;
            inClass.IV_SRVCD   = paramCls.serviceCode;

            String              jsonData= JSON.serialize( inClass);
            IF_Callout          call    = new IF_Callout( INTERFACE_ID);
            resMap                      = call.httpCallout( jsonData, '');


            // 로그설정
            String respVal = String.valueOf( resMap.get( 'Response'));
            ifLog  = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, jsonData, respVal);
            
            // // 결과값            
            // if( respVal != null){

            //     outHeader = ( OutputHeader)JSON.deserialize( respVal, OutputHeader.class);
            // }
        }catch( Exception e){

            //  로그 설정
            ifLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, JSON.serialize( params), e.getStackTraceString());
        }finally{
            
            // 로그 등록
            log.createLog(ifLog);
        }

        // return outHeader;
        return resMap;        
    }


    ////// 검색 파라미터 ////
    public class ParamClass{

        @AuraEnabled
        public String projectCode;
        @AuraEnabled
        public String serviceCode;        
    }


    ////// JSON 형식: BODY 정보
    public class InputClass{

        @AuraEnabled
        public String IV_PSPID;
        @AuraEnabled
        public String IV_SRVCD;
    }

   
    // public class OutputHeader{

    //     @AuraEnabled
    //     public String EV_RTNST; //메시지 유형: S 성공, E 오류, W 경고, I 정보, A 중단
        
    //     // @AuraEnabled
    //     // public List<TT_RTNOutputClass>  TT_RTN;
    // }
    /*
    public class TT_RTNOutputClass{

        public String TYPE;         // Message type: S Success, E Error, W Warning, I Info, A Abort
        public String ID;           // Message Class
        public String NUMBER;       // Message Number
        public String MESSAGE;      // Message Text
        public String LOG_NO;       // Application log: log number
        public String LOG_MSG_NO;   // Application log: Internal message serial number
        public String MESSAGE_V1;   // Message Variable
        public String MESSAGE_V2;   // Message Variable
        public String MESSAGE_V3;   // Message Variable
        public String MESSAGE_V4;   // Message Variable
        public String PARAMETER;    // Parameter Name
        public Integer ROW;         // Lines in parameter
        public String FIELD;        // Field in parameter
        public String SYSTEM;       // Logical system from which message originates

    }
    */
}