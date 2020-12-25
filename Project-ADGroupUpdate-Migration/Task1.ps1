<#

.SYNOPSIS
This script is developed for creating bulk groups and adding users in the group

.DESCRIPTION
Takes input from first source file with group names (file name and path is hardcoded) and another source file with Users name in it (File name is hardcoded)
SourceFile Format i.e Source.txt (Three Column as mentioned) 
Name Description ToAdd

.EXAMPLE
./Task1-GroupCreation.ps1

---------------------------EXAMPLE 2---------------------------

./Task1-GroupCreation.ps1 -GroupFile "C:\temp\source.txt" -UserFile "C:\temp\UsersList.txt" -ExportFile "C:\temp\export.csv"


---------------------------EXAMPLE 3---------------------------



.NOTES
The Script is meant to be executed by Authorized DNB / HCL Admins. Executor needs to have Minimum of delegated permissions on Active Directory to create groups
Created By    : Ritesh Grover - HCL
Reviewed By   :      
Version: 1.0
.LINK
N/A

#>

param (
    #Provide source file path like C:\temp\source.csv
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $GroupFile,

    #Provide file path with user name like C:\temp\UsersList.csv
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $UserFile,

     #Provide file path with export file name like C:\temp\export.csv
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $ExportFile

)
$ExecutionTime = Get-date
$TiTle = "TASK 1 : Domain1 DOMAIN LOCAL GROUPS CREATION AND MEMBERS ADDITION TASK"
$username = $env:username
$result = @()
$report = @()
$GCount = 0
$path= "OU=XXX Trans,OU=YYYY Trans,OU=Groups,OU=System Operations,DC=Domain1,DC=net"
$Groups = Import-Csv $GroupFile 
$Users = Import-Csv $UserFile
$GroupsCount = $Groups.Count
$UsersCount = $Users.Count
Try{ 
foreach ($Group in $Groups) 
{
$GroupDescription = $Group.Description
$GroupToAdd = $Group.Domain1Groups
Try
{
$GNResult=get-Adgroup -Filter 'Name -eq $GroupToAdd'
}
catch
{ 
Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
}
Try
{
        if(!$GNResult)        
            {
            $result += "********************************************************"
            Try
            {
            $result += "GROUP NAME : $GroupToAdd"
            $result += "ACTION : Group doesnt exists,create group & add members"
            New-ADGroup -Name $GroupToAdd -SamAccountName $GroupToAdd -GroupScope Global -GroupCategory Security -DisplayName $GroupToAdd -Description $GroupDescription -Path $path
            $result += "Group Added"
            $GCount = $GCount +1
            }
            catch
            {
            Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White
            }
            $result += "Adding Users"       
            foreach($User in $Users)
                {
                $UserToAdd = $User.Name
                Try
                {
                Add-ADGroupMember -Identity $GroupToAdd -Members $UserToAdd
                $result += "User Added : $UserToAdd " 
                }
                catch
                { 
                Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                $result += "Not able to Add : $UserToAdd " 
                }
                }
            }
        else
        {
            $result += "********************************************************"
            $result += "GROUP NAME : $GroupToAdd"
            $result += "ACTION : Group Already exists, Validate and add User Manually"
        }
}
catch
{ 
Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
}
}
}
catch
{ 
Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
}
$report += "***********************REPORT****************************"
$report += "TASK TITLE       : $Title"                     
$report += "EXECUTION DATE   : $ExecutionTime"
$report += "EXECUTED BY      : $username"
$report += "TOTAL GROUPS     : $Groupscount"
$report += "TOTAL USERS      : $Userscount"
$report += "GROUPS CREATED   : $GCount"
$report += "*********************************************************"

$report >> $ExportFile  
$result >> $ExportFile  




