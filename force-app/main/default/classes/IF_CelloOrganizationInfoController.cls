/**
* @description       : Receive Organization master information from Cello system.(IF-186)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-12-22 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-08-16   vikrant.ks@samsung.com   Initial Version(MySales 279)
* 1.1   2023-12-22   vikrant.ks@samsung.com   When receive AREA_CCD = 'H' (Korea) then put in 'T100' value in Companycode__c(MySales 390)
**/
@RestResource(urlMapping = '/IF186/*')
global class IF_CelloOrganizationInfoController{
   
    private static final String INTERFACE_ID = 'IF-186';
    private static final String APEX_CLASS   = 'IF_CelloOrganizationInfoController';
    private static final String METHOD_NAME  = 'ReceiveDatafromCello'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void ReceiveDatafromCello(){
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
            
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
            
            List<Company__c> CompList = new List<Company__c>([Select Id,CompanyCode__c from Company__c where CompanyCode__c != null]);
            Map<String,String> compMap = new Map<String,String>();
            For(Company__c comp:CompList){
                compMap.put(comp.CompanyCode__c,comp.Id);
            }
                        
            List<Organization__c> OrgList = new List<Organization__c>([select Id,Company__r.CompanyCode__c,Code__c from Organization__c]);
            Map<String,Organization__c> orgMap = new Map<String,Organization__c>();
            For(Organization__c org:OrgList){
                orgMap.put(org.Code__c,org);
            }
            
            List<Organization__c> OrgUpdateList = new List<Organization__c>();
            
             if(inputHeader != null && inputHeader.wksIaOrgSndIFvo != null && inputHeader.wksIaOrgSndIFvo.size() > 0){
                for(InputClass input:inputHeader.wksIaOrgSndIFvo){
                    
                    Organization__c temp = new Organization__c();
                    
                    if(input.ORG_ID != null && input.ORG_ID != '' && orgMap.containsKey(input.ORG_ID)){
                        System.debug('ORG_ID: '+orgMap.get(input.ORG_ID).Id);
                        temp.Id = orgMap.get(input.ORG_ID).Id;                     
                    } 
                    if(input.AREA_CCD != 'H'){//V1.1
                        if(!compMap.containsKey(input.PRNT_ORG_PATY_ID)){ 
                            CalloutException e = new CalloutException();
                            e.setmessage('Upsert failed. Invalid Company code: '+input.PRNT_ORG_PATY_ID+' : [PRNT_ORG_PATY_ID]');
                            throw e;
                        }
                        temp.Company__c = compMap.get(input.PRNT_ORG_PATY_ID);
                    }else{ //V1.1
                        temp.Company__c = compMap.get('T100');
                    }
                    temp.Code__c 		 = input.ORG_ID;
                    temp.Name 			 = input.ORG_NM;
                    temp.CurrencyIsoCode = input.CURR_CD;
                    temp.Region__c 		 = input.AREA_CCD;
                    temp.Status__c		 = input.DEL_YN;
                    
                    OrgUpdateList.add(temp);
                }   
                upsert OrgUpdateList;
        }   
            outHeader.RESULT = 'S';
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
            
        }catch(Exception e){
            
            outHeader.RESULT = 'F';
            String sendData          = JSON.serialize(outHeader);
            errorMsgList.add('Exception : ' + e.getMessage());

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
        public List<InputClass> wksIaOrgSndIFvo; 
    }
    
    public class InputClass{
        
        public String ORG_ID;
        public String ORG_NM;	
        public String CURR_CD;	
        public String AREA_CCD;	
        public String PRNT_ORG_PATY_ID;	
        public String DEL_YN;
    }
    
}