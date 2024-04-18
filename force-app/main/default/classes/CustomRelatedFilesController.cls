/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author            			   Modification
 * 1.0   09-22-2020   woomg@dkbmc.com                  Initial Version
 * 1.1   10-05-2023   anish.jain@partner.samsung.com   Initial Version
 * 1.2   10-13-2023   saurav.k@partner.samsung.com     MYSALES-324
 * 1.3   02-26-2024   vikrant.ks@samsung.com           Disable "Upload Files" button for Delivery Manager Profile(MYSALES-447)
**/
public with sharing class CustomRelatedFilesController {

	@AuraEnabled
	public static Boolean isCreatable(String objectName){
		try {
			SObjectType objType = Schema.getGlobalDescribe().get(objectName);
			return objType.getDescribe().isCreateable();
			//return objType.getDescribe().fields.Name.isCreatable();	
		} catch(Exception e){
			return true;
		}
	}

    @AuraEnabled
    public static list<ContentDocumentLink> getRelatedFiles(String recordId){       
          return  [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.ContentSize, 
                    ContentDocument.FileExtension, ContentDocument.ContentModifiedDate
                FROM ContentDocumentLink WHERE LinkedEntityId = :recordId and ContentDocument.FileExtension !='snote' ORDER BY ContentDocument.ContentModifiedDate DESC];  //Added by Anish - v 1.1       
    }																																									   //Added orderby - v 1.2

    @AuraEnabled
    public static Object getVaultAuthToken(String apiType, list<String> fileIds, String platform) {
		System.debug('●●●● getVaultAuthToken ●●●●');
		System.debug('apiType : ' + apiType);
		System.debug('fileIds : ' + fileIds);
		System.debug('platform : ' + platform);
		map<String, Object> token = new map<String, Object>();
		Boolean hasFiles = false;
		String endpoint = Label.EFSS_VAULT_AUTHURL + '/vault/sds/sfdc/otp?api=' + apiType;
		System.debug('endpoint : ' + endpoint);
		String sourceIp = getUserIPAddress();
		
		if(apiType == 'file-download' || apiType == 'file-multi-download' || apiType == 'file-view' || apiType == 'file-delete')
			hasFiles = true;

		Http http = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(endpoint);
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + Label.EFSS_VAULT_AUTHKEY);
		req.setHeader('Client-Type', platform);
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
		System.debug('req : ' + req);
		HttpResponse res = http.send(req);
		System.debug('res : ' + res);
		if(res.getStatusCode() == 200){
			token = (map<String, Object>) JSON.deserializeUntyped(res.getBody());
			System.debug('token : ' + token);
		} else {
			throw new CustomException('{"status":'+ String.valueOf(res.getStatusCode()) +', "message":'+ res.getStatus() +'}');
		}	
        return token;
	}

    @AuraEnabled
    public static Boolean saveVaultId2Content(String recordId, String vaultId, String filename){
		try {
			String ExternalSourceId = [SELECT Id FROM ExternalDataSource WHERE DeveloperName = 'EFSS_Vault' LIMIT 1].Id;
			ContentVersion cv = new ContentVersion(
				ContentLocation = 'E',
				Origin = 'H',
				OwnerId = UserInfo.getUserId(),
				Title = filename,
				PathOnClient = filename,
				ExternalDataSourceId = ExternalSourceId,
				ExternalDocumentInfo1 = 'vault://' + vaultId,
				ExternalDocumentInfo2 = vaultId,
				FirstPublishLocationId = recordId
			);
			
			insert cv;
			return true;	
		} catch(Exception ex){
			throw new AuraHandledException(ex.getMessage());
		}
    }

	@AuraEnabled
	public static Boolean checkDeletePermission(String docId){
		ContentDocument cd = [SELECT Id, OwnerId FROM ContentDocument WHERE Id = :docId];

		return cd.OwnerId == UserInfo.getUserId() ? true : false;
	}

	@AuraEnabled
	public static Boolean deleteContentDocument(String docId){
		try {
			ContentDocument cd = [SELECT Id
								 FROM ContentDocument
								 WHERE Id = :docId
								 LIMIT 1];
			delete cd;
			return true;
		} catch (Exception e) {
			throw new AuraHandledException(e.getMessage());
		}
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

    public static String getUserIPAddress() {
		System.debug('●●●● getUserIPAddress ●●●●');
		String localIp = '';
		if(!Test.isRunningTest()){
            localIp = Auth.SessionManagement.getCurrentSession().get('SourceIp');
		} else {
			localIp = '203.244.212.21';
		}
		System.debug('localIp : ' + localIp);
		return localIp;
	}
    //V1.3 Start
    @AuraEnabled
	public static Boolean DisableUploadButton(Id recordId){        
		try {
            String objectAPiName =String.valueOf(recordId.getSObjectType()); 
            List<User> UserProfile = [Select Profile.Name from User where Id = : UserInfo.getUserId() limit 1];
            if(objectAPiName == 'Opportunity' && UserProfile[0].Profile.Name == 'Delivery Manager(HQ)'){
                return true;
            }
			return false;
		} catch(Exception e){
			return false;
		}
	}
	//V1.3 End
	public class CustomException extends Exception {}
}