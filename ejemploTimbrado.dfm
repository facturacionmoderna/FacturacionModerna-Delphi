object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 403
  ClientWidth = 492
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
    Width = 361
    Height = 21
    TabOrder = 0
    Text = '--- Buscar archivo xml ---'
  end
  object Button1: TButton
    Left = 24
    Top = 203
    Width = 443
    Height = 46
    Caption = 'Timbrar Layout'
    TabOrder = 1
    OnClick = Button1Click
  end
  object Edit2: TEdit
    Left = 24
    Top = 312
    Width = 443
    Height = 21
    TabOrder = 2
    Text = '5729175F-47BE-4881-8AE8-5892F624F99F'
  end
  object Button2: TButton
    Left = 24
    Top = 339
    Width = 443
    Height = 44
    Caption = 'Cancelar UUID'
    TabOrder = 3
    OnClick = Button2Click
  end
  object CheckBox1: TCheckBox
    Left = 24
    Top = 17
    Width = 161
    Height = 17
    Caption = 'Timbrar Xml de retenciones'
    TabOrder = 4
  end
  object Edit3: TEdit
    Left = 24
    Top = 176
    Width = 361
    Height = 21
    TabOrder = 5
    Text = '--- Buscar archivo layout---'
  end
  object Button5: TButton
    Left = 24
    Top = 67
    Width = 443
    Height = 52
    Caption = 'Timbrar Xml'
    TabOrder = 6
    OnClick = Button5Click
  end
  object Button3: TButton
    Left = 384
    Top = 38
    Width = 83
    Height = 25
    Caption = 'Examinar'
    TabOrder = 7
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 384
    Top = 174
    Width = 83
    Height = 25
    Caption = 'Examinar'
    TabOrder = 8
    OnClick = Button4Click
  end
end
