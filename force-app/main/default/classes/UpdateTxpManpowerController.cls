/**
* @description       : Send BO Records and Receive Records of TXPmanpower Object from Jitterbit for UPSERT Operation(IF-184)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-11-15
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-11-15   vikrant.ks@samsung.com   Initial Version(MySales 356)
**/
public class UpdateTxpManpowerController {
    private static final String INTERFACE_ID = 'IF-184';
    private static final String APEX_CLASS   = 'IF_TXPManpowerInfoController';
    private static final String METHOD_NAME  = 'SendTXPManpowerInfo';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    @Future(callout=true)
    public static void SendTXPManpowerInfo(Set<String> BoList){
        
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        try{
                       
            List<OutputClass> outputList = new List<OutputClass>();   
            
            List<opportunity> oppList = [select opportunitycode__c, companycode__c, ProposalPM__r.EvEmpNO__c,RepresentativePM__r.EvEmpNO__c from opportunity where opportunitycode__c IN :BoList];
            for(opportunity opp:oppList){
                OutputClass out  = new OutputClass();
                out.BO_CODE      = opp.opportunitycode__c;
                out.Company_Code = opp.companycode__c;
                out.Proposal_PM  = opp.ProposalPM__r.EvEmpNO__c;
                out.Exec_PM      = opp.RepresentativePM__r.EvEmpNO__c;
                
                outputList.add(out); 
            }
            ifLog.addLog('Opportunity Count: '+String.valueOf(outputList.size()));
            
            //#######################--------------- HTTP CALLOUT --------------#######################################
            
            IF_Callout call = new IF_Callout(INTERFACE_ID);
        
            OutputHeader output = new OutputHeader();
            InputHeader inputHeader = new InputHeader();
            
            Output.Opportunity_mySales = outputList;
            String jsonBody = JSON.serialize(output);
            HttpResponse response;
            
            Integer errorCount = 3;
            while(errorCount > 0){
            	resMap = call.httpCallout(jsonBody, '');
                response = (HttpResponse)resMap.get('HttpResponse');
                if(response.getStatusCode() != 200 || response.getBody() == null || response.getBody() == ''){
                    errorCount--;
                }
                else{ break;}
            }
            
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
            
            response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response.getBody: '+response.getBody());
            if(response.getStatusCode() == 200){//Test.isRunningTest()
                inputHeader = (InputHeader)JSON.deserialize(response.getBody(),InputHeader.class);    
            }else {
				throw new CustomException('{"status":'+ String.valueOf(response.getStatusCode()) +', "message":'+ response.getStatus() +'}');
			}
            
            //#######################--------------- HTTP CALLOUT --------------#######################################
            
            List<String> incomingBo = new List<String>();
            if(inputHeader != null && inputHeader.TXP_Manpower_mySales != null && inputHeader.TXP_Manpower_mySales.size() > 0){
                
                for(InputClass temp:inputHeader.TXP_Manpower_mySales){
                    if(temp.BO_CODE != null && temp.BO_CODE != '') incomingBo.add(temp.BO_CODE);
                }
            }
            
            Map<String,TXPmanpower__c> txpMap = new Map<String,TXPmanpower__c>();
            List<TXPmanpower__c> txpList = new List<TXPmanpower__c>();
            txpList = [Select Id,BOCode__c,companycode__c from TXPmanpower__c where BOCode__c != null and companycode__c != null and BOCode__c != '' and companycode__c != '' and BOCode__c IN :incomingBo];
            
            if(txpList.size() >0){
                for(TXPmanpower__c txp:txpList){
                	txpMap.put(txp.BOCode__c+'_'+txp.companycode__c,txp);
                }
            }
            
            //#######################--------------- UPSERT OPERATION --------------#######################################
            //System.debug('InputHeader: '+inputHeader);
            
            //v1.1 start
            
            List<opportunity> opportunityList = [select Id,OpportunityCode__c, CompanyCode__c from opportunity where opportunitycode__c IN :incomingBo and companycode__c != null and companycode__c != ''];            
            Map<String,String> oppMap = new Map<String,String>();
            for(opportunity opp:opportunityList){
                oppMap.put(opp.OpportunityCode__c +'_'+opp.CompanyCode__c,opp.Id);
            }
            //v1.1 end
            
            List<TXPmanpower__c> txpUpsertList = new List<TXPmanpower__c>();
            if(inputHeader != null && inputHeader.TXP_Manpower_mySales != null && inputHeader.TXP_Manpower_mySales.size() > 0){
                
                for(InputClass temp:inputHeader.TXP_Manpower_mySales){
                    
                    TXPmanpower__c txpTemp = new TXPmanpower__c();
                    System.debug('TxpManPower: '+temp);
                    
                    if(txpMap.containsKey(temp.BO_CODE+'_'+temp.Company_Code)){
                        txpTemp.Id = txpMap.get(temp.BO_CODE+'_'+temp.Company_Code).Id;
                    }
                    if(oppMap.containsKey(temp.BO_CODE+'_'+temp.Company_Code)){
                        txpTemp.Opportunity__c = oppMap.get(temp.BO_CODE+'_'+temp.Company_Code);//v1.1
                        System.debug('TxpManPowerOpp: '+txpTemp.Opportunity__c);
                    }
                    txpTemp.BOCode__c	        = temp.BO_CODE;
                    txpTemp.companycode__c		= temp.Company_Code;
                    txpTemp.ProposalPMNo__c		= temp.Proposal_PM;
                    txpTemp.ProposalPMStatus__c	= temp.PROPOSAL_PM_STATUS;
                    txpTemp.P_Projectcode__c    = temp.P_PJT_CD;
                    txpTemp.P_Projectname__c	= temp.P_PJT_NM;
                    txpTemp.E_Projectcode__c    = temp.E_PJT_CD;
                    txpTemp.E_Projectname__c    = temp.E_PJT_NM;
                    
                    if(temp.PROPOSAL_START_DATE != null && temp.PROPOSAL_START_DATE != ''){
                    	txpTemp.ProposalPMStDt__c	= Date.valueOf(temp.PROPOSAL_START_DATE);}
                    
                    if(temp.PROPOSAL_END_DATE != null && temp.PROPOSAL_END_DATE != ''){
                        txpTemp.ProposalPMEdDt__c	= Date.valueOf(temp.PROPOSAL_END_DATE);}
                    
                    txpTemp.ExecutionPMNo__c	= temp.Exec_PM;
                    txpTemp.ExecutionPMStatus__c= temp.EXEC_PM_STATUS;
                    
                    if(temp.EXEC_START_DATE != null && temp.EXEC_START_DATE != ''){
                        txpTemp.ExecutionPMStDt__c	= Date.valueOf(temp.EXEC_START_DATE);}
                    
                    if(temp.EXEC_END_DATE != null && temp.EXEC_END_DATE != ''){
                        txpTemp.ExecutionPMEdDt__c	= Date.valueOf(temp.EXEC_END_DATE);}
                    
                    txpTemp.ProposalPMPlan__c	= temp.A_PJT_YN;
                    txpTemp.ExecutionPMPlan__c	= temp.C_PJT_YN;  
                    
                    txpUpsertList.add(txpTemp);
                }
                upsert txpUpsertList;
            }
            //#######################--------------- UPSERT OPERATION --------------#######################################
            
            ifLog.addLog('TXP Manpower Record Count: '+String.valueOf(txpUpsertList.size()));
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        }
        catch(Exception e){   
            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());           
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        }
        ifLog.createLog(interfaceLog);        
    }
    @AuraEnabled
    public static String UpdateTXPManpowerInfo(String oppId){
        
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
		ifLog.addLog('Opportunity ID: '+ oppId);
        
        try{
                       
            List<OutputClass> outputList = new List<OutputClass>();   
            
            List<opportunity> oppList = [select opportunitycode__c, companycode__c, ProposalPM__r.EvEmpNO__c,RepresentativePM__r.EvEmpNO__c from opportunity where Id = :oppId];
            for(opportunity opp:oppList){
                OutputClass out  = new OutputClass();
                out.BO_CODE      = opp.opportunitycode__c;
                out.Company_Code = opp.companycode__c;
                out.Proposal_PM  = opp.ProposalPM__r.EvEmpNO__c;
                out.Exec_PM      = opp.RepresentativePM__r.EvEmpNO__c;
                
                outputList.add(out); 
            }
            ifLog.addLog('Opportunity Count: '+String.valueOf(outputList.size()));
            
            //#######################--------------- HTTP CALLOUT --------------#######################################
            
            IF_Callout call = new IF_Callout(INTERFACE_ID);
        
            OutputHeader output = new OutputHeader();
            InputHeader inputHeader = new InputHeader();
            
            Output.Opportunity_mySales = outputList;
            String jsonBody = JSON.serialize(output);
            HttpResponse response;
            
            Integer errorCount = 3;
            while(errorCount > 0){
            	resMap = call.httpCallout(jsonBody, '');
                response = (HttpResponse)resMap.get('HttpResponse');
                if(response.getStatusCode() != 200 || response.getBody() == null || response.getBody() == ''){
                    errorCount--;
                }
                else{ break;}
            }
            
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
            
            response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response.getBody: '+response.getBody());
            if(response.getStatusCode() == 200){//Test.isRunningTest()
                inputHeader = (InputHeader)JSON.deserialize(response.getBody(),InputHeader.class);    
            }else {
				throw new CustomException('{"status":'+ String.valueOf(response.getStatusCode()) +', "message":'+ response.getStatus() +'}');
			}
            
            //#######################--------------- HTTP CALLOUT --------------#######################################
            
            List<String> incomingBo = new List<String>();
            if(inputHeader != null && inputHeader.TXP_Manpower_mySales != null && inputHeader.TXP_Manpower_mySales.size() > 0){
                
                for(InputClass temp:inputHeader.TXP_Manpower_mySales){
                    if(temp.BO_CODE != null && temp.BO_CODE != '') incomingBo.add(temp.BO_CODE);
                }
            }
            
            Map<String,TXPmanpower__c> txpMap = new Map<String,TXPmanpower__c>();
            List<TXPmanpower__c> txpList = new List<TXPmanpower__c>();
            txpList = [Select Id,BOCode__c,companycode__c from TXPmanpower__c where BOCode__c != null and companycode__c != null and BOCode__c != '' and companycode__c != '' and BOCode__c IN :incomingBo];
            
            if(txpList.size() >0){
                for(TXPmanpower__c txp:txpList){
                	txpMap.put(txp.BOCode__c+'_'+txp.companycode__c,txp);
                }
            }
            
            //#######################--------------- UPSERT OPERATION --------------#######################################
            //System.debug('InputHeader: '+inputHeader);
            
            //v1.1 start
            
            List<opportunity> opportunityList = [select Id,OpportunityCode__c, CompanyCode__c from opportunity where opportunitycode__c IN :incomingBo and companycode__c != null and companycode__c != ''];            
            Map<String,String> oppMap = new Map<String,String>();
            for(opportunity opp:opportunityList){
                oppMap.put(opp.OpportunityCode__c +'_'+opp.CompanyCode__c,opp.Id);
            }
            //v1.1 end
            
            List<TXPmanpower__c> txpUpsertList = new List<TXPmanpower__c>();
            if(inputHeader != null && inputHeader.TXP_Manpower_mySales != null && inputHeader.TXP_Manpower_mySales.size() > 0){
                
                for(InputClass temp:inputHeader.TXP_Manpower_mySales){
                    
                    TXPmanpower__c txpTemp = new TXPmanpower__c();
                    System.debug('TxpManPower: '+temp);
                    
                    if(txpMap.containsKey(temp.BO_CODE+'_'+temp.Company_Code)){
                        txpTemp.Id = txpMap.get(temp.BO_CODE+'_'+temp.Company_Code).Id;
                    }
                    if(oppMap.containsKey(temp.BO_CODE+'_'+temp.Company_Code)){
                        txpTemp.Opportunity__c = oppMap.get(temp.BO_CODE+'_'+temp.Company_Code);//v1.1
                        System.debug('TxpManPowerOpp: '+txpTemp.Opportunity__c);
                    }
                    txpTemp.BOCode__c	        = temp.BO_CODE;
                    txpTemp.companycode__c		= temp.Company_Code;
                    txpTemp.ProposalPMNo__c		= temp.Proposal_PM;
                    txpTemp.ProposalPMStatus__c	= temp.PROPOSAL_PM_STATUS;
                    txpTemp.P_Projectcode__c    = temp.P_PJT_CD;
                    txpTemp.P_Projectname__c	= temp.P_PJT_NM;
                    txpTemp.E_Projectcode__c    = temp.E_PJT_CD;
                    txpTemp.E_Projectname__c    = temp.E_PJT_NM;
                    
                    if(temp.PROPOSAL_START_DATE != null && temp.PROPOSAL_START_DATE != ''){
                    	txpTemp.ProposalPMStDt__c	= Date.valueOf(temp.PROPOSAL_START_DATE);}
                    
                    if(temp.PROPOSAL_END_DATE != null && temp.PROPOSAL_END_DATE != ''){
                        txpTemp.ProposalPMEdDt__c	= Date.valueOf(temp.PROPOSAL_END_DATE);}
                    
                    txpTemp.ExecutionPMNo__c	= temp.Exec_PM;
                    txpTemp.ExecutionPMStatus__c= temp.EXEC_PM_STATUS;
                    
                    if(temp.EXEC_START_DATE != null && temp.EXEC_START_DATE != ''){
                        txpTemp.ExecutionPMStDt__c	= Date.valueOf(temp.EXEC_START_DATE);}
                    
                    if(temp.EXEC_END_DATE != null && temp.EXEC_END_DATE != ''){
                        txpTemp.ExecutionPMEdDt__c	= Date.valueOf(temp.EXEC_END_DATE);}
                    
                    txpTemp.ProposalPMPlan__c	= temp.A_PJT_YN;
                    txpTemp.ExecutionPMPlan__c	= temp.C_PJT_YN;  
                    
                    txpUpsertList.add(txpTemp);
                }
                upsert txpUpsertList;
            }
            //#######################--------------- UPSERT OPERATION --------------#######################################
            
            ifLog.addLog('TXP Manpower Record Count: '+String.valueOf(txpUpsertList.size()));
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')));
        	ifLog.createLog(interfaceLog);
            return 'SUCCESS';
        }
        catch(Exception e){   
            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());           
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, String.valueOf(resMap.get('Request')), String.valueOf(resMap.get('Response')), e);          
        	ifLog.createLog(interfaceLog);
            return String.valueOf(e.getMessage());
        }
               
    }
    
    
    public class OutputHeader{
        public List<OutputClass> Opportunity_mySales; 
    }
    public class OutputClass{        
        public String BO_CODE;
        public String Company_Code;
        public String Proposal_PM;
        public String Exec_PM;
    }
    public class InputHeader{
        public String IV_COUNT;
        public List<InputClass> TXP_Manpower_mySales; 
    }
    public class InputClass{
        public String BO_CODE;
        public String Company_Code;
        public String Proposal_PM;
        public String P_PJT_CD;
        public String P_PJT_NM;
        public String PROPOSAL_PM_STATUS;
        public String PROPOSAL_START_DATE;
        public String PROPOSAL_END_DATE;
        public String Exec_PM;
        public String E_PJT_CD;
        public String E_PJT_NM;
        
        public String EXEC_PM_STATUS;
        public String EXEC_START_DATE;
        public String EXEC_END_DATE;
        public String A_PJT_YN;
        public String C_PJT_YN;
    }
    public class CustomException extends Exception {}
}