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

#DEMO 3 : Error Control and Action
Function New-VirtualMachine
{
    [CmdletBinding()]
    param(
        [string]$vmname
    )

    switch($vmname){
        'MajorErrorVM'{
            Write-Error -Message "Major Error Condition - ERROR"
        }

        'AlreadyExistsVM' {
            Write-Warning -Message "Already Exists - WARNING"
        }

        'DoesNotExistsVM' {
            Write-Verbose -Message "Does Not Exists - VERBOSE"
        }
        'AdvanceIssueVM'{
            $ThatVariable='notright'
            Write-Debug -Message "Testing Advance issue - DEBUG"
        }   
   }

}
#Error Action is controlled by $ErrorActionPreference Variable
#Test Major Error with default $ErrorActionPreference
New-VirtualMachine -vmname MajorErrorVM
#Test Major Error with default $ErrorActionPreference as SilentleyContinue
New-VirtualMachine -vmname MajorErrorVM -ErrorAction SilentlyContinue
#Same preferences are available for Error, Warning, debug, verbose
#Check Debug mode, use SUSPEND MODE as breakpoint for debuging
New-VirtualMachine -vmname advanceissuevm -Debug

#RECOMMENDED FOR PRODUCTION 'make preferences as silentlycontinue and capture he errors,warnings etc in variable use warningvariable
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$VerbosePreference = 'SilentlyContinue'
$DebugPreference = 'SilentlyContinue'

New-VirtualMachine -vmname AlreadyExistsVM -WarningVariable VMAlreadyExists
if($VMAlreadyExists) {
Add-Content -Path 'C:\logfile.log' -Value "WARNING:$VMAlreadyExists"
}

New-VirtualMachine -vmname MajorErrorVM -WarningVariable err
if($err) {
Add-Content -Path 'C:\logfile.log' -Value "Err:$($VMAlreadyExists.Exception.Message)"
}