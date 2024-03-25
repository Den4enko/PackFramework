@echo off
echo [%time%] Building 1.18.2-Nano...
:: Clean old files
echo [%time%] Cleaning files...
rmdir beta\1.18.2-nano\ /s /q
:: Merge
echo [%time%] Merging...
xcopy development\shared\nano\*.* beta\1.18.2-nano\ /e /Q > nul
xcopy development\1.18.2\nano\*.* beta\1.18.2-nano\ /e /y /Q > nul
:: Copy Changelog
echo [%time%] Copying Changelog...
copy CHANGELOG.md beta\1.18.2-nano\config\fancymenu\assets\changelog.md > nul
:: Update
echo [%time%] Updating...
cd beta\1.18.2-nano
packwiz refresh > nul
packwiz update --all -y > nul
echo [%time%] Done!