; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RgbToHex.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RgbToHex(r,g,b)
{
    return Format("0x{:02X}{:02X}{:02X}", r, g, b)
}