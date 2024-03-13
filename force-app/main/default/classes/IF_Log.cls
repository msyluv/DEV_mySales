/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2023-08-08
 * @last modified by  : aditya.r2@samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-19   ghkil@partner.samsung.com   Initial Version
 * 1.1   2020-11-03   soohong0.kim@partner.samsung.com IF Log ContentVersion 추가
 * 1.2	 2023-08-08   aditya.r2@samsung.com		   InterfaceLog with different Parameters
**/
global class IF_Log {
	public Datetime StartDatetime;
	public String LogText;
	public Boolean IsLogFull;
	public String CreateMode;

	public IF_Log() {
		CreateMode = 'All';

		defaultConstructor();
	}

	public IF_Log(String createModeMdt) {
		CreateMode = createModeMdt;

		defaultConstructor();
	}

	private void defaultConstructor() {
		//경과시간 관리를 위해 생성자 호출 시 Start Datetime을 기록
		StartDatetime = System.now();

		LogText = '';
		isLogFull = false;
	}

	public void setCreateMode(String createModeMdt) {
		CreateMode = createModeMdt;
	}

	public void addLog(Object text) {
		String inputText = String.valueOf(text);

		if (!IsLogFull) {
			Integer totalTextSize = LogText.length() + inputText.length();

			if (totalTextSize <= 130000) {
				LogText += inputText + '\n';
			} else {
				LogText += '로그 길이 제한을 초과하여 입력을 중단합니다.';
				isLogFull = true;
			}
		}
	}

	public virtual class Log {
		//공통 변수
		//LogType : Batch, Interface 등의 Log 발생원인 유형
		public String LogType;
		public String ApexName;
		public String ApexMethod;
        public String StatusCode;
		public String RequestMsg;
		public String ResponseMsg;
		public String RecordTypeId;

		//오류 관련 변수
		public String ExceptionType;
		public String ErrorMessage;
		public String StackTrace;

		//배치결과 관련 변수
		public Integer SuccessCount;
		public Integer FailCount;
		public Integer TotalCount;

		//I/F 관련 변수
		public String InterfaceId;
		public String InterfaceGuid;
	}

    //Interface 관련 Log Wrapper
	public class InterfaceLog extends Log {
        //성공 시 호출 생성자
		public InterfaceLog(String ifId, String guid, String apex, String method, String reqMsg, String resMsg) {
            setInterfaceDefault(ifId, guid, apex, method, reqMsg, resMsg);

            this.StatusCode = 'S';
		}
        
        //v1.2 MySales-273
        public InterfaceLog(String ifId, String guid, String apex, String method, String reqMsg, String resMsg, String ifStatus) {
            setInterfaceDefault(ifId, guid, apex, method, reqMsg, resMsg);

            this.StatusCode = 'W';
		}

        //실패 시 호출 생성자 (오류 메시지 추가)
		public InterfaceLog(String ifId, String guid, String apex, String method, String reqMsg, String resMsg, List<String> errList) {
            setInterfaceDefault(ifId, guid, apex, method, reqMsg, resMsg);

            this.StatusCode = 'F';

			String errMsg;
			if (errList.size() > 0) {
				errMsg = '';
				for (String err : errList) {
					errMsg += err + '\n';
				}
				errMsg = errMsg.substring(0, errMsg.length()-1);
			}
			this.ErrorMessage = errMsg;
		}

        //오류 시 호출 생성자 (Exception 추가)
		public InterfaceLog(String ifId, String guid, String apex, String method, String reqMsg, String resMsg, Exception e) {
            setInterfaceDefault(ifId, guid, apex, method, reqMsg, resMsg);

            this.StatusCode = 'E';

			this.ExceptionType = e.getTypeName();
            this.ErrorMessage = e.getMessage();
			this.StackTrace = e.getStackTraceString();
		}

        //Interface Log 공통 기본값
        private void setInterfaceDefault(String ifId, String guid, String apex, String method, String reqMsg, String resMsg) {
			this.LogType = 'Interface';
//			this.RecordTypeId = InterfaceCommonUtil.getRecordTypeId('IF_Log__c', 'Interface');
			this.InterfaceId = ifId;
			this.InterfaceGuid = guid;
			this.ApexName = apex;
			this.ApexMethod = method;
			this.RequestMsg = reqMsg;
			this.ResponseMsg = resMsg;
        }
	}

    //Batch 관련 Log Wrapper
	public class BatchLog extends Log {
        //성공 시 호출 생성자 (성공 건수)
		public BatchLog(String batchId, String guid, String apex, String reqMsg, Integer sCount) {
            setBatchDefault(batchId, guid, apex, reqMsg);

            this.StatusCode = 'S';

			this.SuccessCount = sCount;
			this.TotalCount = sCount;
		}

        //실패 시 호출 생성자 (성공 건수, 실패 건수, 오류 메시지)
		public BatchLog(String batchId, String guid, String apex, String reqMsg, Integer sCount, Integer fCount, List<String> errList) {
            setBatchDefault(batchId, guid, apex, reqMsg);
			
            this.StatusCode = 'F';

			this.SuccessCount = sCount;
			this.FailCount = fCount;
			this.TotalCount = sCount + fCount;

			String errMsg;
			if (errList != null && errList.size() > 0) {
				errMsg = '';
				for (String err : errList) {
					errMsg += err + '\n';
				}
				errMsg = errMsg.substring(0, errMsg.length()-1);
			}
			this.ErrorMessage = errMsg;
		}

        //오류 시 호출 생성자 (성공 건수, 실패 건수, Exception)
		public BatchLog(String batchId, String guid, String apex, String reqMsg, Integer sCount, Integer fCount, Exception e) {
            setBatchDefault(batchId, guid, apex, reqMsg);

            this.StatusCode = 'E';

			this.SuccessCount = sCount;
			this.FailCount = fCount;
			this.TotalCount = sCount + fCount;

			this.ExceptionType = e.getTypeName();
            this.ErrorMessage = e.getMessage();
			this.StackTrace = e.getStackTraceString();
		}

        //Batch Log 공통 기본값
        private void setBatchDefault(String batchId, String guid, String apex, String reqMsg) {
			this.LogType = 'Batch';
//			this.RecordTypeId = InterfaceCommonUtil.getRecordTypeId('IF_Log__c', 'Batch');
			this.InterfaceId = batchId;
			this.InterfaceGuid = guid;
			this.ApexName = apex;
			this.RequestMsg = reqMsg;
        }


		//////////////////////////// 2021-02-25: apexMethod 함수 추가 //////////////////////////////

        //성공 시 호출 생성자 (성공 건수)
		public BatchLog(String batchId, String guid, String apex, String apexMethod, String reqMsg, Integer sCount) {
            setBatchDefault(batchId, guid, apex, apexMethod, reqMsg);

            this.StatusCode = 'S';

			this.SuccessCount = sCount;
			this.TotalCount = sCount;
		}

        //실패 시 호출 생성자 (성공 건수, 실패 건수, 오류 메시지)
		public BatchLog(String batchId, String guid, String apex, String apexMethod, String reqMsg, Integer sCount, Integer fCount, List<String> errList) {
            setBatchDefault(batchId, guid, apex, apexMethod, reqMsg);
			this.StatusCode = 'S';
            if(fCount >0)this.StatusCode = 'F';
			this.SuccessCount = sCount;
			this.FailCount = fCount;
			this.TotalCount = sCount + fCount;

			String errMsg;
			if (errList != null && errList.size() > 0) {
				errMsg = '';
				for (String err : errList) {
					errMsg += err + '\n';
				}
				errMsg = errMsg.substring(0, errMsg.length()-1);
			}
			this.ErrorMessage = errMsg;
		}

        //오류 시 호출 생성자 (성공 건수, 실패 건수, Exception)
		public BatchLog(String batchId, String guid, String apex, String apexMethod, String reqMsg, Integer sCount, Integer fCount, Exception e) {
            setBatchDefault(batchId, guid, apex, apexMethod, reqMsg);

            this.StatusCode 	= 'E';
			this.SuccessCount 	= sCount;
			this.FailCount 		= fCount;
			this.TotalCount 	= sCount + fCount;

			this.ExceptionType 	= e.getTypeName();
            this.ErrorMessage 	= e.getMessage();
			this.StackTrace 	= e.getStackTraceString();
		}

        //Batch Log 공통 기본값
        private void setBatchDefault(String batchId, String guid, String apex, String apexMethod, String reqMsg) {
			this.LogType = 'Batch';
//			this.RecordTypeId = InterfaceCommonUtil.getRecordTypeId('IF_Log__c', 'Batch');
			this.InterfaceId   = batchId;
			this.InterfaceGuid = guid;
			this.ApexName 	   = apex;
			this.ApexMethod    = apexMethod;
			this.RequestMsg    = reqMsg;
        }		
	}

	public void createLog( List<Log> logList){

		try {
			List<IF_Log__c> ifLogList =  new List<IF_Log__c>();

			for( Log log : logList){
				if (CreateMode == 'All' || (CreateMode == 'FailOnly' && log.StatusCode != 'S')) {
					if (Limits.getDMLRows() < Limits.getLimitDMLRows() && Limits.getDMLStatements() < Limits.getLimitDMLStatements() ) {
						ifLogList.add( makeLog( log));
						
						// //insert ifLog;
						// List<Database.SaveResult> rslt = Database.insert(ifLog, false);
						// system.debug('Log Database.SaveResult : ' + rslt);

						/*
						if(ifLog.RequestMessage__c != null && ifLog.RequestMessage__c != ''){
							ContentVersion cv = new ContentVersion();
							cv.Title = 'request.txt';
							cv.PathOnClient = 'request.txt';
							cv.VersionData = Blob.valueOf(iflog.RequestMessage__c);
							cv.origin = 'H';
							//insert cv;
							rslt = Database.insert(cv, false);
							if(rslt.isSuccess()){
								
								ContentDocumentLink cl = new ContentDocumentLink();
								cl.LinkedEntityId = ifLog.id;
								cl.contentDocumentid = [select contentDocumentid from contentversion where id =: cv.id].contentDocumentid;
								cl.ShareType = 'V';
								Database.SaveResult rslt2 = Database.insert(cl, false);
							}
							system.debug('result : '+rslt.errors);
							if( ifLog.ResponseMessage__c != null && ifLog.ResponseMessage__c != ''){
								cv = new ContentVersion();
								cv.Title = 'response.txt';
								cv.PathOnClient = 'response.txt';
								cv.VersionData = Blob.valueOf(iflog.ResponseMessage__c);
								cv.origin = 'H';

								rslt = Database.insert(cv, false);
								if(rslt.isSuccess()){
									ContentDocumentLink cl = new ContentDocumentLink();
									cl.LinkedEntityId = ifLog.id;
									cl.contentDocumentid = [select contentDocumentid from contentversion where id =: cv.id].contentDocumentid;
									cl.ShareType = 'V';
									Database.SaveResult rslt2 = Database.insert(cl, false); 
								}
								system.debug('result : '+rslt.errors);
							}
						}*/
						
						

					} else {
						System.debug('DML 제한 초과로 로그 생성 불가능');
					}
				}
			}

			List<Database.SaveResult> rslt = Database.insert( ifLogList, false);
			system.debug('Log Database.SaveResult : ' + rslt);

		} catch (Exception e) {
			System.debug('로그 생성 실패');
			System.debug(e.getStackTraceString() + ' / ' + e.getMessage());
		}		
	}

    //Log 생성
	public void createLog(Log log) {
		try {            
			if (CreateMode == 'All' || (CreateMode == 'FailOnly' && log.StatusCode != 'S')) {
				if (Limits.getDMLRows() < Limits.getLimitDMLRows() && Limits.getDMLStatements() < Limits.getLimitDMLStatements()) {
					IF_Log__c ifLog = makeLog( log);
					
					//insert ifLog;
					
					Database.SaveResult rslt = Database.insert(ifLog, false);
					system.debug('Log Database.SaveResult : ' + rslt);

					/*
					if(ifLog.RequestMessage__c != null && ifLog.RequestMessage__c != ''){
						ContentVersion cv = new ContentVersion();
						cv.Title = 'request.txt';
						cv.PathOnClient = 'request.txt';
						cv.VersionData = Blob.valueOf(iflog.RequestMessage__c);
						cv.origin = 'H';
						//insert cv;
						rslt = Database.insert(cv, false);
						if(rslt.isSuccess()){
							
							ContentDocumentLink cl = new ContentDocumentLink();
							cl.LinkedEntityId = ifLog.id;
							cl.contentDocumentid = [select contentDocumentid from contentversion where id =: cv.id].contentDocumentid;
							cl.ShareType = 'V';
							Database.SaveResult rslt2 = Database.insert(cl, false);
						}
						system.debug('result : '+rslt.errors);
						if( ifLog.ResponseMessage__c != null && ifLog.ResponseMessage__c != ''){
							cv = new ContentVersion();
							cv.Title = 'response.txt';
							cv.PathOnClient = 'response.txt';
							cv.VersionData = Blob.valueOf(iflog.ResponseMessage__c);
							cv.origin = 'H';

							rslt = Database.insert(cv, false);
							if(rslt.isSuccess()){
								ContentDocumentLink cl = new ContentDocumentLink();
								cl.LinkedEntityId = ifLog.id;
								cl.contentDocumentid = [select contentDocumentid from contentversion where id =: cv.id].contentDocumentid;
								cl.ShareType = 'V';
								Database.SaveResult rslt2 = Database.insert(cl, false); 
							}
							system.debug('result : '+rslt.errors);
						}
					}*/
					
					

				} else {
					System.debug('DML 제한 초과로 로그 생성 불가능');
				}
			}
		} catch (Exception e) {
			System.debug('로그 생성 실패');
			System.debug(e.getStackTraceString() + ' / ' + e.getMessage());
		}
	}

	//Log 생성. 생성된 LogId 반환
	public Id createLog2(Log log) {
		Id logId;
		try {            
			if (CreateMode == 'All' || (CreateMode == 'FailOnly' && log.StatusCode != 'S')) {
				if (Limits.getDMLRows() < Limits.getLimitDMLRows() && Limits.getDMLStatements() < Limits.getLimitDMLStatements()) {
					IF_Log__c ifLog = makeLog( log);
					Database.SaveResult rslt = Database.insert(ifLog, false);
					if(rslt.isSuccess()) logId = rslt.getId();
					system.debug('Log Database.SaveResult : ' + rslt);
				} else {
					System.debug('DML 제한 초과로 로그 생성 불가능');
				}
			}
		} catch (Exception e) {
			System.debug('로그 생성 실패');
			System.debug(e.getStackTraceString() + ' / ' + e.getMessage());
		}

		return logId;
	}

    //DML 없이 Log Object만 반환
	public IF_Log__c makeLog( Log log) {


		IF_Log__c ifLog = new IF_Log__c();
		
		ifLog.LogType__c 	= log.LogType;
//		ifLog.RecordTypeId = log.RecordTypeId;
		ifLog.StatusCode__c = log.StatusCode;
		ifLog.ApexName__c 	= log.ApexName;
		ifLog.ApexMethod__c = log.ApexMethod;


		if (log.RequestMsg == null) {
			ifLog.RequestMessage__c = null;
		} else {
			ifLog.RequestMessage__c = (log.RequestMsg).length() > 130000 ? (log.RequestMsg).substring(0, 130000) : log.RequestMsg;
		}

		if (log.ResponseMsg == null) {
			ifLog.ResponseMessage__c = null;
		} else {
			ifLog.ResponseMessage__c = (log.ResponseMsg).length() > 130000 ? (log.ResponseMsg).substring(0, 130000) : log.ResponseMsg;
			if((log.ResponseMsg).length() > 130000 && (log.ResponseMsg).length() < 260000 ) ifLog.ResponseMessage2__c = (log.ResponseMsg).substring(130001, (log.ResponseMsg).length());
			if((log.ResponseMsg).length() > 260000 && (log.ResponseMsg).length() < 390000 ){
				ifLog.ResponseMessage2__c = (log.ResponseMsg).substring(130001, 260000);
				ifLog.ResponseMessage3__c = (log.ResponseMsg).substring(260001, (log.ResponseMsg).length());
			} 
		}

		ifLog.ExceptionType__c 	= log.ExceptionType;
		ifLog.ErrorMessage__c 	= log.ErrorMessage;
		ifLog.StackTrace__c 	= log.StackTrace;
		ifLog.SuccessCount__c 	= log.SuccessCount;
		ifLog.FailCount__c 		= log.FailCount;
		ifLog.TotalCount__c 	= log.TotalCount;
		ifLog.InterfaceId__c 	= log.InterfaceId;		
		ifLog.InterfaceGuid__c 	= log.InterfaceGuid;
		ifLog.StartDatetime__c 	= StartDatetime;
		ifLog.LogText__c 		= LogText.length() > 30000 ? LogText.substring(0, 30000) : LogText;
		ifLog.EndDatetime__c 	= System.now();
		ifLog.CPUTime__c 		= Limits.getCpuTime();
		return ifLog;
	}
}