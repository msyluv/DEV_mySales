/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-03-12
 * @last modified by  : sarthak.j1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                         Modification
 * 1.0   2021-05-04   raeganja@partner.samsung.com   Initial Version
 * 1.1	 2024-03-12	  sarthak.j1@samsung.com		 Apply new Probability Field to Logistics -> MYSALES-470
**/
global class Batch_EccOpportunityLogisMigController implements DataBase.stateful, DataBase.Batchable<SObject>, DataBase.AllowsCallouts, Schedulable {
    private static final String INTERFACE_ID = 'IF-094';
    private static final String APEX_CLASS   = 'Batch_EccOpportunityLogisMigController'; 
    private static final String METHOD_NAME  = 'Batch';

    public Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();
    public Batch_EccOpportunityLogisMigController() {  }


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
                AND    InterfaceId__c = 'IF-094'
            ];

            Set<String> oppIdSet = new Set<String>();
            for( MigOppCode__c migOpp : migOppCdList){

                oppIdSet.add( migOpp.Name);
            }

            if(BATCH_CONDITION == null) BATCH_CONDITION = Date.today().addDays(-3);

            queryString = 'Select Id ' +
            '	    , OpportunityCode__c ' +                                    // 사업 기회 Code
            '	    , RecordType.DeveloperName ' +                              // RecordType 구분                                        
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
            '		, Probability_new__c ' +									// -->[Added Probability_new__c as per v-1.1]    
            '	    , VRBMethod__c ' +                                          // VRB 유형
            '	    , Description ' +                                           // 사업기회 개요
            '	    , Collaboration__c ' +                                      // 법인 협업 여부
            '       , IsOriginal__c ' +                                         // 
            '	    , OpportunityStatus__c ' +                                  // Opportunity Status
            '	    , toLabel( OpportunityStatus__c) OpportunityStatusLabel ' + // Opportunity Status 명
            '	    , SalesDepartment__r.CostCenter__c ' +                      // 수주 사업그룹 코스트센터 코드
            '	    , cPrimarySalesDepartment__r.CostCenter__c ' +              // 주 매출 부서 코스트센터 코드
            '	    , BusinessLevel__c ' +                                      // 사업 등급
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
            '       , ColCompanyCode__c ' +                                     // 협업 법인 코드 (협업 BO의 Company Code)                                        
            '       , FinalBusinessLevel__c ' +                                        
            '       , AgencyContract__c	' +                                     // 계약 대행 여부
            '       , AgencyContractException__c ' +                            // 계약 대행 예외 처리 여부
            '       , MigData__c ' +                                            // 마이그 데이터
            '       , IsEdited__c ' +                                           // 수정여부
            '       , LostReasonLogistics__c ' +                                // 실주사유
            '       , Competitors__c ' +                                        // 경쟁사
            ' From   Opportunity ' +
            ' Where  EPCompanyCode__c != null '+
            ' AND    Id IN :oppIdSet ';


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
            // Opportunity Logistics 상세정보 정보 가져오기
            // *************************************
            IF_EccOpportunityLogisController.OutputHeader outHeader = IF_EccOpportunityLogisController.getOpportunityLogisDetailInfo(scopeList);
            
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
                    WHERE InterfaceId__c = 'IF-094' 
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
        DataBase.executeBatch( new Batch_EccOpportunityLogisMigController(), 50);
    }
}