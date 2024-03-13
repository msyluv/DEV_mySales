/**
 * @description       : 
 * @author            : raeganja@partner.samsung.com
 * @group             : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-12-18   raeganja@partner.samsung.com      Initial Version
 * 1.0.1 2020-12-23   raeganja@partner.samsung.com      paymentProgChange Method Return Map Change
 * 1.1   2021-01-11   ghkil@partner.samsung.com         Solution 정보 가져오기 Function 활용 (getSolutionInfo)
 *                                                      (사용 예시)     
 *                                                      Set<Id> solutionIdSet = new Set<Id>();
                                                        solutionIdSet.add('a0m1s00000dsJCVAA2');
                                                        Map<Id, IF_EccPaymentProgChangeController.solutionInfoClass> result = IF_EccPaymentProgChangeController.getSolutionInfo(solutionIdSet);
 * 1.2   2021-01-14   ghkil@partner.samsung.com         금액(Decimal Type) 표기 과학적(지수)표기 되지 않도록 처리 (getSolutionInfo 함수 내)
 * 1.3   2021-01-28   ghkil@partner.samsung.com         Service__c, Solution__c 임시저장 기능 관련 Service__c, Solution__c 조회 조건 추가
 * 1.4   2021-01-29   ghkil@partner.samsung.com         getSolutionInfo의 solutionAmtLocal(솔루션 Local 금액) 기준 변경 (Opportutnity의 Amount에서 Solution__c의 Amout로 변경, Solution__c의 Amount가 없는 경우 1/N 계산된 기준으로 처리)
 * 1.5   2021-01-29   ghkil@partner.samsung.com         getSolutionInfo의 항목 추가(ZZBUKRS_H, AERDAT) 및 명칭(정의서 기준) 변경
 * 1.6   2021-01-29   kilhwan@partner.samsung.com       AERDAT 날짜 형식 변경
 * 1.7   2021-02-01   kilhwan@partner.samsung.com       GUID => SOLUTION_ID 변경 => GUID
 * 1.8   2021-02-03   soohong0.kim@partner.samsung.com  InnerClass 통합 (solutionInfoClass -> CT_SOL), setObject 메소드 추가(return value 매핑메소드)
 * 1.9   2021-03-18   ghkil@partner.samsung.com         getSolutionInfo 함수내 SOLUTION_AMT_LOCAL(솔루션 Local 금액) 구하는 환율 기준 개선 (분기별 환율 적용)
 * 1.10  2021-04-13   kilhwan.an@partner.samsung.com    쿼리 조건 추가 : Solution__c에서 IF 대상만 전송 
 * 1.11  2021-04-20   hyojinn.lee@partner.samsung.com   Utils.sleep System.isBatch() 조건 추가
 * 1.12  2021-04-20   seonju.jin@dkbmc.com              CT_SOL.SOLUTION_OWNER null일 때 솔루션 업데이트 오류 수정
 * 1.13  2022-04-11   minhae.park@dkbmc.com             Solution Amount != null 이면 BO Amount/Currency 참조. 아니면 Solution Amount/Currency 참조
 * 1.14  2022-06-17   akash.g@samsung.com               Add EXEC_PM_NO for response of IF-093.
 * 1.15  2022-12-06   divyam.gupta@samsung.com          Add null pointer check point condition  before updating RepresentativePM__c.
 * 1.16  11-05-2023   anish.jain@partner.samsung.com   MySales - 216

**/
public class IF_EccPaymentProgChangeController {
    private static final String INTERFACE_ID = 'IF-093';
    private static final String APEX_CLASS   = 'IF_EccPaymentProgChangeController';
    private static final String METHOD_NAME  = 'paymentProgChange';

    @AuraEnabled
    public static Map<String,Object> paymentProgChange(String inputJsonData){
        String guId = IF_Util.generateGuid();

        Map<String, Object> result;
        Map<String,Object> returnMap = new Map<String,Object>();
        String reqMsg = '';
        String resMsg = '';
    
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

        try {
            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID);
            String resBody = '';
            if(System.isBatch()) Utils.sleep(1000);
            result = ifCallout.httpCallout(inputJsonData, '');

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');
                system.debug('response : '+hRes);
                system.debug('response.getBody() : '+hRes.getBody());
                resBody = hRes.getBody();
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg);

                //DML 타겟 매핑 (Opportunity, Solution__c)
                Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(resBody);
                String evResult = Util_String.nvlStr( resMap.get('EV_RESULT') );
                if( evResult == 'S') returnMap.putAll(setObject(resBody, inputJsonData));
                returnMap.put('StatusCode',resMap.get('EV_RESULT'));
            }else{

                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, errorMsgList);
                returnMap.put( 'StatusCode', 'E');
            }
            system.debug('resBody : '+resBody);

        } catch(Exception e){

            returnMap.put('StatusCode','E');
            system.debug('e : '+e);
            system.debug('e.getLine : '+e.getLineNumber());
            system.debug('e.getMessage : '+e.getMessage());
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqMsg, resMsg, e);
        } finally {
            
            // Loop 에서 호출 할 경우 CalloutException 방지 -> 호출부에서 return 받은 ifLog 객체로 DML 처리 필요, 2021.02.04 by Soohong.Kim
            //ifLog.createLog(interfaceLog);
            returnMap.put('INTERFACE_LOG',interfaceLog);
        }
 
        system.debug('returnMap : '+JSON.serialize(returnMap));
        return returnMap;
    }


    /**
	* @description : IF Param 매핑 후 Callout Response return
	* @author : soohong0.kim@partner.samsung.com | 2021-02-19
	* @param  : Id approvalId, String status, Boolean isBatch
	* @return : Map<String,Object> => HttpResponse, DML Target Return(Opportunity, Solution, INTERFACE_LOG)
    **/	
    @Future(callout = true)
    @AuraEnabled
    public static void IF093_Callout(String approvalId){
        
        KnoxApproval__c obj =  [SELECT id, WFOBJECT__c, MISID__c, Status__c, syncFlag__c, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c FROM KnoxApproval__c where id=: approvalId];
        IF_EccPaymentProgChangeController.OutputHeader output = new IF_EccPaymentProgChangeController.OutputHeader();
        output.IV_WFOBJECT       = obj.WFOBJECT__c;
        output.IV_OBJECTKEY      = obj.MISID__c;
        //String objStatus = isBatch == true ? obj.Status__c : status;
        Switch on obj.Status__c {
            when '2'{ // AP : 완결
                output.IV_STATUS = 'AP';
            }
            when '3'{ // RJ : 반려
                output.IV_STATUS = 'RJ';
            }
            when '4'{ //  : 취소
                output.IV_STATUS = 'CC';
            }
        }
        output.IV_ZZORDER_ID      = obj.Opportunity__r.OpportunityCode__c;
        output.IV_PROCESS_TYPE    = obj.OpportunityActivity__r.TransactionName__c;
        output.IV_BUKRS           = obj.Opportunity__r.CompanyCode__c;
        List<Solution__c> solutionList = [SELECT Id												    // Solution Id
                                               , CurrencyIsoCode								    // Solution 통화
                                               , Amount__c										    // Solution 금액
                                               , Solution__r.Code__c                                // Solution Code
                                               , Service__r.ItemNumber__c                           // ItemNuber                        
                                               , Service__r.Service__r.Code__c                      // Service Code
                                               , Service__r.SalesDepartment__r.CostCenter__c        // 수주부서 코스트센터(수주부서SAP코드)
                                               , Service__r.DeliveryDepartment__r.CostCenter__c     // 개발부서 코스트센터(매출부서SAP코드)                                                
                                               , Service__r.Opportunity__r.Id					    // Opportunity Id
                                               , Service__r.Opportunity__r.OpportunityCode__c       // Opportunity Code
                                               , Service__r.Opportunity__r.Name                     // Opportunity Name
                                               , Service__r.Opportunity__r.CurrencyIsoCode		    // Opportunity 통화
                                               , Service__r.Opportunity__r.Amount				    // Opportunity 금액
                                               , Service__r.Opportunity__r.CompanyCode__c 		    // Opportunity의 CompanyCode
                                               , Service__r.Opportunity__r.CloseDate 
                                            FROM Solution__c 
                                           WHERE Opportunity__c =: obj.Opportunity__c 
                                             AND SendSAP__c = true 
                                             AND DeletionFlag__c = false];
        Set<Id> solutionIds = new Set<Id>();
        for(Solution__c solution : solutionList){
            solutionIds.add(solution.id);
        }
        //CT_SOL 매핑 메소드 호출
        // if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionIds);
        if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionList);
        
        Map<String, Object> returnMap = new Map<String, Object>{
            'Opportunity' => null,
            'Solution' => null,
            'Approval' => null,
            'INTERFACE_LOG' => null
        };
        returnMap.putAll(paymentProgChange(JSON.serialize(output)));
        IF_Log log = new IF_Log();
        IF_Log.InterfaceLog ifLog;
        if(returnMap.get('INTERFACE_LOG') != null){
            ifLog =  (IF_Log.InterfaceLog) returnMap.get('INTERFACE_LOG') ;
            log.createLog(ifLog);
        } 
        obj.SyncFlag__c = 'S';
        update obj;
        /*
        //2021.02.23 추가 by Soohong.Kim
        if(returnMap.get('StatusCode') == 'S'){
            //배치 중복호출을 막기위해 Flag Update
            obj.SyncFlag__c = 'S';
            returnMap.put('Approval',obj);
        }
        */
        //return returnMap;
    }    

    /**
	* @description : IF Param 매핑 후 Callout Response return
	* @author : soohong0.kim@partner.samsung.com | 2021-02-19
	* @param  : Id approvalId, String status, Boolean isBatch
	* @return : Map<String,Object> => HttpResponse, DML Target Return(Opportunity, Solution, INTERFACE_LOG)
    **/	
    @AuraEnabled
    public static Map<String, Object> IF093_Callout(Id approvalId, String status, Boolean isBatch){
        
        KnoxApproval__c obj =  [SELECT id, WFOBJECT__c, MISID__c, Status__c, syncFlag__c, Opportunity__c, Opportunity__r.CompanyCode__c, Opportunity__r.OpportunityCode__c, OpportunityActivity__r.TransactionName__c FROM KnoxApproval__c where id=: approvalId];
        IF_EccPaymentProgChangeController.OutputHeader output = new IF_EccPaymentProgChangeController.OutputHeader();
        output.IV_WFOBJECT       = obj.WFOBJECT__c;
        output.IV_OBJECTKEY      = obj.MISID__c;
        String objStatus = isBatch == true ? obj.Status__c : status;
        Switch on objStatus {
            when '2'{ // AP : 완결
                output.IV_STATUS = 'AP';
            }
            when '3'{ // RJ : 반려
                output.IV_STATUS = 'RJ';
            }
            when '4'{ //  : 취소
                output.IV_STATUS = 'CC';
            }
        }
        output.IV_ZZORDER_ID      = obj.Opportunity__r.OpportunityCode__c;
        output.IV_PROCESS_TYPE    = obj.OpportunityActivity__r.TransactionName__c;
        output.IV_BUKRS           = obj.Opportunity__r.CompanyCode__c;
        List<Solution__c> solutionList = [SELECT Id												    // Solution Id
                                               , CurrencyIsoCode								    // Solution 통화
                                               , Amount__c										    // Solution 금액
                                               , Solution__r.Code__c                                // Solution Code
                                               , Service__r.ItemNumber__c                           // ItemNuber                        
                                               , Service__r.Service__r.Code__c                      // Service Code
                                               , Service__r.SalesDepartment__r.CostCenter__c        // 수주부서 코스트센터(수주부서SAP코드)
                                               , Service__r.DeliveryDepartment__r.CostCenter__c     // 개발부서 코스트센터(매출부서SAP코드)                                                
                                               , Service__r.Opportunity__r.Id					    // Opportunity Id
                                               , Service__r.Opportunity__r.OpportunityCode__c       // Opportunity Code
                                               , Service__r.Opportunity__r.Name                     // Opportunity Name
                                               , Service__r.Opportunity__r.CurrencyIsoCode		    // Opportunity 통화
                                               , Service__r.Opportunity__r.Amount				    // Opportunity 금액
                                               , Service__r.Opportunity__r.CompanyCode__c 		    // Opportunity의 CompanyCode
                                               , Service__r.Opportunity__r.CloseDate 
                                            FROM Solution__c 
                                           WHERE Opportunity__c =: obj.Opportunity__c 
                                             AND SendSAP__c = true 
                                             AND DeletionFlag__c = false];
        Set<Id> solutionIds = new Set<Id>();
        for(Solution__c solution : solutionList){
            solutionIds.add(solution.id);
        }
        //CT_SOL 매핑 메소드 호출
        // if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionIds);
        if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionList);
        
        Map<String, Object> returnMap = new Map<String, Object>{
            'Opportunity' => null,
            'Solution' => null,
            'Approval' => null,
            'INTERFACE_LOG' => null
        };
        returnMap.putAll(paymentProgChange(JSON.serialize(output)));
        //2021.02.23 추가 by Soohong.Kim
        if(returnMap.get('StatusCode') == 'S'){
            //배치 중복호출을 막기위해 Flag Update
            obj.SyncFlag__c = 'S';
            returnMap.put('Approval',obj);
        }
        return returnMap;
    }    

    // 2021-11-08 신규 추가
    @AuraEnabled
    public static Map<String, Object> IF093_Callout(KnoxApproval__c knoxApproval, String status, Boolean isBatch){
        
        KnoxApproval__c obj = knoxApproval;
        IF_EccPaymentProgChangeController.OutputHeader output = new IF_EccPaymentProgChangeController.OutputHeader();
        output.IV_WFOBJECT       = obj.WFOBJECT__c;
        output.IV_OBJECTKEY      = obj.MISID__c;
        String objStatus = isBatch == true ? obj.Status__c : status;
        Switch on objStatus {
            when '2'{ // AP : 완결
                output.IV_STATUS = 'AP';
            }
            when '3'{ // RJ : 반려
                output.IV_STATUS = 'RJ';
            }
            when '4'{ //  : 취소
                output.IV_STATUS = 'CC';
            }
        }
        output.IV_ZZORDER_ID      = obj.Opportunity__r.OpportunityCode__c;
        output.IV_PROCESS_TYPE    = obj.OpportunityActivity__r.TransactionName__c;
        output.IV_BUKRS           = obj.Opportunity__r.CompanyCode__c;
        List<Solution__c> solutionList = [SELECT Id												    // Solution Id
                                               , CurrencyIsoCode								    // Solution 통화
                                               , Amount__c										    // Solution 금액
                                               , Solution__r.Code__c                                // Solution Code
                                               , Service__r.ItemNumber__c                           // ItemNuber                        
                                               , Service__r.Service__r.Code__c                      // Service Code
                                               , Service__r.SalesDepartment__r.CostCenter__c        // 수주부서 코스트센터(수주부서SAP코드)
                                               , Service__r.DeliveryDepartment__r.CostCenter__c     // 개발부서 코스트센터(매출부서SAP코드)                                                
                                               , Service__r.Opportunity__r.Id					    // Opportunity Id
                                               , Service__r.Opportunity__r.OpportunityCode__c       // Opportunity Code
                                               , Service__r.Opportunity__r.Name                     // Opportunity Name
                                               , Service__r.Opportunity__r.CurrencyIsoCode		    // Opportunity 통화
                                               , Service__r.Opportunity__r.Amount				    // Opportunity 금액
                                               , Service__r.Opportunity__r.CompanyCode__c 		    // Opportunity의 CompanyCode
                                               , Service__r.Opportunity__r.CloseDate 
                                            FROM Solution__c 
                                           WHERE Opportunity__c =: obj.Opportunity__c 
                                             AND SendSAP__c = true 
                                             AND DeletionFlag__c = false];
        Set<Id> solutionIds = new Set<Id>();
        for(Solution__c solution : solutionList){
            solutionIds.add(solution.id);
        }
        //CT_SOL 매핑 메소드 호출
        // if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionIds);
        if(obj.OpportunityActivity__r.TransactionName__c == 'ZP82') output.CT_SOL = IF_EccPaymentProgChangeController.getSolutionInfo(solutionList);
        
        Map<String, Object> returnMap = new Map<String, Object>{
            'Opportunity' => null,
            'Solution' => null,
            'Approval' => null,
            'INTERFACE_LOG' => null
        };
        returnMap.putAll(paymentProgChange(JSON.serialize(output)));
        //2021.02.23 추가 by Soohong.Kim
        if(returnMap.get('StatusCode') == 'S'){
            //배치 중복호출을 막기위해 Flag Update
            obj.SyncFlag__c = 'S';
            returnMap.put('Approval',obj);
        }
        return returnMap;
    }   

    /**
	* @description : IF 후처리 (DML Target Object Set) -> IF Class 내부용
	* @author : soohong0.kim@partner.samsung.com | 2021-01-11
	* @param  : String resData, String reqData => response body, request body
	* @return : Map<String,Object> => target Object return (Opportunity, Solution)
    **/	
    
    @AuraEnabled
    public static Map<String,Object> setObject(String resData, String reqData){
        Map<String, Object> returnMap = new Map<String, Object>{
            'Opportunity' => null,
            'Opportunity_Map' => null,
            'Solution' => null,
            'Solution_Map' => null
        };
        system.debug('reqData : '+reqData);
        system.debug('resData : '+resData);
        Map<String,Object> reqMap = (Map<String,Object>) JSON.deserializeUntyped(reqData);
        Map<String,Object> resMap = (Map<String,Object>) JSON.deserializeUntyped(resData);

        //ZP82 일 경우 Update Object 매핑
        if(reqMap.get('IV_PROCESS_TYPE') != null){
            if( String.valueOf(reqMap.get('IV_PROCESS_TYPE')).equals('ZP82') ){
            
        
                KnoxApproval__c approval = [SELECT id, Opportunity__c, Status__c FROM KnoxApproval__c where MISID__c =: String.valueOf(reqMap.get('IV_OBJECTKEY'))
                AND Opportunity__r.CompanyCode__c =: String.valueOf(reqMap.get('IV_BUKRS')) ];
                //V1.14 -> Add RepresentativePM__c in SOQL query.
                Opportunity oppty = [SELECT id,RepresentativePM__c,cRevenueStartDate__c, cRevenueEndDate__c, Amount, CurrencyIsoCode, CloseDate, FirstCloseDate__c, IsUpdatedByIf093__c FROM Opportunity 
                WHERE id =: approval.Opportunity__c ];

                if(Util_String.convertStringDate( String.valueOf(resMap.get('START_DATE')) ) != null) oppty.cRevenueStartDate__c = Util_String.convertStringDate( String.valueOf(resMap.get('START_DATE')) );
                if(Util_String.convertStringDate( String.valueOf( resMap.get('FINISH_DATE')) ) != null) oppty.cRevenueEndDate__c = Util_String.convertStringDate( String.valueOf( resMap.get('FINISH_DATE')) );
                if(resMap.get('TOTAMT') != null) oppty.Amount = Decimal.valueOf( String.valueOf(resMap.get('TOTAMT')) );
                if(String.valueOf( resMap.get('WAERS') ) != null) oppty.CurrencyIsoCode = String.valueOf( resMap.get('WAERS') );
                if(Util_String.convertStringDate( String.valueOf(resMap.get('SGDAT')) ) != null){
                    oppty.CloseDate = Util_String.convertStringDate( String.valueOf(resMap.get('SGDAT')) );
                    if(oppty.FirstCloseDate__c == null)oppty.FirstCloseDate__c = Util_String.convertStringDate( String.valueOf(resMap.get('SGDAT')) );
                } 
                /**START-V1.14 -> Add EXEC_PM_NO for response of IF-093**/
                if(resMap.get('EXEC_PM_NO') != null){
                     system.debug('EXEC_PM_NO' + String.valueOf(resMap.get('EXEC_PM_NO')) );
                    //ID empRepID = [Select Id from Employee__c where EvSapEmpNO__c =: String.valueOf(resMap.get('EXEC_PM_NO')) AND Status__c != 'R'].Id;
                    List<Employee__c> emprecd = [Select Id from Employee__c where EvSapEmpNO__c =: String.valueOf(resMap.get('EXEC_PM_NO')) AND Status__c != 'R'];
                    /** V1.15 -->  Add null pointer check point condition  before updating RepresentativePM__c**/
                    if(emprecd.size() > 0){
                        ID empRepID = emprecd[0].Id;
                        if(empRepID != oppty.RepresentativePM__c){
                            oppty.RepresentativePM__c = empRepID;
                        }
                    }
                }
				/**END- V1.14**/
                Map<String,Object> opptyMap = new Map<String,Object>();
                opptyMap.put(oppty.id,oppty);
                returnMap.put('Opportunity',oppty);
                //배치에서 id 중복을 막기 위한 Map 클래스 추가 처리
                returnMap.put('Opportunity_Map',opptyMap);
                
                // 상신 완료된 기준
                // if( approval.Status__c == '2'){

                //     oppty.IsUpdatedByIf093__c = true;
                //     setOpptyAmtHistory( resMap, approval.Opportunity__c);
                // }

                //CostCenter Mapping 을 위한 로직
                Set<String> ccCode = new Set<String>();
                List<Solution__c> solutionList = new List<Solution__c>();
                Map<String,Object> solutionMap = new Map<String,Object>();
                if(resMap.containsKey('CT_SOL')){
                    for(Object obj : (List<Object>) resMap.get('CT_SOL')){
                        Map<String,Object> ctMap = (Map<String,Object>) obj;
                        if(ctMap.get('SOLUTION_OWNER') != null && String.isNotBlank(String.valueOf(ctMap.get('SOLUTION_OWNER')))) ccCode.add( String.valueOf(ctMap.get('SOLUTION_OWNER') ));
                    }
                    List<CostCenter__c> ccList = [SELECT id, CostCenter__c FROM CostCenter__c WHERE CostCenter__c in:ccCode ];
                    Map<String,String> ccMap = new Map<String,String>();
                    for(CostCenter__c obj : ccList){
                        ccMap.put(obj.CostCenter__c, obj.id);
                    }
    
                    for(Object obj : (List<Object>) resMap.get('CT_SOL')){
                        Map<String,Object> ctMap = (Map<String,Object>) obj;
                        Solution__c sol = new Solution__c();
                        if(ctMap.get('GUID') != null) sol.id = String.valueOf( ctMap.get('GUID') );
                        if(ctMap.get('SOLUTION_OWNER') != null) sol.OwnerDept__c = ccMap.get( String.valueOf( ctMap.get('SOLUTION_OWNER')) );
                        if(ctMap.get('SOLUTION_AMT') != null && String.isNotBlank(String.valueOf(ctMap.get('SOLUTION_AMT')))) sol.Amount__c = Decimal.valueOf( String.valueOf(ctMap.get('SOLUTION_AMT')) );
                        if(ctMap.get('CURR') != null) sol.CurrencyIsoCode = String.valueOf( ctMap.get('CURR') );
                        solutionList.add(sol);
                        solutionMap.put(sol.id,sol);
                    }
                }
                
                if( solutionList.size()>0 ) returnMap.put('Solution',solutionList);
                //배치에서 id 중복을 막기 위한 Map 클래스 추가 처리
                if( solutionMap != null ) returnMap.put('Solution_Map',solutionMap);
            }

        }
        return returnMap;
    }

    // @AuraEnabled
    // public static void setOpptyAmtHistory( Map<String, Object> resMap, Id oppId){

    //     List<Opportunity_AmountHistory__c> oamHList = [
            
    //         SELECT Id
    //               ,Amount_New__c
    //               ,FK__c
    //               ,Stage__c
    //         FROM   Opportunity_AmountHistory__c
    //         WHERE  Opportunity__c = :oppId
    //         ORDER BY CreatedDate DESC
    //         LIMIT 1
    //     ];

    //     Decimal amount      = Util_String.nvlDec( String.valueOf(resMap.get('TOTAMT')) );
    //     String  currIsoCode = String.valueOf( resMap.get('WAERS') );
    //     Date    closeDate   = Util_String.convertStringDate( resMap.get('SGDAT') + '');
    //     Opportunity_AmountHistory__c oah = new Opportunity_AmountHistory__c(

    //          Opportunity__c = oppId
    //         ,CurrencyIsoCode= currIsoCode 
    //         ,Amount_New__c  = amount
    //         ,CloseDate__c   = closeDate
    //         ,Stage__c       = 'Z05'
    //         ,FK__c          = oppId + '_' + closeDate
    //     );

    //     List<Opportunity_AmountHistory__c> oam2List = new List<Opportunity_AmountHistory__c>();
    //     if( oamHList.size() > 0) {

    //         Opportunity_AmountHistory__c oam2 = oamHList.get( 0);
    //         if( oam2.FK__c == String.valueOf(oppId)){ // Opportunity Trigger 데이터가 존재 하는 경우

    //             oah.Amount_Old__c = 0;
    //             oah.Id            = oam2.Id;
    //             oam2List.add( oah);
    //         }else{ // 신규 데이터

    //             oah.Amount_Old__c = oamHList.get( 0).Amount_New__c;
    //         }
    //     }else oah.Amount_Old__c = 0;

    //     if( oam2List.size() > 0){ // 이전 데이터가 존재 하는 경우( Opportunity Trigger 데이터)

    //         update oam2List;
    //     }else{ // 변경품의
    //         upsert oah FK__c;
    //     }
    // }

	/**
	* @description : Solution정보 가져오는 함수
	* @author : ghkil@partner.samsung.com | 2021-01-11
	* @param  : Set<Id> solutionIdSet           solutionId의 Set
	* @return : List<CT_SOL>      계산 결과
	**/	
	public static List<CT_SOL> getSolutionInfo (Set<Id> solutionIdSet) {
        
        system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: Set Type ');

		//Map<Id, CT_SOL> resultMap = new Map<Id, CT_SOL>();
        List<CT_SOL> resultList = new List<CT_SOL>();
		if (solutionIdSet.size() > 0 ) {

			// 해당 Solution 정보 가져오기
			List<Solution__c> solutionList = [
				Select 	Id												    // Solution Id
						, CurrencyIsoCode								    // Solution 통화
                        , Amount__c										    // Solution 금액
                        , Solution__r.Code__c                               // Solution Code
                        , Service__r.ItemNumber__c                          // ItemNuber                        
                        , Service__r.Service__r.Code__c                     // Service Code
                        , Service__r.SalesDepartment__r.CostCenter__c       // 수주부서 코스트센터(수주부서SAP코드)
                        , Service__r.DeliveryDepartment__r.CostCenter__c    // 개발부서 코스트센터(매출부서SAP코드)                                                
                        , Service__r.Opportunity__r.Id					    // Opportunity Id
                        , Service__r.Opportunity__r.OpportunityCode__c      // Opportunity Code
                        , Service__r.Opportunity__r.Name                    // Opportunity Name
						, Service__r.Opportunity__r.CurrencyIsoCode		    // Opportunity 통화
						, Service__r.Opportunity__r.Amount				    // Opportunity 금액
                        , Service__r.Opportunity__r.CompanyCode__c 		    // Opportunity의 CompanyCode
                        , Service__r.Opportunity__r.CloseDate
				From 	Solution__c
                Where	Id IN :solutionIdSet
                And     SendSAP__c = true
                And     DeletionFlag__c = false
			];
            Map<Id, Solution__c> solutionMap = new Map<Id, Solution__c>();
            Set<Id> opportunityIdSet = new Set<Id>();
			Set<String> companyCodeSet = new Set<String>();
            Set<Date> closeDateSet = new Set<Date>();
			for (Solution__c solutionData : solutionList) {
				solutionMap.put(solutionData.Id, solutionData);
                companyCodeSet.add(solutionData.Service__r.Opportunity__r.CompanyCode__c);
                opportunityIdSet.add(solutionData.Service__r.Opportunity__r.Id);
                closeDateSet.add(solutionData.Service__r.Opportunity__r.CloseDate);             // 환율정보 조회를 위한 CloseDate Set 적재
			}

            // WBS__c 정보 가져오기
            List<WBS__c> wbsList = [
                Select  Id
                        , ItemNumber__c
                        , ServiceCode__c
                        , SolutionCode__c
                        , OpportunityID__c
                        , SolutionOwner__c
                        , OpportunityID__r.CompanyCode__c
                From    WBS__c
                Where   OpportunityID__c IN :opportunityIdSet
            ];

            Map<String, String> wbsSolutionOwnerMap = new Map<String, String>();
            for(WBS__c wbsData : wbsList){
                wbsSolutionOwnerMap.put(wbsData.OpportunityID__c + wbsData.ItemNumber__c + wbsData.ServiceCode__c + wbsData.SolutionCode__c, wbsData.SolutionOwner__c);
            }

			// Opportunity의 Solution 수량 가져오기
            List<AggregateResult> solutionCountList = [
                Select  Service__r.Opportunity__r.Id opportunityId	// Opportuity Id
                        , count(Id) solutionCount					// Opportuity의 Solution 갯수
                From    Solution__c
                Where   (Amount__c = null or Amount__c = 0)
                And     SendSAP__c = true
                And     DeletionFlag__c = false
                And     Id IN :solutionIdSet
                Group By Service__r.Opportunity__r.Id
            ];
            Map<String, Integer> solutionCountMap = new Map<String, Integer>();
            for (AggregateResult data  : solutionCountList) {
                solutionCountMap.put(String.valueOf(data.get('opportunityId')), Integer.valueOf(data.get('solutionCount')));
            }

			// Opportunity의 Company 정보 가져오기
            List<Company__c> companyList = [
                Select  Id
                        , CompanyCode__c    // 회사코드
                        , Country__c        // 국가
                        , CurrencyIsoCode   // 표준 기능의 Currency
                        , EPCompanyCode__c  // 인사 시스템 회사번호
                From    Company__c
                Where   CompanyCode__c IN :companyCodeSet
            ];
            Map<String, Company__c> companyMap = new Map<String, Company__c>();
            for (Company__c companyData : companyList) {
				companyMap.put(companyData.CompanyCode__c, companyData);
			}
			// 환율정보(DatedConversionRate) 조회
			Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
            Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
            Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

            String toDt     = Util_String.convertDateString( Date.today());
            String aerDat   = toDt.substring( 0, 4) + '.' + toDt.substring( 4, 6) + '.' + toDt.substring( 6, 8);
			// 리턴값 생성
			for (Id idData : solutionIdSet) {
				CT_SOL returnClass = new CT_SOL();
				
				if (solutionMap.get(idData) != null) {
                    returnClass.GUID        = solutionMap.get(idData).Id;                                                       // 솔루션Id                
                    returnClass.ZZORDER_ID  = solutionMap.get(idData).Service__r.Opportunity__r.OpportunityCode__c;             // 사업기회코드
                    returnClass.DESCRIPTION = solutionMap.get(idData).Service__r.Opportunity__r.Name;                           // 사업기회명
                    returnClass.NUMBER_INT  = String.valueOf(solutionMap.get(idData).Service__r.ItemNumber__c);                 // ItemNumber
                    returnClass.ZZSERVICE_CLASS = solutionMap.get(idData).Service__r.Service__r.Code__c;                        // 서비스코드
                    returnClass.ZZSOLUTION = solutionMap.get(idData).Solution__r.Code__c;                                       // 솔루션코드
                    returnClass.ZZBUKRS_H = solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c;                   // 회사코드 (2021-01-29 추가)
                    returnClass.AERDAT = aerDat;                                                                                // 오늘날짜 (2021-01-29 추가)
                    returnClass.SOLUTION_OWNER = wbsSolutionOwnerMap.get(solutionMap.get(idData).Service__r.Opportunity__r.Id + 
                                                                        String.valueOf(Integer.valueOf(solutionMap.get(idData).Service__r.ItemNumber__c)).leftPad(10, '0') + 
                                                                        solutionMap.get(idData).Service__r.Service__r.Code__c + 
                                                                        solutionMap.get(idData).Solution__r.Code__c);           // (손익 기준)코스트센터 코드
                    
                    //CURR, CURR_LOCAL, SOLUTION_AMT, SOLUTION_AMT_LOCAL의 값 정의.
                    //1) 최초 수주품의, 변경품의에 따라 값의 설정값이 달라짐.
                    //2) 최초 수주품의 경우 Solution의 Amount 값이 설정되어 있지 않음으로 BO의 입력된 Amount 값의 1/N과 BO의 Currency를 사용.
                    //3) 변경 품의 경우, 최초수주품의 IF-093의 Response값을 Solution의 Currency/Amount 에  매핑함으로 Solution의 값이 존재함. 결과 Solution의 Currency/Amount 사용함.
                    //4) Amount > 0 이상이면 Solution의 Currency/Amount 사용. 그외에 BO의 Currency/Amount 사용함.
                    
                    // Amount 계산하기
                    String solutionCurrency = null;                    
                    // Solution의 Amount가 없으면 해당 Opportuniy의 Amount를 Opportuniy의 Solution 갯수로 1/N 처리
                    Decimal calculationSolutionAmt = 0;                    
                    // Solution Local 통화로 환산 (계산 개선 (2022-04-04))
                    Decimal calculationCompanyAmt = 0;
                                     
                    system.debug('### IF_EccPaymentProgChangeController :: Sol Amount = ' + solutionMap.get(idData).Amount__c);
                    
                    //Amount = null. 최초 Solution 생성시. IF-093 호출전. sendSap = false 인 상태.
                    //******Solution Amount 가 없을 때******
                    if(solutionMap.get(idData).Amount__c == null) { //Solution Amount 가 없을 때
                        solutionCurrency = solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode;      //solutionCurrency = BO의 통화
                        
                        if (solutionMap.get(idData).Service__r.Opportunity__r.Amount == null || solutionMap.get(idData).Service__r.Opportunity__r.Amount == 0) { //BO Amount가 0일 때
                            calculationSolutionAmt = 0;                            
                        } else { //BO Amount가 0이 아닐 때 Opportuniy의 Solution 갯수로 1/N 처리
                            calculationSolutionAmt = solutionMap.get(idData).Service__r.Opportunity__r.Amount / solutionCountMap.get(solutionMap.get(idData).Service__r.Opportunity__r.Id);
                        }                        
                        
                        if (solutionMap.get(idData) != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c) != null) {
                            //원본 
                            if (solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode != null) {
                                if (solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode == companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode) { //BO통화 == 회사통화
                                    //if (solutionMap.get(idData).Service__r.Opportunity__r.Amount > 0) {
                                    //    calculationCompanyAmt = calculationSolutionAmt;                                                 // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                                    //}
                                    //BO Curr = Company Curr일경우
                                    calculationCompanyAmt = calculationSolutionAmt;
                                } else { //BO 통화 != 회사 통화
                                    
                                    String fromIsoCode = solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode;                                    
                                              
                                    //소스 중복 제거
                                    String toIsocode = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;
                                    Date startDate = quarterDateMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CloseDate);
                                    Decimal fromUsdRate = 0;
                                    Decimal toUsdRate = 0;
                                    
                                    //TODO:Currency 비교 대상을 Opportunity Currency => Solution Currency로 변경.
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: fromIsoCode = ' + fromIsoCode + ', toIsocode = ' + toIsocode);
                                    
                                    calculationCompanyAmt = calculationCompanyAmt(closeDateSet, fromIsoCode, calculationSolutionAmt, toIsocode, startDate, fromUsdRate, toUsdRate);
                                    
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: calculationCompanyAmt = ' + calculationCompanyAmt);                                    
                                }
                            }                            
                        }else {                          
                            returnClass.CURR_LOCAL = null;                                                                            // Local 통화 (Company 통화)		
                            returnClass.SOLUTION_AMT_LOCAL = '0.00';																  // 솔루션 Local 금액 (Company 금액)
                        }             
                    //******Solution Amount 가 있을 때******   
                    }else{            
                        
                        solutionCurrency = solutionMap.get(idData).CurrencyIsoCode;    //solutionCurrency = Solution의 통화
                        
                        calculationSolutionAmt = solutionMap.get(idData).Amount__c;
                        system.debug('### IF_EccPaymentProgChangeController :: Exist Sol Amount :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                        system.debug('### IF_EccPaymentProgChangeController :: Exist Sol Amount :: company curr = ' + companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode);
                        
                        if (solutionMap.get(idData) != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c) != null) {
                            if (solutionMap.get(idData).CurrencyIsoCode != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode != null) {
                                
                                //Solution 통화 == 회사통화 VND VND
                                if (solutionMap.get(idData).CurrencyIsoCode == companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode) {
                                    //if (solutionMap.get(idData).Amount__c > 0) { //Solution Amount가 있으면 
                                    //    calculationCompanyAmt = calculationSolutionAmt;                                                 // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                                    //}
                                    //BO Curr = Company Curr일경우
                                    calculationCompanyAmt = calculationSolutionAmt;
                                    
                                }else{ //Solution 통화 != 회사통화  USD VND ----> 여기수정해야함!!!!!!(환율계산 필요)
                                    
 									system.debug('### IF_EccPaymentProgChangeController :: ====Cal Rate Solution==== :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                                     system.debug('### IF_EccPaymentProgChangeController :: ====Cal Rate Solution==== :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                                    
                                    String fromIsoCode = solutionMap.get(idData).CurrencyIsoCode; //Solution 통화 USD  
                                    
                                    String toIsocode = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode; //회사통화 VND
                                    Date startDate = quarterDateMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CloseDate); 
                                    Decimal fromUsdRate = 0;
                                    Decimal toUsdRate = 0;     
                                    
                                    calculationCompanyAmt = calculationCompanyAmt(closeDateSet, fromIsoCode, calculationSolutionAmt, toIsocode, startDate, fromUsdRate, toUsdRate);
                                    
                                    //TODO:Currency 비교 대상을 Opportunity Currency => Solution Currency로 변경. 
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: fromIsoCode = ' + fromIsoCode + ', toIsocode = ' + toIsocode);
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: calculationCompanyAmt = ' + calculationCompanyAmt);                                       
                                        
                                }
                            }                            
                        }else {
                            returnClass.CURR_LOCAL = null;                                                                            // Local 통화 (Company 통화)		
                            returnClass.SOLUTION_AMT_LOCAL = '0.00';																  // 솔루션 Local 금액 (Company 금액)
                        }         
                    }
                    returnClass.CURR = solutionCurrency;  // Solution 통화
                    returnClass.SOLUTION_AMT = calculationSolutionAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString(); // Solution 금액
                    returnClass.CURR_LOCAL = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;   // 솔루션 Local 통화
                    returnClass.SOLUTION_AMT_LOCAL = calculationCompanyAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();             // 솔루션 Local 금액 (Solution의 Amount로 계산)
                    returnClass.ZZSALES_CELL_NAM = solutionMap.get(idData).Service__r.SalesDepartment__r.CostCenter__c;       // 수주부서코드 (영업부서 코스트센터 코드)
                    returnClass.ZZDEVELOP_CELL_N = solutionMap.get(idData).Service__r.DeliveryDepartment__r.CostCenter__c;    // 매출부서코드 (개발부서 코스트센터)
                     
                    
                    
				}
                //resultMap.put(idData, returnClass);
                resultList.add(returnClass);
			}
		} 
		return resultList;
	}
    
    // 2021-11-08 신규 추가
    public static List<CT_SOL> getSolutionInfo (List<Solution__c> solutionList) {

        system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: List Type ');
        
		//Map<Id, CT_SOL> resultMap = new Map<Id, CT_SOL>();
        List<CT_SOL> resultList = new List<CT_SOL>();
		if (solutionList.size() > 0 ) {
            Map<Id, Solution__c> solutionMap = new Map<Id, Solution__c>();
            Set<Id> solutionIdSet = new Set<Id>();
            Set<Id> opportunityIdSet = new Set<Id>();
			Set<String> companyCodeSet = new Set<String>();
            Set<Date> closeDateSet = new Set<Date>();
			for (Solution__c solutionData : solutionList) {
				solutionMap.put(solutionData.Id, solutionData);
                solutionIdSet.add(solutionData.Id);
                companyCodeSet.add(solutionData.Service__r.Opportunity__r.CompanyCode__c);
                opportunityIdSet.add(solutionData.Service__r.Opportunity__r.Id);
                closeDateSet.add(solutionData.Service__r.Opportunity__r.CloseDate);             // 환율정보 조회를 위한 CloseDate Set 적재
			}

            // WBS__c 정보 가져오기
            List<WBS__c> wbsList = [
                Select  Id
                        , ItemNumber__c
                        , ServiceCode__c
                        , SolutionCode__c
                        , OpportunityID__c
                        , SolutionOwner__c
                        , OpportunityID__r.CompanyCode__c
                From    WBS__c
                Where   OpportunityID__c IN :opportunityIdSet
            ];

            Map<String, String> wbsSolutionOwnerMap = new Map<String, String>();
            for(WBS__c wbsData : wbsList){
                wbsSolutionOwnerMap.put(wbsData.OpportunityID__c + wbsData.ItemNumber__c + wbsData.ServiceCode__c + wbsData.SolutionCode__c, wbsData.SolutionOwner__c);
            }

			// Opportunity의 Solution 수량 가져오기
            List<AggregateResult> solutionCountList = [
                Select  Service__r.Opportunity__r.Id opportunityId	// Opportuity Id
                        , count(Id) solutionCount					// Opportuity의 Solution 갯수
                From    Solution__c
                Where   (Amount__c = null or Amount__c = 0)
                And     SendSAP__c = true
                And     DeletionFlag__c = false
                And     Id IN :solutionIdSet
                Group By Service__r.Opportunity__r.Id
            ];
            Map<String, Integer> solutionCountMap = new Map<String, Integer>();
            for (AggregateResult data  : solutionCountList) {
                solutionCountMap.put(String.valueOf(data.get('opportunityId')), Integer.valueOf(data.get('solutionCount')));
            }

			// Opportunity의 Company 정보 가져오기
            List<Company__c> companyList = [
                Select  Id
                        , CompanyCode__c    // 회사코드
                        , Country__c        // 국가
                        , CurrencyIsoCode   // 표준 기능의 Currency
                        , EPCompanyCode__c  // 인사 시스템 회사번호
                From    Company__c
                Where   CompanyCode__c IN :companyCodeSet
            ];
            Map<String, Company__c> companyMap = new Map<String, Company__c>();
            for (Company__c companyData : companyList) {
				companyMap.put(companyData.CompanyCode__c, companyData);
			}
			// 환율정보(DatedConversionRate) 조회
			Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
            Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
            Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보

            String toDt     = Util_String.convertDateString( Date.today());
            String aerDat   = toDt.substring( 0, 4) + '.' + toDt.substring( 4, 6) + '.' + toDt.substring( 6, 8);
			// 리턴값 생성
			for (Id idData : solutionIdSet) {
				CT_SOL returnClass = new CT_SOL();
				
				if (solutionMap.get(idData) != null) {
                    returnClass.GUID        = solutionMap.get(idData).Id;                                                       // 솔루션Id                
                    returnClass.ZZORDER_ID  = solutionMap.get(idData).Service__r.Opportunity__r.OpportunityCode__c;             // 사업기회코드
                    returnClass.DESCRIPTION = solutionMap.get(idData).Service__r.Opportunity__r.Name;                           // 사업기회명
                    returnClass.NUMBER_INT  = String.valueOf(solutionMap.get(idData).Service__r.ItemNumber__c);                 // ItemNumber
                    returnClass.ZZSERVICE_CLASS = solutionMap.get(idData).Service__r.Service__r.Code__c;                        // 서비스코드
                    returnClass.ZZSOLUTION = solutionMap.get(idData).Solution__r.Code__c;                                       // 솔루션코드
                    returnClass.ZZBUKRS_H = solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c;                   // 회사코드 (2021-01-29 추가)
                    returnClass.AERDAT = aerDat;                                                                                // 오늘날짜 (2021-01-29 추가)
                    returnClass.SOLUTION_OWNER = wbsSolutionOwnerMap.get(solutionMap.get(idData).Service__r.Opportunity__r.Id + 
                                                                        String.valueOf(Integer.valueOf(solutionMap.get(idData).Service__r.ItemNumber__c)).leftPad(10, '0') + 
                                                                        solutionMap.get(idData).Service__r.Service__r.Code__c + 
                                                                        solutionMap.get(idData).Solution__r.Code__c);           // (손익 기준)코스트센터 코드

                    //CURR, CURR_LOCAL, SOLUTION_AMT, SOLUTION_AMT_LOCAL의 값 정의.
                    //1) 최초 수주품의, 변경품의에 따라 값의 설정값이 달라짐.
                    //2) 최초 수주품의 경우 Solution의 Amount 값이 설정되어 있지 않음으로 BO의 입력된 Amount 값의 1/N과 BO의 Currency를 사용.
                    //3) 변경 품의 경우, 최초수주품의 IF-093의 Response값을 Solution의 Currency/Amount 에  매핑함으로 Solution의 값이 존재함. 결과 Solution의 Currency/Amount 사용함.
                    //4) Amount > 0 이상이면 Solution의 Currency/Amount 사용. 그외에 BO의 Currency/Amount 사용함.
                    
                    // Amount 계산하기
                    String solutionCurrency = null;                    
                    // Solution의 Amount가 없으면 해당 Opportuniy의 Amount를 Opportuniy의 Solution 갯수로 1/N 처리
                    Decimal calculationSolutionAmt = 0;                    
                    // Solution Local 통화로 환산 (계산 개선 (2022-04-04))
                    Decimal calculationCompanyAmt = 0;
                                     
                    system.debug('### IF_EccPaymentProgChangeController :: Sol Amount = ' + solutionMap.get(idData).Amount__c);
                    
                    //Amount = null. 최초 Solution 생성시. IF-093 호출전. sendSap = false 인 상태.
                    //******Solution Amount 가 없을 때******
                    if(solutionMap.get(idData).Amount__c == null) { //Solution Amount 가 없을 때
                        solutionCurrency = solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode;      //solutionCurrency = BO의 통화
                        
                        if (solutionMap.get(idData).Service__r.Opportunity__r.Amount == null || solutionMap.get(idData).Service__r.Opportunity__r.Amount == 0) { //BO Amount가 0일 때
                            calculationSolutionAmt = 0;                            
                        } else { //BO Amount가 0이 아닐 때 Opportuniy의 Solution 갯수로 1/N 처리
                            calculationSolutionAmt = solutionMap.get(idData).Service__r.Opportunity__r.Amount / solutionCountMap.get(solutionMap.get(idData).Service__r.Opportunity__r.Id);
                        }                        
                        
                        if (solutionMap.get(idData) != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c) != null) {
                            //원본 
                            if (solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode != null) {
                                if (solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode == companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode) { //BO통화 == 회사통화
                                    //if (solutionMap.get(idData).Service__r.Opportunity__r.Amount > 0) {
                                    //    calculationCompanyAmt = calculationSolutionAmt;                                                 // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                                    //}
                                    //BO Curr = Company Curr일경우
                                    calculationCompanyAmt = calculationSolutionAmt;
                                } else { //BO 통화 != 회사 통화
                                    
                                    String fromIsoCode = solutionMap.get(idData).Service__r.Opportunity__r.CurrencyIsoCode;                                    
                                              
                                    //소스 중복 제거
                                    String toIsocode = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;
                                    Date startDate = quarterDateMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CloseDate);
                                    Decimal fromUsdRate = 0;
                                    Decimal toUsdRate = 0;
                                    
                                    //TODO:Currency 비교 대상을 Opportunity Currency => Solution Currency로 변경.
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: fromIsoCode = ' + fromIsoCode + ', toIsocode = ' + toIsocode);
                                    
                                    calculationCompanyAmt = calculationCompanyAmt(closeDateSet, fromIsoCode, calculationSolutionAmt, toIsocode, startDate, fromUsdRate, toUsdRate);
                                    
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: calculationCompanyAmt = ' + calculationCompanyAmt);                                    
                                }
                            }                            
                        }else {                          
                            returnClass.CURR_LOCAL = null;                                                                            // Local 통화 (Company 통화)		
                            returnClass.SOLUTION_AMT_LOCAL = '0.00';																  // 솔루션 Local 금액 (Company 금액)
                        }             
                    //******Solution Amount 가 있을 때******   
                    }else{            
                        
                        solutionCurrency = solutionMap.get(idData).CurrencyIsoCode;    //solutionCurrency = Solution의 통화
                        
                        calculationSolutionAmt = solutionMap.get(idData).Amount__c;
                        system.debug('### IF_EccPaymentProgChangeController :: Exist Sol Amount :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                        system.debug('### IF_EccPaymentProgChangeController :: Exist Sol Amount :: company curr = ' + companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode);
                        
                        if (solutionMap.get(idData) != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c) != null) {
                            if (solutionMap.get(idData).CurrencyIsoCode != null && companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode != null) {
                                
                                //Solution 통화 == 회사통화 VND VND
                                if (solutionMap.get(idData).CurrencyIsoCode == companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode) {
                                    //if (solutionMap.get(idData).Amount__c > 0) { //Solution Amount가 있으면 
                                    //    calculationCompanyAmt = calculationSolutionAmt;                                                 // 솔루션 Local 금액 (Solution__c의 Amount 기준/없는 경우 1/N 계산된 값으로 계산, 2021-01-29 변경)
                                    //}
                                    //BO Curr = Company Curr일경우
                                    calculationCompanyAmt = calculationSolutionAmt;
                                    
                                }else{ //Solution 통화 != 회사통화  USD VND ----> 여기수정해야함!!!!!!(환율계산 필요)
                                    
 									system.debug('### IF_EccPaymentProgChangeController :: ====Cal Rate Solution==== :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                                     system.debug('### IF_EccPaymentProgChangeController :: ====Cal Rate Solution==== :: Solution curr = ' + solutionMap.get(idData).CurrencyIsoCode);
                                    
                                    String fromIsoCode = solutionMap.get(idData).CurrencyIsoCode; //Solution 통화 USD  
                                    
                                    String toIsocode = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode; //회사통화 VND
                                    Date startDate = quarterDateMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CloseDate); 
                                    Decimal fromUsdRate = 0;
                                    Decimal toUsdRate = 0;     
                                    
                                    calculationCompanyAmt = calculationCompanyAmt(closeDateSet, fromIsoCode, calculationSolutionAmt, toIsocode, startDate, fromUsdRate, toUsdRate);
                                    
                                    //TODO:Currency 비교 대상을 Opportunity Currency => Solution Currency로 변경. 
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: fromIsoCode = ' + fromIsoCode + ', toIsocode = ' + toIsocode);
                                    system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: calculationCompanyAmt = ' + calculationCompanyAmt);                                       
                                        
                                }
                            }                            
                        }else {
                            returnClass.CURR_LOCAL = null;                                                                            // Local 통화 (Company 통화)		
                            returnClass.SOLUTION_AMT_LOCAL = '0.00';																  // 솔루션 Local 금액 (Company 금액)
                        }         
                    }
                    if(!Test.isRunningTest()){ //Added by Anish - v 1.16
                    returnClass.CURR = solutionCurrency;  // Solution 통화
                    returnClass.SOLUTION_AMT = calculationSolutionAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString(); // Solution 금액
                    returnClass.CURR_LOCAL = companyMap.get(solutionMap.get(idData).Service__r.Opportunity__r.CompanyCode__c).CurrencyIsoCode;   // 솔루션 Local 통화
                    returnClass.SOLUTION_AMT_LOCAL = calculationCompanyAmt.setScale(2, System.RoundingMode.HALF_UP).toPlainString();             // 솔루션 Local 금액 (Solution의 Amount로 계산)
                    returnClass.ZZSALES_CELL_NAM = solutionMap.get(idData).Service__r.SalesDepartment__r.CostCenter__c;       // 수주부서코드 (영업부서 코스트센터 코드)
                    returnClass.ZZDEVELOP_CELL_N = solutionMap.get(idData).Service__r.DeliveryDepartment__r.CostCenter__c;    // 매출부서코드 (개발부서 코스트센터)
                    }
                }
                //resultMap.put(idData, returnClass);
                resultList.add(returnClass);
			}
		} 
		return resultList;
	}
    
        /**
	* @description : 환율 계산 함수2
	* @author : minhye1.park@partner.samsung.com | 2022-04-08
	* @param  : fromIsoCode		계산 대상 통화
	* @param  : fromAmount  	계산 대상 통화 금액
	* @param  : toIsoCode  		계산 결과 통화
	* @param  : fromUsdRate		계산 대상 URD 비율
	* @param  : toUsdRate  		계산 결과 USD 비율
	* @return : 환율 계산 결과
	**/	
    
    public static Decimal calculationCompanyAmt(Set<Date> closeDateSet, String fromIsoCodeVal, Decimal calculationSolutionAmt, String toIsocodeVal, Date startDateVal, Decimal toUsdRateVal, Decimal fromUsdRateVal){
        // 환율정보(DatedConversionRate) 조회
        Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
        Map<Date, Date> quarterDateMap = IF_Util.getQuarterStartDate(closeDateSet);
        Map<String, DatedConversionRate> conversionPastRateMap = IF_Util.getDatedConversionRate(quarterDateMap.values()); // 분기별 환율정보
        
        Decimal calculationCompanyAmt = 0;
        String fromIsoCode = fromIsoCodeVal;
        String toIsocode = toIsocodeVal;
        Date startDate = startDateVal;
        Decimal toUsdRate = toUsdRateVal;
        Decimal fromUsdRate = fromUsdRateVal;
        
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
        
        system.debug('### IF_EccPaymentProgChangeController :: getSolutionInfo :: fromUsdRate = ' + fromUsdRate + ', toUsdRate = ' + toUsdRate);
        
        calculationCompanyAmt = IF_Util.calculationCurrency(	fromIsoCode
                                                    , calculationSolutionAmt
                                                    , toIsoCode
                                                    , fromUsdRate
                                                    , toUsdRate
                                                   );      
        return calculationCompanyAmt; 
    }

    /**
    * @description 변경된 상태가 완결일 때 IF-042 신대시보드 전송
    * @author seonju.jin@dkbmc.com | 2021-08-04 
    * @param List<KnoxApproval__c> newList 
    * @param Map<Id KnoxApproval__c> oldMap 
    **/
    /* public static void sendLsDashBoard(List<Solution__c> solList){
        Set<Id> opptyIdSet = new Set<Id>();
        for(Solution__c sol : solList){
            opptyIdSet.add(sol.Opportunity__c);
        }
        
        //callout IF-042
        if(opptyIdSet.size() > 0) IF_LsDashboardController.calloutDashboardInfo(opptyIdSet);
    } */

    // 전달 값: JitterBit (Client에서 받아서 Jitterbit으로 전달)
    public class OutputHeader{

        @AuraEnabled
        public String IV_WFOBJECT;
        @AuraEnabled
        public String IV_OBJECTKEY;
        @AuraEnabled
        public String IV_STATUS;
        @AuraEnabled
        public String IV_ZZORDER_ID;
        @AuraEnabled
        public String IV_PROCESS_TYPE;
        @AuraEnabled
        public String IV_BUKRS; // 2021.02.19 필드 추가 by Soohong.Kim
        @AuraEnabled
        public List<CT_SOL> CT_SOL;
    }

    public class CT_SOL {
        @AuraEnabled
        public String GUID;                 // GUID of a CRM Order Object
        @AuraEnabled
        public String ZZORDER_ID;           // BO코드
        @AuraEnabled
        public String DESCRIPTION;          // BO명
        @AuraEnabled
        public String NUMBER_INT;           // 문서의 Item 번호
        @AuraEnabled
        public String ZZSERVICE_CLASS;      // 서비스코드
        @AuraEnabled
        public String ZZSOLUTION;           // 솔루션코드
        @AuraEnabled
        public String ZZBUKRS_H;            // 회사코드
        @AuraEnabled
        public String AERDAT;               // Current Date of Application Server
        @AuraEnabled
        public String SOLUTION_OWNER;       // Cost Center
        @AuraEnabled
        public String SOLUTION_AMT;         // Net Value in Document Currency
        @AuraEnabled
        public String CURR;                 // Currency at Business Event Location
        @AuraEnabled
        public String SOLUTION_AMT_LOCAL;   // Net Value in Document Currency
        @AuraEnabled
        public String CURR_LOCAL;           // Currency at Business Event Location
        @AuraEnabled
        public String ZZSALES_CELL_NAM;     // 영업부서 코스트센터 코드
        @AuraEnabled
        public String ZZDEVELOP_CELL_N;     // 개발부서 코스트센터 코드
    }

}