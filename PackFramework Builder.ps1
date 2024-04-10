$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

    Write-Host "[PackFramework Builder]"
    Write-Host "Select version to build:"
    Write-Host
    Write-Host "1) (Don't use!) All Versions"
    Write-Host "2) Forge 1.20.1 Ultra"
    Write-Host "3) Forge 1.20.1 Nano"
    Write-Host "4) Forge 1.19.2 Ultra"
    Write-Host "5) Forge 1.19.2 Nano"
    Write-Host "6) Forge 1.18.2 Ultra"
    Write-Host "7) Forge 1.18.2 Nano"
    Write-Host
    Write-Host "8) Exit"
    Write-Host

    $type = Read-Host -Prompt "Enter number: "
    Clear-Host

    switch ($type) {
    "2" {
            $mcversion = "1.20.1"
            $modpacktype = "ultra"
            $modloader = "forge"
        }
    "3" {
            $mcversion = "1.20.1"
            $modpacktype = "nano"
            $modloader = "forge"
        }
    "4" {
            $mcversion = "1.19.2"
            $modpacktype = "ultra"
            $modloader = "forge"
        }
    "5" {
            $mcversion = "1.19.2"
            $modpacktype = "nano"
            $modloader = "forge"
        }
    "6" {
            $mcversion = "1.18.2"
            $modpacktype = "ultra"
            $modloader = "forge"
        }
    "7" {
            $mcversion = "1.18.2"
            $modpacktype = "nano"
            $modloader = "forge"
        }

        "1" { 
        Start-Process -FilePath "$scriptPath\scripts\1.20.1-ultra.bat"
        Start-Process -FilePath "$scriptPath\scripts\1.20.1-nano.bat"
        Start-Process -FilePath "$scriptPath\scripts\1.19.2-ultra.bat"
        Start-Process -FilePath "$scriptPath\scripts\1.19.2-nano.bat"
        Start-Process -FilePath "$scriptPath\scripts\1.18.2-ultra.bat"
        Start-Process -FilePath "$scriptPath\scripts\1.18.2-nano.bat"
        exit 
            }
        "8" { exit }
        default { 
            Write-Host "Invalid Input. Please try one more time." -ForegroundColor Red
                }
                    }
# Start
$outputPath = "$scriptPath\beta\$modloader\$mcversion\$modpacktype"
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Building $mcversion-$modpacktype..."

# Clean old files
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Cleaning files..."
Remove-Item -Path "$outputPath\*.*" -Recurse
New-Item -Path "$outputPath" -ItemType Directory -Force

# Merge
Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Merging..."
Copy-Item -Path "$scriptPath\source\$modloader\shared\nano\*" -Destination "$outputPath" -Recurse -Force
if ($modpacktype -eq 'ultra') {
    Copy-Item -Path "$scriptPath\source\$modloader\shared\ultra\*" -Destination "$outputPath" -Recurse -Force
}
Copy-Item -Path "$scriptPath\source\$modloader\$mcversion\nano\*" -Destination "$outputPath" -Recurse -Force

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