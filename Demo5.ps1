#requires -version 5.0


#define some properties
#add a constructor or two
#add some methods
#enhancements and an enumeration
#added tooling around the class and moved methods to external functions
#hide the Zip method

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

    "bat|ps1|psm1|psd1|ps1xml|vbs|wpf"  { [fileclass]::Script }
    "txt|log|xml"                       { [fileclass]::Text }
    "do[ct](x)?|xls(x)?|p[po]t(x)?|pdf" { [fileclass]::Office }
    "exe|cmd|application"               { [fileclass]::Executable }
    "sys|dll"                           { [fileclass]::System }
    "bmp|jpg|png|tif|gif|jpeg"          { [fileclass]::Graphic }
    "mp3|wav|mp4|avi|wmf"               {[FileClass]::Media}
    Default                             { [fileclass]::File }
    }
}

#these functions won't be exposed so I can use non-standard names
Function ZipFile {
    [cmdletbinding()]
    Param(
    [string]$Path,
    [string]$Destination
    ) 

    Try {
        Compress-Archive -Path $Path -DestinationPath $Destination -CompressionLevel Optimal -ErrorAction Stop
    }
    Catch {
        Throw $_
    }
}

Function Get-FType {
    [cmdletbinding()]
    Param([string]$Extension)

    #supress errors for the CMD expression
    $ErrorActionPreference = "SilentlyContinue"
    $result = cmd /c assoc ".$($Extension)"
        if ($result -match "=") {
            $result.split("=")[1]
        }
        else {
            "Unassociated"
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
    [fileclass]$FileClass    
    hidden[string]$Owner     
    hidden[string]$Basename  
    
    #endregion

    #region Methods 
    #these were simple enough to leave internal to the class
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

    #These were moved to external functions
    [string]GetFileType() {
        $r = Get-Ftype -extension $this.Extension
        return $r
    }
    
    #these methods are hidden
    hidden[void]Zip() {
        $destination = Join-Path -Path $this.Directory -ChildPath "$($this.basename).zip"
        ZipFile -Path $this.Path -Destination $destination 
    }

    hidden[void]Zip([string]$DestinationFolder) {
        $destination = Join-Path -Path $DestinationFolder -ChildPath "$($this.basename).zip"
        ZipFile -Path $this.Path -Destination $destination 

    }
    
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

#Walkthrough

$f = New-Object MyFileObject -ArgumentList .\file.txt
$f | Get-Member
$f.zip()
$f.GetFileType()

#use functions
Get-fileclass $f


