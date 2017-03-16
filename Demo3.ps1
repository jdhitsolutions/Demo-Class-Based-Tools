#requires -version 5.0


#define some properties
#add a constructor or two
#add some methods

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

#demo this version
$f = New-Object MyFileObject -ArgumentList .\Demo1.ps1
$f
$f | get-member
$f.GetCreatedAge()
$f.GetModifiedAge()
$f.GetModifiedAge().ToString()

#modify demo1.ps1
$f.Refresh()

