; ===============================================================================================================================
; Count the number of lines in a text file
; ===============================================================================================================================

FileCountLines(FileName)
{
    if (IsObject(file := FileOpen(FileName, "r-d", "UTF-8"))) {
        CountLines := 0
        while !(file.AtEOF)
            file.ReadLine(), CountLines++
        return CountLines, file.Close()
    }
    return false
}

; ===============================================================================================================================

MsgBox % FileCountLines("C:\TEMP\MyLogFile.log")