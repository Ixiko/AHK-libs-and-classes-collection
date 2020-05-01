#Include *i FUNC_hexToDecimal.ahk

class Layout
{ ; функции управления раскладками клавиатуры
	static SISO639LANGNAME := 0x0059 ; ISO abbreviated language name, eg "en"
	static LOCALE_SENGLANGUAGE := 0x1001 ; Full language name, eg "English"
	static WM_INPUTLANGCHANGEREQUEST := 0x0050
	static INPUTLANGCHANGE_FORWARD := 0x0002
	static INPUTLANGCHANGE_BACKWARD := 0x0004
	;
	static Layouts_List := Layout.Get_Layouts_List()
	static Layouts_List_By_HKL := Layout.Get_Layouts_List_By_HKL()
	;
	static Switch_Layout_Combo := "{Blind}{Alt Down}{Shift Down}{Alt Up}{Shift Up}"
	;
	Get_Layouts_List()
	{ ; функция создания базы данных для текущих раскладок
		local
		VarSetCapacity(List, A_PtrSize * 5)
		Layouts_List_Size := DllCall("GetKeyboardLayoutList", Int, 5, Str, List)
		Layouts_List := []
		Loop, % Layouts_List_Size
		{
			Layout_HKL := NumGet(List, A_PtrSize * (A_Index - 1)) ; & 0xFFFF
			Layout_KLID := This.Get_KLID(Layout_HKL)
			Layout_Name := This.Language_Name(Layout_HKL, false)
			Layout_Full_Name := This.Language_Name(Layout_HKL, true)
			Layout_Display_Name := This.Display_Name(Layout_HKL)
			Layouts_List[A_Index] := {}
			Layouts_List[A_Index].HKL := Layout_HKL
			Layouts_List[A_Index].KLID := Layout_KLID
			Layouts_List[A_Index].Name := Layout_Name
			Layouts_List[A_Index].Full_Name := Layout_Full_Name
			Layouts_List[A_Index].Display_Name := Layout_Display_Name
		}
		return Layouts_List
	}
	
	Get_Layouts_List_By_HKL()
	{ ; функция создания базы данных для текущих раскладок
		local
		VarSetCapacity(List, A_PtrSize * 5)
		Layouts_List_Size := DllCall("GetKeyboardLayoutList", Int, 5, Str, List)
		Layouts_List := {}
		Loop, % Layouts_List_Size
		{
			Layout_HKL := NumGet(List, A_PtrSize * (A_Index - 1)) ; & 0xFFFF
			Layout_KLID := This.Get_KLID(Layout_HKL)
			Layout_Name := This.Language_Name(Layout_HKL, false)
			Layout_Full_Name := This.Language_Name(Layout_HKL, true)
			Layout_Display_Name := This.Display_Name(Layout_HKL)
			Layouts_List[Layout_HKL] := {}
			Layouts_List[Layout_HKL].HKL := Layout_HKL
			Layouts_List[Layout_HKL].KLID := Layout_KLID
			Layouts_List[Layout_HKL].Name := Layout_Name
			Layouts_List[Layout_HKL].Full_Name := Layout_Full_Name
			Layouts_List[Layout_HKL].Display_Name := Layout_Display_Name
		}
		return Layouts_List
	}

	Language_Name(HKL, Full_Name := false)
	{ ; функция получения наименования (сокращенного "en" или полного "English") раскладки по ее "HKL"
		local
		LocID := HKL & 0xFFFF
		LCType := Full_Name ? This.LOCALE_SENGLANGUAGE : This.SISO639LANGNAME
		Size := DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, UInt, 0, UInt, 0) * 2
		VarSetCapacity(localeSig, Size, 0)
		DllCall("GetLocaleInfo", UInt, LocID, UInt, LCType, Str, localeSig, UInt, Size)
		return localeSig
	}

	Display_Name(HKL)
	{ ; функция получения названия ("Английская") раскладки по ее "HKL"
		local
		KLID := This.Get_KLID(HKL)
		RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Display Name"
		if (not Display_Name) {
			return False
		}
		DllCall("Shlwapi.dll\SHLoadIndirectString", "Ptr", &Display_Name, "Ptr", &Display_Name, "UInt", outBufSize := 50, "UInt", 0)
		if (not Display_Name) {
			RegRead, Display_Name, % "HKEY_LOCAL_MACHINE", % "SYSTEM\CurrentControlSet\Control\Keyboard Layouts\" . KLID, % "Layout Text"
		}
		return Display_Name
	}

	Get_HKL(Window := "A")
	{ ; функция получения названия "HKL" текущей раскладки
		local
		Window_ID := WinExist(Window)
		WinGetClass, Window_Class
		if (Window_Class == "ConsoleWindowClass") {
			WinGet, Console_PID, PID
			DllCall("AttachConsole", Ptr, Console_PID)
			VarSetCapacity(Buff, 16)
			DllCall("GetConsoleKeyboardLayoutName", Str, Buff)
			DllCall("FreeConsole")
			HKL := SubStr(Buff, -3)
			HKL := HKL ? hexToDecimal(HKL . HKL) : 0 ; HKL := HKL ? "0x" . HKL : 0
		}
		else {
			HKL := DllCall("GetKeyboardLayout", Ptr, DllCall("GetWindowThreadProcessId", Ptr, Window_ID, UInt, 0, Ptr), Ptr) ; & 0xFFFF
		}
		return HKL
	}

	Get_KLID(HKL)
	{ ; функция получения названия "KLID" раскладки по ее "HKL"
		local
		Prior_HKL := DllCall("GetKeyboardLayout", "Ptr", DllCall("GetWindowThreadProcessId", "Ptr", 0, "UInt", 0, "Ptr"), "Ptr")
		VarSetCapacity(KLID, 8 * (A_IsUnicode ? 2 : 1))
		if !DllCall("ActivateKeyboardLayout", "Ptr", HKL, "UInt", 0) || !DllCall("GetKeyboardLayoutName", "Ptr", &KLID) || !DllCall("ActivateKeyboardLayout", "Ptr", Prior_HKL, "UInt", 0) {
			return False
		}
		return StrGet(&KLID)
	}

	Next(Window := "A", BySend := false)
	{ ; функция смены раскладки (вперед)
		local
		if BySend { ; с помощью команды Send
			SendInput, % This.Switch_Layout_Combo
		}
		else { ; с помощью команды PostMessage
			if (Window_ID := WinExist(Window)) {
				PostMessage, % This.WM_INPUTLANGCHANGEREQUEST, % This.INPUTLANGCHANGE_FORWARD,,, ahk_id %Window_ID%
			}
		}
		Sleep, 1
	}

	Change(HKL, Window := "A", BySend := false)
	{ ; функция смены раскладки по "HKL"
		local
		if (Window_ID := WinExist(Window)) {
			if BySend { ; с помощью команды Send
				Loop, % This.Layouts_List.MaxIndex()
				{
					This_Layout_KLID := This.Get_KLID(This.Get_HKL("ahk_id " Window_ID))
					Next_Layout_KLID := This.Get_KLID(HKL)
					Sleep, 1
					if (This_Layout_KLID == Next_Layout_KLID) {
						Break
					}
					SendInput, % This.Switch_Layout_Combo
					Sleep, 1
				}
			}
			else { ; с помощью команды PostMessage
				PostMessage, % This.WM_INPUTLANGCHANGEREQUEST,, % HKL,, ahk_id %Window_ID%
			}
		}
		Sleep, 1
	}

	Get_Index(HKL)
	{ ; функция получения порядкового номера раскладки по "HKL"
		local
		for Index, Layout in This.Layouts_List {
			if (This.Get_KLID(Layout.HKL) = This.Get_KLID(HKL)) {
				return Index
			}
		}
	}

	Get_Index_By_Name(Full_Name)
	{ ; функция получения порядкового номера раскладки по полному имени ("English")
		local
		for Index, Layout in This.Layouts_List {
			if (Layout.Full_Name = Full_Name) {
				return Index
			}
		}
	}
}

