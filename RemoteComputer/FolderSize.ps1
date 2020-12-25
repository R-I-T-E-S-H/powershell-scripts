
$Filename = 'C:\Project\GHub\Temp\list.csv'
$All = Import-Csv $Filename


foreach($Record in $All)
{
    $Folders = Get-ChildItem  ($Record.Networkpath) -Attributes Directory -Recurse -Depth 4
    foreach($Folder in $Folders)
        {
            Write-Output "*********************************"
            Write-Output $Folder.FullName
            Write-Output "Total Size :" 
            "{0:N2} MB" -f ((gci $Folder.FilePath | measure Length -s).sum / 1Mb)
            $TotalFOlders = Get-ChildItem $Folder.FullName -Recurse -Directory | Measure-Object | %{$_.Count} 
            Write-Output "Total Directories : $TotalFOlders"
            $TotalFiles = Get-ChildItem $Folder.FullName -Recurse -File | Measure-Object | %{$_.Count} 
            Write-Output "Total Files : $TotalFiles"
             Write-Output "*********************************"
            
        }
}
