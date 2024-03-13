/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2022-02-08
 * @last modified by  : seonju.jin@dkbmc.com
 * 2022.01.20 seonju.jin@dkbmc.com TA 요건 변경 - 단독 TA 서비스 생성 x.단독 TA와 관련된 로직 제외
 * 
 * ***********서비스 생성 제어 조건
 * 1) TechAttribute가 false인 서비스를 선택할 수 있다.
 * 2) 사용자는 TA체크박스 선택할 수 있음
 * 3) 확정된 서비스인 경우 TA체크박스는 비활성화된다.
**/
({

	REFRESH_TREEITEM:'refreshTreeItem',	// opportunityServiceSolutionMain 컴포넌트 Event Parameter
	POP_SAVE_MODAL:'popupSaveModal',	// opportunityServiceSolutionMain 컴포넌트 Event Parameter
	initService: function(component){
		component.set('v.solRefresh',false);
		
		var serviceList =  component.get('v.serviceList');
		// var isTempSave = false;
		var svccnt = 0;
		for(var  i = 0; i < serviceList.length; i++){
			// if(!isTempSave && (!$A.util.isEmpty(serviceList[i].service.recordId) && serviceList[i].service.isChanged)) {isTempSave = true;}	 //임시저장 여부
			if(serviceList[i].service.isDeleted) continue;

			svccnt ++;	//화면에 노출된 서비스행 갯수
			if(serviceList[i].service.checked){ component.set('v.currIndex', i);}	//현재 선택된 행 Index
			if(!serviceList[i].service.isSendSAP && serviceList[i].solutionList.length == 0) 	//솔루션이 0개인 경우 솔루션 행 추가
				serviceList[i].solutionList.push(this.addRowSol(component,serviceList[i].service));	
		}

		// component.set('v.isTempSave',isTempSave);
		component.set('v.serviceList', serviceList);
		if(svccnt == 0){
			this.addRow(component);		//서비스정보가 없을경우 서비스 행 추가
		}
		this.getServiceOpt(component);	// 서비스 콤보박스 옵션 리스트 조회
	},

	/**
	 * 서비스 combobox 옵션 리스트 조회
	 */
	getServiceOpt: function(component){
		var self = this;
		
		var initOpt = [{
			label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
			value: ''
		}];

		var apexParams = {
			boId: component.get('v.collaboBoId'),
			isHQ: component.get('v.isHQ'),
			isCollaboration: component.get('v.isCollaboration')
		};

		//마스터 서비스 리스트 조회
		self.apex(component, 'getServiceOptions', apexParams
		).then(function(result){
			var svcOptList = [];
			for(var i = 0; i < result.length; i++){
				svcOptList.push({
					label: result[i].Name,
					value: result[i].Id,
					techyn: result[i].techyn,
					code: result[i].Code});
			}
			
			component.set('v.svcOpt',initOpt.concat(svcOptList));							// TA 비대상 서비스
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			component.set('v.solRefresh',true);
			var companyCode = component.get('v.companyCode');
			if(companyCode == 'T100') self.getAllDepartment(component);
		});
	},

	/**
	 * 서비스 combobox change Event
	 */
	onSvcSelectChange: function(component, event){
		this.setCurrIndex(component,event);

		var currIndex = component.get('v.currIndex');
		var serviceList = component.get('v.serviceList');
		var service = serviceList[currIndex].service;
		var serviceId = event.getParam("value");
		var svcOpt = component.get('v.svcOpt');
		var serviceNm = (serviceId == '') ? '' : this.findOptionLabel(svcOpt, serviceId);
		var companyCode = component.get('v.companyCode');

		service.serviceId = serviceId;
		service.serviceNm = serviceNm;
		service.serviceCode = this.getOptionCode(svcOpt, serviceId);

		if(companyCode == 'T100'){
			this.getDepartment(component,serviceId, currIndex);
		}
		component.set('v.serviceList',serviceList);

		this.refresh(component);
		this.solRefresh(component);
		this.sendMainEvt(component,this.REFRESH_TREEITEM);	//Main 컴포넌트 Tree Item 업데이트
	},

	/**
	 * v.techService attribute change handler
	 */
	forceChangeTA: function(component, oldVal, newVal){
		var oldTechService = oldVal;
		var techService = newVal;
		var serviceList = component.get('v.serviceList');
		for(var i = 0 ;i < serviceList.length; i++){
			if(oldTechService != techService){
				serviceList[i].service.serviceId = '';  
				serviceList[i].service.serviceNm = '';
				var solList = serviceList[i].solutionList;
				for(var j = 0; j < solList.length; j++){
					solList[j].solution.serviceId = '';
				}
			}
		}

		component.set('v.serviceList', serviceList);
		this.solRefresh(component);
		this.sendMainEvt(component,this.REFRESH_TREEITEM);	//Main 컴포넌트 Tree Item 업데이트
	},

	/**
	 * 화면의 서비스 하위 부서정보 조회
	 */
	getAllDepartment: function(component){
		var self = this;
		var serviceList = component.get('v.serviceList');
		var svcIdList = [];
		for(var i = 0 ; i < serviceList.length; i++){
			if(!$A.util.isEmpty(serviceList[i].service.serviceId)) svcIdList.push(serviceList[i].service.serviceId);
		}

		var apexParams = {
			svcIdList: svcIdList
		};

		self.apex(component, 'getDepartmentOptions',apexParams).then(function(result){
			for(var i = 0 ; i < serviceList.length; i++){
				if(serviceList[i].service.isDeleted) continue;

				var svc = serviceList[i].service;
				var svcId = svc.serviceId;
				var deptOpt = [];

				deptOpt.push({
					label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
					value: ''
				});
				var deptList = result[svcId];
				var deptIdSet = new Set();
				if(deptList){
					for(var j = 0; j < deptList.length; j++){
						deptOpt.push({
							label: deptList[j].CostCenterName__c,
							value: deptList[j].Id
						});
						deptIdSet.add(deptList[j].Id);
					}
				}

				//마이그 데이터 대응
				if(!$A.util.isEmpty(svc.originDept) && !deptIdSet.has(svc.originDept.Id)){	//현재 저장되어있는 매출부서가 deptList에 없는경우 강제 추가
					deptOpt.push({label: svc.originDept.Name, value: svc.originDept.Id});
				}
				svc.deptOpt = deptOpt;
			}
			
			component.set('v.serviceList', serviceList);
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			self.refresh(component);
		});
	},

	/**
	 * service와 관련된 영업 부서 조회
	 */
	getDepartment: function(component, serviceId, currIndex){
		var self = this;
		var serviceList = component.get('v.serviceList');
		var svcIdList = [serviceId];

		var apexParams = {
			svcIdList: svcIdList
		};

		self.apex(component, 'getDepartmentOptions',apexParams).then(function(result){
			var svc = serviceList[currIndex].service;
			var svcId = svc.serviceId;
			var svcDept = svc.departmentId;
			var deptOpt = [];
			deptOpt.push({
				label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
				value: '',
				selected : true
			});

			var findDept = false;
			var deptList = result[svcId];
			if(deptList){
				for(var i = 0; i < deptList.length; i++){
					if(!findDept && svcDept == deptList[i].Id){
						findDept = true;
					}

					deptOpt.push({
						label: deptList[i].CostCenterName__c,
						value: deptList[i].Id
					});
				}
			}
			svc.deptOpt = deptOpt;
			if(!findDept){	//검색한 부서정보리스트에 없는경우 초기화
				svc.deptRecord.Id = '';
				svc.deptRecord.Name = '';
			}
			component.set('v.serviceList', serviceList);
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			self.refresh(component);
			self.sendMainEvt(component,self.REFRESH_TREEITEM);
		});
	},

	/**
	 * Delivery Department combobox - change event
	 */
	onDeptSelectChange:function(component,event){
		this.setCurrIndex(component,event);
		var currIndex = component.get('v.currIndex');
		var serviceList = component.get('v.serviceList');
		var service = serviceList[currIndex].service;
		var departmentId = event.getParam('value');
		var departmentNm = (departmentId == '' ) ? '' : this.findOptionLabel(service.deptOpt, departmentId);

		service.deptRecord.Id = departmentId;
		service.deptRecord.Name = departmentNm;
		component.set('v.serviceList',serviceList);	
		this.sendMainEvt(component,this.REFRESH_TREEITEM);
	},

	/**
	 * 서비스 행 추가 event
	 */
	addRow: function(component){
		var self = this;
		var serviceList =  component.get('v.serviceList');
		var idx = serviceList.length;
		var itemNumber_svc = self.initSvcItemNumber(component);
		self.rowSelect(component);

		var serviceObj = {
			'service': {
					'recordId': ''					//Service__c Id
					,'itemNumber': itemNumber_svc	//ItemNumber__c
					,'serviceId': ''				//service__c
					,'serviceNm': ''				//service name
					,'salesRecord': {}
					,'deptRecord': {}
					,'checked': (serviceList.length == 0) ? true : false				//use radio button check value
					,'isDeleted': false				//삭제여부
					,'isChanged': true				//레코드 변경
					,'isSendSAP':false				//SAP 전송 여부
					,'techyn': false				//TA Flag
					,'deptOpt': []
					}
			,'solutionList':[{'solution': {'serviceRecordId' : ''
											, 'itemNumber': itemNumber_svc
											, 'recordId' : ''
											, 'serviceId' : ''				//Service__c
											, 'serviceIdx' : idx 			//use component 
											, 'solutionId': ''				//Solution__c
											, 'solutionNm': ''				//select solution name 
											, 'attributeId' : ''			//BizAttribute__c
											, 'attributeNm' : ''			//select attribute name 
											, 'isChanged' : true
											, 'isDeleted' : false
											, 'isSendSAP':false
											, 'salesType': ''
											, 'salesTypeEnable': false
											, 'wbsClass' : ''
											, 'psType': ''
											, 'solOpt': []
											, 'attrOpt': []
										}}]
		};

		serviceList.push(serviceObj);
		component.set('v.serviceList', serviceList);
		component.set('v.currIndex',serviceList.length-1);
		self.rowSelect(component);
	},

	/**
	 * 솔루션 행 추가
	 * @returns 솔루션 obj
	 */
	addRowSol: function(component, service){
		var serviceId = service.serviceId;
		var serviceRecordId = (service.recordId) ? '' : service.recordId;
		var sol = {'solution' : {'serviceRecordId' : serviceRecordId , 'recordId' : '', 'serviceIdx': component.get('v.currIndex'), 'serviceId' : serviceId
		, 'solutionId':'', 'solutionNm': '' ,'attributeId' : '', 'attributeNm' : '', 'isChanged' : true, 'isDeleted' : false
		, 'itemNumber': service.itemNumber
		, 'salesType': ''
		, 'salesTypeEnable': false
		, 'isSendSAP': false
		, 'wbsClass' : ''
		, 'psType': ''
		, 'solOpt': []
		, 'attrOpt': []}};
		return sol;
	},

	/**
	 * 서비스 행 삭제
	 */
	removeRow: function(component, idx){
		try{
            console.log('### OpportunityService :: removeRow');
			var self = this;
			var slist = component.get("v.serviceList");
			var litemNUmber = component.get('v.itemNumberInfo');
			var service = slist[idx].service;
			var recordId = service.recordId;
			var itemNumber = service.itemNumber;

			if($A.util.isEmpty(recordId)){				//새로 추가된 행은 splice
				slist.splice(idx, 1);
				for(var i =0; i < litemNUmber.length; i++){
					if(litemNUmber[i] == itemNumber) litemNUmber.splice(i,1);
				}
			}else{										//기존에 있는 데이터면 isDelete = true로 변경
				service.isDeleted = true;
				if(service.isSendSAP) service.isChanged = true;
				var solList = slist[idx].solutionList;
				var tempList = [];
				for(var i =0; i < solList.length; i++){	//하위 솔루션 삭제처리
					if($A.util.isEmpty(solList[i].solution.recordId)) continue;

					solList[i].solution.isDeleted = true;
					if(solList[i].solution.isSendSAP) solList[i].solution.isChanged = true;

					tempList.push(solList[i]);
				}
				slist[idx].solutionList = tempList;
			}
			
			component.set('v.itemNumberInfo',litemNUmber);
            //component.set("v.serviceList", []);
			component.set("v.serviceList", slist);

			//서비스 또는 솔루션이 없는 경우 행 추가
			var svcCnt = 0;
			var sendSAP = false;
			for(var i = 0; i < slist.length; i++){
				if(!slist[i].service.isDeleted) svcCnt++;
				if(slist[i].service.isSendSAP && slist[i].service.isChanged) sendSAP = true;
			}

			if(svcCnt == 0 ){
				self.addRow(component);
			}
			self.rowSelect(component);
		}catch(e){console.log(e);}
	},

	/**
	 * 서비스 행 추가시 itemNumber 채번
	 */
	initSvcItemNumber:function(component){
		var litemNumber = component.get('v.itemNumberInfo');
		var itemNumber = 10;	//default number 10
		if(litemNumber.length != 0){
			var lastInx = litemNumber.length-1;
			itemNumber = litemNumber[lastInx];
			itemNumber += 10;
		}
		litemNumber.push(itemNumber);

		component.set('v.itemNumberInfo', litemNumber);
		return itemNumber;
	},

	/**
	 * customlookup click listener
	 */
	 onClickCustomlookup: function(component,event){
		try{
			this.rowSelect(component);
		}catch(e){console.log(e.toString());}
	},

	/**
	 * TA 변경 이벤트
	 */
	onTechynChange: function(component, event){
		event.preventDefault();
		try{
			var currIndex = component.get('v.currIndex');
			var serviceList = component.get('v.serviceList');
			var service = serviceList[currIndex].service;
			var solList = serviceList[currIndex].solutionList;

			var cnt = 0;	//하위 솔루션이 없는경우 TA 변경 confirm 없이 바로 변경
			for(var i = 0 ;i < solList.length; i++){
				var sol = solList[i].solution;
				if(!sol.isDeleted && !$A.util.isEmpty(sol.solutionId)){ cnt++;}
			}
	
			var changeTA = true;
			if(cnt > 0){ changeTA = confirm($A.get("$Label.c.SVC_CHANGE_TA"));}
			
			//TA 체크박스 변경 시 하위 솔루션 모두 삭제
			if(changeTA){
				var tempSol = [];
				for(var  i = 0 ; i < solList.length; i++){
					if(!$A.util.isEmpty(solList[i].solution.recordId)){
						solList[i].solution.isDeleted = true;
						tempSol.push(solList[i]);
					}
				}
				tempSol.push(this.addRowSol(component, service));
				solList = tempSol;
				service.techyn = !service.techyn;
				serviceList[currIndex].service = service;
				serviceList[currIndex].solutionList = solList;
				component.set('v.serviceList', serviceList);
				this.solRefresh(component);
			}
		}catch(e){console.log(e);}
	},

	/**
	 * 서비스 행 선택
	 */
	rowSelect:function(component){
		try{

			var currIndex = component.get('v.currIndex');
			var  serviceList = component.get('v.serviceList');
			if(serviceList == undefined || serviceList == null) return;
	
			if(serviceList.length > 0){
				for(var i =0; i < serviceList.length; i++){
					if(i == currIndex) serviceList[i].service.checked = true;
					else serviceList[i].service.checked = false;
				}
				component.set('v.serviceList', serviceList);
			}
	
			this.sendMainEvt(component,this.REFRESH_TREEITEM);
		}catch(e){console.log(e);}
	},

	/**
	 * 현재 선택된 index 값 설정
	 */
	setCurrIndex:function(component, event){
		var itemId = event.getSource().get('v.name'); 
		component.set('v.currIndex',itemId.replace('comboSvc_',''));
		this.rowSelect(component);
	},

	handleSelect: function(component){
		this.sendMainEvt(component,this.REFRESH_TREEITEM);
	},

	/**
	 * Main 컴포넌트로 이벤트
	 * @param {*} actionName 'refreshTreeItem', 'popupSaveModal'
	 */
	sendMainEvt: function(component, actionName){
		var evt = component.getEvent('mainActEvt');
		evt.setParams({'action': actionName});
		evt.fire();
	},

	/**
	 * 선택된 옵션 label 획득
	 */
	findOptionLabel: function(options, value){
		var label ='';
		try{
			for(var i = 0; i < options.length; i++){
				var obj = options[i];
				if(obj.value == value){ label = obj.label; break;}
			}
		}catch(e){console.log(e.toString());}
		return label;
	},

	//Service Combobox 옵션의 TA 여부 획득
	getOptionTA: function(options, value){
		var techyn = false;
		try{
			for(var i = 0; i < options.length; i++){
				var obj = options[i];
				if(obj.value == value){ techyn = obj.techyn; break;}
			}
		}catch(e){console.log(e.toString());}
		return techyn;
	},

	getOptionCode: function(options, value){
		var code = '';
		try{
			for(var i = 0; i < options.length; i++){
				var obj = options[i];
				if(obj.value == value){ code = obj.code; break;}
			}
		}catch(e){console.log(e.toString());}
		return code;
	},

	//서비스 refresh component
	refresh: function(component){
		component.set('v.refresh',false);
		component.set('v.refresh',true);
	},

	//솔루션 refresh component
	solRefresh: function(component){
		component.set('v.solRefresh',false);
		component.set('v.solRefresh',true);
	},

	////////////////////////////////////////////////////////////////////////////////////////////////////////////
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
			self.showToast('error', 'ERROR' ,errors);
		}
	},

    showtoast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})