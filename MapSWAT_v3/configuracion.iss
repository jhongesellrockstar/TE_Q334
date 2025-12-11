; -------------------------------------------------------------
; MapSWAT_N01 Installer for QGIS 3.34.x
; Author: USUARIO_FAMILIAC43
; Based on structure of AdrLBallesteros MapSWAT installer
; -------------------------------------------------------------

#define MyAppName "MapSWAT_N01"
#define MyAppVersion "1.0"
#define MyPublisher "Equipo de Desarrollo POO01"
#define MyURL "https://github.com/tu_repo"
#define PluginFolderSource "C:\Users\jhonv\Documents\GitHub2025\TE_Q334\MapSWAT-3.1_Q334_N01"
#define PluginFolderTarget "{userappdata}\QGIS\QGIS3\profiles\default\python\plugins\{#MyAppName}"

[Setup]
AppName={#MyAppName}
AppVersion={#MyAppVersion}
DefaultDirName={#PluginFolderTarget}
Uninstallable=yes
OutputDir="C:\Users\jhonv\Desktop"
OutputBaseFilename="MapSWAT_N01_Installer"
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64

[Files]
Source: "{#PluginFolderSource}\*"; DestDir: "{#PluginFolderTarget}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName} README"; Filename: "{#PluginFolderTarget}\README.md"

[Run]
Filename: "{#PluginFolderTarget}\README.md"; Description: "Ver instrucciones"; Flags: shellexec postinstall;
