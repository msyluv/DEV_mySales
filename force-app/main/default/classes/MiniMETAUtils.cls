/**
 * @description       : 
 * @author            : woomg@dkbmc.com
 * @group             : 
 * @last modified on  : 10-21-2020
 * @last modified by  : woomg@dkbmc.com
 * Modifications Log 
 * Ver   Date         Author            Modification
 * 1.0   10-21-2020   woomg@dkbmc.com   Initial Version
**/
public without sharing class MiniMETAUtils {

    public static MiniMETA.MetadataPort client;

    public static void ResetAutoNumberField(
        String objectName, 
        String fieldName, 
        String fieldLabel, 
        String displayFormat, 
        Integer startingNumber){

        String fullName = objectName + '.' + fieldName;
        client = MiniMETAClient.createService();
        changeToText(fullName, fieldLabel);
        changeToAutonumber(fullName, displayFormat, startingNumber);
    }

    public static void changeToText(String fullName, String fieldLabel){
        MiniMETA.CustomField customField = new MiniMETA.CustomField();
        customField.fullName = fullName;
        customField.label = fieldLabel;
        customField.type_x = 'Text';
        customField.length = 80;
        List<MiniMETA.SaveResult> results = new List<MiniMETA.SaveResult>();
        if(!Test.isRunningTest()){
            results = client.updateMetadata(new MiniMETA.Metadata[] { customField });
        } else {
            MiniMETA.SaveResult result = new MiniMETA.SaveResult();
            result.fullName = 'Field Error';
            result.success = false;
            results.add(result);
        }
        MiniMETAClient.handleResults(results[0]);

    }

    public static void changeToAutonumber(String fullName, String displayFormat, Integer startingNumber){
        MiniMETA.CustomField customField = new MiniMETA.CustomField();
        customField.fullName = fullName;
        customField.type_x = 'AutoNumber';
        customField.startingNumber = startingNumber;
        customField.displayFormat = displayFormat;
        List<MiniMETA.SaveResult> results = new List<MiniMETA.SaveResult>();
        if(!Test.isRunningTest()){
            results = client.updateMetadata(new MiniMETA.Metadata[] { customField });
        } else {
            MiniMETA.SaveResult result = new MiniMETA.SaveResult();
            result.fullName = 'Field Error';
            result.success = false;
            results.add(result);
        }
        MiniMETAClient.handleResults(results[0]);
    }
}