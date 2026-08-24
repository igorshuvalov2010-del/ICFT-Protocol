@echo off
setlocal
cd /d "%~dp0"
if not exist .env copy .env.example .env >nul
echo.
echo ICFT Frontend
 echo 1. Put your deployed contract addresses into .env
 echo 2. Then this script will install dependencies and start Vite.
echo.
npm install
if errorlevel 1 (
  echo npm install failed. Make sure Node.js 20+ and npm are installed.
  pause
  exit /b 1
)
npm run dev
pause
