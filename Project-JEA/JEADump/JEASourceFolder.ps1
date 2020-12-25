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