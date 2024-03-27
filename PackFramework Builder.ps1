$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

:start
do {
    Clear-Host
    Write-Host "[PackFramework Builder]"
    Write-Host "Select version to build:"
    Write-Host
    Write-Host "1) All Versions"
    Write-Host "2) 1.20.1 Ultra"
    Write-Host "3) 1.20.1 Nano"
    Write-Host "4) 1.19.2 Ultra"
    Write-Host "5) 1.19.2 Nano"
    Write-Host "6) 1.18.2 Ultra"
    Write-Host "7) 1.18.2 Nano"
    Write-Host
    Write-Host "8) Exit"
    Write-Host

    $type = Read-Host -Prompt "Enter number: "
    Clear-Host

    switch ($type) {
        "2" { Start-Process -FilePath "$scriptPath\scripts\1.20.1-ultra.bat" -Wait }
        "3" { Start-Process -FilePath "$scriptPath\scripts\1.20.1-nano.bat" -Wait }
        "4" { Start-Process -FilePath "$scriptPath\scripts\1.19.2-ultra.bat" -Wait }
        "5" { Start-Process -FilePath "$scriptPath\scripts\1.19.2-nano.bat" -Wait }
        "6" { Start-Process -FilePath "$scriptPath\scripts\1.18.2-ultra.bat" -Wait }
        "7" { Start-Process -FilePath "$scriptPath\scripts\1.18.2-nano.bat" -Wait }

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

    Read-Host -Prompt "Press Enter to continue..."
} while ($true) 
