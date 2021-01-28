; ----------------------------------------------------------------------------------------------------------------------
; Function .....: IniParser
; Description ..: Parse ini files and return an array of objects.
; Parameters ...: sFile - Path to the file to parse.
; Return .......: Array of object (__SECTION and relative keys as properties).
; AHK Version ..: AHK_L x32/64 Unicode
; Author .......: Cyruz - http://ciroprincipe.info
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Jun. 28, 2013 - ver 0.1 - First revision
; ----------------------------------------------------------------------------------------------------------------------
IniParser(sFile) {
    arrSection := Object(), idx := 0
    Loop, READ, %sFile%
        If ( RegExMatch(A_LoopReadline, "S)^\s*\[(.*)\]\s*$", sSecMatch) )
            ++idx, arrSection[idx] := Object("__SECTION", sSecMatch1)
        Else If ( RegExMatch(A_LoopReadLine, "S)^\s*(\w+)\s*\=\s*(.*)\s*$", sKeyValMatch) )
            arrSection[idx].Insert(sKeyValMatch1, sKeyValMatch2)
    Return arrSection
}

/* EXAMPLE CODE:
obj := IniParser("test.ini")
For idx, item in obj
    For k, v in item
        If (k == "__SECTION")
            MsgBox, Ini Section: %v%
        Else
            MsgBox, % k . " - " . v 
Return
*/