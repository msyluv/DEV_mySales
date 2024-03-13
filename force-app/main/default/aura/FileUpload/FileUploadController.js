({  
    /**
    * fileUpload Function
    * @description  File Upload Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
	**/
    fileUpload : function(component, event, helper) {
        helper.fileUpload(component, event);        
    },

    /**
    * clear Function
    * @description  File Clear Button Click Event
    * @param        component : Component
                    event : Event Property
                    helper : Helper js File
	**/
    clear : function(component, event, helper) {
        var itemIdx = event.currentTarget.getAttribute("data-itemIdx"),
            fileList = component.get('v.FileList');

        // 파일사이즈 셋팅
        // var refineFileList = JSON.parse(JSON.stringify(fileList));
        var deleteFile = fileList[itemIdx];
        var deleteFileSize = parseInt(deleteFile.fileSize);
        var allFileSize = parseInt(component.get('v.allFileSize'));
        console.log(` allFileSize : ${allFileSize} - deleteFileSize : ${deleteFileSize}`);

        var subtractionSize = allFileSize-deleteFileSize;
        console.log(' # subtractionSize ', subtractionSize);
        component.set('v.allFileSize', subtractionSize);

        fileList.splice(itemIdx, 1);
        component.set('v.FileList', fileList);
        console.log('controller.clear() : ', fileList);
    },
    
    closeToast: function(component, event, helper) {
        var isCloseModal = component.get('v.isCloseModal');
        var toastType = component.get('v.toastType');
        if(isCloseModal) $A.get("e.force:closeQuickAction").fire();
        else helper.toastToggle(component, isCloseModal, toastType);
    }
})