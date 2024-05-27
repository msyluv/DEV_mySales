<aura:application  access="global" implements="ltng:allowGuestAccess" extends="ltng:outApp"><!-- extends="force:slds"  -->
    <aura:dependency resource="c:testComp"/>
   <!-- <c:LookupSObject   recordId=""
                label="Label"
                pluralLabel= "Accounts"
                sObjectAPIName="Account"
                listIconSVGPath="/resource/SLDS0110/assets/icons/standard-sprite/svg/symbols.svg#account"
                listIconClass= "slds-icon-standard-account"
                callback= "function (data) {})"
                filter= "AccountId"
                required= "true"
              />-->
        <!-- <c:customLookup objectName="User" 
                                label="User" 
                                iconName="standard:user" 
                                required="true" 
                                minimum="2" 
                                additionalSelect="ProfileId" 
                                searchFields="Email" 
                                additionalDisplay="UserInfo__c"
                                filterFields = "isActive"
                                filterValues = "true"
                                filterConditions = "eq"/> -->
    
    <!-- <c:customLookup aura:id="clookup"
                                                lookupType="MultiHide"
                                                iconName="standard:user"
                                                label="{!$Label.c.APPR_LAB_APPROVER}"
                                                placeholder="{!$Label.c.APPR_LAB_ADD_APPROVER}"
                                                objectName="Employee__c"
                                                minimum="2" 
                                                searchFields="EvEName__c"
                                                additionalDisplay="Employee_Info__c"
                                                additionalSelect="EvMailAddr__c, EvUniqID__c, EvSdeptNM__c"
                                                filterFields="EvStatus__c"
                                                filterConditions="eq"
                                                filterValues="1"
                                                filterExpression="(Status__c != 'R')"
                                                required="True"
                                                enableMultiRecord="True"
                                                isIgnoredDuplicatedRule="True"
                                                numOfQuery="15" />-->
                
</aura:application>