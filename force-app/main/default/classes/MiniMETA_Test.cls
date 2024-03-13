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
@isTest  
private class MiniMETA_Test {

        /**
     * Dummy Metadata API web service mock class (see MetadataCreateJobTest.cls for a better example)
     **/
	private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType){

			if(request instanceof MiniMETA.listMetadata_element)
				response.put('response_x', new MiniMETA.listMetadataResponse_element());
            else if(request instanceof MiniMETA.readMetadata_element)
                response.put('response_x', new MiniMETA.readBusinessProcessResponse_element());
            else if(request instanceof MiniMETA.updateMetadata_element)
                response.put('response_x', new MiniMETA.updateMetadataResponse_element());
			return;
		}
	}    
		
	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MiniMETA metaDataService = new MiniMETA();
        // Invoke operations     
        Test.startTest();    
        MiniMETA.MetadataPort metaDataPort = new MiniMETA.MetadataPort();
        Test.stopTest();
	}
	
	@IsTest
    private static void coverGeneratedCodeFileBasedOperations()
    {    	
    	// Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MiniMETA metaDataService = new MiniMETA();
        // Invoke operations    
        Test.startTest();     
        MiniMETA.MetadataPort metaDataPort = new MiniMETA.MetadataPort();
        metaDataPort.listMetadata(null, null);
        metaDataPort.readMetadata(null, null);
        metaDataPort.updateMetadata(null);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeTypes()
    {    	       
        // Reference types
        Test.startTest();
        new MiniMETA();
        new MiniMETA.listMetadata_element();
        new MiniMETA.listMetadataResponse_element();
        new MiniMETA.readMetadata_element();
        new MiniMETA.readMetadataResponse_element();
        new MiniMETA.updateMetadata_element();
        new MiniMETA.updateMetadataResponse_element();

        new MiniMETA.ActionOverride();
        new MiniMETA.AllOrNoneHeader_element();
        new MiniMETA.ArticleTypeChannelDisplay();
        new MiniMETA.ArticleTypeTemplate();
        new MiniMETA.BusinessProcess();
        new MiniMETA.CompactLayout();
        new MiniMETA.CustomField();
        new MiniMETA.CustomObject();
        new MiniMETA.CustomValue();
        new MiniMETA.Error();
        new MiniMETA.ExtendedErrorDetails();
        new MiniMETA.FieldSet();
        new MiniMETA.FieldSetItem();
        new MiniMETA.FileProperties();
        new MiniMETA.FilterItem();
        new MiniMETA.HistoryRetentionPolicy();
        new MiniMETA.Index();
        new MiniMETA.IndexField();
        new MiniMETA.ListMetadataQuery();
        new MiniMETA.ListView();
        new MiniMETA.ListViewFilter();
        new MiniMETA.LookupFilter();
        new MiniMETA.Metadata();
        new MiniMETA.MktDataLakeAttributes();
        new MiniMETA.MktDataLakeFieldAttributes();
        new MiniMETA.MktDataModelAttributes();
        new MiniMETA.MktDataModelFieldAttributes();
        new MiniMETA.PicklistValue();
        new MiniMETA.ProfileSearchLayouts();
        new MiniMETA.ReadResult();
        new MiniMETA.RecordType();
        new MiniMETA.RecordTypePicklistValue();
        new MiniMETA.SaveResult();
        new MiniMETA.SearchLayouts();
        new MiniMETA.SessionHeader_element();
        new MiniMETA.SharedTo();
        new MiniMETA.SharingReason();
        new MiniMETA.SharingRecalculation();
        new MiniMETA.UpsertResult();
        new MiniMETA.ValidationRule();
        new MiniMETA.ValueSet();
        new MiniMETA.ValueSettings();
        new MiniMETA.ValueSetValuesDefinition();
        new MiniMETA.WebLink();
        Test.stopTest();
    }

    @IsTest
    private static void coverGetResults1()
    {    	       
        // Reference types
        Test.startTest();
        new MiniMETA.ReadBusinessProcessResult().getRecords();
        new MiniMETA.ReadCompactLayoutResult().getRecords();
        new MiniMETA.ReadCustomFieldResult().getRecords();
        new MiniMETA.ReadCustomObjectResult().getRecords();
        new MiniMETA.ReadCustomValueResult().getRecords();
        new MiniMETA.ReadFieldSetResult().getRecords();
        new MiniMETA.ReadListViewResult().getRecords();
        new MiniMETA.ReadPicklistValueResult().getRecords();
        new MiniMETA.ReadRecordTypeResult().getRecords();
        new MiniMETA.ReadSharingReasonResult().getRecords();
        new MiniMETA.ReadValidationRuleResult().getRecords();
        new MiniMETA.ReadWebLinkResult().getRecords();
        Test.stopTest();
    }
    @IsTest
    private static void coverGetResults2()
    {    	       
        // Reference types
        Test.startTest();
        new MiniMETA.readBusinessProcessResponse_element().getResult();
        new MiniMETA.readCompactLayoutResponse_element().getResult();
        new MiniMETA.readCustomFieldResponse_element().getResult();
        new MiniMETA.readCustomObjectResponse_element().getResult();
        new MiniMETA.readCustomValueResponse_element().getResult();
        new MiniMETA.readFieldSetResponse_element().getResult();
        new MiniMETA.readListViewResponse_element().getResult();
        new MiniMETA.readPicklistValueResponse_element().getResult();
        new MiniMETA.readRecordTypeResponse_element().getResult();
        new MiniMETA.readSharingReasonResponse_element().getResult();
        new MiniMETA.readValidationRuleResponse_element().getResult();
        new MiniMETA.readWebLinkResponse_element().getResult();
        Test.stopTest();
    }

}