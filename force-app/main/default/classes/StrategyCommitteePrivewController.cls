/**
 * @description       : 
 * @author            : Junghwa.Kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-03-11
 * @last modified by  : Junghwa.Kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                  Modification
 * 1.0   2021-01-29   Junghwa.Kim@dkbmc.com   Initial Version
**/
public without sharing class StrategyCommitteePrivewController {
    public static String STRATEGY_COMMITTEEE_EMAIL = 'KnoxApproval_OpportunityActivity_ZP62';

    @AuraEnabled
    public static string getDate(String recordId){
        
        EmailTemplate temp = [SELECT Id, Name, DeveloperName, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :STRATEGY_COMMITTEEE_EMAIL LIMIT 1];

        Biz_Review__c br = [SELECT Id, FM_version__c, OpertingProfit__c, Costplanningreadiness__c, LaborMM__c, Opportunity__c, Attendees__c, FinalDecision__c, Decision__c, Description__c, OriginalPriceVersion__c FROM Biz_Review__c WHERE Id =: recordId];
        System.debug('br : ' + br);
        Opportunity opp = [SELECT Id, OpportunityCode__c, Name, cOriginAcc__r.Name, Account.Name, cPrimarySalesDepartment__r.Name, Amount, SalesDepartment__r.Name, Description, CompanyCode__c FROM Opportunity WHERE Id = :br.Opportunity__c];
        System.debug('opp : ' + opp);
        // List<Question__c> QList = [SELECT Id, Category1__c, Category2__c, TotalScore__c, ReviewDivision__c FROM Question__c WHERE BOBizReview__c = :recordId AND TotalScore__c < 0 ORDER BY Category1__c, Category2__c DESC];
        
        List<Question__c> QList = new List<Question__c>();
        Map<String, String> aMap = new Map<String, String>();
        Map<String, String> countMap = new Map<String, String>();
        for(Answer__c a : [SELECT Id, BOQuestion__c, IsChecked__c, Score__c FROM Answer__c WHERE BOQuestion__r.BOBizReview__c = :recordId]){
            if(a.IsChecked__c && a.Score__c != null) aMap.put(a.BOQuestion__c, 'true');
        }
        for(Question__c q : [SELECT Id, Category1__c, Category2__c, TotalScore__c, ReviewDivision__c FROM Question__c WHERE BOBizReview__c = :recordId ORDER BY Category1__c, Category2__c DESC]){
            if(aMap.get(String.valueOf(q.Id)) != null){
                QList.add(q);
            }
        }
        
        System.debug('QList : ' + QList.size());
        //List<Question__c> QList = [SELECT Id, Category1__c, Category2__c, TotalScore__c, ReviewDivision__c FROM Question__c WHERE BOBizReview__c = :recordId ORDER BY Category1__c, Category2__c DESC];
        
        String projectBody = getProjectBody(QList);
        String servicesolutionBody = getServiceSolutionBody(opp);
        // IF_SdGetConfirmInfoController.InputClass input = new IF_SdGetConfirmInfoController.InputClass();
        // input.IV_ZZORDER_ID = opp.OpportunityCode__c;
        // input.IV_VERSION = br.OriginalPriceVersion__c;
        // input.IV_BUKRS = opp.CompanyCode__c;
        // input.IV_ZZORDER_ID = 'SDS-20017820';
        // input.IV_VERSION = 'F001';
        // input.IV_BUKRS = 'T100';

        //Map<String,Object> OriginalPrice = getOriginalPriceData('SDS-20017820', 'F001', 'T100');
        Map<String,Object> OriginalPrice = new Map<String, Object>();
        if(br.Costplanningreadiness__c == 'Yes'){
            OriginalPrice = getOriginalPriceData(String.valueOf(opp.OpportunityCode__c), String.valueOf(br.OriginalPriceVersion__c), String.valueOf(opp.CompanyCode__c));
        } else {
            OriginalPrice.put('Contract_Amt', '-');
            OriginalPrice.put('Operating_Profit', '-');
            OriginalPrice.put('Labor_MM', '-');
        }
        //.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        String Contract_Amt = String.valueOf(OriginalPrice.get('Contract_Amt'));
        String Operating_Profit = String.valueOf(OriginalPrice.get('Operating_Profit'));
        String Labor_MM = String.valueOf(OriginalPrice.get('Labor_MM'));
        
        if(Contract_Amt != '-') Contract_Amt = Contract_Amt == null ? '-' : Contract_Amt.replaceAll('\\B(?=(\\d{3})+(?!\\d))', ',');
        if(Operating_Profit == null) Operating_Profit = '-';
        if(Labor_MM == null) Labor_MM = '-';

        String body = String.valueOf(temp.HtmlValue);
        body = body.replace('{!version}', (br.FM_version__c == null ? '-' : br.FM_version__c));
        body = body.replace('{!BOName}', String.valueOf(opp.Name));
        body = body.replace('{!BOCode}', String.valueOf(opp.OpportunityCode__c == null ? '-' : String.valueOf(opp.OpportunityCode__c)));
        body = body.replace('{!ContractAmt}', String.valueOf(Contract_Amt));                 //인터페이스로 원가판 값 받아오기
        body = body.replace('{!OperatingProfit}', Operating_Profit);     //인터페이스로 원가판 값 받아오기
        body = body.replace('{!Decision}', String.valueOf(br.Decision__c == null ? '-' : String.valueOf(br.Decision__c)));
        body = body.replace('{!LaborMM}', Labor_MM);                             //인터페이스로 원가판 값 받아오기
        body = body.replace('{!SalesDepartment}', (opp.SalesDepartment__r.Name == null ? '-' : String.valueOf(opp.SalesDepartment__r.Name)));
        body = body.replace('{!DeliveryDepartment}', (opp.cPrimarySalesDepartment__r.Name == null ? '-' : String.valueOf(opp.cPrimarySalesDepartment__r.Name)));
        body = body.replace('{!OriginAccount}', (opp.cOriginAcc__r.Name == null ? '-' : String.valueOf(opp.cOriginAcc__r.Name)));
        body = body.replace('{!ContractAccount}', (opp.Account.Name == null ? '-' : String.valueOf(opp.Account.Name)));
        body = body.replace('{!Contractor}', String.valueOf('SAMSUNG SDS'));    //변경가능
        body = body.replace('{!Attendees}', (br.Attendees__c == null ? '-' : String.valueOf(br.Attendees__c)));
        body = body.replace('{!BusinessInfo}', (opp.Description == null ? '-' : String.valueOf(opp.Description)));
        body = body.replace('{!FinalDecision}', (br.FinalDecision__c == null ? '-' : String.valueOf(br.FinalDecision__c)));
        body = body.replace('{!project}', projectBody);
        body = body.replace('{!servicesolution}', servicesolutionBody);
        body = body.replace('{!BOUrl}', System.URL.getSalesforceBaseUrl().toExternalForm()  + '/' + opp.Id);

        return body;
    }

    public static String getProjectBody(List<Question__c> QList) {
        
        Map<String, String> AMap = new Map<String, String>();
        for(Answer__c a : [SELECT Id, EvaluationDepartmentEvaluationBasis__c, BOQuestion__c FROM Answer__c WHERE BOQuestion__c IN :QList AND IsChecked__c = true]){
            System.debug(a);
            AMap.put(String.valueOf(a.BOQuestion__c), String.valueOf(a.EvaluationDepartmentEvaluationBasis__c));
        }

        String projectBody = '';
        String lastCT1 = '';
        String lastCT2 = '';
        Map<String, Integer> ct1Map = new Map<String, Integer>();
        Map<String, Integer> ct2Map = new Map<String, Integer>();
        for(Question__c q : QList){
            Integer ct1 = 0;
            Integer ct2 = 0;
            Boolean isChange = false;

            if(lastCT1 == q.Category1__c){
                ct1 = ct1Map.get(q.Category1__c);
                ct1 += 1;
            } else {
                ct1 = 1;
                isChange = true;
            }
            
            String keyVal = q.Category1__c + '-' + q.Category2__c;
            if(!lastCT2.equals(q.Category2__c) || !lastCT1.equals(q.Category1__c)) {
                ct2 = 1;
            } else {
                ct2 = (ct2Map.get(keyVal) == null ? ct2 : ct2Map.get(keyVal));
                ct2 += 1;
            }

            ct1Map.put(q.Category1__c, ct1);
            ct2Map.put(keyVal, ct2);

            //System.debug(q.Category1__c + 'ct1 : ' + ct1Map.get(q.Category1__c));
            //System.debug(q.Category2__c + 'ct2 : ' + ct2Map.get(q.Category2__c));
            //System.debug('1 : ' + lastCT1 + '-' + lastCT2 + (!lastCT2.equals(q.Category2__c) || !lastCT1.equals(q.Category1__c)));
            //System.debug('ct1 : ' + ct1 + '- ct2 : ' + ct2);
            lastCT1 = q.Category1__c;
            lastCT2 = q.Category2__c;

            //System.debug('2 : ' + lastCT1 + '-' + lastCT2 + (!lastCT2.equals(q.Category2__c) || !lastCT1.equals(q.Category1__c)));

        }
        lastCT1 = '';
        lastCT2 = '';
        for(Question__c q : QList){

            projectBody += '<TR>';
            if(lastCT1 != q.Category1__c){
                //System.debug(q.Category1__c + 'ct1 : ' + ct1Map.get(q.Category1__c));
                projectBody += '<TD rowspan="' + ct1Map.get(q.Category1__c)  + '" align="center">';
                projectBody += q.Category1__c;
                projectBody += '</TD>';
            }
            if(!lastCT2.equals(q.Category2__c) || !lastCT1.equals(q.Category1__c)){
                //System.debug(q.Category2__c + 'ct2 : ' + ct2Map.get(q.Category2__c));
                String keyVal = q.Category1__c + '-' + q.Category2__c;
                projectBody += '<TD rowspan="' + ct2Map.get(keyVal)  + '" align="center">';
                projectBody += q.Category2__c;
                projectBody += '</TD>';
            }
            projectBody += '<TD align="center">';
            projectBody += q.ReviewDivision__c;
            projectBody += '</TD>';
            projectBody += '<TD align="center">';
            projectBody += q.TotalScore__c;
            projectBody += '</TD>';
            projectBody += '<TD align="center">';
            projectBody += (AMap.get(q.Id) == null ? '-' : AMap.get(q.Id));
            projectBody += '</TD>';
            projectBody += '</TR>';
            lastCT1 = q.Category1__c;
            lastCT2 = q.Category2__c;
        }
        System.debug('projectBody : ' + projectBody);
        return projectBody;
    }

    public static String getServiceSolutionBody(Opportunity opp) {
        String servicesolutionBody = '';
        
        List<Service__c> service = [SELECT Id FROM Service__c WHERE Opportunity__c = :opp.Id];
        Map<String, List<Solution__c>> solutionMap = new Map<String, List<Solution__c>>();
        for(Solution__c s : [SELECT Id, ServiceName__c, Service__r.Service__r.Name, ProjectCode__c, BizAttribute__r.Name, DeliveryDepartment__c, SalesDepartment__c, Solution__r.Name, Service__c FROM Solution__c WHERE Opportunity__c = :opp.Id]){
            //List<Solution__c> sl = (solutionMap.get(s.Service__c) == null ? new List<Solution__c>() : solutionMap.get(s.Service__c));
            //sl.add(s);

            servicesolutionBody += '<TR>';
            servicesolutionBody += '<TD align="center">';  //PJT
            servicesolutionBody += String.valueOf(s.ProjectCode__c == null ? '-' : s.ProjectCode__c);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '<TD align="center">';  //sales department
            servicesolutionBody += String.valueOf(s.SalesDepartment__c == null ? '-' : s.SalesDepartment__c);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '<TD align="center">';  //delivery department
            servicesolutionBody += String.valueOf(s.DeliveryDepartment__c == null ? '-' : s.DeliveryDepartment__c);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '<TD align="center">';  //biz attribute
            servicesolutionBody += String.valueOf(s.BizAttribute__r.Name == null ? '-' : s.BizAttribute__r.Name);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '<TD align="center">';  //service
            servicesolutionBody += String.valueOf(s.Service__r.Service__r.Name == null ? '-' : s.Service__r.Service__r.Name);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '<TD align="center">';  //solution
            servicesolutionBody += String.valueOf(s.Solution__r.Name == null ? '-' : s.Solution__r.Name);
            servicesolutionBody += '</TD>';
            servicesolutionBody += '</TR>';

            //solutionMap.put(s.Service__c, sl);
        }

        return servicesolutionBody;
    }

    public static String noRowTable(Integer colSpan){
        String noRow = '<TR>';
        noRow += '<TD align="center" colspan="' + colSpan + '">';
        noRow += 'List has No Row';
        noRow += '</TD>';
        noRow += '</TR>';

        return noRow;
    }
    
    public static Map<String,Object> getOriginalPriceData(String BOCode, String OPCode, String CCode) {
        System.debug('++++++++++++++++++++++++getOriginalPriceData++++++++++++++++++++++++');
        // BOCode = opp.OpportunityCode__c;
        // OPCode = br.OriginalPriceVersion__c;
        // CCode = opp.CompanyCode__c;
        IF_SdGetConfirmInfoController.InputClass input = new IF_SdGetConfirmInfoController.InputClass();
        input.IV_ZZORDER_ID = BOCode;
        input.IV_VERSION = OPCode;  
        input.IV_BUKRS = CCode;  // company code

        List<Object> t_result = new List<Object>();
        if(!Test.isRunningTest()){
            Map<String,Object> resMap = IF_SdGetConfirmInfoController.getInfo(input);
            System.debug('resMap');
            System.debug(resMap.get('INTERFACE_LOG'));

            Map<String,Object> objMap = (Map<String,Object>) JSON.deserializeUntyped(String.valueOf(resMap.get('Response')));
            
            //t_result = (List<Object>)objMap.get('T_RESULT');
            if(objMap.get('T_RESULT') != null) t_result = (List<Object>)objMap.get('T_RESULT');

            
            IF_Log log = new IF_Log();
            IF_Log.InterfaceLog iflog_interfaceLog = (IF_Log.InterfaceLog)resMap.get('INTERFACE_LOG');
            log.createLog(iflog_interfaceLog);
            
            
        }

        if(t_result.size() == 0){
            return new Map<String,Object>();
        }
        
        return (Map<String,Object>) t_result[0];
    }
}