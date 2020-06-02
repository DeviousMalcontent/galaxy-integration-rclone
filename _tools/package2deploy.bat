@echo off
Rem Package plugin to deploy

Rem SETLOCAL EnableDelayedExpansion EnableExtensions 
Rem for /f "Tokens=* Delims=" %%x in (../manifest.json) do set pluginFolder=!pluginFolder!%%x
Rem echo %pluginFolder:~67,36%
SETLOCAL EnableDelayedExpansion EnableExtensions 
for /f "Tokens=* Delims=" %%x in (../plugin.py) do set pluginFolder=!pluginFolder!%%x
set pluginFolder=%pluginFolder:~4767,48%
echo %pluginFolder%
set pluginFolderLoc=%localappdata%\GOG.com\Galaxy\plugins\installed\%pluginFolder%
echo %pluginFolderLoc%


if exist %localappdata%\GOG.com\Galaxy\plugins\installed\%pluginFolder% (
    echo  file exists
) else (
    echo file doesn't exist
)

pause
