
. ..\common\Login.ps1
. ..\common\New-ComplexPassword.ps1

$DirectoryID = "XXX"
$UserName = "XXXXX"
$SubscriptionID = "XXXXX"

LoginUsingCredentials -DirectoryID  $DirectoryId -UserName $UserName
Get-AzSubscription -SubscriptionId $SubscriptionID | set-azcontext

$SubscriptionName = Read-Host -Prompt "Enter Subscription Code"
$Team = Read-Host -Prompt "Enter Team Code"
$AppCode = Read-Host -Prompt "Enter Application Code"
$RegionCode = Read-Host -Prompt "Enter Region Code"
$Enviornment = Read-Host -Prompt "Enviornment Code"
$location = Read-Host -Prompt "Enter the location (i.e. westeurope)"
$objectId = Read-Host -Prompt "Enter the ObjectID"


#Generate Variables
$resourceGroupName = ($SubscriptionName + "-" + $Team + "-" + $AppCode + "-" + $RegionCode + "-" + $Enviornment + "-rg").ToLower()
$keyVaultName =  ($SubscriptionName + "-" + $Team + "-" + $AppCode + "-" + $RegionCode + "-" + $Enviornment + "-kv").ToLower() 
$SAName = ($SubscriptionName + $Team + $AppCode + $RegionCode + $Enviornment + "sa").ToLower()
$logAnalyticsName = ($SubscriptionName + "-" + $Team + "-" + $AppCode + "-" + $RegionCode + "-" + $Enviornment + "-la").ToLower()
$automationAccountName = ($SubscriptionName + "-" + $Team + "-" + $AppCode + "-" + $RegionCode + "-" + $Enviornment + "-aa").ToLower()
$cotrAADGroup = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_COTR"
$redrAADGroup = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_REDR"
$ownrAADGroup = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_OWNR"

New-AzResourceGroup -Name $resourceGroupName -Location $location
New-AzureADGroup -Description "Contributor Security Group for $resourceGroupName Resource Group" -DisplayName $cotrAADGroup -MailEnabled $false -SecurityEnabled $true -MailNickName $cotrAADGroup
New-AzureADGroup -Description "Reader Security Group for $resourceGroupName Resource Group" -DisplayName $redrAADGroup -MailEnabled $false -SecurityEnabled $true -MailNickName $redrAADGroup
New-AzureADGroup -Description "Owner Security Group for $resourceGroupName Resource Group" -DisplayName $ownrAADGroup -MailEnabled $false -SecurityEnabled $true -MailNickName $ownrAADGroup


$additionalParams = @{
    storageAccountName = $SAName
    keyVaultName = $keyVaultName
    objectId = $objectId
    logAnalyticsName = $logAnalyticsName
    automationAccountName = $automationAccountName
      }

New-AzResourceGroupDeployment -ResourceGroupName $resourceGroupName -templatefile subsetup_azuredeploy.json -TemplateParameterFile .\subsetup_azuredeploy.parameter.json @additionalParams

#Role Assignment