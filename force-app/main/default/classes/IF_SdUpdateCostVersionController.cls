/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-05-25
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   03-18-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.2   05-07-2021   soohong0.kim@partner.samsung.com   원가판 컨펌 Activity 반영시 BO의 기타 다른 정보 update요청
**/
@RestResource(urlMapping = '/IF136/*')
global class IF_SdUpdateCostVersionController {
    private static final String INTERFACE_ID = 'IF-136';
    private static final String APEX_CLASS   = 'IF_SdUpdateCostVersionController';
    private static final String METHOD_NAME  = 'doPost';

    @HttpPost
    global static OutputHeader doPost() {
        String guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        
        InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
        OutputHeader outHeader = new OutputHeader();
        SavePoint sp = DataBase.setSavePoint();
        try{

            Set<String> boCodes = new Set<String>();
            Set<String> companyCodes = new Set<String>();
            for(InputClass obj : (List<InputClass>) input.DATA){
                boCodes.add(obj.IV_ZZORDER_ID);
                companyCodes.add(obj.IV_BUKRS);
            }

            /*
                if(String.valueOf( resMap.get('WAERS') ) != null) oppty.CurrencyIsoCode = String.valueOf( resMap.get('WAERS') );
            */


            List<Opportunity> opptyList = [SELECT Id, OpportunityCode__c, CompanyCode__c, cRevenueStartDate__c, cRevenueEndDate__c, Amount, CurrencyIsoCode
                                           FROM Opportunity 
                                            WHERE OpportunityCode__c in: boCodes AND CompanyCode__c in: companyCodes ];

            Map<String,String>       opptyMap = new Map<String,String>();
            Set<String>              opptyIds = new Set<String>();
            Map<String, Opportunity> oppMap   = new Map<String, Opportunity>();
            for(Opportunity obj : opptyList){

                opptyMap.put(obj.OpportunityCode__c + '_'+ obj.CompanyCode__c,obj.Id);
                opptyIds.add(obj.id);
                oppMap.put( obj.Id, obj);
            }


            //oppty activity 추가 매핑
            List<Opportunity_Activity__c> opptyActList = [SELECT Id, TransactionName__c, WhatId__c, StartDate__c, EndDate__c, Status__c 
                                                            FROM Opportunity_Activity__c 
                                                            WHERE WhatId__c in: opptyIds AND (TransactionName__c = 'XP51' OR TransactionName__c = 'XP32') ];
            Map<String,Object> opptyActMap = new Map<String,Object>();
            for(Opportunity_Activity__c opptyAct : opptyActList){
                //Opportunity Id + '_' + TransactionName
                opptyActMap.put(opptyAct.WhatId__c+'_'+opptyAct.TransactionName__c,opptyAct);
            }

            List<OpportunityCostPlan__c> planList = new List<OpportunityCostPlan__c>();
            List<Opportunity_Activity__c> actUpdateList = new List<Opportunity_Activity__c>();
            for(InputClass obj : (List<InputClass>) input.DATA){
                //External Key 정의 필요할수도?
                OpportunityCostPlan__c plan = new OpportunityCostPlan__c();
                plan.Name           = obj.IV_ZZORDER_ID + '_' + obj.IV_VERSION;
                plan.Opportunity__c = opptyMap.get(obj.IV_ZZORDER_ID + '_' + obj.IV_BUKRS);
                plan.Version__c     = obj.IV_VERSION;
                plan.IsConfirmed__c = obj.IV_GUBUN == 'X' ? true : false;

                Opportunity   upOpp = oppMap.get( plan.Opportunity__c);
                if( upOpp != null){

                    String strDate = Util_String.nvlStr( obj.IV_START_DATE);
                    String endDate = Util_String.nvlStr( obj.IV_FINISH_DATE);
                    String oppAmt  = Util_String.nvlStr( obj.IV_TOTAMT);
                    String currCode= Util_String.nvlStr( obj.IV_WAERS);

                    if( strDate != '') upOpp.cRevenueStartDate__c  = Util_String.convertStringDate( obj.IV_START_DATE);
                    if( endDate != '') upOpp.cRevenueEndDate__c    = Util_String.convertStringDate( obj.IV_FINISH_DATE);
                    if( oppAmt  != '') upOpp.Amount                = Util_String.nvlDec( obj.IV_TOTAMT);
                    if( currCode!= '') upOpp.CurrencyIsoCode       = obj.IV_WAERS;
                }

                planList.add(plan);
                
                
                /*
                Opportunity Activity Upsert 조건 -> obj.IV_GUBUN(승인여부)가 'X' 일때 Opportunity Activity 정보 Upsert ( Jitterbit 에서 넘어오는 'X' 값은 true 로 판단)
                IV_VERSION : S### => TransactionName : 수주 원가, XP51
                IV_VERSION : F### => TransactionName : 수주전략위원회 원가, XP32
                
                obj.IV_GUBUN(승인여부)가 'X' 일때
                1) Opportunity Activity Record가 없는 경우
                    - StartDate/EndDate를 Today()
                    - Status는 Completed.
                2) Opportunity Activity Record가 있는 경우
                    - Status가 Completed 일때 -> Continue (No change)
                    - Status가 completed 가 아닐때 -> status는 Completed, EndDate를 Today(), StartDate가 Null이면 Today(), Null이 아니면 Continue (No change.)
                */
                if(obj.IV_GUBUN == 'X'){
                    String tranName = '';
                    //Version이 S로 시작하면 XP52, F로 시작하면 XP32
                    if(obj.IV_VERSION.Left(1) == 'S') tranName = 'XP51';
                    if(obj.IV_VERSION.Left(1) == 'F') tranName = 'XP32';

                    //사전에 생성된 Opportunity Activity 가 있을때 -> opptyActMap key값 : Opportunity id + '_' + OpportunityActivity TransactionName
                    if(opptyActMap.containsKey( opptyMap.get(obj.IV_ZZORDER_ID + '_' + obj.IV_BUKRS) +'_'+ tranName ) ){
                        Opportunity_Activity__c opptyAct = (Opportunity_Activity__c) opptyActMap.get( opptyMap.get(obj.IV_ZZORDER_ID + '_' + obj.IV_BUKRS) +'_'+ tranName  );

                        if( obj.IV_VERSION.Left(1) == 'S'){

                            if(opptyAct.StartDate__c == null) opptyAct.StartDate__c = Date.today();
                            opptyAct.Status__c  = 'Completed';
                            opptyAct.EndDate__c = Date.today();
                            actUpdateList.add(opptyAct);
                        }


                        //OpportunityActivity 의 Status 가 Completed 가 아닐때 OpportunityActivity Update
                        // if(opptyAct.Status__c != 'Completed'){
                        //     opptyAct.Status__c = 'Completed';
                        //     //시작일자가 비어있으면 오늘날짜로 Update
                        //     if(opptyAct.StartDate__c == null) opptyAct.StartDate__c = Date.today();
                        //     opptyAct.EndDate__c = Date.today();
                        //     actUpdateList.add(opptyAct);
                        // }
                    }
                    else{ //사전에 생성된 Opportunity Activity 가 없을때
                        Opportunity_Activity__c opptyAct = new Opportunity_Activity__c();
                        opptyAct.WhatId__c = opptyMap.get(obj.IV_ZZORDER_ID + '_' + obj.IV_BUKRS);
                        opptyAct.TransactionName__c = tranName;
                        opptyAct.StartDate__c = Date.today();
                        opptyAct.EndDate__c = Date.today();
                        opptyAct.Status__c = 'Completed';
                        actUpdateList.add(opptyAct);
                    }
                }


            }
            //External Key를 추가로 정의하게 되면 upsert로 변경
            //Numbering 불필요 시 Version Type 필요 x
            // Key 조합 : BO Code + Company Code + Transaction Name + Version Type (S or F)
            upsert actUpdateList;
            insert planList;
            update oppMap.values();
            
          

            outHeader.TOTAL_COUNT    = planList.size();
            
            if( oppMap.size() == 0){
                outHeader.TOTAL_COUNT    = 0;
                outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
                outHeader.IV_GUBUN       = IF_Util.RESULT_STATUS_ERROR;    
                outHeader.EV_MESG        = 'NO DATA';
            }else {

                outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
                outHeader.IV_GUBUN       = IF_Util.RESULT_STATUS_SUCCESS;
                outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            }

        }catch(Exception e){

            DataBase.rollback( sp);
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.IV_GUBUN       = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }
        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        log.createLog( infLog);
        return outHeader;
    }
    global class OutputHeader{
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        public String EV_RESULT    = ''; // 처리 결과
        public String EV_MESG      = ''; // 처리 메세지
        public String IV_GUBUN     = ''; //승인여부
    }
    global class InputHeader{
        public List<InputClass> DATA;
    }
    global class InputClass{
        public String IV_ZZORDER_ID;
        public String IV_BUKRS;
        public String IV_VERSION;
        public String IV_GUBUN;


        public String IV_START_DATE;
        public String IV_FINISH_DATE;
        public String IV_TOTAMT;
        public String IV_TOTAMTK;
        public String IV_WAERS;
        public String IV_KWAERS;
        public String IV_ZZORDER_RATE;

    }
}