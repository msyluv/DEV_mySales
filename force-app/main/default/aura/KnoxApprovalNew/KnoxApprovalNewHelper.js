({
    /* Approver Type */
    CONST_APPROVAL : '1',           // 결재
    CONST_CONSENSUS : '2',          // 합의
    CONST_NOTIFICATION : '9',       // 통보
    CONST_PARALLEL_CONSENSUS : '4', // 병렬 합의
    CONST_PARALLEL_APPROVAL : '7',  // 병렬 결재

    MAX_FILE_SIZE: 7340032, /* 6 000 000 * 3/4 to account for base64 */
    
    getData : function(component, event, type, isInit) {
        // 현재 Oppty에 Approval를 가져오기 위하여 이벤트 RecordId 전달
        var recordId = component.get("v.record").Id;
        var action = component.get("c.initComponent");
        var _this = this;
        // Spinner 해제
        _this.spinnerToggle(component, event);
        action.setParams({
            'recordId': recordId,
            'temp' : type,
            'isInit' : isInit
        });
        // Controller에서 Return받은 Approval 정보를 사용하여 Component에 보여주기 위하여 데이터 셋팅
        action.setCallback(this, function(response) {
            
            var device = $A.get("$Browser.formFactor");
            /*
            if(device == "PHONE" || device == "IPHONE"){ 
                alert($A.get("$Label.c.COMM_MSG_0004"));  
                $A.get("e.force:closeQuickAction").fire();
            }*/
            var state = response.getState();
            console.log('[1] initComponent.state', state);
               
            if (state === "SUCCESS") {                
                var result = response.getReturnValue(); 
                console.log('[1] initComponent.result', result);

                if(!result.IsEdit){
                    _this.callToast(component, true,  $A.get('$Label.c.APPR_MSG_0019'), 'error', 5000); //결재 권한이 없습니다. 소유자 혹은 관리자에게 문의하여 주세요.
                }else{
                    /*if(result.isApproval){
                        _this.callToast(component, true, $A.get("$Label.c.APPR_MSG_0015"), 'error', 5000); //'이미 진행중인 결재가 있습니다.'
                        return;
                    }*/
                    
                    if(!result.UserKnoxInfo.EvUniqID__c){
                        _this.callToast(component ,true, $A.get("$Label.c.APPR_MSG_0008"), 'error', 5000);//'User EPID가 없습니다.'
                        return;
                    }

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
                    var temp_desc = data.Description__c ? data.Description__c : result.Description;
                    var temp_opin = data.Opinion__c ? data.Opinion__c : result.Opinion__c;      
                    
                    console.log('description : ' , data.Description__c);
                    console.log('description : ' , result.Description);
                    var temp_name = data.Name ? data.Name : '[Salesforce Approval] ' +objRecordName ;

                    
                    console.log('[1] initComponent.temp_name', temp_name);

                    for(var i=0; i < result.knoxApprover.length; i++){
                        let data = result.knoxApprover[i];
                        var apporver = {
                            'Index__c'              : data.Index__c,
                            'Name'                  : data.Name,
                            'EvEName__c'             : data.EvEName__c,
                            'ApproverType__c'       : data.ApproverType__c,
                            'EvSdeptNM__c'         : data.EvSdeptNM__c,
                            'EnEvSdeptNM__c'       : data.EnEvSdeptNM__c,
                            'EvMailAddr__c'              : data.EvMailAddr__c,
                            'Employee__c'           : data.Employee__c,
                            'EvUniqID__c'               : data.EvUniqID__c,                            
                            'IsChangeLine__c'       : data.IsChangeLine__c,
                            'IsEditText__c'         : data.IsEditText__c,
                            'IsArbitraryDecision__c': data.IsArbitraryDecision__c
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
                            'BizReview__c' : recordId,
                            'HTML__c' : temp_desc
                        },                
                        'ApproverList' : temp_approverList
                    }; 

                    if(result.FileList){
                        FileList = result.FileList;
                    }

                    if(data.TemplateName__c){
                        component.set('v.templateOptionValue', data.TemplateName__c);
                        
                    }
                    console.log('FileList', FileList);
                    console.log('ApprovalData', ApprovalData);
                    console.log('EmployeeList', EmployeeList);
                    
                    component.set('v.newData', newData);
                    component.set('v.ApprovalData', ApprovalData);
                    component.set('v.FileList', FileList);
                    component.set('v.UserKnoxInfo', result.UserKnoxInfo.EvUniqID__c);
                    component.set('v.EmployeeList', EmployeeList);
                    
                    if(isInit){
                        templateOptions = templateOptions.concat(result.TemplateList);
                        component.set('v.templateOptions', templateOptions);
                    }                    

                    if(result.isTemp){
                         _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0009'), 'success', 5000);//'임시저장 데이터를 불러왔습니다.'  
                    }
                }

            } else {
                _this.callToast(component, true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001'), 'error', 5000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
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
	requstApprove : function(component, event) {
        console.log('Requst Approve ############################');        
		var _this = this;
        var ApprovalData = component.get('v.ApprovalData');
        var employeeList = component.get('v.EmployeeList');
        var UserKnoxInfo = component.get('v.UserKnoxInfo');
        var tempalteName = component.get('v.templateOptionValue');
        console.log('tempalteName ' , tempalteName);
        var fList = component.get('v.FileList'); 
        // Spinner 생성
        _this.spinnerToggle(component, event);
        // console.log('EmployeeList : ', employeeList);
        console.log('ApprovalData : ', ApprovalData);
        // console.log('UserKnoxInfo : ', UserKnoxInfo);
        // console.log('File List    : ', fList);
        
        var approverList =[];
        var ApprConsCount = 0;
       
        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){
                var emp = employeeList[i][j];
                if(UserKnoxInfo == employeeList[i][j].EvUniqID__c){
                    _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0010'), 'error', 5000);//'중복된 임직원이 있습니다.'
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
                var apporver = _this.makeApprover(i, emp);               
                approverList.push(apporver);      
            }
        }
        var totalFileSize = 0;

        for(var i=0; i < fList.length; i++){
            totalFileSize += parseInt(fList[i].fileSize);
            console.log('fList[i].fileSize :' + i + ' , ', fList[i].fileSize);
        }

        // File 개수 제한
        // if(1 < fList.length){
        //     _this.callToast(component, false,  $A.get('$Label.c.FILE_MSG_0001'), 'error', 5000);//파일 첨부는 10개까지 가능합니다.
        //     _this.spinnerToggle(component, event);    
        //     return;  
        // }

        // if(this.MAX_FILE_SIZE < totalFileSize){
        //     _this.callToast(component, false,  $A.get('$Label.c.APPR_MSG_0018'), 'error', 5000);//'총 File 크기는 7MB를 넘길 수 없습니다.'
        //     //_this.alertToast(component, false, 'error', $A.get('$Label.c.APPR_MSG_0018'), 5000); //'총 File 크기는 7MB를 넘길 수 없습니다.'
        //     _this.spinnerToggle(component, event);    
        //     return;
        // }

        if(!ApprConsCount){
            _this.spinnerToggle(component, event);
            _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0013'), 'error', 5000);//'결재자와 합의자가 없습니다.'
            //_this.alertToast(component, false, 'error', $A.get('$Label.c.APPR_MSG_0013'), 5000); //'결재자와 합의자가 없습니다.'
        }else{
            ApprovalData.ApproverList = approverList;            
            
            console.log('params: ' + ApprovalData);
            console.log('params: ' + fList);
            ApprovalData.KnoxApproval.TemplateName__c = tempalteName;
            ApprovalData.KnoxApproval.BizReview__c = component.get('v.recordId');
            //ApprovalData.KnoxApproval.HTML__c = ApprovalData.KnoxApproval.Description__c;
            
            console.log('BizReview__c');
            console.log(ApprovalData.KnoxApproval.BizReview__c);
            console.log(ApprovalData.KnoxApproval);
            var action_del = component.get("c.deleteApproval"); 

            let _action = component.get("c.insertApproval"); 

            _action.setParams({
                'approval' : ApprovalData.KnoxApproval                
            });
            
            console.log('ApprovalData.KnoxApproval >> ' , ApprovalData.KnoxApproval);
            _action.setCallback(this, function(_response) {
                var _state = _response.getState();
                if (_state === "SUCCESS") {
                    var _result = _response.getReturnValue(); 
                    console.log('Insert Approval >> ' + JSON.stringify(_result));
                    var tempApp_ = ApprovalData.KnoxApproval;
                    ApprovalData.KnoxApproval = _result;
                    action_del.setParams({'approvalId' : ApprovalData.KnoxApproval.Id}); 

                    console.log('  😡  😡  😡  😡  😡  😡  😡  😡  ', ApprovalData.KnoxApproval);

                   let action = component.get("c.requestApproval"); 
                   action.setParams({
                        'jsonParam' : JSON.stringify(ApprovalData),
                        'fileList' : fList,
                        'tempalteName' : tempalteName
                    });                    
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var result = response.getReturnValue(); 
                            console.log('result' + result);
        
                            if(result.RESULT == 'success'){
                                $A.get('e.force:refreshView').fire();
                                _this.callToast(component, true, $A.get("$Label.c.APPR_MSG_0011"), 'success', 5000); //"결재 상신 하였습니다.",
                                // Spinner 해제
                            _this.spinnerToggle(component, event); 
                            }else{
                                _this.callToast(component, false, $A.get("$Label.c.APPR_MSG_0012"), 'error', 5000);//'결재 상신이 실패하였습니다. 잠시 후 다시 시도해주세요.'
                                //_this.tempSave(component, event, action_del);
                            }
                        } else {
                            console.log('result' + result);
                            console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fail');
                            console.log('response : ' + response);
                            console.log('state :'+ state);                            
                           
                            $A.enqueueAction(action_del);        
                            _this.callToast(component,true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001'), 'error', 5000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                        }                            
                    });
                    $A.enqueueAction(action);
 
                } else {
                    console.log('result' + _result);
                    console.log('!!!!!!!!!!!!!!!!!!!!!!!!!!!! Fail');
                    console.log('_response : ' + _response);
                    console.log('_state :'+ _state);
                    $A.enqueueAction(action_del);
                    _this.callToast(true, '[STATE ERROR] ' + $A.get('$Label.c.COMM_MSG_0001')+ ' [insert Approval Error]', 'error', 5000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                }                        
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
            'EvEName__c'             : emp.EvEName__c,
            'ApproverType__c'       : emp.ApproverType__c,
            'EvSdeptNM__c'         : emp.EvSdeptNM__c,
            'EnEvSdeptNM__c'       : emp.EnEvSdeptNM__c,
            'EvMailAddr__c'              : emp.EvMailAddr__c,
            'Employee__c'           : emp.Employee__c,
            'EvUniqID__c'               : emp.EvUniqID__c,
            'IsChangeLine__c'       : emp.IsChangeLine__c,
            'IsEditText__c'         : emp.IsEditText__c,
            'IsArbitraryDecision__c': emp.IsArbitraryDecision__c
        };
    },
    tempSave : function(component, event, action_del){
        console.log('TempSave ############################');
        var ApprovalData = component.get('v.ApprovalData');
        var employeeList = component.get('v.EmployeeList');
        ApprovalData.KnoxApproval.TemplateName__c = component.get('v.templateOptionValue');
        console.log(ApprovalData.KnoxApproval);
        console.log(ApprovalData.KnoxApproval.TemplateName__c);
        var fList = component.get('v.FileList'); 
        var _this = this;
        _this.spinnerToggle(component, event);
        var tempList = [];
        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){     
                var apporver = _this.makeApprover(i, employeeList[i][j]);             
                tempList.push(apporver);      
            }
        }   
        
        ApprovalData.ApproverList = tempList;
        var action = component.get("c.tempSaveApproval");   
        console.log('File List   :',fList);        
        action.setParams({
            'recordId' : component.get("v.record").Id,
            'jsonParam' : JSON.stringify(ApprovalData),
            'fileList' : fList
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log(result);
            }             
            // Spinner 해제
            _this.spinnerToggle(component, event);
            _this.callToast(component, false, $A.get('$Label.c.APPR_MSG_0014'), 'success', 5000);//'임시저장 하였습니다.'
            
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
        console.log('callToast ~!@~!@');
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
    }, 

    /*getTeamMember : function(component, event){
        console.log('getTeamMember ############################');
        var recordId = component.get("v.record").Id;
        var employeeList = component.get('v.EmployeeList');
        var _this = this;
        _this.spinnerToggle(component, event);

        var EPIDList = [];

        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){
                var emp = employeeList[i][j];
                EPIDList.push(emp.EvUniqID__c);                 
            }
        }
        console.log('action **');
        var action = component.get("c.getTeamMembers");        
        action.setParams({
            'recordId' : recordId,
            'EPIDList' : EPIDList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                console.log(result);
                if(result){
                    var temp = [];
                    for(i=0; i < result.length; i++ ){
                        console.log(result[i]);
                        temp.push([result[i]]);
                    }
                    employeeList = employeeList.concat(temp);                     
                    component.set('v.EmployeeList',employeeList);


                    if(result.length > 0){
                        _this.callToast(component, false, $A.get('$Label.c.TEAM_MSG_0003'), 'success', 5000);//'팀 멤버를 불러왔습니다.'
                    }else{
                        _this.callToast(component, false, $A.get('$Label.c.TEAM_MSG_0004'), 'info', 6000);//'이미 모든 팀 멤버가 승인자에 등록되어 있거나, 불러올 팀 멤버가 없습니다.'
                    }
                }                
            }             
            // Spinner 해제
            _this.spinnerToggle(component, event);
        });
		$A.enqueueAction(action);
    },*/

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'dismissible',
            message: msg,
            title: "[Warning]",
        });
        toastEvent.fire();
	},
})