program QGenify;
uses
  Vcl.Forms,
  SysUtils,
  Windows,
  uQGHelper in 'Units\Units_Helper\uQGHelper.pas',
  uResourceProtector in 'Units\Units_Helper\uResourceProtector.pas',
  CRCArraysTable in 'Units\Units_Helper\CRCArraysTable.pas',
  QCHashGen in 'Units\Genify\QCHashGen.pas' {HashGenFrm1},
  uQCEngine in 'Units\Units_Helper\uQCEngine.pas',
  uNumericInput in 'Units\Units_Helper\uNumericInput.pas',
  uAbout in 'Units\Genify\uAbout.pas' {About},
  uBorderlessWindow in 'Units\Units_Helper\uBorderlessWindow.pas',
  uStrings in 'Units\Units_Helper\uStrings.pas',
  uResourceBuilder in 'Units\Units_Helper\uResourceBuilder.pas';

{$R '_Libraries\ResGenify.res'}

var
  MutexHandle: THandle;
  procedure CheckSingleInstanceQuickHashGen;
  begin
      MutexHandle := CreateMutex(nil, True, 'srstudiobd.QuickHashGenify');
  if (MutexHandle = 0) or (GetLastError = ERROR_ALREADY_EXISTS) then
  begin
    application.MessageBox('Application is already running.', 'Quick Hash Genify', MB_ICONINFORMATION or MB_OK);
    halt(2);
  end;
  end;


const
FormResources: array[0..2] of record Name: string; Hash: string; ResType: PChar; end = (
    (Name: 'GENIFY'; Hash:       '99696A0ECFB5DF5DBA959CFB08202570'; ResType: 'PNG'),
    (Name: 'THashGenFrm1'; Hash: 'C25C1669B945C8B3A31E23D342359961'; ResType: RT_RCDATA)
  , (Name: 'TAbout';     Hash:   '8C0A4DE48461D541A2988EA1A001F934'; ResType: RT_RCDATA)
);



procedure CheckFormsIntegrity;
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
  CheckFormsIntegrity;
  CheckSingleInstanceQuickHashGen;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
   Application.Title := MY_APP_NAME_GENIFY;
  Application.CreateForm(THashGenFrm1, HashGenFrm1);
  Application.Run;
end.
