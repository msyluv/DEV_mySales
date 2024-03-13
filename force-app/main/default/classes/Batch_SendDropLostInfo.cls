/**
 * @author            : hyunhak.roh@dkbmc.com
 * @description       : [IF-155] BO_실주중도종결_정보전송
 * 		              : [schedule execution code] System.Schedule('Batch_SendDropLostInfo', '0 0 * * * ? *', new Batch_SendDropLostInfo());	// 사용안함
 * @last modified on  : 2023-03-24
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2022-03-28   hyunhak.roh@dkbmc.com  Initial Version
 * 1.1	 2022-05-02   hyunhak.roh@dkbmc.com  Drop/Lost(중도종결/실주) '등록 취소' 추가
 * 1.2	 2023-03-24   anish.jain@partner.samsung.com  To add new fields My Sales -157 
**/
public class Batch_SendDropLostInfo implements Database.Stateful, Database.Batchable<sObject>, Database.AllowsCallouts{
    private static final String INTERFACE_ID = 'IF-155';
    private static final String APEX_CLASS   = 'Batch_SendDropLostInfo';
    private static final String METHOD_NAME  = 'sendDropLostInfo';
    
    //전역변수
    //private List<Id> listSource = new List<Id>();
    //TODO listSource => setBOActId
    private Set<Id> setBOActId = new Set<Id>();
    
    List<IF_Log.InterfaceLog> ifLogList = new List<IF_Log.InterfaceLog>();

    private
        static Integer errorCount = 0;
    //TODO : 호출시에 단건/복수건 일수 있음.
    //
    //Database.executeBatch(new Batch_SendDropLostInfo(Set<Id> setBOActId), 200);  
    //
    public Batch_SendDropLostInfo(Set<Id> setBOActId){
        System.debug('========== IF-155 ==========');
        System.debug('========== Batch_SendDropLostInfo ==========');
        this.setBOActId = setBOActId;
        System.debug('########## setBOActId ########## ' + this.setBOActId.size());
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        System.debug('========== start ==========');
        //Datetime deadline = Datetime.now().addHours(-1); 
        String QUERY_STRING = '	SELECT Id										' +
                            '	     , IsDeleted                                ' +
                            '		 , Name                                     ' +
                            '		 , CurrencyIsoCode                          ' +
                            '		 , WhatId__c                                ' +
                            '		 , Description__c                           ' +
                            '		 , DueDate__c                               ' +
                            '		 , Index__c                                 ' +
                            '		 , OpptyRecordType__c                       ' +
                            '		 , Status__c                                ' +
                            '		 , StartDate__c                             ' +
                            '		 , EndDate__c                               ' +
                            '		 , LostType__c                              ' +
            				//'		 , toLabel(LostType__c) LostType_Name		' +
                            //'		 , SalesTeam__c                             ' +
                            //'		 , SalesDivision__c                         ' +
                            //'		 , SalesDepartment__c                       ' +
                            //'		 , CompanyCode__c                           ' +
                            '		 , TransactionName__c                       ' +
                            '		 , LostReason__c                            ' +
            				'		 , toLabel(LostReason__c) LostReason_Name	' +
                            '		 , OpportunityStage__c                      ' +
            				'		 , WhatId__r.OpportunityCode__c				' +    // Master-Detail 구조의 Object Id 값이나 Lookup관계인 경우, WhatId__r 사용가능   
                            '        , WhatId__r.CompanyCode__c                 ' +    //Added by Anish - v 1.2
                            '	  FROM Opportunity_Activity__c                  ' +
                            '	 WHERE TransactionName__c IN (\'ZPZ1\',\'ZPZ2\')' +
                            '	   AND Status__c = \'Completed\'                ' +    //Modified by Anish - v 1.2
            				'      AND Id IN :setBOActId       			';
                           
        System.debug('QUERY_STRING : ' + QUERY_STRING);
        
        return Database.getQueryLocator(QUERY_STRING);
    }
    
    public void execute(Database.BatchableContext bc, List<Opportunity_Activity__c> objList) {
        System.debug('========== execute ==========');
        System.debug('Query Result Size : ' + objList.size());
        System.debug('Query Result objList get : ' + objList.get(0));

        //BO_CODE 조회
        //Code 별 고정된 한글 라벨을 송신.
        //Code 별 고정된 영문 라벨을 송신
        Map<String, String> mapLostTypeCodeToUS = new Map<String, String>{'Z06'=>'LOST', 'Z07'=>'DROP'};
        
        Map<String,Object> resMap = new Map<String,Object>();
        List<BO_CLOSE_INFO> boCloseInfoList = new List<BO_CLOSE_INFO>();
        try{
            
            //
            Integer idx = 0;
            
            for(Opportunity_Activity__c oppyActy : objList){
                System.debug('oppyActy : ' + oppyActy);
                
                //
                if(oppyActy != null) {
                    BO_CLOSE_INFO boCloseInfo = new BO_CLOSE_INFO();
                    //boCloseInfo.BO_CODE 	= objList.get(idx).get('WhatId__r.OpportunityCode__c').toString();
                    boCloseInfo.BO_CODE 	= Util_String.nvlStr(oppyActy.WhatId__r.OpportunityCode__c);
                    //boCloseInfo.CLOSE_STAGE	= objList.get(idx).get('LostType_Name').toString().toUpperCase();
                    boCloseInfo.CLOSE_STAGE	= mapLostTypeCodeToUS.get(oppyActy.LostType__c);
                    boCloseInfo.CLOSE_DATE	= (Util_String.convertDateTimeString(oppyActy.EndDate__c)).left(8);
                    //boCloseInfo.CLOSE_REASON= objList.get(idx).get('LostReason_Name').toString();
                    boCloseInfo.CLOSE_REASON= oppyActy.LostReason__c;     //Modified by Anish - v 1.2
                    boCloseInfo.DESCRIPTION	= oppyActy.Description__c;
                    boCloseInfo.BO_ID = Util_String.nvlStr(oppyActy.WhatId__c);   //Added by Anish - v 1.2
                    boCloseInfo.COMPANY_CODE = Util_String.nvlStr(oppyActy.WhatId__r.CompanyCode__c);   //Added by Anish - v 1.2
                    boCloseInfoList.add(boCloseInfo);
                }
                
                idx++;
            }
            
            System.debug('boCloseInfoList.size() : ' + boCloseInfoList.size());
            System.debug('boCloseInfoList : ' + boCloseInfoList);
            if(!boCloseInfoList.isEmpty()) resMap = sendDropLostInfo(boCloseInfoList);
            IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)resMap.get('IF_Log');
            ifLogList.add(ifLog);
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    public void finish(Database.BatchableContext bc) { 
        System.debug('========== finish ==========');
        try{
            IF_Log log = new IF_Log();
            for(IF_Log.InterfaceLog ifLog : ifLogList){
                system.debug('### Batch_SendDropLostInfo :: finish = ' + ifLog);
                log.createLog(ifLog);
            }
        }catch(Exception e){
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
    }
    
    @AuraEnabled    
    public static Map<String,Object> sendDropLostInfo(List<BO_CLOSE_INFO> boCloseInfoList){
        System.debug('sendDropLostInfo boCloseInfoList : ' + boCloseInfoList);
        IF_Callout call = new IF_Callout(INTERFACE_ID);
        String guId = IF_Util.generateGuid();
        
        Map<String,Object> resMap = new Map<String,Object>();
        Map<String,Object> returnMap = new Map<String,Object>{
            'result' => null,
            'IF_Log' => null,
            'StatusCode' => null
        };
                
        try{
            InputClass input = new InputClass();
            input.BO_CLOSE_INFO = boCloseInfoList;
            String jsonBody = JSON.serialize(input);
            resMap = call.httpCallout(jsonBody, '');
            System.debug('request : '+resMap.get('Request'));
            System.debug('response : '+resMap.get('Response'));
            
            HttpResponse res = (HttpResponse)resMap.get('HttpResponse');
            if(res.getStatusCode() == 200){
                Map<String, Object> bodyMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                if(bodyMap.get('RESULT') != null && bodyMap.get('RESULT') == 'F'){
                    if(errorCount < 2){
                        errorCount += 1;
                        sendDropLostInfo(boCloseInfoList);
                    }
                }
                //IF 결과
                returnMap.put('StatusCode',res.getStatusCode());
                returnMap.put('Response', res.getBody() );
            }
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response'))));
        }catch(Exception e){
            returnMap.put('IF_Log', new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('HttpResponse')), e));
            System.debug('Error : ' + e.getMessage());
            System.debug('Error StackTrace : ' + e.getStackTraceString());
            System.debug('Error Line : ' + e.getLineNumber());
        }
        return returnMap;
    }
    
    public class InputClass{
        @AuraEnabled
        public List<BO_CLOSE_INFO> BO_CLOSE_INFO; 
    }

    public class BO_CLOSE_INFO{
        @AuraEnabled
        public String BO_CODE; 		// 사업기회 코드 -> OpportunityCode__c
        @AuraEnabled
        public String CLOSE_STAGE; 	// 사업종결 상태 -> LostType__c
        @AuraEnabled
        public String CLOSE_DATE; 	// 종결 날짜(실주일/중도종결일)-> EndDate__c
        @AuraEnabled
        public String CLOSE_REASON;	// 종결 사유(Critical 요인)	-> LostReason__c
        @AuraEnabled
        public String DESCRIPTION; 	// 상세 설명 -> Description__c
        //Start- Added by Anish - v 1.2
        @AuraEnabled
        public String BO_ID;
        @AuraEnabled
        public String COMPANY_CODE;
        //End- Added by Anish - v 1.2
    }
}