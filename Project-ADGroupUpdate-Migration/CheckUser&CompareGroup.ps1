********Script 1 : Check if user exists ***********
$working_directory = "c:\FolderPermissions"
new-item $working_directory -ItemType Directory -Force
Set-Location -Path $working_directory 
$LDomain2DC = ""
$Domain1DC = ""
$report = @()
$result = @() 
$UserTable = @()
$ALUserTable = @()

$UserTable = Import-Csv c:\FolderPermissions\UserList.csv
$ALUserTable = new-object PSObject 
foreach($User in $UserTable)
{
    Try
        {
        $UserName = $User.PagaIdent
        $UserName1= $User.MapTo
        $UNResult = Get-ADUser -identity $UserName -Server $Domain1DC
        $result += "$UserName : User exists in Domain1 Domain"
        $ALUserTable | add-member -membertype NoteProperty -name "Domain2-L" -Value $UserName1
        }
    catch
        { 
        Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
        $result += "$UserName : User does not exists in Domain1 Domain"
        }

} 
************************************�
********Script 2 : Compare group membership and add user to group ***********

Set-Location -Path $working_directory 
#$LDomain2DC = ""
#$Domain1DC = ""
$report = @()
$result = @() 
$UserTable = @()
$ALUserTable = @()
$GroupTable = @()
$UserTable = Import-Csv c:\FolderPermissions\UserList.csv
$GroupTable = Import-Csv c:\FolderPermissions\GroupList.csv
$ALUserTable = new-object PSObject 
foreach($User in $UserTable)
    {
        Try
            {
                $Domain1user = $User.Domain1user
                $LDomain2user= $User.LDomain2User
                #$getLDomain2user = Get-ADUser -identity $LDomain2user -Server $LDomain2DC
                $getLDomain2user = Get-ADUser -identity $LDomain2user
                $result += "$LDomain2user : User exists in LDomain2 Domain"
                ##
                $LDomain2usergroups = Get-ADPrincipalGroupMembership -Identity $LDomain2user
                ##
                        foreach($LDomain2usergroup in $LDomain2usergroups)
                         {
                            if($LDomain2usergroup.name -ne 'Domain Users')
                              {
                                 Try
                                  {
                                    foreach($MemberGroupTable in $GroupTable)
                                    {
                        Try
                            {
                            if($LDomain2usergroup.name -eq $MemberGroupTable.LDomain2Group)
                             {
                              Add-ADGroupMember -Identity $MemberGroupTable.Domain1group  -Members $Domain1user
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
                               }
                         }
             }
        catch
            {
               Write-Host $_.Exception.Message  -ForegroundColor Red -BackgroundColor White 
               $result += "$LDomain2user : User does not exists in Domain2-L Domain"  
             }
     }

****************************�
