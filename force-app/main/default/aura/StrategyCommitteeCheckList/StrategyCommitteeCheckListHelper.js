({
    doInit : function(component, event, helper) {
        console.log(':::::StrategyCommitteeCheckList doInit:::::');
        var self = this;
        var params = {'deadline' : component.get('v.deadline'),
                      'decision' : component.get('v.decision'),
                      'isApproval' : component.get('v.approval')};
        self.apex(component, 'getInit', params)
        .then(function(result){
            console.log(result);
            // for(var i=0; i<result.length; i++){
            //     if(result.isCreater && result.isPm){
            //         result.isCreater = false
            //     }
            // }
            component.set('v.bizReviewList', result.initWrapper);
            component.set('v.totalNumberOfRows', result.size);
            component.set('v.data', result.initWrapper);
            component.set('v.rowsToLoad', result.initWrapper.length);
            if(result.size == result.initWrapper.length) component.set('v.enableInfiniteLoading', false);
        })
        .catch(function(errors){
                console.log(errors);
                self.errorHander(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
    },
    
    getCheckList : function(component, event, helper, recordId){
        console.log('::::: StrategyCommitteeCheckList getCheckList :::::');
        var self = this;
        self.apex(component, 'getQuestionList', {Id : recordId})
        .then(function(result){
            console.log(result);
            var questionL = result.questionWrapperList;
            
            for(var i=0; i<questionL.length; i++){
                var answerL = questionL[i].answerList;
                result.questionWrapperList[i].question.Question__c = result.questionWrapperList[i].question.Question__c.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                
                for(var j=0; j<answerL.length; j++){
                    result.questionWrapperList[i].answerList[j].AnswerType = result.answerTypeMap[answerL[j].AnswerType__c];
                }

                result.questionWrapperList[i].question.Question__c = questionL[i].idx + '. ' + result.questionWrapperList[i].question.Question__c;
                if(result.questionWrapperList[i].question.TotalScore__c == null){
                    result.questionWrapperList[i].question.TotalScore__c = 0;
                }
                if(result.questionWrapperList[i].question.TotalPMScore__c == null){
                    result.questionWrapperList[i].question.TotalPMScore__c = 0;
                }
            }

            component.set('v.checkList', result);
            self.countCheckAnswer(component);
        })
        .catch(function(errors){
                console.log(errors);
                self.errorHander(errors);
        }).finally(function(){
        });
    },    
    
    saveAnswer : function(component, event, helper, checkQuestion){
        console.log('::::: StrategyCommitteeCheckList saveAnswer :::::');
        console.log(checkQuestion);
        var self = this;
        self.apex(component, 'updateAnswer', {objList : checkQuestion})
        .then(function(result){
            console.log(result);
            helper.showtoast(result.isSuccess, result.title, result.message);
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
        }).finally(function(){
            component.set('v.isSave', false);
            //component.set('v.isModal', false);
            component.set('v.isModalLoading', false);
            // var init = component.get('c.init');
            // $A.enqueueAction(init);

        });
    },

    countCheckAnswer : function(component){
        var checklist = component.get('v.checkList'),
            count = 0,
            QList = checklist.questionWrapperList;
        console.log(QList);
        for(var i=0; i<QList.length; i++){
            var AList = QList[i].answerList;
            checklist.questionWrapperList[i].question.IsPMAnswer__c = '0';
            checklist.questionWrapperList[i].question.IsAnswer__c = '0';
            for(var j=0; j<AList.length; j++){
                if(checklist.isPm && AList[j].IsPMChecked__c){
                    count += 1;
                    checklist.questionWrapperList[i].question.IsPMAnswer__c = '1';
                    break;
                }
                if(!checklist.isPm && AList[j].IsChecked__c){
                    count += 1;
                    checklist.questionWrapperList[i].question.IsAnswer__c = '1';
                    break;
                }
            }
        }

        component.set('v.checkList', checklist);
        component.set('v.checkAnswerCount', count);
    },

    navigatieToSObject : function (recordId, slideName) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": slideName
        });
        navEvt.fire();
    },    

    moreData : function(component, event, helper){
        console.log(':::::StrategyCommitteeCheckList doInit:::::');
        var self = this;
        
        var params = {'offset' : component.get('v.rowsToLoad'),
                      'deadline' : component.get('v.deadline'),
                      'decision' : component.get('v.decision'),
                      'isApproval' : component.get('v.approval')};
        self.apex(component, 'getMoreData', params)
        .then(function(result){
            var data = component.get('v.data');
            var newData = data.concat(result);
            
            if(newData.length >= component.get('v.totalNumberOfRows')) component.set('v.enableInfiniteLoading', false);

            component.set('v.rowsToLoad', newData.length);
            component.set('v.data', newData);
        })
        .catch(function(errors){
                console.log(errors);
                self.errorHander(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
            component.set('v.loding', false);
        });
    },

    getPickValue : function(component, event, helper){
        console.log(':::::StrategyCommitteeCheckList getPickValue:::::');
        var self = this;
        
        self.apex(component, 'getPickVal', {})
        .then(function(result){
            console.log(result);
            component.set('v.decisionOption', result.decision);
            component.set('v.dateOptions', result.deadline);
        })
        .catch(function(errors){
                console.log(errors);
                self.errorHander(errors);
        }).finally(function(){
            
        });
    },

    /**
     * Common Functions
     */

    showtoast : function(type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : type,
            "title": title,
            "duration": 10000,
            "message": message
        });
        toastEvent.fire();
    },

    apex : function(component, apexAction, params) {
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
                self.showtoast('error', '', err.exceptionType + " : " + err.message);
            });
        } else {
            console.log(errors);
            self.showtoast('error', '', 'Unknown error in javascript controller/helper.')
        }
    }
})