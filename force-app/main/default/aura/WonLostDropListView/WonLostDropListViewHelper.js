/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2021-11-12
 * @last modified by  : younghoon.kim@dkbmc.com
**/
({
	doInit : function(component, event) {
		window.console.log('Helper doInit');

		var self = this;
		self.apex(component, 'getFieldLabel', {

		}).then(function(result){
			component.set('v.title', result.Object); 

			var field = JSON.parse(result.Field);
			component.set('v.labels', field);

			component.set('v.columns', [
				{label : field.title__c, 				   	  fieldName : 'Id', 		    type : 'url', 	sortable: true, typeAttributes: { label: { fieldName : 'Title'/*, target: '_black' */}}},
				{label : field.opportunity_code__c,   		  fieldName : 'OpptyCode',      type : 'text', 	sortable: true},
				{label : field.opportunity__c, 	   		      fieldName : 'OpptyUrl', 	    type : 'url', 	sortable: true, typeAttributes: { label: { fieldName : 'OpptyName'/*, target: '_black' */}}}, 
				{label : field.contract_account__c,   		  fieldName : 'ContAcc', 	    type : 'text', 	sortable: true},
				{label : field.origin_account__c,     		  fieldName : 'OriginAcc',      type : 'text', 	sortable: true},
				{label : field.won_lost_drop_type__c, 		  fieldName : 'WLDType', 	    type : 'text', 	sortable: true},
				{label : field.won_lost_drop_reason_type__c,  fieldName : 'WLDReason',      type : 'text', 	sortable: true},
				{label : field.date_of_occurrence__c,  		  fieldName : 'OccurrenceDate', type : 'date', 	sortable: true},
				{label : field.sales_rep__c,  				  fieldName : 'SalesRep', 	    type : 'text', 	sortable: true},
				{label : field.ownerid,  				  	  fieldName : 'Owner', 	 	    type : 'text', 	sortable: true},
				{label : field.createddate,  				  fieldName : 'CreatedDate',    type : 'date', 	sortable: true}
			]);

			component.set('v.wldType', JSON.parse(result.WLDType));
			component.set('v.wldReasonTypeMap', JSON.parse(result.WLDReasonType));
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
			self.getData(component, event, 'INIT');
		});
	},

	getWLDReasonType : function(component, event) {
		window.console.log('Helper getWLDReasonType');

		var selectedWLDType = component.get('v.selectedValue').WLDType;
		var wldReasonTypeMap = component.get('v.wldReasonTypeMap');
		if(wldReasonTypeMap[selectedWLDType] != undefined) component.set('v.wldReasonType', wldReasonTypeMap[selectedWLDType]);
	},

	getData : function(component, event, type) {
		window.console.log('Helper getData');

		component.set('v.showSpinner', true);

		var wldList = [],
			limits = component.get('v.initialRows'),
			offsets = component.get('v.rowNumberOffset');

		if(type == 'MORE'){
			wldList = component.get('v.wldList');
			offsets = wldList.length;
		}else{
			component.set('v.totalNumberOfRows', 50);
			offsets = 0;
			component.set('v.rowNumberOffset', offsets);
			component.set('v.enableInfiniteLoading', true);
		}
		component.set('v.wldList', wldList);
		
		var selectedValue = component.get('v.selectedValue');
		var lastSelectedValue = {
			'Title' 	 	: selectedValue.Title,
			'OpptyCode'  	: selectedValue.OpptyCode,
			'WLDType'	 	: selectedValue.WLDType,
			'WLDReasonType'	: selectedValue.WLDReasonType,
			'SalesRep'		: selectedValue.SalesRep,
			'Owner' 		: selectedValue.Owner
		};
		component.set('v.lastSelectedValue', lastSelectedValue);

		var self = this;
		self.apex(component, 'getDataList', {
			limits : limits, 
			offsets : offsets,
			selectedValue : JSON.stringify(selectedValue),
			type : 'List'
		}).then(function(result){
			var recordList = JSON.parse(result.LIST),
				recordCount = result.COUNT,
				recordMsg = result.MESSAGE;

			if(type == 'INIT'){
				var count = result.COUNT * 1;
				component.set('v.totalNumberOfRows', count);
			}

			component.set('v.rowNumberOffset', offsets + recordList.length);

			if(recordMsg != 'Success'){
				var msgType = 'error';
				if(recordCount != '0') msgType = 'warning';
				self.showMyToast(msgType, recordMsg);
			}

			let hostname = window.location.hostname;

			for(var i = 0; i < recordList.length; i++){ 
				var wld = {
					'Id' 				: 'https://' + hostname + '/' + recordList[i].Id,
					'Title'				: recordList[i].Title__c,
					'OpptyId'			: recordList[i].Opportunity__c,
					'OpptyCode'			: recordList[i].Opportunity_Code__c,
					'OpptyName'			: recordList[i].Opportunity__r.Name,
					'OpptyUrl'			: 'https://' + hostname + '/' + recordList[i].Opportunity__c,
					'ContAcc'			: recordList[i].Contract_Account__c,
					'OriginAcc'			: recordList[i].Origin_Account__c,
					'WLDType'			: recordList[i].Type_Label, // Won_Lost_Drop_Type__c
					'WLDReason'			: recordList[i].Reason_Label, // Won_Lost_Drop_Reason_Type__c
					'OccurrenceDate'	: recordList[i].Date_of_occurrence__c, // Date_of_occurrence__c
					'SalesRep'			: recordList[i].Sales_Rep__c,
					'Owner'				: recordList[i].Owner.Name,
					'CreatedDate'		: recordList[i].CreatedDate
				}
				wldList.push(wld);
			}
			component.set('v.wldList', wldList);

			if(type == 'INIT'){
				if(count <= 50){
					component.set('v.enableInfiniteLoading', false);
				}
			}else if(type == 'MORE'){
				if(wldList.length >= component.get('v.totalNumberOfRows')){
					component.set('v.enableInfiniteLoading', false);
				}
			}
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
			component.set('v.showSpinner', false);
			event.getSource().set("v.isLoading", false);
			component.set('v.loadMoreStatus', '');
		});
	},

	scriptLoaded : function(component, event){
		window.console.log('Helper scriptLoaded');

		var lastSelectedValue = component.get('v.lastSelectedValue');
		var wldList = component.get('v.wldList') ;

		var self = this;
		if(wldList.length == 0){
			self.showMyToast('warning', $A.get("$Label.c.WONLOSTDROP_MSG_0003")); // The inquired order order closing information is longevity. More than one download is expected.
			return;
		}else if(wldList.length > 1000){
			self.showMyToast('warning',  $A.get("$Label.c.WONLOSTDROP_MSG_0004"));	// More than 1000 search results. Please use the report.
			return;
		}

		component.set('v.showSpinner', true);

        var today = new Date();
        var monthDigit = today.getMonth() + 1;
        if (monthDigit <= 9) monthDigit = '0' + monthDigit;
        var dayDigit = today.getDate();
        if(dayDigit <= 9) dayDigit = '0' + dayDigit;

        var todayStr = today.getFullYear() + "" + monthDigit + "" + dayDigit;
		var filename = $A.get("$Label.c.WONLOSTDROP_LAB_FILEHEADER") +  '_' + todayStr;

		self.apex(component, 'generateHTML', { 
			lastSelectedValue : JSON.stringify(lastSelectedValue)
		}).then(function(result){
			if(result.MSG == 'SUCCESS'){
				self.saveXLSX(component, result.RESULT, filename);
				component.set('v.showSpinner',false);
			}else{
				component.set('v.showSpinner',false);
				self.showMyToast('WARNING',  result.MSG);
			}
		}).catch(function(result){
			component.set('v.showSpinner',false);
			self.showMyToast('ERROR',  result.Error.message);
		});
    },

    saveXLSX : function(component, htmlBody, filename) {
		window.console.log('Helper saveXLSX');

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
                self.showMyToast("success", $A.get("$Label.c.WONLOSTDROP_MSG_0002")); // Export Success.
				component.set('v.showSpinner',false);
           }
        });
    },

	sortBy: function(field, reverse, primer) {
        var key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    },

    handleSort: function(component, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');

        var cloneData = component.get('v.wldList').slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        
        component.set('v.wldList', cloneData);
        component.set('v.sortDirection', sortDirection);
        component.set('v.sortedBy', sortedBy);
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