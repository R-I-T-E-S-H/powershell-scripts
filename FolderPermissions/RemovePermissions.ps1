# param([string]$departmentId)

$departmentId = 'RiteshG'

$folder="C:\temp\"+$departmentId

$folderAcl=get-acl $folder;

# get all department ACLS applied to the folder, DL_ or not.
$departmentAcls=$folderAcl.GetAccessRules($true,$false,[System.Security.Principal.NTAccount])   | ? IdentityReference -match $departmentId


if ($departmentAcls.Count -gt 1) {
              $folder+": ERROR - Multiple security rules found on folder, check manually"
              $departmentAcls
}

if ($departmentAcls.Count -eq 1) {
              $departmentAcls | select IdentityReference | % {
              
              $groupname=$_.IdentityReference

              $folder+": Denying WRITE for "+$groupname
              $cmd="icacls ""$folder"" /remove:d "+$groupname+""
              iex $cmd
              
              # Process Non User Folders
              dir $folder | % { 
                             $q="(&(cn="+$_.Name+")(objectclass=user))"
                             if ((""+([adsisearcher]$q).FindOne()) -eq "") {
                                           $cmd="icacls """+$_.FullName+""" /remove:d "+$groupname+" /t"
                                           #$cmd
                                           iex $cmd
                             }
                             
              }
}

}

