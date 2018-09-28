unit AsyncProgressStatus;

interface

uses
  System.SysUtils, System.Classes, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, System.Generics.Collections, System.Threading;

type
  TAsyncProgressStatus = class(TCustomControl)
  private
  const
    MIN_ANIMATION_INTERVAL: Integer = 50;
    MIN_QUERY_INTERVAL: Integer = 50;
    DEFAULT_ANIMATION_INTERVAL: Integer = 80;
    DEFAULT_QUERY_INTERVAL: Integer = 100;
    ANIMATION_FRAMES: Integer = 9;
  var
    { Private-Deklarationen }
    fInfotext1: TLabel;
    fInfotext2: TLabel;
    fLoadingGraphics: TObjectList<TPngImage>;
    fCurrentIndex: Integer;
    fLoadingImage: TImage;
    fAnimationTimer: TTimer;
    fQueryTimer: TTimer;
    fTasks: TList<ITask>;

    procedure LoadGraphics;
    procedure TimerProc(aSender: TObject);
    procedure QueryTimerProc(aSender: TObject);

    function GetAnimationInterval: Integer;
    procedure SetAnimationInterval(const aInterval: Integer);
    function GetQueryInterval: Integer;
    procedure SetQueryInterval(const aInterval: Integer);
  protected
    { Protected-Deklarationen }
  public
    constructor Create(aOwner: TComponent); override;
    destructor Destroy; override;

    procedure ResetTasks;
    procedure RegisterTask(const aTask: ITask);
  published
    { Published-Deklarationen }
    property AnimationInterval: Integer read GetAnimationInterval write SetAnimationInterval;
    property QueryInterval: Integer read GetQueryInterval write SetQueryInterval;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('DelphiControls', [TAsyncProgressStatus]);
end;

{ TAsyncProgressStatus }

constructor TAsyncProgressStatus.Create(aOwner: TComponent);
begin
  inherited;

  fLoadingGraphics := TObjectList<TPngImage>.Create;
  LoadGraphics;

  fTasks := TList<ITask>.Create;

  fInfotext1 := TLabel.Create(Self);
  fInfotext1.Parent := Self;
  fInfotext1.Caption := 'Loading..';
  fInfotext1.Left := 42;
  fInfotext1.Top := 4;

  fInfotext2 := TLabel.Create(Self);
  fInfotext2.Parent := Self;
  fInfotext2.Caption := '';
  fInfotext2.Left := 42;
  fInfotext2.Top := 18;

  fLoadingImage := TImage.Create(Self);
  fLoadingImage.Parent := Self;
  fLoadingImage.Top := 2;
  fLoadingImage.Left := 2;
  fLoadingImage.Width := 32;
  fLoadingImage.Height := 32;
  fLoadingImage.Picture.Graphic := fLoadingGraphics[fCurrentIndex];

  fAnimationTimer := TTimer.Create(Self);
  fAnimationTimer.Interval := DEFAULT_ANIMATION_INTERVAL;
  fAnimationTimer.OnTimer := TimerProc;

  fQueryTimer := TTimer.Create(Self);
  fQueryTimer.Interval := DEFAULT_QUERY_INTERVAL;

  if not (csDesigning in ComponentState) then
  begin
    fQueryTimer.OnTimer := QueryTimerProc;
  end;

  DoubleBuffered := true;
end;

destructor TAsyncProgressStatus.Destroy;
begin
  fLoadingGraphics.Free;
  fTasks.Free;

  inherited;
end;
procedure TAsyncProgressStatus.LoadGraphics;
var
  i: Integer;
  lPNG: TPngImage;
begin
  for i := 0 to 9 do
  begin
    lPNG := TPngImage.Create;
    lPNG.LoadFromResourceName(hInstance, 'LOAD32_' + IntToStr(i));
    fLoadingGraphics.Add(lPNG);
  end;
end;

procedure TAsyncProgressStatus.TimerProc(aSender: TObject);
begin
  Inc(fCurrentIndex);
  if fCurrentIndex > ANIMATION_FRAMES then
  begin
    fCurrentIndex := 0;
  end;

  fLoadingImage.Picture.Graphic := fLoadingGraphics[fCurrentIndex];
end;

procedure TAsyncProgressStatus.QueryTimerProc(aSender: TObject);
var
  lFinishedCount: Integer;
  lTask: ITask;
begin
  lFinishedCount := 0;

  if fTasks.Count = 0 then
  begin
    fInfotext2.Caption := '';
  end
  else
  begin
    for lTask in fTasks do
    begin
      if (lTask.Status <> TTaskStatus.Running) and (lTask.Status <> TTaskStatus.WaitingToRun) and
        (lTask.Status <> TTaskStatus.Created) then
      begin
        Inc(lFinishedCount);
      end;
    end;

    fInfotext2.Caption := IntToStr(lFinishedCount) + ' of ' + IntToStr(fTasks.Count);
  end;
end;

procedure TAsyncProgressStatus.RegisterTask(const aTask: ITask);
begin
  fTasks.Add(aTask);
end;

procedure TAsyncProgressStatus.ResetTasks;
begin
  fTasks.Clear;
end;

function TAsyncProgressStatus.GetAnimationInterval: Integer;
begin
  Result := fAnimationTimer.Interval;
end;

procedure TAsyncProgressStatus.SetAnimationInterval(const aInterval: Integer);
begin
  if aInterval < MIN_ANIMATION_INTERVAL then
  begin
    fAnimationTimer.Interval := MIN_ANIMATION_INTERVAL;
  end
  else
  begin
    fAnimationTimer.Interval := aInterval;
  end;
end;

function TAsyncProgressStatus.GetQueryInterval: Integer;
begin
  Result := fQueryTimer.Interval;
end;

procedure TAsyncProgressStatus.SetQueryInterval(const aInterval: Integer);
begin
  if aInterval < MIN_QUERY_INTERVAL then
  begin
    fAnimationTimer.Interval := MIN_QUERY_INTERVAL;
  end
  else
  begin
    fQueryTimer.Interval := aInterval;
  end;
end;

end.
