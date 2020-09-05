unit UKNN;

interface

uses
  System.Generics.Collections, Classes,
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
  Result := 0;

  for i := 0 to Pred(Total) do
  begin
    Score := Score + Power(DataA[i]-DataB[i], 2);
  end;

  Result := Sqrt(Score);
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
  Distance, SumDist, MostDist: Double;
  ComputedResults: TStringList;
  ClassScores: TDictionary<Integer, Double>;
  i, DataClass: Integer;

begin
  if FDataPoints.Count = 0 then
    raise Exception.Create('Developer - No data in this model to predict. Add data.');

  Result          := -1;
  ComputedResults := TStringList.Create;
  ClassScores     := TDictionary<Integer, Double>.Create;

  try
    for DataPoint in FDataPoints do
    begin
      Distance := calc_euclidean_distance(UnseeData, DataPoint.DataCollection.ToArray);

      // Insert distance and class to list
      ComputedResults.Values[FloatToStr(Distance)] := IntToStr(DataPoint.DataClass);
    end;

    // Sort list by "Distance" in Asc. Could be Desc....
    // The goal is get most "K" distances scores
    ComputedResults.Sort;

    // Extract "K" results to begin predict
    for i := Pred(ComputedResults.Count) downto K_value do
    begin
      DataClass := StrToInt(ComputedResults.ValueFromIndex[i]);
      Distance  := StrToFloat(ComputedResults.Names[i]);

      if ClassScores.TryGetValue(DataClass, SumDist) then
        SumDist := SumDist + Distance
      else
        SumDist := Distance;

      ClassScores.AddOrSetValue(DataClass, SumDist);
    end;

    // Check the most class score and retur class predicted
    MostDist := 0;
    for DataClass in ClassScores.Keys do
    begin
      if ClassScores.TryGetValue(DataClass, SumDist) and
         (SumDist > MostDist) then
      begin
        MostDist := SumDist;
        Result   := DataClass;
      end;
    end;

  finally
    ComputedResults.Free;
    ClassScores.Free;
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
