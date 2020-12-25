#$JEARole = 'JEARole-Support-Admin-L1'
#Check & Copy Session Configuration
function New-JeaDeploy
{
param ( [string]$JEARole )
if ((Test-Path -Path "$env:ProgramData\JEAConfiguration") -eq $False)
    {
        Write-Output "Creating JEA Configuration Directory"
        New-Item -Path "$env:ProgramData\JEAConfiguration" -ItemType Directory
        Copy-Item -Path "C:\JeaDeploy\$JEARole.pssc" -Destination 'C:\ProgramData\JEAConfiguration'
    }
else
    {
        Write-Output "JEA Configuration Directory Already Exists"
    }

#Check & Copy Role Capability and Modules
if ((Test-Path -Path "C:\Program Files\WindowsPowerShell\Modules\$JEARole") -eq $False)
    {
    #New-Item -Path "C:\Program Files\WindowsPowerShell\Modules\$JEARole" -ItemType Directory
    Copy-Item -Path "C:\JeaDeploy\$JEARole" -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules"
      }
else
    {
        Write-Output "JEA Role Capability and Modules Already Exists"
    }

#Register the Endpoint
$Role = Get-PSSessionConfiguration -Name $JEARole -ErrorAction SilentlyContinue
    if(!$Role)
        {
            Register-PSSessionConfiguration -Name $JEARole
        }
    else
        {
            #Unregister if exists
            Unregister-PSSessionConfiguration -Name $JEARole
            Restart-Service winrm
            Register-PSSessionConfiguration -Name $JEARole -Path "C:\ProgramData\JEAConfiguration\$JEARole.pssc"
        }
        }

        New-JeaDeploy -JEARole JEARole-Support-Admin-L1