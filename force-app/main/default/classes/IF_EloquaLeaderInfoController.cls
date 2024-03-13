/**
 * @description       : 
 * @author            : soohong0.kim@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-11-08
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                             Modification
 * 1.0   04-23-2021   soohong0.kim@partner.samsung.com   Initial Version
 * 1.1   05-17-2021   kilhwan.an@partner.samsung.com     
 * 1.2   07-07-2021   seonju.jin@dkbmc.com               마케팅리드 사업리드 캠페인 정보 미일치의 건 수정
                                                         마케팅 리드 / 세일즈 리드 : 리드 소유자 => SFDC Sales Lead owner
                                                         마케팅 리드 : Marketing lead 담당자  => SFDC Lead Owner
 * 1.3   2021-09-09   younghoon.kim@dkbmc.com            Lead 생성 로직 및 Sales Lead 생성 로직 수정
                                                         - Lead를 생성할때 Status는 Cold, Stage는 In Process로 설정
                                                         - Sales Lead는 생성하지 않도록 로직 수정
 * 1.4	 2022-08-09	  hyunhak.roh@dkbmc.com				 (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
 														 - 추가 : IF_Log 방식 변경
**/
@RestResource( UrlMapping='/IF141/*')
global class IF_EloquaLeaderInfoController implements Schedulable {
    private static final String INTERFACE_ID = 'IF-141';
    private static final String APEX_CLASS   = 'IF_EloquaLeaderInfoController';
    private static final String METHOD_NAME  = 'doPost';
    private static final String MYSALES_EMAIL= 'mysales@samsung.com';
    private static final Boolean isSandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;

    // 데이터 비동기 처리 : 대량의 데이터 처리:
    @HttpPost
    global static OutputHeader doPost(){
        // 로그 정보
        String              guId      = IF_Util.generateGuid();
        OutputHeader        outHeader = new OutputHeader();
        IF_Log              log       = new IF_Log();
        IF_Log.InterfaceLog infLog    = null;

        RestRequest req     = RestContext.request;
        Blob        reqBody = req.requestBody;
        
        Savepoint sp = DataBase.setSavePoint();
        
        //2022-08-09, hyunhak.roh@dkbmc.com, (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
        Integer                   rowCnt   = 0;
        String					  errPreStr= '';
        Boolean                   errChk   = false;
        //2022-08-09, hyunhak.roh@dkbmc.com, (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
        Integer					  totalCnt = 0;
        Integer					  cptLeadCnt   = 0;
        Integer					  errLeadCnt   = 0;
        Integer					  cptCamMCnt   = 0;
        Integer					  errCamMCnt   = 0;
        
        try{
            InputHeader input = (InputHeader)JSON.deserializeStrict(reqBody.toString(),InputHeader.class);
            
            if(input == null){
                outHeader.EV_RESULT = IF_Util.RESULT_MESSAGE_ERROR;
                outHeader.EV_MESG   = 'No Data';

                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
                log.createLog( infLog);
                return outHeader;
            }           

            List<IT_DATA> dataList = input.IT_DATA;
            List<String> emailList = new List<String>();
            Map<String, IT_DATA> itDataMap = new Map<String, IT_DATA>();
            
            emailList.add('mysales@samsung.com');
        	for(IT_DATA data : dataList){
                emailList.add(data.SFDCLeadowner);
                emailList.add(data.SFDCSalesLeadowner);
                
                //2022-08-09, hyunhak.roh@dkbmc.com, (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
                if(data.CampaignId != null && data.CampaignId != '') {
                    
                    if(Utils.isValidSalesforceId(data.CampaignId, Campaign.class)) {
                        itDataMap.put(data.ELOQUA_ID, data);
                    }
                    else {
                        errChk = true;
                        errCamMCnt++;
                    }
                }
                
                totalCnt++;
            }
        	
            // [S] Get User Info
            List<User> userList = [SELECT Id, Email, CompanyCode__c, FederationIdentifier FROM User WHERE Email in: emailList];
            Map<String,String> userMap = new Map<String,String>();
            Set<String> compCodeSet = new Set<String>();
            Set<String> fedIdSet = new Set<String>();
            Map<String, String> epidMap = new Map<String, String>();

            for(User user : userList){
                userMap.put(user.Email,user.id);
                compCodeSet.add(user.CompanyCode__c);
                fedIdSet.add(user.FederationIdentifier);
                epidMap.put(user.Id, user.FederationIdentifier + '_' + user.CompanyCode__c);
            }
            // [E] Get User Info

            // [S] Get Employee Info
            Map<String, String> epidToCCMap = new Map<String, String>();
            List<Employee__c> empList = [SELECT Id, Name, EvMailAddr__c, EvSapBukrs__c, EvUniqID__c, EvStatus__c, EvKostl__c
                                           FROM Employee__c 
                                          WHERE EvSapBukrs__c =: compCodeSet 
                                            AND EvUniqID__c =: fedIdSet 
                                            AND EvSapBukrs__c != null
                                          ORDER BY EvUniqID__c, EvSapBukrs__c];
            if(empList.size() > 0){
                for(Employee__c emp : empList){
                    epidToCCMap.put(emp.EvUniqID__c + '_' + emp.EvSapBukrs__c, emp.EvKostl__c);
                }
            }
            // [E] Get Employee Info

            // [S] Cost Center Map Setting
            Map<String, String> ccMap = new Map<String, String>();
            List<CostCenter__c> ccList = [SELECT Id, Name, CompanyCode__c, CostCenter__c FROM CostCenter__c WHERE CostCenter__c != null ORDER BY CostCenter__c ];
            if(ccList.size() > 0){
                for(CostCenter__c cc : ccList){
                    ccMap.put(cc.CostCenter__c, cc.Id);
                }
            }
            // [E] Cost Center Map Setting

            Map<String,Lead>          leadMap   = new Map<String,Lead>();
            Map<String,Sales_Lead__c> salesMap  = new Map<String,Sales_Lead__c>();
			
            for(IT_DATA data : dataList){
                String company = data.Company;
                if(data.Company == null || data.Company == '') company = 'No name';

                // Create Marketing Lead
                Lead lead                = new Lead();
                lead.FirstName           = data.FirstName;
                lead.LastName            = data.LastName;
                lead.Title               = data.Title;
                lead.Company             = company;
                if(data.Country != null) lead.Country__c = data.Country;
                lead.Phone               = data.BusinessPhone;
                lead.MobilePhone         = data.MobilePhone;
                lead.Email               = data.Emailaddress;
                lead.Status              = 'In Process';
                lead.LeadStage__c        = 'Cold'; 
                lead.Description         = data.Comment;
                lead.InterestSubject1__c = data.SFDCIndustry;
                lead.InterestSubject2__c = data.SolutionOfInterest;
                lead.ELOQUAID__c         = data.ELOQUA_ID;
                lead.Eloqua__c           = true;
                lead.LeadSource          = data.LeadSource;

                //Lead owner  : 김진수 프로님 변경 요청 ( 2021.05.17)
                if(userMap.containsKey(data.SFDCLeadowner)){
                    lead.SalesLeadOwnerCandidate__c = userMap.get(data.SFDCLeadowner);
                    lead.OwnerId = userMap.get(data.SFDCLeadowner);
                }else{
                    lead.SalesLeadOwnerCandidate__c = userMap.get(MYSALES_EMAIL);
                    lead.OwnerId = userMap.get(MYSALES_EMAIL);
                }
                
                if(data.LeadCreatedDate != null && data.LeadCreatedDate != ''){
                    lead.EloquaLeadCreationDate__c = Util_String.convertTimeZone(convertStringToDateTime(data.LeadCreatedDate),'GMT').addHours(13);
                } 
                if(data.HQEmailOptInDate != null && data.HQEmailOptInDate != ''){
                    lead.EloquaOptInDate__c = Util_String.convertTimeZone(convertStringToDateTime(data.HQEmailOptInDate),'GMT');
                }
                if(data.HQEmailOptExpiredDate != null && data.HQEmailOptExpiredDate != '') {
                    lead.PersonalInfoAgreementExpireDate__c = Util_String.convertTimeZone(convertStringToDateTime(data.HQEmailOptExpiredDate),'GMT');
                    lead.PersonalInfoAgreement__c = true;
                }

                // if(epidMap.get(lead.OwnerId) != null){
                //     String ccKey = epidMap.get(lead.OwnerId);
                //     if(epidToCCMap.get(ccKey) != null){
                //         String ccCode = epidToCCMap.get(ccKey);
                //         if(ccMap.get(ccCode) != null){
                //             lead.SalesDepartment__c = ccMap.get(ccCode);
                //         }
                //     }
                // }

                //LastName은 필수값. Null로 들어온 데이터는 패싱 처리함. upsert 하지않음.
                if(lead.ELOQUAID__c != null && lead.LastName != null) leadMap.put(lead.ELOQUAID__c, lead);
                else {
                    errChk = true;
					errLeadCnt++;
                }
            }
            List<Lead> leadList = leadMap.values();
            //2022-08-09, hyunhak.roh@dkbmc.com, (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
            //upsert leadList ELOQUAID__c;
            List<Lead> chkLeadList = new List<Lead>();
            List<Database.UpsertResult> chkSaveList = new List<Database.UpsertResult>();
            if(leadList.size() > 0){
                Schema.SObjectField keys = Lead.Fields.ELOQUAID__c;
                chkSaveList = Database.upsert(leadList, keys, false);
            }
        
        	for(Integer i = 0; i < chkSaveList.size(); i ++){
                Database.UpsertResult chkSv = chkSaveList.get(i);
                
                if(chkSv.isSuccess()){
                    Lead chkLead = leadList.get(i);
                    chkLeadList.add(chkLead);
                    System.debug('### IF_EloquaLeaderInfoController, chkSv : '+ chkSv);
                    cptLeadCnt++;
                }
                else{
                    errChk = true;
                    errLeadCnt++;                    
                }
            }
            System.debug('### IF_EloquaLeaderInfoController, leadList size : '+ leadList.size());
        	System.debug('### IF_EloquaLeaderInfoController, chkLeadList size : '+ chkLeadList.size());

            Map<Id, Lead> leadNmMap = new Map<Id, Lead>([SELECT Id, Name, ELOQUAID__c FROM Lead WHERE ELOQUAID__c IN :leadMap.keySet()]);
			
            Map<String, CampaignMember> campMemMap = new Map<String, CampaignMember>();
            Map<String, Lead>           leadObjMap = new Map<String, Lead>();
            //for(Lead obj : leadList){
            for(Lead obj : chkLeadList){
                IT_DATA itData = itDataMap.get( obj.ELOQUAID__c);
                if(itData != null) {
                    String campId  = itData.CampaignId;
                    if(Util_String.nvlStr(campId) != '') {
                        String strKey = obj.Id + '_' + itData.ELOQUA_ID;
                        System.debug('### IF_EloquaLeaderInfoController, strKey : '+ strKey);
                        CampaignMember camMember = new CampaignMember(
                            LeadID       = obj.Id,
                            CampaignId   = campId,
                            Status       = 'Sent'
                        );
                        campMemMap.put(strKey, camMember);
                        leadObjMap.put(strKey, obj);
                    }
                }
            }
            //update leadList;	//불필요한 로직. 삭제처리.
			System.debug('### IF_EloquaLeaderInfoController, campMemMap : '+ campMemMap);
            System.debug('### IF_EloquaLeaderInfoController, leadObjMap : '+ leadObjMap);
            /* 불필요한 로직??
            List<CampaignMember> campMList = [SELECT Id, ExternalFilterKey__c
                                                FROM CampaignMember
                                               WHERE LeadID IN :leadNmMap.KeySet()
                                                 AND ExternalFilterKey__c IN :leadObjMap.KeySet()];
            for(CampaignMember camMb : campMList){
                CampaignMember camMember = campMemMap.get(camMb.ExternalFilterKey__c);
                if( camMember != null) camMember.Id = camMb.Id;
            }
			*/

            // 오류가 있는 경우 로그 기록
            List<CampaignMember>      camMList = campMemMap.values();
            System.debug('### IF_EloquaLeaderInfoController, camMList : '+ camMList);
            List<Database.UpsertResult> svList = DataBase.upsert(camMList, false);
            rowCnt   						   = svList.size();
            //errChk   						   = false;
            for(Integer i = 0; i < rowCnt; i ++){
                Database.UpsertResult sv = svList.get( i);
                if(!sv.isSuccess()){
                    CampaignMember camMember = camMList.get( i);
                    String eloquaId =  leadNmMap.get(camMember.LeadID).ELOQUAID__c;
                    String strKey   = camMember.LeadID + '_' + eloquaId;
                    Lead leadData   = leadObjMap.get(strKey);
                    for(Database.Error err : sv.errors){
                        //2022-08-09, hyunhak.roh@dkbmc.com, (Eloqua data 수신) 에러시 성공실패 건 별로 처리 로직 추가
                        //log.addLog( 'ELOQUA ID : ' + leadData.ELOQUAID__c + '    ' + err.getFields() + ' => ' + err.getMessage());
                        errChk = true;
                        errCamMCnt++;
                        
                        System.debug('### IF_EloquaLeaderInfoController, camMember, err.getFields() : '		+ err.getFields());
                        System.debug('### IF_EloquaLeaderInfoController, camMember, err.getMessage() : '	+ err.getMessage());
                    }
                }
                else {
                    cptCamMCnt++;
                }
            }
			
            outHeader.EV_RESULT      = errChk ? IF_Util.RESULT_STATUS_FAILED 	: IF_Util.RESULT_STATUS_SUCCESS;
            outHeader.EV_MESG        = errChk ? IF_Util.RESULT_MESSAGE_PARTED	: IF_Util.RESULT_MESSAGE_SUCCESS;
            outHeader.TOTAL_COUNT    = leadList.size();
			    
            // 로그 객체 생성
            if(errChk){
            	errPreStr = '전체 ' + totalCnt + '건 중에 Lead 정상 ' + cptLeadCnt + '건, 오류 ' + errLeadCnt + '건, '
                							 + 'CampaignMember 정상 ' + cptCamMCnt + '건, 오류 ' + errCamMCnt + ' 입니다.';
                
                List<String> errList = new List<String>();
                errList.add(errPreStr);
                
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader), errList);
            }
            else {
                infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader));
            }
        }catch( Exception e){
            DataBase.rollback(sp);
            outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_FAILED;
            outHeader.EV_MESG        = e.getMessage();
            
            infLog = new IF_Log.InterfaceLog( INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, reqBody.toString(), JSON.serialize(outHeader),e);
        }

        System.debug('### IF_EloquaLeaderInfoController, Lead, totalCnt : '		+ totalCnt);
        System.debug('### IF_EloquaLeaderInfoController, CampaignMember rowCnt : '	+ rowCnt);
        System.debug('### IF_EloquaLeaderInfoController, CampaignMember errChk : '	+ errChk);
        System.debug('### IF_EloquaLeaderInfoController, CampaignMember errLeadCnt : '	+ errLeadCnt);
        System.debug('### IF_EloquaLeaderInfoController, CampaignMember errCamMCnt : '	+ errCamMCnt);
        System.debug('### IF_EloquaLeaderInfoController, CampaignMember errPreStr : '	+ errPreStr);
        
        log.createLog( infLog );
        setSchedule();
        return outHeader;
    }

    public static Datetime convertStringToDateTime(String data){
        String year = data.mid(0, 4);
        String Month = data.mid(4, 2);
        String day = data.mid(6, 2);
        String hour = data.mid(8, 2);
        String min = data.mid(10, 2);
        String sec = data.mid(12, 2);
        
        return Datetime.newInstance(Integer.valueOf(year), Integer.valueOf(Month), Integer.valueOf(day), Integer.valueOf(hour), Integer.valueOf(min), Integer.valueOf(sec));
    }

    // Callout 처리
    @Future( Callout=true)
    global static void callInfo( String fromDate, String toDate){
        // 로그 변수
        String      guId = IF_Util.generateGuid();
        IF_Callout  call = new IF_Callout( INTERFACE_ID);
        IF_Log      log  = new IF_Log();
        IF_Log.InterfaceLog ifLog;

        Map<String,String> reqMap = new Map<String,String>();
        reqMap.put('IV_SEARCH_FROM' , fromDate);
        reqMap.put('IV_SEARCH_TO' , toDate);

        if(isSandbox){ // 개발서버인 경우
            reqMap.put('ELOQUA_UPDATE_YN' , 'N'); // Eloqua에 상태값 업데이트 안함
            // reqMap.put('SFDC_IF_YN' , 'Y'); // 이미 SFDC로 전송된 데이터도 조회
            reqMap.put('SFDC_IF_YN' , 'N'); // SFDC에 전송되지 않은 데이터만 조회
        }else{ // 운영서버인 경우
            reqMap.put('ELOQUA_UPDATE_YN' , 'Y'); // Eloqua에 상태값 업데이트 함
            reqMap.put('SFDC_IF_YN' , 'N'); // SFDC에 전송되지 않은 데이터만 조회
        }
        String jsonBody = JSON.serialize(reqMap);

        try{
            // callout
            Map<String, Object> rtnMap = call.httpCallout(jsonBody, '');
            String statusCode = rtnMap.get( 'StatusCode') + '';
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, 'callInfo', jsonBody, statusCode);
        }catch( Exception e){
            ifLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, 'callInfo', jsonBody, 'Async',e);
        }
        log.createLog( ifLog);
        setSchedule();
    }

    public static void setSchedule(){
        //Schedule
        List<CronTrigger> schJobList = [SELECT Id,  CronJobDetail.Name FROM CronTrigger WHERE CronJobDetail.Name = 'IF_EloquaLeaderInfoController'];
        for(CronTrigger obj : schJobList){
            System.abortJob(obj.id);
        }
        
        if(!isSandbox){ // 운영서버인 경우
            Integer iMin = Datetime.now().minute()+30;
            if(iMin >= 60) iMin -=60;
            String min = String.valueOf(iMin);
            System.schedule('IF_EloquaLeaderInfoController', '0 '+min+' * * * ? *' , new IF_EloquaLeaderInfoController() );
        }
    }

    global void execute( SchedulableContext SC){
        // 2021-06-01 / Eloqua는 UTC-4로 Data를 저장하고 있음, MySales에서는 UTC+9를 사용하기 때문에 Eloqua 기준으로 Data를 가져오기 위해 -13시간 계산 추가
        DateTime fromDate = DateTime.now().addDays(-1).addHours(-13);
        DateTime toDate = DateTime.now().addHours(-13);
        callInfo(String.valueOf(fromDate), String.valueOf(toDate));
    }

    // 전달 값: JitterBit
    global class OutputHeader{
        @AuraEnabled
        public Integer TOTAL_COUNT = 0; // 전체 데이터 건수
        @AuraEnabled
        public String EV_RESULT = ''; // 처리 결과
        @AuraEnabled
        public String EV_MESG = ''; // 처리 메세지
        @AuraEnabled
        public List<OutputClass> DATA; // 데이터 포멧
    }

    public class OutputClass{ }

    global class InputHeader{
        public String IV_COUNT;
        public List<IT_DATA> IT_DATA;
    }

    global class IT_DATA{
        public String FirstName;
        public String LastName;
        public String Title;
        public String Company;
        public String Country;
        public String BusinessPhone;
        public String MobilePhone;
        public String Emailaddress;
        public String Comment;
        public String SFDCIndustry;
        public String SolutionOfInterest;
        public String SFDCLeadowner; //마케팅리드 오너
        public String SFDCSalesLeadowner; //사업리드 오너
        public String LeadCreatedDate; //EloquaLeadCreationDate__c
        public String HQEmailOptInDate; //EloquaOptInDate__c
        public String HQEmailOptExpiredDate;
        public String ELOQUA_ID;
        public String LeadSource;
        public String CampaignId;
    }
}