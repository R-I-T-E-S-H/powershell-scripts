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

function Set-JeaRoleCapability01
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

function Set-JeaRoleCapability02
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

function Setup-Jea
{
<#
.SYNOPSIS
    This Function is used to create JEA Role defination and JEA Session Configuration for given Role and Group on local System

.DESCRIPTION
    Function creates Role capability file with extension .psrc under "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole\RoleCapabilities\" folder
    Function creates Session configuration file with extension .pssc under "$env:ProgramData\JEAConfiguration\" folder
    Function creates local folder on C drive with name JEADeploy and copy files as mentioned below
    C:\JeaDeploy\<RoleName>\RoleCapabilities\<RoleName>.psrc
    C:\JeaDeploy\<RoleName>\<RoleName>.psd1
    C:\JeaDeploy\<RoleName>\JEADeploy.ps1
    C:\JeaDeploy\<RoleName>\<RoleName>.pssc

.PARAMETER JEARole
    JEARole parameter is used to define / create role defination for mentioned role. JEARole is a mandatory parameter with below mentioned available Options
    JEARole-Support-Admin-L1
    JEARole-AD-Support-Admin-L2*
    JEARole-AD-Support-Admin-L3*

.PARAMETER JEAGroup
    JEAGroup parameter is used to define / create role defination and assign permission to mentioned group

.EXAMPLE
    PS> Setup-Jea -JEARole JEARole-Support-Admin-L1 -JEAGroup DRF01\JEARole-Support-Admin-L1

.NOTES

.LINK
    https://blogs.technet.microsoft.com/miriamxyra/2018/05/10/securing-your-infrastructure-with-just-enough-administration/
#>

[CmdletBinding()]
param([Parameter( Mandatory = $true
                  )] [ValidateSet ("JEARole-Support-Admin-L1","JEARole-AD-Support-Admin-L2","JEARole-AD-Support-Admin-L3")][string]$JEARole,
      [Parameter( Mandatory = $true )] [string]$JEAGroup ) 

if($JEARole -eq 'JEARole-Support-Admin-L1')
    {
    set-JeaRoleCapability -JEARole $JEARole
    set-JeaSessionConfiguration -JEARole $JEARole -JEAGroup $JEAGroup
    Create-JEASourceFolder -JEARole $JEARole
    copy JEADeploy.ps1 c:\JEADeploy\
    }
    <#
elseif($JEARole -eq 'JEARole-AD-Support-Admin-L2')
    {
    set-JeaRoleCapability01 -JEARole $JEARole
    set-JeaSessionConfiguration -JEARole $JEARole -JEAGroup $JEAGroup
    Create-JEASourceFolder -JEARole $JEARole
    copy JEADeploy.ps1 c:\JEADeploy\
    }
elseif($JEARole -eq 'JEARole-AD-Support-Admin-L3')
    {
    set-JeaRoleCapability02 -JEARole $JEARole
    set-JeaSessionConfiguration -JEARole $JEARole -JEAGroup $JEAGroup
    Create-JEASourceFolder -JEARole $JEARole
    copy JEADeploy.ps1 c:\JEADeploy\
    }
    #>
else
{
Write-Host "Feature is under development"
}

}

Function Deploy-Jea
{
param ([string]$RemoteComputer,
[string]$JEARole)
 Copy-Item -Path 'C:\JEADeploy' -Recurse -Destination "\\$RemoteComputer\c$\folder1" -Force
 Invoke-Command -ComputerName $RemoteComputer -FilePath "\\$RemoteComputer\c$\JeaDeploy\JeaDeploy.ps1" -ArgumentList $JEARole
}
   
