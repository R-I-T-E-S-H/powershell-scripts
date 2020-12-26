workflow New-ServicePrincipalWithCertificate {

  Param(
    [Parameter(Mandatory = $True)]
    [string]$AppName,
    [Parameter(Mandatory = $True)]
    [string]$VaultName
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

  $AppName = "msd-plt-shr-we-prod-sp30"
  $VaultName = "msd-plt-shr-we-prod-kv"

  try
  {
  $App=Get-AzureADApplication | where{$_.displayname -eq $AppName}
  $SP = Get-AzADServicePrincipal -ApplicationId $App.AppId

  write-output "-- start remove credentials from SPN"
  Remove-AzADSpCredential -DisplayName $SP.DisplayName -Force

  write-output "-- start create new credentials from SPN"
  $newCredential = New-AzADSpCredential -ObjectId $SP.Id

  # Find the ID for the Automation SP, KV RG and build Variables
  $objectIDWorker =  (Get-AzureADServicePrincipal | where{$_.appid -eq (Get-AzContext).account.id}).ObjectID
  $KeyVaultRG = (Get-AzKeyVault -VaultName $VaultName).ResourceGroupName
  $SecretName = $SP.DisplayName + "-Secret"

  $YearsToSecretExpireation = 10
  $Expires = (Get-Date).AddYears($YearsToSecretExpireation).ToUniversalTime()
  $NBF = (Get-Date).ToUniversalTime()
  $contentType = 'txt'

  # create KeyVaultAccessPolicy
  $kvAccessPolicy = Set-AzKeyVaultAccessPolicy `
      -ResourceGroupName $KeyVaultRG `
      -VaultName $VaultName `
      -ObjectId $ObjectIDWorker  `
      -PermissionsToSecrets Get, List, Set, Purge, Delete `
      -ErrorAction Stop 
  write-output "-- Set KV Access Policy"
    
  #check if the secret already exists
  $doesSecretExist = Get-AzKeyVaultSecret -VaultName $VaultName  -Name $SecretName -ErrorAction SilentlyContinue
  if (!$doesSecretExist)
  {
  write-output "-- No Secret Exists with name $SecretName "
  }
  else
  {
  # Create a KeyVault Secret
  $secretCreatedDetails = Set-AzKeyVaultSecret `
        -VaultName $VaultName `
        -Name $SecretName `
        -SecretValue $newCredential.Secret  `
        -Expires $Expires `
        -NotBefore $NBF `
        -ContentType $ContentType `
        -ErrorAction Stop
      
  write-output "-- Created KeyVault Access Policy and Secret" 
  }
 }
 catch
 {
  throw  $_.Exception
 }
 finally
 {
     write-output "- End tasks"
    # Remove KV accessPolicy 
    Remove-AzKeyVaultAccessPolicy  `
      -ResourceGroupName $KeyVaultRG `
      -VaultName $VaultName `
      -ObjectId $ObjectIDWorker
    write-output "-- Removed KVaccess"
 }
  
  Get-AzADServicePrincipalCredential -ObjectId d4724e9c-6529-4507-a438-cda5a74c2d5c
  

  }