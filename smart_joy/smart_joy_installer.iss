[Setup]
AppName=Smart Joy Server
AppVersion=1.0.0
DefaultDirName={pf}\SmartJoyServer
DefaultGroupName=Smart Joy Server
OutputDir=build
OutputBaseFilename=SmartJoyServerInstaller
Compression=lzma
SolidCompression=yes

[Files]
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\Joy Server"; Filename: "{app}\JoyServer.exe"
Name: "{group}\Uninstall Joy Server"; Filename: "{uninstallexe}"