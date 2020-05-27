unit AthleticMan;

interface

uses
  Vcl.ExtCtrls, Vcl.Graphics, System.Classes, System.Types, Vcl.Controls, Vcl.Forms;

const
  INTERVAL = 50;
  IntervalForSun = 1500;

type
  TPartsOfMan = (
    ptShoulderLeft, ptShoulderRight,
    ptArmLeft, ptArmRight,
    ptLegLeft, ptLegRight,
    ptHipLeft, pthipright,
    ptBody, ptNeck, ptHead, ptFull, ptSun);

  TState = record
    Angle: Real;
    Size:  Real;
    DelayNum, Num: Integer;
    DeltaAngle: Real;
    DeltaSize: Integer;
  end;

  TNodeP = ^TNode;
  TNode = record
    Data: TState;
    Next: TNodeP;
  end;

  TList = class
  private
    FHead, FTail: TNodeP;
    FSize: Integer;
    function GetFront: TState;
    function GetBack: TState;
  public
    constructor Create;
    destructor Destroy;
    function Empty: Boolean;
    procedure PopFront;
    procedure PushBack(const Node: TState);
    property Front: TState read GetFront;
    property Back: TState read GetBack;
  end;

  TPart = record
    Angle: Real;
    Size: Real;
    DelayNum, Num: Integer;
    DeltaAngle: Real;
    DeltaSize: Integer;
    Queue: TList;
    constructor Create(const AAngle: Real; const ASize: Real);
    procedure UpdateValue;
  end;

  TPartP = ^TPart;

  TJumpingMan = class(TComponent)
  private
    FOwner: TForm;                                  // Форма, на которой располагается
    FCanvas: TCanvas;
    FLeft, FTop: Integer;                           // Позиция соединения шеи с плечами
    FScale: Real;                                   // Масштаб
    FTimer: TTimer;
    FSunTimer: TTimer;

    FShoulderLeft, FShoulderRight: TPart;           // Плечи
    FArmLeft, FArmRight: TPart;                     // Предплечья
    FLegLeft, FLegRight: TPart;                     // Голень
    FHipLeft, FHipRight: TPart;                     // Бедра
    FBody: TPart;                                   // Тело
    FNeck: TPart;                                   // Шея
    FHead: TPart;                                   // Голова
    FFull: TPart;
    FSun: TPart;

    function GetPoint(const Start: TPoint; const APart: TPart): TPoint;
    procedure DrawLine(const AStart, AFinish: TPoint);
    procedure DrawCircle(const ACenter: TPoint; ASize: Integer);
    procedure ReDraw;
    procedure tmrUpdate(Sender: TObject);
    function DeterminePart(APart: TPartsOfMan): TPartP;
    function GetLastState(const APart: TPart): TState;
  public
    constructor Create(AOwner: TForm);
    destructor Destroy;

    procedure SetPosition(const X, Y: Integer);

    procedure Draw;
    procedure MovePartByAngle(APart: TPartsOfMan; AAngle: Real; ADelay: Integer = 0; ATime: Integer = INTERVAL);
    procedure MovePartBySize(APart: TPartsOfMan; ASize: Real; ADelay: Integer = 0; ATime: Integer = INTERVAL);
    procedure MovePart(APart: TPartsOfMan; AAngle: Real; ASize: Real; ADelay: Integer = 0; ATime: Integer = INTERVAL);
    procedure Jump;
    procedure Greeting;
    procedure RunUp;

    procedure UpdateValues;

    property Left: Integer read FLeft;
    property Top: Integer read FTop;
    property Scale: Real read FScale write FScale;

    procedure Background;
  end;


function Rad(const AAngle: Integer): Real;

implementation

uses
   MainWindow;

function Rad(const AAngle: Integer): Real;
begin
  Result := AAngle / 180 * Pi;
end;


procedure TJumpingMan.Background;
var
  i, ty, sx, sy: Integer;
begin
  ty := 735;
  FCanvas.Brush.Color := clMaroon;
  FCanvas.Pen.Color := clBlack;
  FCanvas.Rectangle(0, ty + 60, 10000, ty + 70);
  FCanvas.Rectangle(0, ty + 15, 10000, ty + 25);
  FCanvas.Brush.Color := clOlive;
  FCanvas.Rectangle(0, ty + 24, 10000, ty + 61);
  FCanvas.Brush.Style := bsClear;
  FCanvas.Pen.Color := clBlack;

  sx := 55;
  sy := 55;
  FCanvas.Brush.Color := clYellow;
  FCanvas.Pen.Color := clRed;
  FCanvas.Ellipse(sx, sy, sx + 100,sy + 100);
  FCanvas.MoveTo(sx + 95, sy + 95);
  FCanvas.LineTo(sx + 130, sy + 130);
  FCanvas.MoveTo(sx + 5, sy + 5);
  FCanvas.LineTo(sx - 30, sy - 30);
  FCanvas.MoveTo(sx + 5, sy + 95);
  FCanvas.LineTo(sx - 30, sy + 130);
  FCanvas.MoveTo(sx + 95, sy + 5);
  FCanvas.LineTo(sx + 130, sy - 30);
  FCanvas.MoveTo(sx + 50, sy - 5);
  FCanvas.LineTo(sx + 50, sy - 50);
  FCanvas.MoveTo(sx + 50, sy + 105);
  FCanvas.LineTo(sx + 50, sy + 150);
  FCanvas.MoveTo(sx + 105, sy + 50);
  FCanvas.LineTo(sx + 150, sy + 50);
  FCanvas.MoveTo(sx - 5, sy + 50);
  FCanvas.LineTo(sx - 50, sy + 50);
  FCanvas.Pen.Color := clBlack;
  FCanvas.Brush.Style := bsClear;
end;


{ TJumpingMan }

function TJumpingMan.GetLastState(const APart: TPart): TState;
begin
  if APart.Queue.Empty then
  begin
    Result.Angle := APart.Angle;
    Result.Size := APart.Size;
    Result.DelayNum := APart.DelayNum;
    Result.Num := APart.Num;
    Result.DeltaAngle := Apart.DeltaAngle;
    Result.DeltaSize := Apart.DeltaSize;
  end
  else Result := APart.Queue.Back;
end;

function TJumpingMan.GetPoint(const Start: TPoint; const APart: TPart): TPoint;
begin
  Result.X := Round(Start.X + APart.Size * FScale * Cos(APart.Angle));
  Result.Y := Round(Start.Y + APart.Size * FScale * -Sin(APart.Angle));
end;

procedure TJumpingMan.tmrUpdate(Sender: TObject);
var
  Tmp: TJumpingMan;
begin
  if not (Sender is TTimer) then Exit;
  if not (TTimer(Sender).Owner is TJumpingMan) then Exit;
  Tmp := TTimer(Sender).Owner as TJumpingMan;
  Tmp.UpdateValues;
  Tmp.ReDraw;
end;

procedure TJumpingMan.UpdateValues;
begin
  FHead.UpdateValue;
  FBody.UpdateValue;
  FNeck.UpdateValue;
  FShoulderLeft.UpdateValue;
  FShoulderRight.UpdateValue;
  FArmLeft.UpdateValue;
  FArmRight.UpdateValue;
  FHipLeft.UpdateValue;
  FHipRight.UpdateValue;
  FLegLeft.UpdateValue;
  FLegRight.UpdateValue;
  FFull.UpdateValue;
  FLeft := Round(FFull.Angle);
  FTOp := Round(FFull.Size);
end;

constructor TJumpingMan.Create(AOwner: TForm);
begin
  Inherited Create(AOwner);
  FOwner := AOwner;
  FCanvas := AOwner.Canvas;

  FTimer := TTimer.Create(Self);
  FTimer.Interval := INTERVAL;
  FTimer.Enabled := True;
  FTimer.OnTimer := tmrUpdate;

  FScale := 1.0;

  FSun.Create(100, 100);
  FBody.Create(Rad(270), 80);
  FNeck.Create(Rad(90), 20);
  FHead.Create(Rad(90), 30);
  FShoulderLeft.Create(Rad(250), 50);
  FShoulderRight.Create(Rad(290), 40);
  FArmLeft.Create(Rad(270), 50);
  FArmRight.Create(Rad(270), 45);
  FHipLeft.Create(Rad(280), 60);
  FHipRight.Create(Rad(310), 55);
  FLegLeft.Create(Rad(260), 60);
  FLegRight.Create(Rad(270), 55);
  FFull.Queue := TList.Create;
end;

destructor TJumpingMan.Destroy;
begin
  FSun.Queue.Free;
  FTimer.Free;
  FBody.Queue.Free;
  FNeck.Queue.Free;
  FHead.Queue.Free;
  FShoulderLeft.Queue.Free;
  FShoulderRight.Queue.Free;
  FArmLeft.Queue.Free;
  FArmRight.Queue.Free;
  FHipLeft.Queue.Free;
  FHipRight.Queue.Free;
  FLegLeft.Queue.Free;
  FLegRight.Queue.Free;
  FFull.Queue.Free;
  Inherited;
end;

function TJumpingMan.DeterminePart(APart: TPartsOfMan): TPartP;
begin
  case APart of
    ptShoulderLeft: Result := @FShoulderLeft;
    ptShoulderRight: Result := @FShoulderRight;
    ptArmLeft: Result := @FArmLeft;
    ptArmRight: Result := @FArmRight;
    ptLegLeft: Result := @FLegLeft;
    ptLegRight: Result := @FLegRight;
    ptHipLeft: Result := @FHipLeft;
    pthipright: Result := @FHipRight;
    ptBody: Result := @FBody;
    ptNeck: Result := @FNeck;
    ptHead: Result := @FHead;
    ptFull: Result := @FFull;
  end;
end;

procedure TJumpingMan.Draw;
var
  Now, Next: TPoint;
begin
  Now.Create(FLeft, FTop);

  // Neck and Head
  Next := GetPoint(Now, FNeck);
  DrawLine(Now, Next);
  DrawCircle(GetPoint(Next, FHead), Round(FHead.Size * FScale));

  // Left Arm
  Next := GetPoint(Now, FShoulderLeft);
  DrawLine(Now, Next);
  DrawLine(Next, GetPoint(Next, FArmLeft));

  // Right Arm
  Next := GetPoint(Now, FShoulderRight);
  DrawLine(Now, Next);
  DrawLine(Next, GetPoint(Next, FArmRight));

  // Body
  Next := GetPoint(Now, FBody);
  DrawLine(Now, Next);

  Now := Next;
  // Left Leg
  Next := GetPoint(Now, FHipLeft);
  DrawLine(Now, Next);
  DrawLine(Next, GetPoint(Next, FLegLeft));

  // Right Leg
  Next := GetPoint(Now, FHipRight);
  DrawLine(Now, Next);
  DrawLine(Next, GetPoint(Next, FLegRight));
end;

procedure TJumpingMan.DrawCircle(const ACenter: TPoint; ASize: Integer);
begin
  FCanvas.Ellipse(
    ACenter.X - ASize, ACenter.Y - ASize,
    ACenter.X + ASize, ACenter.Y + ASize);
end;

procedure TJumpingMan.DrawLine(const AStart, AFinish: TPoint);
begin
  FCanvas.MoveTo(AStart.X, AStart.Y);
  FCanvas.LineTo(AFinish.X, AFinish.Y);
end;

procedure TJumpingMan.Greeting;
begin
  MovePart(ptArmLeft, Rad(70), 50, 0, 1000);
  MovePart(ptShoulderLeft, Rad(180), 50, 0, 1000);
  MovePartByAngle(ptArmLeft, Rad(110), 0, 400);
  MovePartByAngle(ptArmLeft, Rad(70), 0, 400);
  MovePartByAngle(ptArmLeft, Rad(110), 0, 400);
  MovePart(ptShoulderLeft, Rad(250), 50, 1000, 1000);
  MovePart(ptArmLeft, Rad(270), 50, 0, 1000);
end;

procedure TJumpingMan.RunUp;
begin
  MovePart(ptArmLeft, Rad(180), 35, 400, 600);
  MovePart(ptArmRight, Rad(360), 35, 3500, 600);
  MovePart(ptShoulderLeft, Rad(180), 30, 400, 500);
  MovePart(ptShoulderRight, Rad(360), 30, 3500, 500);
  MovePart(ptArmLeft, Rad(135), 45, 50, 500);
  MovePart(ptArmRight, Rad(405), 50, 50, 500);
  MovePart(ptShoulderLeft, Rad(135), 40, 50, 400);
  MovePart(ptShoulderRight, Rad(405), 50, 50, 400);
  MovePartByAngle(ptHead, Rad(45), 4100, 1700);
  MovePartByAngle(ptBody, Rad(240), 4100, 1700);
  MovePartByAngle(ptNeck, Rad(60), 4100, 1700);
  MovePartByAngle(ptHipLeft, Rad(300), 4400, 1700);
  MovePartByAngle(ptHipRight, Rad(330), 4400, 1700);
  MovePartByAngle(ptLegleft, Rad(240), 4400, 1700);
  MovePartByAngle(ptLegright, Rad(250), 4400, 1700);
  MovePart(ptShoulderLeft, Rad(-140), 50, 500, 1200);
  MovePart(ptShoulderRight, Rad(215), 40, 450, 1200);
  MovePart(ptArmLeft, Rad(-140), 50, 500, 800);
  MovePart(ptArmRight, Rad(215), 45, 450, 900);
  MovePart(ptFull, 300, 500, 4100, 1700);
end;

procedure TJumpingMan.Jump;
begin
  MovePartByAngle(ptHipLeft, Rad(270), 60, 1000);
  MovePartByAngle(ptHipRight, Rad(290), 60, 1000);
  MovePartByAngle(ptLegLeft, Rad(260), 60, 1000);
  MovePartByAngle(ptLegRight, Rad(270), 60, 1000);
  MovePart(ptShoulderLeft, Rad(-15), 40, 80, 1000);
  MovePart(ptShoulderRight, Rad(360), 50, 80, 800);
  MovePart(ptArmLeft, Rad(-15), 45, 70, 1000);
  MovePart(ptArmRight, Rad(360), 50, 70, 800);
  MovePart(ptFull, 320, 480, 0, 1000);
  MovePart(ptFull, 520, 230, 0, 1800);
  MovePartByAngle(ptHipLeft, Rad(330), 60, 1800);
  MovePartByAngle(ptHipRight, Rad(350), 60, 1800);
  MovePart(ptFull, 600, 180, 0, 600);
  MovePart(ptFull, 680, 230, 0, 600);
  MovePart(ptFull, 880, 400, 0, 1800);
  MovePartByAngle(ptHipLeft, Rad(290), 610, 2000);
  MovePartByAngle(ptHipRight, Rad(310), 610, 2000);
  MovePartByAngle(ptLegLeft, Rad(290), 710, 1900);
  MovePartByAngle(ptLegRight, Rad(300), 710, 1900);
  MovePartByAngle(ptBody, Rad(260), 3600, 1800);
  MovePartByAngle(ptNeck, Rad(80), 3600, 1800);
  MovePartByAngle(ptHipLeft, Rad(350), 1100, 700);
  MovePartByAngle(ptHipRight, Rad(370), 1100, 700);
  MovePartByAngle(ptLegLeft, Rad(240), 1300, 700);
  MovePartByAngle(ptLegRight, Rad(250), 1300, 700);
  MovePartByAngle(ptBody, Rad(220), 300, 1200);
  MovePartByAngle(ptNeck, Rad(40), 300, 1200);
  MovePart(ptFull, 830, 600, 200, 1500);
  MovePart(ptFull, 840, 430, 0, 1500);
  MovePartByAngle(ptBody, Rad(270), 50, 1900);
  MovePartByAngle(ptNeck, Rad(90), 50, 1900);
  MovePart(ptShoulderLeft, Rad(-70), 50, 6000, 1600);
  MovePart(ptShoulderRight, Rad(260), 40, 6000, 1600);
  MovePart(ptArmLeft, Rad(-90), 50, 6000, 2000);
  MovePart(ptArmRight, Rad(270), 45, 6000, 2000);
  MovePartByAngle(ptHipLeft, Rad(280), 50, 1300);
  MovePartByAngle(ptHipRight, Rad(310), 50, 1300);
  MovePartByAngle(ptLegLeft, Rad(260), 50, 1300);
  MovePartByAngle(ptLegRight, Rad(270), 50, 1300);
  MovePartByAngle(ptHead, Rad(90), 7000, 1900);
end;

procedure TJumpingMan.MovePart(APart: TPartsOfMan; AAngle: Real;
  ASize: Real; ADelay: Integer; ATime: Integer);
var
  Tmp: TPartP;
  State, LastState: TState;
begin
  Tmp := DeterminePart(APart);
  LastState := GetLastState(Tmp^);
  State.Num := ATime div INTERVAL;
  State.DelayNum := ADelay div INTERVAL;
  State.DeltaAngle := (AAngle - LastState.Angle) / State.Num;
  State.DeltaSize := Round(ASize - LastState.Size) div State.Num;
  State.Angle := AAngle;
  State.Size := ASize;
  if Tmp^.Queue.Empty then
  begin
    Tmp^.Num := State.Num;
    Tmp^.DelayNum := State.DelayNum;
    Tmp^.DeltaAngle := State.DeltaAngle;
    Tmp^.DeltaSize := State.DeltaSize;
  end;
  Tmp^.Queue.PushBack(State);
end;

procedure TJumpingMan.MovePartByAngle(APart: TPartsOfMan; AAngle: Real; ADelay,
  ATime: Integer);
var
  Tmp: TPartP;
  LastState: TState;
begin
  Tmp := DeterminePart(APart);
  LastState := GetLastState(Tmp^);
  MovePart(APart, AAngle, LastState.Size, ADelay, ATime);
end;

procedure TJumpingMan.MovePartBySize(APart: TPartsOfMan; ASize: Real; ADelay,
  ATime: Integer);
var
  Tmp: TPartP;
  LastState: TState;
begin
  Tmp := DeterminePart(APart);
  LastState := GetLastState(Tmp^);
  MovePart(APart, LastState.Angle, ASize, ADelay, ATime);
end;

procedure TJumpingMan.ReDraw;
begin
  FOwner.Invalidate;
end;

procedure TJumpingMan.SetPosition(const X, Y: Integer);
begin
  FLeft := X;
  FTop := Y;
  FFull.Angle := X;
  FFull.Size := Y;
end;

{ TPart }

constructor TPart.Create(const AAngle: Real; const ASize: Real);
begin
  Angle := AAngle;
  Size := ASize;
  Num := 0;
  Queue := TList.Create;
end;

procedure TPart.UpdateValue;
var
  Tmp: TState;
begin
  if (DelayNum = 0) and (Num = 0) and (not Queue.Empty) then
  begin
    Queue.PopFront;
    if (not Queue.Empty) then
    begin
      Tmp := Queue.Front;
      DelayNum := Tmp.DelayNum;
      Num := Tmp.Num;
      DeltaAngle := Tmp.DeltaAngle;
      DeltaSize := Tmp.DeltaSize;
    end;
  end;
  if DelayNum > 0 then
    Dec(DelayNum)
  else
    if Num > 0 then
    begin
      Angle := Angle + DeltaAngle;
      Size := Size + DeltaSize;
      Dec(Num);
    end;
end;

{ TList }

constructor TList.Create;
begin
  New(FHead);
  FHead^.Next := Nil;
  FTail := FHead;
end;

destructor TList.Destroy;
begin
  while FTail <> nil do
  begin
    FTail := FHead^.Next;
    Dispose(FHead);
    FHead := FTail;
  end;
end;

function TList.Empty: Boolean;
begin
  Result := FSize = 0;
end;

function TList.GetBack: TState;
begin
  Result := FTail^.Data
end;

function TList.GetFront: TState;
begin
  Result := FHead^.Next^.Data
end;

procedure TList.PopFront;
var
  Tmp: TNodeP;
begin
  Tmp := FHead^.Next;
  if Tmp = FTail then
  begin
    FHead^.Next := nil;
    FTail := FHead;
  end
  else
    FHead^.Next := Tmp^.Next;
  Dispose(Tmp);
  Dec(FSize);
end;

procedure TList.PushBack(const Node: TState);
var
  Tmp: TNodeP;
begin
  New(Tmp);
  Tmp^.Data := Node;
  FTail^.Next := Tmp;
  FTail := Tmp;
  FTail^.Next := nil;
  Inc(FSize);
end;


initialization

end.
