unit QCHashGen;

interface

uses
  Windows, SysUtils, Classes, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,  uResourceProtector,
  Vcl.StdCtrls, System.IOUtils, ShellAPI, Hash, Types, Vcl.Menus, Winapi.Messages, uNumericInput,
  uQGHelper, UITypes, uQCEngine, Clipbrd, Vcl.Taskbar, System.Win.TaskbarCore, Graphics, uResourceBuilder,
  uStrings, System.Generics.Collections, System.Generics.Defaults, uAbout,
  CRCArraysTable;

type
  TFileProgressEvent = procedure(FileIndex: Integer; BytesDone, BytesTotal: Int64) of object;
  TFileDoneEvent = procedure(FileIndex: Integer; HashValue: string) of object;
  TFileStartEvent = procedure(FileIndex: Integer) of object;
  TBatchDoneEvent = procedure of object;
  TFileSkipCheckEvent = function(FileIndex: Integer): Boolean of object;

  THashWorker = class(TThread)
  private
    FFileList: TStrings;
    FStartIndex: Integer;
    FFileIndex: Integer;
    FBuffer: TBytes;
    FOnFileStart: TFileStartEvent;
    FOnProgress: TFileProgressEvent;
    FOnDone: TFileDoneEvent;
    FOnBatchDone: TBatchDoneEvent;
    FOnShouldSkip: TFileSkipCheckEvent;
    FOnFileSkip: TFileStartEvent;
    procedure HashSingleFile(const AFileName: string);
  protected
    procedure Execute; override;
    procedure UpdateProgress(BytesDone, BytesTotal: Int64);
    procedure Finish(HashValue: string);
    procedure NotifyFileStart;
    procedure NotifyBatchDone;
    procedure NotifyFileSkip;
  public
   constructor Create(AFileList: TStrings; AStartIndex: Integer;
      OnFileStart: TFileStartEvent; OnProgress: TFileProgressEvent;
      OnDone: TFileDoneEvent; OnBatchDone: TBatchDoneEvent;
      OnShouldSkip: TFileSkipCheckEvent; OnFileSkip: TFileStartEvent);
  end;

type
  TQGListRow = record
    FullPath: string;
    RelPath: string;
    SizeStr: string;
    StatusStr: string;
  end;

 type
  NTSTATUS = LongInt;

type
  THashGenFrm1 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    QCListView1: TListView;
    ProgressBar1: TProgressBar;
    QCLabelParcent: TLabel;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    ChooseFiles: TMenuItem;
    ChooseFolder1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    About1: TMenuItem;
    SaveHash: TMenuItem;
    N2: TMenuItem;
    HashType1: TMenuItem;
    CheckBox1MD5: TMenuItem;
    CheckBox2SHA1: TMenuItem;
    CheckBox3SHA256: TMenuItem;
    Label2: TLabel;
    ProgressBar2: TProgressBar;
    CurrenntFileProg1: TLabel;
    RemoveAll: TMenuItem;
    N7: TMenuItem;
    Generate1: TMenuItem;
    ReGenerateHash1: TMenuItem;
    ClearAllHash: TMenuItem;
    StopHashGeneration1: TMenuItem;
    RemoveSelected1: TMenuItem;
    SaveAs1: TMenuItem;
    PopupMenu1: TPopupMenu;
    ShowInExplorerMenu: TMenuItem;
    N4: TMenuItem;
    Cancel1: TMenuItem;
    SaveHashEachFile1: TMenuItem;
    TaskbarControll: TTaskbar;
    Checkbox0CRC: TMenuItem;
    SelectAll1: TMenuItem;
    CopyHash1: TMenuItem;
    N6: TMenuItem;
    N8: TMenuItem;
    CopyHashwithFilename1: TMenuItem;
    GenerateHash1: TMenuItem;
    N3: TMenuItem;
    SetRootPathDepth1: TMenuItem;
    CheckBox4SHA384: TMenuItem;
    CheckBox5SHA512: TMenuItem;
    N5: TMenuItem;
    Refresh1: TMenuItem;
    ExporttoCheckifier1: TMenuItem;
    N9: TMenuItem;
    WhatsNew1: TMenuItem;
    procedure Default(Sender: TObject);
    procedure ChooseFolder1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure ChoosingHashType(Sender: TObject);
    procedure FixColumnWidtsToApp;
    procedure ChooseFilesClick(Sender: TObject);
    procedure SaveHashClick(Sender: TObject);
    procedure ReGenerateHash1Click(Sender: TObject);
    procedure ClearAllHashClick(Sender: TObject);
    procedure RemoveAllClick(Sender: TObject);
    procedure RemoveSelected1Click(Sender: TObject);
    procedure SaveAs1Click(Sender: TObject);
    procedure StopHashGeneration1Click(Sender: TObject);
    procedure QCListView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowInExplorerMenuClick(Sender: TObject);
    procedure SaveHashEachFile1Click(Sender: TObject);
    procedure SaveQGenify(Sender: TObject);
    procedure ProcessFiles(const Files: TStringList);
    procedure About1Click(Sender: TObject);
    procedure SelectAll1Click(Sender: TObject);
    procedure CopyHash2Click(Sender: TObject);
    procedure CopyHash1Click(Sender: TObject);
    procedure CopyFileName1Click(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure CopyHashwithFilename1Click(Sender: TObject);
    procedure GenerateHash1Click(Sender: TObject);
    procedure SetRootPathDepth1Click(Sender: TObject);
    procedure CheckBox5SHA512Click(Sender: TObject);
    procedure CheckBox4SHA384Click(Sender: TObject);
    procedure RefreshList1Click(Sender: TObject);
    procedure QCListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure QCListView1CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure ExporttoCheckifier1Click(Sender: TObject);
    procedure WhatsNew1Click(Sender: TObject);
   private
    FCurrentWorker: THashWorker;
    FileQueue: TStringList;
    CurrentIndex: Integer;
    FullFilePaths: TStringList;
    FRootPathDepth: Integer;     // 0 = disabled
    FTotalBytes: Int64;
    FTotalWork: Int64;
    FProcessedWork: Int64;
    FPendingDropFiles: TStringList;
    FCurrentRootFolder: string;
    FLastSelectedIndex: Integer;
    procedure DeleteSelectedItems;
    procedure DisableEverything;
    procedure EnableEverything;
    procedure MakeListsItemsQueue;
    function SaveDialogeQG1: TSaveDialog;
    procedure StartNextFile;
    procedure OnFileStart(FileIndex: Integer);
    procedure OnFileProgress(FileIndex: Integer; BytesDone, BytesTotal: Int64);
    procedure OnFileDone(FileIndex: Integer; HashValue: string);
    procedure OnAllDone;
    procedure WorkerTerminatedHandler(Sender: TObject);
    function GetFormattedFileSize(const FilePath: string): string;
    procedure ReGenerateHash;
    procedure GettingReadyQCListView;
    procedure SavingQCLastChanges;
    procedure DeleteTListViewItems;
    procedure ShowinFileExplorer;
    procedure CopyGeneratedHash;
    function GetHashTypeName: string;
    function GetDefaultExtForHashType: string;
    procedure AddExportHeader(Lines: TStringList; const TargetFileName: string; UseDefaultExt: Boolean = False);

    function GetPathWithDepth(const RelPath: string): string;
    function FindFirstPendingIndex: Integer;
    procedure PrepareProgressTotals(StartIndex: Integer);
    function IsFileAlreadyHashed(FileIndex: Integer): Boolean;
    procedure SelectListItem(FileIndex: Integer);
    procedure OnFileSkip(FileIndex: Integer);
    procedure PopulateFileList(const CandidateRoot: string; NewFullPaths: TStringList);   // <-- নতুন
    procedure RefreshList;                                                                 // <-- নতুন
    function IsDuplicatePath(const FullPath: string): Boolean;                             // <-- নতুন
    function BuildRelativePath(const RootFolder, FullPath: string): string;                // <-- নতুন
    procedure RenumberListCaptions;                                                        // <-- নতুন
    function ShouldMergeWithExisting(const CandidateRoot: string): Boolean;                // <-- নতুন
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;



    function BuildChecksumSaveText(const ForFileName: string): string;   // <-- parameter যোগ হলো


  //  Procedure CalculateExternalResourcesHash;

  public
  end;

var
  HashGenFrm1: THashGenFrm1;
  SavePathFileName: string;
  SavedHashFile: Boolean = False;
  GBatchAlgHandle: Pointer = nil;
  GBatchDigestLen: Cardinal = 0;

const
  SkipVisualDelayMs = 1;
  OverheadPerFile: Int64 = 1024 * 1024;
  NoFilesFoundInListMessage = 'No files found in the list.';
  GenerateHashFirstMessage = 'Please generate a hash before saving.';
  GenerateHashBeforeCopyFirstMessage = 'Please generate a hash before copying hash.';
  HasesSavedforExistFileMessages = 'Hashes exported to ';
  EachFileSaveHashFailedStr = 'Failed to save checksum. Please try again.';
  SaveHashFormat = '%s *%s';

  BCRYPT_MD5_ALGORITHM: PWideChar = 'MD5';
  BCRYPT_SHA1_ALGORITHM: PWideChar = 'SHA1';
  BCRYPT_SHA256_ALGORITHM: PWideChar = 'SHA256';
  BCRYPT_SHA384_ALGORITHM: PWideChar = 'SHA384';
  BCRYPT_SHA512_ALGORITHM: PWideChar = 'SHA512';
  BCRYPT_OBJECT_LENGTH: PWideChar = 'ObjectLength';
  BCRYPT_HASH_LENGTH: PWideChar = 'HashDigestLength';
  STATUS_SUCCESS = 0;

implementation

{$R *.dfm}

function StrCmpLogicalW(psz1, psz2: PWideChar): Integer; stdcall;  external 'shlwapi.dll' name 'StrCmpLogicalW';
function BCryptOpenAlgorithmProvider(var phAlgorithm: Pointer; pszAlgId: PWideChar; pszImplementation: PWideChar; dwFlags: DWORD): NTSTATUS; stdcall; external 'bcrypt.dll';
function BCryptCloseAlgorithmProvider(hAlgorithm: Pointer; dwFlags: DWORD): NTSTATUS;stdcall; external 'bcrypt.dll';
function BCryptGetProperty(hObject: Pointer; pszProperty: PWideChar; pbOutput: PByte; cbOutput: ULONG; var pcbResult: ULONG; dwFlags: DWORD): NTSTATUS; stdcall; external 'bcrypt.dll';
function BCryptCreateHash(hAlgorithm: Pointer; var phHash: Pointer; pbHashObject: PByte; cbHashObject: ULONG; pbSecret: PByte; cbSecret: ULONG; dwFlags: DWORD): NTSTATUS; stdcall; external 'bcrypt.dll';
function BCryptHashData(hHash: Pointer; pbInput: PByte; cbInput: ULONG; dwFlags: DWORD): NTSTATUS; stdcall; external 'bcrypt.dll';
function BCryptFinishHash(hHash: Pointer; pbOutput: PByte; cbOutput: ULONG; dwFlags: DWORD): NTSTATUS; stdcall; external 'bcrypt.dll';
function BCryptDestroyHash(hHash: Pointer): NTSTATUS; stdcall; external 'bcrypt.dll';


function CommonAncestorPath(Dirs: TStringList): string;
var
  i: Integer;
  Best, Candidate, Parent: string;

  function IsAncestorOrEqual(const AParent, AChild: string): Boolean;
  var
    NP, NC: string;
  begin
    NP := LowerCase(IncludeTrailingPathDelimiter(ExcludeTrailingPathDelimiter(AParent)));
    NC := LowerCase(IncludeTrailingPathDelimiter(ExcludeTrailingPathDelimiter(AChild)));
    Result := SameText(ExcludeTrailingPathDelimiter(AParent), ExcludeTrailingPathDelimiter(AChild))
              or (Pos(NP, NC) = 1);
  end;
begin
  Result := '';
  if Dirs.Count = 0 then Exit;

  Best := ExcludeTrailingPathDelimiter(Dirs[0]);
  for i := 1 to Dirs.Count - 1 do
  begin
    Candidate := ExcludeTrailingPathDelimiter(Dirs[i]);
    while (Best <> '') and (not IsAncestorOrEqual(Best, Candidate)) do
    begin
      Parent := ExcludeTrailingPathDelimiter(ExtractFileDir(Best));
      if SameText(Parent, Best) then
      begin
        Best := '';   // drive root এ পৌঁছে গেছে, আর উপরে যাওয়া যাচ্ছে না
        Break;
      end;
      Best := Parent;
    end;
    if Best = '' then Break;
  end;

  Result := Best;
end;

procedure OpenBatchAlgHandle;
var
  AlgId: PWideChar;
  cbResult: ULONG;
begin
  GBatchAlgHandle := nil;
  GBatchDigestLen := 0;

  if HashGenFrm1.Checkbox0CRC.Checked then Exit;  // CRC32-তে BCrypt লাগে না

  if HashGenFrm1.CheckBox1MD5.Checked then AlgId := BCRYPT_MD5_ALGORITHM
  else if HashGenFrm1.CheckBox2SHA1.Checked then AlgId := BCRYPT_SHA1_ALGORITHM
  else if HashGenFrm1.CheckBox3SHA256.Checked then AlgId := BCRYPT_SHA256_ALGORITHM
  else if HashGenFrm1.CheckBox4SHA384.Checked then AlgId := BCRYPT_SHA384_ALGORITHM
  else if HashGenFrm1.CheckBox5SHA512.Checked then AlgId := BCRYPT_SHA512_ALGORITHM
  else Exit;

  if BCryptOpenAlgorithmProvider(GBatchAlgHandle, AlgId, nil, 0) <> STATUS_SUCCESS then
  begin
    GBatchAlgHandle := nil;
    Exit;   // খুলতে না পারলে worker আগের মতোই software fallback ব্যবহার করবে
  end;

  cbResult := 0;
  if BCryptGetProperty(GBatchAlgHandle, BCRYPT_HASH_LENGTH,
       PByte(@GBatchDigestLen), SizeOf(GBatchDigestLen), cbResult, 0) <> STATUS_SUCCESS then
  begin
    BCryptCloseAlgorithmProvider(GBatchAlgHandle, 0);
    GBatchAlgHandle := nil;
    GBatchDigestLen := 0;
  end;
end;

procedure CloseBatchAlgHandle;
begin
  if Assigned(GBatchAlgHandle) then
  begin
    BCryptCloseAlgorithmProvider(GBatchAlgHandle, 0);
    GBatchAlgHandle := nil;
  end;
  GBatchDigestLen := 0;
end;


function THashGenFrm1.GetHashTypeName: string;
begin
  if Checkbox0CRC.Checked then Result := 'CRC32'
  else if CheckBox1MD5.Checked then Result := 'MD5'
  else if CheckBox2SHA1.Checked then Result := 'SHA1'
  else if CheckBox3SHA256.Checked then Result := 'SHA256'
  else if CheckBox4SHA384.Checked then Result := 'SHA384'
  else if CheckBox5SHA512.Checked then Result := 'SHA512'
  else Result := 'Unknown';
end;

procedure THashGenFrm1.AddExportHeader(Lines: TStringList; const TargetFileName: string; UseDefaultExt: Boolean = False);
var
  DisplayName: string;
begin
  if UseDefaultExt then
    DisplayName := ChangeFileExt(ExtractFileName(TargetFileName), '.' + GetDefaultExtForHashType)
  else
    DisplayName := ExtractFileName(TargetFileName);

  Lines.Add('# ' + DisplayName);
  Lines.Add('// Hash Type: ' + GetHashTypeName);
  Lines.Add('// Generated with: ' + MY_APP_NAME_GENIFY);
  Lines.Add('// Generated Date: ' + FormatDateTime('dd mmmm, yyyy hh:nn', Now));
  Lines.Add('// ---------------------------------------------');
  Lines.Add('');
end;

procedure QCSetReadOnly(const FileName: string; ReadOnly: Boolean);
var
  Attr: DWORD;
begin
  Attr := GetFileAttributes(PChar(FileName));
  if Attr = INVALID_FILE_ATTRIBUTES then Exit;
  if ReadOnly then
    Attr := Attr or FILE_ATTRIBUTE_READONLY
  else
    Attr := Attr and not FILE_ATTRIBUTE_READONLY;
  SetFileAttributes(PChar(FileName), Attr);
end;

procedure CollectFilesNoHidden(const Root: string; FileList: TStrings);
var
  SR: TSearchRec;
  Attr: Cardinal;
  SubDir: string;
begin
  if FindFirst(IncludeTrailingPathDelimiter(Root) + '*.*', faAnyFile, SR) = 0 then
  try
    repeat
      if (SR.Name = '.') or (SR.Name = '..') then
        Continue;
      SubDir := IncludeTrailingPathDelimiter(Root) + SR.Name;
      Attr := GetFileAttributes(PChar(SubDir));
      if Attr = INVALID_FILE_ATTRIBUTES then
        Continue;
      if (Attr and FILE_ATTRIBUTE_DIRECTORY) <> 0 then
      begin
        if (Attr and (FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM)) <> 0 then
          Continue;
        CollectFilesNoHidden(SubDir, FileList);
      end
      else
      begin
        if (Attr and (FILE_ATTRIBUTE_HIDDEN or FILE_ATTRIBUTE_SYSTEM)) <> 0 then
          Continue;
        FileList.Add(SubDir);
      end;
    until FindNext(SR) <> 0;
  finally
    FindClose(SR);
  end;
end;

function THashGenFrm1.GetPathWithDepth(const RelPath: string): string;
var
  i: Integer;
  Prefix: string;
begin
  if FRootPathDepth <= 0 then
  begin
    Result := RelPath;
    Exit;
  end;
  Prefix := '';
  for i := 1 to FRootPathDepth do
    Prefix := Prefix + '..\';
  Result := Prefix + RelPath;
end;

function THashGenFrm1.FindFirstPendingIndex: Integer;
var
  i: Integer;
  Status: string;
begin
  Result := -1;
  for i := 0 to QCListView1.Items.Count - 1 do
  begin
    Status := QCListView1.Items[i].SubItems[2];
    if (Status = QueueItemsStatusCaption) or
       (Status = GeneratingHashStatusCaption) or
       (Status = AbortedStatusCaption) then
    begin
      Result := i;
      Exit;
    end;
  end;
end;

procedure THashGenFrm1.ChooseFolder1Click(Sender: TObject);
var
  Folder: string;
  NewFiles: TStringList;
begin
  if not SelectFolderDlg1(Folder) then Exit;

  NewFiles := TStringList.Create;
  try
    CollectFilesNoHidden(Folder, NewFiles);
    if NewFiles.Count = 0 then
    begin
      MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
      Exit;
    end;
    PopulateFileList(Folder, NewFiles);
  finally
    NewFiles.Free;
  end;
end;

procedure THashGenFrm1.About1Click(Sender: TObject);
begin
   About := TAbout.Create(Self);
   About.ShowInTaskBar:=False;
   About.Label1.Caption:=MY_APP_NAME_GENIFY;
   About.Label2.Caption:='Version: '+MY_APP_VERSION;
   About.ShowModal;
end;
        {
procedure THashGenFrm1.CalculateExternalResourcesHash;
var
  Hasher: THashSHA2;
  Bytes: TBytes;
begin
  Bytes := ExtractStubBytesFromDLL('ShellExtHelper.dll', 'CHECKIFIER');
  Hasher := THashSHA2.Create(SHA256);
  Hasher.Update(Bytes[0], Length(Bytes));
  ShowMessage(Hasher.HashAsString.ToUpper);
  Clipboard.AsText:=Hasher.HashAsString.ToUpper;
end;
     }
procedure THashGenFrm1.CheckBox4SHA384Click(Sender: TObject);
begin
ChoosingHashType(Sender);
end;

procedure THashGenFrm1.CheckBox5SHA512Click(Sender: TObject);
begin
  ChoosingHashType(Sender);
end;

procedure THashGenFrm1.ChooseFilesClick(Sender: TObject);
var
  i: Integer;
  OpenDialog1: TOpenDialog;
  NewFiles: TStringList;
  CandidateRoot: string;
begin
  OpenDialog1 := TOpenDialog.Create(nil);
  OpenDialog1.Filter := 'All Files (*.*)|*.*';
  OpenDialog1.Options := [ofAllowMultiSelect, ofFileMustExist, ofEnableSizing];
  try
    if not OpenDialog1.Execute then Exit;

    NewFiles := TStringList.Create;
    try
      for i := 0 to OpenDialog1.Files.Count - 1 do
        NewFiles.Add(OpenDialog1.Files[i]);

      CandidateRoot := ExtractFileDir(OpenDialog1.FileName);
      PopulateFileList(CandidateRoot, NewFiles);
    finally
      NewFiles.Free;
    end;
  finally
    OpenDialog1.Free;
  end;
end;

procedure THashGenFrm1.StopHashGeneration1Click(Sender: TObject);
begin
  FreeAndNil(FPendingDropFiles);
  if Assigned(FCurrentWorker) then
  begin
    FCurrentWorker.Terminate;
    if (CurrentIndex >= 0) and (CurrentIndex < QCListView1.Items.Count) then
      QCListView1.Items[CurrentIndex].SubItems[2] := AbortedStatusCaption;
    FCurrentWorker := nil;
  end;
  QCListView1.MultiSelect := True;
  EnableEverything;
end;

procedure THashGenFrm1.WhatsNew1Click(Sender: TObject);
const
  WhatsNewHTML = 'what''s_new.html';
var
  HTMLDocPath: string;
begin
  HTMLDocPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + WhatsNewHTML;
  if not FileExists(HTMLDocPath) then Exit;
  ShellExecute(Handle, 'open', PChar(HTMLDocPath), nil, nil, SW_SHOWNORMAL);
end;

procedure THashGenFrm1.WMDropFiles(var Msg: TWMDropFiles);
var
  FileName: array[0..MAX_PATH] of Char;
  DroppedFiles: TStringList;
  i, FileCount: Integer;
begin
  FileCount := DragQueryFile(Msg.Drop, $FFFFFFFF, nil, 0);
  if FileCount = 0 then
  begin
    DragFinish(Msg.Drop);
    Exit;
  end;

  DroppedFiles := TStringList.Create;
  for i := 0 to FileCount - 1 do
    if DragQueryFile(Msg.Drop, i, FileName, MAX_PATH) > 0 then
      DroppedFiles.Add(FileName);
  DragFinish(Msg.Drop);

  if Assigned(FCurrentWorker) then
    StopHashGeneration1Click(Self);

  Caption := MY_APP_NAME_GENIFY;
  try
    ProcessFiles(DroppedFiles);
  finally
    DroppedFiles.Free;
  end;
end;

procedure THashGenFrm1.WorkerTerminatedHandler(Sender: TObject);
var
  Files: TStringList;
begin
  if FCurrentWorker = Sender then
    FCurrentWorker := nil;
  if Assigned(FPendingDropFiles) then
  begin
    Files := FPendingDropFiles;
    FPendingDropFiles := nil;
    try
      Caption := MY_APP_NAME_GENIFY;
      ProcessFiles(Files);
    finally
      Files.Free;
    end;
  end;
end;

procedure THashGenFrm1.QCListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
begin
  if (Item.SubItems.Count >= 3) and IsInvalidHashStatus(Item.SubItems[2]) then
    Sender.Canvas.Font.Color := clRed
  else
    Sender.Canvas.Font.Color := clWindowText;

  DefaultDraw := True;
end;

procedure THashGenFrm1.QCListView1CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if (Item.SubItems.Count >= 3) and IsInvalidHashStatus(Item.SubItems[2]) then
    Sender.Canvas.Font.Color := clRed
  else
    Sender.Canvas.Font.Color := clWindowText;

  DefaultDraw := True;
end;

procedure THashGenFrm1.QCListView1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
  i: Integer;
begin
  if Button <> mbRight then Exit;
  Item := QCListView1.GetItemAt(X, Y);
  QCListView1.Items.BeginUpdate;
  try
    for i := 0 to QCListView1.Items.Count - 1 do
      QCListView1.Items[i].Selected := False;

    if Assigned(Item) then
    begin
      QCListView1.ItemFocused := Item;
      Item.Selected := True;
    end;
  finally
    QCListView1.Items.EndUpdate;
  end;
end;

procedure THashGenFrm1.SaveAs1Click(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  ContentLines, FinalLines: TStringList;
  item: TListItem;
  i: Integer;
  FileName: string;
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;

  // still require that every pending file has finished
  for i := 0 to QCListView1.Items.Count - 1 do
    if (QCListView1.Items[i].SubItems[2] = QueueItemsStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = GeneratingHashStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = AbortedStatusCaption) then
    begin
      MessageDlg(GenerateHashFirstMessage, mtWarning, [mbOK], 0);
      Exit;
    end;

  ContentLines := TStringList.Create;
  try
    for i := 0 to QCListView1.Items.Count - 1 do
    begin
      item := QCListView1.Items[i];
      // *** SKIP invalid / missing / error hashes ***
      if IsInvalidHashStatus(item.SubItems[2]) then
        Continue;
      ContentLines.Add(Format(SaveHashFormat, [item.SubItems[2], GetPathWithDepth(item.SubItems[0])]));
    end;

    if ContentLines.Count = 0 then
    begin
      MessageDlg('No valid hashes to save.', mtWarning, [mbOK], 0);
      Exit;
    end;

    SaveDlg := SaveDialogeQG1;
    try
      SaveDlg.InitialDir := FCurrentRootFolder;
      if not SaveDlg.Execute then Exit;
      FileName := SaveDlg.FileName;

      FinalLines := TStringList.Create;
      try
        AddExportHeader(FinalLines, FileName);
        FinalLines.AddStrings(ContentLines);
        FinalLines.SaveToFile(FileName, TEncoding.UTF8);
        QCSetReadOnly(FileName, True);
      finally
        FinalLines.Free;
      end;

      SavePathFileName := FileName;
      if FileExists(SavePathFileName) then
        Caption := SavePathFileName;
    finally
      SaveDlg.Free;
    end;
  finally
    ContentLines.Free;
  end;
end;



function THashGenFrm1.SaveDialogeQG1: TSaveDialog;
begin
  Result := TSaveDialog.Create(nil);
  if Checkbox0CRC.Checked then
  begin
    Result.Filter := 'CRC32 Files (*.crc32)|*.crc32|CRC32 Files (*.crc)|*.crc|CRC32 Checksum (*.sfv)|*.sfv';
    Result.DefaultExt := 'crc32';
  end
  else if CheckBox1MD5.Checked then
  begin
    Result.Filter := 'MD5 Checksum (*.md5)|*.md5';
    Result.DefaultExt := 'md5';
  end
  else if CheckBox2SHA1.Checked then
  begin
    Result.Filter := 'SHA-1 Checksum (*.sha1)|*.sha1|SHA Checksum (*.sh1)|*.sh1|SHA Checksum Files (*.sh)|*.sh';
    Result.DefaultExt := 'sha1';
  end
  else if CheckBox3SHA256.Checked then
  begin
    Result.Filter := 'SHA-256 Checksum (*.sha256)|*.sha256|SHA Checksum (*.sh256)|*.sh256|SHA Checksum Files (*.sh)|*.sh';
    Result.DefaultExt := 'sha256';
  end
  else if CheckBox4SHA384.Checked then
  begin
    Result.Filter := 'SHA-384 Checksum (*.sha384)|*.sha384|SHA Checksum (*.sh384)|*.sh384|SHA Checksum Files (*.sh)|*.sh';
    Result.DefaultExt := 'sha384';
  end
  else if CheckBox5SHA512.Checked then
  begin
    Result.Filter := 'SHA-512 Checksum (*.sha512)|*.sha512|SHA Checksum (*.sh512)|*.sh512|SHA Checksum Files (*.sh)|*.sh';
    Result.DefaultExt := 'sha512';
  end;
end;

procedure THashGenFrm1.SaveHashEachFile1Click(Sender: TObject);
var
  i: Integer;
  Item: TListItem;
  HashFileName, FileExt, FilePath: string;
  FileLines: TStringList;
  SavedAny: Boolean;
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;

  for i := 0 to QCListView1.Items.Count - 1 do
    if (QCListView1.Items[i].SubItems[2] = QueueItemsStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = GeneratingHashStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = AbortedStatusCaption) then
    begin
      MessageDlg(GenerateHashFirstMessage, mtWarning, [mbOK], 0);
      Exit;
    end;

  if Checkbox0CRC.Checked then FileExt := '.sfv'
  else if CheckBox1MD5.Checked then FileExt := '.md5'
  else if CheckBox2SHA1.Checked then FileExt := '.sha1'
  else if CheckBox3SHA256.Checked then FileExt := '.sha256'
  else if CheckBox4SHA384.Checked then FileExt := '.sha384'
  else if CheckBox5SHA512.Checked then FileExt := '.sha512'
  else Exit;

  SavedAny := False;
  for i := 0 to QCListView1.Items.Count - 1 do
  begin
    Item := QCListView1.Items[i];

    // *** SKIP invalid / missing / error hashes ***
    if IsInvalidHashStatus(Item.SubItems[2]) then
      Continue;

    FilePath := FullFilePaths[i];
    HashFileName := ChangeFileExt(FilePath, FileExt);
    try
      if FileExists(HashFileName) then
        QCSetReadOnly(HashFileName, False);

      FileLines := TStringList.Create;
      try
        AddExportHeader(FileLines, HashFileName);
        FileLines.Add(Format(SaveHashFormat, [Item.SubItems[2], GetPathWithDepth(Item.SubItems[0])]));
        FileLines.SaveToFile(HashFileName, TEncoding.UTF8);
      finally
        FileLines.Free;
      end;

      QCSetReadOnly(HashFileName, True);
      SavedAny := True;
    except
      on E: Exception do
      begin
        MessageDlg(EachFileSaveHashFailedStr + sLineBreak + sLineBreak + FilePath + ' ' + E.Message,
          mtWarning, [mbOK], 0);
        Exit;
      end;
    end;
  end;

  if not SavedAny then
  begin
    MessageDlg('No valid hashes to save.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Application.MessageBox(PChar('Hashes saved for each file successfully!' + sLineBreak + sLineBreak +
    'Saved Path: ' + ExtractFileDir(HashFileName)), 'Information', MB_OK or MB_ICONINFORMATION);
end;

procedure THashGenFrm1.ShowInExplorerMenuClick(Sender: TObject);
begin
  ShowinFileExplorer;
end;

procedure THashGenFrm1.ShowinFileExplorer;
var
  Item: TListItem;
  FullPath: string;
begin
  Item := QCListView1.Selected;
  if not Assigned(Item) then Exit;
  FullPath := FullFilePaths[Item.Index];
  if FileExists(FullPath) then
    ShellExecute(Handle, 'open', 'explorer.exe',
      PChar('/select,"' + FullPath + '"'), nil, SW_SHOWNORMAL);
end;

procedure THashGenFrm1.SaveHashClick(Sender: TObject);
var
  SaveDlg: TSaveDialog;
  ContentLines, FinalLines: TStringList;
  item: TListItem;
  i: Integer;
  FileName: string;
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;

  for i := 0 to QCListView1.Items.Count - 1 do
    if (QCListView1.Items[i].SubItems[2] = QueueItemsStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = GeneratingHashStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = AbortedStatusCaption) then
    begin
      MessageDlg(GenerateHashFirstMessage, mtWarning, [mbOK], 0);
      Exit;
    end;

  ContentLines := TStringList.Create;
  try
    for i := 0 to QCListView1.Items.Count - 1 do
    begin
      item := QCListView1.Items[i];
      // *** SKIP invalid / missing / error hashes ***
      if IsInvalidHashStatus(item.SubItems[2]) then
        Continue;
      ContentLines.Add(Format(SaveHashFormat, [item.SubItems[2], GetPathWithDepth(item.SubItems[0])]));
    end;

    if ContentLines.Count = 0 then
    begin
      MessageDlg('No valid hashes to save.', mtWarning, [mbOK], 0);
      Exit;
    end;

    if FileExists(SavePathFileName) then
    begin
      FinalLines := TStringList.Create;
      try
        AddExportHeader(FinalLines, SavePathFileName);
        FinalLines.AddStrings(ContentLines);
        QCSetReadOnly(SavePathFileName, False);
        FinalLines.SaveToFile(SavePathFileName, TEncoding.UTF8);
        QCSetReadOnly(SavePathFileName, True);
      finally
        FinalLines.Free;
      end;
      Application.MessageBox(PChar(HasesSavedforExistFileMessages + '"' + SavePathFileName + '"'),
        'Information', MB_OK or MB_ICONINFORMATION);
    end
    else
    begin
      SaveDlg := SaveDialogeQG1;
      try
        SaveDlg.InitialDir := FCurrentRootFolder;
        if not SaveDlg.Execute then Exit;
        FileName := SaveDlg.FileName;

        FinalLines := TStringList.Create;
        try
          AddExportHeader(FinalLines, FileName);
          FinalLines.AddStrings(ContentLines);
          FinalLines.SaveToFile(FileName, TEncoding.UTF8);
          QCSetReadOnly(FileName, True);
        finally
          FinalLines.Free;
        end;

        SavePathFileName := FileName;
        Caption := FileName;
      finally
        SaveDlg.Free;
      end;
    end;
    SavedHashFile := True;
    SaveHash.Enabled := False;
  finally
    ContentLines.Free;
  end;
end;



procedure THashGenFrm1.Exit1Click(Sender: TObject);
begin
 Application.Terminate;

// CalculateExternalResourcesHash;
end;


procedure THashGenFrm1.ExporttoCheckifier1Click(Sender: TObject);
const
  StubDllName = 'ShellExtHelper.dll';
  StubResourceName = 'CHECKIFIER';
var
  Dlg: TSaveDialog;
  i: Integer;
  DllFile, OutputExe, SaveText, FailReason: string;
  StubValidated: Boolean;
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;
  for i := 0 to QCListView1.Items.Count - 1 do
    if (QCListView1.Items[i].SubItems[2] = QueueItemsStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = GeneratingHashStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = AbortedStatusCaption) then
    begin
      MessageDlg(GenerateHashFirstMessage, mtWarning, [mbOK], 0);
      Exit;
    end;
  if not ExporttoCheckifier1.Enabled then Exit;
  DllFile := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + StubDllName;
  if not FileExists(DllFile) then
  begin
    MessageDlg('Required library not found in application folder:' + sLineBreak + DllFile,
      mtError, [mbOK], 0);
    Exit;
  end;
  // --- Menu click korার shathe shathei resource validate kora hocche ---
  StubValidated := ValidateStubResource(DllFile, StubResourceName, FailReason);
  if not StubValidated then
  begin
    if Application.MessageBox(
         PChar('The Checkifier component could not be verified as authentic.' + sLineBreak + sLineBreak +
               'This may indicate the helper library has been modified, corrupted, or replaced ' +
               'by an unrecognized source.' + sLineBreak + sLineBreak +
               'Do you want to continue anyway?'),
         'Warning',
         MB_YESNO or MB_ICONWARNING) <> IDYES then
      Exit;
  end;
  Dlg := TSaveDialog.Create(nil);
  try
    Dlg.Title := 'Export to Checkifier';
    Dlg.Filter := 'Checkifier Executable (*.exe)|*.exe';
    Dlg.DefaultExt := 'exe';
    Dlg.InitialDir := FCurrentRootFolder;
    Dlg.Options := Dlg.Options + [ofOverwritePrompt];
    if not Dlg.Execute then Exit;
    OutputExe := Dlg.FileName;
    if LowerCase(ExtractFileExt(OutputExe)) <> '.exe' then
      OutputExe := ChangeFileExt(OutputExe, '.exe');
    SaveText := BuildChecksumSaveText(OutputExe);
    if SaveText = '' then
      Exit;
    try
      if BuildExeWithTextResource(DllFile, StubResourceName, OutputExe, ResHashType, ResHashName, SaveText,
           not StubValidated) then
      begin
        Application.MessageBox(
          PChar('Exported to Checkifier successfully!' + sLineBreak + sLineBreak +
                'Saved Path: ' + OutputExe),
          'Information', MB_OK or MB_ICONINFORMATION);
        // --- Saved file-ke Explorer-e selected obosthায় dekhano ---
        if FileExists(OutputExe) then
          ShellExecute(Handle, 'open', 'explorer.exe',
            PChar('/select,"' + OutputExe + '"'), nil, SW_SHOWNORMAL);
      end
      else
        MessageDlg('Export failed.' + sLineBreak + sLineBreak + GetLastErrorMessage,
          mtError, [mbOK], 0);
    except
      on E: Exception do
        MessageDlg('Export failed:' + sLineBreak + E.Message, mtError, [mbOK], 0);
    end;
  finally
    Dlg.Free;
  end;
end;

procedure THashGenFrm1.FixColumnWidtsToApp;
var
  AvailableWidth, SlNoFixedWidth, FileSizeFixedWidth, HashWidth: Integer;
begin
  if QCListView1.Columns.Count < 4 then Exit;
  SlNoFixedWidth := 70;
  FileSizeFixedWidth := 100;
  AvailableWidth := QCListView1.ClientWidth - (SlNoFixedWidth + FileSizeFixedWidth);
  if AvailableWidth < 0 then AvailableWidth := 0;
  HashWidth := AvailableWidth div 2;
  if HashWidth > 540 then HashWidth := 540;
  QCListView1.Columns[0].Width := SlNoFixedWidth;
  QCListView1.Columns[2].Width := FileSizeFixedWidth;
  QCListView1.Columns[3].Width := HashWidth;
  QCListView1.Columns[1].Width := AvailableWidth - HashWidth;
end;

procedure THashGenFrm1.Default(Sender: TObject);
begin

//  Clipboard.AsText:=CalculateUniversalResourceHash('THashGenFrm1', rt_rcdata);



  DragAcceptFiles(Handle, True);
  FullFilePaths := TStringList.Create;
  FRootPathDepth := 0;
  FLastSelectedIndex := -1;
  FCurrentRootFolder := '';
  Constraints.MinWidth := 580;
  Constraints.MinHeight := 207;
  Caption := MY_APP_NAME_GENIFY;
  GettingReadyQCListView;
  QCListView1.Items.Clear;


end;

procedure THashGenFrm1.SaveQGenify(Sender: TObject);
begin
  SavingQCLastChanges;
  DragAcceptFiles(Handle, False);
  FreeAndNil(FPendingDropFiles);
  FullFilePaths.Free;
end;

procedure THashGenFrm1.ReGenerateHash1Click(Sender: TObject);
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;
  ReGenerateHash;
end;

function THashGenFrm1.GetDefaultExtForHashType: string;
begin
  if Checkbox0CRC.Checked then Result := 'crc32'
  else if CheckBox1MD5.Checked then Result := 'md5'
  else if CheckBox2SHA1.Checked then Result := 'sha1'
  else if CheckBox3SHA256.Checked then Result := 'sha256'
  else if CheckBox4SHA384.Checked then Result := 'sha384'
  else if CheckBox5SHA512.Checked then Result := 'sha512'
  else Result := '';
end;

function THashGenFrm1.GetFormattedFileSize(const FilePath: string): string;
var
  FileSize: Int64;
begin
  FileSize := TFile.GetSize(FilePath);
  if FileSize < 1024 then
    Result := Format('%d B ', [FileSize])
  else if FileSize < 1024 * 1024 then
    Result := Format('%.2f KB ', [FileSize / 1024])
  else if FileSize < 1024 * 1024 * 1024 then
    Result := Format('%.2f MB ', [FileSize / (1024 * 1024)])
  else
    Result := Format('%.2f GB ', [FileSize / (1024 * 1024 * 1024)]);
end;

procedure THashGenFrm1.GettingReadyQCListView;
var
  HashTypeInt: Integer;
begin
  HashTypeInt := QCRegistryIntRead(MY_REG_PATH_GENIFY, HASH_FORMAT, 0);
  case HashTypeInt of
    0: Checkbox0CRC.Checked := True;
    1: CheckBox1MD5.Checked := True;
    2: CheckBox2SHA1.Checked := True;
    3: CheckBox3SHA256.Checked := True;
    4: CheckBox4SHA384.Checked := True;
    5: CheckBox5SHA512.Checked := True else
    CheckBox1MD5.Checked := True;
  end;
  QCListView1.OwnerDraw := False;
  QCListView1.ViewStyle := vsReport;
  QCListView1.MultiSelect := True;
  Self.Width := QCRegistryIntRead(MY_REG_PATH_GENIFY, QG_WIDTH, Width);
  Self.Height := QCRegistryIntRead(MY_REG_PATH_GENIFY, QG_HEIGHT, Height);
  with QCListView1.Columns.Add do
  begin
    Caption := 'Serial No.';
    MinWidth := 70;
    MaxWidth := 70;
    Width := 70;
  end;
  with QCListView1.Columns.Add do
  begin
    Caption := 'File Names';
    MinWidth := 150;
    Width := 250;
  end;
  with QCListView1.Columns.Add do
  begin
    Caption := 'File Size ';
    MinWidth := 100;
    MaxWidth := 100;
    Width := 100;
    Alignment := taRightJustify;
  end;
  with QCListView1.Columns.Add do
  begin
    if Checkbox0CRC.Checked then Caption := 'Hash - CRC32'
    else if CheckBox1MD5.Checked then Caption := 'Hash - MD5'
    else if CheckBox2SHA1.Checked then Caption := 'Hash - SHA1'
    else if CheckBox3SHA256.Checked then Caption := 'Hash - SHA256'
    else if CheckBox4SHA384.Checked then Caption := 'Hash - SHA384'
    else if CheckBox5SHA512.Checked then Caption := 'Hash - SHA512';
    MinWidth := 180;
    Width := 350;
  end;
end;

procedure THashGenFrm1.MakeListsItemsQueue;
var
  i: Integer;
  item: TListItem;
begin
  FileQueue.Clear;
  for i := 0 to QCListView1.Items.Count - 1 do
  begin
    item := QCListView1.Items[i];
    FileQueue.Add(FullFilePaths[i]);
    item.SubItems[2] := QueueItemsStatusCaption;
  end;
end;

procedure THashGenFrm1.FormResize(Sender: TObject);
begin
  FixColumnWidtsToApp;
end;

procedure THashGenFrm1.ChoosingHashType(Sender: TObject);
begin
  // Hash type পরিবর্তন → সব hash clear
  if Sender = Checkbox0CRC then
  begin
    SavePathFileName := '';
    Checkbox0CRC.Checked := True;

    CheckBox1MD5.Checked := False;
    CheckBox2SHA1.Checked := False;
    CheckBox3SHA256.Checked := False;
    CheckBox4SHA384.Checked := False;
    CheckBox5SHA512.Checked := False;
    QCListView1.Columns[3].Caption := 'Hash - CRC32';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end
  else if Sender = CheckBox1MD5 then
  begin
    SavePathFileName := '';
    CheckBox1MD5.Checked := True;

    Checkbox0CRC.Checked := False;
    CheckBox2SHA1.Checked := False;
    CheckBox3SHA256.Checked := False;
    CheckBox4SHA384.Checked := False;
    CheckBox5SHA512.Checked := False;
    QCListView1.Columns[3].Caption := 'Hash - MD5';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end
  else if Sender = CheckBox2SHA1 then
  begin
    SavePathFileName := '';
    Checkbox0CRC.Checked := False;
    CheckBox1MD5.Checked := False;
    CheckBox2SHA1.Checked := True;

    CheckBox3SHA256.Checked := False;
    CheckBox4SHA384.Checked := False;
    CheckBox5SHA512.Checked := False;
    QCListView1.Columns[3].Caption := 'Hash - SHA1';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end
  else if Sender = CheckBox3SHA256 then
  begin
    SavePathFileName := '';
    Checkbox0CRC.Checked := False;
    CheckBox1MD5.Checked := False;
    CheckBox2SHA1.Checked := False;
    CheckBox3SHA256.Checked := True;
    CheckBox4SHA384.Checked := False;
    CheckBox5SHA512.Checked := False;
    QCListView1.Columns[3].Caption := 'Hash - SHA256';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end
  else if Sender = CheckBox4SHA384 then
  begin
    SavePathFileName := '';
    Checkbox0CRC.Checked := False;
    CheckBox1MD5.Checked := False;
    CheckBox2SHA1.Checked := False;
    CheckBox3SHA256.Checked := False;
    CheckBox4SHA384.Checked := True;
    CheckBox5SHA512.Checked := False;
    QCListView1.Columns[3].Caption := 'Hash - SHA384';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end
  else if Sender = CheckBox5SHA512 then
  begin
    SavePathFileName := '';
    Checkbox0CRC.Checked := False;
    CheckBox1MD5.Checked := False;
    CheckBox2SHA1.Checked := False;
    CheckBox3SHA256.Checked := False;
    CheckBox4SHA384.Checked := False;
    CheckBox5SHA512.Checked := True;
    QCListView1.Columns[3].Caption := 'Hash - SHA512';
    Caption := MY_APP_NAME_GENIFY;
    if QCListView1.Items.Count > 0 then
      MakeListsItemsQueue;
  end;
end;


procedure THashGenFrm1.ClearAllHashClick(Sender: TObject);
var
  i: Integer;
  item: TListItem;
begin
  if QCListView1.Items.Count = 0 then Exit;
  FileQueue.Clear;
  for i := 0 to QCListView1.Items.Count - 1 do
  begin
    item := QCListView1.Items[i];
    FileQueue.Add(FullFilePaths[i]);
    item.SubItems[2] := QueueItemsStatusCaption;
  end;
end;

procedure THashGenFrm1.GenerateHash1Click(Sender: TObject);
var
  StartIdx: Integer;
begin
  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;

  StartIdx := FindFirstPendingIndex;

  if StartIdx < 0 then
  begin
    // সব hash আগে থেকেই generate করা আছে -> কোনো messagebox ছাড়াই শুরু থেকে regenerate করো
    ReGenerateHash;
    Exit;
  end;

  // FileQueue ঠিক করে নেই
  FileQueue.Clear;
  for var i := 0 to QCListView1.Items.Count - 1 do
    FileQueue.Add(FullFilePaths[i]);

  CurrentIndex := StartIdx;
  PrepareProgressTotals(StartIdx);
  DisableEverything;
  StartNextFile;
end;


procedure THashGenFrm1.CopyFileName1Click(Sender: TObject);
begin
  if Assigned(QCListView1.Selected) then
    Clipboard.AsText := QCListView1.Selected.SubItems[0];
end;

procedure THashGenFrm1.CopyGeneratedHash;
var
  Item: TListItem;
begin
  Item := QCListView1.Selected;
  if not Assigned(Item) then Exit;
  if (Item.SubItems[2] = QueueItemsStatusCaption) or
     (Item.SubItems[2] = GeneratingHashStatusCaption) or
     (Item.SubItems[2] = AbortedStatusCaption) then
  begin
    MessageDlg(GenerateHashBeforeCopyFirstMessage, mtWarning, [mbOK], 0);
    Exit;
  end;
  Clipboard.AsText := Item.SubItems[2];
end;

procedure THashGenFrm1.CopyHash1Click(Sender: TObject);
begin
  CopyGeneratedHash;
end;

procedure THashGenFrm1.CopyHash2Click(Sender: TObject);
begin
  CopyGeneratedHash;
end;

procedure THashGenFrm1.CopyHashwithFilename1Click(Sender: TObject);
var
  Item: TListItem;
begin
  Item := QCListView1.Selected;
  if not Assigned(Item) then Exit;
  if (Item.SubItems[2] = QueueItemsStatusCaption) or
     (Item.SubItems[2] = GeneratingHashStatusCaption) or
     (Item.SubItems[2] = AbortedStatusCaption) then
  begin
    MessageDlg(GenerateHashBeforeCopyFirstMessage, mtWarning, [mbOK], 0);
    Exit;
  end;
  Clipboard.AsText := Item.SubItems[2] + ' *' + Item.SubItems[0];
end;

procedure THashGenFrm1.RemoveAllClick(Sender: TObject);
begin
  DeleteTListViewItems;
end;

procedure THashGenFrm1.RemoveSelected1Click(Sender: TObject);
begin
  DeleteSelectedItems;
end;

function THashGenFrm1.ShouldMergeWithExisting(const CandidateRoot: string): Boolean;
begin
  Result := (QCListView1.Items.Count > 0) and
            Assigned(FullFilePaths) and (FullFilePaths.Count > 0) and
            (FCurrentRootFolder <> '') and (CandidateRoot <> '') and
            SameText(ExcludeTrailingPathDelimiter(CandidateRoot),
                     ExcludeTrailingPathDelimiter(FCurrentRootFolder));
end;

function THashGenFrm1.IsDuplicatePath(const FullPath: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  if not Assigned(FullFilePaths) then Exit;
  for i := 0 to FullFilePaths.Count - 1 do
    if SameText(FullFilePaths[i], FullPath) then
    begin
      Result := True;
      Exit;
    end;
end;

function THashGenFrm1.IsFileAlreadyHashed(FileIndex: Integer): Boolean;
var
  Status: string;
begin
  Result := False;
  if (FileIndex < 0) or (FileIndex >= QCListView1.Items.Count) then Exit;

  Status := QCListView1.Items[FileIndex].SubItems[2];

  Result := (Status <> QueueItemsStatusCaption) and
            (Status <> GeneratingHashStatusCaption) and
            (Status <> AbortedStatusCaption);
end;



function THashGenFrm1.BuildChecksumSaveText(const ForFileName: string): string;
var
  ContentLines, FinalLines: TStringList;
  item: TListItem;
  i: Integer;
begin
  Result := '';

  if QCListView1.Items.Count = 0 then
  begin
    MessageDlg(NoFilesFoundInListMessage, mtWarning, [mbOK], 0);
    Exit;
  end;

  for i := 0 to QCListView1.Items.Count - 1 do
    if (QCListView1.Items[i].SubItems[2] = QueueItemsStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = GeneratingHashStatusCaption) or
       (QCListView1.Items[i].SubItems[2] = AbortedStatusCaption) then
    begin
      MessageDlg(GenerateHashFirstMessage, mtWarning, [mbOK], 0);
      Exit;
    end;

  ContentLines := TStringList.Create;
  try
    for i := 0 to QCListView1.Items.Count - 1 do
    begin
      item := QCListView1.Items[i];
      if IsInvalidHashStatus(item.SubItems[2]) then
        Continue;
      ContentLines.Add(Format(SaveHashFormat, [item.SubItems[2], GetPathWithDepth(item.SubItems[0])]));
    end;

    if ContentLines.Count = 0 then
    begin
      MessageDlg('No valid hashes to save.', mtWarning, [mbOK], 0);
      Exit;
    end;

    FinalLines := TStringList.Create;
    try
      AddExportHeader(FinalLines, ForFileName, True);
       FinalLines.AddStrings(ContentLines);
       Result := FinalLines.Text;
    finally
       FinalLines.Free;
    end;
  finally
    ContentLines.Free;
  end;
end;


function THashGenFrm1.BuildRelativePath(const RootFolder, FullPath: string): string;
begin
  if RootFolder = '' then
    Result := FullPath
  else
    Result := StringReplace(FullPath, IncludeTrailingPathDelimiter(RootFolder), '', [rfIgnoreCase]);
end;

procedure THashGenFrm1.RenumberListCaptions;
var
  i: Integer;
begin
  for i := 0 to QCListView1.Items.Count - 1 do
    QCListView1.Items[i].Caption := (i + 1).ToString;
end;

procedure THashGenFrm1.SetRootPathDepth1Click(Sender: TObject);
var
  InputStr: string;
  Depth: Integer;
begin
  // বর্তমান মান থাকলে সেটা দেখাও
  if FRootPathDepth > 0 then
    InputStr := IntToStr(FRootPathDepth)
  else
    InputStr := '0';

  // Custom Numeric InputBox
  InputStr := NumericInputBox('Set Root Path Depth', 'Enter the number of parent folders to move back (1–15):',InputStr, Self);

  // Cancel চাপলে বা খালি রাখলে
  if (InputStr = '') or (InputStr='0') then
  begin
    FRootPathDepth := 0;
    SetRootPathDepth1.Checked := False;
    SetRootPathDepth1.Caption := 'Set Root Path Depth';
    Exit;
  end;

  // সংখ্যায় কনভার্ট
 if (not TryStrToInt(InputStr, Depth)) or (Depth < 1) or (Depth > 15) then
  begin
    MessageDlg('Invalid number.', mtWarning, [mbOK], 0);
    Exit;
  end;

  // সফল
  FRootPathDepth := Depth;
  SetRootPathDepth1.Checked := True;
  SetRootPathDepth1.Caption := 'Set Root Path Depth - ' + IntToStr(Depth);
end;

procedure THashGenFrm1.DeleteSelectedItems;
var
  newIndex, i: Integer;
begin
  if QCListView1.Items.Count = 0 then Exit;
  for i := QCListView1.Items.Count - 1 downto 0 do
  begin
    if QCListView1.Items[i].Selected then
    begin
      QCListView1.Items[i].Delete;
      if i < FullFilePaths.Count then
        FullFilePaths.Delete(i);
      SaveHash.Enabled := True;
      ExporttoCheckifier1.Enabled := True;   // <-- নতুন
    end;
  end;
  for newIndex := 0 to QCListView1.Items.Count - 1 do
    QCListView1.Items[newIndex].Caption := (newIndex + 1).ToString;
  if QCListView1.Items.Count = 0 then
  begin
    Caption := MY_APP_NAME_GENIFY;
    FCurrentRootFolder := '';
    SavePathFileName := '';
  end;
end;

procedure THashGenFrm1.DeleteTListViewItems;
begin
  SavePathFileName := '';
  FCurrentRootFolder := '';
  if QCListView1.Items.Count = 0 then Exit;
  QCListView1.Clear;
  FullFilePaths.Clear;
  SaveHash.Enabled := False;
  ExporttoCheckifier1.Enabled := False;
  SaveAs1.Enabled := False;
  SaveHashEachFile1.Enabled := False;
  Caption := MY_APP_NAME_GENIFY;
end;

procedure THashGenFrm1.DisableEverything;
begin
  OpenBatchAlgHandle;
  FLastSelectedIndex := -1;

  ProgressBar1.Position := 0;
  ProgressBar1.Max := 10000;
  TaskbarControll.ProgressMaxValue := 100;
  TaskbarControll.ProgressValue := 0;
  QCLabelParcent.Caption := '0.00%';
  GroupBox1.Visible := True;
  StopHashGeneration1.Enabled := True;
  ChooseFiles.Enabled := False;
  SelectAll1.Enabled := False;
  ChooseFolder1.Enabled := False;
  ExporttoCheckifier1.Enabled := False;
  SaveHash.Enabled := False;
  SaveAs1.Enabled := False;
  SaveHashEachFile1.Enabled := False;
  ReGenerateHash1.Enabled := False;
  GenerateHash1.Enabled := False;
  ClearAllHash.Enabled := False;
  RemoveAll.Enabled := False;
  RemoveSelected1.Enabled := False;
  Checkbox0CRC.Enabled := False;
  CheckBox1MD5.Enabled := False;
  CheckBox2SHA1.Enabled := False;
  CheckBox3SHA256.Enabled := False;
  CheckBox4SHA384.Enabled := False;
  CheckBox5SHA512.Enabled := False;
  SetRootPathDepth1.Enabled := False;
end;

procedure THashGenFrm1.EnableEverything;
begin
  CloseBatchAlgHandle;

  TaskbarControll.ProgressValue := 0;
  StopHashGeneration1.Enabled := False;
  GroupBox1.Visible := False;
  RemoveAll.Enabled := True;
  RemoveSelected1.Enabled := True;
  ChooseFiles.Enabled := True;
  SelectAll1.Enabled := True;
  ChooseFolder1.Enabled := True;
  ExporttoCheckifier1.Enabled := True;
  SaveHash.Enabled := True;
  SaveAs1.Enabled := True;
  SaveHashEachFile1.Enabled := True;
  ReGenerateHash1.Enabled := True;
  GenerateHash1.Enabled := True;
  ClearAllHash.Enabled := True;
  Checkbox0CRC.Enabled := True;
  CheckBox1MD5.Enabled := True;
  CheckBox2SHA1.Enabled := True;
  CheckBox3SHA256.Enabled := True;
  CheckBox4SHA384.Enabled := True;
  CheckBox5SHA512.Enabled := True;
  SetRootPathDepth1.Enabled := True;
end;

procedure THashGenFrm1.SavingQCLastChanges;
begin
  if Self.WindowState <> wsMaximized then
  begin
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, QG_HEIGHT, Self.Height);
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, QG_WIDTH, Self.Width);
  end;
  if Checkbox0CRC.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 0)
  else if CheckBox1MD5.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 1)
  else if CheckBox2SHA1.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 2)
  else if CheckBox3SHA256.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 3)
  else if CheckBox4SHA384.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 4)
  else if CheckBox5SHA512.Checked then
    QCWriteRegistryInt(MY_REG_PATH_GENIFY, HASH_FORMAT, 5);

end;

procedure THashGenFrm1.SelectAll1Click(Sender: TObject);
var
  i: Integer;
begin
  if not QCListView1.MultiSelect then
    QCListView1.MultiSelect := True;
  for i := 0 to QCListView1.Items.Count - 1 do
    QCListView1.Items[i].Selected := True;
  if QCListView1.Items.Count > 0 then
    QCListView1.Items[0].MakeVisible(False);
end;

procedure THashGenFrm1.SelectListItem(FileIndex: Integer);
begin
  if (FileIndex < 0) or (FileIndex >= QCListView1.Items.Count) then Exit;

  QCListView1.Items.BeginUpdate;
  try
    if (FLastSelectedIndex >= 0) and (FLastSelectedIndex < QCListView1.Items.Count)
       and (FLastSelectedIndex <> FileIndex) then
      QCListView1.Items[FLastSelectedIndex].Selected := False;

    QCListView1.ItemFocused := QCListView1.Items[FileIndex];
    QCListView1.Items[FileIndex].Selected := True;
  finally
    QCListView1.Items.EndUpdate;
  end;
  QCListView1.Items[FileIndex].MakeVisible(False);
  QCListView1.Update;
  FLastSelectedIndex := FileIndex;
end;

procedure THashGenFrm1.OnAllDone;
begin
  FCurrentWorker := nil;
  EnableEverything;
  QCListView1.MultiSelect := True;
  MessageBeep(MB_ICONINFORMATION);
end;

procedure THashGenFrm1.OnFileSkip(FileIndex: Integer);
begin
  if not Assigned(FCurrentWorker) then Exit;
  CurrentIndex := FileIndex;
  SelectListItem(FileIndex);
end;

procedure THashGenFrm1.OnFileStart(FileIndex: Integer);
begin
  if not Assigned(FCurrentWorker) then Exit;
  CurrentIndex := FileIndex;
  SelectListItem(FileIndex);
  ProgressBar2.Position := 0;
  ProgressBar2.Max := 100;
  CurrenntFileProg1.Caption := '0%';
  SavedHashFile := False;
end;

procedure THashGenFrm1.OnFileDone(FileIndex: Integer; HashValue: string);
var
  item: TListItem;
  FileSize: Int64;
  OverallPerc: Double;
begin
  if not Assigned(FCurrentWorker) then Exit;
  item := QCListView1.Items[FileIndex];
  item.SubItems[2] := HashValue;
  QCListView1.Invalidate;

  if FileExists(FileQueue[FileIndex]) then
    FileSize := TFile.GetSize(FileQueue[FileIndex])
  else
    FileSize := 0;

  Inc(FProcessedWork, FileSize + OverheadPerFile);
  OverallPerc := (FProcessedWork / FTotalWork) * 100.0;

  ProgressBar1.Position := Round(OverallPerc * 100);
  TaskbarControll.ProgressValue := Round(OverallPerc);
  QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
  QCLabelParcent.Update;

end;

procedure THashGenFrm1.OnFileProgress(FileIndex: Integer; BytesDone, BytesTotal: Int64);
var
  OverallWork: Int64;
  OverallPerc: Double;
  QCItemLst: TListItem;
begin
  if not Assigned(FCurrentWorker) then Exit;
  QCItemLst := QCListView1.Items[FileIndex];
  if BytesTotal > 0 then
  begin
    ProgressBar2.Position := Round((BytesDone / BytesTotal) * 100);
    CurrenntFileProg1.Caption := IntToStr(ProgressBar2.Position) + '%';

    OverallWork := FProcessedWork + BytesDone;
    OverallPerc := (OverallWork / FTotalWork) * 100.0;

    ProgressBar1.Position := Round(OverallPerc * 100);
    TaskbarControll.ProgressValue := Round(OverallPerc);
    QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);

    QCItemLst.SubItems[2] := GeneratingHashStatusCaption;
  end;
end;

procedure THashGenFrm1.PopulateFileList(const CandidateRoot: string; NewFullPaths: TStringList);
var
  i: Integer;
  ListItem: TListItem;
  Merge: Boolean;
  RelPath: string;
  AddedAny: Boolean;
begin
  if (not Assigned(NewFullPaths)) or (NewFullPaths.Count = 0) or (CandidateRoot = '') then
    Exit;

  Merge := ShouldMergeWithExisting(CandidateRoot);

  if not Merge then
  begin
    if FileExists(Caption) then
      Caption := MY_APP_NAME_GENIFY;
    QCListView1.Clear;
    FreeAndNil(FileQueue);
    FileQueue := TStringList.Create;
    FreeAndNil(FullFilePaths);
    FullFilePaths := TStringList.Create;
    FCurrentRootFolder := CandidateRoot;
    SavePathFileName := CandidateRoot;
  end;

  AddedAny := False;
  for i := 0 to NewFullPaths.Count - 1 do
  begin
    if IsDuplicatePath(NewFullPaths[i]) then
      Continue;

    RelPath := BuildRelativePath(FCurrentRootFolder, NewFullPaths[i]);

    FileQueue.Add(NewFullPaths[i]);
    FullFilePaths.Add(NewFullPaths[i]);

    ListItem := QCListView1.Items.Add;
    ListItem.Caption := QCListView1.Items.Count.ToString;
    ListItem.SubItems.Add(RelPath);
    ListItem.SubItems.Add(GetFormattedFileSize(NewFullPaths[i]));
    ListItem.SubItems.Add(QueueItemsStatusCaption);
    AddedAny := True;
  end;

  if not AddedAny then
    Exit;

  RenumberListCaptions;
  FixColumnWidtsToApp;

  if not Merge then
  begin
    PrepareProgressTotals(0);
    DisableEverything;
    CurrentIndex := 0;
    StartNextFile;
  end;
end;

procedure THashGenFrm1.PopupMenu1Popup(Sender: TObject);
var
  TargetItem: TListItem;
  FilePath, HashStatus: string;
begin
  Refresh1.Enabled := True;
  Cancel1.Enabled := True;
  TargetItem := QCListView1.Selected;
  if not Assigned(TargetItem) then
  begin
    ShowInExplorerMenu.Enabled := False;
    CopyHash1.Enabled := False;
    CopyHashwithFilename1.Enabled := False;
    Exit;
  end;

  FilePath := FullFilePaths[TargetItem.Index];
  ShowInExplorerMenu.Enabled := FileExists(FilePath);

  HashStatus := TargetItem.SubItems[2];

  if (HashStatus = QueueItemsStatusCaption) or
     (HashStatus = GeneratingHashStatusCaption) or
     (HashStatus = AbortedStatusCaption) or
     IsInvalidHashStatus(HashStatus) then
  begin
    CopyHash1.Enabled := False;
    CopyHashwithFilename1.Enabled := False;
  end
  else
  begin
    CopyHash1.Enabled := True;
    CopyHashwithFilename1.Enabled := True;
  end;
end;

procedure THashGenFrm1.PrepareProgressTotals(StartIndex: Integer);
var
  i: Integer;
  FileSize: Int64;
  PendingCount: Integer;
begin
  FTotalBytes := 0;
  FProcessedWork := 0;
  PendingCount := 0;

  for i := StartIndex to FileQueue.Count - 1 do
  begin
    if IsFileAlreadyHashed(i) then
      Continue;
    if FileExists(FileQueue[i]) then
      FileSize := TFile.GetSize(FileQueue[i])
    else
      FileSize := 0;
    Inc(FTotalBytes, FileSize);
    Inc(PendingCount);
  end;

  FTotalWork := FTotalBytes + (Int64(PendingCount) * OverheadPerFile);
  if FTotalWork <= 0 then
    FTotalWork := 1;
end;

procedure THashGenFrm1.ProcessFiles(const Files: TStringList);
var
  i: Integer;
  CandidateRoot: string;
  ParentDirs, NewFullPaths: TStringList;

  procedure AddFilesFromFolder(const CurrentFolder: string; TargetList: TStringList);
  var
    FilesInFolder, SubDirs: TStringDynArray;
    k: Integer;
  begin
    FilesInFolder := TDirectory.GetFiles(CurrentFolder);
    for k := 0 to Length(FilesInFolder) - 1 do
      TargetList.Add(FilesInFolder[k]);
    SubDirs := TDirectory.GetDirectories(CurrentFolder);
    for k := 0 to Length(SubDirs) - 1 do
      AddFilesFromFolder(SubDirs[k], TargetList);
  end;

begin
  if Files.Count = 0 then Exit;

  ParentDirs := TStringList.Create;
  NewFullPaths := TStringList.Create;
  try
    for i := 0 to Files.Count - 1 do
    begin
      if DirectoryExists(Files[i]) then
      begin
        // dragged folder এর "root candidate" হলো তার নিজের parent folder,
        // তাই list এ ফোল্ডারের নাম prefix হয়ে থেকে যায় (Documents\Report.txt)
        ParentDirs.Add(ExtractFileDir(ExcludeTrailingPathDelimiter(Files[i])));
        AddFilesFromFolder(Files[i], NewFullPaths);
      end
      else if FileExists(Files[i]) then
      begin
        ParentDirs.Add(ExtractFileDir(Files[i]));
        NewFullPaths.Add(Files[i]);
      end;
    end;

    if NewFullPaths.Count = 0 then Exit;

    CandidateRoot := CommonAncestorPath(ParentDirs);
    if CandidateRoot = '' then Exit;   // ভিন্ন ড্রাইভ ইত্যাদি কারণে common root বের করা গেল না

    PopulateFileList(CandidateRoot, NewFullPaths);
  finally
    ParentDirs.Free;
    NewFullPaths.Free;
  end;
end;

procedure THashGenFrm1.RefreshList;
var
  Rows: TList<TQGListRow>;
  i: Integer;
  Item: TListItem;
  Row: TQGListRow;
begin
  if Assigned(FCurrentWorker) then Exit;
  if (not Assigned(FullFilePaths)) or (QCListView1.Items.Count = 0) then Exit;

  Rows := TList<TQGListRow>.Create;
  try
    for i := 0 to QCListView1.Items.Count - 1 do
    begin
      Item := QCListView1.Items[i];
      Row.FullPath := FullFilePaths[i];
      Row.RelPath := Item.SubItems[0];
      Row.SizeStr := Item.SubItems[1];
      Row.StatusStr := Item.SubItems[2];
      Rows.Add(Row);
    end;

    // Windows Explorer এর মতোই "natural/logical" sort (File2 < File10)
    Rows.Sort(TComparer<TQGListRow>.Construct(
      function(const L, R: TQGListRow): Integer
      begin
        Result := StrCmpLogicalW(PWideChar(L.RelPath), PWideChar(R.RelPath));
      end));

    QCListView1.Items.BeginUpdate;
    try
      QCListView1.Clear;
      FileQueue.Clear;
      FullFilePaths.Clear;

      for i := 0 to Rows.Count - 1 do
      begin
        FileQueue.Add(Rows[i].FullPath);
        FullFilePaths.Add(Rows[i].FullPath);

        Item := QCListView1.Items.Add;
        Item.Caption := (i + 1).ToString;
        Item.SubItems.Add(Rows[i].RelPath);
        Item.SubItems.Add(Rows[i].SizeStr);
        Item.SubItems.Add(Rows[i].StatusStr);
      end;
    finally
      QCListView1.Items.EndUpdate;
    end;
  finally
    Rows.Free;
  end;
end;

procedure THashGenFrm1.RefreshList1Click(Sender: TObject);
begin
RefreshList;
end;

procedure THashGenFrm1.ReGenerateHash;
var
  i: Integer;
  item: TListItem;
begin
  FileQueue.Clear;
  for i := 0 to QCListView1.Items.Count - 1 do
  begin
    item := QCListView1.Items[i];
    FileQueue.Add(FullFilePaths[i]);
    item.SubItems[2] := QueueItemsStatusCaption;
  end;
  CurrentIndex := 0;
  PrepareProgressTotals(0);
  DisableEverything;
  StartNextFile;
end;

procedure THashGenFrm1.StartNextFile;
begin
  if CurrentIndex >= FileQueue.Count then
  begin
    OnAllDone;
    Exit;
  end;

  FCurrentWorker := THashWorker.Create(FileQueue, CurrentIndex,
    OnFileStart, OnFileProgress, OnFileDone, OnAllDone,
    IsFileAlreadyHashed, OnFileSkip);

  FCurrentWorker.OnTerminate := WorkerTerminatedHandler;
  FCurrentWorker.Start;
end;

{ THashWorker }

constructor THashWorker.Create(AFileList: TStrings; AStartIndex: Integer;
  OnFileStart: TFileStartEvent; OnProgress: TFileProgressEvent;
  OnDone: TFileDoneEvent; OnBatchDone: TBatchDoneEvent;
  OnShouldSkip: TFileSkipCheckEvent; OnFileSkip: TFileStartEvent);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  FFileList := AFileList;
  FStartIndex := AStartIndex;
  FOnFileStart := OnFileStart;
  FOnProgress := OnProgress;
  FOnDone := OnDone;
  FOnBatchDone := OnBatchDone;
  FOnShouldSkip := OnShouldSkip;
  FOnFileSkip := OnFileSkip;
end;

procedure THashWorker.NotifyFileSkip;
begin
  if Assigned(FOnFileSkip) then
    FOnFileSkip(FFileIndex);
end;

procedure THashWorker.NotifyFileStart;
begin
  if Assigned(FOnFileStart) then
    FOnFileStart(FFileIndex);
end;

procedure THashWorker.NotifyBatchDone;
begin
  if Assigned(FOnBatchDone) then
    FOnBatchDone;
end;

procedure THashWorker.Execute;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  i: Integer;
  SkipThis: Boolean;
begin
  SetLength(FBuffer, MaxBufferSize);

  for i := FStartIndex to FFileList.Count - 1 do
  begin
    if Terminated then Exit;
    FFileIndex := i;

    SkipThis := False;
    if Assigned(FOnShouldSkip) then
    begin
      Synchronize(
        procedure
        begin
          SkipThis := FOnShouldSkip(FFileIndex);
        end);
    end;

    if SkipThis then
    begin
      if Assigned(FOnFileSkip) then
        Synchronize(NotifyFileSkip);
      if Terminated then Exit;
      Sleep(SkipVisualDelayMs);
      if Terminated then Exit;
      Continue;
    end;

    if Terminated then Exit;
    Synchronize(NotifyFileStart);
    if Terminated then Exit;
    HashSingleFile(FFileList[i]);
    if Terminated then Exit;
  end;

  if not Terminated then
    Synchronize(NotifyBatchDone);
end;

procedure THashWorker.HashSingleFile(const AFileName: string);
var
  Stream: THandleStream;
  BytesRead, TotalRead, FileSize: Int64;
  ActualBufSize: Integer;
  HashValue: string;
  CRCValue: Cardinal;
  LastUIUpdate, NowTick: Cardinal;
  UseFallback: Boolean;
  FallbackMD5: THashMD5;
  FallbackSHA1: THashSHA1;
  FallbackSHA256: THashSHA2;
  IsCRC, IsMD5, IsSHA1, IsSHA256, IsSHA384, IsSHA512: Boolean;
  hHash: Pointer;
  HashObjBuf: TBytes;
  ObjLen, cbResult: ULONG;
  Digest: TBytes;
  i: Integer;
begin
  HashValue := '';
  TotalRead := 0;
  LastUIUpdate := 0;
  CRCValue := 0;
  UseFallback := False;
  hHash := nil;

  IsCRC    := HashGenFrm1.Checkbox0CRC.Checked;
  IsMD5    := HashGenFrm1.CheckBox1MD5.Checked;
  IsSHA1   := HashGenFrm1.CheckBox2SHA1.Checked;
  IsSHA256 := HashGenFrm1.CheckBox3SHA256.Checked;
  IsSHA384 := HashGenFrm1.CheckBox4SHA384.Checked;
  IsSHA512 := HashGenFrm1.CheckBox5SHA512.Checked;

  try
    if not FileExists(AFileName) then
    begin
      Synchronize(
        procedure
        begin
          Finish(FileISMissingDescStr);
        end);
      Exit;
    end;

    Stream := QCOpenSequentialFileStream(AFileName);
    try
      FileSize := Stream.Size;

      // ছোট ফাইলে reusable buffer এর একটা অংশই ব্যবহার হয়
      if (FileSize > 0) and (FileSize < Length(FBuffer)) then
        ActualBufSize := FileSize
      else
        ActualBufSize := Length(FBuffer);
      if ActualBufSize <= 0 then
        ActualBufSize := 1;

      if IsCRC then
        CRCValue := $FFFFFFFF
      else if IsMD5 or IsSHA1 or IsSHA256 or IsSHA384 or IsSHA512 then
      begin
        if Assigned(GBatchAlgHandle) then
        begin
          // batch শুরুতে খোলা handle থেকে শুধু hash object বানানো হচ্ছে — সস্তা, দ্রুত
          ObjLen := 0;
          cbResult := 0;
          BCryptGetProperty(GBatchAlgHandle, BCRYPT_OBJECT_LENGTH, PByte(@ObjLen), SizeOf(ObjLen), cbResult, 0);
          if ObjLen > 0 then
          begin
            SetLength(HashObjBuf, ObjLen);
            if BCryptCreateHash(GBatchAlgHandle, hHash, @HashObjBuf[0], ObjLen, nil, 0, 0) <> STATUS_SUCCESS then
              hHash := nil;
          end;
        end;

        UseFallback := not Assigned(hHash);
        if UseFallback then
        begin
          if IsMD5 then FallbackMD5 := THashMD5.Create
          else if IsSHA1 then FallbackSHA1 := THashSHA1.Create
          else if IsSHA256 then FallbackSHA256 := THashSHA2.Create;
        end;
      end
      else
      begin
        Synchronize(procedure begin Finish('INVALID_HASH_TYPE'); end);
        Exit;
      end;

      while True do
      begin
        if Terminated then Exit;

        BytesRead := Stream.Read(FBuffer[0], ActualBufSize);
        if BytesRead = 0 then Break;

        if IsCRC then
          CRCValue := UpdateCRC32(CRCValue, FBuffer[0], BytesRead)
        else if Assigned(hHash) then
          BCryptHashData(hHash, PByte(@FBuffer[0]), BytesRead, 0)
        else if UseFallback then
        begin
          if IsMD5 then FallbackMD5.Update(FBuffer, BytesRead)
          else if IsSHA1 then FallbackSHA1.Update(FBuffer, BytesRead)
          else if IsSHA256 then FallbackSHA256.Update(FBuffer, BytesRead);
        end;

        Inc(TotalRead, BytesRead);

        NowTick := GetTickCount;
        if (NowTick - LastUIUpdate >= 80) or (TotalRead >= FileSize) then
        begin
          LastUIUpdate := NowTick;
          Synchronize(
            procedure
            begin
              UpdateProgress(TotalRead, FileSize);
            end);
        end;
      end;

      if not Terminated then
      begin
        if IsCRC then
          HashValue := IntToHex(CRCValue xor $FFFFFFFF, 8).ToUpper
        else if Assigned(hHash) then
        begin
          SetLength(Digest, GBatchDigestLen);
          if BCryptFinishHash(hHash, @Digest[0], GBatchDigestLen, 0) = STATUS_SUCCESS then
          begin
            SetLength(HashValue, GBatchDigestLen * 2);
            for i := 0 to High(Digest) do
              Move(PChar(IntToHex(Digest[i], 2))^, HashValue[1 + i * 2], 2 * SizeOf(Char));
            HashValue := HashValue.ToUpper;
          end;
        end
        else if UseFallback then
        begin
          if IsMD5 then HashValue := FallbackMD5.HashAsString.ToUpper
          else if IsSHA1 then HashValue := FallbackSHA1.HashAsString.ToUpper
          else if IsSHA256 then HashValue := FallbackSHA256.HashAsString.ToUpper;
        end;

        if HashValue = '' then
          HashValue := 'UNSUPPORTED ON THIS SYSTEM';

        Synchronize(
          procedure
          begin
            Finish(HashValue);
          end);
      end;

    finally
      if Assigned(hHash) then
        BCryptDestroyHash(hHash);
      CloseHandle(Stream.Handle);
      Stream.Free;
    end;

  except
    on E: Exception do
    begin
      Synchronize(
        procedure
        begin
          Finish('ERROR: ' + E.Message.ToUpper);
        end);
    end;
  end;
end;

procedure THashWorker.Finish(HashValue: string);
begin
  if Assigned(FOnDone) then
    FOnDone(FFileIndex, HashValue);
end;

procedure THashWorker.UpdateProgress(BytesDone, BytesTotal: Int64);
begin
  if (BytesTotal > 0) and Assigned(FOnProgress) then
    FOnProgress(FFileIndex, BytesDone, BytesTotal);
end;

end.
