$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Define the function to build a modpack
function Select-Version {
# Prompt the user to select a version to build
Write-Host "[PackFramework Builder]" -ForegroundColor Green
Write-Host "Select version to build:"
Write-Host
Write-Host "0) Copy Beta folder to Release"
Write-Host
Write-Host "1) All Forge Versions"
Write-Host "2) Forge 1.20.1 Ultra"
Write-Host "3) Forge 1.20.1 Nano"
Write-Host "4) Forge 1.19.2 Ultra"
Write-Host "5) Forge 1.19.2 Nano"
Write-Host "6) Forge 1.18.2 Ultra"
Write-Host "7) Forge 1.18.2 Nano"
Write-Host
Write-Host "8) Exit"
Write-Host

# Read the user's input
$selectedMCVersion = Read-Host -Prompt "Enter number"
if ($selectedMCVersion -eq '8') {
    exit
}
if (!$selectedMCVersion -eq '0') {
$lastVersion = Get-Content -Path "$scriptPath/beta/lastVersion.txt"
$selectedMPVersion = Read-Host -Prompt "Select new modpack version (Press Enter to keep $lastVersion)"
if ([string]::IsNullOrWhiteSpace($selectedMPVersion)) {
    $selectedMPVersion = $lastVersion
}
$selectedMPVersion | Out-File -FilePath $scriptPath/beta/lastVersion.txt
}
Clear-Host



# Switch statement to handle the user's input
switch ($selectedMCVersion) {
    "0" {
        Remove-Item -Path "release" -Recurse -Include *.*
        Copy-Item -Path "beta\*" -Destination "release" -Recurse -Force
        Remove-Item -Path "release\lastVersion.txt"
        exit
    }
    "1" { 
        $mcversion = "1.20.1"
        $modpacktype = "ultra"
        $modloader = "forge"
        Build-Modpack

        $mcversion = "1.20.1"
        $modpacktype = "nano"
        $modloader = "forge"
        Build-Modpack

        $mcversion = "1.19.2"
        $modpacktype = "ultra"
        $modloader = "forge"
        Build-Modpack

        $mcversion = "1.19.2"
        $modpacktype = "nano"
        $modloader = "forge"
        Build-Modpack

        $mcversion = "1.18.2"
        $modpacktype = "ultra"
        $modloader = "forge"
        Build-Modpack

        $mcversion = "1.18.2"
        $modpacktype = "nano"
        $modloader = "forge"
        Build-Modpack

        exit 
    }
    "2" {
        # Set the variables for the modpack to be built
        $mcversion = "1.20.1"
        $modpacktype = "ultra"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
    "3" {
        # Set the variables for the modpack to be built
        $mcversion = "1.20.1"
        $modpacktype = "nano"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
    "4" {
        # Set the variables for the modpack to be built
        $mcversion = "1.19.2"
        $modpacktype = "ultra"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
    "5" {
        # Set the variables for the modpack to be built
        $mcversion = "1.19.2"
        $modpacktype = "nano"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
    "6" {
        # Set the variables for the modpack to be built
        $mcversion = "1.18.2"
        $modpacktype = "ultra"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
    "7" {
        # Set the variables for the modpack to be built
        $mcversion = "1.18.2"
        $modpacktype = "nano"
        $modloader = "forge"

        # Build the modpack
        Build-Modpack
        Select-Version
    }
}
}
function Build-Modpack {

    # Set the output path based on the modloader, Minecraft version, and modpack type
    $outputPath = "$scriptPath\beta\$modloader\$mcversion\$modpacktype"

    # Display a message indicating that the build is starting
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Building $mcversion-$modpacktype..."

    # Clean up any old files in the output path
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Cleaning files..."
    if (Test-Path -PathType Container $outputPath) {
        Remove-Item -Path $outputPath -Recurse -Include *.*
    } else {
        New-Item -ItemType Directory -Path $outputPath
    }
    # Merge the necessary files into the output path
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Merging..."
    Copy-Item -Path "$scriptPath\source\$modloader\shared\nano\*" -Destination "$outputPath" -Recurse -Force
    if ($modpacktype -eq 'ultra') {
        Copy-Item -Path "$scriptPath\source\$modloader\shared\ultra\*" -Destination "$outputPath" -Recurse -Force
    }
    Copy-Item -Path "$scriptPath\source\$modloader\$mcversion\nano\*" -Destination "$outputPath" -Recurse -Force

    # Change the versions
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Changing versions..."
    
    (Get-Content "$outputPath/pack.toml") | ForEach-Object { $_ -replace "noVersion", "$selectedMPVersion" } | Set-Content "$outputPath/pack.toml"
    (Get-Content "$outputPath/config/fancymenu/custom_locals/meta/en_us.local") | ForEach-Object { $_ -replace "noVersion", "$selectedMPVersion" } | Set-Content "$outputPath/config/fancymenu/custom_locals/meta/en_us.local"

    # Copy the changelog to the output path
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Copying Changelog..."
    Copy-Item "$scriptPath\CHANGELOG.md" "$outputPath\config\fancymenu\assets\changelog.md"

    # Update the modpack using packwiz
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Updating..."
    Set-Location "$outputPath"
    & packwiz refresh
    & packwiz update --all -y

    # Display a message indicating that the build is complete
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Done!"

}
Select-Version