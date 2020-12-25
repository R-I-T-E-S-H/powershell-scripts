function Set-JeaRoleCapability
{
param ( [string]$JEARole )
if ((Test-Path -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole") -eq $False)
    {
        Write-Output "Creating Directory"
        New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole" -ItemType Directory
        New-Item -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole\RoleCapabilities" -ItemType Directory
        New-ModuleManifest -Path "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole\$JEARole.psd1"
    }
else
    {
        Write-Output "Module Already Exists"
    }

#Splatting
$RoleCapabilityCreationParams = @{
        Path = "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole\RoleCapabilities\$JEARole.psrc"
        Description = 'This role capability exposes basic networking, security, AD, DNS and configuration settings for the local server.'
        Author = 'Ritesh Grover'
        Company = 'HCL'
        VisibleCmdlets = 'Get-Service',
                         'Restart-Service',
                         'Restart-Computer',
                         'Stop-Service',
                         'Start-Service',
                         'Get-Process',
                         'Stop-Process',
                         'Get-Eventlog',
                         'Get-AD*',
                         'Get-WindowsFeature',
                         'Get-HotFix',
                         'Defender\*',
                         'NetAdapter\*',
                         'NetConnection\*',
                         'NetSecurity\Get-*',
                         'NetTCPIP\*',
                         'Clear-DnsClientCache',
                         'Set-DnsClientServerAddress',
                         'Resolve-DnsName',
                         'Get-SystemInfo',
                         'Test-Connection',
                         'Microsoft.PowerShell.LocalAccounts\Get-*',
                         'DnsServer\Get-*'
        VisibleFunctions = 'Get-DNS*','Add-DnsServerResourceRecord*'
        VisibleExternalCommands = 'c:\windows\System32\ipconfig.exe', 'C:\Windows\System32\gpupdate.exe', 'C:\Windows\System32\gpresult.exe'
        FunctionDefinitions = @{ Name = 'Get-UserInfo'; ScriptBlock = { $PSSenderInfo } }
        }
New-PSRoleCapabilityFile @RoleCapabilityCreationParams  

}

function Set-JeaSessionConfiguration
{
param ( [string]$JEARole,
 [string]$JEAGroup)
if ((Test-Path -Path "$env:ProgramData\JEAConfiguration") -eq $False)
    {
        Write-Output "Creating Directory"
        New-Item -Path "$env:ProgramData\JEAConfiguration" -ItemType Directory
    }
#Check if already exists
Try 
{
    $Role = Get-PSSessionConfiguration -Name $JEARole -ErrorAction SilentlyContinue
    if(!$Role)
        {
            $JEAConfigParam = @{
                SessionType = 'RestrictedRemoteServer'
                RunAsVirtualAccount = $true
                RoleDefinitions = @{$JEAGroup = @{ RoleCapabilities = $JEARole }}
                TranscriptDirectory = "$env:ProgramData\JEAConfiguration\Transcripts"
                }
            New-PSSessionConfigurationFile -Path "$env:ProgramData\JEAConfiguration\$JEARole.pssc" @JEAConfigParam
        }
    else
        {
            #Unregister if exists
            Unregister-PSSessionConfiguration -Name $JEARole
            Restart-Service winrm
            $JEAConfigParam = @{
                SessionType = 'RestrictedRemoteServer'
                RunAsVirtualAccount = $true
                RoleDefinitions = @{$JEAGroup = @{ RoleCapabilities = $JEARole } }
                TranscriptDirectory = "$env:ProgramData\JEAConfiguration\Transcripts"
                }
                New-PSSessionConfigurationFile -Path "$env:ProgramData\JEAConfiguration\$JEARole.pssc" @JEAConfigParam
        }
    Register-PSSessionConfiguration -Name $JEARole -Path "$env:ProgramData\JEAConfiguration\$JEARole.pssc"
}
Catch
{
 #Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
 $ErrorMessage =  $_.Exception.Message
}
}
function Create-JEASourceFolder
{
param ( [string]$JEARole )

if ((Test-Path -Path C:\JeaDeploy) -eq $False)
    {
        Write-Output "Creating Directory"
        New-Item -Path C:\JeaDeploy -ItemType Directory
        Copy-Item -Path "C:\ProgramData\JEAConfiguration\$JEARole.pssc" -Destination "C:\JeaDeploy"
        Copy-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$JEARole" -Recurse -Destination "C:\JeaDeploy"
    }
else
{
        Write-host "C:\JEADeploy Folder Already Exists"
}
}
   
        