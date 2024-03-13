/**
 * @description       : Develop a batch that calculates the exchange rate and inserts the amount
 * @author            : vikrant.ks@samsung.com
 * @group             : 
 * @last modified on  : 2023-10-10
 * @last modified by  : vikrant.ks@samsung.com 
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-10-10   vikrant.ks@samsung.com   Initial Version(MySales 317)
**/
public class Batch_IF185ExchangeRateController implements Database.Batchable<sObject>, Database.Stateful {
    
    private static final String INTERFACE_ID = 'IF185ExchangeRateController'; //V 1.0- MYSALES: 317
    private static final String APEX_CLASS   = 'Batch_IF185ExchangeRateController'; 
    private static final String METHOD_NAME  = 'Execute';  
    private static String guId = IF_Util.generateGuid();

    public Map<String , Decimal> isoWithRateMap = new Map<String, Decimal>();
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', '', 0);
        ifStartLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + '#####-----##### ');
        
        List<DatedConversionRate> currencyTypeList = [SELECT IsoCode, ConversionRate FROM DatedConversionRate where StartDate <= TODAY AND NextStartDate > TODAY ORDER BY NextStartDate DESC];
        for(DatedConversionRate d : currencyTypeList) {
            isoWithRateMap.put(d.IsoCode , d.ConversionRate);
        }
        ifStartLog.createLog(batchStartLog);
        
        return Database.getQueryLocator('Select Id,Currency__c,TotalAmt__c,TotalAmtKRW__c,TotalAmtUSD__c,DiffAmt__c,DiffAmtKRW__c,DiffAmtUSD__c from OpportunityAmt__c where Currency__c != null'+
                                         + (Test.isRunningTest()?' LIMIT 200':'')
                                       );
    }
    
    public void execute(Database.BatchableContext bc,List<OpportunityAmt__c> oppAmt){
        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        try{
            if(oppAmt.size()>0){
                for(OpportunityAmt__c opp:oppAmt){  
                    
                    Decimal krwRate = 1;
                    if(opp.Currency__c != 'KRW'){ krwRate = (isoWithRateMap.get('KRW')/isoWithRateMap.get(opp.Currency__c)); }
                    Decimal usdRate = (isoWithRateMap.get('USD')/isoWithRateMap.get(opp.Currency__c));
                    
                    opp.TotalAmtKRW__c = (opp.TotalAmt__c*krwRate).setscale(2);
                    opp.TotalAmtUSD__c = (opp.TotalAmt__c*usdRate).setscale(2);
                    opp.DiffAmtKRW__c  = (opp.DiffAmt__c*krwRate).setscale(2);
                    opp.DiffAmtUSD__c  = (opp.DiffAmt__c*usdRate).setscale(2);
                }
            }
            update oppAmt;
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', '', 0);
            ifExcutelog.createLog(batchExcuteLog);
        }catch(Exception e){
             batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, e.getMessage(), 0, 0,e);
             ifExcutelog.createLog(batchExcuteLog);
        } 
    }
    
    public void finish(Database.BatchableContext bc){
        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);
        ifFinishLog.addLog('#####-----##### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + '#####-----##### ');
        ifFinishLog.createLog(batchFinishLog);
    }
}