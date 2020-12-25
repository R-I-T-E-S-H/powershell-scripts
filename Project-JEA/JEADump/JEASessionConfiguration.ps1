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