workflow New-ServicePrincipalWithCertificate {
  #inspired by:     # https://winterdom.com/2017/08/28/azure-ad-service-principal-with-keyvault-cert

  Param(

    [Parameter(Mandatory = $false)]
    [string]$spType = 'runAs',
    [Parameter(Mandatory = $false)]
    [string]$automationAccount,
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
    $VaultName,
    [Parameter(Mandatory = $false)]
    $SecretName,
    [Parameter(Mandatory = $false)]
    $ApplicationCode,
    [Parameter(Mandatory = $false)]
    $Description
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

  # variables
  if (!$VaultName) {
    $VaultName = $SubscriptionCode.ToLower() + "-" + $Team.ToLower() + "-shr-" + $Rcode.ToLower() + "-" + $ENV.ToUpper() + "-kv"
  }


  $KvRG = (Get-AzKeyVault -VaultName $VaultName).ResourceGroupName
  #$resourceGroup = (Get-AzureRmResource -ResourceName $vaultName).ResourceGroupName

  function New-KVCertificate {
    param(
      [Parameter(Mandatory = $true)]
      [string]$SPName,
      [Parameter(Mandatory = $true)]
      [string]$ENV,
      [Parameter(Mandatory = $true)]
      [string]$VaultName,
      [Parameter(Mandatory = $true)]
      [string]$KvRG
    )

    #function Varialbes
    $certificateName = $SPName + '-Cert'
    $subjectName = "cn=" + $certificateName
    $objectIDWorker = (Get-AzureADServicePrincipal -ApplicationId (Get-AzContext).account.id).Id.Guid
  
    try {
      #-- Granting SP access to KeyVault'
      $null = Set-AzKeyVaultAccessPolicy `
        -ResourceGroupName $resourceGroup `
        -VaultName  $vaultName `
        -ObjectId $objectIDWorker `
        -PermissionsToCertificates create, list, delete, get, purge `
        -PermissionsToSecrets list, get `
        -ErrorAction Stop
      #get,list,set,delete,backup,restore,recover,purg
      
      #-- Generate certificate policy'
      $policy = New-AzKeyVaultCertificatePolicy -SecretContentType "application/x-pkcs12" `
        -SubjectName $subjectName `
        -IssuerName Self `
        -ValidityInMonths 12 `
        -ReuseKeyOnRenewal `
        -ErrorAction Stop
      
      $doesCertExist = Get-AzKeyVaultCertificate `
        -VaultName $vaultName `
        -Name $certificateName `
        -ErrorAction SilentlyContinue

      if ($doesCertExist) {
        #remove existing certificate
        $null = remove-AzKeyVaultCertificate `
          -VaultName $vaultName `
          -Name $certificateName `
          -confirm:$false -Force
          
        Start-Sleep -Seconds 30

        # purge certificate from softDelete state
        $null = remove-AzKeyVaultCertificate `
          -VaultName $vaultName `
          -Name $certificateName `
          -InRemovedState -confirm:$false -force
          
        Start-Sleep -Seconds 30
      }

      #-- Creating a new Certificate, sleep untill completed'
      $creating = Add-AzKeyVaultCertificate `
        -VaultName $vaultName `
        -Name $certificateName `
        -CertificatePolicy $policy `
        -ErrorAction stop
      
      while ( $creating.Status -ne 'completed' ) {
        Start-Sleep -Seconds 1
        $creating = Get-AzKeyVaultCertificateOperation `
          -VaultName $vaultName `
          -Name $certificateName `
          -ErrorAction Stop
      }

      #return values
      [hashtable]$returnParams = @{}
      $returnParams.certificateName = $certificateName
      $returnParams.vaultName = $vaultName
      $returnParams.ObjectIDWorker = $ObjectIDWorker
      $returnParams.resourceGroup = $resourceGroup

      return $returnParams
    }
    catch {
      throw $_
    }
    finally {}
  }
  function New-AADappCertificateCredential {
    param(
      [Parameter(Mandatory = $true)]
      [string]$SPName,
      [Parameter(Mandatory = $true)]
      [string]$CertificateName,
      [Parameter(Mandatory = $true)]
      [string]$VaultName,
      [Parameter(Mandatory = $true)]
      [string]$Password,
      [Parameter(Mandatory = $true)]
      $homePage,
      [Parameter(Mandatory = $true)]
      $identifierUris,
      [Parameter(Mandatory = $true)]
      $applicationId
    )      
    try {
      #-- Extracting certificate details'
      $pfxCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".pfx")
      $pfxCertPlainPasswordForRunAsAccount = $Password
      $cerCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".cer")

      $secretRetrieved = Get-AzureKeyVaultSecret -VaultName $VaultName -Name $CertificateName
      $pfxBytes = [System.Convert]::FromBase64String($secretRetrieved.SecretValueText)
      $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
      $certCollection.Import($pfxBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        
      #Export  the .pfx file 
      $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $pfxCertPlainPasswordForRunAsAccount)
      [System.IO.File]::WriteAllBytes($pfxCertPathForRunAsAccount, $protectedCertificateBytes)
      
      #Export the .cer file 
      $cert = Get-AzureKeyVaultCertificate -VaultName $VaultName -Name $CertificateName
      $certBytes = $cert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
      [System.IO.File]::WriteAllBytes($CerCertPathForRunAsAccount, $certBytes)

      # retreive the cert details
      $pfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($pfxCertPathForRunAsAccount, $PfxCertPlainPasswordForRunAsAccount)
      $keyValue = [System.Convert]::ToBase64String($PfxCert.GetRawCertData())
      
      $startDate = Get-Date
      $endDate = (Get-Date $pfxCert.GetExpirationDateString()).AddDays(-1)
    
      #-- Creating new service principal credential'
      $SPDetails = New-AzureRmADAppCredential -ApplicationId $ApplicationId `
        -CertValue $keyValue `
        -StartDate $startDate `
        -EndDate $endDate `
        -ErrorAction Stop
      
      #return values
      [hashtable]$returnParams = @{}
      $returnParams.PfxCertPlainPasswordForRunAsAccount = $PfxCertPlainPasswordForRunAsAccount
      $returnParams.PfxCertPathForRunAsAccount = $pfxCertPathForRunAsAccount
      $returnParams.PfxCertThumbprint = $pfxCert.Thumbprint
  
      return $returnParams
    }
    catch {
      throw $_
    }
    finally {}
  }
  function Remove-CertificateFromKV {
    param(
      [Parameter(Mandatory = $true)]
      [string]$certName,
      [Parameter(Mandatory = $true)]
      [string]$vaultName
    )
    
    $doesCertExist = Get-AzureKeyVaultCertificate -VaultName $vaultName -Name $certName -ErrorAction SilentlyContinue
    
    # remove certificate
    try {
      if ($doesCertExist) {
        #remove existing certificate
        $null = remove-AzKeyVaultCertificate -VaultName $vaultName -Name $certName -confirm:$false -Force
        Start-Sleep -Seconds 30

        # purge certificate from softDelete state
        $null = remove-AzKeyVaultCertificate -VaultName $vaultName -Name $certName -InRemovedState -confirm:$false -force
        Start-Sleep -Seconds 30
      }
    }
    catch {
      throw $_.Exception
    }
  }
  function Remove-KVaccessPolicy {
    param(
      [Parameter(Mandatory = $true)]
      [string]$ObjectId,
      [Parameter(Mandatory = $true)]
      [string]$VaultName
    )

    # delete access to KV
    try {
      $resourceGroup = (Get-AzResource -ResourceName $vaultName).ResourceGroupName
      remove-AzKeyVaultAccessPolicy `
        -ResourceGroupName $ResourceGroup `
        -VaultName  $vaultName `
        -ObjectId $ObjectId
    }
    catch {
      throw $_.Exception
    }
  }
 
  # Variables
  if ($SPName -eq '') {
    if ($spType -eq 'runAs') {
      $SPName = $automationAccount + '-SP'
    }
    elseif ($spType -eq 'application') {
       $SPName = $SubscriptionCode.ToLower() + "-" + $Team.ToUpper() + "-" + $ApplicationCode.ToLower() + "-" + $Rcode.ToUpper() + "-" + $Description.ToLower() + "-SP"
    }
  }
  
  $homePage = "http://" + $SPName
  $IdentifierUris = $homePage 
    
  #create
  try {
    #-- Creating new Azure AD application
    $AadApp = New-AzureADApplication `
      -DisplayName $SPName `
      -HomePage $homePage `
      -IdentifierUris $IdentifierUris `
      -ErrorAction Stop
  
    # Create Password
    $PfxCertPlainPasswordForSP = New-ComplexPassWord -ErrorAction Stop

    # Create self Signet certificate
    $certDetails = New-KVCertificate `
      -spName $SPName `
      -env $ENV `
      -VaultName $VaultName `
      -KvRG $KvRG `
      -ErrorAction stop

    # Create new aad App Credential
    $appCredentialDetails = New-AADappCertificateCredential `
      -SPName $SPName `
      -CertificateName $certDetails.certificateName `
      -VaultName $certDetails.vaultName `
      -Password $PfxCertPlainPasswordForSP `
      -homePage $homePage `
      -identifierUris $identifierUris `
      -application $AadApp.ApplicationId.guid `
      -ErrorAction Stop
    
    # -- Creating new service principal
    $null = New-AzureADServicePrincipal `
      -ApplicationId $Aadapp.ApplicationId.guid `
      -ErrorAction Stop
    
    # remove cert from KV
    $null = Remove-CertificateFromKV `
      -certName  $certDetails.certificateName `
      -vaultName $certDetails.VaultName `
      -ErrorAction Stop

    # remove acces policy IN kv
    $null = Remove-KVaccessPolicy `
      -ObjectId $certDetails.ObjectIDWorker `
      -vaultName $certDetails.VaultName `
      -ErrorAction Stop  
      
    # return values
    $returnParams = InlineScript {
      [hashtable]$returnvalues = @{}
      $returnvalues.spName = $using:SpName
      $returnvalues.AppObjectId = $using:Aadapp.ApplicationId.guid
      $returnvalues.VaultName = $using:VaultName
      $returnvalues.CertificateName = $using:certDetails.CertificateName
      $returnvalues.PfxCertPlainPasswordForRunAsAccount = $using:PfxCertPlainPasswordForSP
      $returnvalues.PfxCertPathForRunAsAccount = $using:appCredentialDetails.pfxCertPathForRunAsAccount
      $returnvalues.PfxCertThumbprint = $using:appCredentialDetails.PfxCertThumbprint
      $returnvalues.ObjectIdWorker = $using:certDetails.ObjectIDWorker
  
      return $returnvalues
    }

    return $returnParams
  }
  catch {
    if ($Aadapp) {
      remove-AzureADApplication -ObjectId $Aadapp.ObjectId.guid
    }
    $err = $_
    write-output   $err
    write-output 'failed'
  }
  finally {
    if ($certDetails) {
      # Remove KV accessPolicy 
      Remove-AzKeyVaultAccessPolicy `
        -ResourceGroupName $certDetails.resourceGroup `
        -VaultName  $certDetails.vaultName `
        -ObjectId $certDetails.ObjectIDWorker `
        -ErrorAction Stop
    }
  }
}