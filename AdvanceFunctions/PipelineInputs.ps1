#DEMO 1 : Basic Function
Function Get-SomethingBasic
{
    param(
        [string]$Param
    )
    Write-Host $Param
}
Get-SomethingBasic -Param "This is a test parameter for basic functions"

#DEMO 2 : Advance Functions
Function Get-SomethingBasicPipeline
{
    Write-Output 'This'
}

Function Get-SomethingAdvance
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateSet('This','That')]
        [String]$Param
    )
    Write-Host $Param
}

