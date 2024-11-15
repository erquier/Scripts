@echo off
echo %~d0
echo %~dp0
set letra=%~d0
set ruta=%~dp0
%letra%
cd %ruta%
powershell.exe -executionpolicy bypass -file Unlock_AD_Account_V2.ps1
pause