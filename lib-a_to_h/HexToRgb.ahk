; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/HexToRgb.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

HexToRgb(hex)
{
    return { "r": Format("{:i}", 0xff & (hex >> 16))
            ,"g": Format("{:i}", 0xff & (hex >> 08))
            ,"b": Format("{:i}", 0xff & (hex >> 00)) }
}