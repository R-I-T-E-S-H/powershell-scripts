function Get-RemoteComputerDisk
{
    
    Param
    (
        $RemoteComputerName
    )

    Begin
    {
        $output="Drive `t UsedSpace(in GB) `t FreeSpace(in GB) `t TotalSpace(in GB) `n"
    }
    Process
    {
        $drives=Get-WmiObject Win32_LogicalDisk -ComputerName $RemoteComputerName

        foreach ($drive in $drives){
            
            $drivename=$drive.DeviceID
            $freespace=[int]($drive.FreeSpace/1GB)
            $totalspace=[int]($drive.Size/1GB)
            $usedspace=$totalspace - $freespace
            $output=$output+$drivename+"`t`t"+$usedspace+"`t`t`t`t`t`t"+$freespace+"`t`t`t`t`t`t"+$totalspace+"`n"
        }


    }
    End
    {
        return $output
    }
}

function Get-CpuUsage
{
                 param(
                 $RemoteComputerName
                 )
                 $os = gwmi win32_perfformatteddata_perfos_processor -ComputerName $RemoteComputerName| ? {$_.name -eq "_total"} | select -ExpandProperty PercentProcessorTime  -ea silentlycontinue
                 if(($os -match '\d+') -or ($os -eq '0')){
                 $results =new-object psobject
                 $results |Add-Member noteproperty Cputil  $os
                 $results |Add-Member noteproperty ComputerName  $RemoteComputerName
                 $results | Select-Object computername,Cputil
                 }
                 else{
                 $results =new-object psobject
                 $results |Add-Member noteproperty Cputil  "Na"
                 $results |Add-Member noteproperty ComputerName  $RemoteComputerName
                 $results | Select-Object computername,Cputil
                 }
                 }

function Get-Cpu
{
   param(
   $RemoteComputerName
   )
   $CPUInfo = Get-WmiObject Win32_Processor -ComputerName $RemoteComputerName #Get CPU Information

Foreach ($CPU in $CPUInfo)
	{
		$infoObject = New-Object PSObject
		#The following add data to the infoObjects.	
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "ServerName" -value $CPU.SystemName
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Processor" -value $CPU.Name
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Model" -value $CPU.Description
		Add-Member -inputObject $infoObject -memberType NoteProperty -name "Manufacturer" -value $CPU.Manufacturer
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "PhysicalCores" -value $CPU.NumberOfCores
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L2CacheSize" -value $CPU.L2CacheSize
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "CPU_L3CacheSize" -value $CPU.L3CacheSize
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "Sockets" -value $CPU.SocketDesignation
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "LogicalCores" -value $CPU.NumberOfLogicalProcessors
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Name" -value $OSInfo.Caption
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "OS_Version" -value $OSInfo.Version
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalPhysical_Memory_GB" -value $PhysicalMemory
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVirtual_Memory_MB" -value $OSTotalVirtualMemory
		#Add-Member -inputObject $infoObject -memberType NoteProperty -name "TotalVisable_Memory_MB" -value $OSTotalVisibleMemory
		$infoObject #Output to the screen for a visual feedback.
		$infoColl += $infoObject
	}

}

function Get-Memory
{
param(
$RemoteComputerName
)
$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName RemoteComputerName | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
                 $Memoryresults =new-object psobject
                 $Memoryresults |Add-Member noteproperty Memory  $PhysicalMemory
                 $Memoryresults |Add-Member noteproperty ComputerName  $RemoteComputerName
                 $Memoryresults | Select-Object computername,Memory

}



	#$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $s #Get OS Information
	#Get Memory Information. The data will be shown in a table as MB, rounded to the nearest second decimal.
	#$OSTotalVirtualMemory = [math]::round($OSInfo.TotalVirtualMemorySize / 1MB, 2)
	#$OSTotalVisibleMemory = [math]::round(($OSInfo.TotalVisibleMemorySize / 1MB), 2)
	

