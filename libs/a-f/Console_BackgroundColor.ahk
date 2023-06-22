#NoEnv
SetBatchLines, -1

; Hintergrundfarbe der Konsole ändern
SetConsoleBackgroundColor(0x0000FF) ; Blaue Hintergrundfarbe (Beispiel)

ExitApp

; Funktion zum Ändern der Hintergrundfarbe der Konsole
SetConsoleBackgroundColor(color) {
    VarSetCapacity(consoleInfo, 16, 0)
    hConsoleOutput := DllCall("GetStdHandle", "UInt", -11)
    DllCall("GetConsoleScreenBufferInfo", "Ptr", hConsoleOutput, "Ptr", &consoleInfo)
    oldAttributes := NumGet(consoleInfo, 4, "UShort")
    newAttributes := (oldAttributes & 0xFFF0) | (color & 0x000F)
    DllCall("SetConsoleTextAttribute", "Ptr", hConsoleOutput, "UShort", newAttributes)
}
