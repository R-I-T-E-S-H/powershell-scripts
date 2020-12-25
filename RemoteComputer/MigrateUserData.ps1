#Script to Migrate users data  (GDrive, QDrive My Doc, Desktop, Links and Favorites folders) 

param(
    $UserCSVFile = "UseParameter.csv",
    $DryRun = $true

)
$cmdMetalogix = "C:\Program Files\Quest\Essentials\Essentials.exe"

Function SendToWebHookTeams
{
    Param(
        $title = '',
        $text = '',
        $color = "good" #good | warning | danger | HEX code
    )
    $webhookurl = "https://outlook.office.com/webhook/1dbec599-eba6-4e72-87cc-0fb73e93fb9c@4cbfea0a-b872-47f0-b51c-1c64953c3f0b/IncomingWebhook/f71e52b2312a4c1da63abe8406b70c87/11f80fae-0fa3-435a-a07f-f304250e38b5"

    $payload = 
        @{
           
            "@context" = "http://schema.org/extensions"
            "@type" = "MessageCard"
            "themeColor" = "0072C6"
            "title" = $title
            "text" = $text

        }
        
    Invoke-WebRequest `
        -Body (ConvertTo-Json -Compress -InputObject $payload) `
        -Method Post `
        -UseBasicParsing `
        -Uri $webhookurl | Out-Null
      #  -Proxy "http://proxy:88" | Out-Null
}

# Using CSV file as Input
Import-Csv $UserCSVFile | ForEach-Object { $UserSamAccountName = $_.name      
  
    $OutputG=[string]::Format(".\CSVFILE\UserMigrationGDrive-{0}.csv", $UserSamAccountName)
    $OutputMyDoc=[string]::Format(".\CSVFILE\UserMigrationMyDoc-{0}.csv", $UserSamAccountName)
    $OutputQ=[string]::Format(".\CSVFILE\UserMigrationQDrive-{0}.csv", $UserSamAccountName)
    $OutputRed=[string]::Format(".\CSVFILE\UserReDirectedFolder-{0}.csv", $UserSamAccountName)
    $OutputMySite=[string]::Format(".\CSVFILE\UserMySite-{0}.csv", $UserSamAccountName)
    Write-Host "Getting data from user " $UserSamAccountName
    $aduser = Get-ADUser  $UserSamAccountName  -Properties HomeDirectory, Department, mail, wWWHomePage, profilepath, Scriptpath, homedrive -Server XXXXXXX.net

    if ($aduser -ne $null -and $aduser.mail -ne '') {
  
      
  # Use this line for getting Users G Drive Path Outside My Documents  
    $UserGDrive = [string]::Format("\\XXXXXXX.net\dfsroot\Department\{0}\{1}", $aduser.Department, $UserSamAccountName)
  
  # Use this line for getting Users My Documents  
    $UserMyDOc = [string]::Format("\\XXXXXXX.net\dfsroot\Department\{0}\{1}\My Documents", $aduser.Department, $UserSamAccountName)
  
   # User these Print User MySite Path
    $mySite = @($aduser.wWWHomePage+ ","+ $aduser.mail)
    $mySite | foreach { Add-Content -Path  $OutputMySite -Value $_ }
    Write-Host "Updating File" $OutputMySite


  # Use this line for getting Users Q Drive Data  
   
    $UserQDrive = $aduser.HomeDirectory

    Write-Host "Users HomeDrive: " $UserQDrive

  # User these Print User G Drive Path
    $myvalue1 = @($UserGDrive+ ","+ $aduser.mail)
    $myvalue1 | foreach { Add-Content -Path  $OutputG -Value $_ }
    Write-Host "Updating File" $OutputG

   # User these Print Users My Doc Path in CSV
    $myvalue2 = @($UserMyDOc+ ","+ $aduser.mail)
    $myvalue2 | foreach { Add-Content -Path  $OutputMyDoc -Value $_ }
    Write-Host "Updating File" $OutputMyDoc


 # Use these lines to Print Users Q Drive Path without Redirected Folders
   Get-ChildItem $UserQDrive |foreach {
    $f = $_
    if ($_.Name.ToLower() -eq "redirectedfolders") {
    $myvalue3 = @($UserQDrive+","+ $aduser.mail)
    $myvalue3 | foreach { Add-Content -Path  $OutputQ -Value $_ } 
    }
  }
  # Use these lines to Print Users Q Drive Path with Redirected Folders
   Get-ChildItem $UserQDrive |foreach {
    $f = $_
    if ($_.Name.ToLower() -eq "redirectedfolders") {
    $myvalue4 = @($UserQDrive+"\"+$_.Name +","+ $aduser.mail)
    $myvalue4 | foreach { Add-Content -Path  $OutputRed -Value $_ } 
    }
  }
   
  Write-Host "G Drive information saved in" $OutputG
  Write-Host "My Documents information saved in" $OutputMyDoc
  Write-Host "Q Drive information saved in" $OutputQ
  Write-Host "Redirected Folder information saved in" $OutputRed
  
  if (!$DryRun) {
      SendToWebHookTeams -title ([string]::Format("Migration Started For {0}", $aduser.mail)) -text "Migration started"
  
  
      $AdUserMapping = ".\ADUserMapping\Input_Users_ADGroups.csv"
      $AduserMapping1 = $AdUserMapping.trim(".")
      $metaADUserMapping = [string]::Format("'C:\Program Files\Quest\Essentials$adusermapping1'")
      write-host $metaADUserMapping
      $metaLogFile = [string]::Format("'C:\Program Files\Quest\Essentials\Logs\MetaLog-{0}-{1}.log'", $UserSamAccountName, [datetime]::Now.ToString('yyyyMMddhhmm'))


      #Migration Data without My Documents
     # $metaUserMapping = $OutputG
      $OutputG1 = $OutputG.trim(".")
      $metaUserMapping =[string]::Format("'C:\Program Files\Quest\Essentials$OutputG1'")
      $metaFolder = [string]::Format("'R0RyaXZlRGF0YQ=='")
      $metaExclude = '\"DirectoryExclude*=$RECYCLE.BIN, Windows, extra, My Documents\" \"ntfsIsHidden=1\"'
  
     Start-Process -FilePath $cmdMetalogix -ArgumentList ([string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping, $metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)) -Wait
     [string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping, $metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)
  
      #Migration Data My Documents
     # $metaUserMapping = $OutputG
      $OutputMyDoc1 = $OutputMyDoc.trim(".")
      $metaUserMapping =[string]::Format("'C:\Program Files\Quest\Essentials$OutputMyDoc1'")
      $metaExclude = '\"ntfsIsHidden=1\"'
      $metaFolder = [string]::Format("'TXkgRG9jdW1lbnRz'")
      Start-Process -FilePath $cmdMetalogix -ArgumentList ([string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping,$metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)) -Wait
      [string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping,$metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)

      #Migration Data without Redirected Folder
      #metaUserMapping = $OutputQ
      $OutputQ1 = $OutputQ.trim(".")
      $metaUserMapping =[string]::Format("'C:\Program Files\Quest\Essentials$OutputQ1'")
      $metaFolder = [string]::Format("'UURyaXZlRGF0YQ=='")
      $metaExclude = '\"DirectoryExclude*=$RECYCLE.BIN, extra, Profile_XXXXXXX, Profile_XXXXXXX_sdp, RedirectedFolders, Setup\" \"ntfsIsHidden=1\"'
      Start-Process -FilePath $cmdMetalogix -ArgumentList ([string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter  {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping,$metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)) -Wait
      [string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter  {1} -dtargetfolder {2} -copypermissions -usersReMapping {3} -log {4} -noSplashexit', $metaUserMapping,$metaExclude, $metaFolder, $metaADUserMapping, $metaLogFile)

      #Migration Data Redirected Folder
     # $metaUserMapping = $OutputRed
     $OutputRed1 = $OutputRed.trim(".")
      $metaUserMapping =[string]::Format("'C:\Program Files\Quest\Essentials$OutputRed1'")
      $metaExclude = '\"DirectoryExclude*=$RECYCLE.BIN, Searches\" \"ntfsIsHidden=1\"'
      Start-Process -FilePath $cmdMetalogix -ArgumentList ([string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter {1} -copypermissions -usersReMapping {2} -log {3} -noSplashexit', $metaUserMapping, $metaExclude, $metaADUserMapping, $metaLogFile)) -Wait
      [string]::Format('-cmd fileSharesToOneDrive -trgtsite https://YYYasa-admin.sharepoint.com -trgtuser MG1@YYYasa.onmicrosoft.com -trgtepass sA9Njwpq4k5NSutTsr0/nkBJWqucgZbw -usermapping {0} -overwritebehavior dont_copy -excludeSubfolders -filter  {1} -copypermissions -usersReMapping {2} -log {3} -noSplashexit', $metaUserMapping, $metaExclude, $metaADUserMapping, $metaLogFile)
  
  # Remove users Profile Path, Home Directory, Home Drive, Script Path

 # Set-ADUser $aduser -Clear profilepath,Scriptpath,homedirectory,homedrive

      # SendToWebHookTeams -title ([string]::Format("Migration Finished for {0}", $aduser.mail)) -text "Migration finished!"

        $logDir = $metaLogFile.trim("'")
        Write-Host $logDir
        $msg = ""

        $msgA = @()
        $msgcolor = 'good'

        Get-ChildItem -Path $logDir -Filter '*.xml' |foreach {
    
            [Xml]$xd = Get-Content $_.FullName
            if ($_.Name  -like '*metadata*') {
                 $msgA += $xd.td.metadata.date
                 $msgA += $xd.td.metadata.duration
                 $msgA += $xd.td.metadata.type
                 $msgA += $xd.td.metadata.source
                 $msgA += $xd.td.metadata.target
                 $msgA += $xd.td.metadata.status
                 if ($xd.td.metadata.status -ne 'Completed') {$msgcolor = 'warning'}
                 $msgA += $xd.td.performance.OTHER
                 $msgA += "-------------------"
            }
            else {
                $msgA += $xd.td.l[0].'#cdata-section'
                $msgA += $xd.td.l[0]
            }

        }


        $msg = [string]::Join("<br>", $msgA)

        SendToWebHookTeams -title ([string]::Format("Migration Summery for {0}", $aduser.mail)) -text $msg -color $msgcolor
 }
 else
 {
    Write-Host "In DryRun mode, will not do any migrations"
 }
  }
  else {
    Write-Host "Failed to get info form domain for : " + $UserSamAccountName -ForegroundColor Red

  }
 }
