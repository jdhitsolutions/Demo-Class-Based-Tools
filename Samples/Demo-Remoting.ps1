#demo remoting

#run these interactively
# enable-psremoting
# test-wsman chi-core01
# enter-pssession chi-core01

help invoke-command -ShowWindow

invoke-command -scriptblock { dir c:\ -Hidden} -computer chi-core01,chi-fp02

help New-PSSession

$computers = "chi-core01","chi-dc01","chi-dc02","chi-dc04","chi-hvr2"
$sessions = new-pssession $computers
$sessions

Get-PSSession
#could do this:
get-process lsass -ComputerName $computers
#this scales better and is faster
invoke-command {get-process lsass } -Session $sessions

#sometimes things only work locally in PS v4
help Get-Process
get-process -IncludeUserName
#this will fail
get-process -ComputerName chi-hvr2 -includeusername

#run it remotely
invoke-command {get-process -includeusername} -ComputerName chi-hvr2

#or run scripts
#This version will hide the computername and 
#runspaceId
invoke-command -FilePath S:\Get-DriveUtilization.ps1 -session $sessions -HideComputerName | 
Select * -excludeproperty RunspaceID |
Out-Gridview -Title "Drive Report"

#sessions will remain until you close PowerShell. Or manually remove them.
Get-PSSession | Remove-PSSession

#demo remoting in the ISE

help psremoting
help about_remote*

cls
