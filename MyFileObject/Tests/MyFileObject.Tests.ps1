#Pester Unit Tests

Import-Module ..\MyFileObject

InModuleScope MyFileObject {

Describe MyFileObject -Tags class,base {

Context BaseClass {
     It "Should have 8 items for [FileClass] enum" {
        ([enum]::GetNames([fileclass]) | Measure-Object).Count | Should be 8
     }
     It "Should not expose the underlying class" {
      {New-Object -TypeName MyFileObject } | Should Throw

     }
    } #baseclass context

} #myFileObject
Describe Commands -tags functions {

    Mock -CommandName Get-ChildItem -ParameterFilter {$path -eq "c:\work\myfile.txt"} -MockWith {
          $item = [pscustomobject]@{ 
            BaseName="myfile"
            Name="myfile.txt"
            Length=37
            DirectoryName="C:\work"
            Directory="C:\work"
            IsReadOnly=$False
            Exists=$True
            FullName="C:\work\myfile.txt"
            Extension=".txt"
            CreationTime=[datetime]"2/18/2015 4:15:01 PM"
            CreationTimeUtc=[datetime]"2/18/2015 9:15:01 PM"
            LastAccessTime=[datetime]"2/18/2015 4:15:01 PM"
            LastAccessTimeUtc=[datetime]"2/18/2015 9:15:01 PM"
            LastWriteTime=[datetime]"4/19/2015 6:03:34 PM"
            LastWriteTimeUtc=[datetime]"4/19/2015 11:03:34 PM"
            Attributes="Archive"
            }
            return $item
        } 

    Mock -CommandName Get-ACL -MockWith { 
        return @{Owner = "BUILTIN\Administrators"}
       }

    Mock -CommandName Get-Item -ParameterFilter {$path -eq "c:\work\myfile.txt"} -MockWith {
        $item = [pscustomobject]@{ 
            BaseName="myfile"
            Name="myfile.txt"
            Length=370
            DirectoryName="C:\work"
            Directory="C:\work"
            IsReadOnly=$False
            Exists=$True
            FullName="C:\work\myfile.txt"
            Extension=".txt"
            CreationTime=[datetime]"2/18/2015 4:15:01 PM"
            CreationTimeUtc=[datetime]"2/18/2015 9:15:01 PM"
            LastAccessTime=[datetime]"2/18/2015 4:15:01 PM"
            LastAccessTimeUtc=[datetime]"2/18/2015 9:15:01 PM"
            LastWriteTime=[datetime]"4/19/2016 6:03:34 PM"
            LastWriteTimeUtc=[datetime]"4/19/2016 11:03:34 PM"
            Attributes="Archive"
            }
            return $item
       }

    Mock -CommandName Test-Path -ParameterFilter {$Path -eq "c:\work\myfile.txt"} -MockWith { $True }
    
    #create an object to test with 
    $f = Get-ChildItem -path 'c:\work\myfile.txt' | New-MyFileObject   
    Context "Testing New-MyFileObject" {
       
<#
#some tests to verify mocking is working properly
    It "mocking should work" {
     { get-childitem -path 'c:\work\myfile.txt'} | Should not Throw
     (get-childitem -path 'c:\work\myfile.txt').Name | Should be "myfile.txt"
     
    }  
    It "Mocking Get-ACL" {
    (Get-ACL).Owner | should be "BUILTIN\Administrators"
    }      

    It "Mocking Get-Item" {
     {Get-Item -path c:\work\myfile.txt} | should not Throw
    }
#>
        It "New-MyFileObject should throw an exception for a bad path" {
         { New-MyFileObject -Path Z:\Foo123.xyz } | Should Throw
        }

        It "New-MyFileObject should create a MyFileObject via the pipeline" {    
            $f.gettype().Name | Should be "MyFileObject"
        }

        It "object should be named myfile.txt" {
            $f.name | Should be "myfile.txt"      
            $f.basename | Should be "myfile"
        }
        It "object should have an extension of txt" {
            $f.extension | should be 'txt'
        }
        It "object should have a size of 370" {
            $f.size | should be 370
        }
        It "object should have a directory of C:\Work" {
            $f.Directory | Should be "C:\Work"
        }
        It "object should show created 2/18/2015" {
            $f.Created.GetType().Name | Should Be DateTime
            $f.Created.ToShortDateString() | Should be "2/18/2015"
        }
        It "object should show modified 4/19/2016" {
            $f.Modified.ToShortDateString() | Should be "4/19/2016"
        }
        It "object should have a Text file class" {
            $f.fileClass | Should be "Text"
        }
    }
    Context "Testing Update-MyFileObject" {
        It "Update-MyFileObject should refresh without error" {
            {$f | Update-MyFileObject } | Should not Throw
        }
    }
    Context "Testing Compress-MyFileObject" {
        #create a dummy file
        $t = [System.IO.Path]::GetTempFileName()
        Get-Process | Out-File $t

        It "Compress-MyFileObject should create a zip file to the same directory" {
            ($t | New-MyFileObject | Compress-MyFileObject -Passthru | Measure-Object).count | Should be 1
        }

        It "Compress-MyFileObject should create a zip file to a specified directory" {
            $out = Join-Path -Path $env:temp -ChildPath $([System.IO.path]::GetRandomFileName())
            mkdir $out
            ($t | New-MyFileObject | Compress-MyFileObject -DestinationPath $out -Passthru | Measure-Object).count | Should be 1
            (dir $out | Measure-Object).count | should be 1
            del $out -Recurse -Force
        }

        It "Compress-MyFileObject should fail to create a zip with a bad destination" {
          { 
            $n = New-MyFileObject -Path C:\windows\notepad.exe 
            $n | Compress-MyFileObject -DestinationPath Q:\F00 } | Should Throw
        }
    
        #clean up
        if (Test-Path $t) { del $t}

    } 
    Context "Testing object methods" {
        Mock Get-Date -MockWith { [datetime]"4/25/2016 12:00PM"}

        It "GetFileType() method should work" {
            $f.GetFileType() | Should be "txtfile"
        }

        It "GetCreatedAge() method should work" {
            $f.getCreatedAge().Days | Should be 431
        }

        It "GetModifiedAge() method should work" {
            $f.GetModifiedAge().Days | Should be 5
        }
    } #methods context

    Context "Testing hidden properties" {
        It "Object should have a computername property" {
         ($f | Get-Member -Name Computername | Measure-Object).count | Should be 0
         ($f | Get-Member -Name Computername -force | Measure-Object).count | Should be 1
         $f.computername | Should be $env:computername
        }
    
        It "Object should have basename property" {
            ($f | Get-Member -Name basename | Measure-Object).count | Should be 0
            ($f | Get-Member -Name basename -force | Measure-Object).count | Should be 1
            $f.basename | should be "myfile"
        }

        It "Object should have Owner property" {
            ($f | Get-Member -Name Owner | Measure-Object).count | Should be 0
            ($f | Get-Member -Name Owner -force | Measure-Object).count | Should be 1
            $f.owner | Should Match "Administrator"
        }

    } #hidden property context

} 

}