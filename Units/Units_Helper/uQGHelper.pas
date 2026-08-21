unit uQGHelper;
 interface


USES Windows, Winapi.ShellAPI, SysUtils, classes, Registry, uStrings, Dialogs;

  procedure QCWriteRegistryStr(const QCKeyName, ValueName: string; QCValue: string);
  function QCReadRegistryStr(const QCKeyName, ValueName: string; Default: string = ''): string;
  procedure QCWriteRegistryInt(const QCKeyName, ValueName: string; QCValue: Integer);
  function QCRegistryIntRead(const QCRKeyName, QCRValueName: string; DefaultValue: Integer): Integer;
  function SelectFolderDlg1(var AFolder: string): Boolean;
  function IsInvalidHashStatus(const Status: string): Boolean;

implementation


function IsInvalidHashStatus(const Status: string): Boolean;
begin
  Result := SameText(Status, FileISMissingDescStr) or
            SameText(Copy(Status, 1, 6), 'ERROR:') or
            SameText(Status, 'UNSUPPORTED ON THIS SYSTEM') or
            SameText(Status, 'INVALID_HASH_TYPE');
end;

procedure QCWriteRegistryStr(const QCKeyName, ValueName: string; QCValue: string);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(QCKeyName, True) then
    begin
      Reg.WriteString(ValueName, QCValue);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function QCReadRegistryStr(const QCKeyName, ValueName: string; Default: string = ''): string;
var
  Reg: TRegistry;
begin
  Result := Default;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(QCKeyName) then
    begin
      if Reg.ValueExists(ValueName) then
        Result := Reg.ReadString(ValueName);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

procedure QCWriteRegistryInt(const QCKeyName, ValueName: string; QCValue: Integer);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create(KEY_WRITE);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey(QCKeyName, True) then
    begin
      Reg.WriteInteger(ValueName, QCValue);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

function QCRegistryIntRead(const QCRKeyName, QCRValueName: string; DefaultValue: Integer): Integer;
var
  Reg: TRegistry;
begin
  Result := DefaultValue;
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKeyReadOnly(QCRKeyName) then
    begin
      if Reg.ValueExists(QCRValueName) then
        Result := Reg.ReadInteger(QCRValueName);
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;


 function SelectFolderDlg1(var AFolder: string): Boolean;
var
  FolderDlg1: TFileOpenDialog;
begin
  Result := False;
  FolderDlg1 := TFileOpenDialog.Create(nil);
  try
    FolderDlg1.Options := [fdoPickFolders];  // enable folder picking
    FolderDlg1.Title := 'Choose folder to Generate Hash...';
    if FolderDlg1.Execute then
    begin
      AFolder := FolderDlg1.FileName;
      Result := True;
    end;
  finally
    FolderDlg1.Free;
  end;
end;







end.
