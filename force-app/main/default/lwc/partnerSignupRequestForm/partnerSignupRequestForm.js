/**
 * @description       : 
 * @author            : zenith21c@test.com
 * @group             : 
 * @last modified on  : 03-14-2022
 * @last modified by  : zenith21c@test.com
**/
import { LightningElement, wire, track } from "lwc";
import { createRecord } from "lightning/uiRecordApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isDuplicate from "@salesforce/apex/PartnerSignupRequestFormController.isDuplicate";
import createPsrRec from "@salesforce/apex/PartnerSignupRequestFormController.createPsrRec";
import createRelatedTnCRec from "@salesforce/apex/PartnerSignupRequestFormController.createRelatedTnCRec";
import getData from "@salesforce/apex/PartnerSignupRequestFormController.getData";

//custom labels for translation purpose
import partner_signup_request_header from "@salesforce/label/c.partner_signup_request_header";
import partner_signup_request_title from "@salesforce/label/c.partner_signup_request_title";
import partner_signup_request_formbody from "@salesforce/label/c.partner_signup_request_formbody";
import partner_signup_request_tc from "@salesforce/label/c.partner_signup_request_tc";
import partner_signup_request_messages from "@salesforce/label/c.partner_signup_request_messages";
import partner_signup_request_text from "@salesforce/label/c.partner_signup_request_text";


import { NavigationMixin } from 'lightning/navigation';

//custom labels end.
export default class PartnerSignupRequestForm extends NavigationMixin(LightningElement) {
	dupCheck = false;
	showForm = true;
	//value = ["option1"];
	autoUpdateEmail = false;
	viewTnC = false;
	tncContent;
	psrId;
	submitData = true;
	ContinueFlow = true;
	companyName;
	firstName;
	lastname;
	mobilePhone;
	userEmailValue;

	//headin values from label
	mainHeading = partner_signup_request_header.split(",")[0];

	//title
	userInformation = partner_signup_request_title.split(",")[0];
	tnCSection = partner_signup_request_title.split(",")[1];
	signupText = partner_signup_request_text;

	//form info section fields
	cName = partner_signup_request_formbody.split(",")[0];
	fName = partner_signup_request_formbody.split(",")[1];
	lName = partner_signup_request_formbody.split(",")[2];
	mobile = partner_signup_request_formbody.split(",")[3];
	userEmail = partner_signup_request_formbody.split(",")[4];
	availabilityButton = partner_signup_request_formbody.split(",")[5];

	//tnC section fields
	agreeAll = partner_signup_request_tc.split(",")[0];
	personalUse = partner_signup_request_tc.split(",")[1];
	crossTransfer = partner_signup_request_tc.split(",")[2];
	termsOfServ = partner_signup_request_tc.split(",")[3];
	viewDetail = partner_signup_request_tc.split(",")[4];
	regButton = partner_signup_request_tc.split(",")[5];
	fourteenYearsLabel = partner_signup_request_tc.split(",")[6];

	//toas message
	toast1 = partner_signup_request_messages.split(",")[0];
	toast2 = partner_signup_request_messages.split(",")[1];
	toast3 = partner_signup_request_messages.split(",")[2];
	toast4 = partner_signup_request_messages.split(",")[3];
	toast5 = partner_signup_request_messages.split(",")[4];
	toast6 = partner_signup_request_messages.split(",")[5];
	toast7 = partner_signup_request_messages.split(",")[6];
	toast8 = partner_signup_request_messages.split(",")[7];
	toast9 = partner_signup_request_messages.split(",")[8];
	toast10 = partner_signup_request_messages.split(",")[9];
	toast11 = partner_signup_request_messages.split(",")[10];
	toast12 = partner_signup_request_messages.split(",")[11];
	toast13 = partner_signup_request_messages.split(",")[12];



	sfdcBaseURL = window.location.origin;

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
		console.log("value capture-->" + event.target.label);
		let fieldValue = event.target.value;
		if (
			event.target.name === "CompanyName" &&
			fieldValue !== "" &&
			fieldValue !== undefined
		) {
			this.companyName = fieldValue;

			console.log("vallll" + this.companyName);
		}
		else if (
			event.target.name === "FirstName" &&
			fieldValue !== "" &&
			fieldValue !== undefined
		)
			this.firstName = event.target.value;
		else if (
			event.target.name === "LastName" &&
			fieldValue !== "" &&
			fieldValue !== undefined
		)
			this.lastname = event.target.value;
	}

	firstNameChangedHandler(event) {

		var re = /^([^0-9]*)$/;
		if (re.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			this.firstName = event.target.value;

		} else {
			this.firstName = "";
			event.target.setCustomValidity(this.toast12);
			event.target.reportValidity();
			this.submitData = false;
		}


	}

	lastNameChangedHandler(event) {

		var re = /^([^0-9]*)$/;
		if (re.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();


			this.lastname = event.target.value;

		} else {
			this.lastname = "";
			event.target.setCustomValidity(this.toast12);
			event.target.reportValidity();
			this.submitData = false;
		}


	}


	closeRegForm() {
		//this.showForm = false;
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
				pageName: 'home'
			},
		});
	}
	//capture UI end.


	//RECORD INSERT
	createPsrRec() {
		this.ContinueFlow = true;
		this.submitData = false;
		this.validateFields();
		if (!this.submitData)
			return;
		this.validateDupAndTerms();
		// console.log('validation return:' + this.validateFields());
		if (this.submitData) {
			console.log('typefieldis-->' + this.typeValue);
			createPsrRec({

				emailEntered: this.emailEntered,
				phone: this.mobilePhone,
				fname: this.firstName,
				lname: this.lastname,
				cName: this.companyName
			})
				.then((result) => {
					console.log("success---->" + JSON.stringify(result));

					this.dispatchEvent(

						new ShowToastEvent({
							title: "Success",
							message: this.toast1,
							variant: "success",
							mode: "sticky"
						})
					);

					this.psrId = JSON.stringify(result);

					//Partner Signup T&C Agreement
					this.createRealted();
				})
				.catch((error) => {
					console.log('inside psr rec creation error');
					this.dispatchEvent(
						new ShowToastEvent({
							title: "Error creating record",
							message: error.body.message, //error.body.output.fieldErrors,
							variant: "error"
						})
					);
				});


		}
	}


	createRealted() {
		createRelatedTnCRec({
			psrecId: this.psrId,
			tnCList: this.wiredData.recId,
		})
			.then((result) => {
				console.log("success---->" + JSON.stringify(result));
				this.closeRegForm();
			})
			.catch((error) => {
				console.log('inside first rec creation error');

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error creating record",
						message: error.body.message, //error.body.output.fieldErrors,
						variant: "error"
					})
				);
			});

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
			this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast11);
			this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
			this.emailEntered = "";
			this.submitData = false;
		}
	}


	phoneChangedHandler(event) {
		console.log("entered--->" + event.target.value);

		var checkPhoneNumber = /^\d{3}-\d{3,4}-\d{4}$/;

		if (checkPhoneNumber.test(event.target.value)) {
			event.target.setCustomValidity('');
			event.target.reportValidity();
			this.mobilePhone = event.target.value;
		} else {
			this.mobilePhone = "";
			event.target.setCustomValidity(this.toast8);
			event.target.reportValidity();
			this.submitData = false;
		}
	}


	validateUserMail() {
		this.validateUniqueUserid(this.emailEntered);
	}


	//InputUserId = emailEntered
	//emailEntered + '.sdspartner' = user id
	validateUniqueUserid(InputUserId) {
		console.log(
			"inside apex call-->" + InputUserId
		);
		if (InputUserId !== undefined && InputUserId !== '') {
			isDuplicate({
				emailEnteredVal: InputUserId
			})
				.then((result) => {
					console.log("success---->" + result);

					if (result == 'NA') {
						console.log("inside unique block");
						this.dupCheck = true;
						this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity('');
						this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
						this.dispatchEvent(
							new ShowToastEvent({
								title: "Success",
								message: this.toast2,
								variant: "success"
							})
						);

					}
					else if (result == 'Exist') {
						console.log("inisde duplicate block");
						this.dupCheck = false;
						this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast3);
						this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
						this.dispatchEvent(
							new ShowToastEvent({
								title: "Error",
								message: this.toast3,
								variant: "error"
							})
						);
					}
					else if (result == 'Request') {
						console.log("inisde request block");
						this.dupCheck = false;
						this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast4);
						this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();
						this.dispatchEvent(
							new ShowToastEvent({
								title: "Error",
								message: this.toast4,
								variant: "error"
							})
						);
					}
					else {
						console.log("inisde error block");
						this.dupCheck = false;
						this.dispatchEvent(
							new ShowToastEvent({
								title: "Error",
								message: this.toast5,
								variant: "error"
							})
						);
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
					message: this.toast6,
					variant: "error"
				})
			);
		}
	}


	validateEmail(email) {
		var re = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*.[a-zA-Z]{2,3}$/i;
		return re.test(email);
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
	}


	closetncAgreementModal() {
		this.viewTnC = false;
		this.showForm = true;
	}


	validateFields() {
		this.template.querySelectorAll("lightning-input").forEach((element) => {
			console.log('element-->' + element.label);
			if (!element.checkValidity()) {
				element.reportValidity();
				this.submitData = false;
				this.ContinueFlow = false;
				console.log("inside false");

				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: this.toast9,
						variant: "error",
						mode: 'dismissable'
					})
				);
				return;
			}
			else{
				if (this.ContinueFlow == true) {
					this.submitData = true;
				}
			}
		});
		
	}


	validateDupAndTerms() {

		let quit = false;

		if (!this.dupCheck) {
			this.submitData = false;

			this.template.querySelector("lightning-input[data-my-id=email]").setCustomValidity(this.toast10);
			this.template.querySelector("lightning-input[data-my-id=email]").reportValidity();

			this.dispatchEvent(
				new ShowToastEvent({
					title: "Error",
					message: this.toast10,
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
				this.submitData = false;
				this.dispatchEvent(
					new ShowToastEvent({
						title: "Error",
						message: this.toast13,
						variant: "error",
						mode: "dismissable"

					})
				);
				return;
			}
		}

		this.submitData = true;
	}


}