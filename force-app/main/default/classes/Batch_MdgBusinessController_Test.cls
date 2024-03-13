/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-08-20
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-12-21   ghkil@partner.samsung.com   Initial Version
**/
@isTest
public class Batch_MdgBusinessController_Test {

    // Batch_MdgBusinessController 테스트 클래스
    // private final String INTERFACE_ID = 'IF-109';
    // private final String APEX_CLASS   = 'Batch_MdgBusinessController'; 
    // private final String METHOD_NAME  = 'Batch';

    public Batch_MdgBusinessController_Test() {    }

    @TestSetup
    static void makeData(){
        
        List<MDGBusinessMaster__c> mdgBusinessMasterList = new List<MDGBusinessMaster__c>();

        MDGBusinessMaster__c businessData = new MDGBusinessMaster__c();

        // Business Data 입력
        businessData.CLASS__c = 'biz001';
        businessData.HCLAS__c = 'X';
        businessData.KLAGR__c = 'XX';
        businessData.VONDT__c = '20201201';
        businessData.BISDT__c = '99991231';
        businessData.USEYN__c = 'Y';
        businessData.IFType__c = 'Business';
        businessData.ExternalId__c  = 'Business' + '|' + 'biz001' + '|' + 'X'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        businessData.IFFlag__c = 'I';
        businessData.ZZTECH_YN__c = 'Y';
        

        mdgBusinessMasterList.add(businessData);

        // Service Data 입력
        MDGBusinessMaster__c serviceData = new MDGBusinessMaster__c();

        serviceData.CLASS__c = 'svc001';
        serviceData.HCLAS__c = 'biz001';
        serviceData.KLAGR__c = 'X';
        serviceData.VONDT__c = '20201201';
        serviceData.BISDT__c = '99991231';
        serviceData.USEYN__c = 'Y';
        serviceData.SRVBNC__c = 'svc3';
        serviceData.SRVBNT__c = 'svc4';
        serviceData.SRVDPC__c = 'svc5';
        serviceData.SRVDPT__c = 'svc6';
        serviceData.IFType__c = 'Service';
        serviceData.ExternalId__c  = 'Service' + '|' + 'svc001' + '|' + 'biz001'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        serviceData.IFFlag__c = 'I';
        serviceData.ZZTECH_YN__c = 'Y';

        mdgBusinessMasterList.add(serviceData);

        MDGBusinessMaster__c serviceData2 = new MDGBusinessMaster__c();

        serviceData2.CLASS__c = 'svc002';
        serviceData2.HCLAS__c = 'biz001';
        serviceData2.KLAGR__c = 'X';
        serviceData2.VONDT__c = '20201201';
        serviceData2.BISDT__c = '99991231';
        serviceData2.USEYN__c = 'Y';
        serviceData2.SRVBNC__c = 'svc3';
        serviceData2.SRVBNT__c = 'svc4';
        serviceData2.SRVDPC__c = 'svc5';
        serviceData2.SRVDPT__c = 'svc6';
        serviceData2.IFType__c = 'Service';
        serviceData2.ExternalId__c  = 'Service' + '|' + 'svc002' + '|' + 'biz001'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        serviceData2.IFFlag__c = 'I';
        serviceData2.ZZTECH_YN__c = '';

        mdgBusinessMasterList.add(serviceData2);

        // Solution Data 입력
        MDGBusinessMaster__c solutionData = new MDGBusinessMaster__c();

        solutionData.CLASS__c = 'sol001';
        solutionData.HCLAS__c = 'svc001';
        solutionData.KLAGR__c = 'X';
        solutionData.VONDT__c = '20201201';
        solutionData.BISDT__c = '99991231';
        solutionData.USEYN__c = 'Y';
        solutionData.SOLTY__c = '10';
        solutionData.PRDYN__c = 'Y';
        solutionData.SOLMNC__c = 'sol-1';
        solutionData.SOLMNT__c = 'sol-11';
        solutionData.SOLDPC__c = 'sol-111';
        solutionData.SOLDPT__c = 'sol-1111';
        solutionData.BRAND__c = 'X';
        solutionData.COMPC__c = 'sol-11111';
        solutionData.PLLEV__c = 'o';
        solutionData.PLCST__c = 'A';
        solutionData.LODAT__c = 'sol-111111';
        solutionData.EOPDT__c = 'sol-1111111';
        solutionData.EOSDT__c = 'sol-11111111';
        solutionData.IFType__c = 'Solution';
        solutionData.ExternalId__c  = 'Solution' + '|' + 'sol001' + '|' + 'svc001'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        solutionData.IFFlag__c = 'I';

        mdgBusinessMasterList.add(solutionData);

        MDGBusinessMaster__c solutionData2 = new MDGBusinessMaster__c();

        solutionData2.CLASS__c = 'sol002';
        solutionData2.HCLAS__c = 'svc011';
        solutionData2.KLAGR__c = 'X';
        solutionData2.VONDT__c = '20201201';
        solutionData2.BISDT__c = '99991231';
        solutionData2.USEYN__c = 'Y';
        solutionData2.SOLTY__c = '10';
        solutionData2.PRDYN__c = 'Y';
        solutionData2.SOLMNC__c = 'sol-1';
        solutionData2.SOLMNT__c = 'sol-11';
        solutionData2.SOLDPC__c = 'sol-111';
        solutionData2.SOLDPT__c = 'sol-1111';
        solutionData2.BRAND__c = 'X';
        solutionData2.COMPC__c = 'sol-11111';
        solutionData2.PLLEV__c = 'o';
        solutionData2.PLCST__c = 'A';
        solutionData2.LODAT__c = 'sol-111111';
        solutionData2.EOPDT__c = 'sol-1111111';
        solutionData2.EOSDT__c = 'sol-11111111';
        solutionData2.IFType__c = 'Solution';
        solutionData2.ExternalId__c  = 'Solution' + '|' + 'sol002' + '|' + 'svc011'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        solutionData2.IFFlag__c = 'I';

        mdgBusinessMasterList.add(solutionData2);        

        // ClassDesc Data 입력
        MDGBusinessMaster__c classDescData = new MDGBusinessMaster__c();

        classDescData.CLASS__c = 'biz001';
        classDescData.SPRAS__c = 'E';
        classDescData.KLAGR__c = 'X';
        classDescData.KSCHL__c = 'biz001 English Name2';
        classDescData.NORMB__c = 'X';
        classDescData.IFType__c = 'ClassDesc';
        classDescData.ExternalId__c  = 'ClassDesc' + '|' + 'biz001' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData);

        MDGBusinessMaster__c classDescData2 = new MDGBusinessMaster__c();

        classDescData2.CLASS__c = 'svc001';
        classDescData2.SPRAS__c = 'E';
        classDescData2.KLAGR__c = 'X';
        classDescData2.KSCHL__c = 'svc001 English Name';
        classDescData2.NORMB__c = 'X';
        classDescData2.IFType__c = 'ClassDesc';
        classDescData2.ExternalId__c  = 'ClassDesc' + '|' + 'svc001' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData2.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData2);

        MDGBusinessMaster__c classDescData3 = new MDGBusinessMaster__c();

        classDescData3.CLASS__c = 'sol001';
        classDescData3.SPRAS__c = 'E';
        classDescData3.KLAGR__c = 'X';
        classDescData3.KSCHL__c = 'sol001 English Name';
        classDescData3.NORMB__c = 'X';
        classDescData3.IFType__c = 'ClassDesc';
        classDescData3.ExternalId__c  = 'ClassDesc' + '|' + 'sol001' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData3.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData3);

        MDGBusinessMaster__c classDescData4 = new MDGBusinessMaster__c();

        classDescData4.CLASS__c = 'biz100';
        classDescData4.SPRAS__c = 'E';
        classDescData4.KLAGR__c = 'X';
        classDescData4.KSCHL__c = 'biz100 English Name';
        classDescData4.NORMB__c = 'X';
        classDescData4.IFType__c = 'ClassDesc';
        classDescData4.ExternalId__c  = 'ClassDesc' + '|' + 'biz100' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData4.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData4);

        upsert mdgBusinessMasterList ExternalId__c;

        system.debug('mdgBusinessMasterList : ' + mdgBusinessMasterList.size());
    }

    @isTest
    static void testBatch() {

        List<MDGBusinessMaster__c> mdgBusinessMasterList = new List<MDGBusinessMaster__c>();

        MDGBusinessMaster__c businessData = new MDGBusinessMaster__c();

        // Service Data 입력
        MDGBusinessMaster__c serviceData = new MDGBusinessMaster__c();

        serviceData.CLASS__c = 'svc100';
        serviceData.HCLAS__c = 'biz100';
        serviceData.KLAGR__c = 'X';
        serviceData.VONDT__c = '20201201';
        serviceData.BISDT__c = '99991231';
        serviceData.USEYN__c = 'Y';
        serviceData.SRVBNC__c = 'svc3';
        serviceData.SRVBNT__c = 'svc4';
        serviceData.SRVDPC__c = 'svc5';
        serviceData.SRVDPT__c = 'svc6';
        serviceData.IFType__c = 'Service';
        serviceData.ExternalId__c  = 'Service' + '|' + 'svc100' + '|' + 'biz100'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        serviceData.IFFlag__c = 'I';
        serviceData.ZZTECH_YN__c = 'Y';

        mdgBusinessMasterList.add(serviceData);

        // Solution Data 입력
        MDGBusinessMaster__c solutionData = new MDGBusinessMaster__c();

        solutionData.CLASS__c = 'sol100';
        solutionData.HCLAS__c = 'svc100';
        solutionData.KLAGR__c = 'X';
        solutionData.VONDT__c = '20201201';
        solutionData.BISDT__c = '99991231';
        solutionData.USEYN__c = 'Y';
        solutionData.SOLTY__c = '10';
        solutionData.PRDYN__c = 'Y';
        solutionData.SOLMNC__c = 'sol-1';
        solutionData.SOLMNT__c = 'sol-11';
        solutionData.SOLDPC__c = 'sol-111';
        solutionData.SOLDPT__c = 'sol-1111';
        solutionData.BRAND__c = 'X';
        solutionData.COMPC__c = 'sol-11111';
        solutionData.PLLEV__c = 'o';
        solutionData.PLCST__c = 'A';
        solutionData.LODAT__c = 'sol-111111';
        solutionData.EOPDT__c = 'sol-1111111';
        solutionData.EOSDT__c = 'sol-11111111';
        solutionData.IFType__c = 'Solution';
        solutionData.ExternalId__c  = 'Solution' + '|' + 'sol100' + '|' + 'svc100'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        solutionData.IFFlag__c = 'I';

        mdgBusinessMasterList.add(solutionData);

        // ClassDesc Data 입력
        MDGBusinessMaster__c classDescData1 = new MDGBusinessMaster__c();

        classDescData1.CLASS__c = 'svc002';
        classDescData1.SPRAS__c = 'K';
        classDescData1.KLAGR__c = 'X';
        classDescData1.KSCHL__c = 'svc002 한글 이름';
        classDescData1.NORMB__c = 'X';
        classDescData1.IFType__c = 'ClassDesc';
        classDescData1.ExternalId__c  = 'ClassDesc' + '|' + 'svc002' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData1.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData1);

        MDGBusinessMaster__c classDescData2 = new MDGBusinessMaster__c();

        classDescData2.CLASS__c = 'sol002';
        classDescData2.SPRAS__c = 'K';
        classDescData2.KLAGR__c = 'X';
        classDescData2.KSCHL__c = 'sol002 한글 이름';
        classDescData2.NORMB__c = 'X';
        classDescData2.IFType__c = 'ClassDesc';
        classDescData2.ExternalId__c  = 'ClassDesc' + '|' + 'sol002' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData2.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData2);

        upsert mdgBusinessMasterList ExternalId__c;

        Test.startTest();

        Id batchJobId = Database.executeBatch(new Batch_MdgBusinessController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch_update() {

        List<MDGBusinessMaster__c> mdgBusinessMasterList = new List<MDGBusinessMaster__c>();

        MDGBusinessMaster__c businessData = new MDGBusinessMaster__c();

        // Business Data 입력
        businessData.CLASS__c = 'biz001';
        businessData.HCLAS__c = 'X';
        businessData.KLAGR__c = 'XX';
        businessData.VONDT__c = '20201201';
        businessData.BISDT__c = '99991231';
        businessData.USEYN__c = 'N';
        businessData.IFType__c = 'Business';
        businessData.ExternalId__c  = 'Business' + '|' + 'biz001' + '|' + 'X'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        businessData.IFFlag__c = 'S';
        businessData.ZZTECH_YN__c = 'Y';

        mdgBusinessMasterList.add(businessData);

        // Service Data 입력
        MDGBusinessMaster__c serviceData = new MDGBusinessMaster__c();

        serviceData.CLASS__c = 'svc001';
        serviceData.HCLAS__c = 'biz001';
        serviceData.KLAGR__c = 'X';
        serviceData.VONDT__c = '20201201';
        serviceData.BISDT__c = '99991231';
        serviceData.USEYN__c = 'N';
        serviceData.SRVBNC__c = 'svc3';
        serviceData.SRVBNT__c = 'svc4';
        serviceData.SRVDPC__c = 'svc5';
        serviceData.SRVDPT__c = 'svc6';
        serviceData.IFType__c = 'Service';
        serviceData.ExternalId__c  = 'Service' + '|' + 'svc001' + '|' + 'biz001'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        serviceData.IFFlag__c = 'S';
        serviceData.ZZTECH_YN__c = '';

        mdgBusinessMasterList.add(serviceData);

        MDGBusinessMaster__c serviceData2 = new MDGBusinessMaster__c();

        serviceData2.CLASS__c = 'svc111';
        serviceData2.HCLAS__c = 'biz111';
        serviceData2.KLAGR__c = 'X';
        serviceData2.VONDT__c = '20201201';
        serviceData2.BISDT__c = '99991231';
        serviceData2.USEYN__c = 'N';
        serviceData2.SRVBNC__c = 'svc3';
        serviceData2.SRVBNT__c = 'svc4';
        serviceData2.SRVDPC__c = 'svc5';
        serviceData2.SRVDPT__c = 'svc6';
        serviceData2.IFType__c = 'Service';
        serviceData2.ExternalId__c  = 'Service' + '|' + 'svc111' + '|' + 'biz111'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        serviceData2.IFFlag__c = 'S';

        mdgBusinessMasterList.add(serviceData2);

        // Solution Data 입력
        MDGBusinessMaster__c solutionData = new MDGBusinessMaster__c();

        solutionData.CLASS__c = 'sol001';
        solutionData.HCLAS__c = 'svc001';
        solutionData.KLAGR__c = 'X';
        solutionData.VONDT__c = '20201201';
        solutionData.BISDT__c = '99991231';
        solutionData.USEYN__c = 'N';
        solutionData.SOLTY__c = '10';
        solutionData.PRDYN__c = 'N';
        solutionData.SOLMNC__c = 'sol-1';
        solutionData.SOLMNT__c = 'sol-11';
        solutionData.SOLDPC__c = 'sol-111';
        solutionData.SOLDPT__c = 'sol-1111';
        solutionData.BRAND__c = 'X';
        solutionData.COMPC__c = 'sol-11111';
        solutionData.PLLEV__c = 'o';
        solutionData.PLCST__c = 'A';
        solutionData.LODAT__c = 'sol-111111';
        solutionData.EOPDT__c = 'sol-1111111';
        solutionData.EOSDT__c = 'sol-11111111';
        solutionData.IFType__c = 'Solution';
        solutionData.ExternalId__c  = 'Solution' + '|' + 'sol001' + '|' + 'svc001'; // ExternalId (데이터 타입 + CLASS + HCLAS)
        solutionData.IFFlag__c = 'S';

        mdgBusinessMasterList.add(solutionData);

        // ClassDesc Data 입력
        MDGBusinessMaster__c classDescData = new MDGBusinessMaster__c();

        classDescData.CLASS__c = 'biz001';
        classDescData.SPRAS__c = 'K';
        classDescData.KLAGR__c = 'X';
        classDescData.KSCHL__c = 'biz001 한글 이름';
        classDescData.NORMB__c = 'X';
        classDescData.IFType__c = 'ClassDesc';
        classDescData.ExternalId__c  = 'ClassDesc' + '|' + 'biz001' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData.IFFlag__c = 'S';

        mdgBusinessMasterList.add(classDescData);

        MDGBusinessMaster__c classDescData2 = new MDGBusinessMaster__c();

        classDescData2.CLASS__c = 'svc001';
        classDescData2.SPRAS__c = 'K';
        classDescData2.KLAGR__c = 'X';
        classDescData2.KSCHL__c = 'svc001 한글 이름';
        classDescData2.NORMB__c = 'X';
        classDescData2.IFType__c = 'ClassDesc';
        classDescData2.ExternalId__c  = 'ClassDesc' + '|' + 'svc001' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData2.IFFlag__c = 'S';

        mdgBusinessMasterList.add(classDescData2);

        MDGBusinessMaster__c classDescData22 = new MDGBusinessMaster__c();

        classDescData22.CLASS__c = 'svc002';
        classDescData22.SPRAS__c = 'K';
        classDescData22.KLAGR__c = 'X';
        classDescData22.KSCHL__c = 'svc002 한글 이름';
        classDescData22.NORMB__c = 'X';
        classDescData22.IFType__c = 'ClassDesc';
        classDescData22.ExternalId__c  = 'ClassDesc' + '|' + 'svc002' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData22.IFFlag__c = 'S';

        mdgBusinessMasterList.add(classDescData22);

        MDGBusinessMaster__c classDescData3 = new MDGBusinessMaster__c();

        classDescData3.CLASS__c = 'sol003';
        classDescData3.SPRAS__c = 'K';
        classDescData3.KLAGR__c = 'X';
        classDescData3.KSCHL__c = 'sol003 한글 이름';
        classDescData3.NORMB__c = 'X';
        classDescData3.IFType__c = 'ClassDesc';
        classDescData3.ExternalId__c  = 'ClassDesc' + '|' + 'sol003' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData3.IFFlag__c = 'S';

        mdgBusinessMasterList.add(classDescData3);

        upsert mdgBusinessMasterList ExternalId__c;
        // Insert mdgBusinessMasterList;

        system.debug('mdgBusinessMasterList : ' + mdgBusinessMasterList.size());

        Test.startTest();

        Id batchJobId = Database.executeBatch(new Batch_MdgBusinessController(), 2000);

        Test.stopTest();
    }

    @isTest
    static void testBatch_ClassDescOnly() {

        // Business__c Data 입력
        Business__c saveBusinessData = new Business__c(
            Name = 'biz005 Name',
            Code__c = 'biz005'
        );

        Insert saveBusinessData;        

        // Master_Service__c Data 입력
        Master_Service__c saveServiceMasterData = new Master_Service__c(
            Name = 'svc005 Name',
            Code__c = 'svc005'
        );

        Insert saveServiceMasterData;

        // Master_Solution__c Data 입력
        Master_Solution__c saveSolutionMasterData = new Master_Solution__c(
            Name = 'sol005 Name',
            Code__c = 'sol005'
        );

        Insert saveSolutionMasterData;

        List<MDGBusinessMaster__c> mdgBusinessMasterList = new List<MDGBusinessMaster__c>();

        // ClassDesc Data 입력
        MDGBusinessMaster__c classDescData = new MDGBusinessMaster__c();

        classDescData.CLASS__c = 'biz005';
        classDescData.SPRAS__c = 'E';
        classDescData.KLAGR__c = 'X';
        classDescData.KSCHL__c = 'biz005 English Name';
        classDescData.NORMB__c = 'X';
        classDescData.IFType__c = 'ClassDesc';
        classDescData.ExternalId__c  = 'ClassDesc' + '|' + 'biz005' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData);

        MDGBusinessMaster__c classDescData2 = new MDGBusinessMaster__c();

        classDescData2.CLASS__c = 'svc005';
        classDescData2.SPRAS__c = 'E';
        classDescData2.KLAGR__c = 'X';
        classDescData2.KSCHL__c = 'svc005 English Name';
        classDescData2.NORMB__c = 'X';
        classDescData2.IFType__c = 'ClassDesc';
        classDescData2.ExternalId__c  = 'ClassDesc' + '|' + 'svc005' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData2.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData2);

        MDGBusinessMaster__c classDescData3 = new MDGBusinessMaster__c();

        classDescData3.CLASS__c = 'sol005';
        classDescData3.SPRAS__c = 'E';
        classDescData3.KLAGR__c = 'X';
        classDescData3.KSCHL__c = 'sol005 English Name';
        classDescData3.NORMB__c = 'X';
        classDescData3.IFType__c = 'ClassDesc';
        classDescData3.ExternalId__c  = 'ClassDesc' + '|' + 'sol005' + '|' + ''; // ExternalId (데이터 타입 + CLASS + HCLAS)
        classDescData3.IFFlag__c = 'I';

        mdgBusinessMasterList.add(classDescData3);

        upsert mdgBusinessMasterList ExternalId__c;

        Test.startTest();

        Id batchJobId = Database.executeBatch(new Batch_MdgBusinessController(), 2000);

        Test.stopTest();
    }
}