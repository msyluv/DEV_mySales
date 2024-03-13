/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-10-26
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-23   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2020-03-24   seonju.jin@dkbmc.com   저장된 매출부서가 폐쇄,손익부서로 전환된경우 리스트 추가하여 화면에서 보여지도록 추가
**/
({

	rowSelect:function(component){
		//선택된 row 색 변경
		component.getEvent('rowSelectEvt').setParams({'rowIndex':component.get('v.rowIndex')}).fire();
	},

	getService: function(component){
		var _cmp = component;
		var sInstance = component.get('v.sInstance');
		var boId = component.get('v.boId');
		var isCollaboration = component.get('v.isCollaboration');
		var isHQ = component.get('v.isHQ');

		var self = this;
		var svcOpt = [];
		svcOpt.push({
			label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
			value: ''
		});

		self.apex(component, 'getServiceOptions',{
			boId: boId,
			isHQ: isHQ,
			isCollaboration: isCollaboration
		}).then(function(result){
			//2021.03.24 폐쇄,손익부서로 전환된 매출부서일 경우 리스트 추가하여 화면에서 보여지도록 추가
			var idsSet = new Set();
			for(var i =0; i < result.length; i++){
				idsSet.add(result[i].Id);
			}

			var addServiceInfo = sInstance.originService;
			if(!$A.util.isEmpty(addServiceInfo.Id) && !idsSet.has(addServiceInfo.Id)){
				result.push({Id:addServiceInfo.Id, Name: addServiceInfo.Name});
				//console.log('push Service');
				//console.log(JSON.stringify(addServiceInfo));
			}
			//2021.03.24

			if(result.length != 0) {
				for(var i =0; i < result.length; i++){
					svcOpt.push({
						label: result[i].Name,
						value: result[i].Id,
						code: result[i].Code
					});
				}

			}else{
				//결과 없을경우 service정보 초기화
				sInstance.serviceId = '';
				sInstance.serviceNm = '';
				sInstance.serviceCode = '';
			}
			
			component.set('v.sInstance', sInstance);
			component.set('v.svcOpt',svcOpt);
			if(component.get('v.companyCode') == 'T100') self.getDepartment(component,sInstance.serviceId);
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			
			//self.onSvcSelect(component);
		});
	},

	onSvcSelect:function(component,event){
		var sInstance = component.get('v.sInstance');

		var selId = 'selSvc';
		var selectCmp = component.find(selId);

		sInstance.serviceId  = (sInstance.serviceId  == undefined) ? '' : sInstance.serviceId ;
		
		var serviceId = event.getParam("value");
		var serviceNm = (serviceId == '') ? '' : this.findOptionLabel(component.get('v.svcOpt'), serviceId);

		
		sInstance.serviceId = serviceId;
		sInstance.serviceNm = serviceNm;
		sInstance.serviceCode = this.getOptionCode(component.get('v.svcOpt'), serviceId);

		if(component.get('v.companyCode') == 'T100') this.getDepartment(component,serviceId);
		else component.set('v.sInstance',sInstance);

		component.getEvent("passSvcIdEvt").setParams({'serviceId' : serviceId, 'serviceIdx': component.get('v.rowIndex')}).fire();
		component.set('v.refresh',false);
		component.set('v.refresh',true);
	},

	/**
	 * SvcDlvrDept__c 조회
	 * @param {*} component 
	 * @param {*} serviceId serviceId
	 */
	getDepartment: function(component, serviceId){
		var sInstance = component.get('v.sInstance');

		var self = this;
		var deptOpt = [];
		var selected = false;


		deptOpt.push({
			label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
			value: '',
			selected : true
		});

		self.apex(component, 'getDepartmentOptions',{
			serviceId: serviceId
		}).then(function(result){
			//2021.03.24 폐쇄,손익부서로 전환된 매출부서일 경우 리스트 추가하여 화면에서 보여지도록 추가
			var deptIdSet = new Set();
			for(var i =0; i < result.length; i++){
				deptIdSet.add(result[i].Id);
			}

			if(serviceId == sInstance.originService.Id){
				var addDeptInfo = sInstance.originDept;
				if(!$A.util.isEmpty(addDeptInfo.Id) && !deptIdSet.has(addDeptInfo.Id)){
					result.push({Id:addDeptInfo.Id, CostCenterName__c: addDeptInfo.Name});
					//console.log('push dept option');
					//console.log(JSON.stringify(addDeptInfo));
				} 
			}
			//2021.03.24
			
			if(result.length != 0) {
				var selectedDeptId = '';
				var selectedDeptNm = '';

				for(var i =0; i < result.length; i++){
					if(result[i].Id == sInstance.deptRecord.Id)	{
						selected = true;
						selectedDeptId = result[i].Id;
						selectedDeptNm = result[i].CostCenterName__c;
					}
					else selected = false;

					deptOpt.push({
						label: result[i].CostCenterName__c,
						value: result[i].Id,
						selected: selected
					});
				}
				

				sInstance.deptRecord.Id = (selectedDeptId == '') ? '' : selectedDeptId;	
				sInstance.deptRecord.Name = (selectedDeptNm == '') ? '' : selectedDeptNm;

			}else{
				//결과 없을경우 department정보 초기화
				sInstance.deptRecord.Id = '';
				sInstance.deptRecord.Name = '';
			}

			component.set('v.deptOpt',deptOpt);
			component.set('v.sInstance', sInstance);
		}).catch(function(errors){
			console.log(errors);
		}).finally(function(){
			//self.onDeptSelect(component);
		});
	},

	onDeptSelect:function(component,event){
		var selId = 'selDept';
		//var selectCmp = component.find(selId);
		var departmentId = event.getParam('value');
		var departmentNm = (departmentId == '' ) ? '' : this.findOptionLabel(component.get('v.deptOpt'), departmentId);

		var sInstance = component.get('v.sInstance');
		sInstance.deptRecord.Id = departmentId;
		sInstance.deptRecord.Name = departmentNm;
		
		component.set('v.sInstance',sInstance);
	},
	
	/**
	 * customlookup td click listener
	 */
	onClickCustomlookup: function(component,event){
		try{
			this.rowSelect(component);
		}catch(e){console.log(e.toString());}
	},

	/**
	 * get selected Options Label
	 * @param {*} options 	option list
	 * @param {*} value 	option value
	 */
	findOptionLabel: function(options, value){
		var label ='';
		try{
			for(var i = 0; i < options.length; i++){
				var obj = options[i];
				if(obj.value == value) label = obj.label;
			}
		}catch(e){console.log(e.toString());}
		return label;
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