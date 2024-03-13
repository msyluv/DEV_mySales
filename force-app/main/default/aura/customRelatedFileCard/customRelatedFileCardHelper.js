/**
 * @description       : 
 * @author            :  woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 16-10-2023
 * @last modified by  : saurav.k@partner.samsung.com
 *  Ver   Date               Author                                Modification
 * 1.0   11-10-2020         woomg@dkbmc.com                        Initial Version
 * 1.1   13-10-2023        saurav.k@partner.samsung.com            MYSALES-324
**/

({
	doInit : function(component, event) {
		var self = this,
			fileSize = component.get("v.fileSize"),
            createdDate = component.get("v.createdDate"),
            formattedFileSize = "",
            formattedFileUnit = "";

        if(fileSize > 1024 * 1024){
            var p = Math.floor(fileSize * 10 / (1024*1024));
            formattedFileSize = "" + (p / 10);
            formattedFileUnit = "MB";
        } else if(fileSize > 1024){
            var p = Math.floor(fileSize * 10 / (1024));
            formattedFileSize = "" + (p / 10);
            formattedFileUnit = "KB";
        } else {
            formattedFileSize = fileSize;
            formattedFileUnit = "Byte";
        }         
        component.set("v.formattedDate", createdDate); //v1.1 - Mysales -324
        console.log('date_____'+ component.get('v.formattedDate'));
        component.set("v.formattedFileSize", formattedFileSize);
		component.set("v.formattedFileUnit", formattedFileUnit);
		self.docType(component, event);

		var docId = component.get("v.documentId");
		component.set("v.showSpinner", true);
		self.apex(component, 'checkDeletePermission', { docId : docId })
		.then(function(result){
			//console.log('checkDeletePermission : ', result);
			component.set("v.canDelete", result);
			component.set("v.showSpinner", false);
		})
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });

	},
	
	docType : function(component, event) {
		var typeMap = {
			'csv'  : 'csv',
			'xls'  : 'excel',
			'xlsx' : 'excel',
			'htm'  : 'html',
			'html' : 'html',
			'png'  : 'image',
			'jpg'  : 'image',
			'jpeg' : 'image',
			'gif'  : 'image',
			'bmp'  : 'image',
			'pdf'  : 'pdf',
			'ppt'  : 'ppt',
			'pptx' : 'ppt',
			'psd'  : 'psd',
			'txt'  : 'txt',
			'doc'  : 'word',
			'docx' : 'word',
			'xml'  : 'xml',
			'wsdl' : 'xml',
			'zip'  : 'zip'
		};
		var extension = component.get("v.fileType"),
			fileType = "";

		if(typeMap[extension] != undefined)
			fileType = typeMap[extension];
		else
			fileType = 'unknown'
		component.set("v.formattedType", fileType);
	},

	queryFile : function(component, docId, device){
		var self = this,
			vaultId = "",
			secKey = "",
			domain = "",
			mobileUrl = "",
			isMobile = component.get("v.isMobile"),
			//urlEvent = $A.get("e.force:navigateToURL");
			urlEvent = component.find("navService");

		component.set("v.showSpinner", true);
		self.apex(component, 'getVaultFileId', { docId : docId })
		.then(function(result){
			//console.log('getVaultFileId : ', result);
			vaultId = result.ExternalDocumentInfo2;
			return self.apex(component, 'getVaultAuthToken', { apiType : 'file-view', fileIds : [ vaultId ], platform : 'mobile' });
		})
		.then(function(result){
			//console.log('getVaultAuthToken : ', result);
			secKey = result.secKey;
			domain = result.domain;
			component.set("v.showSpinner", false);
			/**
			 * Call Viewer 
			 */
			if(isMobile){
				if(device.isAndroid){
					// Call android mobile viewer
					//mobileUrl = 'intent://fileviewer#Intent;scheme=kdfileviewer;package=com.sds.drive.fileviewer;S.cc=sds;S.repo=sfdc;S.secKey='+secKey+';S.legacy=sfdc;S.browser_fallback_url=http://sdssfa--qa.my.salesforce.com;end';
					mobileUrl = 'kdfileviewer://fileviewer?cc=sds&repo=sfdc&secKey='+secKey+'&legacy=sfdc&browser_fallback_url=http://sdssfa--dev.my.salesforce.com';

				} else if(device.isIOS){
					// Call ios mobile viewer
					mobileUrl = 'kdfileviewer://FileInfo?cc=sds;legacy=sfdc;secKey='+secKey;
				}
				if(mobileUrl != ""){
					component.set("v.mobileUrl", mobileUrl);
					// urlEvent.setParams({
					// 	'url': mobileUrl
					// });
					// urlEvent.fire();	
					// window.open(mobileUrl);
					var pageRef = {
						type: "standard__webPage", 
						attributes: { 
							url: mobileUrl
						} 
					};
					urlEvent.navigate(pageRef);
					
				} else {
					// incompatible mobile browser 
					var msg = $A.get("$Label.c.EFSS_COMP_VIEWER_NOT_SUPPORTED");
					self.showMyToast("warning", msg);
				}
			} else {
				// PC viewer
				var msg = $A.get("$Label.c.EFSS_COMP_VIEWER_PC_NOT_SUPPORTED");
				self.showMyToast("warning", msg);
			}
		})
        .catch(function(errors){

            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });
	},

    downloadFile : function(component){
		var self = this,
			vaultId = "",
			secKey = "",
			domain = "",
			docId = component.get("v.documentId");

		component.set("v.showSpinner", true);
		self.apex(component, 'getVaultFileId', { docId : docId })
		.then(function(result){
			console.log('getVaultFileId : ', result);
			vaultId = result.ExternalDocumentInfo2;
			return self.apex(component, 'getVaultAuthToken', { apiType : 'file-download', fileIds : [ vaultId ], platform : 'web' });
		})
		.then(function(result){
			//console.log('getVaultAuthToken : ', result);
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

	deleteFile : function(component){
		var self = this,
			vaultId = "",
			secKey = "",
			domain = "",
			docId = component.get("v.documentId"),
			onchilddeleted = component.get("v.onchilddeleted");

		component.set("v.showSpinner", true);
		self.apex(component, 'getVaultFileId', { docId : docId })
		.then(function(result){
			//console.log('getVaultFileId : ', result);
			vaultId = result.ExternalDocumentInfo2;
			return self.apex(component, 'getVaultAuthToken', { apiType : 'file-delete', fileIds : [ vaultId ], platform : 'web' });
		})
		.then(function(result){
			//console.log('getVaultAuthToken : ', result);

			return self.fileDeleteXHR(component, vaultId, result);
		})
		.then(function(result){
			//console.log('fileDeleteXHR : ', result);

			return self.apex(component, 'deleteContentDocument', {docId : docId});
		})
		.then(function(result){
			//console.log('deleteContentDocument : ', result);
            if(onchilddeleted != null) $A.enqueueAction(onchilddeleted);
			component.set("v.showSpinner", false);
		})
		.catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });

    },

    fileDeleteXHR : function(component, vaultId, authInfo){
        return new Promise($A.getCallback(function(resolve, reject){
            //console.log('entered promise function');

            var req = new XMLHttpRequest();
            //var url = 'https://' + authInfo.domain + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + authInfo.secKey;
			var url = $A.get("$Label.c.EFSS_VAULT_FILEURL") + '/vault/sds/sfdc/files/' + vaultId + '?secKey=' + authInfo.secKey;
            req.open('DELETE', url);
            req.timeout = 120000;

            req.onload = function(){
                if(req.status === 200){
                    //console.log('it responded, file deleted.');
                    resolve(req.response);
                } else {
                    //console.log('request error ', req.response);
                    reject(Error(req.statusText));
                }
            };
            req.onerror = function(e){
				console.log('onerror -> ',e);
				var msg = $A.get("$Label.c.EFSS_COMP_DELETE_ERROR");
                reject(Error("Status : "+ req.status + msg));
            };
            req.send();
        }));
    },

    /**
     * Common Functions
     */
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

    errorHander : function(errors){
        var self = this;
        if(Array.isArray(errors)){
            errors.forEach(function(err){
                self.showMyToast('error', err.exceptionType + " : " + err.message);
            });
        } else {
			console.log(errors);
			var msg = $A.get("$Label.c.EFSS_COMP_UNKNOWN_ERROR");
            self.showMyToast('error', msg)
        }
    },

    showMyToast : function(type, msg) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            type: type,
            duration: 3000,
            mode: 'dismissible',
            message: msg
        });
        toastEvent.fire();
	},

})