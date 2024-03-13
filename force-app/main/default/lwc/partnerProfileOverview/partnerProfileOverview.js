/**
 * @description       : 
 * @author            : ukhyeon.lee@samsung.com
 * @group             : 
 * @last modified on  : 08-30-2022
 * @last modified by  : ukhyeon.lee@samsung.com
**/
import { LightningElement, wire, track, api } from 'lwc';
import USER_ID from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import getUserAccount from '@salesforce/apex/PartnerProfileOverviewController.getUserAccountInformation';
import partnerProfileOverview from '@salesforce/apex/PartnerProfileOverviewController.partnerProfileOverview';

export default class PartnerProfileOverview extends NavigationMixin(LightningElement) {
    //adminAccountList
    isAdmin;
    adminAccountList=[];
    //Account
    accName;
    accPartnerType;
    accPhone;
    accWebsite;
    accCorporateNumber;
    accBillingStreet;
    //Partnership Info    
    piContractStartDate;
    piContractEndDate;
    piPartnerGrade;
    piSdsPdm;
    piSdsSa;
    piPartnerManager;
    piPartnerManagerEmail;   
    //User List
    userList = [];
    //Contact List(Contact)    
    prrList = [];
    mapData = [];

    isTOTAL;
    TOTAL;    
    
    //Partner Benefit
    partnerDiscount;
    paidMarketingFund;
    paidMigrationFund;
    paidFund;
    incentive;
    

    @track currentUser;
    cursorDefault = false;
    //var
    userId = USER_ID;
    accountId;

    @wire(getUserAccount, { recId: '$userId' })
    currentUserAccount({data, error}) {
        if(data) {
            this.accountId = data.Id;
        }
        if(error) {
            console.error(error);
        }
    }
    @wire(partnerProfileOverview, { recId: '$accountId' })
    partnerProfileOverviewHandler(result) {
        const { data, error } = result;
        if(data) {
            this.reset();
            for (let key in data) {
                if(key=='adminAccountList'){
                    this.isAdmin = true;
                    for(let key2 in data[key]){
                        this.adminAccountList.push({'value' : data[key][key2].Id, 'label': data[key][key2].Name});
                    }
                } else if(key=='account'){
                    this.accName = data[key].Name;
                    this.accPartnerType = data[key].Partner_Type__c;
                    this.accPhone = data[key].Phone;
                    this.accWebsite = data[key].Website
                    this.accCorporateNumber = data[key].CorporateNumber__c;   
                    this.accBillingStreet = data[key].BillingStreet;                 
                } else if(key=='partnershipInfo'){
                    this.piContractEndDate = data[key].Contract_End_Date__c;
                    this.piContractStartDate = data[key].Contract_Start_Date__c;
                    this.piPartnerGrade = data[key].Partner_Grade__c;
                    this.piSdsPdm = data[key].SDS_PDM__r?.Name;
                    this.piSdsSa = data[key].SDS_SA__r?.Name;
                    this.piPartnerManager = data[key].Partner_Manager__r?.Name;
                    this.piPartnerManagerEmail = data[key].Partner_Manager__r?.Email;
                } else if(key=='userList'){                    
                    let i = 1;
                    for(let key2 in data[key]){
                        this.mapData.push({ key: i, Id : data[key][key2].Id, Name: data[key][key2].Name, Title: data[key][key2].Contact.Title, MSPRole : data[key][key2].Contact.MSP_Role__c, Email : data[key][key2].Email, Phone : data[key][key2].Phone, CreatedDate : new Date(data[key][key2].CreatedDate).toISOString().slice(0,10)});
                        i++;
                    }
                    this.userList = this.mapData;                
                } else if(key=='prrAddList'){
                    let i = 1;
                    for(let key2 in data[key]){
                        //Convert Boolean to String
                        let ach = '미달성';                        
                        if(data[key][key2].Achievability__c){
                            ach = '달성';
                        }
                        
                        //Check rowspan row
                        let isRowspan = false;
                        if(data[key][key2].rowspan__c!=null){
                            isRowspan = true;
                            console.log("rowspan go")
                        }

                        //Check level 3 node
                        let isLeaf = false;
                        if(data[key][key2].Detail2__c != null){
                            isLeaf = true;
                        }

                        this.prrList.push({ key: i, RowspanTF : isRowspan, rowspan : data[key][key2].rowspan__c, leafTF : isLeaf, Id : data[key][key2].Id, Category: data[key][key2].Category__c, Detail1: data[key][key2].Detail1__c, Detail2 : data[key][key2].Detail2__c, Goal : data[key][key2].Goal__c, Performance : data[key][key2].Performance__c, Achievability : ach});
                        i++;
                        
                    }
                } else if(key=='TOTAL'){
                    this.isTOTAL=false;
                    this.TOTAL = '미달성';
                    if(data[key]){
                        this.isTOTAL=true;
                        this.TOTAL = '달성';
                    };
                } else if(key=='totalAmount'){
                    this.totalAmount = data[key].toLocaleString('en');
                } else if(key=='projectName'){
                    this.projectName = data[key];
                } else if(key=='partnerDiscount'){
                    this.partnerDiscount = data[key].toLocaleString('en');                
                } else if(key=='paidMarketingFund'){
                    this.paidMarketingFund = data[key].toLocaleString('en');
                } else if(key=='paidMigrationFund'){
                    this.paidMigrationFund = data[key].toLocaleString('en');
                } else if(key=='incentive'){
                    this.incentive = data[key].toLocaleString('en');
                } else if(key=='paidFund'){
                    this.paidFund = data[key].toLocaleString('en');
                }



            }
        }
        if(error) {
            console.error(error);
        }
    }
    
    adminAccountHandleChange(event) {
        this.accountId = event.detail.value;
    }

    reset(){
        this.isAdmin = null;
        this.adminAccountList=[];
        this.accName = null;
        this.accPartnerType = null;
        this.accPhone = null;
        this.accWebsite = null;
        this.accCorporateNumber = null;
        this.accBillingStreet = null;
        this.piContractStartDate  = null;
        this.piContractEndDate = null;
        this.piPartnerGrade = null;
        this.piSdsPdm = null;
        this.piSdsSa = null;
        this.piPartnerManager = null;
        this.piPartnerManagerEmail = null;   
        this.userList = [];
        this.prrList = [];
        this.mapData = [];
        this.isTOTAL = null;
        this.TOTAL= null;
        this.partnerDiscount = null;
        this.paidMarketingFund = null;
        this.paidMigrationFund = null;
        this.paidFund = null;
        this.incentive = null;
    }

}