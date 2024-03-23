@echo off
echo [%time%] Building 1.18.2-Ultra...
:: Clean old files
echo [%time%] Cleaning files...
rmdir beta\1.18.2\ /s /q
:: Merge
echo [%time%] Merging...
xcopy development\shared\nano\*.* beta\1.18.2\ /e /Q > nul
xcopy development\shared\ultra\*.* beta\1.18.2\ /e /y /Q > nul
xcopy development\1.18.2\nano\*.* beta\1.18.2\ /e /y /Q > nul
:: Copy Changelog
echo [%time%] Copying Changelog...
copy CHANGELOG.md beta\1.18.2\config\fancymenu\assets\changelog.md > nul
:: Update
echo [%time%] Updating...
cd beta\1.18.2
packwiz refresh > nul
packwiz update --all -y > nul
echo [%time%] Done!