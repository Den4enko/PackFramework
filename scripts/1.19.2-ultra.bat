@echo off
echo [%time%] Building 1.19.2-Ultra...
:: Clean old files
echo [%time%] Cleaning files...
rmdir beta\1.19.2\ /s /q
:: Merge
echo [%time%] Merging...
xcopy development\shared\nano\*.* beta\1.19.2\ /e /Q > nul
xcopy development\shared\ultra\*.* beta\1.19.2\ /e /y /Q > nul
xcopy development\1.19.2\nano\*.* beta\1.19.2\ /e /y /Q > nul
:: Update
echo [%time%] Updating...
cd beta\1.19.2
packwiz refresh > nul
packwiz update --all -y > nul
echo [%time%] Done!
@pause