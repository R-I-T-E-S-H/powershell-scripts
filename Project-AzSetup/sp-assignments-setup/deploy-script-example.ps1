Connect-AzAccount
Connect-AzureAD
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

write-output "Started" 
    #function Varialbes
    $certificateName = $SPName + '-Cert'
    $subjectName = "cn=" + $certificateName
    #$objectIDWorker =  (Get-AzureADServicePrincipal | where{$_.appid -eq (Get-AzContext).account.id}).ObjectID
    $ObjID = ((Get-AzContext).account.id)
    #$objectIDWorker = (Get-AzureADUser | where{$_.userprincipalname -eq 
    $objectIDWorker = (get-azureaduser -Filter "startswith(userprincipalname,'$ObjID')").objectID
  
    try {
    # write-output "Granting SP access to KeyVault" 
    #  $null = Set-AzKeyVaultAccessPolicy `
    #    -ResourceGroupName $KvRG `
    #    -VaultName  $vaultName `
    #    -ObjectId $objectIDWorker `
    #    -PermissionsToCertificates create, list, delete, get, purge `
    #    -PermissionsToSecrets list, get `
    #    -ErrorAction Stop 
    #  #get,list,set,delete,backup,restore,recover,purg
      
      write-output "Generate certificate policy"
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
         write-output "remove existing certificate"
        $null = remove-AzKeyVaultCertificate `
          -VaultName $vaultName `
          -Name $certificateName `
          -confirm:$false -Force
          
        Start-Sleep -Seconds 30

         write-output "purge certificate from softDelete state"
        $null = remove-AzKeyVaultCertificate `
          -VaultName $vaultName `
          -Name $certificateName `
          -InRemovedState -confirm:$false -force
          
        Start-Sleep -Seconds 30
      }

       write-output "Creating a new Certificate, sleep untill completed"
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
      $returnParams.resourceGroup = $KvRG

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
      write-output "Extracting certificate details"
      $pfxCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".pfx")
      $pfxCertPlainPasswordForRunAsAccount = $Password
      $cerCertPathForRunAsAccount = Join-Path $env:TEMP ($CertificateName + ".cer")

      $secretRetrieved = Get-AzKeyVaultSecret -VaultName $VaultName -Name $CertificateName
      $pfxBytes = [System.Convert]::FromBase64String($secretRetrieved.SecretValueText)
      $certCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
      $certCollection.Import($pfxBytes, $null, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
        
      write-output "Export  the .pfx file" 
      $protectedCertificateBytes = $certCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $pfxCertPlainPasswordForRunAsAccount)
      [System.IO.File]::WriteAllBytes($pfxCertPathForRunAsAccount, $protectedCertificateBytes)
      
      write-output "Export the .cer file"
      $cert = Get-AzKeyVaultCertificate -VaultName $VaultName -Name $CertificateName
      $certBytes = $cert.Certificate.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
      [System.IO.File]::WriteAllBytes($CerCertPathForRunAsAccount, $certBytes)

      write-output "retreive the cert details"
      $pfxCert = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList @($pfxCertPathForRunAsAccount, $PfxCertPlainPasswordForRunAsAccount)
      $keyValue = [System.Convert]::ToBase64String($PfxCert.GetCertHash())
      
      $startDate = Get-Date
      $endDate = (Get-Date $pfxCert.GetExpirationDateString()).AddDays(-1)
    
      write-output "Creating new service principal credential"
      $SPDetails = New-AzureADApplicationKeyCredential -ObjectId $applicationId `
       -Value $keyValue `
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
  
  

  $SubID = "XXX"
  $TennantID = "XXXXX"
  $VaultName = "XXX"
  $SPName = "XXXX"
  $AppObjectID = "XXXXX"
  $ENV = "XXX"

  $KvRG = (Get-AzKeyVault -VaultName $VaultName).ResourceGroupName    
  $AadApp = Get-AzureADApplication -ObjectId $AppObjectID
  $homePage = "http://" + $SPName
  $IdentifierUris = $homePage 

      # Create Password
    write-output "Create Password"
    $PfxCertPlainPasswordForSP = New-ComplexPassWord -ErrorAction Stop

    # Create self Signe certificate
    write-output "Create self Signet certificate"   
    $certDetails = New-KVCertificate `
      -spName $SPName `
      -env $ENV `
      -VaultName $VaultName `
      -KvRG $KvRG `
      -ErrorAction stop

    # Create new aad App Credential
    write-output "Create new aad App Credential"
    $appCredentialDetails = New-AADappCertificateCredential `
      -SPName $SPName `
      -CertificateName $certDetails.certificateName `
      -VaultName $certDetails.vaultName `
      -Password $PfxCertPlainPasswordForSP `
      -homePage $homePage `
      -identifierUris $identifierUris `
      -ApplicationId $AadApp.ObjectId `
      -ErrorAction Stop