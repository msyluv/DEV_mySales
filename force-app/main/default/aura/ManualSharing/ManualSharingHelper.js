({
    /*
    * @Name             : doInit
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Manual Sharing 여부를 확인함. 기본은 Owner만 사용 가능
    */
    doInit : function(component, event) {
        var recordId = component.get("v.record").Id;
        var _this = this;
        this.spinnerToggle(component, event);

        var action = component.get("c.init");    

        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();    

                if(result){
                    _this.sharingLoadData(component, event);
                }else{
                    _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0003"), 'error', 3000); //Manual Sharing 사용 권한이 없습니다. 관리자에게 문의하여 주세요.
                }

            } else {
                _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
            } 
            _this.spinnerToggle(component, event);
        });
        $A.enqueueAction(action);

        

    },
    /*
    * @Name             : sharingLoadData    
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Record의 공유 정보를 불러옴.
    */
   sharingLoadData : function(component, event) {
        var recordId = component.get("v.record").Id;
        this.spinnerToggle(component, event);
        var action = component.get("c.getSharingData");
        var _this = this;
        
        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();                
                component.set('v.SharingMap',result );                
                _this.duplicateCheck(component);
            } else {
                _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
            } 
            _this.spinnerToggle(component, event);
        });
        $A.enqueueAction(action);
    }
    /*
    * @Name             : getSearchData
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Search Type 기준으로 검색 결과를 받아옴.
    */
    , getSearchData : function(component, event) {
        console.log('getSearchData');
        var se = component.get('v.searchText');
        var type = component.get('v.selectType');
        var condition = '';
        
        if('User' == type){
            condition = '';
        }else if('PublicGroup' == type){
            condition = '';
        }else{
            condition = '';
        }
        
        var action = component.get("c.getSearchData");
        var _this = this;
        action.setParams({
            'search': se,
            'type': type,
            'condition' : condition
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue(); 
                component.set('v.searchResult', result);  
                _this.duplicateCheck(component);
                
            } else {
                _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
            }     
        });
        $A.enqueueAction(action);
    }
    /*
    * @Name             : getSearchData
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 검색대상이 현재 공유되고 있는 대상인지 체크함.
    */
    , duplicateCheck : function(component) {
        var SharingMap = component.get('v.SharingMap');
        var searchResult = component.get('v.searchResult');
        var type = component.get('v.selectType');
        const objUncovered = JSON.parse(JSON.stringify(SharingMap));
        
        for(var i=0 ; i < searchResult.length; i++){
            var key = searchResult[i].Id + '_' + type;         
            if (objUncovered.hasOwnProperty(key)) {
                searchResult[i].IsInclude = true;
            }else {
                searchResult[i].IsInclude = false;
            }
        }
        component.set('v.searchResult', searchResult);
        
    }
    /*
    * @Name             : callToast
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Toast Message 출력과 isClose 따라 Component를 닫음.
    */
    , callToast : function(isClose, message, type, duration){        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title":type+"!",
            "message":message,
            "type" : type,
            "duration" : duration
        });
        toastEvent.fire();
        if(isClose){
            $A.get("e.force:closeQuickAction").fire();
        }        
    }
    /*
    * @Name             : insertSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 새로운 공유 정보를 추가함.
    */
    , insertSharing : function(component, event) {
        this.spinnerToggle(component, event);
        var sharingdata = component.get('v.SharingMap');
        var type = component.get('v.selectType');
        var recordId = component.get("v.record").Id;
        var att = event.currentTarget.getAttribute("data-itemid").split('_');
        var clickval = att[0];
        var id = att[1];
         
        var sharingMap = {
            'ParentId' : recordId,
            'UserOrGroupId' : id,
            'AccessLevel' : clickval,
            'RowCause' : 'Manual'
        };          
        var action = component.get("c.insertData");
        var _this = this;
        
        action.setParams({
            'recordId' : recordId,
            'jsonParam' : JSON.stringify(sharingMap)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                _this.sharingLoadData(component, event);
            } else {
                _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                console.log(response.getError());
            }  
            _this.spinnerToggle(component, event);
        });
        $A.enqueueAction(action);           
        
    
    }
    /*
    * @Name             : insertSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 해당 공유대상의 현재 액세스 수준과 선택한 액세스 수준을 비교한 후 업데이트함.
    */
    , updateSharing : function(component, event) {
        var att = event.currentTarget.getAttribute("data-itemid").split('_');
        var clickval = att[0];
        var id = att[1];
        var type = att[2];
        
        if(type != clickval && type != 'All'){
            this.spinnerToggle(component, event);
            var recordId = component.get("v.record").Id;
            var sharingMap = {
                'Id' : id,
                'AccessLevel' : clickval
            };          
            var action = component.get("c.updateData");
            var _this = this;
            
            action.setParams({
                'recordId': recordId,
                'jsonParam' : JSON.stringify(sharingMap)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    _this.sharingLoadData(component, event);
                } else {
                    _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                }  
                _this.spinnerToggle(component, event);
            });
            $A.enqueueAction(action);           
            
        }
        
    }
    /*
    * @Name             : deleteSharing
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : 해당 공유대상을 제외시킴.
    */
    , deleteSharing : function(component, event) {
        var delId = event.currentTarget.getAttribute("data-itemid");
        this.spinnerToggle(component, event);
        var recordId = component.get("v.record").Id;
        var action = component.get("c.deleteData");
        var _this = this;
        
        action.setParams({
            'recordId': recordId,
            'delId' : delId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                    _this.sharingLoadData(component, event);
                } else {
                    _this.callToast(true, $A.get( "$Label.c.COMM_MSG_0001"), 'error', 3000); //잠시 후 다시 시도하거나 관리자에게 문의하여 주세요.
                }  
                _this.spinnerToggle(component, event);
            });
        $A.enqueueAction(action);
        
    }    
    /*
    * @Name             : spinnerToggle
    * @author           : Jonggil Kim, 2019/05/29
    * @Description      : Component의 스피너를 토글함.
    */
    ,spinnerToggle : function(component, event){
        var spinner = component.find('spinner');
        $A.util.toggleClass(spinner, 'slds-hide');
    }
})