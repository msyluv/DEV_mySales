/**
* @description       : 
* @author            : jiiiiii.park@partner.samsung.com.sds.dev
* @group             : 
* @last modified on  : 2023-11-09
* @last modified by  : atul.k1@samsung.com
* Modifications Log 
* Ver   Date         Author                                     Modification
* 1.0   2020-11-30   jiiiiii.park@partner.samsung.com.sds.dev   Initial Version
* 1.1   2021-10-21   seonju.jin@dkbmc.com                       Employee 조회 공통처리
* 1.2   2022-09-22   hyunhak.roh@dkbmc.com						IF-052 Exception 로그 적용
* 1.3   2023-05-10   chae_ho.yang@samsung.com					사업자번호, CEO명 전송 시 청구지체크->국가체크
* 1.4   2023-07-21   vikrant.ks@samsung.com                     Apply trim instead of deleteWhitespace on Billing Address(MySales 263)
* 1.5   2023-11-09   atul.k1@samsung.com                        IF-130 Request Date Modification(MYSALES-351)
**/
public class MDGAccountNewController {
    @AuraEnabled
    public static Map<String, String> getAccountInfo(String recordId){
        Map<String, String> rtnMap = new Map<String, String>();
        Account account = [SELECT Id, Name, BillingState, BillingStateCode, BillingCity, 
                                  BillingStreet, BillingPostalCode, BillingCountry, BillingCountryCode,
                                  mCountry__c, OwnerId, Owner.Name, Owner.EmployeeNumber, Owner.FederationIdentifier,
                                  CreatedById, CreatedBy.EmployeeNumber, CorporateNumber__c, mDomesticForeign__c, 
                                  mCEOName__c, mBizTypeL1Code__c, mBizTypeL2Code__c, SvcCallNo__c, RtnSvcCallNo__c
                             FROM Account 
                            WHERE Id =: recordId];
        
        User user = [SELECT Id, Name, EmployeeNumber, FederationIdentifier, CompanyCode__c FROM User WHERE Id =: UserInfo.getUserId()];                           
        Employee__c emp = Utils.getEmployeeData(user.FederationIdentifier, new Set<String>{'EvCompany__c','EvDept__c'}, null);
        
        //List<Employee__c> employeeList = [SELECT Id, Name, EvSapEmpNO__c, EvCompany__c, EvDept__c, EvUniqId__c FROM Employee__c WHERE EvUniqId__c =: user.FederationIdentifier LIMIT 1];

        //if(employeeList.size() > 0){
        if(emp != null){
            Map<String, String> stateCodeMap = getBillingStateCodeMap();
            
            Map<String, String> validMap = checkValidation(account);
            rtnMap.put('Valid', validMap.get('Valid'));
            rtnMap.put('Country', account.mCountry__c);
            rtnMap.put('Msg', validMap.get('Msg'));
            
            if(validMap.get('Valid') == 'true'){
                try{
                    /*
                        MDG Address 글자수 제한
                        City : StateCode + '' + City > 40
                        Street : Street > 60
                        PostalCode : PostalCode > 10
                        StateCode : StateCode > 3 [IF(BillingCountryCode == 'BR')]
                        Name : Name > 40

                        * MDG로 전송하는 주소는 공백제거 후 위 제한 글자수만큼 잘라서 전송
                        * 2021-04-28 무슨 이유인지 trim()이 먹히지않아서 deleteWhitespace() 사용

                        // 김홍진프로가  40글자 안넘는다했음
                    */
                    
                    // [MDG Address] - City
                    String city1 = account.BillingStateCode != null ? stateCodeMap.get(account.BillingStateCode) + ' ' + account.BillingCity : account.BillingCity;
                    city1 = city1.trim(); //v1.4
                    city1 = city1.left(40);
                    
                    // [MDG Address] - Street
                    String street = (account.BillingStreet).trim(); //v1.4
                    street = street.left(60);
                    
                    // [MDG Address] - Postal Code
                    String postalCode = (account.BillingPostalCode).trim(); //v1.4
                    postalCode = postalCode.left(10);
                    
                    // [MDG Address] - Country
                    String country = (account.BillingCountry).trim(); //v1.4
                    
                    // [MDG Address] - Region
                    String region = '';
                    if(account.BillingCountryCode == 'BR'){
						region = (account.BillingStateCode).trim(); //v1.4
                        region = region.left(3);
                    }      
                    
					System.debug('city1: '+ city1+'postalCode: '+ postalCode+'country: '+country+'region: '+region);
                    // [MDG Address] - Name
                    // String name = (account.Name).deleteWhitespace();
                    // name = name.left(40);

                    // 2021-05-13 / Account Name에 글자수 제한 및 공백제거 로직 삭제 - 요청자 : 김홍진 프로("Account의 Name이 40글자를 넘어가지않을거다.")
                    String name = account.Name;

                    // [S] IF-052 호출
                    List<IF_MdgAccountSenderController.Address> addList = new List<IF_MdgAccountSenderController.Address>();
                    IF_MdgAccountSenderController.Address add = new IF_MdgAccountSenderController.Address();
                    add.BillingAddressCity1 = city1;
                    add.BillingAddressStreet = street;
                    add.BillingAddressPostalCode = postalCode;
                    add.BillingAddressCountry = country;
                    add.Name = name;
                    if(account.BillingCountryCode == 'BR') add.Region = region;
                    add.SFDCID = account.Id;
                    addList.add(add);
                    
                    List<IF_MdgAccountSenderController.Kna1> knaList = new List<IF_MdgAccountSenderController.Kna1>();
                    IF_MdgAccountSenderController.Kna1 kna = new IF_MdgAccountSenderController.Kna1();
                    kna.CreatedById = account.CreatedBy.EmployeeNumber;
                    kna.mCountry = account.mCountry__c;
                    // 2023.05.10 v1.3 chae_ho.yang 사업자번호, CEO명 전송 시 청구지체크->국가체크
                    if(account.mCountry__c == 'KR') {
                        kna.CorporateNumber = account.CorporateNumber__c;
                        kna.mCEOName = account.mCEOName__c;
                    }
                    kna.mDomesticForeign = account.mDomesticForeign__c;
                    kna.mBizTypeL1Code = account.mBizTypeL1Code__c;
                    kna.mBizTypeL2Code = account.mBizTypeL2Code__c;
                    knaList.add(kna);
                    
                    IF_MdgAccountSenderController.InputClass inputCLass = new IF_MdgAccountSenderController.InputClass();
                    inputCLass.ADRESS = addList;
                    inputCLass.KNA1 = knaList;
                    Map<String,Object> mdgMap = IF_MdgAccountSenderController.send(inputCLass);
                    System.debug('### MDGAccountNewController, mdgMap : ' + mdgMap);
                    // [E] IF-052 호출

                    //HttpResponse res = (HttpResponse)mdgMap.get('HttpResponse');
                    //Map<String,Object> returnMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    
                    Integer returnSF = Integer.valueOf(mdgMap.get('StatusCode'));
                    String returnMsg = String.valueOf(mdgMap.get('IF_MSG'));
                    String returnAccNumber = String.valueOf(mdgMap.get('AccountNumber'));
                    String returnMessage = String.valueOf(mdgMap.get('INTERFACE_LOG'));
                    
                    // IF-052 로그 저장
                    createIfLogList(returnMessage);

                    if(returnSF == 200 && String.valueOf(mdgMap.get('RETURN')).equals('S') ){ //성공 200, RETURN S성공, F실패
                        System.debug('### MDGAccountNewController, IF-052 SUCCESS');
                        
                        // 레코드 타입 업데이트 > [에러-리턴] > 성공
                        RecordType rcdId = [SELECT Id FROM RecordType WHERE IsActive = true AND SobjectType = 'Account' AND DeveloperName = 'MDG'];
                        account.RecordTypeId = rcdId.Id;
                        account.AccountNumber = returnAccNumber;
                        account.MDGCheck__c = true;                        
                        account.ExternalId__c = returnAccNumber;
                        
                        //account.RtnSvcCallNo__c = String.valueOf(tmp.IT_RETURN.SERV_CALL_RLSE_NO);
                        TriggerHandler.bypass('Account_tr');
                        
                        update account;
                        
                        TriggerHandler.clearBypass('Account_tr');
                        
                        
                        Async_Process_IF130(account.Id, returnAccNumber);

                        /*
                        // 2021-03-06 / YoungHoon.Kim / IF-130 호출 추가
                        // [S] IF-130 호출
                        IF_ItsmAccRegSvcRqstController.OutputClass outputClass = new IF_ItsmAccRegSvcRqstController.OutputClass();
                        outputClass.EXTNL_SYS_ID = 'SFDC'; // 대외시스템ID [고정값 : SFDC]
    
                        DateTime now = DateTime.now();
                        String str_month = now.month() < 10 ? '0' + String.valueOf(now.month()) : String.valueOf(now.month());
                        String str_day = now.day() < 10 ? '0' + String.valueOf(now.day()) : String.valueOf(now.day());
                        String str_nextDay = (now.day())+1 < 10 ? '0' + String.valueOf((now.day())+1) : String.valueOf((now.day())+1);
                        String str_hour = now.hour() < 10 ? '0' + String.valueOf(now.hour()) : String.valueOf(now.hour());
                        String str_minute = now.minute() < 10 ? '0' + String.valueOf(now.minute()) : String.valueOf(now.minute());
                        String str_second = now.second() < 10 ? '0' + String.valueOf(now.second()) : String.valueOf(now.second());
    
                        String svcCallNumber = (String.valueOf(account.SvcCallNo__c)).substring(0, 10) + str_hour + str_minute + str_second + (String.valueOf(account.SvcCallNo__c)).substring(10);
                        outputClass.SERV_CALL_RLSE_NO = svcCallNumber; //서비스 콜 이관번호
                        outputClass.TITLE = 'Account (' + returnAccNumber + ')에 대한 Salesview 생성 요청의 건'; //제목
    
                        String address = account.BillingCountry + ' ' + account.BillingState + ' ' + account.BillingCity + ' ' + account.BillingStreet;
                        String reqContents = '';
                        if(account.mCountry__c == 'KR'){ // 국내인 경우
                            reqContents = '고객코드 : ' + returnAccNumber;
                            reqContents += '\n 고객명 : ' + account.Name;
                            reqContents += '\n 국가 : ' + account.mCountry__c;
                            reqContents += '\n 사업자번호 : ' + account.CorporateNumber__c;
                            reqContents += '\n 대/내외 : ' + account.mDomesticForeign__c;
                            reqContents += '\n 주소 : ' + address;
                            reqContents += '\n 대표자명 : ' + account.mCEOName__c;
                            reqContents += '\n 신청자 사번 : ' + account.Owner.EmployeeNumber;
                        }else{ // 해외인 경우
                            reqContents = 'Account Number : ' + returnAccNumber;
                            reqContents += '\n Account Name : ' + account.Name;
                            reqContents += '\n Country : ' + account.mCountry__c;
                            reqContents += '\n Address : ' + address;
                            reqContents += '\n Requestor : ' + account.Owner.EmployeeNumber;
                        }
                        outputClass.REQ_CTNT = reqContents; //요청내용
                        outputClass.REQ_CTNT_TP_CD = 'T'; //요청내용 입력구분 [고정값 : T]
    
                        String requestDate = String.valueOf(now.year()) + str_month + str_day + str_hour + str_minute + str_second;
                        outputClass.REQ_DTM = requestDate; //요청일시 [현재일시]
                        
                        String endReqDate = String.valueOf(now.year()) + str_month + str_nextDay + str_hour + str_minute + str_second;
                        outputClass.END_REQ_DTM = endReqDate; //완료요청일시 [고정값 : 요청일시 + 1]
    
                        outputClass.START_SCHED_DTM = ''; //착수예정일시 [고정값 : null]
                        outputClass.APPLYR_ID = user.FederationIdentifier; //신청자 Uniq_id(암호화됨) [현재 사용자의 EPID]
                        outputClass.APPLYR_EMP_NO = user.EmployeeNumber; //신청자 사번 [현재 사용자의 사번]
                        outputClass.IS_APPLYR_EMP_NO = 'Y'; //신청자사번전송여부 [고정값 : Y]
                        outputClass.APPLYR_NM = user.Name; //신청자명 [현재 사용자의 이름]
                        outputClass.REGR_ID = user.FederationIdentifier; //등록자 UNIQ_ID [현재 사용자의 EPID]
                        outputClass.REGR_NM = user.Name; //등록자명 [현재 사용자의 이름]
    
                        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: recordId];
                        if(cdlList.size() > 0)  outputClass.ATCH_FILE_YN = 'Y'; //첨부파일여부
                        else                    outputClass.ATCH_FILE_YN = 'N'; //첨부파일여부
                        outputClass.END_SCHED_DTM = ''; //완료예정일 [고정값 : null]
                        outputClass.MAILING_YN = 'Y'; //메일수신여부 [고정값 : Y]
                        outputClass.URG_YN = 'Y'; //긴급여부 [고정값 : Y]
                        // outputClass.SRVC_KEY = 'SR201010261401201986660'; //서비스코드 [고정값 : SR201010261401201986660]
                        outputClass.SRVC_KEY = 'SR201802030000000000004'; //서비스코드 [고정값 : SR201802030000000000004]
                        outputClass.CUST_COMP_CD = emp.EvCompany__c; //고객사 회사 코드 [사용자의 인사회사코드]
                        outputClass.CUST_ORG_CD = emp.EvDept__c; //고객사 조직 코드 [사용자의 인사부서코드]
                        outputClass.CUST_COMP_KEY = 'CU200703230441191491343'; //고객사 KEY [고정값 : CU200703230441191491343]
                        outputClass.REG_IP_ADDR = ''; //등록 IP 주소 [고정값 : null]
                        outputClass.IRP_CODE = ''; //IRP 코드 [고정값 : null]
                        outputClass.IRP_NAME = ''; //IRP 코드 [고정값 : null]
                        
                        List<IF_ItsmAccRegSvcRqstController.OutputClass> outputClassList = new List<IF_ItsmAccRegSvcRqstController.OutputClass>();
                        outputClassList.add(outputClass);
                        IF_ItsmAccRegSvcRqstController.OutputHeader outputHeader = new IF_ItsmAccRegSvcRqstController.OutputHeader();
                        outputHeader.srcertid = 'SFDC'; // 대외시스템 ID [고정값 : SFDC]
                        outputHeader.CallDataWithWorkVOV2 = outputClassList;
                        
                        Map<String,Object> srMap = IF_ItsmAccRegSvcRqstController.accRegSvcRqst(JSON.serialize(outputHeader));
                        System.debug('### MDGAccountNewController, srMap : ' + srMap);
    
                        HttpResponse hRes = (HttpResponse)srMap.get('HttpResponse');
                        System.debug('### MDGAccountNewController, hRes : ' + hRes);
                        // Map<String,Object> bodyMap = (Map<String,Object>) JSON.deserializeUntyped(hRes.getBody());
                        tmp tmp;
                        try{
                            tmp = (tmp)JSON.deserializeStrict(hRes.getBody(), tmp.class);
                        }catch(Exception e){
                            tmp = null;
                            System.debug('### MDGAccountNewController, hres body:' + hres.getBody());
                        }
                        // tmp tmp = (tmp)JSON.deserializeStrict(hRes.getBody(), tmp.class);
                        System.debug('### MDGAccountNewController, tmp : ' + tmp);
                        // [E] IF-130 호출

                        if(Integer.valueOf(srMap.get('StatusCode')) == 200 && tmp != null && String.valueOf(tmp.IT_RETURN.RET_SUCCS_CD).equals('Y')){
                            System.debug('### MDGAccountNewController, IF-130 SUCCESS');
                            // 레코드 타입 업데이트 > [에러-리턴] > 성공
                            RecordType rcdId = [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                                  FROM RecordType 
                                                 WHERE IsActive = true 
                                                   AND SobjectType = 'Account' 
                                                   AND DeveloperName = 'MDG'];
                            account.RecordTypeId = rcdId.Id;
                            account.AccountNumber = returnAccNumber;
                            account.MDGCheck__c = true;
    
                            account.ExternalId__c = returnAccNumber;
    
                            account.RtnSvcCallNo__c = String.valueOf(tmp.IT_RETURN.SERV_CALL_RLSE_NO);
    
                            update account;
    
                            // IF-052 로그 저장
                            createIfLogList(returnMessage);
                        }else{
                            System.debug('### MDGAccountNewController, IF-130 ERROR');
                            
                            // IF-052 로그 저장
                            createIfLogList(returnMessage);

                            rtnMap.put('Valid', 'false');
                            if(tmp != null) rtnMap.put('Msg', String.valueOf(tmp.IT_RETURN.RET_MSG));
                            else rtnMap.put('Msg', 'Webservice call exception : ' + hres.getStatusCode() + ',' + hRes.getStatus());
                            return rtnMap;
                        }
                        */
                    }else{
                        System.debug('### MDGAccountNewController, IF-052 ERROR');
                        
                        // IF-052 로그 저장
                        //createIfLogList(returnMessage);

                        rtnMap.put('Valid', 'false');
                        rtnMap.put('Msg', String.valueOf(mdgMap.get('MESSAGE')));
                        return rtnMap;
                    }
                }catch(Exception e){
                    //2022-09-22, hyunhak.roh@dkbmc.com, IF-052 Exception 로그 적용
                    saveAddAcctMDGIfLog(rtnMap, e.getMessage(), e);
                    
                    System.debug('### MDGAccountNewController, Exception, Error : ' + e.getMessage());
                    System.debug(e.getStackTraceString());
                    //throw new AuraHandledException('Error : ' + e.getMessage());
                    rtnMap.put('Valid', 'false');
                    rtnMap.put('Msg', e.getMessage());
                }
            }
            return rtnMap;
        }else{
            rtnMap.put('Valid', 'false');
            rtnMap.put('Msg', System.Label.MDG_MSG_0004);
            return rtnMap;
        }
    }
    @future(callout=true)
    public static void Async_Process_IF130(Id AccountId, String returnAccNumber){       
        
        Account account = [SELECT Id, Name, BillingState, BillingStateCode, BillingCity, 
                                  BillingStreet, BillingPostalCode, BillingCountry, BillingCountryCode,
                                  mCountry__c, OwnerId, Owner.Name, Owner.EmployeeNumber, Owner.FederationIdentifier,
                                  CreatedById, CreatedBy.EmployeeNumber, CorporateNumber__c, mDomesticForeign__c, 
                                  mCEOName__c, mBizTypeL1Code__c, mBizTypeL2Code__c, SvcCallNo__c, RtnSvcCallNo__c
                             FROM Account 
                            WHERE Id =: AccountId];
        
        User user = [SELECT Id, Name, EmployeeNumber, FederationIdentifier, CompanyCode__c FROM User WHERE Id =: UserInfo.getUserId()];                           
        Employee__c emp = Utils.getEmployeeData(user.FederationIdentifier, new Set<String>{'EvCompany__c','EvDept__c'}, null);
        
        // [S] IF-130 호출
        IF_ItsmAccRegSvcRqstController.OutputClass outputClass = new IF_ItsmAccRegSvcRqstController.OutputClass();
        outputClass.EXTNL_SYS_ID = 'SFDC'; // 대외시스템ID [고정값 : SFDC]
        /* V 1.5 Commented MYSALES-351 Start*/
        /*DateTime now = DateTime.now();
        //** DateTime now = KSTDateTime(DateTime.now());
        system.debug('nownow==>'+now);
        String str_month = now.month() < 10 ? '0' + String.valueOf(now.month()) : String.valueOf(now.month());
        String str_day = now.day() < 10 ? '0' + String.valueOf(now.day()) : String.valueOf(now.day());
        String str_nextDay = (now.day())+1 < 10 ? '0' + String.valueOf((now.day())+1) : String.valueOf((now.day())+1);
        String str_hour = now.hour() < 10 ? '0' + String.valueOf(now.hour()) : String.valueOf(now.hour());
        String str_minute = now.minute() < 10 ? '0' + String.valueOf(now.minute()) : String.valueOf(now.minute());
        String str_second = now.second() < 10 ? '0' + String.valueOf(now.second()) : String.valueOf(now.second());*/
        
        //String svcCallNumber = (String.valueOf(account.SvcCallNo__c)).substring(0, 10) + str_hour + str_minute + str_second + (String.valueOf(account.SvcCallNo__c)).substring(10);
        /*V 1.5 Commented MYSALES-351 End*/
        /* V 1.5 Add the line below MYSALES-351*/
        String svcCallNumber = (String.valueOf(account.SvcCallNo__c)).substring(0, 10) + datetime.now().format('kk','Asia/Seoul') + datetime.now().format('mm','Asia/Seoul') + datetime.now().format('ss','Asia/Seoul')+ (String.valueOf(account.SvcCallNo__c)).substring(10);
        outputClass.SERV_CALL_RLSE_NO = svcCallNumber; //서비스 콜 이관번호
        outputClass.TITLE = 'Account (' + returnAccNumber + ')에 대한 Salesview 생성 요청의 건'; //제목
        
        String address = account.BillingCountry + ' ' + account.BillingState + ' ' + account.BillingCity + ' ' + account.BillingStreet;
        String reqContents = '';
        if(account.mCountry__c == 'KR'){ // 국내인 경우
            reqContents = '고객코드 : ' + returnAccNumber;
            reqContents += '\n 고객명 : ' + account.Name;
            reqContents += '\n 국가 : ' + account.mCountry__c;
            reqContents += '\n 사업자번호 : ' + account.CorporateNumber__c;
            reqContents += '\n 대/내외 : ' + account.mDomesticForeign__c;
            reqContents += '\n 주소 : ' + address;
            reqContents += '\n 대표자명 : ' + account.mCEOName__c;
            reqContents += '\n 신청자 사번 : ' + account.Owner.EmployeeNumber;
        }else{ // 해외인 경우
            reqContents = 'Account Number : ' + returnAccNumber;
            reqContents += '\n Account Name : ' + account.Name;
            reqContents += '\n Country : ' + account.mCountry__c;
            reqContents += '\n Address : ' + address;
            reqContents += '\n Requestor : ' + account.Owner.EmployeeNumber;
        }
        outputClass.REQ_CTNT = reqContents; //요청내용
        outputClass.REQ_CTNT_TP_CD = 'T'; //요청내용 입력구분 [고정값 : T]
        /* V 1.5 Comment and Add requestDate the lines below MYSALES-351*/
        // V 1.5 String requestDate = String.valueOf(now.year()) + str_month + str_day + str_hour + str_minute + str_second;
        /*V 1.5*/String requestDate = datetime.now().format('yyyy','Asia/Seoul') + datetime.now().format('MM','Asia/Seoul') + datetime.now().format('dd','Asia/Seoul') + datetime.now().format('kk','Asia/Seoul') + datetime.now().format('mm','Asia/Seoul') + datetime.now().format('ss','Asia/Seoul');
        system.debug('requestDate111==>'+requestDate);
        outputClass.REQ_DTM = requestDate; //요청일시 [현재일시]
        /* Comment and Add endReqDate the lines below MYSALES-351*/
        //String endReqDate = String.valueOf(now.year()) + str_month + str_nextDay + str_hour + str_minute + str_second;
        /*V 1.5*/String endReqDate = datetime.now().format('yyyy','Asia/Seoul') + datetime.now().format('MM','Asia/Seoul') + datetime.now().adddays(1).format('dd','Asia/Seoul') + datetime.now().format('kk','Asia/Seoul') + datetime.now().format('mm','Asia/Seoul') + datetime.now().format('ss','Asia/Seoul');
        outputClass.END_REQ_DTM = endReqDate; //완료요청일시 [고정값 : 요청일시 + 1]
        
        outputClass.START_SCHED_DTM = ''; //착수예정일시 [고정값 : null]
        outputClass.APPLYR_ID = user.FederationIdentifier; //신청자 Uniq_id(암호화됨) [현재 사용자의 EPID]
        outputClass.APPLYR_EMP_NO = user.EmployeeNumber; //신청자 사번 [현재 사용자의 사번]
        outputClass.IS_APPLYR_EMP_NO = 'Y'; //신청자사번전송여부 [고정값 : Y]
        outputClass.APPLYR_NM = user.Name; //신청자명 [현재 사용자의 이름]
        outputClass.REGR_ID = user.FederationIdentifier; //등록자 UNIQ_ID [현재 사용자의 EPID]
        outputClass.REGR_NM = user.Name; //등록자명 [현재 사용자의 이름]
        
        List<ContentDocumentLink> cdlList = [SELECT Id, LinkedEntityId, ContentDocumentId, IsDeleted, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId =: AccountId];
        if(cdlList.size() > 0)  outputClass.ATCH_FILE_YN = 'Y'; //첨부파일여부
        else                    outputClass.ATCH_FILE_YN = 'N'; //첨부파일여부
        outputClass.END_SCHED_DTM = ''; //완료예정일 [고정값 : null]
        outputClass.MAILING_YN = 'Y'; //메일수신여부 [고정값 : Y]
        outputClass.URG_YN = 'Y'; //긴급여부 [고정값 : Y]
        // outputClass.SRVC_KEY = 'SR201010261401201986660'; //서비스코드 [고정값 : SR201010261401201986660]
        outputClass.SRVC_KEY = 'SR201802030000000000004'; //서비스코드 [고정값 : SR201802030000000000004]
        outputClass.CUST_COMP_CD = emp.EvCompany__c; //고객사 회사 코드 [사용자의 인사회사코드]
        outputClass.CUST_ORG_CD = emp.EvDept__c; //고객사 조직 코드 [사용자의 인사부서코드]
        outputClass.CUST_COMP_KEY = 'CU200703230441191491343'; //고객사 KEY [고정값 : CU200703230441191491343]
        outputClass.REG_IP_ADDR = ''; //등록 IP 주소 [고정값 : null]
        outputClass.IRP_CODE = ''; //IRP 코드 [고정값 : null]
        outputClass.IRP_NAME = ''; //IRP 코드 [고정값 : null]
        
        List<IF_ItsmAccRegSvcRqstController.OutputClass> outputClassList = new List<IF_ItsmAccRegSvcRqstController.OutputClass>();
        outputClassList.add(outputClass);
        IF_ItsmAccRegSvcRqstController.OutputHeader outputHeader = new IF_ItsmAccRegSvcRqstController.OutputHeader();
        outputHeader.srcertid = 'SFDC'; // 대외시스템 ID [고정값 : SFDC]
        outputHeader.CallDataWithWorkVOV2 = outputClassList;
        
        Map<String,Object> srMap = IF_ItsmAccRegSvcRqstController.accRegSvcRqst(JSON.serialize(outputHeader));
        System.debug('### MDGAccountNewController, srMap : ' + srMap);
        
        HttpResponse hRes = (HttpResponse)srMap.get('HttpResponse');
        System.debug('### MDGAccountNewController, hRes : ' + hRes);
        // Map<String,Object> bodyMap = (Map<String,Object>) JSON.deserializeUntyped(hRes.getBody());
        tmp tmp;
        try{
            tmp = (tmp)JSON.deserializeStrict(hRes.getBody(), tmp.class);
        }catch(Exception e){
            tmp = null;
            System.debug('### MDGAccountNewController, hres body:' + hres.getBody());
        }
        // tmp tmp = (tmp)JSON.deserializeStrict(hRes.getBody(), tmp.class);
        System.debug('### MDGAccountNewController, tmp : ' + tmp);
        // [E] IF-130 호출
        
        if(Integer.valueOf(srMap.get('StatusCode')) == 200 && tmp != null && String.valueOf(tmp.IT_RETURN.RET_SUCCS_CD).equals('Y')){
            System.debug('### MDGAccountNewController, IF-130 SUCCESS');
            // 레코드 타입 업데이트 > [에러-리턴] > 성공            
            account.RtnSvcCallNo__c = String.valueOf(tmp.IT_RETURN.SERV_CALL_RLSE_NO);
            
            TriggerHandler.bypass('Account_tr');
            
            update account;
            
            TriggerHandler.clearBypass('Account_tr');
            
            // IF-052 로그 저장
            //createIfLogList(returnMessage);
        }
        /*
        else{
            System.debug('### MDGAccountNewController, IF-130 ERROR');
            
            // IF-052 로그 저장
            //createIfLogList(returnMessage);
            
            rtnMap.put('Valid', 'false');
            if(tmp != null) rtnMap.put('Msg', String.valueOf(tmp.IT_RETURN.RET_MSG));
            else rtnMap.put('Msg', 'Webservice call exception : ' + hres.getStatusCode() + ',' + hRes.getStatus());
            return rtnMap;
        }
		*/
        
    }
    public static void saveAddAcctMDGIfLog(Map<String, String> rtnLogMap, String msg, Exception e)
    {
        System.debug('### MDGAccountNewController, IF-ACCMDG Exception');
        String INTERFACE_ID = 'IF-ACCMDG';
        String APEX_CLASS   = 'MDGAccountNewController';
        String METHOD_NAME  = 'getAccountInfo';
        IF_Log.InterfaceLog infLog;
        IF_Log log = new IF_Log();
        
        infLog = new IF_Log.InterfaceLog( INTERFACE_ID, IF_Util.generateGuid(), APEX_CLASS, METHOD_NAME, rtnLogMap.toString(), msg, e);
        log.createLog( infLog);
        
        //System.debug('### MDGAccountNewController, IF-ACCMDG Exception, rtnLogMap.toString() : ' + rtnLogMap.toString());
        //System.debug('### MDGAccountNewController, IF-ACCMDG Exception, msg : ' + msg);
        //System.debug('### MDGAccountNewController, IF-ACCMDG Exception, trace : ' + e.getStackTraceString());
        //System.debug('### MDGAccountNewController, IF-ACCMDG Exception, End');
    }
    
    public static Map<String, String> checkValidation(Account Account){
        Map<String, String> rtnMap = new Map<String, String>();
        
        if(account.Name != null &&
           // account.BillingState != null &&
           account.BillingCity != null &&
           account.BillingStreet != null &&
           account.BillingPostalCode != null &&
           account.BillingCountry != null &&
           account.mBizTypeL1Code__c != null &&
           account.mBizTypeL2Code__c != null &&
           account.mCountry__c != null &&
           account.mDomesticForeign__c != null){ // 필수값 체크
               if(account.mCountry__c == 'KR'){ // 국가가 대한민국인 경우 필수값 추가
                   if(account.CorporateNumber__c != null && account.mCEOName__c != null){
                       if(account.CorporateNumber__c.length() == 10){ //사업자번호 10자리
                           RecordType rcdIdCor = [SELECT Id, Name, DeveloperName, SobjectType, IsActive 
                                                  FROM RecordType 
                                                  WHERE IsActive = true 
                                                  AND SobjectType = 'Account' 
                                                  AND DeveloperName = 'MDG'];
                           List<Account> mdgAccountList = [SELECT Id, RecordTypeId 
                                                           FROM Account 
                                                           WHERE CorporateNumber__c =: account.CorporateNumber__c
                                                           AND Id !=: Account.Id
                                                           AND (RecordTypeId =: rcdIdCor.Id OR MDGCheck__c = true)];
                           if(mdgAccountList.size() > 0){
                               rtnMap.put('Valid', 'false');
                               rtnMap.put('Msg', System.Label.ACCT_MSG_0002); // The business number was already registered.
                           }else{
                               rtnMap.put('Valid', 'true');
                               rtnMap.put('Msg', '');
                           }
                       } else {
                           rtnMap.put('Valid', 'false');
                           rtnMap.put('Msg', System.Label.ACCT_MSG_0001); // The business number must be 10 characters long.
                       }
                   }else{
                       rtnMap.put('Valid', 'false');
                       rtnMap.put('Msg', System.Label.ACCT_MSG_0003); // MDG call fail : Please enter the required value
                   }
               }else{
                   rtnMap.put('Valid', 'true');
                   rtnMap.put('Msg','');
               }
           }else{
               rtnMap.put('Valid', 'false');
               rtnMap.put('Msg', System.Label.ACCT_MSG_0003); // MDG call fail : Please enter the required value
           }
        return rtnMap;
    }
    
    public static Map<String, String> getBillingStateCodeMap(){
        Map<String, String> rtnMap = new Map<String, String>();
        
        Schema.DescribeFieldResult stateCodeResult = Account.BillingStateCode.getDescribe();
        List<Schema.PicklistEntry> stateCodeList = stateCodeResult.getPicklistValues();
        for( Schema.PicklistEntry stateCode : stateCodeList){
            rtnMap.put(stateCode.getValue(), stateCode.getLabel());
        }
        
        return rtnMap;
    }

    public static void createIfLogList(String ifLogListJSON){
        try{
            if(String.isNotBlank(ifLogListJSON)) {
                IF_Log.InterfaceLog ifLog = (IF_Log.InterfaceLog)JSON.deserialize(ifLogListJSON, IF_Log.InterfaceLog.class);
                IF_Log log = new IF_Log();                
                log.createLog(ifLog);
            }
        }catch(Exception e){
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
    }

    // 2022-05-09 / Minhye.Park / 수동 IF-153, IF-154 호출버튼 추가 
    @AuraEnabled
    public static Map<String, Object> AccountTendencySync(){ //고객성향 Sync
        Map<String, Object> resMap = new Map<String, Object>();
        try{
            Set<Id> accSet = new Set<Id>(); // Batch 호출을 위한 Set일뿐 값은 없음
            DataBase.executeBatch(new Batch_AccountInfoC360(2, accSet), 200); // IF-153
            DataBase.executeBatch(new Batch_AccountInfoLegacy(2, accSet), 200); // IF-154

            resMap.put('Result', 'S');
            resMap.put('Message', '고객성향 Sync 완료');
        }catch(Exception e) {
            System.debug('**********************************************************************');
            System.debug(System.LoggingLevel.ERROR, ' e.getLineNumber() : ' + e.getLineNumber());
            System.debug(System.LoggingLevel.ERROR, ' e.getTypeName() : ' + e.getTypeName());
            System.debug(System.LoggingLevel.ERROR, ' e.getMessage() : ' + e.getMessage());
            System.debug('**********************************************************************');

            resMap.put('Result', 'E');
            resMap.put('Message', '고객성향 Sync 실패');
        }
        
        return resMap;
    }

    public class tmp{
        @AuraEnabled
        public IT_RETURN IT_RETURN;
    }

    public class IT_RETURN{
        @AuraEnabled
        public String SERV_CALL_RLSE_NO;
        @AuraEnabled
        public String RET_SUCCS_CD;
        @AuraEnabled
        public String CHECK_CD;
        @AuraEnabled
        public String RET_MSG;
    }
}