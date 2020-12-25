# Variables
$TenantId = "XXXX" # Enter Tenant Id.
$ClientId = "XXXx" # Enter Client Id.
$ClientSecret = "XXXX" # Enter Client Secret.
$Resource = "https://management.core.windows.net/"
$SubscriptionId = "XXXX" # Enter Subscription Id.

POST https://login.microsoftonline.com/{tenantId}/oauth2/token

$RequestAccessTokenUri = "https://login.microsoftonline.com/$TenantId/oauth2/token"
$body = "grant_type=client_credentials&client_id=$ClientId&client_secret=$ClientSecret&resource=$Resource"
$Token = Invoke-RestMethod -Method Post -Uri $RequestAccessTokenUri -Body $body -ContentType 'application/x-www-form-urlencoded'
Write-Host "Print Token" -ForegroundColor Green
Write-Output $Token

GET https://management.azure.com/subscriptions/88694901-623d-41aa-9baf-96588cdfdf69/resourcegroups?api-version=2017-05-10
https://management.azure.com/subscriptions/88694901-623d-41aa-9baf-96588cdfdf69/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview


# Get Azure Resource Groups
$ResourceGroupApiUri = "https://management.azure.com/subscriptions/88694901-623d-41aa-9baf-96588cdfdf69/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"
$Headers = @{}
$Headers.Add("Authorization","$($Token.token_type) "+ " " + "$($Token.access_token)")
$ResourceGroups = Invoke-RestMethod -Method POST -Uri $ResourceGroupApiUri -Headers $Headers

Write-Host "Print Resource groups" -ForegroundColor Green
Write-Output $ResourceGroups