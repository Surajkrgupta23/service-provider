@echo off
echo ===================================================
echo   COOPERATIVE CLAP - FLUTTER WEB BUILD UPDATER
echo ===================================================
cd /d "%~dp0"
call flutter build web --release --base-href /CP-APPP/service-provider/web/
echo.
echo ===================================================
echo   WEB BUILD UPDATED SUCCESSFULLY!
echo   Open: http://localhost/CP-APPP/service-provider/web/
echo ===================================================
pause
