/**
	 * @description       : 
	 * @author            : kilhwan.an@partner.samsung.com
	 * @group             : 
	 * @last modified on  : 2023-12-05
	 * @last modified by  : atul.k1@samsung.com
	 * Modifications Log 
	 * Ver   Date         Author                           Modification
	 * 1.0   2020-11-04   kilhwan.an@partner.samsung.com   Initial Version (사업기회정보 조회권한체크)
	 * 1.1   2021-02-05   ghkil@partner.samsung.com        2.5일 정의서 기준으로 IF 변경
	 * 1.2   2021-02-08   ghkil@partner.samsung.com        2.8일 정의서 기준으로 IF 항목 추가
	 * 1.2   2021-03-02   kilhwan.an@partner.samsung.com   IV_BURKS 필드 수정
	 * 1.3   2023-10-13   vikrant.ks@samsung.com  		   Change source of user's access information 
	 * 1.4   2023-12-05   atul.k1@samsung.com  		       IF-038 Modification related to billing authority (MYSALES-368)
	**/

	@RestResource(urlMapping= '/IF038/*')
	global class IF_EccBoInfoCheckController {
		
		private static final String INTERFACE_ID = 'IF-038';
		private static final String APEX_CLASS   = 'IF_EccBoInfoCheckController';
		private static final String METHOD_NAME  = 'getBoInfoCheck';

		private static final Boolean DEBUG_FLAG = true;    

		@HttpPost
		global static void getBoInfoCheck(){

			// 권한코드 (1:수정, 2:조회 , 3:권한없음)
			final String ACCESS_LEVEL_ALL       = '1';
			final String ACCESS_LEVEL_READ      = '2';
			final String ACCESS_LEVEL_NOTHING   = '3';

			String guId = IF_Util.generateGuid();
			
			OutputHeader outHeader   = new OutputHeader();
			outHeader.ET_BO           = new List<Output_EtBo>();
			outHeader.TOTAL_COUNT    = 0;
			outHeader.EV_RESULT      = 'S';
			outHeader.EV_MESG        = '';

			IF_Log ifLog;
			IF_Log.InterfaceLog interfaceLog;
			List<String> errorMsgList = new List<String>();        

			ifLog = new IF_Log();
			ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 시작' + ' ####################');        

			// RequestBody 데이터 확인
			RestContext.response.addHeader('Content-Type', 'application/json');
			RestRequest req = RestContext.request;
			Blob    reqBody = req.requestBody;

			if (reqBody == null) {
				RestContext.response.responseBody = Blob.valueOf( JSON.serialize(outHeader));
				return; 
			}
			if (DEBUG_FLAG) ifLog.addLog('데이터 수신');

			// 데이터 파싱
			String inputJsonData = reqBody.toString(); //.escapeJava();
			ifLog.addLog('HttpRequest : ' + inputJsonData);
			system.debug('HttpRequest : ' + inputJsonData);        
			InputHeader     inputHeader = (InputHeader) JSON.deserialize( inputJsonData, InputHeader.class);
			List<InputClass> dataList   = inputHeader.IT_BO;
			system.debug('dataList-->'+dataList);
			system.debug('dataListSize-->'+dataList.size());
			if (dataList == null || dataList.size() == 0){
				RestContext.response.responseBody = Blob.valueOf(JSON.serialize( outHeader));   
				return; 
			}
			if (DEBUG_FLAG) ifLog.addLog('데이터 파싱');

			// 1) 해당정보 반영       
			String sendData;
			//String returnRole = ACCESS_LEVEL_NOTHING;    // 기본값 권한없음

			try {
				// 검색조건값
				List<String> requestEmpNo1 = new List<String>();
				List<String> bOCode = new List<String>();
				List<String> compCode = new List<String>();
                //Looping over the data request received.
				 for(InputClass eachVal : dataList){
					InputClass inClass = eachVal;
					String requestEmpNo            = inClass.IV_EMPLOYEE_NO;    // SAP 사번
					String requestOpportunityCode  = inClass.IV_ORDERID;        // 사업기회 코드
					String requestCompanyCode      = inClass.IV_BUKS;          	// 회사코드
                    //Checking Employee no. not null and adding into List of string 
						if( requestEmpNo != null) {
							if(requestEmpNo.isNumeric()){
								requestEmpNo = Decimal.valueOf( requestEmpNo) + '';
								requestEmpNo1.add(requestEmpNo);
								bOCode.add(inClass.IV_ORDERID);
								compCode.add(inClass.IV_BUKS);
							}
						}
				}
				// User(Profile) 정보 조회
				// Fetching the user info from Employee number.
				List<User> userInfo = [
					SELECT  Id
							, Profile.Name
							, EmployeeNumber
					FROM    User 
					WHERE   isActive        = true 
					AND     EmployeeNumber  = :requestEmpNo1
				];
                //mapEmpNumberUser Map to store the info of user
				Map<string,user> mapEmpNumberUser = new Map<string,user>();
				Set<ID> UserIDSet = new Set<ID>();
                //Looping over the user record.
				for(User eachuser : userInfo){
				   mapEmpNumberUser.put(eachuser.EmployeeNumber , eachuser);
				   UserIDSet.add(eachuser.id);
				 }
                //boCodeOpp Map to store the info of Opportunity
				 Map<String,Opportunity> boCodeOpp = new Map<String,Opportunity>();
                 //Creating the 4 set to the BO id check the user access of multiple records
				 Set<Id> BoIDSet1 = new Set<ID>();
                 Set<Id> BoIDSet2 = new Set<ID>();
                 Set<Id> BoIDSet3 = new Set<ID>();
                 Set<Id> BoIDSet4 = new Set<ID>();
                 // Query to fetch the Opportunity record info on the bases of BO code and company code
				 List<Opportunity> opportunityList = [
						SELECT Id,OwnerId,Owner.EmployeeNumber, ProposalPM__c, ProposalPM__r.EvSapEmpNO__c, ProposalPM__r.EvEmpNO__c , OpportunityCode__c, CompanyCode__c, SalesDepartment__r.CostCenter__c            // 수주 사업그룹 코스트센터 코드 ((Primary) Sales Dept)
						, cPrimarySalesDepartment__r.CostCenter__c    // 주 매출 부서 코스트센터 코드 ((Primary) Delivery Dept)
						FROM   Opportunity
						WHERE  OpportunityCode__c  = :bOCode
						AND    CompanyCode__c      = :compCode
					];
                    // Looping over the BO records
					for(Opportunity opp : opportunityList){
						boCodeOpp.put(opp.OpportunityCode__c+'_'+opp.CompanyCode__c, opp);
                        if(BoIDSet1.size()<200){
                           BoIDSet1.add(opp.id); 
                        }
                        else if(BoIDSet1.size()==200 && BoIDSet2.size()<200 && (!BoIDSet1.contains(opp.id))){
                               BoIDSet2.add(opp.id);
                         }
                         else if(BoIDSet2.size()==200 && BoIDSet3.size()<200  && (!BoIDSet1.contains(opp.id))  && (!BoIDSet2.contains(opp.id))){
                               BoIDSet3.add(opp.id);
                         }
                         else if(BoIDSet3.size()==200 && BoIDSet4.size()<200 && (!BoIDSet1.contains(opp.id)) && (!BoIDSet2.contains(opp.id)) && (!BoIDSet3.contains(opp.id))){
                               BoIDSet4.add(opp.id);
                         }
						
					}
				    //oppIDOpportunityTeam Map to store the Opportunity Team Member data with Opportunity id as key 
					Map<String,OpportunityTeamMember> oppIDOpportunityTeam = new Map<String,OpportunityTeamMember>();
                    // Query over the Opportunity team to fetch the information
				    List<OpportunityTeamMember> oppTeamList = [
							SELECT  Id
									, User.EmployeeNumber
									, Opportunity.OpportunityCode__c
									, OpportunityID								
									, OpportunityAccessLevel
							FROM    OpportunityTeamMember
							WHERE   Opportunity.OpportunityCode__c  = : bOCode            
							AND     User.EmployeeNumber  = :requestEmpNo1 
                            AND     (TeamMemberRole = 'Billing Manager' OR TeamMemberRole = '청구 담당자')
		            ];
                    //Looping over the Opportunity Team Member
				    for(OpportunityTeamMember oppTeam : oppTeamList){
					oppIDOpportunityTeam.put(oppTeam.OpportunityID+'_'+oppTeam.User.EmployeeNumber ,oppTeam);
				}
				//mapUserid_BoidAccess to store the record access info with userid_RecordId as Key
				Map<String,UserRecordAccess> mapUserid_BoidAccess = new Map<String,UserRecordAccess>();
                //List to store the user access
                List<UserRecordAccess> UserRecordAccessfinalLst = new List<UserRecordAccess>();
                //Looping over the user id set
				For(id userID : UserIDSet){
                    // Checking which set of BO contains the record id accordingly which fetching the UserRecordAccess info for the user
                    if(BoIDSet1 != null){
                        List<UserRecordAccess> UserAccessList1 = [Select RecordId, HasEditAccess,  HasReadAccess from UserRecordAccess 
																         where UserId =: userID and RecordId IN: BoIDSet1];
                        UserRecordAccessfinalLst.addAll(UserAccessList1);
                    }
					
                    if(BoIDSet2 != null){
                        List<UserRecordAccess> UserAccessList2 = [Select RecordId, HasEditAccess,  HasReadAccess from UserRecordAccess 
																	     where UserId =: userID and RecordId IN: BoIDSet2];
                        UserRecordAccessfinalLst.addAll(UserAccessList2);
                    }
                    if(BoIDSet3 != null){
                        List<UserRecordAccess> UserAccessList3 = [Select RecordId, HasEditAccess,  HasReadAccess from UserRecordAccess 
																	     where UserId =: userID and RecordId IN: BoIDSet3];
                         UserRecordAccessfinalLst.addAll(UserAccessList3);
                    }
                    if(BoIDSet4 != null){
                        List<UserRecordAccess> UserAccessList4 = [Select RecordId, HasEditAccess,  HasReadAccess from UserRecordAccess 
																	     where UserId =: userID and RecordId IN: BoIDSet4];
                         UserRecordAccessfinalLst.addAll(UserAccessList4);
                    }
                    
                    For(UserRecordAccess userAcc : UserRecordAccessfinalLst){
						mapUserid_BoidAccess.put(userID+'_'+userAcc.RecordId,userAcc);
					}
				}
                List<Output_EtBo> etBoList= new List<Output_EtBo>();
                etBoList = new List<Output_EtBo>();
				//Looping over the data request received.
                for(InputClass eachVal : dataList){
					String returnRole = ACCESS_LEVEL_NOTHING;
					String returnRoleTeam = ACCESS_LEVEL_NOTHING;
					InputClass inClass = eachVal;
					String requestEmpNo            = inClass.IV_EMPLOYEE_NO;    // SAP 사번
					String requestOpportunityCode  = inClass.IV_ORDERID;        // 사업기회 코드
					String requestCompanyCode      = inClass.IV_BUKS;
                    
					if( requestEmpNo != null) {
						if(requestEmpNo.isNumeric()){
							requestEmpNo = Decimal.valueOf( requestEmpNo) + '';
						}
				    }
                    //Checking if mapEmpNumberUser contains the requestEmpNo
					if(mapEmpNumberUser.containsKey(requestEmpNo)){ 
						string UserID = mapEmpNumberUser.get(requestEmpNo).id;
                        //Checking if boCodeOpp contains the requestOpportunityCode_requestCompanyCode
                        //And BO company code equals to requestCompanyCode
						if(boCodeOpp.containsKey(requestOpportunityCode+'_'+requestCompanyCode) && 
                           boCodeOpp.get(requestOpportunityCode+'_'+requestCompanyCode).CompanyCode__c == requestCompanyCode){ 
							string BoID = boCodeOpp.get(requestOpportunityCode+'_'+requestCompanyCode).id;
							List<UserRecordAccess> accCheckVal = new List<UserRecordAccess>();
                            
							if(mapUserid_BoidAccess.containskey(UserID+'_'+BoID)){
								accCheckVal.add(mapUserid_BoidAccess.get(UserID+'_'+BoID));
							}
                            
							if(boCodeOpp.get(requestOpportunityCode+'_'+requestCompanyCode).Owner.EmployeeNumber == requestEmpNo ||
                               boCodeOpp.get(requestOpportunityCode+'_'+requestCompanyCode).ProposalPM__r.EvSapEmpNO__c == requestEmpNo){
								 returnRole = ACCESS_LEVEL_ALL;
							}else if(accCheckVal.size() > 0) {
								if (accCheckVal[0].HasEditAccess){
									returnRole = ACCESS_LEVEL_ALL;
								}else if (accCheckVal[0].HasReadAccess){
									returnRole = ACCESS_LEVEL_READ;
								}
							}
							//Checking oppIDOpportunityTeam Map contains the BOid_requestEmpNo
							if (oppIDOpportunityTeam.containsKey(BoID+'_'+requestEmpNo)){
								OpportunityTeamMember oppTeam = oppIDOpportunityTeam.get(BoID+'_'+requestEmpNo);
								if (oppTeam.OpportunityAccessLevel == 'Read'){
									returnRoleTeam = ACCESS_LEVEL_READ;
								}else if (oppTeam.OpportunityAccessLevel == 'All' || oppTeam.OpportunityAccessLevel == 'Edit'){
								returnRoleTeam = ACCESS_LEVEL_ALL;
								}
							} 
							list<Opportunity> oppIterationLst = new list<Opportunity>();
							oppIterationLst.add(boCodeOpp.get(requestOpportunityCode+'_'+requestCompanyCode));
						    // Looping over the BO to fill the respone.
							for (Opportunity opportunityData : oppIterationLst){
								Output_EtBo etBo = new Output_EtBo();
								etBo.EV_AUTH            = returnRole;
								etBo.BILLING_AUTH       = returnRoleTeam;
								etBo.ZZORDER_ID         = opportunityData.OpportunityCode__c;                       // 사업코드(프로젝트)
								etBo.ZZBUKRS_H          = opportunityData.CompanyCode__c;                           // Company Code
								etBo.ZZSALES_C_NAME_M   = opportunityData.SalesDepartment__r.CostCenter__c;         // (Primary) Sales Dept
								etBo.ZZDEV_C_NAME_M     = opportunityData.cPrimarySalesDepartment__r.CostCenter__c; // (Primary) Delivery Dept
								etBo.GUID               = opportunityData.Id;                                       // Opportunity ID                
								etBoList.add(etBo);
							}
						 }
                         // else if BO doesn't found
                         else{
                              Output_EtBo etBo = new Output_EtBo();
								etBo.EV_AUTH            = returnRole;
								etBo.BILLING_AUTH       = returnRoleTeam;
								etBo.ZZORDER_ID         = null; // 사업코드(프로젝트)
								etBo.ZZBUKRS_H          = null; // Company Code
								etBo.ZZSALES_C_NAME_M   = null; // (Primary) Sales Dept
								etBo.ZZDEV_C_NAME_M     = null; // (Primary) Delivery Dept
								etBo.GUID               = null; // Opportunity ID                
								etBoList.add(etBo);
                         }
					}
                    // else if User doesn't found
                    else{
                                Output_EtBo etBo = new Output_EtBo();
								etBo.EV_AUTH            = returnRole;
								etBo.BILLING_AUTH       = returnRoleTeam;
								etBo.ZZORDER_ID         = null;// 사업코드(프로젝트)
								etBo.ZZBUKRS_H          = null;// Company Code
								etBo.ZZSALES_C_NAME_M   = null;// (Primary) Sales Dept
								etBo.ZZDEV_C_NAME_M     = null;// (Primary) Delivery Dept
								etBo.GUID               = null;// Opportunity ID                
								etBoList.add(etBo);
                     }
				}
				outHeader.ET_BO = etBoList;
				// 성공 로그 데이터
				outHeader.TOTAL_COUNT    = etBoList.size();
				outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_SUCCESS;
				outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_SUCCESS;
				sendData                 = JSON.serialize(outHeader);
				ifLog.addLog('Response : ' + sendData);
				interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData);  
 				if (DEBUG_FLAG) ifLog.addLog('데이터 반영');            
			}catch (Exception e){

				// 에러 로그 데이터
				outHeader.TOTAL_COUNT    = 0;
				outHeader.EV_RESULT      = IF_Util.RESULT_STATUS_ERROR;
				outHeader.EV_MESG        = IF_Util.RESULT_MESSAGE_ERROR + ' |' + e.getMessage();
				sendData          = JSON.serialize(outHeader);
                
                ifLog.addLog('Response : ' + sendData);            
				ifLog.addLog('Exception : ' + e.getMessage());
				errorMsgList.add('Exception : ' + e.getMessage());
				
				interfaceLog = new IF_Log.InterfaceLog(INTERFACE_ID, guId, APEX_CLASS, METHOD_NAME, inputJsonData, sendData, e);   
			}
			ifLog.addLog('#################### ' + INTERFACE_ID + ' | ' + APEX_CLASS + ' | ' + METHOD_NAME + ' 종료' + ' ####################');
			ifLog.createLog(interfaceLog);
			RestContext.response.responseBody = Blob.valueOf( JSON.serialize( outHeader));   
			 // return sendData;
		}

		// 받은 값 : 검색 조건
		public class InputHeader{

			@AuraEnabled
			public List<InputClass> IT_BO;
		}
        
		public class InputClass{

			@AuraEnabled
			public String IV_EMPLOYEE_NO;       // SAP 사번
			@AuraEnabled
			public String IV_ORDERID;           // 사업기회 코드
			@AuraEnabled
			public String IV_BUKS;              // 회사코드
		}

		// 전달 값: JitterBit
		public class OutputHeader{

			@AuraEnabled
			public Integer TOTAL_COUNT;         // 전체 데이터 건수
			@AuraEnabled
			public String EV_RESULT;            // 처리 결과
			@AuraEnabled
			public String EV_MESG;              // 처리 메세지
            @AuraEnabled
			public List<Output_EtBo> ET_BO;        
		}
        
		public class Output_EtBo {
            
			@AuraEnabled
			public String EV_AUTH;
			 @AuraEnabled
			public String BILLING_AUTH;
			@AuraEnabled
			public String ZZORDER_ID;           // 사업코드(프로젝트)
			@AuraEnabled
			public String ZZBUKRS_H;            // Company Code
			@AuraEnabled
			public String ZZSALES_C_NAME_M;     // (Primary) Sales Dept
			@AuraEnabled
			public String ZZDEV_C_NAME_M;       // (Primary) Delivery Dept
			@AuraEnabled
			public String GUID;                 // Opportunity ID
		}
        
		public class Output_EtDept {
            
			@AuraEnabled
			public String KOSTL;                // Cost Center
			@AuraEnabled
			public String ZZTYPE;               // 부서타입
		}
	}