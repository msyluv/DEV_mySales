/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-07-30
 * @last modified by  : seonju.jin@dkbmc.com
**/
({

	getBaseInfo: function(component){
		// 프로필 정보, CronTrigger 정보 가져오기
		var self = this;

		self.apex(component,'getInfo',{}
		).then(function(result){
			console.log(result);
			console.log(result);
			var isAdmin = result.isAdminProfile;
			component.set('v.isAdminProfile',isAdmin);

			if(!isAdmin){
				self.showToast('ERROR','ERROR', 'ADMIN만 가능합니다.');
			}else{
				
				/* var profileList = result.BackupProfileList;
				for(var i = 0 ; i< profileList.length; i++){
					profileList[i].User__rName = profileList[i].User__r.Name;
					var profile =profileList[i].User__r.Profile;
					console.log(profile);
					profileList[i].User__rProfileName = JSON.stringify(profile);
				}
				component.set('v.BackupProfileList', profileList); */
				
				var setList = result.CronTriggerList;
				for(var i = 0 ; i< setList.length; i++){
					setList[i].CronJobDetailName = setList[i].CronJobDetail.Name;
				}
				
				component.set('v.cronTriggerList', setList);

			}
		}).catch(function(errors){
			self.errorHandler(errors);
		});
	},

	//유저 프로필 정보 ReadOnly update
	updateReadProfile: function(component){
		var self = this;
		console.log('isadmin',component.get('v.isAdminProfile'));
		if(component.get('v.isAdminProfile')){
			self.apex(component,'updateReadOnlyProfile',{}
			).then(function(result){
				console.log('result');
				console.log(result);
				component.set('v.BackupProfileList', result);
			}).catch(function(errors){
				self.errorHandler(errors);
			});
		}
	},

	//유저 프로필 정보 복원
	updateRestoreProfile: function(component){
		var self = this;
		if(component.get('v.isAdminProfile')){
			self.apex(component,'updateRestoreUserProfile',{}
			).then(function(result){
				component.set('v.BackupProfileList', result);
			}).catch(function(errors){
				self.errorHandler(errors);
			});
		}
	},

	//배치 실행 (IF-141, IF-133, IF-135)
	runBatchExecute: function(component){
		var self = this;
		if(component.get('v.isAdminProfile')){
			self.apex(component,'IFbatchExecute',{}
			).then(function(result){
				self.showToast('SUCCESS','SUCCESS','실행 성공');
			}).catch(function(errors){
				self.errorHandler(errors);
			});
		}
	},

	getCronTrigger: function(component){
		var self = this;
		if(component.get('v.isAdminProfile')){
			self.apex(component,'getCronTriggerList',{}
		).then(function(result){
			var setList = result;
			for(var i = 0 ; i< setList.length; i++){
				setList[i].CronJobDetailName = setList[i].CronJobDetail.Name;
			}
			component.set('v.cronTriggerList', setList);
		}).catch(function(errors){
			self.errorHandler(errors);
		});
		}
	},
	getBackupProfile: function(component){
		var self = this;
		if(component.get('v.isAdminProfile')){
			self.apex(component,'getBackupProfileList',{}
		).then(function(result){
			var profileList = result;
			for(var i = 0 ; i< profileList.length; i++){
				profileList[i].User__rName = profileList[i].User__r.Name;
				var profile =profileList[i].User__r.Profile;
				console.log(profile);
				profileList[i].User__rProfileName = JSON.stringify(profile);
			}
			component.set('v.BackupProfileList', profileList);
		}).catch(function(errors){
			self.errorHandler(errors);
		});
		}
	},

	apex : function(component, apexAction, params){
        return new Promise( $A.getCallback( function( resolve, reject ) {
			var action = component.get("c."+apexAction+"");
			//if(action == null || action == undefined){console.log('apexAction is undefined'); return;}
			action.setParams( params );
            action.setCallback( this, function(callbackResult) {
                if(callbackResult.getState()=='SUCCESS') {
                    resolve( callbackResult.getReturnValue() );
                }
                if(callbackResult.getState()=='ERROR') {
                    reject( callbackResult.getError() );
                }
            });
            $A.enqueueAction( action );
        }));
	},
    
    errorHandler : function(errors){
		var self = this;
		if(Array.isArray(errors)){
			errors.forEach(function(err){
				self.showToastSticky('error', 'ERROR', err.exceptionType + " : " + err.message);
			});
		} else {
			console.log(errors);
			self.showToastSticky('error', 'ERROR' ,'errors:'+ errors.message);
		}
	},

    showToast : function(type, title, message){
		var toastEvent = $A.get("e.force:showToast");
		var mode = (type == 'success') ? 'pester' : 'sticky';
        toastEvent.setParams({
            "type" : type,
            "title": title,
			"message": message,
			"mode": mode,
			"duration": 5000
        });
        toastEvent.fire();
	},

	showToastSticky : function(type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
			"mode" : 'sticky',
            "type" : type,
            "title": title,
            "message": message
        });
        toastEvent.fire();
	},
})