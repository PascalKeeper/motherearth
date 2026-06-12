@echo off
setlocal enabledelayedexpansion

:: Mother Earth - User End Installer
:: Run this as Administrator for best results (context menu for all users, Start Menu, etc.)
:: It will install the standalone .exe files, register "Run with Mother Earth" context menu,
:: create a Start Menu shortcut, and set up an easy uninstall.

echo ================================================
echo Mother Earth Installer
echo ================================================
echo.

:: Determine install location (prefer Program Files, fallback to user local)
set "INSTALL_DIR=%ProgramFiles%\Mother Earth"
set "USE_LOCAL=0"

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo WARNING: Not running as Administrator.
    echo Installing to user-local folder instead: %LocalAppData%\Mother Earth
    set "INSTALL_DIR=%LocalAppData%\Mother Earth"
    set "USE_LOCAL=1"
    timeout /t 3 >nul
)

echo Installing to: %INSTALL_DIR%
echo.

:: Create directories
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%INSTALL_DIR%\assets" mkdir "%INSTALL_DIR%\assets"

:: Copy the pre-built standalone executables (the only thing users need)
echo Copying executables...
copy /Y "dist\MotherEarth.exe" "%INSTALL_DIR%\" >nul
copy /Y "dist\MotherEarthLauncher.exe" "%INSTALL_DIR%\" >nul

:: Copy the standalone Emergency Restore script (critical safety net)
copy /Y "EmergencyRestore.bat" "%INSTALL_DIR%\" >nul

:: Copy icon for potential future use / shortcuts
if exist "assets\icon.ico" (
    copy /Y "assets\icon.ico" "%INSTALL_DIR%\assets\" >nul
)

:: Register the context menu pointing to the *installed* launcher
echo Registering "Run with Mother Earth" context menu...
set "LAUNCHER=%INSTALL_DIR%\MotherEarthLauncher.exe"
reg add "HKCU\Software\Classes\exefile\shell\MotherEarth" /ve /d "Run with Mother Earth" /f >nul
reg add "HKCU\Software\Classes\exefile\shell\MotherEarth\command" /ve /d "\"%LAUNCHER%\" \"%%1\"" /f >nul
reg add "HKCU\Software\Classes\exefile\shell\MotherEarth" /v "Icon" /d "\"%INSTALL_DIR%\MotherEarth.exe\",0" /f >nul 2>nul

echo Context menu registered for current user.

:: Create Start Menu shortcut (using PowerShell for reliability)
echo Creating Start Menu shortcut...
set "SHORTCUT=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Mother Earth.lnk"
powershell -NoProfile -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%SHORTCUT%'); $s.TargetPath='%INSTALL_DIR%\MotherEarth.exe'; $s.IconLocation='%INSTALL_DIR%\MotherEarth.exe,0'; $s.WorkingDirectory='%INSTALL_DIR%'; $s.Save()" >nul 2>&1

:: Optional: offer to start the tray/monitor on login (commented by default for safety)
:: reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MotherEarthTray" /d "\"%INSTALL_DIR%\MotherEarth.exe\" --monitor --minimized" /f >nul 2>&1

:: Create proper Add/Remove Programs entry + uninstall helper
echo Creating Add/Remove Programs entry and uninstaller...

:: Determine which registry hive to use for ARP
if %USE_LOCAL%==0 (
    set "ARP_ROOT=HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MotherEarth"
) else (
    set "ARP_ROOT=HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\MotherEarth"
)

reg add "%ARP_ROOT%" /v "DisplayName" /d "Mother Earth" /f >nul
reg add "%ARP_ROOT%" /v "UninstallString" /d "\"%INSTALL_DIR%\MotherEarth.exe\" --uninstall" /f >nul
reg add "%ARP_ROOT%" /v "QuietUninstallString" /d "\"%INSTALL_DIR%\MotherEarth.exe\" --uninstall --silent" /f >nul
reg add "%ARP_ROOT%" /v "DisplayIcon" /d "\"%INSTALL_DIR%\MotherEarth.exe\",0" /f >nul
reg add "%ARP_ROOT%" /v "Publisher" /d "Joseph Peransi" /f >nul
reg add "%ARP_ROOT%" /v "InstallLocation" /d "%INSTALL_DIR%" /f >nul
reg add "%ARP_ROOT%" /v "NoModify" /t REG_DWORD /d 1 /f >nul
reg add "%ARP_ROOT%" /v "NoRepair" /t REG_DWORD /d 1 /f >nul

:: Create the uninstall helper (now triggers full system restore via the .exe)
(
echo @echo off
echo echo Mother Earth - Uninstalling and restoring system defaults...
echo.
echo :: First do the full system restore (power plan, ASPM, GPU prefs, SHIM, menu, etc.)
echo "%INSTALL_DIR%\MotherEarth.exe" --uninstall --silent
echo.
echo :: Clean up files and shortcuts
echo reg delete "HKCU\Software\Classes\exefile\shell\MotherEarth" /f ^>nul 2^>^&1
echo reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "MotherEarthTray" /f ^>nul 2^>^&1
echo del /q "%INSTALL_DIR%\MotherEarth.exe" 2^>nul
echo del /q "%INSTALL_DIR%\MotherEarthLauncher.exe" 2^>nul
echo del /q "%INSTALL_DIR%\EmergencyRestore.bat" 2^>nul
echo rmdir /s /q "%INSTALL_DIR%\assets" 2^>nul 2^>^&1
echo rmdir /s /q "%INSTALL_DIR%" 2^>nul
echo del "%SHORTCUT%" 2^>nul 2^>^&1
echo.
echo echo Mother Earth has been completely removed and all system changes reverted.
echo pause
) > "%INSTALL_DIR%\uninstall.bat"

echo.
echo ================================================
echo Installation complete!
echo.
echo Installed to: %INSTALL_DIR%
echo.
echo Mother Earth is now registered in Add/Remove Programs.
echo Uninstalling from there (or running uninstall.bat) will fully revert all system changes.
echo.
echo IMPORTANT SAFETY NET COPIED:
echo   "%INSTALL_DIR%\EmergencyRestore.bat"
echo   - Run this ANY time (even if main exe is missing) to force Balanced + Moderate ASPM.
echo   - It is completely standalone and does not need the Mother Earth exe or config.
echo.
echo Next steps:
echo   1. Run "%INSTALL_DIR%\MotherEarth.exe" (it will request admin if needed).
echo   2. Click "Apply All System Fixes".
echo   3. Right-click any .exe in Explorer and choose "Run with Mother Earth".
echo.
echo To uninstall: use Add/Remove Programs or run "%INSTALL_DIR%\uninstall.bat"
echo ================================================
echo.
pause
endlocal