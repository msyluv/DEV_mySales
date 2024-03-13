public with sharing class WeeklyReportVFController {
    
    public Id recordId { get; set; }
    public String issueDescriptionCheck {get; set;}
    
    public void WeeklyReportVFController(){
        this.recordId = ApexPages.currentPage().getParameters().get('id');
        //this.recordId = 'a0w1s000002fEjYAAU';
        
        WeeklyReport__c weeklyReport = [select IssueDescription__c,Issue_Description_Check__c from WeeklyReport__c where id = :recordId];
        
        if(weeklyReport.Issue_Description_Check__c == null){
            issueDescriptionCheck = null;
        } else{
            issueDescriptionCheck = EncodingUtil.urlDecode(weeklyReport.Issue_Description_Check__c, 'UTF-8');
        }
			
    }
    
    /*@RemoteAction
    public static String getIssueDescription(String recordId){
        system.debug('recordId'+ recordId);
        WeeklyReport__c weeklyReport = [select IssueDescription__c,Issue_Description_Check__c from WeeklyReport__c where id = :recordId];
        system.debug('WeeklyReportData : '+ weeklyReport);
        
        if(weeklyReport.Issue_Description_Check__c == null){
            return null;
        }
			
        return  EncodingUtil.urlDecode(weeklyReport.Issue_Description_Check__c, 'UTF-8');
        
    }*/
    
    public static void deleteImage(String deleteSrc) {
        List<String> src = deleteSrc.split(' ');
        List<String>  cvIdList = new List<String>(); 
        for(String s : src){
        	cvIdList.add(s.split('/')[7]);
        }
        List<ContentVersion> cvList = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE ID IN :cvIdList]; 
        Set<Id> deleteIdList = new Set<Id>(); 
        for(ContentVersion cv : cvList){
        	deleteIdList.add(cv.ContentDocumentId); 
        }
        List<ContentDocument> cdList = [SELECT ID FROM ContentDocument WHERE ID IN :deleteIdList]; 
        DELETE cdList; 
    }
    
    public static void CreateImgPublicLink(String uploadedImgSrc){

        System.debug('########### uploadedImgSrc ##############'); 
        System.debug(uploadedImgSrc); 
        if(uploadedImgSrc == null || uploadedImgSrc == '') return; 
        List<Id> src = uploadedImgSrc.split(' ');
        Set<Id> cvSet = new Set<Id>(); 
        List<ContentDistribution> cdList = new List<ContentDistribution>(); 
        for(Id s : src) cvSet.add(s); 
        Map<Id,ContentVersion> cvMap = new Map<Id,ContentVersion>([SELECT ID,Title FROM ContentVersion WHERE ID in :cvSet]); 

       for(Id s : src){
           ContentVersion cv 		= cvMap.get(s); 
           ContentDistribution cd = new ContentDistribution(); 
           cd.ContentVersionId 	= cv.Id; 
           cd.Name             	= cv.Title; 
           cd.PreferencesNotifyOnVisit = false; 
           cdList.add(cd);
       }
        
        if(cdList.size()>0) Insert cdList; 
    }
    
    public pageReference doSave(){
        try{
            System.debug('******************* CafeNote Editor doSave Start****************'); 
            
            String issueDesc = Apexpages.currentPage().getParameters().get('issueDescription');
			String deleteSrc   = Apexpages.currentPage().getParameters().get('deleteSrc');
            String uploadedImgSrcList   = Apexpages.currentPage().getParameters().get('uploadedImgSrcList');
            
            String encodedContent = EncodingUtil.urlEncode(issueDesc, 'UTF-8');
            Integer stringCount = encodedContent.length(); 
            
            Schema.DescribeFieldResult fieldResult = WeeklyReport__c.Issue_Description_Check__c.getDescribe();
            Integer lengthOfField =fieldResult.getLength(); 
            
            if(stringCount > lengthOfField){
                System.debug('stringCount : ' +stringCount ); 
                System.debug('lengthOfField : ' +lengthOfField ); 
                System.debug('size초과');
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,lengthOfField+'자 Size 초과입니다. 현재('+stringCount+'자)'));                    
                return null;
            }
            
            System.debug('Delete List : ' + DeleteSrc);
            if(deleteSrc.length()>0) deleteImage(deleteSrc); 
            
            createImgPublicLink(uploadedImgSrcList); 
            
            WeeklyReport__c newWR = [select id,Issue_Description_Check__c from WeeklyReport__c where id = :recordId];
        	
            newWR.Issue_Description_Check__c = encodedContent;
        	update newWR;

        }
        catch(Exception e){
            //Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error Saving record: '+e.getMessage()));
        }
        System.debug('*************** do Save End *******************');
        return null;
    }
    
    /*public PageReference afterSave(){
        PageReference redirect = new PageReference('/' + recordId);
        redirect.setRedirect(true);
        return redirect;
    }*/
    
}