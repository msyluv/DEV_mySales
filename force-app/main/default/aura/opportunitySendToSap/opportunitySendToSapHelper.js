/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-12-23
 * @last modified by  : younghoon.kim@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-12-17   younghoon.kim@dkbmc.com   Initial Version
**/
({
	helperInit : function(component, event) {
		var self = this;
		self.apex(component, 'getNotice', { }
		).then(function(result){
			window.console.log('result : ', result);
			var notice = {
				'KR' : result.KR,
				'EN' : result.EN
			}
			component.set('v.notice', notice);

			if(result.CD) component.set('v.contentDocumentId', result.CD);
			// self.showMyToast('success', 'Success');
		}).catch(function(errors){
			self.errorHandler(errors);
		}).finally(function(){
			component.set('v.showSpinner', false);
		});
	},

	downloadFile : function(component, event, cdId){
		var self = this,
			vaultId = "",
			secKey = "",
			domain = "",
			docId = cdId; // 테스트용

		component.set("v.showSpinner", true);
		self.apex(component, 'getVaultFileId', { docId : docId })
		.then(function(result){
			vaultId = result.ExternalDocumentInfo2;
			return self.apex(component, 'getVaultAuthToken', { apiType : 'file-download', fileIds : [ vaultId ]});
		})
		.then(function(result){
			secKey = result.secKey;
			domain = result.domain;
			component.set("v.showSpinner", false);
			//var downloadUrl = 'https://' + domain + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + secKey;
			var downloadUrl = $A.get("$Label.c.EFSS_VAULT_FILEURL") + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + secKey;
			/**
			 * File download
			 */
			window.open(downloadUrl);
		})
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });
    },

	sendToSap : function(component, event) {
        let getEvt = component.getEvent('sendToSapEvt');
        getEvt.setParams({
            isConfirm : true
        });
        getEvt.fire();
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

	errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showMyToast('error', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showMyToast('error', 'Unknown error in javascript controller/helper.');
		}
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
	}
})