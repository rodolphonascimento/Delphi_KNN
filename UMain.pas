unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, System.IOUtils,
  Datasnap.DBClient, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, UKNN, StrUtils, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart;

type
  TFrmMain = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    CdsCustomers: TClientDataSet;
    CdsCustomersSalary: TCurrencyField;
    CdsCustomersRestrict: TBooleanField;
    CdsCustomersHiringTime: TIntegerField;
    CdsCustomersAge: TIntegerField;
    CdsCustomersBillsOnTime: TBooleanField;
    CdsCustomersGoodPayer: TBooleanField;
    dsCustomers: TDataSource;
    DBGrid1: TDBGrid;
    Panel2: TPanel;
    Button1: TButton;
    TabSheet2: TTabSheet;
    Age: TEdit;
    Label1: TLabel;
    HiringTime: TEdit;
    Label2: TLabel;
    Restrict: TCheckBox;
    BillsOnTime: TCheckBox;
    Salary: TEdit;
    Label3: TLabel;
    Button2: TButton;
    Kvalue: TEdit;
    Label4: TLabel;
    TabSheet3: TTabSheet;
    Panel3: TPanel;
    Chart1: TChart;
    Series1: TBarSeries;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CdsCustomersAfterScroll(DataSet: TDataSet);
  private
    { Private declarations }
    KNN: TKNN;
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

procedure TFrmMain.Button1Click(Sender: TObject);
begin
  CdsCustomers.SaveToFile('CdsCustomers.cds');
end;

procedure TFrmMain.Button2Click(Sender: TObject);
var
  Data, NewData: TArray<Double>;
  Result: TKNN_Result;
  I, DataClass: Integer;

begin
  try
    CdsCustomers.DisableControls;
    KNN.clear_data;


    NewData := [StrToInt(Age.Text),
                StrToInt(HiringTime.Text),
                StrToInt(IfThen(Restrict.Checked, '1', '0')),
                StrToFloat(Salary.Text),
                StrToInt(IfThen(BillsOnTime.Checked, '1', '0'))];



    while (not CdsCustomers.Eof) do
    begin
      Data := [CdsCustomersAge.AsInteger,
               CdsCustomersHiringTime.AsInteger,
               StrToInt(IfThen(CdsCustomersRestrict.AsBoolean, '1', '0')),
               CdsCustomersSalary.AsFloat,
               StrToInt(IfThen(CdsCustomersBillsOnTime.AsBoolean, '1', '0'))];

      KNN.add_training_data(StrToInt(IfThen(CdsCustomersGoodPayer.AsBoolean, '1', '0')),
                            Data);

      CdsCustomers.Next;
    end;


    Result := KNN.predict_new_entry(NewData, StrToInt(Kvalue.Text));

    if Result.ClassPredicted = 1 then
    begin
      Panel3.Caption := 'Good Payer. Grant credit!';
      Panel3.Font.Color := clBlue;
    end
    else
    begin
      Panel3.Caption := 'Bad Payer. Revoke credit!';
      Panel3.Font.Color := clRed;
    end;

    Series1.Clear;

    for i := 0 to Pred(Length(Result.Classes)) do
    begin
      DataClass := Result.Classes[i];
      if DataClass = 1 then
        Series1.AddY(Result.Frequencies[i], IntToStr(DataClass), clGreen)
      else
        Series1.AddY(Result.Frequencies[i], IntToStr(DataClass), clRed);
    end;

    PageControl1.ActivePageIndex := 2;

  finally
    CdsCustomers.EnableControls;
    CdsCustomers.First;
  end;
end;

procedure TFrmMain.CdsCustomersAfterScroll(DataSet: TDataSet);
begin
  Panel2.Caption := IntToStr(CdsCustomers.RecordCount) + ' customers';
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  if TFile.Exists('CdsCustomers.cds') then
    CdsCustomers.LoadFromFile('CdsCustomers.cds')
  else
    CdsCustomers.CreateDataSet;

  KNN := TKNN.Create;

  PageControl1.ActivePageIndex := 0;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  KNN.Destroy;
end;

end.
