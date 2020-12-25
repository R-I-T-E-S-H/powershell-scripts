$AzSKModuleRepoPath = "https://azsdkossep.azureedge.net/3.7.0/AzSK.zip"

#Copy module zip to temp location
$CopyFolderPath = $env:temp + "\AzSKTemp\"
if(-not (Test-Path -Path $CopyFolderPath))
{
  mkdir -Path $CopyFolderPath -Force | Out-Null
}
$ModuleFilePath = $CopyFolderPath + "AzSK.zip"           
Invoke-WebRequest -Uri $AzSKModuleRepoPath -OutFile $ModuleFilePath

#Extract zip file to module location
Expand-Archive -Path $ModuleFilePath -DestinationPath "$Env:USERPROFILE\documents\WindowsPowerShell\modules" -Force

#Clean up temp location
Remove-Item –path $CopyFolderPath –recurse

$env:PSModulePath = $env:PSModulePath + ';C:\Users\AB52477\documents\WindowsPowerShell\modules'