#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

		
		List = 
		(
		Item:		1
		Item:		2
		Item:		3
		Item:		4
		Item:		5
		Item:		6
		Item:		7
		Item:		8
		Item:		9
		Item:		10
		Item:		11
		Item:		12
		Item:		13
		Item:		14
		Item:		15
		Item:		16
		Item:		17
		Item:		18
		Item:		19
		Item:		20
		)
		
		New Checklist(List, ReturnFunction := "Validated")
		Exit
		
		Validated(){
			MsgBox % "All Items on Checklist Have Been Reviewd.`n`nPress Okay to being next Process."
		}
		
		
		;------------------------------------------------------------------------------
		; Checklist.ahk 
		; by Casper Harkin
		;
		; This is a simple class that creates a checklist of items from a list 
		; and once all checked off, will call another function. 
		;
		; Class Checklist(List, ReturnFunction)
		;	List - Pass a list of items to be checked off.
		;	ReturnFunction - Pass the name (as a string) of the MenuHandler or function 
		;	to call once the checklist items have been ticked and validated. 
		;
		;
		; last updated 03/09/2021
		;------------------------------------------------------------------------------
		
		
		Class Checklist {
		
			__New(List, ReturnFunction){
				Obj := {}
				Obj.ReturnFunction := ReturnFunction 
				Obj.List := List
				This.CheckListGUI(Obj)
			}
		
			CheckListGUI(Obj){
				Obj["Checklist"] := {}
		
				GUI, Color, 0xFFF7D1
				Gui, Add, Tab3,, Page 1
		
				Array := StrSplit(Obj.List, "`n")
					for each, item in Array {
						Gui, Add, Checkbox, Wrap y+20 wp +hwndh%each% -Theme, % item 
						Obj["Checklist"]["h"each] := h%each%
						If (A_Index = 5) or (A_Index = 10) or (A_Index = 15){
							GuiControl, Text, SysTabControl321, % (A_Index = 5) ? "|Page 1|Page 2" : (A_Index = 10) ? "|Page 1|Page 2|Page 3" : (A_Index = 15) ? "|Page 1|Page 2| Page 3|Page 4" :
							Gui, Tab, % (A_Index = 5) ? "2" : (A_Index = 10) ? "3" : (A_Index = 15) ? "4" :
						}  
					}
		
				Gui, Tab  
				
				Gui, Add, Button, xp y+5 wp  +hwndhOkay , Okay
		
				MenuHandler := ObjBindMethod(this,"ValidateChecklist", Obj)
				GuiControl +g, % hOkay , % MenuHandler
		
				Gui, Show,, CheckList
			}
			
			ValidateChecklist(Obj){
				for each, item in Obj["Checklist"] {
					GuiControlGet, tick,, % item 
					If (tick = 0){
						Gui, Font, cRed 
						GuiControl, Font, % item  
						s := 0
					}
				}
		
				If (s = 0)
					MsgBox % "Error: Not All Items on Checklist have been checked.`n`nMissed Items are marked red."
				Else {
					ReturnFunction := Obj.ReturnFunction
					%ReturnFunction%()
				}
			}
		}


