$JEARole = JEARole-EUC-Support-Admin-L1
if ((Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators") -eq $False)
{
Write-Output "Creating Directory"
New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators" -ItemType Directory
}
else
{
Write-Output "Directory Already Exists"
}


if ((Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators\$JEARole") -eq $False)
{
Write-Output "Creating Directory"
New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators\$JEARole" -ItemType Directory
New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators\$JEARole\RoleCapabilities" -ItemType Directory
New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators\$JEARole\$JEARole.psd1"
}
else
{
Write-Output "Module Already Exists"
}

#Splatting
$RoleCapabilityCreationParams = @{
Path = "$env:ProgramFiles\WindowsPowerShell\Modules\JEARoleOperators\$JEARole\$JEARole.psrc"
Author = 'Ritesh Grover'
Company = 'HCL'
VisibleCmdlets = 'Restart-Service'
#'get-service', @{Name = 'Restart-Service'; Parameters = @{Name = 'Name'; ValidateSet = 'Spooler'}}
#Add Module and verb
#'get-service', @{Name = 'Restart-Service'; Parameters = @{Name = 'Name'; ValidateSet = 'Spooler'}}, 'NetTCPIP\get-*'
VisibleFunctions = '*-printer*'
VisibleExternalCommands = 'c:\windows\System32\ipconfig.exe'
FunctionDefination = @{ Name = 'Get-UserInfo'; ScriptBlock = { $PSSenderInfo } }
}

New-PSRoleCapabilityFile @RoleCapabilityCreationParams

if ((Test-Path -Path "$env:ProgramData\JEAConfiguration") -eq $False)
{
Write-Output "Creating Directory"
New-Item -Path "$env:ProgramData\JEAConfiguration" -ItemType Directory
}

#Cheak if already exisits
Get-PSSessionConfiguration -Name $JEARole
#Unregister if exisits
Unregister-PSSessionConfiguration -Name $JEARole
Restart-Service winrm


#Session Configuration File
$JEAConfigParam = @{
SessionType = 'RestrictedRemoteServer'
RunAsVirtualAccount = $true
RoleDefinations = @{'Domain\JEA Print Group' = @{ RoleCapabilities = 'PrintOperator' }}
TranscriptDirectory = "$env:ProgramData\JEAConfiguration\Transcripts"
}
New-PSSessionConfigurationFile -Path "$env:ProgramData\JEAConfiguration\JEARole-EUC-Support-Admin-L1.pssc" @JEAConfigParam

#Register the Endpoint
Register-PSSessionConfiguration -Name PrintOperators -Path "$env:ProgramData\JEAConfiguration\JEARole-EUC-Support-Admin-L1.pssc"
Restart-Service winrm

#Check the avaiability of Endpoint
Get-PSSessionConfiguration

#Test & Improve
Enter-PSSession -ComputerName Client -ConfigurationName PrintOperators -Credential 

#Enable Event Logs from Policy
#Check Logsin Event Log
$Events = Get-WinEvent -LogName Microsoft.Windows-WinRM/Operational |
Where-Object {$_.ID -eq 193} | Select-Object -first 10
# Copy Virtual Account
$Events[0]
#Check Other Log
$Events1 = Get-WinEvent -LogName Microsoft.Windows-PowerShell/Operational |
Where-Object {$_.UserID -eq 'ID GUID from Events[0]'}


#Connect to Session
Copy-Item -Path 'C:\JeaDeploy' -Recurse -Destination '\\DCNAME\c$' -Force
Invoke-Command -ComputerName DCNAME -FilePath '\\DCNAME\c$\JeaDeploy\JeaDeploy.ps1'

$nonAdminCred = Get-Credential
$JeaRole = 'JEARole-Support-Admin-L1'
Enter-PSSession -ComputerName DCNAME -ConfigurationName $JeaRole -Credential $nonAdminCred

Copy-Item -Path 'C:\JeaDeploy' -Recurse -Destination '\\DCNAME\c$' -Force
Invoke-Command -ComputerName DCNAME -FilePath '\\DCNAME\c$\JeaDeploy\JeaDeploy.ps1'


Get-PSSessionConfiguration | Select-Object Name
