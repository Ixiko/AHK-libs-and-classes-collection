;Example code begin

/* Array_Gui_Ext.ahk by Nextron from 29.03.2016 original by GeekDude

AutoHotkey's Variables and their contents: improvement
Two items I'd like to see:
• Inclusion of a search box (Variable name or content) (I have too many global vars, let's call it legacy code of inexperience)
• Ability to view object contents (Perhaps a clickable link?)
View object contents
GeekDude already made an object viewer.

I've added:
• A search box (Button or F3).
• Copy selected (Ctrl+C).
• And the the ability to open an entire sub-tree by double clicking. 

Usage: This code must be included in the scripts who's object needs to be viewed, i.e. it cannot be ran externally.
Open AHK's main window,
Navigate to the view variables part (Ctrl+V),
Select an object's name (or double click it to select it),
Press Ctrl+V again to open the object viewer.

Link: https://autohotkey.com/boards/viewtopic.php?p=78270#p78270

A := {"A":{"Fruit":["Apple", "Apricot"], "Animals":["Aardvark", "Antelope"]}, "B":{"Fruit":["Banana", "Blueberry"], "Animals":["Bee", "Barnacle"]}, "C":"The alphabet :D"}
ListLines
;Example code end

#IfWinActive,ahk_exe AutoHotkey.exe,Global Variables (alphabetical)
^v::
	var:=CtrlC()
	Try
		If IsObject(%var%)
			Array_Gui(%var%)
 
return
#If

-----------------------------------------------------------------------------------------------------

#IfWinActive,ahk_exe AutoHotkey.exe
^f::SearchAHK(1)
f3::
SearchAHK(NewSearch:=0){
	Static Needle, hWnd
	If (Needle="" || NewSearch){
		InputBox,Needle,Find text,Search string:,,300,130,,,,,% Needle
		If ErrorLevel || Needle=""
			Return Needle:=""
	}
	
	If !hWnd
		ControlGet,hWnd,Hwnd ,,Edit1,ahk_exe AutoHotkey.exe
	
	ControlGetText,HayStack,Edit1,ahk_exe AutoHotkey.exe
	VarSetCapacity(SelectionStart, 4), VarSetCapacity(SelectionEnd, 4)
	SendMessage, 0xB0, &SelectionStart, &SelectionEnd,, ahk_id %hWnd% ;EM_GETSEL
	SelectionStart := NumGet(SelectionStart, 0, "UInt")
	;SelectionEnd := NumGet(SelectionEnd, 0, "UInt")
	
	Sel1:=InStr(HayStack,Needle,,SelectionStart+2)-1
	If (Sel1=-1)
		Sel1:=InStr(HayStack,Needle)-1
	Sel2:=Sel1+StrLen(Needle)
	If (Sel1=-1)
		Sel1:=Sel2:=0
	
	PostMessage, 0xB1,% Sel1,% Sel2,,ahk_id %hWnd% ;EM_SETSEL
	PostMessage, 0xB7,,,,ahk_id %hWnd% ;EM_SCROLLCARET
}
#IfWinActive
 */
 
 
Array_Gui(Array, Parent="") {
    static
    global GuiArrayTree, GuiArrayEdit, GuiArrayFind, GuiArrayTreeX, GuiArrayTreeY, GuiArrayFindW, GuiArrayFn
    if Array_IsCircle(Array)
    {
        MsgBox, 16, GuiArray, Error: Circular refrence
        return "Error: Circular refrence"
    }
    if !Parent
    {
        Gui, +HwndDefault
        Gui, GuiArray:New, +HwndGuiArray +LabelGuiArray +Resize -MaximizeBox +MinSize200x150 ;400x500
		Gui, Add, Edit, vGuiArrayEdit w220
		Gui, Add, Button, vGuiArrayFind gGuiArrayFind x+m Default,Find
        Gui, Add, TreeView, vGuiArrayTree gGuiArrayTree xm
 
        Parent := "P1"
        %Parent% := TV_Add("Array", 0, "+Expand")
        Array_Gui(Array, Parent)
        GuiControlGet, GuiArrayTree, Pos
        GuiControlGet, GuiArrayFind, Pos
        Gui, Show,h375 w275, GuiArray
        Gui, %Default%:Default
 
		GuiArrayFn := Func("GuiArrayKey")
		OnMessage(WM_KEYUP := 0x101,GuiArrayFn)
 
        WinWaitActive, ahk_id%GuiArray%
        WinWaitClose, ahk_id%GuiArray%
        return
    }
    For Key, Value in Array
    {
        %Parent%C%A_Index% := TV_Add(Key, %Parent%)
        KeyParent := Parent "C" A_Index
        if (IsObject(Value))
            Array_Gui(Value, KeyParent)
        else
            %KeyParent%C1 := TV_Add(Value, %KeyParent%)
    }
    return
 
	GuiArrayEscape:
    GuiArrayClose:
	OnMessage(WM_KEYUP := 0x101,GuiArrayFn,0)
    Gui, Destroy
    return
 
    GuiArraySize:
    if !(A_GuiWidth || A_GuiHeight) ; Minimized
        return
    GuiControl, Move, GuiArrayTree, % "w" A_GuiWidth - (GuiArrayTreeX * 2) " h" A_GuiHeight - (GuiArrayTreeY * 2) +25
    GuiControl, Move, GuiArrayEdit, % "w" A_GuiWidth - GuiArrayFindW - 30
    GuiControl, Move, GuiArrayFind, % "x" A_GuiWidth - GuiArrayFindW - 10
    return
 
	GuiArrayTree:
	If (A_GuiEvent="DoubleClick")
		GuiArrayTreeExpand(TV_GetSelection(),(TV_Get(TV_GetSelection(),"Expand") ? "+" : "-") "Expand")
	return

	GuiArrayFind:
		GuiControlGet,GuiArrayEdit
		ItemID1:=ItemID:=TV_GetSelection()
		If !ItemID
			ItemID1:=ItemID:=TV_GetNext()
		ItemID:=TV_GetNext(ItemID,"Full")
		While (ItemID!=ItemID1){
			TV_GetText(ItemText, ItemID)
			If InStr(ItemText,GuiArrayEdit){
				TV_Modify(ItemID)
				GuiControl,Focus,GuiArrayTree
				Break
			}
			ItemID:=TV_GetNext(ItemID,"Full")
			If !ItemID
				ItemID:=TV_GetNext()
		}
	Return

} 

GuiArrayTreeExpand(ItemID,Expand){
		TV_Modify(ItemID,Expand)
		ItemID:=TV_GetChild(ItemID)
		While ItemID
		{
			GuiArrayTreeExpand(ItemID,Expand)
			ItemID:=TV_GetNext(ItemID)
		}
	}

GuiArrayKey(wParam){
		GuiControlGet, GuiArrayFocus, Focus
		If (GuiArrayFocus="SysTreeView321") && wParam=67 && GetKeyState("Control"){ ;Ctrl+C = Copy selected
			TV_GetText(ItemText, TV_GetSelection())
			Clipboard:=ItemText
			return 0
		}Else If (wParam=114) ;F3 = Find next
			gosub,GuiArrayFind
	}
  
Array_IsCircle(Obj, Objs=0) {
    if !Objs
        Objs := {}
    For Key, Val in Obj
        if (IsObject(Val)&&(Objs[&Val]||Array_IsCircle(Val,(Objs,Objs[&Val]:=1))))
            return 1
    return 0
}

CtrlC(){
	WholeClipBoard:=ClipBoardAll
	ClipBoard =
	Send ^c
	ClipWait,.3
	str:=ClipBoard
	ClipBoard:=WholeClipBoard
	Return, str
}