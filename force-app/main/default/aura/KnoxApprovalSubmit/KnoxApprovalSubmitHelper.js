/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-01   seonju.jin@dkbmc.com   Initial Version
 * 1.1	 2022-08-01   hyunhak.roh@dkbmc.com	 결재건 Delete 부분에 대해 케이스를 구분하는 param을 추가하고 해당 로그를 남김
 * 											 IF-079 response로 Error를 받는 경우 이외에는 삭제를 수행하지 않도록 수정
 * 1.2   2023-05-20   anish.jain@partner.samsung.com  Add Log for checking abnormal Knox Approval - MS 198
 * 1.3   2023-08-24   anish.jain@partner.samsung.com     Add Log for checking Knox Approval error (status is null) - MS 283
 * 1.4   2023-10-17   atul.k1@samsung.com         Mysales-318
 * 1.5   2023-11-08   vikrant.ks@samsung.com  Save attachment on mySales when raising bo review approval(Mysales-350)
 * 1.6   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
({
    /* Approver Type */
    CONST_APPROVAL : '1',           // 결재
    CONST_CONSENSUS : '2',          // 합의
    CONST_NOTIFICATION : '9',       // 통보
    CONST_PARALLEL_CONSENSUS : '4', // 병렬 합의
    CONST_PARALLEL_APPROVAL : '7',  // 병렬 결재

    MAX_FILE_SIZE: 7340032, /* 6 000 000 * 3/4 to account for base64 */

    /**   
    * @author       Jonggil.Kim
    * @description  Get Approval Info, Get User Mapping Employee Info
    * @param        component : Component
                    event : Event Property
    **/

   getData : function(component, event, type, isInit) {
    var recordId = component.get("v.record").Id;
    var action = component.get("c.initComponent");
    var _this = this;
    console.log('AJ entry');
    // Spinner 해제
    _this.spinnerToggle(component, event);
    action.setParams({
        'recordId': recordId,
        'temp' : type,
        'isInit' : isInit,
        'opptyactId' : component.get('v.opptyactId')
    });

    // Controller에서 Return받은 Approval 정보를 사용하여 Component에 보여주기 위하여 데이터 셋팅
   console.log('Knox initComponent');
   console.time();
    action.setCallback(this, function(response) {
        var device = $A.get("$Browser.formFactor");
        // [S] Mobile 사용 불가능
        if(device == "PHONE" || device == "IPHONE"){
            console.log('AJ entry');
            alert($A.get("$Label.c.COMM_MSG_0004"));  
            $A.get("e.force:closeQuickAction").fire();
        }
        // [E] Mobile 사용 불가능

        var state = response.getState(); 
          console.timeEnd();
         console.log('# getData.state : ', state);
        if (state === "SUCCESS") {                
            var result = response.getReturnValue(); 
            component.set('v.isAdminProfile', result.isAdminProfile);
            component.set('v.userLang', result.CurrentUserlang);  //<!--V 1.4 Mysales-318-->
             console.log('# getData.isAdminProfile : ', result.isAdminProfile);
           // console.log('# getData.currentLang : ', result.CurrentUserlang);

            if(!result.IsEdit){
                console.log('AJ entry1');
                _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0019'), 10000);  //결재 권한이 없습니다. 소유자 혹은 관리자에게 문의하여 주세요.
            } else{
                /* if(result.isApproval){   // (2021-01-05 수정) Oppty Record Approval.Lock 상태여도 상신 가능
                    _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0015'), 10000);   //'이미 진행중인 결재가 있습니다.'
                    _this.spinnerToggle(component, event);      
                    return;
                } */
                
                /* if(!result.UserKnoxInfo.EvUniqID__c){    //20210630 seonju.jin approvalLine component에서 체크하도록 수정
                    _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0008'), 10000);  //'User EPID가 없습니다.'
                    _this.spinnerToggle(component, event);      
                    return;
                } */

                // Record Name 설정
                console.log('AJ entry2');
                var objRecordName = component.get("v.record").Name;
                var sobjecttype = component.get("v.sobjecttype");
                var templateOptions = component.get('v.templateOptions');
                if('Contract' == sobjecttype) {
                    objRecordName = component.get("v.record").ContractNumber;
                }
                
                // 내용 채워주기                
                var EmployeeList = [];
                var FileList = [];
                var newData = true;

                //임시저장 변수
                var temp_approverList = [];

                var oldindex = 0;
                var approverList =[];
                var data = result.knoxApproval;
                console.log('================data==============');
                // console.log(data);
                var temp_desc = data.Description__c ? data.Description__c : result.Description;
                var temp_opin = data.Opinion__c ? data.Opinion__c : result.Opinion__c;
                
                //2021/02/04 Title 명추가
                var activityLabel = '';
                var activityCode = '';
                var actLostType = '';
                if(result.actTransactionLabel){
                     activityLabel = result.actTransactionLabel;
                    component.set('v.actTransactionLabel',activityLabel);// V 1.1 Mysales-318
                }
                if(result.actLostType) actLostType = result.actLostType;
                if(result.actTransactionCode){
                    component.set('v.actTransactionCode', result.actTransactionCode);
                    activityCode = result.actTransactionCode;
                } 
                console.log('data.Name:'+ data.Name + ', objRecordName' + objRecordName + ', activityCode : '+activityCode);
                var temp_name = '';
                if(activityCode == 'ZPZ2' || activityCode == 'ZPZ1'){
                    console.log('AJ entry3');
                    temp_name = '[' + actLostType + '] ';    //' [' + activityLabel + ']' : length 20
                    //Name Field LengthLimit 80에 맞춰 substring
                    //2022/08/04 knox결재 제목 길이 변경
                    //   - BO Name 57자 이하 : 그대로 가져옴
                    //   - BO Name 58자 이상 : 57자까지만 가져오고 뒤에 '...' 붙임 
                    temp_name += data.Name ? data.Name : objRecordName;
                    if(temp_name.length > 80){
                        temp_name = temp_name.substring(0, 76)+'...';
                    }
                }else{
                    temp_name = data.Name ? data.Name : objRecordName;
                    temp_name += ' [' + activityLabel + ']';    //' [' + activityLabel + ']' : length 20
                    //Name Field LengthLimit 80에 맞춰 substring
                    //2022/08/04 knox결재 제목 길이 변경
                    //   - BO Name 57자 이하 : 그대로 가져옴
                    //   - BO Name 58자 이상 : 57자까지만 가져오고 뒤에 '...' 붙임 
                    if(temp_name.length > 80){
                        var n = temp_name.length - 76;
                        temp_name = data.Name ? data.Name : objRecordName;
                        temp_name = temp_name.substring(0, temp_name.length - n)+'...';
                        temp_name += ' [' + activityLabel + ']';    //' [' + activityLabel + ']' : length 20
                    }
                    
                    
                }
                
                // 결재자 리스트 반환
                for(var i=0; i < result.knoxApprover.length; i++){
                    let data = result.knoxApprover[i];
                    var apporver = {
                        'Index__c'              : data.Index__c,
                        'Name'                  : data.Name,
                        'EvEName__c'            : data.EvEName__c,
                        'ApproverType__c'       : data.ApproverType__c,
                        'EvSdeptNM__c'          : data.EvSdeptNM__c,
                        'EnEvSdeptNM__c'        : data.EnEvSdeptNM__c,
                        'EvMailAddr__c'         : data.EvMailAddr__c,
                        'Employee__c'           : data.Employee__c,
                        'EvUniqID__c'           : data.EvUniqID__c,                            
                        'IsChangeLine__c'       : data.IsChangeLine__c,
                        'IsEditText__c'         : data.IsEditText__c,
                        'IsArbitraryDecision__c': data.IsArbitraryDecision__c,
                        'IsGetApprovalLine__c'  : data.IsGetApprovalLine__c,
                        'Status__c'             : data.Status__c
                    };
                    temp_approverList.push(apporver);                       
                    
                    if(oldindex != data.Index__c ){
                        EmployeeList.push(approverList);
                        approverList =[];
                        oldindex = data.Index__c;
                        
                    }   

                    approverList.push(apporver);
                    
                    if(i == result.knoxApprover.length-1){
                        EmployeeList.push(approverList);
                    }
                }
                
        
                    var ApprovalData = {
                        'KnoxApproval' : {
                            'Id' : '',
                            'Name' : temp_name,
                            'ApprovedId__c' : recordId,
                            'Description__c' : temp_desc,
                            'Opinion__c' : temp_opin,
                            'LossReason__c' : '',
                            'TemplateName__c' : data.TemplateName__c,
                            'Template__c' : data.Template__c,
                            'HTML__c' : temp_desc,
                            'OpportunityActivity__c' : component.get('v.opptyactId'),
                            'Opportunity__c' : component.get('v.opptyId'),
                            'RequestBusinessLevel__c' : component.get('v.requestBusinessLevel'),
                            'BizReview__c' : component.get('v.bizReviewId')
                            },                
                        'ApproverList' : temp_approverList
                    }; 
                    console.log('2223123123123131213123');
                    if(result.FileList){
                        FileList = result.FileList;
                    }

                    if(data.TemplateName__c){
                        component.set('v.templateOptionValue', data.TemplateName__c);
                        
                    }
                    console.log('FileListtest', FileList);
                    // console.log('ApprovalData', ApprovalData);
                    // console.log('EmployeeList', EmployeeList);
                    
                    component.set('v.newData', newData);
                    component.set('v.ApprovalData', ApprovalData);
                    component.set('v.FileList', FileList);
                    component.set('v.UserKnoxInfo', result.UserKnoxInfo.EvUniqID__c);
                    // component.set('v.EmployeeList', EmployeeList);
                    
                    if(isInit){
                        templateOptions = templateOptions.concat(result.TemplateList);
                        component.set('v.templateOptions', templateOptions);
                    }                    

                    if(result.isTemp){
                        _this.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS'), $A.get('$Label.c.APPR_MSG_0009'), 10000);  
                        // _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0009'), 'success', 10000);//'임시저장 데이터를 불러왔습니다.'  
                    }
                }

            } else {
                _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'),'[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001'), 10000);  
                // _this.callToast(component, true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001'), 'error', 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
            }
            // Spinner 해제
            _this.spinnerToggle(component, event);      
        });
        $A.enqueueAction(action);
    },
    
    /**   
    * @author       Jonggil.Kim
    * @description  Request Approve to Knox
    * @param        component : Component
                    event : Event Property
    **/
	requestApprove : function(component, event) {
		var _this = this;
        var ApprovalData = component.get('v.ApprovalData');
        var employeeList = component.get('v.EmployeeList');
        var UserKnoxInfo = component.get('v.UserKnoxInfo');
        var tempalteName = component.get('v.templateOptionValue');
         console.log('==========ApprovalData============');
        // console.log(ApprovalData);

        var approvalHTML = component.get('v.approvalHTML');
        var approvalMISID = component.get('v.approvalMISID');
        // console.log('approvalMISID:' + approvalMISID);
        var approvalTypeCode = component.get('v.approvalTypeCode');
        var requestBusinessLevel = component.get('v.requestBusinessLevel');
        
        
        var fList = component.get('v.FileList'); 
        // Spinner 생성
        _this.spinnerToggle(component, event);
        
        
        var approverList =[];
        var ApprConsCount = 0;
       
        for(var i=0; i < employeeList.length; i++){
            console.log('# state mean');
            for(var j=0; j < employeeList[i].length; j++){
                console.log('# state ');
                var emp = employeeList[i][j];
                if(UserKnoxInfo == employeeList[i][j].EvUniqID__c){
                    _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0010'), 10000);  //'중복된 임직원이 있습니다.'
                    // _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0010'), 'error', 10000);
                    _this.spinnerToggle(component, event);
                    return;
                }
                if(_this.CONST_NOTIFICATION != emp.ApproverType__c){
                    ApprConsCount++;
                }
                if(employeeList[i].length > 1){
                    if(emp.ApproverType__c == _this.CONST_APPROVAL){
                        emp.ApproverType__c = _this.CONST_PARALLEL_APPROVAL;
                    }else{
                        emp.ApproverType__c = _this.CONST_PARALLEL_CONSENSUS;
                    }
                }
                var apporver = _this.makeApprover(i+1, emp);               
                approverList.push(apporver);      
            }
        }
        var totalFileSize = 0;

        for(var i=0; i < fList.length; i++){
            totalFileSize += parseInt(fList[i].fileSize);
            //console.log('fList[i].fileSize :' + i + ' , ', fList[i].fileSize+' File: '+fList[i].file+' fileContents: '+fList[i].fileContents);
            console.log('fList[i].fileSize :' + i + ' , ', fList[i].fileSize);
        }
        
		//this.uploadFiles(component,fList);//V1.5
        // File 개수 제한
        // if(1 < fList.length){
        //     _this.callToast(component, false,  $A.get('$Label.c.FILE_MSG_0001'), 'error', 5000);//파일 첨부는 10개까지 가능합니다.
        //     _this.spinnerToggle(component, event);    
        //     return;  
        // }

        // if(this.MAX_FILE_SIZE < totalFileSize){
        //     _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0018'), 10000); //'총 File 크기는 7MB를 넘길 수 없습니다.'
        //     // _this.callToast(component, false,  $A.get('$Label.c.APPR_MSG_0018'), 'error', 10000);
        //     _this.spinnerToggle(component, event);    
        //     return;
        // }

        if(!ApprConsCount){
            console.log('# state fine ');
            _this.spinnerToggle(component, event);
            _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0013'), 10000); //'결재자와 합의자가 없습니다.'
            // _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0013'), 'error', 10000);
            return;
        }else{
            console.log('# state entry ');
            ApprovalData.ApproverList = approverList;            
            ApprovalData.KnoxApproval.TemplateName__c = tempalteName;;
            var action_del = component.get("c.deleteApproval"); 
            let _action = component.get("c.insertApproval");
            console.log('# state entry1 ');
            var action_log = component.get("c.createInterfaceLog");  //Added by Anish - v 1.3 
            console.log('# state entry2 ');
            ApprovalData.KnoxApproval.WFOBJECT__c = approvalTypeCode;   // 결재 유형 코드 Setting
            ApprovalData.KnoxApproval.RequestBusinessLevel__c = requestBusinessLevel;    // 요청 사업 등급 Setting
            ApprovalData.KnoxApproval.MISID__c = approvalMISID;         // MISID setting
             console.log('# requestBusinessLevel', requestBusinessLevel);

            // console.log('# ApprovalData.KnoxApproval', JSON.parse(JSON.stringify(ApprovalData.KnoxApproval)));

            component.set('v.isApexLoading', true);

            var knoxApprovalApexLoadingEvt = $A.get("e.c:knoxApprovalApexLoadingEvent");
            knoxApprovalApexLoadingEvt.setParams({
                'isApexLoading' : true
            });
            knoxApprovalApexLoadingEvt.fire();
            
            _action.setParams({
                'approval' : ApprovalData.KnoxApproval,
                'opptyactId' : component.get('v.opptyactId') //Added by Anish - v 1.2
            });
            _action.setCallback(this, function(_response) {
                var _state = _response.getState();
            console.log('Entered Insert function successfully2');
                //Start - Added by Anish - v 1.3
                var action_log_on = component.get("c.createInterfaceLog"); 
                action_log_on.setParams({
                'apexMethod' : 'insertApproval',  
                'logMessage' : 'Entered Insert function successfully,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_on);
                //End - Added by Anish - v 1.3
                
                if (_state === "SUCCESS") {
                  console.log('Entered Insert function successfully1');  
                 //Start - Added by Anish - v 1.3
                action_log.setParams({
                'apexMethod' : 'insertApproval',  
                'logMessage' : 'Knox Record Inserted successfully,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                    $A.enqueueAction(action_log);
                //End - Added by Anish - v 1.3
                
                    var _result = _response.getReturnValue(); 
                
                        var tempApp_ = ApprovalData.KnoxApproval;
                   
                        ApprovalData.KnoxApproval = _result;
                        //Divyam v 1.5
                    var knoxapporovalid = _result.Id;
                    if(knoxapporovalid != null && knoxapporovalid != undefined && knoxapporovalid != ''){
                        component.set('v.fileUploadKnoxId',knoxapporovalid);
                    }
                        var oppactivityname = _result.OpportunityActivity__r.TransactionName__c;
                    console.log('knoxapporovalid',_result.Id);
                   console.log('oppactivitystatus',_result.OpportunityActivity__r.TransactionName__c);
                              if(oppactivityname == 'ZP21'){
                      this.uplaodfileafrerinsert(component,knoxapporovalid);
                      //this.upfile(component,knoxapporovalid);
                    }
                    //action_del.setParams({'approvalId' : ApprovalData.KnoxApproval.Id}); 

                    //approvalHTML = '<html><head></head><body>QATEST</body></html>';
                   let action = component.get("c.requestApproval"); 
                   let action_params = {
                        'jsonParam' : JSON.stringify(ApprovalData),
                        'fileList' : fList,
                        'tempalteName' : tempalteName,
                        'approvalHTML' : approvalHTML,
                        'isSuccessCollaboValid' : component.get('v.isSuccessCollaboValid'),
                        'collaboApprovalTypeCode' : component.get('v.collaboApprovalTypeCode'),
                        'opptyactId' : component.get('v.opptyactId') //Added by Anish - v 1.2
                    };
                    var jsonstr = JSON.stringify(action_params);
                    console.log('# requestApproval.action_params', action_params);
                    //console.log('# requestApproval.jsonstr', jsonstr);
                    console.log('# requestApproval.jsonstr length', jsonstr.length);

                   action.setParams(action_params); 
                    console.log('Knox requestApproval');
                    console.time();
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                  //Start - Added by Anish - v 1.3
                  var action_log_onn = component.get("c.createInterfaceLog");
                action_log_onn.setParams({
                'apexMethod' : 'requestApproval',  
                'logMessage' : 'Entered Request Approval Function successfully,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_onn);
                  //End - Added by Anish - v 1.3
                        console.log(response);
                        console.log('# request action response', JSON.stringify(response));
                        console.log('# state ', state);
                       console.timeEnd(); 
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue(); 
                            
                  //Start - Added by Anish - v 1.3
                  console.log('# state Ani ');
                 var action_log_one = component.get("c.createInterfaceLog"); 
                action_log_one.setParams({
                'apexMethod' : 'requestApproval',  
                'logMessage' : 'Request Approval Function Finished Successfully,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_one);
                  //End - Added by Anish - v 1.3

                            console.log('# result ', result);
                            console.log('# result RESULT ', result.RESULT);
                            console.log('# result Message ', result.Message);
                            // 상신 결과
                           if(result.RESULT == 'success' || result.RESULT == 'tempsave'){
                      
                                
                //Start - Added by Anish - v 1.3
                console.log('# state Anish');
                var action_log_two = component.get("c.createInterfaceLog");
                action_log_two.setParams({
                'apexMethod' : 'requestApproval',  
                'logMessage' : 'Request Approval called successfully with (IF-079 Success) response,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_two);
                  //End - Added by Anish - v 1.3
                                $A.get('e.force:refreshView').fire();
                                var toastMsg = (result.RESULT == 'success') ? $A.get('$Label.c.APPR_MSG_0011') :  $A.get('$Label.c.APPR_MSG_0033');
                                _this.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS'), toastMsg, 10000);     //"결재 상신 하였습니다.",
                                _this.spinnerToggle(component, event); // Spinner 해제

                                // Update OpportunityActivity Event
                                var opportunityActivityUpdateEvent = component.getEvent("opportunityActivityUpdateEvent");
                                opportunityActivityUpdateEvent.setParams({ 'status' : 'In Progress' });
                                opportunityActivityUpdateEvent.fire();

                                //  닫기 
                                component.find('overlayLib').notifyClose();
                                
                            }else{
                                
                 //Start - Added by Anish - v 1.3
                 var action_log_three = component.get("c.createInterfaceLog"); 
                action_log_three.setParams({
                'apexMethod' : 'requestApproval',  
                'logMessage' : 'Request Approval called successfully with (IF-079 Failed) response,',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_three);
                  //End - Added by Anish - v 1.3
                                _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR')+ '.requestApproval Error', $A.get('$Label.c.APPR_MSG_0012') + ' : ' + result.Message, 10000); //'결재 상신이 실패하였습니다. 잠시 후 다시 시도해주세요.'
                                // _this.tempSave(component, event, action_del); // 임시저장 
                                _this.spinnerToggle(component, event); // Spinner 해제

                                //2022-08-01, hyunhak.roh@dkbmc.com, IF-079 response로 Error를 받는 경우 이외에는 삭제를 수행하지 않도록 수정
                                action_del.setParams({'approvalId' : ApprovalData.KnoxApproval.Id,
                                                      'deleteFlag' : 'IF079_ERROR'
                                                     });
                                $A.enqueueAction(action_del);      // 저장데이터 삭제  
                                
                  //Start - Added by Anish - v 1.3
                  var action_log_four = component.get("c.createInterfaceLog");
                action_log_four.setParams({
                'apexMethod' : 'deleteApproval',  
                'logMessage' : 'Request Approval Deleted Successfully after (IF-079 Failed) response',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                                
                $A.enqueueAction(action_log_four);
                  //End - Added by Anish - v 1.3
                            }

                        } else if (state === "ERROR") {
                            
                  //Start - Added by Anish - v 1.3
                var action_log_five = component.get("c.createInterfaceLog"); 
                action_log_five.setParams({
                'apexMethod' : 'requestApproval',  
                'logMessage' : 'Request Approval Function got failed',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_five);
                  //End - Added by Anish - v 1.3
                            
                            // Process error returned by server
                            let requestApprovalErrors = response.getError();
                            let message = 'Unknown error'; // Default error message
                            // Retrieve the error message sent by the server
                            if (requestApprovalErrors && Array.isArray(requestApprovalErrors) && requestApprovalErrors.length > 0) {
                                message = requestApprovalErrors[0].message;
                            }
                            console.error('# requestApprovalErrors.message : ', message);
                            
							//2022-08-01, hyunhak.roh@dkbmc.com, 결재건 Delete 부분에 대해 케이스를 구분하는 param을 추가하고 해당 로그를 남김
							action_del.setParams({'approvalId' : ApprovalData.KnoxApproval.Id,
                                                  'deleteFlag' : 'NETWORK_ERROR'
                                                 });
                            $A.enqueueAction(action_del);
                            
                  //Start - Added by Anish - v 1.3
                  var action_log_six = component.get("c.createInterfaceLog"); 
                action_log_six.setParams({
                'apexMethod' : 'deleteApproval',  
                'logMessage' : 'Approval Delete got called after NETWORK_ERROR',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
               $A.enqueueAction(action_log_six);
                  //End - Added by Anish - v 1.3
                            _this.showToast(component, 'error', 'sticky', 'requestApproval state ' + $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.COMM_MSG_0001') + ' : ' +message, 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.       
                            _this.spinnerToggle(component, event);

                        } else {
                            //2022-08-01, hyunhak.roh@dkbmc.com, IF-079 response로 Error를 받는 경우 이외에는 삭제를 수행하지 않도록 수정
                            action_del.setParams({'approvalId' : ApprovalData.KnoxApproval.Id,
                                                  'deleteFlag' : 'ETC_ERROR'
                                                 });
                            $A.enqueueAction(action_del);  
                            
                //Start - Added by Anish - v 1.3
                var action_log_seven = component.get("c.createInterfaceLog");  
                action_log_seven.setParams({
                'apexMethod' : 'deleteApproval',  
                'logMessage' : 'Approval Delete got called after ETC_ERROR',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_seven);
                  //End - Added by Anish - v 1.3
                  
                            _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.COMM_MSG_0001'), 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                            // _this.callToast(component,true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001'), 'error', 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                            
                            // Spinner 해제
                            _this.spinnerToggle(component, event);
                        }                            
                    });
                    
                    $A.enqueueAction(action);
                                        
                } else {
                    // console.log('_state', _state);
                    if (_state === "ERROR") {
                        var errors = _response.getError();
                        
                 //Start - Added by Anish - v 1.3
                 var action_log_eight = component.get("c.createInterfaceLog");
                action_log_eight.setParams({
                'apexMethod' : 'insertApproval',  
                'logMessage' : 'Approval Insert got failed',
                'statusCode' : 'S',
                'oppId' : component.get('v.opptyactId')
                });
                $A.enqueueAction(action_log_eight);
                  //End - Added by Anish - v 1.3
                    
                        _this.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001')+ ' [insert Approval Error]' + errors, 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                        // _this.callToast(true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001')+ ' [insert Approval Error]' + errors, 'error', 10000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                        console.error('# insert Errors : ', errors);
                    }
                    // Spinner 해제
                    _this.spinnerToggle(component, event);
                    //2022-08-01, hyunhak.roh@dkbmc.com, IF-079 response로 Error를 받는 경우 이외에는 삭제를 수행하지 않도록 수정
                    //$A.enqueueAction(action_del);
                }
                component.set('v.isApexLoading', false);
                knoxApprovalApexLoadingEvt.setParams({
                    'isApexLoading' : false
                });
                knoxApprovalApexLoadingEvt.fire();
            });
            
            $A.enqueueAction(_action);
        } 
    },

 /**
    * @author       Jonggil.kim
    * @description  Temp save
    * @param        
    * @return       Boolean true/false
    **/
    makeApprover : function(idx, emp){
        return {
            'Index__c'              : idx,
            'Name'                  : emp.Name,
            'EvEName__c'            : emp.EvEName__c,
            'ApproverType__c'       : emp.ApproverType__c,
            'EvSdeptNM__c'          : emp.EvSdeptNM__c,
            'EvSdeptENM__c'         : emp.EvSdeptENM__c,
            'EvMailAddr__c'         : emp.EvMailAddr__c,
            'Employee__c'           : emp.Employee__c,
            'EvUniqID__c'           : emp.EvUniqID__c,
            'IsChangeLine__c'       : emp.IsChangeLine__c,
            'IsEditText__c'         : emp.IsEditText__c,
            'IsArbitraryDecision__c': emp.IsArbitraryDecision__c,
            'IsGetApprovalLine__c'  : emp.IsGetApprovalLine__c,
            'Status__c'             : '0'
        };
    },

    tempSave : function(component, event, action_del){
        // console.log('TempSave ############################');
        var ApprovalData = component.get('v.ApprovalData');
        var employeeList = component.get('v.EmployeeList');
        ApprovalData.KnoxApproval.TemplateName__c = component.get('v.templateOptionValue');
        // console.log(component.get('v.templateOptionValue'));
        // console.log(ApprovalData.KnoxApproval);
        // console.log(ApprovalData.KnoxApproval.TemplateName__c);
        var fList = component.get('v.FileList'); 
        var _this = this;
        _this.spinnerToggle(component, event);
        var tempList = [];
        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){     
                var apporver = _this.makeApprover(i+1, employeeList[i][j]);             
                tempList.push(apporver);      
            }
        }   
        
        ApprovalData.ApproverList = tempList;
        var action = component.get("c.tempSaveApproval");   
        // console.log('File List   :',fList);        
        action.setParams({
            'opptyactId' : component.get('v.opptyactId'),
            'recordId' : component.get("v.record").Id,
            'jsonParam' : JSON.stringify(ApprovalData),
            'fileList' : fList
        });

         action.setCallback(this, function(response) {
            var state = response.getState();
            console.timeEnd();  
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                // console.log(result);
            }             
            // Spinner 해제
            _this.spinnerToggle(component, event);
            _this.showToast(component, 'success', 'dismissible', $A.get('$Label.c.COMM_LAB_SUCCESS'), $A.get('$Label.c.APPR_MSG_0014'), 10000);  //'임시저장 하였습니다.'
            // _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0014'), 'success', 10000);//'임시저장 하였습니다.'
            
            if(action_del) $A.enqueueAction(action_del);
        });
		$A.enqueueAction(action);
    },
    
    /**
    * @author       Jonggil.Kim
    * @description  Spinner Toggle Action 
    * @param        
    * @return       Boolean true/false
	**/
    spinnerToggle : function(component, event){
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }, 
    
    /**
    * @author       Jonggil.Kim
    * @description  alertToast Action 
    * @param        component : Component
    *               isCloseModal : Close with Modal (Boolean)
    *               toastType : ‘success’, ‘error’
    *               toastMsg : Toast Message
    *               toastSecond : Alert Time
    **/
    alertToast : function(component, isCloseModal, toastType, toastMsg, toastSecond){
        component.set('v.toastMessage', toastMsg);
        this.toastToggle(component, isCloseModal, toastType);
        if(isCloseModal) this.timeOutCloseModal(component, toastSecond);
        else this.timeOutCloseToast(component, isCloseModal, toastSecond, toastType);
    }, 
    
    /**
    * @author       Jonggil.Kim
    * @description  Toast Toggle Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				toastType : 'success', 'error'
	**/
    toastToggle : function(component, isCloseModal, toastType){
        component.set('v.isCloseModal', isCloseModal);
        component.set('v.toastType', toastType);
        $A.util.toggleClass(component.find(toastType+'-toast'), 'slds-hide');
        if(isCloseModal) $A.util.toggleClass(component.find('body'), 'slds-hide');
    },
    
    /**
    * @author       Jonggil.Kim
    * @description  Toast Close Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				time : Alert Time
    * 				toastType : 'success', 'error'
	**/
    timeOutCloseToast : function(component, isCloseModal, time, toastType){
        window.setTimeout(
            $A.getCallback(function() {
                if(isCloseModal) $A.util.removeClass(component.find('body'), 'slds-hide');
                $A.util.addClass(component.find(toastType+'-toast'), 'slds-hide');
            }), time
        );
    },
    
    /**
    * @author       Jonggil.Kim
    * @description  Toast Close with Modal Action
    * @param        component : Component
    * 				time : Alert Time
	**/
    timeOutCloseModal : function(component, time){ 
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), time
        );
    }

    , callToast : function(component, isClose, message, type, duration){ 
        var toast = { 'isClose'      : isClose
                     , 'type'         : type
                     , 'message_type' : type
                     , 'message'      : message
                     , 'duration'     : duration 
                    };
        component.set('v.toast',toast);

        if(type =='error'){
            var spinner = component.find('spinner');
            $A.util.addClass(spinner, 'slds-hide');
        }
                
    }

    , changeTemplate : function(component, event){        
        var selectedOptionValue = event.getParam("value");
        component.set('v.templateOptionValue', selectedOptionValue);

        this.getData(component, event, selectedOptionValue, false);
    }
    
    , getApprovalLine : function(component, event){        
        // console.log('💥 getApprovalLine');
        component.set('v.isCompletedGetApproval', true);
        var opptyId = component.get('v.opptyId');
        var opptyactId = component.get('v.opptyactId');

        var approvalLineGetEvent = $A.get("e.c:approvalLineGetEvent");
        // console.log('# opptyId', opptyId);
        // console.log('# opptyactId', opptyactId);

        if(opptyId && opptyactId){
            approvalLineGetEvent.fire();
        }
    }
    
    , setApprovalLine : function(component, event){
         console.log('💥 setApprovalLine');
        // console.log('get[misid check]' + component.get('v.approvalMISID'));
        // console.log('=== setApprovalLine # event.getParams()', event.getParams());
        var isCompletedGetApproval = component.get("v.isCompletedGetApproval");   // 결재선 가져오기 여부
        var isSuccessGetApproval    = event.getParam("isSuccess"); // 사전점검 or 결재선 성공 여부
        var useApprovalLine     = event.getParam("useApprovalLine");
        var approvalTypeCode    = event.getParam("approvalTypeCode");
        var isRequiredCollaboValid = event.getParam("isRequiredCollaboValid");
        
        var MinusProfit = event.getParam("Minus_Profit"); // V 1.1 Mysales-318
        //alert('isSuccess'+isSuccessGetApproval);
        //alert('MinusProfit=='+MinusProfit); //Atul

        component.set('v.useApprovalLine', useApprovalLine); // 결재선 사용여부
        component.set('v.approvalTypeCode', approvalTypeCode); // 결재유형 코드
        component.set('v.isSuccessGetApproval', isSuccessGetApproval);
        component.set('v.MinusProfitVal', MinusProfit); // V 1.1 Mysales-318
        

        // [협업 BO 최초 수주품의 Activity 제어] 협업 BO 사전 점검 변수 저장
        if(isRequiredCollaboValid) {   
            console.log(' evt Param.collaboApprovalTypeCodeAni :');
            var isSuccessCollaboValid = event.getParam("isSuccessCollaboValid");
            var collaboApprovalTypeCode = event.getParam("collaboApprovalTypeCode");
            component.set('v.isSuccessCollaboValid', isSuccessCollaboValid);
            if(isSuccessCollaboValid) {
                component.set('v.collaboApprovalTypeCode', collaboApprovalTypeCode)
            }
        }

        if(!isCompletedGetApproval) {
            console.log(' evt Param.collaboApprovalTypeCodeAni1 :');
            if(useApprovalLine && isSuccessGetApproval) { 
                 console.log(' evt Param.collaboApprovalTypeCodeAni2 :');
                var approvalLineList = event.getParam("approvalLineList"); // 결재선 임직원 리스트
                console.log(' evt Param.collaboApprovalTypeCodeAni5# :');
                // var approvalHTML = event.getParam("approvalHTML");   // 결재본문            
                console.log(' evt Param.collaboApprovalTypeCodeAni2# :', approvalLineList);
                console.log(' evt Param.collaboApprovalTypeCodeAni2# :', approvalLineList.length);
                var employeeList = component.get('v.EmployeeList');
                var approverList = []; // 2차원 배열
                // 결재선을 상단에 추가

                //20210618 병렬합의, 병령결재 처리 추가 - seonju.jin@dkbmc.com
                if(approvalLineList.length>0) { //Added by Anish-v 1.6
                     //console.log(' evt Param.collaboApprovalTypeCodeAni3 :');
                    var nextIndex__c = -1;
                    for(var i=0; i < approvalLineList.length; i++){

                        // [2021-05-17 수정] 결재선 中 통보자 (ApproverType__c:9) 는 결재유형(결재,합의,통보) 변경 가능토록 수정
                        if(approvalLineList[i].ApproverType__c == '9'){
                            approvalLineList[i].typeDisabled = false;
                        } else {
                            approvalLineList[i].typeDisabled = true;
                        }

                        var approvalType = approvalLineList[i].ApproverType__c;
                                
                        // 2021.06.21 병렬합의, 병렬결재 추가
                        // CONST_PARALLEL_CONSENSUS : '4', // 병렬 합의
                        // CONST_PARALLEL_APPROVAL : '7',  // 병렬 결재
                        if(approvalType == this.CONST_PARALLEL_CONSENSUS || approvalType == this.CONST_PARALLEL_APPROVAL){
                            var Index__c = approvalLineList[i].Index__c;
                            if(i == approvalLineList.length - 1) nextIndex__c = -1;
                            else nextIndex__c = approvalLineList[i+1].Index__c;
                            
                            //customRadioBtnGroup 화면에 맞춰서 ApprovalType__c 값 변경(병렬결재 1, 병렬합의 2)
                            // if(approvalType == this.CONST_PARALLEL_CONSENSUS) approvalLineList[i].ApproverType__c = '2';
                            // else approvalLineList[i].ApproverType__c = '1';

                            //(i)순번이 (i+1)과 같은 경우 병렬합의, 병렬결재에 해당됨
                            if(Index__c == nextIndex__c){
                                approverList.push(approvalLineList[i]);
                            }else{
                                approverList.push(approvalLineList[i]);
                                employeeList.splice(i, 0, approverList);

                                approverList = [];
                            }
                        }else{
                            approverList.push(approvalLineList[i]);
                            employeeList.splice(i, 0, approverList);
                            approverList = [];
                        }
                      
                    }
                }

                if(isSuccessGetApproval) { // 성공
                    console.log('[결재선]' , JSON.stringify(employeeList) );
                    component.set('v.EmployeeList', employeeList);
                    // component.set('v.approvalHTML', approvalHTML);
                    
                    component.set('v.isCompletedGetApproval', true);
                } else { // 실패
                    component.set('v.isCompletedGetApproval', false);
                }
        
            }
        }
    },

    setApprovalHtml : function(component, event){
        // console.log('setApprovalHtml');
        component.set('v.approvalHTML', event.getParam("approvalHTML"));
    },

    changeRequestBusinessLevel : function(component, event){
        var requestBusinessLevel = component.find('RequestBusinessLevel');
        var requestBusinessLevelValue;
        if(requestBusinessLevel) {
            requestBusinessLevelValue = requestBusinessLevel.get('v.value');
        }
        component.set('v.requestBusinessLevel', requestBusinessLevelValue);
        // console.log('=== changeRequestBusinessLevel # requestBusinessLevelValue', requestBusinessLevelValue);
        
        var knoxApprovalFieldPassEvt = $A.get("e.c:knoxApprovalFieldPassEvent");
        if(knoxApprovalFieldPassEvt) {
            knoxApprovalFieldPassEvt.setParams({
                'requestBusinessLevel' : requestBusinessLevelValue
            });
            knoxApprovalFieldPassEvt.fire();
        }
    },

    onChangeParallel: function(component, event){
        var changeIndex = event.getParam("changeIndex");
        var changeVal = event.getParam("changeVal");
        // console.log('changeIndex:' + changeIndex);

        var employeeList = component.get('v.EmployeeList');
        var empItem = employeeList[changeIndex];

        for(var i = 0 ; i < empItem.length; i++){
            empItem[i].ApproverType__c = changeVal;
        }
        component.set('v.EmployeeList',employeeList);

    },

    /**
	 * 
	 * @param {*} component 
	 * @param {*} type 		'error', 'warning', 'success', 'info'
	 * @param {*} mode 		'pester', 'sticky', 'dismissible'
	 * @param {*} title 
	 * @param {*} message 
	 * @param {*} duration 
	 */
    showToast : function(component, type, mode, title, message, duration) {
        switch (type.toLowerCase()) {
            case 'error':
                mode = 'sticky';
                break;
            case 'warning':
                mode = 'sticky';
                break;
            case 'success':
                mode = 'dismissible';
                duration = 5000;
                break;
        }

        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type : type,
            mode : mode,
            title: title,
            message : message,
            duration : duration
        });
        toastEvent.fire();
    },
    //V1.5 Start
    
    /**
     * For using uploadFile to EFSS, you must regist the Urls for Vault external and internal
     * And also need to regist CSP Trusted Site with "*.samsung.net"
     */
    uploadFiles : function(component,fList){
        console.log('uploadFiles called');
        var self = this;
        recordId = component.get("v.recordId");
        console.log('recordId: '+recordId);
        console.log('Fake FileList1');
        console.log('Fake FileList2');
        console.log('fList: '+fList[0]);
        file = fList[0].file;
        fileName = fList[0].name;
        fileType = fList[0].fileType;
        console.log('File: '+file);
        component.set("v.showSpinner", true);
        self.apex(component, 'getVaultAuthToken', {
            apiType : 'file-upload',
            platform : 'web',
            fileIds  : null
        })
        .then(function(result){
            //console.log('getVaultAuthToken : ', result);
            return self.FormXHR(component, file, result);
        })
        .then(function(result){
            var vault = JSON.parse(result);
            console.log('FormXHR : ', vault);
            /**
             * For using saveVaultId2Content, you must create 'External Data Source' 
             * named 'EFSS_Vault'(Simple Url type). From Setup, find 'External Data Source'
             * and create one.
             */
            return self.apex(component, 'saveVaultId2Content', { recordId : recordId, vaultId : vault.fileId, filename : fileName });
        })
        .then(function(result){
            return self.apex(component, 'getRelatedFiles', { recordId : recordId });
        })
        .then(function(result){
            component.set("v.contents", result);

        })
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });

    },
       //Aditya - v 1.6
    uplaodfileafrerinsert : function(component,knoxapporovalid){
        console.log('Enter into uplaodfileafrerinsert');
        var self = this,
        recordIdknox = knoxapporovalid,
        lisfoffiles = component.get("v.AttachFileList");
        console.log('list of files: ', lisfoffiles);
        
       
        	var promiseChain = Promise.resolve();
        
            for (let i = 0; i < lisfoffiles.length; i++) {
          
        promiseChain = promiseChain.then(function (){
             return self.apex(component, 'getVaultAuthToken', { apiType : 'file-upload', fileIds  : null, platform : 'web' });
        })
		.then(function(result){
            console.log('before FormXHR:');
            return self.FormXHR(component, lisfoffiles[i].file, result);           
        })
        .then(function(result){
            console.log('FormXHR:',result);
            var vault = JSON.parse(result);
            console.log('Adi File name : ', lisfoffiles[i].name);
            //console.log('my calling 1 : ', self.apex(component, 'saveVaultId3Content', { filename : fileName }));
            return self.apex(component, 'saveVaultId2Content', { recordId : recordIdknox, vaultId : vault.fileId, filename : lisfoffiles[i].name });
        })
        .then(function(result){
            console.log('saveVaultId2Content : ', result);
            console.log('Enter after saveVaultId2Content');

            return self.apex(component, 'getRelatedFiles', { recordId : recordIdknox });
        })
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });
       
       }
        return promiseChain;
             },
    FormXHR : function(component, file, authInfo){
        console.log('isCreatable4 : ');
                
        return new Promise($A.getCallback(function(resolve, reject){
            console.log('FormXHR process...', file);
            //console.log('FormXHR process AuthInfo...', authInfo);
            var formData = new FormData();
            formData.append("file", file);

            var formDataEntries = [];
            formData.forEach(function(value, key){
                formDataEntries.push({ key: key, value: formatValue(value) });
            });
            console.log('FormData Entries Adi : ',formDataEntries);

            var req = new XMLHttpRequest();
            //var url = 'https://' + authInfo.domain + '/vault/sds/sfdc/files?secKey='+authInfo.secKey;
            var url = $A.get("$Label.c.EFSS_VAULT_FILEURL") + '/vault/sds/sfdc/files?secKey='+authInfo.secKey;
            console.log('Urladd',url);
            req.open('POST', url);
            req.timeout = 120000;

            req.onload = function(){
                if(req.status === 200){
                    console.log('it responded');
                    resolve(req.response);
                } else {
                    console.log('request error ', req.response);
                    var msg = $A.get("$Label.c.EFSS_COMP_ERR_MSG_XHR_ERROR");
                    reject({
                        exceptionType: msg,
                        message: req.statusText
                    });
                }
            };
            req.onerror = function(e){
                var msg = $A.get("$Label.c.EFSS_COMP_ERR_MSG_SERVER_NOT_RESPONDED");
                console.log('Error Message',msg);
                console.error('FormXHR Exception  : ', e);
                reject({
                    exceptionType: 'XHR onerror',
                    message: msg
                });
            };
            req.send(formData);
        }));
        function formatValue(value){
            if(value instanceof File){
                return {name : value.name, type: value.type, size: value.size};
            } else if(typeof value === 'object' && value !== null){
                var formattedObject = {};
                for (var prop in value){
                    formattedObject[prop] = formatValue(value[prop]);
                }
                return formattedObject;
            } else{
                return value;
            }
        }
    },
    
    
    /**
     * Common Functions
     */
    apex : function(component, apexAction, params){
    
        return new Promise( $A.getCallback( function( resolve, reject ) {

            if(apexAction == 'getVaultAuthToken'){
                var action3 = component.get("c.getVaultAuthToken");
            }else if(apexAction == 'saveVaultId2Content'){
                var action3 = component.get("c.saveVaultId2Content");
            }else{
                var action3 = component.get("c."+apexAction+"");
            }
            //var action = component.get("c."+apexAction+"");
            
            action3.setParams( params );
            action3.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action3 );
        }));
    },

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
             //   console.log('errorcomingknox', err.exceptionType , ':' , err.message);
                self.showMyToast('error', err.exceptionType + " : " + err.message);
                //this.showToast(component, 'error', 'dismissible', err.exceptionType, err.message, 10000);
            });
        } else {
            if(errors.exceptionType != undefined) {
                self.showMyToast('error', errors.exceptionType + " : " + errors.message);
            }
            else {
                var msg = $A.get("$Label.c.EFSS_COMP_UNKNOWN_ERROR");

                self.showMyToast('error', msg);
            }
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 60000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},

    upfile : function(component, knoxapporovalid){
        setTimeout(function(){
    		this.uplaodfileafrerinsert(component, knoxapporovalid);
        },10000);
	}
    //V1.5 End
})