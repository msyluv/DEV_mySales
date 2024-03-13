/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2024-03-12
 * @last modified by  : sarthak.j1@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2021-01-26   ghkil@partner.samsung.com         Initial Version (Batch_EccOpportunityController와 같은 기능을 하는 Callout)
 * 1.01  2021-01-26   kilhwan.an@partner.samsung.com    OpportunityStatus__c 의 라벨명 , queryString 지역변수 추가
 * 1.11  2021-01-27   kilhwan.an@partner.samsung.com    수주권역 코드, 수주거점 코드, 매출 권역 코드 , 매출 거점 코드 추가, OpportunityStatus__c 코드값으로 변경
 * 1.21  2021-01-28   kilhwan.an@partner.samsung.com    물류 이외 조건 추가
 * 1.31  2021-01-28   ghkil@partner.samsung.com         REUSE, REUSE_REASON 항목 추가, ORGIN_ACCOUNT, CONTACT_ACCOUNT 항목 삭제
 * 1.41  2021-02-01   ghkil@partner.samsung.com         영업대표명(SALES_EMP_NAME), 고객오너(영업대표명)(AM_EMP_NAME)의 보여주는 항목명을 Employee__c의 EvHName__c로 변경
 * 1.51  2021-02-02   kilhwan.an@partner.samsung.com    영업대표명(SALES_EMP_NAME), 고객오너(영업대표명)(AM_EMP_NAME)의 보여주는 항목명에서 IF_USER인경우 IF_USER로 처리
 * 1.61  2021-02-08   ghkil@partner.samsung.com         인사부서코드(수주부서 인사코드, 매출부서 인사코드)를 가져올 때 수주/매출 코스트센터를 가지고 Department에서 가져옴 (CompanyCode__c 조건 제외)
 * 1.71  2021-02-08   ghkil@partner.samsung.com         BO_RECORD_TYPE(사업유형 레코드 타입) 항목 추가
 * 1.81  2021-02-09   kilhwan.an@partner.samsung.com    BO_CLASS2 => BO_LBS_CLASS , RecordType.DeveloperName 조건 제거 : 본사는 물류 데이터를 받아야 한다는 요건
 * 1.91  2021-02-16   ghkil@partner.samsung.com         CONTACTTEXT 항목 제거
 * 1.92  2021-02-17   ghkil@partner.samsung.com         BusinessLevel__c을 FinalBusinessLevel__c로 변경
 * 1.93  2021-02-19   ghkil@partner.samsung.com         ZZACONT(계약대행 여부), ZZACONT_EX(계약대행 예외처리 여부) 항목 추가
 * 1.94  2021-02-26   ghkil@partner.samsung.com         ZZCOOPER 항목값 변경 (X(True/_(False)))
 * 1.95  2021-02-26   ghkil@partner.samsung.com         UDATE_STRSE, COUNTRYTEXT 항목 제거
 * 1.96  2021-03-03   ghkil@partner.samsung.com         ZZCOOPER(법인 협업 여부), INPUT_P(선투입여부), ZZACONT(계약대행), ZZACONT_EX(계약대행 예외처리 여부)DML False값 '_'에서 ''로 변경 
 * 1.97  2021-03-03   ghkil@partner.samsung.com         BusinessType2__c(사업유형2), DealBreak__c(Deal Break), Construction__c(건설 여부), LegalReviewNo__c(법무 검토 번호) 항목 추가
 * 1.98  2021-03-05   kilhwan.an@partner.samsung.com    마이그데이터 수정시 전송 조건 추가
 * 1.99  2021-03-10   ghkil@partner.samsung.com         Multi PickList인 RLBS_BIZ_TCD(RLBS 사업유형코드), RLBS_SVC_TCD(RLBS 서비스유형코드) 항목의 구분자를 ";"에서 ","로 변경
 * 1.991 2021-03-17   ghkil@partner.samsung.com         ORDER_AMT_KRW(KRW로 환상된 예상금액) 항목 추가
 * 1.992 2021-03-18   ghkil@partner.samsung.com         LOCAL_ORDER_AMT(계약 수주액(로컬 통화)), BIG_ACCOUNT_YN(빅어카운트여부), ORDER_AMT_KRW(KRW로 환상된 예상금액) 구하는 환율 기준 개선 (분기별 환율 적용)
 * 1.993 2021-04-14   kilhwan.an@partner.samsung.com    CostCenter 기준으로 인사 부서코드 가져오기(  SALES_DEPT_CODE, DEVELOP_DEPT_CODE)
 * 1.994 2021-04-22   raeganja@partner.samsung.com      사업유형에 따른 사업개요 구성 내용 변경
 * 1.995 2021-06-17   seonju.jin@dkbmc.com              매출분할 정보 수정 
 * 1.996 2021-06-30   ukhyeon.lee@samsung.com           수전위 필드 추가/수정
 * 1.997 2021-07-08   ukhyeon.lee@samsung.com           수전위 필드 추가/수정
 * 1.998 2022-02-09   younghoon.kim@dkbmc.com           수전위 수정사항 추가(사업규모, 컨소시엄 여부)
 * 1.999 2022-05-12   kj78.yu@partner.samsung.com       CSP/MSP 상세 정보 추가.
 * 2.000 2022-06-13   akash.g@samsung.com               Add Representative PM functionality.
 * 2.1   2023-03-10   anish.jain@partner.samsung.com    MySales - 147 changes
 * 2.2   2023-03-27   gitesh.s@samsung.com              Changed EvEmpNO__c to EvSapEmpNO__c (MySales-155)
 * 2.3   2023-09-14   anish.jain@partner.samsung.com    Changed UDATE_LOSE and UDATE_DROP values
 * 2.4   11-05-2023   anish.jain@partner.samsung.com    MySales - 216
 * 2.5   2024-01-19   sarthak.j1@samsung.com            Opportunity - new 'Probability' Field Creation -> MYSALES-416
 * 2.6   2024-02-19   anish.jain@partner.samsung.com    MYSALES-453
 * 2.7   2024-02-26   divyam.gupta@samsung.com          Mysales-449 (IT) Contract Approval Logic Change.
 * 2.8	 2024-03-12	  sarthak.j1@samsung.com            Apply new Probability Field to Logistics -> MYSALES-470
**/
global class IF_EccOpportunityController implements Queueable , DataBase.AllowsCallouts{

    private static final String INTERFACE_ID = 'IF-125';
    private static final String APEX_CLASS   = 'IF_EccOpportunityController'; 
    private static final String METHOD_NAME  = 'calloutOpportunityInfo';

    private static Date BATCH_CONDITION = null; // 배치 처리 조건 (최초 3일 전부터 조회)
    
    private static final String PROPOSAL_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Submit Proposal');     // 견적/제안 제출(ZP61)
    private static final String REVIEW_OPP_ACTIVITY_CODE = IF_Util.OPPORTUNITY_ACTIVITY.get('Review BO');           // 사업기회 검토(ZP21)
    //신규추가시작
    private static final String VRB_ACTIVITY_CODE        = IF_Util.OPPORTUNITY_ACTIVITY.get('Request Committee (bidding decision) Approval');  // 신규 수전위 품의(XP73)  
    //신규추가종료
    private static final String LOST_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Lost Opportunity');    // 실주 보고(ZPZ1)
    private static final String ABORT_OPP_ACTIVITY_CODE  = IF_Util.OPPORTUNITY_ACTIVITY.get('Abort Opportunity');   // 사업 포기(XPX1)
    private static final String DROP_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Drop Opportunity');    // 사업 중도 종결(ZPZ2)
    private static final String HOLD_OPP_ACTIVITY_CODE   = IF_Util.OPPORTUNITY_ACTIVITY.get('Hold Opportunity');    // 사업 Hold(ZAC1)
    
    private static final Boolean DEBUG_FLAG = IF_Util.DEBUG_FLAG;

    private static String guId = IF_Util.generateGuid();

    private static IF_Log ifLog;
    private static IF_Log.InterfaceLog interfaceLog;
    private static List<String> errorMsgList = new List<String>();

    private List<String> selectIdList;

    public IF_EccOpportunityController( List<String> selectIdList) {    

        this.selectIdList = selectIdList;
    }

    public static String QUERY_STRING = 'Select Id ' +		
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
                                        '	    , Probability_new__c ' +                                                        // 확도 -->[Changed Probability to Probability_new__c] v-2.5
        								'	    , Probability ' +                                                               //-->[Added back Probability as per additional requirement] v-2.5
                                        '	    , Opportunity_Review_VRB_Type_Confirm__c ' +                                    // VRB 유형
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
                                        //신규추가종료
                                        '       , LostReasonLogistics__c ' +                                                    // 물류 중도종결사유
                                        '       , GlobalCustomer__c ' +
        								'		, FirstCloseDate__c ' + 
                                        // 2022-02-09 / [Strat] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
                                        '		, Opportunity_Review_Biz_Amount__c ' +                                          // 사업규모
                                        '		, Opportunity_Review_Consortium__c ' +                                          // 컨소시엄 여부
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
              //Added by Anish - V 2.1
                                        '		, Competitors__c ' + 
                                        '		, mGroupAccNameL1__c ' + 
                                        '		, mGroupAccNameL2__c ' + 
                                        '		, mGroupAccNameL3__c ' + 
                                        '		, CollaborationBOId__r.Name ' + 
                                        '		, OurRole__c ' + 
                                        '		, Security__c ' + 
                                        '		, Urgency__c ' + 
                                        '       , Opportunity_Review_Confirm_New__c ' + //Added by Anish- v 2.4
                        				// 2022-02-09 / [End]] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
                        				'		, ZPZ2_EndDate__c ' +  // V 2.7 Added by Divyam
                                        'From   Opportunity ' +
                                        'Where  EPCompanyCode__c != null ' + 
        								'AND    ( ( MigData__c = false ) OR ( MigData__c = true and IsEdited__c = true) )  '; // 2021-02-02 / younghoon.kim / Migration Data는 SAP으로 전송하지않도록 조건 추가
//                                        'AND    RecordType.DeveloperName != \'Logistics\' ' ;

    public void execute(QueueableContext context) {

        calloutOpportunityInfo2 ( this.selectIdList);
    }

    @Future(callout=true)
    public static void calloutOpportunityInfo(List<String> selectIdList){
        System.debug('selectIdList : ' + selectIdList);
        calloutOpportunityInfo2( selectIdList);
    }

    public static void calloutOpportunityInfo2(List<String> selectIdList){        
        System.debug('selectIdList : ' + selectIdList);
        Map<String, Object> result = new Map<String, Object>();

        String reqMsg = '';
        String resMsg = '';

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');

        // *************************************
        // Opportunity 기본정보 조회
        // *************************************
        String queryString = QUERY_STRING + ' And    Id IN :selectIdList ';
        Organization org = [ SELECT Id, isSandBox FROM Organization];
        if( org.IsSandbox && org.Id != '00D1s0000008pnsEAA'){       // Dev Id 제외 (00D1s0000008pnsEAA)
            // 10, 50, 100, 200, 300, 400, 500
            //queryString = queryString + ' AND CreatedById = \'0051s000000zvP1AAI\' ' ;
            queryString += ' ORDER BY Systemmodstamp DESC LIMIT 10 ';
        }            
        queryString = queryString + 'ALL ROWS ';
        System.debug( 'queryString::::' + queryString);

        List<Opportunity> scopeList = Database.query(queryString);

        if (DEBUG_FLAG) ifLog.addLog('scopeList.size() : ' + scopeList.size());
        system.debug('처리 대상 : ' + scopeList.size());
                
        // *************************************
        // Opportunity 상세정보 정보 가져오기
        // *************************************
        OutputHeader outHeader = getOpportunityDetailInfo(scopeList);

        MigOppCode__c errorOppty = new MigOppCode__c();

        // *************************************
        // Interface 통신
        // *************************************        
        try {            
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            // OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');

            result = ifCallout.httpCallout(JSON.serialize(outHeader), '');
            // ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && (resStatusCode == 200 || resStatusCode == 202)) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);
            } else {
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);

                if(scopeList.size()> 0){
                    errorOppty.Name = scopeList[0].Id;
                    errorOppty.OpportunityCode__c = scopeList[0].OpportunityCode__c;
                    errorOppty.Send_Check__c = false;
                    errorOppty.InterfaceId__c = 'IF-125ERROR';
                }
            }            
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);

            if(scopeList.size()> 0){
                errorOppty.Name = scopeList[0].Id;
                errorOppty.OpportunityCode__c = scopeList[0].OpportunityCode__c;
                errorOppty.Send_Check__c = false;
                errorOppty.InterfaceId__c = 'IF-125ERROR';
            }
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);

            if(errorOppty.InterfaceId__c == 'IF-125ERROR') insert errorOppty;
        }

        // return result;
    }    

    public static OutputHeader getOpportunityDetailInfo(List<Opportunity> scopeList) {

        // *************************************
        // Opportunity 상세정보 정보 가져오기
        // *************************************
        // Opportunity 데이터 적재
        
        Map<String, Opportunity> OpportunityMap = new Map<String, Opportunity>();
        Set<String> costCenterCodeSet = new Set<String>();
        Set<String> companyCodeSet = new Set<String>();
        Set<String> employeeNumberSet = new Set<String>();
        Set<Date> closeDateSet = new Set<Date>();
        for (Opportunity oppData : scopeList) {
            OpportunityMap.Put(oppData.Id, oppData);                                    // Opportunity 데이터 
            costCenterCodeSet.add(oppData.SalesDepartment__r.CostCenter__c);            // Department정보 가져올 costCenterExternalIdSet 적재 (수주 사업그룹)
            costCenterCodeSet.add(oppData.cPrimarySalesDepartment__r.CostCenter__c);    // Department정보 가져올 costCenterExternalIdSet 적재 (주 매출부서)
            companyCodeSet.add(oppData.CompanyCode__c);                                 // Company정보 가져올 companyCodeSet 적재
            employeeNumberSet.add(oppData.Owner.EmployeeNumber);                        // Employee정보 가져올 employeeNumberSet 적재 (소유주(영업대표))
            employeeNumberSet.add(oppData.Account.Owner.EmployeeNumber);                // Employee정보 가져올 employeeNumberSet 적재 (고객오너(영업대표))
            closeDateSet.add(oppData.CloseDate);                                        // 환율정보 조회를 위한 CloseDate Set 적재
        }
//
//        List<Department__c> deptList = [
//            Select  Id
//                    , Kostl__c
//                    , Abtel__c
//            From    Department__c
//            Where  Kostl__c IN :costCenterCodeSet
//        ];
//        Map<String, Department__c> deptMap = new Map<String, Department__c>();
//        for(Department__c dept : deptList){
//            deptMap.put(dept.Kostl__c, dept);
//        }

        List<CostCenter__c> costList = [
            SELECT Id
                  ,CostCenter__c
                  ,L_ORGEH__c
            FROM   CostCenter__c
            WHERE  CostCenter__c IN :costCenterCodeSet
        ];

        Map<String, CostCenter__c> costMap = new Map<String, CostCenter__c>();
        for( CostCenter__c ct : costList){

            costMap.put( ct.CostCenter__c, ct);
        }

        // 각 Activity별 날짜정보 가져오기
        List<Opportunity_Activity__c> oppActivityList = [
            Select  Id, 
                    TransactionName__c,                             // Opportunity Activity Code
                    tolabel(TransactionName__c) TransactionName,    // Opportunity Activity Name
                    LostReason__c,                                  // Drop / Lost Reason Code
                    Status__c,                                      
                    DueDate__c,                                     // 완료 예정일자 (RFP 계획일자)
                    StartDate__c,                                   // 시작일자
                    EndDate__c,                                     // 종료일자
                    WhatId__c                                       // Opportunity Id
            From    Opportunity_Activity__c 
            Where   TransactionName__c in (:PROPOSAL_ACTIVITY_CODE, :REVIEW_OPP_ACTIVITY_CODE, :VRB_ACTIVITY_CODE, :LOST_OPP_ACTIVITY_CODE, :ABORT_OPP_ACTIVITY_CODE, :DROP_OPP_ACTIVITY_CODE, :HOLD_OPP_ACTIVITY_CODE)
            And     WhatId__c In :OpportunityMap.KeySet()
        ];
        // system.debug('oppActivityList.size() : ' + oppActivityList.size());
        Map<String, Opportunity_Activity__c> oppActivityMap = new Map<String, Opportunity_Activity__c>();
        for (Opportunity_Activity__c oppActivityData : oppActivityList) {
            oppActivityMap.put(oppActivityData.WhatId__c + oppActivityData.TransactionName__c, oppActivityData);
        }

        Map<String, String> hq_lostReasonMap = new Map<String, String>();
        Schema.DescribeFieldResult hq_lostReason = Opportunity_Activity__c.LostReason__c.getDescribe();
		List<Schema.PicklistEntry> hq_ple = hq_lostReason.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : hq_ple){
			hq_lostReasonMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}
        
        Map<String, String> logi_lostReasonMap = new Map<String, String>();
        Schema.DescribeFieldResult logi_lostReason = Opportunity.LostReasonLogistics__c.getDescribe();
		List<Schema.PicklistEntry> logi_ple = logi_lostReason.getPicklistValues();
		for( Schema.PicklistEntry pickListVal : logi_ple){
			logi_lostReasonMap.put(pickListVal.getValue(), pickListVal.getLabel());
		}

        // Company 정보 가져오기
        List<Company__c> companyList = [
            Select  Id, 
                    CompanyCode__c,
                    Name,
                    Country__c,
                    CurrencyIsoCode,
                    EPCompanyCode__c,
                    Headquarter__c,
                    CompanyFullName__c
            From    Company__c
            Where   CompanyCode__c IN :companyCodeSet
        ];
        Map<String, Company__c> companyMap = new Map<String, Company__c>();
        for (Company__c companyData : companyList) {
            companyMap.put(companyData.CompanyCode__c, companyData);
        }

        // Employee__c 정보 가져오기 (이름)
        //  v2.2 - Gitesh Saini
        List<Employee__c> employeeList = [
            Select  Id
                    , EvHName__c
                    , EvSapEmpNO__c
            From    Employee__c
            Where   EvSapEmpNO__c IN :employeeNumberSet and Status__c != 'R'
        ]; //Added by Anish - v 2.6
        Map<String, Employee__c> employeeMap = new Map<String, Employee__c>();
        for (Employee__c employeeData : employeeList) {
            employeeMap.put(employeeData.EvSapEmpNO__c, employeeData);// v2.2
        }

        // RevenueScheduleOpportunity 정보 가져오기(2021-04-22 추가)
        List<RevenueScheduleOpportunity__c> RevenueList = [ 
                
            SELECT Id
                  ,Name
                  ,CurrencyIsoCode
                  ,Parent__c
                  ,Revenue__c
                  ,ScheduleDate__c 
            FROM   RevenueScheduleOpportunity__c
            WHERE  Parent__c In :OpportunityMap.KeySet()
            order by Parent__c, scheduleDate__c asc
        ];
        /* Map<String,RevenueScheduleOpportunity__c> RevenueMap = new Map<String,RevenueScheduleOpportunity__c>();
        String checkId = '';
        for(RevenueScheduleOpportunity__c revenueData : RevenueList){
            if((revenueData.Parent__c+'') != checkId){
                RevenueMap.put(revenueData.Parent__c, revenueData);
                checkId = revenueData.Parent__c;
            }
        } */

        //2021.06.15 매출분할 정보 수정
        //OpporutnityId 기준으로 RevenueScheduleOpportunity__c List 정렬
        Map<String,List<RevenueScheduleOpportunity__c>> RevenueMapOpp = new Map<String,List<RevenueScheduleOpportunity__c>>();
		List<RevenueScheduleOpportunity__c> tempList = new List<RevenueScheduleOpportunity__c>();
        String key = '';
        String temp = '';
        for(Integer i = 0; i < RevenueList.size(); i++){
            RevenueScheduleOpportunity__c revenueData = RevenueList.get(i);
            key = revenueData.Parent__c;
            temp = (i == 0) ? key : RevenueList.get(i-1).Parent__c;
            

            if(key != temp){
                RevenueMapOpp.put(temp, tempList); 
                key = revenueData.Parent__c;
                tempList= new List<RevenueScheduleOpportunity__c>();
            }
            tempList.add(revenueData);

            if(i == RevenueList.size()- 1){
                RevenueMapOpp.put(key, tempList); 
            }
        }


        // 환율정보(DatedConversionRate) 조회
        Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
        Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
        Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

        // Request Data 만들기
        Map<String, Object> outputHeaderMap = new Map<String, Object>();
        List<Map<String, Object>> outputDataList = new List<Map<String, Object>>();
        List<OutputClass> dataList = new List<OutputClass>();

        String flagTrue = '10';     // True
        String flagFalse = '20';    // False
        String flagSapTrue = 'X';   // True
        String flagSapFalse = '';   // False

        for (Opportunity oppData : scopeList) {
            System.debug('oppData.OpportunityCode__c : ' + oppData.OpportunityCode__c);
            OutputClass data = new OutputClass();
            Map<String, Object> outputDataMap = new Map<String, Object>();

            data.OPPORTUNITY_ID             = oppData.Id;
            data.ORDER_ID                   = oppData.OpportunityCode__c;
            data.ORDER_NAME                 = oppData.Name;
            data.SALES_PHASE                = oppData.StageName;
            data.ZZSTATUS                   = oppData.ActivityStatus__c;      // Current BO Activity Status
            data.ORDER_TYPE                 = oppData.Type;
            //Added by Anish - V2.1
            data.Competitors                = oppData.Competitors__c;
            //data.Activity_Status            = pickListValuesMap.get(oppData.ActivityStatus__c);
            //Added by Anish --> Changed the date format - V2.1
            String FirstClosedate =          String.valueof(oppData.FirstCloseDate__c);
            if(FirstClosedate!=null && FirstClosedate!=''){
            data.First_CloseDate            = FirstClosedate.replaceAll('-', '');
            }
            data.Origin_Account_Name_1      = oppData.mGroupAccNameL1__c;
            data.Origin_Account_Name_2      = oppData.mGroupAccNameL2__c;
            data.Origin_Account_Name_3      = oppData.mGroupAccNameL3__c;
            data.Collaboration_BO_Name      = oppData.CollaborationBOId__r.Name;
            data.Collaboration_CompanyCode  = oppData.ColCompanyCode__c;
            data.AgencyContract_Role        = oppData.OurRole__c;
            data.AgencyContract_Security    = oppData.Security__c;
            data.AgencyContract_Urgency     = oppData.Urgency__c;
            
            String salesDeptCode = null;
//            if (deptMap.get(oppData.SalesDepartment__r.CostCenter__c) != null) {
//                salesDeptCode = String.valueOf(deptMap.get(oppData.SalesDepartment__r.CostCenter__c).Abtel__c);
//            }

            if (costMap.get(oppData.SalesDepartment__r.CostCenter__c) != null) {
                salesDeptCode = String.valueOf(costMap.get(oppData.SalesDepartment__r.CostCenter__c).L_ORGEH__c);
            }
            data.SALES_DEPT_CODE            = salesDeptCode;
            String developDeptCode = null;
//            if (deptMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c) != null) {
//                developDeptCode = String.valueOf(deptMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c).Abtel__c);
//            }

            if (costMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c) != null) {
                developDeptCode = String.valueOf(costMap.get(oppData.cPrimarySalesDepartment__r.CostCenter__c).L_ORGEH__c);
            }
            data.DEVELOP_DEPT_CODE          = developDeptCode;
            data.COMPANY_ID                 = oppData.Account.AccountNumber;
            data.ORIGINAL_COMPANY_ID        = oppData.cOriginAcc__r.AccountNumber;
            data.SALES_EMP_NO               = oppData.Owner.EmployeeNumber;                                     // 소유주(영업대표)
            String salesEmpName = null;     // (2021-02-01 Employee__c의 EvHName__c로 변경)
            if( oppData.Owner.Name == 'IF_USER'){
                salesEmpName = oppData.Owner.Name;
            }else if (employeeMap.get(oppData.Owner.EmployeeNumber) != null) {
                salesEmpName = employeeMap.get(oppData.Owner.EmployeeNumber).EvHName__c;
            }
            if( salesEmpName != null && salesEmpName.length() > 50) {
                salesEmpName = salesEmpName.substring(0, 50);
            }
            data.SALES_EMP_NAME             = salesEmpName;                                                     // 소유주(영업대표)명
            data.PROPOSAL_EMP_NO            = oppData.ProposalPM__r.EvSapEmpNO__c;                              // 제안PM
            data.PROPOSAL_EMP_NAME          = oppData.ProposalPM__r.EvHName__c;                                 // 제안PM명
            data.IN_OUT_TYPE                = oppData.GroupInternal__c == true ? flagTrue : flagFalse;          // 그룹 내 사업 여부 (10 : 그룹내 / 20 : 그룹외) 
            data.DOM_ABR_TYPE               = oppData.KoreaDomestic__c == true ? flagTrue : flagFalse;          // 국내/해외 여부 (10 : 국내 / 20 : 해외)
            Decimal orderAmt = 0;
            if (oppData.Amount != null) {
                orderAmt = oppData.Amount;
            }
            data.ORDER_AMT                  = orderAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();// 예상금액
            data.CURRENCY_CODE              = oppData.CurrencyIsoCode;                                          // 사업 기회 금액의 통화
            //data.DU_ORDER_DATE              = Util_String.convertDateString(oppData.CloseDate);                 // 예상수주일자
            if(oppData.FirstCloseDate__c != null){
                data.DU_ORDER_DATE              = Util_String.convertDateString(oppData.FirstCloseDate__c);     // 최초예상수주일자
            }else{
                data.DU_ORDER_DATE              = Util_String.convertDateString(oppData.CloseDate);             // 예상수주일자
            }
			
            data.CONTRACT_TERM_FROM         = Util_String.convertDateString(oppData.cRevenueStartDate__c);      // (계약)매출 시작일
            data.CONTRACT_TERM_TO           = Util_String.convertDateString(oppData.cRevenueEndDate__c);        // (계약)매출 종료일
            String CompanyEPCompanyCode = null;
            String CompanyCurrencyIsoCode = null;
            if (companyMap.get(oppData.CompanyCode__c) != null) {
                CompanyEPCompanyCode   = companyMap.get(oppData.CompanyCode__c).EPCompanyCode__c;
                CompanyCurrencyIsoCode = companyMap.get(oppData.CompanyCode__c).CurrencyIsoCode;
            }
            data.COMPANY                    = CompanyEPCompanyCode;                                             // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
            data.SAP_COMPANY                = oppData.CompanyCode__c;                                           // Company Code
            data.LOCAL_CURRENCY_CODE        = CompanyCurrencyIsoCode;                                           // 로컬 통화 (Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode)
            data.FLAG                       = oppData.IsDeleted == true ? 'D' : 'I';                            // 삭제 여부 (삭제된거면 D, 아니면 I)
            if(!Test.isRunningTest()){                                                                          // Added by Anish - V2.1
            data.REG_DATE                   = Util_String.convertDateString( oppData.BO1stRegistrationDate__c, 'Asia/Seoul'); // Opportunity 1st 등록일
            }
            data.REG_EMP_NO                 = oppData.CreatedBy.EmployeeNumber;                                 // Opportunity 등록자 사번
            data.UPDATE_DATE                = Util_String.convertDateString( oppData.LastModifiedDate, 'Asia/Seoul'); // Opportunity 수정일
            data.UPDATE_EMP_NO              = oppData.LastModifiedBy.EmployeeNumber;                            // Opportunity 수정자 사번
            data.BIZ_TYPE                   = oppData.BusinessType__c;                                          // 사업유형
            data.BIZ_TYPE_NM                = String.valueOf(oppData.get('BusinessTypeLabel'));                 // 사업유형명
            // data.COUNTRYTEXT                = 'SFDC 해당사항 없음';                                           // SFDC 해당사항 없음
            data.ORGIN_ACCOUNT_DESC         = oppData.cOriginAcc__r.Name;                                       // 원청사 고객명
            // data.ORGIN_ACCOUNT              = oppData.cOriginAcc__r.AccountNumber;                              // 원청사 고객번호 (2021-01-28 삭제)
            // data.CONTACTTEXT                = oppData.Account.Name;                                             // 고객사명 (2021-02-16 삭제)
            // data.CONTACT_ACCOUNT            = oppData.Account.AccountNumber;                                    // 고객사 고객번호 (2021-01-28 삭제)
            data.PROBABILITY                = String.valueOf(oppData.Probability_new__c);                              // 확도 -->[Changed Probability to Probability_new__c] v-2.5 --> [Commented out for additional requirement] v-2.5 // [Un-commented as part of v-2.8]
            String zzslesstrYn = flagSapFalse;
            // if (oppActivityMap.get(oppData.Id + 'ZP61') != null) {
            //     zzslesstrYn = flagSapTrue;
            // }
            data.ZZSALESSTR                 = zzslesstrYn;                                                      // 수주전략세션 수행 여부 (Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리)
            // 사업유형에 따른 사업개요 구성(HQ:10, Logistic:20) (2021-04-22 추가)
            if( oppData.RecordType.DeveloperName  == 'HQ'){
                //data.PROBABILITY                = String.valueOf(oppData.Probability_new__c);                        // -->[Added for additional requirement] v-2.5 //[Commented out as part of v-2.8]
                data.BO_OVERVIEW                = oppData.Description;                                              // 사업기획 개요
            }else{
                //data.PROBABILITY                = String.valueOf(oppData.Probability);                              // 확도 -->[Added for additional requirement] v-2.5 //[Commented out as part of v-2.8]
                //Shipper Class
                String shipperClass = 'Shipper Class : ' + String.valueOf(oppData.get('LogisticsCustomerTypeLabel')) + '\r\n';
                //Biz Category
                String bizCategory = 'Biz Category : ' + String.valueOf(oppData.get('TypeLabel')) + '\r\n';
                //Biz Type
                String bizType = 'Biz Type : ' + String.valueOf(oppData.get('LogisticsBizTypeLabel')) + '\r\n';                
                //Biz Dev. Type
                String bizDevType = 'Biz Dev. Type : ' + String.valueOf(oppData.get('LogisticsBizDevelopmentTypeLabel')) + '\r\n';
                //Service Type
                String serviceType = 'Service Type : ' + String.valueOf(oppData.get('LogisticsCustomerTypeLabel')) + '\r\n';
                //Industry Type
                String industryType = 'Industry Type : ' + String.valueOf(oppData.get('LogisticsCustomerTypeLabel')) + '\r\n';
                //Annual Revenue
                String annualRevenueAmt = '0';

                if(oppData.cRevenueStartDate__c != null && oppData.cRevenueEndDate__c != null){
                    Integer numberDaysDue = oppData.cRevenueStartDate__c.daysBetween(oppData.cRevenueEndDate__c);
                    Decimal revenueAmt = 0;

                    /**
                     * 매출분할의 월매출금액의 가장 첫번쨰 월 금액 활용
                        case1) 계약기간이 1년이하(혹은 매출분할 데이터가 12개이하)이면
                                Amount의 금액을 그대로 사용
                        case2) 계약기간이 1년초과(혹은 매출분할 데이터가 12개초과)면
                                매출분할 테이블의 가장첫번째 월 금액 * 12로 계산 1년 예상 매출 계산하여 구성
                                단, 이 전제는 물류는 매출분할 테이블에 저장된 월금액들이 모두 동일하다는 전제하에 요청합니다.
                                21년 1월 협의시 물류는 사용자가 각 월들의 매출분할 금액을 다르게 변경저장하더라도
                                시스템에서 다시 동일한 금액으로 만드는 것으로 협의하였습니다
                     */

                    List<RevenueScheduleOpportunity__c> revenueOppList = RevenueMapOpp.get(oppData.Id);
                    if(revenueOppList == null) revenueOppList = new List<RevenueScheduleOpportunity__c> ();

                    if(numberDaysDue <= 365){   //계약기간이 1년이하(혹은 매출분할 데이터가 12개이하)이면
                        if (oppData.Amount != null) {
                            revenueAmt = oppData.Amount;
                        }
                        annualRevenueAmt = revenueAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                    }else if(numberDaysDue > 365 || (RevenueMapOpp.get(oppData.Id).size() > 12)   ){  //1년 초과이거나 매출분할 데이터가 12개 초과인경우
                        if(revenueOppList.size() > 0){
                            revenueAmt = revenueOppList.get(0).Revenue__c * 12;     //가장첫번째 월 금액 * 12로 계산 1년 예상 매출 계산하여 구성
                            annualRevenueAmt = revenueAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                        }
                        
                        /* if( RevenueMap.get(oppData.Id) != null){
                            
                            if (RevenueMap.get(oppData.Id).Revenue__c != null) {
                                revenueAmt = RevenueMap.get(oppData.Id).Revenue__c;
                            }
                            annualRevenueAmt = revenueAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();
                        } */
                    }
                }

                System.debug( 'Annual Revenue : ' + annualRevenueAmt);
                String annualRevenue = 'Annual Revenue : ' + annualRevenueAmt + ' ' + oppData.CurrencyIsoCode;

                String logisticDescription = shipperClass + bizCategory + bizType.replaceAll(';', ',') + bizDevType + serviceType.replaceAll(';', ',') + industryType + annualRevenue;

                data.BO_OVERVIEW                = logisticDescription;                                              // 사업기획 개요(물류사업)
            }
            
            String zzCooper = flagSapFalse;     // False
            //&& oppData.IsOriginal__c
            if (oppData.Collaboration__c) {
                zzCooper = flagSapTrue;         // True
            }
            data.ZZCOOPER                   = zzCooper;                                                         // 법인 협업 여부 (X(True) / ''(False)로 변경, 2021-02-26)
            data.BO_STATUS                  = oppData.OpportunityStatus__c;                                     // Opportunity Status
            // 계약 수주액(로컬 통화) 계산 개선 (2021-03-18)
            Decimal calculationResult = 0;
            if (conversionRateMap.get(oppData.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
                if (oppData.CurrencyIsoCode == CompanyCurrencyIsoCode) {
                    calculationResult = oppData.Amount;
                } else {

                    String fromIsoCode = oppData.CurrencyIsoCode;
                    String toIsocode = CompanyCurrencyIsoCode;
                    Date startDate = quarterDateMap.get(oppData.CloseDate);
                    Decimal fromUsdRate = 0;
                    Decimal toUsdRate = 0;

                    if (conversionPastRateMap.get(fromIsoCode + startDate) != null) {
                        fromUsdRate = conversionPastRateMap.get(fromIsoCode + startDate).ConversionRate;
                    } else {
                        fromUsdRate = conversionRateMap.get(fromIsoCode).ConversionRate;
                    }

                    if (conversionPastRateMap.get(toIsoCode + startDate) != null) {
                        toUsdRate = conversionPastRateMap.get(toIsoCode + startDate).ConversionRate;
                    } else {
                        toUsdRate = conversionRateMap.get(toIsoCode).ConversionRate;
                    }

                    if( Util_String.nvlDec( oppData.Amount) > 0){
                        calculationResult = IF_Util.calculationCurrency(fromIsoCode
                                                                        , oppData.Amount
                                                                        , toIsoCode
                                                                        , fromUsdRate
                                                                        , toUsdRate  );
                    }
                    // calculationResult = IF_Util.calculationCurrency(    oppData.CurrencyIsoCode
                    //                                                     , oppData.Amount
                    //                                                     , CompanyCurrencyIsoCode
                    //                                                     , conversionRateMap.get(oppData.CurrencyIsoCode).ConversionRate
                    //                                                     , conversionRateMap.get(CompanyCurrencyIsoCode).ConversionRate  );
                }
            }
            if (calculationResult == null) {
                calculationResult = 0;
            }
            data.LOCAL_ORDER_AMT            = calculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();   // 계약 수주액(로컬 통화) (Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산)                           
            data.SALES_DEPT_COST_CENTER     = oppData.SalesDepartment__r.CostCenter__c;                         // 수주 사업그룹
            data.DEVELOP_DEPT_COST_CENTER   = oppData.cPrimarySalesDepartment__r.CostCenter__c;                 // 주 매출 부서
            data.BO_CLASS                   = oppData.FinalBusinessLevel__c;                                    // 사업 등급
            data.BID_METHOD                 = oppData.BiddingMethod__c;                                         // 입찰 방식
            data.AM_EMP_NO                  = oppData.Account.Owner.EmployeeNumber;                             // 고객오너(영업대표)    
            String amEmpName = null;     // (2021-02-01 Employee__c의 EvHName__c로 변경)
            if( oppData.Account.Owner.Name == 'IF_USER'){
                amEmpName = oppData.Account.Owner.Name;
            }else if (employeeMap.get(oppData.Account.Owner.EmployeeNumber) != null) {
                amEmpName = employeeMap.get(oppData.Account.Owner.EmployeeNumber).EvHName__c;
            }
            if( amEmpName != null && amEmpName.length() > 20) amEmpName= amEmpName.substring( 0, 20);
            data.AM_EMP_NAME                = amEmpName;                                                        // 고객오너(영업대표)명
            data.COMPANY_ACCOUNT_DESC       = oppData.Account.Name;                                             // 고객명
            // TECH_PROP값은 Submit Proposal(ZP61, 견적/제안 제출)의 Opportunity_Activity__c의 Status 가 "Completed"이면 "Y", 아니면 "N"으로 처리
            String techProp = 'N';
            if (oppActivityMap.get(oppData.Id + PROPOSAL_ACTIVITY_CODE) != null) {
                techProp = oppActivityMap.get(oppData.Id + PROPOSAL_ACTIVITY_CODE).Status__c == 'Completed' ? 'Y' : 'N';  
            }
            data.TECH_PROP = techProp;                                                                          // 제안서 여부
            //신규추가시작
            data.ZZVRB_FQ_T = oppData.Opportunity_Review_VRB_Type_Confirm__c;                                  // VRB 유형
            //신규추가종료
            // UDATE_ZP21값은 Review BO(ZP21, 사업기회 검토)의 Opportunity_Activity__c의 EndDate__c
            String updatZp21 = null;
            if (oppActivityMap.get(oppData.Id + REVIEW_OPP_ACTIVITY_CODE) != null) {
                updatZp21 = Util_String.convertDateString(oppActivityMap.get(oppData.Id + REVIEW_OPP_ACTIVITY_CODE).EndDate__c);
            }
            data.UDATE_ZP21 = updatZp21;                                                                        // BO Activity 사업기회검토 시 종료일자
            //신규추가시작
            // UDATE_VRB값은 BO Approval Result(ZP21, 사업심의 결과 입력)의 Opportunity_Activity__c의 EndDate__c
            String updateVrb = null;
            if (oppActivityMap.get(oppData.Id + VRB_ACTIVITY_CODE) != null) {
                updateVrb = Util_String.convertDateString(oppActivityMap.get(oppData.Id + VRB_ACTIVITY_CODE).EndDate__c);
            }
            data.UDATE_VRB = updateVrb;                                                                         // BO Activity VRB/수전세 시 종료일자, 사업심의 결과 입력
            //신규추가종료
            // data.UDATE_STRSE = 'SFDC 해당사항 없음';  // Strategy_Session_End_Date  <-- SFDC 해당사항 없음
            String updateLose = null;
            String lostReasonCode = null; // 2021-08-10 Lost Reason Code 추가
            String lostReasonName = null; // 2021-08-10 Lost Reason Name 추가
            if( oppData.RecordType.DeveloperName  == 'HQ'){
                if (oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE) != null) {
                    updateLose = Util_String.convertDateString(oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE).EndDate__c);  //Added by Anish - 2.3
                    lostReasonCode = oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE).LostReason__c; // 2021-08-10 Lost Reason Code 추가
                    lostReasonName = hq_lostReasonMap.get(oppActivityMap.get(oppData.Id + LOST_OPP_ACTIVITY_CODE).LostReason__c); // 2021-08-10 Lost Reason Name 추가
                }
            }else{
                lostReasonCode = oppData.LostReasonLogistics__c;
                lostReasonName = logi_lostReasonMap.get(oppData.LostReasonLogistics__c);
            }
            data.UDATE_LOSE = updateLose;
            System.debug('lostReasonCode : ' + lostReasonCode);
            System.debug('lostReasonName : ' + lostReasonName);
            data.Lost_Reason_CD = lostReasonCode; // 2021-08-10 Lost Reason Code 추가
            data.Lost_Reason_Desc = lostReasonName; // 2021-08-10 Lost Reason Name 추가
            
            String updateDrop = null;
            String dropReasonCode = null; // 2021-08-10 Drop Reason Code 추가
            String dropReasonName = null; // 2021-08-10 Drop Reason Name 추가
            if (oppActivityMap.get(oppData.Id + ABORT_OPP_ACTIVITY_CODE) != null) {
                updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + ABORT_OPP_ACTIVITY_CODE).EndDate__c); // Abort Opportunity
            }                   
            if (oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE) != null) {   
              //  updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE).EndDate__c);  // Drop Opportunity
                updateDrop = Util_String.convertDateString(oppData.ZPZ2_EndDate__c); //V 2.7 Added by Divyam gupta
                dropReasonCode = oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE).LostReason__c; // 2021-08-10 Drop Reason Code 추가
                dropReasonName = hq_lostReasonMap.get(oppActivityMap.get(oppData.Id + DROP_OPP_ACTIVITY_CODE).LostReason__c); // 2021-08-10 Drop Reason Name 추가
            }
            if (oppActivityMap.get(oppData.Id + HOLD_OPP_ACTIVITY_CODE) != null) {  
                updateDrop = Util_String.convertDateString(oppActivityMap.get(oppData.Id + HOLD_OPP_ACTIVITY_CODE).EndDate__c);  // Hold Opportunity
            }
            data.UDATE_DROP                 = updateDrop;
            System.debug('dropReasonCode : ' + dropReasonCode);
            System.debug('dropReasonName : ' + dropReasonName);
            data.Drop_Reason_CD = dropReasonCode; // 2021-08-10 Drop Reason Code 추가
            data.Drop_Reason_Desc = dropReasonName; // 2021-08-10 Drop Reason Name 추가
            if(!Test.isRunningTest()){              // Added by Anish - V2.1
            data.EXEC_PM_NO                 = oppData.RepresentativePM__r.EvSapEmpNO__c;                                         // Add Representative PM (2022-06-13)
            }
            data.INPUT_P                    = oppData.ResourcePreInput__c == true ? flagSapTrue : flagSapFalse;                  // 선투입 <- 선투입 여부 (X(True) / ''(False)) (2020-12-28 추가)
            data.BIZ_FROM_DT                = Util_String.convertDateString(oppData.cRevenueStartDate__c);                       // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가)
            data.BIZ_TO_DT                  = Util_String.convertDateString(oppData.cRevenueEndDate__c);                         // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가)
            // [S] 2021-08-10 / SALES_COST_CD, CGUBUN_ID 물류 로직 수정
            if( oppData.RecordType.DeveloperName  == 'HQ'){
                data.SALES_COST_CD              = oppData.BizTeamAttributes01__c;
                data.CGUBUN_ID                  = oppData.BizTeamAttributes02__c;
            }else{
                data.SALES_COST_CD = oppData.CompanyCode__c == 'T100' ? oppData.SalesOrganization__r.Code__c : null;
                data.CGUBUN_ID = oppData.CompanyCode__c == 'T100' ? 'T100' : oppData.SalesOrganization__r.Code__c;
            }
            // [E] 2021-08-10 / SALES_COST_CD, CGUBUN_ID 물류 로직 수정

            // data.SALES_COST_CD              = oppData.BizTeamAttributes01__c;
            // data.CGUBUN_ID                  = oppData.BizTeamAttributes02__c;
            data.BO_LBS_CLASS               = oppData.BizTeamAttributes03__c;
            // data.KEY_ACCOUNT_YN             = oppData.BizTeamAttributes04__c;
            
            // [S] 2021-08-10 / KEY_ACCOUNT_YN 물류 로직 수정
            if( oppData.RecordType.DeveloperName  == 'HQ'){
                data.KEY_ACCOUNT_YN = oppData.BizTeamAttributes04__c;
            }else{
                data.KEY_ACCOUNT_YN = oppData.GlobalCustomer__c;
            }
            // [E] 2021-08-10 / KEY_ACCOUNT_YN 물류 로직 수정
            // Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"으로 처리
            String bigAccountYn = 'N';
            Decimal bigAccountLimit = 3000000000.00;
            Decimal krwCalculationResult = 0;
            if (oppData.CurrencyIsoCode == 'KRW') {
                krwCalculationResult = oppData.Amount == null ? 0 : oppData.Amount;

                if (oppData.Amount >= bigAccountLimit) {
                    bigAccountYn = 'Y';
                }   
            } else {
                // 원화로 환율 변환하여 비교(계산 개선 (2021-03-18))
                String fromIsoCode2 = oppData.CurrencyIsoCode;
                String toIsocode2 = 'KRW';
                Date startDate2 = quarterDateMap.get(oppData.CloseDate);
                Decimal fromUsdRate2 = 0;
                Decimal toUsdRate2 = 0;

                if (conversionPastRateMap.get(fromIsoCode2 + startDate2) != null) {
                    fromUsdRate2 = conversionPastRateMap.get(fromIsoCode2 + startDate2).ConversionRate;
                } else {
                    fromUsdRate2 = conversionRateMap.get(fromIsoCode2).ConversionRate;
                }

                if (conversionPastRateMap.get(toIsoCode2 + startDate2) != null) {
                    toUsdRate2 = conversionPastRateMap.get(toIsoCode2 + startDate2).ConversionRate;
                } else {
                    toUsdRate2 = conversionRateMap.get(toIsoCode2).ConversionRate;
                }

                if( Util_String.nvlDec( oppData.Amount) > 0){
                    krwCalculationResult = IF_Util.calculationCurrency(fromIsoCode2
                                                                        , oppData.Amount
                                                                        , toIsoCode2
                                                                        , fromUsdRate2
                                                                        , toUsdRate2 );
                }
                // Decimal convertAmount;
                // convertAmount = IF_Util.calculationCurrency(    oppData.CurrencyIsoCode
                //                                                 , oppData.Amount
                //                                                 , 'KRW'
                //                                                 , conversionRateMap.get(oppData.CurrencyIsoCode).ConversionRate
                //                                                 , conversionRateMap.get('KRW').ConversionRate   );

                if (krwCalculationResult >= bigAccountLimit) {
                    bigAccountYn = 'Y';
                }
            }
            data.BIG_ACCOUNT_YN             = bigAccountYn;                                                                     // 빅어카운트여부 (Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N")
            data.SFDC_URL                  = URL.getSalesforceBaseUrl().toExternalForm() + '/lightning/r/Opportunity/' + oppData.Id + '/view';  // Opportunity 링크URL (URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view)
            data.AccountNumber              = oppData.Account.AccountNumber;                                                    // Contract Account (MDG 고객코드)
            data.SHPR_CCD                   = oppData.LogisticsCustomerType__c;                                                 // 물류 고객 구분
            data.RLBS_PJT_TCD               = oppData.LogisticsBizDevelopmentType__c;                                           // 사업 개발 유형
            data.SALES_AREA_CCD             = oppData.SalesOrganization__r.Region__c;                                           // 수주 권역 코드
            data.SALES_PRNT_ORG_CD          = oppData.SalesOrganization__r.Code__c;                                             // 수주 거점 코드
            // data.SALES_AREA_CCD             = oppData.SalesRegion__c;                                                        // 수주 권역
            // data.SALES_PRNT_ORG_CD          = oppData.SalesOrganization__c;                                                  // 수주 거점
            data.DLVRY_AREA_CCD             = oppData.DeliveryOrganization__r.Region__c;                                        // 매출 권역 코드
            data.DLVRY_PRNT_ORG_CD          = oppData.DeliveryOrganization__r.Code__c;                                          // 매출 거점 코드
            // data.DLVRY_AREA_CCD             = oppData.DeliveryRegion__c;                                                     // 매출 권역
            // data.DLVRY_PRNT_ORG_CD          = oppData.DeliveryOrganization__c;                                               // 매출 거점
            if (oppData.LogisticsBizType__c != null) {
                data.RLBS_BIZ_TCD               = oppData.LogisticsBizType__c.replaceAll(';', ',');                             // 물류 서비스 범위 (Mulit PickList 구분자 ";"을 ","로 변경)
            } else {
                data.RLBS_BIZ_TCD               = oppData.LogisticsBizType__c;                                                  // 물류 서비스 범위 (값 없을때 그대로 처리)
            }
            if (oppData.LogisticsServiceType__c != null) {
                data.RLBS_SVC_TCD               = oppData.LogisticsServiceType__c.replaceAll(';', ',');                         // 물류 서비스 영역 (Mulit PickList 구분자 ";"을 ","로 변경)
                // data.RLBS_SVC_TCD               = Util_String.nvlStr(oppData.get('LogisticsServiceTypeLabel')).replaceAll(';', ',');                  // 2021.06.15 물류 서비스 영역 (Mulit PickList 구분자 ";"을 ","로 변경) Label값
            } else {
                data.RLBS_SVC_TCD               = oppData.LogisticsServiceType__c;                                              // 물류 서비스 영역 (값 없을때 그대로 처리)
            }
            data.BID_EST_DTM                = Util_String.convertDateString(oppData.BiddingDeadline__c);                        // 입찰 마감일
            data.LBS_Exception_Type         = oppData.LBSExceptionType__c;                                                      // 예외 LBS 유형 확인
            data.RLBS_IND_TCD               = oppData.SubIndusrty__c;                                                           // 하위 업종 구분
            // data.RLBS_IND_TCD               = Util_String.nvlStr(oppData.get('SubIndusrtyLabel'));                           // 2021.06.15 하위 업종 구분 Label값
            data.USER_ID                    = oppData.Owner.FederationIdentifier;                                               // 소유자 (영업 대표)의 EP ID
            data.INS_PERSON_ID              = oppData.CreatedBy.FederationIdentifier;                                           // Created By ID의 EP ID
            data.UPD_PERSON_ID              = oppData.LastModifiedBy.FederationIdentifier;                                      // Last Modified By ID의 EP ID
            data.REUSE                      = oppData.Reuse__c;                                                                 // 재활용 필요성 여부 (2021-01-28 추가), Boolean을 Picklist로 변경(2021-03-22) 
            data.REUSE_REASON               = oppData.ReuseReason__c;                                                           // 재활용 필요성 여부 사유 (2021-01-28 추가)

           //##2022-08-23 minhye.park@dkbmc.com LegalReviewNo 물류일 시 Null ----------------------------------
            // 사업유형 레코드 타입 (HQ:10, Logistic:20) (2021-02-08 추가)
            if( oppData.RecordType.DeveloperName  == 'HQ'){
                data.BO_RECORD_TYPE = '10';
                data.LegalReviewNo              = oppData.LegalReviewNo__c;  //2022-08-23추가
            }else{
                data.BO_RECORD_TYPE = '20';
                data.LegalReviewNo              = null;
            }
            
            data.ZZACONT                    = oppData.AgencyContract__c == true ? flagSapTrue : flagSapFalse;                    // 계약대행 여부 (2021-02-19 추가)
            data.ZZACONT_EX                 = oppData.AgencyContractException__c == true ? flagSapTrue : flagSapFalse;           // 계약대행 예외처리 여부 (2021-02-19 추가)
            data.BusinessType2              = oppData.BusinessType2__c;                                                          // 사업유형2 (2021-03-03 추가, X(True) / ''(False))
            data.DealBreak                  = oppData.DealBreak__c == true ? flagSapTrue : flagSapFalse;                         // Deal Break (2021-03-03 추가, X(True) / ''(False))
            data.Construction               = oppData.Construction__c == true ? flagSapTrue : flagSapFalse;                      // 건설 여부 (2021-03-03 추가)
            // data.LegalReviewNo              = oppData.LegalReviewNo__c;                                                          // 법무 검토 번호 (2021-03-03 추가)
            // Decimal krwCalculationResult = 0;
            // if (conversionRateMap.get(oppData.CurrencyIsoCode) != null && conversionRateMap.get(CompanyCurrencyIsoCode) != null) {
            //     if (oppData.CurrencyIsoCode == 'KRW') {
            //         krwCalculationResult = oppData.Amount;
            //     } else {
            //         // KRW로 환상된 예상금액 (계산 개선 (2021-03-18))
            //         String fromIsoCode3 = oppData.CurrencyIsoCode;
            //         String toIsocode3 = 'KRW';
            //         Date startDate3 = quarterDateMap.get(oppData.CloseDate);
            //         Decimal fromUsdRate3 = 0;
            //         Decimal toUsdRate3 = 0;

            //         if (conversionPastRateMap.get(fromIsoCode3 + startDate3) != null) {
            //             fromUsdRate3 = conversionPastRateMap.get(fromIsoCode3 + startDate3).ConversionRate;
            //         } else {
            //             fromUsdRate3 = conversionRateMap.get(fromIsoCode3).ConversionRate;
            //         }

            //         if (conversionPastRateMap.get(toIsoCode3 + startDate3) != null) {
            //             toUsdRate3 = conversionPastRateMap.get(toIsoCode3 + startDate3).ConversionRate;
            //         } else {
            //             toUsdRate3 = conversionRateMap.get(toIsoCode3).ConversionRate;
            //         }

            //         krwCalculationResult = IF_Util.calculationCurrency(    fromIsoCode3
            //                                                                 , oppData.Amount
            //                                                                 , toIsoCode3
            //                                                                 , fromUsdRate3
            //                                                                 , toUsdRate3 );

            //         // krwCalculationResult = IF_Util.calculationCurrency( oppData.CurrencyIsoCode
            //         //                                                     , oppData.Amount
            //         //                                                     , 'KRW'
            //         //                                                     , conversionRateMap.get(oppData.CurrencyIsoCode).ConversionRate
            //         //                                                     , conversionRateMap.get('KRW').ConversionRate   );
            //     }
            // }
            // if (krwCalculationResult == null) {
            //     krwCalculationResult = 0;
            // }

            data.ORDER_AMT_KRW              = krwCalculationResult.setScale(2, System.RoundingMode.HALF_UP).toPlainString();    // KRW로 환상된 예상금액 (2021-03-17 추가), BIG_ACCOUNT_YN 항목 체크를 위해 구한 금액으로 처리
            //신규추가시작
            //수전위 추가
            data.VRB_TYPE_MODI = oppData.Opportunity_Review_Exception__c ? 'Y' : 'N';       //사업심의유형 변경여부
            data.VRB_TYPE_MODI_ID = oppData.Opportunity_Review_Exception_Modifier__r.FederationIdentifier;       //사업심의유형 변경자
            data.BO_CONFIRM_YN = oppData.Opportunity_Review_Confirm_New__c ? 'Y' : 'N';         //BO점검 확정여부 //Added by Anish- v 2.4
            //신규추가종료

            // 2022-02-09 / [Strat] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
            Decimal bizAmt = 0;
            if(!Test.isRunningTest()){              // Start-Added by Anish-V2.1
            if (oppData.Opportunity_Review_Biz_Amount__c != null) {
                bizAmt = oppData.Opportunity_Review_Biz_Amount__c;
            }
            
            data.BIZ_AMOUNT = bizAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString(); // 사업규모
            data.CONSORTIUM_YN = oppData.Opportunity_Review_Consortium__c ? 'Y' : 'N'; // 컨소시엄 여부
            
            // 2022-02-09 / [End] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
               
            // 2022-04-15 / [Start] 서비스형 관련된 컬럼 추가            
            data.CSP_MSP_Type = oppData.CspMspType__c;
            data.CM_Biz_Type = oppData.CMBizType__c;
            data.Collabo_Dept_1 =  oppData.CMCollaboDept1__r.CostCenter__c;  
            data.Collabo_Dept_2 =  oppData.CMCollaboDept2__r.CostCenter__c;  
            // 2022-08-02 MSP 수주금액필드 추가.
            Decimal mspAmt = 0;
            if (oppData.MSP_Amount__C != null) {
                mspAmt = oppData.MSP_Amount__C;
            }            
            data.Collabo_Dept_3 =  mspAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();// MSP 수주 금액
            data.Conversion_Type = oppData.ConversionType__c;
            data.Other_CSP = oppData.OtherCSP__c;
            data.Partner_Account = oppData.PartnerAccount__r.AccountNumber;
            //data.Partner_Account = oppData.PartnerAccountId;  ---> 둘 중 어느것인가
            data.SCP_DC = oppData.SCP_DC__c;
            data.SCP_Scale = oppData.SCPScale__c;
            data.Service_Sales = String.valueOf(oppData.ServiceSales__c);           
            // 2022-04-15 / [End] 서비스형 관련된 컬럼 추가            
            }
            dataList.add(data);
        }

        // Output Data 적재
        OutputHeader outHeader = new OutputHeader();
        outHeader.OPPORTUNITY = dataList;

        return outHeader;
    }

    public class OutputHeader{

        @AuraEnabled
        public List<OutputClass> OPPORTUNITY;
    }

    public class OutputClass{
        
        @AuraEnabled
        public String OPPORTUNITY_ID;                   // Opportunity ID
        @AuraEnabled
        public String ORDER_ID;                         // 사업기회 ID <-- 사업 기회 Code
        @AuraEnabled
        public String ORDER_NAME;                       // BO 명 <-- 사업기획명
        @AuraEnabled
        public String SALES_PHASE;                      // BOM 단계 <-- 단계
        @AuraEnabled
        public String ZZSTATUS;                         // BO Activity Status
        @AuraEnabled
        public String ORDER_TYPE;                       // 사업유형 <-- 사업기회 유형
        @AuraEnabled
        public String SALES_DEPT_CODE;                  // 수주부서 인사코드 <-- 수주 사업그룹 인사코드
        @AuraEnabled
        public String DEVELOP_DEPT_CODE;                // 매출부서 인사코드 <-- 주 매출 부서 인사코드
        @AuraEnabled
        public String COMPANY_ID;                       // 고객사 코드 <-- Contract Account
        @AuraEnabled
        public String ORIGINAL_COMPANY_ID;              // 원청사 코드 <-- 원청사 고객
        @AuraEnabled
        public String SALES_EMP_NO;                     // 영업대표사번 <-- 소유자 (영업 대표)
        @AuraEnabled
        public String SALES_EMP_NAME;                   // 영업대표명 <-- 소유자 (영업 대표)
        @AuraEnabled
        public String PROPOSAL_EMP_NO;                  // 제안PM사번 <-- 제안 PM
        @AuraEnabled
        public String PROPOSAL_EMP_NAME;                // 제안PM명 <-- 제안 PM
        @AuraEnabled
        public String IN_OUT_TYPE;                      // 그룹내/그룹외 <-- 그룹 내 사업 여부
        @AuraEnabled
        public String DOM_ABR_TYPE;                     // 국내/해외 <-- 국내/해외 여부
        @AuraEnabled
        public String ORDER_AMT;                        // 계약 수주액 <-- 예상금액
        @AuraEnabled
        public String CURRENCY_CODE;                    // 계약 통화 <-- 사업 기회 금액의 통화
        @AuraEnabled
        public String DU_ORDER_DATE;                    // 예상수주일자 <-- 예상수주일자
        @AuraEnabled
        public String CONTRACT_TERM_FROM;               // 계약기간 시작일 <-- (계약)매출 시작일
        @AuraEnabled
        public String CONTRACT_TERM_TO;                 // 계약기간 종료일 <-- (계약)매출 종료일
        @AuraEnabled
        public String COMPANY;                          // BO 회사코드 인사코드 <-- Opportunity의 CompanyCode__c로 Company__c의 EPCompanyCode__c
        @AuraEnabled
        public String SAP_COMPANY;                      // 회사코드 <-- Company Code
        @AuraEnabled
        public String LOCAL_CURRENCY_CODE;              // 로컬 통화 <-- Opportunity의 CompanyCode__c로 Company__c의 CurrencyIsoCode
        @AuraEnabled
        public String FLAG;                             // 삭제여부 <-- 삭제 여부
        @AuraEnabled
        public String REG_DATE;                         // BO 등록일 <-- Opportunity 등록일
        @AuraEnabled
        public String REG_EMP_NO;                       // BO 등록자 사번 <-- Opportunity 등록자 사번
        @AuraEnabled
        public String UPDATE_DATE;                      // BO 최종 수정일 <-- Opportunity 수정일
        @AuraEnabled
        public String UPDATE_EMP_NO;                    // BO 최종 수정자 사번 <-- Opportunity 수정자 사번
        @AuraEnabled
        public String BIZ_TYPE;                         // 사업 유형 <-- 사업 유형
        @AuraEnabled
        public String BIZ_TYPE_NM;                      // 사업 유형명 <-- 사업 유형명
        // @AuraEnabled
        // public String COUNTRYTEXT;                      // Country text <-- SFDC 해당사항 없음 (2021-02-26 제거)
        @AuraEnabled
        public String ORGIN_ACCOUNT_DESC;               // 원청사 고객명
        // @AuraEnabled
        // public String ORGIN_ACCOUNT;                    // 원청사 고객사 고객번호    (2021-01-28 중복 필드로 삭제)
        // @AuraEnabled
        // public String CONTACTTEXT;                      // Main Contact <-- 고객사명 (2021-02-16 삭제)
        // @AuraEnabled
        // public String CONTACT_ACCOUNT;                  // 고객사 고객번호  (2021-01-28 중복 필드로 삭제)
        @AuraEnabled
        public String PROBABILITY;                      // 확도 <-- 확도
        @AuraEnabled
        public String ZZSALESSTR;                       // 수주전략세션 수행 여부 <-- Opportunity Activity에"ZP61" 가 있으면 "X", 없으면""로 처리
        @AuraEnabled
        public String BO_OVERVIEW;                      // 개요 <-- 사업기회 개요
        @AuraEnabled
        public String ZZCOOPER;                         // 협업여부(Collaboration) <-- 법인 협업 여부
        @AuraEnabled
        public String BO_STATUS;                        // BO status(Drop, Hold, In process, Lose, Win) <-- Opportunity Status
        @AuraEnabled
        public String LOCAL_ORDER_AMT;                  // 계약 수주액(로컬 통화) <-- Opportunity의 Amount, CurrencyIsoCode를 Company__c의 CurrencyIsoCode로 환산
        @AuraEnabled
        public String SALES_DEPT_COST_CENTER;           // 수주부서 코스트센터 코드 <-- 수주 사업그룹 코스트센터 코드
        @AuraEnabled
        public String DEVELOP_DEPT_COST_CENTER;         // 매출부서 코스트센터 코드 <-- 주 매출 부서 코스트센터 코드
        @AuraEnabled
        public String BO_CLASS;                         // 사업기회 등급 <-- 사업 등급
        @AuraEnabled
        public String BID_METHOD;                       // 입찰 방식 <-- 입찰 방식
        @AuraEnabled
        public String AM_EMP_NO;                        // AM사번 <-- 고객오너(영업대표)
        @AuraEnabled
        public String AM_EMP_NAME;                      // AM명 <-- 고객오너(영업대표)명
        @AuraEnabled
        public String COMPANY_ACCOUNT_DESC;             // 고객사 명
        @AuraEnabled
        public String TECH_PROP;                        // 제안서 여부 <-- Submit Proposal
        @AuraEnabled
        public String ZZVRB_FQ_T;                       // VRB Method Description <-- VRB 유형
        @AuraEnabled
        public String UDATE_ZP21;                       // 사기검(BO Review) <-- Review Opportunity
        @AuraEnabled
        public String UDATE_VRB;                        // VRB(Gate Review) <-- BO Approval Result(ZP52, 사업기회 검토)
        // @AuraEnabled
        // public String UDATE_STRSE;                      // Strategy_Session_End_Date  <-- SFDC 해당사항 없음 (2021-02-26 제거)
        @AuraEnabled
        public String UDATE_LOSE;                       // LOSE_END_DATE <-- Report Lost Opportunity
        @AuraEnabled
        public String UDATE_DROP;                       // DROP_END_DATE <-- Abort Opportunity, Drop Opportunity, Hold Opportunity
        @AuraEnabled
        public String EXEC_PM_NO;                       // 실행PM 사번 <- 제안 PM (2020-12-28 추가)
        @AuraEnabled
        public String INPUT_P;                          // 선투입 <- 선투입 여부 (X(True) / _(False)) (2020-12-28 추가)
        @AuraEnabled
        public String BIZ_FROM_DT;                      // 개발시작일 <- (계약)매출 시작일 (2020-12-28 추가)
        @AuraEnabled
        public String BIZ_TO_DT;                        // 개발완료일 <- (계약)매출 종료일 (2020-12-28 추가)
        @AuraEnabled
        public String SALES_COST_CD;                    // 원가귀속부서 <-- 사업팀 정의 속성01
        @AuraEnabled
        public String CGUBUN_ID;                        // 거점코드 <-- 사업팀 정의 속성02
        @AuraEnabled
        public String BO_LBS_CLASS;                         // RLBS산업유형코드 <-- 사업팀 정의 속성03
        @AuraEnabled
        public String KEY_ACCOUNT_YN;                   // 키어카운트여부 <-- 사업팀 정의 속성04
        @AuraEnabled
        public String BIG_ACCOUNT_YN;                   // 빅어카운트여부 <-- Opportunity Amount가 30억원 이상일 경우 "Y", 아니면 "N"
        @AuraEnabled
        public String SFDC_URL;                         // Opportunity 링크URL <-- URL.getSalesforceBaseUrl() + /lightning/r/Opportunity/ + (Opportunity의 Opportunity_id) + /view
        @AuraEnabled
        public String AccountNumber;                    // MDG 고객코드 <-- Contract Account
        @AuraEnabled
        public String SHPR_CCD;                         // 화주구분코드 <-- 물류 고객 구분
        @AuraEnabled
        public String RLBS_PJT_TCD;                     // 사업 개발 유형 <-- 사업 개발 유형
        @AuraEnabled
        public String SALES_AREA_CCD;                   // 수주 권역 <-- 수주 권역
        @AuraEnabled
        public String SALES_PRNT_ORG_CD;                // 수주 거점 <-- 수주 거점
        @AuraEnabled
        public String DLVRY_AREA_CCD;                   // 매출 권역 <-- 매출 권역
        @AuraEnabled
        public String DLVRY_PRNT_ORG_CD;                // 매출 거점 <-- 매출 거점
        @AuraEnabled
        public String RLBS_BIZ_TCD;                     // 물류 서비스 범위 <-- 물류 서비스 범위
        @AuraEnabled
        public String RLBS_SVC_TCD;                     // 물류 서비스 영역 <-- 물류 서비스 영역
        @AuraEnabled
        public String BID_EST_DTM;                      // 입찰 마감일 <-- 입찰 마감일
        @AuraEnabled
        public String LBS_Exception_Type;               // 예외 :LBS 유형 확인 <-- 예외 LBS 유형 확인
        @AuraEnabled
        public String RLBS_IND_TCD;                     // 물류 업종 <-- 하위 업종 구분
        @AuraEnabled
        public String USER_ID;                          // 소유자 (영업 대표) <-- 소유자 (영업 대표)의 EP ID
        @AuraEnabled
        public String INS_PERSON_ID;                    // Created By ID <-- Created By ID의 EP ID
        @AuraEnabled
        public String UPD_PERSON_ID;                    // Last Modified By ID <-- Last Modified By ID의 EP ID
        @AuraEnabled
        public String REUSE;                            // 재활용필요성여부 (2021-01-28 추가)
        @AuraEnabled
        public String REUSE_REASON;                     // 재활용필요성여부 사유 (2021-01-28 추가)
        @AuraEnabled
        public String BO_RECORD_TYPE;                   // 사업유형 레코드 타입 (HQ:10, Logistic:20) (2021-02-08 추가)
        @AuraEnabled
        public String ZZACONT;                          // 계약대행 여부 (2021-02-19 추가)
        @AuraEnabled
        public String ZZACONT_EX;                       // 계약대행 예외처리 여부 (2021-02-19 추가)
        @AuraEnabled
        public String BusinessType2;                    // 사업유형2 (2021-03-03 추가)
        @AuraEnabled
        public String DealBreak;                        // Deal Break (2021-03-03 추가, X(True) / ''(False))
        @AuraEnabled
        public String Construction;                     // 건설 여부 (2021-03-03 추가, X(True) / ''(False))
        @AuraEnabled
        public String LegalReviewNo;                    // 법무 검토 번호 (2021-03-03 추가)
        @AuraEnabled
        public String ORDER_AMT_KRW;                    // KRW로 환상된 예상금액 (2021-03-17 추가)
        //신규추가시작
        @AuraEnabled
        public String VRB_TYPE_MODI;                    // 사업심의유형 변경여부 (2021-06-30 추가)
        @AuraEnabled
        public String VRB_TYPE_MODI_ID;                 // 사업심의유형 변경자 (2021-06-30 추가)
        @AuraEnabled
        public String BO_CONFIRM_YN;                    // BO 점검 확정여부 (2021-06-30 추가)
        //신규추가종료
        @AuraEnabled
        public String Lost_Reason_CD;                   // 실주 사유코드 (2021-08-10 추가)
        @AuraEnabled
        public String Lost_Reason_Desc;                 // 실주 사유 Description (2021-08-10 추가)
        @AuraEnabled
        public String Drop_Reason_CD;                   // 중도종결 사유코드 (2021-08-10 추가)
        @AuraEnabled
        public String Drop_Reason_Desc;                 // 중도종결 사유 Description (2021-08-10 추가)
        // 2022-02-09 / [Strat] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
        @AuraEnabled
        public String BIZ_AMOUNT;                       // 사업규모
        @AuraEnabled
        public String CONSORTIUM_YN;                    // 컨소시엄 여부
        // 2022-02-09 / [End] 수전위 수정사항 추가(사업규모, 컨소시엄 여부)
       
        // 2022-04-15 / [Start] 서비스형 관련된 컬럼 추가
        @AuraEnabled
        public string CSP_MSP_Type;
        @AuraEnabled
        public string CM_Biz_Type;
        @AuraEnabled
        public string Collabo_Dept_1;
        @AuraEnabled
        public string Collabo_Dept_2;
        @AuraEnabled
        public string Collabo_Dept_3;
        @AuraEnabled
        public string Conversion_Type;
        @AuraEnabled
        public string  Other_CSP;
        @AuraEnabled
        public string  Partner_Account;
        @AuraEnabled
        public string  SCP_DC;
        @AuraEnabled
        public Decimal  SCP_Scale;
        @AuraEnabled
        public string  Service_Sales;
        // 2022-04-15 / [End] 서비스형 관련된 컬럼 추가
        //Added by Anish - V.2.1
        @AuraEnabled
        public string  Competitors;
        @AuraEnabled
        public string  Activity_Status;
        @AuraEnabled
        public String  First_CloseDate;  // Change DataType to String
        @AuraEnabled
        public string  Origin_Account_Name_1;
        @AuraEnabled
        public string  Origin_Account_Name_2;
        @AuraEnabled
        public string  Origin_Account_Name_3;
        @AuraEnabled
        public string  Collaboration_BO_Name;
        @AuraEnabled
        public string  Collaboration_CompanyCode;
        @AuraEnabled
        public string  AgencyContract_Role;
        @AuraEnabled
        public string  AgencyContract_Security;
        @AuraEnabled
        public string  AgencyContract_Urgency;
        
        
    }   
}