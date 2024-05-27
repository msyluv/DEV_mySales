/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2024-04-25
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-17   seonju.jin@dkbmc.com   Initial Version
 * 1.1	 2021-01-07	  seonju.jin@dkbmc.com	 Service, Solution 중복처리
 * 1.2   2021-02-17	  seonju.jin@dkbmc.com	 예외: 동일 서비스에 용역 솔루션(Solution Category=Professional Service) 중복 불가
 * 1.3   2021-03-14	  seonju.jin@dkbmc.com	 WBS중복체크 수정(WBSClass - > (Soltuion + WBSClass)로 중복체크)
 * 1.4   2021-05-14	  seonju.jin@dkbmc.com	 Professional Service 중복 체크 제거
 * 1.5   2021-07-07	  seonju.jin@dkbmc.com	 서비스의 솔루션정보가 없을경우 신규 행 추가
 * 1.6   2024-04-25   anish.jain@partner.samsung.com  Analysis the cause of 'Review Opportunity' issue -> [MYSALES-495]
**/
({
	REFRESH_TREEITEM:'refreshTreeItem',
	POP_SAVE_MODAL:'popupSaveModal',
	INIT_SERVICE:0,
    NORMAL_SERVICE:1,
    TECH_SERVICE:2,
	doInit : function(component) {
		var self = this;
		self.getOppty(component, component.get('v.recordId'));
	},

	/**
	 * 사업기회 정보 조회
	 * @param {*} component 
	 * @param {*} recordId opportunity Id
	 */
	getOppty: function(component, recordId){
		component.set('v.refresh',false);
		var self = this;

		var apexParams = {
			opportId: recordId,
			opptyActId: component.get('v.opptyActId')
		};
		
		self.apex(component
			, 'getOpptyInfo'
			, apexParams
		).then(function(result){
			if(!$A.util.isEmpty(result)){
				if(result.MSG == 'SUCCESS'){
					var opptyInfo = result.RESULT;
					component.set('v.isCollaboration', opptyInfo.oppty.Collaboration__c);
					component.set('v.collaboBoId', opptyInfo.oppty.CollaborationBOId__c);
					component.set('v.companyCode', ($A.util.isEmpty(opptyInfo.oppty.CompanyCode__c) ? '' : opptyInfo.oppty.CompanyCode__c));
					component.set('v.recordId', opptyInfo.oppty.Id);
					component.set('v.actStatus', opptyInfo.actStatus);
					component.set('v.locked', opptyInfo.locked);

					if(opptyInfo.oppty.Collaboration__c && opptyInfo.oppty.CompanyCode__c == 'T100') component.set('v.isHQ', true);	//T100:본사
					else component.set('v.isHQ', false);

					self.getServiceInfo(component);
				}else{
					self.errorHandler(result.MSG);
				}
			}
		}).catch(function(errors){
			self.errorHandler(errors);
		});
	},

	/**
	 * 서비스/솔루션 조회
	 * @param {*} component 
	 */
	getServiceInfo: function(component){
		component.set('v.loadInit', false);
		component.set('v.refresh', false);

		var self = this;
		var recordId = component.get('v.recordId');		//Opporutnity Record Id

		var apexParams = {
			opportId: recordId
		};

		self.apex(component
				, 'selectSvcSol'
				, apexParams
			).then(function(result){
				component.set('v.serviceList', result.serviceList);
				component.set('v.itemNumberInfo', result.itemNumberInfo);
				component.set('v.isTempSave', result.isTempSave);

			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				component.set('v.isLoading',false);		//로딩
				component.set('v.refresh', true);
				// self.refreshSvcCmp(component);
				self.initTreeItems(component);			//서비스,솔루션 treeItem init
			});
	},

	/**
	 * tree item init
	 * @param {*} component 
	 */
	initTreeItems: function(component){
		var self = this;
		var slist = component.get('v.serviceList');

		var oldItem = component.get('v.treeItem');
		var treeItem = new Array();
		var isExpanded = false;
		var name = 1;

		var oldMap = new Map();
		for(var i = 0 ; i< oldItem.length; i++){
			oldMap.set(oldItem[i].name, oldItem[i].expanded);
		}
		
		/* depth 표현
		   1: service , sales , delivery Depts
		   2: solution, attribute */
		try{
			for(var i = 0; i < slist.length; i++){
				var service = slist[i].service;								//service info
				if(!service.isDeleted){
					var solList = slist[i].solutionList;					//solutionList
					var isExpanded = false;
					if(oldMap.get(name.toString()) != undefined) isExpanded = oldMap.get(name.toString());
					isExpanded = (isExpanded) ? true : slist[i].service.checked;				//item expand
					var serviceNm = service.serviceNm;						//selected service name
					var deptNm = service.deptRecord.Name;					//selected department name
					var obj = {};											//parent tree obj
					var items = new Array();								//child tree obj
					var serviceLabel = ($A.util.isEmpty(service.serviceId)) 
											? 'Updating...' 
											: self.concatLabel(serviceNm
												, ((service.salesRecord.Name == undefined) ? '' : service.salesRecord.Name)  + ', ' + ((deptNm == undefined) ? '' : deptNm)
												,true);
	
					obj.label 		= serviceLabel;							//label
					obj.name 		= String(name++);						//tree index
					obj.expanded 	= isExpanded;							//expanded
					for(var j = 0; j < solList.length; j++){
						var solution = solList[j].solution;
						if(!solution.isDeleted){
							var cObj = {};						
							cObj.label = self.concatLabel(solution.solutionNm,solution.attributeNm,false);
							cObj.name = String(name++);
							cObj.expanded = false;				
							cObj.items = [];
							items.push(cObj);
						}
					}
					obj.items = items;										  //items
					treeItem.push(obj);
				}
			}
			component.set('v.treeItem', treeItem);
            console.log('treitem_______ '+ JSON.stringify(component.get('v.treeItem')));
		}catch(e){
			console.log(e.toString());
		}  
	},

	/**
	 * Opporutnity Activity 종료
	 * @param {*} component 
	 * @param {*} event 
	 */
	cancel : function(component, event) {
		component.find('overlayLib').notifyClose();
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get('v.recordId'),
            "slideDevName": "Details"
        });
        navEvt.fire();
	},

	refreshSvcCmp: function(component){
		component.set('v.refresh',false);
		component.set('v.refresh',true);
	},
    //505
	sendService: function(component, event,helper){ 
	var recordId = component.get('v.recordId');	
        var self = this;
		//Opporutnity RecordId
        var a = component.get('c.SendServiceMethod');	
        a.setParams({
            oppid: recordId
        });
        a.setCallback(this,function(response){
            var state =response.getState();
            if(response.getState()=='SUCCESS'){
           /* var toastEvent = $A.get("e.force.showToast");
                toastEvent.setParams({
                    "title" : "Success!",
                    "message" : "Service Sent Succesfully..."
                });
                toastEvent.fire();*/
                	self.showToast('success','SUCCESS','Service Sent Successfully...');		//interface return success message
			
            }
        });
        $A.enqueueAction(a);
    }
    ,
	/**
	 * Service Solution 저장
	 * @param {*} component 
	 * @param {*} isSendSAP SAP전송 flag
	 */
	saveServiceSolution: function(component, isSendSAP){ 
		component.set('v.pjtDisable', true);

		var self = this;
		var recordId = component.get('v.recordId');			//Opporutnity RecordId
		var serviceList = component.get('v.serviceList');	//서비스,솔루션 리스트

		var rtnObj = self.checkValidation(serviceList);		//유효성 체크

		if(rtnObj.isValid){									//유효성 체크 성공
			component.set('v.isLoading',true);

			var itemNumberList = rtnObj.solType10NumberList;
			var sol10CheckParam = {
				opptyId: recordId
				, companyCode: component.get('v.companyCode')
				, itemNumberList: itemNumberList
			}

			self.apex(component,'addSolType10Check', sol10CheckParam).then(function(sol10CheckResult){
				var solAddCheck = false;
				if(itemNumberList.length == 0 ) solAddCheck = true;
				solCheck: for(var i = 0 ; i < itemNumberList.length; i++){
					var itemNumberStr = itemNumberList[i];
					console.log('sol10CheckParam', sol10CheckResult[itemNumberStr]);
					if(!sol10CheckResult[itemNumberStr]){
						solAddCheck = false;
						break solCheck;
					}else{
						solAddCheck = true;
					}
				}

				if(solAddCheck){
					serviceList = self.clearJsonArray(serviceList);
					var apexParams = {
						opportId: recordId
						, jsonStr: JSON.stringify(serviceList)
						, isSendSAP: isSendSAP
					};

					var resultMsg =  '';			//upsert 결과
					self.apex(component
							, 'saveServiceList'
							, apexParams
					).then(function(result){
						resultMsg = result.SAVE_MSG;

						if(resultMsg != 'SAVE_SUCCESS') {
							self.showToast('error','ERROR', resultMsg);
							self.getServiceInfo(component);
							component.set('v.isLoading',false);
						}else{//임시저장 성공
							if(!isSendSAP){	 //임시저장만 한 경우
								if(resultMsg == 'SAVE_SUCCESS') self.openModel(component);
								self.getServiceInfo(component);
								component.set('v.isLoading',false);
								component.set('v.pjtDisable', false);
							}else{			//Create/Change Project 클릭한 경우 바로 onConfirmSAP진행
								if(resultMsg == 'SAVE_SUCCESS') self.onConfirmSAP(component);
							}
						}
					}).catch(function(errors){
						self.showToast('error', 'ERROR' , errors); console.log(errors);
					}).finally(function(){
						component.set('v.forceSave', false);
					});
				}else{
					//임시저장 솔루션 중 solutionType 10번 솔루션 조회
					var validItemNumberSet = new Set();
					itemNumberList.forEach(function(number){
						if(!sol10CheckResult[number]){
							validItemNumberSet.add(number);	//addSolType10Check에 해당하는 ItemNumber만 조회하기 위해 Set에 add
						}
					});

					var invalidSolInfo = '';
					var svcList = component.get('v.serviceList');
					for(var i = 0; i < svcList.length; i++){
						var service = svcList[i].service;
						if(validItemNumberSet.has(service.itemNumber) && service.isSendSAP){
							var solList = svcList[i].solutionList;
							for(var j = 0; j < solList.length; j++){
								if(!solList[j].solution.isSendSAP && solList[j].solution.solutionType == '10'){
									invalidSolInfo += '\n' + 'ItemNumber ' + service.itemNumber + '. ' + solList[j].solution.solutionNm + '/' + solList[j].solution.attributeNm + '\n';
								}
							}
						}
					}
					console.log('invalidSolInfo',invalidSolInfo);
					component.set('v.isLoading',false);
					component.set('v.pjtDisable', false);
					self.showToast('error', 'ERROR' ,'solution valid Error. ' + invalidSolInfo + $A.get('$Label.c.SOL_ERR_MSG_06'));	//Please register the solution by adding new service to register Professional Service solution.
					
				}
			});
			
		}else{
			self.showToast('error', 'ERROR' , rtnObj.msg);
			component.set('v.isLoading',false);
			component.set('v.pjtDisable', false);
		}
	},

	openModel: function(component){
		component.set('v.isModalOpen',true);
	},

	/**
	 * 유효성 검사
	 * @param {object} slist 서비스/솔루션 리스트
	 */
	checkValidation: function(slist){
		//serviceId, departmentId, solutionId, attributeId 필수값
		// 1. (서비스 + 수주부서 + 매출부서) 중복체크 - 2021.08.27 중복체크 비활성화
		// 2. 서비스하위 (솔루션 + bizAttr) 중복체크
		// 3. 서비스하위 SolutionType = 10인경우 wbsClass + solutionType 중복불가능
		// 3-1. 서비스하위 SolutionType != 10인경우 solId +wbsClass + solutionType 중복불가능

		var self = this;
		var rtnObj = { isValid : true, msg: '', solType10NumberList: []}; //solType10NumberList solutionType 10 추가 가능여부 체크하기 위한 itemNumber List
		var svcSolDuplCheckSet = new Set();	//2021.09.08 서비스 + 실행부서 + 영업부서 + 솔루션 + 사업속성 중복체크
		var valuesService = new Set();			//서비스 중복체크를 위한 변수
		var psTypeCheckSet = new Set();			// 솔루션 신규 추가 체크를 위한 set
		var psTypeCheckMap = new Map();			// 솔루션 신규 추가 체크를 위한 set
		var solDelMap = new Map();
		outer: for(var i = 0; i < slist.length; i++){
			var service = slist[i].service;
			var serviceId = service.serviceId;
			var deptId = (service.deptRecord.Id == undefined)? '' : service.deptRecord.Id;
			var salesId = (service.salesRecord.Id  == undefined)? '' : service.salesRecord.Id;

			if(!service.isDeleted){
				//service, dept, sales 빈값체크

				var newRecord = $A.util.isEmpty(service.recordId);	//신규레코드여부
				if(newRecord){	//신규

					if($A.util.isEmpty(serviceId) &&  $A.util.isEmpty(deptId) && $A.util.isEmpty(salesId)) continue;

					if(!$A.util.isEmpty(serviceId) && ( $A.util.isEmpty(deptId) || $A.util.isEmpty(salesId))){
						var emptyparam = ''/* ($A.util.isEmpty(serviceId)) ? $A.get("$Label.c.SVC_LAB_SVC") : '' */;
						emptyparam += ($A.util.isEmpty(salesId)) ? ((emptyparam.length == 0) ? '' : ',') + $A.get("$Label.c.SVC_LAB_SALES") : '';
						emptyparam += ($A.util.isEmpty(deptId)) ? ((emptyparam.length == 0) ? '' : ',') + $A.get("$Label.c.SVC_LAB_DEPT") : '';
						rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_01"),[emptyparam, service.itemNumber]);
						rtnObj.isValid = false;
						break outer;
					}
				}else{	//수정
					if($A.util.isEmpty(serviceId) || $A.util.isEmpty(deptId) || $A.util.isEmpty(salesId)){
						var emptyparam = ($A.util.isEmpty(serviceId)) ? $A.get("$Label.c.SVC_LAB_SVC") : '';
						emptyparam += ($A.util.isEmpty(salesId)) ? ((emptyparam.length == 0) ? '' : ',') + $A.get("$Label.c.SVC_LAB_SALES") : '';
						emptyparam += ($A.util.isEmpty(deptId)) ? ((emptyparam.length == 0) ? '' : ',') + $A.get("$Label.c.SVC_LAB_DEPT") : '';
						rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_01"),[emptyparam, service.itemNumber]);
						rtnObj.isValid = false;
						break outer;
					}
				}
				 
				//service + dept + sales  중복 체크 - 2021.08.27 중복체크 비활성화
				/**
				 * 2021.08.27 데이터 정합성 차원에서 같은 정보를 가진 WBS가 중복 생성되지 않게 하려는 취지였다고 합니다.
				 * 지금은 중복의 기준이 서비스에서 솔루션으로 변경이 되는 것이라 중복 서비스는 허용해도  될 것 같습니다.
				 */
				/* var duplicateValue = serviceId + salesId + deptId;
				if(valuesService.has(duplicateValue)) {
					rtnObj.isValid = false;
					rtnObj.idx = i;
					rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_02"),[service.itemNumber]);	// 	Cannot register same service in duplicate.
					break outer;
				}
				valuesService.add(duplicateValue); */
	
				//솔루션 유효성 체크
				var solutionList = slist[i].solutionList;
				var solAttrVal = '';
				var valueSolAttr = new Set();		//Solution _ Biz.Attr 중복체크를 위한 Set
				var solAttrMap = new Map();			//동일한 솔루션 정보를 찾기위한 map
				var valueWBS = new Set();			//wbsClass + solutionType + solId 키 중복체크를 위한 Set
				var valueSolType_10 = new Set();	//Solution Type 10번 중복체크를 위한 Set
				var solutionCnt= 0;
				var professionalServiceCnt = 0;		//Professional Service 중복 체크 변수
				// var professionalCheckCnt = 0;		//삭제된 솔루션 포함 Professional Service 중복 체크 변수
				for(var j = 0; j < solutionList.length; j++){
					var solution = solutionList[j].solution;
					var solId = solution.solutionId;
					var attrId = solution.attributeId;
					var wbsClass = solution.wbsClass;
					var solutionType = solution.solutionType;
					var psType = solution.psType;
					var solDelNoArray = [];						//유효성 실패한 솔루션 중 삭제할 array index 정보
	
					solutionCnt++;
					
					if(!solution.isDeleted){
						//Solution, Biz Attribute 빈값 체크
						if(($A.util.isEmpty(service.recordId) && !$A.util.isEmpty(service.serviceId)) || !$A.util.isEmpty(service.recordId)){
							if($A.util.isEmpty(solId) || $A.util.isEmpty(attrId)){
								var emptyparam2 = ($A.util.isEmpty(solId)) ? $A.get("$Label.c.SOL_LAB_SOL") : '';
								emptyparam2 += ($A.util.isEmpty(attrId)) ? ((emptyparam2.length == 0) ? '' : ',') + $A.get("$Label.c.SOL_LAB_ATTR") : '';
								
									rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_01"),[emptyparam2, service.itemNumber]);
									rtnObj.isValid = false;
									break outer;
							}
						}
							
						//Solution, Biz Attribute 중복체크
						solAttrVal = solId + attrId;
						if(valueSolAttr.has(solAttrVal)){
							rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_05"),[service.itemNumber]);	//	Solution/Biz.Attribute cannot be duplicated. At Service No {0}.
							// console.log('solAttr',solAttrMap.get(solAttrVal));
							// if((solAttrMap.get(solAttrVal) != undefined && solAttrMap.get(solAttrVal).isDeleted) || solution.isDeleted){
							// 	rtnObj.msg = '삭제된 솔루션과 동일한 솔루션을 생성할 수 없습니다.';
							// }else{
							// }
							
							rtnObj.isValid = false;
							//[TODO]삭제할 솔루션 index정보 추가.. -> 사용자가 어떤 솔루션이 이상한지 인지하고 있어햐는건 아닌지?
							// solDelNoArray.push(j);
							// solDelMap.set(service.itemNumber,solDelNoArray);
							// rtnObj.solDelMap = solDelMap;
							break outer;
						}
						valueSolAttr.add(solAttrVal);
						solAttrMap.set(solAttrVal, {itemNumber:service.itemNumber, isDeleted: solution.isDeleted});
						
						//서비스 + 실행부서 + 영업부서 + 솔루션 + 사업속성 중복체크
						var svcSolDuplVar = serviceId + deptId + salesId + solId + attrId;
						if(svcSolDuplCheckSet.has(svcSolDuplVar)){
							rtnObj.msg = self.strformat($A.get("$Label.c.SOL_ERR_MSG_05"),[service.itemNumber]);	//	Solution/Biz.Attribute cannot be duplicated. At Service No {0}.
							rtnObj.isValid = false;
							break outer;
						}
						svcSolDuplCheckSet.add(svcSolDuplVar);

						//2021.06.15 WBSClass 값이 비어있는 경우 에러처리 추가
						//console.log(solution.solutionNm);
						if($A.util.isEmpty(wbsClass)){
							rtnObj.isValid = false;
							rtnObj.msg = self.strformat($A.get("$Label.c.SOL_ERR_MSG_03"),[solution.solutionNm, service.itemNumber]);	// 	There is no WBSClass info of {0}. At Service No {1} Please contact the administrator.
							break outer;
						}

						if($A.util.isEmpty(psType)){
							rtnObj.isValid = false;
							rtnObj.msg = self.strformat($A.get("$Label.c.SOL_ERR_MSG_03"),[solution.solutionNm, service.itemNumber]);	// 	There is no WBSClass info of {0}. At Service No {1} Please contact the administrator.
							break outer;
						} 
						
						// ----- 솔루션타입 체크 로직 히스토리
						// 2021.08.02 (@김룡일 프로 요청) Professional Service 중복 불가
						// 2021.06.15 (@김보라 프로 요청) Solution TYpe =10(Professional Service)인 경우에 SolutionType + WBSClass 중복체크 추가 
						// (2021.05.14) Professional Service 중복 체크 제거
						// (2021.05.20 수정) 솔루션 타입이 10(Professional Service)은 WBSClass 중복가능 -> 로직 제외
						// (2021.05.25 수정) SolutionType이 다르면 WBSClass 같아도 등록가능 (wbsclass+ solutionType)
						// (2021.06.01) Solution 체크 추가
						// ----- 
						console.log('solutionType',solutionType);
						if(solutionType != '10'){
							// (2021.05.20) WBS중복 체크 (2021.05.20  서비스 하위 솔루션 관계없이 WBSClass 중복 안되도록 수정)
							var key = wbsClass + solutionType + solId;
							if(valueWBS.has(key)) {
								rtnObj.isValid = false;
								rtnObj.msg = self.strformat($A.get("$Label.c.SVC_ERR_MSG_03"),[service.itemNumber]);	//	You cannot register the same SolutionType and WBSClass in Service {0}.
								break outer;
							}
							valueWBS.add(key);
						}else{
							//Professional Service 중복 체크
							//2021.08.02 (@김룡일 프로 요청) 용역솔루션 중복 불가
							console.log('professionalServiceCnt',professionalServiceCnt);
							if(professionalServiceCnt > 0) {
								rtnObj.isValid = false;
								rtnObj.msg = 'ItemNumber ' + service.itemNumber + '. ' + solution.solutionNm + '/' + solution.attributeNm + '\n' + $A.get('$Label.c.SOL_ERR_MSG_06');		//Please register the solution by adding new service to register Professional Service solution.
								break outer;
							}
							professionalServiceCnt ++;
							if(service.isSendSAP && !solution.isSendSAP){		//확정된 서비스 중 신규 솔루션 추가 시
								rtnObj.solType10NumberList.push(service.itemNumber);	//solutionType 10 추가 가능여부 체크하기 위해 push
							}
							
							// WBSClass 중복체크 주석처리
							// var key = wbsClass + solutionType;
							// if(valueSolType_10.has(key)) {
							// professionalServiceCnt ++;
							// if(professionalServiceCnt > 1) {
							// 	rtnObj.isValid = false;
							// 	rtnObj.msg = self.strformat($A.get("$Label.c.SOL_ERR_MSG_02"),[service.itemNumber]);	//	Cannot register same Solution Type(Professional Service) in duplicate. At Service No {0}.
							// 	break outer;
							// }
								// valueSolType_10.add(key);
						}
					}
				}

				if(solutionCnt == 0){
					rtnObj.isValid = false;
					rtnObj.msg = self.strformat($A.get('$Label.c.SOL_ERR_MSG_01'), [service.itemNumber]);	// 	No register Souiton at Service {0}.
					break outer;
				}
			}
		}

		return rtnObj;
	},

	//Professional솔루션이 중복되지 않도록 임시저장솔루션 삭제처리
	removeSolType10: function(component, serviceList, solResultMap){
		try{
			var removeList = new Set();

			for(var key in solResultMap){
				if(!solResultMap[key]) removeList.add(key);
			}

			for(var i = 0; i < serviceList.length; i++){
				var service = serviceList[i].service;
				if(service.isSendSAP){
					var solutionList = serviceList[i].solutionList;
					if(removeList.has(service.itemNumber+'')){
						for(var j = 0; j < solutionList.length; j++){
							if(!solutionList[j].solution.isSendSAP && solutionList[j].solution.solutionType == '10'){
								if($A.util.isEmpty(solutionList[j].solution.recordId)){		// 화면에서 신규추가 솔루션 삭제
									solutionList.splice(j,1);
								}else{
									solutionList[j].solution.isDeleted = true;
								}
							}
						}

						serviceList[i].solutionList = solutionList;
					}
				}
			}

			component.set('v.serviceList',serviceList);
			this.refreshSvcCmp(component);
		}catch(e){
			console.log('removeSolType10',e);
		}
	},

	/**
	 * 저장 전 비어있는 json 삭제
	 */
	clearJsonArray: function(serviceList){
		var arrSpliceService = [];						//비어있는 json 삭제하기 위한 array
		var saveList = [];
		for(var i =0; i < serviceList.length; i++){
			if($A.util.isEmpty(serviceList[i].service.recordId) && ($A.util.isEmpty(serviceList[i].service.serviceId) 
					&& $A.util.isEmpty(serviceList[i].service.deptId) && $A.util.isEmpty(serviceList[i].service.salesId))){
				continue;
			}
			
			//Client Payload Data Limit에 맞추기위해 초기화
			serviceList[i].service.deptOpt = [];
			serviceList[i].service.deptOpt = [];
			
			var solList = serviceList[i].solutionList;
			for(var j = 0; j < solList.length; j++){
				//하위 솔루션이 수정된 경우 서비스의 플래그값 true
				if(solList[j].solution.isChanged) {serviceList[i].service.isChanged = true;}
				//Client Payload Data Limit에 맞추기위해 솔루션, 사업속성 속성정보 초기화
				solList[j].solution.attrOpt = [];
				solList[j].solution.solOpt = [];
			}

			saveList.push(serviceList[i]);
		}
		return saveList;
	},

	/**
	 * SAP 전송
	 * 전송 성공 시 status completed로 activity update
	 * @param {*} component 
	 */
	onConfirmSAP: function(component){ 
		component.set('v.pjtDisable', true);
		var self = this;
		var alertMsg = '';
		var resultMsg = '';
        console.log('AJ Entry onConfirmToSAP');
		var apexParams ={
			opprtyId: component.get('v.recordId')
		};

		self.apex(component
			, 'onConfirmToSAP'
			, apexParams
		).then(function(result){
			resultMsg = result.MSG;
			var resultChange = result.RESULT.CHANGE_PROJECT;		//IF-050 프로젝트 변경 결과
			var resultPjtCreate = result.RESULT.CREATE_PROJECT;		//IF-040 프로젝트 생성 결과
            console.log('result.RESULT',result.RESULT);
            console.log('result Ani New',result.BizType);

			if(!$A.util.isEmpty(resultPjtCreate)){
				alertMsg += resultPjtCreate.MSG + '\n';
			} 
			if(!$A.util.isEmpty(resultChange)){
				alertMsg += resultChange.MSG + '\n'
			};
           
            if(result.BizType != 'TI'){    //v 1.6
                console.log('Entered result New',result.BizType);
                var appEvent = $A.get("e.c:RefreshKnoxTabsOnBizType");
                appEvent.setParams({
                    isImplementation: true
                });
               appEvent.fire(); 
            }
            
			self.doInit(component);
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			alertMsg = alertMsg.trim();
			if(resultMsg == 'S'){
				self.showToast('success','SUCCESS',alertMsg);		//interface return success message
			}else if(resultMsg == 'W'){
				self.showToast('warning','WARNING',alertMsg);		//interface return warning message
			}else{
				if(resultMsg != 'E'){
					self.showToastSticky('error','ERROR',resultMsg);
				}else{
					self.showToastSticky('error','ERROR',alertMsg);
				}
			}
			component.set('v.isLoading', false);
			component.set('v.forceSave', false);
			component.set('v.pjtDisable', false);
			self.refreshSvcCmp(component);
		});
	},

	onEvtAction: function(component, event){
		var action = event.getParam('action');

		if(action == this.REFRESH_TREEITEM){
			this.initTreeItems(component);
		}else if(action == this.POP_SAVE_MODAL){
			this.refreshSvcCmp(component);
			component.set('v.forceSave', true);
			this.openModel(component);
			console.log('forceSave saveservice');
		}
	},

	concatLabel: function(str1, str2, isPad){
		var label = '';
		var	prefix = '';
		var	suffix = '';

		if(isPad){ prefix = '['; suffix = ']'; } 
		label += prefix;
		if(str1 != undefined && str1 != '') label += str1;
		if(str2 != undefined && str2 != '') label += ', ' + str2;

		label += suffix;
		return label;
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
				self.showToastSticky('error', 'ERROR', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showToastSticky('error', 'ERROR' ,'errors:'+ errors.message);
		}
	},

    showToast : function(type, title, message){
		var toastEvent = $A.get("e.force:showToast");
		var mode = (type == 'success') ? 'pester' : 'sticky';
        toastEvent.setParams({
            "type" : type,
            "title": title,
			"message": message,
			"mode": mode,
			"duration": 5000
        });
        toastEvent.fire();
	},

	showToastSticky : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
			"mode" : 'sticky',
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
	},

	strformat: function(source, params){
		try{
			for(var i =0; i < params.length; i++){
				source = source.replace(new RegExp("\\{" + i + "\\}", "g"), params[i]);
			}
		}catch(e){
			console.log(e);
		}
		return source;
	}
})