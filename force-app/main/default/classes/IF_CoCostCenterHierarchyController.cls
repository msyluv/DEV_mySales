/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-26
 * @last modified by  : raeganja@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   11-20-2020   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   11-30-2020   kilhwan.an@partner.samsung.com
 * 1.2   02-09-2021   raeganja@partner.samsung.com       Dept Manager 업데이트를 위한 로직 추가
 * - ClosingDate__c null 처리
 * 1.3   03-02-2021   kilhwan.an@partner.samsung.com     L_ORGEH__c 필드 추가, Bkzer__c, Bkzkp__c, Bkzks__c, Bkzob__c, Pkzer__c, Pkzkp__c, Pkzks__c 주석 처리
 * 1.4   02-10-2023   anish.jain@partner.samsung.com     Change added to remove the duplicate CostCenter__c upsert based on External Id (My Sales -135)
 * 1.5   03-04-2024   atul.k1@samsung.com                Opportunity-Checking BA when Delivery Department is changed (My Sales -462)
**/
@RestResource(urlMapping = '/IF124/*')
global class IF_CoCostCenterHierarchyController {
    private static final String INTERFACE_ID = 'IF-124';
    private static final String APEX_CLASS   = 'IF_CoCostCenterHierarchyController';
    private static final String METHOD_NAME  = 'saveCostCenter';

    private static final String INTERFACE_ID2 = 'IF-062';//Team 부서장 정보 가져오기
    private static final String METHOD_NAME2  = 'updateDeptManager';//부서장 정보 업데이트

    private static final Boolean DEBUG_FLAG = true;

    @HttpPost
    global static OutputHeader saveCostCenter() {
        String guId      = IF_Util.generateGuid();
        RestRequest req = RestContext.request;
        Blob    reqBody = req.requestBody;
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        OutputHeader outheader = new OutputHeader();
        try{
            InputClass input = (InputClass)JSON.deserializeStrict(reqBody.toString(),InputClass.class);
            List<CostCenter__c> ccList = new List<CostCenter__c>();
            List<Company__c> companyList = [select id, CompanyCode__c from company__c];
            Map<String,String> cMap = new Map<String,String>();
            //Dept Manager 업데이트를 위한 추가 변수
            Map<String, Object> costCenterListMap   = new Map<String, Object>();            
            List<Object>        costCenterList  = new List<Object>();

            for(Company__c obj : companyList){
                cMap.put(obj.CompanyCode__c, obj.id);
            }
            for(IT_TABLE obj : input.IT_TABLE){
                CostCenter__c cc = new CostCenter__c();
                cc.Company__c           = cMap.get(obj.BUKRS);
                cc.CompanyCode__c       = obj.BUKRS;
                cc.Name                 = obj.KOSTL_KTEXT;
                cc.Node1__c             = obj.NODE1;
                cc.Node2__c             = obj.NODE2;
                cc.Node3__c             = obj.NODE3;
                cc.Node4__c             = obj.NODE4;
                cc.Node5__c             = obj.NODE5;
                cc.Text1__c             = obj.TEXT1;
                cc.Text2__c             = obj.TEXT2;
                cc.Text3__c             = obj.TEXT3;
                cc.Text4__c             = obj.TEXT4;
                cc.Text5__c             = obj.TEXT5;
                cc.CostCenterName__c    = obj.KOSTL_KTEXT;
                cc.ZZCheck__c           = obj.ZZCHECK   == 'X' ? true : false;
                cc.L_ORGEH__c           = obj.L_ORGEH;
                cc.BA__c                = obj.GSBER;
                // cc.Bkzer__c             = obj.BKZER     == 'X' ? true : false;
                // cc.Bkzkp__c             = obj.BKZKP     == 'X' ? true : false;
                // cc.Bkzks__c             = obj.BKZKS     == 'X' ? true : false;
                // cc.Bkzob__c             = obj.BKZOB     == 'X' ? true : false;
                // cc.Pkzer__c             = obj.PKZER     == 'X' ? true : false;
                // cc.Pkzkp__c             = obj.PKZKP     == 'X' ? true : false;    
                // cc.Pkzks__c             = obj.PKZKS     == 'X' ? true : false; 

                if( '00000000' == obj.ZEXPIRED || Util_String.nvlStr( obj.ZEXPIRED) == '') cc.ClosingDate__c= null ;
                else cc.ClosingDate__c = Util_String.convertStringDate( obj.ZEXPIRED);
                cc.CostCenter__c = obj.KOSTL;
                ccList.add(cc);

                //Dept Manager 업데이트를 위한 추가 로직
                if(!obj.KOSTL_KTEXT.startsWith('[CLSD') && !obj.KOSTL_KTEXT.startsWith('[Delete') && !obj.KOSTL_KTEXT.startsWith('[Temp') 
                && !obj.KOSTL_KTEXT.startsWith('[계획') && !obj.KOSTL_KTEXT.startsWith('[구코드') && !obj.KOSTL_KTEXT.startsWith('[더미')
                && !obj.KOSTL_KTEXT.startsWith('[페쇄') && !obj.KOSTL_KTEXT.startsWith('[폐쇄') && !obj.KOSTL_KTEXT.startsWith('(Mig)')){
                    Map<String, Object> costCenterMap   = new Map<String, Object>();

                    costCenterMap.put('KOSTL', obj.KOSTL);

                    costCenterList.add(costCenterMap);
                }
            }
            
            //Start- Added by Anish - v 1.4
            if(ccList.size()>0){
                Schema.SObjectField keys = CostCenter__c.Fields.CostCenter__c;
                Database.upsert(ccList, keys, false);
            }
            //upsert ccList CostCenter__c;
            //Start- Added by Anish - v 1.4
            
            

            //Dept Manager 업데이트를 위한 추가 로직
            costCenterListMap.put('IT_KOSTL_INFO', costCenterList);
            String jsonData = JSON.serialize( costCenterListMap);
            //부서장정보 업데이트 로직
            updateDeptManager(jsonData);

            outheader.TOTAL_COUNT = ccList.size();
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize( outheader));
        }
        catch(Exception e){
            outHeader.TOTAL_COUNT    = 0;
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
            outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize( outheader), e);
        }
        log.createLog( infLog);
        return outheader;
    }

    @future(callout=true)
    public static void updateDeptManager(String costCenterJosnData)
    {   
        String guId = IF_Util.generateGuid();

        Map<String, Object> result;

        String reqMsg = '';
        String resMsg = '';
    
        IF_Log ifLog;
        IF_Log.InterfaceLog interfaceLog;
        List<String> errorMsgList = new List<String>();        

        ifLog = new IF_Log();
        ifLog.addLog('#################### ' + INTERFACE_ID2 + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME2 + ' 시작' + ' ####################');

        try {

            IF_Callout ifCallout = new IF_Callout(INTERFACE_ID2);

            // Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 만들기
            //OutputHeader outHeader = (OutputHeader) JSON.deserialize(inputJsonData, OutputHeader.class);
            if (DEBUG_FLAG) ifLog.addLog('Client에서 전달받은 데이터를 callout 규격에 맞게 변환하여 requestbody 생성');            


            result = ifCallout.httpCallout(costCenterJosnData, '');
            ifLog.addLog('result : '  + result);

            reqMsg = String.valueOf(result.get('Request'));
            resMsg = String.valueOf(result.get('Response'));

            if (DEBUG_FLAG) ifLog.addLog('StatusCode : '  + String.valueOf(result.get('StatusCode')));
            if (DEBUG_FLAG) ifLog.addLog('HttpResponse : '+ String.valueOf(result.get('HttpResponse')));
            // if (DEBUG_FLAG) ifLog.addLog('Log : '         + String.valueOf(result.get('Log')));
            // if (DEBUG_FLAG) ifLog.addLog('Message : '     + String.valueOf(result.get('Message')));
           
            Integer resStatusCode = (Integer)result.get('StatusCode');

            if (resStatusCode != null && resStatusCode == 200) {
                HttpResponse hRes = (HttpResponse)result.get('HttpResponse');

                ifLog.addLog('Response Body : ' + hRes.getBody());

                Map<String,Object>     returnMap = (Map<String,Object>) JSON.deserializeUntyped(hRes.getBody());
                List<Object>           dataList  = new List<Object>();
                Object                 mngInfoObj= returnMap.get('ET_MANAGER_INFO');
                Map<String,Object>     ctMap     = (Map<String,Object>)JSON.deserializeUntyped( costCenterJosnData);
                List<Object>           ctCenterLt= (List<Object>)ctMap.get( 'IT_KOSTL_INFO');
                if( mngInfoObj != null) dataList = (List<Object>)mngInfoObj;


                // if(dataList != null){
                    Map<String, Object> costCenterMap  = new Map<String, Object>();
                    Map<String, Id>     empMap         = new Map<String, Id>();
                    Set<String> costCenterSet          = new Set<String>();//Cost Center Set
                    Set<String> managerNoSet           = new Set<String>();//부서장 사번 Set
                    for(Object obj : dataList){
                        Map<String,Object> objMap = (Map<String,Object>) obj;

                        String evKostl = objMap.get('EV_KOSTL') + '';
                        // costCenterSet.add(evKostl);

                        String managerNo = String.valueOf(Util_String.nvlInt(objMap.get('EV_MANAGER_NO') + ''));
                        managerNoSet.add(managerNo);

                        costCenterMap.put(evKostl, objMap);
                    }
                    
                    for( Object ctCenterObj : ctCenterLt){

                        costCenterSet.add( ((Map<String, Object>)ctCenterObj).get( 'KOSTL') + '');
                    }

                    //Employee List 조회
                    List<Employee__c> empList = [Select Id, Name, EvSapEmpNO__c, EvKostl__c From Employee__c Where EvSapEmpNO__c IN :managerNoSet];

                    for(Employee__c emp : empList){
                        empMap.put(emp.EvSapEmpNO__c, emp.Id);
                    }

                    //CostCenter List 조회
                    List<CostCenter__c> costCenterList = [Select Id, Name, CostCenter__c, DeptManager__c From CostCenter__c Where CostCenter__c IN :costCenterSet];

                    //Dept Manager Update
                    for(CostCenter__c costCenter : costCenterList){

                        Object objCostMap = costCenterMap.get( costCenter.CostCenter__c);
                        Id     evManageId = null;
                        if( objCostMap != null){

                            Map<String,Object> objCostCenterMap = (Map<String,Object>) objCostMap;
                            Object evManageObj = objCostCenterMap.get( 'EV_MANAGER_NO');
                            evManageId  = empMap.get( Util_String.nvlInt( evManageObj) + '');
                        }
                        costCenter.DeptManager__c =  evManageId;                        
                    }

                    update costCenterList;
                // }
                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID2, guId, APEX_CLASS, METHOD_NAME2, reqMsg, resMsg);
            }else{
                ifLog.addLog('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));
                errorMsgList.add('Communication Error : ' + String.valueOf(result.get('Message')) + ' / StatusCode : ' + String.valueOf(resStatusCode));

                interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID2, guId, APEX_CLASS, METHOD_NAME2, reqMsg, resMsg, errorMsgList);
            }
           
        } catch(Exception e){
            ifLog.addLog('Exception : ' + String.valueOf(e.getMessage()));
            errorMsgList.add('Exception : ' + String.valueOf(e.getMessage()));

            interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID2, guId, APEX_CLASS, METHOD_NAME2, reqMsg, resMsg, e);
        } finally {
            ifLog.addLog('#################### ' + INTERFACE_ID2 + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME2 + ' 종료' + ' ####################');

            ifLog.createLog(interfaceLog);
        }
			
    }

    global class OutputHeader{

        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        //@AuraEnabled
        //public List<OutputClass> DATA; // 데이터 포멧        
    }

    public class InputClass{
        public List<IT_TABLE> IT_TABLE; 
    }
    public class IT_TABLE {
        public String BUKRS;
        public String KOSTL;
        public String NODE1;
        public String NODE2;
        public String NODE3;
        public String NODE4;
        public String NODE5;
        public String TEXT1;
        public String TEXT2;
        public String TEXT3;
        public String TEXT4;
        public String TEXT5;
        public String KOSTL_KTEXT;
        public String ZEXPIRED;
        public String ZZCHECK;
        public String L_ORGEH;
        public String GSBER;
        // public String BKZER;
        // public String BKZKP;
        // public String BKZKS;
        // public String BKZOB;
        // public String PKZER;
        // public String PKZKP;
        // public String PKZKS;
    }
}