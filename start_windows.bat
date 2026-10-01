@echo off
cd /d "%~dp0"
where node >nul 2>nul || (echo Install Node.js 22 or later, then run this file again. & pause & exit /b 1)
where python >nul 2>nul || (echo Install Python 3.10 or later and add it to PATH. & pause & exit /b 1)
call npm ci
if errorlevel 1 (pause & exit /b 1)
call npm run build
if errorlevel 1 (pause & exit /b 1)
call npm run dev
pause
