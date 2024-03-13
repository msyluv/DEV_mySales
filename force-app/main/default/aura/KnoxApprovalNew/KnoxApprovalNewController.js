/**
 * @description       : 
 * @author            : dongyoung.kim@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-22
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2021-01-08   dongyoung.kim@dkbmc.com   Initial Version
**/
({
	/**   
    * @author       Jonggil.Kim
    * @description  init Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File2+
    **/
    init: function(component, event, helper) {
        console.log('recordId : ', component.get('v.recordId'));
        console.log(component.get("v.record").Id);
        //
        var action = component.get("c.getStrategyInfo");

        action.setParams({
			recordId : component.get("v.record").Id
        })
        
        action.setCallback(this,function(response){
			var state = response.getState();
			if(state === "SUCCESS"){
                var data = response.getReturnValue();
                console.log('================data===============');
                console.log(data);
                if(data.length > 0){
                    if(data[0].TotalQuestionCount__c != data[0].IsPMAnswerCount__c || data[0].TotalQuestionCount__c != data[0].IsAnswerCount__c){
                        //helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0017'), 'error', 5000); //결재 이름을 입력해 주세요. 
                        helper.showMyToast('warning', $A.get('$Label.c.APPR_MSG_0024')); //아직 답변이 완료되지 않았습니다. 답변 완료 후 결제바랍니다.
                        $A.get("e.force:closeQuickAction").fire();
                        console.log('data2');
                    }
                    if(data[0].Decision__c == null){
                        helper.showMyToast('warning', $A.get('$Label.c.APPR_MSG_0025')); //제출 전에 결정 필드를 선택해야 합니다.
                        $A.get("e.force:closeQuickAction").fire();
                    }
                }
			}  	
			else if (state === "INCOMPLETE") {
			}
			else if (state === "ERROR") {
                var errors = response.getError();
                console.log(errors);
			}			 
        });
        $A.enqueueAction(action);
        //
        // var templateLabel = [{label: '-- none --' , value : '-'}];
        // component.set('v.templateOptions', templateLabel);
        helper.getData(component, event, '-', true);
        var btnt1 = [
            {label : $A.get("$Label.c.APPR_BTN_APPR_ADD"), value : '1'},
            {label : $A.get("$Label.c.APPR_BTN_CONSENT_ADD"), value : '2'},
            {label : $A.get("$Label.c.APPR_BTN_NOTIFICATION_ADD"), value : '9'}
            ];
        var btnt2 = [
            {label : $A.get("$Label.c.APPR_BTN_PARAPPROVAL"), value : '1'},
            {label : $A.get("$Label.c.APPR_BTN_PARCONSENT"), value : '2'}
            ];
        
        component.set('v.buttonType1', btnt1);
        component.set('v.buttonType2', btnt2);

        
    },
      
    /**   
    * @author       Jonggil.Kim
    * @description  Remove in Approver List
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    **/
    removeItem: function(component, event, helper) {
        // 버튼이 클릭된 iteration Index를 가져옴
		var clickedDataIndex = event.currentTarget.getAttribute("data-itemId");
        var EmployeeList = component.get('v.EmployeeList');
        
        console.log('EmployeeList before' , EmployeeList);
        // 받아온 Index를 기준으로 Approver 삭제
        for(var i=0; i<EmployeeList.length; i++){
            var emplist = EmployeeList[i];
            for(var j=0; j<emplist.length; j++){
                if(emplist[j].EvUniqID__c == clickedDataIndex){
                    console.log('del count : ' +'[' +i+'], [' +j+']');
                    console.log('del' ,emplist[j]);
                    if(emplist.length > 1){                       
                        emplist.splice(j, 1);
                        EmployeeList[i] = emplist;
                    }else{
                        EmployeeList.splice(i, 1);
                    }
                    break;
                }
            }
        }
        component.set('v.EmployeeList', EmployeeList); 
    },
    
    /**   
    * @author       Jonggil.Kim
    * @description  Approve Button Click Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    **/
    clickApprove: function(component, event, helper) {
        var ApprovalData = component.get('v.ApprovalData');
        var EmployeeList = component.get('v.EmployeeList');
        
        console.log('ApprovalData', ApprovalData);
        console.log('EmployeeList', EmployeeList);

        //validation
        if(!ApprovalData.KnoxApproval.Name.trim()){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0017'), 'error', 10000); //결재 이름을 입력해 주세요. 
            return;
		}

        if(EmployeeList.length < 1){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0003'), 'error', 10000); //선택된 임직원이 없습니다.
            return;
        }
		/*if(!ApprovalData.KnoxApproval.Description__c.trim()){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 10000); //본문을 입력해 주세요.
            return;
        }*/
        if(!ApprovalData.KnoxApproval.Opinion__c.trim()){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 10000); //본문을 입력해 주세요.
            return;
		}
        console.log('heper call');
        helper.requstApprove(component, event);
    },
    
    /**   
    * @author       Jonggil.Kim
    * @description  Toast Close Button Click Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    **/
    closeToast: function(component, event, helper) {
        var isCloseModal = component.get('v.isCloseModal');
        var toastType = component.get('v.toastType');
        if(isCloseModal) $A.get("e.force:closeQuickAction").fire();
        else helper.toastToggle(component, isCloseModal, toastType);
    },
    
    /**   
    * @author       Jonggil.Kim
    * @description  Cancel Button Click Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    **/
    clickCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    
    /**   
    * @author       Jonggil.Kim
    * @description  Approver Click Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
    **/
   clickApprover: function(component, event, helper) {
    var selectRecords = component.get('v.selectRecords');
    var employeeList = component.get('v.EmployeeList');
    var auraid = event.currentTarget.getAttribute("data-itemid");
  
    // 멀티 여부
    if(!event.ctrlKey){
        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){                    
                if(employeeList[i][j].check){
                    employeeList[i][j].check = false;
                }       
            }
        }
        selectRecords = [];
    }

    var clickemp =  auraid.split('_employee')[0].split('-');
    var arry1 = clickemp[0];
    var arry2 = clickemp[1];

    employeeList[arry1][arry2].check = true;
    selectRecords.push(clickemp);        

    component.set('v.EmployeeList', employeeList );
    component.set('v.selectRecords', selectRecords );

    },
    mergeApproval : function(component, event, helper) {
        console.log('## mergeApproval');

        var selectRecords = component.get('v.selectRecords');

        if(selectRecords.length > 1){
            var employeeList = component.get('v.EmployeeList');
            var srecsize = selectRecords.length;
            var srecod = selectRecords[0]; 
            var arry1 = srecod[0];
            var arry2 = srecod[1];

            var CONST_NOTIFICATION = Number(helper.CONST_NOTIFICATION); // 통보 설정
            if(employeeList[arry1][arry2].ApproverType__c == CONST_NOTIFICATION){
                helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0004'), 'error', 10000); //'병렬은 결재 또는 합의자만 지정 가능합니다.'
                return;
            }

            for(var i=1; i < selectRecords.length; i++){               
                
                var records = selectRecords[i];
                var arr1 = records[0];
                var arr2 = records[1];

                if(employeeList[arr1][arr2].ApproverType__c == CONST_NOTIFICATION){
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0004'), 'error', 10000); //'병렬은 결재 또는 합의자만 지정 가능합니다.'
                    return;
                }

                if(employeeList[arr1].length > 1 && employeeList[arry1].length > 1){ //병합끼리는 병합불가
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0005'), 'error', 10000); //'병렬 해제 후 다시 시도해주세요.'
                    return;
                }
                employeeList[arr1][arr2].check = false;
                employeeList[arry1].push(employeeList[arr1][arr2]);
                employeeList[arr1].splice(arr2, 1); 
                console.log('m:' ,employeeList);
                
            }
            employeeList[arry1][arry2].check = true; 
       
           // 화면에서의 체크 해제
            for(var i=0; i < employeeList.length; i++){
                for(var j=0; j < employeeList[i].length; j++){                                 
                    if(employeeList[i][j].check){
                        employeeList[i][j].check = false;
                    }       
                }
            }  
             // List 에서 비여있는 값 clear
            for(var i=0; i < employeeList.length; i++){         
                if(employeeList[i].length == 0){                    
                    employeeList.splice(i, 1);                   
                    i--;
                }
            }

            selectRecords = []; 
 
            component.set('v.EmployeeList', employeeList );
            component.set('v.selectRecords', selectRecords );

        }
    },
    mergeCancelApproval : function(component, event, helper) {
        var selectRecords = component.get('v.selectRecords');
        var employeeList = component.get('v.EmployeeList'); 

        if(selectRecords.length == 1){       
                
            var records = selectRecords[0];
            var arr1 = records[0];
            var arr2 = records[1];
            var count= parseInt(arr1)+1;
            while(employeeList[arr1].length > 1){
                console.log(count);
                var newlist = new Array();
                newlist.push(employeeList[arr1][1]);               
                employeeList.splice(count, 0, newlist);
                employeeList[arr1].splice(1, 1);  
                count++;                    
            }
            
              // 화면에서의 체크 해제
            for(var i=0; i < employeeList.length; i++){
                for(var j=0; j < employeeList[i].length; j++){                                 
                    if(employeeList[i][j].check){
                        employeeList[i][j].check = false;
                    }       
                }
            }  
            selectRecords = [];
            component.set('v.EmployeeList', employeeList );
            component.set('v.selectRecords', selectRecords );
            
        }

    }
    , moveItem : function(component, event, helper) {
        var employeeList = component.get('v.EmployeeList'); 
        var selectRecords = component.get('v.selectRecords');
        
        var btnType = event.currentTarget.getAttribute("data-itemid");

        if(selectRecords.length > 0){
            var sidx = parseInt(selectRecords[0][0]);
            var idx;
            for(var i=0; i < employeeList.length; i++){
                for(var j=0; j < employeeList[i].length; j++){                                 
                    if(employeeList[i][j].check){
                        employeeList[i][j].check = false;
                    }       
                }
            }  
            if(btnType == 'itemUpBtn' && sidx > 0 ){
                idx = sidx-1;
            }else if( btnType == 'itemDownBtn' &&  sidx < employeeList.length-1){
                idx = sidx+1;               
            }else{
                return;
            }
            var temp = employeeList[idx];
            employeeList[idx] = employeeList[sidx];
            employeeList[sidx] = temp;
            var arr = [];
            arr.push(idx);
            arr.push(0);
            selectRecords = [];
            selectRecords.push(arr);
            employeeList[idx][0].check = true;           

            component.set('v.EmployeeList', employeeList );
            component.set('v.selectRecords', selectRecords );
        }

    },
    tempSave : function(component, event, helper) {
        var ApprovalData = component.get('v.ApprovalData');

        /*if(!ApprovalData.KnoxApproval.Description__c){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 10000); //본문을 입력해 주세요.
            return;
        }*/
        if(!ApprovalData.KnoxApproval.Opinion__c){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 10000); //본문을 입력해 주세요.
            return;
        }
        
        helper.tempSave(component, event);
    },

    clickTypeBtn : function(component, event, helper) {
        var datait = event.currentTarget.getAttribute("data-itemId");
        var employeeList = component.get('v.EmployeeList');

        var item = datait.split('_');
        var type = item[1];
        var arr1 = item[0].split('-')[0];
        var arr2 = item[0].split('-')[1];

        if(type == 'path'){
            employeeList[arr1][arr2].IsChangeLine__c = !employeeList[arr1][arr2].IsChangeLine__c;
        }else if(type == 'mod'){
            employeeList[arr1][arr2].IsEditText__c = !employeeList[arr1][arr2].IsEditText__c;
        }else if(type == 'dec'){
            employeeList[arr1][arr2].IsArbitraryDecision__c = !employeeList[arr1][arr2].IsArbitraryDecision__c;
        }

        component.set('v.EmployeeList', employeeList);
    },

    /*
    * handleComponentEvent Function
    * @author       Jonggil.Kim
    * @description  User Select any record from the result list Function - Result Attribute control
    * @param        component : Component
    event : Event Property
    helper : Helper js File
    * @return       N/A 
    *               Result Attribute Data Set 
    */
   handleComponentEvent : function(component, event, helper) {
    console.log('** handleComponentEvent **');     
    
        var selectedEmployeeGetFromEvent = event.getParam("recordByEvent");
        var employeeList = component.get('v.EmployeeList');      
        var UserKnoxInfo = component.get('v.UserKnoxInfo');  
        console.log('selectedEmployeeGetFromEvent : ', selectedEmployeeGetFromEvent);
        console.log('UserKnoxInfo : ', UserKnoxInfo);
          
        if(UserKnoxInfo == selectedEmployeeGetFromEvent.EvUniqID__c){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0006'), 'error', 10000); //'본인은 추가할 수 없습니다.'
            return;
        }  

        for(var i=0; i < employeeList.length; i++){
            for(var j=0; j < employeeList[i].length; j++){
                console.log('EPID : ', employeeList[i][j].EvUniqID__c);
                // if(employeeList[i][j].Employee__c == selectedEmployeeGetFromEvent.Id){
                if(employeeList[i][j].EvUniqID__c == selectedEmployeeGetFromEvent.EvUniqID__c){ // SFDC Id가 아니나 EP ID를 사용하여 비교하도록 수정
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0007'), 'error', 10000);//'이미 입력된 정보 입니다.'
                    return;
                } 
            }
        }
        
        // 병합 결재를 위한 이중 배열

        var itemlist = [];
        var employee = {
            'Name'                  : selectedEmployeeGetFromEvent.Name,
            'EvEName__c'            : selectedEmployeeGetFromEvent.EvEName__c,
            'ApproverType__c'       : helper.CONST_APPROVAL,
            'EvSdeptNM__c'          : selectedEmployeeGetFromEvent.EvSdeptNM__c,
            'EvSdeptENM__c'         : selectedEmployeeGetFromEvent.EvSdeptENM__c,
            'EvMailAddr__c'         : selectedEmployeeGetFromEvent.EvMailAddr__c,
            'Employee__c'           : selectedEmployeeGetFromEvent.Id,
            'EvUniqID__c'           : selectedEmployeeGetFromEvent.EvUniqID__c,
            'IsChangeLine__c'       : true,
            'IsEditText__c'         : true,
            'IsArbitraryDecision__c': false
        };    

        itemlist.push(employee);
        employeeList.push(itemlist);        
     
        component.set("v.EmployeeList", employeeList);
     
    }
    /*
    * @Name             : changeTemplate
    * @author           : Jonggil Kim, 2019/06/26
    * @Description      : Template 변경시 해당하는 Template을 불러와 Description에 셋팅함.
    */
    , changeTemplate : function(component, event, helper) {    
        console.log('** changeTemplate controller **');
        helper.changeTemplate(component, event);
    }
    /*
    * @Name             : getTeamMember
    * @author           : Jonggil Kim, 2019/07/11
    * @Description      : Team Member를 결재 통보자로 추가함.
    */
    /*, 
    getTeamMember : function(component, event, helper) {    
        console.log('** getTeamMember controller **');
        helper.getTeamMember(component, event);
    }*/

})