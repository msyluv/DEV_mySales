/**
 * @description       : 
 * @author            : chae_ho.yang@samsung.com
 * @group             : 
 * @last modified on  : 01-03-2024
 * @last modified by  : chae_ho.yang@samsung.com
**/
public with sharing class NewTestOpportunity {

    public User user = [select id, EvKostl__c from user where id =: Userinfo.getUserid()];


    public Boolean condition { get; set; }
    public Opportunity newOpportunity { get; set; }      
    public Service__c srv = new Service__c();
    public Solution__c sol = new Solution__c();
    public Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    public RecordType RT_OPPTY_HQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'HQ' Limit 1];
    public RecordType RT_OPPTY_LOGI = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'Logistics' Limit 1];
    public Employee__C pm = [select id, name from employee__c where name = '양채호'];
    public Account hyundai = [select id, name from account where AccountNumber = 'A1000259'];
    public Account emro = [select id, name from account where AccountNumber = 'A0034034'];
    public CostCenter__c cc = [select id, name from costcenter__c where costcenter__c =: user.EvKostl__c];
    public Master_Service__c ms = [select id, name from Master_Service__c where name = 'CRM'];
    public Master_Solution__c ms2 = [select id, name from Master_solution__c where name = 'CRM Implementation'];
    public BizAttribute__c bizatt = [select id, name from BizAttribute__c where name = 'SI/NI Implementation'];
    public Organization__c org = [select id, name, Code__c from Organization__c where code__c = 'T714'];
   
    public NewTestOpportunity(ApexPages.StandardSetController controller) {
       newOpportunity = new Opportunity();
    }

    private void createData() {
        newOpportunity.RecordTypeId = RT_OPPTY_HQ.Id;
        newOpportunity.ProposalPM__c = pm.Id;
        newOpportunity.MigData__c = True;
        newOpportunity.StageName = 'Z01';
        newOpportunity.CloseDate = Date.today().addDays(1);
        newOpportunity.AccountId = hyundai.Id;
        newOpportunity.cOriginAcc__c = hyundai.Id;
        newOpportunity.cLeadID__c = NULL;
        newOpportunity.BusinessType2__c = 'Implementation';
        newOpportunity.Amount = 200000000;
        newOpportunity.BiddingMethod__c = 'BID001';
        newOpportunity.CurrencyIsoCode = 'KRW';
        newOpportunity.Reuse__c = 'Y';
        newOpportunity.ReuseReason__c = '기타 재활용';
        newOpportunity.cRevenueStartDate__c = Date.today().addDays(3);
        newOpportunity.cRevenueEndDate__c = Date.today().addDays(7);
        newOpportunity.SalesDepartment__c = cc.Id;
        newOpportunity.cPrimarySalesDepartment__c = cc.Id;
        System.debug(newOpportunity);
    }

    private void createServ() {
        srv.Opportunity__c = newOpportunity.id;
        srv.ItemNumber__c = 10;
        srv.sservice__c = ms.id;
        srv.sSalesDepartment__c = cc.id;
        srv.sDeliveryDepartment__c = cc.id;
        srv.sDeletionFlag__c = false;
        srv.TechAttribute__c = false;
        //srv.Changed__c = true;
        System.debug('service1 : ' + srv);
    }

    private void createSol() {
        sol.Service__c = srv.Id;
        sol.sSolution__c = ms2.Id;
        sol.sBizAttribute__c = bizatt.Id;
        sol.sDeletionFlag__c = false;
        sol.SendSAP__c = false;
        sol.changed__c = false;
        sol.Opportunity__c = newOpportunity.Id;
        //sol.sPSType__c = 'SI1';
        //sol.sBusinessType__c = 'TI';
        //sol.sWBSClass__c = 'SI';
        System.debug('solution1 : ' + sol);
    }

    public PageReference createOpportunityLogi() {
        newOpportunity.RecordTypeId = RT_OPPTY_LOGI.Id;
        newOpportunity.type = '01';
        newOpportunity.MigData__c = True;
        newOpportunity.StageName = 'Z01';
        newOpportunity.CloseDate = Date.today().addDays(3);
        newOpportunity.AccountId = emro.Id;
        newOpportunity.LogisticsBizDevelopmentType__c = '04';
        newOpportunity.cLeadID__c = NULL;
        newOpportunity.BiddingDeadline__c = Date.today().addDays(1);
        newOpportunity.Amount = 200000000;
        newOpportunity.LogisticsServiceType__c = '01';
        newOpportunity.CurrencyIsoCode = 'KRW';
        newOpportunity.LogisticsBizType__c = '01';
        newOpportunity.LBSExceptionType__c = '05';
        newOpportunity.cRevenueStartDate__c = Date.today().addDays(4);
        newOpportunity.cRevenueEndDate__c = Date.today().addDays(7);
        newOpportunity.LogisticsCustomerType__c = 'SECSET';
        newOpportunity.SubIndusrty__c = '06';
        newOpportunity.SalesOrganization__c = org.Id;
        newOpportunity.DeliveryOrganization__c = org.Id;
        System.debug(newOpportunity);
        insert newOpportunity;
        PageReference home = new PageReference('https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/'+newOpportunity.Id+'/view');
        newOpportunity = new Opportunity(); // Reset the form
        home.setRedirect(true);        
        return home;
    }

    public PageReference back() {
        PageReference home = new PageReference('https://sdssfa--qa.sandbox.lightning.force.com/lightning/o/Opportunity/list?filterName=Recent');
        newOpportunity = new Opportunity(); // Reset the form
        home.setRedirect(true);        
        return home;    
    }
    
    public PageReference createOpportunity() {
        createData();
        System.debug('data created');
        try {
            insert newOpportunity;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Opportunity created successfully!'));
            System.debug('done');
            PageReference home = new PageReference('https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/'+newOpportunity.Id+'/view');
            newOpportunity = new Opportunity(); // Reset the form
            home.setRedirect(true);        
            return home;    
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Occurred'));
            return null;
        }
    }

    public PageReference createOpportunityServSol() {
        createData();
        System.debug('createdata done');
        try {
            insert newOpportunity;
            createServ();
            System.debug('createserv done');
            insert srv;
            System.debug('serv create done');
            createSol();
            insert sol;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Opportunity with Service/Solution created successfully!'));
            System.debug('done');
            PageReference home = new PageReference('https://sdssfa--qa.sandbox.lightning.force.com/lightning/r/Opportunity/'+newOpportunity.Id+'/view');
            newOpportunity = new Opportunity(); // Reset the form
            home.setRedirect(true);        
            return home;    
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error Occurred'));
            System.debug('fail' + ex);
            return null;
        }
    }
}