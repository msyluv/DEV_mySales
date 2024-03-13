/**
* @description       : 
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-02-21
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2024-02-21    vikrant.ks@samsung.com   Initial Version(MySales 447)
**/
@RestResource(urlMapping = '/forecast/*')
global class IF_ForecastController{
    private static final String INTERFACE_ID = 'IF-188';
    private static final String APEX_CLASS   = 'IF_ForecastController';
    private static final String METHOD_NAME  = 'ReceiveForecastData'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveForecastData(){
        
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
            
            if(reqBody == null || reqBody.toString() == '{}') {
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Request format is incorrect.'});
                ifLog.createLog(interfaceLog);
                return;      
            }
            inputJsonData = reqBody.toString();
            ifLog.addLog('HttpRequest : ' + inputJsonData); 
            System.debug('HttpRequest: ' + inputJsonData);
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
           
            if(inputHeader.bo_code == null || inputHeader.bo_name == null || inputHeader.company_code == null || inputHeader.forecast_version == null || inputHeader.YYYY_MM == null || inputHeader.bo_code == '' || inputHeader.bo_name == '' || inputHeader.company_code == '' || inputHeader.forecast_version == '' || inputHeader.YYYY_MM == ''){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Required fields are missing.'});
                ifLog.createLog(interfaceLog);
                return;
            }
            
            List<FORECAST__c> FORECASTID = new List<FORECAST__c>([Select Id from FORECAST__c where BOCode__c = :inputHeader.bo_code and BOName__c = :inputHeader.bo_name and Companycode__c = :inputHeader.company_code and forecast_version__c = :inputHeader.forecast_version and YYYY_MM__c = :inputHeader.YYYY_MM]);// Opportunity__c = :inputHeader.opportunity_id
                        
            FORECAST__c temp = new FORECAST__c();
            
            if(FORECASTID.size()>0){
                temp.Id = FORECASTID[0].Id;
            }
                        
            if(inputHeader.contract != null && inputHeader.contract != ''){
                temp.contract__c = Decimal.valueOf(inputHeader.contract);
            }else{
                temp.contract__c = Null;
            }
            if(inputHeader.sales != null && inputHeader.sales != ''){
                temp.sales__c = Decimal.valueOf(inputHeader.sales);
            }else{
                temp.sales__c = Null;
            }
            
            temp.BOCode__c = inputHeader.bo_code;
            temp.BOName__c = inputHeader.bo_name;
            temp.Companycode__c = inputHeader.company_code;
            temp.Curr__c = inputHeader.Curr;
            temp.YYYY_MM__c = inputHeader.YYYY_MM;
            temp.forecast_version__c = inputHeader.forecast_version;
            temp.Opportunity__c = inputHeader.opportunity_id; 
            
            upsert temp;
            
            List<Opportunity> oppID = new List<Opportunity>([Select Id,Forecast__c from Opportunity where OpportunityCode__c = :inputHeader.bo_code and CompanyCode__c = :inputHeader.company_code limit 1]);
            if(oppID.size()>0){
                if(oppID[0].Forecast__c == False){
                    oppID[0].Forecast__c = True;
                    update oppID;
                }
            }
            outHeader.RESULT = 'S';
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e){
            
            outHeader.RESULT = 'F';
            String sendData          = JSON.serialize(outHeader);
            errorMsgList.add('Exception: ' + e.getMessage());
			System.debug('Exception: ' + e.getMessage());
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e); 
        }
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        

        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));

    }
    
	public class OutputHeader{
        public String RESULT;
    }
    
    public class InputHeader{
        
        public String bo_code;
        public String bo_name;
        public String company_code;
        public String opportunity_id;
        public String forecast_version;
        public String YYYY_MM;
        public String Curr;
        public String sales;
        public String contract;
    }
}