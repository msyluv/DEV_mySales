public without sharing class LookupSObjectController
{
  /*
   * Loads the initial value of the given SObject type with ID "value"
 */
@AuraEnabled
  public static String getCurrentValue(String type, String value){
      if(String.isBlank(type)){
          return null;
      }

      ID lookupId = null;
      try{
        lookupId = (ID)value;
      }catch(Exception e){
          return null;
      }

      if(String.isBlank(lookupId)){
          return null;
      }

      SObjectType objType = Schema.getGlobalDescribe().get(type);
      if(objType == null){
          return null;
      }

      String nameField = getSobjectNameField(objType);
      String query = 'Select Id, '+nameField+' From '+type+' Where Id = \''+lookupId+'\'';
      System.debug('### Query: '+query);
      List<SObject> oList = Database.query(query);
      if(oList.size()==0) {
          return null;
      }
  return (String) oList[0].get(nameField);
  }


      /*
       * Returns the "Name" field for a given SObject (e.g. Case has CaseNumber, Account has Name)
    */
      private static String getSobjectNameField(SobjectType sobjType){

          //describes lookup obj and gets its name field
          String nameField = 'Name';
          Schema.DescribeSObjectResult dfrLkp = sobjType.getDescribe();
          for(schema.SObjectField sotype : dfrLkp.fields.getMap().values()){
              Schema.DescribeFieldResult fieldDescObj = sotype.getDescribe();
              if(fieldDescObj.isNameField() ){
                nameField = fieldDescObj.getName();
                  break;
              }
          }
          return nameField;
      }
    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);

        List<Result> results = new List<Result>();

        // Build our SOSL query
        String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name) Limit 50';

        // Execute the Query
        List<List<SObject>> searchList = search.query(searchQuery);

        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
            results.add(new Result((String)so.get('Name'), so.Id));
        }

        return results;
    }

    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}

        public Result(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}