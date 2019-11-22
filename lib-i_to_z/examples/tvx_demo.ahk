#NoEnv
#SingleInstance force

	gosub CreateGui
	gosub FillTV


	TVX("MyTree", "Handler", "HasRoot CollapseOnMove ", "aTooltip")		;!!!!!
	Gui, Show, h410 w430
return


Handler:
	if A_GuiEvent = S
		Tooltip % aTooltip%A_EventInfo%, 0, 0
return

;-------------------------------------------------------------------------------

Save:
	TVX_Walk(root, "SaveHandler", Event, Item)
return

SaveHandler:
	TV_GetText(txt, Item)
	if Event = +
	{
		FileDelete, _out.txt
		FileAppend %txt%`n, _out.txt
		line := "|-"
	}

	if Event = E
		StringTrimRight, line, line, 2

	if Event in I,M
	{
		FileAppend %line%%txt%, _out.txt
		FileAppend % "    " aTooltip%item% "`n", _out.txt
	}

	if Event = M
		line .= "--"

	if Event = -
	  	Msgbox, TVX saved in _out.txt
return

;---------------------------------------------------------------------------------

OnButton:
    ControlSend, SysTreeView321, {SHIFT down}
	ControlSend, SysTreeView321, {%A_GuiControl%}
	sleep 50
    ControlSend, SysTreeView321, {SHIFT up}

;	h := TVX_Move(TV_GetSelection(), A_GuiControl="Up" ? "u" : "d")
;   TV_Modify(h, "Select")
return

Modify:

	if A_GuiControl=Delete
	    ControlSend, SysTreeView321, {DELETE}

	if A_GuiControl=Insert
	    ControlSend, SysTreeView321, {INSERT}

	if A_GuiControl=Insert Submenu
	{
	    ControlSend, SysTreeView321, {SHIFT down}
	    ControlSend, SysTreeView321, {INSERT}
		Sleep 50
	    ControlSend, SysTreeView321, {SHIFT up}
	}
return

;---------------------------------------------------------------------------------

FillTV:
	root  := TV_Add("Root", "" , "Expand")
	TV_Modify( root, "", A_Index "    " root)
	loop, 10 {
		P     := TV_Add("", root)
		TV_Modify( P, "", A_Index "    " P)
		aTooltip%P% := "My Tooltip " A_Index
	}


	P2  := TV_Add("", P),		aTooltip%P2% := "My Tooltip 2.1"
	TV_Modify( P2, "", "2.1    " P2)

	P2   := TV_Add("", P), 		aTooltip%P2% := "My Tooltip 2.2"
	TV_Modify( P2, "", "2.2    " P2)

	P3   := TV_Add("", P2),		aTooltip%P3% := "My Tooltip 2.2.1"
	TV_Modify( P3, "", "2.2.1    " P3)

	P3   := TV_Add("", P2),		aTooltip%P3% := "My Tooltip 2.2.2"
	TV_Modify( P3, "", "2.2.2   " P3)

	P3   := TV_Add("", P2),		aTooltip%P3% := "My Tooltip 2.2.3"
	TV_Modify( P3, "", "2.2.3    " P3)
return

;---------------------------------------------------------------------------------

CreateGui:
	Gui, Add, TreeView, h400 w300 vMyTree
	Gui, Add, Button, w100 gOnButton x+10 , Up
	Gui, Add, Button, wp gOnButton,Down

	Gui, Add, Button, y+20 wp gModify, Insert
	Gui, Add, Button, wp gModify, Insert Submenu

	Gui, Add, Button, y+20 wp gModify, Delete

	Gui, Add, Edit, y+50 wp vMyEdit gEdit,
	Gui, Add, Text, yp-30 wp, Change tooltip for selection

	Gui, Add, Button, y+150 w100 gSave, Save to file
return

;---------------------------------------------------------------------------------

Edit:
	 Gui, Submit, Nohide
	 c := TV_GetSelection()
	 aTooltip%c% := MyEdit
return

GuiClose:
GuiEscape:
	 ExitApp
return

#include %A_ScriptDir%\..\tvx.ahk