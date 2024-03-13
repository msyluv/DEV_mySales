public class newWeeklyReportVFController {

    public newWeeklyReportVFController(ApexPages.StandardController std){
        
    }
    
    public Id recordId { get; set; }
    public String issueDescriptionCheck {get; set;}
    
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
            String ReportingName = Apexpages.currentPage().getParameters().get('ReportingName');
			Date ReportingDate   = Date.valueOf(Apexpages.currentPage().getParameters().get('ReportingDate'));
            String Critical   = Apexpages.currentPage().getParameters().get('Critical');
            String Account = Apexpages.currentPage().getParameters().get('Account');
			String Opportunity   = Apexpages.currentPage().getParameters().get('Opportunity');
            String SalesLead   = Apexpages.currentPage().getParameters().get('SalesLead');
            String IssueReport = Apexpages.currentPage().getParameters().get('IssueReport');
			String Flag   = Apexpages.currentPage().getParameters().get('Flag');
            String ComplianceGuide   = Apexpages.currentPage().getParameters().get('ComplianceGuide');
            String ReportContent   = Apexpages.currentPage().getParameters().get('ReportContent');
            system.debug('parameters value : '+ ReportContent);
            String IssueDescription1 = Apexpages.currentPage().getParameters().get('IssueDescription1');
			system.debug('parameters value : '+ IssueDescription1);
            String DisplayOrder   = Apexpages.currentPage().getParameters().get('DisplayOrder');
            system.debug('DoSave name: ' + ReportingName + 'date: ' + ReportingDate + 'critical: ' + Critical + 'Account: ' + Account + 'Opp ' + Opportunity + 'SalesLead: ' + SalesLead + 'IssueReport: ' + IssueReport + 'Flag: ' + Flag);
            
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
            system.debug('Present1');
            WeeklyReport__c newWR = new WeeklyReport__c();
        	system.debug('Present2');
            newWR.name = ReportingName;
            system.debug('Present3');
            newWR.ReportingDate__c = ReportingDate;
            system.debug('Present4');
            newWR.Critical__c = Boolean.valueOf(Critical);
            system.debug('Present5');
            if(Account != null && Account != '' && Account != ' ') newWR.Account__c = Account;
            system.debug('Present6');
            if(Opportunity != null && Opportunity != '' && Opportunity != ' ') newWR.Opportunity__c = Opportunity;
            system.debug('Present7');
            if(SalesLead != null && SalesLead != '' && SalesLead != ' ') newWR.SalesLead__c = SalesLead;
            system.debug('Present8');
            newWR.CheckedforIssue__c = Boolean.valueOf(IssueReport);
            system.debug('Present9');
            newWR.Flag__c = Flag;
            system.debug('Present10');
            if(encodedContent != null) newWR.Issue_Description_Check__c = encodedContent;
            if(ComplianceGuide != null) newWR.ComplianceGuide__c = ComplianceGuide;
            if(ReportContent != null) newWR.Contents__c = ReportContent;
            if(IssueDescription1 != null) newWR.IssueDescription__c = IssueDescription1;
            if(DisplayOrder != null) newWR.DisplayOrder__c = decimal.valueOf(DisplayOrder);
            system.debug('Before insert Apex Class '+ newWR);
        	insert newWR;
            system.debug('After insert Apex Class '+ newWR.Id);
            
            PageReference redirectUrl = new PageReference('https://sdssfa--qa.sandbox.my.salesforce.com/' + newWR.Id);
            redirectUrl.setRedirect(true);
			return redirectUrl;
        }
        catch(Exception e){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.Severity.ERROR, 'Error Saving record: '+e.getMessage()));
        }
        System.debug('*************** do Save End *******************');
        return null;
    }
}