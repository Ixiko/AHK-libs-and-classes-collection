Class RichEdit {
	Static Class := "RICHEDIT50W"
	Static DLL := "Msftedit.dll"
	Static Instance := DllCall("Kernel32.dll\LoadLibrary", "Str", RichEdit.DLL, "UPtr")
	Static SubclassCB := 0
	Static Controls := 0
	GuiName := ""
	GuiHwnd := ""
	HWND := ""
	DefFont := ""
	__New(GuiName, Options, MultiLine := True) {
		Static WS_TABSTOP := 0x10000, WS_HSCROLL := 0x100000, WS_VSCROLL := 0x200000, WS_VISIBLE := 0x10000000
		, WS_CHILD := 0x40000000
		, WS_EX_CLIENTEDGE := 0x200, WS_EX_STATICEDGE := 0x20000
		, ES_MULTILINE := 0x0004, ES_AUTOVSCROLL := 0x40, ES_AUTOHSCROLL := 0x80, ES_NOHIDESEL := 0x0100
		, ES_WANTRETURN := 0x1000, ES_DISABLENOSCROLL := 0x2000, ES_SUNKEN := 0x4000, ES_SAVESEL := 0x8000
		, ES_SELECTIONBAR := 0x1000000
		If !(SubStr(A_AhkVersion, 1, 1) > 1) && !(A_IsUnicode) {
			MsgBox, 16, % A_ThisFunc, % This.__Class . " requires a unicode version of AHK!"
			Return False
		}
		If (This.Base.HWND)
			Return False
		Gui, %GuiName%:+LastFoundExist
		GuiHwnd := WinExist()
		If !(GuiHwnd) {
			ErrorLevel := "ERROR: Gui " . GuiName . " does not exist!"
			Return False
		}
		If (This.Base.Instance = 0) {
			This.Base.Instance := DllCall("Kernel32.dll\LoadLibrary", "Str", This.Base.DLL, "UPtr")
			If (ErrorLevel) {
				ErrorLevel := "ERROR: Error loading " . This.Base.DLL . " - " . ErrorLevel
				Return False
			}
		}
		Styles := WS_TABSTOP | WS_VISIBLE | WS_CHILD ;| ES_AUTOHSCROLL
		If (MultiLine)
			Styles |= WS_VSCROLL | ES_MULTILINE | ES_AUTOVSCROLL | ES_NOHIDESEL | ES_WANTRETURN
		| ES_DISABLENOSCROLL | ES_SAVESEL ;| WS_HSCROLL
		ExStyles := WS_EX_STATICEDGE
		CtrlClass := This.Class
		Gui, %GuiName%:Add, Custom, Class%CtrlClass% %Options% hwndHWND +%Styles% +E%ExStyles%
		SendMessage, 0x0478, 0, 0x03, , ahk_id %HWND%
		If (This.Base.SubclassCB = 0)
			This.Base.SubclassCB := RegisterCallback("RichEdit.SubclassProc")
		DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", HWND, "Ptr", This.Base.SubclassCB, "Ptr", HWND, "Ptr", 0)
		This.GuiName := GuiName
		This.GuiHwnd := GuiHwnd
		This.HWND := HWND
		This.DefFont := This.GetFont(1)
		This.DefFont.Default := 1
		If (Round(This.DefFont.Size) <> This.DefFont.Size) {
			This.DefFont.Size := Round(This.DefFont.Size)
			This.SetDefaultFont()
		}
		This.Base.Controls += 1
		This.GetMargins()
		This.LimitText(2147483647)
	}
	__Delete() {
		If (This.HWND) {
			DllCall("Comctl32.dll\RemoveWindowSubclass", "Ptr", This.HWND, "Ptr", This.Base.SubclassCB, "Ptr", 0)
			DllCall("User32.dll\DestroyWindow", "Ptr", This.HWND)
			This.HWND := 0
			This.Base.Controls -= 1
			If (This.Base.Controls = 0) {
				DllCall("Kernel32.dll\FreeLibrary", "Ptr", This.Base.Instance)
				This.Base.Instance := 0
			}
		}
	}
	Class CF2 {
		__New() {
			Static CF2_Size := 116
			This.Insert(":", {Mask: {O: 4, T: "UInt"}, Effects: {O: 8, T: "UInt"}
			, Height: {O: 12, T: "Int"}, Offset: {O: 16, T: "Int"}
			, TextColor: {O: 20, T: "Int"}, CharSet: {O: 24, T: "UChar"}
			, PitchAndFamily: {O: 25, T: "UChar"}, FaceName: {O: 26, T: "Str32"}
			, Weight: {O: 90, T: "UShort"}, Spacing: {O: 92, T: "Short"}
			, BackColor: {O: 96, T: "UInt"}, LCID: {O: 100, T: "UInt"}
			, Cookie: {O: 104, T: "UInt"}, Style: {O: 108, T: "Short"}
			, Kerning: {O: 110, T: "UShort"}, UnderlineType: {O: 112, T: "UChar"}
			, Animation: {O: 113, T: "UChar"}, RevAuthor: {O: 114, T: "UChar"}
			, UnderlineColor: {O: 115, T: "UChar"}})
			This.Insert(".")
			This.SetCapacity(".", CF2_Size)
			Addr :=  This.GetAddress(".")
			DllCall("Kernel32.dll\RtlZeroMemory", "Ptr", Addr, "Ptr", CF2_Size)
			NumPut(CF2_Size, Addr + 0, 0, "UInt")
		}
		__Get(Name) {
			Addr := This.GetAddress(".")
			If (Name = "CF2")
				Return Addr
			If !This[":"].HasKey(Name)
				Return ""
			Attr := This[":"][Name]
			If (Name <> "FaceName")
				Return NumGet(Addr + 0, Attr.O, Attr.T)
			Return StrGet(Addr + Attr.O, 32)
		}
		__Set(Name, Value) {
			Addr := This.GetAddress(".")
			If !This[":"].HasKey(Name)
				Return ""
			Attr := This[":"][Name]
			If (Name <> "FaceName")
				NumPut(Value, Addr + 0, Attr.O, Attr.T)
			Else
				StrPut(Value, Addr + Attr.O, 32)
			Return Value
		}
	}
	Class PF2 {
		__New() {
			Static PF2_Size := 188
			This.Insert(":", {Mask: {O: 4, T: "UInt"}, Numbering: {O: 8, T: "UShort"}
			, StartIndent: {O: 12, T: "Int"}, RightIndent: {O: 16, T: "Int"}
			, Offset: {O: 20, T: "Int"}, Alignment: {O: 24, T: "UShort"}
			, TabCount: {O: 26, T: "UShort"}, Tabs: {O: 28, T: "UInt"}
			, SpaceBefore: {O: 156, T: "Int"}, SpaceAfter: {O: 160, T: "Int"}
			, LineSpacing: {O: 164, T: "Int"}, Style: {O: 168, T: "Short"}
			, LineSpacingRule: {O: 170, T: "UChar"}, OutlineLevel: {O: 171, T: "UChar"}
			, ShadingWeight: {O: 172, T: "UShort"}, ShadingStyle: {O: 174, T: "UShort"}
			, NumberingStart: {O: 176, T: "UShort"}, NumberingStyle: {O: 178, T: "UShort"}
			, NumberingTab: {O: 180, T: "UShort"}, BorderSpace: {O: 182, T: "UShort"}
			, BorderWidth: {O: 184, T: "UShort"}, Borders: {O: 186, T: "UShort"}})
			This.Insert(".")
			This.SetCapacity(".", PF2_Size)
			Addr :=  This.GetAddress(".")
			DllCall("Kernel32.dll\RtlZeroMemory", "Ptr", Addr, "Ptr", PF2_Size)
			NumPut(PF2_Size, Addr + 0, 0, "UInt")
		}
		__Get(Name) {
			Addr := This.GetAddress(".")
			If (Name = "PF2")
				Return Addr
			If !This[":"].HasKey(Name)
				Return ""
			Attr := This[":"][Name]
			If (Name <> "Tabs")
				Return NumGet(Addr + 0, Attr.O, Attr.T)
			Tabs := []
			Offset := Attr.O - 4
			Loop, 32
				Tabs[A_Index] := NumGet(Addr + 0, Offset += 4, "UInt")
			Return Tabs
		}
		__Set(Name, Value) {
			Addr := This.GetAddress(".")
			If !This[":"].HasKey(Name)
				Return ""
			Attr := This[":"][Name]
			If (Name <> "Tabs") {
				NumPut(Value, Addr + 0, Attr.O, Attr.T)
				Return Value
			}
			If !IsObject(Value)
				Return ""
			Offset := Attr.O - 4
			For Each, Tab In Value
				NumPut(Tab, Addr + 0, Offset += 4, "UInt")
			Return Tabs
		}
	}
	GetBGR(RGB) {
		Static HTML := {BLACK:  0x000000, SILVER: 0xC0C0C0, GRAY:   0x808080, WHITE:   0xFFFFFF
		, MAROON: 0x000080, RED:    0x0000FF, PURPLE: 0x800080, FUCHSIA: 0xFF00FF
		, GREEN:  0x008000, LIME:   0x00FF00, OLIVE:  0x008080, YELLOW:  0x00FFFF
		, NAVY:   0x800000, BLUE:   0xFF0000, TEAL:   0x808000, AQUA:    0xFFFF00}
		If HTML.HasKey(RGB)
			Return HTML[RGB]
		Return ((RGB & 0xFF0000) >> 16) + (RGB & 0x00FF00) + ((RGB & 0x0000FF) << 16)
	}
	GetRGB(BGR) {
		Return ((BGR & 0xFF0000) >> 16) + (BGR & 0x00FF00) + ((BGR & 0x0000FF) << 16)
	}
	GetMeasurement() {
		Static Metric := 2.54
		, Inches := 1.00
		, Measurement := ""
		, Len := A_IsUnicode ? 2 : 4
		If (Measurement = "") {
			VarSetCapacity(LCD, 4, 0)
			DllCall("Kernel32.dll\GetLocaleInfo", "UInt", 0x400, "UInt", 0x2000000D, "Ptr", &LCD, "Int", Len)
			Measurement := NumGet(LCD, 0, "UInt") ? Inches : Metric
		}
		Return Measurement
	}
	SubclassProc(M, W, L, I, R) {
		If (M = 0x87)
			Return 4
		Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", This, "UInt", M, "Ptr", W, "Ptr", L)
	}
	GetCharFormat() {
		CF2 := New This.CF2
		SendMessage, 0x043A, 1, % CF2.CF2, , % "ahk_id " . This.HWND
		Return (CF2.Mask ? CF2 : False)
	}
	SetCharFormat(CF2) {
		SendMessage, 0x0444, 1, % CF2.CF2, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	SetEventMask(Events := "") {
		Static ENM := {NONE: 0x00, CHANGE: 0x01, UPDATE: 0x02, SCROLL: 0x04, SCROLLEVENTS: 0x08, DRAGDROPDONE: 0x10
		, PARAGRAPHEXPANDED: 0x20, PAGECHANGE: 0x40, KEYEVENTS: 0x010000, MOUSEEVENTS: 0x020000
		, REQUESTRESIZE: 0x040000, SELCHANGE: 0x080000, DROPFILES: 0x100000, PROTECTED: 0x200000
		, LINK: 0x04000000}
		If !IsObject(Events)
			Events := ["NONE"]
		Mask := 0
		For Each, Event In Events {
			If ENM.HasKey(Event)
				Mask |= ENM[Event]
			Else
				Return False
		}
		SendMessage, 0x0445, 0, %Mask%, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	GetRTF(Selection := False) {
		Static GetRTFCB := 0
		Flags := 0x4022 | (1200 << 16) | (Selection ? 0x8000 : 0)
		GetRTFCB := RegisterCallback("RichEdit.GetRTFProc")
		VarSetCapacity(ES, (A_PtrSize * 2) + 4, 0)
		NumPut(This.HWND, ES, 0, "Ptr")
		NumPut(GetRTFCB, ES, A_PtrSize + 4, "Ptr")
		SendMessage, 0x044A, %Flags%, &ES, , % "ahk_id " . This.HWND
		DllCall("Kernel32.dll\GlobalFree", "Ptr", GetRTFCB)
		Return This.GetRTFProc("Get", 0, 0)
	}
	GetRTFProc(pbBuff, cb, pcb) {
		Static RTF := ""
		If (cb > 0) {
			RTF .= StrGet(pbBuff, cb, "CP0")
			Return 0
		}
		If (pbBuff = "Get") {
			Out := RTF
			VarSetCapacity(RTF, 0)
			Return Out
		}
		Return 1
	}
	LoadRTF(FilePath, Selection := False) {
		Static LoadRTFCB := 0, PCB := 0
		Flags := 0x4002 | (Selection ? 0x8000 : 0)
		This.LoadRTFProc(FilePath, 0, 0)
		LoadRTFCB := RegisterCallback("RichEdit.LoadRTFProc")
		VarSetCapacity(ES, (A_PtrSize * 2) + 4, 0)
		NumPut(This.HWND, ES, 0, "Ptr")
		NumPut(LoadRTFCB, ES, A_PtrSize + 4, "Ptr")
		SendMessage, 0x0449, %Flags%, &ES, , % "ahk_id " . This.HWND
		Result := ErrorLevel
		DllCall("Kernel32.dll\GlobalFree", "Ptr", LoadRTFCB)
		Return Result
	}
	LoadRTFProc(pbBuff, cb, pcb) {
		Static File := ""
		If (cb > 0) {
			If !IsObject(File)
				Return 1
			If File.AtEOF {
				File.Close()
				File := ""
				NumPut(0, pcb + 0, 0, "UInt")
				Return 0
			}
			NumPut(File.RawRead(pbBuff + 0, cb), pcb + 0, "UInt")
			Return 0
		}
		If !(pbBuff + 0) {
			If !IsObject(File := FileOpen(pbBuff, "r"))
				Return False
			Return True
		}
		Return 1
	}
	GetScrollPos() {
		VarSetCapacity(PT, 8, 0)
		SendMessage, 0x04DD, 0, &PT, , % "ahk_id " . This.HWND
		Return {X: NumGet(PT, 0, "Int"), Y: NumGet(PT, 4, "Int")}
	}
	SetScrollPos(X, Y) {
		VarSetCapacity(PT, 8, 0)
		NumPut(X, PT, 0, "Int")
		NumPut(Y, PT, 4, "Int")
		SendMessage, 0x04DE, 0, &PT, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	ScrollCaret() {
		SendMessage, 0x00B7, 0, 0, , % "ahk_id " . This.HWND
		Return True
	}
	ShowScrollBar(SB, Mode := True) {
		SendMessage, 0x0460, %SB%, %Mode%, , % "ahk_id " . This.HWND
		Return True
	}
	FindText(Find, Mode := "") {
		Static FR:= {DOWN: 1, WHOLEWORD: 2, MATCHCASE: 4}
		Flags := 0
		For Each, Value In Mode
			If FR.HasKey(Value)
				Flags |= FR[Value]
		Sel := This.GetSel()
		Min := (Flags & FR.DOWN) ? Sel.E : Sel.S
		Max := (Flags & FR.DOWN) ? -1 : 0
		VarSetCapacity(FTX, 16 + A_PtrSize, 0)
		NumPut(Min, FTX, 0, "Int")
		NumPut(Max, FTX, 4, "Int")
		NumPut(&Find, FTX, 8, "Ptr")
		SendMessage, 0x047C, %Flags%, &FTX, , % "ahk_id " . This.HWND
		S := NumGet(FTX, 8 + A_PtrSize, "Int"), E := NumGet(FTX, 12 + A_PtrSize, "Int")
		If (S = -1) && (E = -1)
			Return False
		This.SetSel(S, E)
		This.ScrollCaret()
		Return
	}
	GetSelText() {
		VarSetCapacity(CR, 8, 0)
		SendMessage, 0x0434, 0, &CR, , % "ahk_id " . This.HWND
		L := NumGet(CR, 4, "Int") - NumGet(CR, 0, "Int") + 1
		If (L > 1) {
			VarSetCapacity(Text, L * 2, 0)
			SendMessage, 0x043E, 0, &Text, , % "ahk_id " . This.HWND
			VarSetCapacity(Text, -1)
		}
		Return Text
	}
	GetSel() {
		VarSetCapacity(CR, 8, 0)
		SendMessage, 0x0434, 0, &CR, , % "ahk_id " . This.HWND
		Return {S: NumGet(CR, 0, "Int"), E: NumGet(CR, 4, "Int")}
	}
	GetText() {
		Text := ""
		If (Length := This.GetTextLen() * 2) {
			VarSetCapacity(GTX, (4 * 4) + (A_PtrSize * 2), 0)
			NumPut(Length + 2, GTX, 0, "UInt")
			NumPut(1200, GTX, 8, "UInt")
			VarSetCapacity(Text, Length + 2, 0)
			SendMessage, 0x045E, &GTX, &Text, , % "ahk_id " . This.HWND
			VarSetCapacity(Text, -1)
		}
		Return Text
	}
	GetTextLen() {
		VarSetCapacity(GTL, 8, 0)
		NumPut(1200, GTL, 4, "UInt")
		SendMessage, 0x045F, &GTL, 0, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	GetTextRange(Min, Max) {
		If (Max <= Min)
			Return ""
		VarSetCapacity(Text, (Max - Min) << !!A_IsUnicode, 0)
		VarSetCapacity(TEXTRANGE, 16, 0)
		NumPut(Min, TEXTRANGE, 0, "UInt")
		NumPut(Max, TEXTRANGE, 4, "UInt")
		NumPut(&Text, TEXTRANGE, 8, "UPtr")
		SendMessage, 0x044B, 0, % &TEXTRANGE, , % "ahk_id " . This.HWND
		VarSetCapacity(Text, -1)
		Return Text
	}
	HideSelection(Mode) {
		SendMessage, 0x043F, %Mode%, 0, , % "ahk_id " . This.HWND
		Return True
	}
	LimitText(Limit)  {
		SendMessage, 0x0435, 0, %Limit%, , % "ahk_id " . This.HWND
		Return True
	}
	ReplaceSel(Text := "") {
		SendMessage, 0xC2, 1, &Text, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	SetText(ByRef Text := "", Mode := "") {
		Static ST := {DEFAULT: 0, KEEPUNDO: 1, SELECTION: 2}
		Flags := 0
		For Each, Value In Mode
			If ST.HasKey(Value)
				Flags |= ST[Value]
		CP := 1200
		BufAddr := &Text
		If (SubStr(Text, 1, 5) = "{\rtf") || (SubStr(Text, 1, 5) = "{urtf") {
			Len := StrPut(Text, "CP0")
			VarSetCapacity(Buf, Len, 0)
			StrPut(Text, &Buf, "CP0")
			BufAddr := &Buf
			CP := 0
		}
		VarSetCapacity(STX, 8, 0)
		NumPut(Flags, STX, 0, "UInt")
		NumPut(CP  ,  STX, 4, "UInt")
		SendMessage, 0x0461, &STX, BufAddr, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	SetSel(Start, End) {
		VarSetCapacity(CR, 8, 0)
		NumPut(Start, CR, 0, "Int")
		NumPut(End,   CR, 4, "Int")
		SendMessage, 0x0437, 0, &CR, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	AutoURL(On) {
		SendMessage, 0x45B, % !!On, 0, , % "ahk_id " . This.HWND
		WinSet, Redraw, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	GetOptions() {
		Static ECO := {AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100
		, READONLY: 0x800, WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000
		, VERTICAL: 0x400000}
		SendMessage, 0x044E, 0, 0, , % "ahk_id " . This.HWND
		O := ErrorLevel
		Options := []
		For Key, Value In ECO
			If (O & Value)
				Options.Insert(Key)
		Return Options
	}
	GetStyles() {
		Static SES := {1: "EMULATESYSEDIT", 1: "BEEPONMAXTEXT", 4: "EXTENDBACKCOLOR", 32: "NOXLTSYMBOLRANGE", 64: "USEAIMM"
		, 128: "NOIME", 256: "ALLOWBEEPS", 512: "UPPERCASE", 1024: "LOWERCASE", 2048: "NOINPUTSEQUENCECHK"
		, 4096: "BIDI", 8192: "SCROLLONKILLFOCUS", 16384: "XLTCRCRLFTOCR", 32768: "DRAFTMODE"
		, 0x0010000: "USECTF", 0x0020000: "HIDEGRIDLINES", 0x0040000: "USEATFONT", 0x0080000: "CUSTOMLOOK"
		, 0x0100000: "LBSCROLLNOTIFY", 0x0200000: "CTFALLOWEMBED", 0x0400000: "CTFALLOWSMARTTAG"
		, 0x0800000: "CTFALLOWPROOFING"}
		SendMessage, 0x04CD, 0, 0, , % "ahk_id " . This.HWND
		Result := ErrorLevel
		Styles := []
		For Key, Value In SES
			If (Result & Key)
				Styles.Insert(Value)
		Return Styles
	}
	SetBkgndColor(Color) {
		If (Color = "Auto")
			System := True, Color := 0
		Else
			System := False, Color := This.GetBGR(Color)
		SendMessage, 0x0443, %System%, %Color%, , % "ahk_id " . This.HWND
		Return This.GetRGB(ErrorLevel)
	}
	SetOptions(Options, Mode := "SET") {
		Static ECO := {AUTOWORDSELECTION: 0x01, AUTOVSCROLL: 0x40, AUTOHSCROLL: 0x80, NOHIDESEL: 0x100, READONLY: 0x800
		, WANTRETURN: 0x1000, SAVESEL: 0x8000, SELECTIONBAR: 0x01000000, VERTICAL: 0x400000}
		, ECOOP := {SET: 0x01, OR: 0x02, AND: 0x03, XOR: 0x04}
		If !ECOOP.HasKey(Mode)
			Return False
		O := 0
		For Each, Option In Options {
			If ECO.HasKey(Option)
				O |= ECO[Option]
			Else
				Return False
		}
		SendMessage, 0x044D, % ECOOP[Mode], %O%, , % "ahk_id " . This.HWND
		Return ErrorLevel
	}
	SetStyles(Styles) {
		Static SES = {EMULATESYSEDIT: 1, BEEPONMAXTEXT: 2, EXTENDBACKCOLOR: 4, NOXLTSYMBOLRANGE: 32, USEAIMM: 64
		, NOIME: 128, ALLOWBEEPS: 256, UPPERCASE: 512, LOWERCASE: 1024, NOINPUTSEQUENCECHK: 2048
		, BIDI: 4096, SCROLLONKILLFOCUS: 8192, XLTCRCRLFTOCR: 16384, DRAFTMODE: 32768
		, USECTF: 0x0010000, HIDEGRIDLINES: 0x0020000, USEATFONT: 0x0040000, CUSTOMLOOK: 0x0080000
		, LBSCROLLNOTIFY: 0x0100000, CTFALLOWEMBED: 0x0200000, CTFALLOWSMARTTAG: 0x0400000
		, CTFALLOWPROOFING: 0x0800000}
		Flags := Mask := 0
		For Style, Value In Styles {
			If SES.HasKey(Style) {
				Mask |= SES[Style]
				If (Value <> 0)
					Flags |= SES[Style]
			}
		}
		If (Mask) {
			SendMessage, 0x04CC, %Flags%, %Mask%, ,, % "ahk_id " . This.HWND
			Return ErrorLevel
		}
		Return False
	}
	ChangeFontSize(Diff) {
		Font := This.GetFont()
		If (Diff > 0 && Font.Size < 160) || (Diff < 0 && Font.Size > 4)
			SendMessage, 0x04DF, % (Diff > 0 ? 1 : -1), 0, , % "ahk_id " . This.HWND
		Else
			Return False
		Font := This.GetFont()
		Return Font.Size
	}
	GetFont(Default := False) {
		Static Mask := 0xEC03001F
		Static Effects := 0xEC000000
		CF2 := New This.CF2
		CF2.Mask := Mask
		CF2.Effects := Effects
		SendMessage, 0x043A, % (Default ? 0 : 1), % CF2.CF2, , % "ahk_id " . This.HWND
		Font := {}
		Font.Name := CF2.FaceName
		Font.Size := CF2.Height / 20
		CFS := CF2.Effects
		Style := (CFS & 1 ? "B" : "") . (CFS & 2 ? "I" : "") . (CFS & 4 ? "U" : "") . (CFS & 8 ? "S" : "")
		. (CFS & 0x10000 ? "L" : "") . (CFS & 0x20000 ? "H" : "") . (CFS & 16 ? "P" : "")
		Font.Style := Style = "" ? "N" : Style
		Font.Color := This.GetRGB(CF2.TextColor)
		If (CF2.Effects & 0x04000000)
			Font.BkColor := "Auto"
		Else
			Font.BkColor := This.GetRGB(CF2.BackColor)
		Font.CharSet := CF2.CharSet
		Return Font
	}
	SetDefaultFont(Font := "") {
		If IsObject(Font) {
			For Key, Value In Font
				If This.DefFont.HasKey(Key)
					This.DefFont[Key] := Value
		}
		Return This.SetFont(This.DefFont)
	}
	SetFont(Font) {
		CF2 := New This.CF2
		Mask := Effects := 0
		If (Font.Name != "") {
			Mask |= 0x20000000, Effects |= 0x20000000
			CF2.FaceName := Font.Name
		}
		Size := Font.Size
		If (Size != "") {
			If (Size < 161)
				Size *= 20
			Mask |= 0x80000000, Effects |= 0x80000000
			CF2.Height := Size
		}
		If (Font.Style != "") {
			Mask |= 0x3001F
			If InStr(Font.Style, "B")
				Effects |= 1
			If InStr(Font.Style, "I")
				Effects |= 2
			If InStr(Font.Style, "U")
				Effects |= 4
			If InStr(Font.Style, "S")
				Effects |= 8
			If InStr(Font.Style, "P")
				Effects |= 16
			If InStr(Font.Style, "L")
				Effects |= 0x10000
			If InStr(Font.Style, "H")
				Effects |= 0x20000
		}
		If (Font.Color != "") {
			Mask |= 0x40000000
			If (Font.Color = "Auto")
				Effects |= 0x40000000
			Else
				CF2.TextColor := This.GetBGR(Font.Color)
		}
		If (Font.BkColor != "") {
			Mask |= 0x04000000
			If (Font.BkColor = "Auto")
				Effects |= 0x04000000
			Else
				CF2.BackColor := This.GetBGR(Font.BkColor)
		}
		If (Font.CharSet != "") {
			Mask |= 0x08000000, Effects |= 0x08000000
			CF2.CharSet := Font.CharSet = 2 ? 2 : 1
		}
		If (Mask != 0) {
			Mode := Font.Default ? 0 : 1
			CF2.Mask := Mask
			CF2.Effects := Effects
			SendMessage, 0x0444, %Mode%, % CF2.CF2, , % "ahk_id " . This.HWND
			Return ErrorLevel
		}
		Return False
	}
}
