; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/PauseOtherScripts.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

PauseOtherScripts()
{
    O_DetectHiddenWindows := A_DetectHiddenWindows
    DetectHiddenWindows, On

    WinGet, list, List, ahk_class AutoHotkey

    Loop, % list
        if (list%A_Index% != A_ScriptHWND)
            DllCall("PostMessage", "Ptr", list%A_Index%, "UInt", 0x111, "Ptr", ID_FILE_PAUSE := 65403, "Ptr", 0)

    DetectHiddenWindows, % O_DetectHiddenWindows
    return
}