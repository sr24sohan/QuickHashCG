unit uResourceBuilder;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.Hash;

function BuildExeWithTextResource(
  const ADllPath: string;
  const AStubResName: string;
  const AOutputExe: string;
  const AResourceType: string;
  const AResourceName: string;
  const AText: string;
  ASkipHashCheck: Boolean = False
): Boolean;

function GetLastErrorMessage: string;

function ExtractStubBytesFromDLL(const ADllPath, AResName: string): TBytes;
function ValidateStubResource(const ADllPath, AStubResName: string; out FailReason: string): Boolean;

const
  LOAD_LIBRARY_AS_IMAGE_RESOURCE = $00000020;
  ExpectedStubSHA256 = 'FF68050440559AED7A69A32F8F0770EFAF5F0B3D58BFF6F18BF388570E9AF699';

implementation

function GetOwnExePath: string;
var
  Buffer: array[0..MAX_PATH] of Char;
begin
  SetString(Result, Buffer, GetModuleFileName(0, Buffer, MAX_PATH));
end;

function GetLastErrorMessage: string;
var
  ErrorCode: DWORD;
  Buffer: array[0..1023] of Char;
  Len: DWORD;
begin
  ErrorCode := GetLastError;
  if ErrorCode = ERROR_SUCCESS then
  begin
    Result := 'No Windows error was reported.';
    Exit;
  end;
  Len := FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM or FORMAT_MESSAGE_IGNORE_INSERTS,
    nil, ErrorCode, 0, Buffer, Length(Buffer), nil);
  if Len > 0 then
    Result := Format('Error %d: %s', [ErrorCode, Trim(Buffer)])
  else
    Result := Format('Windows error code: %d', [ErrorCode]);
end;

function StringToUtf8Bytes(const S: string): TBytes;
begin
  Result := TEncoding.UTF8.GetBytes(S);
end;

{ ---------- DLL er RCDATA resource theke stub bytes extract kora ---------- }
function ExtractStubBytesFromDLL(const ADllPath, AResName: string): TBytes;
var
  HMod: HMODULE;
  ResInfo: HRSRC;
  ResData: HGLOBAL;
  ResPtr: Pointer;
  ResSize: DWORD;
begin
  SetLength(Result, 0);

  if not FileExists(ADllPath) then
    raise EFileNotFoundException.CreateFmt('Helper library not found: %s', [ADllPath]);

  HMod := LoadLibraryEx(PChar(ADllPath), 0,
    LOAD_LIBRARY_AS_DATAFILE or LOAD_LIBRARY_AS_IMAGE_RESOURCE);
  if HMod = 0 then
    raise Exception.CreateFmt('Failed to load resource library: %s (%s)',
      [ADllPath, GetLastErrorMessage]);

  try
    ResInfo := FindResource(HMod, PChar(AResName), RT_RCDATA);
    if ResInfo = 0 then
      raise Exception.CreateFmt('Unexpected behavior detected for %s.', [ExtractFileName(ADllPath)]);

    ResData := LoadResource(HMod, ResInfo);
    if ResData = 0 then
      raise Exception.CreateFmt('Unexpected behavior detected for %s.', [ExtractFileName(ADllPath)]);

    ResPtr := LockResource(ResData);
    ResSize := SizeofResource(HMod, ResInfo);

    if (ResPtr = nil) or (ResSize = 0) then
      raise Exception.CreateFmt('Unexpected behavior detected for %s.', [ExtractFileName(ADllPath)]);

    SetLength(Result, ResSize);
    Move(ResPtr^, Result[0], ResSize);
  finally
    FreeLibrary(HMod);
  end;
end;

{ ---------- Shudhu structural (MZ/PE) validity check ---------- }
function VerifyStubStructureOnly(const StubBytes: TBytes; out FailReason: string): Boolean;
var
  DosHeader: PImageDosHeader;
  NtSignature: DWORD;
begin
  Result := False;
  FailReason := '';

  if Length(StubBytes) < SizeOf(TImageDosHeader) then
  begin
    FailReason := 'Stub is too small to be a valid executable.';
    Exit;
  end;

  DosHeader := @StubBytes[0];
  if DosHeader.e_magic <> IMAGE_DOS_SIGNATURE then
  begin
    FailReason := 'Stub does not have a valid MZ header (not a PE file).';
    Exit;
  end;

  if (DosHeader._lfanew <= 0) or
     (DosHeader._lfanew + SizeOf(DWORD) > Length(StubBytes)) then
  begin
    FailReason := 'Stub has an invalid PE header offset.';
    Exit;
  end;

  Move(StubBytes[DosHeader._lfanew], NtSignature, SizeOf(DWORD));
  if NtSignature <> IMAGE_NT_SIGNATURE then
  begin
    FailReason := 'Stub does not have a valid PE signature.';
    Exit;
  end;

  Result := True;
end;

{ ---------- Structural + hash validation (full check) ---------- }
function VerifyStubIntegrity(const StubBytes: TBytes; out FailReason: string): Boolean;
var
  Hasher: THashSHA2;
  ActualHash: string;
begin
  Result := False;
  FailReason := '';

  if not VerifyStubStructureOnly(StubBytes, FailReason) then
    Exit;

  if ExpectedStubSHA256 <> '' then
  begin
    Hasher := THashSHA2.Create(SHA256);
    Hasher.Update(StubBytes[0], Length(StubBytes));
    ActualHash := Hasher.HashAsString.ToUpper;

    if not SameText(ActualHash, ExpectedStubSHA256) then
    begin
      FailReason := 'Stub hash mismatch — the helper library appears to have been modified.';
      Exit;
    end;
  end;

  Result := True;
end;

function ValidateStubResource(const ADllPath, AStubResName: string; out FailReason: string): Boolean;
var
  StubBytes: TBytes;
begin
  Result := False;
  FailReason := '';
  try
    StubBytes := ExtractStubBytesFromDLL(ADllPath, AStubResName);
    if Length(StubBytes) = 0 then
    begin
      FailReason := 'Extracted stub is empty.';
      Exit;
    end;
    Result := VerifyStubIntegrity(StubBytes, FailReason);
  except
    on E: Exception do
      FailReason := E.Message;
  end;
end;

function BuildExeWithTextResource(
  const ADllPath: string;
  const AStubResName: string;
  const AOutputExe: string;
  const AResourceType: string;
  const AResourceName: string;
  const AText: string;
  ASkipHashCheck: Boolean = False
): Boolean;
var
  HUpdate: THandle;
  StubBytes, Data: TBytes;
  ResourceName, ResourceType: PChar;
  Committed: Boolean;
  FailReason, TempExe, OwnExe, ExpandedOutput, ExpandedDll: string;
  FS: TFileStream;
begin
  Committed := False;

  ExpandedOutput := ExpandFileName(AOutputExe);
  ExpandedDll := ExpandFileName(ADllPath);
  OwnExe := GetOwnExePath;

  // --- self-protect #1: output kokhono nijer chalu-thaka exe-ke target korte parbe na ---
  // GetModuleFileName use kora hocche, karon ParamStr(0) majhe majhe relative/short-name
  // return korte pare, jar fole SameText comparison silently fail (bypass) korte pare.
  if SameText(ExpandedOutput, ExpandFileName(OwnExe)) then
    raise Exception.Create('Output cannot be the currently running executable.');

  // --- self-protect #2: output kokhono helper DLL-ke o target korte parbe na ---
  if SameText(ExpandedOutput, ExpandedDll) then
    raise Exception.Create('Output cannot be the helper library file.');

  ForceDirectories(ExtractFileDir(ExpandedOutput));

  // --- Step 1: DLL theke stub bytes extract kora ---
  StubBytes := ExtractStubBytesFromDLL(ADllPath, AStubResName);
  if Length(StubBytes) = 0 then
    raise Exception.Create('Extracted stub is empty.');

  // --- Step 1.5: extract kora stub-ta valid kina verify kora ---
  if ASkipHashCheck then
  begin
    if not VerifyStubStructureOnly(StubBytes, FailReason) then
      raise Exception.Create('Stub integrity check failed: ' + FailReason +
        sLineBreak + 'The helper library may be corrupted or invalid.');
  end
  else
  begin
    if not VerifyStubIntegrity(StubBytes, FailReason) then
      raise Exception.Create('Stub integrity check failed: ' + FailReason +
        sLineBreak + 'The helper library may be corrupted, tampered, or modified.');
  end;

  // --- Step 2: atomic write er jonno temp file banano (shob shomoy AOutputExe-r sathe
  //     unique suffix jog kora hoy, tai eta kokhono onno kono existing file-er sathe collide korবে na) ---
  TempExe := ExpandedOutput + '.tmp' + IntToStr(GetCurrentThreadId) + IntToStr(GetTickCount);
  if FileExists(TempExe) then
    DeleteFile(TempExe);

  try
    FS := TFileStream.Create(TempExe, fmCreate);
    try
      FS.WriteBuffer(StubBytes[0], Length(StubBytes));
    finally
      FS.Free;
    end;

    // --- Step 3: temp file-er upor checksum text resource patch kora ---
    Data := StringToUtf8Bytes(AText);
    ResourceType := PChar(AResourceType);
    ResourceName := PChar(AResourceName);

    HUpdate := BeginUpdateResource(PChar(TempExe), False);
    if HUpdate = 0 then
      RaiseLastOSError;
    try
      if Length(Data) = 0 then
      begin
        if not UpdateResource(HUpdate, ResourceType, ResourceName, LANG_NEUTRAL, nil, 0) then
          RaiseLastOSError;
      end
      else
      begin
        if not UpdateResource(HUpdate, ResourceType, ResourceName, LANG_NEUTRAL, @Data[0], Length(Data)) then
          RaiseLastOSError;
      end;

      if not EndUpdateResource(HUpdate, False) then
        RaiseLastOSError;

      Committed := True;
    except
      if not Committed then
        EndUpdateResource(HUpdate, True);
      raise;
    end;

    // --- Step 4: final safety re-check — rename-er thik age abar nishchit kora hocche
    //     je target kono vabe running exe hoye jay ni (race-condition guard) ---
    if SameText(ExpandedOutput, ExpandFileName(GetOwnExePath)) then
      raise Exception.Create('Output cannot be the currently running executable.');

    // --- Step 5: verified-good temp file-ke final destination-e atomically move kora ---
    if FileExists(ExpandedOutput) then
      DeleteFile(ExpandedOutput);
    if not RenameFile(TempExe, ExpandedOutput) then
      RaiseLastOSError;

    Result := True;
  except
    if FileExists(TempExe) then
      DeleteFile(TempExe);
    raise;
  end;
end;

end.
