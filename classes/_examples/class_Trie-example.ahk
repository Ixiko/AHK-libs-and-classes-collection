#Include %A_ScriptDir%\..\Class_Trie.ahk
#persistent
SetBatchLines, -1
CoordMode, Mouse, Screen

Entries := new Trie(500, "Autohotkey")

BackgroundColor := "C6D43C"
WM_SETREDRAW := 0x0B

Gui, 1:New
Gui, 1:+AlwaysOnTop +ToolWindow -SysMenu -Caption +HwndGuiHwnd +LastFound ; +E0x08000000
Gui, 1:Color, %BackgroundColor%

Gui, 1:Font, s15
Gui, 1:Margin, 0, 0, 0, 0
Gui, 1:Add, Edit, vAddress gSearch w300
Gui, 1:Add, ListBox, vSuggestions w300 h200 +HwndCtrlHwnd

WinSet, TransColor, %BackgroundColor%

AddDict()
return

#s::
	MouseGetPos, x, y
	Gui, Show, % "x" x " y" y " AutoSize"
return

AddDict() {
	Global Entries
	lst := StrSplit(FileOpen(A_ScriptDir "\English British.txt", "r").Read(), "`n")

	len := Round(lst.Length() / 100)

	for index, line in lst {
		if(!mod(index, len)) {
			ToolTip, % Format("{:02.1d}", (index / lst.Length())*100)
		}
		Entries.__Set(Format("{:L}", (pos := InStr(line, "/")) ? SubStr(line, 1, pos - 1) : RegExReplace(line, "`n|`r")), "")
	}
	ToolTip
}

#If WinActive("ahk_id " GuiHwnd)
	Enter::
		Gui, Submit, NoHide
		Entries.__Set(Address, "")
		Goto, Search
	return

	Delete::
		Gui, Submit, NoHide
		Entries.remove(Address)
		Goto, Search
	return
#If

Search:
	Gui, Submit, NoHide
	GuiControl, -Redraw, Suggestions
	GuiControl, , Suggestions, % "|" __Join("|", Entries[Address])
	GuiControl, +Redraw, Suggestions
Return