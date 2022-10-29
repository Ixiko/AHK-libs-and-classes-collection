#SingleInstance Force
#Persistent

OnExit("AddMenu.ExitFunc")

Run, Notepad,,, pid
WinWait, ahk_exe notepad.exe

WinTitle := "ahk_pid " pid 

Global Menu := {}

; Building the Menu Items
MyMenu := AddMenu.Popup(WinTitle, "&Edit Clipboard")
AddMenu.Item(WinExist(WinTitle), 1001, "Uppercase", MyMenu)
AddMenu.Item(WinExist(WinTitle), 1002, "Lowercase", MyMenu)
AddMenu.Item(WinExist(WinTitle), 1003, "Titlecase", MyMenu)

; Set Call Function WinEventProc() on Msg *Event_Menu _Start / _End*
Event_Menu_Start := "0x0004"
Event_Menu_End := "0x0005"
pCallback := RegisterCallback("AddMenu.WinEvent")
Acc_SetWinEventHook(Event_Menu_Start, Event_Menu_End, pCallBack)
Return

Class AddMenu {

	Popup(WinTitle, MenuName) {
		MF_POPUP = 16
		Menu.MenuName := MenuName
		hItem := DllCall("CreateMenu")
		hWndTarget := WinExist(WinTitle)
		hMenu := DllCall("GetMenu", "Ptr", hWndTarget, "Ptr")
		DllCall("AppendMenu", "Ptr", hMenu, "UInt", MF_POPUP, "UPtr", hItem, "Str", MenuName)
		Return hItem
	}

    WinEvent(hHook, event, hWnd, idObject, idChild, eventThread, eventTime) {
        if (Menu.hWnd = Format("{:X}",event))
            { 
                obj := AddMenu.GetInfoUnderCursor() 
                If ("&" . obj.text = Menu.MenuName) {   
                    Sleep 100
                    obj := ""
                    KeyWait, LButton, D
                    obj := AddMenu.GetInfoUnderCursor() 
                    if (obj.text = "Uppercase")
                        Clipboard := Format("{:U}", Clipboard)

                    if (obj.text = "Lowercase")
                        Clipboard := Format("{:L}", Clipboard)

                    if (obj.text = "Titlecase")
                        Clipboard := Format("{:T}", Clipboard)

                }
            }
        }


	Item(hWnd, ItemID, ItemName, hItem) {
		MF_BYPOSITION = 0x400
		MF_SEPARATOR = 0x800
		MF_STRING = 0x000
		MF_POPUP = 16
		
		hMenu := DllCall("GetMenu", "UInt", hWnd)
		DllCall("InsertMenu", "UInt", hItem, "UInt", 0x0, "UInt", MF_BYPOSITION | MF_STRING, "UInt", ItemID, "Str", ItemName)
		DllCall("SetMenu", "Ptr", hItem, "Ptr", hMenu)
		DllCall("DrawMenuBar", "Ptr", hWnd)

		Menu.hWnd := Format("{:X}",hWnd)
		Menu.hMenu := Format("{:X}",hMenu)
		Menu.hItem := Format("{:X}",hItem)
	}

	GetInfoUnderCursor() {
		Acc := Acc_ObjectFromPoint(child)
		if !value := Acc.accValue(child)
			value := Acc.accName(child)
		accPath := this.GetAccPath(acc, hwnd).path
		return {text: value, path: accPath, hwnd: hwnd}
	}
	
	GetAccPath(Acc, byref hwnd="") {
		hwnd := Acc_WindowFromObject(Acc)
		WinObj := Acc_ObjectFromWindow(hwnd)
		WinObjPos := Acc_Location(WinObj).pos
		while Acc_WindowFromObject(Parent:=Acc_Parent(Acc)) = hwnd {
			t2 := this.GetEnumIndex(Acc) "." t2
			if Acc_Location(Parent).pos = WinObjPos
				return {AccObj:Parent, Path:SubStr(t2,1,-1)}
			Acc := Parent
		}
		while Acc_WindowFromObject(Parent:=Acc_Parent(WinObj)) = hwnd
			t1.="P.", WinObj:=Parent
		return {AccObj:Acc, Path:t1 SubStr(t2,1,-1)}
	}
	
	GetEnumIndex(Acc, ChildId=0) {
		if Not ChildId {
			ChildPos := Acc_Location(Acc).pos
			For Each, child in Acc_Children(Acc_Parent(Acc))
				if IsObject(child) and Acc_Location(child).pos=ChildPos
					return A_Index
		} 
		else {
			ChildPos := Acc_Location(Acc,ChildId).pos
			For Each, child in Acc_Children(Acc)
				if Not IsObject(child) and Acc_Location(Acc,child).pos=ChildPos
					return A_Index
		}
	}

	ExitFunc() {
		Acc_UnhookWinEvent(pCallback)
		WinClose, AHK_EXE Notepad.EXE
		ExitApp
	}
}


