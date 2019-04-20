; #Include FileExtract.ahk
#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%

; Self-compiling Example Script (not Unicode-compatible) by Lexikos

if !A_IsCompiled
{   ; Self-compile-and-run.
    RunWait, %A_AhkPath%\..\Compiler\Ahk2Exe.exe /in "%A_ScriptFullPath%"
    Run % SubStr(A_ScriptFullPath, 1, InStr(A_ScriptFullPath,".",1,0)-1) ".exe"
    ExitApp
   
    ; Not executed by AutoHotkey, but interpreted by Ahk2Exe:
    FileInstall, FileExtract_Demo.ahk, ~
}

Menu, Tray, MainWindow

VarSetCapacity(important, 40, Asc("="))
GuiOut(important " Actual Script")

; Initialize pData since it has no value yet:
pData := 0
; DataSize specifies the desired initial size of the buffer, or zero for "don't care".
DataSize := 0

; The script itself is either >AUTOHOTKEY SCRIPT< or >AHK WITH ICON<.
if FileExtract_ToMem(">AUTOHOTKEY SCRIPT<", pData, DataSize)
    || FileExtract_ToMem(">AHK WITH ICON<", pData, DataSize)
{   ; Show the string data in a GUI.
    GuiOut(GetStrN(pData, DataSize))
}
else
{   ; Note: At this point, AutoHotkey has probably already shown an error dialog.
    GuiOut("-- Failed! --")
}

GuiOut(important " FileExtract_Demo.ahk")

; Extract a FileInstall'd file.
if FileExtract_ToMem("FileExtract_Demo.ahk", pData, DataSize)
{
    GuiOut(GetStrN(pData, DataSize))
}
else
{
    GuiOut("-- Failed! --")
}

; Free the buffer.
DllCall("GlobalFree", "uint", pData)

return

GuiOut(Text, GuiNum=37) {
    static GuiText
    Gui, %GuiNum%: Default
    if (GuiText = "") {
        GuiText := Text "`n"
        Gui, Font,, Courier New
        Gui, Add, Edit, ReadOnly W600 H400, %GuiText%
    } else
        GuiControl,, Edit1, % GuiText .= Text "`n"
    Gui, Show
    Gui, +LastFound +LabelGuiOut
    ControlSend, Edit1, ^{End}
    return
    GuiOutClose:
    GuiOutEscape:
    ExitApp
}

GetStrN(Pointer, Length) {
    VarSetCapacity(String, Length)
    DllCall("lstrcpyn", "str", String, "uint", Pointer, "int", Length+1)
    return String
}