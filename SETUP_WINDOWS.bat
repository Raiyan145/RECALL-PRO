@echo off
setlocal
cd /d "%~dp0"
where flutter >nul 2>nul
if errorlevel 1 (
  echo Flutter SDK was not found in PATH.
  echo Install Flutter and add flutter\bin to PATH, then run this file again.
  pause
  exit /b 1
)

echo Checking Flutter...
flutter --version
if errorlevel 1 goto :fail

echo Getting packages...
flutter pub get
if errorlevel 1 goto :fail

echo Starting RecallPro...
flutter run
if errorlevel 1 goto :fail
exit /b 0

:fail
echo.
echo Setup failed. Read the Flutter error above.
pause
exit /b 1
