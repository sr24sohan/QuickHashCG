unit uNumericInput;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Samples.Spin;

function NumericInputBox(const ACaption, APrompt, ADefault: string;
  AOwner: TForm): string;

implementation

type
  TKeyFilter = class(TObject)
    procedure OnlyNumericKeyPress(Sender: TObject; var Key: Char);
  end;

procedure TKeyFilter.OnlyNumericKeyPress(Sender: TObject; var Key: Char);
var
  E: TSpinEdit;
  S: string;
  Value: Integer;
  SelStart, SelLength: Integer;
begin
  E := TSpinEdit(Sender);

  // Backspace
  if Key = #8 then
    Exit;

  // Only numbers allowed
 if not CharInSet(Key, ['0'..'9']) then
begin
  Key := #0;
  Exit;
end;

  // Build the text as it will appear after this key is entered
  S := E.Text;

  SelStart := E.SelStart;
  SelLength := E.SelLength;

  Delete(S, SelStart + 1, SelLength);
  Insert(Key, S, SelStart + 1);

  // Prevent values greater than 15
  if (S <> '') and TryStrToInt(S, Value) then
  begin
    if Value > 15 then
      Key := #0;
  end;
end;

function NumericInputBox(const ACaption, APrompt, ADefault: string;
  AOwner: TForm): string;
var
  F: TForm;
  E: TSpinEdit;
  L: TLabel;
  BtnOK, BtnCancel: TButton;
  KeyFilter: TKeyFilter;
  DefaultValue: Integer;
begin
  Result := ADefault;
  KeyFilter := TKeyFilter.Create;

  F := TForm.CreateNew(nil);
  try
    with F do
    begin
      BorderStyle := bsSingle;
      BorderIcons := [];
      Caption := ACaption;
      Icon.Assign(Application.Icon);
      Position := poMainFormCenter;
      Width := 350;
      Color := clWhite;
      Height := 140;
      KeyPreview := True;


    end;

    // Center relative to owner form
    if Assigned(AOwner) then
    begin
      F.Left := AOwner.Left + (AOwner.Width - F.Width) div 2;
      F.Top := AOwner.Top + (AOwner.Height - F.Height) div 2;
    end
    else
      F.Position := poScreenCenter;

    // Label
    L := TLabel.Create(F);
    with L do
    begin
      Parent := F;
      Left := 10;
      Top := 8;
      Width := 320;
      Height := 20;
      Caption := APrompt;
    end;

    // Numeric SpinEdit
    E := TSpinEdit.Create(F);
    with E do
    begin
      Parent := F;
      Left := 10;
      Top := 30;
      Width := 315;
      Height := 24;

      MinValue := 0;
      MaxValue := 15;

      // Make sure default value is valid
      if TryStrToInt(ADefault, DefaultValue) then
      begin
        if DefaultValue < 0 then
          DefaultValue := 0
        else if DefaultValue > 15 then
          DefaultValue := 15;

        Value := DefaultValue;
      end
      else
        Value := 0;

      OnKeyPress := KeyFilter.OnlyNumericKeyPress;
    end;

    // OK / Set button
    BtnOK := TButton.Create(F);
    with BtnOK do
    begin
      Parent := F;
      Caption := 'Set';
      ModalResult := mrOk;
      Left := 160;
      Top := 62;
      Width := 80;
      Height := 28;
      Default := True;
    end;

    // Cancel button
    BtnCancel := TButton.Create(F);
    with BtnCancel do
    begin
      Parent := F;
      Caption := 'Cancel';
      ModalResult := mrCancel;
      Left := 245;
      Top := 62;
      Width := 80;
      Height := 28;
      Cancel := True;
    end;

    F.ActiveControl := E;

    if F.ShowModal = mrOk then
      Result := Trim(E.Text);

  finally
    KeyFilter.Free;
    F.Free;
  end;
end;

end.
