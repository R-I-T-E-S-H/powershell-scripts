workflow New-ServicePrincipalWithSecret
{
 Param(
    [Parameter(Mandatory = $false)]
    [string]$ENV,
    [Parameter(Mandatory = $false)]
    [string]$Team,
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionCode,
    [Parameter(Mandatory = $false)]
    [string]$Region,
    [Parameter(Mandatory = $false)]
    [string]$ShortName,
    [Parameter(Mandatory = $false)]
    [string]$SPName,
    [Parameter(Mandatory = $false)]
    [string]$VaultName,
    [Parameter(Mandatory = $false)]
    [string]$SecretName,
    [Parameter(Mandatory = $false)]
    [string]$ApplicationCode,
    [Parameter(Mandatory = $false)]
    [string]$Description
  )

  #   #region connection
  $Conn = Get-AutomationConnection -Name AzureRunAsConnection

  $null = Add-AzAccount `
    -ServicePrincipal `
    -Tenant $Conn.TenantID `
    -ApplicationId $Conn.ApplicationID `
    -CertificateThumbprint $Conn.CertificateThumbprint

  $null = Connect-AzureAD  `
    -TenantId $Conn.TenantID    `
    -ApplicationId  $Conn.ApplicationID  `
    -CertificateThumbprint $Conn.CertificateThumbprint
  #endregion
  
  # Variables
  write-output "- Building variables"

  if ($Region -eq "westeurope")
      {
      $Rcode = "we"
      }
      elseif ($Region -eq "northeurope")
      {$Rcode = "ne"}
      elseif ($Region -eq "westnorway")
      {$Rcode = "wn"}
      elseif ($Region -eq "eastnorway")
      {$Rcode = "en"}

  if (!$SPName) {
    $SPName = $SubscriptionCode.ToLower() + "-" + $Team.ToUpper() + "-" + $ApplicationCode.ToLower() + "-" + $Rcode.ToUpper() + "-" + $Description.ToLower() + "-SP"
  }
  if (!$VaultName) {
    $VaultName = $SubscriptionCode.ToLower() + "-" + $Team.ToLower() + "-shr-" + $Rcode.ToLower() + "-" + $ENV.ToUpper() + "-kv"
  }
  if (!$SecretName) {
    $SecretName = "$SPName-Secret"
  }


$HomePage = "http://" + $SpName
$IdentifierUris = $HomePage  
$YearsToSecretExpireation = 10
$KeyVaultRG = (Get-AzKeyVault -VaultName $VaultName).ResourceGroupName
$SecretName = $SpName + "-Secret"

# Create a new AAD application with a Service Principal
try {
    # create Application
    $AadApp = New-AzureADApplication `
      -DisplayName $SpName `
      -HomePage $HomePage `
      -IdentifierUris $IdentifierUris `
      -ErrorAction Stop
    
    write-output "-- created new application"

    # Find the ID for the Automation SP to crate access policy
    #$ObjectIDWorker = (Get-AzureRmADServicePrincipal -ApplicationId (Get-AzureRmContext).account.id).Id.Guid
    $objectIDWorker =  (Get-AzureADServicePrincipal | where{$_.appid -eq (Get-AzContext).account.id}).ObjectID
   
        
    # create KeyVaultAccessPolicy, new secret, keyVaultSecret,  remove policy
    $kvAccessPolicy = Set-AzKeyVaultAccessPolicy `
      -ResourceGroupName $KeyVaultRG `
      -VaultName $VaultName `
      -ObjectId $ObjectIDWorker  `
      -PermissionsToSecrets Get, List, Set, Purge, Delete `
      -ErrorAction Stop

    write-output "-- Set KV Access Policy"
    #check if the secret already exists
    $doesSecretExist = Get-AzKeyVaultSecret -VaultName $VaultName  -Name $SecretName -ErrorAction SilentlyContinue
    
    if (!$doesSecretExist) {
      # Expiration date set according to default or override settings
      $Expires = (Get-Date).AddYears($YearsToSecretExpireation).ToUniversalTime()
      $NBF = (Get-Date).ToUniversalTime()
      $contentType = 'txt'
      

    # Create Password
    write-output "Create Password"
    $Password = New-ComplexPassWord -ErrorAction Stop
    $Secure_String_Pwd = ConvertTo-SecureString $Password -AsPlainText -Force
   
   
      # Create a KeyVault Secret
      $secretCreatedDetails = Set-AzKeyVaultSecret `
        -VaultName $VaultName `
        -Name $SecretName `
        -SecretValue $Secure_String_Pwd  `
        -Expires $Expires `
        -NotBefore $NBF `
        -ContentType $ContentType `
        -ErrorAction Stop
      
      write-output "-- Created KeyVault Access Policy and Secret"

      # Crate a new Azure App Credential
      $null = New-AzureADApplicationPasswordCredential `
        -ObjectId $AadApp.ObjectId `
        -Value $Password `
        -EndDate $Expires `
        -ErrorAction Stop
      
      write-output "-- Created AppCredential and KeyVaultAccessPolicy"  
    }
    else {
      throw "Secret already exists, new Secret not created"
    }
 
    # create SP (Sleep here for a few seconds to allow the service principal application to become active)
    $null = New-AzureADServicePrincipal `
      -AppId $aadApp.AppId `
      -ErrorAction Stop
    
    write-output "-- Created New Service Principal"  
    
 }
catch {

    Write-Output "- Cleanup Actions"
    # remove App if it was created
    if ($aadApp) {
      remove-AzureADApplication -ObjectId $aadApp.ObjectId
      write-output "-- Removed Application"
    }
    
    # Remove KV secret if it got created       
    if ($secretCreatedDetails) {
      $null = Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Force
      Start-Sleep -s 30
      $null = Remove-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -Force -InRemovedState
      write-output "-- Removed KeyVault Secret"
    }
    
    throw  $_.Exception
 }
Finally {
    write-output "- End tasks"
    # Remove KV accessPolicy 
    Remove-AzKeyVaultAccessPolicy  `
      -ResourceGroupName $KeyVaultRG `
      -VaultName $VaultName `
      -ObjectId $ObjectIDWorker
    write-output "-- Removed KVaccess"
 }
  
}
