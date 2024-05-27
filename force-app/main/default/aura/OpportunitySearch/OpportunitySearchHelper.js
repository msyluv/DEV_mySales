/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2024-05-26
 * @last modified by  : akash.g@samsung.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-11-02   younghoon.kim@dkbmc.com   Initial Version
 * 1.1   2023--02-10  anish.jain@partner.samsung.com Modification for 'TA' checkbox (My Sales -125)
 * 1.2   2023-02-22   anish.jain@partner.samsung.com   Changes Added for new Search box 'Intensive BO' regarding (My Sales - 141)
 * 1.3   2024-01-04   sarthak.j1@samsung.com		   Changes added for MYSALES-385.
 * 1.4   2024-05-26   akash.g@samsung.com              Changes added for MYSALES-534
**/
({
	doInit : function(component, event) {
		var self = this;

		self.apex(component, 'defaultSetting', { 
			}).then(function(result){
				// window.console.log('result : ', result);
				var status = result.Status,
					rcdType = result.RecordType,
					service = result.Service,
					solution = result.Solution,
					collaboration = result.Collaboration,
					internalBiz = result.InternalBiz;

				// window.console.log('status : ', status);
				// window.console.log('rcdType : ', rcdType);
				// window.console.log('service : ', service);
				// window.console.log('solution : ', solution);
				// window.console.log('collaboration : ', collaboration);
				// window.console.log('internalBiz : ', internalBiz);

				component.set('v.status', status);
				component.set('v.selectedValue.Status', status[0].value);
				component.set('v.rcdType', rcdType);
				component.set('v.selectedValue.RecordType', rcdType[0].value);
				component.set('v.service', service);
				component.set('v.selectedValue.Service', service[0].value);
				component.set('v.solution', solution);
				component.set('v.selectedValue.Solution', solution[0].value);
				component.set('v.collaboration', collaboration);
				component.set('v.selectedValue.Collaboration', collaboration[0].value);
				component.set('v.internalBiz', internalBiz);
				component.set('v.selectedValue.GroupInternal', internalBiz[0].value);
                component.set('v.selectedValue.StrategicAccount', 'All'); // Added by Anish - v 1.2
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				self.getOppList(component, event, '', '');
			});

	},

	getOppList : function(component, event, rcdId, searchType) {
		var selectedValue = component.get('v.selectedValue');
        console.log('MSP Ani',component.get('v.selectedValue.MSP'));
        console.log('CSP Ani',component.get('v.selectedValue.CSP'));
        console.log('SaaS Ani',component.get('v.selectedValue.SaaS'));
        //console.log('ERP Ani',component.get('v.selectedValue.ERP'));
        //console.log('MES Ani',component.get('v.selectedValue.MES'));
        var bTechAttribute = component.get('v.techAttribute'); //Anish by Anish - v 1.1
        var CSPCheck = component.get('v.CSPCheck'); //Added by Anish - v 1.2
        var MSPCheck = component.get('v.MSPCheck'); //Added by Anish - v 1.2
        var SCPCheck = component.get('v.SCPCheck'); //Added by Anish - v 1.2
        var ERPCheck = component.get('v.ERPCheck'); //Added by Anish - v 1.2
        //Change by akash-V1.4
        var SaaSCheck = component.get('v.SaasCheck'); //Added by Anish - v 1.2
        
		
		var self = this;

		if(selectedValue.StartDate != null && selectedValue.EndDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0001")); // Please select CloseDate(End)
			component.set('v.loading', false);
			return;
		}
		
		if(selectedValue.EndDate != null && selectedValue.StartDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0002")); // Please select CloseDate(Start)
			component.set('v.loading', false);
			return;
		}
        
        //Start v 1.3
        if(selectedValue.FirstStartDate != null && selectedValue.FirstEndDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0003"));
			component.set('v.loading', false);
			return;
		}
		
		if(selectedValue.FirstEndDate != null && selectedValue.FirstStartDate == null){
			self.showMyToast('error', $A.get( "$Label.c.BOSEARCH_MSG_0004"));
			component.set('v.loading', false);
			return;
		}
        //End v 1.3

		self.apex(component, 'getOpptyList', {
			pageSize : '20', 
			rcdId : rcdId, 
			searchType : searchType, 
			selectedValue : JSON.stringify(selectedValue),
            bTechAttribute : bTechAttribute,  //Anish by Anish - v 1.1
            CSPCheck : CSPCheck, //Added by Anish - v 1.2
            MSPCheck : MSPCheck, //Added by Anish - v 1.2
            SCPCheck : SCPCheck, //Added by Anish - v 1.2 
            ERPCheck : ERPCheck, //Added by Anish - v 1.2
            SaaSCheck : SaaSCheck //Added by Anish - v 1.2 
            }).then(function(result){
            	var opptyList = JSON.parse(result.LIST);
				if(searchType == 'Prev') opptyList = JSON.parse(result.LIST).reverse();

				component.set('v.OpptyList', opptyList);

				if(searchType == ''){
					component.set('v.totalCount', result.TOTALCOUNT);
					component.set('v.totalPage', JSON.parse(result.COUNT)*1);
				}

				component.set('v.selectedCurrValue',selectedValue);
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
				component.set('v.loading', false);
			});
		
	},

	solutionInfoGet : function(component, event, serviceId){
		// window.console.log('serviceId : ', serviceId);

		var self = this;
        var bTechAttribute = component.get('v.techAttribute');
        console.log('### bTechAttribute = ' + bTechAttribute);
        console.log('### Ani serviceId = ' + serviceId);
		self.apex(component, 'getSolutionList', {
            serviceId : serviceId, bTechAttribute: bTechAttribute
			}).then(function(result){
				// window.console.log('result : ', result);
				component.set('v.solution', result);
				component.set('v.selectedValue.Solution', result[0].value);
			}).catch(function(errors){
				self.errorHandler(errors);
			}).finally(function(){
			});
	},

	scriptLoaded : function(component, event){
        var self = this;
		var selectedValue = component.get('v.selectedCurrValue');

		var opptyList = component.get('v.OpptyList') ;
		console.log('### scriptLoaded, opptyList.length > 1000:' + opptyList.length);
        console.log('### scriptLoaded, selectedValue : ' + JSON.stringify(selectedValue));
		if(opptyList.length == 0){
			self.showMyToast('warning',  $A.get("$Label.c.BOSEARCH_LAB_EXPORT_NO_OPPTY"));	//조회된 사업기회 정보가 없습니다. 1건 이상부터 다운로드가 가능합니다.
			return;
		}/* else if(opptyList.length > 1000){
			self.showMyToast('warning',  '검색 결과가 1000건 이상입니다. 리포트를 이용해주세요.');	//
			return;
		} */

		component.set('v.loading', true);
        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) monthDigit = '0' + monthDigit;
        var dayDigit = today.getDate();
        if(dayDigit <= 9) dayDigit = '0' + dayDigit;

        var todayStr = today.getFullYear() + "" + monthDigit + "" + dayDigit;
		var filename = $A.get("$Label.c.BOSEARCH_LAB_HEADER") +  '_' + todayStr;

		self.apex(component, 'generateHTML', { selectedValue : JSON.stringify(selectedValue)})
			.then(function(result){
                console.log('### scriptLoaded, result : ' + result);
                if(result.MSG == 'SUCCESS'){
                    self.saveXLSX(component, result.RESULT, filename);
                    component.set('v.loading',false);
                }else{
                    console.log('### scriptLoaded, result.MSG : ' + result.MSG);
                    component.set('v.loading',false);
                    self.showMyToast('WARNING',  result.MSG);
                }
			}).catch(function(result){
                component.set('v.loading',false);
                console.log(result.Error.message);
                console.log(result.Error.stackTrace);
                self.showMyToast('ERROR',  result.Error.message);
            });
    },

    saveXLSX : function(component, htmlBody, filename) {
        var self = this;

        html2xlsx(htmlBody, (err, file) => {
            if (err) {
                self.showMyToast("error", err);
                return console.log(err);
            } else{
                file.saveAs('blob')
                .then(function (blob) {
                    filename = filename.replace('|','_').replace('!','_').replace('?','_').replace(' ','_');
                    saveAs(blob, filename+".xlsx");
                });
                self.showToast("success", $A.get("$Label.c.BOSEARCH_LAB_EXPORT_SUCCESS"));
				component.set('v.loading',false);
           }
        });
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
                    console.log('ERROR', callbackResult.getError() ); 
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
	},

	showToast : function(type, message){
		console.log('message:' + message);
		var toastEvent = $A.get("e.force:showToast");
		var mode = (type == 'success') ? 'pester' : 'sticky';
        toastEvent.setParams({
            "type" : type,
			"message": message,
			"mode": mode,
			"duration": 5000
        });
        toastEvent.fire();
	},
	
    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 10000,
            mode: 'sticky',
            message: msg
        });
        toastEvent.fire();
	},

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.')
		}
	}
})