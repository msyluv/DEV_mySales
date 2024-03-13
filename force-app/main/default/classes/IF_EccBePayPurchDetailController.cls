/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-01-22
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-16   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2020-12-23   ghkil@partner.samsung.com        return Type Class에서 Map으로 변경
 * 1.2   2021-01-22   younghoon.kim@dkbmc.com     IF Log를 Return 해주는 방식으로 수정 (CalloutException 방지)
**/


/* 테스트 데이터
IF_EccBePayPurchDetailController bb = new IF_EccBePayPurchDetailController();
IF_EccBePayPurchDetailController.ParamClass kk = new IF_EccBePayPurchDetailController.ParamClass();
kk.boCode 		 = 'SDS-20054480';
System.debug( 'zzzz:' + bb.bePayPurchDetailChk( JSON.serialize( kk)));
*/
public class IF_EccBePayPurchDetailController {

    private static final String INTERFACE_ID = 'IF-055';
    private static final String APEX_CLASS   = 'IF_EccBePayPurchDetailController';
    private static final String METHOD_NAME  = 'bePayPurchDetailChk';
        
    
    /**
    * @description 결재 수행 전, 구매내역(MM) 체크하기
    * @author kilhwan.an@partner.samsung.com | 2020-11-16 
    **/
    @AuraEnabled
    public static Map<String, Object> bePayPurchDetailChk( String params ) {

        Map<String, Object> resMap;

        IF_Log       log      = new IF_Log();
        String       guId     = IF_Util.generateGuid();
        // OutputHeader outHeader= null;
        IF_Log.InterfaceLog ifLog   = null;

        try{
            ////// 입력 파라미터 설정: json 구조 확인 /////
            ParamClass paramCls= ( ParamClass) JSON.deserialize( params, ParamClass.class);
            InputClass inClass = new InputClass();
            inClass.IV_ZZCCODE = paramCls.boCode;


            ////
            String              jsonData= JSON.serialize( inClass);
            IF_Callout          call    = new IF_Callout( INTERFACE_ID);
            resMap                      = call.httpCallout( jsonData, '');

            // 로그기록
            String  respVal = String.valueOf( resMap.get( 'Response'));
            ifLog   = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, 'POST', jsonData, respVal);
            
            
            ///// 출력 파라미터: 아래 주석 클래스 참고(예약어 관계로 클래스 설계 불가) //////
            // if( respVal != null){

            //     // dataList = ( List<Object>)resMap.get( 'KEY값') ; //필드명 정의 필요
            //     outHeader = ( OutputHeader)JSON.deserialize( respVal, OutputHeader.class);
            // }
        }catch( Exception e){

            //  로그 설정
            ifLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, 'POST', JSON.serialize( params), e.getStackTraceString());
        }finally{
            
            // 로그 등록
            /** 
             * 2020-01-22 | younghoon.kim@dkbmc.com
             * CalloutException으로 log정보 returnMap에 추가하여 직접 로그 생성하도록 수정
             * */
            // log.createLog(ifLog);           
            resMap.put('INTERFACE_LOG', ifLog);
        }
        // return outHeader;
        return resMap;        
    }

    ////// 검색 파라미터 ////
    public class ParamClass{

        @AuraEnabled
        public String boCode; // B/O Code : SDS-20054480
    }
    
    ////// JSON 형식: BODY 정보
    public class InputClass{

        @AuraEnabled
        public String IV_ZZCCODE;
    }


    // //////출력 내용: 포펫 확인 필요 /////
    // public class OutputHeader{

    //     @AuraEnabled
    //     public String EV_STATUS; // Status (1:Possibility,2:Impossibility)

    //     @AuraEnabled
    //     public String EV_MSGTY; // Message type: S Success, E Error, W Warning, I Info, A Abort

    //     @AuraEnabled
    //     public String EV_MSGTXT; // Message Text

    //     // @AuraEnabled
    //     // public List<OutputClass> ET_PE;        
    // }

    //// 리스트 내용 
    // public class OutputClass{

    //     @AuraEnabled
    //     public String PS_PSPID; // Project Definition
    //     @AuraEnabled
    //     public String PS_POST1; // PS: Short description (1st text line)
    //     @AuraEnabled
    //     public String BANFN;    // Purchase Requisition Number
    //     @AuraEnabled
    //     public String ZZ_EPEREQ;// PE activity description
    //     @AuraEnabled
    //     public String ZZ_ESTATU;// 상태지시자
    //     @AuraEnabled
    //     public String VAL_TEXT; // Short Text for Fixed Values
        
    // }    



}