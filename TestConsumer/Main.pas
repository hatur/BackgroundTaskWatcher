unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, AsyncProgressStatus;

type
  TForm1 = class(TForm)
    AsyncProgressStatus1: TAsyncProgressStatus;
    procedure FormCreate(Sender: TObject);
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  System.Threading;

procedure TForm1.FormCreate(Sender: TObject);
var
  lTask: ITask;
begin
  lTask := TTask.Create(procedure()
    begin
      Sleep(5000);
    end
  );
  lTask.Start;

  AsyncProgressStatus1.RegisterTask(lTask);
end;

end.
