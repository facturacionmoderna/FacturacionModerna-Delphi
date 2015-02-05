{
Components
import Microsoft xml 6
}
unit ejemploTimbrado;

interface

uses
  Windows, Messages, Variants, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, WS, Generics.Collections, StrUtils, CFD, DateUtils, ExtDlgs;

type
    TForm1 = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    Edit2: TEdit;
    Button2: TButton;
    CheckBox1: TCheckBox;
    Edit3: TEdit;
    Button5: TButton;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
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
    layout := 'C:\Users\Arango\Documents\RAD Studio\Projects\FacturacionModerna-Delphi_2009\ejemplos\ejemploTimbradoLayout.ini';

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

procedure TForm1.Button3Click(Sender: TObject);
var
  openDialog : TOpenDialog;

begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Archivos Xml|*.xml';
  // Abrir archivos xml por default
  openDialog.FilterIndex := 1;
  if openDialog.Execute then
  begin
    Edit1.Text := openDialog.FileName;
  end
  else
  begin
    Edit1.Text := '--- Buscar archivo xml ---';
  end;
  openDialog.Free;
end;

procedure TForm1.Button4Click(Sender: TObject);
var
  openDialog : TOpenDialog;

begin
  openDialog := TOpenDialog.Create(self);
  openDialog.InitialDir := GetCurrentDir;
  openDialog.Options := [ofFileMustExist];
  openDialog.Filter := 'Archivos ini|*.ini|Archivos txt|*.txt';
  // Abrir archivos txt por default
  openDialog.FilterIndex := 2;
  if openDialog.Execute then
  begin
    Edit3.Text := openDialog.FileName;
  end
  else
  begin
    Edit3.Text := '--- Buscar archivo layout ---';
  end;
  openDialog.Free;
end;

{ Timbrar XML }
procedure TForm1.Button5Click(Sender: TObject);
  var
    path, xsltfile, certfile, comando, certificateNumber,keyfile, password : String;
    status, msg, cadenaO, xmlfile, certificate, certi, certiNumber,dgSign : wideString;
    salida : String;
    cfd : Comprobante;
    resp : TDictionary<String, WideString>;
    layout, rfc, pass, id, url : string;
    timbrar : WSConecFM;
    parametros : TDictionary<string, string>;
    resultados : TDictionary<string, WideString>;
    xmlb64, pdfb64, txtb64, cbbb64, uuid : wideString;
    f: TextFile;
    pdfbytes, cbbbytes, xmlbytes: TBytes;
    stream: TFileStream;

  begin
    Screen.Cursor:= crHourGlass;
    path := ExtractFilePath( Application.ExeName );
    xmlfile := Edit1.Text;
    xsltfile := 'C:\Users\Arango\Documents\RAD Studio\Projects\FacturacionModerna-Delphi_2009\utilerias\xslt3_2\cadenaoriginal_3_2.xslt';
    certfile := 'C:\Users\Arango\Documents\RAD Studio\Projects\FacturacionModerna-Delphi_2009\utilerias\certificados\20001000000200000278.cer';
    keyfile := 'C:\Users\Arango\Documents\RAD Studio\Projects\FacturacionModerna-Delphi_2009\utilerias\certificados\20001000000200000278.key';
    password := '12345678a';

    if CheckBox1.Checked then
    begin
        xsltfile := 'C:\Users\Arango\Documents\RAD Studio\Projects\FacturacionModerna-Delphi_2009\utilerias\xslt_retenciones\retenciones.xslt';
    end;


    { Obtener informacion del certificado }
    resp := cfd.getInfoCertificate(certfile);
    if ( status = 'false' ) then
    begin
      resp.TryGetValue('msg', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;
    resp.TryGetValue('certificate', certi);
    resp.TryGetValue('certificateNumber', certiNumber);

    { Agregar informacion del certificado al xml }
    resp :=  cfd.addCertificateToXml(xmlfile, certi, certiNumber);
    if ( status = 'false' ) then
    begin
      resp.TryGetValue('msg', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;
    resp.TryGetValue('newXml', xmlfile);

    { Generar la cadena original del xml }
    resp := cfd.createOriginalChain(xmlfile, xsltfile);
    resp.TryGetValue('status', status);
    if ( status = 'false' ) then
    begin
      resp.TryGetValue('msg', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;
    resp.TryGetValue('msg', cadenaO);

    resp := cfd.createDigitalStamp(keyfile,cadenaO, password);
    if ( status = 'false' ) then
    begin
      resp.TryGetValue('msg', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;
    resp.TryGetValue('sello', dgSign);

    { Agregar el sello al xml }
    resp := cfd.addDigitalStampToXml(xmlfile, dgSign);
    if ( status = 'false' ) then
    begin
      resp.TryGetValue('msg', msg);
      showMessage(msg);
      Screen.Cursor:= crDefault;
      Exit;
    end;
    resp.TryGetValue('newXml', xmlfile);

    {Realizar timbrado de XML }
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

    resultados := timbrar.timbrado(xmlfile, parametros);
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

end.

