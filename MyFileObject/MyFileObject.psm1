#requires -version 5.0

#Previous steps
#define some properties
#add a constructor or two
#add some methods
#enhancements and an enumeration
#added tooling around the class and moved methods to external functions
#created a module 

#DEMO THIS IN A NEW CONSOLE SESSION

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
    hidden[string]$Computername = $env:Computername 

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

    [string]GetFileType() {
        #call the private helper function
        $r = Get-Ftype -extension $this.Extension
        return $r
    }

    <#
    these hidden methods use the private helper function. I 
    will use public functions to expose them in a controlled manner.
    #>
    hidden[void]Zip() {
        $destination = Join-Path -Path $this.Directory -ChildPath "$($this.basename).zip"
        ZipFile -Path $this.Path -Destination $destination 
    }

    [void]Zip([string]$DestinationFolder) {
        $destination = Join-Path -Path $DestinationFolder -ChildPath "$($this.basename).zip"
        ZipFile -Path $this.Path -Destination $destination 

    }

    #endregion

    #region Constructors
    MyFileObject([string]$FilePath) {
     If (Test-Path -Path $Filepath) {
        write-Verbose "Getting file information from $filepath"
        $item = Get-Item -Path $Filepath
        $this.path = $item.fullname
        $this.Name = $item.Name
        #added code to handle files without extensions
        $this.Extension = If ($item.Extension) {$item.Extension.Substring(1)} else {$Null}
        $this.size = $item.Length
        $this.Created = $item.CreationTime
        $this.Modified = $item.LastWriteTime
        $this.Directory = $item.Directory
        Write-Verbose "Getting owner from the ACL"
        $this.owner = ($item | Get-ACL).owner
        $this.Basename = $item.BaseName
        #call a private function
        Write-Verbose "Getting file class information"
        $this.FileClass = GetFileClass -Extension $item.Extension
     }
     else {
        Write-Warning "Failed to find $filepath."
        #don't create the object
        Break
     }
 
    }

    #endregion

} #end class definition

#region private helper functions
#these functions won't be exposed so I can use non-standard names

Function GetFileClass {
[cmdletbinding()]
Param([string]$Extension) 

    Switch -Regex ($Extension) {
        "bat|ps1|psm1|psd1|ps1xml|vbs|wpf" { [fileclass]::Script }
        "txt|log|xml"                      { [fileclass]::Text }
        "doc|xls|ppt|pdf"                  { [fileclass]::Office }
        "exe|cmd|application"              { [fileclass]::Executable }
        "sys|dll"                          { [fileclass]::System }
        "bmp|jpg|png|tif|gif|jpeg"         { [fileclass]::Graphic }
        "wmv|mp4|avi|mp3|wav"              { [fileclass]::Media }
        Default                            { [fileclass]::File }
    }
}

Function ZipFile {
[cmdletbinding(SupportsShouldProcess)]
Param(
[string]$Path,
[string]$Destination
) 
    Write-Verbose "Starting $($MyInvocation.MyCommand)"

    $params = @{
    Path = $Path 
    DestinationPath = $Destination 
    CompressionLevel = "Optimal"
    ErrorAction = "Stop"
    }

    if ($WhatIfPreference) {
        $params.Add("WhatIf",$True)
    }
    Try {
      Compress-Archive @params
    }
    Catch {
        Throw $_
    }
    Write-Verbose "Ending $($MyInvocation.MyCommand)"

}

Function GetFType {
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

#endregion

#region Public functions for my class that will be exported in the module

Function New-MyFileObject {
[cmdletbinding()]
Param(
[Parameter(
Mandatory,
HelpMessage = "Enter the path to a file",
ValueFromPipeline,
ValueFromPipelineByPropertyName
)]
[Alias("fullname")]
[ValidateNotNullorEmpty()]
[string[]]$Path

)

Begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
} #begin
Process {
    foreach ($item in $Path) {
        if (Test-Path -path $item) {
            Write-Verbose "Creating MyFileObject for $item"
            Try {
                New-Object MyFileObject $item -ErrorAction Stop
            }
            Catch {
                Write-Warning "Error creating object for $item. $($_.exception.message)"
            }
        }
        else {
            Throw $_
        }
    }
} #process

End {
   Write-Verbose "Ending $($MyInvocation.MyCommand).name"

} #end
}

Function Update-MyFileObject {
[cmdletbinding()]
Param(
[Parameter(
Mandatory,
ValueFromPipeline
)]
[ValidateNotNullOrEmpty()]
[MyFileObject[]]$FileObject
)

Begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
} #begin
Process {
foreach ($item in $FileObject) {
    Write-Verbose "Refreshing MyFileObject $($item.name)"
    $item.refresh()

}
} #process

End {
   Write-Verbose "Ending $($MyInvocation.MyCommand)"

} #end
}

Function Compress-MyFileObject {
[cmdletbinding(SupportsShouldProcess)]
Param(
[Parameter(
Mandatory,
ValueFromPipeline
)]
[ValidateNotNullOrEmpty()]
[MyFileObject[]]$FileObject,
[string]$DestinationPath,
[switch]$Passthru
)

Begin {
    Write-Verbose "Starting $($MyInvocation.MyCommand)"
} #begin
Process {
foreach ($item in $FileObject) {
    Write-Verbose "Processing $($item.path)"
    if (-Not $DestinationPath) {
        $DestinationPath = $item.Directory
    }
   
   Write-Verbose "Testing destination path: $DestinationPath"
   If (Test-Path -Path $DestinationPath) {
      Write-Verbose "Zipping MyFileObject $($item.name) to $DestinationPath"
  
       $Destination = Join-path -Path $DestinationPath -ChildPath "$($item.basename).zip"
       $zipParams = @{
        Path = $item.Path
        Destination = $Destination 
       }
   
       #pass these on to the internal function
       if ($WhatIfPreference) {
        $zipParams.Add("WhatIf",$True)
       }

       if ($VerbosePreference -eq "continue") {
        $zipParams.Add("Verbose",$True)
       }

       #Call the internal function directly
       Write-Verbose "Invoking ZipFile()"
       ZipFile @zipParams

        if ($passthru -AND (-NOT $WhatIfPreference)) {
            Get-Item -Path $destination

        }
      } #if Test-Path $DestinationPath
      else {
        Throw "Exception for $($MyInvocation.MyCommand) : Can't find $DestinationPath"
      }
} #foreach
} #process

End {
   Write-Verbose "Ending $($MyInvocation.MyCommand)"

} #end
}

#endregion

Export-ModuleMember -Function New-MyFileObject,Update-MyFileObject,Compress-MyFileObject

<#
Next steps:
 Add custom format extensions
 Add custom type extensions
 help documentation
 add a manifest - nothing to declare for the class
 Separate functions from class definition into different files
#>
