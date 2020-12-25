#Enable Azure Resource Access Management at Azure AD Tenant level before creating MG
$ParentGroupName = 'ContosoParentGroup'
$ParentGroupDisplayName = 'Contoso Parent Group'

$ManagedGroupName = 'ContosoManagedGroup'
$ManagemendGroupDisplayName = 'Contoso Managed Group'

$UnManagedGroupName = 'ContosoUnManagedGroup'
$UnManagemendGroupDisplayName = 'Contoso UnManaged Group'

$ManagedGroupProductName = 'ContosoManagedProducts'
$ManagedGroupProductDisplayName = 'Contoso Managed Products'

$ManagedGroupSharedServiceName = 'ContosoManagedSharedServices'
$ManagedGroupSharedServiceDisplayName = 'Contoso Managed Shared Services'

$SharedSubID = '7fd5afcb-ddc2-4d3f-bc22-b34f54991de2'
$ProductSubID = '88694901-623d-41aa-9baf-96588cdfdf69'

New-AzManagementGroup -GroupName $ParentGroupName -DisplayName $ParentGroupDisplayName

#Create Parent Management Group
$Parent = Get-AzManagementGroup -GroupName $ParentGroupName
New-AzManagementGroup -GroupName $ManagedGroupName -DisplayName $ManagemendGroupDisplayName -ParentId $Parent.id
New-AzManagementGroup -GroupName $UnManagedGroupName -DisplayName $UnManagemendGroupDisplayName -ParentId $Parent.id

#Create SubParent Management Group
$SubParent = Get-AzManagementGroup -GroupName $ManagedGroupName
New-AzManagementGroup -GroupName $ManagedGroupProductName -DisplayName $ManagedGroupProductDisplayName -ParentId $SubParent.id
New-AzManagementGroup -GroupName $ManagedGroupSharedServiceName -DisplayName $ManagedGroupSharedServiceDisplayName -ParentId $SubParent.id

#Move Subscription to Correct RG
New-AzManagementGroupSubscription -GroupName $ManagedGroupProductName -SubscriptionId $ProductSubID
New-AzManagementGroupSubscription -GroupName $ManagedGroupSharedServiceName -SubscriptionId $SharedSubID

