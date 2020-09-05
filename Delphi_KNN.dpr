program Delphi_KNN;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FrmMain},
  UKNN in 'UKNN.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFrmMain, FrmMain);
  Application.Run;
end.
