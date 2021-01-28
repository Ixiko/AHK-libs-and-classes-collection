; Link:
; Author:
; Date:
; for:     	AHK_L

/*


*/

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

DebugWindowHelp=
(Join`r`n
Debug console commands are:
  >Clear
  >CloseOutput
  >Exit
  >set debug level 0
  >set debug level 1
  >set debug level 2
  >set debug level 3
  >set debug level 4
  >set debug level 5
  >get debug level
Press ENTER for the command prompt
)

D:=new Debug
D.InitDebugWindow()
D.WriteNL(DebugWindowHelp)
D.WriteNL("Example of writing text to the debug window")
MsgBox Enter commands in the debug console, then press OK to terminate
D.CloseOutput()
ExitApp

Enter::
D.OnEnter()



#include class_DebugWindow.ahk