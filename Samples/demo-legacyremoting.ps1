#demo legacy remoting

#these commands run locally and query remote computers
get-service adws -ComputerName chi-dc04

#define a variable of domain controller names
$dcs = 'chi-dc04','chi-dc01','chi-dc02'

get-service adws,dns -ComputerName $dcs | 
Select DisplayName,Status,Machinename

get-process Microsoft* -ComputerName $dcs | 
Select Machinename,Name,ID,Handles,VM,WS

get-eventlog "Active Directory Web Services" -ComputerName $dcs -EntryType Error,Warning -Newest 10 | 
Select Machinename,TimeGenerated,EntryType,Message | 
out-gridview -title "AD Logs"
