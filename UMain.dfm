object FrmMain: TFrmMain
  Left = 0
  Top = 0
  Caption = 'Delphi K-NN example'
  ClientHeight = 373
  ClientWidth = 741
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 741
    Height = 49
    Align = alTop
    Caption = 'Financial Credit'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 0
  end
  object PageControl1: TPageControl
    Left = 0
    Top = 49
    Width = 741
    Height = 283
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 1
    object TabSheet1: TTabSheet
      Caption = 'Data to train'
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object DBGrid1: TDBGrid
        Left = 0
        Top = 73
        Width = 733
        Height = 182
        Align = alClient
        DataSource = dsCustomers
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -11
        TitleFont.Name = 'Tahoma'
        TitleFont.Style = []
        Columns = <
          item
            Expanded = False
            FieldName = 'Age'
            Width = 85
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'HiringTime'
            Title.Caption = 'HiringTime (years)'
            Width = 141
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Restrict'
            Title.Caption = 'Restrict?'
            Width = 86
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'Salary'
            Width = 105
            Visible = True
          end
          item
            Expanded = False
            FieldName = 'BillsOnTime'
            Title.Caption = 'Bills on time?'
            Width = 108
            Visible = True
          end
          item
            Color = clCream
            Expanded = False
            FieldName = 'GoodPayer'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            Title.Caption = 'Good payer? (Label)'
            Title.Font.Charset = DEFAULT_CHARSET
            Title.Font.Color = clNavy
            Title.Font.Height = -11
            Title.Font.Name = 'Tahoma'
            Title.Font.Style = [fsBold]
            Width = 127
            Visible = True
          end>
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 733
        Height = 73
        Align = alTop
        TabOrder = 1
        object Label5: TLabel
          Left = 16
          Top = 16
          Width = 83
          Height = 13
          Caption = 'Filter expression:'
        end
        object Filter: TEdit
          Left = 16
          Top = 32
          Width = 401
          Height = 21
          TabOrder = 0
          OnChange = FilterChange
          OnKeyDown = FilterKeyDown
        end
        object BtFilter: TButton
          Left = 431
          Top = 31
          Width = 75
          Height = 25
          Caption = 'Apply filter'
          TabOrder = 1
          OnClick = BtFilterClick
        end
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Credit test'
      ImageIndex = 1
      object Label1: TLabel
        Left = 24
        Top = 16
        Width = 19
        Height = 13
        Caption = 'Age'
      end
      object Label2: TLabel
        Left = 152
        Top = 16
        Width = 52
        Height = 13
        Caption = 'Hiring Time'
      end
      object Label3: TLabel
        Left = 383
        Top = 16
        Width = 30
        Height = 13
        Caption = 'Salary'
      end
      object Label4: TLabel
        Left = 24
        Top = 92
        Width = 36
        Height = 13
        Caption = 'K-value'
      end
      object Age: TEdit
        Left = 24
        Top = 32
        Width = 97
        Height = 21
        TabOrder = 0
      end
      object HiringTime: TEdit
        Left = 152
        Top = 32
        Width = 97
        Height = 21
        TabOrder = 1
      end
      object Restrict: TCheckBox
        Left = 280
        Top = 34
        Width = 97
        Height = 17
        Caption = 'Has restrict?'
        TabOrder = 2
      end
      object BillsOnTime: TCheckBox
        Left = 528
        Top = 34
        Width = 97
        Height = 17
        Caption = 'Bills on time?'
        TabOrder = 3
      end
      object Salary: TEdit
        Left = 383
        Top = 32
        Width = 97
        Height = 21
        TabOrder = 4
      end
      object Button2: TButton
        Left = 104
        Top = 96
        Width = 201
        Height = 41
        Caption = 'Check credit test!'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -16
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 5
        OnClick = Button2Click
      end
      object Kvalue: TEdit
        Left = 24
        Top = 108
        Width = 49
        Height = 21
        TabOrder = 6
        Text = '4'
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Result'
      ImageIndex = 2
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitWidth = 0
      ExplicitHeight = 0
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 733
        Height = 49
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGreen
        Font.Height = -19
        Font.Name = 'Tahoma'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
      end
      object Chart1: TChart
        Left = 0
        Top = 49
        Width = 733
        Height = 206
        Legend.TextStyle = ltsLeftPercent
        Title.Text.Strings = (
          'TChart')
        Align = alClient
        TabOrder = 1
        DefaultCanvas = 'TGDIPlusCanvas'
        PrintMargins = (
          15
          36
          15
          36)
        ColorPaletteIndex = 13
        object Series1: TBarSeries
          BarBrush.BackColor = clDefault
          ColorEachPoint = True
          Marks.Style = smsValue
          Marks.Callout.Length = 8
          XValues.Name = 'X'
          XValues.Order = loNone
          YValues.Name = 'Bar'
          YValues.Order = loAscending
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 332
    Width = 741
    Height = 41
    Align = alBottom
    TabOrder = 2
    DesignSize = (
      741
      41)
    object Button1: TButton
      Left = 648
      Top = 6
      Width = 75
      Height = 25
      Anchors = [akTop, akRight]
      Caption = 'Save data'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
  object CdsCustomers: TClientDataSet
    Aggregates = <>
    Params = <>
    AfterScroll = CdsCustomersAfterScroll
    Left = 96
    Top = 312
    object CdsCustomersSalary: TCurrencyField
      FieldName = 'Salary'
    end
    object CdsCustomersRestrict: TBooleanField
      FieldName = 'Restrict'
    end
    object CdsCustomersHiringTime: TIntegerField
      FieldName = 'HiringTime'
    end
    object CdsCustomersAge: TIntegerField
      FieldName = 'Age'
    end
    object CdsCustomersBillsOnTime: TBooleanField
      FieldName = 'BillsOnTime'
    end
    object CdsCustomersGoodPayer: TBooleanField
      FieldName = 'GoodPayer'
    end
  end
  object dsCustomers: TDataSource
    DataSet = CdsCustomers
    Left = 24
    Top = 320
  end
end
