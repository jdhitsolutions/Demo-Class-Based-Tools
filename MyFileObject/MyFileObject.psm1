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
    File
    Script
    Text
    Office
    Graphic
    Executable
    System
    Media  
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
        $r = GetFtype -extension $this.Extension
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

    hidden[void]Zip([string]$DestinationFolder) {
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
        "txt|log|xml" { [fileclass]::Text }
        "do[ct](x)?|xls(x)?|p[po]t(x)?|pdf" { [fileclass]::Office }
        "exe|cmd|application" { [fileclass]::Executable }
        "sys|dll" { [fileclass]::System }
        "bmp|jpg|png|tif|gif|jpeg" { [fileclass]::Graphic }
        "mp3|wav|mp4|avi|wmf" {[FileClass]::Media}
        Default {[FileClass]::File}
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
        Path             = $Path 
        DestinationPath  = $Destination 
        CompressionLevel = "Optimal"
        ErrorAction      = "Stop"
    }

    if ($WhatIfPreference) {
        $params.Add("WhatIf", $True)
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
                    Path        = $item.Path
                    Destination = $Destination 
                }
   
                #pass these on to the internal function
                if ($WhatIfPreference) {
                    $zipParams.Add("WhatIf", $True)
                }

                if ($VerbosePreference -eq "continue") {
                    $zipParams.Add("Verbose", $True)
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

Function Get-MyFileObject {
    [cmdletbinding(DefaultParameterSetName = "path")]
    Param(
        [Parameter(Position = 0, Mandatory, ParameterSetName = "path")]
        [ValidateScript( {Test-Path $_})]
        [string]$Path,
        [Parameter(ParameterSetName = "path")]
        [Switch]$Recurse,

        [Parameter(Position = 1, Mandatory, ParameterSetName = "file")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"

    } #begin

    Process {
        If ($PSCmdlet.ParameterSetName -eq 'path') {
            Write-Verbose "Getting files from $Path"
            Get-Childitem @PSBoundParameters -file | New-MyFileObject
        }
        else {
            Write-Verbose "Getting file $filepath"
            Get-ChildItem -path $filename | New-MyFileObject 
        }
    }

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"

    } #end

}

Function Get-MyFileObjectAge {
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [myFileObject]$MyFileObject
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.MyCommand)"

    } #begin

    Process {
        Write-Verbose "Processing $($MyFileObject.name)"
        $myFileObject | Select Path, Name, Size, Created,
        @{Name = "CreatedAge"; Expression = {$_.getcreatedAge()}},
        Modified,
        @{Name = "ModifiedAge"; Expression = {$_.getmodifiedAge()}}

    }

    End {
        Write-Verbose "Ending $($MyInvocation.MyCommand)"

    } #end


}

#endregion

Export-ModuleMember -Function Get-MyFileObjectAge, Get-MyFileObject,
New-MyFileObject, Update-MyFileObject, Compress-MyFileObject

<#
Next steps:
 Add custom format extensions
 Add custom type extensions
 help documentation
 add a manifest - nothing to declare for the class
 Separate functions from class definition into different files
#>
