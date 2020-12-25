
#$ServerList = "C:\Scripts\Temp\ServerList.txt"
$ExportPath = "C:\Technology\Project\DNS\Data\XML\DNBNOR\"
$ExportCSVPath = "C:\Technology\Project\DNS\Data\CSV\DNBNOR\"
$ext=".xlsx" 
$path="C:\Technology\Project\DNS\Data\Result\DNBNOR$ext"

#**#**#**#**#**#**#**#**#**Export DNSServer Settings in XML#**#**#**#**#**#**#**#**#**#**#**
#invoke-command -ComputerName (get-content $ServerList)  {get-dnsserver | Export-Clixml -Path $ExportPath"$env:COMPUTERNAME".xml}

#**#**#**#**#**#**#**#**#**Import XML#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$XMLPath = $ExportPath
$AllxmlObject=@()
$Allxml = @()
$Allxml = Get-ChildItem $XMLPath
foreach ($XML in $ALLxml)
{
$FullPath = $XMLPath+$XML
$ALLxmlObject+= Import-Clixml $FullPath
}
#**#**#**#**#**#***Create EXCEL#**#**#**#**#**#**#**#**#***
#$excel = New-Object -ComObject excel.application
#$excel.visible = $False

#**#**#**#**#**#**#**#**#***Server Settings#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$serversetting=@()
foreach ($XMLObject in $ALLxmlObject)
{
#$NewXMLObject=$XMLObject | select -Property @{name="ServerName";e={$XMLObject.CimSystemProperties.ServerName}}, *
$serversetting+= $XMLObject.serversetting
}
#**#**#**#**#**#**#**#**#**#**Export Server Settings Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serversetting"
$serversetting | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$Destination = "C:\Temp\DataSet$ext"
$delimiter = "," #Specify the delimiter used in the file
# Create a new Excel workbook with one empty sheet
$excel = New-Object -ComObject excel.application 
$workbook = $excel.Workbooks.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()

#**#**#**#**#**#**#**#**#***scavenging Settings#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$serverscavenging=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverscavenging+=$XMLObject.serverscavenging 
}
#**#**#**#**#**#**#**#**#**#**Export Scavenging Settings Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverscavenging"
$serverscavenging | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()

#**#**#**#**#**#**#**#**#**#***Server RootHint#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverroothint=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverroothint+=$XMLObject.serverroothint
}
#**#**#**#**#**#**#**#**#**#**Export roothint Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverroothint"
$serverroothint | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()

#**#**#**#**#**#**#**#**#**#***Server Zone#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverzone=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverzone+=$XMLObject.serverzone
}
#**#**#**#**#**#**#**#**#**#**Export ServerZone Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverzone"
$serverzone | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"

$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()

#**#**#**#**#**#**#**#**#**#***Server Zonescope#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverzonescope=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverzonescope+=$XMLObject.serverzonescope
}
#**#**#**#**#**#**#**#**#**#**Export serverzonescope Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverzonescope"
$serverzonescope | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()

#**#**#**#**#**#**#**#**#**#***Server Forworder#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverforwarder=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverforwarder+=$XMLObject.serverforwarder
}
#**#**#**#**#**#**#**#**#**#**Export serverforwarder Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverforwarder"
$serverforwarder | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()
#$reportOut = $excel.Workbooks.Add()

#**#**#**#**#**#**#**#**#**#**Export serverdssetting #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$serverdssetting=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverdssetting+=$XMLObject.serverdssetting
}
#**#**#**#**#**#**#**#**#**#**Export serverdssetting Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverdssetting"
$serverdssetting | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()


#**#**#**#**#**#**#**#**#**#**Export serverglobalnamezone#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
foreach ($XMLObject in $ALLxmlObject)
{
$serverglobalnamezone+=$XMLObject.serverglobalnamezone
}
#**#**#**#**#**#**#**#**#**#**Export serverglobalnamezone only#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverglobalnamezone"
$serverglobalnamezone | Export-CSV $ExportCSVPath$csvname.csv
$Source = "$ExportCSVPath$csvname.csv"
$excel.worksheets.Add()
$worksheet = $workbook.worksheets.Item(1)
$worksheet.Name = "$csvname"
# Build the QueryTables.Add command and reformat the data
$TxtConnector = ("TEXT;" + $Source)
$Connector = $worksheet.QueryTables.add($TxtConnector,$worksheet.Range("A1"))
$query = $worksheet.QueryTables.item($Connector.name)
$query.TextFileOtherDelimiter = $delimiter
$query.TextFileParseType  = 1
$query.TextFileColumnDataTypes = ,1 * $worksheet.Cells.Columns.Count
$query.AdjustColumnWidth = 1
# Execute & delete the import query
$query.Refresh()
$query.Delete()


#**#**#**#**#**#**#**#**#**#***Close Excel#**#**#**#**#**#**#**#**#**#**#**#**#**
$Workbook.SaveAs($Destination,51)
$excel.Quit()
**************FOR Zone SOA TTL************
Get-DnsServerResourceRecord -zonename corp.contoso.com -Type 6

*************ServerLevel DNSServer Recursion value to be 9 Sec**************
Get-DnsServerRecursion