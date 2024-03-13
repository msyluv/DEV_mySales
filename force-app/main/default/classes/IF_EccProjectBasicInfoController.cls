/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-18
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-02-04   raeganja@partner.samsung.com   Initial Version
 * 1.1   2021-02-18   kilhwan.an@partner.samsung.com   FinalBusinessLevel__c  필드 추가 및  사업등급 변경
**/
public class IF_EccProjectBasicInfoController {
    public IF_EccProjectBasicInfoController() {
    }

    private static final String INTERFACE_ID = 'IF-010';
    private static final String APEX_CLASS   = 'IF_EccProjectBasicInfoController';
    private static final String METHOD_NAME  = 'getProjectBasicInfo';

    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    public static String QUERY_STRING = 'Select Id ' +		
    '	    , OpportunityCode__c ' +                                    // 사업 기회 Code
    '	    , Name ' +                                                  // 사업기회명
    '	    , StageName ' +                                             // 단계
    '       , ActivityStatus__c ' +                                     // Current BO Activity Status
    '	    , Type ' +                                                  // 사업기회 유형
    '	    , Account.AccountNumber ' +                                 // Contract Account
    '	    , cOriginAcc__r.AccountNumber ' +                           // 원청사 고객
    '	    , Owner.EmployeeNumber ' +                                  // 소유자 (영업 대표)
    '	    , Owner.Name ' +                                            // 소유자 (영업 대표)
    '	    , ProposalPM__r.EvSapEmpNO__c ' +                           // 제안 PM
    '	    , ProposalPM__r.EvHName__c ' +                              // 제안 PM
    '	    , GroupInternal__c ' +                                      // 그룹 내 사업 여부
    '	    , KoreaDomestic__c ' +                                      // 국내/해외 여부
    '	    , Amount ' +                                                // 예상금액
    '	    , CurrencyIsoCode ' +                                       // 사업 기회 금액의 통화
    '	    , CloseDate ' +                                             // 예상수주일자
    '	    , cRevenueStartDate__c ' +                                  // (계약)매출 시작일
    '	    , cRevenueEndDate__c ' +                                    // (계약)매출 종료일
    '	    , CompanyCode__c ' +                                        // Company Code
    '	    , IsDeleted ' +                                             // 삭제 여부
    '	    , CreatedDate ' +                                           // Opportunity 등록일
    '	    , CreatedBy.EmployeeNumber ' +                              // Opportunity 등록자 사번
    '	    , LastModifiedDate ' +                                      // Opportunity 수정일
    '	    , LastModifiedBy.EmployeeNumber ' +                         // Opportunity 수정자 사번
    '	    , BusinessType__c ' +                                       // 사업 유형
    '	    , tolabel(BusinessType__c) BusinessTypeLabel ' +            // 사업 유형명
    '       , cOriginAcc__r.Name ' +                                    // 원청사 고객명
    '       , Account.Name ' +                                          // 고객사명
    '	    , Probability ' +                                           // 확도
    '	    , VRBMethod__c ' +                                          // VRB 유형
    '	    , Description ' +                                           // 사업기회 개요
    '	    , Collaboration__c ' +                                      // 법인 협업 여부
    '       , IsOriginal__c ' +                                         // 
    '	    , OpportunityStatus__c ' +                                  // Opportunity Status
    '	    , toLabel( OpportunityStatus__c) OpportunityStatusLabel ' + // Opportunity Status 명
    '	    , SalesDepartment__r.CostCenter__c ' +                      // 수주 사업그룹 코스트센터 코드
    '	    , cPrimarySalesDepartment__r.CostCenter__c ' +              // 주 매출 부서 코스트센터 코드
    '	    , BusinessLevel__c ' +                                      // 사업 등급
    '	    , FinalBusinessLevel__c ' +                                 // 사업 등급 => 20210218 추가
    '	    , BiddingMethod__c ' +                                      // 입찰 방식
    '       , Account.Owner.EmployeeNumber ' +                          // 고객오너(영업대표)
    '       , Account.Owner.Name ' +                                    // 고객오너(영업대표) 명
    '	    , BizTeamAttributes01__c ' +                                // 사업팀 정의 속성01
    '	    , BizTeamAttributes02__c ' +                                // 사업팀 정의 속성02
    '	    , BizTeamAttributes03__c ' +                                // 사업팀 정의 속성03
    '	    , BizTeamAttributes04__c ' +                                // 사업팀 정의 속성04
    '	    , LogisticsCustomerType__c ' +                              // 물류 고객 구분
    '	    , LogisticsBizDevelopmentType__c ' +                        // 사업 개발 유형
    '	    , SalesRegion__c ' +                                        // 수주 권역
    '	    , SalesOrganization__r.Region__c ' +                        // 수주 권역 코드
    '	    , SalesOrganization__c ' +                                  // 수주 거점
    '	    , SalesOrganization__r.Code__c ' +                          // 수주 거점 코드
    '	    , DeliveryRegion__c ' +                                     // 매출 권역
    '	    , DeliveryOrganization__r.Region__c ' +                     // 매출 권역 코드
    '	    , DeliveryOrganization__c ' +                               // 매출 거점
    '	    , DeliveryOrganization__r.Code__c ' +                       // 매출 거점 코드
    '	    , LogisticsBizType__c ' +                                   // 물류 서비스 범위
    '	    , LogisticsServiceType__c ' +                               // 물류 서비스 영역
    '	    , BiddingDeadline__c ' +                                    // 입찰 마감일
    '	    , LBSExceptionType__c ' +                                   // 예외 LBS 유형 확인
    '	    , SubIndusrty__c ' +                                        // 하위 업종 구분
    '       , Owner.FederationIdentifier ' +                            // 소유자 (영업 대표)의 EP ID
    '       , CreatedBy.FederationIdentifier ' +                        // Created By ID의 EP ID
    '       , LastModifiedBy.FederationIdentifier ' +                   // Last Modified By ID의 EP ID
    '       , ResourcePreInput__c ' +                                   // 선투입 여부
    '       , Reuse__c ' +                                              // 재활용 필요성 여부
    '       , ReuseReason__c ' +                                        // 재활용 필요성 여부 사유
    'From   Opportunity ' +
    'Where  EPCompanyCode__c != null ';
    //'AND    MigData__c = false '; // 2021-02-02 / younghoon.kim / Migration Data는 SAP으로 전송하지않도록 조건 추가
    //'AND    RecordType.DeveloperName != \'Logistics\' ' ;

    @AuraEnabled
    public static Map<String, Object> getProjectBasicInfo(String selectId){
        String guId = IF_Util.generateGuid();

        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        try {

            // *************************************
            // Opportunity 기본정보 조회
            // *************************************
            String queryString = QUERY_STRING + ' And    Id = :selectId ';
            Organization org = [ SELECT Id, isSandBox FROM Organization];
            if( org.IsSandbox && org.Id != '00D1s0000008pnsEAA'){       // Dev Id 제외 (00D1s0000008pnsEAA)
                // 10, 50, 100, 200, 300, 400, 500
                //queryString = queryString + ' AND CreatedById = \'0051s000000zvP1AAI\' ' ;
                //queryString += ' ORDER BY Systemmodstamp DESC LIMIT 10 ';
            }            
            queryString = queryString + 'ALL ROWS ';
            System.debug( 'queryString::::' + queryString);

            Opportunity opportunity = Database.query(queryString);
            
            if (DEBUG_FLAG) ifLog.addLog('Opportunity : ' + opportunity.Id);
            system.debug('처리 대상 ID : ' + opportunity.Id);

            // *************************************
            // Opportunity 상세정보 정보 가져오기
            // *************************************
            OutputHeader outHeader = getOpportunityDetailInfo(opportunity);

            // *************************************
            // Interface 통신
            // *************************************

            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            //OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            } else {
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }
        return result;
    }

    public static OutputHeader getOpportunityDetailInfo(Opportunity oppData) {

        // Request Data 만들기
        String flagTrue = '10';
        String flagFalse = '20';
        String flagSapTrue = 'X';
        String flagSapFalse = '_';

        OutputHeader outHeader = new OutputHeader();

        if (oppData != null) {            
            outHeader.ZZORDER_ID            = oppData.OpportunityCode__c;                                       //BO코드
            outHeader.DESCRIPTION           = oppData.Name;                                                     //BO명

            outHeader.ZZSALEMP_CNO          = oppData.Owner.EmployeeNumber;                                     // 영업대표사번
            outHeader.ZZPROPOSAL_PM_CNO     = oppData.ProposalPM__r.EvSapEmpNO__c;                              // 제안PM 사번
            outHeader.ZZSALES_C_NAME_M      = oppData.SalesDepartment__r.CostCenter__c;                         // 수주 코스트센터 코드
            outHeader.ZZDEV_C_NAME_M        = oppData.cPrimarySalesDepartment__r.CostCenter__c;                 // 매출 코스트센터 코드

            outHeader.CURRENCY_CODE         = oppData.CurrencyIsoCode;                                          // 통화
            outHeader.ZCONTRACTEXP          = Util_String.convertDateString(oppData.CloseDate);                 // 수주예상일
            outHeader.ZDEVELOPTIME_FR       = Util_String.convertDateString(oppData.cRevenueStartDate__c);      //프로젝트기간From
            outHeader.ZDEVELOPTIME_TO       = Util_String.convertDateString(oppData.cRevenueEndDate__c);        //프로젝트기간To

            // outHeader.ZZBIZ_LEVEL           = oppData.BusinessLevel__c;                                      // 사업 등급//사업등급
            outHeader.ZZBIZ_LEVEL           = oppData.FinalBusinessLevel__c;                                    // 사업 등급//사업등급 : 20210218

            outHeader.ZZDOM_ABR_TYPE        = oppData.KoreaDomestic__c == true ? flagTrue : flagFalse;          // 고객사 국내/외(10 : 국내 / 20 : 해외)
            outHeader.ZZIN_OUT_TYPE         = oppData.GroupInternal__c == true ? flagTrue : flagFalse;          // 고객사 그룹내/외(10 : 그룹내 / 20 : 그룹외) 
            outHeader.PARTNER_ORIGIN        = oppData.cOriginAcc__r.AccountNumber;                              // 원청사 고객번호
            outHeader.PARTNER_CUST          = oppData.Account.AccountNumber;                                    // 고객사 고객번호
            outHeader.EXEC_PM_NO            = oppData.ProposalPM__r.EvSapEmpNO__c;                              // 실행PM 사번
            outHeader.ZZVRB_FQ              = oppData.VRBMethod__c;                                             // VRB 유형
            
            outHeader.BUKRS                 = oppData.CompanyCode__c;                                           // Company Code

            outHeader.ZZINPUT_P             = oppData.ResourcePreInput__c == true ? flagSapTrue : flagSapFalse; // 선투입 <- 선투입 여부 (X(True) / _(False)) (2020-12-28 추가)
            outHeader.ZZBIZ_FROM_DT         = Util_String.convertDateString(oppData.cRevenueStartDate__c);      // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가)
            outHeader.ZZBIZ_TO_DT           = Util_String.convertDateString(oppData.cRevenueEndDate__c);        // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가)
        }

        return outHeader;
    }

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public String ZZORDER_ID;//BO코드
        @AuraEnabled
        public String DESCRIPTION;//BO명
        @AuraEnabled
        public String ZZSALEMP_CNO;//영업대표사번
        @AuraEnabled
        public String ZZPROPOSAL_PM_CNO;//제안PM 사번
        @AuraEnabled
        public String ZZSALES_C_NAME_M;//수주 코스트센터 코드
        @AuraEnabled
        public String ZZDEV_C_NAME_M;//매출 코스트센터 코드
        @AuraEnabled
        public String CURRENCY_CODE;//통화
        @AuraEnabled
        public String ZCONTRACTEXP;//수주예상일
        @AuraEnabled
        public String ZDEVELOPTIME_FR;//프로젝트기간From
        @AuraEnabled
        public String ZDEVELOPTIME_TO;//프로젝트기간To
        @AuraEnabled
        public String ZZBIZ_LEVEL;//사업등급
        @AuraEnabled
        public String ZZDOM_ABR_TYPE;//고객사 국내/외
        @AuraEnabled
        public String ZZIN_OUT_TYPE;//고객사 그룹내/외
        @AuraEnabled
        public String PARTNER_ORIGIN;//원청사 고객번호
        @AuraEnabled
        public String PARTNER_CUST;//고객사 고객번호
        @AuraEnabled
        public String EXEC_PM_NO;//실행PM 사번
        @AuraEnabled
        public String ZZVRB_FQ;//VRB유형
        @AuraEnabled
        public String BUKRS;//Company Code
        @AuraEnabled
        public String ZZINPUT_P;//선투입
        @AuraEnabled
        public String ZZBIZ_FROM_DT;//개발시작일
        @AuraEnabled
        public String ZZBIZ_TO_DT;//개발완료일
    }
}