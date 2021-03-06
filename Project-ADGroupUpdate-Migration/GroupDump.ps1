﻿
$GroupTable = $null
$GroupTable = @()
$GroupNames = get-adgroup -Filter * | where{$_.name -like "GZ*"}

foreach($GroupName in $GroupNames)
{
$GroupMembers = Get-ADGroupMember -Identity $GroupName.name
        foreach($GroupMember in $GroupMembers)
            {
            $GroupTableTemp = New-Object PSObject
            $GroupTableTemp | add-member -MemberType NoteProperty -name "GroupName" -value $GroupName
            $GroupTableTemp | add-member -MemberType NoteProperty -name "MemberName" -value $GroupMember.name
            $GroupTableTemp | add-member -MemberType NoteProperty -name "MemberType" -value $GroupMember.objectClass
            $GroupTableTemp | add-member -MemberType NoteProperty -name "MemberSamAccountName" -value $GroupMember.SamAccountName
            $GroupTable += $GroupTableTemp
            }
        ## $GroupTable | Export-Csv "FolderList.csv" -NoTypeInformation -Force
}

