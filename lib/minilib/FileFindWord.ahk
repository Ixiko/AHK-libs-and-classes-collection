; ===============================================================================================================================
; Find specific words in a text file
; ===============================================================================================================================

FileFindWord(FileName, Search)
{
    if (IsObject(file := FileOpen(FileName, "r-d", "UTF-8"))) {
        Found := []
        while !(file.AtEOF)
            if (InStr(GetLine := file.ReadLine(), Search))
                Found[A_Index] := GetLine
        return Found, file.Close()
    }
    return false
}

; ===============================================================================================================================

for i, v in FileFindWord("C:\TEMP\MyLogFile.log", "Hello World")
    MsgBox % "Line: " i "`n" v