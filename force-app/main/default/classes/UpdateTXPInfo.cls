/**
* @description       : Send BO Records and Receive Records of TXPmanpower Object from Jitterbit for UPSERT Operation(IF-184)
* @author            : vikrant.ks@samsung.com
* @group             : 
* @last modified on  : 2023-11-15
* @last modified by  : vikrant.ks@samsung.com 
* Modifications Log 
* Ver   Date         Author                   Modification
* 1.0   2023-11-15   vikrant.ks@samsung.com   Initial Version(MySales 356)
**/
public class UpdateTXPInfo {
    //public String oppId = ApexPages.currentPage().getParameters().get('id');//{!oppId}
    public UpdateTXPInfo(ApexPages.StandardSetController controller){
        //newTxp = new TXPmanpower__c();
        System.debug('All: '+ApexPages.currentPage().getParameters());
    }
    public static PageReference UpdateTxp(){// action="{!UpdateTxp}"
        String oppId = ApexPages.currentPage().getParameters().get('id');
        
        //Start Spinner
        //String Response = UpdateTxpManpowerController.UpdateTXPManpowerInfo(oppId);
        //Stop Spinner
        
        System.debug('ID: '+oppId);
        System.debug('All: '+ApexPages.currentPage().getParameters());
        
        String URL = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Opportunity/'+ oppId+'/related/TXP_manpower_input_information__r/view'; 
        PageReference Page = new PageReference(URL);
        Page.setRedirect(true);
        return Page; 
    }
}