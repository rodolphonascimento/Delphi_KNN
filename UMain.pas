unit UMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Data.DB, System.IOUtils,
  Datasnap.DBClient, Vcl.ComCtrls, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, UKNN, StrUtils, VclTee.TeeGDIPlus, VCLTee.TeEngine,
  VCLTee.Series, VCLTee.TeeProcs, VCLTee.Chart, Math,
  System.Generics.Collections;

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
    Panel4: TPanel;
    Label5: TLabel;
    Filter: TEdit;
    BtFilter: TButton;
    TrackBar: TTrackBar;
    GrpStats: TGroupBox;
    LblAge: TLabel;
    LblHT: TLabel;
    LblSalary: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CdsCustomersAfterScroll(DataSet: TDataSet);
    procedure BtFilterClick(Sender: TObject);
    procedure FilterChange(Sender: TObject);
    procedure FilterKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure TrackBarChange(Sender: TObject);
  private
    { Private declarations }
    KNN: TKNN;

    procedure update_stats;
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
  CdsCustomers.Filtered := False;


  try
    CdsCustomers.DisableControls;

    // Clear data in object
    KNN.clear_data;


    // Collect data to predict into array values
    NewData := [StrToInt(Age.Text),
                StrToInt(HiringTime.Text),
                StrToInt(IfThen(Restrict.Checked, '1', '0')),
                StrToFloat(Salary.Text),
                StrToInt(IfThen(BillsOnTime.Checked, '1', '0'))];


    // Collect data to train
    CdsCustomers.First;
    while (not CdsCustomers.Eof) do
    begin
      Data := [CdsCustomersAge.AsInteger,
               CdsCustomersHiringTime.AsInteger,
               StrToInt(IfThen(CdsCustomersRestrict.AsBoolean, '1', '0')),
               CdsCustomersSalary.AsFloat,
               StrToInt(IfThen(CdsCustomersBillsOnTime.AsBoolean, '1', '0'))];

      KNN.add_example(StrToInt(IfThen(CdsCustomersGoodPayer.AsBoolean, '1', '0')),
                            Data);

      CdsCustomers.Next;
    end;

    // Predict
    Result := KNN.predict_new_entry(NewData, StrToInt(Kvalue.Text));

    // Check results
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

    Panel3.Caption := Panel3.Caption + '. Reliability: ' + FloatToStr(Result.Reliability) + '%';


    // Plot selection criteria take by K-NN
    Series1.Clear;
    for i := 0 to Pred(Length(Result.Classes)) do
    begin
      DataClass := Result.Classes[i];
      if DataClass = 1 then
        Series1.AddY(Result.Frequency[i], IntToStr(DataClass), clGreen)
      else
        Series1.AddY(Result.Frequency[i], IntToStr(DataClass), clRed);
    end;

    PageControl1.ActivePageIndex := 2;

  finally
    CdsCustomers.EnableControls;
    CdsCustomers.First;
  end;
end;

procedure TFrmMain.BtFilterClick(Sender: TObject);
begin
  CdsCustomers.Filtered := False;
  CdsCustomers.Filter   := Filter.Text;
  CdsCustomers.Filtered := True;
  update_stats;
end;

procedure TFrmMain.CdsCustomersAfterScroll(DataSet: TDataSet);
begin
  Panel2.Caption := IntToStr(CdsCustomers.RecordCount) + ' customers';
end;

procedure TFrmMain.FilterChange(Sender: TObject);
begin
  CdsCustomers.Filtered := False;
  update_stats;
end;

procedure TFrmMain.FilterKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    BtFilter.Click;
end;

procedure TFrmMain.FormCreate(Sender: TObject);
begin
  if TFile.Exists('CdsCustomers.cds') then
    CdsCustomers.LoadFromFile('CdsCustomers.cds')
  else
    CdsCustomers.CreateDataSet;

  TrackBar.Max := CdsCustomers.RecordCount;
  TrackBar.Position := (Round(CdsCustomers.RecordCount / 100 * 30));


  KNN := TKNN.Create;

  PageControl1.ActivePageIndex := 0;

  update_stats;
end;

procedure TFrmMain.FormDestroy(Sender: TObject);
begin
  KNN.Destroy;
end;

procedure TFrmMain.TrackBarChange(Sender: TObject);
begin
  Kvalue.Text := IntToStr(TrackBar.Position);
end;

procedure TFrmMain.update_stats;
var
  LstAge, LstHT, LstSalary: TList<Double>;
  Mean, Std: String;

begin
  CdsCustomers.DisableControls;
  LstAge    := TList<Double>.Create;
  LstHT     := TList<Double>.Create;
  LstSalary := TList<Double>.Create;

  try
    CdsCustomers.First;
    while not CdsCustomers.Eof do
    begin
      LstAge.Add(CdsCustomersAge.AsInteger);
      LstHT.Add(CdsCustomersHiringTime.AsInteger);
      LstSalary.Add(CdsCustomersSalary.AsFloat);
      CdsCustomers.Next;
    end;

    Mean := FloatToStr(Trunc(Math.Mean(LstAge.ToArray)));
    Std  := FloatToStr(Trunc(Math.StdDev(LstAge.ToArray)));
    LblAge.Caption := 'Age: ' + Mean + ' (mean) ' + Std + ' (std)';

    Mean := FloatToStr(Trunc(Math.Mean(LstHT.ToArray)));
    Std  := FloatToStr(Trunc(Math.StdDev(LstHT.ToArray)));
    LblHT.Caption := 'Hiring time: ' + Mean + ' (mean) ' + Std + ' (std)';

    Mean := FloatToStr(Math.RoundTo(Math.Mean(LstSalary.ToArray), -2));
    Std  := FloatToStr(Math.RoundTo(Math.StdDev(LstSalary.ToArray), -2));
    LblSalary.Caption := 'Salary: ' + Mean + ' (mean) ' + Std + ' (std)';


  finally
    LstAge.Free;
    LstHT.Free;
    LstSalary.Free;
    CdsCustomers.First;
    CdsCustomers.EnableControls;
  end;
end;

end.
