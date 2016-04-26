#the legacy approach that we've always used

$file = get-item .\Demo1.ps1

#create a hashtable of property names for a new object
$propHash = @{
  Path = $file.FullName
  Name = $file.Name
  Extension = $file.Extension.Substring(1)
  Directory = $file.Directory
  Size = $file.Length
  Created = $file.CreationTime
  Modified = $file.LastWriteTime
}

#create a custom object
$obj = New-Object -TypeName PSObject -Property $propHash

#insert a type name
$obj.psobject.TypeNames.Insert(0,"myFileObject")

#add members
$obj | Add-Member -MemberType ScriptMethod -Name GetCreatedAge -Value {(Get-Date) - $this.Created}
$obj | Add-Member -MemberType ScriptMethod -Name GetModifiedAge -Value {(Get-Date) - $this.Modified}

#look at the object
$obj
$obj | Get-Member
#invoke a custom method
$obj.GetCreatedAge()


