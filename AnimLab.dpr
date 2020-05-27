program AnimLab;

uses
  Vcl.Forms,
  MainWindow in 'MainWindow.pas' {MyForm},
  AthleticMan in 'AthleticMan.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMyForm, MyForm);
  Application.Run;
end.
