@echo off
setlocal enabledelayedexpansion

echo ================================================
echo Mother Earth - Build Standalone EXE (v1.0)
echo Target: F:\motherearth\dist\
echo ================================================

REM Ensure we are in project root
cd /d "%~dp0"

echo [1/5] Installing build dependencies (PyInstaller + runtime)...
pip install --upgrade pip
pip install pyinstaller psutil pillow pystray

echo [2/5] Preparing icon (convert png to multi-res .ico for best Windows support)...
python convert_icon.py || echo "Icon conversion step failed or skipped (non-fatal)"

set ICON_ARG=
if exist "assets\icon.ico" (
    set ICON_ARG=--icon "assets\icon.ico"
) else (
    echo   (No custom icon.ico - using python -m PyInstaller default)
)

echo [3/5] Building MotherEarth.exe (full GUI + CLI + orchestrator)...
python -m PyInstaller --clean --onefile --console ^
    --name "MotherEarth" ^
    %ICON_ARG% ^
    --add-data "assets;assets" ^
    --add-data "src;src" ^
    --hidden-import=pystray ^
    --hidden-import=PIL ^
    --hidden-import=psutil ^
    motherearth.py

echo [4/5] Building MotherEarthLauncher.exe (brief context-menu launcher, no UAC)...
python -m PyInstaller --clean --onefile --console ^
    --name "MotherEarthLauncher" ^
    %ICON_ARG% ^
    --add-data "assets;assets" ^
    launcher.py

echo [5/5] Post-build: copy artifacts and clean...
if not exist "dist" mkdir dist
move /Y "MotherEarth.exe" "dist\" >nul 2>&1 || echo (main exe already in dist or move not needed)
move /Y "MotherEarthLauncher.exe" "dist\" >nul 2>&1 || echo (launcher exe already in dist or move not needed)

echo.
echo ================================================
echo BUILD COMPLETE
echo.
echo Standalone executables:
echo   F:\motherearth\dist\MotherEarth.exe
echo   F:\motherearth\dist\MotherEarthLauncher.exe
echo.
echo Usage (after first run as admin for full setup):
echo   dist\MotherEarth.exe
echo   (Right-click any .exe in Explorer - "Run with Mother Earth")
echo.
echo Tray icon + quick actions are included.
echo 20s monitor default (configurable in %APPDATA%\MotherEarth\config.json).
echo ================================================
pause
endlocal