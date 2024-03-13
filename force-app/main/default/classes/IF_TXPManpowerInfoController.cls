/**
* @description       : Send BO Records and Receive Records of TXPmanpower Object from Jitterbit for UPSERT Operation(IF-184)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-10-27
* @last modified by  : atul.k1@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-08-01   vikrant.ks@samsung.com   Initial Version(MySales 265)
* 1.1   2023-08-09   vikrant.ks@samsung.com   Add lookup field of opportunity(MySales 265)
* 1.2   2023-10-18   vikrant.ks@samsung.com   Change query condition when request IF-184(MySales 327)
* 1.3   2023-10-27   atul.k1@samsung.com      Task - (IT) IF-184 Fields addition(MySales 341)
**/
public class IF_TXPManpowerInfoController{
    
    private static final String INTERFACE_ID = 'IF-184';
    private static final String APEX_CLASS   = 'IF_TXPManpowerInfoController';
    private static final String METHOD_NAME  = 'SendTXPManpowerInfo';
    private static String guId = IF_Util.generateGuid();
    private static Integer errorCount = 0;
    public static Map<String,Object> resMap = new Map<String,Object>();
    
    
    public static void SendTXPManpowerInfo(){
        
        IF_Log ifLog = new IF_Log();
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');

        try{
                       
            List<OutputClass> outputList = new List<OutputClass>();   
            
            Set<String> setProfile = new Set<String>(System.Label.TXP_Manpower_Profiles.split(','));
            List<opportunity> oppList = [select opportunitycode__c, companycode__c, ProposalPM__r.EvEmpNO__c,RepresentativePM__r.EvEmpNO__c from opportunity where (stagename = 'Z01' or stagename = 'Z02' or stagename = 'Z03' or stagename = 'Z04') and recordtype.name = 'HQ' and companycode__c = 'T100' and closedate > today and closedate <= NEXT_N_MONTHS:3 and opportunitycode__c != null and companycode__c != null and opportunitycode__c != '' and companycode__c != ''];//V1.2
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
            System.debug('Output Data: '+jsonBody);
            resMap = call.httpCallout(jsonBody, '');
            
            System.debug('request : '+resMap.get('Request')); 
            System.debug('response : '+resMap.get('Response'));
            
            HttpResponse response = (HttpResponse)resMap.get('HttpResponse');
            System.debug('response.getBody: '+response.getBody());
            if(response.getStatusCode() == 200){//Test.isRunningTest()
                inputHeader = (InputHeader)JSON.deserialize(response.getBody(),InputHeader.class);    
            }
            
            //#######################--------------- HTTP CALLOUT --------------#######################################
            
            Map<String,TXPmanpower__c> txpMap = new Map<String,TXPmanpower__c>();
            List<TXPmanpower__c> txpList = new List<TXPmanpower__c>();
            txpList = [Select Id,BOCode__c,companycode__c from TXPmanpower__c where BOCode__c != null and companycode__c != null and BOCode__c != '' and companycode__c != ''];
            
            if(txpList.size() >0){
                for(TXPmanpower__c txp:txpList){
                	txpMap.put(txp.BOCode__c+'_'+txp.companycode__c,txp);
                }
            }
            
            //#######################--------------- UPSERT OPERATION --------------#######################################
            //System.debug('InputHeader: '+inputHeader);
            
            //v1.1 start
            List<String> incomingBo = new List<String>();
            if(inputHeader != null && inputHeader.TXP_Manpower_mySales != null && inputHeader.TXP_Manpower_mySales.size() > 0){
                
                for(InputClass temp:inputHeader.TXP_Manpower_mySales){
                    if(temp.BO_CODE != null && temp.BO_CODE != '') incomingBo.add(temp.BO_CODE);
                }
            }
            
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
                    txpTemp.P_Projectname__c	= temp.P_PJT_NM;//V 1.3 MySales-341
                    txpTemp.E_Projectcode__c    = temp.E_PJT_CD;
                    txpTemp.E_Projectname__c    = temp.E_PJT_NM;//V 1.3 MySales-341
                    
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
        public String P_PJT_CD;//
        public String P_PJT_NM;// V 1.3Mysales-341
        public String PROPOSAL_PM_STATUS;
        public String PROPOSAL_START_DATE;
        public String PROPOSAL_END_DATE;
        public String Exec_PM;
        public String E_PJT_CD;//
        public String E_PJT_NM;//V 1.3Mysales-341
        
        public String EXEC_PM_STATUS;
        public String EXEC_START_DATE;
        public String EXEC_END_DATE;
        public String A_PJT_YN;
        public String C_PJT_YN;
    }
}