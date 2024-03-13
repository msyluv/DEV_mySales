/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-06-17
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-18   seonju.jin@dkbmc.com   Initial Version
 * 1.1   2020-01-20   seonju.jin@dkbmc.com   Sales Type 입력 가능 조건 수정
 * 1.2   2020-03-24   seonju.jin@dkbmc.com   마이그 시 폐쇄된 서비스/솔루션인경우 리스트 추가하여 화면에서 보여지도록 수정
**/
({

    doInit: function(component){
        this.getSolutionInfo(component);
    },

    rowSelect:function(component){
        component.getEvent('rowSelectEvt').setParams({'rowIndex':component.get('v.sInstance').serviceIdx}).fire();
    },

    /**
     * select Master_Solution__c
     */
    getSolutionInfo: function(component){
        
        var self = this;
        var sInstance = component.get('v.sInstance');
        var serviceId = (sInstance != undefined) ? sInstance.serviceId: '';
        var boId = component.get('v.boId');
		var isCollaboration = component.get('v.isCollaboration');
		var isHQ = component.get('v.isHQ');
        var solOpt = [];        //solution options

        solOpt.push({
			label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
            value: '',
            codeNm: ''
		});

        self.apex(component, 'getSolutionOptions',{
            serviceId: serviceId,
            boId: boId,
			isHQ: isHQ,
			isCollaboration: isCollaboration
        }).then(function(result){
            //2021.03.24 마이그 시 폐쇄된 서비스/솔루션인경우 리스트 추가하여 화면에서 보여지도록 수정
			/*var idsSet = new Set();
			for(var i =0; i < result.length; i++){
				idsSet.add(result[i].Id);
			}

			var originService = sInstance.originService;
			var addSolutionInfo = sInstance.originSolution;
            var originSolutionType = sInstance.originSolutionType;
            if(originService.Id == serviceId){
                if(!$A.util.isEmpty(addSolutionInfo.Id) && !idsSet.has(addSolutionInfo.Id)){
                    result.push({Id:addSolutionInfo.Id, Name: addSolutionInfo.Name, Code:originSolutionType.Id, CodeNm: originSolutionType.Name});
                }
            }*/

            //Solution select option 조회결과 set
            if(result.length != 0) {
                var selected = false;
                var selectedSolutionId = '';
                var selectedSolutionNm = '';
                for(var i =0; i < result.length; i++){
                    if(result[i].Id == sInstance.solutionId){
                        selected = true;
                        selectedSolutionId = result[i].Id;
                        selectedSolutionNm = result[i].Name;
                    } 
                    else selected = false;
                    solOpt.push({
                        label: result[i].Name,
                        value: result[i].Id,
                        code: result[i].Code,
                        codeNm: result[i].CodeNm,
                        otherCode: result[i].otherCode,
                        selected: selected
                    });
                }

                if(!selected){
                    sInstance.solutionId = '';
                    sInstance.solutionNm = '';
                }
                
                //set instance solution info
                sInstance.solutionId = (selectedSolutionId == '') ? '': selectedSolutionId;
                sInstance.solutionNm = (selectedSolutionNm == '') ? '' : selectedSolutionNm;
            }else{
                sInstance.solutionId = '';
                sInstance.solutionNm = '';
            }

            var findOption = self.findOptionOthers(solOpt, sInstance.solutionId);
            sInstance.solutionType = (sInstance.solutionId == '') ? '' : findOption.code;
            sInstance.solutionTypeNm = (sInstance.solutionId == '') ? '' : findOption.codeNm;
            sInstance.plcStatus =  (sInstance.solutionId == '') ? '' : findOption.otherCode.PLCStatus;
            
            

            component.set('v.solOpt',solOpt);
            component.set('v.attrOpt',[]);
            component.set('v.sInstance', sInstance);
            self.getBizAttrInfo(component, sInstance.solutionId);

        }).catch(function(errors){
            self.errorHandler(errors);
            console.log(errors);
        });
    },
    
    onSolSelectChange: function(component, event){
        var self = this;

        var solutionId = event.getParam('value');
        var solutionNm = (solutionId == '') ? '' : self.findOptionLabel(component.get('v.solOpt'), solutionId);
        var sInstance = component.get('v.sInstance');

        sInstance.solutionId = solutionId;
        sInstance.solutionNm = solutionNm;

        var findOption = self.findOptionOthers(component.get('v.solOpt'), sInstance.solutionId);
        //set solutionType
        sInstance.solutionType = (solutionId == '') ? '' : findOption.code;
        sInstance.solutionTypeNm = (solutionId == '') ? '' : findOption.codeNm;
        sInstance.plcStatus =  (solutionId == '') ? '' : findOption.otherCode.PLCStatus;
        component.set('v.sInstance',sInstance);
        self.getBizAttrInfo(component, solutionId);
        
    },

    /**
     * select SvcSolBizAttr__c 
     */
    getBizAttrInfo:function(component, solutionId){
        var sInstance = component.get('v.sInstance');
        var self = this;
        var attrOpt = [];

        try{
            self.apex(component, 'getBizAttributeOptions',{
                solutionId: solutionId
            }).then(function(result){
                //2021.03.24 마이그 시 폐쇄된 서비스/솔루션인경우 리스트 추가하여 화면에서 보여지도록 수정
                var idsSet = new Set();
                for(var i =0; i < result.length; i++){
                    idsSet.add(result[i].Id);
                }

                var originSolutionId = sInstance.originSolution.Id;
                var originAttr = sInstance.originAttribute;
                var originAttrCode = sInstance.originAttrCode;
                var originWbsClass = sInstance.originWbsClass;
                var originPsType = sInstance.originPsType;

                if(originSolutionId == solutionId){
                    if(!$A.util.isEmpty(originAttr.Id) && !idsSet.has(originAttr.Id)){
                        result.push({
                            label: originAttr.Name,
                            value: originAttr.Id,
                            code: originAttrCode,
                            wbsClass: originWbsClass,
                            psType: originPsType
                        });
                        //console.log('push originAttr');
                        //console.log(JSON.stringify(originAttr));
                    }
                }
                
                //2021.03.24

                if(result.length != 0){
                    attrOpt.push({
                        label: $A.get("$Label.c.SVC_LAB_SELOPTION"), //'Please Select Option...',
                        value: '',
                        code: '',
                        wbsClass: '',
                        psType: '',
                        selected: ''
                    });

                    var selected = false;
                    var selectedAttrId = '';
                    var selectedAttrNm = '';
                    var selectedWbsClass = '';
                    var selectedPsType = '';
                    var selectedBizType = '';

                    for(var i =0; i < result.length; i++){
                        if(result[i].Id == sInstance.attributeId){
                            selected = true;  
                            selectedAttrId = result[i].Id;
                            selectedAttrNm = result[i].Name;
                            selectedWbsClass = result[i].WBSClass;
                            selectedPsType = result[i].PSType;
                            selectedBizType = (result[i].otherCode).BizType;
                        } else  selected = false;
    
                        attrOpt.push({
                            label: result[i].Name,
                            value: result[i].Id,
                            code: result[i].Code,
                            wbsClass: result[i].WBSClass,
                            psType: result[i].PSType,
                            otherCode: result[i].otherCode, //WBSClass, PSType, BizType
                            selected: selected
                        });
                    }
                    
                    sInstance.attributeId = (selectedAttrId == '') ? '' : selectedAttrId;
                    sInstance.attributeNm = (selectedAttrNm == '') ? '' : selectedAttrNm;
                    sInstance.wbsClass = (selectedWbsClass == '') ? '' : selectedWbsClass;
                    sInstance.psType = (selectedPsType == '') ? '' : selectedPsType;
                    sInstance.bizType = (selectedBizType == '') ? '' : selectedBizType;

                    component.set('v.attrEmpty', false);
                }else{
                    sInstance.attributeId = '';
                    sInstance.attributeNm = '';
                    sInstance.wbsClass = '';
                    sInstance.psType = '';
                    sInstance.bizType = '';

                    component.set('v.attrEmpty', true);
                }

                component.set('v.attrOpt',attrOpt);
                component.set('v.sInstance', sInstance);
                self.setSalesTypeEnable(component);
            }).catch(function(errors){
                self.errorHandler(errors);
            }).finally(function(){
                //self.onAttrSelectChange(component);
                //self.setSalesTypeEnable(component);
            });
        }catch(e){console.log(e.toStirng());}
    },

    onAttrSelectChange:function(component, event){
        var selId = 'selAttr';

        try{
            var attrOpt = component.get('v.attrOpt');

            var attributeId = event.getParam('value');
            //console.log('attrId:' + attributeId);
            
            var attributeNm = (attributeId == '') ? '' : this.findOptionLabel(attrOpt, attributeId);
            var findOption = this.findOptionOthers(attrOpt, attributeId);
            var attributeWbsClass = (attributeId == '') ? '' : findOption.otherCode.WBSClass;
            var attributepsType = (attributeId == '') ? '' : findOption.otherCode.PSType;
            var attributeBizType = (attributeId == '') ? '' : findOption.otherCode.BizType;
            
            var sInstance = component.get('v.sInstance');
    
            sInstance.attributeId = attributeId;
            sInstance.attributeNm = attributeNm;
            sInstance.wbsClass = attributeWbsClass;
            sInstance.psType = attributepsType;
            sInstance.bizType = attributeBizType;
    
            component.set('v.sInstance',sInstance);
            this.setSalesTypeEnable(component);
        }catch(e){
            console.log(e);
        }


    },

    setSalesTypeEnable:function(component){
        component.set('v.salesTypeDisable', true);

        var sInstance = component.get('v.sInstance');
        var attributeCd = (this.findOptionOthers(component.get('v.attrOpt'), sInstance.attributeId)).code;
        var solutionType = sInstance.solutionType;

        
        /* 2021.01.20 Sales Type : Solution Type 이 'S/W (30)' 이고, 동시에 Biz. Attribute의 Code 값이 'S122' 또는 'S109', 'S156' 일 경우에만 입력할 수 있도록 함 */
        if(solutionType == '30' && (attributeCd == 'S109' || attributeCd == 'S122' || attributeCd == 'S156')){
            component.set('v.salesTypeDisable', false);
            this.getSalesTypeInfo(component);
        }else{
            component.set('v.salesTypeOpt',[]);
            sInstance.salesType = '';
        }
        component.set('v.sInstance',sInstance);
    },

    getSalesTypeInfo:function(component){
        var sInstance = component.get('v.sInstance');
        var self = this;
        var salesTypeOpt = [];

        self.apex(component, 'getSalesTypeOptions',{
        }).then(function(result){
            var selected = false;
            var selectedSalesType = '';
            if(result.length != 0){
                salesTypeOpt.push({
                    label: ' - ',
                    value: '',
                    selected: true
                });
                
                for(var i =0; i < result.length; i++){
                    if(result[i].Id == sInstance.salesType){
                        selected = true;  
                        selectedSalesType = result[i].Id;
                    } else  selected = false;

                    salesTypeOpt.push({
                        label: result[i].Name,
                        value: result[i].Id,
                        selected: selected
                    })
                }
                sInstance.salesType = (selectedSalesType == '') ? '' : selectedSalesType
            }else{
                sInstance.salesType = '';
            }

            component.set('v.salesTypeOpt',salesTypeOpt);
            component.set('v.sInstance', sInstance);
        }).catch(function(errors){
            console.log('errors:' + errors);
            self.errorHandler(errors);
        });
    },

    onSalesTypeSelectChange: function(component,event){
        var selId = 'selSalesType';
        //var selCmp = component.find(selId);
        var salesType  = event.getParam('value');
        var sInstance = component.get('v.sInstance');

        sInstance.salesType = salesType;
        component.set('v.sInstance',sInstance);

    },

    /**
     * get selected options label
     * @param {*} options option list
     * @param {*} value selected option value
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

    findOptionOthers: function( options, value){
        var rtnObj ={};
		try{
			for(var i = 0; i < options.length; i++){
				var obj = options[i];
				if(obj.value == value){
                    rtnObj.code = obj.code;
                    rtnObj.codeNm = obj.codeNm;
                    rtnObj.wbsClass = obj.wbsClass;
                    rtnObj.psType = obj.psType;
                    rtnObj.otherCode = obj.otherCode;
                } 
			}
		}catch(e){console.log(e.toString());}
		return rtnObj;
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