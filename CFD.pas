{
  Requisitos:
  1.- Instalar openssl en el sistema
  2.- import Microsoft xml 6
}
unit CFD;

interface

uses
  SysUtils,Messages, Classes, Windows, Forms, Generics.Collections, MSXMLDOM, MSXML2_TLB,Dialogs;

type
  Comprobante = class(TObject)

private
  { Private declarations }
  function RandomNameFile(extension: String): String;
  function ReadFileTmp(file_path: String; delete : integer): WideString;
  function executeCommand(command: String; outpath : String): boolean;
  function ejecutarComando (comando : String; outpath: String) : String;
  function IsWinNT: boolean;
  function WriteFileTmp(file_path: String; myText:WideString): boolean;
  function WriteFileChain(file_path: String; myText:WideString): boolean;

protected
  { Protected declarations }

public
  { Public declarations }
  function createOriginalChain(xml: String; xslt : String): TDictionary<string, WideString>;
  function getInfoCertificate(certfile: String): TDictionary<String, WideString>;
  function addCertificateToXml(xml: String; cert: WideString; certNo: String): TDictionary<String, WideString>;
  function createDigitalStamp(keyfile: String; chain: String; password: String): TDictionary<String, WideString>;
  function addDigitalStampToXml(xml: String; digitalStamp: String): TDictionary<String, WideString>;

published
  { Published declarations }

end;

implementation

{ Leer certificado para extraer el No de certificado y el contenido del cer en base 64 }
function Comprobante.getInfoCertificate( certfile: String ): TDictionary<String, WideString>;
var
  file_name, certificateNumber : String;
  content_file, certificate : WideString;
  dtDate: TDateTime;
  res : TDictionary<String, WideString>;
  path : String;
  pid : String;
  i : Integer;
  fecha : LongWord;
  command : String;
  file_path: TFileName;

const
  UnixStartDate: TDateTime = 25569.0; // 01/01/1970

begin
  path := ExtractFilePath( Application.ExeName );
  certificateNumber := '';
  certificate := '';
  res := TDictionary<String, WideString>.Create;

  if (certfile = '') then
  begin;
    res.Add('msg', 'No se especifico la ruta del certificado');
    res.Add('status', 'false');
    res.Add('certificate', certificate);
    res.Add('certificateNumber', certificateNumber);
    Result := res;
    Exit;
  end;

  if not FileExists(certfile) then
  begin
    res.Add('msg', 'La ruta especificada del certificado no existe');
    res.Add('status', 'false');
    res.Add('certificate', certificate);
    res.Add('certificateNumber', certificateNumber);
    Result := res;
    Exit;
  end;

  { Obtener el número de certificado }
  command := 'openssl x509 -inform DER -in "' + String(certfile) + '" -noout -serial';
  file_name := RandomNameFile('.txt');
  file_path := path + file_name;
  pid := ejecutarComando(command, file_path);
  content_file := ReadFileTmp(file_path, 1);
  i := 9;
  while i <= Length(content_file) do
  begin
    certificateNumber := certificateNumber + content_file[i];
    Inc(i, 2);
  end;
  if (certificateNumber = '') then
  begin
    res.Add('msg', 'Error al obtener el numero del certificado');
    res.Add('status', 'false');
    res.Add('certificate', '');
    res.Add('certificateNumber', '');
    Result := res;
    Exit;
  end;

  {Obtener el contenido del certificado}
  command := 'openssl enc -base64 -A -in "' + String(certfile) + '"';
  file_name := RandomNameFile('.txt');
  file_path := path + file_name;
  pid := ejecutarComando(command, file_path);
  certificate := ReadFileTmp(file_path, 1);
  If certificate = '' Then
    begin
    res.Add('msg', 'Error al obtener el contenido del certificado');
    res.Add('status', 'false');
    res.Add('certificate', '');
    res.Add('certificateNumber', '');
    Result := res;
    Exit;
  end;

  res.Add('msg', 'Informacion extraida con exito');
  res.Add('status', 'true');
  res.Add('certificate', certificate);
  res.Add('certificateNumber', certificateNumber);
  Result := res;

end;

{ Agregar al xml, el numero de certificado y el contenido del certificado }
function Comprobante.addCertificateToXml(xml: String; cert: WideString; certNo: String): TDictionary<String, WideString>;
var
  XMLDoc : IXMLDOMDocument2;
  root: IXMLDomElement;
  objNodelist, objNodelist2: IXMLDOMNodeList;
  objNode, objNode2: IXMLDOMNode;
  res : TDictionary<String, WideString>;
  oFile : TStringlist;
  i: integer;
  newXml : WideString;
  otro: string;

begin
  res := TDictionary<string, WideString>.Create;

  if (xml = '') or (cert = '') or (certNo = '') then
  begin;
    res.Add('msg', 'Verificar los parametros enviados, se encuentran vacios');
    res.Add('status', 'false');
    Result := res;
    Exit;
  end;

  { Validar existencia del xml }
  if FileExists(xml) then
  begin
    oFile := TStringlist.Create;
    oFile.LoadFromFile(xml);
    xml := oFile.Text;
    oFile.Free;
  end;

  try
    XMLDoc := CoDOMDocument60.Create;
    XMLDoc.async := False;
    XMLDoc.setProperty('SelectionLanguage', 'XPath');
    XMLDoc.loadXML(xml);
  except
    on E : Exception do
    begin
      res.Add('msg', E.Message);
      res.Add('status', 'false');
      res.Add('newXml', '');
      Result := res;
      Exit;
    end;
  end;

  { Aplica para facturas }
  XMLDoc.setProperty('SelectionNamespaces', 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3"');
  objNodelist := XMLDoc.selectNodes('cfdi:Comprobante');
  for i := 0 to objNodelist.length - 1 do
  begin
    objNode := objNodelist.item[i];
    objNode.selectSingleNode('@certificado').Text := cert;
    objNode.selectSingleNode('@noCertificado').Text := certNo;
  end;
  //
  XMLDoc.setProperty('SelectionNamespaces', 'xmlns:retenciones="http://www.sat.gob.mx/esquemas/retencionpago/1"');
  objNodelist2 := XMLDoc.selectNodes('retenciones:Retenciones');
  for i := 0 to objNodelist2.length - 1 do
  begin
    objNode2 := objNodelist2.item[i];
    objNode2.selectSingleNode('@Cert').Text := cert;
    objNode2.selectSingleNode('@NumCert').Text := certNo;
  end;

  newXml := XMLDoc.xml;

  objNodelist := nil;
  objNode := nil;
  objNodelist2 := nil;
  objNode2 := nil;
  XMLDoc := nil;

  res.Add('msg', 'XML modificado con éxito');
  res.Add('status', 'true');
  res.Add('newXml', newXml);
  Result := res;

end;

{ Generar la cadena original del comprobante }
function Comprobante.createOriginalChain( xml: String; xslt : String ): TDictionary<String, WideString>;
var
  chain : String;
  res : TDictionary<String, WideString>;
  oFile : TStringlist;
  XMLDoc : IXMLDOMDocument;
  XSLDoc : IXMLDOMDocument;
  Template : IXSLTemplate;
  Processor : IXSLProcessor;

begin;
  res := TDictionary<string, WideString>.Create;

  if (xml = '') Or (xslt = '') then
  begin;
    res.Add('msg', 'Verificar los parametros enviados, se encuentran vacios');
    res.Add('status', 'false');
    Result := res;
    Exit;
  end;

  { Validar existencia del xml }
  if FileExists(xml) then
  begin
    oFile := TStringlist.Create;
    oFile.LoadFromFile(xml);
    xml := oFile.Text;
    oFile.Free;
  end;

  try
    XMLDoc := CoFreeThreadedDOMDocument60.Create;
    XSLDoc := CoFreeThreadedDOMDocument60.Create;
    XMLDoc.loadXML(xml);
    XSLDoc.load(xslt);
    Template := CoXSLTemplate60.Create;
    XSLDoc.async := False;
    XSLDoc.resolveExternals := True;
    XSLDoc.validateOnParse := True;
    Template.stylesheet := XSLDoc;
    Processor := Template.createProcessor;
    Processor.input := XMLDoc;
    Processor.transform;
    chain :=  Processor.output;
    if (chain = '|||') then
    begin
      res.Add('msg', 'Error al generar la cadena original, la cadena esta vacia: ' + chain);
      res.Add('status', 'false');
      Result := res;
      Exit;
    end;
    res.Add('msg', chain);
    res.Add('status', 'true');
  except
    on E : Exception do
    begin
      res.Add('msg', E.Message);
      res.Add('status', 'false');
    end;
  end;
  XMLDoc := nil;
  XSLDoc := nil;
  Result := res;
end;

{ Crear el sello del comprobante }
function Comprobante.createDigitalStamp(keyfile: String; chain: String; password: String): TDictionary<String, WideString>;
var
  res : TDictionary<String, WideString>;
  oFile : TStringlist;
  XMLDoc : IXMLDOMDocument;
  pid2, deleted: boolean;
  command, sello, file_name, file_path, path, pemfile, pid: String;

begin
  path := ExtractFilePath( Application.ExeName );
  res := TDictionary<string, WideString>.Create;
  deleted := False;

  if (keyfile = '') Or (chain = '') Or (password = '') then
  begin;
    res.Add('msg', 'Verificar los parametros enviados, se encuentran vacios');
    res.Add('status', 'false');
    Result := res;
    Exit;
  end;

  { Validar existencia del string de cadena original }
  if not FileExists(chain) then
  begin
    file_name := RandomNameFile('.txt');
    file_path := path + file_name;
    pid2 := WriteFileChain(file_path, chain);
    chain := file_path;
    deleted := True;
  end;

  { Generar PEM del archivo .key para poder sellar }
  command := 'openssl pkcs8 -inform DER -in "' + keyfile + '" -passin pass:"' + password + '"';
  file_name := RandomNameFile('.pem');
  pemfile := path + file_name;
  pid := ejecutarComando(command, pemfile);

  { Crear el sello del xml }
  command := 'openssl dgst -sha1 -sign "' + pemfile + '" "' + chain + '" | openssl enc -base64 -A';
  file_name := RandomNameFile('.txt');
  file_path := path + file_name;
  pid := ejecutarComando(command, file_path);
  sello := ReadFileTmp(file_path, 1);

  if (sello = '') then
  begin
    res.Add('msg', 'Sello vacio');
    res.Add('status', 'false');
    Result := res;
    Exit;
  end;

  { Eliminar archivos temporales }
  DeleteFile(PWideChar(pemfile));
  If deleted Then
  begin
    DeleteFile(PWideChar(chain));
  end;

  res.Add('msg', 'Sello creado con exito');
  res.Add('status', 'true');
  res.Add('sello', sello);
  Result := res;

end;

{ Agregar sello al xml }
function Comprobante.addDigitalStampToXml(xml: String; digitalStamp: String): TDictionary<String, WideString>;
var
  XMLDoc : IXMLDOMDocument2;
  root: IXMLDomElement;
  objNodelist, objNodelist2: IXMLDOMNodeList;
  objNode, objNode2: IXMLDOMNode;
  res : TDictionary<String, WideString>;
  oFile : TStringlist;
  i: integer;
  newXml : WideString;
  otro: string;

begin
  res := TDictionary<string, WideString>.Create;

  if (xml = '') or (digitalStamp = '') then
  begin;
    res.Add('msg', 'Verificar los parametros enviados, se encuentran vacios');
    res.Add('status', 'false');
    Result := res;
    Exit;
  end;

  { Validar existencia del xml }
  if FileExists(xml) then
  begin
    oFile := TStringlist.Create;
    oFile.LoadFromFile(xml);
    xml := oFile.Text;
    oFile.Free;
  end;

  try
    XMLDoc := CoDOMDocument60.Create;
    XMLDoc.async := False;
    XMLDoc.setProperty('SelectionLanguage', 'XPath');
    XMLDoc.loadXML(xml);
  except
    on E : Exception do
    begin
      res.Add('msg', E.Message);
      res.Add('status', 'false');
      res.Add('newXml', '');
      Result := res;
      Exit;
    end;
  end;

  { Aplica para facturas }
  XMLDoc.setProperty('SelectionNamespaces', 'xmlns:cfdi="http://www.sat.gob.mx/cfd/3"');
  objNodelist := XMLDoc.selectNodes('cfdi:Comprobante');
  for i := 0 to objNodelist.length - 1 do
  begin
    objNode := objNodelist.item[i];
    objNode.selectSingleNode('@sello').Text := digitalStamp;
  end;
  //
  XMLDoc.setProperty('SelectionNamespaces', 'xmlns:retenciones="http://www.sat.gob.mx/esquemas/retencionpago/1"');
  objNodelist2 := XMLDoc.selectNodes('retenciones:Retenciones');
  for i := 0 to objNodelist2.length - 1 do
  begin
    objNode2 := objNodelist2.item[i];
    objNode2.selectSingleNode('@Sello').Text := digitalStamp;
  end;

  newXml := XMLDoc.xml;

  objNodelist := nil;
  objNode := nil;
  objNodelist2 := nil;
  objNode2 := nil;
  XMLDoc := nil;

  res.Add('msg', 'XML modificado con éxito');
  res.Add('status', 'true');
  res.Add('newXml', newXml);
  Result := res;

end;


{##############################}
{##### Private functions ######}
{##############################}
function Comprobante.executeCommand(command: String; outpath: String): boolean;
var
  comm : String;
  comm2 : PAnsiChar;
  I: Integer;
  f: String;
begin
  //comm := PAnsiChar(command);
  comm :=  command + ' > ' + '"' + outpath + '"';
  comm2 := PAnsiChar(AnsiString(comm));
  //ShowMessage(comm2);
  I := WinExec( @comm2, SW_HIDE);
  f := IntToStr(I);
  Result := True;
end;

function Comprobante.ReadFileTmp(file_path: String; delete: integer): WideString;
var
  content_file : WideString;
  oFile : TStringlist;

begin
  if FileExists(file_path) then
  begin
    oFile := TStringlist.Create;
    oFile.LoadFromFile(file_path);
    content_file := oFile.Text;
    oFile.Free;
    if (delete = 1) then
    begin
      DeleteFile(PWideChar(file_path));
    end;
  end
  else
  begin
    content_file := '';
  end;
  Result := Trim(content_file);
end;

function Comprobante.WriteFileTmp(file_path: String; myText:WideString): boolean;
var
  content_file: WideString;
  oFile: TStrings;

begin
  content_file := '';

  if FileExists(file_path) then
  begin
    content_file := ReadFileTmp(file_path, 1);
    content_file := content_file + AnsiString(#13#10);
  end;

  oFile := TStringList.Create();
  oFile.Text := content_file + myText;
  oFile.SaveToFile(file_path, TUTF8Encoding.UTF8);

  Result := true;
end;

function Comprobante.WriteFileChain(file_path: String; myText:WideString): boolean;
var
  Temp: Utf8String;
  Stream: TStringStream;

begin
  Temp:= Utf8Encode (myText);
  Stream:= TStringStream.Create;
  try
    Stream.Write (Pointer (Temp) ^, Length (Temp));
    Stream.SaveToFile (file_path);
  finally
    Stream.Free;
  end;
  Result:= True;
end;

function Comprobante.RandomNameFile(extension: String): String;
var
  wAnyo, wMes, wDia: Word;
  wHora, wMinutos, wSegundos, wMilisegundos: Word;
  filename : String;
begin
  LongTimeFormat := 'hh:mm:ss.zzz';
  filename := 'tmp' + TimeToStr(Now());
  filename := StringReplace(filename, ':', '', [rfReplaceAll, rfIgnoreCase]);
  filename := StringReplace(filename, '.', '', [rfReplaceAll, rfIgnoreCase]);
  Result := filename + extension;
end;

function Comprobante.ejecutarComando (comando : String; outpath: String) : String;
var
  Buffer: array[0..4096] of Char;
  si: STARTUPINFO;
  sa: SECURITY_ATTRIBUTES;
  sd: SECURITY_DESCRIPTOR;
  pi: PROCESS_INFORMATION;
  newstdin, newstdout, read_stdout, write_stdin: THandle;
  exitcod, bread, avail: Cardinal;
  salidados: String;

begin
  Result:= '';
  comando := comando + ' > ' + '"' + outpath + '"';
  if IsWinNT then
  begin
    InitializeSecurityDescriptor(@sd, SECURITY_DESCRIPTOR_REVISION);
    SetSecurityDescriptorDacl(@sd, true, nil, false);
    sa.lpSecurityDescriptor := @sd;
  end
  else sa.lpSecurityDescriptor := nil;
  sa.nLength := sizeof(SECURITY_ATTRIBUTES);
  sa.bInheritHandle := TRUE;
  if CreatePipe(newstdin, write_stdin, @sa, 0) then
  begin
    if CreatePipe(read_stdout, newstdout, @sa, 0) then
    begin
      GetStartupInfo(si);
      with si do
      begin
        dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
        wShowWindow := SW_HIDE;
        hStdOutput := newstdout;
        hStdError := newstdout;
        hStdInput := newstdin;
      end;
      Fillchar(Buffer, SizeOf(Buffer), 0);
      GetEnvironmentVariable('COMSPEC', @Buffer, SizeOf(Buffer) - 1);
      StrCat(@Buffer,PChar(' /c ' + comando));
      if CreateProcess(nil, @Buffer, nil, nil, TRUE, CREATE_NEW_CONSOLE, nil, nil, si, pi) then
      begin
        repeat
          PeekNamedPipe(read_stdout, @Buffer, SizeOf(Buffer) - 1, @bread, @avail, nil);
          if bread > 0 then
          begin
            Fillchar(Buffer, SizeOf(Buffer), 0);
            ReadFile(read_stdout, Buffer, bread, bread, nil);
            Result:= Result + String(PChar(@Buffer));
          end;
          Application.ProcessMessages;
          GetExitCodeProcess(pi.hProcess, exitcod);
        until (exitcod <> STILL_ACTIVE) and (bread = 0);
      end;
      CloseHandle(read_stdout);
      CloseHandle(newstdout);
    end;
    CloseHandle(newstdin);
    CloseHandle(write_stdin);
  end;
end;

function Comprobante.IsWinNT: boolean;
var
  OSV: OSVERSIONINFO;
begin
  OSV.dwOSVersionInfoSize := sizeof(osv);
  GetVersionEx(OSV);
  result := OSV.dwPlatformId = VER_PLATFORM_WIN32_NT;
end;

end.
