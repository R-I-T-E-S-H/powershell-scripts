


function NetWorkSetup() {
    # $env:http_proxy = "http://webguard.gjensidige.no:8080"
    # $env:https_proxy = "http://webguard.gjensidige.no:8080"
    $proxyString = "http://139.112.164.43:8080/"
    $proxyUri = new-object System.Uri($proxyString)
    [System.Net.WebRequest]::DefaultWebProxy = new-object System.Net.WebProxy ($proxyUri, $true)
    [system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
}


function LoginUsingCertificate {
    param(
        [Parameter(ParameterSetName = "Environment", Mandatory = $true)]
        $Env,
        [Parameter(ParameterSetName = "ConfigFile", Mandatory = $true)]
        $ConfigFile,
        [Parameter(ParameterSetName = "CertDetails", Mandatory = $true)]
        $TenantId,
        [Parameter(ParameterSetName = "CertDetails", Mandatory = $true)]
        $ApplicationId,
        [Parameter(ParameterSetName = "CertDetails", Mandatory = $true)]
        $CertSubject
    )
    NetWorkSetup
    LogOut
    $cert = Get-ChildItem cert:\CurrentUser\My\ | Where-Object {$_.Subject -match $CertSubject }

    if ($Env -ne $null) {
        Write-Output "Reading config from file: ..\config-$Env.json"
        $config = Read-Config -ConfigFilePath "..\config-$Env.json"
        $TenantId = $config.Subscription.TenantId
        $ApplicationId = $config.Subscription.ServicePrincipal.ApplicationId
        $CertSubject = $config.Subscription.ServicePrincipal.CertSubject

    }
    elseif ($ConfigFile -ne $null) {
        Write-Output "Reading config from file: ..\$ConfigFile"
        $config = Read-Config -ConfigFilePath "..\$ConfigFile"
        $TenantId = $config.Subscription.TenantId
        $ApplicationId = $config.Subscription.ServicePrincipal.ApplicationId
        $CertSubject = $config.Subscription.ServicePrincipal.CertSubject

    }

    Connect-AzAccount -ServicePrincipal `
        -CertificateThumbprint $cert.Thumbprint `
        -ApplicationId $ApplicationId `
        -TenantId $TenantId

    # Connect-AzureAD -TenantId $TenantId   `
    #     -ApplicationId  $ApplicationId `
    #     -CertificateThumbprint $cert.Thumbprint  

}

function LogOut() {
    try {
        Disconnect-AzAccount -ErrorAction SilentlyContinue
        # Disconnect-AzureAD -ErrorAction SilentlyContinue
    }
    catch {
        #do nothing
    }
}


function LoginUsingCredentials {
    param(
        [Parameter(Mandatory = $false)]
        $DirectoryId,
        [Parameter(Mandatory = $false)]
        $UserName,
        [Parameter(Mandatory = $false)]
        $adfs = $false
    )

   
    LogOut
    if ($adfs -eq $true) {
        Write-Output "A windows will open to log user into Azure AD - Login does not work with guest accounts"
        Connect-AzAccount
        Connect-AzureAD
    }
    else {
        # Login to Azure
        if ($UserName -ne $null) {
            $Credential = Get-Credential -UserName $UserName -Message "Using predefined username"
        }
        else {
            $Credential = Get-Credential 
        }

        if ($DirectoryId -ne $null ) {
            #Connect-AzureAD -TenantId $DirectoryId
            Connect-AzureAD -TenantId $DirectoryId -Credential $Credential
            $account = Connect-AzAccount -TenantId $DirectoryId -Credential $Credential
        }
        else {
            Add-AzureRmAccount  -Credential $Credential
            $account = Connect-AzureAD -Credential $Credential
        
            #Add-AzureRmAccount
        } 
    }
    Return $account
}
 

function LoginUsingADFSCredentials {
    param(
        [Parameter(Mandatory = $false)]
        $DirectoryId
    )

    Write-Output "A multiple windows will open to log user into Azure AD - Login does not work with guest accounts"
    Set-AzureRmContext -Context ([Microsoft.Azure.Commands.Profile.Models.PSAzureContext]::new())
      
    if ($DirectoryId -ne $null ) {
        #Connect-AzureAD -TenantId $DirectoryId
        Connect-AzureAD -TenantId $DirectoryId 
        Login-AzureRmAccount -TenantId $DirectoryId 
    }
    else {
        Add-AzureRmAccount  
        Connect-AzureAD
        
        #Add-AzureRmAccount
    } 
 
}