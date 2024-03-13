({
    /**
    * @author       kilhwan.an
    * @description  초기값 설정
    * @param        component : Component
    *               event     : event
    *               helper    : helper
    **/    
    doInit : function( component, event) {

        console.log( "::::::::::::: doInit( ComSenderEmail.helper) :::::::::::::");

        var _THIS    = this;
        var recordId = component.get( "v.recordId");
        var action   = component.get( "c.doInit");
        action.setParams( { recordId : recordId});
        action.setCallback( this, function( res){

            var state = res.getState();
            if( state === "SUCCESS"){

                var returnVal      = res.getReturnValue();
                var userInfo       = returnVal["userInfo"];
                var isEmailObj     = returnVal["isEmailObj"];
                var recordInfo     = returnVal["recordInfo"];
                var teamMemberList = returnVal["teamMemberList"];
                var acceptedEmail = returnVal["acceptedEmail"];
                
                //if( userInfo != null) component.set( "v.from", userInfo);
                
                component.set( "v.from"         , userInfo);
                component.set( "v.emailList"    , returnVal["emailList"]);
                component.set( "v.emailTemplate", returnVal["emailTemplate"]);
                component.set( 'v.isEmailObj'   , isEmailObj);
                component.set( "v.userId"       , userInfo["Id"]);
                component.set( "v.acceptedEmail"         , acceptedEmail);
                
                // SendEmailReport 상세 페이지 인 경우
                if( isEmailObj) _THIS.setFieldValue( component, recordInfo, teamMemberList);
            }else{

                console.log( 'doInit ERROR:::::::' + res.getError()[0]["message"]);
            }
        });
        
        $A.enqueueAction( action);
    }
    
    /**
    * @author       kilhwan.an
    * @description  모바일 여부 확인 후  창닫기
    * @param        component : Component
    *               helper    : helper
    **/   
   ,isMobileClose: function( component) {

        var isMobile = component.get( "v.isMobile");
        if( isMobile){

            var mobileAction = component.get( "c.isMobile");
            mobileAction.setParam   ( { isMobile : isMobile});
            mobileAction.setCallback( this, function( res){

                alert( $A.get( "$Label.c.COMM_MSG_0004"));
                $A.get( "e.force:closeQuickAction").fire();
            });
            $A.enqueueAction( mobileAction);
            return;
        }    
    }
    
    /**
    * @author       kilhwan.an
    * @description  SendEmailReport 상세 페이지 값 설정
    * @param        component : Component
    *               event     : event
    *               helper    : helper
    **/     
   ,setFieldValue: function( component, recordInfo, teamMemberList){

        console.log( "::::::::::::: setFieldValue( ComSenderEmail.helper) :::::::::::::");
        component.set( "v.teamMemberList" , teamMemberList);
        component.set( "v.subject"        , recordInfo["Subject__c"]);
        component.set( "v.description"    , recordInfo["Content__c"]);
        component.set( "v.selEmailId"     , recordInfo["ExtEmailId__c"]);
    }

    /**
    * @author       kilhwan.an
    * @description  이메일 발송
    * @param        component  : Component
    *               event      : event
    *               eToList    : User To List
    *               eCcList    : User Cc List
    *               eBccList   : User Bcc List
    **/    
   ,clickSendEmail: function( component, event, eToList, eCcList, eBccList){

        console.log( "::::::::::::: clickSendEmail( ComSenderEmail.helper) :::::::::::::");
        var _THIS      = this;
        _THIS.spinnerToggle( component, event);
        
        var action      = component.get( "c.sendKnoxEmail");
        console.log(action);
        var params = {
             recordId    : component.get( "v.recordId")
            ,isEmailObj  : component.get( "v.isEmailObj") 
            ,eToList     : eToList
            ,eCcList     : eCcList
            ,eBccList    : eBccList
            ,subject     : component.get( "v.subject")
            ,description : component.get( "v.description")
            ,efileList   : component.get( "v.FileList")
            ,nfileList   : component.get( "v.nFileList")
            ,selEmailId  : component.get( "v.selEmailId")
        };

        action.setParams( params);

        console.log('## params', JSON.stringify(params) )        

        action.setCallback( this, function( res){

            var state       = res.getState();
            var toastType   = state.toLowerCase();
            var toastMsg    = $A.get( "$Label.c.EMAIL_MSG_0007");
            if( state === "SUCCESS"){

                var returnVal = res.getReturnValue();
                if( returnVal.result == 'fail'){
                    toastType = "error";
                    state     = toastType;
                    toastMsg  = $A.get( "$Label.c.EMAIL_MSG_0006") + "(" + JSON.stringify( failList) +")";
                    console.log( "STATE( SUCCESS)_RESULT_FAIL ::::::::" + JSON.stringify( failList));
                } else {

                }
                _THIS.doInitFields( component);
            }else{

                //toastType = "error";
                toastMsg  = $A.get( "$Label.c.EMAIL_MSG_0006") + "\n(" + res.getError()[0]["errorMessage"] + ")";
                console.log( "clickSendEmail ERROR ::::::::" + res.getError()[0]["errorMessage"]);
            }

            _THIS.spinnerToggle( component, event);
            _THIS.callToast(component, state === "SUCCESS" ? true : false, toastMsg, toastType, 5000);

            
        });
        $A.enqueueAction( action);
    }

    /**
    * @author       kilhwan.an
    * @description  팀 구성원을 읽어온다
    * @param        component  : Component
    *               event      : event
    **/ 
   ,clickTeamMember : function( component, event, epIdList){
        
        console.log( "::::::::::::: clickTeamMember( ComSenderEmail.helper) :::::::::::::");
        var _THIS  = this;
        var action = component.get( "c.getTeamMembers");
        var params = {

             recordId   : component.get( "v.recordId")
            ,epIdList   : epIdList
        };
        
        _THIS.spinnerToggle( component, event);
        action.setParams( params);
        action.setCallback( this, function( res){

            var state = res.getState();
            if( state === "SUCCESS"){

                var returnValue    = res.getReturnValue();
                var teamMemberList = component.get( "v.teamMemberList");
                teamMemberList     = teamMemberList.concat( returnValue);
                component.set( "v.teamMemberList", teamMemberList);
            }

            _THIS.spinnerToggle( component, event);
        });

        $A.enqueueAction( action);
    }
   ,docFileList: function( component, event, fileIdList){

        console.log( "::::::::::::: docFileList( ComSenderEmail.helper) :::::::::::::");
        var action = component.get( "c.getDocFileList");
        action.setParams( {

            fileIdList: fileIdList
        });

        action.setCallback( this, function( res){

            var state = res.getState();
            if( state === "SUCCESS"){

                var returnValue = res.getReturnValue();
                var fileList    = component.get( "v.nFileList");
                fileList        = fileList.concat( returnValue);
                component.set( "v.nFileList", fileList);
            }else{

                console.log( JSON.stringify( res.getError()));
            }
        });

        $A.enqueueAction( action);
    }

    /**
    * @author       kilhwan.an
    * @description  이메일 서식 필드를 값으로 치환
    * @param        component  : Component
    *               event      : event
    **/    
    ,changeEmailList: function( component, event){

        console.log( "::::::::::::: changeEmailList( ComSenderEmail.helper) :::::::::::::");
        var _THIS         = this;
        var recordId      = component.get( "v.recordId");
        var action        = component.get( "c.convertHtmlFieldValue");
        
        var selEmailId    = component.get( "v.selEmailId");
        var emailTemplate = component.get( "v.emailTemplate")[selEmailId];
        var jsonParam     = { 

             "recordId"      : recordId
            ,"emailTemplate" : emailTemplate
        };

        _THIS.spinnerToggle( component, event);        
        action.setParams( jsonParam);
        action.setCallback( this, function( res){

            var state = res.getState();
            if( state === "SUCCESS"){

                var template = res.getReturnValue();
                component.set( "v.subject"      , template[ 0]);
                component.set( "v.description"  , template[ 1]);                
            }else{

                console.log( "changeEmailList ERROR ::::::::" + res.getError()[0]["message"]);
            }
            _THIS.spinnerToggle( component, event);            
        });
        $A.enqueueAction( action);
     }    
    ,doInitFields: function( component){
        
        console.log( "::::::::::::: doInitFields( ComSenderEmail.helper) :::::::::::::");
        component.set( "v.to"         , []);
        component.set( "v.cc"         , []);
        component.set( "v.bcc"        , []);
        component.set( "v.subject"    , "");
        component.set( "v.description", "");
        component.set( "v.FileList"   , []);
        component.set( "v.selEmailId" , "");
     }

    /**
    * @author       Jonggil.Kim
    * @description  Spinner Toggle Action 
    * @param        
    * @return       Boolean true/false
	**/    
   ,spinnerToggle: function( component, event){

        console.log( "::::::::::::: spinnerToggle( ComSenderEmail.helper) :::::::::::::");
        var spinner = component.find( "spinner");
        $A.util.toggleClass( spinner, "slds-hide");
    }
    
    /**
    * @author       Jonggil.Kim
    * @description  alertToast Action 
    * @param        component : Component
    *               isCloseModal : Close with Modal (Boolean)
    *               toastType : ‘success’, ‘error’
    *               toastMsg : Toast Message
    *               toastSecond : Alert Time
    **/    
   ,alertToast: function( component, isCloseModal, toastType, toastMsg, toastSecond){

        console.log( "::::::::::::: alertToast( ComSenderEmail.helper) :::::::::::::");
        component.set( "v.toastMessage", toastMsg);
        this.toastToggle( component, isCloseModal, toastType);
        if( isCloseModal) this.timeOutCloseModal( component, toastSecond);
        else this.timeOutCloseToast( component, isCloseModal, toastSecond, toastType);
    }

    /**
    * @author       Jonggil.Kim
    * @description  Toast Toggle Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				toastType : 'success', 'error'
	**/    
   ,toastToggle: function( component, isCloseModal, toastType){

        console.log( "::::::::::::: toastToggle( ComSenderEmail.helper) :::::::::::::");
        component.set( "v.isCloseModal", isCloseModal);
        component.set( "v.toastType"   , toastType);
        $A.util.toggleClass( component.find( toastType +'-toast'), 'slds-hide');
        if( isCloseModal) $A.util.toggleClass( component.find( "body"), "slds-hide");
    }

    /**
    * @author       Jonggil.Kim
    * @description  Toast Close Action 
    * @param        component : Component
    * 				isCloseModal : Close with Modal (Boolean)
    * 				time : Alert Time
    * 				toastType : 'success', 'error'
	**/
   ,timeOutCloseToast: function( component, isCloseModal, time, toastType){

        console.log( "::::::::::::: timeOutCloseToast( ComSenderEmail.helper) :::::::::::::");
        window.setTimeout(
            $A.getCallback( function(){
                
                if( isCloseModal) $A.util.removeClass( component.find( "body"), "slds-hide");
                $A.util.addClass( component.find( toastType + "-toast"), "slds-hide");
            }), time
        );
    }

    /**
    * @author       Jonggil.Kim
    * @description  Toast Close with Modal Action
    * @param        component : Component
    * 				time : Alert Time
	**/
   ,timeOutCloseModal: function( component, time){

 
        console.log( "::::::::::::: timeOutCloseModal( ComSenderEmail.helper) :::::::::::::");
        window.setTimeout( 
            $A.getCallback( function(){
                
                $A.get( "e.force:closeQuickAction").fire();
            }), time
        );
    }

   , callToast : function(component, isClose, message, type, duration){    
        console.log('callToast ~!@~!@');
        var toast = { 'isClose'      : isClose
                     , 'type'         : type
                     , 'message_type' : type
                     , 'message'      : message
                     , 'duration'     : duration 
                    };
        component.set('v.toast',toast);

        if(type =='error'){
            var spinner = component.find('spinner');
            $A.util.addClass(spinner, 'slds-hide');
        }
                
    } 
    
})