#requires -version 5.0


#define some properties

Class MyFileObject {

    [ValidateNotNullorEmpty()]
    [string]$Path
    [string]$Name
    [string]$Extension
    [string]$Directory
    [int]$Size
    [datetime]$Created
    [datetime]$Modified

}

#load the class into your session
Return

#WALKTHROUGH

#different ways to create a new instance of the object
New-Object MyFileObject

[myfileobject]::new()

[myfileobject]::new() | get-member

