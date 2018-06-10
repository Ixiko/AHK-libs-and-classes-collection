; ===============================================================================================================================
; Read last x lines of a text file
; ===============================================================================================================================

FileReadLastLines(FileName, LastLines := 5)
{
    if (IsObject(file := FileOpen(FileName, "r-d", "UTF-8"))) {
        CountLines := LinesCount := 0, GetLine := GetLines := ""
        while !(file.AtEOF)
            file.ReadLine(), CountLines++
        file.Seek(0)
        while !(file.AtEOF) {
            GetLine := file.ReadLine()
            if (LinesCount >= CountLines - LastLines)
                GetLines .= GetLine
            LinesCount++
        }
        return GetLines, file.Close()    
    }
    return false
}

; ===============================================================================================================================

MsgBox % FileReadLastLines("C:\TEMP\MyLogFile.log", 10)