workflow New-AutomationRunasAccount {
  Param(
    [Parameter(Mandatory = $true)]
    [string]$automationAccount,
    [Parameter(Mandatory = $true)]
    [string]$env,
    [Parameter(Mandatory = $true)]
    [string]$Team 
  )
  
  #Write-Output "-- Logging in to Azure"
  $Conn = Get-AutomationConnection -Name AzureRunAsConnection
  $null = Add-AzAccount `
    -ServicePrincipal `
    -Tenant $Conn.TenantID `
    -ApplicationId $Conn.ApplicationID `
    -CertificateThumbprint $Conn.CertificateThumbprint

  $null = Connect-AzureAD  `
    -TenantId $Conn.TenantID    `
    -ApplicationId  $Conn.ApplicationID  `
    -CertificateThumbprint $Conn.CertificateThumbprint `

  #Write-Output "-- Getting Subscription information"

  #region FUNCTIONS
  function Set-SPRBACrole {
    param(
      [Parameter(Mandatory = $true)]
      [string]$automationSP,
      [Parameter(Mandatory = $true)]
      [string] $ResourceGroupName,
      [Parameter(Mandatory = $true)]
      [string]$automationAccount,
      [Parameter(Mandatory = $false)]
      [string]$rbacRole = 'contributor'
    )
    try {
      $null = New-AzRoleAssignment `
        -RoleDefinitionName $rbacRole `
        -ServicePrincipalName $automationSP `
        -ResourceGroupName $ResourceGroupName `
        -ResourceName $automationAccount `
        -ResourceType "Microsoft.Automation/automationAccounts" `
        -ErrorAction Stop
    }
    catch {
      throw $_
    }
  }
  function New-AutomationRunAs {
    param(
      [Parameter(Mandatory = $true)]
      [string]$ResourceGroup,
      [Parameter(Mandatory = $true)]
      [string]$AutomationAccountName,
      [Parameter(Mandatory = $true)]
      [string]$ApplicationId,
      [Parameter(Mandatory = $true)]
      [string]$PfxCertThumbprint,
      [Parameter(Mandatory = $true)]
      [string]$PfxCertPlainPasswordForRunAsAccount,
      [Parameter(Mandatory = $true)]
      [string]$PfxCertPathForRunAsAccount
    )
    # connection asset variables
    $ConnectionTypeName = "AzureServicePrincipal"
    $ConnectionAssetName = "AzureRunAsConnection"
    $CertifcateAssetName = "AzureRunAsCertificate"
    $SubscriptionInfo = Get-AzSubscription
    $ConnectionFieldValues = @{"ApplicationId" = $ApplicationID; "TenantId" = $SubscriptionInfo.tenantid; "CertificateThumbprint" = $PfxCertThumbprint; "SubscriptionId" = $SubscriptionInfo.id} 
 
    try {
      #-- Creating Certificate in the Asset'
      $CertPassword = ConvertTo-SecureString $PfxCertPlainPasswordForRunAsAccount -AsPlainText -Force   
      $null = Remove-AzAutomationCertificate -ResourceGroupName $ResourceGroup `
        -automationAccountName $AutomationAccountName `
        -Name $certifcateAssetName `
        -ErrorAction SilentlyContinue


      $null = New-AzAutomationCertificate `
        -ResourceGroupName $ResourceGroup `
        -automationAccountName $AutomationAccountName `
        -Path $PfxCertPathForRunAsAccount `
        -Name $certifcateAssetName `
        -Password $CertPassword `
        -ErrorAction Stop
    
      #-- Creating Connection Asset'
      $null = Remove-AzAutomationConnection `
        -ResourceGroupName $ResourceGroup `
        -automationAccountName $AutomationAccountName `
        -Name $connectionAssetName `
        -Force `
        -ErrorAction silentlyContinue
    
      # create connection asset
      New-AzAutomationConnection `
        -ResourceGroupName $ResourceGroup `
        -automationAccountName $AutomationAccountName `
        -Name $connectionAssetName `
        -ConnectionTypeName $connectionTypeName `
        -ConnectionFieldValues $connectionFieldValues `
        -ErrorAction Stop
    }
    catch {
      throw $_
    }
  }
  #endregion

  #--- Variables ---#
  $spRoleType = 'runAs'
  $ResourceGroupName = (Get-AzResource -ResourceName $automationAccount).ResourceGroupName
 
  try {
    # create SP with certificate
    $newSPwCert = New-ServicePrincipalWithCertificate `
      -ENV $ENV `
      -Team $Team `
      -spType $spRoleType `
      -automationAccount $automationAccount
    
    # set permissions for the SP on the auomation account
    $null = Set-SPRBACrole `
      -automationSP $newSPwCert.AppObjectId `
      -automationAccount $automationAccount `
      -ResourceGroupName $ResourceGroupName
    

    # Create runAs Account

    $null = New-AutomationRunAs `
      -ResourceGroup  $ResourceGroupName `
      -AutomationAccountName $automationAccount `
      -ApplicationId $newSPwCert.AppObjectId `
      -PfxCertThumbprint $newSPwCert.PfxCertThumbprint `
      -PfxCertPlainPasswordForRunAsAccount $newSPwCert.PfxCertPlainPasswordForRunAsAccount `
      -PfxCertPathForRunAsAccount $newSPwCert.PfxCertPathForRunAsAccount
    
    # return values
    $returnParams = InlineScript {
      [hashtable] $returnvalues = @{}
      $returnvalues.spName = $using:newSPwCert.SpName
      $returnvalues.AppObjectId = $using:newSPwCert.AppObjectId
      
      return $returnvalues
    }
    return  $returnParams
  }
  catch {
    throw $_
  }
}