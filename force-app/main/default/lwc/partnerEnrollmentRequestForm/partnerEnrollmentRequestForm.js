/*
  @description       : 
  @author            : rakshit.s@samsung.com.sds.mspdev
  @group             : 
  @last modified on  : 06-10-2022
  @last modified by  : rakshit.s@samsung.com
*/
import { LightningElement, wire, track, api } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isDuplicate from "@salesforce/apex/PartnerEnrollmentRequestFormController.isDuplicate";
import createPerRec from "@salesforce/apex/PartnerEnrollmentRequestFormController.createPerRec";
import createRelatedTnCRec from "@salesforce/apex/PartnerEnrollmentRequestFormController.createRelatedTnCRec";
import getData from "@salesforce/apex/PartnerEnrollmentRequestFormController.getData";
import getFormData from '@salesforce/apex/CustomPathController.getFormData';

//custom labels for translation purpose
import partner_enrollment_heading_label from "@salesforce/label/c.partner_enrollment_heading_label";
import partner_enrollment_company_info_fields from "@salesforce/label/c.partner_enrollment_company_info_fields";
import partner_enrollment_description_label from "@salesforce/label/c.partner_enrollment_description_label";
import partner_enrollment_primary_con_fields from "@salesforce/label/c.partner_enrollment_primary_con_fields";
import partner_enrollment_tnc_label from "@salesforce/label/c.partner_enrollment_tnc_label";
import partner_enrollment_partner_type_label from "@salesforce/label/c.partner_enrollment_partner_type_label";
import partner_enrollment_status_fields_label from "@salesforce/label/c.partner_enrollment_status_fields_label";
import partner_enrollment_request_messages from "@salesforce/label/c.partner_enrollment_request_messages";

//custom labels end.
export default class PartnerEnrollmentRequestForm extends NavigationMixin(LightningElement) {

	AllowSubmit = false;
	isUserUnique = true;
	showForm = true;
	//value = ["option1"];
	autoUpdateEmail = false;
	emailValue;
	userIdValue;
	viewTnC = false;
	tncContent;
	perId;
	perTCId;
	tnCrecId;
	createRelatedRec = false;
	showInfoScreen = false;
	disableSave = false;
	perDuplicate = false;
	userDuplicate = false
	ContinueFlow = true;
	@api isComingFromStatusCheckComponent = false;
	@api reqNo;
	@api companyName;
	@api companyPhone;
	@api companyFax;
	@api companyWebsite;
	@api firstName;
	@api lastname;
	@api mobilePhone;
	@api currentStatus; 
	@api reviewerName;
	@api usrEmail;
	userIdValue;
	@api typeValue;
	@api myRecordId;
	subj;
	@api subject;
	@api emailEntered;
	@api description;
	@api readOnlyMode = false;
	wiredData;
	tnCheading;
	messageVal;
	@ api enrollmentNumber;
	dupCheck = false;
	descCount;	//2022-04-25 added Description count
	@api fromEditContext = false;
	viewStatusForm = false;
	  filledData = [];
	//headin values from label
	mainHeading = partner_enrollment_heading_label.split(",")[0];
	companyInfo = partner_enrollment_heading_label.split(",")[1];
	primaryContactInfo = partner_enrollment_heading_label.split(",")[2];
	enrollmentSection = partner_enrollment_heading_label.split(",")[3];
	tnCSection = partner_enrollment_heading_label.split(",")[4];
	statusSection = partner_enrollment_heading_label.split(",")[5];

	//heading values from labels

	//toast messages labels
	partner_enrollment_request_messages

	toast1 = partner_enrollment_request_messages.split(",")[0];
	toast2 = partner_enrollment_request_messages.split(",")[1];
	toast3 = partner_enrollment_request_messages.split(",")[2];
	toast4 = partner_enrollment_request_messages.split(",")[3];
	toast5 = partner_enrollment_request_messages.split(",")[4];
	toast6 = partner_enrollment_request_messages.split(",")[5];
	toast7 = partner_enrollment_request_messages.split(",")[6];
	toast8 = partner_enrollment_request_messages.split(",")[7];
	toast9 = partner_enrollment_request_messages.split(",")[8];
	toast10 = partner_enrollment_request_messages.split(",")[9];
	toast11 = partner_enrollment_request_messages.split(",")[10];
	toast12 = partner_enrollment_request_messages.split(",")[11];
	toast13 = partner_enrollment_request_messages.split(",")[12];
	toast14 = partner_enrollment_request_messages.split(",")[13];
	//toast messages labels

	//company info section fields
	cName = partner_enrollment_company_info_fields.split(",")[0];
	cPhone = partner_enrollment_company_info_fields.split(",")[1];
	cFax = partner_enrollment_company_info_fields.split(",")[2];
	cWebsite = partner_enrollment_company_info_fields.split(",")[3];

	//compan info section fields

	//primary contact section fields
	fName = partner_enrollment_primary_con_fields.split(",")[0];
	lName = partner_enrollment_primary_con_fields.split(",")[1];
	mobile = partner_enrollment_primary_con_fields.split(",")[2];
	userEmail = partner_enrollment_primary_con_fields.split(",")[3];
	sameCheckbox = partner_enrollment_primary_con_fields.split(",")[4];
	uId = partner_enrollment_primary_con_fields.split(",")[5];
	availabilityButton = partner_enrollment_primary_con_fields.split(",")[6];
	editButton = partner_enrollment_primary_con_fields.split(",")[7];
	//primary contact section fields

	emailLabel = partner_enrollment_status_fields_label.split(",")[0];
	enrollmentReqLabel = partner_enrollment_status_fields_label.split(",")[1];
	//enrollment section
	prtnerType = partner_enrollment_description_label.split(",")[0];
	subj = partner_enrollment_description_label.split(",")[1];
	desc = partner_enrollment_description_label.split(",")[2];
	reqNoLabel = partner_enrollment_description_label.split(",")[3];
	stageLabel = partner_enrollment_description_label.split(",")[4];
	reviewerLabel = partner_enrollment_description_label.split(",")[5];

	//enrollment section

	//tnC section fields
	agreeAll = partner_enrollment_tnc_label.split(",")[0];
	personalUse = partner_enrollment_tnc_label.split(",")[1];
	crossTransfer = partner_enrollment_tnc_label.split(",")[2];
	termsOfServ = partner_enrollment_tnc_label.split(",")[3];
	viewDetail = partner_enrollment_tnc_label.split(",")[4];
	regButton = partner_enrollment_tnc_label.split(",")[5];
	fourteenYearsLabel = partner_enrollment_tnc_label.split(",")[6];
	//tnC section fields

	@track error;
	@track email;



	@wire(getData)
	wiredContacts({
		error,
		data
	}) {
		if (data) {
			this.wiredData = data;
			console.log("success-->" + this.wiredData.recId[0]);
		} else if (error) {
			this.error = error;
			console.log("error-->" + JSON.stringify(error));
			// this.contacts = undefined;
		}
	}


	//capture UI Values
	captureUIValues(event) {
		console.log("value capture-->" + event.target.label + 'from label' + this.mobile);
		let fieldValue = event.target.value;
		if (
			event.target.label === this.cName
		) {
			this.companyName = fieldValue;

			console.log("vallll" + this.companyName);
		} else if (
			event.target.label === this.cPhone
		) {
			if (this.companyPhoneOrFaxChangedHandler(event)) {
				this.companyPhone = event.target.value;
			}
			else {
				//this.companyPhone = '';
			}
		}
		else if (
			event.target.label === this.cFax
		) {
			if (this.companyPhoneOrFaxChangedHandler(event)) {
				console.log('inside if of fax');
				this.companyFax = event.target.value;
			}
			else {
				console.log('inside else of fax');
				//this.companyFax = '';
			}
		}
		else if (
			event.target.label === this.cWebsite
		)
			this.companyWebsite = event.target.value;
		else if (
			event.target.label === this.fName
		)
			this.firstName = event.target.value;
		else if (
			event.target.label === this.lName
		)
			this.lastname = event.target.value;
		else if (
			event.target.label === this.mobile
		) {
			console.log('assigning value to mobilePhone beofre' + this.mobilePhone + 'eventval->' + event.target.value);
			if (this.phoneChangedHandler(event)) {
				this.mobilePhone = event.target.value;
				console.log('assigning value to mobilePhone after' + this.mobilePhone + 'eventval->' + event.target.value);
			}
			else {
				//this.mobilePhone = '';
			}
		}

		else if (
			event.target.label === this.userEmail
		)
			this.usrEmail = event.target.value;
		else if (
			event.target.label === this.uId &&
			fieldValue !== "" &&
			fieldValue !== undefined
		)
			this.userIdValue = event.target.value;
		/*else if (
			event.target.label === "Partner Type" &&
			fieldValue !== "" &&
			fieldValue !== undefined
		)
			this.typeValue = event.target.value;*/
		else if (
			event.target.label === this.subj
		)
			this.subject = event.target.value;
		else if (
			event.target.label === this.desc
		)
		{	this.description = event.target.value;
			
			//2022-04-25 added Description count
			if(event.target.value.length>0){
				this.descCount =event.target.value.length+'/32000'
			} else if(event.target.value.length===0){
				this.descCount = null;
			} else{	//To-do
				if(event.target.value.length < 32000){
					this.descCount =event.target.value.length+'/32000'
				}
				
			}
			}
	}

	closeRegForm() {
		this.showForm = false;
	}
	//capture UI end.

	partnerTypeAction(event) {
		console.log('typeVal-->' + event.target.value);
		this.typeValue = event.target.value;
	}

	//RECORD INSERT END
	emailChangedHandler(event) {
		console.log("entered--->" + event.target.value);
		this.dupCheck = false;
		if (this.validateEmail(event.target.value)) {
			this.emailEntered = event.target.value;
			this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity('');
			this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
		} else {
			this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast10);
			this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
			//this.emailEntered = "";
		}
	}



	get options() {
		this.messageVal = this.toast7;
		const pickVal = [];

		pickVal.push({
			label: partner_enrollment_partner_type_label.split(",")[0],
			value: 'Value Added Reseller',
		})
		pickVal.push({
			label: partner_enrollment_partner_type_label.split(",")[1],
			value: partner_enrollment_partner_type_label.split(",")[1],
		})
		return pickVal;
	}

	autoPopulateEmailField(event) {
		console.log("is checked" + event.target.value);
		if (event.target.checked) {
			console.log("inside true->" + this.emailEntered);

			if (this.validateEmail(this.emailEntered)) {
				console.log("inside email validity");
				this.template.querySelector(
					'[data-id="userIdField"]'
				).value = this.emailEntered;
				this.userIdValue = this.emailEntered;
				this.autoUpdateEmail = true;
			}
		} else {
			this.autoUpdateEmail = false;
			this.template.querySelector('[data-id="userIdField"]').value = "";
			this.userIdValue = "";
		}
	}

	UserIdInputChnage(event) {
		console.log("email val->" + event.target.value);
		this.userIdValue = event.target.value;
	}

	validateuserId(event, isComingFromcheckButton) {

		console.log('label of button-->' + typeof event);
		var uniqueId = this.emailEntered + '.sdspartner';
		this.partnerId = uniqueId;

		if (this.emailEntered !== undefined && this.emailEntered !== '' ) {
			isDuplicate({
				UserID: uniqueId,
				emailEnteredVal: this.emailEntered,
				isEditContext : this.fromEditContext
			})
				.then((result) => {
					console.log("successduplicacy---->" + result.duplicateEntity + 'if condition-->' + result.userAlreadyPresent);

					if (!result.userAlreadyPresent) {

						this.dupCheck = true;
						if(!this.fromEditContext){
								this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity('');
						this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
						}
						
						console.log("inside unique block");
						if (!isComingFromcheckButton) {
							this.dispatchEvent(
								new ShowToastEvent({
									title: "Success",
									message: this.toast1,
									variant: "success",
									mode: "sticky"
								})
							);
						}

						this.disableSave = false;

						if (typeof event == 'undefined') {
							this.recCreationFunc();
						}

						//return true;

					} else {

						
						this.dupCheck = false;
						console.log("inisde duplicate block");

						this.isUserUnique = false;

						if (result.duplicateEntity == 'PER') {
							this.perDuplicate = true;

							this.disableSave = true;

							this.dispatchEvent(
								new ShowToastEvent({
									title: "Error",
									message: this.toast2,
									variant: "error",
									mode: "sticky"
								})
							);
						}

						else if (result.duplicateEntity == 'USER') {
							this.userDuplicate = true;

							this.disableSave = true;

							this.dispatchEvent(
								new ShowToastEvent({
									title: "Error",
									message: this.toast3,
									variant: "error",
									mode: "sticky"
								})
							);
						}

						return false;
						
					}
				})
				.catch((error) => {
					this.error = error;
				});

		}

		else {
			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: this.toast4,
					variant: "error",
					mode: "sticky"
				})
			);
		}

	}



	validateEmail(email) {
		var re = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
		return re.test(email);
	}

	//Navigate to home page
	navigateToHomePage() {
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
				pageName: 'home'
			},
		});
	}

	urlChangeHandler(event) {

		//var re = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/;
		var re = /[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/;
		if (!event.target.value || re.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			this.companyWebsite = event.target.value;
		} else {
			//this.companyWebsite = "";
			event.target.setCustomValidity(this.toast8);
			event.target.reportValidity();
		}
	}

	firstNameChangedHandler(event) {

		var re = /^([^0-9]*)$/;
		if (re.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			this.firstName = event.target.value;

		} else {
			//this.firstName = "";
			event.target.setCustomValidity(this.toast9);
			event.target.reportValidity();
		}


	}

	lastNameChangedHandler(event) {

		var re = /^([^0-9]*)$/;
		if (re.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();


			this.lastname = event.target.value;

		} else {
			//this.lastname = "";
			event.target.setCustomValidity(this.toast9);
			event.target.reportValidity();
		}


	}

	validateuRl(url) {
		var re = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-_]*)?\??(?:[\-\+=&;%@\.\w_]*)#?(?:[\.\!\/\\\w]*))?)/;
		if (re.test(url)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			this.mobilePhone = event.target.value;
		} else {
			this.mobilePhone = "";
			event.target.setCustomValidity(this.toast11);
			event.target.reportValidity();
		}

	}
	openForm() {
		console.log("button clicked");
		this.showForm = true;
	}



	agreeAllAction(event) {
		let i;
		let checkboxes = this.template.querySelectorAll('[data-id="check"]');

		for (i = 0; i < checkboxes.length; i++) {
			checkboxes[i].checked = event.target.checked;
		}
	}

	termAndConditionsViewAction(event) {
		console.log(
			"tnc-->" +
			event.currentTarget.dataset.id +
			"onload-->" +
			JSON.stringify(this.wiredData)
		);
		let linkClicked = event.target.value;

		this.viewTnC = true;
		//this.showForm = false;

		if (event.currentTarget.dataset.id == "personalInfo") {
			console.log("1st:" + this.wiredData.collectPersonalInfo);
			this.tncContent = this.wiredData.collectPersonalInfo;
			this.tnCheading = this.personalUse.split('(')[0];
		} else if (event.currentTarget.dataset.id == "crossInfo") {
			console.log("2nd:" + this.wiredData.crossBorderTransfer);
			this.tncContent = this.wiredData.crossBorderTransfer;
			this.tnCheading = this.crossTransfer.split('(')[0];
		} else if (event.currentTarget.dataset.id == "termOfService") {
			console.log("3rd:" + this.wiredData.termsOfService);
			this.tncContent = this.wiredData.termsOfService;
			this.tnCheading = this.termsOfServ.split('(')[0];
		}
		else if (event.currentTarget.dataset.id == "fourteenYearsOld") {
			console.log("4th:" + this.wiredData.fourteenYearsOld);
			this.tncContent = this.wiredData.fourteenYearsOld;
			this.tnCheading = this.fourteenYearsLabel.split('(')[0];
		}
		//this.tncContent = this.wiredData
	}

	//RECORD INSERT
	createPerRec() {
		
		this.ContinueFlow = true;
		this.validateFields();

		if (!this.AllowSubmit)
			return;

		 if(!this.fromEditContext) this.validateDupAndTerms();

		console.log('checkunique block' + this.AllowSubmit);
		if (this.AllowSubmit) {
			this.validateuserId(event, true);
		}



	}

	ediTSubmittedForm(){

		 getFormData({
				EmailInput: this.emailEntered,
            EnrollmentNumberInput: ''
			})
				.then((result) => {
                    result.EditContext = true;
                      this.filledData = result;
					  this.reqNo = result.Name;
					  this.currentStatus = result.Status__c;
					console.log('inside value assignation---->' + this.reviewerName);
					if(result.Status__c == '신청접수' && result.Reviewer__c === undefined){

					this.reviewerName = '미배정';
					}
					else{
							this.reviewerName = result.Reviewer__c;
					}
					  
                     this.editMode =true;
					 this.myRecordId = result.Id;
					//console.log('return-->' + JSON.stringify(result));

						this.showForm = true;
		this.showInfoScreen = false;
		this.fromEditContext = true;

				})
				.catch((error) => {
					this.error = error;
				});
	
		//this.viewStatusForm = true;

	}

	recCreationFunc() {

		createPerRec({
			partnerId: this.partnerId,
			pType: this.typeValue,
			sub: this.subject,
			emailEntered: this.emailEntered,
			phone: this.mobilePhone,
			description: this.description,
			fname: this.firstName,
			lname: this.lastname,
			website: this.companyWebsite,
			fax: this.companyFax,
			cName: this.companyName,
			cphone: this.companyPhone,
			isEditContext: this.fromEditContext

		})
			.then((result) => {
				console.log("success from first return---->" + JSON.stringify(result));

				this.myRecordId = result.insertedId;

				if(this.fromEditContext){
					this.toast5 = '수정사항이 성공적으로 저장되었습니다.';
				}
				this.dispatchEvent(

					new ShowToastEvent({
						title: "Success",
						message: this.toast5,
						variant: "success",
						mode: "sticky"
					})
				);

				this.perId = result.insertedId;

				//this.enrollmentNumber = result.insertedNumber;

				//setTimeout(this.createRealted(), 3000);

				if(!this.fromEditContext) {
					this.createRealted();
				}

				else{
					this.closeRegForm();
				this.showInfoScreen = true;
				}
			})
			.catch((error) => {
				console.log('inside per rec creation error');
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error creating record",
						message: error.body.message, //error.body.output.fieldErrors,
						variant: "error",
						mode: "sticky"
					})
				);
			});



		/*else{
			console.log('inside else block of insertion');
			this.disableSave = false;
			console.log('inside else block of insertion after' + this.disableSave);*/

	}

	createRealted() {
		console.log("inside related insert---->" + this.perId);
		createRelatedTnCRec({

			perecId: this.perId,
			tnCList: this.wiredData.recId,
		})
			.then((result) => {


				//this.navigateToHomePage();
				this.enrollmentNumber = result;
				this.closeRegForm();
				this.showInfoScreen = true;

			})
			.catch((error) => {
				console.log('inside first rec creation error');

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error creating record",
						message: error.body.message, //error.body.output.fieldErrors,
						variant: "error",
						mode: "sticky"
					})
				);
			});

	}



	closetncAgreementModal() {
		this.viewTnC = false;
		this.showForm = true;
	}

	formatDate() {
		console.log("formatDate");
		let d = new Date();
		let month = "" + (d.getMonth() + 1);
		let day = "" + d.getDate();
		let year = d.getFullYear();

		if (month.length < 2) month = "0" + month;
		if (day.length < 2) day = "0" + day;
		return [year, month, day].join("-");
	}

	validateFields() {

		let inputFields = this.template.querySelectorAll('.validate');
		let quit = false;
		inputFields.forEach((element) => {
			console.log('element-->' + element.label);

			if (!element.checkValidity()) {
				console.log("inside false of validation fields");
				element.reportValidity();
				this.AllowSubmit = false;
				this.ContinueFlow = false;

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: this.toast6,
						variant: "error",
						mode: "dismissable"

					})
				);
				
				return;
			}
			else {
				console.log('inside else of validation');
				if (this.ContinueFlow == true) {
					this.AllowSubmit = true;
				}
			}

		});

	}



	validateDupAndTerms() {

		let quit = false;

		if (!this.dupCheck  && !this.fromEditContext) {
			this.AllowSubmit = false;
			this.ContinueFlow = false;

			this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast13);
			this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();

			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: this.toast13,
					variant: "error",
					mode: "dismissable"

				})
			);

			quit = true;
			return;
		}

		if (quit)
			return;

		let i;
		let checkboxes = this.template.querySelectorAll('[data-id="check"]');

		for (i = 0; i < checkboxes.length; i++) {

			if (!checkboxes[i].checked) {
				this.AllowSubmit = false;
				this.ContinueFlow = false;
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: this.toast14,
						variant: "error",
						mode: "dismissable"

					})
				);
				return;
			}
		}

		this.ContinueFlow = true
		this.AllowSubmit = true;
	}

	companyPhoneOrFaxChangedHandler(event) {
		console.log("entered--->" + event.target.value);

		var checkPhoneNumber = /^\d{2,3}-\d{3,4}-\d{4}$/;

		if (!event.target.value || checkPhoneNumber.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			//this.mobilePhone = event.target.value;
			return true;
		} else {
			//this.mobilePhone = "";
			event.target.setCustomValidity(this.toast12);
			event.target.reportValidity();
			return false;
		}
	}

	phoneChangedHandler(event) {
		console.log("entered--->" + event.target.value);

		var checkPhoneNumber = /^\d{3}-\d{3,4}-\d{4}$/;

		if (checkPhoneNumber.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			//this.mobilePhone = event.target.value;

			return true;
		} else {
			//	this.mobilePhone = "";
			event.target.setCustomValidity(this.toast11);
			event.target.reportValidity();
			return false;
		}
	}

	getBaseUrl() {
		let baseUrl = 'https://' + location.host + '/';
		return baseUrl;
	}


	cancelAction(){

		console.log('inside cancel-->' );
		let baseUrl = this.getBaseUrl();
		let navUrl = baseUrl+'s/partner-enrollment-request-status';
		console.log('inside cancel-->' + baseUrl);
		if(this.isComingFromStatusCheckComponent == 'true'){

			console.log('inside if');
			this[NavigationMixin.GenerateUrl]({
    		type: "standard__webPage",
    			attributes: {
                    url: navUrl
                }	
				}).then(url => {
   				 window.open(url, "_self");
				});

			
			
		}

		else{
			console.log('inside else');
			this.showInfoScreen = true;
			this.showForm = false
			
		}


	}
}