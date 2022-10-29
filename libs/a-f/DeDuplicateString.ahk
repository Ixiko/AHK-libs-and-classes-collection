; https://www.autohotkey.com/boards/viewtopic.php?f=7&t=29232#p137390
DeduplicateString(String, Delimiter := "`n", CaseSensitivity := False, Sort := False) {
    Output := ""
    VarSetCapacity(Output, StrLen(String) * 2 * 2)

    If (!CaseSensitivity) {
        Array := {}
        StrReplace(String, Delimiter,, Count)
        Array.SetCapacity(Count + 1)
        If (Sort)
            Sort, String, D%Delimiter%
        Loop Parse, String, % Delimiter
            ; Z is used to avoid creating a key with the same name as a method.
            If (!Array.HasKey("Z" . A_LoopField))
                Array["Z" . A_LoopField] := True, Output .= A_LoopField . Delimiter
    }
    Else {
        Array := ComObjCreate("Scripting.Dictionary")
        If (Sort)
            Sort, String, CS D%Delimiter%
        Loop Parse, String, % Delimiter
            If (!Array.Exists("" . A_LoopField))
                Array.Item["" . A_LoopField] := True, Output .= A_LoopField . Delimiter
    }

    Array := ""
    Return RTrim(Output, Delimiter)
}

String := "f,e,d,C,B,A,a,b,c,A,B,C"
MsgBox,,, % DeduplicateString(String, ",", False, True)
