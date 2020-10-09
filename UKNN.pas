unit UKNN;
//
// Delphi KNN
// Author: Rodolpho Nascimento
// Email: contato@essencialcode.com.br

interface

uses
  System.Generics.Collections, Classes, System.Generics.Defaults,
  System.SysUtils, System.Variants, Math;

type
  TDataPoint = class
  private
    FDataClass: Integer;
    FFeatures: TList<Double>;
  public
    constructor Create;
    destructor Destroy; override;

    property DataClass: Integer read FDataClass write FDataClass;
    property Features: TList<Double> read FFeatures;
  end;

  TComputedResult = class
    DataClass: Integer;
    Distance: Double;
  end;

  TKNN_Result = record
    ClassPredicted: Integer;
    Reliability: Double;
    Classes: TArray<Integer>;
    Frequency: TArray<Integer>;
  end;


  TKNN = class
  private
    FDataPoints: TObjectList<TDataPoint>;
    function calc_euclidean_distance(DataA, DataB: TArray<Double>): Double;

    procedure compute_reliability(var Result: TKNN_Result);

  public
    constructor Create;
    destructor Destroy; override;

    procedure clear_data;
    procedure add_example(DataClass: Integer; Features: TArray<Double>);
    function predict_new_entry(UnseenData: TArray<Double>; K_value: Integer): TKNN_Result;
  end;



implementation

{ TKNN }

procedure TKNN.add_example(DataClass: Integer; Features: TArray<Double>);
var
  NewDataPoint: TDataPoint;
begin
  NewDataPoint := TDataPoint.Create;
  NewDataPoint.DataClass := DataClass;
  NewDataPoint.Features.AddRange(Features);

  FDataPoints.Add(NewDataPoint);
end;

function TKNN.calc_euclidean_distance(DataA, DataB: TArray<Double>): Double;
var
  Total, i: Integer;
  Score: Double;

begin
  Total := Length(DataA);
  if Total <> Length(DataB) then
    raise Exception.Create('Developer - Samples "A" and "B" must be same size.');

  Score  := 0;
  for i := 0 to Pred(Total) do
  begin
    Score := Score + Power(DataA[i]-DataB[i], 2);
  end;

  Result := RoundTo(Sqrt(Score), -4);
end;

procedure TKNN.clear_data;
begin
  FDataPoints.Clear;
end;

procedure TKNN.compute_reliability(var Result: TKNN_Result);
var
  i, total: Integer;

begin
  total := 0;
  Result.Reliability := 0;


  for i := 0  to Pred(Length(Result.Frequency)) do
  begin
    total := total + Result.Frequency[i];
  end;

  for i := 0  to Pred(Length(Result.Classes)) do
  begin
    if Result.Classes[i] = Result.ClassPredicted then
    begin
      Result.Reliability := RoundTo((Result.Frequency[i] / total) * 100, -2);
      Break;
    end;
  end;
end;

constructor TKNN.Create;
begin
  FDataPoints := TObjectList<TDataPoint>.Create;
end;

destructor TKNN.Destroy;
begin
  inherited;
  FDataPoints.Free;
end;


function TKNN.predict_new_entry(UnseenData: TArray<Double>; K_value: Integer): TKNN_Result;
var
  DataPoint: TDataPoint;
  Distance, MostFreq: Double;

  ComputedResults: TObjectList<TComputedResult>;
  ClassFrequency: TDictionary<Integer, Integer>;
  Frequency, i, DataClass: Integer;
  CR: TComputedResult;
  Comparer: IComparer<TComputedResult>;


begin
  if FDataPoints.Count = 0 then
    raise Exception.Create('Developer - No data in this model to predict. Add data.');


  Comparer := TComparer<TComputedResult>.Construct (
  function(const Left, Right: TComputedResult): Integer
  begin
    Result := CompareValue(Left.Distance, Right.Distance);
  end);



  Result.ClassPredicted := -1;
  ComputedResults       := TObjectList<TComputedResult>.Create;
  ClassFrequency        := TDictionary<Integer, Integer>.Create;

  try
    for DataPoint in FDataPoints do
    begin
      Distance := calc_euclidean_distance(UnseenData, DataPoint.Features.ToArray);

      // Insert distance and class to list
      CR := TComputedResult.Create;
      CR.DataClass := DataPoint.DataClass;
      CR.Distance  := Distance;
      ComputedResults.Add(CR);
    end;

    // Sort list by "Distance"
    ComputedResults.Sort(Comparer);

    // Computer frequency of each class until reach
    // K-value
    i := 0;
    for CR in ComputedResults do
    begin
      Inc(i);
      if i > K_value then
        Break;

      DataClass := CR.DataClass;

      if ClassFrequency.TryGetValue(DataClass, Frequency) then
        Inc(Frequency)
      else
        Frequency := 1;

      ClassFrequency.AddOrSetValue(DataClass, Frequency);
    end;

    // Check the less class score and return class predicted
    MostFreq := -1;
    for DataClass in ClassFrequency.Keys do
    begin
      if ClassFrequency.TryGetValue(DataClass, Frequency) then
      begin
        if (Frequency > MostFreq) then
        begin
          MostFreq := Frequency;
          Result.ClassPredicted := DataClass;
        end
        else
        if Frequency = MostFreq then
          raise Exception.Create('Inconclusive result. Add more data and run again');
      end;
    end;

    Result.Classes   := ClassFrequency.Keys.ToArray;
    Result.Frequency := ClassFrequency.Values.ToArray;

    compute_reliability(Result);


  finally
    ComputedResults.Free;
    ClassFrequency.Free;
  end;
end;

{ TDataPoint }

constructor TDataPoint.Create;
begin
  FFeatures := TList<Double>.Create;
  FDataClass := 0;
end;

destructor TDataPoint.Destroy;
begin
  inherited;
  FFeatures.Free;
end;

end.
