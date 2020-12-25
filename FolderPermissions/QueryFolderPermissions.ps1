$DirList = Get-ChildItem \\XX.XX.XX.XX\c$\Demo
$working_directory = "c:\FolderPermissions"
new-item $working_directory -ItemType Directory -Force
Set-Location -Path $working_directory 
$FolderList = $null
$FolderList = @()
foreach ($Dir in $DirList)
{
$DirPath = $Dir.FullName
$Acl = Get-Acl $DirPath
$AccessList = $Acl.Access
    foreach ($Access in $AccessList)
        {
        $ObjectName = $Access.IdentityReference
            if ($ObjectName -match $Dir.Name)
            {
            $FolderList_temp = new-object PSObject 
            $FolderList_temp | add-member -membertype NoteProperty -name "FolderName" -Value $Dir.Name
            $FolderList_temp | add-member -membertype NoteProperty -name "FolderPath" -Value $Dir.FullName
            $FolderList_temp | add-member -membertype NoteProperty -name "GroupName" -Value $ObjectName
            $FolderList += $FolderList_temp
             }
           }
        $FolderList | Export-Csv "FolderList.csv" -NoTypeInformation -Force
}

Foreach($Folder in $FolderList)
{
$SACL = (Get-Item $Folder.FolderPath).GetAccessControl('Access')
$Username = $Folder.GroupName
$Ar = New-Object System.Security.AccessControl.FileSystemAccessRule($Username, 'ReadAndExecute','ContainerInherit,ObjectInherit', 'None', 'Allow')
$SACL.SetAccessRule($Ar)
Set-Acl $Folder.FolderPath -AclObject $SACL
}
