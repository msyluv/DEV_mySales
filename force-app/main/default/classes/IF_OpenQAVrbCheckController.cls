/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 04-01-2021
 * @last modified by  : soohong0.kim@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   01-28-2021   soohong0.kim@partner.samsung.com   Initial Version
**/
@RestResource(urlMapping = '/IF061/*')
global class IF_OpenQAVrbCheckController {
    private static final String INTERFACE_ID = 'IF-061';
    private static final String APEX_CLASS   = 'IF_OpenQAVrbCheckController';
    private static final String METHOD_NAME  = 'doPost';

    @HttpPost
    global static OutputHeader doPost() {
        String guId      = IF_Util.generateGuid();
        IF_Log.InterfaceLog ifLog;
        IF_Log log = new IF_Log();
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        
        InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
        OutputHeader outheader = new OutputHeader();
        try{
            List<Biz_Review__c> reviewList = [SELECT Id, TotalScore__c, Version__c, Opportunity__r.VRBMethod__c FROM Biz_Review__c WHERE Opportunity__r.OpportunityCode__c =: input.ZZORDER_ID AND Opportunity__r.EPCompanyCode__c =: input.EP_COMPANY Order by Version__c desc limit 1];
            Set<String> reviewIds = new Set<String>();
            for(Biz_Review__c obj : reviewList){
                reviewIds.add(obj.id);

                //Opportunity의 VRBMethod__c 필드
                if(outheader.VRB_TYPE != null) outheader.VRB_TYPE = obj.Opportunity__r.VRBMethod__c;
                //Version 정보, Question Object의 TotalScore Summary 필드 추가
                System.debug('obj.Version : '+obj.Version__c);
                System.debug('obj.TotalScore__c : '+obj.TotalScore__c);
                outheader.VERSION = String.valueOf(obj.Version__c);
                outheader.TOTAL = String.valueOf(obj.TotalScore__c);
            }
            outheader.ZZORDER_ID = input.ZZORDER_ID;
            outheader.EP_COMPANY = input.EP_COMPANY;
            
            List<Question__c> questionList = [SELECT Category1__c, Category2__c, Question__c FROM Question__c WHERE BOBizReview__c in: reviewIds];
            Set<String> questionIds = new Set<String>();
            Map<String,Object> questionMap = new Map<String,Object>();
            for(Question__c obj : questionList){
                questionIds.add(obj.id);
                questionMap.put(obj.id, obj);
            }
            List<Answer__c> answerList = [SELECT id, BOQuestion__c, Answer__c, IsChecked__c, EvaluationDepartmentEvaluationBasis__c 
                                          FROM Answer__c WHERE BOQuestion__c in: questionIds
                                          ORDER BY BOQuestion__c, NO__c
                                          ];



            List<OutputClass> outputList = new List<OutputClass>();
            for(Answer__c obj : answerList){
                Question__c question = (Question__c) questionMap.get(obj.BOQuestion__c);
                OutputClass output = new OutputClass();
                output.Q_CLASS       = question.Category1__c + '>' + question.Category2__c;
                output.Q_QUESTION    = question.Question__c;
                output.A_ANSWER      = obj.Answer__c;                
                output.A_RESULT_TEXT = obj.EvaluationDepartmentEvaluationBasis__c;
                if(obj.IsChecked__c) output.A_RESULT = obj.Answer__c;
                outputList.add(output);
            }
            outheader.ET_OUTPUT = outputList;

            

            outheader.TOTAL_COUNT    = outputList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
        }catch(Exception e){
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            ifLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
            log.createLog(ifLog);
        }

        
        ifLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
        log.createLog(ifLog);
        return outHeader;
    }

    public class InputHeader{
        public String ZZORDER_ID;
        public String EP_COMPANY;
    }

    global class OutputHeader{
        public String EV_RESULT;
        public String EV_MESG;
        public Integer TOTAL_COUNT;
        

        public String ZZORDER_ID;
        public String EP_COMPANY;
        public String VRB_TYPE;
        public String VERSION;
        public String TOTAL;
        public List<OutputClass> ET_OUTPUT;
    }

    /*
    public class InputClass{
        public String ZZORDER_ID;
        public String EP_COMPANY;
    }
*/
    public class OutputClass{
        public String Q_CLASS;
        public String Q_QUESTION;
        public String A_ANSWER;
        public String A_RESULT;
        public String A_RESULT_TEXT;
    }
}