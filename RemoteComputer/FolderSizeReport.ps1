$Folder = "C:\temp\3250"
                            $Folders = Get-ChildItem  $Folder -Attributes Directory
                            $ParentFolder = $Folder
                            $ParentFolderSize = "{0:N2} MB" -f ((gci $Folder -Depth 10 | measure Length -s).sum / 1Mb)
                            $ParentFolderSubDir = Get-ChildItem $Folder -Recurse -Directory -Depth 10 | Measure-Object | %{$_.Count} 
                            $ParentFolderFiles = Get-ChildItem $Folder -Recurse -File -Depth 10 | Measure-Object | %{$_.Count} 
                            
                            $mytotalfolders = @()
                                          foreach($F in $Folders)
                                          {   
                                          $q="(&(cn="+$F.Name+")(objectclass=user))"
                                          if ((""+([adsisearcher]$q).FindOne()) -eq "") 
                                                  {
                                                    $a = New-Object System.Object
                                                    
                                                    $a  | Add-Member -type NoteProperty -name FolderName -Value $F.FullName
                                                     
                                                    $Size = "{0:N2} MB" -f ((gci $F.FullName | measure Length -s).sum / 1Mb)
                                                    $a  | Add-Member -type NoteProperty -name FolderSize -Value $Size

                                                    $TotalFOlders = Get-ChildItem $F.FullName -Recurse -Directory -Depth 10 | Measure-Object | %{$_.Count}  
                                                    $a  | Add-Member -type NoteProperty -name TotalSubFolders -Value $TotalFOlders
                                                
                                                    $TotalFiles = Get-ChildItem $F.FullName -Recurse -File -Depth 10 | Measure-Object | %{$_.Count} 
                                                    $a  | Add-Member -type NoteProperty -name TotalFiles -Value $TotalFiles
                                                    
                                                    $mytotalfolders += $a
                                                   }
                                             }
                                             Write-Output "Parent Folder      : $ParentFolder"
                                             Write-output "ParentFolderSize   : $ParentFolderSize"
                                             Write-Output "ParentFolderSubDir : $ParentFolderSubDir"
                                             Write-Output "ParentFolderFiles  : $ParentFolderFiles"
                                             $mytotalfolders