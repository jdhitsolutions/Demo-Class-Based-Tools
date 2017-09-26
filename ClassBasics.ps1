
return "This is a walkthrough demo file, not a script."

Class MyStarShip {
#properties
    [string]$Name
    [int]$Crew
    [datetime]$ManufactureDate
    [int]$QuantumTorpedoCount

#methods
#must define what they write to the pipeline, if anything
[void]FireTorpedo() {
    Write-Host "Fire!" -ForegroundColor Red
    $this.QuantumTorpedoCount--
}
[void]FireTorpedo([int]$Count) {
    Write-Host "Fire $Count!!" -ForegroundColor Red
    $this.QuantumTorpedoCount-=$Count
}
[timespan]GetAge() {
    $age = (Get-Date).AddYears(123) - $this.ManufactureDate
    #methods must use RETURN is writing something to the pipeline
    return $age
}

#constructors
myStarShip([string]$Name,[int]$CrewSize) {
    $this.name = $Name
    $this.Crew = $CrewSize
    $this.QuantumTorpedoCount = 50
    $this.ManufactureDate = (Get-Date).AddYears(120).AddMonths(4).AddDays(3)
}
}

[MyStarShip]::new
[MyStarShip]::new("Proxima",20)

$ship = new-object -TypeName MyStarShip -ArgumentList "USS Snover",100
$ship
$ship | get-member

$ship.GetAge()
$ship.GetAge().ToString()

$ship
$ship.FireTorpedo()
$ship.FireTorpedo(3)
$ship.QuantumTorpedoCount

#have more fun with starships at https://github.com/jdhitsolutions/myStarShip