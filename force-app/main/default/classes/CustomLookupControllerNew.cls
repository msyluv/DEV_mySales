/**
 * @author            : divyam.gupta@samsung.com
 * @group             : 
 * @description       : Apex class for VF Page LookupPopup.vfp
 * @last modified on  : 2024-05-10
 * @last modified by  : divyam.gupta@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2024-05-10   divyam.gupta@samsung.com	Initial Version
**/
public with sharing class CustomLookupControllerNew {
    public String query {get; set;}
    public String objname {get; set;}
    public String objnames {get; set;}
    public String objnamevf {get; set;}

    public List<Account> accounts {get; set;} 
    public List<Opportunity> opps{get; set;}
    public List<Sales_Lead__c> salesleads {get; set;}
    public Boolean doneLookup {get; set;}   
     public Boolean doneLookupopp {get; set;}   
    public Boolean doneLookuplead {get; set;}   
    public Boolean errorMessagequery {get; set;}   
    public String listSize {get; set;}   

    // constructor
    public CustomLookupControllerNew() {
    	doneLookup=false;
        query = Apexpages.currentPage().getParameters().get('name');
        objnamevf = Apexpages.currentPage().getParameters().get('objname');
        if(objnamevf == 'Account'){
            objname = System.Label.Account_weeklyReport;
            objnames = System.Label.Accounts_weeklyReport;
        }
        if(objnamevf == 'Opportunity'){
             objname = System.Label.Opportunity_weeklyReport;
            objnames = System.Label.Opportunities_weeklyReport;
        }
         if(objnamevf == 'Sales Lead'){
             objname = System.Label.SalesLead_weeklyReport;
            objnames = System.Label.SalesLeads_weeklyReport;
        }
        //objname = Apexpages.currentPage().getParameters().get('objname');

        runQuery();
    }
    // executes the search
    public PageReference runQuery() {
        if(query != '' && query != null){
            String keyword = '%'+query +'%';
            if(objnamevf !='' && objnamevf == 'Account'){
            List<Account> searchResults=
               /* [FIND :query IN ALL FIELDS RETURNING 
                    Account (id,Name,AccountNumber,Owner.Alias, AccountSource, Active__c, Phone, Type, mLoevm__c)]; */
                [select id,Name,AccountNumber,Owner.Alias, AccountSource, Active__c, Phone, Type, mLoevm__c from Account where Name LIKE: keyword OR AccountNumber LIKE: keyword OR Owner.Alias LIKE: keyword LIMIT 1000];
            accounts=searchResults;
                integer sizelist = searchResults.size();
                if(searchResults.size() >= 1000){
                    system.debug('Coming of if loo more than 1000 records'+searchResults.size());
                    this.listSize = String.valueof(searchResults.size()) + '+';
                   this.doneLookup=true;

                }
                else {
            this.doneLookup=true;
            this.listSize = String.valueof(searchResults.size());
            this.errorMessagequery = false;

                }
        }
            if(objnamevf !='' && objnamevf == 'Opportunity'){
               /*List<List<Opportunity>> searchResults=
                [FIND :query IN ALL FIELDS RETURNING 
                    Opportunity (id,Name, OpportunityCode__c, AccountId, Account.Name, StageName, CloseDate, Owner.Alias)]; */
                List<Opportunity> searchResults =
                [select id,Name, OpportunityCode__c, AccountId, Account.Name, StageName, CloseDate, Owner.Alias from Opportunity where Name LIKE: keyword OR Account.Name LIKE: keyword OR OpportunityCode__c LIKE: keyword OR Owner.Alias LIKE: keyword LIMIT 1000];
           // opps=searchResults[0];
             opps=searchResults;
             integer sizelist = searchResults.size();
                if(searchResults.size() >= 1000){
                this.doneLookupopp=true; 
                this.listSize = String.valueof(searchResults.size()) + '+';


                }
                else {
            this.doneLookup=false;
            this.doneLookupopp=true; 
             this.listSize = String.valueof(searchResults.size());
                }
            }
            if(objnamevf !='' && objnamevf == 'Sales Lead'){
               List<Sales_Lead__c> searchResults=
               /* [FIND :query IN ALL FIELDS RETURNING 
                    Sales_Lead__c (id,Name, AccountId__c,AccountId__r.name,LeadStage__c, Amount__c, CloseDate__c, RevenueStartDate__c, RevenueEndDate__c)];*/
                   [select id,Name, AccountId__c,AccountId__r.name,LeadStage__c, Amount__c, CloseDate__c, RevenueStartDate__c, RevenueEndDate__c from Sales_Lead__c where Name LIKE: keyword OR AccountId__r.name LIKE: keyword LIMIT 1000];
                 salesleads=searchResults;
                integer sizelist = searchResults.size();

                   if(searchResults.size() >= 1000){
                    system.debug('Coming of if loo more than 1000 records'+searchResults.size());
                    this.doneLookuplead=true;
                    this.listSize = String.valueof(searchResults.size()) + '+';


                }
                else {
            this.doneLookuplead=true;
                 this.listSize = String.valueof(searchResults.size());    

                }
            }
        }
        return null;
    }
}