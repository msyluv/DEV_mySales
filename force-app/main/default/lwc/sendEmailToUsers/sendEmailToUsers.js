import { LightningElement, track, wire } from 'lwc';
import getAllReports from '@salesforce/apex/ReportSearchController.getAllReports';
import getUsers from '@salesforce/apex/ReportSearchController.getUsers';
import sendEmail from '@salesforce/apex/ReportTableGenerator.generateHtmlTable';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class sendEmailToUsers extends LightningElement {
   picklistOrdered;
   searchResults;
   selectedSearchResult;
   showPopup = false;
   showUserSelection = false;
   showPicklist = false;
   timeOptions = [];
   selectedTime = '';
   showRecipients = false;
   selectedEntityOption = '';
   ShowSenderSelectionSearchBox = false;
   users = [];
   showSuggestions = false;
   searchTerm = '';
   selectedOption = '';
   isImmediate = false;


     entityArray = [
  {"label": "Users", "value": "Users"},
  {"label": "Roles", "value": "Roles"},
  {"label": "Roles and Subordinates", "value": "Roles and Subordinates"},
  {"label": "Public Groups", "value": "Public Groups"}
];

    currentVariantDaily = 'neutral';
    currentVariantWeekly = 'neutral';
    currentVariantMonthly = 'neutral';

    handleFrequencyButtonClick(event) {
        const buttonName = event.target.label;
        console.log('n111ame-->' + event.target.label);
        // Toggle the variant between 'neutral' and 'brand'
        if(buttonName == 'Daily'){
        this.currentVariantDaily = this.currentVariantDaily === 'neutral' ? 'brand' : 'neutral';
        this.currentVariantWeekly = 'neutral';
        this.currentVariantMonthly = 'neutral';
        }

        else if(buttonName == 'Weekly'){
        this.currentVariantDaily = 'neutral';
        this.currentVariantWeekly = this.currentVariantWeekly === 'neutral' ? 'brand' : 'neutral';
        this.currentVariantMonthly = 'neutral';
        }

        else if(buttonName == 'Monthly'){
        this.currentVariantDaily = 'neutral';
        this.currentVariantWeekly = 'neutral';
        this.currentVariantMonthly = this.currentVariantMonthly === 'neutral' ? 'brand' : 'neutral';
        }
        

    }


  get selectedValue() {
    return this.selectedSearchResult ? this.selectedSearchResult.label : null;
  }

  sendEmail(){
    console.log('inside immediate');
    this.isImmediate = true;
    this.showRecipients = true;
      /*console.log('toapex->' + JSON.stringify(this.selectedSearchResult));
        this.showToast('Success', 'Email is on its way!', 'success');
      sendEmail({repId : this.selectedSearchResult.value,
                      
                receivers : '',
                  isImmediate : true})
      .then(result => {
          console.log('success');
          
      })
      .catch(error => {
          this.error = error;
      })*/

  }

  connectedCallback() {
      this.generateTimeOptions();
      
    getAllReports().then((result) => {
        result = this.convertToArray(result);
        console.log('result-->' + JSON.stringify(result));
        this.showPicklist = true;
      this.picklistOrdered = result.map(({ value: label, key: value }) => ({ label, value }));
      this.picklistOrdered = this.picklistOrdered.sort((a, b) => {
        if (a.label < b.label) {
          return -1;
        } else if (a.label > b.label) {
          return 1;
        }
        return 0;
      });
      console.log('firstlist-->' + JSON.stringify(this.picklistOrdered));
    });

    //this.getUsersByName();
 
  }

     getUsersByName() {
        getUsers({ searchTerm: this.searchTerm })
            .then(result => {
                this.users = result;
                console.log('usersparent-->' + JSON.stringify(this.users));
                this.ShowSenderSelectionSearchBox = true;
            })
            .catch(error => {
                console.error('Error fetching users:', error);
            });
    }


  generateTimeOptions() {
        for (let hour = 0; hour <= 23; hour++) {
  const displayHour = hour % 12 === 0 ? 12 : hour % 12;
  const meridiem = hour < 12 ? 'AM' : 'PM';
  const timeLabel = `${meridiem} ${displayHour.toString().padStart(2, '0')}:00`;
  const timeValue = `${displayHour.toString().padStart(2, '0')} ${meridiem}`;
  this.timeOptions.push({ label: timeLabel, value: timeValue });
}

    }

    handleTimeChange(event) {
        console.log('selected-->' + event.detail.value);
        this.selectedTime = event.detail.value;
        this.cronExpression = this.generateCronExpression(this.selectedTime);
        console.log('cron-->' + this.generateCronExpression(this.selectedTime));
    }

     generateCronExpression(selectedTime) {
  // Convert the selected time to hours and minutes
  const [hourString, meridiem] = selectedTime.split(' ');
  let hours = parseInt(hourString);
  if (meridiem === 'PM' && hours !== 12) {
    hours += 12;
  } else if (meridiem === 'AM' && hours === 12) {
    hours = 0;
  }

  // Get the current date and time
  const now = new Date();

  // Set the scheduled time to today's date
  const scheduledTime = new Date(now);
  scheduledTime.setHours(hours);
  scheduledTime.setMinutes(0);

  // If the scheduled time is before the current time, it means it's for the next day
  if (scheduledTime < now) {
    scheduledTime.setDate(scheduledTime.getDate() + 1);
  }

  // Create the cron expression
  const cronExpression = `0 ${scheduledTime.getMinutes()} ${scheduledTime.getHours()} * * ?`;
  
  return cronExpression;
}


    

hidepicklistValues(){
    console.log('clicked outside picklist');
    this.showPicklist = false;
}
  convertToArray(jsonArray) {
  return jsonArray.map((item, index) => ({
    key: item.reportId,
    value: item.reportName
  }));
}
  
  search(event) {
    const input = event.detail.value.toLowerCase();
    const result = this.picklistOrdered.filter((picklistOption) =>
      picklistOption.label.toLowerCase().includes(input)
    );
    this.searchResults = result;
  }

  selectSearchResult(event) {
    const selectedValue = event.currentTarget.dataset.value;
    this.selectedSearchResult = this.picklistOrdered.find(
      (picklistOption) => picklistOption.value === selectedValue
    );

    console.log('selected value-->' + JSON.stringify(this.selectedSearchResult.value));
    this.showUserSelection = true;
    this.clearSearchResults();
  }

  clearSearchResults() {
    this.searchResults = null;
  }

  showPicklistOptions() {
    if (!this.searchResults) {
      this.searchResults = this.picklistOrdered;
    }
  }

    handleEntityOptionChange(event) {
        this.selectedEntityOption = event.detail.value;
            console.log('selected-->' + event.detail.value);
            this.getUsersByName();
        


    }

  showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(event);
    }
    

    openPopup() {
      this.isImmediate = false;
        this.showPopup = true;
    }

    closePopup() {
        this.showPopup = false;
    }

    handleRecipients(){

        this.showRecipients = true;
         this.showPopup = false;
    } 

    closeRecipientsPopup() {
        this.showRecipients = false;
         this.showPopup = true;
    }
}