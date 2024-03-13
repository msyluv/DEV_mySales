/**
* @description       : This class is used to show attachments on the UI and also controls who is allowed to upload attachments.
* @author            : rakshit.s@samsung.com
* @group             : 
* @last modified on  : 13-12-2022
* @last modified by  : gitesh.s@samsung.com
* Modifications Log 
* Ver   Date         Author                  Modification
* 1.0   01-10-2022   rakshit.s@samsung.com   Initial Version
* 1.1   31-08-2022   gitesh.s@samsung.com    Added Community Login Profile
* 1.2   29-11-2022   gitesh.s@samsung.com    Added sObjName for MSP Project
* 1.3   08-12-2022   gitesh.s@samsung.com    Changed sObjName for MSP Project
* 1.4   13-12-2022   gitesh.s@samsung.com    Allow upload for partner profile in SCP Account
**/
public without sharing class MSPFileAttachmentController {
    
    
    @AuraEnabled(cacheable = true)
    public static void refreshComponentMock(){
        
    }
    @AuraEnabled()
    public static AttachmentWrapper getAttachments(String parentRecordId){
        System.debug('id-->' + parentRecordId);
        //parentRecordId ='a1U1s000001bkiaEAA';
        AttachmentWrapper getAttachmentDetail = new AttachmentWrapper();
        Id Idval = parentRecordId;
        String sObjName = Idval.getSObjectType().getDescribe().getName();
        
        Set<Id> RecordIdSet = new Set<Id>();
        
        // v1.2, v1.3 - Gitesh Saini
        if(sObjName=='PartnerFundRequest' || sObjName=='PartnerFundClaim' || sObjName=='Partnership_Guide__c' || sObjName=='Marketing_Tool__c' || sObjName=='Partner_Notice__c' || sObjName =='Partner_Enrollment_Request__c' || sObjName == 'SCP_Account__c'){
        // v1.2, v1.3
            getAttachmentDetail.rendercomponent = true;
            getAttachmentDetail.objName = sObjName;
	        }
        
        else{
            getAttachmentDetail.rendercomponent = false;
        }
        
       
        RecordIdSet.add(parentRecordId);
        //for attachment
        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentRecordId];
        if (CDLs.size() < 1 ) {
            getAttachmentDetail.attachmentList = null;
        }
        else{
            List<Id> CDIdList = new List<Id> (); 
            for (ContentDocumentLink nextCDL : CDLs) { 
                CDIdList.add(nextCDL.ContentDocumentId); 
            } 
            List<ContentVersion> contentVersionList = [SELECT  Id, OwnerId, VersionData, FileType, Title, FileExtension,ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,CreatedDate, ContentDocumentId, ContentDocument.FileType FROM   ContentVersion WHERE  ContentDocumentId IN : CDIdList order by createddate desc]; 
            
            for(ContentVersion attchmnt : contentVersionList){
                getAttachmentDetail.attachmentUrl.add(URL.getSalesforceBaseUrl().toExternalForm() 
                                                      + '/sfc/servlet.shepherd/document/download/' + attchmnt.ContentDocumentId);
            }
            getAttachmentDetail.attachmentList = contentVersionList;
        }
        
        //for attachment
        Id ProfileId = UserInfo.getProfileId();
        
        List<profile> MSPAdminProfileId = new List<Profile>([Select id,name from profile where Id=:ProfileId]);
        // Id SystemAdminId = [Select id from profile where name= 'System Administrator'].Id;
        
        for(Profile validProfile : MSPAdminProfileId ){
            system.debug('proname->' + validProfile.Name);
            if(validProfile.Name == 'MSP Admin' || validProfile.Name == 'System Administrator' || validProfile.Name == 'Delivery Profile')
            {
                getAttachmentDetail.allowUpload = true;
                system.debug('inside if-->' + validProfile.Name);
                
            }
            
            /*Ver 1.1 Added Community Login Profile*/
            else if(((validProfile.Name == 'Partner Community Manager' || validProfile.Name == 'Partner Community Login Manager') && (sObjName == 'PartnerFundRequest' || sObjName == 'PartnerFundClaim')) || Test.isRunningTest() ) {
                if(validProfile.Name == 'Partner Community Manager') {
                    getAttachmentDetail.profileName = 'Partner Community Manager';
                }
                else if(validProfile.Name == 'Partner Community Login Manager') {
                    getAttachmentDetail.profileName = 'Partner Community Login Manager';
                }
                
                if(sObjName == 'PartnerFundClaim'){
                    PartnerFundClaim pp = new PartnerFundClaim();
                    
                    pp = [select id, status__c from PartnerFundClaim where Id =: parentRecordId];
                    
                    if(pp.status__c == 'Claimable' || pp.status__c == 'Submitted'){
                        getAttachmentDetail.allowUpload = true;
                        //getAttachmentDetail.profileName = 'Partner Community Manager';
                    }
                }
               
                else if(sObjName == 'PartnerFundRequest'){
                    PartnerFundRequest pp = new PartnerFundRequest();
                    
                    pp = [select id, status from PartnerFundRequest where Id =: parentRecordId];
                    
                    if(pp.status == 'Draft' || pp.status == 'Submitted'){
                        getAttachmentDetail.allowUpload = true;
                        
                    }
                }
            }
            // v1.4 - Gitesh Saini
            else if((validProfile.Name == 'Partner Community Manager' || validProfile.Name == 'Partner Community Login Member') && (sObjName == 'SCP_Account__c')) {
                getAttachmentDetail.allowUpload = true;
                system.debug('inside if-->' + validProfile.Name);
            }
            // v1.4
        }
        
        return getAttachmentDetail;
    }
    
    @AuraEnabled
    public static void clearUploadAction(List<Id> incomingDocIds){
        
        
        List<ContentDocument> delRec= New List<ContentDocument>();
        delRec = [select id from ContentDocument where id IN: incomingDocIds];
        
        delete delRec;
    }
    
    @AuraEnabled
    public static void deleteAttachmentAction(Id recId){
        
        delete [SELECT Id,Title,FileType from ContentDocument WHERE id=:recId]; 
    }
    
    public class AttachmentWrapper {
        @AuraEnabled
        public boolean allowUpload = false;
        
        @AuraEnabled
        public List<ContentVersion> attachmentList{get;set;}
        
        @AuraEnabled
        public List<String> attachmentUrl = new List<String>();
        
        @AuraEnabled
        public boolean rendercomponent = false;
        
        @AuraEnabled
        public String objName;
        
         @AuraEnabled
        public String profileName;
        
        @AuraENabled
        public Id userId;
        
    } 
}