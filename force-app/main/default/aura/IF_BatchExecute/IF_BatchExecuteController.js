/**
 * @description       : 
 * @author            : seonju.jin@dkbmc.com
 * @group             : 
 * @last modified on  : 2021-07-30
 * @last modified by  : seonju.jin@dkbmc.com
**/
({
	init : function(component, event, helper) {
		component.set('v.profileColumns',[
			{label: 'name', fieldName: 'Name', type: 'text'},
            {label: 'User__c', fieldName: 'User__c', type: 'text'},
            {label: 'User__r.Name', fieldName: 'User__rName', type: 'text'},
            {label: 'User__r.Profile', fieldName: 'User__rProfileName', type: 'text', fixedWidth:'400px'},
            {label: 'BackupProfileId__c', fieldName: 'BackupProfileId__c', type: 'text'},
            {label: 'RestoreDateTime__c', fieldName: 'RestoreDateTime__c', type: 'date'},
            {label: 'IsRestoreSuccess__c', fieldName: 'IsRestoreSuccess__c', type: 'boolean'},
            {label: 'UpdateErrMsg__c', fieldName: 'UpdateErrMsg__c', type: 'text'}
		]);
		component.set('v.cronColumns',[
			{label: 'CronJobDetailId', fieldName: 'CronJobDetailId', type: 'text'},
            {label: 'CronJobDetailName', fieldName: 'CronJobDetailName', type: 'Object'},
            {label: 'NextFireTime', fieldName: 'NextFireTime', type: 'date'},
            {label: 'PreviousFireTime', fieldName: 'PreviousFireTime', type: 'date'},
            {label: 'State', fieldName: 'State', type: 'text'},
            {label: 'StartTime', fieldName: 'StartTime', type: 'date'},
            {label: 'Close EndTime', fieldName: 'EndTime', type: 'date'},
            {label: 'CronExpression', fieldName: 'CronExpression', type: 'text'},
            {label: 'TimesTriggered', fieldName: 'TimesTriggered', type: 'text'}
		]);

		helper.getBaseInfo(component, event);
	},

	updateReadProfile: function(component, event, helper){
		helper.updateReadProfile(component);
	},
	updateRestoreProfile: function(component, event, helper){
		helper.updateRestoreProfile(component);
	},
	runBatchExecute: function(component, event, helper){
		helper.runBatchExecute(component);
	},
	getCronTrigger: function(component, event, helper){
		helper.getCronTrigger(component);
	},
	getBackupProfile: function(component, event, helper){
		helper.getBackupProfile(component);
	},
})