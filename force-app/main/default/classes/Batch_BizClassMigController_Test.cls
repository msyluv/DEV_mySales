/**
 * @description       : 
 * @author            : kwangjin.yu@dkbmc.com
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : kwangjin.yu@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   01-21-2022   kwangjin.yu@dkbmc.com   Initial Version
**/
@isTest
public with sharing class Batch_BizClassMigController_Test {
    static List<MasterMap__c> listMasterMap = new List<MasterMap__c>();
    static String strPrefix = 'NoName';
    static Set<Id> setOppId = new Set<Id>();
    static Account acc1 = new Account();
    static Opportunity opp1 = new Opportunity();
    
    static Company__c company = new Company__c();
    static CostCenter__c cCenter = new CostCenter__c();
    
    static Service__c srv = new Service__c();
    static Solution__c sol = new Solution__c();    
    
    
    
    static Master_Service__c MasterService = new Master_Service__c();
    static Master_Solution__c MasterSolution = new Master_Solution__c();
    static Map<String, MasterMap__c> mapMasterMap = new Map<String, MasterMap__c>();
    

    @TestSetup
    static void setData(){
        company.Name = 'test';
        insert company;
        
        cCenter.CostCenter__c = 'T514-70000';
        cCenter.Company__c = company.id;
        insert cCenter;
        
        Business__c biz1 = new Business__c(Name='MSP', Code__c='12000005', Use__c=TRUE ,ValidityEndDate__c=Date.newInstance(4000, 12, 31), ValidityStartDate__c=Date.newInstance(2022, 01, 13));
        insert biz1;
        
        Master_Service__c mSer1 = new Master_Service__c(Name='Cloud App ITO', Code__c='22000008'
                                     , ServiceBizUnitCode__c='T100-10407', ServiceBizUnit__c='클라우드사업부', ServiceDepartmentCode__c='T100-10407'
                                     , ServiceDepartment__c='클라우드사업부', Use__c=TRUE, ValidityEndDate__c=Date.newInstance(4000, 12, 31)
                                     , ValidityStartDate__c=Date.newInstance(2022, 01, 13));
        mSer1.Business__c = biz1.Id;
        insert mSer1;
        
        Master_Solution__c mSol1 = new Master_Solution__c(Name='Mobile App ITO', Code__c='30000026', CompanyCode__c='T100', PLCStatus__c='A', PLManagementLevel__c='L3'
                                      , Product__c=FALSE, SolutionDepartmentCode__c='T100-12014'
                                      , SolutionDepartment__c='전자서비스혁신팀', SolutionManageName__c='오명택 상무', SolutionManagerNo__c='28845', SolutionType__c='10'
                                      , Use__c=TRUE, ValidityEndDate__c=Date.newInstance(4000, 12, 31), ValidityStartDate__c=Date.newInstance(2022, 01, 13));
        mSol1.Service__c = mSer1.Id;
        insert mSol1;
        
        BizAttribute__c mBizAttr = new BizAttribute__c(Name='Service_Usage/Recurring', Code__c='S133');
        insert mBizAttr;
        
        MasterMap__c mMap1 = new MasterMap__c(AsisCode__c='30000026', AsIsName__c='Sol_TEST', TobeCode__c='30000026', ToBeName__c='Sol_TEST',Level__c='L3',RelatedAB__c='equalsAll',TAFlag__c=FALSE);
        insert mMap1;
        
        MasterMap__c mMap2 = new MasterMap__c(AsisCode__c='22000008_30000026', AsIsName__c='Ser_TEST', TobeCode__c='22000008', ToBeName__c='Ser_TEST',Level__c='L2',RelatedAB__c='equalsAll',TAFlag__c=FALSE);
        insert mMap2;
        
        MasterMap__c mMap3 = new MasterMap__c(AsisCode__c='30000026_S133', AsIsName__c='Ser_TEST', TobeCode__c='22000008', ToBeName__c='Ser_TEST',Level__c='BizAttr',RelatedAB__c='merge',TAFlag__c=FALSE);
        insert mMap3;


        MasterMap__c mMap4 = new MasterMap__c(AsisCode__c='22000008_T514-70000', AsIsName__c='Ser_TEST', TobeCode__c=cCenter.Id, ToBeName__c='Ser_TEST',Level__c='Dept',RelatedAB__c='merge',TAFlag__c=FALSE);
        insert mMap4;
        
        
        
        	
        
    }
    
    @isTest
    static void TestCase01(){
        
        acc1 = Utils_TestDataFactory.createAccount('Batch_BizClassMigController_0214');
        acc1.MDGCheck__c = true;
        update acc1;        
        
        opp1.Name = 'testoppty';
        opp1.AccountId = acc1.id;
        opp1.OpportunityCode__c = 'SDS-212109999';
		opp1.ActivityStatus__c = 'XP11';
		opp1.StageName = 'Qualification';
		opp1.CloseDate = Utils.getCurDatetime().date().addDays(1);
        insert opp1;
        
        system.debug('### Batch_BizClassMigController_Test :: TestCase01 :: opp1 = ' + opp1.id);
        
        setOppId.add(opp1.Id);
        
        
        
        
        
        
       // Service__r.Name, Service__r.Code__c, sService__c
       //      , sService__r.Name, sService__r.Code__c, DeliveryDepartmentNmBackup__c, TechAttribute__c, DeliveryDepartment__c, sDeliveryDepartment__c
        Master_Service__c mse1 = [SELECT id, Name FROM Master_Service__c WHERE Code__c='22000008'];
            
        CostCenter__c mCC = [SELECT id, Name, CostCenter__c FROM CostCenter__c WHERE CostCenter__c='T514-70000']; 
        system.debug('### Batch_BizClassMigController_Test :: TestCase01 :: mCC = ' + mCC.CostCenter__c);
            
        system.debug('### Batch_BizClassMigController_Test :: TestCase01 :: mse1 name = ' + mse1.Name);
        srv.Opportunity__c = opp1.id;
        srv.ItemNumber__c = 10;
        srv.Service__c = mse1.id;
        srv.sService__c = mse1.id;
        srv.SalesDepartment__c = mCC.id;
        srv.sSalesDepartment__c = mCC.id;
        srv.DeliveryDepartment__c = mCC.id;
        srv.sDeliveryDepartment__c = mCC.id;
        //srv.TechAttribute__c = false;
        srv.SendSAP__c = true;
        srv.DeletionFlag__c = false;
        insert srv;
        
        
        //Id, Name, Opportunity__c, Service__c, Solution__c, Solution__r.Name, Solution__r.Code__c, sSolution__c, sSolution__r.Name, sSolution__r.Code__c
        //     , SolutionNmBackup__c, sDeletionFlag__c, SendSAP__c, SolutionType__c
        BizAttribute__c bizAttr1 = [SELECT id FROM BizAttribute__c WHERE Code__c='S133'];
        Master_Solution__c mso1 = [SELECT id FROM Master_Solution__c WHERE Code__c='30000026'];
        sol.Opportunity__c = opp1.id;
        sol.Service__c = srv.Id;
        sol.Solution__c = mso1.Id;
        sol.sSolution__c = mso1.Id;
        sol.sDeletionFlag__c = false;
        sol.SendSAP__c = true;
        sol.BizAttributeBackup__c = 'S133';
        sol.BizAttribute__c  = bizAttr1.id;
        insert sol;

        Test.startTest();       
        //Database.executeBatch(new Batch_BizClassMigController(strPrefix, setOppId), 200);
        
        BizClassMigController.executeBatch(opp1.Id,'2020-01-01 00:00:00','2022-10-10 00:00:00',false);
        Test.stopTest();
		
    }
  
    
}