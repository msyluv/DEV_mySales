/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 10-21-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   10-19-2020   woomg@dkbmc.com   Initial Version
**/
public without sharing class MiniMETAClient {
    public static MiniMETA.MetadataPort service;

    public static MiniMETA.MetadataPort createService() {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
//        String metaUrl = baseUrl + '/services/Soap/m/49.0/' + UserInfo.getOrganizationId();
        MiniMETA.MetadataPort service = new MiniMETA.MetadataPort();
//        service.endpoint_x = metaUrl;
        service.SessionHeader = new MiniMETA.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public static void handleResults(MiniMETA.SaveResult saveResult) {
        // Nothing to see?
        if(saveResult==null || saveResult.success) return;

        // Construct error message and throw an exception
        if(saveResult.errors != null) {
            List<String> messages = new List<String>();
            messages.add((saveResult.errors.size()==1 ? 'Error ' : 'Errors ') + 'occured processing component ' + saveResult.fullName + '.');
            for(MiniMETA.Error error : saveResult.errors)
                messages.add(error.message + ' (' + error.statusCode + ').' + ( error.fields!=null && error.fields.size()>0 ? ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size() > 0)
                if(!Test.isRunningTest()) throw new MiniMETAClientException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            if(!Test.isRunningTest()) throw new MiniMETAClientException('Request failed with no specified error.');
    }

    public class MiniMETAClientException extends Exception { }
}