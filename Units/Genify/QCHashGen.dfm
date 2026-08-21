object HashGenFrm1: THashGenFrm1
  Left = 0
  Top = 0
  ClientHeight = 352
  ClientWidth = 644
  Color = clWhite
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu1
  Position = poDesktopCenter
  ShowInTaskBar = True
  OnCreate = Default
  OnDestroy = SaveQGenify
  OnResize = FormResize
  TextHeight = 15
  object GroupBox1: TGroupBox
    AlignWithMargins = True
    Left = 2
    Top = 332
    Width = 640
    Height = 20
    Margins.Left = 2
    Margins.Top = 0
    Margins.Right = 2
    Margins.Bottom = 0
    Align = alBottom
    ShowFrame = False
    TabOrder = 0
    Visible = False
    DesignSize = (
      640
      20)
    object Label1: TLabel
      Left = 2
      Top = 2
      Width = 115
      Height = 15
      Caption = 'Current File Progress: '
    end
    object QCLabelParcent: TLabel
      Left = 430
      Top = 2
      Width = 16
      Height = 15
      Anchors = [akLeft, akBottom]
      Caption = '0%'
    end
    object Label2: TLabel
      Left = 340
      Top = 2
      Width = 85
      Height = 15
      Anchors = [akLeft, akBottom]
      Caption = 'Overall Progress'
    end
    object CurrenntFileProg1: TLabel
      Left = 118
      Top = 2
      Width = 16
      Height = 15
      Caption = '0%'
    end
    object ProgressBar1: TProgressBar
      Left = 474
      Top = 3
      Width = 157
      Height = 12
      Anchors = [akLeft, akRight, akBottom]
      Smooth = True
      TabOrder = 0
    end
    object ProgressBar2: TProgressBar
      Left = 150
      Top = 3
      Width = 180
      Height = 12
      TabOrder = 1
    end
  end
  object QCListView1: TListView
    AlignWithMargins = True
    Left = 0
    Top = 3
    Width = 644
    Height = 329
    Margins.Left = 0
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alClient
    BorderStyle = bsNone
    Color = clWhite
    Columns = <>
    ColumnClick = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Segoe UI'
    Font.Style = []
    FlatScrollBars = True
    GridLines = True
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    ParentShowHint = False
    PopupMenu = PopupMenu1
    ShowWorkAreas = True
    ShowHint = False
    TabOrder = 1
    ViewStyle = vsReport
    OnCustomDrawItem = QCListView1CustomDrawItem
    OnCustomDrawSubItem = QCListView1CustomDrawSubItem
    OnMouseDown = QCListView1MouseDown
  end
  object MainMenu1: TMainMenu
    Left = 146
    Top = 50
    object File1: TMenuItem
      Caption = 'File'
      object ChooseFiles: TMenuItem
        Caption = 'Choose Files'
        ShortCut = 16463
        OnClick = ChooseFilesClick
      end
      object ChooseFolder1: TMenuItem
        Caption = 'Choose Folder'
        ShortCut = 49231
        OnClick = ChooseFolder1Click
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object SelectAll1: TMenuItem
        Caption = 'Select All'
        ShortCut = 16449
        OnClick = SelectAll1Click
      end
      object RemoveSelected1: TMenuItem
        Caption = 'Remove Selected'
        ShortCut = 46
        OnClick = RemoveSelected1Click
      end
      object RemoveAll: TMenuItem
        Caption = 'Remove All'
        ShortCut = 16452
        OnClick = RemoveAllClick
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object SaveHash: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
        OnClick = SaveHashClick
      end
      object SaveAs1: TMenuItem
        Caption = 'Save As'
        ShortCut = 49235
        OnClick = SaveAs1Click
      end
      object SaveHashEachFile1: TMenuItem
        Caption = 'Save Hash for Each File'
        ShortCut = 24659
        OnClick = SaveHashEachFile1Click
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object ExporttoCheckifier1: TMenuItem
        Caption = 'Export to Checkifier'
        ShortCut = 57427
        OnClick = ExporttoCheckifier1Click
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Caption = 'Exit'
        ShortCut = 32883
        OnClick = Exit1Click
      end
    end
    object Generate1: TMenuItem
      Caption = 'Tasks'
      object GenerateHash1: TMenuItem
        Caption = 'Generate Hash'
        ShortCut = 13
        OnClick = GenerateHash1Click
      end
      object ReGenerateHash1: TMenuItem
        Caption = 'Re-Generate Hash'
        ShortCut = 16397
        OnClick = ReGenerateHash1Click
      end
      object StopHashGeneration1: TMenuItem
        Caption = 'Stop Hash Generation'
        Enabled = False
        ShortCut = 27
        OnClick = StopHashGeneration1Click
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object SetRootPathDepth1: TMenuItem
        Caption = 'Set Root Path Depth'
        OnClick = SetRootPathDepth1Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object ClearAllHash: TMenuItem
        Caption = 'Clear All Hash'
        ShortCut = 24608
        OnClick = ClearAllHashClick
      end
    end
    object HashType1: TMenuItem
      Caption = 'Hash Type'
      object Checkbox0CRC: TMenuItem
        Caption = 'CRC32'
        OnClick = ChoosingHashType
      end
      object CheckBox1MD5: TMenuItem
        Caption = 'MD5'
        OnClick = ChoosingHashType
      end
      object CheckBox2SHA1: TMenuItem
        Caption = 'SHA1'
        OnClick = ChoosingHashType
      end
      object CheckBox3SHA256: TMenuItem
        Caption = 'SHA256'
        OnClick = ChoosingHashType
      end
      object CheckBox4SHA384: TMenuItem
        Caption = 'SHA384'
        OnClick = CheckBox4SHA384Click
      end
      object CheckBox5SHA512: TMenuItem
        Caption = 'SHA512'
        OnClick = CheckBox5SHA512Click
      end
    end
    object Options1: TMenuItem
      Caption = 'Help'
      object WhatsNew1: TMenuItem
        Caption = 'What'#39's New'
        OnClick = WhatsNew1Click
      end
      object About1: TMenuItem
        Caption = '&About'
        OnClick = About1Click
      end
    end
  end
  object PopupMenu1: TPopupMenu
    OnPopup = PopupMenu1Popup
    Left = 50
    Top = 48
    object Refresh1: TMenuItem
      Caption = 'Refresh'
      ShortCut = 116
      OnClick = RefreshList1Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object ShowInExplorerMenu: TMenuItem
      Caption = 'Show in Explorer'
      ShortCut = 16453
      OnClick = ShowInExplorerMenuClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object CopyHash1: TMenuItem
      Caption = 'Copy Hash Only'
      ShortCut = 16451
      OnClick = CopyHash1Click
    end
    object CopyHashwithFilename1: TMenuItem
      Caption = 'Copy Hash Format'
      OnClick = CopyHashwithFilename1Click
    end
    object N8: TMenuItem
      Caption = '-'
    end
    object Cancel1: TMenuItem
      Caption = 'Close'
    end
  end
  object TaskbarControll: TTaskbar
    TaskBarButtons = <>
    ProgressState = Normal
    TabProperties = []
    Left = 242
    Top = 120
  end
end
