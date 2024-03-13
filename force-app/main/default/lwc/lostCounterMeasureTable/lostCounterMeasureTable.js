import { LightningElement, api } from 'lwc';
import getMasterLostType from '@salesforce/apex/LostCounterMeasureTableController.getCounterMeasureData';
import isLostOrDrop from "@salesforce/apex/LostCounterMeasureTableController.isLostOrDrop";
import NodataSavedLabel from '@salesforce/label/c.No_Data_Saved_Countermeasure';
import LANG from '@salesforce/i18n/lang';
export default class LostCounterMeasureTable extends LightningElement {
  @api recId;
  @api oppactid;
  isLost = false;
  isDrop = false;
  initData;
  SpanLength;
  label = {
        NodataSavedLabel,
    };
  secondSpanLength;
   renderAgain = false;
   noDataPopup = false;
  
    renderedCallback(){
      console.log('inside renderedcallback');
       
        
      if(this.renderAgain){
          console.log('insidegegenrationhtml');
              
                var finalMergedString = this.rowIterator()+this.initData; //forviewAllBased onOppId
               console.log('finalmerged------>' + finalMergedString);
              
              this.template.querySelector('.elementHoldingHTMLContent').innerHTML = finalMergedString;
      }
            
        
       
    }


    connectedCallback() {
       console.log('inside connected callback');
            isLostOrDrop({ activityId: "", oppId: this.recId  })
            .then(result => {
                console.log('Apex call returned:', result);
                // do something with the result
                if (result) {
          console.log("inside if");
          this.isLost = true;
        } else {
          console.log("inside else");
          this.isDrop = true;
        }
            })
            .catch(error => {
                console.error('Apex call error:', error);
                // handle the error
            });
            this.generateTableString();
       
    }


    generateTableString(){
      console.log('method entry apex');
      console.log('activity id',this.oppactid);
        getMasterLostType({
            recId: this.recId,
            userLang: LANG,
            oppActid : this.oppactid,
        })
        .then((data) => {
            //console.log('language----->' + LANG);
            //console.log('init data->' + data.LostActionItems__r.length);
            this.initData = data;
            console.log('value-->' +  JSON.stringify(this.initData));
           
              

            if(this.initData.length === 0 ){
                this.noDataPopup = true;
            }
            
           else{
              this.renderAgain = true;
            console.log('after renderagainboolean');
           }

           
            
            
          
            
              
           
        })
        .catch((error) => {
            console.log('init error->' + JSON.stringify(error));
        });

    }


    rowIterator(){
      console.log('inside row iteration');
      var htmlData = '';
         if(LANG == 'ko'){
          
        htmlData += "<tr>";
  
    //htmlData += `<th style="font-size: medium; font-family: NanumSquare,Helvatica,Arial,sans-serif; color:#000; background: #ebeff4; /*padding-top: 1%;*/ width:30%; white-space: pre-wrap;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: rgb(204, 255, 255);">실주/종결 사유</th>`;
    if (this.isLost) {
        htmlData += `<th  style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background-color: #ebeff4; white-space: pre-wrap;  font-weight: bold; width: 24%; white-space: pre-wrap;">실주 사유</th>`;
      }

      if (this.isDrop) {
        htmlData += `<th  style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;  color:#000; font-weight: bold; background-color: #ebeff4; width: 24%; white-space: pre-wrap;">종결 사유</th>`;
      }
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background: #ebeff4; width:35%; white-space: pre-wrap;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: rgb(204, 255, 255);">대책</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background: #ebeff4; /*padding-top: 1%;*/ white-space: pre-wrap; width:35%;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: rgb(204, 255, 255);">Action Item</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background: #ebeff4; /*padding-top: 1%;*/ width:17%;  white-space: pre-wrap;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: rgb(204, 255, 255);">주관부서</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background: #ebeff4; /*padding-top: 1%;*/ width:9%; white-space: pre-wrap; font-weight: bold; background-color: #ebeff4;" style="font-weight: bold; background-color: rgb(204, 255, 255);">기한</th>`;
    htmlData += "</tr>";
   /* htmlData += "<tr>";
    htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" colspan="1" style="font-weight: bold; background-color: rgb(204, 255, 255);">구분</th>`;
    htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" colspan="3" style="font-weight: bold; background-color: rgb(204, 255, 255);">상세</th>`;
    htmlData += "</tr>"; */
         }
         else {

        htmlData += "<tr>";
  
    //htmlData += `<th style="font-size: medium; font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000;  /*padding-top: 1%;*/ width:30%; white-space: pre-wrap;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: #ebeff4;">Reason for Drop/Lost</th>`;
     if (this.isLost) {
        htmlData += `<th  style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 24%; white-space: pre-wrap;">Lost Type</th>`;
      }

      if (this.isDrop) {
        htmlData += `<th  style=" font-family: NanumSquare,Helvatica,Arial,sans-serif;  background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold; width: 24%; white-space: pre-wrap;">Drop Type</th>`;
      }
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000;  width:35%; white-space: pre-wrap;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: #ebeff4;">Countermeasures</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; /*padding-top: 1%;*/ white-space: pre-wrap; width:35%;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: #ebeff4;">Action Item</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000;  /*padding-top: 1%;*/ white-space: pre-wrap; width:17%;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: #ebeff4;">Managing Dept.</th>`;
    htmlData += `<th style=" font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000;  /*padding-top: 1%;*/ white-space: pre-wrap; width:9%;  font-weight: bold; background-color: #ebeff4;"  style="font-weight: bold; background-color: #ebeff4;">Deadline</th>`;
    htmlData += "</tr>";
    /*htmlData += "<tr>";
    htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" colspan="1" style="font-weight: bold; background-color: rgb(204, 255, 255);">Category</th>`;
    htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" colspan="3" style="font-weight: bold; background-color: rgb(204, 255, 255);">Details</th>`;
    htmlData += "</tr>";*/
         }
  return htmlData;
    }


  




}