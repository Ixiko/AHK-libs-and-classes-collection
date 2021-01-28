; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/GetYIQ.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

GetYIQ(n)
{
    r := 0xff & (n >> 16)
    g := 0xff & (n >>  8)
    b := 0xff & (n >>  0)

    return ((( (r*299) + (g*587) + (b*114) ) / 1000) >= 128) ? "Black" : "White"
}