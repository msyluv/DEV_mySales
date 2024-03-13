/**
* @description       : 
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-02-16
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date          Author                   Modification
* 1.0   2024-02-16    vikrant.ks@samsung.com   Initial Version(MySales 447)
**/
@RestResource(urlMapping = '/deliveryprob/*')//IF187
global class IF_DeliveryProbabilityController{
    private static final String INTERFACE_ID = 'IF-187';
    private static final String APEX_CLASS   = 'IF_DeliveryProbabilityController';
    private static final String METHOD_NAME  = 'ReceiveDatafromDashboard'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveDatafromDashboard(){
        
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
            if(inputHeader.BOCode == null || inputHeader.BOName == null  || inputHeader.Companycode == null || inputHeader.BOCode == '' || inputHeader.BOName == ''  || inputHeader.Companycode == ''){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Required fields are missing.'});
                ifLog.createLog(interfaceLog);
                return;
            }/*
            List<Opportunity> opp = [Select Id from Opportunity where Opportunitycode__c = :inputHeader.BOCode and Name = :inputHeader.BOName and CompanyCode__c =:inputHeader.Companycode];
            if(opp.size()==0){
                outHeader.RESULT = 'F';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader),new List<String>{'Opportunity Doesn\'t Exist.'});
                ifLog.createLog(interfaceLog);
                return;
            }*/
            List<Delivery_Probabiliy__c> DPId = new List<Delivery_Probabiliy__c>([Select Id from Delivery_Probabiliy__c where Opportunity__c = :inputHeader.opportunity_id]);
            
            //List<User> UserID = [Select Id from User where Name = :inputHeader.Modifiedby];
            
            Delivery_Probabiliy__c temp = new Delivery_Probabiliy__c();
            
            if(DPId.size()>0){
                temp.Id = DPId[0].Id;
            }else{ 
                temp.Opportunity__c = inputHeader.opportunity_id; 
            }
                        
            if(inputHeader.Probability != null && inputHeader.Probability != ''){
                temp.Probability__c = Decimal.valueOf(inputHeader.Probability);
            }else{
                temp.Probability__c = Null;
            }
            
            if(inputHeader.prob_reg_date != null && inputHeader.prob_reg_date != ''){
                temp.prob_reg_date__c     = Date.valueOf(inputHeader.prob_reg_date);}
            else{
                temp.prob_reg_date__c = null;
            }
            if(inputHeader.prob_mod_date != null && inputHeader.prob_mod_date != ''){
                temp.prob_mod_date__c     = Date.valueOf(inputHeader.prob_mod_date);}
            else{
                temp.prob_mod_date__c = null;
            }
            if(inputHeader.act_reg_date != null && inputHeader.act_reg_date != ''){
                temp.act_reg_date__c     = Date.valueOf(inputHeader.act_reg_date);}
            else{
                temp.act_reg_date__c = null;
            }
			if(inputHeader.act_mod_date != null && inputHeader.act_mod_date != ''){
                temp.act_mod_date__c     = Date.valueOf(inputHeader.act_mod_date);}
            else{
                temp.act_mod_date__c = null;
            }
            
            temp.DeliveryActivity__c = inputHeader.Activity;
            temp.prob_regby__c = inputHeader.prob_regby;
            temp.prob_Modifiedby__c = inputHeader.prob_Modifiedby;
            temp.act_regby__c = inputHeader.act_regby;
            temp.act_Modifiedby__c = inputHeader.act_Modifiedby;
            
            /*if(UserID.size()>0){
                temp.LastModifiedById = UserID[0].Id;
            }else{
                temp.LastModifiedById = Null;
            }*/
            String s = inputHeader.BOCode;
            temp.TXP_Link__c = 'http://txp.sds.samsung.net/front/#/management/?busn='+s.substring(4,s.length()-1);
            temp.Companycode__c = inputHeader.Companycode;
            temp.Dashboardlink__c = 'http://bos.sds.samsung.net/app/detail?orderId='+inputHeader.BOCode+'&sapCompany='+inputHeader.Companycode+'&lang=ko';
            
            upsert temp;
            
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
        
        public String BOCode;
        public String BOName;
        public String Probability;
        public String Activity;
        public String Companycode;
        public String opportunity_id;
        public String prob_regby;
        public String prob_reg_date;
        public String prob_Modifiedby;
        public String prob_mod_date;
        public String act_regby;
        public String act_reg_date;
        public String act_Modifiedby;
        public String act_mod_date;
    }
}