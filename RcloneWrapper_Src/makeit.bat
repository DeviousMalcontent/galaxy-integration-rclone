@echo off

if not exist RcloneWrapper.rc goto over1
\masm32\bin\rc /v RcloneWrapper.rc
\masm32\bin\cvtres /machine:ix86 RcloneWrapper.res
 :over1
 
if exist "RcloneWrapper.obj" del "RcloneWrapper.obj"
if exist "RcloneWrapper.exe" del "RcloneWrapper.exe"

\masm32\bin\ml /c /coff "RcloneWrapper.asm"
if errorlevel 1 goto errasm

if not exist RcloneWrapper.obj goto nores

\masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF "RcloneWrapper.obj" RcloneWrapper.res
 if errorlevel 1 goto errlink

dir "RcloneWrapper.*"
goto TheEnd

:nores
 \masm32\bin\Link /SUBSYSTEM:WINDOWS /OPT:NOREF "RcloneWrapper.obj"
 if errorlevel 1 goto errlink
dir "RcloneWrapper.*"
goto TheEnd

:errlink
 echo _
echo Link error
goto TheEnd

:errasm
 echo _
echo Assembly Error
goto TheEnd

:TheEnd
move RcloneWrapper.exe ..
pause
