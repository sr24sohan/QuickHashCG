unit QCUnit1;

interface

uses
  Windows, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ComCtrls, UITypes,
  StdCtrls, StrUtils, IOUtils, Threading, ShellAPI, Registry, Clipbrd, Hash, uStrings,
  Messages, DateUtils, ImageList, ImgList, Menus, Vcl.Taskbar,   uResourceProtector,
  System.Win.TaskbarCore, CRCArraysTable, IdHashSHA, System.Generics.Collections,
  CommCtrl, Vcl.VirtualImage, Vcl.VirtualImageList, Vcl.BaseImageCollection,
  Winapi.UxTheme, Vcl.ImageCollection, uQCEngine;


type
  TQCFileRecord = uQCEngine.TQCFileRecord;

  THashChecksum = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    QCListView1: TListView;
    ProgressBar1: TProgressBar;
    QCLabelParcent: TLabel;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    Browsethefile1: TMenuItem;
    Cancel1: TMenuItem;
    N3: TMenuItem;
    CopyFIleName1: TMenuItem;
    N4: TMenuItem;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    LoadChecksum1: TMenuItem;
    CloseCurrent1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Options1: TMenuItem;
    About1: TMenuItem;
    Label2: TLabel;
    CurrentFileProgress: TLabel;
    ProgressBar2: TProgressBar;
    ask1: TMenuItem;
    StopTasks1: TMenuItem;
    ContinueScan1: TMenuItem;
    TaskbarControll: TTaskbar;
    Filte1: TMenuItem;
    ShowGenuineFileOnly1: TMenuItem;
    ShowMismatchedFileOnly1: TMenuItem;
    ShowMissingOnly1: TMenuItem;
    ShowAll1: TMenuItem;
    N2: TMenuItem;
    RestartScan1: TMenuItem;
    VirtualImageList1: TVirtualImageList;
    ImageCollection1: TImageCollection;
    procedure LoadChecksum1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CloseCurrent1Click(Sender: TObject);
    procedure QCListView1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Cancel1Click(Sender: TObject);
    procedure Browsethefile1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CopyFIleName1Click(Sender: TObject);
    procedure CopyFileName2Click(Sender: TObject);
    procedure StartingQCFileChecsum(MDChecksumPath: string);
    procedure Exit1Click(Sender: TObject);
    procedure ListViewResult(Sender: TCustomListView; Item: TListItem;
      SubItem: Integer; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure FormResizeFixQCColumn(Sender: TObject);
    procedure FixListViewSize(Sender: TObject);
    procedure StopTasks1Click(Sender: TObject);
    procedure ContinueScan1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure ShowAll1Click(Sender: TObject);
    procedure ShowGenuineFileOnly1Click(Sender: TObject);
    procedure ShowMismatchedFileOnly1Click(Sender: TObject);
    procedure ShowMissingOnly1Click(Sender: TObject);
    procedure RestartScan1Click(Sender: TObject);
    procedure QCListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure QCListView1Changing(Sender: TObject; Item: TListItem;
      Change: TItemChange; var AllowChange: Boolean);
  private
    FCancelRequested: Boolean;
    FSummaryRowColor: TColor;
    FTotalBytes: Int64;
    FProcessedBytes: Int64;
    FTotalWork: Int64;
    FProcessedWork: Int64;
    FLastUIUpdateTick: Cardinal;
    FScanning: Boolean;
    FClosePending: Boolean;
    FPendingDropFile: string;
    FAllItems: TList<TQCFileRecord>;
    FLines: TStringList;
    FResumeLineIndex: Integer;
    FResumeValidIndex: Integer;
    FResumeReuseRow: Boolean;
    FCurrentChecksumFile: string;
    FDefaultSummaryColor: TColor;
    FGenuineCountStored: Integer;
    FMismatchCountStored: Integer;
    FMissingCountStored: Integer;
    FTotalFilesStored: Integer;
    FTimeTakenStored: string;



    FAlgHandleMD5, FAlgHandleSHA1, FAlgHandleSHA256, FAlgHandleSHA384, FAlgHandleSHA512: Pointer;
    FDigestLenMD5, FDigestLenSHA1, FDigestLenSHA256, FDigestLenSHA384, FDigestLenSHA512: Cardinal;
    function GetSharedAlgHandle(Kind: TQCHashKind; out DigestLen: Cardinal): Pointer;
    procedure CloseAllAlgHandles;


    procedure SetFilterToogle(AItem: TMenuItem);
    procedure ApplyFilter;
    function GetMergedSubItemRect(ItemIndex, FromSubItem, ToSubItem: Integer): TRect;
    procedure ColumnsStretchtoForm;
    procedure GettingReadyQCListView;
    procedure SavingQCLastChanges;
    procedure CancledByUser;
    procedure ReScanChecksumFile;
    procedure DisableEverythingProcesStarted;
    procedure EnableEverythingProcesEnded;
    procedure WMDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    function QCCalculateCRC32WithProgress(const FileName: string): string;
    function QCCalculateMD5WithProgress(const FileName: string): string;
    function QCCalculateSHA1WithProgress(const FileName: string): string;
    function QCCalculateSHA256WithProgress(const FileName: string): string;
    function QCCalculateSHA384WithProgress(const FileName: string): string;  // NEW
    function QCCalculateSHA512WithProgress(const FileName: string): string;  // NEW

    procedure PushProgressUI(FilePerc: Integer; OverallPerc: Double; ForceUpdate: Boolean);
    procedure QCMDHashChecksmProc(const HashChecksumFile: string; Resuming: Boolean = False);
    procedure FreeQCListViewItemsData;
    procedure FormDestroyHandler(Sender: TObject);
  end;

var
  HashChecksum: THashChecksum;
  DetectedChecksumFileName: string;

  MissingFileColor: TColor = clRed;
  NotGenuineFileColor: TColor = $00229CF7;
  GenuineFileColor: TColor = clGreen;
const  OverheadPerFile: Int64 = 1024 * 1024;

implementation {$R *.dfm}


{
FEATURE LIST - QCUnit1
----------------------
1. Load checksum file (.md5 .sha1 .sha256 .crc32 .sfv etc) via menu or drag-drop
2. Auto-detect checksum file in exe folder on startup
3. Command-line parameter support for opening checksum file
4. Background multi-algorithm hashing (MD5/SHA1/SHA256/CRC32) with cancel
5. Weighted progress bar (file size + fixed overhead per file) with decimal % display
6. Per-file progress bar + overall progress + taskbar progress
7. Resume / Continue interrupted scan
8. Restart full scan
9. Filter results: All / Genuine only / Mismatched only / Missing only
10. Summary status row (non-selectable) with icon + merged result text
11. Color / style for Genuine (green), Mismatch (italic orange), Missing (red strikethrough)
12. Right-click context menu: Browse in Explorer / Copy file name
13. Save/restore window size via registry
14. Safe close while scanning (hide + finish then terminate)
15. Pending drop file auto-starts after current scan ends
16. Double-buffered Explorer-themed ListView
17. CNG hardware-accelerated hashing via uQCEngine with System.Hash fallback
}






procedure THashChecksum.About1Click(Sender: TObject);
begin
  ShellAbout(Self.Handle, '', MY_APP_NAME_CHECKIFY + ' v'+ MY_APP_VERSION  +slineBreak+'Developer: '+ MY_APP_DEVELOPER,
  Application.Icon.Handle);
end;

procedure THashChecksum.Browsethefile1Click(Sender: TObject);
var
  Item: TListItem;
  FullPath: string;
begin
  Item := QCListView1.Selected;
  if Assigned(Item) and Assigned(Item.Data) then
  begin
    FullPath := string(PChar(Item.Data));
    if FileExists(FullPath) then
      ShellExecute(Handle, 'open', 'explorer.exe', PChar('/select,"' + FullPath + '"'), nil, SW_SHOWNORMAL);
  end;
end;

procedure THashChecksum.Cancel1Click(Sender: TObject);
begin
  PopupMenu1.CloseMenu;
end;

procedure THashChecksum.CancledByUser;
begin
  FCancelRequested := True;
  if PopupMenu1.PopupComponent <> nil then
    PopupMenu1.CloseMenu;
  TThread.Synchronize(nil,
    procedure
    begin
      ProgressBar2.Position := 0;
      CurrentFileProgress.Caption := '';
      QCLabelParcent.Caption := Format('%.2f%% (Canceled)', [ProgressBar1.Position / 100.0]);
      GroupBox1.Visible := False;
      StopTasks1.Enabled := False;
      TaskbarControll.ProgressState := TTaskbarProgressState.Error;
    end);
end;

procedure THashChecksum.CloseAllAlgHandles;
begin
  QCCloseAlgHandle(FAlgHandleMD5);
  QCCloseAlgHandle(FAlgHandleSHA1);
  QCCloseAlgHandle(FAlgHandleSHA256);
  QCCloseAlgHandle(FAlgHandleSHA384);
  QCCloseAlgHandle(FAlgHandleSHA512);
end;

procedure THashChecksum.CloseCurrent1Click(Sender: TObject);
begin
  if FScanning then
    Exit;
  FreeQCListViewItemsData;
  QCListView1.Clear;
  if Assigned(FAllItems) then
    FAllItems.Clear;
  if Assigned(FLines) then
    FreeAndNil(FLines);
  FResumeLineIndex := -1;
  FResumeValidIndex := -1;
  FResumeReuseRow := False;
  FCurrentChecksumFile := '';
  Caption := MY_APP_NAME_CHECKIFY;
  RestartScan1.Enabled := False;
  ContinueScan1.Enabled := False;
  ShowAll1.Enabled := False;
  ShowGenuineFileOnly1.Enabled := False;
  ShowMismatchedFileOnly1.Enabled := False;
  ShowMissingOnly1.Enabled := False;
end;

procedure THashChecksum.CopyFIleName1Click(Sender: TObject);
begin
  if Assigned(QCListView1.Selected) then
    Clipboard.AsText := QCListView1.Selected.SubItems[0];
end;

procedure THashChecksum.CopyFileName2Click(Sender: TObject);
begin
  if Assigned(QCListView1.Selected) then
    Clipboard.AsText := QCListView1.Selected.SubItems[0];
end;

procedure THashChecksum.Exit1Click(Sender: TObject);
begin
  if FScanning then
  begin
    FCancelRequested := True;
    FClosePending := True;
    Self.Hide;
    Exit;
  end;
  Application.Terminate;
end;

procedure THashChecksum.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FScanning then
  begin
    FCancelRequested := True;
    FClosePending := True;
    Action := caNone;
    Self.Hide;
    Exit;
  end;
  try
    CancledByUser;
  except
  end;
end;

procedure THashChecksum.FormCreate(Sender: TObject);
var
  ChecksumOpenWithQChecikfy: string;
begin
//    Clipboard.AsText:=CalculateUniversalResourceHash('THashChecksum', RT_RCDATA);

  Constraints.MinWidth := 620;
  Constraints.MinHeight := 207;
  Caption := MY_APP_NAME_CHECKIFY;
  GettingReadyQCListView;
  QCListView1.Items.Clear;
  DragAcceptFiles(Handle, True);
  ColumnsStretchtoForm;
  Self.Menu := MainMenu1;
  ShowAll1.Checked := True;
  FAllItems := TList<TQCFileRecord>.Create;
  FResumeLineIndex := -1;
  FResumeValidIndex := -1;
  FResumeReuseRow := False;
  FCurrentChecksumFile := '';
  FPendingDropFile := '';
  ShowAll1.Enabled := False;
  ShowGenuineFileOnly1.Enabled := False;
  ShowMismatchedFileOnly1.Enabled := False;
  ShowMissingOnly1.Enabled := False;
  Self.OnDestroy := FormDestroyHandler;
  QCListView1.OnChanging := QCListView1Changing;


  if ParamCount > 0 then
  begin
    ChecksumOpenWithQChecikfy := ParamStr(1);
    if FileExists(ChecksumOpenWithQChecikfy) and MatchExtension(ChecksumOpenWithQChecikfy, ChecksumExtQC) then
    begin
      Self.Caption := ChecksumOpenWithQChecikfy;
      StartingQCFileChecsum(ChecksumOpenWithQChecikfy);
      Exit;
    end;
  end;

  if StartAutoCheckingIfChecksumExist(DetectedChecksumFileName) then
  begin
    Self.Caption := ExtractFilePath(ParamStr(0)) + DetectedChecksumFileName;
    QCMDHashChecksmProc(ExtractFilePath(ParamStr(0)) + DetectedChecksumFileName);
  end;

end;

procedure THashChecksum.FormDestroyHandler(Sender: TObject);
begin
  FreeQCListViewItemsData;
  SavingQCLastChanges;
  if Assigned(FAllItems) then
    FreeAndNil(FAllItems);
  if Assigned(FLines) then
    FreeAndNil(FLines);
end;

procedure THashChecksum.FormResizeFixQCColumn(Sender: TObject);
begin
  ColumnsStretchtoForm;
end;

procedure THashChecksum.FreeQCListViewItemsData;
var
  i: Integer;
begin
  for i := 0 to QCListView1.Items.Count - 1 do
    if Assigned(QCListView1.Items[i].Data) then
    begin
      StrDispose(PChar(QCListView1.Items[i].Data));
      QCListView1.Items[i].Data := nil;
    end;
end;

procedure THashChecksum.ColumnsStretchtoForm;
var
  FixedWidthSerial, FixedWidthSize, FixedWidthStatus, AvailableWidth, FixedWidthDescription: Integer;
begin
  if QCListView1.Columns.Count < 5 then
    Exit;

  FixedWidthSerial := 70;
  FixedWidthSize := 90;
  FixedWidthStatus := 90;
  FixedWidthDescription := 190;

  AvailableWidth := QCListView1.ClientWidth -
    (FixedWidthSerial + FixedWidthSize + FixedWidthStatus + FixedWidthDescription);
  if AvailableWidth < 0 then
    AvailableWidth := 0;

  QCListView1.Columns[0].Width := FixedWidthSerial;
  QCListView1.Columns[2].Width := FixedWidthSize;
  QCListView1.Columns[3].Width := FixedWidthStatus;
  QCListView1.Columns[4].Width := FixedWidthDescription;
  QCListView1.Columns[1].Width := Round(AvailableWidth * 0.99);

  // status row-এর custom paint ঠিক রাখতে
  QCListView1.Invalidate;
end;

procedure THashChecksum.GettingReadyQCListView;
var
  Header: HWND;
  Style: Integer;
begin
  QCListView1.ViewStyle := vsReport;
  QCListView1.SmallImages := VirtualImageList1;
  QCListView1.GridLines := True;
  Self.Width := QCRegistryRead(MY_REG_PATH_CHECKIFY, QC_WIDTH, Width);
  Self.Height := QCRegistryRead(MY_REG_PATH_CHECKIFY, QC_HEIGHT, Height);

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
    MinWidth := 100;
    Width := 400;
  end;
  with QCListView1.Columns.Add do
  begin
    Caption := 'Size             ';
    MinWidth := 90;
    MaxWidth := 90;
    Width := 90;
    Alignment := taRightJustify;
  end;
  with QCListView1.Columns.Add do
  begin
    Caption := 'Status';
    MinWidth := 90;
    MaxWidth := 90;
    Width := 90;
  end;
  with QCListView1.Columns.Add do
  begin
    Caption := 'Description';
    MinWidth := 190;
    MaxWidth := 190;
    Width := 190;
  end;

  QCListView1.HandleNeeded;
  QCListView1.DoubleBuffered := True;
  SetWindowTheme(QCListView1.Handle, 'Explorer', nil);
  ListView_SetExtendedListViewStyle(QCListView1.Handle,
    ListView_GetExtendedListViewStyle(QCListView1.Handle) or
    LVS_EX_DOUBLEBUFFER or LVS_EX_FULLROWSELECT);

  // ===== Column resize সম্পূর্ণ বন্ধ =====
  Header := ListView_GetHeader(QCListView1.Handle);
  if Header <> 0 then
  begin
    Style := GetWindowLong(Header, GWL_STYLE);
    // HDS_NOSIZING = $0800  (Windows Vista+)
    SetWindowLong(Header, GWL_STYLE, Style or $0800);
  end;
end;

procedure THashChecksum.LoadChecksum1Click(Sender: TObject);
begin
  if FScanning then
    Exit;
  if OpenDialog1.Execute then
  begin
    DetectedChecksumFileName := ExtractFilePath(OpenDialog1.FileName);
    StartingQCFileChecsum(OpenDialog1.FileName);
    Self.Caption := OpenDialog1.FileName;
  end;
end;

function THashChecksum.GetMergedSubItemRect(ItemIndex, FromSubItem, ToSubItem: Integer): TRect;
var
  i: Integer;
  LeftPos, RightPos: Integer;
  ItemR: TRect;
  ScrollX: Integer;
begin
  ItemR := QCListView1.Items[ItemIndex].DisplayRect(drBounds);
  ScrollX := GetScrollPos(QCListView1.Handle, SB_HORZ);

  LeftPos := 0;
  for i := 0 to FromSubItem - 1 do
    Inc(LeftPos, QCListView1.Columns[i].Width);
  LeftPos := LeftPos - ScrollX;

  RightPos := 0;
  for i := 0 to ToSubItem do
    Inc(RightPos, QCListView1.Columns[i].Width);
  RightPos := RightPos - ScrollX;

  Result := Rect(ItemR.Left + LeftPos, ItemR.Top, ItemR.Left + RightPos, ItemR.Bottom);
end;

function THashChecksum.GetSharedAlgHandle(Kind: TQCHashKind; out DigestLen: Cardinal): Pointer;
begin
  case Kind of
    qcMD5:
      begin
        if not Assigned(FAlgHandleMD5) then
          FAlgHandleMD5 := QCOpenAlgHandle(qcMD5, FDigestLenMD5);
        Result := FAlgHandleMD5;
        DigestLen := FDigestLenMD5;
      end;
    qcSHA1:
      begin
        if not Assigned(FAlgHandleSHA1) then
          FAlgHandleSHA1 := QCOpenAlgHandle(qcSHA1, FDigestLenSHA1);
        Result := FAlgHandleSHA1;
        DigestLen := FDigestLenSHA1;
      end;
    qcSHA256:
      begin
        if not Assigned(FAlgHandleSHA256) then
          FAlgHandleSHA256 := QCOpenAlgHandle(qcSHA256, FDigestLenSHA256);
        Result := FAlgHandleSHA256;
        DigestLen := FDigestLenSHA256;
      end;
    qcSHA384:
      begin
        if not Assigned(FAlgHandleSHA384) then
          FAlgHandleSHA384 := QCOpenAlgHandle(qcSHA384, FDigestLenSHA384);
        Result := FAlgHandleSHA384;
        DigestLen := FDigestLenSHA384;
      end;
    qcSHA512:
      begin
        if not Assigned(FAlgHandleSHA512) then
          FAlgHandleSHA512 := QCOpenAlgHandle(qcSHA512, FDigestLenSHA512);
        Result := FAlgHandleSHA512;
        DigestLen := FDigestLenSHA512;
      end;
  else
    begin
      Result := nil;
      DigestLen := 0;
    end;
  end;
end;



procedure THashChecksum.ListViewResult(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  // Status row-এ হাত দেব না
  if Item.Caption = 'Status:' then
  begin
    DefaultDraw := False;
    Exit;
  end;

  // Show All মোডেই শুধু বিশেষ স্টাইল
  if ShowAll1.Checked then
  begin
    if Item.ImageIndex = 2 then          // Mismatch
    begin
      Sender.Canvas.Font.Style := [fsItalic];
      Sender.Canvas.Font.Color := NotGenuineFileColor;
      DefaultDraw := True;
    end
    else if Item.ImageIndex = 3 then     // Missing
    begin
      if SubItem = 1 then
        Sender.Canvas.Font.Style := [fsStrikeOut]
      else
        Sender.Canvas.Font.Style := [];
      Sender.Canvas.Font.Color := MissingFileColor;
      DefaultDraw := True;
    end
    else
    begin
      Sender.Canvas.Font.Style := [];
      Sender.Canvas.Font.Color := clWindowText;
      DefaultDraw := True;
    end;
  end
  else
  begin
    // Genuine / Mismatched / Missing ফিল্টারে সব নরমাল
    Sender.Canvas.Font.Style := [];
    Sender.Canvas.Font.Color := clWindowText;
    DefaultDraw := True;
  end;
end;
        {
procedure THashChecksum.ListViewResult(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  if Item.Caption = 'Status:' then
  begin
    DefaultDraw := False;
    Exit;
  end;

  if Item.ImageIndex = 2 then
  begin
    Sender.Canvas.Font.Style := [fsItalic];
    Sender.Canvas.Font.Color := NotGenuineFileColor;
    DefaultDraw := True;
  end
  else if Item.ImageIndex = 3 then
  begin
    if SubItem = 1 then
      Sender.Canvas.Font.Style := [fsStrikeOut]
    else
      Sender.Canvas.Font.Style := [];
    Sender.Canvas.Font.Color := MissingFileColor;
    DefaultDraw := True;
  end
  else
  begin
    Sender.Canvas.Font.Style := [];
    Sender.Canvas.Font.Color := clWindowText;
    DefaultDraw := True;
  end;
end;
          }
procedure THashChecksum.QCListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var
  FullR, Col0R, MergeR: TRect;
  ResultText: string;
  IconW, ScrollX, Col0Width: Integer;
begin
  if Item.Caption <> 'Status:' then
  begin
    DefaultDraw := True;
    Exit;
  end;

  DefaultDraw := False;

  FullR := Item.DisplayRect(drBounds);
  Sender.Canvas.Brush.Color := clWindow;
  Sender.Canvas.FillRect(FullR);

  ScrollX := GetScrollPos(QCListView1.Handle, SB_HORZ);
  Col0Width := QCListView1.Columns[0].Width;

  Col0R := Rect(FullR.Left, FullR.Top, FullR.Left + Col0Width - ScrollX, FullR.Bottom);
  if Col0R.Right < Col0R.Left then
    Col0R.Right := Col0R.Left;

  IconW := 0;
  if Item.ImageIndex >= 0 then
  begin
    IconW := 18;
    VirtualImageList1.Draw(Sender.Canvas, Col0R.Left + 2, Col0R.Top + 2, Item.ImageIndex);
  end;

  Sender.Canvas.Font.Color := FSummaryRowColor;
  Sender.Canvas.Font.Style := [];
  Sender.Canvas.Brush.Style := bsClear;
  Sender.Canvas.TextOut(Col0R.Left + IconW + 4, Col0R.Top + 2, 'Status:');

  MergeR := GetMergedSubItemRect(Item.Index, 1, 4);
  Sender.Canvas.Brush.Color := clWindow;
  Sender.Canvas.FillRect(MergeR);

  ResultText := '';
  if Item.SubItems.Count > 0 then
    ResultText := Item.SubItems[0];

  Sender.Canvas.Font.Color := FSummaryRowColor;
  Sender.Canvas.Brush.Style := bsClear;
  Sender.Canvas.TextOut(MergeR.Left + 4, MergeR.Top + 2, ResultText);
end;




procedure THashChecksum.QCListView1Changing(Sender: TObject; Item: TListItem;
  Change: TItemChange; var AllowChange: Boolean);
begin
  if (Change = ctState) and Assigned(Item) and (Item.Caption = 'Status:') then
    AllowChange := False;
end;

procedure THashChecksum.QCListView1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  Item: TListItem;
  FilePath: string;
begin
  if Button = mbRight then
  begin
    Item := QCListView1.GetItemAt(X, Y);
    if Assigned(Item) and Assigned(Item.Data) then
    begin
      FilePath := string(PChar(Item.Data));
      Browsethefile1.Enabled := FileExists(FilePath);
      PopupMenu1.Popup(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    end;
  end;
end;

procedure THashChecksum.FixListViewSize(Sender: TObject);
begin
  ColumnsStretchtoForm;
end;

procedure THashChecksum.PushProgressUI(FilePerc: Integer; OverallPerc: Double; ForceUpdate: Boolean);
var
  Now_: Cardinal;
begin
  Now_ := GetTickCount;
  if (not ForceUpdate) and (Now_ - FLastUIUpdateTick < UIUpdateIntervalMs) then
    Exit;
  FLastUIUpdateTick := Now_;

  TThread.Queue(nil,
    procedure
    begin
      ProgressBar2.Position := FilePerc;
      CurrentFileProgress.Caption := Format('%d%%', [FilePerc]);
      ProgressBar1.Position := Round(OverallPerc * 100);
      TaskbarControll.ProgressValue := Round(OverallPerc);
      QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
    end);
end;

function THashChecksum.QCCalculateCRC32WithProgress(const FileName: string): string;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  ActualBufSize: Integer;
  FilePerc: Integer;
  OverallPerc: Double;
  CRCValue: LongWord;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);
  try
    FileSize := Stream.Size;
    TotalRead := 0;
    CRCValue := $FFFFFFFF;

    // ছোট ফাইলে fixed 16MB buffer allocate না করে, ফাইলের size অনুযায়ী
    // dynamic buffer ব্যবহার হচ্ছে — এতে হাজারো ছোট ফাইলে allocation overhead কমে
    if (FileSize > 0) and (FileSize < MaxBufferSize) then
      ActualBufSize := FileSize
    else
      ActualBufSize := MaxBufferSize;
    if ActualBufSize <= 0 then
      ActualBufSize := 1;
    SetLength(Buffer, ActualBufSize);

    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        ProgressBar2.Max := 100;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], ActualBufSize);
      if BytesRead = 0 then
        Break;

      CRCValue := UpdateCRC32(CRCValue, Buffer[0], BytesRead);
      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      CRCValue := CRCValue xor $FFFFFFFF;
      Result := IntToHex(CRCValue, 8).ToUpper;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;


function THashChecksum.QCCalculateMD5WithProgress(const FileName: string): string;
const
  BufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  FilePerc: Integer;
  OverallPerc: Double;
  Hasher: TQCFastHasher;
  FallbackMD5: THashMD5;
  UseFallback: Boolean;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);
  Hasher := TQCFastHasher.Create(qcMD5);
  UseFallback := not Hasher.Valid;
  if UseFallback then
    FallbackMD5 := THashMD5.Create;
  try
    FileSize := Stream.Size;
    TotalRead := 0;
    SetLength(Buffer, BufferSize);
    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Max := 100;
        ProgressBar2.Position := 0;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], BufferSize);
      if BytesRead = 0 then
        Break;

      if UseFallback then
        FallbackMD5.Update(Buffer, BytesRead)
      else
        Hasher.Update(Buffer[0], BytesRead);

      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      if UseFallback then
        Result := FallbackMD5.HashAsString.ToUpper
      else
        Result := Hasher.Finalize;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    Hasher.Free;
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;

function THashChecksum.QCCalculateSHA1WithProgress(const FileName: string): string;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  ActualBufSize: Integer;
  FilePerc: Integer;
  OverallPerc: Double;
  Hasher: TQCFastHasher;
  FallbackSHA1: THashSHA1;
  UseFallback: Boolean;
  SharedAlg: Pointer;
  SharedDigestLen: Cardinal;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);

  SharedAlg := GetSharedAlgHandle(qcSHA1, SharedDigestLen);
  Hasher := TQCFastHasher.CreateShared(SharedAlg, SharedDigestLen);
  UseFallback := not Hasher.Valid;
  if UseFallback then
    FallbackSHA1 := THashSHA1.Create;
  try
    FileSize := Stream.Size;
    TotalRead := 0;

    if (FileSize > 0) and (FileSize < MaxBufferSize) then
      ActualBufSize := FileSize
    else
      ActualBufSize := MaxBufferSize;
    if ActualBufSize <= 0 then
      ActualBufSize := 1;
    SetLength(Buffer, ActualBufSize);

    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Max := 100;
        ProgressBar2.Position := 0;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], ActualBufSize);
      if BytesRead = 0 then
        Break;

      if UseFallback then
        FallbackSHA1.Update(Buffer, BytesRead)
      else
        Hasher.Update(Buffer[0], BytesRead);

      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      if UseFallback then
        Result := FallbackSHA1.HashAsString.ToUpper
      else
        Result := Hasher.Finalize;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    Hasher.Free;
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;


function THashChecksum.QCCalculateSHA256WithProgress(const FileName: string): string;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  ActualBufSize: Integer;
  FilePerc: Integer;
  OverallPerc: Double;
  Hasher: TQCFastHasher;
  FallbackSHA256: THashSHA2;
  UseFallback: Boolean;
  SharedAlg: Pointer;
  SharedDigestLen: Cardinal;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);

  SharedAlg := GetSharedAlgHandle(qcSHA256, SharedDigestLen);
  Hasher := TQCFastHasher.CreateShared(SharedAlg, SharedDigestLen);
  UseFallback := not Hasher.Valid;
  if UseFallback then
    FallbackSHA256 := THashSHA2.Create;
  try
    FileSize := Stream.Size;
    TotalRead := 0;

    if (FileSize > 0) and (FileSize < MaxBufferSize) then
      ActualBufSize := FileSize
    else
      ActualBufSize := MaxBufferSize;
    if ActualBufSize <= 0 then
      ActualBufSize := 1;
    SetLength(Buffer, ActualBufSize);

    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        ProgressBar2.Max := 100;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], ActualBufSize);
      if BytesRead = 0 then
        Break;

      if UseFallback then
        FallbackSHA256.Update(Buffer, BytesRead)
      else
        Hasher.Update(Buffer[0], BytesRead);

      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      if UseFallback then
        Result := FallbackSHA256.HashAsString.ToUpper
      else
        Result := Hasher.Finalize;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    Hasher.Free;
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;


function THashChecksum.QCCalculateSHA384WithProgress(const FileName: string): string;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  ActualBufSize: Integer;
  FilePerc: Integer;
  OverallPerc: Double;
  Hasher: TQCFastHasher;
  SharedAlg: Pointer;
  SharedDigestLen: Cardinal;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);

  SharedAlg := GetSharedAlgHandle(qcSHA384, SharedDigestLen);
  Hasher := TQCFastHasher.CreateShared(SharedAlg, SharedDigestLen);
  try
    if not Hasher.Valid then
      Exit;

    FileSize := Stream.Size;
    TotalRead := 0;

    if (FileSize > 0) and (FileSize < MaxBufferSize) then
      ActualBufSize := FileSize
    else
      ActualBufSize := MaxBufferSize;
    if ActualBufSize <= 0 then
      ActualBufSize := 1;
    SetLength(Buffer, ActualBufSize);

    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        ProgressBar2.Max := 100;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], ActualBufSize);
      if BytesRead = 0 then
        Break;

      Hasher.Update(Buffer[0], BytesRead);

      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      Result := Hasher.Finalize;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    Hasher.Free;
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;


function THashChecksum.QCCalculateSHA512WithProgress(const FileName: string): string;
const
  MaxBufferSize = 16 * 1024 * 1024;
var
  Stream: THandleStream;
  Buffer: TBytes;
  BytesRead, TotalRead, FileSize, ExpectedSize: Int64;
  ActualBufSize: Integer;
  FilePerc: Integer;
  OverallPerc: Double;
  Hasher: TQCFastHasher;
  SharedAlg: Pointer;
  SharedDigestLen: Cardinal;
begin
  Result := '';
  ExpectedSize := GetFileExpectedSize(FileName);

  if not FileExists(FileName) then
  begin
    Inc(FProcessedBytes, ExpectedSize);
    Inc(FProcessedWork, ExpectedSize + OverheadPerFile);
    TThread.Synchronize(nil,
      procedure
      begin
        OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
        ProgressBar1.Position := Round(OverallPerc * 100);
        TaskbarControll.ProgressValue := Round(OverallPerc);
        QCLabelParcent.Caption := Format('%.2f%%', [OverallPerc]);
        CurrentFileProgress.Caption := 'Missing';
      end);
    Exit;
  end;

  Stream := QCOpenSequentialFileStream(FileName);

  SharedAlg := GetSharedAlgHandle(qcSHA512, SharedDigestLen);
  Hasher := TQCFastHasher.CreateShared(SharedAlg, SharedDigestLen);
  try
    if not Hasher.Valid then
      Exit;

    FileSize := Stream.Size;
    TotalRead := 0;

    if (FileSize > 0) and (FileSize < MaxBufferSize) then
      ActualBufSize := FileSize
    else
      ActualBufSize := MaxBufferSize;
    if ActualBufSize <= 0 then
      ActualBufSize := 1;
    SetLength(Buffer, ActualBufSize);

    FLastUIUpdateTick := 0;

    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        ProgressBar2.Max := 100;
      end);

    while True do
    begin
      if FCancelRequested then
        Break;
      BytesRead := Stream.Read(Buffer[0], ActualBufSize);
      if BytesRead = 0 then
        Break;

      Hasher.Update(Buffer[0], BytesRead);

      Inc(TotalRead, BytesRead);
      Inc(FProcessedBytes, BytesRead);
      Inc(FProcessedWork, BytesRead);

      FilePerc := Round((TotalRead / FileSize) * 100);
      OverallPerc := (FProcessedWork / FTotalWork) * 100.0;
      PushProgressUI(FilePerc, OverallPerc, False);
    end;

    if not FCancelRequested then
    begin
      Result := Hasher.Finalize;
      Inc(FProcessedWork, OverheadPerFile);
      PushProgressUI(100, (FProcessedWork / FTotalWork) * 100.0, True);
    end;
  finally
    Hasher.Free;
    CloseHandle(Stream.Handle);
    Stream.Free;
    TThread.Synchronize(nil,
      procedure
      begin
        ProgressBar2.Position := 0;
        CurrentFileProgress.Caption := '';
      end);
  end;
end;




procedure THashChecksum.QCMDHashChecksmProc(const HashChecksumFile: string; Resuming: Boolean = False);
begin
  if FScanning then
    Exit;

  FCancelRequested := False;
  FScanning := True;
  DisableEverythingProcesStarted;
  TaskbarControll.ProgressState := TTaskbarProgressState.Normal;
  if not Resuming then
    FCurrentChecksumFile := HashChecksumFile;

  TTask.Run(
    procedure
    var
      Line, QCTimeTaken, FileName, ExpectedHash, RealHash, FullPath: string;
      i, ValidIndex, MissingCount, GenuineCount, MismatchCount, TotalSeconds, Minutes, Seconds: Integer;
      StartTime, EndTime: TDateTime;
      StartLineIndex: Integer;
      LoadFailed: Boolean;
      FileCount: Integer;
    begin
      try
        LoadFailed := False;

        if (not Resuming) or (not Assigned(FLines)) then
        begin
          if Assigned(FLines) then
            FreeAndNil(FLines);
          FLines := TStringList.Create;

          try
            FLines.LoadFromFile(HashChecksumFile);
          except
            on E: Exception do
            begin
              LoadFailed := True;
              TThread.Synchronize(nil,
                procedure
                begin
                  GroupBox1.Visible := False;
                  MessageDlg('Could not open checksum file:' + sLineBreak + E.Message,  mtWarning, [mbOK], 0)
                end);
            end;
          end;
          if LoadFailed then
            Exit;

          StartLineIndex := 0;
          ValidIndex := 0;
          FResumeReuseRow := False;

          TThread.Synchronize(nil,
            procedure
            begin
              FreeQCListViewItemsData;
              QCListView1.Items.Clear;
              FAllItems.Clear;
              SetFilterToogle(ShowAll1);
              ProgressBar1.Position := 0;
              ProgressBar1.Max := 10000;
              TaskbarControll.ProgressValue := 0;
              TaskbarControll.ProgressMaxValue := 100;
              QCLabelParcent.Caption := '0.00%';
              GroupBox1.Visible := True;
            end);

          FTotalBytes := 0;
          FProcessedBytes := 0;
          FTotalWork := 0;
          FProcessedWork := 0;
          FileCount := 0;

          for i := 0 to FLines.Count - 1 do
          begin
            Line := Trim(FLines[i]);
            if (Line = '') or (Line.StartsWith(';')) or (Line.StartsWith('\')) or
               (Line.StartsWith('/')) or (Line.StartsWith('#')) or
               (Line.StartsWith('*')) or (Pos('*', Line) = 0) then
              Continue;

            FileName := Trim(Copy(Line, Pos('*', Line) + 1, MaxInt));
            FullPath := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(HashChecksumFile)) + FileName);

            Inc(FileCount);
            if FileExists(FullPath) then
              Inc(FTotalBytes, TFile.GetSize(FullPath))
            else
              Inc(FTotalBytes, 1024);
          end;

          FTotalWork := FTotalBytes + (Int64(FileCount) * OverheadPerFile);
          if FTotalWork = 0 then
            FTotalWork := 1;
        end
        else
        begin
          StartLineIndex := FResumeLineIndex;
          ValidIndex := FResumeValidIndex;

          FTotalBytes := 0;
          FProcessedBytes := 0;
          FTotalWork := 0;
          FProcessedWork := 0;
          FileCount := 0;

          for i := StartLineIndex to FLines.Count - 1 do
          begin
            Line := Trim(FLines[i]);
            if (Line = '') or (Line.StartsWith(';')) or (Line.StartsWith('\')) or
               (Line.StartsWith('/')) or (Line.StartsWith('#')) or
               (Line.StartsWith('*')) or (Pos('*', Line) = 0) then
              Continue;

            FileName := Trim(Copy(Line, Pos('*', Line) + 1, MaxInt));
            FullPath := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(HashChecksumFile)) + FileName);

            Inc(FileCount);
            if FileExists(FullPath) then
              Inc(FTotalBytes, TFile.GetSize(FullPath))
            else
              Inc(FTotalBytes, 1024);
          end;

          FTotalWork := FTotalBytes + (Int64(FileCount) * OverheadPerFile);
          if FTotalWork = 0 then
            FTotalWork := 1;

          TThread.Synchronize(nil,
            procedure
            begin
              GroupBox1.Visible := True;
              ProgressBar1.Position := 0;
              ProgressBar1.Max := 10000;
              TaskbarControll.ProgressValue := 0;
              QCLabelParcent.Caption := '0.00%';
            end);
        end;

        StartTime := Now;

        for i := StartLineIndex to FLines.Count - 1 do
        begin
          if FCancelRequested then
            Break;

          Line := Trim(FLines[i]);
          if (Line = '') or (Line.StartsWith(';')) or (Line.StartsWith('\')) or
             (Line.StartsWith('/')) or (Line.StartsWith('#')) or
             (Line.StartsWith('*')) or (Pos('*', Line) = 0) then
            Continue;

          ExpectedHash := Trim(Copy(Line, 1, Pos('*', Line) - 1));
          FileName := Trim(Copy(Line, Pos('*', Line) + 1, MaxInt));
          FullPath := ExpandFileName(IncludeTrailingPathDelimiter(ExtractFilePath(HashChecksumFile)) + FileName);

          // ===== এই একই Synchronize ব্লকে এখন row add/update এবং
          // select+scroll দুইটাই একসাথে করা হচ্ছে — আগে এই দুটো কাজ
          // আলাদা আলাদা Synchronize কলে হতো, যেটা প্রতি ফাইলে একটা
          // অতিরিক্ত thread context-switch তৈরি করছিল =====
          if Resuming and (i = StartLineIndex) and FResumeReuseRow then
          begin
            TThread.Synchronize(nil,
              procedure
              var
                Rec: TQCFileRecord;
              begin
                with QCListView1.Items[ValidIndex] do
                begin
                  SubItems[2] := CurrentFileStatus;
                  SubItems[3] := CurrentFileDescription;
                  ImageIndex := 0;
                end;
                Rec := FAllItems[ValidIndex];
                Rec.Status := CurrentFileStatus;
                Rec.Description := CurrentFileDescription;
                Rec.ImageIndex := 0;
                FAllItems[ValidIndex] := Rec;

                QCListView1.ItemIndex := ValidIndex;
                if Assigned(QCListView1.Selected) then
                  QCListView1.Selected.MakeVisible(False);
              end);
          end
          else
          begin
            TThread.Synchronize(nil,
              procedure
              var
                Item: TListItem;
                Rec: TQCFileRecord;
              begin
                Item := QCListView1.Items.Add;
                Item.Caption := Format('%.2d', [ValidIndex + 1]);
                Item.SubItems.Add(GetDisplayRelativePath(FileName));
                Item.SubItems.Add(GetFormattedFileSize(FullPath));
                Item.SubItems.Add(CurrentFileStatus);
                Item.SubItems.Add(CurrentFileDescription);
                Item.Data := Pointer(StrNew(PChar(FullPath)));

                Rec.Serial := Item.Caption;
                Rec.FileName := GetDisplayRelativePath(FileName);
                Rec.SizeStr := Item.SubItems[1];
                Rec.Status := CurrentFileStatus;
                Rec.Description := CurrentFileDescription;
                Rec.ImageIndex := 0;
                Rec.FullPath := FullPath;
                Rec.IsSummary := False;
                FAllItems.Add(Rec);

                QCListView1.ItemIndex := ValidIndex;
                if Assigned(QCListView1.Selected) then
                  QCListView1.Selected.MakeVisible(False);
              end);
          end;
          // পুরনো আলাদা "QCListView1.ItemIndex := ValidIndex;" Synchronize ব্লকটা
          // এখন সম্পূর্ণভাবে বাদ দেওয়া হয়েছে, কারণ সেটা উপরের দুটো ব্লকের
          // ভেতরেই merge হয়ে গেছে।

          if not FileExists(FullPath) then
          begin
            TThread.Synchronize(nil,
              procedure
              var
                Rec: TQCFileRecord;
              begin
                with QCListView1.Items[ValidIndex] do
                begin
                  SubItems[2] := FileisMissingStr;
                  SubItems[3] := FileISMissingDescStr;
                  ImageIndex := 3;
                end;
                Rec := FAllItems[ValidIndex];
                Rec.Status := FileisMissingStr;
                Rec.Description := FileISMissingDescStr;
                Rec.ImageIndex := 3;
                FAllItems[ValidIndex] := Rec;
              end);
            Inc(FProcessedWork, 1024 + OverheadPerFile);
          end
          else
          begin
            try
              if FCancelRequested then
                Break;

              if Length(ExpectedHash) = 32 then
                RealHash := QCCalculateMD5WithProgress(FullPath).ToUpper
              else if Length(ExpectedHash) = 40 then
                RealHash := QCCalculateSHA1WithProgress(FullPath).ToUpper
              else if Length(ExpectedHash) = 64 then
                RealHash := QCCalculateSHA256WithProgress(FullPath).ToUpper
              else if Length(ExpectedHash) = 96 then
                RealHash := QCCalculateSHA384WithProgress(FullPath).ToUpper
              else if Length(ExpectedHash) = 128 then
                RealHash := QCCalculateSHA512WithProgress(FullPath).ToUpper
              else if Length(ExpectedHash) = 8 then
                RealHash := QCCalculateCRC32WithProgress(FullPath).ToUpper
              else
              begin
                RealHash := '';
                Inc(FProcessedBytes, TFile.GetSize(FullPath));
                Inc(FProcessedWork, TFile.GetSize(FullPath) + OverheadPerFile);
              end;

              if FCancelRequested then
              begin
                FResumeReuseRow := True;
                TThread.Synchronize(nil,
                  procedure
                  var
                    Rec: TQCFileRecord;
                  begin
                    with QCListView1.Items[ValidIndex] do
                    begin
                      SubItems[2] := FileisAbortedStr;
                      SubItems[3] := FileISAbortedDescStr;
                      ImageIndex := 0;
                    end;
                    Rec := FAllItems[ValidIndex];
                    Rec.Status := FileisAbortedStr;
                    Rec.Description := FileISAbortedDescStr;
                    Rec.ImageIndex := 0;
                    FAllItems[ValidIndex] := Rec;
                  end);
                Break;
              end;

              TThread.Synchronize(nil,
                procedure
                var
                  Rec: TQCFileRecord;
                begin
                  with QCListView1.Items[ValidIndex] do
                  begin
                    if RealHash = ExpectedHash.ToUpper then
                    begin
                      SubItems[2] := FileisOKStr;
                      SubItems[3] := FileISOKDescStr;
                      ImageIndex := 1;
                    end
                    else
                    begin
                      SubItems[2] := FileisMissMatchStr;
                      SubItems[3] := FileISMissMatchDescStr;
                      ImageIndex := 2;
                    end;
                  end;
                  Rec := FAllItems[ValidIndex];
                  if RealHash = ExpectedHash.ToUpper then
                  begin
                    Rec.Status := FileisOKStr;
                    Rec.Description := FileISOKDescStr;
                    Rec.ImageIndex := 1;
                  end
                  else
                  begin
                    Rec.Status := FileisMissMatchStr;
                    Rec.Description := FileISMissMatchDescStr;
                    Rec.ImageIndex := 2;
                  end;
                  FAllItems[ValidIndex] := Rec;
                end);
            except
              on E: Exception do
                TThread.Synchronize(nil,
                  procedure
                  var
                    Rec: TQCFileRecord;
                  begin
                    with QCListView1.Items[ValidIndex] do
                    begin
                      SubItems[2] := 'Error';
                      SubItems[3] := E.Message;
                      ImageIndex := 3;
                    end;
                    Rec := FAllItems[ValidIndex];
                    Rec.Status := 'Error';
                    Rec.Description := E.Message;
                    Rec.ImageIndex := 3;
                    FAllItems[ValidIndex] := Rec;
                  end);
            end;
          end;

          Inc(ValidIndex);
          FResumeLineIndex := i + 1;
          FResumeValidIndex := ValidIndex;
          FResumeReuseRow := False;
        end;

        EndTime := Now;
        MissingCount := 0;
        MismatchCount := 0;
        GenuineCount := 0;

        TThread.Synchronize(nil,
          procedure
          var
            j: Integer;
            SummaryRec: TQCFileRecord;
          begin
            if FCancelRequested then
            begin
              GroupBox1.Visible := False;
              EnableEverythingProcesEnded;
              ContinueScan1.Enabled := True;
              Exit;
            end;

            ProgressBar1.Position := 10000;
            QCLabelParcent.Caption := '100.00%';
            TaskbarControll.ProgressValue := 100;
            TaskbarControll.ProgressState := TTaskbarProgressState.None;

            for j := 0 to FAllItems.Count - 1 do
            begin
              if FAllItems[j].ImageIndex = 1 then
                Inc(GenuineCount)
              else if FAllItems[j].ImageIndex = 3 then
                Inc(MissingCount)
              else if FAllItems[j].ImageIndex = 2 then
                Inc(MismatchCount);
            end;

            if (MissingCount = 0) and (MismatchCount = 0) then
              FSummaryRowColor := GenuineFileColor
            else if MissingCount > 0 then
              FSummaryRowColor := clRed
            else
              FSummaryRowColor := TColor(NotGenuineFileColor);

            FDefaultSummaryColor := FSummaryRowColor;
            FGenuineCountStored := GenuineCount;
            FMismatchCountStored := MismatchCount;
            FMissingCountStored := MissingCount;
            FTotalFilesStored := GenuineCount + MismatchCount + MissingCount;

            TotalSeconds := SecondsBetween(EndTime, StartTime);
            if TotalSeconds >= 60 then
            begin
              Minutes := TotalSeconds div 60;
              Seconds := TotalSeconds mod 60;
              QCTimeTaken := Format('Time Taken: %d minute(s) %d second(s).', [Minutes, Seconds]);
            end
            else
              QCTimeTaken := Format('Time Taken: %d second(s).', [TotalSeconds]);
            FTimeTakenStored := QCTimeTaken;

            SummaryRec.Serial := 'Status:';
            SummaryRec.ImageIndex := SummaryImageIndexFor(GenuineCount, MismatchCount, MissingCount);
            SummaryRec.IsSummary := True;
            SummaryRec.FullPath := '';
            if (MissingCount = 0) and (MismatchCount = 0) then
              SummaryRec.FileName := 'All files are OK. ' + QCTimeTaken
            else
              SummaryRec.FileName := Format('Genuine: %d,   Not Genuine: %d,   Missing:  %d,   ' + QCTimeTaken,
                [GenuineCount, MismatchCount, MissingCount]);
            SummaryRec.SizeStr := '';
            SummaryRec.Status := '';
            SummaryRec.Description := '';
            FAllItems.Add(SummaryRec);

            ApplyFilter;

            if QCListView1.Items.Count > 0 then
            begin
              QCListView1.Items[QCListView1.Items.Count - 1].MakeVisible(False);
              SendMessage(QCListView1.Handle, LVM_ENSUREVISIBLE,
                QCListView1.Items.Count - 1, 0);
            end;

            GroupBox1.Visible := False;
            Caption := HashChecksumFile;
            if not FCancelRequested then
              MessageBeep(MB_ICONINFORMATION);
            EnableEverythingProcesEnded;
            ContinueScan1.Enabled := False;
            FResumeLineIndex := -1;
            FResumeValidIndex := -1;
          end);
      finally
        CloseAllAlgHandles;
        FScanning := False;
        if FClosePending then
          TThread.Queue(nil,
            procedure
            begin
              Application.Terminate;
            end)
        else if FPendingDropFile <> '' then
          TThread.Queue(nil,
            procedure
            var
              DropFile: string;
            begin
              DropFile := FPendingDropFile;
              FPendingDropFile := '';
              if DropFile <> '' then
              begin
                DetectedChecksumFileName := ExtractFilePath(DropFile);
                StartingQCFileChecsum(DropFile);
                Self.Caption := DropFile;
              end;
            end);
      end;
    end);
end;



procedure THashChecksum.ReScanChecksumFile;
begin
  if FileExists(Caption) then
  begin
    FCancelRequested := False;
    GroupBox1.Visible := True;
    ProgressBar1.Position := 0;
    ProgressBar2.Position := 0;
    TaskbarControll.ProgressValue := 0;
    QCLabelParcent.Caption := '0.00%';
    CurrentFileProgress.Caption := '';
    QCMDHashChecksmProc(Caption);
  end
  else
      MessageDlg('No checksum file loaded to re-scan.',  mtInformation, [mbOK], 0)
end;

procedure THashChecksum.RestartScan1Click(Sender: TObject);
begin
  if not ShowAll1.Checked then
  begin
    SetFilterToogle(ShowAll1);
    ApplyFilter;
  end;
  ReScanChecksumFile;
end;

procedure THashChecksum.DisableEverythingProcesStarted;
begin
  StopTasks1.Enabled := True;
  RestartScan1.Enabled := False;
  ContinueScan1.Enabled := False;
  ShowAll1.Enabled := False;
  ShowGenuineFileOnly1.Enabled := False;
  ShowMismatchedFileOnly1.Enabled := False;
  ShowMissingOnly1.Enabled := False;
  CloseCurrent1.Enabled := False;
  LoadChecksum1.Enabled := False;
end;

procedure THashChecksum.EnableEverythingProcesEnded;
var
  HasItems: Boolean;
begin
  StopTasks1.Enabled := False;
  RestartScan1.Enabled := True;
  HasItems := Assigned(FAllItems) and (FAllItems.Count > 0);
  ShowAll1.Enabled := HasItems;
  ShowGenuineFileOnly1.Enabled := HasItems;
  ShowMismatchedFileOnly1.Enabled := HasItems;
  ShowMissingOnly1.Enabled := HasItems;
  CloseCurrent1.Enabled := True;
  LoadChecksum1.Enabled := True;
end;

procedure THashChecksum.SavingQCLastChanges;
begin
  if Self.WindowState <> wsMaximized then
  begin
    QCWriteRegistry(MY_REG_PATH_CHECKIFY, QC_HEIGHT, Self.Height);
    QCWriteRegistry(MY_REG_PATH_CHECKIFY, QC_WIDTH, Self.Width);
  end;
end;

procedure THashChecksum.ContinueScan1Click(Sender: TObject);
begin
  if (not Assigned(FLines)) or (FCurrentChecksumFile = '') then
  begin
      MessageDlg('No cancelled scan to continue.',  mtInformation, [mbOK], 0);

      Exit;
  end;
  if FResumeLineIndex < 0 then
  begin
    ReScanChecksumFile;
    Exit;
  end;
  if not ShowAll1.Checked then
  begin
    SetFilterToogle(ShowAll1);
    ApplyFilter;
  end;
  QCMDHashChecksmProc(FCurrentChecksumFile, True);
end;

procedure THashChecksum.SetFilterToogle(AItem: TMenuItem);
begin
  ShowAll1.Checked := False;
  ShowGenuineFileOnly1.Checked := False;
  ShowMismatchedFileOnly1.Checked := False;
  ShowMissingOnly1.Checked := False;
  AItem.Checked := True;
end;

procedure THashChecksum.ApplyFilter;
var
  i: Integer;
  Rec: TQCFileRecord;
  Item: TListItem;
  ShowIt: Boolean;
  DisplayText: string;
  SummaryImageIndex: Integer;
begin
  if not Assigned(FAllItems) then
    Exit;

  QCListView1.Items.BeginUpdate;
  try
    FreeQCListViewItemsData;
    QCListView1.Items.Clear;

    for i := 0 to FAllItems.Count - 1 do
    begin
      Rec := FAllItems[i];
      SummaryImageIndex := 0;

      if Rec.IsSummary then
      begin
        ShowIt := True;
        if ShowMissingOnly1.Checked then
        begin
          DisplayText := Format('Total Missing File: %d of %d', [FMissingCountStored, FTotalFilesStored]);
          FSummaryRowColor := MissingFileColor;
          SummaryImageIndex := 7;
        end
        else if ShowMismatchedFileOnly1.Checked then
        begin
          DisplayText := Format('Total Missmatched File: %d of %d', [FMismatchCountStored, FTotalFilesStored]);
          FSummaryRowColor := NotGenuineFileColor;
          SummaryImageIndex := 6;
        end
        else if ShowGenuineFileOnly1.Checked then
        begin
          DisplayText := Format('Total Genuine File: %d of %d', [FGenuineCountStored, FTotalFilesStored]);
          FSummaryRowColor := GenuineFileColor;
          SummaryImageIndex := 5;
        end
        else
        begin
          DisplayText := Rec.FileName;
          FSummaryRowColor := FDefaultSummaryColor;
          SummaryImageIndex := Rec.ImageIndex;
        end;
      end
      else
      begin
        DisplayText := Rec.FileName;
        if ShowGenuineFileOnly1.Checked then
          ShowIt := (Rec.ImageIndex = 1)
        else if ShowMismatchedFileOnly1.Checked then
          ShowIt := (Rec.ImageIndex = 2)
        else if ShowMissingOnly1.Checked then
          ShowIt := (Rec.ImageIndex = 3)
        else
          ShowIt := True;
      end;

      if not ShowIt then
        Continue;

      Item := QCListView1.Items.Add;

      if Rec.IsSummary then
      begin
        Item.Caption := Rec.Serial;
        Item.SubItems.Add(DisplayText);
        Item.SubItems.Add('');
        Item.SubItems.Add('');
        Item.SubItems.Add('');
        Item.ImageIndex := SummaryImageIndex;
      end
      else
      begin
        Item.Caption := Rec.Serial;
        Item.SubItems.Add(DisplayText);
        Item.SubItems.Add(Rec.SizeStr);
        Item.SubItems.Add(Rec.Status);
        Item.SubItems.Add(Rec.Description);
        Item.ImageIndex := Rec.ImageIndex;
      end;

      if Rec.FullPath <> '' then
        Item.Data := Pointer(StrNew(PChar(Rec.FullPath)));
    end;
  finally
    QCListView1.Items.EndUpdate;
  end;
end;


procedure THashChecksum.ShowAll1Click(Sender: TObject);
begin
  SetFilterToogle(ShowAll1);
  ApplyFilter;
end;

procedure THashChecksum.ShowGenuineFileOnly1Click(Sender: TObject);
begin
  SetFilterToogle(ShowGenuineFileOnly1);
  ApplyFilter;
end;

procedure THashChecksum.ShowMismatchedFileOnly1Click(Sender: TObject);
begin
  SetFilterToogle(ShowMismatchedFileOnly1);
  ApplyFilter;
end;

procedure THashChecksum.ShowMissingOnly1Click(Sender: TObject);
begin
  SetFilterToogle(ShowMissingOnly1);
  ApplyFilter;
end;


procedure THashChecksum.StartingQCFileChecsum(MDChecksumPath: string);
begin
  QCMDHashChecksmProc(MDChecksumPath);
end;

procedure THashChecksum.StopTasks1Click(Sender: TObject);
begin
  CancledByUser;
    TaskbarControll.ProgressState:=TTaskbarProgressState.Error;
end;

procedure THashChecksum.WMDropFiles(var Msg: TWMDropFiles);
var
  FileName: array[0..MAX_PATH] of Char;
  DroppedFile, Ext: string;
begin
  if DragQueryFile(Msg.Drop, 0, FileName, MAX_PATH) > 0 then
  begin
    DroppedFile := FileName;
    Ext := LowerCase(ExtractFileExt(DroppedFile));
    if MatchText(Ext, ChecksumExtQC) then
    begin
      if FScanning then
      begin
        FPendingDropFile := DroppedFile;
        CancledByUser;
      end
      else
      begin
        DetectedChecksumFileName := ExtractFilePath(DroppedFile);
        StartingQCFileChecsum(DroppedFile);
        Self.Caption := DroppedFile;
      end;
    end;
  end;
  DragFinish(Msg.Drop);
end;

end.


