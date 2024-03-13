/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-01-19
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-05-17   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2022-02-09   younghoon.kim@dkbmc.com          수전위 수정사항 추가(사업규모, 컨소시엄 여부)
 * 1.2   2023-03-14   anish.jain@partner.samsung.com   MySales - 147 changes
 * 1.3   2024-01-19   sarthak.j1@samsung.com          Opportunity - new 'Probability' Field Creation -> MYSALES-416
**/
public class Batch_EccOpportunityHQMigController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static final String INTERFACE_ID = 'IF-125';
    private static final String APEX_CLASS   = 'Batch_EccOpportunityHQMigController'; 
    private static final String METHOD_NAME  = 'Batch';

    public Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();
    public Batch_EccOpportunityHQMigController() {  }


    public DataBase.QueryLocator start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        String queryString;
        Database.QueryLocator returnScope;

        // 기본 쿼리 검색
        try{

            List<MigOppCode__c> migOppCdList = [

                SELECT Id 
                      ,Name                 // ID
                      ,OpportunityCode__c
                FROM   MigOppCode__c
                WHERE  Systemmodstamp = today
                AND    Send_Check__c  = false
                AND    InterfaceId__c = 'IF-125'
            ];

            Set<String> oppCdSet = new Set<String>();
            for( MigOppCode__c migOpp : migOppCdList){

                oppCdSet.add( migOpp.Name);
            }

            if(BATCH_CONDITION == null) BATCH_CONDITION = Date.today().addDays(-3);

            queryString = 'Select Id ' +		
                        '	    , OpportunityCode__c ' +                                                        // 사업 기회 Code
                        '	    , RecordType.DeveloperName ' +                                                  // RecordType 구분
                        '	    , Name ' +                                                                      // 사업기회명
                        '	    , StageName ' +                                                                 // 단계
                        '       , ActivityStatus__c ' +                                                         // Current BO Activity Status
                        '	    , Type ' +                                                                      // 사업기회 유형
                        '	    , toLabel(Type) TypeLabel ' +                                                   // 사업기회 유형명
                        '	    , Account.AccountNumber ' +                                                     // Contract Account
                        '	    , cOriginAcc__r.AccountNumber ' +                                               // 원청사 고객
                        '	    , Owner.EmployeeNumber ' +                                                      // 소유자 (영업 대표)
                        '	    , Owner.Name ' +                                                                // 소유자 (영업 대표)
                		'	    , RepresentativePM__r.EvSapEmpNO__c ' +                                         // Add Representative PM.
                        '	    , ProposalPM__r.EvSapEmpNO__c ' +                                               // 제안 PM
                        '	    , ProposalPM__r.EvHName__c ' +                                                  // 제안 PM
                        '	    , GroupInternal__c ' +                                                          // 그룹 내 사업 여부
                        '	    , KoreaDomestic__c ' +                                                          // 국내/해외 여부
                        '	    , Amount ' +                                                                    // 예상금액
                        '	    , CurrencyIsoCode ' +                                                           // 사업 기회 금액의 통화
                        '	    , CloseDate ' +                                                                 // 예상수주일자
                        '	    , cRevenueStartDate__c ' +                                                      // (계약)매출 시작일
                        '	    , cRevenueEndDate__c ' +                                                        // (계약)매출 종료일
                        '	    , CompanyCode__c ' +                                                            // Company Code
                        '	    , IsDeleted ' +                                                                 // 삭제 여부
                        '	    , CreatedDate ' +                                                               // Opportunity 등록일
                		'	    , BO1stRegistrationDate__c ' +                                                  // Opportunity 1st 등록일
                        '	    , CreatedBy.EmployeeNumber ' +                                                  // Opportunity 등록자 사번
                        '	    , LastModifiedDate ' +                                                          // Opportunity 수정일
                        '	    , LastModifiedBy.EmployeeNumber ' +                                             // Opportunity 수정자 사번
                        '	    , BusinessType__c ' +                                                           // 사업 유형
                        '	    , tolabel(BusinessType__c) BusinessTypeLabel ' +                                // 사업 유형명
                        '       , cOriginAcc__r.Name ' +                                                        // 원청사 고객명
                        '       , Account.Name ' +                                                              // 고객사명
                        '	    , Probability_new__c ' +                                                        // 확도 -->[Changed Probability to Probability_new__c] v-1.3
                        '	    , Probability ' +                                                               // 확도 -->[Added back Probability for additional requirement] v-1.3
                        '	    , VRBMethod__c ' +                                                              // VRB 유형
                        '	    , Description ' +                                                               // 사업기회 개요
                        '	    , Collaboration__c ' +                                                          // 법인 협업 여부
                        '       , IsOriginal__c ' +                                                             // 
                        '	    , OpportunityStatus__c ' +                                                      // Opportunity Status
                        '	    , toLabel(OpportunityStatus__c) OpportunityStatusLabel ' +                      // Opportunity Status 명
                        '	    , SalesDepartment__r.CostCenter__c ' +                                          // 수주 사업그룹 코스트센터 코드
                        '	    , cPrimarySalesDepartment__r.CostCenter__c ' +                                  // 주 매출 부서 코스트센터 코드
                        '	    , BusinessLevel__c ' +                                                          // 사업 등급
                        '	    , BiddingMethod__c ' +                                                          // 입찰 방식
                        '       , Account.Owner.EmployeeNumber ' +                                              // 고객오너(영업대표)
                        '       , Account.Owner.Name ' +                                                        // 고객오너(영업대표) 명
                        '	    , BizTeamAttributes01__c ' +                                                    // 사업팀 정의 속성01
                        '	    , BizTeamAttributes02__c ' +                                                    // 사업팀 정의 속성02
                        '	    , BizTeamAttributes03__c ' +                                                    // 사업팀 정의 속성03
                        '	    , BizTeamAttributes04__c ' +                                                    // 사업팀 정의 속성04
                        '	    , LogisticsCustomerType__c ' +                                                  // 물류 고객 구분
                        '	    , toLabel(LogisticsCustomerType__c) LogisticsCustomerTypeLabel ' +              // 물류 고객 구분명
                        '	    , LogisticsBizDevelopmentType__c ' +                                            // 사업 개발 유형
                        '	    , toLabel(LogisticsBizDevelopmentType__c) LogisticsBizDevelopmentTypeLabel ' +  // 사업 개발 유형명
                        '	    , SalesRegion__c ' +                                                            // 수주 권역
                        '	    , SalesOrganization__r.Region__c ' +                                            // 수주 권역 코드
                        '	    , SalesOrganization__c ' +                                                      // 수주 거점
                        '	    , SalesOrganization__r.Code__c ' +                                              // 수주 거점 코드
                        '	    , DeliveryRegion__c ' +                                                         // 매출 권역
                        '	    , DeliveryOrganization__r.Region__c ' +                                         // 매출 권역 코드
                        '	    , DeliveryOrganization__c ' +                                                   // 매출 거점
                        '	    , DeliveryOrganization__r.Code__c ' +                                           // 매출 거점 코드
                        '	    , LogisticsBizType__c ' +                                                       // 물류 서비스 범위
                        '	    , toLabel(LogisticsBizType__c) LogisticsBizTypeLabel ' +                        // 물류 서비스 범위명
                        '	    , LogisticsServiceType__c ' +                                                   // 물류 서비스 영역
                        '	    , toLabel(LogisticsServiceType__c) LogisticsServiceTypeLabel ' +                // 물류 서비스 영역명
                        '	    , BiddingDeadline__c ' +                                                        // 입찰 마감일
                        '	    , LBSExceptionType__c ' +                                                       // 예외 LBS 유형 확인
                        '	    , SubIndusrty__c ' +                                                            // 하위 업종 구분
                        '	    , toLabel(SubIndusrty__c) SubIndusrtyLabel ' +                                  // 하위 업종 구분명
                        '       , Owner.FederationIdentifier ' +                                                // 소유자 (영업 대표)의 EP ID
                        '       , CreatedBy.FederationIdentifier ' +                                            // Created By ID의 EP ID
                        '       , LastModifiedBy.FederationIdentifier ' +                                       // Last Modified By ID의 EP ID
                        '       , ResourcePreInput__c ' +                                                       // 선투입 여부
                        '       , Reuse__c ' +                                                                  // 재활용 필요성 여부
                        '       , ReuseReason__c ' +                                                            // 재활용 필요성 여부 사유
                        '       , ColCompanyCode__c ' +                                                         // 협업 법인 코드 (협업 BO의 Company Code)
                        '       , FinalBusinessLevel__c ' +
                        '       , AgencyContract__c	' +                                                         // 계약 대행 여부
                        '       , AgencyContractException__c ' +                                                // 계약 대행 예외 처리 여부
                        '       , BusinessType2__c ' +                                                          // 사업유형2
                        '       , DealBreak__c ' +                                                              // Deal Break
                        '       , Construction__c ' +                                                           // 건설 여부
                        '       , LegalReviewNo__c ' +                                                          // 법무 검토 번호
                        '       , MigData__c ' +                                                                // 마이그 데이터
                        '       , IsEdited__c ' +                                                               // 수정여부
                        //신규추가시작
                        '       , Opportunity_Review_Exception__c ' +                                           // 사업심의유형 변경여부
                        '       , Opportunity_Review_Exception_Modifier__r.FederationIdentifier ' +             // 사업심의유형 변경자
                        '       , Opportunity_Review_Confirm__c ' +                                             // BO 점검 확정여부
                        '       , Opportunity_Review_VRB_Type_Confirm__c ' +
                        //신규추가종료
                        '       , LostReasonLogistics__c ' +                                                    // 물류 중도종결사유
                        '       , GlobalCustomer__c ' +
                        '		, FirstCloseDate__c ' + 
                        // 2022-02-09 / [Strat] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
                        '		, Opportunity_Review_Biz_Amount__c ' +                                          // 사업규모
                        '		, Opportunity_Review_Consortium__c ' +                                          // 컨소시엄 여부
                        // 2022-02-09 / [End]] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
                        // 2022-04-19 / CSP/MSP 필드 전송건 추가.
                        '		, CspMspType__c ' + 
                        '		, CMBizType__c ' + 
                        '		, CMCollaboDept1__r.CostCenter__c ' + 
                        '		, CMCollaboDept2__r.CostCenter__c ' + 
                        '		, CMCollaboDept3__r.CostCenter__c ' + 
		// 2022-08-02 MSP 수주금액필드 추가.
                	'		, MSP_Amount__c ' + 
                        '		, ConversionType__c ' + 
                        '		, OtherCSP__c ' + 
                        '		, PartnerAccount__r.AccountNumber ' + 
                        '		, SCP_DC__c ' +         
                        '		, SCPScale__c ' +         
                        '		, ServiceSales__c ' + 
                //Added by Anish- V1.2
                        '		, Opportunity_Review_Confirm_New__c ' + //Added by Anish- v 2.4
                        '		, Competitors__c ' + 
                        '		, mGroupAccNameL1__c ' + 
                        '		, mGroupAccNameL2__c ' + 
                        '		, mGroupAccNameL3__c ' + 
                        '		, CollaborationBOId__r.Name ' +  
                        '		, OurRole__c ' + 
                        '		, Security__c ' + 
                        '		, Urgency__c ' + 
                        '		, ZPZ2_EndDate__c ' + 
                        'From   Opportunity ' +
                        'Where  EPCompanyCode__c != null ' +
                        ' AND   Id IN :oppCdSet ';


            returnScope = DataBase.getQueryLocator(queryString);

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');
                          
            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
            
            ifStartLog.createLog(batchStartLog);
        }catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);
        }

        return returnScope;
    }
    
    public void execute(DataBase.BatchableContext BC, List<Opportunity> scopeList){

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        String reqMsg = '';
        String resMsg = '';

        Map<String, Object> result = new Map<String,Object>();

        try {

            if (DEBUG_FLAG) ifExcuteLog.addLog('scopeList.size() : ' + scopeList.size());
            system.debug('처리 대상 : ' + scopeList.size());

            // *************************************
            // Opportunity HQ 상세정보 정보 가져오기
            // *************************************
            IF_EccOpportunityController.OutputHeader outHeader = IF_EccOpportunityController.getOpportunityDetailInfo(scopeList);
            
            // 관련정보 Callout 처리
            // Callout 처리
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            system.debug('CallOut Result' + ' / ' + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));
            
            // Batch는 Request 정보가 길어 주석 처리
            // if (DEBUG_FLAG) ifExcuteLog.addLog('Request : '  + reqMsg);     

            ifExcuteLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            ifExcuteLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));
           
            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                
                Set<String> oppCodeSet = new Set<String>();
                for( Opportunity opp : scopeList){

                    oppCodeSet.add( opp.Id);
                }

                List<MigOppCode__c> migOppList = [
                    
                    SELECT Id 
                          ,Name                 // ID
                          ,OpportunityCode__c
                          ,Send_Check__c
                    FROM  MigOppCode__c
                    WHERE InterfaceId__c = 'IF-125'
                    AND   Name IN :oppCodeSet
                ];

                for( MigOppCode__c migOpp : migOppList){

                    migOpp.Send_Check__c = true;
                }

                update migOppList;


                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifExcuteLog.addLog( '마이그 update : ' + migOppList.size() + ' 전송건수:'  + outHeader.OPPORTUNITY.size());
                ifExcuteLog.addLog('HttpResponse getBody : ' + hRes.getBody());
                ifExcuteLog.addLog('recHeader : ' + hRes.getBody());

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg,  outHeader.OPPORTUNITY.size());


            } else {
                ifExcuteLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                excuteErrorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, excuteErrorMsgList);
            }



            // 로그 남기기
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);
        } catch (Exception e) {
            ifExcuteLog.addLog('Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);
        }
    }

    public void finish(DataBase.BatchableContext BC){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
    }
    // 스케줄 호출
    public void execute( SchedulableContext SC){
        DataBase.executeBatch( new Batch_EccOpportunityLogisController(), 50);
    }
}