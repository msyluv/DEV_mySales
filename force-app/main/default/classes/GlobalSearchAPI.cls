@RestResource(urlMapping='/globalSearch/*')
global with sharing class GlobalSearchAPI {
   /* @HttpGet
    global static List<List<SObject>> search() {
        String searchTerm = RestContext.request.params.get('q');
        
        List<List<SObject>> searchResults = new List<List<SObject>>();
        
        if (!String.isEmpty(searchTerm)) {
            String searchQuery = 'FIND \'' + searchTerm + '\' IN ALL FIELDS RETURNING ';
            Map<String, Schema.SObjectType> objectTypes = Schema.getGlobalDescribe();
            for (String objectName : objectTypes.keySet()) {
                if (objectTypes.get(objectName).getDescribe().isSearchable()) {
                    searchQuery += objectName + ',';
                }
            }
            searchQuery = searchQuery.removeEnd(',');
            
            List<List<SObject>> searchResultsLists = search.query(searchQuery);
            for (List<SObject> resultList : searchResultsLists) {
                searchResults.add(resultList);
            }
        }
        
        return searchResults;
    }*/
    

    
    @HttpGet
    global static List<List<SObject>> search() {
        String searchTerm = RestContext.request.params.get('q');
        List<List<SObject>> searchList = [FIND :searchTerm IN ALL FIELDS 
                                          RETURNING Account(Name), Opportunity(Name), Contact(FirstName, LastName)];
        
        return searchList;
    }
}