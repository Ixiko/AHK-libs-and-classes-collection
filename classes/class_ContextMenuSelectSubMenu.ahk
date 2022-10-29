			q:: 
		
			ContextMenuSelectSubMenu(hMenu,"Se&nd to", "Desktop (create shortcut)")  
			;ContextMenuSelect(hMenu,"&Print")
		
			Exit ; EOAES
		
			;based on:
			;https://www.autohotkey.com/boards/viewtopic.php?t=41170
			;https://www.autohotkey.com/boards/viewtopic.php?t=39209
			;https://autohotkey.com/boards/viewtopic.php?f=6&t=40514
			;https://www.autohotkey.com/board/topic/7771-extracting-menus/
		
			ContextMenuSelectSubMenu(hMenu, MenuSelection, SubMenuSelection := "")
			{
				hMenu := "Null"
			  	nMaxCount := 100
				SendInput {Appskey}
				Sleep 500
				While hMenu = "FAIL" or hMenu = "Null" {
					SendMessage, 0x1E1,,,, ahk_class #32768 ;MN_GETHMENU := 0x1E1, 
					hMenu := ErrorLevel
					if (A_Index > nMaxCount)
						break
				}
		
			  Loop % NumberOfItemsinMenu := DllCall("GetMenuItemCount", UInt, hMenu)
			  {
			    VarSetCapacity(MenuString,100,0) 
			    length := DllCall("user32\GetMenuString","UInt",hMenu,"UINT",A_Index-1,"STR", MenuString,"int", nMaxCount,"UINT", 0x0400) ; 0x0400 := MF_BYPOSITION
		
				if (MenuString = MenuSelection) {
		
					if SubMenuSelection {
						PostMessage, 0x1ED, % A_Index-1, 0,, ahk_class #32768 ;MN_BUTTONDOWN := 0x1ED
						sleep 500
						hSubMenu := DllCall("user32\GetSubMenu","UInt", hMenu,"int",A_Index-1) 
						ContextMenuSelect(hSubMenu, MenuSelection, SubMenuSelection)
					}
					Else
						PostMessage, 0x1F1, % A_Index-1, 0,, ahk_class #32768 ;MN_DBLCLK := 0x1F1
				}
		
				if (MenuString = SubMenuSelection) and (SubMenuSelection != ""){
					PostMessage, 0x1F1, % A_Index-1, 0,, ahk_class #32768 ;MN_DBLCLK := 0x1F1
				}
			  }
			}
