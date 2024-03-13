({
    doInit : function(component, event, helper) {
        console.log('::::: QuestionOwnerView doInit :::::');

        var self = this;
        self.apex(component, 'getQuestionList', {recordId : component.get('v.recordId')})
        .then(function(result){
            console.log(result);
            var questionL = result.questionWrapperList,
                PManswerQCount = 0,
                answerQCount = 0,
                isCreater = result.isCreater,
                isPm = result.isPm;

            for(var i=0; i<questionL.length; i++){
                //console.log(questionL[i]);
                questionL[i].question.Question = questionL[i].question.Question__c.replace(/<(\/)?([a-zA-Z]*)(\s[a-zA-Z]*=[^>]*)?(\s)*(\/)?>/ig, "").replaceAll('&amp;', '&');
                var answerL = questionL[i].answerList,
                    isCount = false,
                    isCountPm = false;
                //console.log(answerL);
                for(var j=0; j<answerL.length; j++){
                    result.questionWrapperList[i].answerList[j].AnswerType = result.answerTypeMap[answerL[j].AnswerType__c];
                    if(!isCount && result.questionWrapperList[i].answerList[j].IsChecked__c){
                        answerQCount += 1;
                        isCount = true;
                    }
                    if (!isCountPm && result.questionWrapperList[i].answerList[j].IsPMChecked__c){
                        PManswerQCount += 1;
                        isCountPm = true;
                    }

                    if(answerL[j].AnswerType__c == '법적리스크' || answerL[j].AnswerType__c == '손해배상'){
                        questionL[i].answerList[j].Answer__c = result.questionWrapperList[i].answerList[j].AnswerType + questionL[i].answerList[j].Answer__c;
                    }
                }
                // console.log(answerQCount);
                // console.log(PManswerQCount);
            }

            console.log(result);
            component.set('v.readOnlyQList', questionL);
            component.set('v.questionList', result.questionWrapperList);
            component.set('v.bizReviewObj', result.bizReview);
            component.set('v.totalScore', result.totalScore);
            component.set('v.totalPMScore', result.totalPMScore);
            component.set('v.IsAnswerCount', answerQCount);
            component.set('v.IsPMAnswerCount', PManswerQCount);
            component.set('v.isCreater', isCreater);
            component.set('v.isPm', isPm);
            //component.set('v.updateQuestionList', result);
        })
        .catch(function(errors){
            console.log(errors);
            self.errorHander(errors);
        }).finally(function(){
            component.set('v.isLoading', false);
        });
    },    

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