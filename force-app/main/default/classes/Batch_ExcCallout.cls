/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-02-26
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-02-26   kilhwan.an@partner.samsung.com   Initial Version
**/
public class Batch_ExcCallout implements DataBase.Batchable<Object>, DataBase.Stateful, DataBase.AllowsCallouts{
    
     public String  INTERFACE_ID  = 'IF-093';
     public String  JSON_DATA     = '{"IV_ZZORDER_ID":"SDS-21008990","IV_WFOBJECT":"ZCRM000160","IV_STATUS":"CC","IV_PROCESS_TYPE":"ZP82","IV_OBJECTKEY":"SDSSFDC2021022514282816142309086","IV_BUKRS":"T100","CT_SOL":[{"ZZSOLUTION":"30000135","ZZSERVICE_CLASS":"20000026","ZZSALES_CELL_NAM":"T100-12436","ZZORDER_ID":"SDS-21008990","ZZDEVELOP_CELL_N":"T100-10242","ZZBUKRS_H":"T100","SOLUTION_OWNER":null,"SOLUTION_AMT_LOCAL":"343155000.00","SOLUTION_AMT":"343155000.00","NUMBER_INT":"20","GUID":"a0k1s000000nlIZAAY","DESCRIPTION":"Price simulation 결재테스트_2/18","CURR_LOCAL":"KRW","CURR":"KRW","AERDAT":"2021.02.25"},{"ZZSOLUTION":"32000072","ZZSERVICE_CLASS":"22000006","ZZSALES_CELL_NAM":"T100-12436","ZZORDER_ID":"SDS-21008990","ZZDEVELOP_CELL_N":"T100-12296","ZZBUKRS_H":"T100","SOLUTION_OWNER":null,"SOLUTION_AMT_LOCAL":"333155000.00","SOLUTION_AMT":"333155000.00","NUMBER_INT":"30","GUID":"a0k1s000000nlIaAAI","DESCRIPTION":"Price simulation 결재테스트_2/18","CURR_LOCAL":"KRW","CURR":"KRW","AERDAT":"2021.02.25"},{"ZZSOLUTION":"32000072","ZZSERVICE_CLASS":"22000006","ZZSALES_CELL_NAM":"T100-12314","ZZORDER_ID":"SDS-21008990","ZZDEVELOP_CELL_N":"T100-12296","ZZBUKRS_H":"T100","SOLUTION_OWNER":null,"SOLUTION_AMT_LOCAL":"333155000.00","SOLUTION_AMT":"333155000.00","NUMBER_INT":"40","GUID":"a0k1s000000nlIbAAI","DESCRIPTION":"Price simulation 결재테스트_2/18","CURR_LOCAL":"KRW","CURR":"KRW","AERDAT":"2021.02.25"},{"ZZSOLUTION":"30000101","ZZSERVICE_CLASS":"20000029","ZZSALES_CELL_NAM":"T100-11788","ZZORDER_ID":"SDS-21008990","ZZDEVELOP_CELL_N":"T100-10490","ZZBUKRS_H":"T100","SOLUTION_OWNER":null,"SOLUTION_AMT_LOCAL":"10000000.00","SOLUTION_AMT":"10000000.00","NUMBER_INT":"50","GUID":"a0k1s000000nmaPAAQ","DESCRIPTION":"Price simulation 결재테스트_2/18","CURR_LOCAL":"KRW","CURR":"KRW","AERDAT":"2021.02.25"}]}';
    //public String  INTERFACE_ID  = 'IF-090';
    //public String  JSON_DATA     = '{"IV_GUBUN":"1","IV_SABUN":"00016241"}';
    public Integer BATCH_COUNT   = 50;
    public Integer SUCCESS_COUNT = 0;
    public Integer FAIL_COUNT    = 0;
    private String RECV_DATA     = '';
    private Integer idx          = 0;

    /////이메일 정보 //////
    List<String>   TO_LIST       = new List<String> { 'kilhwan.an@partner.samsung.com'};

    public List<Object> start( Database.BatchableContext BC){

        List<Object> dataList = new List<Object>();
        for( Integer i = 0; i < BATCH_COUNT; i ++){

            dataList.add( i);
        }

        return dataList;
    }

    public void execute( Database.BatchableContext BC, List<Object> objList){

        try{

            Integer rowCnt = objList.size();
            for( Integer i = 0; i < rowCnt; i ++){
                
                IF_Callout          ifCallout = new IF_Callout( INTERFACE_ID);
                Map<String, Object> result    = ifCallout.httpCallout( JSON_DATA, '');

                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');
                String dBody      = hRes.getBody();
                String headerData = hRes.getStatusCode() + '';

                if( Util_String.nvlStr( dBody) != ''){

                    RECV_DATA += ( ++idx ) + ',' + headerData +  ',SUCC:' + ( ++ SUCCESS_COUNT ) + '\n';
                }else {

                    RECV_DATA += ( ++idx) + ',' + headerData + ',FAIL:' + ( ++ FAIL_COUNT ) + '\n';
                }
            }
        }catch( Exception e){

            RECV_DATA += ( ++idx) + ',' + '00' + ',FAIL:' + ( ++ FAIL_COUNT) + '\n';
        }
        

    }

    public void finish( DataBase.BatchableContext BC){

        Messaging.SingleEmailMessage sEmail  = new Messaging.SingleEmailMessage();
        sEmail.setToAddresses   ( TO_LIST);
        sEmail.setSubject       ( INTERFACE_ID + ' 테스트');
        sEmail.setPlainTextBody ( RECV_DATA);
        // sEmail.setWhatId        ( UserInfo.getUserId());
        // sEmail.setSaveAsActivity( false);
        // sEmail.setTargetObjectId( UserInfo.getUserId());

        Messaging.Email[] emails  = new Messaging.Email[]{ sEmail};
        List<Messaging.SendEmailResult> seList = Messaging.sendEmail( emails);
        System.debug( seList+'::::::::::::::seList');
    }
}