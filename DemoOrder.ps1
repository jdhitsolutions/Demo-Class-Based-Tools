#it is assumed you are running this file in the PowerShell ISE

return "This is a walk-through demo file not a script to run."

#change folder to demo root
# set-location 'C:\scripts\Demo Class-Based Tools'

psedit .\legacy.ps1
psedit .\classbasics.ps1
psedit .\Demo1.ps1
psedit .\Demo2.ps1
psedit .\Demo3.ps1
psedit .\Demo4.ps1
psedit .\Demo5.ps1
psedit .\MyFileObject\MyFileObject.psm1

#region demo the module

import-module .\MyFileObject\MyFileObject.psm1 -force
get-command -module MyFileObject

help New-MyFileObject
$f = New-MyFileObject .\Samples\bieber.mp4
$f
$f | gm
$f | Compress-MyFileObject -WhatIf

#do an entire folder
$all = dir .\Samples -file | New-MyFileObject
$all | Out-GridView -Title Samples
$all | group fileclass
$all.where({$_.fileclass -eq 'media'}).foreach({Compress-MyFileObject -FileObject $_ -Passthru})

#what are some other ways of getting the same result from this code
$all | Select-Object *,@{Name="AgeCategory";Expression={
    Switch ($_.GetModifiedAge().TotalDays) {
        {$_ -gt 365} {'1YrPlus' ; Break}
        {$_ -gt 180 -AND $_ -le 365} {'1Yr' ; Break}
        {$_ -gt 90 -AND $_ -le 180} {'6Mo' ; Break}
        {$_ -gt 30 -AND $_ -le 90} {'3Mo' ; Break}
        {$_ -gt 7 -AND $_ -le 30} { '1Mo'; Break }
        Default {"New"}
    }
}} | Group AgeCategory

#endregion