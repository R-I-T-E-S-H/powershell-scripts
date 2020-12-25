setup-Jea -JEARole <> -JEAGroup <>
deploy-jea -RemoteComputer <>

Invoke-Command -ComputerName $RemoteComputer -FilePath "\\$RemoteComputer\c$\JeaDeploy\JeaDeploy.ps1" -ArgumentList $JEARole

$nonAdminCred = Get-Credential
$JeaRole = 'JEARole-Support-Admin-L1'
Enter-PSSession -ComputerName localhost -ConfigurationName $JeaRole -Credential $c

Get-PSSessionConfiguration | Select-Object Name
get-pssessionconfiguration -name 'JEARole-Support-Admin-L1'