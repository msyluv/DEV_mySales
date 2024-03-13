/**
 * @description       : Schedulable class for BO_MATRIX_Count 
 * @author            : d.ashish@samsung.com
 * @group             : 
 * @last modified on  : 2023-09-01
 * @last modified by  : anish.jain@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                   Modification
 * 1.0   2023-06-06   d.ashish@samsung.com   Initial Version
 * 1.1   2023-09-01   anish.jain@partner.samsung.com   Task - (Logistics) BO Matrix Enhancement - MS 286
**/

public class logisticOpportunityCountSchedulable  implements schedulable{
    public void execute(SchedulableContext cx){
        System.debug('logisticOpportunityCountSchedulable entry');
    List<BO_Matrix_cnt__c> logisticOpptyCountList =  new List<BO_Matrix_cnt__c>([select id,From_RHQ__c,To_RHQ__c,Count__c,Related_Report__c  from BO_Matrix_cnt__c order by From_RHQ__c,To_RHQ__c asc LIMIT 100]); //Added by Anish - V 1.1
        for(BO_Matrix_cnt__c countVar: logisticOpptyCountList){
            countVar.Count__c = [Select count() from opportunity where (
                (From_RHQ1__c =:countVar.From_RHQ__c  AND   To_RHQ_1__c =:countVar.To_RHQ__c) OR
                (From_RHQ2__c =:countVar.From_RHQ__c  AND   To_RHQ_2__c =:countVar.To_RHQ__c) OR
                (From_RHQ3__c =:countVar.From_RHQ__c  AND   To_RHQ_3__c =:countVar.To_RHQ__c) OR
                (From_RHQ4__c =:countVar.From_RHQ__c  AND   To_RHQ_4__c =:countVar.To_RHQ__c) OR
                (From_RHQ5__c =:countVar.From_RHQ__c  AND   To_RHQ_5__c =:countVar.To_RHQ__c) OR
                (From_RHQ6__c =:countVar.From_RHQ__c  AND   To_RHQ_6__c =:countVar.To_RHQ__c) OR
                (From_RHQ7__c =:countVar.From_RHQ__c  AND   To_RHQ_7__c =:countVar.To_RHQ__c) OR
                (From_RHQ8__c =:countVar.From_RHQ__c  AND   To_RHQ_8__c =:countVar.To_RHQ__c) OR
                (From_RHQ9__c =:countVar.From_RHQ__c  AND   To_RHQ_9__c =:countVar.To_RHQ__c) OR
                (From_RHQ10__c =:countVar.From_RHQ__c  AND   To_RHQ_10__c =:countVar.To_RHQ__c) 
                
            ) AND (StageName = 'Z01' OR StageName ='Z02' OR StageName ='Z03' OR StageName ='Z04') //Added by Anish - V 1.1
                ];
        }
        database.update(logisticOpptyCountList, false);
        matrixSum(logisticOpptyCountList); //Added by Anish - V 1.1
    }
    
    //Added by Anish - V 1.1
    public void matrixSum (List<BO_Matrix_cnt__c> logisticOpptyCountList){
        Decimal SumRow1 = 0;
        Decimal SumRow2 = 0;
        Decimal SumRow3 = 0;
        Decimal SumRow4 = 0;
        Decimal SumRow5 = 0;
        Decimal SumRow6 = 0;
        Decimal SumRow7 = 0;
        Decimal SumCol1 = 0;
        Decimal SumCol2 = 0;
        Decimal SumCol3 = 0;
        Decimal SumCol4 = 0;
        Decimal SumCol5 = 0;
        Decimal SumCol6 = 0;
        Decimal SumCol7 = 0;
        for(Integer i=0 ; i<logisticOpptyCountList.Size() ; i++ ){
            if(i == 0 || i== 1 || i == 2 || i== 3 || i== 4 || i== 5 || i== 6){
                SumRow1 = SumRow1 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 7){
                System.debug('Ani Count ' + SumRow1);
              logisticOpptyCountList[i].Count__c = SumRow1;  
            }
            if(i == 8 || i== 9 || i == 10 || i== 11 || i== 12 || i== 13 || i== 14){
                SumRow2 = SumRow2 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 15){
                System.debug('Ani Count ' + SumRow2);
              logisticOpptyCountList[i].Count__c = SumRow2;  
            }
            if(i == 16 || i== 17 || i == 18 || i== 19 || i== 20 || i== 21 || i== 22){
                SumRow3 = SumRow3 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 23){
                System.debug('Ani Count ' + SumRow3);
              logisticOpptyCountList[i].Count__c = SumRow3;  
            }
            if(i == 24 || i== 25 || i == 26 || i== 27 || i== 28 || i== 29 || i== 30){
                SumRow4 = SumRow4 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 31){
                System.debug('Ani Count ' + SumRow4);
              logisticOpptyCountList[i].Count__c = SumRow4;  
            }
            if(i == 32 || i== 33 || i == 34 || i== 35 || i== 36 || i== 37 || i== 38){
                SumRow5 = SumRow5 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 39){
                System.debug('Ani Count ' + SumRow5);
              logisticOpptyCountList[i].Count__c = SumRow5;  
            }
            if(i == 40 || i== 4 || i == 42 || i== 43 || i== 44 || i== 45 || i== 46){
                SumRow6 = SumRow6 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 47){
                System.debug('Ani Count ' + SumRow6);
              logisticOpptyCountList[i].Count__c = SumRow6;  
            }
            if(i == 48 || i== 49 || i == 50 || i== 51 || i== 52 || i== 53 || i== 54){
                SumRow7 = SumRow7 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 55){
                System.debug('Ani Count ' + SumRow7);
              logisticOpptyCountList[i].Count__c = SumRow7;  
            }
             if(i == 0 || i== 8 || i == 16 || i== 24 || i== 32 || i== 40 || i== 48){
                SumCol1 = SumCol1 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 56){
                System.debug('Ani Count ' + SumCol1);
              logisticOpptyCountList[i].Count__c = SumCol1;  
            }
             if(i == 1 || i== 9 || i == 17 || i== 25 || i== 33 || i== 41 || i== 49){
                SumCol2 = SumCol2 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 57){
                System.debug('Ani Count ' + SumCol2);
              logisticOpptyCountList[i].Count__c = SumCol2;  
            }
             if(i == 2 || i== 10 || i == 18 || i== 26 || i== 34 || i== 42 || i== 50){
                SumCol3 = SumCol3 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 58){
                System.debug('Ani Count ' + SumCol3);
              logisticOpptyCountList[i].Count__c = SumCol3;  
            }
             if(i == 3 || i== 11 || i == 19 || i== 27 || i== 35 || i== 43 || i== 51){
                SumCol4 = SumCol4 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 59){
                System.debug('Ani Count ' + SumCol4);
              logisticOpptyCountList[i].Count__c = SumCol4;  
            }
             if(i == 4 || i== 12 || i == 20 || i== 28 || i== 36 || i== 44 || i== 52){
                SumCol5 = SumCol5 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 60){
                System.debug('Ani Count ' + SumCol5);
              logisticOpptyCountList[i].Count__c = SumCol5;  
            }
             if(i == 5 || i== 13 || i == 21 || i== 29 || i== 37 || i== 45 || i== 53){
                SumCol6 = SumCol6 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 61){
                System.debug('Ani Count ' + SumCol6);
              logisticOpptyCountList[i].Count__c = SumCol6;  
            }
             if(i == 6 || i== 14 || i == 22 || i== 30 || i== 38 || i== 46 || i== 54){
                SumCol7 = SumCol7 + logisticOpptyCountList[i].Count__c ;
            }
            if(i == 62){
                System.debug('Ani Count ' + SumCol7);
              logisticOpptyCountList[i].Count__c = SumCol7;  
            }
             if(i == 63){
                System.debug('Ani Count ' + SumCol7);
                 //SJOSHI start: Commented below 1 line and added 1 line as per requirement
              //logisticOpptyCountList[i].Count__c = SumCol1 + SumCol2 + SumCol3 + SumCol4 + SumCol5 + SumCol6 + SumCol7 + SumRow1 + SumRow2 + SumRow3 + SumRow4 + SumRow5 + SumRow6 + SumRow7; 
                 logisticOpptyCountList[i].Count__c = SumRow1 + SumRow2 + SumRow3 + SumRow4 + SumRow5 + SumRow6 + SumRow7;  
                 //SJOSHI end
            }
        }
        database.update(logisticOpptyCountList, false);
    }
}