@echo off
:: Clean old files
echo [%time%] Cleaning 1.19.2-Nano files...
rmdir beta\1.19.2-nano\ /s /q
:: Merge
echo [%time%] Merging 1.19.2-Nano...
xcopy development\shared\nano\*.* beta\1.19.2-nano\ /e /Q > nul
xcopy development\1.19.2\nano\*.* beta\1.19.2-nano\ /e /y /Q > nul
:: Update
echo [%time%] Updating...
cd beta\1.19.2-nano
packwiz refresh > nul
packwiz update --all -y > nul
echo [%time%] Done!
@pause