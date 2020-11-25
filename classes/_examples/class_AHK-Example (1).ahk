DetectHiddenWindows, On ;required for Embedding Console.. If not used, then add style 0x2000000 manually

#Include, Console.ahk

MyConsole := new Console()
Gui, +LastFound ;+0x2000000 if DetectHiddenWindows is off
MyConsole.EmbedConsole(WinExist(), 10, 25)
ConsoleHWnd := DllCall("GetConsoleWindow")
WinGetPos,,, W, H, % "ahk_id" ConsoleHWnd
Gui, Add, Tab, % "h" H " w" W " +Theme gChangeBuffer vBufferVal", Buffer1|Buffer2|Buffer3
Gui, Tab
Gui, Add, Edit, % "w" W-115 " xp y" H+35 " section vLine"
Gui, Add, Button, ys w100 gAddLine, Add line
Gui, Show

Buffer1 := MyConsole.GetStdHandle()
Buffer2 := MyConsole.CreateConsoleScreenBuffer()
Buffer3 := MyConsole.CreateConsoleScreenBuffer()
return

AddLine:
Gui, Submit, Nohide
MyConsole.WriteLine(Line)
return

ChangeBuffer:
Gui, Submit, Nohide
MyConsole.SetConsoleActiveScreenBuffer(%BufferVal%)
MyConsole.SetStdHandle(-11, %BufferVal%)
ConsoleHWnd := DllCall("GetConsoleWindow")
DllCall("SetWindowPos", "int", ConsoleHWnd, "int", 0, "int", 10, "int", 25, "int", 660, "int", 300, "int", 0x4000)
DllCall("MoveWindow", "int", ConsoleHWnd, "int", 10, "int", 25, "int", W, "int", H, "int", 1)
return

GuiClose:
esc::
ExitApp
