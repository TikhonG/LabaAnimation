object MyForm: TMyForm
  Left = 0
  Top = 0
  Caption = 'What are you doing man?'
  ClientHeight = 730
  ClientWidth = 1200
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object btnStart: TButton
    Left = 1000
    Top = 600
    Width = 75
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnStartClick
  end
end
