# MapSWAT Windows Installer Overview

This guide summarizes a reproducible approach to generate a Windows installer for MapSWAT based on the current plugin source. It assumes familiarity with PyInstaller and Inno Setup, and a Windows environment with QGIS 3.x installed.

## 1. Understand the plugin entry point
* The QGIS plugin loads through `classFactory` in `Base.py`, which registers the toolbar/menu action and opens the dialogs implemented in `BaseDialog.py` (standard) and `BaseDialog_GEE.py` (GEE workflow).
* Both dialogs rely on PyQt5 widgets generated from `gui/ui_dialog.py` and `gui/ui_dialog_GEE.py`, plus resource files under `resources/` and `ui.resources/`.

## 2. Prepare a clean build environment
* Install QGIS 3.x for Windows (standalone installer) and ensure its Python is on PATH, e.g. `C:\Program Files\QGIS 3.34.0\bin` and `C:\Program Files\QGIS 3.34.0\apps\Python39`.
* Verify QGIS Python imports from an OSGeo shell:
  ```bat
  python -c "from qgis.core import QgsApplication; print('QGIS OK')"
  ```
* Optional: create a separate virtual environment pointing to the QGIS Python executable to avoid polluting the system installation.

## 3. Bundle the plugin with PyInstaller
1. Copy the repository into a Windows workspace (e.g., `C:\src\MapSWAT-3.1_Q334_N01`).
2. Create a small launcher script (e.g., `mapswat_launcher.py`) that initializes `QgsApplication`, adds `qgis.utils.iface` stubs if running without the full QGIS GUI, and then calls the plugin’s `classFactory` to show the main dialog. This keeps the runtime consistent with QGIS while allowing PyInstaller to discover imports.
3. Run PyInstaller from the OSGeo shell so that GDAL/PROJ/QGIS DLLs resolve correctly:
  ```bat
  pyinstaller --name MapSWAT --windowed --noconfirm \
    --add-data "resources;resources" \
    --add-data "ui.resources;ui.resources" \
    --add-data "metadata.txt;." \
    --hidden-import qgis._gui --hidden-import qgis._analysis \
    mapswat_launcher.py
  ```
4. Validate the unpacked `dist/MapSWAT` folder by running `MapSWAT.exe` directly. Confirm that dialogs open, resources load, and GEE authentication works.

## 4. Create an Inno Setup installer
1. Point Inno Setup to the PyInstaller output directory (`dist/MapSWAT`).
2. Add QGIS runtime DLLs if they are not already present in the PyInstaller bundle (e.g., `gdal304.dll`, `proj_9.dll`, `qgis_core.dll`, `qgis_gui.dll`). If you rely on the user’s QGIS installation, document the minimum version and install path.
3. Define shortcuts and file associations as needed; a typical script uses:
  ```pascal
  [Setup]
  AppName=MapSWAT
  AppVersion=3.1
  DefaultDirName={pf64}\MapSWAT
  ArchitecturesInstallIn64BitMode=x64
  
  [Files]
  Source: "dist\MapSWAT\*"; DestDir: "{app}"; Flags: recursesubdirs
  
  [Icons]
  Name: "{group}\MapSWAT"; Filename: "{app}\MapSWAT.exe"
  Name: "{commondesktop}\MapSWAT"; Filename: "{app}\MapSWAT.exe"
  ```
4. Build the installer (`.exe`) and test on a clean Windows VM (Windows 10/11, different usernames) to ensure paths with spaces and non-ASCII characters work.

## 5. Distribute as a plugin (alternative path)
* If you only need a plugin installer (without PyInstaller), zip the plugin folder contents (`Base.py`, `BaseDialog*.py`, `gui/`, `resources/`, `ui.resources/`, `metadata.txt`) so the root of the zip mirrors the QGIS plugin directory layout.
* Users can install via QGIS Plugin Manager > “Install from ZIP…”. This approach relies entirely on the user’s QGIS and does not create a standalone executable.

## 6. Practical tips
* Keep `resources/` and `ui.resources/` in the same relative layout; the code loads icons with package-relative paths.
* The GEE-enabled flow requires the `qgis-earthengine-plugin` dependency in QGIS; for the PyInstaller path, vendor the Earth Engine Python client and ensure OAuth callbacks are permitted.
* Avoid hard-coding user-specific paths. Use `%APPDATA%` or `Path.home()` to store temporary outputs so the installer works across different Windows usernames.
