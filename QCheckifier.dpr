program QCheckifier;

uses
  Vcl.Forms, Windows, SysUtils,
  CRCArraysTable in 'Units\Units_Helper\CRCArraysTable.pas',
  uStrings in 'Units\Units_Helper\uStrings.pas',
  uQCEngine in 'Units\Units_Helper\uQCEngine.pas',
  uResourceProtector in 'Units\Units_Helper\uResourceProtector.pas',
  uCheckifier in 'Units\Checkifier\uCheckifier.pas' {Checkifier};


{$R '_Libraries\ResCheckifier.res'}


const
FormResources: array[0..1] of record Name: string; Hash: string; ResType: PChar; end = (
  (Name: 'TCheckifier';       Hash: '0F1F0EF488F378BA574817862CC05C53'; ResType: RT_RCDATA),
  (Name: '1';                 Hash: '75D9F4BDED889D3C004DB7177BA5D583'; ResType: RT_VERSION)
   );

procedure CheckFormsHashIntegrity;
var i: Integer; ActualHash: string; MyExeName: string;
begin
   MyExeName := ExtractFileName(ParamStr(0));
  for i := 0 to High(FormResources) do
  begin
    ActualHash := CalculateUniversalResourceHash(FormResources[i].Name, FormResources[i].ResType);
    if (ActualHash = 'ERROR') or (not SameText(ActualHash, FormResources[i].Hash)) then
    begin
     MessageBoxW(Application.Handle, PWideChar('The application was unable to start correctly (0xC0000005).' + sLineBreak + 'Click OK to close the application.'),  PWideChar(MyExeName + ' - Application Error'), MB_OK or MB_ICONERROR or MB_TOPMOST);
     Halt(1);
    end;
  end;
end;



begin
  CheckFormsHashIntegrity;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TCheckifier, Checkifier);
  Application.Run;
end.
