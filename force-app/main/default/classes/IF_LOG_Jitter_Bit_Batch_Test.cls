/**
* @description       : Email for If Logs of jitter bit error
* @author            : 
* @group             : 
* @last modified on  : 07-28-2023
* @last modified by  : Kajal.c@samsung.com
* Modifications Log 
* Ver   Date         Author            		Modification
* 1.0   07-28-2023     Kajal.c@samsung.com  Initial Version(MySales -457)
**/
@isTest(SeeAllData=false)
public class IF_LOG_Jitter_Bit_Batch_Test {
    static final String INTERFACE_ID = 'IF_LOG_Jitter_Bit';
    static final String APEX_CLASS   = 'IF_LOG_Jitter_Bit_Batch';
    static final String METHOD_NAME  = 'Execute';
    static String guId = IF_Util.generateGuid();
    
    @TestSetup
    static void setData(){
        
        List<String> errorMsgList = new List<String>();  
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        errorMsgList.add('Communication Error StatusCode : 504');
        interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, 'reqMsg', 'resMsg', errorMsgList);
        ifLog.createLog(interfaceLog);
    }
	@isTest
    public static void IFLOG_JitterBit_BatchTest_1(){
        Test.startTest();
		DataBase.executeBatch(new IF_LOG_Jitter_Bit_Batch(), 200); 
        Test.stopTest();
    }
    @isTest
    public static void IFLOG_JitterBit_BatchTest_2(){
        Test.startTest();
        IF_LOG_Jitter_Bit_Batch IF_Batch = new IF_LOG_Jitter_Bit_Batch();
		String sch = '20 30 8 10 2 ?';
		String jobID = System.schedule('IF_Batch Job', sch, IF_Batch);
        Test.stopTest();
    }
}