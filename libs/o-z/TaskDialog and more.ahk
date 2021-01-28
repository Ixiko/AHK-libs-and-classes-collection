;=========================================================================
; TaskDialogEx(主文,副文,标题,按钮,图标,宽度,父窗口,超时)
TaskDialogEx(Main, Extra := "", Title := "提示：", Buttons := 1, Icon := 8, Width := 600, Parent := -1, TimeOut := 0) {
	Static TDCB      := RegisterCallback("TaskDialogCallback", "Fast")
		, TDCSize   := (4 * 8) + (A_PtrSize * 16)
		, TDBTNS    := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16, CLOSE: 32}
		, TDF       := {HICON_MAIN: 0x0002, ALLOW_CANCEL: 0x0008, CALLBACK_TIMER: 0x0800, SIZE_TO_CONTENT: 0x01000000}
		, TDICON    := {1: 1, 2: 2, 3: 3, 4: 4, 5: 5, 6: 6, 7: 7, 8: 8, 9: 9
		, WARN: 1, ERROR: 2, INFO: 3, SHIELD: 4, BLUE: 5, YELLOW: 6, RED: 7, GREEN: 8, GRAY: 9
		, QUESTION: 0}
		, HQUESTION := DllCall("User32.dll\LoadIcon", "Ptr", 0, "Ptr", 0x7F02, "UPtr")
		, DBUX      := DllCall("User32.dll\GetDialogBaseUnits", "UInt") & 0xFFFF
		, OffParent := 4
		, OffFlags  := OffParent + (A_PtrSize * 2)
		, OffBtns   := OffFlags + 4
		, OffTitle  := OffBtns + 4
		, OffIcon   := OffTitle + A_PtrSize
		, OffMain   := OffIcon + A_PtrSize
		, OffExtra  := OffMain + A_PtrSize
		, OffCB     := (4 * 7) + (A_PtrSize * 14)
		, OffCBData := OffCB + A_PtrSize
		, OffWidth  := OffCBData + A_PtrSize
	; -------------------------------------------------------------------------------------------------------------------
	if ((DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF) < 6) {
		if TaskDialogUseMsgBoxOnXP()
			return TaskDialogMsgBox(Main, Extra, Title, Buttons, Icon, Parent, Timeout)
		else {
			MsgBox, 16, %A_ThisFunc%, You need at least Win Vista / Server 2008 to use %A_ThisFunc%().
			ErrorLevel := "You need at least Win Vista / Server 2008 to use " . A_ThisFunc . "()."
			return 0
		}
	}
	; -------------------------------------------------------------------------------------------------------------------
	Flags := Width = 0 ? TDF.SIZE_TO_CONTENT : 0
	if (Title = "")
		Title := A_ScriptName
	BTNS := 0
	if Buttons Is Integer
		BTNS := Buttons & 0x3F
	else
		For Each, Btn In StrSplit(Buttons, ["|", " ", ",", "`n"])
	BTNS |= (B := TDBTNS[Btn]) ? B : 0
	ICO := (I := TDICON[Icon]) ? 0x10000 - I : 0
	if Icon Is Integer
		if ((Icon & 0xFFFF) <> Icon) ; caller presumably passed HICON
			ICO := Icon
	if (Icon = "Question")
		ICO := HQUESTION
	if (ICO > 0xFFFF)
		Flags |= TDF.HICON_MAIN
	AOT := Parent < 0 ? !(Parent := 0) : False ; AlwaysOnTop
	; -------------------------------------------------------------------------------------------------------------------
	PTitle := A_IsUnicode ? &Title : TaskDialogToUnicode(Title, WTitle)
	PMain  := A_IsUnicode ? &Main : TaskDialogToUnicode(Main, WMain)
	PExtra := Extra = "" ? 0 : A_IsUnicode ? &Extra : TaskDialogToUnicode(Extra, WExtra)
	VarSetCapacity(TDC, TDCSize, 0) ; TASKDIALOGCONFIG structure
	NumPut(TDCSize, TDC, "UInt")
	NumPut(Parent, TDC, OffParent, "Ptr")
	NumPut(BTNS, TDC, OffBtns, "Int")
	NumPut(PTitle, TDC, OffTitle, "Ptr")
	NumPut(ICO, TDC, OffIcon, "Ptr")
	NumPut(PMain, TDC, OffMain, "Ptr")
	NumPut(PExtra, TDC, OffExtra, "Ptr")
	if (AOT) || (TimeOut > 0) {
		if (TimeOut > 0) {
			Flags |= TDF.CALLBACK_TIMER
			TimeOut := Round(Timeout * 1000)
		}
		TD := {AOT: AOT, Timeout: Timeout}
		NumPut(TDCB, TDC, OffCB, "Ptr")
		NumPut(&TD, TDC, OffCBData, "Ptr")
	}
	NumPut(Flags, TDC, OffFlags, "UInt")
	if (Width > 0)
		NumPut(Width * 4 / DBUX, TDC, OffWidth, "UInt")
	if !(RV := DllCall("Comctl32.dll\TaskDialogIndirect", "Ptr", &TDC, "IntP", Result, "Ptr", 0, "Ptr", 0, "UInt"))
		return TD.TimedOut ? -1 : Result
	ErrorLevel := "The call of TaskDialogIndirect() failed!`nreturn value: " . RV . "`nLast error: " . A_LastError
	return 0
}
; ================================================================================?======================================
; Call this function once passing 1/True if you want a MsgBox to be displayed instead of the task dialog on Win XP.
; ================================================================================?======================================
TaskDialogUseMsgBoxOnXP(UseIt := "") {
	Static UseMsgBox := False
	if (UseIt <> "")
		UseMsgBox := !!UseIt
	return UseMsgBox
}
; ================================================================================?======================================
; Internally used functions
; ================================================================================?======================================
TaskDialogMsgBox(Main, Extra, Title := "", Buttons := 0, Icon := 0, Parent := 0, TimeOut := 0) {
	Static MBICON := {1: 0x30, 2: 0x10, 3: 0x40, WARN: 0x30, ERROR: 0x10, INFO: 0x40, QUESTION: 0x20}
		, TDBTNS := {OK: 1, YES: 2, NO: 4, CANCEL: 8, RETRY: 16}
	BTNS := 0
	if Buttons Is Integer
		BTNS := Buttons & 0x1F
	else
		For Each, Btn In StrSplit(Buttons, ["|", " ", ",", "`n"])
	BTNS |= (B := TDBTNS[Btn]) ? B : 0
	Options := 0
	Options |= (I := MBICON[Icon]) ? I : 0
	Options |= Parent = -1 ? 262144 : Parent > 0 ? 8192 : 0
	if ((BTNS & 14) = 14)
		Options |= 0x03 ; Yes/No/Cancel
	else if ((BTNS & 6) = 6)
		Options |= 0x04 ; Yes/No
	else if ((BTNS & 24) = 24)
		Options |= 0x05 ; Retry/Cancel
	else if ((BTNS & 9) = 9)
		Options |= 0x01 ; OK/Cancel
	Main .= Extra <> "" ? "`n`n" . Extra : ""
	MsgBox, % Options, %Title%, %Main%, %TimeOut%
	IfMsgBox, OK
		return 1
	IfMsgBox, Cancel
		return 2
	IfMsgBox, Retry
		return 4
	IfMsgBox, Yes
		return 6
	IfMsgBox, No
		return 7
	IfMsgBox, TimeOut
		return -1
	return 0
}
; ================================================================================?======================================
TaskDialogToUnicode(String, ByRef Var) {
	VarSetCapacity(Var, StrPut(String, "UTF-16") * 2, 0)
	StrPut(String, &Var, "UTF-16")
	return &Var
}
; ================================================================================?======================================
TaskDialogCallback(H, N, W, L, D) {
	Static TDM_Click_BUTTON := 0x0466
		, TDN_CREATED := 0
		, TDN_TIMER   := 4
	TD := Object(D)
	if (N = TDN_TIMER) && (W > TD.Timeout) {
		TD.TimedOut := True
		PostMessage, %TDM_Click_BUTTON%, 2, 0, , ahk_id %H% ; IDCANCEL = 2
	}
	else if (N = TDN_CREATED) && TD.AOT {
		DHW := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinSet, AlwaysOnTop, On, ahk_id %H%
		DetectHiddenWindows, %DHW%
	}
	return 0
}

LoadIcon(FullFilePath, IconNumber := 1, LargeIcon := 1) {
	HIL := IL_Create(1, 1, !!LargeIcon)
	IL_Add(HIL, FullFilePath, IconNumber)
	HICON := DllCall("Comctl32.dll\ImageList_GetIcon", "Ptr", HIL, "Int", 0, "UInt", 0, "UPtr")
	IL_Destroy(HIL)
	return HICON
}
GuiButtonIcon(Handle, File, Index := 1, Options := "") {
	RegExMatch(Options, "i)w\K\d+", W), (W="") ? W := 16 :
	RegExMatch(Options, "i)h\K\d+", H), (H="") ? H := 16 :
	RegExMatch(Options, "i)s\K\d+", S), S ? W := H := S :
	RegExMatch(Options, "i)l\K\d+", L), (L="") ? L := 0 :
	RegExMatch(Options, "i)t\K\d+", T), (T="") ? T := 0 :
	RegExMatch(Options, "i)r\K\d+", R), (R="") ? R := 0 :
	RegExMatch(Options, "i)b\K\d+", B), (B="") ? B := 0 :
	RegExMatch(Options, "i)a\K\d+", A), (A="") ? A := 4 :
	Psz := A_PtrSize = "" ? 4 : A_PtrSize, DW := "UInt", Ptr := A_PtrSize = "" ? DW : "Ptr"
	VarSetCapacity( button_il, 20 + Psz, 0 )
	NumPut( normal_il := DllCall( "ImageList_Create", DW, W, DW, H, DW, 0x21, DW, 1, DW, 1 ), button_il, 0, Ptr )   ; Width & Height
	NumPut( L, button_il, 0 + Psz, DW )     ; Left Margin
	NumPut( T, button_il, 4 + Psz, DW )     ; Top Margin
	NumPut( R, button_il, 8 + Psz, DW )     ; Right Margin
	NumPut( B, button_il, 12 + Psz, DW )    ; Bottom Margin
	NumPut( A, button_il, 16 + Psz, DW )    ; Alignment
	SendMessage, BCM_SETIMAGELIST := 5634, 0, &button_il,, AHK_ID %Handle%
	return IL_Add( normal_il, File, Index )
}
