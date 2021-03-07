; Title:   	Append text to an Edit control
; Link:   	http://www.autohotkey.com/forum/viewtopic.php?t=56717
; Author:	TheGood
; Date:
; for:     	AHK_L

/*


*/

InsertText(hEdit, ptrText, iPos = -1) {

    If (iPos = -1) {
        SendMessage, 0x000E, 0, 0,, ahk_id %hEdit% ;WM_GETTEXTLENGTH
        iPos := ErrorLevel
    }

    SendMessage, 0x00B1, iPos, iPos,, ahk_id %hEdit% ;EM_SETSEL
    SendMessage, 0x00C2, False, ptrText,, ahk_id %hEdit% ;EM_REPLACESEL
}

