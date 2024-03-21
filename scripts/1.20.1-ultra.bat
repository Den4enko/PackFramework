@echo off
echo [%time%] Building 1.20.1-Ultra...
:: Clean old files
echo [%time%] Cleaning files...
rmdir beta\1.20.1\ /s /q
:: Merge
echo [%time%] Merging...
xcopy development\shared\nano\*.* beta\1.20.1\ /e /Q > nul
xcopy development\shared\ultra\*.* beta\1.20.1\ /e /y /Q > nul
xcopy development\1.20.1\nano\*.* beta\1.20.1\ /e /y /Q > nul
:: Update
echo [%time%] Updating...
cd beta\1.20.1
packwiz refresh > nul
packwiz update --all -y > nul
echo [%time%] Done!