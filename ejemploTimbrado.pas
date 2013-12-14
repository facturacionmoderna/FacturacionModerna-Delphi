unit ejemploTimbrado;

interface

uses
  Windows, Messages, Variants, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WS, Generics.Collections, StrUtils;

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
    pdfbytes, cbbbytes, xmlbytes: TBytes;
    stream: TFileStream;

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

    resultados.TryGetValue('uuid', uuid);

    // Guardar XML
    stream := TFileStream.Create(path + 'resultados\' + uuid + '.xml', fmCreate);
    resultados.TryGetValue('xmlb64', xmlb64);
    xmlbytes := timbrar.base64decodebyte(xmlb64);
    try
      if xmlbytes <> nil then
        Stream.WriteBuffer(xmlbytes[0], Length(xmlbytes));
    finally
      Stream.Free;
    end;

    // Guardar PDF
    if resultados.ContainsKey('pdfb64') then
    begin
      stream := TFileStream.Create(path + 'resultados\' + uuid + '.pdf', fmCreate);
      resultados.TryGetValue('pdfb64', pdfb64);
      pdfbytes := timbrar.base64decodebyte(pdfb64);
      try
        if pdfbytes <> nil then
          Stream.WriteBuffer(pdfbytes[0], Length(pdfbytes));
      finally
        Stream.Free;
      end;
    end;

    // Guardar TXT
    if resultados.ContainsKey('txtb64') then
    begin
      resultados.TryGetValue('txtb64', txtb64);
      txtb64 := timbrar.base64decode(txtb64);
      AssignFile(f, path + 'resultados\' + uuid + '.txt');
      Rewrite(f);
      WriteLn(f,txtb64);
      CloseFile(f);
    end;

    // Guardar CBB
    if resultados.ContainsKey('cbbb64') then
    begin
      stream := TFileStream.Create(path + 'resultados\' + uuid + '.png', fmCreate);
      resultados.TryGetValue('cbbb64', cbbb64);
      cbbbytes := timbrar.base64decodebyte(cbbb64);
      try
        if cbbbytes <> nil then
          Stream.WriteBuffer(cbbbytes[0], Length(cbbbytes));
      finally
        Stream.Free;
      end;
    end;

    Screen.Cursor:= crDefault;
    showMessage('Timbrado Exitoso');
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

