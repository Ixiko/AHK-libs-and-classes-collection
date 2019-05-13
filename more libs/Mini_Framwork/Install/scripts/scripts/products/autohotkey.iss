
[CustomMessages]
autohotkey_title=AutoHotkey
autohotkey_size=7 MB - 15 MB


[Code]
const
	autohotkey_url = 'http://www.autohotkey.com/download/ahk-install.exe';

procedure autohotkey(MinVersion: string);
var
	version: string;
  add_product: boolean;
begin
  add_product := True;
	if RegQueryStringValue(HKLM, 'Software\AutoHotkey', 'Version', version) then
  begin
    if (compareversion(MinVersion, version) < 0) then
    begin
      add_product := False;
    end
  end;
	if (add_product = True) then
  begin
		AddProduct('AutoHotkey.exe',
			'/S',
			CustomMessage('autohotkey_title'),
			CustomMessage('autohotkey_size'),
			autohotkey_url,
			false, false);
  end;
end;