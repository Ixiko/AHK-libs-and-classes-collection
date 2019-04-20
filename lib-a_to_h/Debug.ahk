debug(msg, delimiter = False) {
    global debugfile, s_name
    if (!s_name)
        s_name := A_ScriptName
    static stdout, ft := True ; First time.
    
    args := arg()
    for index, arg in args
        parameters .= (A_Index > 1 ? arg . " " : "")
        
    file := Exception("", -1).File
    SplitPath, file, fileName
    msg := fileName . ":" . Exception("", -1).Line . " - " . msg
    
    if (ft)
        stdout := FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")

    t := delimiter = 1 ? msg := "* ----------------------------------------`n" . msg
    t := delimiter = 2 ? msg := msg . "* ----------------------------------------`n"
    t := delimiter = 3 ? (msg := "* ----------------------------------------`n" . msg
                                       .   "`n* ----------------------------------------")
    t := delimiter = 4 ? (msg := "* " . s_name . " Debug OFF`n* " . s_name . "[Stop]`n"
                                       . "* ----------------------------------------`n")
    if (!debugfile) {
        ft ? (msg := "* ----------------------------------------`n"
                                       .   "* " . s_name . " Debug ON`n* " . s_name . "[Start]`n"
                                       .   "* Parameters: " . parameters "`n" . msg, ft := 0)
        OutputDebug % msg
        stdout.Write(msg . "`n")
        stdout.Read(0) ; Flush the write buffer.
    }                           
    else if (debugfile) {
        ft ? (msg := "* ----------------------------------------`n"
                      .   "* " . s_name . " Debug ON`n* " . s_name . "[Start]`n"
                      .   "* Parameters: " . parameters . "`n" . msg, ft := 0)         
        FileAppend, %msg%`n, %debugfile%
    }
}

arg() {
    Loop, % (arg := {0: %false%}) [0]
        arg[A_Index] := %A_Index%
    return arg
}