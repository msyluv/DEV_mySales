/**
 * @description       : 
 * @author            : hj.lee@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-02-06
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author             		Modification
 * 1.0   2020-11-16   hj.lee@dkbmc.com   		Initial Version
 * 1.1   2024-02-06   vikrant.ks@samsung.com    Increased code coverage.(MySales-389)
**/
@isTest
public class ManualSharingController_Test {
    static Macro macro;
    Static Account acc;
    static User user1;
    static UserRole ur;
    static UserRole urole;
    static Group gr;
    
    //V1.1 Start
	static User member1;
    static User member2;
    static Campaign campaign1;
    static CostCenter__c costCenter;
    static Sales_Lead__c sl;
    static Sales_Lead_Team__c slt;
    //V1.1 End
    
    static{
        
        System.runAs(new User(Id=UserInfo.getUserId())){
            urole = new UserRole();
            urole.Name = 'New Role';
            insert urole;
        }
        gr = [SELECT Id FROM Group WHERE RelatedId = :urole.Id][0];


        acc = new Account();
        acc.Name = 'TestAccount';

        insert acc; 

        macro = new Macro();
        macro.Name = 'test';
        insert macro;
        
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
        
         user1 = new User(
            Alias = 'TestUser'
            , Email='SysAdminTestuser@dkbmc.com'
            , EmailEncodingKey='UTF-8'
            , LastName='TestUser'
            , LanguageLocaleKey='en_US'
            , LocaleSidKey='en_US'
            , EmployeeNumber='AC100000'
            , TimeZoneSidKey='Asia/Seoul'
            , UserName='SysAdminTestuser@samsung.com'
            , ProfileId = pf.Id
        );
                                
        insert user1;
        

    }

    @isTest
    static void initCompTest() {        
        Map<String, Object> insertdata = new Map<String, Object>();

        insertdata.put('ParentId', macro.Id);
        insertdata.put('UserOrGroupId', user1.Id);
        insertdata.put('AccessLevel', 'Edit');
        insertdata.put('RowCause', 'Manual');

        Id insertId = ManualSharingController.insertData(macro.Id, JSON.serialize(insertdata));
        MacroShare ms = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM MacroShare WHERE UserOrGroupId = :user1.Id];
        System.assertEquals(ms.ParentId, macro.Id);
        System.assertEquals(ms.AccessLevel, 'Edit');

        insertdata = new Map<String, Object>();

        insertdata.put('ParentId', macro.Id);
        insertdata.put('UserOrGroupId', gr.Id);
        insertdata.put('AccessLevel', 'Read');
        insertdata.put('RowCause', 'Manual');

        ManualSharingController.insertData(macro.Id, JSON.serialize(insertdata));
        
        Map<String,Object> sharingList = ManualSharingController.getSharingData(macro.Id);

        List<Map<String,Object>> sResult = ManualSharingController.getSearchData('TestUser', 'User','');
        List<Map<String,Object>> rResult = ManualSharingController.getSearchData('New Role', 'Role','');
        List<Map<String,Object>> uResult = ManualSharingController.getSearchData('Test','PublicGroup','');//V1.1

        System.assertEquals(user1.LastName, sResult[0].get('Name'));
        System.assertEquals(urole.Name, rResult[0].get('Name'));

        Map<String, Object> updatedata = new Map<String, Object>();

        updatedata.put('Id', insertId);
        updatedata.put('AccessLevel', 'Read');

        ManualSharingController.updateData(macro.Id, JSON.serialize(updatedata));

        MacroShare ums = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM MacroShare WHERE UserOrGroupId = :user1.Id];
        System.assertEquals(ums.AccessLevel, 'Read');

        Boolean isAvailability = ManualSharingController.init(macro.Id);
        System.assertEquals(true, isAvailability);     

        ManualSharingController.deleteData(macro.Id, insertId);

        List<MacroShare> dms = [SELECT Id, ParentId, UserOrGroupId, AccessLevel, RowCause FROM MacroShare WHERE UserOrGroupId = :user1.Id];
        System.assertEquals(dms.size() , 0);
    }
    //V1.1 Start
    @isTest
    static void SalesLeadTest() {        
        Test.startTest();
        
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];

        member1 = new User(Alias = 'member1', Email='member1@samsung.com', 
                     EmailEncodingKey='UTF-8', LastName='member1', LanguageLocaleKey='en_US', 
                     LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
                     UserName='member1@samsung.com');

        insert member1;
        
        campaign1 = new Campaign(Name = 'test1');
        insert campaign1;
        
        costCenter = new CostCenter__c(CostCenterName__c = 'Test1', Name ='Test1');
        insert costCenter;
        sl = new Sales_Lead__c(
            Name = 'TestSalesLead', 
            LeadStatus__c = 'In Process',
            CampaignId__c = campaign1.Id,
            Company__c = 'Company__c',
            Email__c = 'tse@sdfjo.com.vop',
            LeadChannel__c='Demand',
            LeadStage__c = 'Hot',
            Amount__c = 5000, 
            CloseDate__c = Date.today().addDays(1),  
            RevenueEndDate__c = Date.today().addDays(3), 
            RevenueStartDate__c = Date.today().addDays(2),
            Budget__c = true,
            Authority__c = true,
            SalesDepartment__c = costCenter.Id
        );
		insert sl;

        Sales_Lead_Team__c slt = new Sales_Lead_Team__c(
            SalesLead_TeamMember__c = member1.Id, 
            AccessLevel__c = 'Read',
            Sales_Lead__c = sl.Id,
            Team_Role__c = 'Sales Rep'
        );
        
        insert slt;
        Sales_Lead__Share sLeadShare = new Sales_Lead__Share();
        sLeadShare.ParentId      = sl.Id;
        sLeadShare.UserOrGroupId = member1.Id; 
        sLeadShare.AccessLevel   = 'Read'; 
        sLeadShare.RowCause      = 'Manual';
        insert sLeadShare;
        
        Map<String, Object> updatedata = new Map<String, Object>();

        updatedata.put('Id', sLeadShare.Id);
        updatedata.put('AccessLevel','Edit');
		
        ManualSharingController.updateData(sl.Id, JSON.serialize(updatedata));
        //ManualSharingController.deleteData(sl.Id, sLeadShare.Id);
        slt.Id = null;
        sLeadShare.Id = null;
        //insert slt;
        insert sLeadShare;
        ManualSharingController.deleteDatas(sl.Id);
        Test.stopTest();
    }
    //V1.1 End
}