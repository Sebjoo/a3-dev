@echo off
setlocal enabledelayedexpansion

set mod=%~1
cd /d %~dp0\..
set basePath=%cd%
cd "%basePath%\cfg"
set /p toolsPath=<toolsPath.txt
set /p clientProfilePath=<clientProfilePath.txt
set /p keyName=<keyName.txt

set modpath=%basePath%\build\mods\%mod%
rmdir "%modpath%" /q /s
xcopy "%basePath%\src\mods\%mod%" "%modpath%" /h /i /c /k /e /r /y
copy "%basePath%\cfg\keys\%keyName%.bikey" "%modpath%" /y

"%toolsPath%\AddonBuilder\AddonBuilder.exe" ^
    "%modpath%\addons\%mod%" ^
    "%modpath%\addons" ^
    -include="%basePath%\cfg\include.lst" ^
    -sign="%basePath%\cfg\keys\%keyName%.biprivatekey" ^
    -clear

rmdir "%modpath%\addons\%mod%" /q /s

exit