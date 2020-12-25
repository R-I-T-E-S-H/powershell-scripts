#ParameterSetName can be used to use either value at one point of time
Function Get-NewVirtualMachine
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ParameterSetName= 'ByVMName')]
        [string]$vmname,

        [Parameter(Mandatory,ParameterSetName= 'ByID')]
        [string]$ID
        )

        if($PSCmdlet.ParameterSetName -eq 'ByName')
        {
            Write-host "This is used when vmname parameter is passed"
        }
        elseif($PSCmdlet.ParameterSetName -eq 'ByID')
        {
            Write-host "This is used when ID parameter is passed"
        }
}