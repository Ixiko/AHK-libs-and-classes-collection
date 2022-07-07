; Source:   Serenity - https://autohotkey.com/board/topic/32608-changing-the-system-cursor/
; Modified: iseahound - https://www.autohotkey.com/boards/viewtopic.php?t=75867

SetSystemCursor(Cursor := "", cx := 0, cy := 0) {

	if (Cursor="Default"){
		return DllCall("SystemParametersInfo", "UInt", SPI_SETCURSORS := 0x57, "UInt", 0, "UInt", 0, "UInt", 0)
	}
	
	static SystemCursors := Map("APPSTARTING", 32650, "ARROW", 32512, "CROSS", 32515, "HAND", 32649, "HELP", 32651, "IBEAM", 32513, "NO", 32648,
		"SIZEALL", 32646, "SIZENESW", 32643, "SIZENS", 32645, "SIZENWSE", 32642, "SIZEWE", 32644, "UPARROW", 32516, "WAIT", 32514)

	if (Cursor = "") {
		AndMask := Buffer(128, 0xFF), XorMask := Buffer(128, 0)

		for CursorName, CursorID in SystemCursors {
			CursorHandle := DllCall("CreateCursor", "ptr", 0, "int", 0, "int", 0, "int", 32, "int", 32, "ptr", AndMask, "ptr", XorMask, "ptr")
			DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID)	; calls DestroyCursor
		}
		return
	}

	if (Cursor ~= "^(IDC_)?(?i:AppStarting|Arrow|Cross|Hand|Help|IBeam|No|SizeAll|SizeNESW|SizeNS|SizeNWSE|SizeWE|UpArrow|Wait)$") {
		Cursor := RegExReplace(Cursor, "^IDC_")

		if !(CursorShared := DllCall("LoadCursor", "ptr", 0, "ptr", SystemCursors[StrUpper(Cursor)], "ptr"))
			throw Error("Error: Invalid cursor name")

		for CursorName, CursorID in SystemCursors {
			CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", cx, "int", cy, "uint", 0, "ptr")
			DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID)	; calls DestroyCursor
		}
		return
	}

	if FileExist(Cursor) {
		SplitPath Cursor, , , &Ext := ""	; auto-detect type
		if !(uType := (Ext = "ani" || Ext = "cur") ? 2 : (Ext = "ico") ? 1 : 0)
			throw Error("Error: Invalid file type")

		if (Ext = "ani") {
			for CursorName, CursorID in SystemCursors {
				CursorHandle := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x10, "ptr")
				DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID)	; calls DestroyCursor
			}
		} else {
			if !(CursorShared := DllCall("LoadImage", "ptr", 0, "str", Cursor, "uint", uType, "int", cx, "int", cy, "uint", 0x8010, "ptr"))
				throw Error("Error: Corrupted file")

			for CursorName, CursorID in SystemCursors {
				CursorHandle := DllCall("CopyImage", "ptr", CursorShared, "uint", 2, "int", 0, "int", 0, "uint", 0, "ptr")
				DllCall("SetSystemCursor", "ptr", CursorHandle, "int", CursorID)	; calls DestroyCursor
			}
		}
		return
	}

	throw Error("Error: Invalid file path or cursor name")
}