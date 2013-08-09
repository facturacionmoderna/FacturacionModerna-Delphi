program TimbrarCancelar;

uses
  Forms,
  ejemploTimbrado in 'ejemploTimbrado.pas' {Form1},
  WS in 'WS.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
