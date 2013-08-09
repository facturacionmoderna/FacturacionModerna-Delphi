unit ejemploTimbrado;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WS, Generics.Collections;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Edit2: TEdit;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

{Timbrar Layout}
procedure TForm1.Button1Click(Sender: TObject);
  var
    layout, rfc, pass, id, url, path : string;
    timbrar : WSConecFM;
    parametros : TDictionary<string, string>;
    resultados : TDictionary<string, WideString>;
    msg, xmlb64, pdfb64, txtb64, cbbb64, uuid : wideString;
    f: TextFile;

  begin
    Screen.Cursor:= crHourGlass;
    layout := Edit1.Text;
    path := ExtractFilePath( Application.ExeName );
    {
    A continuación se definen las credenciales de acceso al Web Service, en cuanto se
    active su servicio deberá cambiar esta información por
    sus claves de acceso en modo productivo.
    }
    rfc := 'ESI920427886';
    pass := 'b9ec2afa3361a59af4b4d102d3f704eabdf097d4';
    id := 'UsuarioPruebasWS';
    url := 'https://t1demo.facturacionmoderna.com/timbrado/soap';
    parametros := TDictionary<string, string>.Create;
    parametros.Add('emisorRFC', rfc);
    parametros.Add('userPass', pass);
    parametros.Add('userId', id);
    parametros.Add('urlTimbrado', url);
    parametros.Add('generarPDF', 'true');
    parametros.Add('generarTXT', 'false');
    parametros.Add('generarCBB', 'false');

    resultados := timbrar.timbrado(layout, parametros);
    if resultados.ContainsKey('code') then
    begin
      resultados.TryGetValue('message', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;

    resultados.TryGetValue('xmlb64', xmlb64);
    resultados.TryGetValue('uuid', uuid);

    xmlb64 := timbrar.base64decode(xmlb64);
    AssignFile(f, path + 'resultados\' + uuid + '.xml');
    Rewrite(f);
    WriteLn(f,xmlb64);
    CloseFile(f);

    if resultados.ContainsKey('pdfb64') then
    begin
      pdfb64 := timbrar.base64decode(pdfb64);
      AssignFile(f, path + 'resultados\' + uuid + '.pdf');
      Rewrite(f);
      WriteLn(f,pdfb64);
      CloseFile(f);
    end;
    if resultados.ContainsKey('txtb64') then
    begin
      txtb64 := timbrar.base64decode(txtb64);
      AssignFile(f, path + 'resultados\' + uuid + '.txt');
      Rewrite(f);
      WriteLn(f,txtb64);
      CloseFile(f);
    end;
    if resultados.ContainsKey('cbbb64') then
    begin
      cbbb64 := timbrar.base64decode(cbbb64);
      AssignFile(f, path + 'resultados\' + uuid + '.png');
      Rewrite(f);
      WriteLn(f,cbbb64);
      CloseFile(f);
    end;
    Screen.Cursor:= crDefault;
  end;

{Cancelar UUID}
procedure TForm1.Button2Click(Sender: TObject);
var
  uuid, rfc, pass, id, url : string;
  cancelar : WSConecFM;
  parametros : TDictionary<string, string>;
  resultados : TDictionary<string, WideString>;
  msg: wideString;

begin
  Screen.Cursor:= crHourGlass;
  uuid := Edit2.Text;
  rfc := 'ESI920427886';
  pass := 'b9ec2afa3361a59af4b4d102d3f704eabdf097d4';
  id := 'UsuarioPruebasWS';
  url := 'https://t1demo.facturacionmoderna.com/timbrado/soap';
  parametros := TDictionary<string, string>.Create;
  parametros.Add('emisorRFC', rfc);
  parametros.Add('userPass', pass);
  parametros.Add('userId', id);
  parametros.Add('urlCancelado', url);

  resultados := cancelar.cancelado(uuid, parametros);
  resultados.TryGetValue('message', msg);
  showMessage(msg);
  Screen.Cursor:= crDefault;

end;

end.

