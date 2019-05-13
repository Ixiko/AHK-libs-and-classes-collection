

[Code]
const
	miniframwork0200url = 'http://bigbytetech.ca/files/Software/mini-framwork/0200/MfSetup.exe';
  mfsoftwarekey_reg = 'Software\Mini-Framwork\';
  type
    MfVersions = (v0200);

function mfinstalled(MfVersion: MfVersions): boolean;
var
  MyResult: boolean;
begin
    MyResult := False;
    case MfVersion of            
      v0200:
        if RegKeyExists(HKLM, mfsoftwarekey_reg + '0.2.0') then
        begin
          MyResult := True;
        end;
    end;

    Result := MyResult;
end;