unit uAbout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  uBorderlessWindow,  Vcl.Controls, Vcl.Forms, ShellAPI, VCL.Imaging.pngimage, Vcl.Imaging.jpeg,
  Vcl.Imaging.GIFImg, Vcl.ImageCollection, Vcl.VirtualImageList, Vcl.Buttons, Vcl.BaseImageCollection,
  System.ImageList, Vcl.ImgList,Vcl.ExtCtrls, Vcl.StdCtrls;


type
  TAbout = class(TForm)
    AppLogo: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    VirtualImageList1: TVirtualImageList;
    ImageCollection1: TImageCollection;
    btnFacebook: TSpeedButton;
    btnYoutube: TSpeedButton;
    btnGithub: TSpeedButton;
    btnWhatsapp: TSpeedButton;
    btnWebsite: TSpeedButton;
    procedure DEFAULT_WINDOW(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClick(Sender: TObject);
    procedure btnWebsiteClick(Sender: TObject);
    procedure btnFacebookClick(Sender: TObject);
    procedure btnGithubClick(Sender: TObject);
    procedure btnYoutubeClick(Sender: TObject);
    procedure btnWhatsappClick(Sender: TObject);
  private
   FBorderless: TBorderlessWindow;
   procedure GettingReadyUI;


  end;

var
    About: TAbout;

procedure LoadFromResources(const ResName: string; Image: TImage); overload;
procedure LoadFromResources(const ResName: string; ResType: PChar; Image: TImage); overload;
procedure LoadFromResources(ResID: Integer; ResType: PChar; Image: TImage); overload;
procedure LoadFromResources(ResID: Integer; Image: TImage); overload;
implementation

{$R *.dfm}


function DetectGraphicClass(Stream: TStream): TGraphicClass;
var Buf: array[0..7] of Byte; OldPos: Int64; ReadCount: Integer;
begin
  Result := nil;
  if (Stream = nil) or (Stream.Size < 4) then  Exit;
  OldPos := Stream.Position;
  try
    Stream.Position := 0;
    FillChar(Buf, SizeOf(Buf), 0);
    ReadCount := Stream.Read(Buf, SizeOf(Buf));
    if ReadCount < 4 then   Exit;

    if (Buf[0] = $89) and (Buf[1] = $50) and (Buf[2] = $4E) and (Buf[3] = $47) then
      Result := TPngImage                                  // PNG
    else if (Buf[0] = $FF) and (Buf[1] = $D8) then
      Result := TJPEGImage                                 // JPEG
    else if (Buf[0] = Ord('B')) and (Buf[1] = Ord('M')) then
      Result := TBitmap                                    // BMP
    else if (Buf[0] = Ord('G')) and (Buf[1] = Ord('I')) and (Buf[2] = Ord('F')) then
      Result := TGIFImage                                  // GIF
    else if (Buf[0] = 0) and (Buf[1] = 0) and (Buf[2] = 1) and (Buf[3] = 0) then
      Result := TIcon;                                     // ICO
  finally
    Stream.Position := OldPos;
  end;
end;
procedure InternalLoadFromResource(Instance: HMODULE; ResName: PChar;
  ResType: PChar; Image: TImage);
var  RS: TResourceStream; GraphicClass: TGraphicClass; Graphic: TGraphic;
begin
  if Image = nil then Exit;
  if FindResource(Instance, ResName, ResType) = 0 then Exit;
  RS := nil;
  Graphic := nil;
  try
    try
      RS := TResourceStream.Create(Instance, ResName, ResType);
      GraphicClass := DetectGraphicClass(RS);
      if GraphicClass = nil then Exit;
      Graphic := GraphicClass.Create;
      Graphic.LoadFromStream(RS);
      Image.Picture.Graphic := Graphic;
    except
    end;
  finally
    Graphic.Free;
    RS.Free;
  end;
end;


procedure LoadFromResources(const ResName: string; Image: TImage);
begin
  InternalLoadFromResource(HInstance, PChar(ResName), 'PNG', Image);
end;

procedure LoadFromResources(const ResName: string; ResType: PChar; Image: TImage);
begin
  InternalLoadFromResource(HInstance, PChar(ResName), ResType, Image);
end;

procedure LoadFromResources(ResID: Integer; ResType: PChar; Image: TImage);
begin
  InternalLoadFromResource(HInstance, PChar(ResID), ResType, Image);
end;

procedure LoadFromResources(ResID: Integer; Image: TImage);
begin
  InternalLoadFromResource(HInstance, PChar(ResID), 'PNG', Image);
end;
procedure OpenUrlAuthorSite(SiteUrl: string);
begin
  SiteUrl := StringReplace(SiteUrl, '"', '%22', [rfReplaceAll]);
  SiteUrl := StringReplace(SiteUrl, ' ', '%20', [rfReplaceAll]);
  ShellExecute(0, 'open', PChar(SiteUrl), nil, nil, SW_SHOWNORMAL);
end;


procedure TAbout.btnFacebookClick(Sender: TObject);
begin
   OpenUrlAuthorSite('https://www.facebook.com/sr24.sohan')
end;

procedure TAbout.btnGithubClick(Sender: TObject);
begin
OpenUrlAuthorSite('https://github.com/sr24sohan')
end;

procedure TAbout.btnWebsiteClick(Sender: TObject);
begin
OpenUrlAuthorSite('https://srstudio24.blogspot.com/')
end;

procedure TAbout.btnWhatsappClick(Sender: TObject);
begin
 OpenUrlAuthorSite('http://wa.me/+8801408712154');
end;

procedure TAbout.btnYoutubeClick(Sender: TObject);
begin
     OpenUrlAuthorSite('https://www.youtube.com/@srstudio24');
end;

procedure TAbout.DEFAULT_WINDOW(Sender: TObject);
begin
FBorderless := TBorderlessWindow.Create(Self);
FBorderless.BorderWidth := 6;
GettingReadyUI;
end;


procedure TAbout.FormClick(Sender: TObject);
begin
 Close;
end;

procedure TAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action := caFree;
  About := nil;
end;

procedure TAbout.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then  Close;
end;

procedure TAbout.GettingReadyUI;
begin

         Height:=200;
         Width:=300;
         Position:=poMainFormCenter;
         Color:= clWhite ; //$00FFFCF7;
         BorderIcons:=[TBorderIcon.biSystemMenu];
         BorderStyle:=bsSingle;
         Caption:='About';
      //   Label1.Caption:='MY_APP_NAME';
      //   Label2.Caption:='Version: Edition';
         LoadFromResources('GENIFY', 'PNG', AppLogo);




end;

end.
