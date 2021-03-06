#demo help

help Update-Help

Update-Help -Force

help Save-Help

Save-Help -DestinationPath \\chi-fp02\PSHelp -Force

#update help for a single module for the sake of the demo
Update-Help -SourcePath \\chi-fp02\PSHelp -Module ISE

#how to use help
help *service

help Get-Service
help Get-Service -Full
help Get-Service -Examples
help Get-Service -ShowWindow
help get-service -online

#also works for aliases
help dir
help get-childitem

#search for everything PowerShell related
help powershell

#or find the about topics
help about*

#only need to type enough of the topic name so PowerShell knows what you mean
help about_run

#can also use -ShowWindows
help about_run -ShowWindow

cls