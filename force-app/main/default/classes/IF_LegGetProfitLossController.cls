/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-12
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-01-15   raeganja@partner.samsung.com   Initial Version
**/
@RestResource( UrlMapping='/IF031/*')
global class IF_LegGetProfitLossController implements Schedulable{
    private static final String INTERFACE_ID = 'IF-031';
    private static final String APEX_CLASS   = 'IF_LegGetProfitLossController';
    private static final String METHOD_NAME  = 'getProfitLoss';

    @HttpPost
    global static OutputHeader receiveProfitLoss(){
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

            List<Object>        dataList       = (List<Object>)bodyMap.get('IT_DATA');
            List<ProfitLoss__c> profitLossList = new List<ProfitLoss__c>();
            String bizYear  = '';//사업년도;
            String version  = '';//버전;
            String realFlag2= '';//실매출 구분(수주부서 L2);

            for(Object obj : dataList) {
                Map<String,Object> objMap = (Map<String,Object>) obj;

                //Upsert 정보 매핑
            
                bizYear   = Util_String.nvlStr(objMap.get('BizYear'));//사업년도;
                version   = Util_String.nvlStr(objMap.get('Version'));//버전;
                realFlag2 = Util_String.nvlStr(objMap.get('REAL_FLAG2'));//실매출 구분(수주부서 L2);

                if(String.isNotBlank(bizYear) && String.isNotBlank(version) && String.isNotBlank(realFlag2)){
                    ProfitLoss__c profitLoss = new ProfitLoss__c();

                    profitLoss.BizYear__c               = bizYear;//사업년도;
                    profitLoss.Version__c               = version;//버전
                    profitLoss.REAL_FLAG2__c            = realFlag2;//실매출 구분(수주부서 L2)
                    profitLoss.CompanyCode__c           = Util_String.nvlStr(objMap.get('CompanyCode'));//법인코드
                    profitLoss.CompanyName__c           = Util_String.nvlStr(objMap.get('CompanyName'));//법인명
                    profitLoss.BACode__c                = Util_String.nvlStr(objMap.get('BACode'));//Business Area
                    profitLoss.BAName__c                = Util_String.nvlStr(objMap.get('BAName'));//Business Area Name
                    profitLoss.BALANCE_FLAG__c          = Util_String.nvlStr(objMap.get('BALANCE_FLAG'));//차감구분
                    profitLoss.Opportunity__c           = Util_String.nvlStr(objMap.get('Opportunity'));//사업기회코드
                    profitLoss.OpportunityName__c       = Util_String.nvlStr(objMap.get('OpportunityName'));//사업기회명
                    profitLoss.Project__c               = Util_String.nvlStr(objMap.get('Project'));//프로젝트코드
                    profitLoss.ProjectName__c           = Util_String.nvlStr(objMap.get('ProjectName'));//프로젝트명
                    profitLoss.RegionCode__c            = Util_String.nvlStr(objMap.get('RegionCode'));//권역
                    profitLoss.RegionName__c            = Util_String.nvlStr(objMap.get('RegionName'));//권역명
                    profitLoss.SalesDeptL1__c           = Util_String.nvlStr(objMap.get('SalesDeptL1'));//수주부서코드 L1
                    profitLoss.SalesDeptNameL1__c       = Util_String.nvlStr(objMap.get('SalesDeptNameL1'));//수주부서명 L1
                    profitLoss.SalesDeptL2__c           = Util_String.nvlStr(objMap.get('SalesDeptL2'));//수주부서코드 L2
                    profitLoss.SalesDeptNameL2__c       = Util_String.nvlStr(objMap.get('SalesDeptNameL2'));//수주부서명 L2
                    profitLoss.SalesDeptL3__c           = Util_String.nvlStr(objMap.get('SalesDeptL3'));//수주부서코드 L3
                    profitLoss.SalesDeptNameL3__c       = Util_String.nvlStr(objMap.get('SalesDeptNameL3'));//수주부서명 L3
                    profitLoss.SalesDeptL4__c           = Util_String.nvlStr(objMap.get('SalesDeptL4'));//수주부서코드 L4
                    profitLoss.SalesDeptNameL4__c       = Util_String.nvlStr(objMap.get('SalesDeptNameL4'));//수주부서명 L4
                    profitLoss.SalesDeptL5__c           = Util_String.nvlStr(objMap.get('SalesDeptL5'));//수주부서코드 L5
                    profitLoss.SalesDeptNameL5__c       = Util_String.nvlStr(objMap.get('SalesDeptNameL5'));//수주부서명 L5
                    profitLoss.DeliveryDeptL1__c        = Util_String.nvlStr(objMap.get('DeliveryDeptL1'));//개발부서코드 L1
                    profitLoss.DeliveryDeptL2__c        = Util_String.nvlStr(objMap.get('DeliveryDeptL2'));//개발부서코드 L2
                    profitLoss.DeliveryDeptL3__c        = Util_String.nvlStr(objMap.get('DeliveryDeptL3'));//개발부서코드 L3
                    profitLoss.DeliveryDeptL4__c        = Util_String.nvlStr(objMap.get('DeliveryDeptL4'));//개발부서코드 L4
                    profitLoss.DeliveryDeptL5__c        = Util_String.nvlStr(objMap.get('DeliveryDeptL5'));//개발부서코드 L5
                    profitLoss.DeliveryDeptName__c      = Util_String.nvlStr(objMap.get('DeliveryDeptName'));//개발부서명
                    profitLoss.BizType1__c              = Util_String.nvlStr(objMap.get('BizType1'));//사업유형3
                    profitLoss.BizType2__c              = Util_String.nvlStr(objMap.get('BizType2'));//사업유형3
                    profitLoss.ServiceCode__c           = Util_String.nvlStr(objMap.get('ServiceCode'));//서비스코드
                    profitLoss.ServiceName__c           = Util_String.nvlStr(objMap.get('ServiceName'));//서비스명
                    profitLoss.SolutionCode__c          = Util_String.nvlStr(objMap.get('SolutionCode'));//솔루션코드
                    profitLoss.SolutionName__c          = Util_String.nvlStr(objMap.get('SolutionName'));//솔루션명
                    profitLoss.OriginAccount__c         = Util_String.nvlStr(objMap.get('OriginAccount'));//원청고객코드
                    profitLoss.AccountName__c           = Util_String.nvlStr(objMap.get('AccountName'));//원천고객명
                    profitLoss.StndCustCode__c          = Util_String.nvlStr(objMap.get('StndCustCode'));//표준고객코드
                    profitLoss.StndCustName__c          = Util_String.nvlStr(objMap.get('StndCustName'));//표준고객명
                    profitLoss.GroupInOut__c            = Util_String.nvlStr(objMap.get('GroupInOut'));//그룹내외 구분 (10:대내, 20:대외)
                    profitLoss.LocalInternational__c    = Util_String.nvlStr(objMap.get('LocalInternational'));//국내외 구분 (10:국내, 20:해외)
                    profitLoss.CurrencyIsoCode          = Util_String.nvlStr(objMap.get('CurrencyIsoCode'));//화폐코드
                    profitLoss.Contract01__c            = Util_String.nvlDec(objMap.get('Contract01'));//수주금액01
                    profitLoss.Contract02__c            = Util_String.nvlDec(objMap.get('Contract02'));//수주금액02
                    profitLoss.Contract03__c            = Util_String.nvlDec(objMap.get('Contract03'));//수주금액03
                    profitLoss.Contract04__c            = Util_String.nvlDec(objMap.get('Contract04'));//수주금액04
                    profitLoss.Contract05__c            = Util_String.nvlDec(objMap.get('Contract05'));//수주금액05
                    profitLoss.Contract06__c            = Util_String.nvlDec(objMap.get('Contract06'));//수주금액06
                    profitLoss.Contract07__c            = Util_String.nvlDec(objMap.get('Contract07'));//수주금액07
                    profitLoss.Contract08__c            = Util_String.nvlDec(objMap.get('Contract08'));//수주금액08
                    profitLoss.Contract09__c            = Util_String.nvlDec(objMap.get('Contract09'));//수주금액09
                    profitLoss.Contract10__c            = Util_String.nvlDec(objMap.get('Contract10'));//수주금액10
                    profitLoss.Contract11__c            = Util_String.nvlDec(objMap.get('Contract11'));//수주금액11
                    profitLoss.Contract12__c            = Util_String.nvlDec(objMap.get('Contract12'));//수주금액12
                    profitLoss.Revenue01__c             = Util_String.nvlDec(objMap.get('Revenue01'));//매출금액01
                    profitLoss.Revenue02__c             = Util_String.nvlDec(objMap.get('Revenue02'));//매출금액02
                    profitLoss.Revenue03__c             = Util_String.nvlDec(objMap.get('Revenue03'));//매출금액03
                    profitLoss.Revenue04__c             = Util_String.nvlDec(objMap.get('Revenue04'));//매출금액04
                    profitLoss.Revenue05__c             = Util_String.nvlDec(objMap.get('Revenue05'));//매출금액05
                    profitLoss.Revenue06__c             = Util_String.nvlDec(objMap.get('Revenue06'));//매출금액06
                    profitLoss.Revenue07__c             = Util_String.nvlDec(objMap.get('Revenue07'));//매출금액07
                    profitLoss.Revenue08__c             = Util_String.nvlDec(objMap.get('Revenue08'));//매출금액08
                    profitLoss.Revenue09__c             = Util_String.nvlDec(objMap.get('Revenue09'));//매출금액09
                    profitLoss.Revenue10__c             = Util_String.nvlDec(objMap.get('Revenue10'));//매출금액10
                    profitLoss.Revenue11__c             = Util_String.nvlDec(objMap.get('Revenue11'));//매출금액11
                    profitLoss.Revenue12__c             = Util_String.nvlDec(objMap.get('Revenue12'));//매출금액12
                    profitLoss.Profit01__c              = Util_String.nvlDec(objMap.get('Profit01'));//영업이익01
                    profitLoss.Profit02__c              = Util_String.nvlDec(objMap.get('Profit02'));//영업이익02
                    profitLoss.Profit03__c              = Util_String.nvlDec(objMap.get('Profit03'));//영업이익03
                    profitLoss.Profit04__c              = Util_String.nvlDec(objMap.get('Profit04'));//영업이익04
                    profitLoss.Profit05__c              = Util_String.nvlDec(objMap.get('Profit05'));//영업이익05
                    profitLoss.Profit06__c              = Util_String.nvlDec(objMap.get('Profit06'));//영업이익06
                    profitLoss.Profit07__c              = Util_String.nvlDec(objMap.get('Profit07'));//영업이익07
                    profitLoss.Profit08__c              = Util_String.nvlDec(objMap.get('Profit08'));//영업이익08
                    profitLoss.Profit09__c              = Util_String.nvlDec(objMap.get('Profit09'));//영업이익09
                    profitLoss.Profit10__c              = Util_String.nvlDec(objMap.get('Profit10'));//영업이익10
                    profitLoss.Profit11__c              = Util_String.nvlDec(objMap.get('Profit11'));//영업이익11
                    profitLoss.Profit12__c              = Util_String.nvlDec(objMap.get('Profit12'));//영업이익12

                    //Upsert 를 위한 Key값
                    //profitLoss.ExternalId__c            = bizYear + '_' + version +'_'+ realFlag2;
                    profitLossList.add(profitLoss);
                }
            }
            
            insert profitLossList;
            outHeader.TOTAL_COUNT = profitLossList.size();

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
    // @Future( Callout=true)
    global static void getProfitLoss(String bizYear, String version){
        // 로그 변수
        String      guId = IF_Util.generateGuid();
        IF_Callout  call = new IF_Callout( INTERFACE_ID);
        IF_Log      log  = new IF_Log();
        IF_Log.InterfaceLog ifLog;

        // 검색할 사업년도, 버전 -> json 변환
        Map<String,String> reqMap = new Map<String,String>();
        reqMap.put('BizYear' , bizYear);
        reqMap.put('Version' , version);
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

        Date toDt = Date.today();
        String bizYear = toDt.year()+'';
        String version = '';

        getProfitLoss ( bizYear, version);
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