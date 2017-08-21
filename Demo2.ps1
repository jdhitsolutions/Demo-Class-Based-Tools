#requires -version 5.0


#define some properties
#add a constructor or two

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
     }
     else {
        Write-Warning "Failed to find $filepath"
        #don't create the object
        Break
     }

    }
    
    #endregion
}

Return

#walkthrough demo
cls

[myfileobject]::new.overloadDefinitions

$f = New-Object MyFileObject -ArgumentList .\Demo1.ps1
$f
$f | get-member

#test bad path
[MyFileObject]::New("x:\foo.txt")

#creating several objects
dir .\ -File | foreach { New-Object myfileobject $_.FullName}