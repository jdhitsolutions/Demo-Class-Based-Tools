
#change folder to demo root
set-location 'C:\scripts\Demo Class-Based Tools'
psedit .\legacy.ps1
psedit .\Demo1.ps1
psedit .\Demo2.ps1
psedit .\Demo3.ps1
psedit .\Demo4.ps1
psedit .\Demo5.ps1
psedit .\MyFileObject\MyFileObject.psm1

import-module .\MyFileObject\MyFileObject.psm1
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