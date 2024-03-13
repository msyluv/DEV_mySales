/**
 * @description       : 
 * @author            : sh.shin@dkbmc.com
 * @group             : 
 * @last modified on  : 2020-10-23
 * @last modified by  : sh.shin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author              Modification
 * 1.0   2020-10-23   sh.shin@dkbmc.com   Initial Version
**/
public class FileUploadController {    
    public static Id saveTheFile(Boolean bUrlEncoded, Id parentId, String fileName, String base64Data, String iconName, Decimal filesize) { 
        if(bUrlEncoded) {
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        }

        Attachment a = new Attachment();        
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = iconName;
        a.Description = String.valueOf(filesize);
        
        insert a;
        return a.Id;
    }
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String iconName, Decimal filesize) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

        Attachment a = new Attachment();        
        a.parentId = parentId;
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = iconName;
        a.Description = String.valueOf(filesize);
        
        insert a;
                
        return a.Id;
    }

    @AuraEnabled
    public static List<Attachment> saveTheFiles( Id parentId, List<Map<String, Object>> fileList){
        
        List<Attachment> attachList = new List<Attachment>();
        for( Map<String, Object> file : fileList){

            Attachment attach = new Attachment();
            attach.parentId   = parentId;
            attach.Name       = String.valueOf( file.get( 'name'));
            attach.Body       = ( Blob)EncodingUtil.base64Decode( file.get( 'fileContents') + '');
            attach.ContentType= String.valueOf( file.get( 'iconName'));
            attach.Description= String.valueOf( file.get( 'filesize'));
            attachList.add( attach);
        }

        insert attachList;

        return attachList;
    }

    /*@AuraEnabled    
    public static void linkedFile(List<KnoxParam.FileInfo> fileList, Id parentId) { 

        List<ContentDocumentLink> condocLink = new List<ContentDocumentLink>();
        List<ContentVersion> cv = new List<ContentVersion>();        

        for(KnoxParam.FileInfo file : fileList ){
            ContentVersion cVersion = new ContentVersion();
            cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
            cVersion.PathOnClient = file.getFileName();//File name with extention
            cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
            //cVersion.OwnerId = attach.OwnerId;//Owner of the file
            cVersion.Title = file.getFileName();//Name of the file
            cVersion.VersionData = file.getBlobFile();//File content
            cv.add(cVersion);
            
        }
        Insert cv;

        Set<Id> cvId = new Map<Id, ContentVersion>(cv).keySet();

        List<ContentVersion> conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :cvId];
                
        //After saved the Content Verison, get the ContentDocumentId
        
        for(ContentVersion  c : conDocument){
            ContentDocumentLink cDocLink = new ContentDocumentLink();
            cDocLink.ContentDocumentId = c.ContentDocumentId;//Add ContentDocumentId
            cDocLink.LinkedEntityId = parentId;//Add attachment parentId
            cDocLink.ShareType = 'V';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
            //cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
            condocLink.add(cDocLink);         
        }
        Insert condocLink;
            
       
    }*/

    @AuraEnabled
    public static List<Map<String, Object>> getFile(Id parentId) { 
        List<Attachment> att =  [SELECT Id, IsDeleted, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, OwnerId, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Description 
                                FROM Attachment
                                WHERE parentId = :parentId];
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for(Attachment at : att ){
            Map<String, Object> file = new Map<String, Object>();
            //Map<String, Object> fileinfo = new Map<String, Object>();

            file.put('fileSize', at.Description);
            file.put('name', at.Name); 
            //file.put('iconName', 'doctype:'+at.ContentType.split('/')[0]);
            file.put('iconName', at.ContentType);            
            //file.put('fileContents', EncodingUtil.urlEncode(EncodingUtil.base64Encode(at.Body), 'UTF-8'));
            file.put('fileContents', EncodingUtil.base64Encode(at.Body));
            result.add(file);

        }
        return result;  
    }

    @AuraEnabled
    public static void delTheFile(Id parentId) { 
        DELETE [SELECT id FROM Attachment WHERE parentId = :parentId];
    }

}