/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 06-29-2021
 * @last modified by  : yeongju.baek@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-03   seonju.jin@dkbmc.com   Initial Version
**/
public class SearchRoadAddressController {
    /**
    * @description 검색 주소 update
    * @author seonju.jin@dkbmc.com | 2020-11-03 
    * @param String recordId 
    * @param String addrInfoJson 
    * @return String
    **/
    @AuraEnabled
    @RemoteAction
    public static String saveAddress(String recordId, String addrInfoJson){
        String returnMsg = '';

        try {
            Map<String,Object> addr = (Map<String, Object>)JSON.deserializeUntyped(addrInfoJson);

            Account acct = [SELECT Id, Name
                                        , BillingState, BillingCity, BillingStreet, BillingPostalCode, BillingCountry
                                        , ShippingState, ShippingCity, ShippingStreet, ShippingPostalCode, ShippingCountry
                                     FROM Account
                                    WHERE Id =: recordId];
                                    
            //행정구역코드(admCd)는 법정시도 코드(2자리) + 법정시군구 코드(3자리) + 읍면동(3자리) + 00 로 총 10자리로구성되어있음
            String roadAddrPart2 = (addr.get('roadAddrPart2') == null)  ? '' : addr.get('roadAddrPart2').toString();
            String stateKR       = (addr.get('siNm') == null)           ? '' : addr.get('siNm').toString();             //시도명
            String city          = (addr.get('sggNm') == null)          ? '' : addr.get('sggNm').toString();            //시군구
            String zipNo         = (addr.get('zipNo') == null)          ? '' : addr.get('zipNo').toString();            //우편번호
            String roadAddr      = (addr.get('roadAddr') == null)       ? '' : addr.get('roadAddr').toString();         //도로명 주소
            String addrDetail    = (addr.get('addrDetail') == null)     ? '' : addr.get('addrDetail').toString();       //상세주소
            String admCd         = (addr.get('admCd') == null)          ? '' : addr.get('admCd').toString();            //행정구역코드
            String engAddr       = (addr.get('engAddr') == null)        ? '' : addr.get('engAddr').toString();            //engAddr
            String street        = roadAddr + ' ' + addrDetail + roadAddrPart2;
            
            String country = 'Korea, Republic of';
            
            System.debug('stateKR:' + stateKR);
            System.debug('engAddr:' + engAddr);

            //시도명 영문 명 얻기
            Integer idx = (engAddr.length() > 0) ? engAddr.lastIndexOf(',') : -1;
            
            String state = '';
            if(idx != -1){
            	state = engAddr.substring(idx + 1,engAddr.length());
            }
            state = state.trim();
            
            System.debug('state:' + state);
            //String state = getSidoEngNmWithAPI(roadAddr);
            
            if(!String.isEmpty(state)){
                acct.BillingState  = state;
                acct.ShippingState = state;
            }

            acct.BillingCity        = city;
            acct.BillingStreet      = street;
            acct.BillingPostalCode  = zipNo;
            acct.BillingCountry     = country;
            acct.ShippingCity       = city;
            acct.ShippingStreet     = street;
            acct.ShippingPostalCode = zipNo;
            acct.ShippingCountry    = country;
            
            update acct;
        }catch (Exception e) {
            returnMsg = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        
        return returnMsg;
    }

    /**
    * @description 시도 영문명 얻기
    * @author seonju.jin@dkbmc.com | 2020-11-11 
    * @param String roadAddress 도로명주소
    * @return String 시도 영문명
    * @link https://https://www.juso.go.kr/addrlink/devAddrLinkRequestUse.do?menu=engRoadSearch
    **/
    /* public static String getSidoEngNmWithAPI(String roadAddress){
        String siNm = '';

        //set http request Parameter
        String confirmKey = 'devU01TX0FVVEgyMDIxMDQxNDA4NTQyOTExMTA0NzM='; //System.Label.API_ADDR_ENG_CONFMKEY;
        String countPerPage = '1';
        String currentPage= '1';
        String resultType = 'json';
        String keyword = roadAddress;
        String url = 'http://www.juso.go.kr/addrlink/addrEngApi.do';

        String param = '';
        param += '?currentPage=' + currentPage;
        param += '&countPerPage=' + countPerPage;
        param += '&keyword=' + keyword;
        param += '&confmKey=' + confirmKey;
        param += '&resultType=' + resultType;
        url += param;

        //get response
        //String responseBody = getResponse(url);
        String responseBody = '';
        try{
            HttpRequest req = new HttpRequest();
            //req.setTimeout ( 60000 ); 
            req.setEndpoint(url);
            req.setMethod('GET');
            req.setHeader('Content-Type', 'application/json');
    
            Http http = new Http();
            HttpResponse res = http.send(req);
            responseBody = res.getBody();
			System.debug(responseBody);		

            ClassResult result = (ClassResult)JSON.deserialize(responseBody, ClassResult.class );
            ClassJuso resultsJuso = result.results;
            Common common = resultsJuso.common;     //common
            List<Juso> jusoList = resultsJuso.juso; //juso info
    
            if(common.errorCode == '0'){
                for(Juso juso : jusoList){
                    siNm = juso.siNm;
                    break;  //시군구 영문명만 획득하면 되기때문에 한건만 돌림.
                }
            }
            
        }catch(Exception e){
            System.debug(e.getStackTraceString());
            System.debug(e.getMessage());
            siNm = 'Seoul';
        }
        return siNm;
    } */

    @AuraEnabled
    public static string getUserLocale(){
        return UserInfo.getLocale();
    }
    
    @AuraEnabled
    public static String getUserProfile(){
        String userId = UserInfo.getUserId();
        String userProfile = [select Profile.Name from User where id =: userId].Profile.Name;
        return userProfile;
        
    }
    @AuraEnabled
    public static string getRecordNo(String recordId){
        String Id = recordId;
        String recordNo = [select AccountNumber from Account where id =: recordId].AccountNumber;
        return recordNo;
    }


    public class ClassResult {
        @AuraEnabled
        public ClassJuso results;
    }

    public class ClassJuso{
        @AuraEnabled
        public Common common;
        @AuraEnabled
        public List<Juso> juso;
    }

    public class Common{
        @AuraEnabled
        public String errorMessage;
        @AuraEnabled
        public String countPerPage;
        @AuraEnabled
        public String totalCount;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public String currentPage;
    }

    public class Juso{
        @AuraEnabled
        public String roadAddr;
        @AuraEnabled
        public String jibunAddr;
        @AuraEnabled
        public String zipNo;
        @AuraEnabled
        public String admCd;
        @AuraEnabled
        public String rnMgtSn;
        @AuraEnabled
        public String bdKdcd;
        @AuraEnabled
        public String siNm;
        @AuraEnabled
        public String sggNm;
        @AuraEnabled
        public String emdNm;
        @AuraEnabled
        public String liNm;
        @AuraEnabled
        public String udrtYn;
        @AuraEnabled
        public String buldMnnm;
        @AuraEnabled
        public String buldSlno;
        @AuraEnabled
        public String mtYn;
        @AuraEnabled
        public String lnbrMnnm;
        @AuraEnabled
        public String lnbrSlno;
        @AuraEnabled
        public String korAddr;
    }

    /* public class SearchJusoResultClass{
        @AuraEnabled
        public SearchJusoResult results;
    }

    public class SearchJusoResult{
        @AuraEnabled
        public Common common;
        @AuraEnabled
        public List<SearchJuso> juso;
    }

    public class SearchJuso{
        @AuraEnabled
        public String roadAddr;
        @AuraEnabled
        public String roadAddrPart1;
        @AuraEnabled
        public String roadAddrPart2;
        @AuraEnabled
        public String jibunAddr;
        @AuraEnabled
        public String engAddr;
        @AuraEnabled
        public String zipNo;
        @AuraEnabled
        public String admCd;
        @AuraEnabled
        public String rnMgtSn;
        @AuraEnabled
        public String detBdNmList;
        @AuraEnabled
        public String bdNm;
        @AuraEnabled
        public String bdKdcd;
        @AuraEnabled
        public String siNm;
        @AuraEnabled
        public String sggNm;
        @AuraEnabled
        public String emdNm;
        @AuraEnabled
        public String liNm;
        @AuraEnabled
        public String rn;
        @AuraEnabled
        public String udrtYn;
        @AuraEnabled
        public Integer buldMnnm;
        @AuraEnabled
        public Integer buldSlno;
        @AuraEnabled
        public String mtYn;
        @AuraEnabled
        public Integer lnbrMnnm;
        @AuraEnabled
        public Integer lnbrSlno;
        @AuraEnabled
        public String emdNo;
        @AuraEnabled
        public String hstryYn;
        @AuraEnabled
        public String relJibun;
        @AuraEnabled
        public String hemdNm;
    } */
}