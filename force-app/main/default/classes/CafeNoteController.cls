public with sharing class CafeNoteController {
    public String record{get;set;}
    public String editorContent{get;set;}
    public Boolean isSandbox{get;set;}
    public String baseUrl{get;set;}
    public String language{get;set;}
    
    public void CafeNoteController() {
        //record = ApexPages.currentPage().getParameters().get('record'); 
        this.record = 'a0w1s0000003GQrAAM';
        //this.record = ApexPages.currentPage().getParameters().get('id');

        WeeklyReport__c weeklyReport = [select IssueDescription__c,Issue_Description_Check__c from WeeklyReport__c where id = :record];
        system.debug('WeeklyReportData : '+ weeklyReport);
        
        if(weeklyReport.Issue_Description_Check__c == null){
            editorContent = null;
        } else{
            editorContent = EncodingUtil.urlDecode(weeklyReport.Issue_Description_Check__c, 'UTF-8');
            system.debug('issueDescriptionCheck : '+ editorContent);
            //issueDescriptionCheck = String.escapeSingleQuotes(EncodingUtil.urlDecode(String.ValueOf(weeklyReport.Issue_Description_Check__c), 'UTF-8'));
        }

        organization org = [select isSandbox from organization where id=:Userinfo.getOrganizationId()];
        isSandbox = (org.IsSandbox == true) ? true : false;
        User u = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId()];
        language = u.LanguageLocaleKey;
    }

    public pageReference doSave(){
        
        String issueDesc = Apexpages.currentPage().getParameters().get('issueDescription');
            
        WeeklyReport__c newWR = [select id,Issue_Description_Check__c from WeeklyReport__c where id = :record];
        	
        newWR.Issue_Description_Check__c = EncodingUtil.urlEncode(issueDesc, 'UTF-8');
        update newWR;
            
        return null;
    }
}