public class ossDataWrapper {
    public Opportunity rowOpp;
    public Map<String, ServiceWrap> Services;
    
    public class ServiceWrap {
        public String ServiceCode; //String 으로 따로 처리하는 이유. 코드값이 존재하지 않아 ##Manual## 처리 해야 함.
        public String sServiceCode; //String 으로 따로 처리하는 이유. 코드값이 존재하지 않아 ##Manual## 처리 해야 함.
        
        public String MasterServiceName; 
        public String MastersServiceName; 
        
        //public String DlvDeptCostCenter; 
        //public String sDlvDeptCostCenter; 
        //public String DlvDeptName; 	
        //public String sDlvDeptName; 
        
        public Service__c Service;
        public Map<String, SolutionWrap> Solutions;
    }
    
    public class SolutionWrap { 
        public String SolutionCode; //String 으로 따로 처리하는 이유. 코드값이 존재하지 않아 ##Manual## 처리 해야 함.
        public String sSolutionCode; //String 으로 따로 처리하는 이유. 코드값이 존재하지 않아 ##Manual## 처리 해야 함.
        
        public String MasterSolutionName; 
        public String MastersSolutionName; 
        
        public Solution__c Solution;
    }
}