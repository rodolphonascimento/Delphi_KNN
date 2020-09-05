unit UKNN;

interface

uses
  System.Generics.Collections, Classes, System.Generics.Defaults,
  System.SysUtils, System.Variants, Math;

type
  TDataPoint = class
  private
    FDataClass: Integer;
    FDataCollection: TList<Double>;
  public
    constructor Create;
    destructor Desyroy;

    property DataClass: Integer read FDataClass write FDataClass;
    property DataCollection: TList<Double> read FDataCollection;
  end;

  TComputedResult = class
    DataClass: Integer;
    Distance: Double;
  end;



  TKNN = class
  private
    FDataPoints: TObjectList<TDataPoint>;
    function calc_euclidean_distance(DataA, DataB: TArray<Double>): Double;

  public
    constructor Create;
    destructor Destroy; override;

    procedure clear_data;
    procedure add_training_data(DataClass: Integer; DataCollection: TArray<Double>);
    function predict_new_entry(UnseeData: TArray<Double>; K_value: Integer): Integer;

  end;



implementation

{ TKNN }

procedure TKNN.add_training_data(DataClass: Integer; DataCollection: TArray<Double>);
var
  NewDataPoint: TDataPoint;
begin
  NewDataPoint := TDataPoint.Create;
  NewDataPoint.DataClass := DataClass;
  NewDataPoint.DataCollection.AddRange(DataCollection);

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

constructor TKNN.Create;
begin
  FDataPoints := TObjectList<TDataPoint>.Create;
end;

destructor TKNN.Destroy;
begin
  inherited;
  FDataPoints.Free;
end;


function TKNN.predict_new_entry(UnseeData: TArray<Double>; K_value: Integer): Integer;
var
  DataPoint: TDataPoint;
  Distance, MostFreq: Double;

  ComputedResults: TObjectList<TComputedResult>;
  ClassFrequences: TDictionary<Integer, Integer>;
  ClassFreq, i, DataClass: Integer;
  CP: TComputedResult;
  Comparer: IComparer<TComputedResult>;


begin
  if FDataPoints.Count = 0 then
    raise Exception.Create('Developer - No data in this model to predict. Add data.');


  Comparer := TComparer<TComputedResult>.Construct (
  function(const Left, Right: TComputedResult): Integer
  begin
    Result := CompareValue(Left.Distance, Right.Distance);
  end);



  Result          := -1;
  ComputedResults := TObjectList<TComputedResult>.Create;
  ClassFrequences     := TDictionary<Integer, Integer>.Create;

  try
    for DataPoint in FDataPoints do
    begin
      Distance := calc_euclidean_distance(UnseeData, DataPoint.DataCollection.ToArray);

      // Insert distance and class to list
      CP := TComputedResult.Create;
      CP.DataClass := DataPoint.DataClass;
      CP.Distance  := Distance;
      ComputedResults.Add(CP);
    end;

    // Sort list by "Distance"
    ComputedResults.Sort(Comparer);

    // Extract "K" results to begin predict
    i := 0;
    for CP in ComputedResults do
    begin
      Inc(i);
      if i > K_value then
        Break;

      DataClass := CP.DataClass;

      if ClassFrequences.TryGetValue(DataClass, ClassFreq) then
        Inc(ClassFreq)
      else
        ClassFreq := 1;

      ClassFrequences.AddOrSetValue(DataClass, ClassFreq);
    end;

    // Check the most class score and retur class predicted
    MostFreq := 0;
    for DataClass in ClassFrequences.Keys do
    begin
      if ClassFrequences.TryGetValue(DataClass, ClassFreq) and
         (ClassFreq > MostFreq) then
      begin
        MostFreq := ClassFreq;
        Result   := DataClass;
      end;
    end;

  finally
    ComputedResults.Free;
    ClassFrequences.Free;
  end;
end;

{ TDataPoint }

constructor TDataPoint.Create;
begin
  FDataCollection := TList<Double>.Create;
  FDataClass := 0;
end;

destructor TDataPoint.Desyroy;
begin
  FDataCollection.Free;
end;

end.
