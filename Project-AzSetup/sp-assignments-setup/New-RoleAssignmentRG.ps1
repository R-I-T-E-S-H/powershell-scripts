 Function New-AADRoleAssignment
{
    Param(
        [Parameter(Mandatory)]
        [string]$AppID,

        [Parameter(Mandatory)]
        [ValidateSet('Reader','Contributor','Owner')]
        [string]$RDN,
        
        [Parameter(Mandatory)]
        [string]$ResourceGroupName

        )



$RoleDefination = New-AzRoleAssignment -ApplicationId $AppID -RoleDefinitionName $RDN -ResourceGroupName $ResourceGroupName

}