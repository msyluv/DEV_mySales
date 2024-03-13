/**
 * @description       : 
 * @author            : kilhwan.an@partner.samsung.com
 * @group             : 
 * @last modified on  : 2021-04-21
 * @last modified by  : kilhwan.an@partner.samsung.com
 * Modifications Log 
 * Ver   Date         Author                           Modification
 * 1.0   2021-04-21   kilhwan.an@partner.samsung.com   Initial Version
**/
public class Batch_DeleteData implements DataBase.Batchable<SObject> {
    
    public String query = null;
    public DataBase.QueryLocator start( DataBase.BatchableContext BC){

        return DataBase.getQueryLocator( query);
    }

    public void execute( DataBase.BatchableContext BC, List<SObject> scopeList){

        SavePoint sp = DataBase.setSavePoint();
        try{

            delete scopeList;
            DataBase.emptyRecycleBin( scopeList);
        }catch( Exception e){

            DataBase.rollback( sp);
        }
    }

    public void finish( DataBase.BatchableContext BC){

    }
}