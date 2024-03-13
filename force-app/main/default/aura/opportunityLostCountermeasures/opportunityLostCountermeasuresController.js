/**
  @author            : divyam.gupta@samsung.com
  @description       : Add new tab Analysis of Competition Result. 
  @last modified on  : 2022-10-17
  @last modified by  : divyam.gupta@samsung.com
  Modifications Log 
  Ver   Date         Author                   	Modification
  1.0   2022-10-17   Divyam.gupta@samsung.com       Initial Version
**/
(
    {
        doInit : function(component, event, helper) {  
            helper.getOppActivitystatus(component, event);
            helper.getLosttype(component, event);
            helper.getLostresult(component, event);
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
             helper.getpicklistcounter(component, event);

        },


        clickCancel: function(component, event, helper){
            
            helper.reload(component,event);               
            
        },
        clickSave:  function(component, event, helper){
            var self = this;
            if(component.get("v.activitystatus") == 'Completed'){
                var checkvalue = component.find("detaillv1");
            var checkvalue1 = component.find("detaillv2");
            var checkvalue2 = component.find("detaillv3");
            var checkvalue3 = component.find("detaillv4");
            var checkvalue4 = component.find("detaillv5");
            var checkvalue5 = component.find("detaillv6");
            var checkvalue6 = component.find("detaillv7");
            
            var enterdrecord = [];
            var enterdrecord1 = [];
            var enterdrecord2 = [];
            var enterdrecord3 = [];
            var enterdrecord4 = [];
            var enterdrecord5 = [];
            var enterdrecord6 = [];
            var enterdrecord7 = [];
             component.set("v.setmandtryfields",false);

            if(!Array.isArray(checkvalue)){
                if (checkvalue.get("v.value") != '' && checkvalue.get("v.value") != null) {
                    var getvalue = checkvalue.get("v.value");
                    var getname = checkvalue.get("v.name");
                    var getname1 = 'name';
                    enterdrecord.push({detailslost: getvalue, typename: getname, typename1: getname1});
                }   
                  else {
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);                        
                    }
            }else{
                for (var i = 0; i < checkvalue.length; i++) {
                    if (checkvalue[i].get("v.value") != '' && checkvalue[i].get("v.value") != null) {
                        var getvalue = checkvalue[i].get("v.value");
                        var getname = checkvalue[i].get("v.name");
                        var getname1 = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord.push({detailslost: getvalue, typename: getname, typename1: getname1});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r1-->');
                        
                    }
                    else {
                        console.log('Eneter into else group');                       
                        var getvalue = '';
                        var getname = checkvalue[i].get("v.name");
                        var getname1 = 'name'+i;
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);
                        console.log('val value-->'+getvalue);                    
                        enterdrecord.push({detailslost: getvalue, typename: getname,typename1: getname1});  
                        
                    }
                }
            }
            
            if(!Array.isArray(checkvalue1)){
                if (checkvalue1.get("v.value") != '' && checkvalue1.get("v.value") != null) {
                    var getvalue = checkvalue1.get("v.value");
                    var getname = checkvalue1.get("v.name");
                    enterdrecord1.push({detailslost1: getvalue, typename: getname});
                }
                 else {
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);                        
                    }
                
            }else{
                for (var i = 0; i < checkvalue1.length; i++) {
                    if (checkvalue1[i].get("v.value") != '' && checkvalue1[i].get("v.value") != null) {
                        var getvalue = checkvalue1[i].get("v.value");
                        var getname = checkvalue1[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord1.push({detailslost1: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r2-->');
                    } 
                    else {
                        var getvalue = '';
                        var getname = checkvalue1[i].get("v.name");
                          helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                           component.set("v.setmandtryfields",true);
                        console.log('val value-->'+getvalue);                    
                        enterdrecord1.push({detailslost1: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(checkvalue2)){
                if (checkvalue2.get("v.value") != '' && checkvalue2.get("v.value") != null  ) {
                    var getvalue = checkvalue2.get("v.value");
                    var getname = checkvalue2.get("v.name");
                    enterdrecord2.push({detailslost2: getvalue, typename: getname});
                }  
                   else {
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);                        
                    }
            }else{
                for (var i = 0; i < checkvalue2.length; i++) {
                    if (checkvalue2[i].get("v.value") != '' && checkvalue2[i].get("v.value") != null) {
                        var getvalue = checkvalue2[i].get("v.value");
                        var getname = checkvalue2[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord2.push({detailslost2: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r3-->');
                    }
                    else {
                        var getvalue = '';
                        var getname = checkvalue2[i].get("v.name");
                       helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);
                        console.log('val value-->'+getvalue);                    
                        enterdrecord2.push({detailslost2: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(checkvalue3)){
                if (checkvalue3.get("v.value") != '') {
                    var getvalue = checkvalue3.get("v.value");
                    var getname = checkvalue3.get("v.name");
                    enterdrecord3.push({detailslost3: getvalue, typename: getname});
                }  
            }else{
                for (var i = 0; i < checkvalue3.length; i++) {
                    if (checkvalue3[i].get("v.value") != '' && checkvalue3[i].get("v.value") != null) {
                        var getvalue = checkvalue3[i].get("v.value");
                        var getname = checkvalue3[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord3.push({detailslost3: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r4-->');
                    } 
                    else {
                        var getvalue = '';
                        var getname = checkvalue3[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord3.push({detailslost3: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(checkvalue4)){
                if (checkvalue4.get("v.value") != '') {
                    var getvalue = checkvalue4.get("v.value");
                    var getname = checkvalue4.get("v.name");
                    enterdrecord4.push({detailslost4: getvalue, typename: getname});
                }  
            }else{
                for (var i = 0; i < checkvalue4.length; i++) {
                    if (checkvalue4[i].get("v.value") != '' && checkvalue4[i].get("v.value") != null) {
                        var getvalue = checkvalue4[i].get("v.value");
                        var getname =  checkvalue4[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord4.push({detailslost4: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r5-->');
                    }  
                    else {
                        var getvalue = '';
                        var getname = checkvalue4[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord4.push({detailslost4: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(checkvalue5)){
                if (checkvalue5.get("v.value") != '') {
                    var getvalue = checkvalue5.get("v.value");
                    var getname = checkvalue5.get("v.name");
                    enterdrecord5.push({detailslost5: getvalue, typename: getname});
                }    
            }else{
                for (var i = 0; i < checkvalue5.length; i++) {
                    if (checkvalue5[i].get("v.value") != '' && checkvalue5[i].get("v.value") != null) {
                        var getvalue = checkvalue5[i].get("v.value");
                        var getname = checkvalue5[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord5.push({detailslost5: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r6-->');
                        
                    } 
                    else {
                        var getvalue = '';
                        var getname = checkvalue5[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord5.push({detailslost5: getvalue, typename: getname});  
                    }
                }
            }
            
            if(!Array.isArray(checkvalue6)){
                if (checkvalue6.get("v.value") != '') {
                    var getvalue = checkvalue6.get("v.value");
                    var getname =  checkvalue6.get("v.name");
                    enterdrecord6.push({detailslost6: getvalue, typename: getname});
                }  
            }else{
                for (var i = 0; i < checkvalue6.length; i++) {
                    if (checkvalue6[i].get("v.value") != '' && checkvalue6[i].get("v.value") != null) {
                        var getvalue = checkvalue6[i].get("v.value");
                        var getname = checkvalue6[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord6.push({detailslost6: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam r7-->');
                    }
                    else {
                        var getvalue = '';
                        var getname = checkvalue6[i].get("v.name");
                        console.log('val value-->'+getvalue);                    
                        enterdrecord6.push({detailslost6: getvalue, typename: getname});  
                    }
                    
                }
            }
            //  var detailRecord = enterdrecord.push(enterdrecord1);
            //  console.log('After push-->'+detailRecord);
            var detailRecord =[];
            var detailRecord1 =[];
            var detailRecord2 =[];
            var detailRecordfinl =[];
            
            
            // var detailRecord =[...enterdrecord,...enterdrecord1,...enterdrecord2,...enterdrecord3,...enterdrecord4,...enterdrecord5,...enterdrecord6];
            for(var key in enterdrecord){
                for(var key1 in enterdrecord1 ){
                    for(var key2 in enterdrecord2 ){
                        if((enterdrecord[key].typename == enterdrecord1[key1].typename) &&  (enterdrecord[key].typename == enterdrecord2[key2].typename)){
                            var detailreasnlst = enterdrecord[key].detailslost;
                            var getname =  enterdrecord[key].typename;
                            var getname1 =  enterdrecord[key].typename1;
                            var detailreasnimp = enterdrecord1[key1].detailslost1;
                            console.log('lll1-->'+detailreasnimp);
                            var detailaction1 = enterdrecord2[key2].detailslost2;
                            detailRecord.push({typename: getname,typename1: getname1,detailresnlost: detailreasnlst,detailresnimp: detailreasnimp,detailactn1: detailaction1});   
                            console.log('the divyam l1-->');
                        }
                        
                    }
                }                                      
            }
            for(var key in enterdrecord3){
                for(var key1 in enterdrecord4 ){
                    for(var key2 in enterdrecord5 ){
                        if((enterdrecord3[key].typename == enterdrecord4[key1].typename) &&  (enterdrecord3[key].typename == enterdrecord5[key2].typename)){
                            var detailaction2 = enterdrecord3[key].detailslost3;
                            var getname =  enterdrecord3[key].typename;
                            var detailaction3 = enterdrecord4[key1].detailslost4;
                            var detailaction4 = enterdrecord5[key2].detailslost5;
                            console.log('lll2-->'+detailaction4);
                            
                            detailRecord1.push({typename: getname,detailactn2: detailaction2,detailactn3: detailaction3,detailactn4: detailaction4});   
                            console.log('the divyam l2-->');
                            
                        }     
                    }
                }                                      
            }
            for(var key in enterdrecord6){
                for(var key1 in detailRecord ){
                    for(var key2 in detailRecord1 ){
                        if((enterdrecord6[key].typename == detailRecord[key1].typename) &&  (enterdrecord6[key].typename == detailRecord1[key2].typename)){
                            var detailaction5 = enterdrecord6[key].detailslost6;
                            var detailreasnlost = detailRecord[key1].detailresnlost;
                            var deailreasnimpv = detailRecord[key1].detailresnimp;
                            var detailaction1 = detailRecord[key1].detailactn1;
                            var getname =  detailRecord[key1].typename;
                            var getname1 =  detailRecord[key1].typename1;
                            var detailaction2 = detailRecord1[key2].detailactn2;
                            var detailaction3 = detailRecord1[key2].detailactn3;
                            var detailaction4 = detailRecord1[key2].detailactn4;
                            detailRecordfinl.push({typename: getname,typename1: getname1,detailrsnlost: detailreasnlost,detailrsnimpv: deailreasnimpv,detailactn1: detailaction1,detailactn2: detailaction2,detailactn3: detailaction3,detailactn4: detailaction4,detailactn5: detailaction5});   
                            console.log('the divyam l3-->');
                            
                        }     
                    }
                }                                      
            }
            for(var key in detailRecordfinl){
                console.log('value for detail1'+detailRecordfinl[key]);                 
                console.log('value for detail1'+detailRecordfinl[key].detailrsnlost);
                console.log('value for detail1'+detailRecordfinl[key].detailrsnimpv);
                console.log('value for detail1'+detailRecordfinl[key].detailactn1);
                console.log('value for detail1'+detailRecordfinl[key].detailactn2);
                console.log('value for detail1'+detailRecordfinl[key].detailactn5);
                console.log('value for detail'+detailRecordfinl[key].typename);
            }  
            
            
            var impdeptchar = component.find("Deptincharge1");
            var actionitem1char = component.find("Deptincharge2");
            var actionitem2char = component.find("Deptincharge3");
            var actionitem3char = component.find("Deptincharge4");
            var actionitem4char = component.find("Deptincharge5");
            var actionitem5char = component.find("Deptincharge6");
            var imprevdeptchar = component.find("Relevantdept1");
            var actionitem1revchar = component.find("Relevantdept2");
            var actionitem2revchar = component.find("Relevantdept3");
            var actionitem3revchar = component.find("Relevantdept4");
            var actionitem4revchar = component.find("Relevantdept5");
            var actionitem5revchar = component.find("Relevantdept6");
            
            var enterdrecord7 =[];
            var enterdrecord8 =[];
            var enterdrecord9 =[];
            var enterdrecord10 =[];
            var enterdrecord11 =[];
            var enterdrecord12 =[];
            var enterdrecord13 =[];
            var enterdrecord14 =[];
            var enterdeptcharg =[];
            var enterdrecord15 =[];
            var enterdrecord16 =[];
            var enterdrecord17 =[];
            var enterdrecord18 =[];
            var enterdrecord19 =[];
            var enterdrecord20 =[];
            var enterdrecord21 =[];
            var enterdrecord22 =[];
            var enterrevldept =[];
            
            
            
            
            if(!Array.isArray(impdeptchar)){
                if (checkvalue.get("v.value") != '') {
                    var getvalue = impdeptchar.get("v.value");
                    var getname = 'name';
                    enterdrecord7.push({impchargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < impdeptchar.length; i++) {
                    if (impdeptchar[i].get("v.value") != '' && impdeptchar[i].get("v.value") != null) {
                        var getvalue = impdeptchar[i].get("v.value");
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord7.push({impchargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr1-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord7.push({impchargedpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem1char)){
                if (actionitem1char.get("v.value") != '') {
                    var getvalue = actionitem1char.get("v.value");
                    var getname = 'name';
                    enterdrecord8.push({actchargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem1char.length; i++) {
                    if (actionitem1char[i].get("v.value") != '' && actionitem1char[i].get("v.value") != null) {
                        var getvalue = actionitem1char[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord8.push({actchargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr2-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord8.push({actchargedpt: getvalue, typename: getname});  
                    }
                }
            }
            
            if(!Array.isArray(actionitem2char)){
                if (actionitem2char.get("v.value") != '') {
                    var getvalue = actionitem2char.get("v.value");
                    var getname = 'name';
                    enterdrecord9.push({act1chargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem2char.length; i++) {
                    if (actionitem2char[i].get("v.value") != '' && actionitem2char[i].get("v.value") != null) {
                        var getvalue = actionitem2char[i].get("v.value");
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord9.push({act1chargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr3-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord9.push({act1chargedpt: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(actionitem3char)){
                if (actionitem3char.get("v.value") != '') {
                    var getvalue = actionitem3char.get("v.value");
                    var getname = 'name';
                    enterdrecord10.push({act2chargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem3char.length; i++) {
                    if (actionitem3char[i].get("v.value") != '' && actionitem3char[i].get("v.value") != null) {
                        var getvalue = actionitem3char[i].get("v.value");
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord10.push({act2chargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr4-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord10.push({act2chargedpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem4char)){
                if (actionitem4char.get("v.value") != '') {
                    var getvalue = actionitem4char.get("v.value");
                    var getname = 'name';
                    enterdrecord11.push({act3chargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem4char.length; i++) {
                    if (actionitem4char[i].get("v.value") != '' && actionitem4char[i].get("v.value") != null) {
                        var getvalue = actionitem4char[i].get("v.value");
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord11.push({act3chargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr5-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord11.push({act3chargedpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem5char)){
                if (actionitem5char.get("v.value") != '') {
                    var getvalue = actionitem5char.get("v.value");
                    var getname =  'name';
                    enterdrecord12.push({act4chargedpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem5char.length; i++) {
                    if (actionitem5char[i].get("v.value") != '' && actionitem5char[i].get("v.value") != null) {
                        var getvalue = actionitem5char[i].get("v.value");
                        var getname =  'name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord12.push({act4chargedpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rr6-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord12.push({act4chargedpt: getvalue, typename: getname});  
                    }
                    
                }
            }
            
            for(var key in enterdrecord7 ){
                for(var key1 in enterdrecord8 ){
                    for(var key2 in enterdrecord9){
                        if((enterdrecord7[key].typename == enterdrecord8[key1].typename) && (enterdrecord7[key].typename == enterdrecord9[key2].typename)){
                            var imprchargedpt = enterdrecord7[key].impchargedpt;
                            var getname =  enterdrecord7[key].typename;
                            var actichargedpt = enterdrecord8[key1].actchargedpt;
                            var acti1chargedpt = enterdrecord9[key2].act1chargedpt;
                            enterdrecord13.push({typename: getname,impchargedpt: imprchargedpt,actchargedpt: actichargedpt,act1chargedpt: acti1chargedpt});   
                        }    
                    }
                }                                      
            }
            
            for(var key in enterdrecord10 ){
                for(var key1 in enterdrecord11 ){
                    for(var key2 in enterdrecord12){
                        if((enterdrecord10[key].typename == enterdrecord11[key1].typename) &&  (enterdrecord10[key].typename == enterdrecord12[key2].typename)){
                            var acti2chargedpt = enterdrecord10[key].act2chargedpt;
                            var getname =  enterdrecord10[key].typename;
                            var acti3chargedpt = enterdrecord11[key1].act3chargedpt;
                            var acti4chargedpt = enterdrecord12[key2].act4chargedpt;
                            enterdrecord14.push({typename: getname,act2chargedpt: acti2chargedpt,act3chargedpt: acti3chargedpt,act4chargedpt: acti4chargedpt});   
                        }    
                    }
                }                                      
            }
            
            for(var key in enterdrecord13){
                for(var key1 in enterdrecord14){
                    
                    if((enterdrecord13[key].typename == enterdrecord14[key1].typename)){
                        var imprchargedpt = enterdrecord13[key].impchargedpt;
                        var getname =       enterdrecord13[key].typename;
                        var actichargedpt = enterdrecord13[key].actchargedpt;
                        var acti1chargedpt = enterdrecord13[key].act1chargedpt;
                        var acti2chargedpt = enterdrecord14[key1].act2chargedpt;
                        var acti3chargedpt = enterdrecord14[key1].act3chargedpt;
                        var acti4chargedpt = enterdrecord14[key1].act4chargedpt;
                        enterdeptcharg.push({typename: getname,impchargedpt: imprchargedpt,actchargedpt: actichargedpt,act1chargedpt: acti1chargedpt,act2chargedpt: acti2chargedpt,act3chargedpt: acti3chargedpt,act4chargedpt: acti4chargedpt})
                        
                    }                           
                }
                
            }
            for(var key in enterdeptcharg){
                console.log('value for detail'+enterdeptcharg[key]);                 
                console.log('value for detail'+enterdeptcharg[key].impchargedpt);
                console.log('value for detail'+enterdeptcharg[key].act1chargedpt);
                console.log('value for detail'+enterdeptcharg[key].act2chargedpt);
                console.log('value for detail'+enterdeptcharg[key].act4chargedpt);
                
            } 
            if(!Array.isArray(imprevdeptchar)){
                if (checkvalue.get("v.value") != '') {
                    var getvalue = imprevdeptchar.get("v.value");
                    var getname = 'name';
                    enterdrecord15.push({imprevldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < imprevdeptchar.length; i++) {
                    if (imprevdeptchar[i].get("v.value") != '' && imprevdeptchar[i].get("v.value") != null) {
                        var getvalue = imprevdeptchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord15.push({imprevldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr1-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord15.push({imprevldpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem1revchar)){
                if (actionitem1revchar.get("v.value") != '') {
                    var getvalue = actionitem1revchar.get("v.value");
                    var getname = 'name';
                    enterdrecord16.push({actrevldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem1revchar.length; i++) {
                    if (actionitem1revchar[i].get("v.value") != '' && actionitem1revchar[i].get("v.value") != null) {
                        var getvalue = actionitem1revchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord16.push({actrevldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr2-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        enterdrecord16.push({actrevldpt: getvalue, typename: getname});  
                    }
                }
            }
            
            if(!Array.isArray(actionitem2revchar)){
                if (actionitem2revchar.get("v.value") != '') {
                    var getvalue = actionitem2revchar.get("v.value");
                    var getname = 'name';
                    enterdrecord17.push({act1revldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem2revchar.length; i++) {
                    if (actionitem2revchar[i].get("v.value") != '' && actionitem2revchar[i].get("v.value") != null) {
                        var getvalue = actionitem2revchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord17.push({act1revldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr3-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord17.push({act1revldpt: getvalue, typename: getname});  
                    }
                    
                }
            }
            if(!Array.isArray(actionitem3revchar)){
                if (actionitem3revchar.get("v.value") != '') {
                    var getvalue = actionitem3revchar.get("v.value");
                    var getname = 'name';
                    enterdrecord18.push({act2revldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem3revchar.length; i++) {
                    if (actionitem3revchar[i].get("v.value") != '' && actionitem3revchar[i].get("v.value") != null) {
                        var getvalue = actionitem3revchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord18.push({act2revldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr4-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord18.push({act2revldpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem4revchar)){
                if (actionitem4revchar.get("v.value") != '') {
                    var getvalue = actionitem4revchar.get("v.value");
                    var getname = 'name';
                    enterdrecord19.push({act3revldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem4revchar.length; i++) {
                    if (actionitem4revchar[i].get("v.value") != '' && actionitem4revchar[i].get("v.value") != null) {
                        var getvalue = actionitem4revchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord19.push({act3revldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr5-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord19.push({act3revldpt: getvalue, typename: getname});  
                    }
                }
            }
            if(!Array.isArray(actionitem5revchar)){
                if (actionitem5revchar.get("v.value") != '') {
                    var getvalue = actionitem5revchar.get("v.value");
                    var getname = 'name';
                    enterdrecord20.push({act4revldpt: getvalue, typename: getname});
                }
            }else{
                for (var i = 0; i < actionitem5revchar.length; i++) {
                    if (actionitem5revchar[i].get("v.value") != '' && actionitem5revchar[i].get("v.value") != null) {
                        var getvalue = actionitem5revchar[i].get("v.value");
                        var getname ='name'+i;
                        console.log('val value-->'+getvalue);  
                        console.log('val value-->'+getname);                    
                        
                        enterdrecord20.push({act4revldpt: getvalue, typename: getname});
                        // component.set("v.checkboxList",selectedrecord);
                        console.log('Divyam rrr6-->');
                        
                    }
                    else {
                        var getvalue = '';
                        var getname = 'name'+i;
                        console.log('val value-->'+getvalue);                    
                        enterdrecord20.push({act4revldpt: getvalue, typename: getname});  
                    }
                }
            }
            
            for(var key in enterdrecord15 ){
                for(var key1 in enterdrecord16 ){
                    for(var key2 in enterdrecord17){
                        if((enterdrecord15[key].typename == enterdrecord16[key1].typename) && (enterdrecord15[key].typename == enterdrecord17[key2].typename)){
                            var impvrevldpt = enterdrecord15[key].imprevldpt;
                            var getname =  enterdrecord15[key].typename;
                            var actirevldpt = enterdrecord16[key1].actrevldpt;
                            var acti1revldpt = enterdrecord17[key2].act1revldpt;
                            enterdrecord21.push({typename: getname,imprevldpt: impvrevldpt,actrevldpt: actirevldpt,act1revldpt: acti1revldpt});   
                        }    
                    }
                }                                      
            }
            
            for(var key in enterdrecord18 ){
                for(var key1 in enterdrecord19 ){
                    for(var key2 in enterdrecord20){
                        if((enterdrecord18[key].typename == enterdrecord19[key1].typename) &&  (enterdrecord18[key].typename == enterdrecord20[key2].typename)){
                            var acti2revldpt = enterdrecord18[key].act2revldpt;
                            var getname =  enterdrecord18[key].typename;
                            var acti3revldpt = enterdrecord19[key1].act3revldpt;
                            var acti4revldpt = enterdrecord20[key2].act4revldpt;
                            enterdrecord22.push({typename: getname,act2revldpt: acti2revldpt,act3revldpt: acti3revldpt,act4revldpt: acti4revldpt});   
                        }    
                    }
                }                                      
            }
            
            for(var key in enterdrecord21){
                for(var key1 in enterdrecord22){
                    
                    if((enterdrecord21[key].typename == enterdrecord22[key1].typename)){
                        var imprrevldpt = enterdrecord21[key].imprevldpt;
                        var getname =       enterdrecord21[key].typename;
                        var actirevldpt = enterdrecord21[key].actrevldpt;
                        var acti1revldpt = enterdrecord21[key].act1revldpt;
                        var acti2revldpt = enterdrecord22[key1].act2revldpt;
                        var acti3revldpt = enterdrecord22[key1].act3revldpt;
                        var acti4revldpt = enterdrecord22[key1].act4revldpt;
                        enterrevldept.push({typename: getname,imprevldpt: imprrevldpt,actrevldpt: actirevldpt,act1revldpt: acti1revldpt,act2revldpt: acti2revldpt,act3revldpt: acti3revldpt,act4revldpt: acti4revldpt})
                        
                    }                           
                }
                
            }
            for(var key in enterrevldept){
                console.log('value for detail rev-->'+enterrevldept[key]);                 
                console.log('value for detail rev-->'+enterrevldept[key].imprevldpt);
                console.log('value for detail rev-->'+enterrevldept[key].actrevldpt);
                console.log('value for detail rev-->'+enterrevldept[key].act3revldpt);
                console.log('value for detail rev-->'+enterrevldept[key].act4revldpt);
                
            } 
            //var codelst = component.get("v.codelist");
            var detailRecordfinl1 =[];
            for(var key in detailRecordfinl){
                for(var key1 in enterdeptcharg){
                    for(var key2 in enterrevldept){
                        if((enterdeptcharg[key1].typename == enterrevldept[key2].typename)
                           && (detailRecordfinl[key].typename1 == enterdeptcharg[key1].typename)){
                            var detailaction5 = detailRecordfinl[key].detailactn5;
                            var detailreasnlost = detailRecordfinl[key].detailrsnlost;
                            var deailreasnimpv = detailRecordfinl[key].detailrsnimpv;
                            var detailaction1 = detailRecordfinl[key].detailactn1;
                            var getname = detailRecordfinl[key].typename;
                            var detailaction2 = detailRecordfinl[key].detailactn2;
                            var detailaction3 = detailRecordfinl[key].detailactn3;
                            var detailaction4 = detailRecordfinl[key].detailactn4;
                            var imprchargedpt = enterdeptcharg[key1].impchargedpt;
                            var actichargedpt = enterdeptcharg[key1].actchargedpt;
                            var acti1chargedpt = enterdeptcharg[key1].act1chargedpt;
                            var acti2chargedpt = enterdeptcharg[key1].act2chargedpt;
                            var acti3chargedpt = enterdeptcharg[key1].act3chargedpt;
                            var acti4chargedpt = enterdeptcharg[key1].act4chargedpt;  
                            var imprrevldpt = enterrevldept[key2].imprevldpt;
                            console.log('imprrevldpt value = '+ imprrevldpt);
                            var actirevldpt = enterrevldept[key2].actrevldpt;
                            var acti1revldpt = enterrevldept[key2].act1revldpt;
                            var acti2revldpt = enterrevldept[key2].act2revldpt;
                            var acti3revldpt = enterrevldept[key2].act3revldpt;
                            var acti4revldpt = enterrevldept[key2].act4revldpt;
                            detailRecordfinl1.push({typename: getname,detailrsnlost: detailreasnlost,detailrsnimpv: deailreasnimpv,detailactn1: detailaction1,detailactn2: detailaction2,detailactn3: detailaction3,detailactn4: detailaction4,detailactn5: detailaction5,
                                                    impchargedpt: imprchargedpt,actchargedpt: actichargedpt,act1chargedpt: acti1chargedpt,act2chargedpt: acti2chargedpt,act3chargedpt: acti3chargedpt,act4chargedpt: acti4chargedpt,
                                                    imprevldpt: imprrevldpt,actrevldpt: actirevldpt,act1revldpt: acti1revldpt,act2revldpt: acti2revldpt,act3revldpt: acti3revldpt,act4revldpt: acti4revldpt
                                                   });   
                        }
                    }
                }
            }
            component.set("v.LostCounterMsrList",detailRecordfinl1);
            
            for(var key in detailRecordfinl1){
                console.log('value for detail last-->'+detailRecordfinl1[key]);     
                console.log('value for detail last-->'+detailRecordfinl1[key].typename);
                console.log('value for detail last impchargedpt-->'+detailRecordfinl1[key].impchargedpt);
                console.log('value for detail last impchargedpt-->'+detailRecordfinl1[key].imprevldpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].detailrsnlost);
                console.log('value for detail last-->'+detailRecordfinl1[key].detailactn1);
                console.log('value for detail last-->'+detailRecordfinl1[key].detailactn4);
                console.log('value for detail last-->'+detailRecordfinl1[key].actchargedpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].act3chargedpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].act4chargedpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].actrevldpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].act2revldpt);
                console.log('value for detail last-->'+detailRecordfinl1[key].act3revldpt);
            }
            var picklistvalues =[];
            var checkpicklist = component.find("Typepicklist");
            var picklstval= checkpicklist.get("v.value");
            console.log('picklist value-->'+picklstval);
                if(component.get("v.lostresndetail") != '' && component.get("v.lostresndetail") != null){
                 var lostresndtail = component.get("v.lostresndetail");  
                }
                else {
                      var lostresndtail ='';  
                    if(picklstval !='' && picklstval != null ){
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        console.log('Toast1');
                        component.set("v.setmandtryfields",true);

                    }
                    
                }
                 if(component.get("v.impresndetail") != '' && component.get("v.impresndetail") != null){
                 var impresndtail = component.get("v.impresndetail");  
                }
                else {
                    var impresndtail = '';
                    if(picklstval != '' && picklstval != null ){
                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                           console.log('Toast2');

                        component.set("v.setmandtryfields",true);
                    }
                    
                }
                
                if(component.get("v.action1detail") != '' && component.get("v.action1detail") != null){
                 var action1details = component.get("v.action1detail");  
                }
                else {
                   var action1details = '';
                    if(picklstval != '' && picklstval != null ){
                           console.log('Toast3');

                        helper.showMyToast('error',$A.get("$Label.c.Error_Mandatory_Fields_Table2"));
                        component.set("v.setmandtryfields",true);
                    }
                    
                }

                
            var action2details = component.get("v.action2detail");
            var action3details = component.get("v.action3detail");
            var action4details = component.get("v.action4detail");
            var action5details = component.get("v.action5detail");
            
            if(component.get("v.imprvchngdept") != '' && component.get("v.imprvchngdept") != null){
                var imprvchngdepts = component.get("v.imprvchngdept");
            }
            else{                
                 var imprvchngdepts = '';


            }
            if(component.get("v.imprvrevdept") != '' && component.get("v.imprvrevdept") != null){
            var imprvrevdepts = component.get("v.imprvrevdept");
            }
            else {
             var imprvrevdepts = '';
                 if(picklstval !='' && picklstval != null ){
                    
                }
  
            }
            console.log('picklist imprvrevdept-->'+imprvrevdepts);
             if(component.get("v.action1chngdept") != '' && component.get("v.action1chngdept") != null){
            var action1chngdepts = component.get("v.action1chngdept");
             }
            else {
            var action1chngdepts = '';

   
            }
           if(component.get("v.action2chngdept") != '' ){
            var action2chngdepts = component.get("v.action2chngdept");
           }
            else {
              var action2chngdepts = '';
    
            }
            if(component.get("v.action3chngdept") != ''){
            var action3chngdepts = component.get("v.action3chngdept");
            }
            else{
            var action3chngdepts = '';
   
            }
            if(component.get("v.action4chngdept") != ''){
            var action4chngdepts = component.get("v.action4chngdept");
            }
            else {
              var action4chngdepts = '';
    
            }
           if(component.get("v.action5chngdept") != ''){
            var action5chngdepts = component.get("v.action5chngdept");
           }
            else {
             var action5chngdepts = '';
               
            }
             if(component.get("v.action1revdept") != '' && component.get("v.action1revdept") != null){
            var action1revdepts = component.get("v.action1revdept");
           }
            else {
             var action1revdepts = '';

               
            }

            if(component.get("v.action2revdept") != ''){
            var action2revdepts = component.get("v.action2revdept");
           }
            else {
             var action2revdepts = '';
               
            }
            if(component.get("v.action3revdept") != ''){
            var action3revdepts = component.get("v.action3revdept");
           }
            else {
             var action3revdepts = '';
               
            }
            if(component.get("v.action4revdept") != ''){
            var action4revdepts = component.get("v.action4revdept");
           }
            else {
             var action4revdepts = '';
               
            }
            if(component.get("v.action5revdept") != ''){
            var action5revdepts = component.get("v.action5revdept");
           }
            else {
             var action5revdepts = '';
               
            }
            
            picklistvalues.push({picklistval: picklstval,lostresndetail: lostresndtail,impresndetail: impresndtail,action1detail: action1details,action2detail: action2details,action3detail: action3details,action4detail: action4details,action5detail: action5details,imprvchngdept: imprvchngdepts,imprvrevdept: imprvrevdepts,action1chngdept: action1chngdepts,action2chngdept: action2chngdepts,action3chngdept: action3chngdepts,action4chngdept: action4chngdepts, action5chngdept: action5chngdepts,action1revdept: action1revdepts,action2revdept: action2revdepts,action3revdept: action3revdepts,action4revdept: action4revdepts,action5revdept: action5revdepts });          
            console.log('the picklistvale-->'+picklistvalues);
            component.set("v.piclistvalues",picklistvalues);
            
            for(var key in picklistvalues){
                console.log('values after push-->'+picklistvalues[key].picklistval);
                console.log('values after push-->'+picklistvalues[key].imprvrevdept);
                
            }
            
            
            console.log('Akash1');
                if(component.get("v.setmandtryfields") == false){
            helper.insertLostCounter(component, event);
                }
            }
            },
        changePicklistval : function(component, event, helper) {
            console.log('enter into the changepicklist-->');
                var checkpicklist = component.find("Typepicklist");
                var picklstval= checkpicklist.get("v.value");
              if(picklstval == ''){
                component.set("v.lostresndetail",'');
                component.set("v.impresndetail",'');
                component.set("v.action1detail",'');
                component.set("v.action2detail",'');
                component.set("v.action3detail",'');
                component.set("v.action4detail",'');
                component.set("v.action5detail",'');
                component.set("v.imprvchngdept",'');
                component.set("v.imprvrevdept",'');
                component.set("v.action1chngdept",'');
                component.set("v.action2chngdept",'');
                component.set("v.action3chngdept",'');
                component.set("v.action4chngdept",'');
                component.set("v.action5chngdept",'');
                component.set("v.action1revdept",'');
                component.set("v.action2revdept",'');
                component.set("v.action3revdept",'');
                component.set("v.action4revdept",'');
                component.set("v.action5revdept",'');
            }
        }
        

    })