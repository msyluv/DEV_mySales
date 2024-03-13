/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2020-11-04
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2020-11-03   kilhwan.an@partner.samsung.com   Initial Version
**/
public with sharing abstract class IF_Master {


    /**
    * @description 
    * @author kilhwan.an@partner.samsung.com | 2020-11-03 
    * @param ifId       인터페이스 id
    * @param reqBody    파라미터
    * @return Object 
    **/
    protected Object getCallRestApi( String ifId, String reqBody){

        // Callout 
        List<Object>         resultClass = new List<Object>();
        IF_Callout           handler     = new IF_Callout( ifId);
        Map<String, Object>  resultMap   = handler.httpCallout( reqBody, '');
        Object               resObj      = resultMap.get( 'HttpResponse');
        String               jsonData    = null;
        if( resObj != null){

            HttpResponse res = ( HttpResponse)resObj;
            jsonData = res.getBody().escapeJava();
        }
        
        return getReturnValue( jsonData);
    }


    /**
    * @description 처리 리턴 결과
    * @author kilhwan.an@partner.samsung.com | 2020-11-03 
    * @param jsonData 처리 결과 데이터
    * @param ; 
    * @return abstract 
    **/
    protected abstract Object getReturnValue( String jsonData);
}