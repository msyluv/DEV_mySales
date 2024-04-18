/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : vikrant.ks@samsung.com
 * Modifications Log 
 * Ver   Date         Author            	  Modification
 * 1.0   09-22-2020   woomg@dkbmc.com   	  Initial Version
 * 1.1   02-26-2024   vikrant.ks@samsung.com      Disable "Upload Files" button for Delivery Manager Profile(MYSALES-447)
**/
({
    doInit : function(component) {
        var self = this,
            recordId = component.get("v.recordId"),
            objectName = component.get("v.sObjectName");
            
        component.set("v.showSpinner", true);
        self.apex(component, 'isCreatable', { objectName : objectName })
            .then(function(result){
                component.set("v.isCreatable", result);

                return self.apex(component, 'getRelatedFiles', { recordId : recordId });
            })
            .then(function(result){
                console.log('getRelatedFiles : ', result);
                component.set("v.contents", result);
                component.set("v.count", result.length);
                component.set("v.showSpinner", false);
            })
            .catch(function(errors){
                self.errorHander(errors);
                component.set("v.showSpinner", false);
            });
        //V1.1
        var action = component.get("c.DisableUploadButton");        
        action.setParams({"recordId":recordId});
        action.setCallback(this, function (response) { 
            var state = response.getState();
            if (state === 'SUCCESS') {
                var res = response.getReturnValue(); 
                component.set("v.isDeliveryManager", res);
            }
        });
        $A.enqueueAction(action);
        //V1.1
        
    },

    handle4LightningFiles : function(component, event){
        var self = this;
        console.log('isCreatable1 : ');
        var files = event.getSource().get("v.files");
        console.log('file detals : ', files);
        if(files && files.length > 0)
            self.uploadFiles(component, files);
    },

    handle4PlainFiles : function(component, event){
        console.log('isCreatable2 : ');
        if(event.target && event.target.files && event.target.files.length == 1){
            var self = this;
            self.uploadFiles(component, event.target.files);
        }    
    },

    /**
     * For using uploadFile to EFSS, you must regist the Urls for Vault external and internal
     * And also need to regist CSP Trusted Site with "*.samsung.net"
     */
    uploadFiles : function(component, files){
        console.log('isCreatable3 : ');
        var self = this,
            recordId = component.get("v.recordId"),
            file = files[0],
            fileName = file.name,
            fileType = file.type;
         console.log('filetype',fileType);
        component.set("v.showSpinner", true);
        self.apex(component, 'getVaultAuthToken', {
            apiType : 'file-upload',
            platform : 'web',
            fileIds  : null
        })
        .then(function(result){
            //console.log('getVaultAuthToken : ', result);
            return self.FormXHR(component, file, result);
        })
        .then(function(result){
            console.log('FormXHR : ', result);
            var vault = JSON.parse(result);
            /**
             * For using saveVaultId2Content, you must create 'External Data Source' 
             * named 'EFSS_Vault'(Simple Url type). From Setup, find 'External Data Source'
             * and create one.
             */
            return self.apex(component, 'saveVaultId2Content', { recordId : recordId, vaultId : vault.fileId, filename : fileName });
        })
        .then(function(result){
            console.log('saveVaultId2Content : ', result);
            return self.apex(component, 'getRelatedFiles', { recordId : recordId });
        })
        .then(function(result){
            console.log('getRelatedFiles : ', result);
            component.set("v.contents", result);
            component.set("v.count", result.length);
            component.set("v.showSpinner", false);
        })
        .catch(function(errors){
            self.errorHander(errors);
            component.set("v.showSpinner", false);
        });

    },

    FormXHR : function(component, file, authInfo){
        console.log('isCreatable4 : ');
        return new Promise($A.getCallback(function(resolve, reject){
            //console.log('FormXHR process...', file, authInfo);
            var formData = new FormData();
            formData.append("file", file);
            
            var formDataEntries = [];
            formData.forEach(function(value, key){
                formDataEntries.push({ key: key, value: formatValue(value) });
            });
            console.log('FormData Entries Adi : ',formDataEntries);

            var req = new XMLHttpRequest();
            //var url = 'https://' + authInfo.domain + '/vault/sds/sfdc/files?secKey='+authInfo.secKey;
            var url = $A.get("$Label.c.EFSS_VAULT_FILEURL") + '/vault/sds/sfdc/files?secKey='+authInfo.secKey;
            console.log('Form data',formData);
            console.log('urlis',url);
            req.open('POST', url);
            req.timeout = 120000;

            req.onload = function(){
                if(req.status === 200){
                    //console.log('it responded');
                    resolve(req.response);
                } else {
                    //console.log('request error ', req.response);
                    var msg = $A.get("$Label.c.EFSS_COMP_ERR_MSG_XHR_ERROR");
                    reject({
                        exceptionType: msg,
                        message: req.statusText
                    });
                }
            };
            req.onerror = function(e){
                var msg = $A.get("$Label.c.EFSS_COMP_ERR_MSG_SERVER_NOT_RESPONDED");
                reject({
                    exceptionType: 'XHR onerror',
                    message: msg
                });
            };
            req.send(formData);
        }));
        function formatValue(value){
            if(value instanceof File){
                return {name : value.name, type: value.type, size: value.size};
            } else if(typeof value === 'object' && value !== null){
                var formattedObject = {};
                for (var prop in value){
                    formattedObject[prop] = formatValue(value[prop]);
                }
                return formattedObject;
            } else{
                return value;
            }
        }
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
            if(errors.exceptionType != undefined)
                self.showMyToast('error', errors.exceptionType + " : " + errors.message);
            else {
                var msg = $A.get("$Label.c.EFSS_COMP_UNKNOWN_ERROR");
                self.showMyToast('error', msg);
            }
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