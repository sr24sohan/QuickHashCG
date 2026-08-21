program QCheckify;
uses
  Vcl.Forms,
  Windows,
  SysUtils,
  uQCEngine in 'Units\Units_Helper\uQCEngine.pas',
  CRCArraysTable in 'Units\Units_Helper\CRCArraysTable.pas',
  uResourceProtector in 'Units\Units_Helper\uResourceProtector.pas',
  QCUnit1 in 'Units\Checkify\QCUnit1.pas' {HashChecksum},
  uStrings in 'Units\Units_Helper\uStrings.pas';

{$R '_Libraries\ResCheckify.res'}
// {$R '_Libraries\Chekcsum.res'}



const
FormResources: array[0..0] of record Name: string; Hash: string; ResType: PChar; end = (
  (Name: 'THashChecksum';     Hash: '2FE84DAE3F945122B1439F2DE1EEB2EC'; ResType: RT_RCDATA) );

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
  Application.Title := MY_APP_NAME_CHECKIFY;
  Application.CreateForm(THashChecksum, HashChecksum);
  Application.Run;
end.
