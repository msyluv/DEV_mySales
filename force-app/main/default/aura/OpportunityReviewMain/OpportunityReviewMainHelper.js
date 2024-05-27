/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 11-05-2023
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   06-21-2021   ukhyeon.lee@samsung.com          Initial Version
 * 1.1   04-01-2022   akash.g@samsung.com              MY-SALES- 108 -> Adding error message on click of BO review tab if Biz Type 1 is null.
 * 1.2   23-10-2023   saurav.k@partner.samsung.com     MY-SALES- 326 -> mySales amount/biz budget change bug on BO Review tab.
 * 1.3   10-25-2023   rakshit.s@samsung.com            MySales-336
 * 1.4   11-05-2023   anish.jain@partner.samsung.com   MySales - 216
 * 1.5   2024-02-19   anish.jain@partner.samsung.com   BO Review Approval Issue Check (MS-418)
**/

({
    helperinit : function(component, event) {
        var self = this;        
        self.getBOInfo(component);//화면 조회
        //for Anish- v 1.4 (ToolTip Dynamic)
        var locale = $A.get("$Locale.language");
        console.log('Test AJC1',locale);
        var tooltipText = '';
        if(locale === 'ko'){
            tooltipText = 'BO Review 품의 탭을 눌러 품의를 진행해주세요. (KOR)';
        }
        else{
            tooltipText = 'Please proceed BO Review Knox Approval clicking Knox Approval(BO Review) tab.';
        }
        component.set('v.dynamicToolTip' ,tooltipText );
        //for v Anish- v 1.4 end
    }, 
    
    apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
            var action = component.get("c."+apexAction+"");
            action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
    },
    
    errorHandler : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showToast('error', 'ERROR', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showToast('error', 'ERROR' ,'errors:'+ errors.message);
        }
    },
    
    showToast : function(type, msg) {
        var mode = 'sticky';
        if(type.toLowerCase() == 'success') mode = 'dismissible';
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 5000,
            mode: mode,
            message: msg
        });
        toastEvent.fire();
    },
    
    //체크박스
    handleCheck : function(component, event){
        component.set('v.opptyData.Opportunity_Review_Checkbox1__c', component.find('checkbox1').get('v.checked'));//컴플라이언스1
        component.set('v.opptyData.Opportunity_Review_Checkbox2__c', component.find('checkbox2').get('v.checked'));//컴플라이언스2
        if("Y"==component.find('checkbox4').get('v.value')){
            component.set('v.opptyData.Opportunity_Review_Consortium__c', true); 
        }else {
            component.set('v.opptyData.Opportunity_Review_Consortium__c', false);
        } 
        
        //사업심의예외여부는 PI Admin 일때만
        if (component.get("v.Admin")){
            component.set('v.opptyData.Opportunity_Review_Exception__c', component.find('checkbox3').get('v.checked'));//사업심의예외여부
        }        
        //사업심의유형 외 체크박스 클릭 시 Disable
        if('checkbox3'!=event.getSource().get("v.name")){
            component.set("v.isSearchDisabled", true);
            component.set('v.opptyData.Opportunity_Review_Exception__c', false);//V 1.2-mySales-326
            component.set("v.isExcDisabled", true);      //V 1.2-mySales-326
            component.set("v.opptyData.Opportunity_Review_Exception_Reason__c","");//V 1.2-mySales-326
        } 
        //컴플라이언스 체크 시
        if('checkbox1'==event.getSource().get("v.name") || 'checkbox2'==event.getSource().get("v.name")){
            var check1 = component.find("checkbox1").get("v.checked");
            var check2 = component.find("checkbox2").get("v.checked");
            if(check1||check2){
                component.set("v.opptyData.Opportunity_Review_Result__c", $A.get('$Label.c.OPPTYACT_BO_REVIEW_COMPLIANCE_DROP'));
            } else{
                if(component.get('v.opptyData_origin.Opportunity_Review_Result__c') === $A.get('$Label.c.OPPTYACT_BO_REVIEW_COMPLIANCE_DROP')){
                    component.set("v.opptyData.Opportunity_Review_Result__c", null);
                } else{
                    component.set("v.opptyData.Opportunity_Review_Result__c", component.get('v.opptyData_origin.Opportunity_Review_Result__c'));
                }
            } 
        } 
    },
    
    //데이터 조회
    getBOInfo: function(component){
        var self = this;
        var locale = $A.get("$Locale.language");
        self.apex(component
                  , 'getBOInfo'
                  , {opptyId: component.get('v.recordId')}
                 ).then(function(result){
            //1.3 start
            if((result.opptyData.Opportunity_Review_VRB_Type__c=='10' || result.opptyData.Opportunity_Review_VRB_Type__c=='20') && !result.opptyData.Collaboration__c && (result.opptyData.CompanyCode__c!='T100' && result.opptyData.CompanyCode__c!='T140' && result.opptyData.CompanyCode__c!='ZB01' && result.opptyData.CompanyCode__c!='T110' && result.opptyData.CompanyCode__c!='T120')){
                if(locale === 'ko'){
                    component.set("v.descLabelDynamicValue" ,'※ 법인 단독사업의 경우 전사/사업부 수전위 요청 전 김현준 프로(newfaith@samsung.com)에게 문의.<br> <br>'+ $A.get("$Label.c.OPPTYACT_BO_REVIEW_DESC") );
                }
                else{
                    component.set("v.descLabelDynamicValue" ,'※ If the business opportunity is conducted solely by overseas subsidiaries,contact Hyunjun Kim(newfaith@samsung.com) before requesting strategy committee.<br> <br>'+ $A.get("$Label.c.OPPTYACT_BO_REVIEW_DESC") );
                }
                
            }
            else{
                console.log('inside else');
                //component.set("v.descLabelDynamicValue" ,'※ If the business opportunity is conducted solely by overseas subsidiaries,contact Hyunjun Kim(newfaith@samsung.com) before requesting strategy committee.<br>'+ $A.get("$Label.c.OPPTYACT_BO_REVIEW_DESC") );
                component.set("v.descLabelDynamicValue" , $A.get("$Label.c.OPPTYACT_BO_REVIEW_DESC"));
            }
            //1.3 End
            if(result.RESULT == 'S' || result.RESULT == 'I'){
                //값 세팅 먼저
                component.set("v.isAdmin", result.isAdmin);
                component.set("v.opptyData",result.opptyData);
                component.set("v.opptyData_origin",result.opptyData_origin);
                component.set("v.vrbPickList", result.vrbPickList); //VRB method pick list
                component.set("v.vrbLabelList", result.vrbLabelList);//VRB method label
                component.set("v.vrbCount", result.vrbCount);
                component.set("v.isSaveDisabled", result.isConfirm);
                component.set("v.isAmtDisabled", result.isAmtChange);
                result.opptyData.Opportunity_Review_Consortium__c ? component.set("v.consortiumYn", "Y") : component.set("v.consortiumYn", "N");

                console.log('result** pendingKnox new' + result.pendingKnox);
                console.log('result** implementation' + result.implementation);
                if ($A.util.isUndefinedOrNull(result.project)){ // 1. Project Code 없으면 Readonly
                    console.log('result** CD project' + result.project);
                    self.showToast('error', $A.get('$Label.c.OPPTYACT_BO_REVIEW_NO_PROJECT_CODE'));
                    return;
                }
                
                
                if(result.approved){// 2. 수주품의 결재완결 이력있으면 Readonly
                    console.log('result** CD New approved' + result.approved);
                    return;
                }
                
                //Start -Added by Anish - v 1.4
                if(result.CD) {
                    console.log('result** CD Analysis' + result.CD);
                    component.set('v.contentDocumentId', result.CD);
                }
                
                //End - for v Anish- v 1.4 (show tabs on init)

                
                //It return error message if biz type 1 is null on click of BO Review tab.
                if (result.implementationNull){//V1.1 -> MY-SALES- 108 -> Adding error message on click of BO review tab if Biz Type 1 is null.
                    console.log('implementationNull**');
                    self.showToast('error', $A.get('$Label.c.OPPTYACT_BO_REVIEW_ERRORMSG'));
                    return;
                }
                
                if (!result.implementation){ // 3. 사업유형1- 판매형/서비스형이면 Readonly(협업 포함 모두 판매형or서비스형일경우)
                    console.log('implementation**');
                    self.showToast('error', $A.get('$Label.c.OPPTYACT_BO_REVIEW_NO_SERVICE_SALES'));
                    return;
                }
                
                
                if(result.opptyData.Opportunity_Review_Exception__c){// 4. 사업심의예외의 경우 - Admin : 예외 입력창 enable, 일반 : Readonly
                    if(result.isAdmin){
                        component.set("v.isExcDisabled", false);
                    } else{
                        self.showToast('error', $A.get('$Label.c.OPPTYACT_BO_REVIEW_EXCEPTION_CANNOT_MODIFIED'));
                        return;
                    }
                }
                
                if(!$A.util.isUndefinedOrNull(result.opptyData.Opportunity_Review_Result__c)){// 5. 기존 저장된 경우 저장버튼 항상 활성화
                    //Account 변경사항이 있을경우 다시 조회해야함
                    if(!$A.util.isUndefinedOrNull(result.opptyData.Opportunity_Review_Account__c) && !$A.util.isUndefinedOrNull(result.opptyData.Opportunity_Review_cOriginAcc__c)){
                        if(result.opptyData.Opportunity_Review_Account__c == result.opptyData.AccountId && result.opptyData.Opportunity_Review_cOriginAcc__c ==result.opptyData.cOriginAcc__c ){
                            component.set("v.isSearchDisabled", false);
                            //component.find("accordion").set('v.activeSectionName', 'A');
                        }
                    }
                } 
                
                //Anish-v 1.4 
                if(result.pendingKnox == true){
                  component.set("v.isSearchDisabled", true); 
                  component.set("v.isTabDisabled", true);
                } 
                else{
                component.set("v.isTabDisabled", false);// 6. 탭 활성화   
                }
                //Anish-v 1.4
            
            }else{
                self.showToast('error', result.MESSAGE);
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
    },
    
    //Added by Anish - v 1.4
    downloadFile : function(component, event, cdId){
		var self = this,
			vaultId = "",
			secKey = "",
			domain = "",
			docId = cdId; // 테스트용

		component.set("v.showSpinner", true);
		self.apex(component, 'getVaultFileId', { docId : docId })
		.then(function(result){
			vaultId = result.ExternalDocumentInfo2;
			return self.apex(component, 'getVaultAuthToken', { apiType : 'file-download', fileIds : [ vaultId ]});
		})
		.then(function(result){
			secKey = result.secKey;
			domain = result.domain;
			component.set("v.showSpinner", false);
			//var downloadUrl = 'https://' + domain + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + secKey;
			var downloadUrl = $A.get("$Label.c.EFSS_VAULT_FILEURL") + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + secKey;
			/**
			 * File download
			 */
			window.open(downloadUrl);
		})
        .catch(function(errors){
            self.errorHandler(errors);
            component.set("v.showSpinner", false);
        });
    },
    
    
    //저장
    saveData : function(component, event){
        console.log('OpprotunityReviewMainHelper saveData');
        component.set('v.showSpinner', true);
        
        var close = $A.get("e.force:closeQuickAction");
        var refresh = $A.get('e.force:refreshView');
        
        
        
        /*변수세팅 ****************************************** */
        var varList = this.getVarLists(component, 'opptyData');
        var passYn = this.checkRule(component, varList, null);
        if (!passYn){
            component.set('v.showSpinner', false);
            return;
        }
        /* ************************************************** */
        
        //저장
        var self = this;
        self.apex(component, 'boDataSave', {
            recordId : component.get('v.recordId'),
            inputDatas : JSON.stringify(varList)
        }).then(function(result){
            console.log('insideeventfiringcondition@' + result);
            if(result.RESULT == 'S'  || result.RESULT == 'I'){
                
                component.set("v.opptyData",result.opptyData);
                component.set("v.opptyData_origin",result.opptyData_origin);
                
                       //for v Anish-v 1.4 check if value coming is equal to BO Review meeting (business team)/ 30.
                
                console.log('the value--->' + component.get('v.opptyData.Opportunity_Review_VRB_Type__c'));  //v1.2
                
               if(component.get('v.opptyData.Opportunity_Review_VRB_Type__c') == 30 && (result.opptyData.VRB_Account_Change__c==true || result.opptyData.VRB_Account_Change__c ==false) ){  //Added by Anish-v 1.5
                    console.log('insideeventfiringcondition');
                    // component.set('v.isSearchDisabled' , true);
                    
                    
                    
                    
                    var appEvent = $A.get("e.c:RefreshActivityTabs");
                    appEvent.setParams({
                    isConfirmed: false,
                        isBoReviewValue: true,
                        updatedOppData: result.opptyData,
                        updatedVrb: result.opptyData.VRB_Account_Change__c    //Added by Anish-v 1.5
                });
                   if((result.opptyData.Collaboration__c == false && result.opptyData.CompanyCode__c == 'T100') && !(result.opptyData.cOriginAcc__r.AccountGroup__c == 'ZIC2' || result.opptyData.cOriginAcc__r.AccountGroup__c == 'ZIC')){
                       appEvent.fire();
                   }
                    //debugger;
                }
                
                else{
                    console.log('insideeventfiringcondition@#');
                     var appEvent = $A.get("e.c:RefreshActivityTabs");
                    appEvent.setParams({
                   isConfirmed: false,
                        isBoReviewValue: false,
                        updatedOppData: result.opptyData
                });
                    if((result.opptyData.Collaboration__c == false && result.opptyData.CompanyCode__c == 'T100')){
                       appEvent.fire();
                   }     
                }
               
                //for v Anish-v 1.4 check if value coming is equal to BO Review meeting (business team)/ 30 ends.
                
                close.fire();
                refresh.fire();
                //임시저장되었습니다. 사업심의유형확정 버튼을 눌러야 변경된 내용이 SAP시스템에 반영됩니다
                //self.showToast('success', $A.get('$Label.c.OPPTYACT_BO_REVIEW_TEMP_SAVE'));
                self.openModal(component);
            }else{
                self.showToast('error', result.MESSAGE);
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
        });
        
    },
    
    
    //사업심의유형 조회
    retrieveBusinessCheckType : function(component){
        console.log('OpportunityReviewMainHelper retrieveBusinessCheckType');
        component.set('v.showSpinner', true);
        
        var self = this;
        
        //사업심의유형 조회시에도 체크로직에 걸리는게 없는지 확인
        /*변수세팅 ****************************************** */
        var varList = this.getVarLists(component, 'opptyData');
        console.log('OpportunityReviewMainHelper varList' + varList);
        var exceptMap = new Map();
        exceptMap.set('rule3', 'rule3');//사업심의유형 선택 pass
        exceptMap.set('rule5', 'rule5');//BO점검결과 입력 pass
        exceptMap.set('rule6', 'rule6');//admin 이면서 예외여부체크했을경우, 예외사유입력 여부 pass
        
        
        var passYn = this.checkRule(component, varList, exceptMap);
        if (!passYn){
            component.set('v.showSpinner', false);
            return;
        }
        /* ************************************************** */
        
        self.apex(component
                  , 'retrieveBusinessCheckType'
                  , {opptyId: component.get('v.recordId')
                     ,inputDatas : JSON.stringify(varList)
                    }
                 ).then(function(result){
            /*사업심의유형 확인(IF-143) output
                EV_DANGER_YN //위험고객여부 / Y
                EV_VRB_TYPE// 사업심의유형(VRB Method)/ 10,20,30
                EV_RESULT// Message type  
                            *E : Error
                            *W : Warning
                            *I : Info
                            *A : Abort
                EV_MESSAGE// Message Text
            */
            component.set("v.opptyData",result.opptyData);
            component.set("v.infData",   result.infData);//사업심의결과 연계데이터
            console.log('Ani Testing VRB ',result);
            var EV_DANGER_YN = '';
            var EV_VRB_TYPE = '';
            if('S'===result.infData.RESULT || 'I'===result.infData.RESULT){
                component.set("v.isSearchDisabled", false);
                EV_DANGER_YN = result.infData.EV_DANGER_YN;
                EV_VRB_TYPE = result.infData.EV_VRB_TYPE;
                
                console.log('### EV_VRB_TYPE = ' + EV_VRB_TYPE);
                
                //위험고객 여부 문구 표시            
                component.set('v.opptyData.Opportunity_Review_Dangerous__c', EV_DANGER_YN);
                
                if(component.get('v.isAdmin')){                                                                 //1. 어드민
                    if(!component.get('v.opptyData_origin.Opportunity_Review_Exception__c')){                   //2. 사업심의유형이 예외가 아니었던 경우               
                        var before  = component.get('v.opptyData.Opportunity_Review_VRB_Type_Confirm__c');      
                        var after = EV_VRB_TYPE;
                        console.log('before______' + before);
                        console.log('after______' + after);
                        if(!$A.util.isUndefinedOrNull(before)){                                                  //3. 사업심의유형 확정값이 존재
                            if(before!==after){                                                                 //4.1 확정값 != 셀렉트 박스값                               
                                // component.set('v.opptyData.Opportunity_Review_Exception__c', true);             //5. 사업심의유형 예외처리 //V 1.2-mySales-326
                                // component.set("v.isExcDisabled", false);  //V 1.2-mySales-326           
                            } else{                                                                             //4.2 확정값 == 셀렉트 박스값
                                
                                component.set('v.opptyData.Opportunity_Review_Exception__c', false);            //5. 사업심의유형 예외처리 X
                                component.set("v.isExcDisabled", true);
                            }      
                        }            
                    }
                }
                
                /*  - IF-143 호출하여 리턴받은 사업심의유형, 위험고객 값을 화면에 보여줌
                    - IF-143에서 조회된 사업심의유형과, 원래 저장되어있던 사업심의유형이 다르다면 체크하여 알림창을 띄운다
                    * 원래 저장되어있던 사업심의유형(origin_Opportunity_Review_VRB_Type__c) 값과 IF-143에서 받은 값을 비교
                        (1) 사업심의유형이 변경(상향)된경우, "사업심의유형이 ~에서 ~로 상향되었습니다. 해당 프로세스로 사업심의를 진행하십시오."
                        (2) 사업심의유형이 변경되지 않았을경우,  "사업심의유형 변동 없습니다"
                */
                var originVal = component.get('v.opptyData_origin.Opportunity_Review_VRB_Type__c');//원래 저장되어있던 사업심의유형값
                var message = '';
                
                if (!$A.util.isEmpty(originVal)){    //사업불참의 경우 새로 조회하는것처럼
                    //String을 Number로 변환
                    originVal *= 1;
                    EV_VRB_TYPE *= 1;
                    
                    var labelList = component.get("v.vrbLabelList");
                    var count = component.get("v.vrbCount");
                    count*=1;
                    
                    var msg1 = '';
                    var msg2 = '';
                    
                    /*
                        OPPTYACT_BO_REVIEW_TYPE_10	전사 수주전략위원회
                        OPPTYACT_BO_REVIEW_TYPE_20	사업부 수주전략위원회
                        OPPTYACT_BO_REVIEW_TYPE_30	BO 점검회의
                    */
                    for(var i=0; i<count; i++){
                        if (labelList[i].value == originVal){
                            if (labelList[i].value=='10')
                                msg1 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_10');
                            else if (labelList[i].value=='20')
                                msg1 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_20');
                                else if (labelList[i].value=='30')
                                    msg1 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_30');
                        }
                        if (labelList[i].value == EV_VRB_TYPE){
                            if (labelList[i].value=='10')
                                msg2 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_10');
                            else if (labelList[i].value=='20')
                                msg2 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_20');
                                else if (labelList[i].value=='30')
                                    msg2 = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_30');
                        }
                    }
                    
                    //컴플라이언스 체크 시 Drop 안내
                    if(component.get('v.opptyData.Opportunity_Review_Checkbox1__c') || component.get('v.opptyData.Opportunity_Review_Checkbox2__c') ){
                        message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_COMPLIANCE_DROP');
                    } 
                    //이전값이 사업불참인 경우 기본메세지
                    else if(40===originVal){
                        
                    }
                    //숫자가 낮을수록 상위단계이다
                        else if (originVal == EV_VRB_TYPE){
                            //사업심의유형 변동 없습니다
                            message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_EQUAL');
                        } 
                            else if (originVal < EV_VRB_TYPE){
                                //사업심의유형이 {0} 에서 {1} 로 상향되었습니다. 해당 프로세스로 사업심의를 진행하십시오.
                                message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_CHANGE_DOWN');
                                message = message.replace('{0}', msg1);
                                message = message.replace('{1}', msg2);
                            } 
                                else if (originVal > EV_VRB_TYPE){
                                    //사업심의유형이 {0} 에서 {1} 로 하향되었습니다. 해당 프로세스로 사업심의를 진행하십시오.
                                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_TYPE_CHANGE');
                                    message = message.replace('{0}', msg1);
                                    message = message.replace('{1}', msg2);
                                }
                }
                
                if('I'===result.infData.RESULT){
                    if(!$A.util.isEmpty(message)) message += '\n';
                    message += result.infData.MESSAGE;
                } 
                
                component.set('v.opptyData.Opportunity_Review_VRB_Type__c', EV_VRB_TYPE+'');
                
                if (!$A.util.isEmpty(message)){
                    self.showToast('info', message);
                } else if('S'===result.infData.RESULT){
                    self.showToast('success', $A.get('$Label.c.OPPTYACT_BO_REVIEW_SEARCH_COMPLETED'));
                } 
            }//2022-08-12 yeongju.baek@dkbmc.com 대외사업 참여시 전사 수전위 필수영역 변경건 
            else{
                self.showToast('error', result.infData.MESSAGE);
            }
            
            //VRB method pick list
            var temp = result.vrbPickList;
            component.set("v.vrbPickList", result.vrbPickList);
            
            //VRB method label
            component.set("v.vrbLabelList", result.vrbLabelList);
            component.set("v.vrbCount", result.vrbCount);
            
        }).catch(function(errors){
            self.errorHandler(errors);
            console.log(errors);
        }).finally(function(){
            component.set('v.showSpinner', false);
            //component.find("accordion").set('v.activeSectionName', 'A');
        });
    },
    
    //사업심의유형 확정
    confirmData : function(component, event){
        console.log('OpprotunityReviewMainHelper confirmData');
        component.set('v.showSpinner', true);
        
        var close = $A.get("e.force:closeQuickAction");
        var refresh = $A.get('e.force:refreshView');
        
        /*변수세팅 ****************************************** */
        var varList = this.getVarLists(component, 'opptyData');
        var passYn = this.checkRule(component, varList, null);
        if (!passYn){
            component.set('v.showSpinner', false);
            return;
        }
        /* ************************************************** */
        
        //저장
        console.log('KajalTest');
        var self = this;
        self.apex(component, 'confirmBoData', {
            recordId : component.get('v.recordId'),
            inputDatas : JSON.stringify(varList)
        }).then(function(result){
            if(result.RESULT == 'S' || result.RESULT == 'I'){
                component.set("v.opptyData",result.opptyData);
                console.log('Ani Inspect New ', result);
                component.set("v.opptyData_origin",result.opptyData_origin); 
                //for Anish-v 1.4 start
                var appEvent = $A.get("e.c:RefreshActivityTabs");
                if(result.opptyData.Opportunity_Review_VRB_Type_Confirm__c == '30' && (result.opptyData.VRB_Account_Change__c==true || result.opptyData.VRB_Account_Change__c ==false) ){ //Added by Anish-v 1.5
                    appEvent.setParams({
                    isConfirmed: true,
                        isBoReviewValue: true,
                        updatedOppData: result.opptyData,
                        updatedVrb: result.opptyData.VRB_Account_Change__c,    //Added by Anish-v 1.5
                        knoxApproved : result.knoxRecord,  //Added by Anish-v 1.5
                        knxStatus : result.knxStatus //Added by Anish-v 1.5
                });
                    console.log('KAnish2Test');
                    if((result.opptyData.Collaboration__c == false && result.opptyData.CompanyCode__c == 'T100' && !(result.opptyData.cOriginAcc__r.AccountGroup__c == 'ZIC2' || result.opptyData.cOriginAcc__r.AccountGroup__c == 'ZIC'))){ //531
                        appEvent.fire();    
                    }
                }
                
                else{
                     appEvent.setParams({
                    isConfirmed: true,
                        isBoReviewValue: false,
                        updatedOppData: result.opptyData
                });
               if((result.opptyData.Collaboration__c == false && result.opptyData.CompanyCode__c == 'T100')){
                        appEvent.fire();    
                    } 
                    
                }
               
                //for Anish-v 1.4 end
                self.showToast('success', result.MESSAGE);
                console.log('Kajal1');
                if(result.opptyData.CompanyCode__c == 'T100'){ // Added By Vipul v1.4 
                    component.set('v.isModalOpenBOReviewConfirmation',true);
                }
            }else{
                self.showToast('error', result.MESSAGE);
                console.log('Kajal123');
            }
            
        }).catch(function(errors){
            self.errorHandler(errors);
        }).finally(function(){
            close.fire();
            refresh.fire();
            component.set('v.showSpinner', false);
        });
    },
    
    //모든 rule&validation 체크
    //varList : 화면의 변수값들
    //exceptRuleMap : 체크 하고싶지않은 rule들
    checkRule : function(component, varList, exceptRuleMap){
        var ruleCount = 6;
        var passYn = true;
        console.log('checkRule start');
        console.log(exceptRuleMap);
        for(var i=1; i<=ruleCount; i++){
            //체크안하고싶은 룰들 있는경우 continue
            if (exceptRuleMap!=undefined && exceptRuleMap!=null && (new String('rule'+i).localeCompare(exceptRuleMap.get('rule'+i))==0)){
                continue;
            }
            
            var resultSet = this.checkValidationSet(component, 'rule'+i, varList);
            
            //rule을 순차적으로 check하여 결과가 false이면 진행 중지
            if (!resultSet.result){
                //toast로 알림창 띄우는경우
                if (resultSet.alertMode=='toast'){
                    //alert('hi');
                    this.showToast('error', resultSet.message);
                    
                    if (resultSet.endYn){
                        passYn = passYn&&false;
                    }
                }
                //confirm창으로 물어보는 경우
                else if (resultSet.alertMode=='confirm'){
                    if (!confirm(resultSet.message)){
                        //confirm에 yes를 누르면 진행, no를 누르면 진행중지
                        passYn = passYn&&false;//no
                    }
                }
            }
            else{
                if (resultSet.alertMode=='toast'&& !$A.util.isEmpty(resultSet.message)){
                    self.showToast('success', resultSet.message);
                }
                
                passYn = passYn&&true;
            }
            
            if (!passYn){
                return passYn;
            }
        }
        
        console.log('checkRule end');
        
        return passYn;
    },
    
    //개별 validation 구현
    //ruleName : 체크하려고 하는 rule명
    //inputList : 화면의 변수값들
    checkValidationSet : function(component, ruleName, inputList){
        var endYn = true;//로직 종료 여부
        var alertMode = '';//알림창을 toast/confirm으로 띄울지 모드
        var message = '';//메세지
        var result = false;//rule 통과여부
        
        console.log('checkValidationSet['+ruleName+'] start!!!!');
        
        
        /* **************************************************************************
          [rule1]
            - 사업규모 금액 입력했는지 체크
        */
        if (ruleName == 'rule1'){
            var Opportunity_Review_Biz_Amount__c = inputList[0].Opportunity_Review_Biz_Amount__c;//사업규모
            
            if (!$A.util.isEmpty(Opportunity_Review_Biz_Amount__c) && Opportunity_Review_Biz_Amount__c > 0){
                result = true;
            }
            else{
                endYn = true;
                alertMode = 'toast';
                result = false;
                //사업규모 금액을 입력하세요
                message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_ENTER_BUDGET');
            }
        }
        /* **************************************************************************
          [rule2]
            - 컨소시엄이 아닌경우, 사업규모는 수주예상금액보다 크거나 같아야 한다
            - 컨소시엄인 경우, 사업규모는 수주예상금액보다 커야한다
        */
        else if (ruleName == 'rule2'){
            var Opportunity_Review_Consortium__c = inputList[0].Opportunity_Review_Consortium__c;//컨소시엄여부
            var Opportunity_Review_Biz_Amount__c = inputList[0].Opportunity_Review_Biz_Amount__c;//사업규모
            var Amount = inputList[0].Amount;//수주예상금액
            
            //컨소시엄 아닌경우
            if (Opportunity_Review_Consortium__c != true){
                if (Opportunity_Review_Biz_Amount__c >= Amount){
                    result = true;
                }
                else{
                    endYn = true;
                    alertMode = 'toast';
                    result = false;
                    //컨소시엄이 아닌경우, 사업규모는 수주예상금액보다 크거나 같아야 합니다
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_CHECK_CONSORTIUM_01');
                }
            }
            //컨소시엄인경우
            else{
                if (Opportunity_Review_Biz_Amount__c > Amount){
                    result = true;
                }
                else{
                    endYn = true;
                    alertMode = 'toast';
                    result = false;
                    //컨소시엄인 경우, 사업규모는 수주예상금액보다 커야 합니다
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_CHECK_CONSORTIUM_02');
                }
            }
        }
        /* **************************************************************************
          [rule3]
            - 사업심의유형 선택했는지 여부(셋중 하나 반드시 선택)
        */
            else if (ruleName == 'rule3'){
                var Opportunity_Review_VRB_Type__c = inputList[0].Opportunity_Review_VRB_Type__c;//사업심의유형(VRB Method)
                
                if ($A.util.isEmpty(Opportunity_Review_VRB_Type__c)){
                    endYn = true;
                    alertMode = 'toast';
                    result = false;
                    //사업심의 유형을 선택하세요
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_CHOOSE_REVIEW_TYPE');
                }
                else{
                    result = true;
                }
            }
        /* **************************************************************************
          [rule4]
            - Compliance 체크(둘중 하나라도 체크되어있으면 안내 Confirm을 띄워준다)
        */
            else if (ruleName == 'rule4'){
                var Opportunity_Review_Checkbox1__c = inputList[0].Opportunity_Review_Checkbox1__c;//컴플라이언스1
                var Opportunity_Review_Checkbox2__c = inputList[0].Opportunity_Review_Checkbox2__c;//컴플라이언스2
                
                
                if (Opportunity_Review_Checkbox1__c==true || Opportunity_Review_Checkbox2__c == true){
                    endYn = false;
                    alertMode = 'confirm';
                    result = false;
                    //Compliance 자가점검 및 불참업종을 체크하셨습니다. 본 BO는 Drop처리하셔야 합니다.
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_COMPLIANCE_DROP');  
                }
                else{
                    result = true;
                }
            }
        /* **************************************************************************
          [rule5]
            - BO점검결과 입력여부
        */
            else if (ruleName == 'rule5'){
                var Opportunity_Review_Result__c = inputList[0].Opportunity_Review_Result__c;//BO점검결과
                
                if ($A.util.isEmpty(Opportunity_Review_Result__c)){
                    endYn = true;
                    alertMode = 'toast';
                    result = false;
                    //BO점검결과를 입력해주세요.
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_RESULT_NULL');
                }
                else{
                    result = true;
                }
            }
        /* **************************************************************************
          [rule6]
            - Admin이면서 예외여부에 체크했을때, 예외사유 입력여부 
        */
            else if (ruleName == 'rule6'){
                var Opportunity_Review_Exception__c = inputList[0].Opportunity_Review_Exception__c;//예외여부
                var Opportunity_Review_Exception_Reason__c = inputList[0].Opportunity_Review_Exception_Reason__c;//예외사유
                var isAdmin = component.get("v.isAdmin");
                
                if (isAdmin && Opportunity_Review_Exception__c && $A.util.isEmpty(Opportunity_Review_Exception_Reason__c)){
                    endYn = true;
                    alertMode = 'toast';
                    result = false;
                    //예외사유를 입력하세요.
                    message = $A.get('$Label.c.OPPTYACT_BO_REVIEW_EXCEPTION_DESC');
                }
                else{
                    result = true;
                }
            }
        
        console.log('checkValidationSet['+ruleName+'] end with :' + result);
        
        var rtn = {"endYn"    : endYn
                   ,"alertMode": alertMode
                   ,"result"   : result
                   ,"message"  : message};
        return rtn;
    },
    
    //화면 변수 리턴
    getVarLists : function(component, varName){
        /*변수세팅 ****************************************** */
        var Opportunity_Review_Biz_Amount__c = component.get('v.'+varName+'.Opportunity_Review_Biz_Amount__c');//사업규모
        var Opportunity_Review_Checkbox1__c = component.get('v.'+varName+'.Opportunity_Review_Checkbox1__c');//Compliance 자가점검 체크박스1
        var Opportunity_Review_Checkbox2__c = component.get('v.'+varName+'.Opportunity_Review_Checkbox2__c');//Compliance 자가점검 체크박스2
        var Opportunity_Review_Result__c = component.get('v.'+varName+'.Opportunity_Review_Result__c');//점검결과
        var Opportunity_Review_Consortium__c = component.get('v.'+varName+'.Opportunity_Review_Consortium__c');//컨소시엄 여부
        var Opportunity_Review_Exception__c  = component.get('v.'+varName+'.Opportunity_Review_Exception__c');//사업심의 예외 여부
        var Opportunity_Review_Exception_Reason__c = component.get('v.'+varName+'.Opportunity_Review_Exception_Reason__c');//사업심의 예외 사유
        var Opportunity_Review_VRB_Type__c = component.get('v.'+varName+'.Opportunity_Review_VRB_Type__c');//사업심의 유형(VRB Method)
        var Opportunity_Review_Dangerous__c = component.get('v.'+varName+'.Opportunity_Review_Dangerous__c');//위험고객여부
        var Amount = component.get('v.'+varName+'.Amount');//수주예상금액
        console.log('checkBeforeClose getVarLists' + Opportunity_Review_Biz_Amount__c);
        var varList = [];
        varList.push({"Opportunity_Review_Biz_Amount__c"       : Opportunity_Review_Biz_Amount__c
                      ,"Opportunity_Review_Checkbox1__c"        : Opportunity_Review_Checkbox1__c
                      ,"Opportunity_Review_Checkbox2__c"        : Opportunity_Review_Checkbox2__c
                      ,"Opportunity_Review_Result__c"           : Opportunity_Review_Result__c
                      ,"Opportunity_Review_Consortium__c"       : Opportunity_Review_Consortium__c
                      ,"Opportunity_Review_Exception__c"        : Opportunity_Review_Exception__c
                      ,"Opportunity_Review_Exception_Reason__c" : Opportunity_Review_Exception_Reason__c
                      ,"Amount"                                 : Amount
                      ,"Opportunity_Review_VRB_Type__c"         : Opportunity_Review_VRB_Type__c
                      ,"Opportunity_Review_Dangerous__c"        : Opportunity_Review_Dangerous__c
                     });
        return varList;
    },
    
    
    //화면 종료 전 변경여부 체크
    //사용자가 변경하거나 입력한 데이터가 있을경우, confirm으로 정말 종료할것인지 물어본다
    canClose : function(component, event){
        console.log('checkBeforeClose start');
        var curList = this.getVarLists(component, 'opptyData');
        var originList = this.getVarLists(component, 'opptyData_origin');
        var cur = curList[0];
        var origin = originList[0];
        
        var checkResult = true;
        checkResult = checkResult&&(cur.Opportunity_Review_Biz_Amount__c       == origin.Opportunity_Review_Biz_Amount__c      );
        checkResult = checkResult&&(cur.Opportunity_Review_Checkbox1__c        == origin.Opportunity_Review_Checkbox1__c       );
        checkResult = checkResult&&(cur.Opportunity_Review_Checkbox2__c        == origin.Opportunity_Review_Checkbox2__c       );
        checkResult = checkResult&&(cur.Opportunity_Review_Result__c           == origin.Opportunity_Review_Result__c          );
        checkResult = checkResult&&(cur.Opportunity_Review_Consortium__c       == origin.Opportunity_Review_Consortium__c      );
        checkResult = checkResult&&(cur.Opportunity_Review_Exception__c        == origin.Opportunity_Review_Exception__c       );
        checkResult = checkResult&&(cur.Opportunity_Review_Exception_Reason__c == origin.Opportunity_Review_Exception_Reason__c);
        checkResult = checkResult&&(cur.Amount                                 == origin.Amount                                );
        checkResult = checkResult&&(cur.Opportunity_Review_VRB_Type__c         == origin.Opportunity_Review_VRB_Type__c        );
        checkResult = checkResult&&(cur.Opportunity_Review_Dangerous__c        == origin.Opportunity_Review_Dangerous__c       );
        console.log('checkResult:'+checkResult);
        
        if (!checkResult){
            //변경된 데이터가 있습니다, 종료하겠습니까?
            return confirm($A.get('$Label.c.OPPTYACT_BO_REVIEW_DATA_CHANGED'));
        }
        
        return true;
        
    },
    
    openModal: function(component){
        component.set('v.isModalOpen',true);
    },
})