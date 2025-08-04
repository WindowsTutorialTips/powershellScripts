# Load notification module
Import-Module BurntToast

# Configuration
$minMagnitude = 5.5
$regionsOfInterest = @("Turkey", "Japan", "Russia", "Greece", "Iran", "Indonesia")
$logFilePath = "C:\Scripts\earthquake_log.txt"

# Fetch latest significant earthquakes in the past hour
$data = Invoke-RestMethod -Uri "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"

# Exit if no data
if ($data.features.Count -eq 0) {
    Write-Output "No earthquakes in the last hour."
    return
}

# Process each quake
foreach ($quake in $data.features) {
    $place = $quake.properties.place
    $mag = $quake.properties.mag
    $timeRaw = [System.DateTimeOffset]::FromUnixTimeMilliseconds($quake.properties.time).DateTime
    $time = Get-Date $timeRaw -Format "yyyy-MM-dd HH:mm:ss"

    # Filter by magnitude
    if ($mag -lt $minMagnitude) { continue }

    # Filter by location keywords
    $matched = $false
    foreach ($region in $regionsOfInterest) {
        if ($place -like "*$region*") {
            $matched = $true
            break
        }
    }

    if (-not $matched) { continue }

    $message = "Magnitude $mag - $place at $time"
    Write-Output $message

    # Show toast notification
    New-BurntToastNotification -Text "Earthquake Alert", $message

    # Append to log file
    Add-Content -Path $logFilePath -Value $message
}
