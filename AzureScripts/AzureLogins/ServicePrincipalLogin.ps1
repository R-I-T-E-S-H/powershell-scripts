################Certificate Login#################
#Create Selfsign Certificate
$cert = New-SelfSignedCertificate -CertStoreLocation "Cert:\CurrentUser\My" -Subject "CN=PowerAuth" -KeySpec KeyExchange
$keyValue = [System.Convert]::ToBase64String($cert.GetRawCertData())

#This creates application and service principal in Azure AD
$sp = New-AzADServicePrincipal -DisplayName 'PowerAuth' -CertValue $keyValue -EndDate $cert.NotAfter -StartDate $cert.NotBefore 
start-sleep -Seconds 20
# $sp = Get-AzADServicePrincipal -DisplayName 'DemoApp'

#Assign Role to Service Principal Application ID
New-AzRoleAssignment -RoleDefinitionName Owner -ApplicationId $sp.ApplicationId

#$TenantID = (Get-AzSubscription -SubscriptionName "Visual Studio Ultimate with MSDN").TenantId
$TenantID = ''
#$ApplicationID = (Get-AzADApplication -DisplayNameStartWith 'PowerAuth').ApplicationId
$ApplicationID = ''

$Thumbprint = (Get-ChildItem Cert:\CurrentUser\my\ | Where-Object {$_.Subject -eq "CN=PowerAuth"}).Thumbprint

Connect-AzAccount -ServicePrincipal -CertificateThumbprint $Thumbprint -ApplicationId $ApplicationID -Tenant $TenantID



###############Client Secret Login#############

$passwd = ConvertTo-SecureString <use a secure password here> -AsPlainText -Force
$pscredential = New-Object System.Management.Automation.PSCredential('service principal name/id', $passwd)
Connect-AzAccount -ServicePrincipal -Credential $pscredential -TenantId $tenantId

