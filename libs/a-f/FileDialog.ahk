#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

VarSetCapacity(OPENFILENAMEW, (cbOFN := A_PtrSize == 8 ? 152 : 88), 0)
NumPut(cbOFN, OPENFILENAMEW,, "UInt") ; lStructSize
NumPut(A_ScriptHwnd, OPENFILENAMEW, A_PtrSize, "Ptr") ; hwndOwner

filters := [ "Text Documents", "*.txt"
			,"Test",           "*.nfo"
			,"All files",      "*.*"]

if (IsObject(filters) && Mod(filters.MaxIndex(), 2) == 0) {
	finalFilterString := ""
	for _, filter in filters
		finalFilterString .= Mod(A_Index, 2) ? filter . " (" : filter . ")|" . filter . "|"
	
	while ((char := DllCall("ntdll\wcsrchr", "Ptr", &finalFilterString, "UShort", Asc("|"), "CDecl Ptr")))
		NumPut(0, char+0,, "UShort")

	NumPut(&finalFilterString, OPENFILENAMEW, A_PtrSize*3, "Ptr") ; lpstrCustomFilter
	NumPut(1, OPENFILENAMEW, A_PtrSize*(5 + (A_PtrSize == 4)), "UInt") ; nFilterIndex
}

max_path := 260 ; if keeping the option to select multiple files, consider raising the size
VarSetCapacity(vPath, (max_path+2)*2, 0)
NumPut(&vPath, OPENFILENAMEW, A_PtrSize*(6 + (A_PtrSize == 4)), "Ptr") ; lpstrFile
NumPut(max_path, OPENFILENAMEW, A_PtrSize*(7 + (A_PtrSize == 4)), "UInt") ; nMaxFile

NumPut(&(initialDir := A_Desktop), OPENFILENAMEW, A_PtrSize*(10 + (A_PtrSize == 4)), "Ptr") ; lpstrInitialDir
NumPut(&(title := "Open"), OPENFILENAMEW, A_PtrSize*(11 + (A_PtrSize == 4)), "Ptr") ; lpstrTitle
NumPut((cb := RegisterCallback("OFNHookProc")), OPENFILENAMEW, A_PtrSize == 8 ? 120 : 68, "Ptr") ; lpfnHook
NumPut(OFN_EXPLORER := 0x00080000 | OFN_HIDEREADONLY := 0x00000004 | OFN_ALLOWMULTISELECT := 0x00000200 | OFN_ENABLEHOOK := 0x00000020, OPENFILENAMEW, A_PtrSize*(12 + (A_PtrSize == 4)), "UInt") ; Flags

if (DllCall("comdlg32\GetOpenFileNameW", "Ptr", &OPENFILENAMEW)) {
	dirOrFile := StrGet(&vPath,, "UTF-16")
	if (!NumGet(vPath, (StrLen(dirOrFile) + 1) * 2, "UShort")) {
		MsgBox %dirOrFile%
	} else {
		; Multiple files selected
		fileNames := &vPath + (NumGet(OPENFILENAMEW, A_PtrSize == 8 ? 100 : 56, "UShort") * 2)
		while (*fileNames) {
			MsgBox % dirOrFile . "\" . StrGet(fileNames,, "UTF-16")
			fileNames += (DllCall("ntdll\wcslen", "Ptr", fileNames, "CDecl Ptr") * 2) + 2
		}		
	}
	if (ColorSelection) {
		MsgBox % ColorSelection
		ColorSelection := ""
	}
}
DllCall("GlobalFree", "Ptr", cb, "Ptr")
ExitApp

OFNHookProc(hdlg, uiMsg, wParam, lParam)
{
	Critical
	global ColorSelection
	if (uiMsg == 0x0110) { ; WM_INITDIALOG
		dlgWindow := DllCall("GetParent", "Ptr", hdlg, "Ptr")
		if ((filterCb := DllCall("GetDlgItem", "Ptr", dlgWindow, "Int", cmb1 := 0x0470,"Ptr"))) {
			Gui, Add, Text, hwndhColourLabel, Colour:
			filterLabel := DllCall("GetDlgItem", "Ptr", dlgWindow, "Int", stc2 := 0x0441,"Ptr")
			DllCall("SetParent", "Ptr", hColourLabel, "Ptr", dlgWindow, "Ptr")
			ControlGetPos X, Y, Width, Height,, ahk_id %filterLabel%
			ControlMove ,, %X%, % Y + Height + 12, %Width%, %Height%, ahk_id %hColourLabel%

			Gui, Add, DropDownList, hwndhColourSelection vColorSelection, Red||Green|Blue|Black|White
			DllCall("SetParent", "Ptr", hColourSelection, "Ptr", dlgWindow, "Ptr")
			ControlGetPos X, Y, Width, Height,, ahk_id %filterCb%
			ControlMove ,, %X%, % Y + Height + 5, %Width%, %Height%, ahk_id %hColourSelection% ; TODO: determine spacing properly :-)

			DetectHiddenWindows On
			WinGetPos, X, Y, Width, Height2, ahk_id %dlgWindow%
			WinMove ahk_id %dlgWindow%,,,,, % Height2 + Height + 5
			DetectHiddenWindows Off
		}
	} else if (uiMsg == 0x004E) { ; WM_NOTIFY
		CDN := NumGet(lParam+0, A_PtrSize * 2, "UInt")
		if (CDN == 4294966690) { ; CDN_FILEOK
			Gui submit
		}
	} else if (uiMsg == 0x0002) { ; WM_DESTROY
		Gui Destroy
	}
	Critical Off
	return 0
}