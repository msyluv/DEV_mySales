/**
 * @description       : 주소검색 helper
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-09-03
 * @last modified by  : seonju.jin@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   2020-11-03   seonju.jin@dkbmc.com   Initial Version
**/
({
	doInit : function(component, event) {
        component.set('v.gcmp',component);
        this.addPopupEventListner(component,event);
		this.getLocale(component);
		this.getUserProfile(component);
		
		
		
		
	},

	/**
	 * addPopupEventListner
	 * @description add eventlistener
	 */
	addPopupEventListner: function(component, event){
		var self = this;
        var url = $A.get("$Label.c.API_ADDR_EVENT_URL");
        
        console.log('window.isListenerSet:' + window.isListenerSet);        
        var  saveEvent = function(event){
            if(event.origin == url){
            	self.saveAccountInfo(component.get('v.gcmp'),event.data);}
		};
        
        if(!window.isListenerSet){
        	window.addEventListener("message", saveEvent, false);
        } else{
           	window.removeEventListener("message", saveEvent);
            component.set('v.gcmp',component);
            window.addEventListener("message", saveEvent, false);
		}
        /*window.addEventListener("message", function(event){
            if(event.origin == url){
                self.saveAccountInfo(component,event.data);
            }
        }, false);*/
        window.isListenerSet = true;
        
	},

	/**
	 * @description 유저 locale정보
	 * @param component 
	 */
	getLocale:  function(component){
		//getUserLocale
		var self = this;

		self.apex(component, 'getUserLocale', {
		}).then(function(result){
			console.log('locale:' + result);
			var isLocaleKR = false;
			if(result == 'ko' || result == 'ko_KR') isLocaleKR = true;
			component.set('v.isLocaleKR',isLocaleKR);
		}).catch(function(errors){
			//self.errorHandler(errors);
		});
	},
	getUserProfile: function(component){
		var self = this;

		self.apex(component, 'getUserProfile',{	
		}).then(function(result){
			console.log('userProfile:' + result);
			 if(result == 'System Administrator'|| result == '시스템 관리자' || result == 'PI (Biz. Owner)' ){
				component.set('v.userProfile',true);
			}
			
		}).catch(function(errors){

		});
	},
	open360:function(component){
		var self = this;
var recordNo = '';
		self.apex(component, 'getRecordNo',{
			recordId: component.get('v.recordId')
		}).then(function(result){
			console.log('recordNo:' + result);
			// console.log("https://mybi.sds.samsung.net/#/views/C360_16195995582260/Customer360?:alerts=no&:embed=yes&:showShareOptions=false&P_CODE=" + recordNo + "&P_L4=" + recordNo + "&P_LV=LV4")
			// window.open("https://mybi.sds.samsung.net/#/views/C360_16195995582260/Customer360?:alerts=no&:embed=yes&:showShareOptions=false&P_CODE=" + result + "&P_L4=" + result + "&P_LV=LV4");
            // 2022-04-04 / 임근형 <khjoa.lim@samsung.com>정보전략그룹(경영혁신)/삼성SDS 요청으로 URL 변경
            window.open("https://mybi.sds.samsung.net/views/C360_IT_URL_ver2/Customer360?:alerts=no&:embed=yes&:showShareOptions=false&P_CODE=" + result + "&P_L4=" + result + "&P_LV=LV4");
			
		}).catch(function(errors){

		});
		
	},
	
	openPopup:function(component){
		var cssClass = 'slds-modal_medium popupbody';
		window.open("/apex/JusoChild?recordId=" + component.get('v.recordId'), "JusoWindow", "width=570, height=420, scrollbars=yes");
		//this.showComponentModal(component,'SearchAddrMobilePopup',{recordId: component.get('v.recordId')},cssClass,null);
	},

	/**
	 * saveAccountInfo
	 * @description 검색주소 저장
	 * @param component component
	 * @param data 주소 검색결과 
	 */
	saveAccountInfo: function(component, data){
		var self = this;

		var result = JSON.parse(data);
		//console.log('result:');
		console.log(component.get('v.recordId'));
		console.log(result);
		if(result.recordId == component.get('v.recordId')){
			self.apex(component, 'saveAddress', {
				recordId: component.get('v.recordId'),
				addrInfoJson: data
			}).then(function(result){
				$A.get('e.force:refreshView').fire();
				self.showToast('success', 'SUCCESS', $A.get("$Label.c.COMM_MSG_0002"));	//성공적으로 저장되었습니다.
			}).catch(function(errors){
				self.errorHandler(errors);
			});
		}
		
	},

	showComponentModal : function(component, componentName, attributeParams, cssClass, closeCallback) {        
        $A.createComponent('c:' + componentName
            , attributeParams
            , function(content, status, errorMessage) {
				if (status === "SUCCESS") {
					component.find('overlayLib').showCustomModal({
						body: content,
						showCloseButton: true,
						cssClass: cssClass,
						closeCallback: closeCallback
					})
				} else if (status === "ERROR") {
					console.log("Error: " + errorMessage);
				}
		});
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
			self.showToast('error', 'ERROR' ,'Unknown error in javascript controller/helper.');
		}
	},

	
})