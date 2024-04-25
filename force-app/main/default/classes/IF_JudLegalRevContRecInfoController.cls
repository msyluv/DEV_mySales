/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 01-04-2024
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   12-03-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.0.1 12-14-2020   raegganja@partner.samsung.com      class name change
 * 1.0.2 01-13-2021   soohong0.kim@partner.samsung.com   setActivity method add
 * 1.1   01-19-2024   divyam.gupta@samsung.com           Mysales-412 fiexd Iflog creation logic.
 * 1.2   28-03-2024   vikrant.ks@samsung.com             Add DEL_YN field in request Message and if DEL_YN = 'Y' comes then set change LegalReviewNo__c to null and change Legal Review Activity status to N/A.(MySales-484)
**/

//XP52 - 법무검토 완료
//XP57 - 계약서 입고 완료
@RestResource(urlMapping = '/IF128/*')
global class IF_JudLegalRevContRecInfoController {
    private static final String INTERFACE_ID = 'IF-128';
    private static final String APEX_CLASS   = 'IF_JudLegalRevContRecInfoController';
    private static final String METHOD_NAME  = 'saveData';

    @HttpPost
    global static OutputHeader saveData() {
        String guId = IF_Util.generateGuid();
        IF_Log.InterfaceLog infLog;
        IF_Log 		log 	= new IF_Log();
        RestRequest req 	= RestContext.request;
        Blob 		reqBody = req.requestBody;
        OutputHeader outHeader = new OutputHeader();
        SavePoint   sp      = DataBase.setSavePoint();
        try{
        
            System.debug( 'reqBody:_d_::' + reqBody.toString());
            InputHeader inHeader = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
            
            System.debug( 'inHeader:::' + inHeader);
            InputClass  input 	 = inHeader.DATA[0];
            System.debug( 'input:::' + input);
            
            List<Opportunity> oppList = [SELECT id, LegalReviewNo__c from Opportunity where OpportunityCode__c =: input.ORDER_ID and EPCompanyCode__c  =: input.COMPANY];
        
        		System.debug('oppList::::' + oppList);
            if( oppList.size() < 1) {
                
                outHeader.RETURN_CODE = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.RETURN_TEXT = 'No Data';
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }
        	Opportunity opp = oppList.get( 0);
            opp.LegalReviewNo__c = input.CONTRACT_NO;
            
            List<Opportunity_Activity__c> oppActXp52List = [select id, TransactionName__c, Status__c, DueDate__c from Opportunity_Activity__c where WhatId__c =:opp.id and TransactionName__c = 'XP52' order by CreatedDate desc limit 1] ;
            List<Opportunity_Activity__c> oppActXp57List = [select id, TransactionName__c, Status__c, DueDate__c from Opportunity_Activity__c where WhatId__c =:opp.id and TransactionName__c = 'XP57' order by CreatedDate desc limit 1] ;
            List<Opportunity_Activity__c> upsertActList = new List<Opportunity_Activity__c>();

            //XP52 Dataset (기존의 OpportunityActivity가 있으면 Status 만 변경 후 Return, 없으면 Status 및 데이터 매핑 후 Return
            upsertActList.addAll(setActivity(opp.id,'XP52',oppActXp52List,input));
            //XP57 Dataset (기존의 OpportunityActivity가 있으면 Status 만 변경 후 Return, 없으면 Status 및 데이터 매핑 후 Return
            upsertActList.addAll(setActivity(opp.id,'XP57',oppActXp57List,input));
            
            //V1.2 Start
            if(input.DEL_YN == 'Y'){
                opp.LegalReviewNo__c = Null;
                if(input.CONTRACT_STATUS == '00401' || input.CONTRACT_STATUS == '00404' || input.CONTRACT_STATUS == '00410' || input.CONTRACT_STATUS == '00417'){
                    for(Opportunity_Activity__c obj:upsertActList){
                        if(obj.TransactionName__c == 'XP52'){
                            obj.Status__c = 'N/A';
                        }
                    }
                }else{
                    if(oppActXp52List.size() > 0){
                        oppActXp52List[0].Status__c = 'N/A';
                        update oppActXp52List;
                    }
                }
            }
            //V1.2 End

            update opp;
            upsert upsertActList;

            outHeader.RETURN_CODE  = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.RETURN_TEXT  = IF_Util.RESULT_MESSAGE_SUCCESS;
            //V 1.1
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
            log.createLog( infLog);

        }catch(Exception e){

             DataBase.rollback( sp);
            outHeader.RETURN_CODE  = IF_Util.RESULT_STATUS_ERROR;
            outHeader.RETURN_TEXT  = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog( infLog);
        }

        
                return outHeader;
    }

    public static List<Opportunity_Activity__c> setActivity(String opptyId, String TransactionName, List<Opportunity_Activity__c> actList, InputClass input){
        List<Opportunity_Activity__c> updateList = new List<Opportunity_Activity__c>();

        if(actList.size()>0){// 기존에 생성된 Opportunity_Activity__c 가 있을때 -> update
            for(Opportunity_Activity__c obj : actList){
                if(TransactionName.equals('XP52')){
                    if( String.isNotBlank(obj.TransactionName__c) && obj.TransactionName__c.equals('XP52') && String.isNotBlank(input.CONTRACT_STATUS)){
                        if( input.CONTRACT_STATUS.equals('00401') ){
                            obj.Status__c = 'In Progress';
                            obj.EndDate__c = Date.today();
                            updateList.add(obj);
                        }
                        else if( input.CONTRACT_STATUS.equals('00417') || input.CONTRACT_STATUS.equals('00404') || input.CONTRACT_STATUS.equals('00410') ){
                            obj.Status__c = 'Completed';
                            obj.EndDate__c = Date.today();
                            updateList.add(obj);
                        }
                    }
                }
                else if(TransactionName.equals('XP57')){
                    if( String.isNotBlank(obj.TransactionName__c) && obj.TransactionName__c.equals('XP57') && String.isNotBlank(input.CONTRACT_STATUS) ){
                        if( input.CONTRACT_STATUS.equals('00420') ){
                            obj.Status__c = 'In Progress';
                            obj.EndDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                            updateList.add(obj);
                        }
                        else if( input.CONTRACT_STATUS.equals('00407') || input.CONTRACT_STATUS.equals('00405') ){
                            obj.Status__c = 'Completed';
                            obj.EndDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                            //obj.DueDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                            updateList.add(obj);
                        }
                    }
                }
            }
        }
        else{ // 기존에 생성된 Opportunity_Activity__c 가 없을때 -> insert
            if(TransactionName.equals('XP52') && String.isNotBlank(input.CONTRACT_STATUS)){
                Opportunity_Activity__c obj = new Opportunity_Activity__c();                
                if( input.CONTRACT_STATUS.equals('00401') ){
                    obj.TransactionName__c = TransactionName;
                    obj.WhatId__c = opptyId;
                    obj.StartDate__c = Date.today();
                    obj.EndDate__c = Date.today();
                    obj.Status__c = 'In Progress';
                    obj.ExtId__c = opptyId+TransactionName;
                    updateList.add(obj);
                }
                else if( input.CONTRACT_STATUS.equals('00417') || input.CONTRACT_STATUS.equals('00404') || input.CONTRACT_STATUS.equals('00410') ){
                    obj.TransactionName__c = TransactionName;
                    obj.WhatId__c = opptyId;
                    obj.StartDate__c = Date.today();
                    obj.EndDate__c = Date.today();
                    obj.Status__c = 'Completed';
                    obj.ExtId__c = opptyId+TransactionName;
                    updateList.add(obj);
                }
            }
            else if(TransactionName.equals('XP57') && String.isNotBlank(input.CONTRACT_STATUS)){
                Opportunity_Activity__c obj = new Opportunity_Activity__c();
                if( input.CONTRACT_STATUS.equals('00420') ){
                    obj.TransactionName__c = TransactionName;
                    obj.WhatId__c = opptyId;
                    obj.StartDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                    obj.EndDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                    obj.Status__c = 'In Progress';
                    obj.ExtId__c = opptyId+TransactionName;
                    updateList.add(obj);
                }
                else if( input.CONTRACT_STATUS.equals('00407') || input.CONTRACT_STATUS.equals('00405') ){
                    obj.TransactionName__c = TransactionName;
                    obj.WhatId__c = opptyId;
                    obj.StartDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                    obj.EndDate__c = Util_String.convertStringDate(input.CONFIRM_DATE);
                    obj.Status__c = 'Completed';
                    obj.ExtId__c = opptyId+TransactionName;
                    updateList.add(obj);
                }
            }
        }
        return updateList;
    }

    // 전달 값: JitterBit
    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String RETURN_CODE = ''; // 처리 결과
        @AuraEnabled
        public String RETURN_TEXT = ''; // 처리 메세지
    }

    // 받은 값 : 입력정보
    public class InputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT;
        @AuraEnabled
        public Integer PAGE_COUNT;
        @AuraEnabled
        public Integer PAGE_NUM;  
        @AuraEnabled
        public List<InputClass> DATA;
    }

    public class InputClass{

        @AuraEnabled
        public String COMPANY;
        @AuraEnabled
        public String CONTRACT_TYPE;
        @AuraEnabled
        public String ORDER_ID;
        @AuraEnabled
        public String CONTRACT_NO;
        @AuraEnabled
        public String CONTRACT_STATUS;
        @AuraEnabled
        public String CONFIRM_DATE;
        @AuraEnabled
        public String DEL_YN;//V1.2
    }
}