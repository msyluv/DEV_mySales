({
    /**
    * @author       kilhwan.an
    * @description  초기값 설정
    * @param        component : Component
    *               event     : event
    *               helper    : helper
    **/     
    init : function( component, event, helper) {

        console.log( "::::::::::::: doInit( ComSenderEmail.controller) :::::::::::::");

        // 모바일 체크 여부
        var dvModule = $A.get( "$Browser.formFactor");
        if( dvModule === "PHONE" || dvModule === "IPHONE"){
            
           // component.set( "v.isMobile", "M");
            component.set( "v.isMobile", "M");
            //helper.isMobileClose( component);
        }else{

            component.set( "v.isMobile", "W");
        }

        // 초기값 
        helper.doInit( component, event);


        // 팀 멤버에서 TO/CC/BCC 선택 버튼값
        var emailRecipt = [

            {label : "To" , value : 'TO'},
            {label : "Cc" , value : 'CC'},
            {label : "Bcc", value : 'BCC'}
        ];
        component.set( "v.emailRecipt", emailRecipt);
   }
    /**
    * @author       kilhwan.an
    * @description  Send Email
    * @param        component : Component
    *               event     : event
    *               helper    : Alert Time
    **/    
   ,clickSendEmail: function( component, event, helper){

        console.log( "::::::::::::: clickSendEmail( ComSenderEmail.controller) :::::::::::::");

        var subject         = component.get( "v.subject");
        var description     = component.get( "v.description");
        var fileList        = component.get( "v.FileList");
        var fileCnt         = fileList.length;
        var errorMsg        = null;
        var emailRecipt     = [].concat( component.find( "emailRecipt"));
        var teamMemberList  = component.get( "v.teamMemberList");
        var eToList         = [];
        var eCcList         = [];
        var eBccList        = [];

        Array.prototype.slice.call( teamMemberList).forEach( function( teamObj, idx){
            
            var userEmail = teamObj["EvMailAddr__c"];
            var radioVal  = emailRecipt[idx].get( "v.value");
            switch( radioVal){

                case "TO"   :  eToList.push( userEmail);  break;
                case "CC"   :  eCcList.push( userEmail);  break;
                case "BCC"  :  eBccList.push( userEmail); break;
            }
        });

        if( eToList.length == 0 
         && eCcList.length == 0 && eBccList.length == 0 ){     // 보낸사람

            errorMsg  = $A.get( "$Label.c.EMAIL_MSG_0009");
        }else if( eToList.length > 10){                        // 받는사람

            var toLimitMsg  = $A.get( "$Label.c.EMAIL_MSG_0001");
            errorMsg        = toLimitMsg.replace( "%[MSG1]%", "10");
        }else if( eCcList.length > 25){                        // 참조

            var ccLimitMsg  = $A.get( "$Label.c.EMAIL_MSG_0002");
            errorMsg        = ccLimitMsg.replace( "%[MSG1]%", "25");
        }else if( eBccList.length > 25){                       // 숨은 참조

            var bccLimitMsg = $A.get( "$Label.c.EMAIL_MSG_0003");
            errorMsg        = bccLimitMsg.replace( "%[MSG1]%", "25");
        }else if( subject == null || subject === ""){          // 제목
         
            var subjectMsg  = $A.get( "$Label.c.EMAIL_MSG_0004");
            errorMsg        = subjectMsg.replace( "%[MSG1]%", "25");
        }else if( description == null || description === ""){  // 본문
         
            var descMsg     = $A.get( "$Label.c.EMAIL_MSG_0005");
            errorMsg        = descMsg.replace( "%[MSG1]%", "25");
        }else if( fileCnt > 0){                                // 파일 size

            var fileSize = 0;
            for( var i = 0; i < fileCnt; i ++){

                fileSize += fileList[i]["fileSize"];
            }
            //if( fileSize > 0){
               
            fileSize = fileSize / 1024 / 1024;
            if( fileSize > 3){

                var fileSizeMsg = $A.get( "$Label.c.EMAIL_MSG_0008");
                errorMsg        = fileSizeMsg.replace( "%[MSG1]%", "(3M)");
            }
            //}
        }
        if( errorMsg != null){
            
            helper.callToast(component, false, errorMsg, 'error', 5000);
            //helper.callToast( true, errorMsg, "error", 3000);
            return;
        }

        helper.clickSendEmail( component, event, eToList, eCcList, eBccList);
    }

    /**
    * @author       kilhwan.an
    * @description  팀멤버를 읽어온다
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/        
   ,clickTeamMember: function( component, event, helper){
        
        console.log( "::::::::::::: clickTeamMember( ComSenderEmail.controller) :::::::::::::");
        var teamMemberList = component.get( "v.teamMemberList");
        var epIdList       = [];
        Array.prototype.slice.call( teamMemberList).forEach( function( teamObj){
            
            epIdList.push( teamObj["EvUniqID__c"]);
        })
        helper.clickTeamMember( component, event, epIdList);
    }

    /**
    * @author       kilhwan.an
    * @description  이메일 템플릿 읽어오기
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/   
   ,changeEmailList: function( component, event, helper){

        console.log( "::::::::::::: changeEmailList( ComSenderEmail.controller) :::::::::::::");

        var recordId  = component.get( "v.recordId");
        var isEmailObj= component.get( "v.isEmailObj");
        var selEmailId= component.get( "v.selEmailId");
        if( selEmailId === ""){

            component.set( "v.selEmailId"   , "");
            component.set( "v.subject"      , "");
            component.set( "v.description"  , "");
        }else if( recordId != null && recordId !== "" && !isEmailObj){

            helper.changeEmailList( component, event);
        }else{

            var selEmailId   = component.get( 'v.selEmailId');
            var emailTemplate= component.get( "v.emailTemplate");
            var selETemplate = emailTemplate [ selEmailId];
            var description  = selETemplate[ "HtmlValue"] != null ? selETemplate[ "HtmlValue"] : selETemplate[ "Body"].split( "\n").join( "</br>");
            component.set( "v.subject"      , selETemplate[ "Subject"]);
            component.set( "v.description"  , description);
        }
    }

    /**
    * @author       kilhwan.an
    * @description  사용자 추가
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/   
   ,handlerEmployeeInfo: function( component, event, helper){

        console.log( "::::::::::::: handlerEmployeeInfo( ComSenderEmail.controller) :::::::::::::");

        var receiptUser     = event.getParam( "recordByEvent");
        console.log('receiptUser', JSON.stringify(receiptUser));
        var userEpId        = receiptUser["EvUniqID__c"];
        var teamMemberList  = component.get( "v.teamMemberList");
        for(var i=0; i < teamMemberList.length; i++){
            for(var j=0; j < teamMemberList[i].length; j++){
                console.log('EPID : ', teamMemberList[i][j].EvUniqID__c);
                if(teamMemberList[i][j].Employee__c == receiptUser.Id){
                    helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0007'), 'error', 5000);//'이미 입력된 정보 입니다.'
                    return;
                } 
            }
        }
        console.log('team Data > ' , JSON.stringify(teamMemberList));


        var employee = {
            Name                  : receiptUser.Name,
            EvEName__c             : receiptUser.EvEName__c,
            EvSdeptNM__c         : receiptUser.EvSdeptNM__c,
            EnEvSdeptNM__c       : receiptUser.EnEvSdeptNM__c,
            EvMailAddr__c              : receiptUser.EvMailAddr__c,
            Employee__c           : receiptUser.Id,
            EvUniqID__c               : receiptUser.EvUniqID__c,
            RecpSt                : 'TO'
        }; 

        teamMemberList.push( employee);

        console.log('team Data > ' , JSON.stringify(teamMemberList));
        component.set( "v.teamMemberList", teamMemberList);
    }

    
    /**
    * @author       kilhwan.an
    * @description  사용자 이메일 추가
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/  
   ,handlerEmailInfo: function( component, event, helper){
        
        console.log( "::::::::::::: handlerEmailInfo( ComSenderEmail.controller) :::::::::::::");
        var reciptEmail = event.getParam( "SearchKeyWord");
        if( reciptEmail === "") return;

        // 이메일 주소 형식
        var regExp = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
        if( !regExp.test( reciptEmail)){

            //helper.callToast(component, false, $A.get('$Label.c.EMAIL_MSG_0012'), 'error', 5000);
            return;
        }

        // 이메일 기존 등록 여부 확인
        var teamMemberList  = component.get( "v.teamMemberList");
        for( var idx in teamMemberList){

            if( teamMemberList[ idx]["EvMailAddr__c"] == reciptEmail) {
                
                helper.callToast(component, false, $A.get('$Label.c.APPR_MSG_0007'), 'error', 5000);//'이미 입력된 정보 입니다.'
                return ;
            }
        }
       
       var acceptedEmail = component.get('v.acceptedEmail');
       var includeEmail = false;
       for(var i =0; i< acceptedEmail.length; i++){
           //if( reciptEmail.includes('@' + acceptedEmail[i].Domain__c)){
           if( reciptEmail.split('@')[1] == acceptedEmail[i].Domain__c){
               includeEmail = true;               
               break;
           }
       }
       console.log('!!');
       if(!includeEmail){
           helper.callToast(component, false, $A.get('$Label.c.EMAIL_MSG_0013'), 'error', 5000);//'사용할 수 없는 이메일 입니다.'
           return;
       }


        // 이메일 사용자 추가
        var emailUser = {

             Name           : reciptEmail
            ,EvSdeptNM__c  : "--"
            ,EvMailAddr__c       : reciptEmail
            ,EvUniqID__c        : reciptEmail
            ,RecpSt         : 'TO'
        }
        teamMemberList.push( emailUser);
        component.set( "v.teamMemberList", teamMemberList);
        component.set( "v.searchKeyWord" , "");
    }

    /**
    * @author       kilhwan.an
    * @description  메일 목록 사용자 삭제
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/       
   ,removeItem: function( component, event, helper){

        console.log( "::::::::::::: removeItem( ComSenderEmail.controller) :::::::::::::");
        var teamMemberList = component.get( "v.teamMemberList");
        var rowIdx         = event.currentTarget.getAttribute( "data-itemIdx");
        teamMemberList.splice( rowIdx, 1);
        component.set( "v.teamMemberList", teamMemberList);
    }

    
    /**
    * @author       kilhwan.an
    * @description  Toast 닫기 창
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/   
   ,closeToast: function( component, event, helper){

        console.log( "::::::::::::: closeToast( ComSenderEmail.controller) :::::::::::::");
        
        var toastType    = component.get( "v.toastType");
        var isCloseModal = component.get( "v.isCloseModal");
        var toastSecond  = 3000;

        if( isCloseModal) helper.timeOutCloseModal( component, toastSecond);
        else helper.timeOutCloseToast( component, isCloseModal, toastSecond, toastType);
    }
    , clickCancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
    /**
    * @author       kilhwan.an
    * @description  파일 업로드후 Document Id 값 리턴
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/       
   ,handleUploadFinished: function ( component, event, helper) {

        console.log( "::::::::::::: handleUploadFinished( ComSenderEmail.controller) :::::::::::::");
        var uploadedFiles = event.getParam("files");
        var fileIdList    = [];
        for( var idx in uploadedFiles){

            fileIdList[idx] = uploadedFiles[idx].documentId;
        }
        helper.docFileList( component, event, fileIdList);
    }

    
    /**
    * @author       kilhwan.an
    * @description  파일 목록 삭제
    * @param        component  : Component
    *               event      : event
    *               helper     : helper
    **/   
   ,removefile: function( component, event, helper) {

        console.log( "::::::::::::: removefile( ComSenderEmail.controller) :::::::::::::");
        var rowIdx   = event.currentTarget.getAttribute( "data-itemIdx");
        var fileList = component.get( "v.nFileList");
        fileList.splice( rowIdx, 1);
        component.set( "v.nFileList", fileList);
    }
});