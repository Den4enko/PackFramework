@echo off
set script=%~dp0
:start
cls
echo [PackFramework Builder]
echo Select version to build:
echo.
echo 1) 1.19.2 Ultra
echo 2) 1.19.2 Nano
echo 3) 1.18.2 Ultra
echo 4) 1.18.2 Nano
echo 5) All Versions
echo.
echo 6) Exit
echo.
set /p input="Enter number: "
cls
if "%input%"=="1" (
    call "scripts/1.19.2-ultra.bat"
) else (
if "%input%"=="2" (
    call "scripts/1.19.2-nano.bat"
) else (
if "%input%"=="3" (
    call "scripts/1.18.2-ultra.bat"
) else (
if "%input%"=="4" (
    call "scripts/1.18.2-nano.bat"
) else (
if "%input%"=="5" (
    call "scripts/1.19.2-ultra.bat"
    cd %script%
    call "scripts/1.19.2-nano.bat"
    cd %script%
    call "scripts/1.18.2-ultra.bat"
    cd %script%
    call "scripts/1.18.2-nano.bat"
    pause
    exit
) else (
if "%input%"=="6" (
    exit
) else (
  echo Invalid Input. Please try one more time.
)
)
)
)
)
)
pause
cd %script%
goto :start