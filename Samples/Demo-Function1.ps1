#requires -version 3.0

#this is a simple function 

Function Get-MyComputer {

Param(
[string[]]$computername=$env:COMPUTERNAME
)

Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername | 
Select-Object -property @{Name="Computername";Expression={$_.CSName}},
@{Name="OS";Expression={$_.Caption}},
@{Name="SvcPack";Expression={$_.CSDVersion}},
@{Name="LastBoot";Expression={
$_.ConvertToDateTime($_.LastBootUpTime)}},
@{Name="Uptime";Expression={
 (Get-Date) - $_.ConvertToDateTime($_.LastBootUpTime)}},
@{Name="%Free";Expression={
 $C = Get-WmiObject -Class win32_logicaldisk -filter "DeviceID='c:'" -ComputerName $_.CSName
 [math]::Round(($C.freespace/$c.size)*100,2)
}}

} #end function

#end of script