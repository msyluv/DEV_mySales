public class MasterActivityLogisticsAttributeHelper {
    private String OriginObject;
    private List<Criteria> Criterias;
    private String Logic;
    private String Output;
    
    private class Criteria { 
        private String No;
        private String OriginField;
        private String Operator;
        private String AttributeField;
    }
    
    
    public Static String dynamicSOQL(String jsonFilterCriteria, sObject rowObject, String Attribute, String TransactionName){
        String SOQL = 'SELECT Id, {Output} FROM MasterActivityLogisticsAttribute__c WHERE RecordType.DeveloperName = \'Condition\' AND Attribute__c = \'{Attribute}\' AND TransactionName__c = \'{TransactionName}\' AND {Logic} ';
        MasterActivityLogisticsAttributeHelper rowCriteria = (MasterActivityLogisticsAttributeHelper) System.JSON.deserialize(jsonFilterCriteria, MasterActivityLogisticsAttributeHelper.class);
                
        String sObjcet = rowCriteria.OriginObject;        
        String Output = rowCriteria.Output;
        
		Map<String, String> mapCondition = new Map<String, String>();      
        for(Criteria row : rowCriteria.Criterias){           
            String strCondition = '';
            
            //TODO : Operator Case는 확장 되어야 함.            
            switch on row.Operator.toLowercase() {
                when 'includes' {	
                    strCondition = row.AttributeField + ' INCLUDES (\'' + rowObject.get(row.OriginField) + '\')';
                }
                when '=' {	
                    strCondition = row.AttributeField + ' = \'' + rowObject.get(row.OriginField) + '\'';
                }
                when else {
                    // TODO : 에러 발생 시키기.
                }
            }
            mapCondition.put(row.No, strCondition);            
        }
        
        //SOQL 조건절 Generate
        String Logic = rowCriteria.Logic;
        for(String key : mapCondition.keySet()){
            Logic = Logic.replace('{'+key+'}', mapCondition.get(key));
        }
        
        SOQL = SOQL.replace('{Output}', rowCriteria.Output).replace('{sObject}', rowCriteria.OriginObject).replace('{Logic}', Logic).replace('{Attribute}', Attribute).replace('{TransactionName}', TransactionName);
        
        
        system.debug('### MasterActivityAttribute :: dynamicSOQL :: SOQL = ' + SOQL);
        
        return SOQL;
    }
}