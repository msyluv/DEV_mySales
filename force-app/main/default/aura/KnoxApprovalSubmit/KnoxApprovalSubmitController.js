/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 11-05-2023 
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2021-06-02   seonju.jin@dkbmc.com   Initial Version
 * 1.1   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
**/
({

    init: function(component, event, helper) {
        console.log('opptyId : ', component.get('v.opptyId'));
        console.log('opptyactId : ', component.get('v.opptyactId'));
        console.log('approvalMISID:' + component.get('v.approvalMISID'));
        //console.log('userIDLanguage : ', $A.get("$SObjectType.CurrentUser.LanguageLocaleKey"));

        // var templateLabel = [{label: '-- none --' , value : '-'}];
        // component.set('v.templateOptions', templateLabel);
        helper.getData(component, event, '-', true);
        /* 
            CONST_APPROVAL : '1',           // 결재
            CONST_CONSENSUS : '2',          // 합의
            CONST_NOTIFICATION : '9',       // 통보
            CONST_PARALLEL_CONSENSUS : '4', // 병렬 합의
            CONST_PARALLEL_APPROVAL : '7',  // 병렬 결재
        */
        var btnt1 = [
            {label : $A.get("$Label.c.APPR_BTN_APPR_ADD"), value : '1'},
            {label : $A.get("$Label.c.APPR_BTN_CONSENT_ADD"), value : '2'},
            {label : $A.get("$Label.c.APPR_BTN_NOTIFICATION_ADD"), value : '9'}
            ];
        var btnt2 = [
            {label : $A.get("$Label.c.APPR_BTN_PARAPPROVAL"), value : '7'},
            {label : $A.get("$Label.c.APPR_BTN_PARCONSENT"), value : '4'}
            ];
        
        component.set('v.buttonType1', btnt1);
        component.set('v.buttonType2', btnt2);

           
    },
      
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
    
    clickApprove: function(component, event, helper) {
        console.warn('{ clickApprove }');
        var ApprovalData = component.get('v.ApprovalData');
        var EmployeeList = component.get('v.EmployeeList');
        var useApprovalLine = component.get('v.useApprovalLine');
        var isSuccessGetApproval = component.get('v.isSuccessGetApproval');
        
        console.log('ApprovalData', ApprovalData);
        console.log('EmployeeList', EmployeeList);
        console.log('useApprovalLine', useApprovalLine);
        console.log('isSuccessGetApproval ', isSuccessGetApproval);

        var isRequiredCollaboValid = component.get('v.isRequiredCollaboValid');
        var isSuccessCollaboValid = component.get('v.isSuccessCollaboValid');
        var collaboApprovalTypeCode = component.get('v.collaboApprovalTypeCode');
        console.log('v.isRequiredCollaboValid', isRequiredCollaboValid);
        console.log('v.isSuccessCollaboValid', isSuccessCollaboValid);
        console.log('v.collaboApprovalTypeCode ',collaboApprovalTypeCode);

        // 결재 본문 html 여부
        // Knox Approval Component 보다 Preview Component가 먼저 로딩된 경우 Event 재호출하여 받아옴
        console.log('==== [S] knoxApprovalHtmlGetEvent.fire()');
        var knoxApprovalHtmlGetEvt = $A.get('e.c:knoxApprovalHtmlGetEvent');
        knoxApprovalHtmlGetEvt.fire();
        console.log('==== [E] knoxApprovalHtmlGetEvent.fire()');

        // **************** Validation ****************
        // [ZPG1] 사업등급 변경 결재 요청시 기존과 같은 등급으로 요청 불가능
        var actTransactionCode = component.get('v.actTransactionCode');
        if(actTransactionCode == 'ZPG1') {
            var oppty = component.get('v.oppty');
            var requestBusinessLevel = component.get('v.requestBusinessLevel');

            if(!requestBusinessLevel) {
                // 변경 사업 등급을 선택해주세요.
                helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0028'), 10000);                 
                return;
            }

            console.log('### [before] oppty.FinalBusinessLevel__c : ', oppty.FinalBusinessLevel__c);
            console.log('### [after] requestBusinessLevel', requestBusinessLevel);

            if(oppty.FinalBusinessLevel__c == requestBusinessLevel) {
                // 기존과 동일한 사업등급으로 요청할 수 없습니다. 요청 사업 등급을 확인해주세요.
                helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0029'), 10000);  
                return;
            }
        }

        if(!(ApprovalData.KnoxApproval.Name).trim()){
            //결재 이름을 입력해 주세요. 
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0017'), 10000); 
            return;
        }

        // 결재 사전점검 or 결재조회 성공 여부
        if(!isSuccessGetApproval){
            // 결재선 조회(or 사전 점검)가 완료되지 않았습니다.
            var toastMsg = useApprovalLine ? $A.get('$Label.c.LAPP_MSG_007') : $A.get('$Label.c.VAPP_MSG_013');
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), toastMsg, 10000);
            return;
        } 
        
        

        var approvalHTML = component.get('v.approvalHTML');
        // console.log('==== approvalHTML : ', approvalHTML);
        if(!approvalHTML.trim()){
            // 결재 본문이 없습니다. 결재 본문 조회 후,결재 상신하십시오.
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0027'), 10000);             
            return;
        }

        if(EmployeeList.length < 1){
            //선택된 임직원이 없습니다.
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0003'), 10000); 
            // helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0003'), 'error', 10000); 
            return;
        }
		/*if(!ApprovalData.KnoxApproval.Description__c.trim()){
            helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 5000); //본문을 입력해 주세요.
            return;
        }*/
        
        var approvalOpinion = ApprovalData.KnoxApproval.Opinion__c ? ApprovalData.KnoxApproval.Opinion__c : '';        
        console.log('approvalOpinion', approvalOpinion);
        if(!approvalOpinion.trim()){
            //본문을 입력해 주세요.
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.APPR_MSG_0002'), 10000); 
            // helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0002'), 'error', 10000); 
            return;
		}
        //Start - Added by Anish-v 1.1
        if(actTransactionCode == 'ZP21'){
        if(component.get('v.messageTemp') != "true"){
            //본문을 입력해 주세요.
            helper.showToast(component, 'error', 'sticky', $A.get('$Label.c.COMM_LAB_ERROR'), $A.get('$Label.c.FILE_0002'), 10000);  
            return;
		}
        }
        //End - Added by Anish-v 1.1

        helper.requestApprove(component, event);
    },
    
    closeToast: function(component, event, helper) {
        var isCloseModal = component.get('v.isCloseModal');
        var toastType = component.get('v.toastType');
        if(isCloseModal) $A.get("e.force:closeQuickAction").fire();
        else helper.toastToggle(component, isCloseModal, toastType);
    },
    

    clickCancel: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },

    
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
        console.log(JSON.stringify(selectRecords));
        console.log(selectRecords.length);

        if(selectRecords.length > 1){
            var employeeList = component.get('v.EmployeeList');
            var srecod = selectRecords[0]; 
            var arry1 = srecod[0];
            var arry2 = srecod[1];

            var CONST_NOTIFICATION = Number(helper.CONST_NOTIFICATION); // 통보 설정
            if(employeeList[arry1][arry2].ApproverType__c == CONST_NOTIFICATION){
                helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0004'), 'error', 10000); //'병렬은 결재 또는 합의자만 지정 가능합니다.'
                return;
            }

            if(employeeList[arry1][arry2].typeDisabled){
                helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0034'), 'error', 10000); //'병렬은 결재 또는 합의자만 지정 가능합니다.'
                return;
            }

            //validation Check
            for(var i=1; i < selectRecords.length; i++){         
                var records = selectRecords[i];
                var arr1 = records[0];
                var arr2 = records[1];

                if(employeeList[arr1][arr2].typeDisabled){
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0034'), 'error', 10000); //'비활성화된 결재선은 병렬할 수 없습니다.'
                    return;
                }

                if(employeeList[arr1][arr2].ApproverType__c == CONST_NOTIFICATION){
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0004'), 'error', 10000); //'병렬은 결재 또는 합의자만 지정 가능합니다.'
                    return;
                }

                if(employeeList[arr1].length > 1 && employeeList[arry1].length > 1){ //병합끼리는 병합불가
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0005'), 'error', 10000); //'병렬 해제 후 다시 시도해주세요.'
                    return;
                }
            }

            /* 
            ApprvoalType
            CONST_APPROVAL : '1',           // 결재
            CONST_CONSENSUS : '2',          // 합의
            CONST_NOTIFICATION : '9',       // 통보
            CONST_PARALLEL_CONSENSUS : '4', // 병렬 합의
            CONST_PARALLEL_APPROVAL : '7',  // 병렬 결재
            */
            var approverType =  employeeList[arry1][arry2].ApproverType__c;
            if(approverType == helper.CONST_APPROVAL) approverType = helper.CONST_PARALLEL_APPROVAL;
            else if(approverType == helper.CONST_CONSENSUS) approverType = helper.CONST_PARALLEL_CONSENSUS;

            for(var i=1; i < selectRecords.length; i++){              
            
                var records = selectRecords[i];
                var arr1 = records[0];
                var arr2 = records[1];

                employeeList[arr1][arr2].check = false;
                employeeList[arr1][arr2].ApproverType__c = approverType;
                console.log('approverType after:' +approverType);

                employeeList[arry1].push(employeeList[arr1][arr2]);
                employeeList[arr1].splice(arr2, 1); 
            }
            
            employeeList[arry1][arry2].ApproverType__c = approverType;
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
 
            //console.log(JSON.stringify(employeeList));
            component.set('v.EmployeeList', employeeList );
            component.set('v.selectRecords', selectRecords );

        }


    },
    
    mergeCancelApproval : function(component, event, helper) {
        var selectRecords = component.get('v.selectRecords');
        var employeeList = component.get('v.EmployeeList'); 

        var records = selectRecords[0];
        var arr1 = records[0];
        var arr2 = records[1];

        if(selectRecords.length == 1){
            if(employeeList[arr1].length > 1){
                for(var i =0; i < employeeList[arr1].length; i++){
                    if(employeeList[arr1][i].typeDisabled){
                        helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0035'), 'error', 10000); //'비활성화된 결재선은 병렬할 수 없습니다.'
                        return;
                    }
                }
            }


            var count= parseInt(arr1)+1;
            var approverType = employeeList[arr1][0].ApproverType__c;
            if(approverType == helper.CONST_PARALLEL_APPROVAL) approverType = helper.CONST_APPROVAL;
            else if(approverType == helper.CONST_PARALLEL_CONSENSUS) approverType = helper.CONST_CONSENSUS;

            employeeList[arr1][0].ApproverType__c = approverType;

            while(employeeList[arr1].length > 1){
                //console.log(count);
                var newlist = new Array();
                employeeList[arr1][1].ApproverType__c = approverType; 
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

        var approvalLineIndex; // 결재선 last index

        if(selectRecords.length > 0){
            var sidx = parseInt(selectRecords[0][0]);
            var idx;
            for(var i=0; i < employeeList.length; i++){
                for(var j=0; j < employeeList[i].length; j++){
                    if(employeeList[i][j].check){
                        employeeList[i][j].check = false;
                    }       
                    if(employeeList[i][j].IsGetApprovalLine__c) {
                        approvalLineIndex = i;
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

            // (2021-05-10 수정) 결재선 여부 관계없이 순서 이동 가능하도록 변경
            // [제한] if 결재선이 이동할 위치에 있는 경우 return;
            /*
            var isAdminProfile = component.get('v.isAdminProfile');
            if(approvalLineIndex && approvalLineIndex == idx) {
                if(!isAdminProfile) return; // Admin Profile은 가능
            }
            */

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

        
        if(!ApprovalData.KnoxApproval.Opinion__c.trim()){
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
            'IsChangeLine__c'       : false,
            'IsEditText__c'         : false,
            'IsArbitraryDecision__c': false,
            'IsGetApprovalLine__c'  : false,
            'Status__c'             : '0'
        };    

        itemlist.push(employee);
        employeeList.push(itemlist); 
        console.log('EmployeeList========================');
        console.log(employeeList);       
     
        component.set("v.EmployeeList", employeeList);
     
    }

    , changeTemplate : function(component, event, helper) {    
        console.log('** changeTemplate controller **');
        helper.changeTemplate(component, event);
    }

    /**
     * 결재선 정보 호출
     */
    , getApprovalLine : function(component, event, helper) {
        helper.getApprovalLine(component, event);
    }

    , setApprovalLine : function(component, event, helper) {
         console.log('** changeTemplate controller Ani **');
        helper.setApprovalLine(component, event);
    }

    , setApprovalHtml : function(component, event, helper) {
        helper.setApprovalHtml(component, event);
    }
    
    //Added by Anish-v 1.1
    , handleFileFlag: function(component, event, helper) {
        var message = event.getParam("fileFlag");
        //var filelist = event.event.getParam("AllFilelist");
        if(message.length > 0 ){
        component.set("v.messageTemp","true");
        component.set("v.AttachFileList",message);
        }
        
        //console.log('messageTemp Ani==',message);
    }
    
    //Added by Anish-v 1.1
    , handleFileVaultFlag: function(component, event, helper) {
        var message1 = event.getParam("vaultfileFlag");
        //var filelist = event.event.getParam("AllFilelist");
        if(message1.length > 0 ){
        //component.set("v.messageTemp","true");
        component.set("v.AttachFileListVault",message1);
            console.log('after event fired file details : ',component.get("v.AttachFileListVault"));
        }
        
        //console.log('messageTemp Ani==',message);
    }
    
    /**
     * @Description : [ZPG1] Request Business Level Preview Pass
     * 속성변경품의(사업등급변경) : 변경할 Business Level Picklist 정보 Privew로 전달 
     */
    , changeRequestBusinessLevel  : function(component, event, helper) {
        helper.changeRequestBusinessLevel(component, event);
    }

    , onChangeParallel : function(component,event,helper){
        helper.onChangeParallel(component,event);
    }
})