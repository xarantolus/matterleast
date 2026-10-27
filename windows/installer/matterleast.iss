; Per-user installer for the Windows build, no admin rights needed.
; Built in CI after `flutter build windows --release`:
;   iscc /DAppVersion=0.12.0 /O<output dir> windows\installer\matterleast.iss

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppExe "matterleast.exe"
#define BuildDir "..\..\build\windows\x64\runner\Release"
; Windows toasts show the name and icon of the shortcut with this ID; the
; app sends its notifications under the same one.
#define AppUserModelId "io.github.xarantolus.matterleast"

[Setup]
; Fixed for good: upgrades replace the installed copy under this ID.
AppId={{E33E83B7-97BE-4196-AD93-0B902C2BA8E8}
AppName=Matterleast
AppVersion={#AppVersion}
AppVerName=Matterleast {#AppVersion}
AppPublisher=xarantolus
AppPublisherURL=https://github.com/xarantolus/matterleast
AppSupportURL=https://github.com/xarantolus/matterleast/issues
VersionInfoVersion={#AppVersion}
PrivilegesRequired=lowest
DefaultDirName={autopf}\Matterleast
DisableDirPage=yes
DisableProgramGroupPage=yes
DisableReadyPage=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes
RestartApplications=no
SetupIconFile=..\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName=Matterleast
WizardStyle=modern
Compression=lzma2/max
SolidCompression=yes
OutputBaseFilename=matterleast-setup

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\Matterleast"; Filename: "{app}\{#AppExe}"; AppUserModelID: "{#AppUserModelId}"
Name: "{autodesktop}\Matterleast"; Filename: "{app}\{#AppExe}"; AppUserModelID: "{#AppUserModelId}"; Tasks: desktopicon

[Registry]
; mmauth:// opens the app, which finishes a single sign-on with the token
; the server sends back.
Root: HKCU; Subkey: "Software\Classes\mmauth"; ValueType: string; ValueName: ""; ValueData: "URL:Matterleast sign-in"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\Classes\mmauth"; ValueType: string; ValueName: "URL Protocol"; ValueData: ""
Root: HKCU; Subkey: "Software\Classes\mmauth\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"",0"
Root: HKCU; Subkey: "Software\Classes\mmauth\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#AppExe}"" ""%1"""

[Run]
Filename: "{app}\{#AppExe}"; Description: "{cm:LaunchProgram,Matterleast}"; Flags: nowait postinstall skipifsilent
