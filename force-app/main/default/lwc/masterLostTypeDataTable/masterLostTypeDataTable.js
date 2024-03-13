/**
 * @description       : custom table view for master lost types(merged first 2 column rows if they are common)
 * @author            : rakshit.s@samsung.com
 * @group             :
 * @last modified on  : 04-12-2023
 * @last modified by  : rakshit.s@samsung.com
 * Modifications Log
 * Ver   Date         Author                  Modification
 * 1.1   03-01-2023   rakshit.s@samsung.com   Initial Development
 **/
import { LightningElement, api } from "lwc";

import getMasterLostType from "@salesforce/apex/MasterLostTypeDataController.getMasterLostType";
import isLostOrDrop from "@salesforce/apex/MasterLostTypeDataController.isLostOrDrop";
import LANG from "@salesforce/i18n/lang";

export default class MasterLostTypeDataTable extends LightningElement {
  @api recId;
  @api isViewAll;
  @api oppactid;
  convertedItems = [];
  renderAgain = false;
  showModal = false;
  OppSpecific = false;
  noDataPopup = false;
  showTable = true;
  noDataMessage;
  isLost = false;
  isDrop = false;

  renderedCallback() {
    console.log("inside renderedcallback");

    if (this.convertedItems.length > 0) {
      console.log("insidegegenrationhtml");
      if (this.OppSpecific) {
        var finalMergedString = this.rowIteratorviewAll(this.convertedItems); //forviewAllBased onOppId
      } else {
        var finalMergedString = this.rowIterator(this.convertedItems);
      }
      console.log("final string-->" + finalMergedString);
      this.template.querySelector(
        ".elementHoldingHTMLContent"
      ).innerHTML = finalMergedString;
    }
  }

  connectedCallback() {
    console.log("recordid-->" + this.recId);
    console.log("viewAll-->" + this.isViewAll);
    if (this.isViewAll) {
      this.viewModalAction();
    } else {
      this.viewOppSpecificModalAction();
    }

    if (LANG == "ko") {
      this.noDataMessage = "저장된 데이터가 없습니다";
    } else {
      this.noDataMessage = "No Data Saved";
    }
  }

  viewModalAction() {
    getMasterLostType({
      userLang: LANG,
      isSecondButton: false,
      oppId: this.recId,
    })
      .then((data) => {
        console.log("viewModalActionlanguage----->" + LANG);
        console.log("viewModalActioninit data->" + JSON.stringify(data));
        console.log("viewModalActionoppSpecificBoolean-->" + this.OppSpecific);

        if (this.OppSpecific) {
          this.convertedItems = [...this.convertViewAl(data)]; //forviewAllBased onOppId
          console.log(
            "viewModalActionconvertedjsonfrominitfirst->" +
              JSON.stringify(this.convertViewAl(data))
          );
        } else {
          this.convertedItems = [...this.convert(data)];
          console.log(
            "viewModalActionconvertedjsonfrominitSecond->" +
              JSON.stringify(this.convert(data))
          );
        }

        this.renderAgain = true;
      })
      .catch((error) => {
        console.log("init error->" + JSON.stringify(error));
      });
    this.showModal = true;
  }
  closeModalAction() {
    this.showModal = false;
    this.OppSpecific = false;
    this.renderAgain = false;
    this.convertedItems = [];
  }
  viewOppSpecificModalAction() {

    let isLost = false;
    let isDrop = false;
    

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
          
    getMasterLostType({
      userLang: LANG,
      isSecondButton: true,
      oppId: this.recId,
      oppActId : this.oppactid,
    })
      .then((data) => {
        console.log("viewOppSpecificModalActionlanguage----->" + LANG);
        console.log(
          "viewOppSpecificModalActioninit data->" + JSON.stringify(data)
        );
        console.log(
          "viewOppSpecificModalActionoppSpecificBoolean-->" + this.OppSpecific
        );

        if (data.length === 0) {
          this.noDataPopup = true;
          this.showTable = false;
        } else {
          if (this.OppSpecific) {
            this.convertedItems = [...this.convertViewAl(data)]; //forviewAllBased onOppId
            console.log(
              "viewOppSpecificModalActionconvertedjsonfrominitfirst->" +
                JSON.stringify(this.convertViewAl(data))
            );
          } else {
            this.convertedItems = [...this.convert(data)];
            console.log(
              "viewOppSpecificModalActionconvertedjsonfrominitsecond->" +
                JSON.stringify(this.convert(data))
            );
          }

          this.renderAgain = true;
        }
      })
      .catch((error) => {
        console.log("init error->" + JSON.stringify(error));
      });
    this.OppSpecific = true;
    this.showModal = true;
  }
  //convert for viewAll functionality.

  convertViewAl(json) {
    console.log("inisdeconvertviewAll-->" + JSON.stringify(json));
    try {
      const result = [];
      let level1;
      let level2;
      for (const obj of json) {
        if (LANG == "ko") {
          level1 = result.find(
            (o) => o.text === obj.Master_LostType__r.Level1_Type_Kor__c
          );
        } else {
          level1 = result.find(
            (o) => o.text === obj.Master_LostType__r.Level1_Type_Eng__c
          );
        }

        if (!level1) {
          if (LANG == "ko") {
            level1 = {
              data: [],
              text: obj.Master_LostType__r.Level1_Type_Kor__c,
            };
          } else {
            level1 = {
              data: [],
              text: obj.Master_LostType__r.Level1_Type_Eng__c,
            };
          }

          if (LANG == "ko") {
            level1 = {
              data: [],
              text: obj.Master_LostType__r.Level1_Type_Kor__c,
            };
          } else {
            level1 = {
              data: [],
              text: obj.Master_LostType__r.Level1_Type_Eng__c,
            };
          }

          result.push(level1);
        }

        if (LANG == "ko") {
          level2 = level1.data.find(
            (o) => o.text === obj.Master_LostType__r.Level2_Type_Kor__c
          );
        } else {
          level2 = level1.data.find(
            (o) => o.text === obj.Master_LostType__r.Level2_Type_Eng__c
          );
        }

        if (!level2) {
          if (LANG == "ko") {
            level2 = {
              data: [],
              text: obj.Master_LostType__r.Level2_Type_Kor__c,
            };
          } else {
            level2 = {
              data: [],
              text: obj.Master_LostType__r.Level2_Type_Eng__c,
            };
          }

          level1.data.push(level2);
        }

        if (LANG == "ko") {
          level2.data.push({
            Level1_Type_Kor__c: obj.Master_LostType__r.Level1_Type_Kor__c,
            Level2_Type_Kor__c: obj.Master_LostType__r.Level2_Type_Kor__c,
            Type_Kor__c: obj.Master_LostType__r.Type_Kor__c,
            Prediction_Strategy__c: obj.Prediction_Strategy__c,
            Results_Bidding__c: obj.Results_Bidding__c,
            Lost_Detail__c: obj.LOST_DETAIL__c,
            Rate__c: obj.Rate__c,
          });
        } else {
          level2.data.push({
            Level1_Type_Eng__c: obj.Master_LostType__r.Level1_Type_Eng__c,
            Level2_Type_Eng__c: obj.Master_LostType__r.Level2_Type_Eng__c,
            Type_Eng__c: obj.Master_LostType__r.Type_Eng__c,
            Prediction_Strategy__c: obj.Prediction_Strategy__c,
            Results_Bidding__c: obj.Results_Bidding__c,
            Lost_Detail__c: obj.LOST_DETAIL__c,
            Rate__c: obj.Rate__c,
          });
        }
      }

      return result;
    } catch (error) {
      console.log("error--->" + error);
    }
  }

  //convert for viewAll functionality ends.

  convert(json) {
    console.log("inisdeconvert");
    const result = [];
    let level1;
    let level2;
    for (const obj of json) {
      if (LANG == "ko") {
        level1 = result.find((o) => o.text === obj.Level1_Type_Kor__c);
      } else {
        level1 = result.find((o) => o.text === obj.Level1_Type_Eng__c);
      }

      if (!level1) {
        if (LANG == "ko") {
          level1 = { data: [], text: obj.Level1_Type_Kor__c };
        } else {
          level1 = { data: [], text: obj.Level1_Type_Eng__c };
        }

        if (LANG == "ko") {
          level1 = { data: [], text: obj.Level1_Type_Kor__c };
        } else {
          level1 = { data: [], text: obj.Level1_Type_Eng__c };
        }

        result.push(level1);
      }

      if (LANG == "ko") {
        level2 = level1.data.find((o) => o.text === obj.Level2_Type_Kor__c);
      } else {
        level2 = level1.data.find((o) => o.text === obj.Level2_Type_Eng__c);
      }

      if (!level2) {
        if (LANG == "ko") {
          level2 = { data: [], text: obj.Level2_Type_Kor__c };
        } else {
          level2 = { data: [], text: obj.Level2_Type_Eng__c };
        }

        level1.data.push(level2);
      }

      if (LANG == "ko") {
        level2.data.push({
          Level1_Type_Kor__c: obj.Level1_Type_Kor__c,
          Level2_Type_Kor__c: obj.Level2_Type_Kor__c,
          Type_Kor__c: obj.Type_Kor__c,
        });
      } else {
        level2.data.push({
          Level1_Type_Eng__c: obj.Level1_Type_Eng__c,
          Level2_Type_Eng__c: obj.Level2_Type_Eng__c,
          Type_Eng__c: obj.Type_Eng__c,
        });
      }
    }

    return result;
  }

  //convert for viewAll functionality Starts.
  rowIteratorviewAll(mainRowItem) {
    //let isFirstRowSpanSet = false;
    //let firstRowsSpanCount = 0;
    
        var htmlData = "";

    if (LANG == "ko") {
      htmlData += "<tr>";
      
      if (this.isLost) {
        htmlData += `<th colspan="3" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; text-color:#000; background-color: #ebeff4; white-space: pre-wrap;  font-weight: bold; width: 28%">실주 사유</th>`;
      }

      if (this.isDrop) {
        htmlData += `<th colspan="3" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;  color:#000; font-weight: bold; background-color: #ebeff4; width: 28%">종결 사유</th>`;
      }

      // htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA; width: 32.5%">사전 경쟁 예측 및 전략</th>`;
      // htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" width: 32.5%>입찰 후 결과</th>`;
      htmlData += `<th rowspan="2" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap; color:#000;  font-weight: bold; background-color: #ebeff4; width: 65%">상세 내용</th>`;
      htmlData += `<th rowspan="2" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap; color:#000;  font-weight: bold; background-color: #ebeff4; width: 7%">비중(%)</th>`;

      htmlData += "</tr>";
         htmlData += "<tr>"
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 1</th>`;
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 2</th>`;
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 3</th>`;
      htmlData += "</tr>";
    } else {
      console.log("inside english lang");
      //console.log('isDrop' + isDrop);
      htmlData += "<tr>";
      if (this.isLost) {
        htmlData += `<th colspan="3" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Lost Type</th>`;
      }

      if (this.isDrop) {
        htmlData += `<th colspan="3" style="font-family: NanumSquare,Helvatica,Arial,sans-serif;  background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold; width: 28%">Drop Type</th>`;
      }

      // htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA; width: 32.5%">Pre Competition Prediction and Strategy</th>`;
      // htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;" width: 32.5%>Result After Bidding</th>`;
      htmlData += `<th rowspan="2" style="font-family: NanumSquare,Helvatica,Arial,sans-serif;  background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 65%">Detail</th>`;
      htmlData += `<th rowspan="2" style="font-family: NanumSquare,Helvatica,Arial,sans-serif;  background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 7%">Rate(%)</th>`;

      htmlData += "</tr>";

      htmlData += "<tr>"
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 1</th>`;
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 2</th>`;
      htmlData += `<th colspan="1" style="font-family: NanumSquare,Helvatica,Arial,sans-serif; background-color: #ebeff4; white-space: pre-wrap; color:#000; font-weight: bold;  width: 28%">Level 3</th>`;
      htmlData += "</tr>";

    }

    console.log("mainrowitem-->" + JSON.stringify(mainRowItem));

    for (let i = 0; i < mainRowItem.length; i++) {
      let isFirstRowSpanSet = false;
      let firstRowsSpanCount = 0;
      mainRowItem[i].data.forEach(firstRowsSpanCounter);
      function firstRowsSpanCounter(item, index) {
        firstRowsSpanCount = firstRowsSpanCount + item.data.length;
        console.log("inside firstrowspancounter" + firstRowsSpanCount);
      }

      mainRowItem[i].data.forEach(firstRowsSpanIterator);

      function firstRowsSpanIterator(outerItem, outerIndex) {
        //console.log('insidesecondfunction');
        var isSecondRowSpanSet = false;
        outerItem.data.forEach(secondRowSpanIterator);
        function secondRowSpanIterator(innerItem, innerIndex) {
          console.log("insidenestedfunction");

          htmlData += "<tr>";

          if (!isFirstRowSpanSet) {
            if (LANG == "ko") {
              htmlData +=
                '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;" rowspan="' +
                firstRowsSpanCount +
                '">' +
                innerItem.Level1_Type_Kor__c +
                "</td>";
            } else {
              htmlData +=
                '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;" rowspan="' +
                firstRowsSpanCount +
                '">' +
                innerItem.Level1_Type_Eng__c +
                "</td>";
            }

            isFirstRowSpanSet = true;
          }

          if (!isSecondRowSpanSet) {
            if (LANG == "ko") {
              htmlData +=
                '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;" rowspan="' +
                outerItem.data.length +
                '">' +
                innerItem.Level2_Type_Kor__c +
                "</td>";
            } else {
              htmlData +=
                '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;" rowspan="' +
                outerItem.data.length +
                '">' +
                innerItem.Level2_Type_Eng__c +
                "</td>";
            }

            isSecondRowSpanSet = true;
          }

          if (LANG == "ko") {
            htmlData +=
              '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;">' +
              innerItem.Type_Kor__c +
              "</td>";
            //htmlData+= '<td style="white-space: pre-wrap;text-align:left;">' + innerItem.Prediction_Strategy__c + '</td>';
            htmlData +=
              '<td style="word-break:break-all; background-color: #fff; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;text-align:left;">' +
              innerItem.Lost_Detail__c +
              "</td>";
            //htmlData+= '<td style="white-space: pre-wrap;text-align:left;">' + innerItem.Results_Bidding__c + '</td>';
            htmlData +=
              '<td style="background-color: #fff; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;">' +
              innerItem.Rate__c +
              "</td>";
          } else {
            console.log("inneritem-->" + JSON.stringify(innerItem));
            htmlData +=
              '<td style="background-color: #f8f9f9; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;">' +
              innerItem.Type_Eng__c +
              "</td>";
            htmlData +=
              '<td style="word-break:break-all; background-color: #fff; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;text-align:left;">' +
              innerItem.Lost_Detail__c +
              "</td>";
            //htmlData+= '<td style="white-space: pre-wrap;text-align:left;">' + innerItem.Results_Bidding__c + '</td>';
            htmlData +=
              '<td style="background-color: #fff; color:#000; font-family: NanumSquare,Helvatica,Arial,sans-serif; white-space: pre-wrap;">' +
              innerItem.Rate__c +
              "</td>";
          }

          htmlData += "</tr>";
        }
      }
    }
    return htmlData;
  

    
  }
  //converts for viewAll functionality Ends.

  rowIterator(mainRowItem) {
    //let isFirstRowSpanSet = false;
    //let firstRowsSpanCount = 0;
    var htmlData = "";

    if (LANG == "ko") {
      htmlData += "<tr>";

      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">레벨 1</th>`;
      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">레벨 2</th>`;
      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">레벨 3</th>`;

      htmlData += "</tr>";
    } else {
      htmlData += "<tr>";

      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">Level 1</th>`;
      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">Level 2</th>`;
      htmlData += `<th style="white-space: pre-wrap; color:#597385; font-weight: bold; background-color: #FAFAFA;">Level 3</th>`;

      htmlData += "</tr>";
    }

    console.log("mainrowitem-->" + JSON.stringify(mainRowItem));

    for (let i = 0; i < mainRowItem.length; i++) {
      let isFirstRowSpanSet = false;
      let firstRowsSpanCount = 0;
      mainRowItem[i].data.forEach(firstRowsSpanCounter);
      function firstRowsSpanCounter(item, index) {
        firstRowsSpanCount = firstRowsSpanCount + item.data.length;
        console.log("inside firstrowspancounter" + firstRowsSpanCount);
      }

      mainRowItem[i].data.forEach(firstRowsSpanIterator);

      function firstRowsSpanIterator(outerItem, outerIndex) {
        //console.log('insidesecondfunction');
        var isSecondRowSpanSet = false;
        outerItem.data.forEach(secondRowSpanIterator);
        function secondRowSpanIterator(innerItem, innerIndex) {
          console.log("insidenestedfunction");

          htmlData += "<tr>";

          if (!isFirstRowSpanSet) {
            if (LANG == "ko") {
              htmlData +=
                '<td style="white-space: pre-wrap;" rowspan="' +
                firstRowsSpanCount +
                '">' +
                innerItem.Level1_Type_Kor__c +
                "</td>";
            } else {
              htmlData +=
                '<td style="white-space: pre-wrap;" rowspan="' +
                firstRowsSpanCount +
                '">' +
                innerItem.Level1_Type_Eng__c +
                "</td>";
            }

            isFirstRowSpanSet = true;
          }

          if (!isSecondRowSpanSet) {
            if (LANG == "ko") {
              htmlData +=
                '<td style="white-space: pre-wrap;" rowspan="' +
                outerItem.data.length +
                '">' +
                innerItem.Level2_Type_Kor__c +
                "</td>";
            } else {
              htmlData +=
                '<td style="white-space: pre-wrap;" rowspan="' +
                outerItem.data.length +
                '">' +
                innerItem.Level2_Type_Eng__c +
                "</td>";
            }

            isSecondRowSpanSet = true;
          }

          if (LANG == "ko") {
            htmlData +=
              '<td style="white-space: pre-wrap;">' +
              innerItem.Type_Kor__c +
              "</td>";
          } else {
            htmlData +=
              '<td style="white-space: pre-wrap;">' +
              innerItem.Type_Eng__c +
              "</td>";
          }

          htmlData += "</tr>";
        }
      }
    }
    return htmlData;
  }
}