
#get local installed modules that have update help
$modules = get-module -ListAvailable | where {$_.HelpInfoUri}

#get remote modules not found locally
$modules+= get-module -list -CimSession chi-core01 | where {$_.name -notin $modules.name -AND $_.HelpInfoUri}

$modules.count

$modules | Save-Help -DestinationPath c:\work\help -Force

#later
get-module -ListAvailable | Update-Help -SourcePath C:\work\help -Force

