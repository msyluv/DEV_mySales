/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 07-12-2021
 * @last modified by  : ukhyeon.lee@samsung.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-28   ghkil@partner.samsung.com   Initial Version
 * 1.1	 2021-01-11   ghkil@partner.samsung.com   Solution정보 Interface 환율 계산 함수 (IF-093) 추가 (주석처리)
 * 1.2   2021-01-12   ghkil@partner.samsung.com   최종 DatedConversionRate 조회 수정 (NextStartDate가 9999-12-31인 데이터 기준)
**/
public class IF_Util {

	/** 
	 * 인터페이스 결과에 대한 상태값
	 * S : 성공
	 * F : Exception은 발생하지 않았으나, Logic/Data에 문제가 있을 때
	 * E : Exception 발생으로 시스템 롤백이 되었을 때
	**/
	public static final String RESULT_STATUS_SUCCESS = 'S';
	public static final String RESULT_STATUS_FAILED = 'F';
	public static final String RESULT_STATUS_ERROR = 'E';

	/** 
	 * 인터페이스(Restful API) 결과 메세지
	**/
	public static final String RESULT_MESSAGE_SUCCESS 	= 'The request has been processed successfully.'; // 요청이 성공적으로 처리 되었습니다.
	public static final String RESULT_MESSAGE_FAILED 	= 'The request was not proceed as a conditional issue.'; // 요청 조건 문제로 처리되지 않았습니다.
	public static final String RESULT_MESSAGE_PARTED	= 'The request was only partially registered as a conditional issue.'; // 요청 조건 문제로 처리되지 않았습니다.
	public static final String RESULT_MESSAGE_ERROR 	= 'An error occurred when processing the request.'; // 요청 처리 시 오류가 발생했습니다.

	/** 
	 * 인터페이스 로그 타입값
	**/
	public static final String LOG_TYPE_CALLOUT = 'CallOut';
	public static final String LOG_TYPE_BATCH = 'Batch';
	public static final String LOG_TYPE_RESTSERVICE = 'RestService';

	/** 
	 * 인터페이스(Restful API) Method값
	**/
	public static final String METHOD_GET = 'Get';
	public static final String METHOD_POST = 'Post';
	public static final String METHOD_PUT = 'Put';
	public static final String METHOD_DELETE = 'Delete';

	/** 
	 * Debug Flag값
	**/
	public static final Boolean DEBUG_FLAG = false;
	
    public static final Map<String, String> OPPORTUNITY_ACTIVITY = new Map<String, String>{
		'Register BO' => 'XP11', 								// 사업기회 등록
		'Review BO' => 'ZP21', 									// 사업기회 검토
		'Request Resources' => 'ZP32', 							// 사전영업 자원요청
		'Receive RFP' => 'XP31', 								// RFP 접수
		'Request Strategy Committee' => 'ZP31', 	
		'Strategy Committee Cost Plan Completion' => 'XP32', 	
		'Request Committee Approval' => 'ZP62', 				// 수전위 품의
		'Agency Contract Exception' => 'ZPZ3', 	
        'Strategy Committee 1' => 'XP61', 	
		'Submit Proposal' => 'ZP61', 							// 견적/제안 제출
		'Presentation' => 'XP41', 								// 제안 발표
		'Preferred Bidder' => 'XP42', 							// 우선협상 대상 선정
		'Customer Approval' => 'XP43', 							// 고객 내부 승인
		'Negotiation' => 'XP44', 								// 고객협상
		'Contract P&L' => 'XP51', 	
		'Legal Review' => 'XP52', 								// 법무 검토
		'Contract Approval' => 'ZP82', 							// 수주 품의
		'Closing' => 'XP57', 									// 계약서 입고
		'Abort Opportunity' => 'XPX1', 							// 사업 포기
		'Drop Opportunity' => 'ZPZ2', 							// 사업 중도 종결
		'Hold Opportunity' => 'ZAC1', 							// 사업 Hold
		'Lost Opportunity' => 'ZPZ1',							// 실주 보고
		'Unhold Opportunity' => 'ZAC4',							// 사업 Unhold
		'Change Approval Request' => 'ZPG1',
		//신규추가시작
		'Request Strategy Committee (biz participation)' => 'XP61',		//사업참여결정 수주전략위원회 요청
		'Committee (biz participation) Cost Planning' => 'XP62',		//사업참여결정 수주전략위원회 원가
		'Request Committee (biz participation) Approval' => 'XP63',		//사업참여결정 수주전략위원회 품의
		'Request Strategy Committee (bidding decision)' => 'XP71',		//입찰결정 수주전략위원회 요청
		'Committee (bidding decision) Cost Planning' => 'XP72',			//입찰결정 수주전략위원회 원가
		'Request Committee (bidding decision) Approval' => 'XP73'		//입찰결정 수주전략위원회 품의
		//신규추가종료
    };	

	// --------------------------------------------------------------- Data Type 변환 Method
	public static Datetime convertDatetime(Date dt) {
		Datetime dtTime;

		if (dt != null) {
			Time tm = Time.newInstance(9, 0, 0, 0);
			dtTime = Datetime.newInstance(dt, tm);
		}

		return dtTime;
	}

	public static Long convertDecimalToLong(Decimal decimalNumber) {
		Long longNumber;

		if (decimalNumber != null) {
			longNumber = decimalNumber.longValue();
		}

		return longNumber;
	}

	public static Date convertStringToDate(String yyyyMMdd) {
		Integer year = Integer.valueOf(yyyyMMdd.substring(0, 4));
		Integer month = Integer.valueOf(yyyyMMdd.substring(4, 6));
		Integer day = Integer.valueOf(yyyyMMdd.substring(6, 8));
		
		Date dt = Date.newInstance(year, month, day);

		return dt;
	}

	// --------------------------------------------------------------- RecordType 관련 Method
	public static String getRecordTypeId(String objName, String recordTypeName) {
		String rtId;

		if (objName != null && recordTypeName != null) {
			rtId = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
		}

		return rtId;
	}

	public static Map<String, String> getRecordTypeMap(String objName) {
		Map<String, String> rtMap = new Map<String, String>();

		if (objName != null) {
			for (Schema.RecordTypeInfo rtInfo : Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByName().values()) {
				rtMap.put(rtInfo.getName(), rtInfo.getRecordTypeId());
			}
		}

		return rtMap;
	}

	// --------------------------------------------------------------- User 관련 Method
    public static User getUserRecord() {
		String query = 'SELECT Id, UserName FROM User WHERE Id = \'' + Userinfo.getUserId() + '\' Limit 1';
        List<User> userList = Database.query(query);
 
        return userList[0];
    }

	// --------------------------------------------------------------- Interface 관련 Method
	/**
	 * I/F 시스템 사이에 항목을 식별하기 위한 고유값
	 * 임시로 만들었으나 되도록이면 고객사의 생성 규칙에 따르는 것을 권장
	**/
	public static String generateGuid() {
		Datetime now = Datetime.now();
		String strDate = now.format('YYYYMMdd', 'Asia/Seoul');
		String strTime = now.format('HHmmssSSS', 'Asia/Seoul');

		Integer randomNum = (Math.random() * 10000).intValue();
		String randomStr = String.valueOf(randomNum).leftPad(4, '0');

		return strDate + strTime + randomStr;
	}

	/**
	* @description 파라미터로 넘어온 Interface Id가 실제로 사용중인 Id인지 체크.
	* @param infId 
	* @return List<MT_Interface_Config__mdt> 
	**/
	public static List<IF_Config__mdt> getInterfaceMdt(String ifId){
		return [SELECT Id, 
					DeveloperName, 
					MasterLabel, 
					Language, 
					NamespacePrefix, 
					Label, 
					QualifiedApiName, 
					InterfaceId__c, 
					Endpoint__c, 
					CreateType__c, 
					ContentType__c 
					FROM IF_Config__mdt 
					WHERE  InterfaceId__c = :ifId];
	}

	/**
	* @description 목업 함수: rest service
	* @author kilhwan.an@partner.samsung.com | 2020-11-23 
	* @param ifId  		인터페이스 아이디
	* @param guId  		guid
	* @param apexClass  클래스명
	* @param methodName 함수명
	* @param res 		리턴값(  목업 리턴값)
	**/
	public static void makePayLoad( String ifId, String guId, String apexClass, String methodName, String res){

		IF_Log log = new IF_Log();
		IF_Log.InterfaceLog infLog;

		// RestResponse rep = RestContext.response;
		RestResponse rep = new RestResponse();

        try{
			// RestRequest req = RestContext.request;
			RestRequest req = new RestRequest();

			if (req == null) {
				String body =   '{' +
								'	"TOTAL_COUNT": 1000, ' +
								'	"PAGE_COUNT": 50, ' +
								'	"PAGE_NUM": 1, ' +
								'	"DATA": [ { ' +
								'		"BUKRS": "T100", ' +
								'		"PSPID": "SIC-20055891-A0", ' +
								'		"DELETE_FLAG":"X" ' +
								'		}     ' +
								'	] ' +
								'}';

				req.requestBody = Blob.valueOf(body);
			}

			Blob    reqBody = req.requestBody;

			infLog = new IF_Log.InterfaceLog( ifId, guId, apexClass, methodName, res, reqBody.toString());

        }catch( Exception e){
			infLog = new IF_Log.InterfaceLog( ifId, guId, apexClass, methodName, res, e.getStackTraceString());
		}
		log.createLog( infLog);

		rep.responseBody = Blob.valueOf( res);
	}
		
	public static List<IF_Util.SelectOptions> getPicklist (String objName, String apiName){
		List<IF_Util.SelectOptions> opt = new List<IF_Util.SelectOptions>();
		Schema.PicklistEntry[] pes = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(apiName).getDescribe().getPicklistValues();
		for (Schema.PicklistEntry p : pes) {
			opt.add(new IF_Util.SelectOptions(p.getLabel(), p.getValue()));
		}
		return opt;
	}

	public class SelectOptions{
        public String label;
        public String value;
    
        public SelectOptions(String lb, String vl){
            this.label = lb;
            this.value = vl;

        }
	}

	// // 건별 DatedConversionRate (삭제 예정)
	// private static DatedConversionRate getRecentlyDatedConversionRate(String isoCode) {
	// 	Map<String, DatedConversionRate> conversionRateMap = new Map<String, DatedConversionRate>();

	// 	List<DatedConversionRate> rate = [
	// 		Select  Id, 
	// 				IsoCode,
	// 				StartDate,
	// 				NextStartDate, 
	// 				ConversionRate
	// 		From    DatedConversionRate 
	// 		Where   IsoCode = :isoCode
	// 		Order by NextStartDate Desc Limit 1
	// 	];

	// 	DatedConversionRate result = null;

	// 	if (rate.size() > 0) {
	// 		conversionRateMap.put(rate[0].IsoCode, rate[0]);

	// 		result = conversionRateMap.get(isoCode);
	// 	}

	// 	return result;
	// }

	// 최종 DatedConversionRate 조회 (NextStartDate가 9999-12-31인 데이터 기준)
	public static Map<String, DatedConversionRate> getRecentlyDatedConversionRate() {
		Map<String, DatedConversionRate> conversionRateMap = new Map<String, DatedConversionRate>();

		List<DatedConversionRate> rateList = [
			Select  Id, 
					IsoCode,
					StartDate,
					NextStartDate, 
					ConversionRate
			From    DatedConversionRate 
			Where   NextStartDate >= 4000-12-31
		];		

		for (DatedConversionRate rateData : rateList) {
			conversionRateMap.put(rateData.IsoCode, rateData);
		}

		return conversionRateMap;
	}

	// // 기간 DatedConversionRate 조회 (정확하게 사용하기 위해서는 NextStartDate에 대한 추가 조건 체크 필요)  (삭제 예정)
	// public static Map<String, DatedConversionRate> getDatedConversionRate(Date fromDate, Date toDate) {

	// 	if (fromDate == null || toDate == null)
	// 		return null;

	// 	Map<String, DatedConversionRate> conversionRateMap = new Map<String, DatedConversionRate>();

	// 	List<DatedConversionRate> rateList = [
	// 		Select  Id, 
	// 				IsoCode,
	// 				StartDate,
	// 				NextStartDate, 
	// 				ConversionRate
	// 		From    DatedConversionRate 
	// 		Where   StartDate >= :fromDate
	// 		And		StartDate <= :toDate
	// 	];

	// 	for (DatedConversionRate rateData : rateList) {
	// 		conversionRateMap.put(rateData.IsoCode + rateData.StartDate, rateData);	// Map Key : 통화 + 시작일
	// 	}

	// 	return conversionRateMap;
	// }	

	// 날짜 List DatedConversionRate 조회 (정확하게 사용하기 위해서는 NextStartDate에 대한 추가 조건 체크 필요)
	public static Map<String, DatedConversionRate> getDatedConversionRate(List<Date> startDateList) {

		if (startDateList == null)
			return null;

		Map<String, DatedConversionRate> conversionRateMap = new Map<String, DatedConversionRate>();

		List<DatedConversionRate> rateList = [
			Select  Id, 
					IsoCode,
					StartDate,
					NextStartDate, 
					ConversionRate
			From    DatedConversionRate 
			Where   StartDate IN :startDateList
		];

		for (DatedConversionRate rateData : rateList) {
			conversionRateMap.put(rateData.IsoCode + rateData.StartDate, rateData);	// Map Key : 통화 + 시작일
		}

		return conversionRateMap;
	}

	// /**  (삭제 예정)
	// * @description : 환율 계산 함수
	// * @author : ghkil@partner.samsung.com | 2020-12-15
	// * @param  : fromIsoCode		계산 대상 통화
	// * @param  : fromAmount  	계산 대상 통화 금액
	// * @param  : toIsoCode  		계산 결과 통화
	// * @return : 환율 계산 결과
	// **/	
	// public static Decimal calculationCurrency (String fromIsoCode, Decimal fromAmount, String toIsoCode) {

	// 	Decimal fromUsdRate;
	// 	Decimal toUsdRate;
	// 	Decimal result = null;

	// 	if (fromIsoCode != null && fromAmount != null && toIsoCode != null) {

	// 		if (getRecentlyDatedConversionRate(fromIsoCode.toUpperCase()) != null) {
	// 			fromUsdRate = getRecentlyDatedConversionRate(fromIsoCode).ConversionRate;
	// 		}
	// 		if (getRecentlyDatedConversionRate(toIsoCode.toUpperCase()) != null) {
	// 			toUsdRate = getRecentlyDatedConversionRate(toIsoCode).ConversionRate;
	// 		}

	// 		if (fromUsdRate != null && toUsdRate != null) {
	// 			result = (fromAmount / fromUsdRate) * toUsdRate;
	// 		}
	// 	} 
	// 	return result;
	// } 

	/**
	* @description : 환율 계산 함수
	* @author : ghkil@partner.samsung.com | 2020-12-17
	* @param  : fromIsoCode		계산 대상 통화
	* @param  : fromAmount  	계산 대상 통화 금액
	* @param  : toIsoCode  		계산 결과 통화
	* @param  : fromUsdRate		계산 대상 URD 비율
	* @param  : toUsdRate  		계산 결과 USD 비율
	* @return : 환율 계산 결과
	**/	
	public static Decimal calculationCurrency (String fromIsoCode, Decimal fromAmount, String toIsoCode, Decimal fromUsdRate, Decimal toUsdRate) {

		Decimal result = null;

		if (fromIsoCode != null && fromAmount != null && toIsoCode != null && fromUsdRate != null && toUsdRate != null) {

			result = (fromAmount / fromUsdRate) * toUsdRate;
		} 
		return result;
	}

	/**
	* @description : 해당 날짜의 분기 시작일 구하기
	* @author : ghkil@partner.samsung.com | 2021-03-18
	* @param  : dateSet				날짜 Set
	* @return : 분기 시작일 Map
	**/	
	public static Map<Date, Date> getQuarterStartDate(Set<Date> dateSet) {

		Map<Date, Date> returnMap = new Map<Date, Date>();

		for (Date dateData : dateSet) {
            
            double dMonth = Double.valueOf( ( dateData+ '').replaceAll('-', '').mid( 4, 2));
			// Integer quarterStartMonth = (((Math.ceil((Decimal.valueOf(dateData.month()) / 12) * 4))*3) - 2).intValue();
			Integer quarterStartMonth = (((Math.ceil(( dMonth / 12) * 4))*3) - 2).intValue();
			Date quarterStartDate = Date.newInstance(dateData.year(), quarterStartMonth, 1);

			returnMap.put(dateData, quarterStartDate);
		}
		
		return returnMap;
	}

	// /** (삭제 예정)
	// * @description : Set에서 Min Date, Max Date 가져오기
	// * @author : ghkil@partner.samsung.com | 2021-03-18
	// * @param  : dateSet				날짜 Set
	// * @return : 분기 시작일 Map
	// **/	
	// public static Map<String, Date> getMinMaxDate(Set<Date> dateSet) {

	// 	Map<String, Date> returnMap = new Map<String, Date>();
	// 	Date maxDate = null;
	// 	Date minDate = null;

	// 	for (Date dateData : dateSet) {
	// 		if (maxDate < dateData) {
	// 			maxDate = dateData;
	// 		}

	// 		if (minDate > dateData) {
	// 			minDate = dateData;
	// 		}			
	// 	}
	// 	returnMap.put('MIN', minDate);
	// 	returnMap.put('MAX', maxDate);

	// 	return returnMap;
	// }
	
	// /** (삭제 예정)
	// * @description : List에서 Min Date, Max Date 가져오기
	// * @author : ghkil@partner.samsung.com | 2021-03-18
	// * @param  : dateList				날짜 List
	// * @return : 분기 시작일 Map
	// **/	
	// public static Map<String, Date> getMinMaxDate(List<Date> dateList) {

	// 	Map<String, Date> returnMap = new Map<String, Date>();
	// 	Date maxDate = null;
	// 	Date minDate = null;

	// 	for (Date dateData : dateList) {
	// 		if (maxDate < dateData) {
	// 			maxDate = dateData;
	// 		}

	// 		if (minDate > dateData) {
	// 			minDate = dateData;
	// 		}			
	// 	}
	// 	returnMap.put('MIN', minDate);
	// 	returnMap.put('MAX', maxDate);

	// 	return returnMap;
	// }		
}