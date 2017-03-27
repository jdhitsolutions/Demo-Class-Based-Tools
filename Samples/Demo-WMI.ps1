#demo WMI
help Get-WmiObject

get-wmiobject -list -class win32*

get-wmiobject -ClassName win32_operatingsystem
get-wmiobject win32_operatingsystem | select *

$computers = "chi-fp02","chi-core01",
"chi-dc01","chi-dc02","chi-dc04","chi-hvr2"

get-wmiobject win32_operatingsystem -computername $computers | 
select PSComputername,Caption,OSArchitecture,ServicePackMajorVersion,InstallDate

#WMI Dates can be converted

get-wmiobject win32_operatingsystem -computername $computers | 
select PSComputername,Caption,OSArchitecture,
ServicePackMajorVersion,
@{Name="Installed";
Expression={$_.ConvertToDatetime($_.InstallDate)}}

#filtering
#gwmi is an alias for Get-WMIObject
gwmi win32_logicaldisk -ComputerName chi-fp02

#several options:
gwmi -query "Select * from win32_logicaldisk where drivetype=3" -ComputerName chi-fp02
gwmi win32_logicaldisk -filter "drivetype=3" -ComputerName chi-fp02

#NOT THIS
gwmi win32_logicaldisk -ComputerName chi-fp02 | 
where { $_.drivetype -eq 3}

#also supports credentials
gwmi win32_logicaldisk -filter "deviceid='c:'" -ComputerName $computers -credential "globomantics\administrator" | 
Select PSComputername,Caption,Size,Freespace

#customize the output
gwmi win32_logicaldisk -filter "deviceid='c:'" -ComputerName $computers -credential "globomantics\administrator" | 
Select PSComputername,Caption,@{Name="SizeGB";
Expression={($_.Size/1gb) -as [int]}},
@{Name="FreeGB";Expression={$_.Freespace/1gb}},
@{Name="PctFree";
Expression={ ($_.freespace/$_.size)*100}}

help wmi

cls