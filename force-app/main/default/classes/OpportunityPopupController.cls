/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-01-19
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-19   younghoon.kim@dkbmc.com   Initial Version
**/
public class OpportunityPopupController {
	@AuraEnabled
    public static Map<String, String> getInfo(String type){
        Map<String, String> rtnMap = new Map<String, String>();

        RecordType rcdType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'OpportunityNotice__c' AND Name =: type];

            //Start - Added by Anish - Safety Management Modification
            List<OpportunityNotice__c> OpptyNoticeList = new List<OpportunityNotice__c>();
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            if(isSandbox){
             OpptyNoticeList = [SELECT Id, Name, RecordTypeId, NoticeKR__c, NoticeEN__c, NoticeCN__c, CreatedDate 
                                                        FROM OpportunityNotice__c 
                                                       WHERE RecordTypeId =: rcdType.Id and Name = 'ON-20210100002'
                                                       ORDER BY CreatedDate DESC 
                                                       LIMIT 1];
            }
            else{
              OpptyNoticeList = [SELECT Id, Name, RecordTypeId, NoticeKR__c, NoticeEN__c, NoticeCN__c, CreatedDate 
                                                        FROM OpportunityNotice__c 
                                                       WHERE RecordTypeId =: rcdType.Id and Name = 'ON-20210300002'
                                                       ORDER BY CreatedDate DESC 
                                                       LIMIT 1];   
            }
        //End - Added by Anish - Safety Management Modification
        
        if(OpptyNoticeList.size() > 0){
            if(OpptyNoticeList[0].NoticeKR__c != null) rtnMap.put('KR', OpptyNoticeList[0].NoticeKR__c);
            if(OpptyNoticeList[0].NoticeEN__c != null) rtnMap.put('EN', OpptyNoticeList[0].NoticeEN__c);
            if(OpptyNoticeList[0].NoticeCN__c != null) rtnMap.put('CN', OpptyNoticeList[0].NoticeCN__c);

            List<ContentDocumentLink> cdList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: OpptyNoticeList[0].Id];
            if(cdList.size() > 0) rtnMap.put('CD', cdList[0].ContentDocumentId);
        }
        return rtnMap;
    }

    @AuraEnabled
    public static ContentVersion getVaultFileId(String docId){
        try {
            ContentVersion cv = [SELECT Id, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId
                                 FROM ContentVersion
                                 WHERE ContentDocumentId = :docId
                                    AND isLatest=true
                                 LIMIT 1];
            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Object getVaultAuthToken(String apiType, list<String> fileIds) {
        map<String, Object> token = new map<String, Object>();
        Boolean hasFiles = false;
        String endpoint = Label.EFSS_VAULT_AUTHURL + '/vault/sds/sfdc/otp?api=' + apiType;
        String sourceIp = getUserIPAddress();
        
        if(apiType == 'file-download' || apiType == 'file-multi-download' || apiType == 'file-view' || apiType == 'file-delete')
            hasFiles = true;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + Label.EFSS_VAULT_AUTHKEY);
        req.setHeader('Client-Type', 'web');
        req.setHeader('Client-Addr', sourceIp);

        if(hasFiles){
            req.setHeader('Content-Type', 'application/json');
            if(fileIds == null || fileIds.isEmpty()) throw new CustomException('no files');
            list<String> files = new list<String>();
            for(String fileId : fileIds){
                files.add(fileId);
            }
            map<String, list<String>> mapBody = new map<String, list<String>>();
            mapBody.put('fileIds', files);
            // system.debug(JSON.serialize(mapBody));
            req.setBody(JSON.serialize(mapBody));
        }
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            token = (map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // system.debug(token);
        } else {
            throw new CustomException('{"status":'+ String.valueOf(res.getStatusCode()) +', "message":'+ res.getStatus() +'}');
        }    
        return token;
    }

    public static String getUserIPAddress() {
        String localIp = '203.244.212.21';
        //localIp = Auth.SessionManagement.getCurrentSession().get('SourceIp');
        return localIp;
    }
    
    public class CustomException extends Exception {}

}