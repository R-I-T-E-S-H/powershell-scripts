$policysetdefination = 'C:\Project\GHub\Powershell\AzurePolicy\policy-initiative\storage-account-network-restriction-initiative\azurepolicyset.json'

$policysetdefinition = 'C:\Project\GHub\Powershell\AzurePolicy\policy-defination\restrict-public-storageAccount\azurepolicy.json'
$policysetdefinition = 'C:\Project\GHub\Powershell\AzurePolicy\policy-defination\restrict-storageAccount-firewall-rules\azurepolicy.json'

$policydefinition = 'C:\Project\GHub\Powershell\AzurePolicy\policy-definition\custom-definition\contoso-enforce-tag-and-value.json'

$ManagedGroupProductName = 'ContosoManagedProducts'

-PolicyLocations @{policyLocationResourceId1 = '/providers/Microsoft.Management/managementGroups/ContosoManagedProducts'}

.\deploy-PolicySetDef.ps1 -definationfile $policysetdefinition -managementGroupname $ManagedGroupProductName  -PolicyLocations @{policyLocationResourceId1 = '/providers/Microsoft.Management/managementGroups/ContosoManagedProducts'}

.\deploy-PolicyDef.ps1 -definitionfile $policydefinition -managementgroupname $ManagedGroupProductName




POST https://management.azure.com/subscriptions/88694901-623d-41aa-9baf-96588cdfdf69/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview

$url = 'https://management.azure.com/subscriptions/88694901-623d-41aa-9baf-96588cdfdf69/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview'
$cred = Get-Credential
Invoke-RestMethod -Method 'Post' -Uri $url -Credential $cred

##New-AzResourceGroupDeployment -TemplateFile .\DomainJoin.json -vmList XXX -domainFQDN XXX -domainJoinUserName XXX -domainJoinUserPassword $Secure_String_Pwd
