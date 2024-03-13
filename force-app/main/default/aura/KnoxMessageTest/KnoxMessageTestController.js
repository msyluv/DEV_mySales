/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 09-28-2021
 * @last modified by  : zenith21c@test.com
**/

({
	init : function(component, event, helper) {
		console.log('KnoxMessageTestController init Start');

        helper.helperinit(component, event);
	},
  
	cancel : function(component, event, helper){       
		component.find("overlayLib").notifyClose();
    },
    
    onRefresh: function(Component, event, helper){
        helper.helperinit(Component, event);
    },
    
    //암호화+압축+base64인코딩 테스트
    goEncrypt2 : function(component, event, helper) {
        console.log('KnoxMessageTestController goEncrypt');
        
        helper.goEncrypt(component, event);
    },


    //Knox 인증key 조회
    knoxRegKeyRetrive2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxRegKeyRetrive2');
        
        helper.knoxRegKeyRetrive(component, event);
    },


    //Knox 대화 송신자정보 조회
    knoxSenderInfo2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxSenderInfo2');
        
        helper.knoxSenderInfo(component, event);
    },


    //Knox 대화 수신자정보 조회
    knoxReceiverInfo2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxReceiverInfo2');
        
        helper.knoxReceiverInfo(component, event);
    },


    //Knox AES256 Key 조회
    knoxAESKey2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxAESKey2');
        
        helper.knoxAESKey(component, event);
    },


    //대화방 개설요청
    knoxChatRoomRequest2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxChatRoomRequest2');
        
        helper.knoxChatRoomRequest(component, event);
    },


    //대화 요청
    knoxChatRequest2 : function(component, event, helper) {
        console.log('KnoxMessageTestController knoxChatRequest2');
        
        helper.knoxChatRequest(component, event);
    },


    //Knox App 카드 보내기
    sendKnoxAppCard2 : function(component, event, helper) {
        console.log('KnoxMessageTestController sendKnoxAppCard2');
        
        helper.sendKnoxAppCard(component, event);
    }
    
})