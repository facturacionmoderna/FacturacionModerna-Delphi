object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 227
  ClientWidth = 559
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Edit1: TEdit
    Left = 24
    Top = 40
    Width = 369
    Height = 21
    TabOrder = 0
    Text = 'C:\FacturacionModernaDelphi\ejemplos\ejemploTimbradoLayout'
  end
  object Button1: TButton
    Left = 416
    Top = 38
    Width = 97
    Height = 25
    Caption = 'Timbrar Layout'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 24
    Top = 128
    Width = 369
    Height = 21
    TabOrder = 2
    Text = '5729175F-47BE-4881-8AE8-5892F624F99F'
  end
  object Button2: TButton
    Left = 416
    Top = 126
    Width = 97
    Height = 25
    Caption = 'Cancelar UUID'
    TabOrder = 3
    OnClick = Button2Click
  end
end
