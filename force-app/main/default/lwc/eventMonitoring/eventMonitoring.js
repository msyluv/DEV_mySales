/**
 * @description	   : 
 * @author			: woomg@dkbmc.com
 * @group			 : 
 * @last modified on  : 04-07-2021
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date		 Author			Modification
 * 1.0   04-02-2021   woomg@dkbmc.com   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import checkAccessPermission from "@salesforce/apex/EventMonitoringController.checkAccessPermission";
import getEventTypes from "@salesforce/apex/EventMonitoringController.getEventTypes";
import getDateRanges from "@salesforce/apex/EventMonitoringController.getDateRanges";
import getEventLogs from "@salesforce/apex/EventMonitoringController.getEventLogs";
import getSessionId from "@salesforce/apex/EventMonitoringController.getSessionId";

const FIELDS = [ 'LogFile' ];

export default class EventMonitoring extends NavigationMixin(LightningElement) {
	@track  eventTypes = new Array();
	@track  dateRanges = new Array();
	@track  eventType = "Login";
	@track	interval = "Daily";
	@track	logDate = "";
	@track	disableDate = false;

	@track	eventLogs = new Array();

	@track	progressOpen = false;
	@track	isCancel = false;
	@track	progress = 0;
	
	columns = [
		{ label: 'Event Type', fieldName: 'EventType', type: 'text', fixedWidth:200 },
		{ label: 'Interval', fieldName: 'Interval', type: 'text', fixedWidth:100 },
		{ label: 'API', fieldName: 'ApiVersion', type: 'number', fixedWidth:70, typeAttributes: { minimumIntegerDigits: '2'}},
		{ label: 'Log Date (GMT)', fieldName: 'LogDate', type: 'date', fixedWidth:200, typeAttributes: { year:"numeric", month:"2-digit", day:"2-digit", hour:"2-digit", minute:"2-digit", hour12:"false", timeZone: "UTC" }},
		{ label: 'File size', fieldName: 'LogFileLength', type: 'number', fixedWidth: 100, typeAttributes: { minimumIntegerDigits: '2'}},
		{ label: 'Download', type: 'button', fixedWidth: 140, typeAttributes: {
			label: 'Download', name: 'Download', variant: 'brand', iconName: 'action:download', iconPosition: 'right' }},
		{ label: 'Fields List', fieldName: 'LogFileFieldNames', type: 'text'}
	];

	intervals = [
		{ label: 'Daily', value: 'Daily' },
		{ label: 'Hourly', value: 'Hourly' }
	];
	
	connectedCallback(){
		this.disableDate = true;
		checkAccessPermission()
			.then(result => {
				console.log('checkAccessPermission ->', result);
				if(!result) throw new Exception("You don't have permission to use this menu");

				return getDateRanges();
			})
			.then(result => {
				console.log('getDateRanges ->', result);
				this.dateRanges = result;
				this.logDate = result[0].value;

				return getEventTypes();
			})
			.then(result => {
				console.log('getEventTypes ->', result);
				this.eventTypes = result;

				return getEventLogs({ eventType : this.eventType, interval : this.interval, logDate : this.logDate });
			})
			.then(result => {
				console.log('getEventLogs ->', result);
				this.eventLogs = result;

			})
			.catch(errors => {
				this.errorHandler(errors);
			});
	}

	changeEventType(event){
		event.preventDefault();
		this.eventType = event.target.value;

		this.getEventLogs();
	}

	changeInterval(event){
		event.preventDefault();
		this.interval = event.target.value;
		this.disableDate = this.interval == 'Hourly' ? false : true;
		this.logDate = this.dateRanges[0].value;
		this.getEventLogs();
	}

	changeDate(event){
		event.preventDefault();
		this.logDate = event.target.value;
		this.getEventLogs();
	}

	getEventLogs(){
		// Prevents the anchor element from navigating to a URL.
		this.spinnerToggle();
		getEventLogs({ eventType : this.eventType, interval : this.interval, logDate : this.logDate })
			.then(result => {
				console.log('getEventLogs ->', result);
				this.eventLogs = result;
				this.spinnerToggle();
			})
			.catch(errors => {
				this.errorHandler(errors);
				this.spinnerToggle();
			});
	}

	handleRowAction(event) {
		const action = event.detail.action;
		const row = event.detail.row;
		var self = this,
			filesize = row.LogFileLength,
			mydomain = window.location.href.split(".")[0];

		if(filesize <= 524288000){
			this.downloadFile(row.ApiVersion, filesize, row.Id);
		} else {
			getSessionId()
				.then(result => {
					this.showMyToast("info", "Infomation", "Can not download file larger than 500MB, use shell script!");
					var url = " \"" + mydomain + ".my.salesforce.com/services/data/v" + row.ApiVersion + ".0/sobjects/EventLogFile/" + row.Id + "/LogFile\" ";
					var authCode = " -H \"Authorization: Bearer " + result + "\" ";
					var logDate = row.LogDate.substring(0, 10);
					var filename = logDate + "-" + row.EventType;
					var scr = "#!/usr/bin/env sh\n";
					scr += "# A script that downloads an event log file\n";
					scr += "# Requires cURL http://curl.haxx.se/\n\n";
					scr += "# Event Type: " + row.EventType + "\n";
					scr += "# Log Date: " + logDate + "\n";
					scr += "# File Size (in Bytes): " + row.LogFileLength + "\n\n";
					scr += "curl --compressed " + url + authCode + " -o \"" + filename + ".csv\"\n";
					self.saveAs(scr, filename +".sh");
				});
		}
	}

	clickCancelDownload(event){
		this.isCancel = true;
		this.progressOpen = false;
	}

	downloadFile(ver, filesize, recId){
		var self = this;
		var count = 1;

		getSessionId()
			.then(result => {
				console.log('getSessionId -> ', result);
				this.progress = 0;
				this.progressOpen = true;

				var req = new XMLHttpRequest(),
					url = '/services/data/v' + ver + '.0/sobjects/EventLogFile/' + recId + '/LogFile';
				req.open('GET', url, true);
				//req.responseType = "blob";
				req.setRequestHeader('Authorization','Bearer ' + result);
				req.setRequestHeader('Content-Type', 'text/csv');
				req.onprogress = function(ev){
					self.progress = (ev.loaded / filesize) * 100;
				};
				req.onreadystatechange = function(){
					if(self.isCancel){
						console.log('cancel download');
						self.isCancel = false;
						req.abort();
					}
					if(req.readyState === 4){ // XMLHttpRequest.DONE
						var status = req.status;
						if(status === 0 || (status >= 200 && status < 400)){
							console.log('downloaded', req.response.length);
							//console.log('downloaded -> ', req.responseText);
							self.progress = 100;
							self.progressOpen = false;
							self.saveAs(req.response, "sample.csv");
						} else throw new Exception('Download Error!!');
					}
				};
				req.send();
				
			})
			.catch(errors => {
				self.errorHandler(errors);
			});

	}

	saveAs(body, filename){
		// var reader = new FileReader();
		// reader.onloadend = function(){
		// 	var url = reader.result;
		// 	url = url.replace(/^data:[^;]*;/, 'data:attachment/file;');

		// 	var pom = document.createElement('a');
		// 	pom.setAttribute('href', url);
		// 	pom.setAttribute('download', filename);
		// 	if (document.createEvent) {
		// 		var event = document.createEvent('MouseEvents');
		// 		event.initEvent('click', true, true);
		// 		pom.dispatchEvent(event);
		// 	} else {
		// 		pom.click();
		// 	}
		// };

		// //var blob = new Blob([body], {type:'text/csv'});
		// //reader.readAsDataURL(blob);
		// reader.readAsDataURL(body);

		var pom = document.createElement('a');
		pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(body));
		pom.setAttribute('download', filename);
	
		if (document.createEvent) {
			var event = document.createEvent('MouseEvents');
			event.initEvent('click', true, true);
			pom.dispatchEvent(event);
		} else {
			pom.click();
		}
	}

	// Spinner toggle
	spinnerToggle(){
		this.template.querySelector('[data-result-spinner]').classList.toggle("slds-hide");
	}

	errorHandler(errors){
		if(Array.isArray(errors)){
			errors.forEach(error => {
				this.showMyToast('error', 'Error', error.message, 'sticky');
			})
		} else {
			console.log(errors);
			this.showMyToast('error', 'Error', 'Unknown error in javascript controller/helper.', 'sticky');
		}
	}

	showMyToast(variant, title, msg, mode){
		let dismissible = mode != undefined ? mode : 'dismissible';
		const event = new ShowToastEvent({
			"variant" : variant,
			"title" : title,
			"message" : msg,
			"mode" : dismissible
		});
		this.dispatchEvent(event);
	}
}