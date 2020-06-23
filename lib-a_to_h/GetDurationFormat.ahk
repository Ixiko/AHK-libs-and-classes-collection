; Link:   	https://github.com/jNizM/htopmini/blob/master/src/htopmini.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

GetDurationFormat(ullDuration, lpFormat := "d'd 'hh:mm:ss")
{
    VarSetCapacity(lpDurationStr, 128, 0)
    DllCall("Kernel32.dll\GetDurationFormat", "UInt",  0x400
                                            , "UInt",  0
                                            , "Ptr",   0
                                            , "Int64", ullDuration * 10000000
                                            , "WStr",  lpFormat
                                            , "WStr",  lpDurationStr
                                            , "Int",   64)
    return lpDurationStr
}
