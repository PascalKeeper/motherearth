# Mother Earth

**Smart Hybrid Graphics Orchestrator for Windows**

Copyright (C) 2026 Joseph Peransi

Force legacy and modern NVIDIA GPUs (especially GTX 1070) to be properly used instead of the Intel iGPU on hybrid systems. Eliminates micro-stutters caused by aggressive power saving and incorrect GPU assignment.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.

---

## LEGAL DISCLAIMER, WARNINGS, AND LIMITATION OF LIABILITY (IMPORTANT - READ FULLY)

**USE OF THIS SOFTWARE IS ENTIRELY AT YOUR OWN RISK.**

MOTHER EARTH IS PROVIDED BY JOSEPH PERANSI "AS IS" AND "AS AVAILABLE", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.

IN NO EVENT SHALL JOSEPH PERANSI, THE COPYRIGHT HOLDERS, AUTHORS, CONTRIBUTORS, OR ANY AFFILIATED PARTIES BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, PUNITIVE, EXEMPLARY, OR OTHER DAMAGES WHATSOEVER (INCLUDING, WITHOUT LIMITATION, DAMAGES FOR LOSS OF PROFITS, LOSS OF DATA, BUSINESS INTERRUPTION, PERSONAL INJURY, HARDWARE DAMAGE, SYSTEM INSTABILITY, DATA CORRUPTION, OR ANY OTHER LOSS) ARISING OUT OF OR IN CONNECTION WITH THE USE, INABILITY TO USE, OR PERFORMANCE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

### Specific Risks and Warnings
This software modifies core Windows system settings including (but not limited to):
- Power plans (e.g., forcing "Ultimate Performance")
- PCIe Active State Power Management (ASPM / Link State) — disabling this keeps hardware links active, which can significantly increase idle power draw, heat, and temperatures (typically +5°C to +10°C or more on GPUs and related components). This can lead to thermal throttling, reduced component lifespan, fan noise, or in extreme cases hardware failure.
- Per-application GPU preferences via the Windows registry (HKCU\Software\Microsoft\DirectX\UserGpuPreferences)
- Environment variables (e.g., SHIM_MCCOMPAT)
- Explorer context menu (shell integration)
- Background process monitoring and registry writes

**These changes can cause:**
- Increased heat and power consumption (especially dangerous on laptops, even when "plugged in" — battery life will be severely impacted if used on battery).
- Micro-stutter "fixes" that introduce other instability.
- Conflicts with drivers, other software (NVIDIA Control Panel, manufacturer tools, Windows updates), or hardware.
- Registry bloat or corruption if not properly reverted.
- Incorrect GPU routing leading to crashes, black screens, poor performance, or failure to launch applications.
- On hybrid systems (Intel iGPU + NVIDIA dGPU like GTX 1070), forcing dGPU usage may bypass intended power-saving behaviors of the OS and drivers.

**This tool is intended ONLY for:**
- Advanced users
- Desktop systems with adequate cooling and power delivery
- Controlled testing environments
- Users who fully understand the risks and have backups

**DO NOT USE ON:**
- Laptops or portable devices on battery power (or even plugged in without monitoring)
- Production machines, servers, or systems where downtime/data loss is unacceptable
- Systems without the ability to monitor temperatures in real-time (use HWInfo, GPU-Z, etc.)
- Without first using the --dry-run mode and reviewing the logs and before-snapshots

**Mandatory Precautions (Failure to follow may result in damage for which there is NO LIABILITY):**
- ALWAYS run with --dry-run --apply first and review the full output.
- ALWAYS create system restore points and backup important data before use.
- Monitor GPU/CPU temperatures, power draw, and stability continuously.
- Have the standalone EmergencyRestore.bat ready and tested.
- Revert changes (via GUI Restore, --uninstall, or EmergencyRestore.bat) and reboot before major Windows updates or hardware changes.
- Test on a non-critical system first.
- This software performs privileged operations. Elevation is requested only when necessary, but misuse can still affect system stability.

By using this software, you acknowledge that you have read, understood, and agree to this entire disclaimer. You assume **ALL RISKS** of use, including but not limited to damage to hardware, software, data, or other property, and personal injury. Joseph Peransi and any contributors explicitly disclaim all liability.

If you do not agree to these terms, do not use the software. Delete all copies immediately.

This disclaimer is in addition to the terms of the GNU General Public License v3.0 under which the software is licensed. In the event of any conflict, the stronger protections for the author shall apply.

**No support is provided.** This is provided as-is for those who understand the implications on hybrid graphics systems (target hardware: legacy NVIDIA like GTX 1070 + Intel iGPU on Windows 10/11 24H2+).

---

## Features

### ⚡ Power Subsystem Enforcement
- Unlocks "Ultimate Performance": Injects the hidden Windows workstation power plan (GUID: e9a42b02-d5df-448d-aa00-03f14749eb61). Falls back to High Performance if needed.
- Kills PCIe ASPM: Disables "Active State Power Management." This prevents the PCIe bus from powering down between frames, eliminating micro-stutters and input latency caused by "wake-up" lag.

### 💉 Registry Injection
- Bypasses Windows Settings: Writes directly to `HKCU\Software\Microsoft\DirectX\UserGpuPreferences`. This circumvents the Windows 11 24H2 bug where the Settings app crashes if it detects invalid legacy entries.
- Force High Performance: Hard-codes `GpuPreference=2` for target applications.
- Also forces background/system processes that do not need the dGPU (dwm.exe, csrss.exe, SearchApp.exe, ShellExperienceHost.exe, etc.) onto the iGPU (`GpuPreference=1`).

### 🖱️ Context Menu — "Run with Mother Earth"
- Restores the classic right-click context menu option that NVIDIA removed and Microsoft buried.
- Right-click any .exe → **Run with Mother Earth** → brief confirmation window → the app is permanently forced to the dGPU on future launches.

### 🛠️ Legacy Shim + Active Management
- SHIM_MCCOMPAT: Injects the legacy environment variable `0x800000001` into the user session. Forces Electron apps (Discord, VS Code, launchers) and OpenGL titles to detect the dGPU.
- Background Monitor: Actively watches running processes (default 20-second interval, fully configurable) and enforces iGPU assignment for known background executables. New processes are checked automatically.

### Driver & Hardware Compatibility
- Driver-agnostic (targets WDDM + kernel power plans directly).
- Works on NVIDIA Pascal/Maxwell (GTX 10/900/700) through RTX 50-series.
- AMD support: Registry + Power Plan enforcement works; SHIM is ignored harmlessly.
- Requires a functional WDDM driver (not the Microsoft Basic Display Adapter).

**Modern GPUs benefit too**: Even RTX 4090-class cards suffer "Sleep State Aggression". Disabling ASPM keeps the link in L0, removing wake-up micro-stutters in high-FPS scenarios.

---

## Important Warnings & Disclaimers

- **Thermals**: Disabling ASPM means your GPU PCIe link is always active (L0 state). Idle temperatures will rise (expect +5°C to +10°C). This is the cost of eliminating latency.
- **Battery Life**: Do not use on battery power. Turns a laptop into a desktop workstation. Battery life will be decimated.
- **Windows Updates**: Major feature updates (25H2, etc.) may reset the power plan and ASPM settings. Re-run "Apply All" after updates.
- This tool performs privileged operations (power plans, ASPM). It will request Administrator elevation only when necessary. The context-menu launcher path never prompts for UAC.

---

## Installation & Daily Usage (Standalone .exe)

The project builds **standalone Windows executables**. End users do **not** need Python installed to run the final product.

1. Download or build the release:
   - `dist/MotherEarth.exe` — full application (GUI + CLI + all features)
   - `dist/MotherEarthLauncher.exe` — tiny context-menu helper (brief black window)

2. **First run**:
   - Double-click `MotherEarth.exe` (or run as Administrator).
   - It will request elevation if needed.
   - Hardware is detected.
   - Click **Apply All System Fixes** (or use the CLI equivalent).

3. **Daily use**:
   - Right-click any game, launcher, or .exe file in Explorer.
   - Select **"Run with Mother Earth"**.
   - A black console window appears briefly to confirm the registry injection.
   - Launch the application normally (double-click, Start menu, etc.). It is now permanently forced to the high-performance NVIDIA GPU.

4. **Tray Icon**:
   - The main window can be minimized/hidden.
   - A tray icon (icy frosted globe) appears in the notification area.
   - Left-click or double-click to restore the dashboard.
   - Right-click for quick actions menu (Apply All, Toggle Monitor, Restore Defaults, Exit, etc.).

5. **Background Monitor**:
   - Start from the GUI or `--monitor` flag.
   - Default poll interval: **20 seconds** (configurable in `%APPDATA%\MotherEarth\config.json`).
   - It continuously enforces iGPU assignment for background processes.

**Verification after applying** (run in an elevated Command Prompt):

```powershell
powercfg /getactivescheme
powercfg /query 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5
reg query "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /s
```

Look for Ultimate Performance active and Link State Power Management = Off (index 0).

---

## Building from Source (for developers / custom builds)

Python 3.10+ required (Add to PATH during install).

```bat
cd F:\motherearth
build.bat
```

This:
- Installs PyInstaller + runtime deps (psutil, Pillow, pystray)
- Converts `assets/icon.png` → `assets/icon.ico`
- Produces `dist/MotherEarth.exe` and `dist/MotherEarthLauncher.exe` (one-file, console)

The source tree is included for transparency and modification.

---

## CLI Flags (MotherEarth.exe or python -m ...)

- (no args)          → Launch GUI (default)
- `--cli`            → Interactive text menu
- `--apply`          → Apply all system fixes (non-interactive)
- `--dry-run --apply` → **SAFETY**: Simulate the entire apply process and log every change that *would* be made. Nothing is modified.
- `--force "C:\path\to\game.exe"`
- `--monitor`        → Run background monitor (20s default)
- `--status`         → Print current state
- `--restore`        → Undo Mother Earth changes (power + ASPM + managed prefs)
- `--uninstall`      → Full system revert (used automatically by Add/Remove Programs)
- `--emergency-restore` → Last-resort: force Balanced + Moderate ASPM (does not need our saved config)
- `--register-menu`  → (Re)install the Explorer context menu
- `--verify`         → Run built-in health checks

---

## Safety & Design Principles + Failure Prevention

**Critical safety features added for system/hardware protection:**

- **`--dry-run --apply`** (and GUI simulation path): Logs *exactly* what would be changed (power plan switch, ASPM disable, every registry write, SHIM, menu) **without touching the system**. Use this first on any new machine.
- **Automatic full state snapshot**: On every Apply (even dry-run), a timestamped folder is created in `%APPDATA%\MotherEarth\backups\before-YYYYMMDD-HHMMSS\` containing:
  - Full `powercfg /query` output for ASPM
  - Current active scheme + all schemes list
  - Complete GPU preferences registry dump
  - Current SHIM value
  - Hardware detection snapshot
  This gives you a forensic before-image for manual recovery.
- **Battery / laptop pre-flight**: Loud warning + logged if a battery is present. Power plan + ASPM changes are **strongly discouraged** on battery.
- **Post-apply validation**: After changes, the code re-queries the active plan and ASPM status and logs the result.
- **`--emergency-restore`**: Last-resort flag that forces Balanced + Moderate ASPM (index 1) **without relying on our saved config**. Safe "undo" even if config is corrupted.
- **Comprehensive `full_restore()` / `--uninstall`**: Used by Add/Remove Programs and `uninstall.bat`. Reverts in order:
  1. Original power scheme
  2. Original ASPM AC + DC values (we now capture these before changing)
  3. SHIM_MCCOMPAT removal
  4. Context menu removal
  5. All GPU prefs we ever set (via tracked lists)
- **Uninstall via ARP always reverts first**: The `UninstallString` runs `MotherEarth.exe --uninstall` (or `--silent`) *before* file deletion.
- All mutating operations are wrapped in defensive error handling; partial failures do not leave the tool in a broken state for future runs.
- The context-menu launcher (`MotherEarthLauncher.exe`) is completely non-elevating and only touches one HKCU value.

**Recommended safe testing & verification procedure (do this on your real GTX 1070 + Intel machine):**

1. **Dry run first**:
   ```
   MotherEarth.exe --dry-run --apply
   ```
   Review the log. Nothing should have changed.

2. **Status / verify (always safe)**:
   ```
   MotherEarth.exe --status
   MotherEarth.exe --verify
   ```

3. **Real apply (with automatic backup)**:
   - Plug in power.
   - Run `MotherEarth.exe` → Apply All.
   - Note the backup folder created in `%APPDATA%\MotherEarth\backups\`.
   - Manually confirm with:
     ```
     powercfg /getactivescheme
     powercfg /query 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5
     reg query "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /s
     ```

4. **Test revert**:
   - Use GUI "Restore Defaults" button, or `MotherEarth.exe --restore`, or the uninstaller.
   - Re-run the queries above — they should return close to the pre-apply state (or at least Balanced + ASPM not forced Off by us).

5. **Hardware safety**:
   - Monitor GPU/CPU temperatures (HWInfo, GPU-Z, or MSI Afterburner) before/after ASPM disable. Expect +5-10 °C idle.
   - If on a laptop, only test while plugged in and with good cooling.
   - After ASPM change, stress test briefly (a game or FurMark) and watch for thermal throttling or instability.

6. **Emergency recovery** (if something feels wrong):
   ```
   MotherEarth.exe --emergency-restore
   ```
   This forces Balanced + Moderate ASPM without needing our config.

7. **Uninstall test**:
   - Install via `install.bat`.
   - Go to Add/Remove Programs and uninstall Mother Earth.
   - It must run the full revert before removing files.

**What we deliberately do NOT do** (failure prevention):
- No changes on the fast launcher path.
- No kernel drivers or low-level PCI device writes.
- No permanent "always on" without user action.
- No overclocking or voltage changes.
- Context menu and per-app GPU prefs are user-scope only.

If the machine becomes unstable after ASPM disable, the first thing to try is the emergency restore above, followed by a reboot. The before- snapshot folders give you the exact `powercfg` commands you can run manually if needed.

Use responsibly. The tool is designed so that even in a worst-case partial failure, you have the snapshots + the emergency path + the uninstaller to get back to a known-good state.

---

## CLI Flags (MotherEarth.exe or python -m ...)

- (no args)          → Launch GUI (default)
- `--cli`            → Interactive text menu
- `--apply`          → Apply all system fixes (non-interactive)
- `--dry-run --apply` → **SAFETY**: Simulate the entire apply process and log every change that *would* be made. Nothing is modified.
- `--force "C:\path\to\game.exe"`
- `--monitor`        → Run background monitor (20s default)
- `--status`         → Print current state
- `--restore`        → Undo Mother Earth changes (power + ASPM + managed prefs)
- `--uninstall`      → Full system revert (used automatically by Add/Remove Programs)
- `--emergency-restore` → Last-resort: force Balanced + Moderate ASPM (does not need our saved config)
- `--register-menu`  → (Re)install the Explorer context menu
- `--verify`         → Run built-in health checks

---

## Safety & Design Principles + Failure Prevention

**Critical safety features added for system/hardware protection:**

- **`--dry-run --apply`** (and GUI simulation path): Logs *exactly* what would be changed (power plan switch, ASPM disable, every registry write, SHIM, menu) **without touching the system**. Use this first on any new machine.
- **Automatic full state snapshot**: On every Apply (even dry-run), a timestamped folder is created in `%APPDATA%\MotherEarth\backups\before-YYYYMMDD-HHMMSS\` containing:
  - Full `powercfg /query` output for ASPM
  - Current active scheme + all schemes list
  - Complete GPU preferences registry dump
  - Current SHIM value
  - Hardware detection snapshot
  This gives you a forensic before-image for manual recovery.
- **Battery / laptop pre-flight**: Loud warning + logged if a battery is present. Power plan + ASPM changes are **strongly discouraged** on battery.
- **Post-apply validation**: After changes, the code re-queries the active plan and ASPM status and logs the result.
- **`--emergency-restore`**: Last-resort flag that forces Balanced + Moderate ASPM (index 1) **without relying on our saved config**. Safe "undo" even if config is corrupted.
- **Comprehensive `full_restore()` / `--uninstall`**: Used by Add/Remove Programs and `uninstall.bat`. Reverts in order:
  1. Original power scheme
  2. Original ASPM AC + DC values (we now capture these before changing)
  3. SHIM_MCCOMPAT removal
  4. Context menu removal
  5. All GPU prefs we ever set (via tracked lists)
- **Uninstall via ARP always reverts first**: The `UninstallString` runs `MotherEarth.exe --uninstall` (or `--silent`) *before* file deletion.
- All mutating operations are wrapped in defensive error handling; partial failures do not leave the tool in a broken state for future runs.
- The context-menu launcher (`MotherEarthLauncher.exe`) is completely non-elevating and only touches one HKCU value.

**Recommended safe testing & verification procedure (do this on your real GTX 1070 + Intel machine):**

1. **Dry run first**:
   ```
   MotherEarth.exe --dry-run --apply
   ```
   Review the log. Nothing should have changed.

2. **Status / verify (always safe)**:
   ```
   MotherEarth.exe --status
   MotherEarth.exe --verify
   ```

3. **Real apply (with automatic backup)**:
   - Plug in power.
   - Run `MotherEarth.exe` → Apply All.
   - Note the backup folder created in `%APPDATA%\MotherEarth\backups\`.
   - Manually confirm with:
     ```
     powercfg /getactivescheme
     powercfg /query 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5
     reg query "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /s
     ```

4. **Test revert**:
   - Use GUI "Restore Defaults" button, or `MotherEarth.exe --restore`, or the uninstaller.
   - Re-run the queries above — they should return close to the pre-apply state (or at least Balanced + ASPM not forced Off by us).

5. **Hardware safety**:
   - Monitor GPU/CPU temperatures (HWInfo, GPU-Z, or MSI Afterburner) before/after ASPM disable. Expect +5-10 °C idle.
   - If on a laptop, only test while plugged in and with good cooling.
   - After ASPM change, stress test briefly (a game or FurMark) and watch for thermal throttling or instability.

6. **Emergency recovery** (if something feels wrong):
   ```
   MotherEarth.exe --emergency-restore
   ```
   This forces Balanced + Moderate ASPM without needing our config.

7. **Uninstall test**:
   - Install via `install.bat`.
   - Go to Add/Remove Programs and uninstall Mother Earth.
   - It must run the full revert before removing files.

**What we deliberately do NOT do** (failure prevention):
- No changes on the fast launcher path.
- No kernel drivers or low-level PCI device writes.
- No permanent "always on" without user action.
- No overclocking or voltage changes.
- Context menu and per-app GPU prefs are user-scope only.

If the machine becomes unstable after ASPM disable, the first thing to try is the emergency restore above, followed by a reboot. The before- snapshot folders give you the exact `powercfg` commands you can run manually if needed.

Use responsibly. The tool is designed so that even in a worst-case partial failure, you have the snapshots + the emergency path + the uninstaller to get back to a known-good state.

---

## CLI Flags (MotherEarth.exe or python -m ...)

- (no args)          → Launch GUI (default)
- `--cli`            → Interactive text menu
- `--apply`          → Apply all system fixes (non-interactive)
- `--dry-run --apply` → **SAFETY**: Simulate the entire apply process and log every change that *would* be made. Nothing is modified.
- `--force "C:\path\to\game.exe"`
- `--monitor`        → Run background monitor (20s default)
- `--status`         → Print current state
- `--restore`        → Undo Mother Earth changes (power + ASPM + managed prefs)
- `--uninstall`      → Full system revert (used automatically by Add/Remove Programs)
- `--emergency-restore` → Last-resort: force Balanced + Moderate ASPM (does not need our saved config)
- `--register-menu`  → (Re)install the Explorer context menu
- `--verify`         → Run built-in health checks

---

## Safety & Design Principles + Failure Prevention

**Critical safety features added for system/hardware protection:**

- **`--dry-run --apply`** (and GUI simulation path): Logs *exactly* what would be changed (power plan switch, ASPM disable, every registry write, SHIM, menu) **without touching the system**. Use this first on any new machine.
- **Automatic full state snapshot**: On every Apply (even dry-run), a timestamped folder is created in `%APPDATA%\MotherEarth\backups\before-YYYYMMDD-HHMMSS\` containing:
  - Full `powercfg /query` output for ASPM
  - Current active scheme + all schemes list
  - Complete GPU preferences registry dump
  - Current SHIM value
  - Hardware detection snapshot
  This gives you a forensic before-image for manual recovery.
- **Battery / laptop pre-flight**: Loud warning + logged if a battery is present. Power plan + ASPM changes are **strongly discouraged** on battery.
- **Post-apply validation**: After changes, the code re-queries the active plan and ASPM status and logs the result.
- **`--emergency-restore`**: Last-resort flag that forces Balanced + Moderate ASPM (index 1) **without relying on our saved config**. Safe "undo" even if config is corrupted.
- **Comprehensive `full_restore()` / `--uninstall`**: Used by Add/Remove Programs and `uninstall.bat`. Reverts in order:
  1. Original power scheme
  2. Original ASPM AC + DC values (we now capture these before changing)
  3. SHIM_MCCOMPAT removal
  4. Context menu removal
  5. All GPU prefs we ever set (via tracked lists)
- **Uninstall via ARP always reverts first**: The `UninstallString` runs `MotherEarth.exe --uninstall` (or `--silent`) *before* file deletion.
- All mutating operations are wrapped in defensive error handling; partial failures do not leave the tool in a broken state for future runs.
- The context-menu launcher (`MotherEarthLauncher.exe`) is completely non-elevating and only touches one HKCU value.

**Recommended safe testing & verification procedure (do this on your real GTX 1070 + Intel machine):**

1. **Dry run first**:
   ```
   MotherEarth.exe --dry-run --apply
   ```
   Review the log. Nothing should have changed.

2. **Status / verify (always safe)**:
   ```
   MotherEarth.exe --status
   MotherEarth.exe --verify
   ```

3. **Real apply (with automatic backup)**:
   - Plug in power.
   - Run `MotherEarth.exe` → Apply All.
   - Note the backup folder created in `%APPDATA%\MotherEarth\backups\`.
   - Manually confirm with:
     ```
     powercfg /getactivescheme
     powercfg /query 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5
     reg query "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /s
     ```

4. **Test revert**:
   - Use GUI "Restore Defaults" button, or `MotherEarth.exe --restore`, or the uninstaller.
   - Re-run the queries above — they should return close to the pre-apply state (or at least Balanced + ASPM not forced Off by us).

5. **Hardware safety**:
   - Monitor GPU/CPU temperatures (HWInfo, GPU-Z, or MSI Afterburner) before/after ASPM disable. Expect +5-10 °C idle.
   - If on a laptop, only test while plugged in and with good cooling.
   - After ASPM change, stress test briefly (a game or FurMark) and watch for thermal throttling or instability.

6. **Emergency recovery** (if something feels wrong):
   ```
   MotherEarth.exe --emergency-restore
   ```
   This forces Balanced + Moderate ASPM without needing our config.

7. **Uninstall test**:
   - Install via `install.bat`.
   - Go to Add/Remove Programs and uninstall Mother Earth.
   - It must run the full revert before removing files.

**What we deliberately do NOT do** (failure prevention):
- No changes on the fast launcher path.
- No kernel drivers or low-level PCI device writes.
- No permanent "always on" without user action.
- No overclocking or voltage changes.
- Context menu and per-app GPU prefs are user-scope only.

If the machine becomes unstable after ASPM disable, the first thing to try is the emergency restore above, followed by a reboot. The before- snapshot folders give you the exact `powercfg` commands you can run manually if needed.

Use responsibly. The tool is designed so that even in a worst-case partial failure, you have the snapshots + the emergency path + the uninstaller to get back to a known-good state.

---

## Installation & Daily Usage (Standalone .exe)

The project builds **standalone Windows executables**. End users do **not** need Python installed to run the final product.

1. Download or build the release:
   - `dist/MotherEarth.exe` — full application (GUI + CLI + all features)
   - `dist/MotherEarthLauncher.exe` — tiny context-menu helper (brief black window)

2. **First run**:
   - Double-click `MotherEarth.exe` (or run as Administrator).
   - It will request elevation if needed.
   - Hardware is detected.
   - Click **Apply All System Fixes** (or use the CLI equivalent).

3. **Daily use**:
   - Right-click any game, launcher, or .exe file in Explorer.
   - Select **"Run with Mother Earth"**.
   - A black console window appears briefly to confirm the registry injection.
   - Launch the application normally (double-click, Start menu, etc.). It is now permanently forced to the high-performance NVIDIA GPU.

4. **Tray Icon**:
   - The main window can be minimized/hidden.
   - A tray icon (icy frosted globe) appears in the notification area.
   - Left-click or double-click to restore the dashboard.
   - Right-click for quick actions menu (Apply All, Toggle Monitor, Restore Defaults, Exit, etc.).

5. **Background Monitor**:
   - Start from the GUI or `--monitor` flag.
   - Default poll interval: **20 seconds** (configurable in `%APPDATA%\MotherEarth\config.json`).
   - It continuously enforces iGPU assignment for background processes.

**Verification after applying** (run in an elevated Command Prompt):

```powershell
powercfg /getactivescheme
powercfg /query 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5
reg query "HKCU\Software\Microsoft\DirectX\UserGpuPreferences" /s
```

Look for Ultimate Performance active and Link State Power Management = Off (index 0).

---

## Building from Source (for developers / custom builds)

Python 3.10+ required (Add to PATH during install).

```bat
cd F:\motherearth
build.bat
```

This:
- Installs PyInstaller + runtime deps (psutil, Pillow, pystray)
- Converts `assets/icon.png` → `assets/icon.ico`
- Produces `dist/MotherEarth.exe` and `dist/MotherEarthLauncher.exe` (one-file, console)

The source tree is included for transparency and modification.

---

## Project Structure (High Level)

```
F:\motherearth\
├── README.md
├── LICENSE (GPL-3.0)
├── .gitignore
├── requirements.txt
├── build.bat
├── build.spec
├── EmergencyRestore.bat (standalone safety net - the "option")
├── install.bat (end-user installer with ARP entry + full revert guarantee)
├── motherearth.py (thin entry)
├── launcher.py
├── src/motherearth/ (full package)
└── assets/ (icon)
```

All changes are logged. Full backup/restore of power plan, ASPM values, and managed GPU preferences is implemented for safety.

---

## Credits & Notes

- Icon generated for this project (icy round frosted Earth globe).
- Power plan and ASPM GUIDs validated against Windows 11 query output and Microsoft documentation.
- Registry injection technique proven across many hybrid GPU tools and confirmed against DXGI_GPU_PREFERENCE behavior.
- Monitor interval defaults to 20 seconds and is user-configurable.
- **EmergencyRestore.bat** (standalone, no .exe needed) is included in the root and deployed by install.bat. Run it as a last-resort to force Balanced + Moderate ASPM + clean menu/SHIM. It is referenced in the ARP entry and can be run even if the main app is gone.

**Target OS**: Windows 10 / 11 (24H2 and newer recommended for full 24H2 bug workarounds)  
**Target Hardware**: Any WDDM hybrid system with Intel iGPU + discrete GPU (NVIDIA focus for SHIM, but power/reg work on AMD too).

Use responsibly. Enjoy the smooth frames.

— Joseph Peransi, 2026
