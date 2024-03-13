/**
  @author            : divyam.gupta@samsung.com
  @description       : Add new tab Analysis of Competition Result. 
  @last modified on  : 2023-05-30
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
  1.2   2023-01-24   rakshit.s@samsung.com      View All and Opp Specific Lost Type Custom Table with common merged cells.
  1.3   2023-05-30   divyam.gupta@samsung.com   Add on changes Lost Enchacement(Mysales -204)

**/
(
    {
        doInit : function(component, event, helper) {  
            var locale = $A.get("$Locale.language");
            console.log('the user lang:'+locale);
            if(locale == 'ko'){
                component.set("v.setLangEng",false);
                component.set("v.setLangKor",true);
            }
            else{
                component.set("v.setLangEng",true);
                component.set("v.setLangKor",false);
            }
            //   helper.addRow(component,event);
            helper.getOppActivitystatus(component,event);
            helper.getLosttype(component,event);
            helper.getLosttype1(component,event);
            //added by rakshit.s@samsung.com
            helper.checkIfDropOrLost(component,event);
            //1.3 Divyam
            helper.getProfilecheck(component,event);
            
            
        },
        
        changeLostType : function(component, event, helper){
            // var checkcomboval = component.find("combobox2");
            //var getvalue = checkcomboval.set("v.value",'');
            //  component.set("v.combo2val",'');
            helper.changeLostType(component,event);
        },
        changeLostType1 : function(component, event, helper){
            helper.changeLostType1(component,event);
        },
        handleLvlCheckbox : function(component, event, helper) {
            helper.handleLvlCheckboxval(component, event);
            
        },
        handleTotal: function(component, event, helper){
            //Akash Changes
            helper.handleTotalHelper(component,event);
        },
        
        handleTemprarory: function(component, event, helper){
            var totalValue = component.get("v.totalval");
            var emptyfield = false;
            var contnspclchr = false;
            
            
            console.log('totalValue='+ totalValue);
            if(totalValue != '100' && totalValue > 0){
                console.log('Enter in error box');
                helper.showMyToast('error',$A.get("$Label.c.ErrorTotal100Value"));
            }
            
            
       
                
                var lostReslistval = component.get("v.lostReslist");
                for(var i = 0; i < lostReslistval.length; i++) {
                    if(lostReslistval[i].Checked == true ){
                        
                        //var regex = /^[^a-zA-Z0-9^ㄱㄲㄴㄷㄸㄹㅁㅂㅃㅅㅆㅇㅈㅉㅊㅋㅌㅍㅎㅏㅐㅑㅐㅓㅔㅕㅖㅗㅘㅙㅚㅛㅜㅝㅞㅟㅠㅡㅢㅣ]+$/;
                        //var regularExpression= new RegExp('^.*[-@!$%^&*()_+|~=`{}[\\]:";\'<>?,.\/]+.*$');
                    var regurwexp = ['^','.','*','-','@','!','#','$','%','&','(',')','_','+','[',']','|','~','=','`','{','}',':',';','<','>','?','/',' '];
                        var detailpvalue = lostReslistval[i].detail;
                                                console.log('detailpvalue',detailpvalue);

                        var detailval1 = detailpvalue.replace(/[\r\n]+/gm,"");


                        var matchvar = '';
                        var matchvar1 = '';

                       console.log('regurwexp',regurwexp.length);
                        
                    for(let k=0;k < detailval1.length;k++  ){
                       for(let j=0 ; j < regurwexp.length; j++){
                           if(detailval1[k] == regurwexp[j]){
                            matchvar = matchvar + regurwexp[j];
                               break;
                           }
                       }
                          console.log('matchvar',matchvar);

                    }
                        
                    var checkspclchrdetails = false;
                    if(matchvar == detailval1 && detailval1 != '' && detailval1 != undefined ){
                     checkspclchrdetails= true;
                        
                    }
                  
                      //var checkspclchrpre= precompval1.match(regex) ? "true" : "false";
                       //var checkspclchraftrbid= resaftrbid.match(regex) ? "true" : "false";
                         // console.log('regularExpressionlen',regex.length);
              
                    if(lostReslistval[i].detail == '' || lostReslistval[i].lvl3Record == '' || lostReslistval[i].lvl1Record == '' || lostReslistval[i].lvl2Record == ''){
                        emptyfield = true; 
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields"));
                    }
                    
                    if(checkspclchrdetails == true ){
                      contnspclchr = true;  
                      helper.showMyToast('error',$A.get("$Label.c.Special_Char_Err_Msg"));

                    }
                    }
                }
                
            helper.CheckCharacterLength(component,event);
            var CheckCharLength = component.get("v.CheckCharacterlength");
            /** START 1.3 **/
            helper.checkRate(component,event);
              var lostReslistval1 = component.get("v.lostReslist");
        
              var checkratevalue= component.get("v.CheckRateVal");
            console.log('checkratevalue',checkratevalue);

            if( emptyfield == false && contnspclchr == false && CheckCharLength == false && checkratevalue == false){
                /** END 1.3 **/
              /**  helper.checkDuplicateValue(component,event);
                var level3duplicateval = component.get("v.level3duplicate");  
                console.log('level3duplicateval',component.get("v.level3duplicate"));
                if(level3duplicateval == false){
                console.log('setmandtryfields-->'+component.get("v.setmandtryfields")) **/
                // helper.helperHandleTemp(component,event); 
                helper.insertLostresult(component,event);
            
            }
            
        },
        
        addRow: function(component, event, helper){
            if(component.get("v.activitystatus") != 'In Progress') {
                
            helper.addRow(component,event);
            }
        },
        
        removeRow: function(component, event, helper){
              if(component.get("v.activitystatus") != 'In Progress') {
                
            var lostReslistval = component.get("v.lostReslist");
            var lostReslistval1 = [];
            console.log('the lenght is',lostReslistval.length);
           
            for(let i=0; i < lostReslistval.length ; i++){
                if( lostReslistval[i].Checked ==  true ){
                    lostReslistval1.push(lostReslistval[i]);
                   }   
            }
            if(lostReslistval1.length > 1 )
            {
                helper.removeRow(component,event);
                
                console.log('the lenght is1',lostReslistval1.length);
                
            }
                  if(component.get("v.activitystatus") != 'Completed'){
            if(lostReslistval1.length == 1){
                    helper.removeRow(component,event);
                   helper.addRow(component,event);
            }
            }
              }
            
        },
        rowSelect: function(component, event , helper){
            var itemId = event.currentTarget.getAttribute("data-itemId"); 
            component.set('v.currIndex',itemId.replace('row',''));
            helper.rowSelect(component,event);
        },
        
        //added by @rakshit.s@samsung.com
        //logic to implement popup view on button click.
        
        handlechildLwc: function(component, event, helper){
            // var oppId = component.get("v.opprecordId");
            console.log('calling form button' + event.getSource().getLocalId());
            console.log('datachild-->' + component.get("v.opptyActId"));
            //getting activity status
           /* callApexMethod : function(component, event, helper) {
        var myArgument = component.get("v.opptyActId");
        var action = component.get("c.myApexMethod");
        action.setParams({ myArgument : myArgument });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
            }
            else {
                console.log("Error calling Apex method: " + state);
            }
        });
        $A.enqueueAction(action);
    }*/
            //getting activity status logic ends.
            component.set('v.showTablefromLWC' , true); 
            let isViewAll = false;
            if(event.getSource().getLocalId() == 'viewAll'){
                isViewAll = true;
            }
            let isLangKorean = false;
            //added locale calculation seperately here
             var locale = $A.get("$Locale.language");
            console.log('the user lang:'+locale);
            if(locale == 'ko'){
                 isLangKorean = true;
            }
            
           
            
            $A.createComponent(
            "c:childLwcPopupContainer",{
                "opprecordId" : component.get('v.opprecordId'),
                "isViewAll" : isViewAll,
                "isCounterMeasureTable" : false,
                "isMasterLostTypeT" : true,
                "activityId" : component.get("v.opptyActId")
                
            },
            function(modalComponent, status, errorMessage){
                //Add the new button to the body array
                if (status === "SUCCESS") {
                    var body = component.find('showChildModal').get("v.body"); 
                    body.push(modalComponent);
                    component.find('showChildModal').set("v.body", body);
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
        
        clickCancel: function(component, event, helper){
            
            helper.reload(component,event);               
            
        },
        
        
        
        
    })