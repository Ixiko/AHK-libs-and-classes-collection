;http://ahkscript.org/boards/viewtopic.php?f=5&t=3583
#include %A_ScriptDir%\..\class_LoaderBar.ahk
#SingleInstance, Force
SetBatchLines,-1
SetWinDelay,0
Gui, load_BarGUI:-Border -Caption +ToolWindow
Gui, load_BarGUI:Color, 0x4D4D4D, 0xFFFFFF
load_Bar := new LoaderBar("load_BarGUI",3,3,280,28,1,"EFEFEF")
wW:=load_Bar.Width + 2*load_Bar.X
wH:=load_Bar.Height + 2*load_Bar.Y
Gui, load_BarGUI:Show, w%wW% h%wH%


FileList:=Object()
Loop %A_WinDir%\System32\*.dll
  if (A_Index>=100)
	break
  else
	FileList.Insert(A_LoopFileLongPath "`n")

Percent:=0
while (Percent<100)
{
	Percent:=(Percent>=100) ? Percent:=100 : Percent+0.25
	utext := "Loading: " FileList[Round(Percent,0)]
	load_Bar.Set(Percent,utext)
	Sleep, 25
}
load_Bar.Set(100,"Done.")
Sleep 500
MsgBox Done!
Exitapp