; Link:   	https://github.com/Vismund-Cygnus/AutoHotkey/blob/37c4da39274ec14b53e9c0712cd75f09879ac368/Functions/RegEx%20Functions/RegExSplit.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

/* EXAMPLE
    str := "this.abc, bufferBytes := 4, this.hProc := this.OpenProcess(), bufferAddress := this.OpenBuffer(bufferBytes), this.SendMsg(this.hwndNpp, this.NPPMSG + 4, bufferBytes, bufferAddress), stringresult := this.ReadBuffer(bufferAddress, bufferBytes), this.CloseBuffer(bufferAddress), this.CloseProcess(), return NumGet(&stringresult, ""UInt"")}, this.that"
    for e, part in RegExSplit(str, "\w+\.(\w+)", 0, 0x3) {
        out .= "[" e "] - " part "`n"
    }
    MsgBox, % SubStr(out, 1, -1)
    return
*/
#Include %A_LineFile%\..\RegExMatchAll.ahk

RegExSplit(haystack, regex, limit := -1, flags := 0x0) {
      NO_EMPTY       := (flags & 0x1)
    , DELIM_CAPTURE  := (flags & 0x2)
    , OFFSET_CAPTURE := (flags & 0x4)

    if !(RegExMatchAll(haystack, regex, matches, 0x2))
        return [haystack]

    if (DELIM_CAPTURE)
        rgx := RegExOptions(regex, "O") ")" regex

    offset := 1, outArray := []

    for #, match in matches[0] {
        matchStr := match[1], matchPos := match[2], matchLen := StrLen(matchStr)

        partLen := matchPos - offset

        partStr := SubStr(haystack, offset, partLen)

        if !(NO_EMPTY && !StrLen(partStr))
            outArray.Push(OFFSET_CAPTURE ? [partStr, offset] : partStr)

        if (DELIM_CAPTURE && RegExMatch(matchStr, rgx, subs)) {
            while (sub := subs[A_Index]) {
                if !(NO_EMPTY && !StrLen(sub)) {
                    if (OFFSET_CAPTURE) {
                        subPos := (InStr(subs[0], sub) - 1)
                        val := [sub, offset + partLen + subPos]
                    } else {
                        val := sub
                    }
                    outArray.Push(val)
                    delims++
                }
            }
        } else delims := 0

        offset += partLen + matchLen

        count := outArray.Count() - delims

        if (count + 1 = limit)
            break
    }

    offset := matchPos + matchLen

    partStr := SubStr(haystack, offset)

    if !(NO_EMPTY && !StrLen(partStr))
        outArray.Push(OFFSET_CAPTURE ? [partStr, offset] : partStr)

    return outArray
}