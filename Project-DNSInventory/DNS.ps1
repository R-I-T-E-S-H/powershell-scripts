
$ServerList = "C:\Scripts\Temp\ServerList.txt"
$ExportPath = "C:\Temp\xml\"
$ExportCSVPath = "c:\Temp\CSV\"
$ext=".xlsx" 
$path="C:\Temp\DataSet$ext"

#**#**#**#**#**#**#**#**#**Export DNSServer Settings in XML#**#**#**#**#**#**#**#**#**#**#**
#invoke-command -ComputerName (get-content $ServerList)  {get-dnsserver | Export-Clixml -Path $ExportPath"$env:COMPUTERNAME".xml}

#**#**#**#**#**#**#**#**#**Import XML#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$XMLPath = $ExportPath
$AllxmlObject=@()
$Allxml = Get-ChildItem $XMLPath
foreach ($XML in $ALLxml)
{
$FullPath = $XMLPath+$XML
$ALLxmlObject+= Import-Clixml $FullPath
}
#**#**#**#**#**#***Create EXCEL#**#**#**#**#**#**#**#**#***
$excel = New-Object -ComObject excel.application
$excel.visible = $False

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
$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(1))
$wb.Close(0)

#**#**#**#**#**#**#**#**#***scavenging Settings#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$serverscavenging=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverscavenging+=$XMLObject.serverscavenging 
}
#**#**#**#**#**#**#**#**#**#**Export Scavenging Settings Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverscavenging"
$serverscavenging | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(2))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#***Server RootHint#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverroothint=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverroothint+=$XMLObject.serverroothint
}
#**#**#**#**#**#**#**#**#**#**Export roothint Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverroothint"
$serverroothint | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(3))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#***Server Zone#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverzone=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverzone+=$XMLObject.serverzone
}
#**#**#**#**#**#**#**#**#**#**Export ServerZone Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverzone"
$serverzone | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(4))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#***Server Zonescope#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverzonescope=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverzonescope+=$XMLObject.serverzonescope
}
#**#**#**#**#**#**#**#**#**#**Export serverzonescope Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverzonescope"
$serverzonescope | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(5))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#***Server Forworder#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**#**
$serverforwarder=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverforwarder+=$XMLObject.serverforwarder
}
#**#**#**#**#**#**#**#**#**#**Export serverforwarder Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverforwarder"
$serverforwarder | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(6))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#**Export serverdssetting #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$serverdssetting=@()
foreach ($XMLObject in $ALLxmlObject)
{
$serverdssetting+=$XMLObject.serverdssetting
}
#**#**#**#**#**#**#**#**#**#**Export serverdssetting Only #**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverdssetting"
$serverdssetting | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(7))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#**Export serverglobalnamezone#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
foreach ($XMLObject in $ALLxmlObject)
{
$serverglobalnamezone+=$XMLObject.serverglobalnamezone
}
#**#**#**#**#**#**#**#**#**#**Export serverglobalnamezone only#**#**#**#**#**#**#**#**#**#**#**#**#**#**#***
$csvname = "serverglobalnamezone"
$serverglobalnamezone | Export-CSV $ExportCSVPath$csvname.csv
#$reportOut = $excel.Workbooks.Add()
$wb = $excel.WorkBooks.Open("$ExportCSVPath$csvname")
$wb.Worksheets.Item(1).Name = "$csvname"
$wb.Worksheets.Copy($reportOut.WorkSheets.Item(8))
$wb.Close(0)

#**#**#**#**#**#**#**#**#**#***Close Excel#**#**#**#**#**#**#**#**#**#**#**#**#**
$excel.DisplayAlerts = 'False'
$reportOut.SaveAs($path)  
#$reportOut.Close
$excel.DisplayAlerts = 'False'
$excel.Quit()

**************FOR Zone SOA TTL************
Get-DnsServerResourceRecord -zonename corp.contoso.com -Type 6

*************ServerLevel DNSServer Recursion value to be 9 Sec**************
Get-DnsServerRecursion