/* http://ahkscript.org/boards/viewtopic.php?f=9&t=503&p=4648#p4263
## Funktion: SetEditPlaceholder
## Beschreibung: Setzt einen Platzhalter für ein Edit-Feld. Dieser ist nur sichtbar, solange nichts in dem Feld steht. Entspricht dem Attribut placeholder in HTML.
## Parameter:
# control: Entweder ein HWND oder die zugewiesene Variable (als String!) des Steuerelements.
# string: Der Text, der als Platzhalter im Steuerelement stehen soll.
# showalways: Bestimmt, ob der Text auch angezeigt werden soll, während das Steuerelement Fokus hat. Standard: 0 (deaktiviert)
## return: "" (kein besonderer Wert)
*/

SetEditPlaceholder(control, string, showalways = 0){
    if control is not number
        GuiControlGet, control, HWND, %control%
    if(!A_IsUnicode){
        VarSetCapacity(wstring, (StrLen(wstring) * 2) + 1)
        DllCall("MultiByteToWideChar", UInt, 0, UInt, 0, UInt, &string, Int, -1, UInt, &wstring, Int, StrLen(string) + 1)
    }
    else
        wstring := string
    DllCall("SendMessageW", "UInt", control, "UInt", 0x1501, "UInt", showalways, "UInt", &wstring)
    return
}