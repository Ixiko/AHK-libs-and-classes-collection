/*

Plugin            : Slots
Purpose           : Load & Save 10 quick paste texts
Version           : 1.1
CL3 version       : 1.2

10 Slots
Hotkeys: RCTRL-[1-0] 

History:
- 1.1 Bug fix for not correctly updatin control (Edit0 vs Slot0) and moved XML to ClipData, improved firsttime init

*/

SlotsInit:

If !IsObject(Slots)
	{
	 IfExist, %A_ScriptDir%\ClipData\Slots\Slots.xml
		{
		 XA_Load(A_ScriptDir "\ClipData\Slots\Slots.xml") ; the name of the variable containing the array is returned 
		}
	 else
		{
		 Slots:=[]
		 Loop, 10
			Slots[A_Index-1]:="Slot" A_Index-1 "a"
		}
	}

x:=10
y:=10
Index:=0
Loop, 10
	{
	 Index++
	 If (Index = 10)
	 	Index:=0
	 Gui, Slots:Add, Text, x%x% y%y% ,Slot #%Index% [RCtrl + %Index%]
	 Gui, Slots:Add, Edit, w290 h60 vSlot%Index%, % Slots[Index]
	 y+=80
	 if (A_Index = 5)
	 	y:=10
	 if (A_Index = 5)
	 	x:=310
	}
Gui, Slots:Add, Button, x10 gSlotsSave, &Save Slots (slots.xml)
Gui, Slots:Add, Button, xp130 gSlotsSaveAs, Save &As (name.xml)
Gui, Slots:Add, Button, xp130 gLoadSlots, &Load (name.xml)
Gui, Slots:Add, Button, xp253 gSlotsClose, &Close window
Return

^#F12::
If !WinExist("CL3Slots ahk_class AutoHotkeyGUI")
	Gui, Slots:Show, ,CL3Slots
else
	Gui, Slots:Hide
Return

>^1::
>^2::
>^3::
>^4::
>^5::
>^6::
>^7::
>^8::
>^9::
>^0::
Clipboard:=Slots[SubStr(A_thisHotkey,0)]
Send ^v
Return

~Esc::
SlotsGuiClose:
SlotsClose:
Gui, Slots:Cancel
Return

SlotsSave:
Gui, Slots:Submit, Hide
Index:=0
Loop, 10
	{
	 Slots[Index]:=Slot%Index%
	 Index++
	}
XA_Save("Slots", A_ScriptDir "\ClipData\Slots\Slots.xml") ; put variable name in quotes
Return

SlotsSaveAs:
SaveAsName:=""
Gui, Slots:Submit, Hide
InputBox, SaveAsName, Name for XML, Save slots as
If (SaveAsName = "")
	{
	 MsgBox, Enter filename!`nSlots not saved.
	 Gui, Slots:Show
	 Return
	}
Index:=0
Loop, 10
	{
	 Slots[Index]:=Slot%Index%
	 Index++
	}
StringReplace, SaveAsName, SaveAsName, .xml,,All
XA_Save("Slots", A_ScriptDir "\ClipData\Slots\" SaveAsName ".xml") ; put variable name in quotes
Return

LoadSlots:
Menu, SlotsMenu, Add
Menu, SlotsMenu, Delete
Menu, SlotsMenu, Add, Slots.xml, MenuHandlerSlots
Menu, SlotsMenu, Add
Loop, %A_ScriptDir%\ClipData\Slots\*.xml
	{
	 If (A_LoopFileName = "slots.xml")
	 	Continue
	 Menu, SlotsMenu, Add, %A_LoopFileName%, MenuHandlerSlots
	}
Menu, SlotsMenu, Show
Return

MenuHandlerSlots:
Try
	{
	 Slots:=[]
	 XA_Load(A_ScriptDir "\ClipData\Slots\" A_ThisMenuItem) ; the name of the variable containing the array is returned
	}
Catch
	{
	 Slots:=[]
	 Loop, 10
		Slots[Index-1]:="Slot" A_Index-1 "a"
	}
Index:=0	
Loop, 10
	{
	 GuiControl,Slots:, Slot%Index%, % Slots[Index]
	 Index++
	}
Return
