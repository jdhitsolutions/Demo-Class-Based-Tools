#requires -version 3.0

<#
 This is a simple demonstration script.
 The main par is a one-line command you could 
 have run interactively in the console.

 Using a script saves typing and provides
 consistency.
#>

#a collection of computers to query
$computername="chi-dc01","chi-dc02","chi-dc04"

#Use WMI to display some customized OS information
Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computername | 
Select-Object -Property @{Name="Computername";
Expression={$_.CSName}},
@{Name="OS";Expression={$_.Caption}},
@{Name="SvcPack";Expression={$_.CSDVersion}},
@{Name="LastBoot";
Expression={$_.ConvertToDateTime($_.LastBootUpTime)}},
@{Name="Uptime";Expression={ 
(Get-Date) - $_.ConvertToDateTime($_.LastBootUpTime)}},
@{Name="%Free";Expression={
 $C = Get-WmiObject -Class win32_logicaldisk -filter "DeviceID='c:'" -ComputerName $_.CSName
 [math]::Round(($C.freespace/$c.size)*100,2)
}}