#Include %A_ScriptDir%\..\CryptBy_nnik.ahk

c:=encryptstr("Baba","ahk_class nnikMasterClass")
d:=encryptstr("Babo","ahk_class nnikMasterClass")
Msgbox % c "  " decryptstr(c,"ahk_class OptoAppClass") "`n" d "    " decryptstr(d,"ahk_class OptoAppClass") 