<#

.SYNOPSIS
This script is developed for Creating new groups based on Domain1 bussiness logic

.DESCRIPTION
Takes input from source file and Export file
SourceFile Format i.e Source.txt (Three Column as mentioned) 
LunaGroups, Description, Domain1Groups

.EXAMPLE
./Task3.ps1

---------------------------EXAMPLE 2---------------------------

./Task3 -GroupFile "C:\temp\source.txt" -ExportFile "C:\temp\export.csv"


---------------------------EXAMPLE 3---------------------------



.NOTES
The Script is meant to be executed by Authorized Admins. Executor needs to have Minimum of delegated permissions on Active Directory to create groups
Created By    : Ritesh Grover
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

     #Provide file path with export file name like C:\temp\export.csv
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    $ExportFile
)


$ExecutionTime = Get-date
$TiTle = "TASK 3 : XXXX DOMAIN GROUPS CREATION AND MODIFICATION TASK"
$username = $env:username
$report = @()
$result = @() 
$GroupCount = 0
$GGroupConWCh = 0
$GGroupCon = 0
$LGroup = 0
$LGroupNoCha = 0
$NewGGroup = 0
$path = "OU=XXXXX-Trans,OU=Sikkerhetsgrupper,OU=GNSF,DC=XXXXX,DC=YYYYYYY,DC=no"
$Groups = Import-Csv $GroupFile -Encoding Unicode
foreach ($Group in $Groups) 
{
$ServerIP = "XX:XX:XX:XX"
$GroupName = $Group.XXXXGroups
$GroupDescription = $Group.Description
$GroupToAdd = $Group.Domain1Groups
$GroupCount = $GroupCount + 1
Try
{
$GNResult=get-Adgroup -Filter 'Name -eq $GroupName'
}
catch
{ 
Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
}
        if(!$GNResult)        
            {
            $result += "********************************************************"
            $result += "GROUP NAME : $GroupName"
            $result += "ACTION : Group does not exists, Domain Local Group created"
            New-ADGroup -name $GroupName -SamAccountName $GroupName -GroupScope DomainLocal -GroupCategory Security -DisplayName $GroupName -Description $GroupDescription -path $path
            $LGroup = $LGroup + 1
            $result += "GROUP CREATED : $GroupName"
            $Domain1Group=Get-ADGroup -identity $GroupToAdd -Server $ServerIP
            Add-ADGroupMember -Identity $GroupName -Members $Domain1Group
            $result += "Domain1 GROUP ADDED : $GroupToAdd"
            }
        else
            {    
            $GroupType = $GNResult.GroupScope
                if ($GroupType -eq "DomainLocal")
                    {
                    Try
                    {
                    $LGroupNoCha = $LGroupNoCha + 1
                    $result += "********************************************************"
                    $result += "GROUP NAME : $GroupName"
                    $result += "GROUP TYPE : $GroupType"
                    $result += "ACTION : No Change Required, Just Add Domain1 Group"
                    $Domain1Group=Get-ADGroup -identity $GroupToAdd -Server $ServerIP
                    Add-ADGroupMember -Identity $GroupName -Members $Domain1Group
                    $result += "Domain1 GROUP ADDED : $GroupToAdd"
                    }
                    catch
                    {
                    Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                    $result += "NOT ABLE TO ADD Domain1 GROUP : $GroupToAdd"
                    }

                    }
                else
                    {
                    $result += "********************************************************"
                    $result += "GROUP NAME : $GroupName"
                    $result += "GROUP TYPE : $GroupType"
                    $MembersOf = Get-ADPrincipalGroupMembership -Identity $GroupName
                    $count = 0
                    foreach($MemOf in $MembersOf)
                    {
                    $count=$count + 1
                    }
                        if($count -eq 0)
                            {
                            Try
                            {
                            $GGroupCon = $GGroupCon + 1
                            $result += "ACTION : No Memberof present, Convert Group into Domain Local and Add Domain1 Group"
                            Set-ADGroup $GroupName -GroupScope Universal 
                            Set-ADGroup $GroupName -GroupScope DomainLocal
                            $result += "GROUP Converted : $GroupName"
                            $Domain1Group=Get-ADGroup -identity $GroupToAdd -Server $ServerIP
                            Add-ADGroupMember -Identity $GroupName -Members $Domain1Group
                            $result += "Domain1 GROUP ADDED : $GroupToAdd"
                            }
                        catch
                            {
                            Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                            $result += "NOT ABLE TO ADD Domain1 GROUP : $GroupToAdd"
                            }
                             }
                        else
                            {
                            Try
                            {
                            $NewGGroup = $NewGGroup + 1
                            $result += "ACTION : Memberof not empty, Create New domain Global group, move members and  memberOf to new group and Add Domain1 Group"
                            $NewGroupName = $GroupName -ireplace "_", "G_"
                            New-ADGroup -Name $NewGroupName -SamAccountName $NewGroupName -GroupCategory Security -GroupScope Global -DisplayName $NewGroupName -Description $GroupDescription -path $path
                            $result += "NEW GROUP CREATED : $NewGroupName"
                            $OldGroupMembers=Get-ADGroupMember -Identity $GroupName
                            $OldGroupMembersOf=Get-ADPrincipalGroupMembership -Identity $GroupName
                                foreach($OldGroupMember in $OldGroupMembers)
                                {
                                Try
                                    {
                                    Add-ADGroupMember -Identity $NewGroupName -Members $OldGroupMember
                                    }
                                catch
                                    { 
                                    Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                                    }
                                }
                                    $result += "Members from $GroupName Add to  $NewGroupName"
                                foreach($OldGroupMemberOf in $OldGroupMembersOf)
                                {
                                    Try
                                    {
                                    Add-ADPrincipalGroupMembership -Identity $NewGroupName -MemberOf $OldGroupMemberOf
                                    }
                                    catch
                                    { 
                                    Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                                    }
                                }
                                    $result += "MembersOf from $GroupName Add to  $NewGroupName"
                             
                             foreach($OldGroupMember in $OldGroupMembers)
                                {
                                Try
                                    {
                                    Remove-ADGroupMember -Identity $GroupName -Members $OldGroupMember -Confirm:$false 
                                    }
                                catch
                                    { 
                                    Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                                    }
                                }
                                $result += "All Members from group $GroupName has been removed"

                                 foreach($OldGroupMemberOf in $OldGroupMembersOf)
                                {
                                Try
                                    {
                                   Remove-ADPrincipalGroupMembership -Identity $GroupName -MemberOf $OldGroupMemberOf -Confirm:$false 
                                    }
                                catch
                                    { 
                                    Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                                    }
                                }
                            $result += "All MembersOf from group $GroupName has been removed"
                            Try
                            {  
                            $GGroupConWCh = $GGroupConWCh + 1                     
                            Set-ADGroup $GroupName -GroupScope Universal 
                            Set-ADGroup $GroupName -GroupScope DomainLocal
                            $result += "GROUP Converted in Domain Local : $GroupName"
                            $Domain1Group=Get-ADGroup -identity $GroupToAdd -Server $ServerIP
                            Add-ADGroupMember -Identity $GroupName -Members $Domain1Group
                            $result += "Domain1 GROUP ADDED : $GroupToAdd"
                            Add-ADGroupMember -Identity $GroupName -Members $NewGroupName
                            $result += "NEW GROUP ADDED : $NewGroupName"
                            }
                            catch
                            { 
                            Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                             }
                            }
                            catch
                            { 
                            Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
                             }
                            }    
                    }
             }

}

$report += "********************************************************************************************************"
$report += "************************************************REPORT**************************************************"
$report += "TASK TITLE                          : $Title "
$report += "EXECUTION DATE                      : $ExecutionTime"
$report += "EXECUTED BY                         : $username"
$report += "TOTAL GROUPS                        : $Groupcount"
$report += "LOCAL GROUPS WITH NO CHANGE         : $LGroupNoCha"
$report += "NEW LOCAL GROUPS CREATED            : $LGroup"
$report += "NEW GLOBAL GROUPS CREATED           : $NewGGroup"
$report += "GLOBAL GROUPS CONVERTED W/O CHANGE  : $GGroupCon"
$report += "GLOBAL GROUPS CONVERTED WITH CHANGE : $GGroupConWCh"
$report += "********************************************************************************************************"

$report >> $ExportFile
$result >> $ExportFile 

