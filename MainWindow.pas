unit MainWindow;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, AthleticMan, Vcl.StdCtrls;

type
  TMyForm = class(TForm)
    btnStart: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
  private
    Man: TJumpingMan;
  public
    { Public declarations }
  end;

var
  MyForm: TMyForm;

implementation

{$R *.dfm}


procedure TMyForm.btnStartClick(Sender: TObject);
begin
  Man.Greeting;
  Man.RunUp;
  Man.Jump;
end;

procedure TMyForm.FormCreate(Sender: TObject);
begin
  Man := TJumpingMan.Create(Self);
  Man.SetPosition(200, 400);
  Man.Scale := 2.0;
end;

procedure TMyForm.FormPaint(Sender: TObject);
begin
  Man.Draw;
  Man.BeginSun;
  Man.SandboxAndTrek;
end;

Initialization

end.
