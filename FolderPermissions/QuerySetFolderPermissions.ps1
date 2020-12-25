param([string]$departmentId)

$departmentId = '547'

$folder="\\dnbnor.net\dfsroot\Department\"+$departmentId
$folderAcl=get-acl $folder;
# get all department ACLS applied to the folder, DL_ or not.
$departmentAcls=$folderAcl.GetAccessRules($true,$false,[System.Security.Principal.NTAccount])   | ? IdentityReference -match $departmentId


if ($departmentAcls.Count -gt 1) {
              $folder+": ERROR - Multiple security rules found on folder, check manually"
              $departmentAcls
}

if ($departmentAcls.Count -eq 1) {
              $departmentAcls | select IdentityReference | % {
              get-command 
              $groupname=$_.IdentityReference

              $folder+": Denying WRITE for "+$groupname
              $cmd="icacls ""$folder"" /deny "+$groupname+":W"
              #$cmd
              iex $cmd

              # Process Non User Folders
              dir $folder | % { 
                             $q="(&(cn="+$_.Name+")(objectclass=user))"
                             if ((""+([adsisearcher]$q).FindOne()) -eq "") {
                                           $cmd="icacls """+$_.FullName+""" /deny "+$groupname+":W /t"
                                           #$cmd
                                           iex $cmd
                             }
                             
              }
}

}



#"Current ACL on "+$folder
#$folderAcl=get-acl $folder;
#$departmentAcls=$folderAcl.GetAccessRules($true,$false,[System.Security.Principal.NTAccount])  | ? IdentityReference -match $departmentId
#$departmentAcls


# For CSV type .\departments.csv  | % { .\crap.ps1 $_ }
# For Single Department Type  .\crap.ps1 8791
