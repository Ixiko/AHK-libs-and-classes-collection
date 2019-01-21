SetWorkingDir %A_ScriptDir%
#NoEnv
#Include <MinHook>

Gui, Font, s12
Gui, Add, Activex, w400 h100 vdoc, MSHTML:<input type="file" id="file1" />
Gui, Add, Button, gSetInputFile Default, Set Input File
Gui, Show
Return

SetInputFile:
	hook1 := New MinHook("comdlg32.dll", "GetOpenFileNameW", "GetOpenFileName_Hook")
	hook1.Enable()

	fPath := "C:\1.jpg"
	doc.getElementById("file1").Click()
Return

GetOpenFileName_Hook(ofn) {
	global hook1, fPath
	NumPut(&fPath, ofn+0, (A_PtrSize=8) ? 48 : 28, "UInt")
	return true, hook1 := ""
}

GuiClose:
ExitApp