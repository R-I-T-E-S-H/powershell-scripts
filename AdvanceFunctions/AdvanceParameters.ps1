Function Get-NewVirtualMachine
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$vmname
    )
}

#Parameter Validations

#DEMO 1 : Validation Script (Used to validate output true or false)

Function Get-NewVirtualMachine
{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$vmname,

        [Parameter()]
        [ValidateSet('5','11')]
        [int]$generation,
      
        [Parameter()]
        [ValidateRange(512MB,1024MB)]
        [int]$Memory,

        [Parameter()]
        [ValidateCount(1,3)]
        [string[]]$NICName,
        
        [Parameter()]
        [ValidateScript({Test-Path -path $_ -PathType Container})] #Use leaf for file validation
        [ValidatePattern('^C:\\')]
        [string]$path,

        [Parameter()]
        [ValidateScript({
            if(-not (Test-Path -path $_ -PathType Container))
            {
                throw "The folder [$_] does not exists. Try another"
            }
            else
            {
                $true
            }
        })]
        [ValidatePattern('^C:\\')]  # 'C:\somefolder' -match '^C:\\'
        [string]$path1,


        [Parameter()]
        [ValidateScript({
            if(Test-Connection -Computername $_ -Quiet -count 1)
            {
                throw "The Computer  [$_] is offline. Try another"
            }
            else
            {
                $true
            }
        })]

        [string]$Computer
    )
}