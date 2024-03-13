/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-08-01
 * @last modified by  : atul.k1@samsung.com
 * Modifications Log 
 * Ver   Date         Author                            Modification
 * 1.0   2020-11-12   kilhwan.an@partner.samsung.com    Initial Version
 * 1.1   2021-01-21   ghkil@partner.samsung.com         Batch 처리에 대한 Log 처리 수정 (Start, Excute, End 각각 나눠 기록), Start의 "Start did not return a valid iterable object." Exception 방지를 위히 Garbage값을 등록하여 처리 --> Gabage 처리 제거됨
 * 1.2   2021-02-25   ghkil@partner.samsung.com         Batch Log 생성 시 ApexMethod 추가 (JobId 제거)
 * 1.3   2023-08-01   atul.k1@samsung.com               MYSALES-270(Calling Batch class in finish method)
**/
public class Batch_EccRegCurrencyController implements DataBase.Batchable<Batch_EccRegCurrencyController.ReceiveClass>, DataBase.Stateful, DataBase.AllowsCallouts, Schedulable{

    private final String INTERFACE_ID    = 'IF-017';
    private final String SF_INTERFACE_ID = 'SF-CURRENCY';
    private final String APEX_CLASS      = 'Batch_EccRegCurrencyController';
    private final String METHOD_NAME     = 'Batch';
    private String       baseDate        = null;
    public List<String>  currDateList    = null;

    private final Boolean DEBUG_FLAG = true;

    String guId = IF_Util.generateGuid();

    public List<ReceiveClass> start(DataBase.BatchableContext BC){

        IF_Log ifStartLog = new IF_Log();
        IF_Log.BatchLog batchStartLog;
        List<String> startErrorMsgList = new List<String>();

        ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 시작' + ' ####################');

        // 환율 날짜
        Date currDate = Date.today();
        if( currDateList != null && currDateList.size() > 0){

            // 현재 달의 분기를 구함
            currDateList.sort();
            String strCurDt = currDateList.get( 0).replaceAll( '-', '');
            Integer iYear   = Integer.valueOf( strCurDt.substring( 0, 4));
            Integer iMonth  = Integer.valueOf( strCurDt.substring( 4, 6));
            currDate        = Date.newInstance( iYear, iMonth, 1);
        }

        // 현재 분기의 첫번째 월을 확인 : ex>  2020-02-03 => 2020-01-01
        Map<Date, Date> quartMap   = IF_Util.getQuarterStartDate( new Set<Date>{ currDate});
        Date            quartaDate = quartMap.get( currDate);
        baseDate                   = quartaDate.year() + '-' + ( quartaDate.month() + '').leftPad( 2, '0') + '-' + ( quartaDate.day() + '').leftPad( 2, '0');
        
        // 전일자 기준 날짜
        String schDate = Util_String.convertDateString( quartaDate.addDays( -1));



        // currDate = '20201227';
        // 호출할 환율 파라미터
        Map<String, String> paramMap = new Map<String, String>{
             'KURST' => 'M'      // 통화 선택 코드
            ,'FCURR' => 'USD'    // 소스 통화
            ,'TCURR' => null     // 대상 통화 : null인경우 전체 통화
            ,'GDATU' => schDate  // 환율 효력 시작일 
        };

        System.debug( 'baseDate::::' + baseDate);
        System.debug( 'paramMap::::' + paramMap);

        List<ReceiveClass> currencyList = new List<ReceiveClass>();        
        String jsonBody;

        String reqMsg = '';

        try {
            
            // Rest Api 호출
            IF_Callout call           = new IF_Callout(INTERFACE_ID);
            jsonBody                  = JSON.serialize(paramMap);
            Map<String,Object> resMap = call.httpCallout(jsonBody, '');

            // 데이터 수신 확인
            String statusCode = resMap.get('StatusCode') + '';
            reqMsg = String.valueOf(resMap.get('Request'));
        
            if( statusCode == '200'){

                String resMsg = resMap.get('Response') + '';
                System.debug('resMsg::::' + resMsg);
                if( resMsg != '' && resMsg != 'null'){
                 
                    InputHeader inputClass = (InputHeader)JSON.deserialize(resMsg, InputHeader.class);
                    currencyList = inputClass.row;
                }
            }

            if(currencyList != null) {
                if (DEBUG_FLAG) ifStartLog.addLog('Batch 처리 대상 조회 : ' + currencyList.size());
                system.debug('Batch 처리 대상 조회 : ' + currencyList.size());
            } else {

                throw new CurrencyException( 'No Data');
            }

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', reqMsg, 0);
            ifStartLog.addLog( JSON.serialize( currencyList));
            ifStartLog.createLog(batchStartLog);

        }catch(Exception e){

            batchStartLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Start', reqMsg, 0, 0, e);
            startErrorMsgList.add('Batch exception : ' + e.getMessage());

            ifStartLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Start:' + BC.getJobId() + ') 종료' + ' ####################');

            ifStartLog.createLog(batchStartLog);            
        }
        return currencyList;
    }

    public void execute( DataBase.BatchableContext BC, List<ReceiveClass> scopeList){

        IF_Log ifExcuteLog = new IF_Log();
        IF_Log.BatchLog batchExcuteLog;
        List<String> excuteErrorMsgList = new List<String>();

        ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 시작' + ' ####################');

        String reqMsg = '';
        String resMsg = '';
                
        try{

            // Garbage값 제거
            // if (scopeList.size() == 1) {

            //     if (scopeList[0].KURST == '000') {
            //         scopeList.clear();
            //     }
            // }

            // 적용대상 통화 확인
            List<CurrencyType> currTypeList =[
                SELECT  Id
                      , IsoCode 
                FROM    CurrencyType
                WHERE   isActive = true
            ];

            Set<String> currTypeSet = new Set<String>();
            for( CurrencyType currType : currTypeList){
                currTypeSet.add( currType.IsoCode);
            }

            // 환율 데이터 처리
            Map<String, Object> restMap     = new Map<String, Object>();
            List<Object>        recordList  = new List<Object>();
            for(ReceiveClass rvClass : scopeList){
            
                // 환율이 존재 하지 않는 경우 skip
                if( !currTypeSet.contains( rvClass.TCURR)) continue;

                // 환율 계산 기준 UNIT PER USD
                // UKURS(환율), FFACT(Ratio for the "From" Currency Units), TFACT (Ratio for the "To" Currency Units)
                // UKURS이 양수 => TFACT / FFACT * UKURS
                // UKURS이 음수 => 1/[ABS(UKURS)*FFACT/TFACT]

                String  ukursSy= rvClass.UKURS.left( 1);
                Decimal ukurs  = Util_String.nvlDec( rvClass.UKURS);
                Decimal ffact  = Util_String.nvlDec( rvClass.FFACT);
                Decimal tfact  = Util_String.nvlDec( rvClass.TFACT);
                // Decimal rate   = ffact / tfact;
                Decimal rate = 0;
                if( ukursSy == '/' || ukursSy == '-') {
                    ukurs  = Util_String.nvlDec( rvClass.UKURS.substringAfter( ukursSy));

                    rate = ffact / tfact;
                    rate = 1 / ( ukurs * rate);
                }
                else {
                    rate = tfact / ffact;
                    rate = rate * ukurs;
                }                    

                // 환율 데이터 포멧 형식
                // System.debug(':::rvClass.GDATU::' + rvClass.GDATU);
                // String baseDate = rvClass.GDATU.left( 4) + '-' + rvClass.GDATU.mid( 4, 2) + '-' + rvClass.GDATU.right( 2);
                // System.debug( 'baseDate:::' + baseDate);
                Map<String, Object> attrMap = new Map<String, Object>();
                attrMap.put('type'       , 'DatedConversionRate');
                attrMap.put('referenceId', 'referenceID' + rvClass.TCURR);

                Map<String, Object> isoMap = new Map<String, Object>();
                isoMap.put('IsoCode'       , rvClass.TCURR);   // 통화코드
                isoMap.put('ConversionRate', rate);            // 환율
                isoMap.put('StartDate'     , baseDate);        // 일자
//                isoMap.put('StartDate'     , '2013-11-25');    // 일자
                isoMap.put('attributes'    , attrMap);         // 속성
                recordList.add(isoMap);
            }

            restMap.put('records', recordList);
            String jsonData = JSON.serialize( restMap);

            System.debug('jsonData:::' + jsonData);

            Map<String, Object> result = new Map<String,Object>();

            IF_Callout call = new IF_Callout( SF_INTERFACE_ID);
            result = call.httpCallout(jsonData, '');

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            ifExcuteLog.addLog('Processed Data :' + jsonData);
            
            // 로그 남기기
            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, recordList.size());
            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');

            ifExcutelog.createLog(batchExcuteLog);            
        }catch( Exception e){

            ifExcuteLog.addLog( 'Exception : ' + e.getStackTraceString());
            excuteErrorMsgList.add('Batch exception : ' + e.getMessage());

            batchExcuteLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Excute', reqMsg, 0, 0, e);

            ifExcuteLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Excute:' + BC.getJobId() + ') 종료' + ' ####################');            

            ifExcutelog.createLog(batchExcuteLog);            
        }
    }

    public void finish( DataBase.BatchableContext BC){

        // 다른 일짜 환율 데이터가 존재 한다면
        if( currDateList != null && currDateList.size() > 1){

            currDateList.remove(0);
            Batch_EccRegCurrencyController batch = new Batch_EccRegCurrencyController();
            batch.currDateList = currDateList;
            DataBase.executeBatch( batch, 2000);
        }

        IF_Log ifFinishLog = new IF_Log();
        IF_Log.BatchLog batchFinishLog;
        List<String> finishErrorMsgList = new List<String>();

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 시작' + ' ####################');

        batchFinishLog = new IF_Log.BatchLog(INTERFACE_ID, guId, APEX_CLASS, 'Finish', '', 0);

        ifFinishLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + '(Finish:' + BC.getJobId() + ') 종료' + ' ####################');

        ifFinishLog.createLog(batchFinishLog);
        //V1.3
        //MYSALES-270(To Update the CurrencyType ConversionRate)
        Batch_EccRegCurrencyTypeController batchJob = new Batch_EccRegCurrencyTypeController();
        Id batchJobId = Database.executeBatch(batchJob, 100);
                
    }

    // 스케줄 호출
    public void execute( SchedulableContext SC){

        DataBase.executeBatch( new Batch_EccRegCurrencyController(), 2000);
    }

    public class InputHeader{

        @AuraEnabled
        public String RTN_CNT;
        @AuraEnabled
        public List<ReceiveClass> row;
    }

    // 환율인터페이스
    public class ReceiveClass{

        @AuraEnabled
        public String KURST; //환율 유형
        @AuraEnabled
        public String FCURR; //소스 통화
        @AuraEnabled
        public String TCURR; //대상 통화
        @AuraEnabled
        public String GDATU; //환율 효력 시작일 
        @AuraEnabled
        public String UKURS; //환율
        @AuraEnabled
        public String FFACT; //Ratio for the "From" Currency Units
        @AuraEnabled
        public String TFACT; //Ratio for the "To" Currency Units
    }

    public class CurrencyException extends Exception {}
}