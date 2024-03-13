/**
 * @author            : younghoon.kim@dkbmc.com
 * @group             : 
 * @description       : 
 * @last modified on  : 2020-08-26
 * @last modified by  : younghoon.kim@dkbmc.com
 * @comments : https://ap16.salesforce.com/services/apexrest/searchBO/search?id=BOId
 * Modifications Log 
 * Ver   Date         Author                    Modification
 * 1.0   2020-08-24   younghoon.kim@dkbmc.com   Initial Version
**/
@RestResource(urlMapping='/searchBO/*')
global class Search_BO_For_KnoxTeams {
    /**
    * @description 
    * @author younghoon.kim@dkbmc.com | 2020-08-24 
    * @return String 
    **/
    @HttpGet
    global static String search(){
        // String BOID = String.valueOf(RestContext.request.params.get('id'));
        String returnString = 'SUCCESS';
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        // List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity WHERE Id =: BOID];

        // if(oppList !=null && oppList.size()>0){
        //     response.acct = result[0];
        //     response.status = 'Success';
        // }else{
        //     response.acct = null;
        //     response.status = 'Error';
        //     response.message = 'This Business Opportunity could not be found, please try again';
        //     res.StatusCode = 404;
        // }
        return returnString;
    }
}