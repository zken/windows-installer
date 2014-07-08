; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define MyAppName "Boot2Docker for Windows"
#define MyAppVersion "1.1.0"
#define MyAppPublisher "Docker Inc"
#define MyAppURL "http://boot2docker.io"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
SetupIconFile=boot2docker.ico
;DisableProgramGroupPage=yes
;DisableReadyPage=yes

AppId={{05BD04E9-4AB5-46AC-891E-60EA8FD57D56}
AppCopyright=Docker Project
AppContact=Sven Dowideit <SvenDowideit@docker.com>
AppComments=http://docker.com/
AppName={#MyAppName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName=Docker
; lets not be annoying
;InfoBeforeFile=.\LICENSE
;DisableFinishedPage
;InfoAfterFile=
OutputBaseFilename=docker-install
Compression=lzma
SolidCompression=yes
WizardImageFile=logo-docker-side.bmp
WizardSmallImageFile=logo-docker-small.bmp  
WizardImageStretch=no     
WizardImageBackColor=$325461

SignTool=ksign /d $qBoot2Docker for Windows$q /du $qhttp://docker.com$q $f

; for modpath.iss
ChangesEnvironment=true

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "upgrade"; Description: "Upgrade Boot2Docker only"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Tasks]
Name: modifypath; Description: &Add Boot2Docker environmental PATH; Flags: 

[Components]
Name: "Boot2Docker"; Description: "Boot2Docker management script and ISO" ; Types: full upgrade
Name: "VirtualBox"; Description: "VirtualBox"; Types: full
Name: "MSYS"; Description: "MSYS-git UNIX tools"; Types: full

[Files]
Source: ".\Boot2Docker\boot2docker.iso"; DestDir: "{app}"; Flags: ignoreversion; Components: "Boot2Docker"
Source: ".\boot2docker.ico"; DestDir: "{app}"; Flags: ignoreversion; Components: "Boot2Docker"
Source: ".\Boot2Docker\boot2docker.exe"; DestDir: "{app}"; Flags: ignoreversion; Components: "Boot2Docker"
;Source: ".\Boot2Docker\profile"; DestDir: "{app}"; Flags: ignoreversion
Source: ".\start.sh"; DestDir: "{app}"; Flags: ignoreversion; Components: "Boot2Docker"
Source: ".\delete.sh"; DestDir: "{app}"; Flags: ignoreversion; Components: "Boot2Docker"

; msys-Git
Source: ".\msys-Git\Git-1.9.0-preview20140217.exe"; DestDir: "{app}"; AfterInstall: RunInstallMSYS();  Components: "MSYS" 

;VirtualBox - 64 bit only
;https://forums.virtualbox.org/viewtopic.php?f=3&t=21127
Source: ".\VirtualBox\VirtualBox-4.3.12-r93733-MultiArch_amd64.msi"; DestDir: "{app}"; Components: "VirtualBox"
Source: ".\VirtualBox\common.cab"; DestDir: "{app}"; AfterInstall: RunInstallVirtualBox(); Components: "VirtualBox"
; the cert http://www.catonrug.net/2013/03/virtualbox-silent-install-store-oracle-certificate.html
;Source: ".\VirtualBox\oracle-vbox.cer"; DestDir: "{app}"; AfterInstall: MSYSInstalled();  Components: "VirtualBox"

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\{cm:ProgramOnTheWeb,{#MyAppName}}"; Filename: "{#MyAppURL}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{group}\Boot2Docker Start"; WorkingDir: "{app}"; Filename: "{app}\start.sh"; IconFilename: "{app}/boot2docker.ico"
Name: "{commondesktop}\Boot2Docker Start"; WorkingDir: "{app}"; Filename: "{app}\start.sh"; IconFilename: "{app}/boot2docker.ico"
Name: "{commonprograms}\Boot2Docker Start"; WorkingDir: "{app}"; Filename: "{app}\start.sh"; IconFilename: "{app}/boot2docker.ico"
Name: "{group}\Delete Boot2Docker VM"; WorkingDir: "{app}"; Filename: "{app}\delete.sh"
Name: "{group}\Unix Bash"; Filename: "C:\Program Files (x86)\Git\bin\sh.exe"; Parameters: "--login -i"; Flags: dontcloseonexit

[UninstallRun]
Filename: "{app}\delete.sh"

[Code]
var
  restart: boolean;
const  UninstallKey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{#SetupSetting("AppId")}_is1';
//  32 bit on 64  HKLM\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

function IsUpgrade: Boolean;
var
  Value: string;
begin
  Result := (RegQueryStringValue(HKLM, UninstallKey, 'UninstallString', Value) or
    RegQueryStringValue(HKCU, UninstallKey, 'UninstallString', Value)) and (Value <> '');
end;


function NeedRestart(): Boolean;
begin
  Result := restart;
end;

function NeedToInstallVirtualBox(): Boolean;
begin
  Result := False;
  if (GetEnv('VBOX_INSTALL_PATH') = '') and (GetEnv('VBOX_MSI_INSTALL_PATH') = '') then begin
    Result := True;
  end;
end;

function NeedToInstallMSYS(): Boolean;
begin
  Result := True;
  if RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Git_is1') then begin
    Result := False;
  end;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
    WizardForm.FinishedLabel.Caption := 'Docker for Windows installation completed.      The `Boot2Docker Start` icon on your desktop and in Program Files will initialize, start and connect you to your Boot2Docker virtual machine.';
  //if CurPageID = wpSelectDir then
    // to go with DisableReadyPage=yes and DisableProgramGroupPage=yes
    //WizardForm.NextButton.Caption := SetupMessage(msgButtonInstall)
  //else
    //WizardForm.NextButton.Caption := SetupMessage(msgButtonNext);
  //if CurPageID = wpFinished then 
    //WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish)
    if CurPageID = wpSelectComponents then
    begin  
      if IsUpgrade() then
      begin
        Wizardform.TypesCombo.ItemIndex := 2
      end;
      Wizardform.ComponentsList.Checked[1] := NeedToInstallVirtualBox();
      Wizardform.ComponentsList.Checked[2] := NeedToInstallMSYS();
    end;
end;

procedure RunInstallVirtualBox();
var
  ResultCode: Integer;
begin
    //MsgBox('installing vbox', mbInformation, MB_OK);
    WizardForm.FilenameLabel.Caption := 'installing VirtualBox'
    if Exec(ExpandConstant('msiexec'), ExpandConstant('/qn /i "{app}\VirtualBox-4.3.12-r93733-MultiArch_amd64.msi"'), '', SW_HIDE,
       ewWaitUntilTerminated, ResultCode) then
    begin
      // handle success if necessary; ResultCode contains the exit code
      //MsgBox('vbox installed OK', mbInformation, MB_OK);
    end
    else begin
      // handle failure if necessary; ResultCode contains the error code
      MsgBox('vbox install failure', mbInformation, MB_OK);
    end;
    restart := True;
end;



procedure RunInstallMSYS();
var
  ResultCode: Integer;
begin
    WizardForm.FilenameLabel.Caption := 'installing MSYS Git'
    if Exec(ExpandConstant('{app}\Git-1.9.0-preview20140217.exe'), '/sp- /verysilent /norestart', '', SW_HIDE,
       ewWaitUntilTerminated, ResultCode) then
    begin
      // handle success if necessary; ResultCode contains the exit code
      //MsgBox('msys installed OK', mbInformation, MB_OK);
    end
    else begin
      // handle failure if necessary; ResultCode contains the error code
      MsgBox('msys install failure', mbInformation, MB_OK);
    end;
end;

const
	ModPathName = 'modifypath';
	ModPathType = 'user';

function ModPathDir(): TArrayOfString;
begin
	setArrayLength(Result, 1);
	Result[0] := ExpandConstant('{app}');
end;
#include "modpath.iss"
