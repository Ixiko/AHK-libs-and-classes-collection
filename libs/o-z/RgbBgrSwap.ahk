; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RgbBgrSwap.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

RgbBgrSwap(n)
{
    return (0xff & (n >> 16)) << 0 | (0xff & (n >>  8)) << 8 | (0xff & (n >>  0)) << 16
}