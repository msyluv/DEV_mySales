/**
 * @description       :
 * @author            : ukhyeon.lee@samsung.com
 * @group             :
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log
 * Ver   Date         Author                    Modification
 * 1.0   06-21-2021   ukhyeon.lee@samsung.com   Initial Version
 * 1.0   09-01-2021   seonju.jin@dkbmc.com      getOpptyData 수정 - 본사협업의 경우 법인 협업기회에 read권한없는경우 예외처리
 * 1.1   04-01-2022   akash.g@samsung.com       MY-SALES - 108 -> Adding error message on click of BO review tab if Biz Type 1 is null.
 * 1.2   02-09-2023   anish.jain@partner.samsung.com  'Review Opportunity' Post Processing IF logs (My Sales - 107)
 * 1.3   05-10-2023   anish.jain@partner.samsung.com  Changed added to resolve the error for Subsidiary Opportunity
 * 1.4   09-15-2023   anish.jain@partner.samsung.com  BO Review Confirm error on CollaborationBO - MS -298
 * 1.5   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 1.6   2024-02-19   anish.jain@partner.samsung.com           BO Review Approval Issue Check (MS-418)
**/
public class OpportunityReviewMainController {

    static final String[] systemAdmin = new String[]{'System Administrator', '시스템 관리자', 'Custom System Administrator'};
    static final String[] piAdmin = new String[]{'PI (Biz. Owner)'};  
    static final String OPPTYACT_STATUS_COMPLETED = 'Completed';
    static final String OPPTYACT_STATUS_INPROGRESS = 'In Progress';


    //Opportunity에 ProjectCode가 있는지 조회
    public static Project__c getProjectCode(String recordId){        
        Project__c project = [SELECT Id
                                        , Name
                                        , ProjectCode__c
                                    FROM Project__c
                                WHERE opportunity__r.Id =:recordId
                                limit 1];
        return project;
    } 
   
    //Opportunity 데이터 조회
    public static Opportunity getOpptyData(String recordId){        
        Opportunity opptyData = [SELECT Id
                                    , Name /* 사업기회 명 */
                                    , Amount /* 수주 예상금액 */
                                    , CurrencyIsoCode /* 환율 */
                                    , OpportunityCode__c /* 사업기회 코드 */
                                    , cOriginAcc__c /* 원청사 ID */
                                    , cOriginAcc__r.Name /* 원청사 명 */
                                    , toLabel(cOriginAcc__r.mBizTypeL2Code__c) /* 업종(원청사) */
                                    , toLabel(cOriginAcc__r.mBizLoan__c) /* 신용등급(원청사) */
                                    , Opportunity_Review_cOriginAcc__c /* 저장된 원청사 */
                                    , AccountId /* 고객사 ID */
                                    , toLabel(Account.mBizLoan__c) /* 신용등급(고객사) */
                                    , Opportunity_Review_Account__c /* 저장된 고객사 */
                                    , Opportunity_Review_Biz_Amount__c /*사업규모금액 */
                                    , Opportunity_Review_Checkbox1__c /*체크박스1 */
                                    , Opportunity_Review_Checkbox2__c /*체크박스2 */
                                    , Opportunity_Review_Dangerous__c /* 위험고객 */
                                    , Opportunity_Review_Result__c /* BO점검결과 */
                                    , Opportunity_Review_Consortium__c /* 컨소시엄 여부 */
                                    , Opportunity_Review_Exception__c /* 사업심의예외 여부 */
                                    , Opportunity_Review_Exception_Reason__c /* 사업심의예외 사유 */
                                    , Opportunity_Review_VRB_Type__c /*사업심의유형*/
                                    , Opportunity_Review_VRB_Type_Confirm__c /*사업심의유형 확정 값 */
                                    , Opportunity_Review_Temp_Save__c /*임시저장여부*/
                                    , Opportunity_Review_Confirm__c /*사업심의 확정여부 */
                                    , CompanyCode__c /*회사코드 */
                                    , Collaboration__c /*협업여부*/
                                    , BusinessType__c /*사업 유형1*/
                                    , ReuseReason__c /* 재사용 사유 */
                                    , CollaborationBOId__c
                                    , WonCount__c
                                    , VRB_Account_Change__c
                                   
                                    
                                FROM Opportunity
                                WHERE Id =:recordId];  //Added by Anish-v 1.6

        
        //1 본사협업의 경우 
        //1.1 고객사 신용등급 값을 원청사 신용등급으로 표기 // 2021-12-15 해당 로직 사용 X
        //1.2 사업규모금액 없을경우 법인협업 사업규모금액(BizAmount)으로 표기                       
        //2 본사협업이 아닌 경우
        //2.1 사업규모금액 없을경우 수주금액(Amount)로 표기
        if(opptyData.Collaboration__c && 'T100'.equals(opptyData.CompanyCode__c)){
            UserRecordAccess userRecordAccess = [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = : opptyData.CollaborationBOId__c ];
            if(userRecordAccess == null || !userRecordAccess.HasReadAccess){
                System.debug(System.Label.OPPTYACT_BO_REVIEW_ERR_MSG_01 +',' + userRecordAccess);
                AuraHandledException e = new AuraHandledException(System.Label.OPPTYACT_BO_REVIEW_ERR_MSG_01);
                e.setMessage(System.Label.OPPTYACT_BO_REVIEW_ERR_MSG_01);
                throw e;
            }

            List<Opportunity> subsOppty = [SELECT Id, Opportunity_Review_Biz_Amount__c, CurrencyIsoCode, toLabel(Account.mBizLoan__c)   //Modified by Anish - v 1.3
                            FROM Opportunity
                            WHERE OpportunityCode__c =:opptyData.OpportunityCode__c
                            AND CompanyCode__c !=:opptyData.CompanyCode__c
                            AND Collaboration__c =:opptyData.Collaboration__c];
            if(subsOppty.Size()>0){         //Modified by Anish - v 1.3
                // opptyData.Account.mBizLoan__c = opptyData.cOriginAcc__r.mBizLoan__c; // 2021-12-15 해당 로직 사용 X
                if(opptyData.Opportunity_Review_Biz_Amount__c == null){
                    Map<String, DatedConversionRate> conversionRateMap = IF_Util.getRecentlyDatedConversionRate();                    // 최근 환율정보
                    Decimal calculationResult = 0;
                    String fromIsoCode = subsOppty[0].CurrencyIsoCode;      //Modified by Anish - v 1.3
                    String toIsocode = opptyData.CurrencyIsoCode;
                    Decimal fromUsdRate = 0;
                    Decimal toUsdRate = 0;
                    if (conversionRateMap.get(fromIsoCode) != null && conversionRateMap.get(toIsocode) != null) {                            
                        fromUsdRate = conversionRateMap.get(fromIsoCode).ConversionRate;                           
                        toUsdRate = conversionRateMap.get(toIsoCode).ConversionRate;
                        if( Util_String.nvlDec(subsOppty[0].Opportunity_Review_Biz_Amount__c) > 0){        //Modified by Anish - v 1.3
                            calculationResult = IF_Util.calculationCurrency(    fromIsoCode
                                                                                , subsOppty[0].Opportunity_Review_Biz_Amount__c     //Modified by Anish - v 1.3
                                                                                , toIsoCode
                                                                                , fromUsdRate
                                                                                , toUsdRate  );
                        }                        
                    }
                    opptyData.Opportunity_Review_Biz_Amount__c = calculationResult.setScale(2, System.RoundingMode.HALF_UP);
                }
            }
        } else if(opptyData.Opportunity_Review_Biz_Amount__c == null){                                         
            opptyData.Opportunity_Review_Biz_Amount__c  = opptyData.Amount;
        }
          
        return opptyData;
    }


    //현재 사용자가 profileName 에 해당하는지 체크
    public static Boolean checkProfile(String[] profileName){
        Boolean result = false;

        try{
            User user = [SELECT Id
                            , Name
                            , Profile.Name
                            , Profile.Id
                        FROM User
                        WHERE Profile.Name in :profileName
                        AND Id = :UserInfo.getUserId()];

            if(user != NULL && user.Id!=null){
                result = true;
            }  
        }
        catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            result = false;
        }
        
        return result;
    }
    
   //Added by Anish - v 1.5
    @AuraEnabled
    public static ContentVersion getVaultFileId(String docId){
        try {
            ContentVersion cv = [SELECT Id, ExternalDocumentInfo1, ExternalDocumentInfo2, ExternalDataSourceId
                                 FROM ContentVersion
                                 WHERE ContentDocumentId = :docId
                                    AND isLatest=true
                                 LIMIT 1];
            return cv;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
  //Added by Anish - v 1.5  
    @AuraEnabled
    public static Object getVaultAuthToken(String apiType, list<String> fileIds) {
        map<String, Object> token = new map<String, Object>();
        Boolean hasFiles = false;
        String endpoint = Label.EFSS_VAULT_AUTHURL + '/vault/sds/sfdc/otp?api=' + apiType;
        String sourceIp = getUserIPAddress();
        
        if(apiType == 'file-download' || apiType == 'file-multi-download' || apiType == 'file-view' || apiType == 'file-delete')
            hasFiles = true;

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + Label.EFSS_VAULT_AUTHKEY);
        req.setHeader('Client-Type', 'web');
        req.setHeader('Client-Addr', sourceIp);

        if(hasFiles){
            req.setHeader('Content-Type', 'application/json');
            if(fileIds == null || fileIds.isEmpty()) throw new CustomException('no files');
            list<String> files = new list<String>();
            for(String fileId : fileIds){
                files.add(fileId);
            }
            map<String, list<String>> mapBody = new map<String, list<String>>();
            mapBody.put('fileIds', files);
            // system.debug(JSON.serialize(mapBody));
            req.setBody(JSON.serialize(mapBody));
        }
        HttpResponse res = http.send(req);
        if(res.getStatusCode() == 200){
            token = (map<String, Object>) JSON.deserializeUntyped(res.getBody());
            // system.debug(token);
        } else {
            throw new CustomException('{"status":'+ String.valueOf(res.getStatusCode()) +', "message":'+ res.getStatus() +'}');
        }    
        return token;
    }
   
    // Added by Anish - v 1.5
    public static String getUserIPAddress() {
        String localIp = '203.244.212.21';
        return localIp;
    }
    
    // Added by Anish - v 1.5
    public class CustomException extends Exception {}

    //사업기회 데이터 조회
    @AuraEnabled
    public static Map<String,Object> getBOInfo(String opptyId){
        Map<String,Object> resultMap = new Map<String,Object>();
        //기본 성공메세지
        String result = 'S';
        String message = '';

        try{
            //Opportunity에 ProjectCode가 있는지 체크
            try{
                Project__c project = getProjectCode(opptyId);
                resultMap.put('project', project.ProjectCode__c);
            }
            catch(Exception e){
                resultMap.put('project', null);
            }

            Opportunity opptyData = getOpptyData(opptyId);
            Opportunity opptyData_origin = opptyData.clone();//화면에서 변경여부 확인하기 위함

            resultMap.put('opptyData', opptyData);
            resultMap.put('opptyData_origin', opptyData_origin);
            
            //Added by Anish - v 1.5
            RecordType rcdType = [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE SobjectType = 'OpportunityNotice__c' AND Name ='Guide'];
            Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
            List<OpportunityNotice__c> OpptyNoticeList = new List<OpportunityNotice__c>();
            if(isSandbox){
             OpptyNoticeList = [SELECT Id, Name, RecordTypeId, NoticeKR__c, NoticeEN__c, NoticeCN__c, CreatedDate 
                                                        FROM OpportunityNotice__c 
                                                       WHERE RecordTypeId =: rcdType.Id and Name = 'ON-20231200003'
                                                       ORDER BY CreatedDate DESC 
                                                       LIMIT 1];
            }
            else{
              OpptyNoticeList = [SELECT Id, Name, RecordTypeId, NoticeKR__c, NoticeEN__c, NoticeCN__c, CreatedDate 
                                                        FROM OpportunityNotice__c 
                                                       WHERE RecordTypeId =: rcdType.Id and Name = 'ON-20240100003'
                                                       ORDER BY CreatedDate DESC 
                                                       LIMIT 1];   
            }
            
            if(OpptyNoticeList.size() > 0){
            List<ContentDocumentLink> cdList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: OpptyNoticeList[0].Id];
            if(cdList.size() > 0) resultMap.put('CD', cdList[0].ContentDocumentId);
        }
            //Added by Anish - v 1.5
            
            //협업 포함해서 구축형이 없을경우 - BO점검및 수전위 안함
            // at least one TS or TD in BO include HQ and SUB
            List<Opportunity> optyList = [SELECT Id, BusinessType__c, Collaboration__c, CompanyCode__c
                                FROM Opportunity
                                WHERE OpportunityCode__c =:opptyData.OpportunityCode__c];
            resultMap.put('implementation', false);
            for(Opportunity opty : optyList){
                if('TI'==opty.BusinessType__c){
                    resultMap.put('implementation', true);
                }
            }

            //V 1.1 -> MY-SALES - 108 -> Adding error message on click of BO review tab if Biz Type 1 is null.
            List<Opportunity> optyListNullCheck = [SELECT Id, BusinessType__c, Collaboration__c, CompanyCode__c
                                FROM Opportunity
                                WHERE id =:opptyData.Id];
            resultMap.put('implementationNull', false);
            for(Opportunity opty : optyListNullCheck){
                if(opty.BusinessType__c == null){
                    system.debug('Inside Null Business type');
                    resultMap.put('implementationNull', true);
                }
            }

            
            //PI, System Admin인지 여부
            Boolean isPiAdmin = checkProfile(piAdmin);
            Boolean isSystemAdmin = checkProfile(systemAdmin);
            resultMap.put('isAdmin', isPiAdmin||isSystemAdmin);

            String money = String.valueOf(opptyData.Amount);
            String cur = opptyData.CurrencyIsoCode;
            resultMap.put('curAmount', money + ' ' + cur);

            // 2021-12-14 / BO점검 확정여부 체크 추가
            Boolean isConfirm = opptyData.Opportunity_Review_Confirm__c;
            resultMap.put('isConfirm', isConfirm);
            Boolean isAmtChange = true;
            if(opptyData.Opportunity_Review_Confirm__c && opptyData.WonCount__c == 0) isAmtChange = false;
            resultMap.put('isAmtChange', isAmtChange);
            

            /*<pick list - VRB Method 조회>
                - Admin인 경우에는 combobox 값을 다 보여준다
                - Admin이 아니라면 원래 저장된 사업심의유형 정보가 있을경우, 해당 유형정보 하위의 값은 화면에 보여주지 않는다
            */
            List<Map<String, String>> vrbPickList = new List<Map<String, String>>();
            List<Map<String, String>> vrbLabelList = new List<Map<String, String>>();
            List<Map<String, String>> vrbValueList = Utils.getPicklistOptionType('Opportunity', 'Opportunity_Review_VRB_Type__c');

            
            //화면에서 VRB method label 세팅용도
            resultMap.put('vrbCount', vrbValueList.size());
            resultMap.put('vrbLabelList', vrbValueList);
            
            // Default Map Setting
            Map<String, String> defaultMap = new Map<String, String>();
            // defaultMap.put('label', '없음');
            // defaultMap.put('value', '');
            // vrbPickList.add(defaultMap);

            //Admin이거나, 기존에 저장된 값이 없는 경우에는 combobox 값을 다 보여준다
            if ((isPiAdmin||isSystemAdmin) ||
                String.isBlank(opptyData.Opportunity_Review_VRB_Type__c)){
                for(Integer i = 0; i < vrbValueList.size(); i++){
                    vrbPickList.add(vrbValueList[i]);
                }
            }
            else{
                for(Integer i = 0; i < vrbValueList.size(); i++){
                    /*
                        Opportunity_Review_VRB_Type__c picklist 값들
                        전사수전위      10
                        사업부수전위    20
                        BO점검회의      30
                        사업불참        40
                    */
                    if(40!=Decimal.valueOf(opptyData.Opportunity_Review_VRB_Type__c)){
                        if (Decimal.valueOf(vrbValueList[i].get('value')) <= Decimal.valueOf(opptyData.Opportunity_Review_VRB_Type__c)){
                            vrbPickList.add(vrbValueList[i]);
                        }
                    } else{
                        if (Decimal.valueOf(vrbValueList[i].get('value')) == Decimal.valueOf(opptyData.Opportunity_Review_VRB_Type__c)){
                            vrbPickList.add(vrbValueList[i]);
                        }
                    }
                }
            }

            resultMap.put('vrbPickList', vrbPickList);


            //수주품의 완료 결재이력이 있으면 수정/저장 버튼 disable
            String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
            List<KnoxApproval__c> knoxApproval = [
                SELECT  Id
                FROM    KnoxApproval__c
                WHERE   Opportunity__c = :opptyId
                    AND OpportunityActivity__r.TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
                    AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                        )
            ];
            
            //Added by Anish-v 1.5
            List<KnoxApproval__c> knoxApprovalList = [
                SELECT  Id
                FROM    KnoxApproval__c
                WHERE   Opportunity__c = :opptyId
                    AND OpportunityActivity__r.TransactionName__c = 'ZP21'
                    AND ( Status__c = '1'
                        )
            ];
            
             if(!knoxApprovalList.isEmpty()){
                resultMap.put('pendingKnox', true);
            }  
            //Added by Anish-v 1.5
            
            if(!knoxApproval.isEmpty()){
                resultMap.put('approved', true);
            }                                    
        
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
        }

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);

        return resultMap;
    }

    
    //사업기회 데이터 저장
    @AuraEnabled
    public static Map<String, Object> boDataSave(String recordId, String inputDatas){
        Map<String,Object> resultMap = new Map<String,Object>();

        //기본 성공메세지
        String result = 'S';
        String message = 'Opportunity information update success.';// Opportunity information update success.

        try{
            //PI, System Admin인지 여부
            Boolean isPiAdmin = checkProfile(piAdmin);
            Boolean isSystemAdmin = checkProfile(systemAdmin);
        

            //화면에서 전달한 입력값
            List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
            Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);

            //변경전 데이터 조회
            Opportunity opptyData = getOpptyData(recordId);
            
            //재사용여부 입력여부 체크
            Map<String,String> fieldMap = Utils.getFieldLabel('Opportunity');       //Opporutnity 필드정보Map
            if(opptyData.CompanyCode__c == 'T100' && (opptyData.BusinessType__c != null && opptyData.BusinessType__c == 'TI')){
                if(String.isBlank(opptyData.ReuseReason__c)){
                    resultMap.put('RESULT', 'E');
                    resultMap.put('MESSAGE', System.Label.SVC_ERR_MSG_04 + '\n[' + Util_String.nvlStr(fieldMap.get('ReuseReason__c'.toLowerCase())) +']');
                    return resultMap;
                }
            }

            //화면에서 전달한 변수들 입력
            if (inputData.get('Opportunity_Review_Biz_Amount__c') instanceOf String)
                opptyData.Opportunity_Review_Biz_Amount__c = Decimal.valueOf((String)inputData.get('Opportunity_Review_Biz_Amount__c'));
            else
                opptyData.Opportunity_Review_Biz_Amount__c = ((Decimal)inputData.get('Opportunity_Review_Biz_Amount__c'));

            opptyData.Opportunity_Review_Checkbox1__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox1__c');
            opptyData.Opportunity_Review_Checkbox2__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox2__c');
            opptyData.Opportunity_Review_Result__c           = (String)inputData.get('Opportunity_Review_Result__c');
            opptyData.Opportunity_Review_Consortium__c       = (Boolean)inputData.get('Opportunity_Review_Consortium__c');
            opptyData.Opportunity_Review_VRB_Type__c         = (String)inputData.get('Opportunity_Review_VRB_Type__c');
            opptyData.Opportunity_Review_Dangerous__c        = (String)inputData.get('Opportunity_Review_Dangerous__c');
            
            //사업심의예외는 Admin 일때만
            if (isPiAdmin || isSystemAdmin){
                opptyData.Opportunity_Review_Exception__c        = (Boolean)inputData.get('Opportunity_Review_Exception__c');
                opptyData.Opportunity_Review_Exception_Reason__c = (String)inputData.get('Opportunity_Review_Exception_Reason__c');
                opptyData.Opportunity_Review_Exception_Modifier__c = UserInfo.getUserId(); //사업심의유형 변경자
            }
            
            //임시저장의 경우 Temp_Save = true
            opptyData.Opportunity_Review_Temp_Save__c = true;
            
            //현재 어카운트 정보 저장
            opptyData.Opportunity_Review_cOriginAcc__c = opptyData.cOriginAcc__c;
            opptyData.Opportunity_Review_Account__c = opptyData.AccountId;

            //업데이트 수행
            update opptyData;

            //Activity 업데이트
            //added extra condition for Anish-v 1.5

            upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_INPROGRESS, false,false); //Modified for Anish-v 1.5

            resultMap.put('opptyData', opptyData);
            resultMap.put('opptyData_origin', opptyData);

        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
        }

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);
        System.debug('Ani Test @---->'+ resultMap);
        return resultMap;
    }


    //사전심의결과 조회
    @AuraEnabled
    public static Map<String,Object> retrieveBusinessCheckType(String opptyId, String inputDatas){
        Map<String,Object> resultMap = new Map<String,Object>();

        try{
            //화면에서 입력한 값
            List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
            Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);

            //사업기회 기본데이터 조회
            Opportunity opptyData = getOpptyData(opptyId);

            //PI, System Admin인지 여부
            Boolean isPiAdmin = checkProfile(piAdmin);
            Boolean isSystemAdmin = checkProfile(systemAdmin);
            resultMap.put('isAdmin', isPiAdmin||isSystemAdmin);

            //화면에서 전달한 변수들 입력
            if (inputData.get('Opportunity_Review_Biz_Amount__c') instanceOf String)
                opptyData.Opportunity_Review_Biz_Amount__c = Decimal.valueOf((String)inputData.get('Opportunity_Review_Biz_Amount__c'));
            else
                opptyData.Opportunity_Review_Biz_Amount__c = ((Decimal)inputData.get('Opportunity_Review_Biz_Amount__c'));

            if (inputData.get('Amount') instanceOf String)
                opptyData.Amount = Decimal.valueOf((String)inputData.get('Amount'));
            else
                opptyData.Amount = ((Decimal)inputData.get('Amount'));

            opptyData.Opportunity_Review_Checkbox1__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox1__c');
            opptyData.Opportunity_Review_Checkbox2__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox2__c');
            opptyData.Opportunity_Review_Result__c           = (String)inputData.get('Opportunity_Review_Result__c');
            opptyData.Opportunity_Review_Consortium__c       = (Boolean)inputData.get('Opportunity_Review_Consortium__c');
            opptyData.Opportunity_Review_VRB_Type__c         = (String)inputData.get('Opportunity_Review_VRB_Type__c');
            
            //사업심의결과는 Admin 일때만
            if (isPiAdmin || isSystemAdmin){
                opptyData.Opportunity_Review_Exception__c        = (Boolean)inputData.get('Opportunity_Review_Exception__c');
                opptyData.Opportunity_Review_Exception_Reason__c = (String)inputData.get('Opportunity_Review_Exception_Reason__c');
                opptyData.Opportunity_Review_Exception_Modifier__c = UserInfo.getUserId(); //사업심의유형 변경자
            }

            //사전심의결과 연계조회 - Interface
            String CONSORTIUM_YN = 'N';
            Boolean checkVar = (Boolean)inputData.get('Opportunity_Review_Consortium__c');
            if (checkVar){
                CONSORTIUM_YN = 'Y';
            }

            String COMPLIANCE_1_YN = 'N';
            checkVar = (Boolean)inputData.get('Opportunity_Review_Checkbox1__c');
            if (checkVar){
                COMPLIANCE_1_YN = 'Y';
            }

            String COMPLIANCE_2_YN = 'N';
            checkVar = (Boolean)inputData.get('Opportunity_Review_Checkbox2__c');
            if (checkVar){
                COMPLIANCE_2_YN = 'Y';
            }
            
            Map<String,String> inputMap = new Map<String, String>();
            inputMap.put('ZZORDER_ID'       , opptyData.OpportunityCode__c);//BO코드
            inputMap.put('ZZBUKRS_H'    , opptyData.CompanyCode__c);//회사코드
            inputMap.put('CONSORTIUM_YN'  , CONSORTIUM_YN);//컨소시엄여부
            inputMap.put('COMPLIANCE_1_YN', COMPLIANCE_1_YN);//Complicance 1
            inputMap.put('COMPLIANCE_2_YN', COMPLIANCE_2_YN);//Complicance 2

            inputMap.put('BIZ_AMOUNT'     , String.valueOf(opptyData.Opportunity_Review_Biz_Amount__c));//사업규모(VAT제외)
            //협업+본사의 경우 법인 사업규모 금액 전송 - 22.07.05
            if(opptyData.Collaboration__c && 'T100'.equals(opptyData.CompanyCode__c)){
                List<Opportunity> subsOppty = [SELECT Id, Opportunity_Review_Biz_Amount__c
                            FROM Opportunity
                            WHERE OpportunityCode__c =:opptyData.OpportunityCode__c
                            AND CompanyCode__c !=:opptyData.CompanyCode__c
                            AND Collaboration__c =:opptyData.Collaboration__c
                            LIMIT 1];
                if(!subsOppty.isEmpty()){
                    inputMap.put('BIZ_AMOUNT'     , String.valueOf(subsOppty[0].Opportunity_Review_Biz_Amount__c));//사업규모(VAT제외)
                }     
            }


            Map<String,String> returnMap = getBOVRBCheck(inputMap);
            
            //조회결과 리턴
            resultMap.put('opptyData', opptyData);
            resultMap.put('infData', returnMap);

            /*<pick list - VRB Method 조회>
                - Admin인 경우에는 combobox 값을 다 보여준다
                - Admin이 아니라면 원래 저장된 사업심의유형 정보가 있을경우, 해당 유형정보 하위의 값은 화면에 보여주지 않는다
            */
            List<Map<String, String>> vrbPickList = new List<Map<String, String>>();
            List<Map<String, String>> vrbLabelList = new List<Map<String, String>>();
            List<Map<String, String>> vrbValueList = Utils.getPicklistOptionType('Opportunity', 'Opportunity_Review_VRB_Type__c');

            
            //화면에서 VRB method label 세팅용도
            resultMap.put('vrbCount', vrbValueList.size());
            resultMap.put('vrbLabelList', vrbValueList);
            
            // Default Map Setting
            Map<String, String> defaultMap = new Map<String, String>();
            // defaultMap.put('label', '없음');
            // defaultMap.put('value', '');
            // vrbPickList.add(defaultMap);
            Integer EV_VRB_TYPE = 30;
            try{
                if (returnMap!=null && returnMap.get('EV_VRB_TYPE')!=null){
                    EV_VRB_TYPE = Integer.valueof(returnMap.get('EV_VRB_TYPE'));
                }
            }
            catch(Exception e){
                EV_VRB_TYPE = 30;
            }

            //Admin이면 combobox 값을 다 보여준다
            if (isPiAdmin||isSystemAdmin){
                for(Integer i = 0; i < vrbValueList.size(); i++){
                    vrbPickList.add(vrbValueList[i]);
                }
            }
            //Admin이 아니면 사전심의결과 조회된 값보다 상위의 값만 보여준다
            //
            else{
                for(Integer i = 0; i < vrbValueList.size(); i++){
                    /*
                        Opportunity_Review_VRB_Type__c picklist 값들
                        전사수전위      10
                        사업부수전위    20
                        BO점검회의      30
                        사업불참        40
                    */
                    if(40!=EV_VRB_TYPE){
                        if (Decimal.valueOf(vrbValueList[i].get('value')) <= EV_VRB_TYPE){
                            vrbPickList.add(vrbValueList[i]);
                        }
                    } else{
                        if (Decimal.valueOf(vrbValueList[i].get('value')) == EV_VRB_TYPE){
                            vrbPickList.add(vrbValueList[i]);
                        }
                    }
                }
            }
            resultMap.put('vrbPickList', vrbPickList);

        }
        catch(Exception e){
            resultMap.put('error', e.getMessage());
            System.debug('ERROR : ' + e.getMessage());
        }

        return resultMap;
    }
    
    
    //사전심의결과 연계조회 - Interface
    @AuraEnabled
    public static Map<String, String> getBOVRBCheck(Map<String, String> inputMap) {
        Map<String, String> rtnMap = new Map<String, String>();
        rtnMap.put('RESULT', '');
        rtnMap.put('MESSAGE', '');
        rtnMap.put('DATA', '');

        try {
            IF_SdBOVRBCheckController.OutputHeader inputData = new IF_SdBOVRBCheckController.OutputHeader();
            
            inputData.ZZORDER_ID      = inputMap.get('ZZORDER_ID');//BO코드
            inputData.ZZBUKRS_H       = inputMap.get('ZZBUKRS_H');//회사코드
            inputData.BIZ_AMOUNT      = inputMap.get('BIZ_AMOUNT');//사업규모(VAT제외)
            inputData.CONSORTIUM_YN   = inputMap.get('CONSORTIUM_YN');//컨소시엄여부
            inputData.COMPLIANCE_1_YN = inputMap.get('COMPLIANCE_1_YN');//Complicance 1
            inputData.COMPLIANCE_2_YN = inputMap.get('COMPLIANCE_2_YN');//Complicance 2

            Map<String, Object> resultMap = IF_SdBOVRBCheckController.getBOVRBCheck(
                JSON.serialize(inputData)
            );

            HttpResponse hRes = (HttpResponse) resultMap.get('HttpResponse');
            Map<String, Object> bodyMap = (Map<String, Object>) JSON.deserializeUntyped(
                hRes.getBody()
            );

            System.debug('EV_RESULT : ' + bodyMap.get('EV_RESULT'));
            System.debug('INTERFACE_LOG : ' + resultMap.get('INTERFACE_LOG'));

            // TO-DO
            // success
            if (bodyMap.get('EV_RESULT') != null && bodyMap.get('EV_RESULT')=='S') {
                rtnMap.put('RESULT', 'S');
                rtnMap.put('EV_DANGER_YN', (String)bodyMap.get('EV_DANGER_YN'));
                rtnMap.put('EV_VRB_TYPE', (String)bodyMap.get('EV_VRB_TYPE'));       
            }//2022-08-12 yeongju.baek@dkbmc.com 대외사업 참여시 전사 수전위 필수영역 변경건 
            else if(bodyMap.get('EV_RESULT')=='I'){
				rtnMap.put('RESULT', 'I');
                rtnMap.put('EV_DANGER_YN', (String)bodyMap.get('EV_DANGER_YN'));
                rtnMap.put('EV_VRB_TYPE', (String)bodyMap.get('EV_VRB_TYPE'));
                rtnMap.put('MESSAGE', replaceNewlineToTag((String) bodyMap.get('EV_MESSAGE')));                
            } else {
                rtnMap.put('RESULT', 'E');
                rtnMap.put('MESSAGE', (String) bodyMap.get('EV_MESSAGE'));
            }

            if (resultMap.get('INTERFACE_LOG') != null) {
                IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog) resultMap.get(
                'INTERFACE_LOG'
                );
                IF_Log log = new IF_Log();
                log.createLog(ifLog);
            }

        } catch (Exception e) {
            System.debug('ERROR : ' + e.getMessage());
            rtnMap.put('RESULT', 'E');
            rtnMap.put('MESSAGE', System.Label.OPPTYACT_BO_REVIEW_SEARCH_ERROR); 
        }

        return rtnMap;
    }


    //사전심의결과 확정
    @AuraEnabled
    public static Map<String, Object> confirmBoData(String recordId, String inputDatas){
        Map<String,Object> resultMap = new Map<String,Object>();

        //기본 성공메세지
        String result = 'S';
        String message = System.Label.OPPTYACT_BO_REVIEW_SAVE;

        try{
            //PI, System Admin인지 여부
            Boolean isPiAdmin = checkProfile(piAdmin);
            Boolean isSystemAdmin = checkProfile(systemAdmin);

            //화면에서 전달한 입력값
            List<Object> inputList = (List<Object>)JSON.deserializeUntyped(inputDatas);
            Map<String, Object> inputData = (Map<String, Object>)inputList.get(0);

            //변경전 데이터 조회
            Opportunity opptyData = getOpptyData(recordId);
            
            //재사용여부 입력여부 체크
            Map<String,String> fieldMap = Utils.getFieldLabel('Opportunity');       //Opporutnity 필드정보Map
            if(opptyData.CompanyCode__c == 'T100' && (opptyData.BusinessType__c != null && opptyData.BusinessType__c == 'TI')){
                if(String.isBlank(opptyData.ReuseReason__c)){
                    resultMap.put('RESULT', 'E');
                    resultMap.put('MESSAGE', System.Label.SVC_ERR_MSG_04 + '\n[' + Util_String.nvlStr(fieldMap.get('ReuseReason__c'.toLowerCase())) +']');
                    return resultMap;
                }
            }
            
            //최초 확정여부 조회
            Boolean isEdit = opptyData.Opportunity_Review_Confirm__c;

            //화면에서 전달한 변수들 입력
            if (inputData.get('Opportunity_Review_Biz_Amount__c') instanceOf String)
                opptyData.Opportunity_Review_Biz_Amount__c = Decimal.valueOf((String)inputData.get('Opportunity_Review_Biz_Amount__c'));
            else
                opptyData.Opportunity_Review_Biz_Amount__c = ((Decimal)inputData.get('Opportunity_Review_Biz_Amount__c'));

            opptyData.Opportunity_Review_Checkbox1__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox1__c');
            opptyData.Opportunity_Review_Checkbox2__c        = (Boolean)inputData.get('Opportunity_Review_Checkbox2__c');
            opptyData.Opportunity_Review_Result__c           = (String)inputData.get('Opportunity_Review_Result__c');
            opptyData.Opportunity_Review_Consortium__c       = (Boolean)inputData.get('Opportunity_Review_Consortium__c');
            opptyData.Opportunity_Review_VRB_Type__c         = (String)inputData.get('Opportunity_Review_VRB_Type__c');
            opptyData.Opportunity_Review_VRB_Type_Confirm__c = (String)inputData.get('Opportunity_Review_VRB_Type__c');
            opptyData.Opportunity_Review_Dangerous__c        = (String)inputData.get('Opportunity_Review_Dangerous__c');
            opptyData.Opportunity_Review_Confirm__c          = true; //BO 점검결과 확정여부 true처리
            if (inputData.get('Amount') instanceOf String)
                opptyData.Amount = Decimal.valueOf((String)inputData.get('Amount'));
            else
                opptyData.Amount = (Decimal)inputData.get('Amount');
            opptyData.IsCustom__c                            = true;

            //사업심의예외는 Admin 일때만
            if (isPiAdmin || isSystemAdmin){
                opptyData.Opportunity_Review_Exception__c        = (Boolean)inputData.get('Opportunity_Review_Exception__c');
                opptyData.Opportunity_Review_Exception_Reason__c = (String)inputData.get('Opportunity_Review_Exception_Reason__c');
                opptyData.Opportunity_Review_Exception_Modifier__c = UserInfo.getUserId(); //사업심의유형 변경자
            }
            
            //결과확정일 경우 Temp_Save = false
            opptyData.Opportunity_Review_Temp_Save__c = false;
            
            //현재 어카운트 정보 저장
            opptyData.Opportunity_Review_cOriginAcc__c = opptyData.cOriginAcc__c;
            opptyData.Opportunity_Review_Account__c = opptyData.AccountId;

            //업데이트 수행
            update opptyData;
            
            //Start-Added by Anish-v 1.5
            Boolean knxApproved = false;
            Boolean knxApproved1 = false;  //Added by Anish-v 1.6
            String knxStatus = '';  //Added by Anish-v 1.6
            Boolean oppApproved = false;

            List<KnoxApproval__c> knAppr1 = [Select Id,Status__c from KnoxApproval__c where Opportunity__c =: opptyData.id and OpportunityActivity__r.TransactionName__c = 'ZP21' Order by CreatedDate Desc]; //Added by Anish-v 1.6
            if(knAppr1.Size()>0){
                System.debug('AJ Entry1');
               knxApproved1 = true;
               knxStatus = knAppr1[0].Status__c;
                if(knAppr1[0].Status__c == '2'){
                  knxApproved = true;  
                }
            }
            
            List<Opportunity_Activity__c> oppAct = [Select Id,Status__c from Opportunity_Activity__c where WhatId__c =: opptyData.id and TransactionName__c = 'XP63' and Status__c ='Completed' Order by CreatedDate Desc LIMIT 1]; //Added by Anish-v 1.6
           // if(oppAct != null || oppAct.Id !=null || oppAct.Id !=''){
            if(oppAct.Size()>0){
               System.debug('AJ Entry');
               oppApproved = true;
            }
            //End-Added by Anish-v 1.5

            //본사에서 협업일 경우
            if(opptyData.Collaboration__c && 'T100'.equals(opptyData.CompanyCode__c)){  
                OpportunityReviewSyncController infoCall = new OpportunityReviewSyncController(opptyData.Id); //Added by Anish- V 1.4
                    System.enqueueJob(infoCall);
            }

            
            //Compliance에 체크되어있지 않다면 Activity 완료처리
            //added extra condition for Anish-v 1.5
            if (!opptyData.Opportunity_Review_Checkbox1__c && !opptyData.Opportunity_Review_Checkbox2__c && opptyData.Opportunity_Review_VRB_Type__c != '30' ){
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_COMPLETED, isEdit,false);
            }
            
            
            
            //for Anish-v 1.5 reverting the activity status back to in progress from completed If BO Review Meeting is selected again START
            if(opptyData.VRB_Account_Change__c == false){ //Added by Anish-v 1.6
            if (!opptyData.Opportunity_Review_Checkbox1__c && !opptyData.Opportunity_Review_Checkbox2__c && opptyData.Opportunity_Review_VRB_Type__c == '30' && knxApproved == false){ //Added by Anish-v 1.5
                if(!(opptyData.Collaboration__c == false && opptyData.CompanyCode__c == 'T100')){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_COMPLETED, isEdit,true);
                }
                else{
                if(oppApproved == false){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_INPROGRESS, isEdit,true);
                 }
                //Added by Anish-v 1.6
                if(oppApproved == true){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_COMPLETED, isEdit,true);
                 }
                }
            } 
            }
            //Added by Anish - v 1.6
            if(opptyData.VRB_Account_Change__c == true){
             if (!opptyData.Opportunity_Review_Checkbox1__c && !opptyData.Opportunity_Review_Checkbox2__c && opptyData.Opportunity_Review_VRB_Type__c == '30'){ //Added by Anish-v 1.5
                if(!(opptyData.Collaboration__c == false && opptyData.CompanyCode__c == 'T100')){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_COMPLETED, isEdit,true);
                }
                else{
                //if(oppApproved == false){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_INPROGRESS, isEdit,true);
                // }
                /*if(oppApproved == true){
                    System.debug('AJ Entry');
                upsertOpportunityActivity(opptyData.id, OPPTYACT_STATUS_COMPLETED, isEdit,true);
                 }*/
                }
            }    
                
            }
            //for 1.5 reverting the activity status back to in progress from completed If BO Review Meeting is selected again END

            resultMap.put('opptyData', opptyData);
            resultMap.put('opptyData_origin', opptyData);
            resultMap.put('knoxRecord', knxApproved1); //Added by Anish-v 1.6
            resultMap.put('knxStatus', knxStatus); //Added by Anish-v 1.6
            
        }catch(Exception e){
            System.debug('ERROR : ' + e.getMessage());
            result = 'E';
            message = 'ERROR : ' + e.getMessage();
        }

        resultMap.put('RESULT', result);
        resultMap.put('MESSAGE', message);
        
        return resultMap;
    }
    
    //Opportunity Activity 완료 처리
//Anish-v 1.5 edited by @rakshit.s@samsung.com 
    //added new boolean argument to method to revert back activity status to in progress from completed in case of BO review meeting.
    public static void upsertOpportunityActivity(String opptyId, String actStatus, Boolean isEdit, Boolean isBOReviewMeeting){

        List<Opportunity_Activity__c> opptyActList = [SELECT Id
                                                           , Name 
                                                           ,Status__c
                                                           , StartDate__c 
                                                           , DueDate__c
                                                           , EndDate__c
                                                           , ExtId__c
                                                           , WhatId__c, WhatId__r.OpportunityCode__c, WhatId__r.CompanyCode__c
                                                           , TransactionName__c, WhatId__r.Opportunity_Review_VRB_Type_Confirm__c 
                                                        FROM Opportunity_Activity__c 
                                                        WHERE WhatId__c =: opptyId AND TransactionName__c = :OpportunityActivityHelper.ACT_CODE_REVIEW_BO // ZP21
                                                        ORDER BY CreatedDate DESC LIMIT 1]; //Modified by Anish - v 1.2

        if(opptyActList.size() > 0){
            Opportunity_Activity__c opptyAct = opptyActList[0];            
            
            if(actStatus == OPPTYACT_STATUS_INPROGRESS){        //1. 저장 후            
                //Activity Completed 아닐 경우에만 Inprogress update
                if(opptyAct.Status__c != OPPTYACT_STATUS_COMPLETED /*v Anish-v 1.5*/ || isBOReviewMeeting ){
                    System.debug('AJ1 Entry');
                    opptyAct.Status__c =  OPPTYACT_STATUS_INPROGRESS;   //In Progress
                }else{
                    return;
                }
            }else if(actStatus == OPPTYACT_STATUS_COMPLETED){   //2. 사업심의유형 확정 시
                opptyAct.Status__c = OPPTYACT_STATUS_COMPLETED;
            }
            
            //액티비티 상태 완료일 때 Activity Date 비어있을 경우 today 입력
            if(opptyAct.Status__c == OPPTYACT_STATUS_COMPLETED){
                if( String.isBlank(String.ValueOf(opptyAct.StartDate__c)) ) {
                    opptyAct.StartDate__c = Date.today();
                } else if (opptyAct.StartDate__c > Date.today()) {
                    opptyAct.StartDate__c = Date.today();
                }
                
                //사전영업자원요청 && 수주품의 결재이력 없을경우 && 최초 확정일경우 EndDate 업데이트 하지 않음
                String ACT_CODE_CONTRACT_APPROVAL = OpportunityActivityHelper.ACT_CODE_CONTRACT_APPROVAL;
                String ACT_CODE_REQUEST_RESOURCES = OpportunityActivityHelper.ACT_CODE_REQUEST_RESOURCES;
                List<KnoxApproval__c> knoxApproval = [
                    SELECT  Id
                    FROM    KnoxApproval__c
                    WHERE   Opportunity__c = :opptyId
                    AND ( OpportunityActivity__r.TransactionName__c = :ACT_CODE_CONTRACT_APPROVAL
                        OR OpportunityActivity__r.TransactionName__c = :ACT_CODE_REQUEST_RESOURCES)
                    AND ( Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_COMPLETED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_ARBITRARY_CONFIRMED
                        OR Status__c = :KnoxApprovalHelper.KNOX_APPROVAL_STATUS_AFTER_CONFIRMED
                        )
                ];

                if( knoxApproval.isEmpty() && !isEdit && opptyAct.EndDate__c == null) {
                    opptyAct.EndDate__c = Date.today();
                }                
            }
            try{
            upsert opptyAct;
            OpportunityServiceSolutionMainController.createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '6.BO Review Completed : Success, value : '+ opptyActList[0].WhatId__r.Opportunity_Review_VRB_Type_Confirm__c , 'S'); //Added by Anish - v 1.2
            if(opptyAct.Status__c == OPPTYACT_STATUS_COMPLETED){
                OpportunityServiceSolutionMainController.createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+ opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '7.(BO Review)Opportunity Activity Status Updated : Success, Value : ' + opptyAct.Status__c, 'S'); //Added by Anish - v 1.2
                }    
            }
            catch(exception e){
             OpportunityServiceSolutionMainController.createInterfaceLog3('upsertOpportunityActivity', 'BO_CODE : '+opptyActList[0].WhatId__r.OpportunityCode__c + ', COMPANY_CODE : ' + opptyActList[0].WhatId__r.CompanyCode__c + '\n' + '6.BO Review Failed : '+ e.getStackTraceString() + ' Message : ' + e.getMessage() , 'F'); //Added by Anish - v 1.2   
            }
        }
    }
    //2022-08-17 yeongju.baek
    private static String replaceNewlineToTag(String longText) {
        return longText.replace('\\n', '\n');
    }

}