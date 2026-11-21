@echo off
echo ===================================================
echo   COOPERATIVE CLAP - FLUTTER LIVE DEV SERVER (HOT RELOAD)
echo ===================================================
cd /d "%~dp0"
call flutter run -d chrome
pause
