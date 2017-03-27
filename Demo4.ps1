#requires -version 5.0


#define some properties
#add a constructor or two
#add some methods
#enhancements and an enumeration


#added an enumeration
enum FileClass { 
  Script
  Text
  Office
  Graphic
  Executable
  System
  Media
  File
}

#a helper function
Function Get-FileClass {
[cmdletbinding()]
Param([string]$Extension) 

    Switch -Regex ($Extension) {

    "bat|ps1|psm1|psd1|ps1xml|vbs|wpf" { [fileclass]::Script }
    "txt|log|xml"                      { [fileclass]::Text }
    "doc|xls|ppt|pdf"                  { [fileclass]::Office }
    "exe|cmd|application"              { [fileclass]::Executable }
    "sys|dll"                          { [fileclass]::System }
    "bmp|jpg|png|tif|gif|jpeg"         { [fileclass]::Graphic }
    "mp3|wav|mp4|avi|wmf"              {[FileClass]::Media}
    Default                            { [fileclass]::File }
    }

}

Class MyFileObject {

    #region Properties
    [ValidateNotNullorEmpty()]
    [string]$Path
    [string]$Name
    [string]$Extension
    [string]$Directory
    [int]$Size
    [datetime]$Created
    [datetime]$Modified
    [fileclass]$FileClass    #<----- Added
    hidden[string]$Owner     #<----- Added
    hidden[string]$Basename  #<----- Added
    #endregion

    #region Methods 
    [timespan]GetCreatedAge() {
        $result = (Get-Date) - $this.Created
        Return $result
    }

    [timespan]GetModifiedAge() {
        $result = (Get-Date) - $this.Modified
        Return $result
    }

    [void]Refresh() {
      If (Test-Path -Path $this.path) {
        $item = Get-Item -Path $this.path
        $this.size = $item.Length
        $this.Modified = $item.LastWriteTime
     }
     else {
       Write-Warning "Failed to find $($this.path). Cannot refresh the object."
     }  
    } 

    #vvvvvvvvvvvvvvvvvvvvvvvvvv---NEW---vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv
    [string]GetFileType() {
        $result = cmd /c assoc ".$($this.Extension)"
        if ($result -match "=") {
            Return $result.split("=")[1]
        }
        else {
            return $result
        }
    }

    [void]Zip() {
        $destination = Join-Path -Path $this.Directory -ChildPath "$($this.basename).zip"
        Compress-Archive -Path $this.Path -DestinationPath $destination 
    }

    [void]Zip([string]$DestinationFolder) {
        $destination = Join-Path -Path $DestinationFolder -ChildPath "$($this.basename).zip"
        Compress-Archive -Path $this.Path -DestinationPath $destination 

    }

    #^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    #endregion

    #region Constructors
    MyFileObject([string]$FilePath) {
     If (Test-Path -Path $Filepath) {
        $item = Get-Item -Path $Filepath
        $this.path = $item.fullname
        $this.Name = $item.Name
        $this.Extension = $item.Extension.Substring(1)
        $this.size = $item.Length
        $this.Created = $item.CreationTime
        $this.Modified = $item.LastWriteTime
        $this.Directory = $item.Directory
        $this.owner = ($item | Get-ACL).owner
        $this.Basename = $item.BaseName
        $this.FileClass = Get-FileClass -Extension $item.Extension
     }
     else {
        Write-Warning "Failed to find $filepath"
        #don't create the object
        Break
     }
}
     #endregion

}

cls
Return

#demo this version

$f = New-Object MyFileObject -ArgumentList .\file.txt
$f | get-member

#can use it if you know it on hidden properties
$f.owner

#display it
$f | get-member -Force -MemberType Properties

#try the new methods
$f.GetFileType()

$f.zip()
dir *.zip

#zip to a folder
$f.zip("c:\")
dir C:\*.zip

