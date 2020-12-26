
    Function New-AADGroup
{
    [cmdletbinding(
        DefaultParameterSetName='FullGPName'
    )]
    Param(
        [Parameter(
            ParameterSetName='FullGPName',
            Mandatory = $true
        )]
        [String]
        $GPName,

        [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $SubscriptionName,

        [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $Team,

        [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $AppCode,

        [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $RegionCode,

        [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $Enviornment,

       [Parameter(
            ParameterSetName='CustomGPName'
        )]
        [String]
        $GroupType,

        [String]
        $ResourceGroupName

    )
    $PSCmdlet.ParameterSetName


    if(!GPName)
    {        if ($GroupType -eq 'Reader')        {
        $GPN = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_REDR"
        }
        elseif ($GroupType -eq 'Contributor')
        {
        $GPN = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_COTR"        
        }
        elseif ($GroupType -eq 'Owner')
        {
        $GPN = "RBAC_AAD_" + $SubscriptionName.ToUpper() + "-" + $Team.ToUpper() + "-" + $AppCode + "-" + $RegionCode.ToUpper() + "-" + $Enviornment.ToUpper() + "-RG_OWNR"        
        }
    
    }
    else
    {

    $GPN = $GPName
    
    }

$AADGroup = New-AzureADGroup -Description "$GroupType Security Group for $resourceGroupName Resource Group" -DisplayName $GPN -MailEnabled $false -SecurityEnabled $true -MailNickName $GPN
}