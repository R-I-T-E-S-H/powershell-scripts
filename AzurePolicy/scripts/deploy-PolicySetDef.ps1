[CmdLetBinding()]
Param (
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'deployToSub', HelpMessage = 'Specify the file path for the policy initiative definition file.')]
  [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'deployToMG', HelpMessage = 'Specify the file path for the policy initiative definition file.')]
  [ValidateScript({test-path $_})][String]$definitionFile,

  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'deployToSub', HelpMessage = 'Specify hashtable that contains policy definition locations that the script will find and replace from the policy set definition.')]
  [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'deployToMG', HelpMessage = 'Specify hashtable that contains policy definition locations that the script will find and replace from the policy set definition.')]
  [hashtable]$PolicyLocations,

  [Parameter(Mandatory = $true, ParameterSetName = 'deployToSub')]
  [ValidateScript({try {[guid]::parse($_)} catch {$false}})][String]$subscriptionId,

  [Parameter(Mandatory = $true, ParameterSetName = 'deployToMG')]
  [ValidateNotNullOrEmpty()][String]$managementGroupName,

  [Parameter(Mandatory = $false, ParameterSetName = 'deployToSub', HelpMessage = 'Silent mode. When used, no interative prompt for sign in')]
  [Parameter(Mandatory = $false, ParameterSetName = 'deployToMG', HelpMessage = 'Silent mode. When used, no interative prompt for sign in')]
  [Switch]$silent
)

#region functions
Function ProcessAzureSignIn
{
    $null = Connect-AzAccount
    $context = Get-AzContext -ErrorAction Stop
    $Script:currentTenantId = $context.Tenant.Id
    $Script:currentSubId = $context.Subscription.Id
    $Script:currentSubName = $context.Subscription.Name
}

Function DeployPolicySetDefinition
{
    [CmdLetBinding()]
    Param (
      [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'deployToSub')]
      [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'deployToMG')]
      [object]$Definition,
      [Parameter(Mandatory = $true, ParameterSetName = 'deployToSub')][String]$subscriptionId,
      [Parameter(Mandatory = $true, ParameterSetName = 'deployToMG')][String]$managementGroupName
    )
    #Extract from policy definition
    $policySetName = $Definition.name
    $policySetDisplayName = $Definition.properties.displayName
    $policySetDescription = $Definition.properties.description
    $policySetParameters = convertTo-Json -InputObject $Definition.properties.parameters -Depth 15
    $policySetDefinition = convertTo-Json -InputObject $Definition.properties.policyDefinitions -Depth 15
    $policySetMetaData =  convertTo-Json -InputObject $Definition.properties.metadata -Depth 15
    If ($PSCmdlet.ParameterSetName -eq 'deployToSub')
    {
        Write-Verbose "Deploying Policy Initiative '$policySetName' to subscription '$subscriptionId'"
    } else {
        Write-Verbose "Deploying Policy Initiative '$policySetName' to management group '$managementGroupName'"
    }
    
    $deployParams = @{
      Name = $policySetName
      DisplayName = $policySetDisplayName
      Description = $policySetDescription
      Parameter = $policySetParameters
      PolicyDefinition = $policySetDefinition
      Metadata = $policySetMetaData
    }
    Write-Verbose "  - 'DeployPolicySetDefinition' function parameter set name: '$($PSCmdlet.ParameterSetName)'"
    If ($PSCmdlet.ParameterSetName -eq 'deployToSub')
    {
      Write-Verbose "  - Adding SubscriptionId to the input parameters for New-AzPolicySetDefinition cmdlet"
      $deployParams.Add('SubscriptionId', $subscriptionId)
    } else {
      Write-Verbose "  - Adding ManagementGroupName to the input parameters for New-AzPolicySetDefinition cmdlet"
      $deployParams.Add('ManagementGroupName', $managementGroupName)
    }
    Write-Verbose "Initiative Definition:"
    Write-Verbose $policySetDefinition
    $deployResult = New-AzPolicySetDefinition @deployParams
    $deployResult
}
#endregion

#region main
#ensure signed in to Azure
if ($silent)
{
  Write-Verbose "Running script in silent mode."
}
Try
{
    $context = Get-AzContext -ErrorAction SilentlyContinue
    $currentTenantId = $context.Tenant.Id
    $currentSubId = $context.Subscription.Id
    $currentSubName = $context.Subscription.Name
    if ($context -ne $null)
    {
      Write-output "You are currently signed to to tenant '$currentTenantId', subscription '$currentSubName'  using account '$($context.Account.Id).'"
      if (!$silent)
      {
        Write-Output '', "Press any key to continue using current sign-in session or Esc to login using another user account."
        $KeyPress = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        If ($KeyPress.virtualKeyCode -eq 27)
        {
          #sign out first
          Disconnect-AzAccount -AzureContext $context
          #sign in
          ProcessAzureSignIn
        }
      } 
    } else {
      if (!$silent)
      {
        Write-Output '', "You are currently not signed in to Azure. Please sign in from the pop-up window."
        ProcessAzureSignIn
      } else {
        Throw "You are not signed in to Azure!"
      }

    }
} Catch {
    if (!$silent)
    {
      #sign in
      ProcessAzureSignIn
    } else {
      Throw "You are not signed in to Azure!"
    }

}

#Read initiative definition
Write-Verbose "Processing '$definitionFile'..."
$DefFileContent = Get-Content -path $definitionFile -Raw

#replace policy definition resource Ids
If ($PSBoundParameters.ContainsKey('PolicyLocations'))
{
    Write-Verbose "Replacing policy definition locations in the initiative definition file."
    Foreach ($key in $PolicyLocations.Keys)
    {
        $DefFileContent = $DefFileContent.Replace("{$key}", $PolicyLocations.$key)
    }
}
$objDef = Convertfrom-Json -InputObject $DefFileContent

#Validate definition content
If ($objDef.properties.policyDefinitions)
{
    Write-Verbose "'$definitionFile' is a policy initiative definition. It will be deployed."
    $bProceed = $true
} elseif ($objDef.properties.policyRule) {
    Write-Warning "'$definitionFile' contains a policy definition. policy definitions are not supported by this script. please use deploy-policyDef.ps1 to deploy policy definitions."
    $bProceed = $false
} else {
    Write-Error "Unable to parse '$definitionFile'. It is not a policy or initiative definition file. Content unrecognised."
    $bProceed = $false
}

#Deploy definitions
if ($bProceed -eq $true)
{
    $params = @{
        Definition = $objDef
    }
    If ($PSCmdlet.ParameterSetName -eq 'deployToSub')
    {
        $params.Add('subscriptionId', $subscriptionId)
    } else {
        $params.Add('managementGroupName', $managementGroupName)
    }
    $deployResult = DeployPolicySetDefinition @params
}
$deployResult
#endregion
