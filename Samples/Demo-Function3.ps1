#requires -version 3.0

#this is a complete advanced function 

Function Get-MyComputer {

<#
.Synopsis
Get corporate server information.
.Description
This command uses WMI to retrieve basic server information.
.Example
PS C:\> get-mycomputer chi-dc01
.Example
PS C:\> get-content c:\work\servers.txt | get-mycomputer | export-csv c:\work\chidata.csv

#>

[cmdletbinding()]

Param(
[Parameter(Mandatory=$true,
HelpMessage="Enter computer name",
ValueFromPipeline=$true)]
#[ValidatePattern("^chi-")]
[string[]]$Computername
)

Begin {
    Write-Verbose "Getting my computer information"
}

Process {
foreach ($computer in $computername) {
    Write-Verbose "Processing $($Computer.toUpper())"
    Try {
      #get Operating system information
      $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $computer -ErrorAction Stop
      
      #if no error get logical disk information
      if ($os) {
        Write-Verbose "...querying Drive C:"
        $C = Get-WmiObject -Class win32_logicaldisk -filter "DeviceID='c:'" -ComputerName $OS.CSName
      } #if $os
      #create a custom object 
      $LastBoot = $OS.ConvertToDateTime($OS.LastBootUpTime)
      #format last boot time
      $myObj = [ordered]@{
        Computername = $OS.CSName
        OS= $OS.Caption
        SvcPack=$OS.CSDVersion
        LastBoot= $LastBoot
        Uptime= (Get-Date) - $LastBoot
       '%Free'= [math]::Round(($C.freespace/$c.size)*100,2)
    }
      #write the custom object to the pipeline
      New-Object -TypeName PSObject -Property $myObj
    } #Try
    Catch {
        Write-Warning "Failed to get computer information from $($computer.toUpper())"
    } #Catch
 } #foreach computer
} #Process

End {
    Write-Verbose "Ending computer information function"
} #end

} #end function