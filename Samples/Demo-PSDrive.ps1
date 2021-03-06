#demo PSDrives and Providers

Get-PSDrive
#let's navigate
#save current location using an alias for Push-Location
pushd
cd c:\
dir
help dir
dir c:\scripts
dir C:\scripts -file
dir C:\scripts -Directory
dir c:\scripts -Recurse
cd '.\Program Files\windows defender'
dir *.exe
#registry
cd hklm:
dir
cd '.\SOFTWARE\Microsoft\Windows NT'
dir
cd \
dir env:\
#easy way to reference variables
$env:COMPUTERNAME
cd c:\
help new-psdrive 
new-psdrive -Name Sales -PSProvider FileSystem -Root \\chi-fp02\SalesData
cd sales:
dir *.pdf
#return back to starting location
popd

Get-PSProvider
dir Cert:\LocalMachine\my
help Certificate

#known bug with provider help and showwindow
help Certificate -ShowWindow

cls

