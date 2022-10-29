#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
Gui, Add, GroupBox, x6 y7 w230 h380 , CB_*() Example
Gui, Add, DropDownList, x16 y27 w210 h20 r15, % "Test||" Range("a","z",1,"|") . "|" . Range(1,50,1,"|")
Gui, Add, Button, x16 y57 w100 h20 gGet, CB_Get()
Gui, Add, Button, x126 y57 w100 h20 gSet, CB_Set()
Gui, Add, Edit, x16 y87 w100 h20 vAdd, String to Add
Gui, Add, Button, x126 y87 w100 h20 gAdd, CB_Add()
Gui, Add, Edit, x16 y117 w100 h20 vInsert, String to Insert
Gui, Add, Button, x126 y117 w100 h20 gInsert, CB_Insert()
Gui, Add, Edit, x16 y147 w100 h20 vModify, String to be Modified
Gui, Add, Button, x126 y147 w100 h20 gModify, CB_Modify()
Gui, Add, Edit, x16 y177 w100 h20 vFind, String to Find
Gui, Add, Button, x126 y177 w100 h20 gFind, CB_Find()
Gui, Add, Edit, x16 y207 w100 h20 vSelect, String to Select
Gui, Add, Button, x126 y207 w100 h20 gSelect, CB_Select()
Gui, Add, Button, x16 y237 w210 h20 gGetCount, CB_GetCount()
Gui, Add, Button, x16 y267 w210 h20 gGetText, CB_GetText()
Gui, Add, Button, x16 y297 w210 h20 gGetTexts, CB_GetTexts()
Gui, Add, Button, x16 y327 w100 h20 gShow, CB_Show()
Gui, Add, DropDownList, x126 y327 w100 h20 r2 vShow, True||False
Gui, Add, Button, x16 y357 w210 h20 gReset, CB_Reset()
Gui, Show, w246 h397
Return

GuiClose:
ExitApp

Get:
MsgBox % CB_Get()
Return

Set:
InputBox, OutputVar,44, Type Position to be set,, 150, 120,,,,,0
CB_Set(OutputVar)
Return

Add:
Gui, Submit, NoHide
CB_Add(Add)
Return

Insert:
Gui, Submit, NoHide
CB_Insert(Insert)
Return

Modify:
Gui, Submit, NoHide
CB_Modify(Modify)
Return

Find:
Gui, Submit, NoHide
MsgBox % CB_Find(Find) ;CB_FindExact() is available too
Return

Select:
Gui, Submit, NoHide
CB_Select(Select) ;equivalent to (GuiControl, ChooseString, ControlID, String)
Return

GetCount:
MsgBox % CB_GetCount()
Return

GetText:
MsgBox % CB_GetText()
Return

GetTexts:
MsgBox % CB_GetTexts("|") ;custom delimiter
Return

Show:
Gui, Submit, NoHide
Flag := (Show=="True") ? 1 : 0
CB_Show(Flag)
Return

Reset:
CB_Reset()
Return


;http://www.autohotkey.com/forum/viewtopic.php?t=33958#209490
;function by Titan
range(x, y = "", c = 1, d = ",") {
	If (!a := x | 1)
		x := Asc(x), y := Asc(y)
	Loop, % (y == (a ? "" : 0) ? (y := x) - x := x > 96 ? 97 : x > 64 ? 65 : 1 : y - x) // c + 1
		r .= d . (a ? x : Chr(x)), x += c
	Return, SubStr(r, 1 + StrLen(d))
}