/**
* @description       : 
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-03-08
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2024-03-08    vikrant.ks@samsung.com   Initial Version(MySales 468)
**/
@RestResource(urlMapping = '/IF189/*')
global class IF_BusinessPriorityInfoController{
    private static final String INTERFACE_ID = 'IF-189';
    private static final String APEX_CLASS   = 'IF_BusinessPriorityInfoController';
    private static final String METHOD_NAME  = 'ReceiveBusinessPriorityData'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveBusinessPriorityData(){
        
        OutputHeader outHeader   = new OutputHeader();
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        
		RestResponse rep = RestContext.response;
        String inputJsonData;
        
        
		ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
		try
        {
            RestRequest req = RestContext.request;
            Blob    reqBody = req.requestBody;
            rep.addHeader('Content-Type', 'application/json');
            
            if(reqBody == null || reqBody.toString() == '{}'){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Request format is incorrect.'});
                ifLog.createLog(interfaceLog);
                return;      
            }
            inputJsonData = reqBody.toString();
            InputClass inputClass = (InputClass) JSON.deserialize(inputJsonData, InputClass.class);
            InputHeader inputHeader = (InputHeader)inputClass.API_1_request;
           
            if(inputHeader.ZZCCODE == null || inputHeader.BUKRS == null || inputHeader.ZZCCODE == '' || inputHeader.BUKRS == ''){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Required fields are missing.'});
                ifLog.createLog(interfaceLog);
                return;
            }
			List<Opportunity> OpportunityList = new List<Opportunity>([Select Id,Business_Importance__c,Business_Priority__c,Probability_new__c from Opportunity where OpportunityCode__c = :inputHeader.ZZCCODE and CompanyCode__c = :inputHeader.BUKRS limit 1]);
            if(OpportunityList.size()>0){
                Opportunity temp = OpportunityList[0];
                
                if(inputHeader.BUSINESS_IMPORTANCE != null && inputHeader.BUSINESS_IMPORTANCE != ''){
                    temp.Business_Importance__c = Decimal.valueOf(inputHeader.BUSINESS_IMPORTANCE);
                }else{
                    temp.Business_Importance__c = Null;
                }
                
                if(inputHeader.TOTAL_SCORE != null && inputHeader.TOTAL_SCORE != ''){
                    temp.Business_Priority__c = Decimal.valueOf(inputHeader.TOTAL_SCORE);
                }else{
                    temp.Business_Priority__c = Null;
                }
                
                if(inputHeader.ORDER_PROBABILITY != null && inputHeader.ORDER_PROBABILITY != ''){
                    temp.Probability_new__c = Decimal.valueOf(inputHeader.ORDER_PROBABILITY);
                }else{
                    temp.Probability_new__c = Null;
                }
                
                update temp;
            }
            else{
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'No Opportunity exists for this combination of BO Code and Company Code.'});
                ifLog.createLog(interfaceLog);
                return;
            }
            
            outHeader.RESULT = 'S';
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e){
            System.debug('Exception: ' + e.getMessage());
            outHeader.RESULT = 'F';
            String sendData  = JSON.serialize(outHeader);
            errorMsgList.add('Exception: ' + e.getMessage());
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e); 
        }
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));

    }
    
	public class OutputHeader{
        public String RESULT;
    }
    public class InputClass{
        public InputHeader API_1_request;
    }
    public class InputHeader{
        public String ZZCCODE;
        public String BUKRS;
        public String ORDER_PROBABILITY;
        public String BUSINESS_IMPORTANCE;
        public String TOTAL_SCORE;
        public String DELETE_FLAG;// Null : Not deleted, X : Deleted.
    }
}