@isTest
public class RegistrationProposalPMController_Test {
    static User user1;
    static User user2;
    static User user3;
    static Account mdgAcc;
    static Company__c comp;
    static CostCenter__c cc;
    static Opportunity oppty;
   static Opportunity oppty1;

    
    static{
        user admin = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs (admin) {
			Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' OR Name = '시스템 관리자'];
            Profile p1 = [SELECT Id FROM Profile WHERE Name = 'Service Desk Agency'];

			list<User> userList = new list<User>();
			user1 = new User(Alias = 'standt1', Email='user0001@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0001@samsung.com');
			userList.add(user1);
            
            user2 = new User(Alias = 'standt2', Email='user0002@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0002@samsung.com');
			userList.add(user2);
            
            user3 = new User(Alias = 'standt3', Email='user0003@samsung.com', 
						EmailEncodingKey='UTF-8', LastName='Testing3', LanguageLocaleKey='en_US', 
						LocaleSidKey='en_US', ProfileId = p1.Id, TimeZoneSidKey='Asia/Seoul', 
						UserName='user0003@samsung.com');
			userList.add(user3);
            
            insert userList;
        }

		RecordType mdgRcdType = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType = 'Account' AND IsActive = TRUE AND Name LIKE '%MDG%'];
        mdgAcc = new Account(
			Name = 'Test MDG Account',
            AccountNumber = 'M1234567',
            mDomesticForeign__c = '20',
            mCountry__c = 'US',
            RecordTypeId = mdgRcdType.Id,
            MDGCheck__c = true
       	);
        insert mdgAcc;
        
        comp = new Company__c(
            Name = 'Test Company',
            CompanyCode__c = 'T100'
        );
        insert comp;
        
        cc = new CostCenter__c(
            Name = 'Test Cost Center', 
            Company__c = comp.Id,
            CompanyCode__c = 'T100', 
            Text2__c = '테스트'
        );
        insert cc;
        
        RecordType hqRcdType = [SELECT Id, Name, SobjectType FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'HQ'];
        List<Opportunity> opplst = new List<Opportunity>();
        oppty = new Opportunity(
            Name = 'Test Opportunity', 
            RecordTypeId = hqRcdType.Id,
            StageName = 'Z01', 
            AccountId = mdgAcc.Id, 
            OwnerId = user1.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            CloseDate = Date.today()
        );
        opplst.add(oppty);
            oppty1 = new Opportunity(
            Name = 'Test Opportunity1', 
            RecordTypeId = hqRcdType.Id,
            StageName = 'Z01', 
            AccountId = mdgAcc.Id, 
            OwnerId = user3.Id, 
            SalesDepartment__c = cc.Id, 
            cPrimarySalesDepartment__c = cc.Id, 
            CloseDate = Date.today()
        );
        opplst.add(oppty1);   
        
        insert opplst;
    }
    
    @isTest static void test_method_01(){
        Test.startTest();
        RegistrationProposalPMController.init(oppty.Id);
        RegistrationProposalPMController.proposalPMSave(oppty.Id, user2.Id);
        RegistrationProposalPMController.representativePMSave(oppty.Id, user2.Id);
        RegistrationProposalPMController.representativePMCheckProjectCode(oppty.Id);
        System.runAs(user2){
          RegistrationProposalPMController.representativePMCheckProjectCode(oppty1.Id);
           RegistrationProposalPMController.profilecheck(); 
        }
          System.runAs(user3){
          RegistrationProposalPMController.representativePMCheckProjectCode(oppty.Id);
           RegistrationProposalPMController.profilecheck(); 
        }

        Test.stopTest();
    }
}