$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$mcversion = "1.20.1"
$modpacktype = "ultra"
$outputPath = "$scriptPath\beta\$mcversion-$modpacktype"

# Start
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Building $mcversion-$modpacktype..."

# Clean old files
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Cleaning files..."
Remove-Item -Path "$outputPath\*.*" -Recurse
New-Item -Path "$outputPath" -ItemType Directory -Force

# Merge
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Merging..."
Copy-Item -Path "$scriptPath\development\shared\nano\*" -Destination "$outputPath" -Recurse -Force
Copy-Item -Path "$scriptPath\development\shared\ultra\*" -Destination "$outputPath" -Recurse -Force
Copy-Item -Path "$scriptPath\development\$mcversion\nano\*" -Destination "$outputPath" -Recurse -Force

# Copy Changelog
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Copying Changelog..."
Copy-Item "$scriptPath\CHANGELOG.md" "$outputPath\config\fancymenu\assets\changelog.md"

# Update
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Updating..."
Set-Location "$outputPath"
& packwiz refresh
& packwiz update --all -y

# Finish
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Done!" 
