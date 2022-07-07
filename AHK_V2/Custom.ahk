EmuleMsg(intext) {
    ; MsgBox IM IN!
    Loop Parse intext, "`n"
    {
        If (A_Index = 1) {
            emuleSingleLine := A_LoopField
        }
    }
    
    Loop Parse emuleSingleLine, A_Tab
    {
        If (A_Index <= 2) {
            emuleFinalVar .= A_LoopField . "`r`n`r`n"
        }
        If (A_Index = 3)
        {
            emuleFinalVar .= "Sources: " . A_LoopField . "`r`n"
        }
        If (A_Index = 4) {
            emuleFinalVar .= "Complete: " . A_LoopField . "`r`n"
        }
        If (A_Index = 5) {
            emuleFinalVar .= "Type: " . A_LoopField . "`r`n"
        }
        If (A_Index = 6) {
            emuleFinalVar .= "FileID: " . A_LoopField . "`r`n"
        }
        If (A_Index = 7) {
            emuleFinalVar .= "Artist: " . A_LoopField . "`r`n"
        }
        If (A_Index = 8) {
            emuleFinalVar .= "Album: " . A_LoopField . "`r`n"
        }
        If (A_Index = 9) {
            emuleFinalVar .= "Title: " . A_LoopField . "`r`n"
        }
        If (A_Index = 10) {
            emuleFinalVar .= "Length: " . A_LoopField . "`r`n"
        }
        If (A_Index = 11) {
            emuleFinalVar .= "Biterate: " . A_LoopField . "`r`n"
        }
        If (A_Index = 12) {
            emuleFinalVar .= "Codec: " . A_LoopField . "`r`n"
        }
        If (A_Index = 13) {
            emuleFinalVar .= "Folder: " . A_LoopField . "`r`n"
        }
        If (A_Index = 14) {
            emuleFinalVar .= "Known: " . A_LoopField . "`r`n"
        }
        If (A_Index = 15) {
            emuleFinalVar .= "AICH Hash: " . A_LoopField . "`r`n"
        }
    }
    
    If (StrLen(emuleFinalVar) < 10) {
        emuleFinalVar := "Blank data returned." . "`r`n" . "Activate function before tooltip kicks in."
    }
    
    return emuleFinalVar
}