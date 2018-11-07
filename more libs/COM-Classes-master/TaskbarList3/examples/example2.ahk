/*
Example: Demonstrates the usage of *TaskbarList3.ahk*
	* Creation and Usage of TaskBarButtons (shown on Preview window when hoovering over TaskBarEntry)

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Server 2008 R2 or higher
	Classes - _CCF_Error_Handler_, CCFramework, Unknown, TaskbarList, TaskbarList2, TaskbarList3, StructBase, THUMBBUTTON, IDI, THUMBBUTTONMASK, THUMBBUTTONFLAGS
*/

#SingleInstance force
#include ..\..\_CCF_Error_Handler_.ahk
#include ..\..\CCFramework.ahk
#Include ..\..\Unknown\Unknown.ahk
#include ..\..\TaskbarList\TaskbarList.ahk
#include ..\..\TaskbarList2\TaskbarList2.ahk
#include ..\TaskbarList3.ahk
#Include ..\..\Structure Classes\StructBase.ahk
#include ..\..\Constant Classes\IDI.ahk
#include ..\..\Structure Classes\THUMBBUTTON.ahk
#include ..\..\Constant Classes\THUMBBUTTONMASK.ahk
#include ..\..\Constant Classes\THUMBBUTTONFLAGS.ahk

OnExit GuiClose
OnMessage(0x111, "WM_COMMAND") ; monitor clicks on buttons

Gui, Add, Text,, Hover over Taskbar Symbol`nand mind the Buttons...
Gui +LastFound
hGui := WinExist() ; get window handle
Gui Show, h100 ; show gui

tbl := new TaskbarList3() ; create instance
tbl.HrInit() ; init instance

il := IL_Create() ; create imagelist
IL_Add(il, A_WinDir "\system32\shell32.dll", 42) ; add 1 icon to imagelist
tbl.ThumbBarSetImageList(hGui, il) ; set imagelist for ThumbBar

buttons := []
Loop 6
{
	b := new THUMBBUTTON()
	b.szTip := "This is button #" . A_Index . "."
	b.iId := A_Index
	b.dwMask := THUMBBUTTONMASK.TOOLTIP|(A_Index == 1 ? THUMBBUTTONMASK.BITMAP : THUMBBUTTONMASK.ICON)
	buttons[A_Index] := b
}
buttons[1].iBitmap := 0
buttons[2].hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI.HAND, "ptr")
buttons[3].hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI.WINLOGO, "ptr")
buttons[4].hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI.QUESTION, "ptr")
buttons[5].hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI.INFORMATION, "ptr")
buttons[6].hIcon := DllCall("LoadIcon", "uint", 0, "uint", IDI.SHIELD, "ptr")

tbl.ThumbBarAddButtons(hGui, buttons) ; add buttons

sleep 10000 ; sleep some time
buttons[2].dwFlags |= THUMBBUTTONFLAGS.DISABLED
buttons[2].dwMask |= THUMBBUTTONMASK.FLAGS
tbl.ThumbBarUpdateButtons(hGui, [buttons[2]]) ; disable the 2nd button

ObjRelease(tbl) ; release the instance
return

GuiClose:
Gui Destroy
ExitApp
return
	
WM_COMMAND(wp)
{
	static THBN_CLICKED := 0x1800
	if (HIWORD(wp) = THBN_CLICKED) ; if we received a button click:
		Msgbox 64,,% "The ThumbBar button with the id `"" LOWORD(wp) "`" was clicked!", 3 ; show it to the user
}

HIWORD(val)
{
	return val >> 16
}

LOWORD(val)
{
	return val & 0xFFFF 
}