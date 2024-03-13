({
    CHUNK_SIZE: 950000, /* Use a multiple of 4 */
	/**
    * fileUpload Function
    * @author       Jonggil.Kim
    * @description  File Upload Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
     1.1   11-05-2023   anish.jain@partner.samsung.com  Initial Version  - MS 216
	**/
    fileUpload : function(component, event, helper) {
		var _this = this,
            fileList = component.get('v.FileList'),
            selectFileList = event.getSource().get("v.files"),
            uploadFileList = [];
        var maximumAttachFile = component.get('v.maximumAttachFile');
        var selectFileListVault; //Anish V 1.1
        
        //Anish V 1.1
        if(!Array.isArray(selectFileList)){
            selectFileListVault = [selectFileList];
        }
		
        if(maximumAttachFile < selectFileList.length + fileList.length ){

            var message = $A.get('$Label.c.FILE_MSG_0004'); //파일 첨부는 {0}개까지 가능합니다.
            message = message.replace('{0}', maximumAttachFile);

            var toast = { 'isClose'      : false
                        , 'type'         : 'error'
                        , 'message_type' : 'ERROR'
                        , 'message'      :  message
                        , 'duration'     : 10000
                        };
            
            component.set('v.customToast',toast);
            return;

        }

        //file Validition    Anish - v 1.1     
        if(selectFileList){
                var isValidate = this.fileValidation(component, selectFileList[0]);
               
                if(isValidate){
                    var allFileSize = component.get('v.allFileSize');
                    component.set('v.allFileSize', allFileSize + selectFileList[0].size);
                    console.log('FileUpload file: '+selectFileList[0]);
                    var fileData = this.setFileData(component, selectFileList[0]);
                    //var fileData = selectFileList[i];
                    console.log('Adi log 1 : ', fileData);
                    console.log('Adi log 2 file : ', fileData.file);
                    console.log('Adi log 2-1 file : ', fileData.file.file);
                    console.log('Adi log 3 fileContents : ', fileData.fileContents);
                    fileList.push(fileData);
                    console.log('FileUpload fileList: '+fileList);
                }
            //}
        }
        
        component.set('v.FileList', fileList);
        window.console.log('Adi Logs : ', component.get('v.FileList'));
        //Start - Added by Anish-v 1.1
        if(component.get('v.activityName') == 'ZP21'){
            console.log('Ani Confo',fileList.length );
        	if(fileList.length >0){
            	console.log('Ani Confi',fileList.length );
        		var FileValidationEvent = component.getEvent("FileValidationEvent");
            	console.log('Ani Confu',fileList.length );
        		FileValidationEvent.setParams({
            		"fileFlag" :  fileList
                });
        		FileValidationEvent.fire();
                var VaultFileEvent = component.getEvent("VaultFileEvent");
            	console.log('Ani Confu1');
        		VaultFileEvent.setParams({
            		"vaultfileFlag" :  selectFileList[0]
                });
        		VaultFileEvent.fire();
        	console.log('Ani Confo');
        	}
        }
        //End - Added by Anish-v 1.1
    },

    /**
    * fileValidation Function
    * @author       Jonggil.Kim
    * @description  File fileValidation Setting [".jpg", ".jpeg", ".png", ".gif", ".html"];
    * @param        component : Component
                    file : File Data
	**/
    fileValidation : function(component, file) {
        var fileName = file.name,
            fileSize = file.size,
            fileType = file.type;
        //if(fileType){
             /*
            var fileTypeArray = fileType.split( "/" ),
                ftype = fileTypeArray[1].toLowerCase();

            if( ftype == 'gif' || ftype == 'jpg' || ftype == 'jpeg' || ftype == 'png' || ftype == 'gif' || ftype == 'html') {
                //success
            }else{
                this.alertToast(component, false, 'error', '[' + fileName +']\n정책상, 파일 업로드는 "jpg, jpeg, png, gif" 형식의 이미지 파일 또는 "HTML" 형식의 EDM 파일만 업로드 할 수 있습니다.', 3000);
                console.log('file dation');
               
                this.customToast(component, {
                    'isUrl' : false
                    , 'target' : ''
                    , 'history' : false
                    , 'type' : 'error'
                    , 'duration' : 5000
                    , 'message' : '[' + fileName +']\n정책상, 파일 업로드는 "jpg, jpeg, png, gif" 형식의 이미지 파일 또는 "HTML" 형식의 EDM 파일만 업로드 할 수 있습니다.'  
                });
               
                return false;
            }
             */
            
            var allFileSize = parseInt(component.get('v.allFileSize'));
            var maxFileSize = parseInt(component.get('v.maximumFileSize'));
            console.log(' allFileSize + fileSize  : ', allFileSize + fileSize);
            console.log(' maxFileSize   : ', maxFileSize);
            if ((allFileSize + parseInt(fileSize)) > maxFileSize) {
                var txt = $A.get('$Label.c.FILE_MSG_0007'); // 파일 첨부 제한 용량을 초과했습니다.

                console.log(' # File Size Check : ', txt );
                var toast = { 'isClose'      : false
                        , 'type'         : 'error'
                        , 'message_type' : fileName
                        , 'message'      : txt
                        , 'duration'     : 10000
                        };
            
                component.set('v.customToast',toast);
                return false;
            }
            
            
            // File Size Check (단일 파일 체크)
            /*
            if (fileSize > component.get('v.maximumFileSize')) {
                var txt =  $A.get('$Label.c.FILE_MSG_0002') +' '+ component.get('v.maximumFileSize') +  $A.get('$Label.c.FILE_MSG_0003')  +' : ' + fileSize;  //파일의 크기는   bytes를 초과 할 수 없습니다. 선택한 파일의 사이즈
                console.log(' # File Size Check : ', txt );
                var toast = { 'isClose'      : false
                        , 'type'         : 'error'
                        , 'message_type' : fileName
                        , 'message'      : txt
                        , 'duration'     : 10000
                        };
            
                component.set('v.customToast',toast);
                return false;
            }
            */

       // }
        return true;
    },

    /**
    * setFileData Function
    * @author       Jonggil.Kim
    * @description  File Data Setting
    * @param        component : Component
                    fileObject : File Data
	**/
    setFileData : function(component, fileObject) {
        console.log('fileobject inside setFileData : ', fileObject);
        var fileList        = component.get('v.FileList'),
            fileType        = fileObject.type,
            // fileTypeArray   = fileType.split( "/" ),
            // ftype           = fileTypeArray[1].toLowerCase(),
            fileTypeArray   = fileType.substring( fileType.indexOf( "/") + 1),
            ftype           = fileTypeArray.toLowerCase(),
            iconName        = 'doctype:'+ ((ftype == 'html') ? 'html' : 'image'),
            fileData        = {
                'name' : fileObject.name,
                'file' : fileObject,
                'fileContents' : '',
                'fileSize' : fileObject.size,
                'iconName' : iconName,
                'fileType' : fileType
            };

        var fr = new FileReader();        
            fr.onload = function() {
                var fileContents = fr.result,
                    base64Mark = 'base64,',
                    dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
                    fileContents = fileContents.substring(dataStart);

                //fileData.file = fileObject;
                fileData.fileContents = fileContents;
            };
        fr.readAsDataURL(fileObject);
        console.log('FileUpload fileData: '+fileData);
        return fileData;
    }, 
    
    /**
    * alertToast Function
    * @author       Jonggil.Kim
    * @description  alertToast Action 
    * @param        alertToast(component, isCloseModal, toastType, toastMsg, toastSecond)
    * @return       Boolean true/false
	**/
    alertToast : function(component, isCloseModal, toastType, toastMsg, toastSecond){
        component.set('v.toastMessage', toastMsg);
        this.toastToggle(component, isCloseModal, toastType);
        if(isCloseModal) this.timeOutCloseModal(component, toastSecond);
        else this.timeOutCloseToast(component, isCloseModal, toastSecond, toastType);
    }, 
    
    /**
    * toastToggle Function
    * @author       Jonggil.Kim
    * @description  Toast Toggle Action 
    * @param        
    * @return       Boolean true/false
	**/
    toastToggle : function(component, isCloseModal, toastType){
        component.set('v.isCloseModal', isCloseModal);
        component.set('v.toastType', toastType);
        $A.util.toggleClass(component.find(toastType+'-toast'), 'slds-hide');
        if(isCloseModal) $A.util.toggleClass(component.find('body'), 'slds-hide');
    },
    
    /**
    * timeOutCloseToast Function
    * @author       Jonggil.Kim
    * @description  Toast Close Action 
    * @param        
    * @return       Boolean true/false
	**/
    timeOutCloseToast : function(component, isCloseModal, time, toastType){
        window.setTimeout(
            $A.getCallback(function() {
                if(isCloseModal) $A.util.removeClass(component.find('body'), 'slds-hide');
                $A.util.addClass(component.find(toastType+'-toast'), 'slds-hide');
            }), time
        );
    },
    
    /**
    * timeOutCloseModal Function
    * @author       Jonggil.Kim
    * @description  Modal Close Action 
    * @param        
    * @return       Boolean true/false
	**/
    timeOutCloseModal : function(component, time){ 
        window.setTimeout(
            $A.getCallback(function() {
                $A.get("e.force:closeQuickAction").fire();
            }), time
        );
    },
    customToast : function(cmp, params) {
        console.log('custom : ' , params);
        $A.createComponent(
            "c:customToast",
            {
                "isUrl": params.isUrl,
                "target": params.target,
                "history": params.history,
                "type":  params.type,
                "duration": params.duration,
                "message": params.message
            },
            function(newButton, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = cmp.get("v.body");
                    body.push(newButton);
                    cmp.set("v.body", body);
                    console.log('toast success');
                    console.log(newButton);
                }
                else if (status === "INCOMPLETE") {
                    console.log("No response from server or client is offline.")
                    // Show offline error
                }
                else if (status === "ERROR") {
                    console.log("Error: " + errorMessage);
                    // Show error message
                }
            }
        );
    },
	// /**
    // * upload Function
    // * @author       Jonggil.Kim
    // * @description  File AttachObject Insert
    // * @param        component : Component
    //                 event : Event Property
    //                 helper : Helper js File
	// **/
	// upload: function(component, file, fileContents) {
	// 	var fromPos = 0;
    //     var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
		
    //     // start with the initial chunk
	// 	this.uploadChunk(component, file, fileContents, fromPos, toPos, '');
    // },

	// uploadChunk : function(component, file, fileContents, fromPos, toPos, attachId) {
    //     var action = component.get("c.saveTheFile"); 
    //     var chunk = fileContents.substring(fromPos, toPos);
 
    //     action.setParams({
    //         fileName: file.name,
    //         base64Data: encodeURIComponent(chunk), 
    //         contentType: file.type,
    //         fileId: attachId
    //     });
       
    //     var _this = this;
    //     action.setCallback(this, function(a) {
    //         attachId = a.getReturnValue();
            
    //         fromPos = toPos;
    //         toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);    
    //         if (fromPos < toPos) {
    //         	_this.uploadChunk(component, file, fileContents, fromPos, toPos, attachId);  
    //         }else{
	// 			//_this.setFileData(component, attachId, file.name);
	// 		}
    //     });
            
        
    //     $A.enqueueAction(action);         
	// },
	
    
})