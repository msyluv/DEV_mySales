/**
 * @description       : 
 * @author            : ghkil@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-03-22
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                      Modification
 * 1.0   2020-10-28   ghkil@partner.samsung.com   Initial Version
**/
@isTest
global class IF_Callout_TestMock implements HttpCalloutMock {
    
    Integer returnStatusCode = 200;
    String returnStatus = 'OK';

    global IF_Callout_TestMock() {    
        returnStatusCode = 200;
        setReturnStatus(returnStatusCode);
    }

    global IF_Callout_TestMock(Integer statusCode) {
        returnStatusCode = statusCode;
        setReturnStatus(returnStatusCode);
    }

    global IF_Callout_TestMock(Integer statusCode, String status) {
        returnStatusCode = statusCode;
        returnStatus = status;
    }

    private void setReturnStatus(Integer statusCode) {
        
        if (statusCode == 200) {
            returnStatus = 'OK';
        } else if (statusCode == 201) {
            returnStatus = 'Created';
        } else if (statusCode == 202) {
            returnStatus = 'Accepted';
        } else if (statusCode == 300) {
            returnStatus = 'Multiple Choice';
        } else if (statusCode == 301) {
            returnStatus = 'Moved Permanently';
        } else if (statusCode == 302) {
            returnStatus = 'Found';
        } else if (statusCode == 400) {
            returnStatus = 'Bad Request';
        } else if (statusCode == 401) {
            returnStatus = 'Unauthorized';
        } else if (statusCode == 402) {
            returnStatus = 'Payment Required';
        }
    } 

    global HttpResponse respond(HttpRequest request) {

        String url      = request.getEndPoint();
        System.debug('url::::' + url);
        String jsonData = getResponseData( url + '');
        HttpResponse response = new HttpResponse();

        System.debug( 'jsonData::::' + jsonData);

        response.setHeader('Content-Type', 'application/json');
        response.setBody( jsonData);
//        response.setBody('{"animals": ["majestic badger_mock", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}');
        response.setStatus(returnStatus);
        response.setStatusCode(returnStatusCode);

        return response;
    }


    global String getResponseData( String val){

        System.debug( 'val::::' + val);
        String jsonData = '{"animals": ["majestic badger_mock", "fluffy bunny", "scary bear", "chicken", "mighty moose"]}';
        if (val.indexOf('/if004/') > -1) {
            jsonData = '{ ' +
                '  "IT_PROJ": [ ' +
                '  { ' +
                '    "ZZORDER_ID": "SDS-20054480", ' +
                '    "ZZBUKRS_H": "T100", ' +
                '    "PSPID": "SCA07000285A000", ' +
                '    "SALES_EMP_NO": "16421", ' +
                '    "SALES_EMP_NAME": "홍길동", ' +
                '    "ZZSALES_C_NAME_M": "T100-12371", ' +
                '    "ZZORDER_AMT": 1000000000 ' +
                '  } ' +
                '], ' +
                '  "EV_RESULT": "S" ' +
            ' }';
        }else if (val.indexOf('/if005/') > -1) {
            jsonData = '{ ' +
                '  "ET_ESTAT": [ ' +
                '  { ' +
                '    "EV_ZZORDER_ID": "SIC20054481A000", ' +
                '    "EV_ESTAT": "B100", ' +
                '    "EV_ESTAT_TXT": "수주품의", ' +
                '    "EV_SUB_HQ": "M", ' +
                '    "EV_RESULT": "E" ' +
                '  } ' +
                '] ' +
            ' }';
        } else if (val.indexOf('/if008/') > -1) {
            jsonData = '{ "E_RTNST": "S" }';
        } else if (val.indexOf('/if009/') > -1) {
            jsonData =  '{ ' +
                        '   "ES_RTMSG": [ ' +
                        '   { ' +
                        '        "TYPE": "S", ' +
                        '        "RTMSG": "Success" ' +
                        '    } ' +
                        '   ] ' +
                        ' }';
        } else if (val.indexOf('/if010/') > -1) {
            jsonData = '{ "EV_RTNST": "S" }';
        } else if (val.indexOf('/if011/') > -1) {
            jsonData =  '{ ' +
                        '   "T_PATHLIST": [ ' +
                        '   { ' +
                        '        "objectKey": "", ' +
                        '        "draftId": "terius.kim", ' +
                        '        "draftCompany": "C60", ' +
                        '        "draftEmpNo": "16241", ' +
                        '        "draftDept": "C60AJ760", ' +
                        '        "approvalLine": "오른쪽과 같음", ' +
                        '        "T_USERS": [ ' +
                        '           { ' +
                        '               "user_type": "1", ' +
                        '               "user_roleID": "", ' +
                        '               "user_roleType": "0", ' +
                        '               "user_option": "0", ' +
                        '               "user_serialOrder": "1", ' +
                        '               "user_parallelOrder": "0", ' +
                        '               "user_isPool": "", ' +
                        '               "userID": "terius.kim", ' +
                        '               "userUID": "S020126190831C600013", ' +
                        '               "userName": "김경남", ' +
                        '               "userOtherName": "KIM KYUNGNAM", ' +
                        '               "employeeNumber": "C6016241", ' +
                        '               "deptName": "C60AJ760", ' +
                        '               "gradeName": "B1J0", ' +
                        '               "stageName": "", ' +
                        '               "stageTypeName": "", ' +   
                        '           } ' +
                        '        ] ' +                     
                        '    } ' +
                        '   ] ' +
                        ' }';
        } else if (val.indexOf('/if015/') > -1) {
            jsonData =  '{ ' +
                        '  "TT_OPPORT_H": [ ' +
                        '  { ' +
                        '    "GUBUN": "H", ' +
                        '    "BUKRS": "T100", ' +
                        '    "ZZORDER_ID": "SDS-16300280", ' +
                        '    "DESCRIPTION": "삼성에스디아이 (주) 울산 PACK라인 FA망 NW 구매대행공급", ' +
                        '    "PARTNER": 29581, ' +
                        '    "NAME_LAST": "최송", ' +
                        '    "NUMBER_INT": 0, ' +
                        '    "ZZSERVICE": "string", ' +
                        '    "ZZSERVICE_DESC": "string", ' +
                        '    "ZZSLSDIVISION": "string", ' +
                        '    "ZZSLSDIVISION_NM": "string", ' +
                        '    "ZZSLSTEAM": "string", ' +
                        '    "ZZSLSTEAM_NM": "string", ' +
                        '    "ZZSLSDEPT_B": "T100-11961", ' +
                        '    "ZZSLSDEPT_B_DESC": "사업그룹(스마트팩토리)", ' +
                        '    "ZZDLVDEPT_B": "T100-11493", ' +
                        '    "ZZDLVDEPT_B_DESC": "네트워크그룹(제조)", ' +
                        '    "ZZSLSDEPT_A": "T100-11961", ' +
                        '    "ZZSLSDEPT_A_DESC": "SET사업그룹(사업전략)", ' +
                        '    "ZZDLVDEPT_A": "T100-11493", ' +
                        '    "ZZDLVDEPT_A_DESC": "부품/제조네트워크그룹(네트워크기술)" ' +
                        '  } ' +
                        '], ' +
                        '"TT_SERVICE": [ ' +
                        '  { ' +
                        '    "ZZORDER_ID": "SDS-16300280", ' +
                        '    "PSPID_OUTPUT": "SCC-16300281-A0", ' +
                        '    "PSPID": "SCC16300281A000", ' +
                        '    "PSPID_DESC": "삼성에스디아이 (주) 울산 PACK라인 FA망 NW", ' +
                        '    "POSID_OUTPUT": "SCC-16300281-A0", ' +
                        '    "POSID": "SCC16300281A000", ' +
                        '    "POSID_DESC": "삼성에스디아이 (주) 울산 PACK라인 FA망 NW", ' +
                        '    "NUMBER_INT": 0, ' +
                        '    "ZZSERVICE": 20000020, ' +
                        '    "ZZSERVICE_DESC": "Network", ' +
                        '    "ZZSLSDIVISION": "T100-12033", ' +
                        '    "ZZSLSDIVISION_NM": "인텔리전트팩토리사업부", ' +
                        '    "ZZSLSTEAM": "T100-12034", ' +
                        '    "ZZSLSTEAM_NM": "사업전략팀", ' +
                        '    "ZZSLSDEPT": "T100-11961", ' +
                        '    "ZZSLSDEPT_DESC": "SET사업그룹(사업전략)", ' +
                        '    "ZZDLVDEPT": "T100-11493", ' +
                        '    "ZZDLVDEPT_DESC": "부품/제조네트워크그룹(네트워크기술)" ' +
                        '  } ' +
                        '], ' +
                        '"TT_KOSTL": [ ' +
                        '  { ' +
                        '    "BUKRS": "T100", ' +
                        '    "KOSTL": "T100-10022", ' +
                        '    "VERAK": "전자/제조컨설팅그룹(IT혁신컨설팅)" ' +
                        '  } ' +
                        '] ' +
                    ' }';
        } else if (val.indexOf('/if016/') > -1) {
            jsonData = '{ ' +
                '  "ET_RESULT": [ ' +
                '  { ' +
                '    "ZZORDER_ID": "SDS-07000285", ' +
                '    "PSPID": "SCA-07000285-A0", ' +
                '    "POSID": "SCA-07000285-A0-01", ' +
                '    "ASTNR": 20000032, ' +
                '    "FR_ROCTR": "", ' +
                '    "TO_ROCTR": "T100-10463", ' +
                '    "FR_SACTR": "", ' +
                '    "TO_SACTR": "T100-10463" ' +
                //'    "FR_INCTR": "", ' +
                //'    "TO_INCTR": "", ' +
                //'    "L_ORGEH": "" ' +
                '  } ' +
                '], ' +
                '  "EV_ERROR": "S", ' +
                '  "EV_MESSAGE": "" ' +
            ' }';
        } else if (val.indexOf('/if017/') > -1) {
            jsonData = '{ ' +
                        '    "RTN_CNT": "string", ' +
                        '    "row": [ ' +
                        '    { ' +
                        '        "KURST": "M", ' +
                        '        "FCURR": "KRW", ' +
                        '        "TCURR": "USD", ' +
                        '        "GDATU": "2020.10.13", ' +
                        '        "UKURS": 1206.6, ' +
                        '        "FFACT": 1, ' +
                        '        "TFACT": 1 ' +
                        '    } ' +
                        '    ] ' +
                        ' }';            
        } else if (val.indexOf('/if018/') > -1) {
            jsonData =  '{ ' +
                        '"TT_RESULT": [ ' +
                        '    { ' +
                        '      "PSPID": "SIC18058521A000", ' +
                        '      "RFQ_NO": "Q000087496002", ' +
                        '      "BANFN": 4000030306, ' +
                        '      "POSID": "string", ' +
                        '      "PS_PSP_PNR": 726450, ' +
                        '      "START_DT": "2019.12.16", ' +
                        '      "END_DT": "2020.12.15", ' +
                        '      "IO_CD": 1, ' +
                        '      "PRICE": 16645800, ' +
                        '      "PRICE_I": 0, ' +
                        '      "WAERS": "KRW", ' +
                        '      "WAERS_EN": "string", ' +
                        '      "GUBUN": "A", ' +
                        '      "EBELN": 3400016365, ' +
                        '      "BSART": "string", ' +
                        '      "VERSI": "string", ' +
                        '      "ZZ_CONNM": "string", ' +
                        '      "LIFNR": "string", ' +
                        '      "NAME1": "string", ' +
                        '      "ZZ_CONFT": "2019.12.16", ' +
                        '      "ZZ_CONTT": "2020.12.15", ' +
                        '      "MONTH_AMT": 1716646.53, ' +
                        '      "ICMS": 0, ' +
                        '      "IPI": 0, ' +
                        '      "ICMS_ST": 0, ' +
                        '      "PIS": 0, ' +
                        '      "COFINS": 0, ' +
                        '      "ISS": 0, ' +
                        '      "IRRF": 0, ' +
                        '      "CSLL": 0, ' +
                        '      "INSS": 0 ' +
                        '    } ' +
                        '  ], ' +
                        '  "TT_SLAVE": [ ' +
                        '    { ' +
                        '      "EBELN": 3400016365, ' +
                        '      "PS_PSP_PNR": 726450, ' +
                        '      "SYSTEM_ID": "MM21", ' +
                        '      "YYYYMM": 201912, ' +
                        '      "MONTH_AMT": 951929.68, ' +
                        '      "WAERS": "KRW" ' +
                        '    } ' +
                        '  ], ' +
                        '  "EV_RETURN": "string", ' +
                        '  "EV_RETMSG": "string" ' +
                        ' }';
        } else if (val.indexOf('/if019/') > -1) {
            jsonData = '{ ' +
            '  "IT_DATA":[  ' +
            '   {	 ' +
            '       "BizRegNo":"1018116269", ' +
            '       "InformationSource":"SMInfo", ' +
            '       "Name":"2019-12-30", ' +
            '       "TotalAssets":"9.77655133E11", ' +
            '       "TotalLiability":"0.0", ' +
            '       "TotalCapital":"3.39057379E11", ' +
            '       "Revenue":"3.211386027E12", ' +
            '       "OperatingProfit":"2.8049946E10", ' +
            '       "NetIncome":"1.5469289E10" ' +
            '   }, '+
            '   {	 ' +
            '       "BizRegNo":"1018116269", ' +
            '       "InformationSource":"SMInfo", ' +
            '       "Name":"2019-12-31", ' +
            '       "TotalAssets":"9.77655133E11", ' +
            '       "TotalLiability":"0.0", ' +
            '       "TotalCapital":"3.39057379E11", ' +
            '       "Revenue":"3.211386027E12", ' +
            '       "OperatingProfit":"2.8049946E10", ' +
            '       "NetIncome":"1.5469289E10" ' +
            '   }'+
            '   ]' +
            '}';            
        } else if (val.indexOf('/if022/') > -1) {
            jsonData = '{' +
            '   "IT_DATA": [ ' +
            '   { ' +
            '       "CorporateNumber": "1048158502", ' +
            '       "eInfoSource": "OPENDART", ' +
            '       "eAccName": "(주)아이마켓코리아", ' +
            '       "eAccNameE": "iMarketKorea Inc.", ' +
            '       "eCEOName": "남인봉", ' +
            '       "eAddress": "서울특별시 강남구 삼성로 512 삼성동빌딩 16층", ' +
            '       "ePhoneNum": "02-3708-5678", ' +
            '       "eFaxNum": "02-3708-5797", ' +
            '       "eHomepage": "www.imarketkorea.com", ' +
            '       "eCorporateNum": "1048158502", ' +
            '       "eEstablishmentDate": "2001-12-08", ' +
            '       "eIndustryCode": "", ' +
            '       "eUpdateDateB": "2019-12-30" ' +
            '   } ' +
            '   ] ' +
            '}';            
        } else if (val.indexOf('/if025/') > -1) {
            jsonData = '{' +
            '   "IT_DATA": [ ' +
            '   { ' +
            '       "BizRegNo": "string", ' +
            '       "InfoSource": "string", ' +
            '       "SeqNo": "string", ' +
            '       "ExecName": "string", ' +
            '       "Gender": "남", ' +
            '       "BirthDay": "string", ' +
            '       "JobTitle": "string", ' +
            '       "RegisteredExecutive": "string", ' +
            '       "WorkingType": "string", ' +
            '       "JobDescription": "string", ' +
            '       "Description": "string", ' +
            '       "StockHolder": "string", ' +
            '       "EmploymentPeriod": "string", ' +
            '       "ExpirationDay": "string" ' +
            '   } ' +
            '   ] ' +
            '}';            
        } else if (val.indexOf('/if026/') > -1) {
            jsonData = '{' +
            '   "IT_DATA": [ ' +
            '   { ' +
            '       "CorporateNumber": "1018123421", ' +
            '       "eInfoSource": "OPENDART", ' +
            '       "eAccName": "(주)아이마켓코리아", ' +
            '       "eAccNameE": "iMarketKorea Inc.", ' +
            '       "eCEOName": "남인봉", ' +
            '       "eAddress": "서울특별시 강남구 삼성로 512 삼성동빌딩 16층", ' +
            '       "ePhoneNum": "02-3708-5678", ' +
            '       "eFaxNum": "02-3708-5797", ' +
            '       "eHomepage": "www.imarketkorea.com", ' +
            '       "eCorporateNum": "1018123421", ' +
            '       "eEstablishmentDate": "2001-12-08", ' +
            '       "eIndustryCode": "", ' +
            '       "eUpdateDateB": "2019-12-30" ' +
            '   } ' +
            '   ] ' +
            '   ,' +
            '   "IT_FINANCE": [' +
            '   {' +
            '       "BizRegNo": "5148106690",' +
            '       "InformationSource": "OpenDart",' +
            '       "Name": "20181231",' +
            '       "TotalAssets": "772716727753",' +
            '       "TotalLiability": "555212961283",' +
            '       "TotalCapital": "217503766470",' +
            '       "Revenue": "654760355625",' +
            '       "OperatingProfit": "5219510812",' +
            '       "NetIncome": "1464261985"' +
            '   }' +
            '   ]' +
            '   ,' +
            '   "IT_HISTORY": [' +
            '   {' +
            '       "BizRegNo": "1208103391",' +
            '       "InfoSource": "SMInfo",' +
            '       "HistoryDate": "20151008",' +
            '       "Description": "본점을 서울 강남구 영동대로 517 (삼성동,아셈타워) 소재로 이전"' +
            '   }' +
            '   ]' +
            '   ,' +
            '   "IT_MANAGER": [' +
            '   {' +
            '       "BizRegNo": "1208103391",' +
            '       "InfoSource": "SMInfo",' +
            '       "SeqNo": "3",' +
            '       "ExecName": "스콧러셀발포어",' +
            '       "Gender": null,' +
            '       "BirthDay": null,' +
            '       "JobTitle": "사내이사",' +
            '       "RegisteredExecutive": null,' +
            '       "WorkingType": null,' +
            '       "JobDescription": null,' +
            '       "Description": null,' +
            '       "StockHolder": null,' +
            '       "EmploymentPeriod": null,' +
            '       "ExpirationDay": null' +
            '   }' +
            '   ]' +
            '}';            
        } else if (val.indexOf('/if029/') > -1) {
            jsonData = '{ ' +
                '  "EV_RETURN": "Y" ' +                
            ' }';
        } else if (val.indexOf('/if034/') > -1) {
            jsonData =  '{' +
                        '  "TT_RTN": [ ' +
                        '    { ' +
                        '      "TYPE": null, ' +
                        '      "ID": null, ' +
                        '      "NUMBER": null, ' +
                        '      "MESSAGE": null, ' +
                        '      "LOG_NO": null, ' +
                        '      "LOG_MSG_NO": null, ' +
                        '      "MESSAGE_V1": null, ' +
                        '      "MESSAGE_V2": null, ' +
                        '      "MESSAGE_V3": null, ' +
                        '      "MESSAGE_V4": null, ' +
                        '      "PARAMETER": null, ' +
                        '      "ROW": null, ' +
                        '      "FIELD": null, ' +
                        '      "SYSTEM": null ' +
                        '    } ' +
                        '  ], ' +
                        '  "EV_RTNST": "S" ' +
                        '}';
        } else if (val.indexOf('/if036/') > -1) {
            jsonData =  '{ ' +
                        '   "TT_PLANAMT": [ ' +
                        '    { ' +
                        '      "PSPID": "SIC-20001421-A0", ' +
                        '      "POSID": "SCC-14006235-C0-01-11", ' +
                        '      "PSPRI": "1", ' +
                        '      "WAERS": "KRW", ' +
                        '      "LOCAMT": 738085.17 ' +
                        '    } ' +
                        '  ], ' +
                        '  "ES_ACT": ' +
                        '    { ' +
                        '      "KSTAR_105": 0.00, ' +
                        '      "KSTAR_111": 0.00, ' +
                        '      "KSTAR_255": 0.00, ' +
                        '      "KSTAR_265": 0.00, ' +
                        '      "KSTAR_195": 0.00, ' +
                        '      "KSTAR_211": 0.00, ' +
                        '      "KSTAR_910": 0.00, ' +
                        '      "WAERS": "" ' +
                        '    }, ' +
                        '  "ES_PLAN": ' +
                        '    { ' +
                        '      "KSTAR_105": 0.00, ' +
                        '      "KSTAR_111": 0.00, ' +
                        '      "KSTAR_255": 0.00, ' +
                        '      "KSTAR_265": 0.00, ' +
                        '      "KSTAR_195": 0.00, ' +
                        '      "KSTAR_211": 0.00, ' +
                        '      "KSTAR_910": 0.00, ' +
                        '      "WAERS": "" ' +
                        '    } ' +
                        ' }';
        } else if (val.indexOf('/if040/') > -1) {
            jsonData =  '{' +
                        '  "ET_MESSAGE": [ ' +
                        '    { ' +
                        '      "TYPE": "W", ' +
                        '      "ID": "", ' +
                        '      "NUMBER": 51, ' +
                        '      "MESSAGE": "There is a Project Code with the same BO nu", ' +
                        '      "LOG_NO": "", ' +
                        '      "LOG_MSG_NO": 0, ' +
                        '      "MESSAGE_V1": "", ' +
                        '      "MESSAGE_V2": "", ' +
                        '      "MESSAGE_V3": "", ' +
                        '      "MESSAGE_V4": "", ' +
                        '      "PARAMETER": "", ' +
                        '      "ROW": 0, ' +
                        '      "FIELD": "", ' +
                        '      "SYSTEM": "" ' +
                        '    } ' +
                        '  ], ' +
                        '  "ET_WBS_INFO": [ ' +
                        '    { ' +
                        '      "PSPID": "SMC20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMC20061131A000", ' +
                        '      "POSID": "SMC20061131A000", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": "", ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMC20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMC20061131A000", ' +
                        '      "POSID": "SMC20061131A001", ' +
                        '      "ZZSOLUTION": "", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMC20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMC20061131A000", ' +
                        '      "POSID": "SMC20061131A00111", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMC20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMC20061131A000", ' +
                        '      "POSID": "SMC20061131A00121", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMC20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMC20061131A000", ' +
                        '      "POSID": "SMC20061131A00131", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMA20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMA20061131A000", ' +
                        '      "POSID": "SMA20061131A000", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": "", ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMA20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMA20061131A000", ' +
                        '      "POSID": "SMA20061131A001", ' +
                        '      "ZZSOLUTION": "", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMA20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMA20061131A000", ' +
                        '      "POSID": "SMA20061131A00111", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMA20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMA20061131A000", ' +
                        '      "POSID": "SMA20061131A00121", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    }, ' +
                        '    { ' +
                        '      "PSPID": "SMA20061131A000", ' +
                        '      "PSPID_OUTPUT": "SMA20061131A000", ' +
                        '      "POSID": "SMA20061131A00131", ' +
                        '      "ZZSOLUTION": "30000067", ' +
                        '      "SERVICE": 20000020, ' +
                        '      "NUMBER_INT": 10, ' +
                        '      "LOEVM": "", ' +
                        '      "SOLUTION_OWNER": "" ' +
                        '    } ' +
                        '  ], ' +
                        '  "ET_PJT_CODE_A": "SMA-20061131-A0", ' +
                        '  "ET_PJT_CODE_C": "SMC-20061131-A0" ' +
                        '}';
        } else if (val.indexOf('/if042/') > -1) {
            jsonData =  '{ ' +
                        '} ' ;
        } else if (val.indexOf('/if049/') > -1){

            jsonData = '{' +
            '"EV_RTNID": null,' +
            '"EV_RTNMS": null,' +
            '"EV_RTNST": "C",' +
            '"EV_VERSION": "Z00"' +
            '}';
        } else if (val.indexOf('/if050/') > -1){

            jsonData = '{   "ET_MESSAGE": [     {       "TYPE": "S",       "ID": null,       "NUMBER": "000",       "MESSAGE": "SIA20056211A001 Service wbs change is success.",       "LOG_NO": null,       "LOG_MSG_NO": "000000",       "MESSAGE_V1": null,       "MESSAGE_V2": null,       "MESSAGE_V3": null,       "MESSAGE_V4": null,       "PARAMETER": null,       "ROW": "0",       "FIELD": null,       "SYSTEM": null     },     {       "TYPE": "S",       "ID": null,       "NUMBER": "000",       "MESSAGE": "SIC20056211A001 Service wbs change is success.",       "LOG_NO": null,       "LOG_MSG_NO": "000000",       "MESSAGE_V1": null,       "MESSAGE_V2": null,       "MESSAGE_V3": null,       "MESSAGE_V4": null,       "PARAMETER": null,       "ROW": "0",       "FIELD": null,       "SYSTEM": null     },     {       "TYPE": "S",       "ID": null,       "NUMBER": "000",       "MESSAGE": "Solution Delete is complete( 30000085 )",       "LOG_NO": null,       "LOG_MSG_NO": "000000",       "MESSAGE_V1": null,       "MESSAGE_V2": null,       "MESSAGE_V3": null,       "MESSAGE_V4": null,       "PARAMETER": null,       "ROW": "0",       "FIELD": null,       "SYSTEM": null     }   ],   "ET_WBS_INFO": [     {       "PSPID": "SCC20056211A000",       "PSPID_OUTPUT": "SCC-20056211-A0",       "POSID": "SCC20056211A000",       "ZZSOLUTION": "30000085",       "SERVICE": "22000004",       "NUMBER_INT": "0000000000",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12032"     },     {       "PSPID": "SCC20056211A000",       "PSPID_OUTPUT": "SCC-20056211-A0",       "POSID": "SCC20056211A001",       "ZZSOLUTION": null,       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12042"     },     {       "PSPID": "SCC20056211A000",       "PSPID_OUTPUT": "SCC-20056211-A0",       "POSID": "SCC20056211A00132",       "ZZSOLUTION": "30000085",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A000",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000000",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12032"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A001",       "ZZSOLUTION": "30000075",       "SERVICE": "22000004",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-11792"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00111",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00121",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00131",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A002",       "ZZSOLUTION": null,       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00211",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00221",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIA20056211A000",       "PSPID_OUTPUT": "SIA-20056211-A0",       "POSID": "SIA20056211A00231",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A000",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000000",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12032"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A001",       "ZZSOLUTION": null,       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12042"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00111",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00121",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00131",       "ZZSOLUTION": "30000054",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": null,       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00132",       "ZZSOLUTION": "30000085",       "SERVICE": "22000004",       "NUMBER_INT": "0000000010",       "LOEVM": "X",       "SOLUTION_OWNER": "T100-10056"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A002",       "ZZSOLUTION": null,       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00211",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00221",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     },     {       "PSPID": "SIC20056211A000",       "PSPID_OUTPUT": "SIC-20056211-A0",       "POSID": "SIC20056211A00231",       "ZZSOLUTION": "30000075",       "SERVICE": "20000022",       "NUMBER_INT": "0000000020",       "LOEVM": null,       "SOLUTION_OWNER": "T100-12185"     }   ] }';
        } else if (val.indexOf('/if052/') > -1){
            jsonData = '{' +
                        ' "RETURN": "S",' +
                        ' "MESSAGE": "Success",' +
                        ' "AccountNumber": "A2044806"' +
                        ' }';            
        } else if (val.indexOf('/if055/') > -1) {
            jsonData =  '{ ' +
                        '    "ET_PE": [ ' +
                        '        { ' +
                        '           "PS_PSPID": "SIC-20054481-A0", ' +
                        '           "PS_POST1": "[삼성전자(주)] DS부문 중기 혁신 新제품>  2", ' +
                        '           "BANFN": "2000050885 [삼", ' +
                        '           "ZZ_EPEREQ": "[삼성전자(주)] DS부문 중기 혁신 新제품코드 전환(SI1)", ' +
                        '           "ZZ_ESTATU": "N", ' +
                        '           "VAL_TEXT": "Save" ' +
                        '        } ' +
                        '    ], ' +
                        '    "EV_STATUS": "1", ' +
                        '    "EV_MSGTY": "S", ' +
                        '    "EV_MSGTXT": "It is possible proceeding" ' +
                        '} ' ;
        } else if (val.indexOf('/if056/') > -1) {
            jsonData =  '{ ' +
                        '    "T_RTN": [ ' +
                        '        { ' +
                        '           "TYPE": "W", ' +
                        '           "ID": 0, ' +
                        '           "NUMBER": 398, ' +
                        '           "MESSAGE": "string", ' +
                        '           "LOG_NO": "string", ' +
                        '           "LOG_MSG_NO": 0, ' +
                        '           "MESSAGE_V1": "Entertainment Expense exceeded the limit.", ' +
                        '           "MESSAGE_V2": "string", ' +
                        '           "MESSAGE_V3": "SIC16320291A000", ' +
                        '           "MESSAGE_V4": "S002", ' +
                        '           "PARAMETER": "string", ' +
                        '           "ROW": 0, ' +
                        '           "FIELD": "string", ' +
                        '           "SYSTEM": "string" ' +
                        '        } ' +
                        '    ], ' +
                        '    "EV_VERSION": "S002", ' +
                        '    "EV_VNCRE": 0, ' +
                        '    "EV_RTNST": "S", ' +
                        '    "EV_HURDLERATE_OK": "X", ' +
                        '    "EV_CONTAPRO_OK": "S", ' +
                        '    "EV_EXTERN_ACT_ID": "string", ' +
                        '    "EV_PRESALE_LIMIT": "string", ' +
                        '    "EV_OUTCOME_YN": "string", ' +
                        '    "EV_OUTCOST_YN": "string", ' +
                        '    "EV_EXCEPT": "string", ' +
                        '    "EV_PRESALES_YN": "Y", ' +
                        '    "EV_OPERATING_INCOME": "string" ' +
                        '} ' ;
        } else if (val.indexOf('/if058/') > -1) {
            jsonData =  '{ ' +
                        '    "ET_MESSAGE": [ ' +
                        '    { ' +
                        '        "TYPE": "S", ' +
                        '        "ID": null, ' +
                        '        "NUMBER": "000", ' +
                        '        "MESSAGE": "SCC-18065191-C2-01-11Erasable WBS.", ' +
                        '        "LOG_NO": null, ' +
                        '        "LOG_MSG_NO": "000000", ' +
                        '        "MESSAGE_V1": null, ' +
                        '        "MESSAGE_V2": null, ' +
                        '        "MESSAGE_V3": null, ' +
                        '        "MESSAGE_V4": null, ' +
                        '        "PARAMETER": null, ' +
                        '        "ROW": "0", ' +
                        '        "FIELD": null, ' +
                        '        "SYSTEM": null ' +
                        '    }, ' +
                        '    { ' +
                        '        "TYPE": "E", ' +
                        '        "ID": null, ' +
                        '        "NUMBER": "000", ' +
                        '        "MESSAGE": "SCC-18065191-C2-01-21PE Activity Request data still exists. Proceed after deleting the data", ' +
                        '        "LOG_NO": null, ' +
                        '        "LOG_MSG_NO": "000000", ' +
                        '        "MESSAGE_V1": null, ' +
                        '        "MESSAGE_V2": null, ' +
                        '        "MESSAGE_V3": null, ' +
                        '        "MESSAGE_V4": null, ' +
                        '        "PARAMETER": null, ' +
                        '        "ROW": "0", ' +
                        '        "FIELD": null, ' +
                        '        "SYSTEM": null ' +
                        '    }, ' +
                        '    { ' +
                        '        "TYPE": "S", ' +
                        '        "ID": null, ' +
                        '        "NUMBER": "000", ' +
                        '        "MESSAGE": "SCC-18065191-C2-01-31Erasable WBS.", ' +
                        '        "LOG_NO": null, ' +
                        '        "LOG_MSG_NO": "000000", ' +
                        '        "MESSAGE_V1": null, ' +
                        '        "MESSAGE_V2": null, ' +
                        '        "MESSAGE_V3": null, ' +
                        '        "MESSAGE_V4": null, ' +
                        '        "PARAMETER": null, ' +
                        '        "ROW": "0", ' +
                        '        "FIELD": null, ' +
                        '        "SYSTEM": null ' +
                        '    } ' +
                        '    ] ' +
                        '}';
        } else if (val.indexOf('/if059/') > -1) {
            jsonData =  '{' +
                        '"EV_RTNST": "S" ' +
                        '}';
        } else if (val.indexOf('/if062/') > -1) {
            jsonData =  '{ ' +
                        '    "ET_MANAGER_INFO": [ ' +
                        '        { ' +
                        '           "EV_BUKRS": "T100", ' +
                        '           "EV_KOSTL": "T100-12371", ' +
                        '           "EV_LDEPT": "C60AJ760", ' +
                        '           "EV_STEXT": "BA Cell(Delivery혁신2)", ' +
                        '           "EV_MANAGER_KOSTL": "T100-12016", ' +
                        '           "EV_MANAGER_ORGEH": "C60AJ451", ' +
                        '           "EV_MANAGER_STEXT": "Delivery혁신2팀", ' +
                        '           "EV_MANAGER_NO": "00028325", ' +
                        '           "EV_MANAGER_HNAME": "엄태덕", ' +
                        '           "EV_UNIT_KOSTL": "T601-10004", ' +
                        '           "EV_UNIT_STEXT": "Group", ' +
                        '           "EV_SUBRC": "0", ' +
                        '           "EV_MSGTX": "null" ' +
                        '        } ' +
                        '    ] ' +
                        '} ' ;
        } else if (val.indexOf('/if063/') > -1) {
            jsonData =  '{ ' +
                        '    "CT_SOL": [ ' +
                        '    { ' +
                        '        "GUID": "0", ' +
                        '        "ZZORDER_ID": "SDS-20021960", ' +
                        '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        '        "NUMBER_INT": "10", ' +
                        '        "ZZSERVICE_CLASS": "20000012", ' +
                        '        "ZZSOLUTION": "30000028", ' +
                        '        "KSCHL_SOL": "", ' +
                        '        "ZZBUKRS_H": "T100", ' +
                        '        "COMPANY": "", ' +
                        '        "AERDAT": "2020.10.20", ' +
                        '        "SOLUTION_OWNER": "T100-11975", ' +
                        '        "SOLUTION_AMT": "0", ' +
                        '        "CURR": "", ' +
                        '        "SOLUTION_AMT_LOCAL": "0", ' +
                        '        "CURR_LOCAL": "", ' +
                        '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        '        "ZZSALES_CELL_L": "", ' +
                        '        "ZZDEVELOP_CELL_L": "", ' +
                        '        "SOLUTION_OWNER_L": "" ' +
                        '    }, ' +
                        '    { ' +
                        '        "GUID": "0", ' +
                        '        "ZZORDER_ID": "SDS-20021960", ' +
                        '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        '        "NUMBER_INT": "10", ' +
                        '        "ZZSERVICE_CLASS": "20000012", ' +
                        '        "ZZSOLUTION": "30000032", ' +
                        '        "KSCHL_SOL": "", ' +
                        '        "ZZBUKRS_H": "T100", ' +
                        '        "COMPANY": "", ' +
                        '        "AERDAT": "2020.10.20", ' +
                        '        "SOLUTION_OWNER": "T100-11975", ' +
                        '        "SOLUTION_AMT": "0", ' +
                        '        "CURR": "", ' +
                        '        "SOLUTION_AMT_LOCAL": "0", ' +
                        '        "CURR_LOCAL": "", ' +
                        '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        '        "ZZSALES_CELL_L": "", ' +
                        '        "ZZDEVELOP_CELL_L": "", ' +
                        '        "SOLUTION_OWNER_L": "" ' +
                        '    } ' +
                        '    ] ' +
                        '}';
        } else if (val.indexOf('/if067/') > -1) {
            jsonData =  '{' +
                        '"EV_RETURN": "N",' +
                        '"EV_RETMSG": "Project code doesn\'t exist."' +
                        '}';
        } else if (val.indexOf('/if071/') > -1){
            
            jsonData = '{ "result": "success", "data": [ { "invitedYn": null, "subject": "Test subject", "originalStartTime": null, "originalScheduleId": null, "priority": "5", "userId": "M201014060123C60971", "sendMailYn": null, "recurrence": null, "calendarId": "CALM201014060123C60971", "contentsType": null, "contents": "test contents", "authority": "ALL", "contentsCharset": "UTF-8", "allDayYn": "N", "place": null, "class_SFDC": "PRIVATE", "scheduleId": "SCH202012151132151425558352", "placeCode": null, "attendees": [ { "sourceType": "EMPLOYEE", "replyStatus": "ACCEPTED", "type": "CHAIR", "userId": "M201014060123C60971", "seq": "0" } ], "startTime": { "date_SFDC": null, "dateTime_SFDC": "2020-12-15T05:00:00+09:00", "timeZone": "Asia/Seoul" }, "endTime": { "date_SFDC": null, "dateTime_SFDC": "2021-01-30T06:00:00+09:00", "timeZone": "Asia/Seoul" } } ], "statusCode": "200" }';
        }else if (val.indexOf('/if071/') > -1){
            
            jsonData = '{   "result": "success",   "data": {     "result": "SUCCESS"   },   "statusCode": "200" }';
        }else if (val.indexOf('/if072/') > -1){
            
            jsonData = '{   "result": "success",   "data": {     "result": "SUCCESS"   },   "statusCode": "200" }';
        }else if (val.indexOf('/if073/') > -1){
            
            jsonData = '{   "result": "success",   "data": {     "invitedYn": null,     "subject": "1210 / 11:03 TEST",     "originalStartTime": null,     "originalScheduleId": null,     "priority": "5",     "userId": "M201014060123C60971",     "sendMailYn": null,     "recurrence": null,     "calendarId": "CALM201014060123C60971",     "contentsType": null,     "contents": null,     "authority": "ALL",     "contentsCharset": null,     "allDayYn": "N",     "place": null,     "class_SFDC": "PRIVATE",     "scheduleId": "SCH202012100357037601610252",     "placeCode": null,     "attendees": [       {         "sourceType": "EMPLOYEE",         "replyStatus": "ACCEPTED",         "type": "CHAIR",         "userId": "M201014060123C60971",         "seq": "0"       }     ],     "startTime": {       "date_SFDC": null,       "dateTime_SFDC": "2020-12-10T05:00:00+09:00",       "timeZone": "Asia/Seoul"     },     "endTime": {       "date_SFDC": null,       "dateTime_SFDC": "2020-12-10T06:00:00+09:00",       "timeZone": "Asia/Seoul"     }   },   "statusCode": "200" }';
        }else if (val.indexOf('/if074/') > -1){
            
            jsonData = '{   "result": "success",   "data": [     {       "defaultYn": "N",       "displayType": "VISIBLE",       "calendarId": "CAL202012090105406736306323",       "color": "#9b77c2",       "subject": "Salesforce",       "timezone": "Asia/Seoul",       "authority": "ALL",       "description": null,       "type": "NORMAL",       "userId": "M201014060123C60971",       "seq": "1"     },     {       "defaultYn": "Y",       "displayType": "VISIBLE",       "calendarId": "CALM201014060123C60971",       "color": "#ffc71b",       "subject": "기본 캘린더",       "timezone": "Asia/Seoul",       "authority": "ALL",       "description": null,       "type": "NORMAL",       "userId": "M201014060123C60971",       "seq": "0"     }   ],   "statusCode": "200" }';
        }else if (val.indexOf('/if075/') > -1){
            
            jsonData = ' {   "result": "success",   "mailId": "20201119012141nwcms1s165d85e91072731e41c8c805c0ad5dccb",   "sfdcId": "test",   "statusCode": "200" }';
        }else if (val.indexOf('/if076/') > -1){
            
            jsonData = ' { "result": "success", "statusCode": "200" } ';
        }else if (val.indexOf('/if077/') > -1){
            
            jsonData = ' { "result": "success", "data": [ { "apInfId": "SDSSFDC2020120917105916075014599", "docChgNum": "0", "status": "1" } ], "statusCode": "200", "errorDetail": { "url": null, "errorCode": null, "errorMessage": null, "detailMessages": null } }';
        }else if (val.indexOf('/if078/') > -1){
            
            jsonData = ' { "result": "success", "data": { "apInfId": "SDSSFDC2020121710344116081688819" }, "statusCode": "200" } ';
        }else if (val.indexOf('/if079/') > -1){
            jsonData = ' {"result": "success","data": {"apInfId": "test"},"statusCode": "200"} ';
        }else if (val.indexOf('/if090/') > -1) {
            jsonData =  '{ ' +
                        '    "EV_SAP_EMPNO": "00016241", ' +
                        '    "EV_ACUBE_ID": "C6016241", ' +
                        '    "EV_EMPNO": "16241", ' +
                        '    "EV_UNIQ_ID": "S020126190831C600013", ' +
                        '    "EV_HNAME": "김경남", ' +
                        '    "EV_ENAME": "KYUNGNAM KIM", ' +
                        '    "EV_COMPANY": "C60", ' +
                        '    "EV_SAP_BUKRS": "T100", ' +
                        '    "EV_COMPNM": "삼성SDS", ' +
                        '    "EV_JIKGUB": "B1J0", ' +
                        '    "EV_JIKGUBNM": "CL4(Principal Consul", ' +
                        '    "EV_TITLE_JIKCHAK_NM": "Principal Consultant", ' +
                        '    "EV_DEPT": "C60AJ760", ' +
                        '    "EV_SDEPTNM": "BA Cell(Delivery혁신2)", ' +
                        '    "EV_KOSTL": "T100-12371", ' +
                        '    "EV_CELL_TEL": "+82-10-5210-5750", ' +
                        '    "EV_COMP_TEL": "+82-10-5210-5750", ' +
                        '    "EV_SAP_USRID": "TERIUS.KIM", ' +
                        '    "EV_MAIL_ADDR": "terius.kim@samsung.com", ' +
                        '    "EV_STATUS": "1", ' +
                        '    "EV_MAIL_RELANGUAGE": "ko", ' +
                        '    "EV_COMPENM": "SAMSUNG SDS", ' +
                        '    "EV_SDEPTENM": "Data Analytics Delivery Group", ' +
                        '    "EV_TITLE_JIKCHAK_EN": "Principal Consultant", ' +
                        '    "EV_GSBER": "AT00", ' +
                        '    "EV_FLAG": "4" ' +
                        '}';                          
        } else if (val.indexOf('/if093/') > -1) {
            jsonData =  '{ ' +
                        '    "EV_RESULT": "S", ' +
                        '    "START_DATE": "2020.07.01", ' +
                        '    "FINISH_DATE": "2021.06.30", ' +
                        '    "TOTAMT": "357000", ' +
                        '    "TOTAMTK": "357000", ' +
                        '    "WAERS": "KRW", ' +
                        '    "KWAERS": "KRW", ' +
                        '    "ZZORDER_RATE": "1", ' +
                        '    "ZZORDER_RATE_LO": "1", ' +
                        '    "SGDAT": "2021-01-01", ' +
                        '    "CT_SOL": [ ' +
                        '    { ' +
                        '        "GUID": "0", ' +
                        '        "ZZORDER_ID": "SDS-20021960", ' +
                        '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        '        "NUMBER_INT": "10", ' +
                        '        "ZZSERVICE_CLASS": "20000012", ' +
                        '        "ZZSOLUTION": "30000028", ' +
                        '        "KSCHL_SOL": "", ' +
                        '        "ZZBUKRS_H": "T100", ' +
                        '        "COMPANY": "", ' +
                        '        "AERDAT": "2020.10.20", ' +
                        '        "SOLUTION_OWNER": "T100-11975", ' +
                        '        "SOLUTION_AMT": "0", ' +
                        '        "CURR": "", ' +
                        '        "SOLUTION_AMT_LOCAL": "0", ' +
                        '        "CURR_LOCAL": "", ' +
                        '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        '        "ZZSALES_CELL_L": "", ' +
                        '        "ZZDEVELOP_CELL_L": "", ' +
                        '        "SOLUTION_OWNER_L": "" ' +
                        '    }, ' +
                        '    { ' +
                        '        "GUID": "0", ' +
                        '        "ZZORDER_ID": "SDS-20021960", ' +
                        '        "DESCRIPTION": "[신세계건설(주)] 하남빌리브 344세대 도어록(DP740) 납품설치", ' +
                        '        "NUMBER_INT": "10", ' +
                        '        "ZZSERVICE_CLASS": "20000012", ' +
                        '        "ZZSOLUTION": "30000032", ' +
                        '        "KSCHL_SOL": "", ' +
                        '        "ZZBUKRS_H": "T100", ' +
                        '        "COMPANY": "", ' +
                        '        "AERDAT": "2020.10.20", ' +
                        '        "SOLUTION_OWNER": "T100-11975", ' +
                        '        "SOLUTION_AMT": "0", ' +
                        '        "CURR": "", ' +
                        '        "SOLUTION_AMT_LOCAL": "0", ' +
                        '        "CURR_LOCAL": "", ' +
                        '        "ZZSALES_CELL_NAM": "T100-11975", ' +
                        '        "ZZDEVELOP_CELL_N": "T100-11975", ' +
                        '        "ZZSALES_CELL_L": "", ' +
                        '        "ZZDEVELOP_CELL_L": "", ' +
                        '        "SOLUTION_OWNER_L": "" ' +
                        '    } ' +
                        '    ], ' +
                        '    "T_RESULT": [ ' +
                        '    { ' +
                        '       "SEQ": 0, ' +
                        '       "MSGTY": "", ' +
                        '       "MESSAGE": "" ' +
                        '    } ' +
                        '    ], ' +
                        '    "T_DATA": [ ' +
                        '    { ' +
                        '       "SEQ": 0, ' +
                        '       "MSGTY": "", ' +
                        '       "MESSAGE": "" ' +
                        '    } ' +
                        '    ] ' +                        
                        '}';
        } else if (val.indexOf('/if094/') > -1) {
            jsonData =  '{ ' +
                        '} ' ;                        
        } else if (val.indexOf('/if102/') > -1) {
            jsonData =  '{ ' +
                        '   "EV_EXIST": "X", ' +
                        '   "EV_BO_CHECK": "X", ' +
                        '   "EV_PJT_CHECK": "X" ' +
                        '}';                        
        } else if (val.indexOf('/if125/') > -1) {
            jsonData =  '{ ' +
                        '}';
        } else if (val.indexOf('/if126/') > -1){
            
            jsonData = ' { "StatusCode": "200", "ES_OUTPUT": { "msgty": "S", "message": null }, "IT_FACTOR": [ { "name": "BSNE_ESTIMATED_AMT","value": "0", "multi": null }, { "name": "BSNE_GRADE_CODE","value": "A", "multi": null }, { "name": "BSNE_PRSNT_EMP_NO","value": "29716", "multi": null }, { "name": "DELAY_YN", "value": "N", "multi": null }, { "name": "LONGDAYS_YN","value": "Y", "multi": null }, { "name": "MAIN_BSNE_DEPT_CODE","value": "C60AJ439", "multi": null }, { "name": "MAIN_SALE_DEPT_CODE","value": "C60AJ680", "multi": null }, { "name": "PJT_BSNE_DEPT_CODE","value": "C60AJ439", "multi": "X" }, { "name": "PROPOSAL_PM_EMP_NO","value": "29716", "multi": null }, { "name": "REDELAY_YN","value": null, "multi": null }, { "name": "SALES_COST_YN","value": "Y", "multi": null }, { "name": "SALE_STANDARD_LIMIT","value": "A", "multi": null }, { "name": "TELECOM_NW_PJT_YN","value": "N", "multi": null } ], "IT_PATHLIST": [ { "bukrs": "T100", "empno": "C6029716", "name": "최동권", "relclass": null, "seqno": "0000000000","wfsysno": null, "wistatus": "CR", "wrstatus": "CR", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6012354", "name": "김원만", "relclass": "3", "seqno": "0000000001","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6031379", "name": "이승준", "relclass": "1", "seqno": "0000000002","wfsysno": "2", "wistatus": "RD", "wrstatus": "AP", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6017093", "name": "허용석", "relclass": "2", "seqno": "0000000003","wfsysno": "2", "wistatus": "RD", "wrstatus": "AG", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6031404", "name": "안대중", "relclass": "1", "seqno": "0000000004","wfsysno": "2", "wistatus": "RD", "wrstatus": "AP", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6016171", "name": "김성기", "relclass": "3", "seqno": "0000000005","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6031367", "name": "김정민", "relclass": "3", "seqno": "0000000006","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6024352", "name": "이지현", "relclass": "3", "seqno": "0000000007","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6029588", "name": "김규종", "relclass": "3", "seqno": "0000000008","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6032658", "name": "최진욱", "relclass": "3", "seqno": "0000000009","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6031824", "name": "김준영", "relclass": "3", "seqno": "0000000010","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6019695", "name": "임해택", "relclass": "3", "seqno": "0000000011","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null }, { "bukrs": "T100", "empno": "C6016575", "name": "정제훈", "relclass": "3", "seqno": "0000000012","wfsysno": "2", "wistatus": "RD", "wrstatus": "NT", "ca_bukrs": null } ], "IT_HTML": [ { "LINE": null } ] } ';
        } else if (val.indexOf('/if127/') > -1) {
            jsonData =  '{ ' +
                        '}';                        
        } else if (val.indexOf('/if130/') > -1) {
            jsonData =  '{' + 
                        '  "IT_RETURN": {' + 
                        '    "SERV_CALL_RLSE_NO": "SF202103081541010078",' + 
                        '    "RET_SUCCS_CD": "Y",' + 
                        '    "CHECK_CD": "00000000000000000000",' + 
                        '    "RET_MSG": "SUCCESS"' + 
                        '  }' + 
                        '}';
        } else if (val.indexOf('/if131/') > -1) {
            jsonData =  '{ ' +

                        '}';                        
        } else if (val.indexOf('/if133/') > -1){
            
            jsonData = ' {"result": "success","data": {"contentsType": "HTML","sbmDt": 20201217041538,"sbmLang": "ko","apInfId": "SDSSFDC2020121713153516081785350","SystemID": null,"notifyOption": 0,"urgYn": "0","docSecuType": "PERSONAL","status": 1,"timeZone": "GMT","subject": "[Salesforce Approval] OPTY 9","aplns": [{"actPrssDt": 20201217041538,"docOpenDt": null,"docArvDt": 20201217041538,"opinion": null,"companyCode": "C60","companyName": "삼성SDS","subOrgCode": null,"subOrgName": null,"departmentCode": "C60AJ384","departmentName": "데이터분석실행그룹(Delivery혁신2)","epId": "M201014061334C60205","emailAddress": "dong00.kim@stage.partner.samsung.com","name": "김동영","titleCode": null,"titleName": null,"seq": 0,"role": 0,"aplnStatsCode": 0,"prxAprYn": "N","dlgAprEpid": null,"arbPmtYn": "N","arbActYn": "N","aplnMdfyPmtYn": "Y","aplnMdfyActYn": "N","contentsMdfyPmtYn": "N","contenstsMdfyActYn": null},{"actPrssDt": null,"docOpenDt": null,"docArvDt": 20201217041538,"opinion": null,"companyCode": "C60","companyName": "삼성SDS","subOrgCode": null,"subOrgName": null,"departmentCode": "C60AJ384","departmentName": "데이터분석실행그룹(Delivery혁신2)","epId": "M200810085139C603253","emailAddress": "yeoguri.kim@stage.partner.samsung.com","name": "김영훈","titleCode": null,"titleName": null,"seq": 1,"role": 1,"aplnStatsCode": 0,"prxAprYn": "N","dlgAprEpid": null,"arbPmtYn": "N","arbActYn": "N","aplnMdfyPmtYn": "Y","aplnMdfyActYn": "N","contentsMdfyPmtYn": "Y","contenstsMdfyActYn": null}]}} ';
        } else if (val.indexOf('/if134/') > -1) {
            jsonData =  /*'{ ' +
                        '   "Opportunity_ID": "SDS-20017820", ' +
                        '   "Version": "F001", ' +
                        // '   "STATU": "PROTECTION", ' +
                        '   "STATU": "A2", ' +
                        '   "ZCONF": "X", ' +
                        '   "Contract_Amt": "21928", ' +
                        '   "Operating_Profit": "1644(7.50%)", ' +
                        '   "Labor_MM": "380.5" ' +
                        '}';*/
                        '{' + 
                        ' "T_RESULT" : [ ' +
                            '{'+
                            '   "Opportunity_ID": "SDS-20017820", ' +
                            '   "Version": "F001", ' +
                            // '   "STATU": "PROTECTION", ' +
                            '   "STATU": "A2", ' +
                            '   "ZCONF": "X", ' +   
                            '   "Contract_Amt": "21928", ' +
                            '   "Operating_Profit": "1644(7.50%)", ' +
                            '   "Labor_MM": "380.5" ' +
                            '}'                       +
                            ']' +
                        '}';
        } else if (val.indexOf('/if135/') > -1) {
            jsonData =  '{ ' +
                        '   "EV_RESULT": "S", ' +
                        '   "EV_MESS": "Approval status updated successfully." ' +                        
                        '} ';
        } else if (val.indexOf('/if137/') > -1) {
            jsonData =  '{ ' +
                        '   "EV_RETURN": "S", ' +
                        '   "EV_MSG": "Auth transfered successfully." ' +                        
                        '} ';
        } else if (val.indexOf('/if184') > -1) {
            jsonData =  '{ ' +
                         '"TXP_Manpower_mySales" : ['+
                            '{'+
                				'"BO_CODE":"SDS-22001260",'+
                                '"Company_Code":"T100",'+
                                '"Proposal_PM":"12345",'+
                                '"PROPOSAL_PM_STATUS":"ASSGNREQ",'+
                                '"PROPOSAL_START_DATE":"2023-1-8",'+
                                '"PROPOSAL_END_DATE":"2023-12-31",'+
                                '"Exec_PM":"12345",'+
                                '"EXEC_PM_STATUS":"ASSGNEND",'+
                                '"EXEC_START_DATE":"2023-10-1",'+
                                '"EXEC_END_DATE":"2024-2-3",'+
                                '"A_PJT_YN":"Y",'+
                                '"C_PJT_YN":"Y"'+
                            '}'+
                			']'+
                        '} ';
        }
        else if (val.indexOf('/if190/getCalendars') > -1) {
            jsonData = '['+
                '{'+
                '"defaultYn": "Y",'+
                '"displayType": "VISIBLE",'+
                '"calendarId": "CALM230315081100C6N7454",'+
                '"color": "#ffc71b",'+
                '"subject": "Default Calendar",'+
                '"timezone": "Asia/Seoul",'+
                '"authority": "ALL",'+
                '"description": null,'+
                '"type": "NORMAL",'+
                '"userId": "M230315081100C6N7454",'+
                '"seq": "0"'+
                '}'+
                ']' ;
        }
        else if (val.indexOf('/if192/getSchedules') > -1) {
            jsonData = '['+
                '{'+
                '"invitedYn": null,'+
                '"scheduleId": "SCH202311020716542253050486",'+
                '"subject": "test",'+
                '"attendees": '+'['+
                '{'+
                '"sourceType": "EMPLOYEE",'+
                '"replyStatus": "ACCEPTED",'+
                '"type": "CHAIR",'+
                '"userId": "M230315081100C6N7454",'+
                '"seq": "0"'+
                '}'+
                ']'+
                '"originalStartTime": null,'+
                '"originalScheduleId": null,'+
                '"priority": null,'+
                '"userId": "M230315081100C6N7454",'+
                '"sendMailYn": null,'+
                '"recurrence": null,'+
                '"calendarId": "CAL202311020647098783247701",'+
                '"contentsType": null,'+
                '"contents": "Test Contents",'+
                '"authority": "ALL",'+
                '"startTime":'+ '{'+
                '"date": "2023-11-14",'+
                '"dateTime": null,'+
                '"timeZone": null'+
                '}'+
                '"contentsCharset": null,'+
                '"allDayYn": "Y",'+
                '"endTime":'+ '{'+
                '"date": "2023-11-14",'+
                '"dateTime": null,'+
                '"timeZone": null'+
                '}'+
                '"place": "Good",'+
                '"class": "PRIVATE",'+
                '"placeCode": null'+
                '}'+
                ']' ;
        }
        
        return jsonData;
    }
}