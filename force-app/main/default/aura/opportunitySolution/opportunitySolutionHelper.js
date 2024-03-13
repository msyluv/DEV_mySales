/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2023-08-01
 * @last modified by  : divyam.gupta@samsung.com
 * 
 * 솔루션 생성 제어 
 * 1) 서비스가 TA 체크박스를 선택하지 않은 경우   - 해당 서비스에 속한 솔루션 선택 가능
 * 2) 서비스가 TA 체크박스를 선택한 경우	
 *     - 임시저장 상태일 때, 첫번째 솔루션에 모든 TA솔루션이 보여야함.
 *     - 확정이 된 상태이면 무조건 1번 기준으로만 솔루션 목록이 나오게 함
 *     - 확정 전 상태이면 1번은 전체, 2번이후부터는 자기 소속 솔루션 목록만, 1번 솔루션군이 바뀐경우는 2번 이후 행을 모두 삭제
 * V1.3  divyam.gupta@samsung.com   Mysales-267 Add validation logic for changing solution.
**/
({
	REFRESH_TREEITEM:'refreshTreeItem',
	POP_SAVE_MODAL:'popupSaveModal',
	SOLTYPE_PROFESSIONAL_SERVICE: '10',
	SOLTYPE_SW: '30',
	/**
	 * TA 대상 서비스(techService - true)는 TA 서비스 하위 솔루션정보만 나와야한다.
	 * TA 대상 서비스가 아니면서(techService - false) TA Flag true인 경우(service.techyn - true) 모든 TA 솔루션이 나와야한다.
	 * @param {*} component 
	 */
	getSolutions: function(component){
		component.set('v.isLoading',true);
		var self = this;
		
		var svcFirstIndex = component.get('v.svcFirstIndex');	// 서비스 첫번째 행 Index
		var svcIndex = component.get('v.svcIndex');				// 현재 서비스 행 Index
		component.set('v.svcFirst', (svcFirstIndex  == svcIndex));
		
		var service = component.get('v.service');
		var solList = component.get('v.solList');
		solList = self.initSolutionVal(solList);

		var getAllTA = false;
		if(service.techyn){ //service.techyn=true일 때 모든 TA 솔루션 정보가 나오도록 true
			getAllTA = true;
		}

		var apexParams = {
			serviceId		: service.serviceId,					// 상위 서비스 Id
			boId			: component.get('v.boId'),				// BO Id
			collaboBoId		: component.get('v.collaboBoId'),		// 협업 BO Id
			isHQ			: component.get('v.isHQ'),				// 협업 - 본사 여부
			isCollaboration	: component.get('v.isCollaboration'),	// 협업 여부
			getAllTA		: getAllTA								// TA 여부 (TA check 여부)
		};

		self.apex(component, 'getSolutionOptions', apexParams).then(function(result){
			var solOpt = [];
			var solTAOpt = [];
			var firstRow = false;	 //첫번째 행 여부
			var firstRowSolParentId; //첫번째 솔루션 선택한 솔루션군
			var firstRowSolId;		 //첫번째 솔루션 Id
			var isSendSAP = service.isSendSAP;	// 확정 여부

			if(!isSendSAP){
				solOpt.push({
					label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
					value: '',
					codeNm: ''
				});
			}

			if(result.length != 0) {
				for(var i = 0; i < result.length; i++){
					solOpt.push({
						label: result[i].Name,
						value: result[i].Id,
						code: result[i].Code,
						codeNm: result[i].CodeNm,
						otherCode: result[i].otherCode,
						parentId: result[i].parentId
					});
				}
			}

			/**
			 * 2021.10.08
			 * TA비대상 서비스인경우 TA Check를 했을 때
			 * 확정이 된 상태(isSendSAP = true)이면 무조건 1번 기준으로 솔루션군이 보여져야한다.
			 * 확정 전 상태(isSendSAP = false)일때 1번은 모든 TA솔루션이 나와야 한다. 2번 솔루션은 자기 소속 솔루션 군만 보여져야하고, 1번 솔루션이 변경됐을 때 2번 이후의 행은 모두 삭제처리한다.
			 */
			if(getAllTA  && isSendSAP){		// TA 솔루션이고, 확정됐을 때 하위 모든 솔루션의 combobox Options이 동일한 솔루션군만 보이도록 함.
				var firstRowSolParentId = '';
				//첫번째 row의 선택한 솔루션과 관련된 솔루션만 리스트업 되도록 설정
				if(solList.length > 0) firstRowSolParentId = (self.findOptionOthers(solOpt,solList[0].solution.solutionId)).parentId;
				for(var j = 0; j < solOpt.length; j++){
					if(solOpt[j].parentId == firstRowSolParentId){
						solTAOpt.push(solOpt[j]);
					}
				}
			}

			//솔루션 옵션 설정
			for(var i = 0; i < solList.length; i++){
				var obj = solList[i].solution;
				if(obj.isDeleted) continue;
				
				if(!getAllTA){		// 일반서비스
					obj.solOpt = solOpt;
				}else{				// TA 서비스인경우
					if(!isSendSAP){ // 임시저장상태일 때 첫번째 row의 선택한 솔루션과 관련된 솔루션군 리스트업 되도록 설정
						if(!firstRow ){
							firstRow = true;
							firstRowSolId = solList[i].solution.solutionId;
							var firstRowSolParentId = (self.findOptionOthers(solOpt,firstRowSolId)).parentId;
							
							component.set('v.solParentId', firstRowSolParentId);
							obj.solOpt = solOpt;
	
							solTAOpt = [{
								label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
								value: '',
								codeNm: ''
							}];
							for(var j = 0; j < solOpt.length; j++){
								if(solOpt[j].parentId == firstRowSolParentId){
									solTAOpt.push(solOpt[j]);
								}
							}
						} else{
							if($A.util.isEmpty(firstRowSolId)) obj.solOpt = [{ label: $A.get("$Label.c.SVC_LAB_SELOPTION"), value: '', codeNm: '' }];
							else obj.solOpt = solTAOpt;
						}
					}else{
						obj.solOpt= solTAOpt;
					}
				}

				//솔루션정보가 solOpt에 존재하지않으면 솔루션 값 초기화
				var findSolution = false;
				for(var j = 0; j < obj.solOpt.length; j++){
					var opt = obj.solOpt[j];
					if(opt.value == obj.solutionId){ findSolution = true; break;}
				}

				if(isSendSAP && !findSolution){		//마이그 데이터 대응을 위해 솔루션이 화면에 보이도록 옵션 강제 추가
					var tempObj = JSON.parse(JSON.stringify(obj.solOpt));
					if(!$A.util.isEmpty(obj.originSvcId)
						&& !$A.util.isEmpty(obj.originSolId) 
						&& !$A.util.isEmpty(obj.originSolType)){
							//console.log('마이그 데이터 대응을 위해 솔루션이 화면에 보이도록 옵션 강제 추가');
							tempObj.push({
								label: obj.originSolNm,
								value: obj.originSolId,
								code:  obj.originSolType,
								codeNm: obj.originSolTypeNm,
								otherCode: {PLCStatus : $A.util.isEmpty(obj.originPlcStatus) ? '' : obj.originPlcStatus},
								parentId: obj.originSvcId
							});
							findSolution = true;
					}

					obj.solOpt = tempObj;
				}

				if(!findSolution){
					obj.solutionId = '';
					obj.solutionNm = '';
					obj.solutionType = '';
					obj.solutionTypeNm = '';
					obj.plcStatus = '';
					obj.attributeId = '';
					obj.attributeNm = '';
					obj.wbsClass = '';
					obj.psType = '';
					obj.bizType = '';
					obj.salesType = '';
					obj.attrOpt = [];
					obj.salesTypeEnable = false;
				}
			}
			component.set('v.solList',solList);

			self.refreshSolution(component);
			self.getBizAttrAllInfo(component);
		}).catch(function(error){
			component.set('v.isLoading',false);
			console.log(error);
		});
	},

	initSolutionVal: function(solList){
		if(solList == undefined) return [];
		for(var i = 0 ;i < solList.length; i++){
			solList[i].solution.solutionComboVal = solList[i].solution.solutionId;
			solList[i].solution.solutionComboValNm = solList[i].solution.solutionNm;
		}
		return solList;
	},

	/**
	 * 솔루션 변경
	 */
	onSolSelectChange: function(component, event){
		try{
			var self = this;
			self.setCurrIndex(component,event);				//솔루션 선택 행 currIndex 설정

			var emptyObj = {};
			var solutionId = event.getParam('value');
			var currIndex = component.get('v.currIndex');
			var solList = component.get('v.solList');
			var techyn =  component.get('v.techyn');
			var isSendSAP = solList[currIndex].solution.isSendSAP;
			var prevSolId = solList[currIndex].solution.solutionId;
			var prevSolutionType = solList[currIndex].solution.solutionType;
			var solutionNm = (solutionId == '') ? '' : self.findOptionLabel(solList[currIndex].solution.solOpt, solutionId);
			var findOption = self.findOptionOthers(solList[currIndex].solution.solOpt, solutionId);
			var solType = findOption.code;

			/*
			 * Professinal Service : 10 , S/W: 30
			 * 확정된 솔루션의 solution TYpe을 Professional Service 타입으로 변경할려고 할때
			 * 제어여부 상관없이 professional 솔루션이 존재하면 professional 솔루션으로 변경 x
			*/
			var changeSolution = false;
			if(isSendSAP 
				&& solList[currIndex].solution.originSolType != self.SOLTYPE_PROFESSIONAL_SERVICE
				&& prevSolutionType != self.SOLTYPE_PROFESSIONAL_SERVICE
				&& solType == self.SOLTYPE_PROFESSIONAL_SERVICE){
				changeSolution = false;
			}else{
				changeSolution = true;
			}

			if(changeSolution){
				solList[currIndex].solution.solutionId = solutionId;
				solList[currIndex].solution.solutionNm = solutionNm;
				solList[currIndex].solution.solutionType 	= (findOption == emptyObj) ? '' : findOption.code;
				solList[currIndex].solution.solutionTypeNm  = (findOption == emptyObj) ? '' : findOption.codeNm;
				solList[currIndex].solution.plcStatus 		= (findOption == emptyObj) ? '' : findOption.otherCode.PLCStatus;
				solList[currIndex].solution.isChanged = true;
				if(!solList[currIndex].solution.isSendSAP){
					solList[currIndex].solution.attrOpt = [];
					solList[currIndex].solution.attributeId = '';
					solList[currIndex].solution.attributeNm = '';
					solList[currIndex].solution.wbsClass = '';
					solList[currIndex].solution.psType = '';
					solList[currIndex].solution.bizType = '';
					solList[currIndex].solution.salesType = '';
					solList[currIndex].solution.salesTypeEnable = false;
				} 
	
				// 첫행 솔루션 변경할 경우 나머지 솔루션 리스트업 변경(관련된 솔루션만 보이도록)
				if(!isSendSAP && techyn){
					var firstIndex = 0;
					for(var i = 0; i < solList.length; i++){
						if(solList[i].isDeleted) continue;
						firstIndex = i;
						break;
					}
		
					if(currIndex == firstIndex){
						var oldParentId = component.get('v.solParentId');
						var newParentId = (self.findOptionOthers(solList[currIndex].solution.solOpt, solList[currIndex].solution.solutionId)).parentId;
						console.log('old',oldParentId);
						console.log('new',newParentId);
						if(oldParentId != newParentId){
							solList = self.initSolutionList(solList, firstIndex);	//솔루션 첫번재 행 기준 솔루션이 변경되면 나머지 하위 솔루션 초기화
							component.set('v.solList',[]);
							console.log('refesh sol',solList);
						}
						component.set('v.solParentId',newParentId);
					}
				}
	
				component.set('v.solList',solList);

				self.getBizAttrInfo(component, solutionId, currIndex, prevSolId);
				self.setSalesTypeEnable(component, currIndex);
				self.sendMainEvt(component,self.REFRESH_TREEITEM);
			}else{
				alert($A.get('$Label.c.SOL_CHANGE_MSG'));
				//변경불가능. 이전 값으로 원복
				solList[currIndex].solution.solutionComboVal = solList[currIndex].solution.solutionId;
				solList[currIndex].solution.solutionComboValNm = solList[currIndex].solution.solutionNm;

				component.set('v.solList',solList);
			}
			if(component.get('v.techyn')) {console.log('refresh'); self.refreshSolution(component);}
		}catch(e){console.log(e);}
		
	},

	/**
	 * 하위 솔루션 초기화
	 * @returns solution List
	 */
	 initSolutionList:function(solList, firstIndex){
		var tempSolArray = [];
		console.log('solList',solList);
		for(var i = 0 ; i < solList.length; i++){
			if(i == firstIndex){
				tempSolArray.push(solList[i]);
			}else{
				if(!$A.util.isEmpty(solList[i].solution.recordId)){
					solList[i].solution.isDeleted = true;
					tempSolArray.push(solList[i]);
				}
			}
		}

		console.log('tempSolArray',tempSolArray);
		return tempSolArray;
	},

	/**
	 * 현재 모든 솔루션 행의 사업속성 옵션 리스트 조회
	 */
	getBizAttrAllInfo:function(component){
		var self = this;
		
		var solList = component.get('v.solList');
		var solIdList = [];
		for(var i = 0 ; i < solList.length; i++){
			if(!$A.util.isEmpty(solList[i].solution.solutionId)) solIdList.push(solList[i].solution.solutionId);
		}

		if(solIdList.length == 0) return;

		var apexParams = {
			solIdList: solIdList,	// 변경 할 솔루션 Id
			solPSType: '',			// 솔루션 psType
			solChangeCheck: false	// 솔루션 변경 가능 로직 체크 여부 
		};

		self.apex(component, 'getBizAttributeOptions', apexParams).then(function(result){
			var optList = [];
			for(var i  = 0 ; i < solList.length; i++){
				var solution = solList[i].solution;
				var solutionId = solList[i].solution.solutionId;
				var resultList = result.OPTIONS[solutionId];
				optList = [{
					label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
					value: '',
					code: ''
				}];
				
				if(resultList != undefined && resultList != null){
					for(var j = 0; j < resultList.length; j++){
						var opt = {
							label: resultList[j].Name,
							value: resultList[j].Id,
							code: resultList[j].Code,
							otherCode: resultList[j].otherCode
						};
						optList.push(opt);
					}
				}
				solution.attrOpt = (optList.length == 0) ? [] : optList;
			}
			component.set('v.solList',solList);
		}).finally(function(){
			//salesType init
			component.set('v.isLoading',false);
			self.setAllSalesTypeEnable(component);
		});
	},

	/**
	 * 솔루션과 관련된 사업속성 리스트 조회
	 * SAP으로 전송된 솔루션인 경우 사업속성변경 불가로, 솔루션 변경시 하위에 같은 사업속성이 없는 경우 솔루션 변경하지 못하도록 체크
	 */
	getBizAttrInfo:function(component, solutionId, currIndex, prevSolId){
		var _currIndex = currIndex;
		var _solutionId = solutionId;
		var solList = component.get('v.solList');
		var self = this;
		
		if($A.util.isEmpty(solutionId)){
			solList[_currIndex].solution.attrOpt = '';
			solList[_currIndex].solution.attributeId = '';
			solList[_currIndex].solution.attributeNm = '';
			solList[_currIndex].solution.wbsClass = '';
			solList[_currIndex].solution.psType = '';
			solList[_currIndex].solution.bizType = '';
			solList[_currIndex].solution.salesType = '';
			solList[_currIndex].solution.salesTypeEnable = false;

			component.set('v.solList',solList);
		}else{
			var solIdList = [solutionId];
			var solChangeCheck = solList[_currIndex].solution.isSendSAP;

			var apexParams = {
				solIdList: solIdList,									// 변경 할 솔루션 Id
				solPSType: solList[_currIndex].solution.psType,			// 솔루션 PsType
				solChangeCheck: solChangeCheck,							// 솔루션 변경가능 로직 체크 여부 (확정된 솔루션만 체크)
			};

			//사업속성 리스트 조회
			self.apex(component, 'getBizAttributeOptions', apexParams).then(function(result){
				var optList = [];
				var resultMsg = result.MESSAGE;

				if(!resultMsg){		//솔루션 변경 불가 이전 선택한 값으로 변경
					alert($A.get('$Label.c.SOL_CHANGE_MSG'));	//동일한 Solution Type으로만 변경 가능합니다. Solution Type이 변경될 경우 기존 솔루션을 삭제하시고 새로운 서비스를 추가하여 생성해주세요

					//이전 솔루션 값으로 변경
					var findOption = self.findOptionOthers(solList[_currIndex].solution.solOpt, prevSolId);
					var emptyObj = {};
					solList[_currIndex].solution.solutionComboVal		= prevSolId;
					solList[_currIndex].solution.solutionComboValNm 	= self.findOptionLabel(solList[_currIndex].solution.solOpt, prevSolId);
					solList[_currIndex].solution.solutionId				= prevSolId;
					solList[_currIndex].solution.solutionNm 			= self.findOptionLabel(solList[_currIndex].solution.solOpt, prevSolId);
					solList[_currIndex].solution.solutionType 			= (findOption == emptyObj) ? '' : findOption.code;
					solList[_currIndex].solution.solutionTypeNm 		= (findOption == emptyObj) ? '' : findOption.codeNm;
				}else{
					var resultList = result.OPTIONS[_solutionId];
					optList.push({
						label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
						value: '',
						code: ''
					});
					if(resultList != undefined && resultList != null){
						for(var i = 0; i < resultList.length; i++){
							var opt = {
								label: resultList[i].Name,
								value: resultList[i].Id,
								code: resultList[i].Code,
								otherCode: resultList[i].otherCode
							};
							optList.push(opt);
						}
					}
					solList[_currIndex].solution.attrOpt = (optList.length == 0) ? [] : optList;

					//사업속성 옵션리스트 설정
					var attrOpt = solList[_currIndex].solution.attrOpt;
					var findOption = false;
					for(var i = 0 ; i < attrOpt.length; i++){
						if(solList[_currIndex].solution.attributeId == attrOpt[i].value){
							findOption = true; break;
						}
					}

					if(!findOption){
						solList[_currIndex].solution.attributeId = '';
						solList[_currIndex].solution.attributeNm = '';
						solList[_currIndex].solution.wbsClass = '';
						solList[_currIndex].solution.psType = '';
						solList[_currIndex].solution.bizType = '';
						solList[_currIndex].solution.salesType = '';
						solList[_currIndex].solution.salesTypeEnable = false;
					}
				}
				component.set('v.solList',solList);
				self.sendMainEvt(component,self.REFRESH_TREEITEM);

			}).finally(function(){
				self.refreshSolution(component);	//refresh
				
			});
		}
	},

	/**
	 * Attribute Select Change event
	 */
	onAttrSelectChange:function(component, event){
		try{
			var self = this;
			
			self.setCurrIndex(component,event);
			var emptyObj = {};
			var currIndex = component.get('v.currIndex');
			var solList = component.get('v.solList');
			var attributeId = event.getParam('value');
			var attrOptList = solList[currIndex].solution.attrOpt;
			var findOption = self.findOptionOthers(attrOptList, attributeId);

			var attributeNm 		= (attributeId == '') ? '' : self.findOptionLabel(attrOptList, attributeId);
			var attributeWbsClass 	= (findOption == emptyObj) ? '' : findOption.otherCode.WBSClass;
			var attributepsType 	= (findOption == emptyObj) ? '' : findOption.otherCode.PSType;
			var attributeBizType 	= (findOption == emptyObj) ? '' : findOption.otherCode.BizType;
	
		    solList[currIndex].solution.attributeId = attributeId;
			solList[currIndex].solution.attributeNm = attributeNm;
			solList[currIndex].solution.wbsClass = attributeWbsClass;
			solList[currIndex].solution.psType = attributepsType;
			solList[currIndex].solution.bizType = attributeBizType;
			solList[currIndex].solution.isChanged = true;
            // START V1.3
            var solutiontype = solList[currIndex].solution.solutionComboVal;
            var service = component.get('v.service');
            var serviceid = service.recordId;
            console.log('serviceidval',serviceid);
             var apexParams = {
			serviceId		:  serviceid,					// 상위 서비스 Id
			boId			: component.get('v.boId'),				// BO Id
			attributeid    :  attributeId,
			solutiontype   :  solutiontype
                 // 협업 - 본사 여부
										// TA 여부 (TA check 여부)
		};
            if(serviceid != '' && serviceid != null) 
            {
            self.apex(component, 'getSolutionduplicterecord',apexParams).then(function(result){
                    console.log('resultcoiming-->',result);
            if(result == 'DupliSolrecord'){
		    self.showToast('error','ERROR',$A.get("$Label.c.SOL_DUPLICACY_MSG"));
            solList[currIndex].solution.attributeId ='';
			solList[currIndex].solution.attributeNm ='';
			solList[currIndex].solution.wbsClass ='';
			solList[currIndex].solution.psType ='';
			solList[currIndex].solution.bizType ='';
			solList[currIndex].solution.isChanged =true;
            solList[currIndex].solution.salesType ='';
    
            console.log('afterset');
            component.set('v.solList',solList);
             self.sendMainEvt(component,self.REFRESH_TREEITEM);


            }
                else {
                 component.set('v.solList',solList);
			self.setSalesTypeEnable(component, currIndex);
			self.sendMainEvt(component,self.REFRESH_TREEITEM);
                }
                

        }).catch(function(errors){
            console.log('errors:' + errors);
            self.errorHandler(errors);
        });

            }
            else {
		      console.log('sollist',solList[currIndex].solution.attributeId);
                            component.set('v.solList',solList);
			self.setSalesTypeEnable(component, currIndex);
			self.sendMainEvt(component,self.REFRESH_TREEITEM);
            }
            // END V1.3
		}catch(e){console.log(e);}
	},
	
	/**
	 * 현재 선택된 솔루션정보 SalesType Enable 여부 설정
	 */
	setSalesTypeEnable:function(component, currIndex){
		var solList = component.get('v.solList');
		var attrOptList = solList[currIndex].solution.attrOpt;
		var solution = solList[currIndex].solution;
		var attributeCd = (this.findOptionOthers(attrOptList, solution.attributeId)).code;
		var solutionType = solution.solutionType;

		if($A.util.isEmpty(attributeCd)){
			solution.salesType = '';
			solution.salesTypeEnable = false;
		}else{
			if(solutionType == this.SOLTYPE_SW && (attributeCd == 'S109' || attributeCd == 'S122' || attributeCd == 'S156')){
				solution.salesTypeEnable = true;
				solution.salesType = (solList[currIndex].solution.salesType) ? '' : solList[currIndex].solution.salesType;
			}else{
				solution.salesType = '';
				solution.salesTypeEnable = false;
			}
		}
		component.set('v.solList',solList);
		
	},

	/**
	 * 솔루션별 SalesType Enable 여부 설정
	 */
	setAllSalesTypeEnable:function(component){
		var solList = component.get('v.solList');
		for(var i = 0; i < solList.length; i++){
			var solution = solList[i].solution;
			var attrOptList = solution.attrOpt;
			var attributeCd = (this.findOptionOthers(attrOptList, solution.attributeId)).code;
			var solutionType = solution.solutionType;
	
			if(solutionType == '30' && (attributeCd == 'S109' || attributeCd == 'S122' || attributeCd == 'S156')){
				solution.salesTypeEnable = true;
			}else{
				solution.salesType = '';
				solution.salesTypeEnable = false;
			}
			var solutionType = solution.solutionType;
		}
		
		component.set('v.solList',solList);
	},

	/**
	 * getSalesTypeOptions 초기화
	 */
	getSalesTypeInfo:function(component){
        var self = this;
        var salesTypeOpt = [];

        self.apex(component, 'getSalesTypeOptions',{
        }).then(function(result){
            if(result.length != 0){
                salesTypeOpt.push({
                    label: ' - ',
                    value: ''
                });
                
                for(var i =0; i < result.length; i++){
                    salesTypeOpt.push({
                        label: result[i].Name,
                        value: result[i].Id
                    })
                }
            }

            component.set('v.salesTypeOpt',salesTypeOpt);
        }).catch(function(errors){
            console.log('errors:' + errors);
            self.errorHandler(errors);
        });
    },

	/**
	 * Sales Type 변경
	 */
	onSalesTypeSelectChange: function(component,event){
		this.setCurrIndex(component,event);
        var salesType  = event.getParam('value');
		var currIndex = component.get('v.currIndex');
        var solList = component.get('v.solList');

        solList[currIndex].solution.salesType = salesType;
		solList[currIndex].solution.isChanged = true;
        component.set('v.solList',solList);
    },

	/**
	 * 현재 선택된 index 값 설정
	 */
	rowSelect:function(component, event){
		var solItemId = event.currentTarget.getAttribute("data-itemId"); 
		component.set('v.currIndex',solItemId.replace('sol_',''));
	},

	/**
	 * 현재 선택된 index 값 설정
	 */
	setCurrIndex:function(component, event){
		var solItemId = event.getSource().get('v.name'); 
		component.set('v.currIndex',solItemId.replace('comboSol_',''));
	},

	/**
	 * 솔루션 행 추가 이벤트
	 */
	addRow:function(component){
		var svcIdx = component.get('v.svcIndex');
		var service = component.get('v.service');
		var solList = component.get('v.solList');
		try{
			var serviceId = service.serviceId;
			var serviceRecordId = (service.recordId) ? '' : service.recordId;
			//solutionObject 초기화
			var sol = {'solution' : {'serviceRecordId' : serviceRecordId , 'recordId' : '', 'serviceIdx': svcIdx, 'serviceId' : serviceId
						, 'solutionId':'', 'solutionNm': '' ,'attributeId' : '', 'attributeNm' : '', 'isChanged' : true, 'isDeleted' : false
						, 'itemNumber': service.itemNumber
						, 'salesType': ''
						, 'salesTypeEnable': false
						, 'isSendSAP': false
						, 'wbsClass' : ''
						, 'psType': ''
						, 'solOpt': []
						, 'attrOpt': []
						, 'originSvcId':''
						, 'originSolId':''
						, 'originSolNm':''
						, 'originPlcStatus':''
						, 'originSolType':''
						, 'originSolTypeNm':''}};
	
			solList.push(sol);
			service.isChanged = true;
			component.set('v.service',service);
			component.set('v.solList',solList);
			this.getSolutions(component);
		}catch(e){console.log(e.toString());}
	},

	/**
	 * 솔루션 삭제
	 */
	removeRow: function(component){
		var currIndex = component.get('v.currIndex');
		var solList = component.get('v.solList');
		var solution = solList[currIndex].solution;
		var recordId = solution.recordId;

		var cnt = 0;
		for(var i = 0 ;i < solList.length; i++){
			if(!solList[i].solution.isDeleted) cnt++;
		}

		try{
			if(cnt == 1){
				alert($A.get("$Label.c.SOL_ERR_MSG_04"));	//서비스 하위에 등록된 솔루션이 하나밖에 없습니다. 솔루션을 삭제하시려면 서비스를 삭제해 주세요
			}else{
				if($A.util.isEmpty(recordId)){			//새로 추가된 행은 splice
					solList.splice(currIndex, 1);
				}else{									//기존에 있는 데이터면 isDelete = true로 변경
					solution.isDeleted = true;
					if(solution.isSendSAP) solution.isChanged = true;
					solList[currIndex].solution = solution;
				}
			}
			
			component.set("v.solList", solList);
		}catch(e){console.log(e);}
	},

	/**
	 * @param {*} actionName refreshTreeItem, popupSaveModal
	 */
	 sendMainEvt: function(component, actionName){
		var evt = component.getEvent('mainActEvt');
		evt.setParams({'action': actionName});
		evt.fire();
	},

	/**
     * combobox옵션 label값 획득
     */
	 findOptionLabel: function(options, value){
		var label ='';
		try{
			if(!$A.util.isEmpty(options)){
				for(var i = 0; i < options.length; i++){
					var obj = options[i];
					if(obj.value == value) label = obj.label;
				}
			}
			
		}catch(e){console.log(e.toString());}
		return label;
    },

    findOptionOthers: function( options, value){
        var rtnObj ={};
		try{
			if(!$A.util.isEmpty(options)){
				for(var i = 0; i < options.length; i++){
					var obj = options[i];
					if(obj.value == value){
						rtnObj.code = $A.util.isEmpty(obj.code) ? '' : obj.code;
						rtnObj.codeNm = obj.codeNm;
						rtnObj.otherCode = $A.util.isEmpty(obj.otherCode) ? '' : obj.otherCode;
						rtnObj.parentId = obj.parentId;
					} 
				}
			}
		}catch(e){console.log(e.toString());}
		return rtnObj;
    },

	refreshSolution: function(component){
		component.set('v.refresh',false);
		component.set('v.refresh',true);
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

    showToast : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    }
})