/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : zenith21c@test.com
**/

({
	helperinit : function(component, event) {
        var self = this;                
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
    
    
    //암호화+압축+base64인코딩 테스트
    goEncrypt : function(component, event){
        console.log('KnoxMessageTestHelper goEncrypt');
        
        var key = component.get('v.key');//key
        var origin = component.get('v.origin');//key
        var varList = [];
        varList.push({"key"       : key
                     ,"origin"        : origin                     
                    });
        //저장
		var self = this;
        console.log('varList -----------');
        console.log(varList);
        console.log(JSON.stringify(varList));
        console.log('varList ----------- 1');
		self.apex(component, 'goEncryptClass', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log(result);
            component.set("v.encrypted",result.encryptedData);
            component.set("v.decrytedAll",result.decStr);            
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[1]IF-147 인증key 조회
    knoxRegKeyRetrive : function(component, event){
        console.log('KnoxMessageTestHelper knoxRegKeyRetrive');
               
        var varList = [];
        var self = this;
       
		self.apex(component, 'getKnoxRegKeyValue', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- getKnoxRegKey result ----------------');
            console.log(result);
            console.log('-----------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[2]IF-148 송신자정보 조회
    knoxSenderInfo : function(component, event){
        console.log('KnoxMessageTestHelper knoxSenderInfo');
        
        var varList = [];
        var self = this;
        
		self.apex(component, 'getChatSenderInfo', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- getChatSenderInfo result ----------------');
            console.log(result);
            console.log('-----------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[3]IF-149 수신자정보 조회
    knoxReceiverInfo : function(component, event){
        console.log('KnoxMessageTestHelper knoxReceiverInfo');
        
        var varList = [];
        var self = this;
        
		self.apex(component, 'getChatReceiverInfo', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- getChatReceiverInfo result ----------------');
            console.log(result);
            console.log('-----------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[4]IF-150 AES256key 조회
    knoxAESKey : function(component, event){
        console.log('KnoxMessageTestHelper knoxAESKey');
        
        var varList = [];
        var self = this;
        varList.push({"deviceServerId"       : 1000259729                     
                    });
        
		self.apex(component, 'getAES256Key', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- getAES256Key result ----------------');
            console.log(result);
            console.log('-----------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[5]IF-145 대화방 개설 요청
    knoxChatRoomRequest : function(component, event){
        console.log('KnoxMessageTestHelper knoxChatRoomRequest');
        
        var requestId = 628;
        var chatType = 2;
        var varList = [];
        varList.push({"requestId"       : requestId
                     ,"chatType"        : chatType                     
                    });
        //저장
		var self = this;
        console.log('varList -----------');
        console.log(varList);
        console.log(JSON.stringify(varList));
        console.log('varList ----------- 1');
		self.apex(component, 'createKnoxChatRoomRequest', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- createKnoxChatRoomRequest result ----------------');
            console.log(result);
            console.log('-----------------------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},


    //[6]IF-146 대화 요청
    knoxChatRequest : function(component, event){
        console.log('KnoxMessageTestHelper knoxChatRequest');
        
        var requestId = 628;
        var chatType = 2;
        var varList = [];
        varList.push({"requestId"       : requestId
                     ,"chatType"        : chatType                     
                    });
        var self = this;
        
        self.apex(component, 'doKnoxChatRequest', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
            console.log('--------- doKnoxChatRequest result ----------------');
            console.log(result);
            console.log('-----------------------------------------------------------');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
	},



    //Knox App 카드 보내기
    sendKnoxAppCard : function(component, event){
        var varList = [];
        var self = this;
        
        self.apex(component, 'sendKnoxAppCardMessage', {
			inputDatas : JSON.stringify(varList)
		}).then(function(result){
                console.log('sendKnoxAppCardMessage result');
                console.log(result);
                
		}).catch(function(errors){
            //getKnoxRegKeyValue error
			self.errorHandler(errors);
		}).finally(function(){
            component.set('v.showSpinner', false);
        });
    }
    
})