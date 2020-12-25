
## Steps
```sh
1.	Run script JeaFunctions.ps1
2.	Run Setup-Jea -JEARole JEARole-Support-Admin-L1 -JEAGroup DRF01\JEARole-Support-Admin-L1 
3.	This will expose endpoint with name JEARole-Support-Admin-L1 with permission to <domainname>\JEARole-Support-Admin-L1
4.	Connect endpoint from Management server  Enter-PSSession -ComputerName <computername> -ConfigurationName JEARole-Support-Admin-L1
```

Note : The help has been inbuild into the module

## Script performs the below actions
```sh
Function creates Role capability file with extension .psrc under "$env:ProgramFiles\WindowsPowerShell\Modules\$JEARole\RoleCapabilities\" folder
Function creates Session configuration file with extension .pssc under "$env:ProgramData\JEAConfiguration\" folder
Function creates local folder on C drive with name JEADeploy and copy files as mentioned below
    C:\JeaDeploy\<RoleName>\RoleCapabilities\<RoleName>.psrc
    C:\JeaDeploy\<RoleName>\<RoleName>.psd1
    C:\JeaDeploy\<RoleName>\JEADeploy.ps1
    C:\JeaDeploy\<RoleName>\<RoleName>.pssc 
```
