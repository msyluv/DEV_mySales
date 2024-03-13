/**
* @description       : Send BO information for request of Gen.AI (IF-200)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2024-01-05 
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2024-01-05   vikrant.ks@samsung.com   Initial Version(MySales 400)
**/
@RestResource(urlMapping = '/IF200/*')
global class IF_SendDatatoGENAI {
    
    private static final String INTERFACE_ID = 'IF-200';
    private static final String APEX_CLASS   = 'IF_SendDatatoGENAI';
    private static final String METHOD_NAME  = 'SendDatatoGENAI'; 
    private static String guId = IF_Util.generateGuid();
    
    @HttpPost
    global static void SendDatatoGENAI(){
        System.debug('CpuTimeFirst: '+Limits.getCpuTime());
        System.debug('TotalCpuTime: '+Limits.getLimitCpuTime());
        OutputHeader outHeader   = new OutputHeader();
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();
		RestResponse rep = RestContext.response;
		String inputJsonData;
        
        Set<String> incomingBoBiz1Set          = new Set<String>();
        Set<String> incomingBoBiz2Set          = new Set<String>();
        Set<String> incomingBoBusinessLevelSet = new Set<String>();
        
        try
        {   
            ifLog = new IF_Log();
            ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');
            
            RestRequest req = RestContext.request;
            Blob    reqBody = req.requestBody;  
            
            rep.addHeader('Content-Type', 'application/json');
            
            if(reqBody == null || reqBody.toString() == '{}') {
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request format is incorrect.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(),JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;      
            }
            
            inputJsonData = reqBody.toString();
            System.debug('inputJsonData: '+inputJsonData);
            InputHeader inputHeader = (InputHeader) JSON.deserialize(inputJsonData, InputHeader.class);
            System.debug('inputHeader: '+inputHeader);
            if(inputHeader.Opportunitycode == null || inputHeader.Opportunitycode == ''){
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request Opportunitycode is incorrect.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            Opportunity incomingBO;
            List<Opportunity> incomingBOList = ([SELECT Id,OriginAcc_BizTypeL1__c, OriginAcc_BizTypeL2__c,BusinessLevel__c,CompanyCode__c
                                                 FROM Opportunity WHERE OpportunityCode__c = :inputHeader.Opportunitycode AND RecordType.Name = 'HQ']);
            
            if(incomingBOList.size() == 1){
                incomingBO = incomingBOList[0];
                System.debug('incomingBO: '+incomingBO);
            }
            else if(incomingBOList.size() > 1){
                for(Opportunity opp:incomingBOList){
                    if(opp.CompanyCode__c == 'T100'){
                        incomingBO = opp;
                        Break;
                    }
                }
                if(incomingBO == Null){incomingBO = incomingBOList[0];}
                System.debug('incomingBO: '+incomingBO);
            }
            else{
                outHeader.RESULT = 'F';
                outHeader.RESULT_MESSAGE = 'Request Opportunitycode is incorrect.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            
            if(incomingBO.OriginAcc_BizTypeL1__c != null){
                incomingBoBiz1Set.add(incomingBO.OriginAcc_BizTypeL1__c);
            }
            if(incomingBO.OriginAcc_BizTypeL2__c != null){
                incomingBoBiz2Set.add(incomingBO.OriginAcc_BizTypeL2__c);
            }
            if(incomingBO.BusinessLevel__c != null){
                incomingBoBusinessLevelSet.add(incomingBO.BusinessLevel__c);
            }
            
            Set<String> incomingBOServiceNameSet  = new Set<String>();
        	Set<String> incomingBOSolutionNameSet = new Set<String>();
            Set<Id> BOServiceIDSet  = new Set<Id>();
        	Set<Id> BOSolutionIDSet = new Set<Id>();
            Map<id,Set<String>> BOIdtoServiceMap  = new Map<id,Set<String>>();
        	Map<id,Set<String>> BOIdtoSolutionMap = new Map<id,Set<String>>();
            
            for(Service__c serObj:[SELECT sService__r.Name,Opportunity__c FROM Service__c WHERE Opportunity__c = : incomingBO.Id  AND sDeletionFlag__c = false ORDER BY ItemNumber__c ASC]){
                incomingBOServiceNameSet.add(serObj.sService__r.Name);
            }
            
            for(Service__c serObj:[SELECT sService__r.Name,Opportunity__c FROM Service__c WHERE sService__r.Name IN :incomingBOServiceNameSet  AND sDeletionFlag__c = false AND Opportunity__c != Null AND 
                                   Opportunity__r.OriginAcc_BizTypeL1__c IN :incomingBoBiz1Set AND Opportunity__r.OriginAcc_BizTypeL2__c IN :incomingBoBiz2Set AND 
                                   Opportunity__r.BusinessLevel__c IN :incomingBoBusinessLevelSet AND Opportunity__r.RecordType.Name = 'HQ' AND (Opportunity__r.closedate = LAST_N_YEARS:4 OR Opportunity__r.closedate = THIS_YEAR)]){
                BOServiceIDSet.add(serObj.Opportunity__c);
            }
            
            for(Service__c serObj:[SELECT sService__r.Name,Opportunity__c FROM Service__c WHERE Opportunity__c IN : BOServiceIDSet  AND sDeletionFlag__c = false ORDER BY ItemNumber__c ASC]){
                if(BOIdtoServiceMap.containskey(serObj.Opportunity__c)) {
                    set<String> servName = BOIdtoServiceMap.get(serObj.Opportunity__c);
                    servName.add(serObj.sService__r.Name);
                    BOIdtoServiceMap.put(serObj.Opportunity__c,servName);
                }
                else{
                    set<String> servName = new Set<String>();
                    servName.add(serObj.sService__r.Name);
                    BOIdtoServiceMap.put(serObj.Opportunity__c,servName);
                }
            }
            
        	for(Solution__c solObj:[SELECT sSolution__r.Name,Opportunity__c FROM Solution__c WHERE Opportunity__c = :incomingBO.Id AND sDeletionFlag__c = false ORDER BY ItemNumber__c ASC]){
                incomingBOSolutionNameSet.add(solObj.sSolution__r.Name);
            }
            
            for(Solution__c solObj:[SELECT sSolution__r.Name,Opportunity__c FROM Solution__c WHERE sSolution__r.Name IN :incomingBOSolutionNameSet AND sDeletionFlag__c = false AND Opportunity__c != Null AND
                                   Opportunity__r.OriginAcc_BizTypeL1__c IN :incomingBoBiz1Set AND Opportunity__r.OriginAcc_BizTypeL2__c IN :incomingBoBiz2Set AND 
                                   Opportunity__r.BusinessLevel__c IN :incomingBoBusinessLevelSet AND Opportunity__r.RecordType.Name = 'HQ' AND (Opportunity__r.closedate = LAST_N_YEARS:4 OR Opportunity__r.closedate = THIS_YEAR)]){
                BOSolutionIDSet.add(solObj.Opportunity__c);
            }
            
            for(Solution__c solObj:[SELECT sSolution__r.Name,Opportunity__c FROM Solution__c WHERE Opportunity__c IN :BOSolutionIDSet AND sDeletionFlag__c = false ORDER BY ItemNumber__c ASC]){
                if(BOIdtoSolutionMap.containskey(solObj.Opportunity__c)) {
                    set<String> solName = BOIdtoSolutionMap.get(solObj.Opportunity__c);
                    solName.add(solObj.sSolution__r.Name);
                    BOIdtoSolutionMap.put(solObj.Opportunity__c,solName);
                }
                else{
                    set<String> solName = new Set<String>();
                    solName.add(solObj.sSolution__r.Name);
                    BOIdtoSolutionMap.put(solObj.Opportunity__c,solName);
                }
            }
            
            String recordType = 'HQ';
            Id incomingBOId = incomingBO.Id;
            
            String str_SELECT1 = '';
            str_SELECT1 += 'Select Id,Name, OpportunityCode__c,Opportunity_Review_VRB_Type_Confirm__c,CompanyCode__c, ';
			str_SELECT1 += ' (select TransactionName__c,Status__c from BO_Activity__r where transactionname__c= ' + '\'' + 'ZP61' + '\'' + ' and status__c= ' + '\'' + 'Completed' + '\'' + ') ,';            
            str_SELECT1 += 'ProposalPM__r.name,OriginAcc_BizTypeL1__c,OriginAcc_BizTypeL2__c, ';
            str_SELECT1 += 'BusinessLevel__c,closedate,amount,toLabel(StageName),owner.name From Opportunity ';
            
            String str_WHERE1 = '';
            str_WHERE1 += ' where OriginAcc_BizTypeL1__c IN :incomingBoBiz1Set AND OriginAcc_BizTypeL2__c IN :incomingBoBiz2Set AND BusinessLevel__c IN :incomingBoBusinessLevelSet';
            str_WHERE1 += ' AND RecordType.Name = :recordType AND Id IN :BOServiceIDSet AND Id IN :BOSolutionIDSet AND (closedate = LAST_N_YEARS:4 OR closedate = THIS_YEAR) AND Id != :incomingBOId ';
            
            String str_ORDER1 = ' order by LastModifiedDate DESC limit 3';
            
            String query= str_SELECT1 + str_WHERE1 + str_ORDER1;
        	
            List<Opportunity> objList = Database.query(query);
            
            if(objList.size() == 0){
                outHeader.RESULT = 'S';
                outHeader.RESULT_MESSAGE = 'No similar Opportunity exist for this Opportunitycode.';
                rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData,JSON.serialize(outHeader));
                ifLog.createLog(interfaceLog);
                return;
            }
            
            List<OutputClass> OpportunityList = new List<OutputClass>();
            
            for(Opportunity opp : objList)
            {	
                OutputClass temp = new OutputClass();
                
                temp.Opportunitycode     = opp.OpportunityCode__c;
                temp.Opportunityname     = opp.Name;
                temp.Stagename           = opp.StageName;
                temp.VRB_Confirmtype     = vrbTypeValues(opp.Opportunity_Review_VRB_Type_Confirm__c);
                temp.Proposalsubmitte    = opp.BO_Activity__r.size() > 0? 'Y':'N';
                temp.Owner               = opp.owner.name;
                temp.ProposalPM          = opp.ProposalPM__r.name;
                temp.BusinessLevel    	 = opp.BusinessLevel__c;
                temp.OriginAcc_BizTypeL1 = opp.OriginAcc_BizTypeL1__c;
                temp.OriginAcc_BizTypeL2 = opp.OriginAcc_BizTypeL2__c;
                temp.DashboardLink       = 'http://scd.sds.samsung.net/app/scdDetail?sapCompany='+opp.CompanyCode__c+'&orderId='+opp.OpportunityCode__c;
          
                if(BOIdtoServiceMap.get(opp.Id) != null){
                    temp.Servicename     = BOIdtoServiceMap.get(opp.Id);}
                if(BOIdtoSolutionMap.get(opp.Id) != null){
                    temp.Solutionname    = BOIdtoSolutionMap.get(opp.Id);}
                if(opp.amount != null){
                    temp.Amount          = String.valueOf(opp.amount);}
                if(opp.closedate != null){
                    temp.Closedate       = datetoString(opp.closedate);}
                
                OpportunityList.add(temp);
            }
            outHeader.RESULT = 'S';
            outHeader.RESULT_MESSAGE = 'The request has been processed successfully.';
            outHeader.Similar_BO = OpportunityList;
            
            String sendData = JSON.serialize(outHeader);
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);
        }   
        catch(Exception e)
        {
            outHeader.RESULT = 'F';
            outHeader.RESULT_MESSAGE = 'An error occurred when processing the request.' +' | '+e.getMessage();
            String sendData          = JSON.serialize(outHeader);
            ifLog.addLog('Response : ' + sendData);            
            ifLog.addLog('Exception : ' + e.getMessage());
            errorMsgList.add('Exception : ' + e.getMessage());
            System.debug('ErrorMessage: '+e.getMessage());
            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);     
        }
        
        ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
        ifLog.createLog(interfaceLog);        
        
        rep.responseBody = Blob.valueOf(JSON.serialize(outHeader));
        System.debug('CpuTimeLast: '+Limits.getCpuTime());
        
    }
    
    public class OutputHeader{
        public String RESULT;
        public String RESULT_MESSAGE;
        public List<OutputClass> Similar_BO;
    }
    public class OutputClass{
        
        public String Opportunitycode;
        public String Opportunityname;
        public String Closedate;
        public String Stagename;
        public String Amount;
        public String VRB_Confirmtype;
        public String Proposalsubmitte;
        public String Owner;
        public String ProposalPM;
        public String BusinessLevel;
        public String OriginAcc_BizTypeL1;
        public String OriginAcc_BizTypeL2;
        public Set<String> Servicename;
        public Set<String> Solutionname;
        public String DashboardLink;
    }
    public class InputHeader{
        public String Opportunitycode;
    }
    
    public static String datetoString(Date d)
    {	
        String nullString;
        if(d == Null) return nullString;
        String sMonth = String.valueof(d.month());
        String sDay = String.valueof(d.day());
        
        return String.valueof(d.year()) +'.'+sMonth +'.'+sDay ;
    }
    public static string vrbTypeValues(String vrbTypeVal){
        String BO_Strategy_Type = '';
        
        if(vrbTypeVal == '10' ) BO_Strategy_Type = '전사';
        else if(vrbTypeVal == '20') BO_Strategy_Type = '사업부';
        else if(vrbTypeVal == '21') BO_Strategy_Type = 'AM 담당';
        
        return BO_Strategy_Type;
    }
}