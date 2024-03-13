import { LightningElement, track , api} from 'lwc';
import getUsers from '@salesforce/apex/ReportSearchController.getUsers';
import scheduleEmailSubscription from  '@salesforce/apex/ReportSubscriptionInitiator.scheduleEmailSubscription';

export default class UserSearchDropdown extends LightningElement {
    @track searchTerm = '';
    @track userOptions = [];
    @track showSuggestions = false;
    @track selectedUsers = [];
    @api  cronExp='';
    @api repId;
    @api immediate = false;
    @track finalList = [];
  @track renderfinalList = false;

    async handleInputChange(event) {
        this.searchTerm = event.target.value.trim();
        this.showSuggestions = false;

        if (this.searchTerm) {
            try {
                const result = await getUsers({ searchTerm: this.searchTerm });
                this.userOptions = result.map(user => ({
                    label: user.Name,
                    value: user.Id,
                    email: user.Email,
                    cssClass: 'slds-listbox__item' // Add this to apply SLDS styling to the list item
                }));
                this.showSuggestions = true;
            } catch (error) {
                console.error('Error fetching users:', error);
            }
        }
    }

    filterFinalList(event){

        const inputValue = event.detail.value;
        console.log('input-->' + inputValue);
        console.log('selectedusers-->' + JSON.stringify(this.selectedUsers));
       const finalList = [];

        for (let i = 0; i < this.selectedUsers.length; i++) {
            console.log('inside for loop-->' + this.selectedUsers[i].label);
            const user = this.selectedUsers[i];
            if (user.label.toLowerCase().includes(inputValue)) {
                console.log('inside if');
                finalList.push(user);
            }
        }

        this.finalList = finalList;

        console.log('finallist->' + JSON.stringify(this.finalList));
    }
    handleUserSelect(event) {
        const selectedValue = event.currentTarget.dataset.value;
        const selectedUser = this.userOptions.find(user => user.value === selectedValue);

        if (!this.selectedUsers.some(user => user.value === selectedUser.value)) {
            this.selectedUsers = [...this.selectedUsers, selectedUser];
        }
    }

     confirmReceivers() {
    console.log('clicked add before');
    this.finalList = this.selectedUsers;
    this.renderfinalList = true;
    console.log('clicked add-->' + JSON.stringify(this.finalList));
  }

  confirmSubscription(){
      console.log('cronexpressionfinal->' + this.cronExp);
      console.log('emailids-->' + JSON.stringify(this.finalList));
      console.log('repid-->' + this.repId);
       const emailsList = this.finalList.map(item => item.email);
        
        // Now 'emailsList' will be an array of email addresses
        console.log('updated-->' + emailsList);
      scheduleEmailSubscription({
          cronExp : this.cronExp,
          userEmails : emailsList,
          repId : this.repId
      })
      .then(result =>{
            console.log('success');
      })
      .catch(error => {
            console.log('error') + JSON.stringify(error);
      })
  }

    handleInputFocus() {
        this.showSuggestions = true;
    }

    handleInputBlur() {
        // Delay hiding the suggestions to handle click events on the suggestion list
        setTimeout(() => {
            this.showSuggestions = false;
        }, 300);
    }
}