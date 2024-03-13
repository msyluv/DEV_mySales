/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-07-23
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-01-05   kilhwan.an@partner.samsung.com   Initial Version
 * 1.1   2021-07-23   seonju.jin@dkbmc.com             shedule추가
 * ex) DataBase.executeBatch( new Batch_DeleteApexLogRt(), 100)
**/

public with sharing class Batch_DeleteApexLogRt implements DataBase.Batchable<SObject>, DataBase.Stateful, DataBase.AllowsCallouts{

    Set<Id> recordIdSet;
    public Batch_DeleteApexLogRt(){}

    public DataBase.QueryLocator start( DataBase.BatchableContext BC){
        // Datetime StartDatetime = System.now();
        // startdateTime.addDays(-2);
        //String queryStr = 'SELECT Id FROM Apexlog WHERE StartTime <=: startdateTime';
        String queryStr = 'SELECT Id FROM Apexlog ORDER BY LogLength DESC';
        return DataBase.getQueryLocator(queryStr);
    }

    public void execute( DataBase.BatchableContext BC, List<ApexLog> scopeList){

        List<String> idsList = new List<String>();
        for( ApexLog log : scopeList){

            idsList.add( log.Id);
        }
        System.debug('delete log ids:' + idsList);

        // 삭제 처리
        Http        htt = new Http();
        HttpRequest req = new HttpRequest();
        String   logIds = String.join( idsList, ',');
        req.setEndpoint( url.getOrgDomainUrl().toExternalForm() + '/services/data/v44.0/composite/sobjects?ids=' + logIds + '&allOrNone=false');
        req.setMethod( 'DELETE');
        req.setHeader( 'Authorization',  'Bearer ' + UserInfo.getSessionId());
        HttpResponse res;
        res = htt.send( req);   

        if(String.isNotBlank(res.getBody())){
            if(res.getStatus() == '200'){
                List<DelResult> resultList = (List<DelResult>)JSON.deserialize(res.getBody(), List<DelResult>.class);
                System.debug(resultList);
            }else{
                system.debug(res.getBody());
            }
        }
        
    }

    public void finish( DataBase.BatchableContext Bc){
        System.debug('finish Batch_DeleteApexLogRt');
    }


    private class DelResult{
        String id;
        Boolean success;
        List<DelError> errors;
    }

    private class DelError{
        StatusCode statusCode;
        String message;
        String[] fields;
    }
}