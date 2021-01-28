; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/HexToDecColor.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

HexToDecColor(hex)
{
    return Format("{:i},{:i},{:i}", 0xff & (hex >> 16)
                                  , 0xff & (hex >>  8)
                                  , 0xff & (hex >>  0))
}