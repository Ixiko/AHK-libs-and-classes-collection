/*
	class RichCode({"TabSize": 4     ; Width of a tab in characters
		, "Indent": "`t"             ; What text to insert on indent
		, "FGColor": 0xRRGGBB        ; Foreground (text) color
		, "BGColor": 0xRRGGBB        ; Background color
		, "Font"                     ; Font to use
		: {"Typeface": "Courier New" ; Name of the typeface
			, "Size": 12             ; Font size in points
			, "Bold": False}         ; Bolded (True/False)
		
		
		; Whether to use the highlighter, or leave it as plain text
		, "UseHighlighter": True
		
		; Delay after typing before the highlighter is run
		, "HighlightDelay": 200
		
		; The highlighter function (FuncObj or name)
		; to generate the highlighted RTF. It will be passed
		; two parameters, the first being this settings array
		; and the second being the code to be highlighted
		, "Highlighter": Func("HighlightAHK")
		
		; The colors to be used by the highlighter function.
		; This is currently used only by the highlighter, not at all by the
		; RichCode class. As such, the RGB ordering is by convention only.
		; You can add as many colors to this array as you want.
		, "Colors"
		: [0xRRGGBB
			, 0xRRGGBB
			, 0xRRGGBB,
			, 0xRRGGBB]})
*/

class RichCode
{
	static Msftedit := DllCall("LoadLibrary", "Str", "Msftedit.dll")
	static IID_ITextDocument := "{8CC497C0-A1DF-11CE-8098-00AA0047BE5D}"
	static MenuItems := ["Cut", "Copy", "Paste", "Delete", "", "Select All", ""
		, "UPPERCASE", "lowercase", "TitleCase"]
	
	_Frozen := False
	
	; --- Static Methods ---
	
	BGRFromRGB(RGB)
	{
		return RGB>>16&0xFF | RGB&0xFF00 | RGB<<16&0xFF0000
	}
	
	; --- Properties ---
	
	Value[]
	{
		get {
			GuiControlGet, Code,, % this.hWnd
			return Code
		}
		
		set {
			this.Highlight(Value)
			return Value
		}
	}
	
	; TODO: reserve and reuse memory
	Selection[i:=0]
	{
		get {
			VarSetCapacity(CHARRANGE, 8, 0)
			this.SendMsg(0x434, 0, &CHARRANGE) ; EM_EXGETSEL
			Out := [NumGet(CHARRANGE, 0, "Int"), NumGet(CHARRANGE, 4, "Int")]
			return i ? Out[i] : Out
		}
		
		set {
			if i
				Temp := this.Selection, Temp[i] := Value, Value := Temp
			VarSetCapacity(CHARRANGE, 8, 0)
			NumPut(Value[1], &CHARRANGE, 0, "Int") ; cpMin
			NumPut(Value[2], &CHARRANGE, 4, "Int") ; cpMax
			this.SendMsg(0x437, 0, &CHARRANGE) ; EM_EXSETSEL
			return Value
		}
	}
	
	SelectedText[]
	{
		get {
			Selection := this.Selection, Length := Selection[2] - Selection[1]
			VarSetCapacity(Buffer, (Length + 1) * 2) ; +1 for null terminator
			if (this.SendMsg(0x43E, 0, &Buffer) > Length) ; EM_GETSELTEXT
				throw Exception("Text larger than selection! Buffer overflow!")
			Text := StrGet(&Buffer, Selection[2]-Selection[1], "UTF-16")
			return StrReplace(Text, "`r", "`n")
		}
		
		set {
			this.SendMsg(0xC2, 1, &Value) ; EM_REPLACESEL
			this.Selection[1] -= StrLen(Value)
			return Value
		}
	}
	
	EventMask[]
	{
		get {
			return this._EventMask
		}
		
		set {
			this._EventMask := Value
			this.SendMsg(0x445, 0, Value) ; EM_SETEVENTMASK
			return Value
		}
	}
	
	UndoSuspended[]
	{
		get {
			return this._UndoSuspended
		}
		
		set {
			try ; ITextDocument is not implemented in WINE
			{
				if Value
					this.ITextDocument.Undo(-9999995) ; tomSuspend
				else
					this.ITextDocument.Undo(-9999994) ; tomResume
			}
			return this._UndoSuspended := !!Value
		}
	}
	
	Frozen[]
	{
		get {
			return this._Frozen
		}
		
		set {
			if (Value && !this._Frozen)
			{
				try ; ITextDocument is not implemented in WINE
					this.ITextDocument.Freeze()
				catch
					GuiControl, -Redraw, % this.hWnd
			}
			else if (!Value && this._Frozen)
			{
				try ; ITextDocument is not implemented in WINE
					this.ITextDocument.Unfreeze()
				catch
					GuiControl, +Redraw, % this.hWnd
			}
			return this._Frozen := !!Value
		}
	}
	
	Modified[]
	{
		get {
			return this.SendMsg(0xB8, 0, 0) ; EM_GETMODIFY
		}
		
		set {
			this.SendMsg(0xB9, Value, 0) ; EM_SETMODIFY
			return Value
		}
	}
	
	; --- Construction, Destruction, Meta-Functions ---
	
	__New(Settings, Options:="")
	{
		static Test
		this.Settings := Settings
		FGColor := this.BGRFromRGB(Settings.FGColor)
		BGColor := this.BGRFromRGB(Settings.BGColor)
		
		Gui, Add, Custom, ClassRichEdit50W hWndhWnd +0x5031b1c4 +E0x20000 %Options%
		this.hWnd := hWnd

		; Enable WordWrap in RichEdit control ("WordWrap" : true)
		if this.Settings.WordWrap
			SendMessage, 0x0448, 0, 0, , % "ahk_id " . This.HWND

		; Register for WM_COMMAND and WM_NOTIFY events
		; NOTE: this prevents garbage collection of
		; the class until the control is destroyed
		this.EventMask := 1 ; ENM_CHANGE
		CtrlEvent := this.CtrlEvent.Bind(this)
		GuiControl, +g, %hWnd%, %CtrlEvent%
		
		; Set background color
		this.SendMsg(0x443, 0, BGColor) ; EM_SETBKGNDCOLOR
		
		; Set character format
		VarSetCapacity(CHARFORMAT2, 116, 0)
		NumPut(116,                    CHARFORMAT2, 0,  "UInt")       ; cbSize      = sizeof(CHARFORMAT2)
		NumPut(0xE0000000,             CHARFORMAT2, 4,  "UInt")       ; dwMask      = CFM_COLOR|CFM_FACE|CFM_SIZE
		NumPut(FGColor,                CHARFORMAT2, 20, "UInt")       ; crTextColor = 0xBBGGRR
		NumPut(Settings.Font.Size*20,  CHARFORMAT2, 12, "UInt")       ; yHeight     = twips
		StrPut(Settings.Font.Typeface, &CHARFORMAT2+26, 32, "UTF-16") ; szFaceName  = TCHAR
		this.SendMsg(0x444, 0, &CHARFORMAT2) ; EM_SETCHARFORMAT
		
		; Set tab size to 4 for non-highlighted code
		VarSetCapacity(TabStops, 4, 0), NumPut(Settings.TabSize*4, TabStops, "UInt")
		this.SendMsg(0x0CB, 1, &TabStops) ; EM_SETTABSTOPS
		
		; Change text limit from 32,767 to max
		this.SendMsg(0x435, 0, -1) ; EM_EXLIMITTEXT
		
		; Bind for keyboard events
		; Use a pointer to prevent reference loop
		this.OnMessageBound := this.OnMessage.Bind(&this)
		OnMessage(0x100, this.OnMessageBound) ; WM_KEYDOWN
		OnMessage(0x205, this.OnMessageBound) ; WM_RBUTTONUP
		
		; Bind the highlighter
		this.HighlightBound := this.Highlight.Bind(&this)
		
		; Create the right click menu
		this.MenuName := this.__Class . &this
		RCMBound := this.RightClickMenu.Bind(&this)
		for Index, Entry in this.MenuItems
			Menu, % this.MenuName, Add, %Entry%, %RCMBound%
		
		; Get the ITextDocument object
		VarSetCapacity(pIRichEditOle, A_PtrSize, 0)
		this.SendMsg(0x43C, 0, &pIRichEditOle) ; EM_GETOLEINTERFACE
		this.pIRichEditOle := NumGet(pIRichEditOle, 0, "UPtr")
		this.IRichEditOle := ComObject(9, this.pIRichEditOle, 1), ObjAddRef(this.pIRichEditOle)
		this.pITextDocument := ComObjQuery(this.IRichEditOle, this.IID_ITextDocument)
		this.ITextDocument := ComObject(9, this.pITextDocument, 1), ObjAddRef(this.pITextDocument)
	}
	
	RightClickMenu(ItemName, ItemPos, MenuName)
	{
		if !IsObject(this)
			this := Object(this)
		
		if (ItemName == "Cut")
			Clipboard := this.SelectedText, this.SelectedText := ""
		else if (ItemName == "Copy")
			Clipboard := this.SelectedText
		else if (ItemName == "Paste")
			this.SelectedText := Clipboard
		else if (ItemName == "Delete")
			this.SelectedText := ""
		else if (ItemName == "Select All")
			this.Selection := [0, -1]
		else if (ItemName == "UPPERCASE")
			this.SelectedText := Format("{:U}", this.SelectedText)
		else if (ItemName == "lowercase")
			this.SelectedText := Format("{:L}", this.SelectedText)
		else if (ItemName == "TitleCase")
			this.SelectedText := Format("{:T}", this.SelectedText)
	}
	
	__Delete()
	{
		; Release the ITextDocument object
		this.ITextDocument := "", ObjRelease(this.pITextDocument)
		this.IRichEditOle := "", ObjRelease(this.pIRichEditOle)
		
		; Release the OnMessage handlers
		OnMessage(0x100, this.OnMessageBound, 0) ; WM_KEYDOWN
		OnMessage(0x205, this.OnMessageBound, 0) ; WM_RBUTTONUP
		
		; Destroy the right click menu
		Menu, % this.MenuName, Delete
		
		HighlightBound := this.HighlightBound
		SetTimer, %HighlightBound%, Delete
	}
	
	; --- Event Handlers ---
	
	OnMessage(wParam, lParam, Msg, hWnd)
	{
		if !IsObject(this)
			this := Object(this)
		if (hWnd != this.hWnd)
			return
		
		if (Msg == 0x100) ; WM_KEYDOWN
		{
			if (wParam == GetKeyVK("Tab"))
			{
				; Indentation
				Selection := this.Selection
				if GetKeyState("Shift")
					this.IndentSelection(True) ; Reverse
				else if (Selection[2] - Selection[1]) ; Something is selected
					this.IndentSelection()
				else
				{
					; TODO: Trim to size needed to reach next TabSize
					this.SelectedText := this.Settings.Indent
					this.Selection[1] := this.Selection[2] ; Place cursor after
				}
				return False
			}
			else if (wParam == GetKeyVK("Escape")) ; Normally closes the window
				return False
			else if (wParam == GetKeyVK("v") && GetKeyState("Ctrl"))
			{
				this.SelectedText := Clipboard ; Strips formatting
				this.Selection[1] := this.Selection[2] ; Place cursor after
				return False
			}
		}
		else if (Msg == 0x205) ; WM_RBUTTONUP
		{
			Menu, % this.MenuName, Show
			return False
		}
	}
	
	CtrlEvent(CtrlHwnd, GuiEvent, EventInfo, _ErrorLevel:="")
	{
		if (GuiEvent == "Normal" && EventInfo == 0x300) ; EN_CHANGE
		{
			; Delay until the user is finished changing the document
			HighlightBound := this.HighlightBound
			SetTimer, %HighlightBound%, % -Abs(this.Settings.HighlightDelay)
		}
	}
	
	; --- Methods ---
	
	; First parameter is taken as a replacement value
	; Variadic form is used to detect when a parameter is given,
	; regardless of content
	Highlight(NewVal*)
	{
		if !IsObject(this)
			this := Object(this)
		if !(this.Settings.UseHighlighter && this.Settings.Highlighter)
		{
			if NewVal.Length()
				GuiControl,, % this.hWnd, % NewVal[1]
			return
		}
		
		; Freeze the control while it is being modified, stop change event
		; generation, suspend the undo buffer, buffer any input events
		PrevFrozen := this.Frozen, this.Frozen := True
		PrevEventMask := this.EventMask, this.EventMask := 0 ; ENM_NONE
		PrevUndoSuspended := this.UndoSuspended, this.UndoSuspended := True
		PrevCritical := A_IsCritical
		Critical, 1000
		
		; Run the highlighter
		Highlighter := this.Settings.Highlighter
		RTF := %Highlighter%(this.Settings, NewVal.Length() ? NewVal[1] : this.Value)
		
		; "TRichEdit suspend/resume undo function"
		; https://stackoverflow.com/a/21206620
		
		; Save the rich text to a UTF-8 buffer
		VarSetCapacity(Buf, StrPut(RTF, "UTF-8"), 0)
		StrPut(RTF, &Buf, "UTF-8")
		
		; Set up the necessary structs
		VarSetCapacity(ZOOM,      8, 0) ; Zoom Level
		VarSetCapacity(POINT,     8, 0) ; Scroll Pos
		VarSetCapacity(CHARRANGE, 8, 0) ; Selection
		VarSetCapacity(SETTEXTEX, 8, 0) ; SetText Settings
		NumPut(1, SETTEXTEX, 0, "UInt") ; flags = ST_KEEPUNDO
		
		; Save the scroll and cursor positions, update the text,
		; then restore the scroll and cursor positions
		MODIFY := this.SendMsg(0xB8, 0, 0)    ; EM_GETMODIFY
		this.SendMsg(0x4E0, &ZOOM, &ZOOM+4)   ; EM_GETZOOM
		this.SendMsg(0x4DD, 0, &POINT)        ; EM_GETSCROLLPOS
		this.SendMsg(0x434, 0, &CHARRANGE)    ; EM_EXGETSEL
		this.SendMsg(0x461, &SETTEXTEX, &Buf) ; EM_SETTEXTEX
		this.SendMsg(0x437, 0, &CHARRANGE)    ; EM_EXSETSEL
		this.SendMsg(0x4DE, 0, &POINT)        ; EM_SETSCROLLPOS
		this.SendMsg(0x4E1, NumGet(ZOOM, "UInt")
			, NumGet(ZOOM, 4, "UInt"))        ; EM_SETZOOM
		this.SendMsg(0xB9, MODIFY, 0)         ; EM_SETMODIFY
		
		; Restore previous settings
		Critical, %PrevCritical%
		this.UndoSuspended := PrevUndoSuspended
		this.EventMask := PrevEventMask
		this.Frozen := PrevFrozen
	}
	
	IndentSelection(Reverse:=False, Indent:="")
	{
		; Freeze the control while it is being modified, stop change event
		; generation, buffer any input events
		PrevFrozen := this.Frozen, this.Frozen := True
		PrevEventMask := this.EventMask, this.EventMask := 0 ; ENM_NONE
		PrevCritical := A_IsCritical
		Critical, 1000
		
		if (Indent == "")
			Indent := this.Settings.Indent
		IndentLen := StrLen(Indent)
		
		; Select back to the start of the first line
		Min := this.Selection[1]
		Top := this.SendMsg(0x436, 0, Min) ; EM_EXLINEFROMCHAR
		TopLineIndex := this.SendMsg(0xBB, Top, 0) ; EM_LINEINDEX
		this.Selection[1] := TopLineIndex
		
		; TODO: Insert newlines using SetSel/ReplaceSel to avoid having to call
		; the highlighter again
		Text := this.SelectedText
		if Reverse
		{
			; Remove indentation appropriately
			Loop, Parse, Text, `n, `r
			{
				if (InStr(A_LoopField, Indent) == 1)
				{
					Out .= "`n" SubStr(A_LoopField, 1+IndentLen)
					if (A_Index == 1)
						Min -= IndentLen
				}
				else
					Out .= "`n" A_LoopField
			}
			this.SelectedText := SubStr(Out, 2)
			
			; Move the selection start back, but never onto the previous line
			this.Selection[1] := Min < TopLineIndex ? TopLineIndex : Min
		}
		else
		{
			; Add indentation appropriately
			Trailing := (SubStr(Text, 0) == "`n")
			Temp := Trailing ? SubStr(Text, 1, -1) : Text
			Loop, Parse, Temp, `n, `r
				Out .= "`n" Indent . A_LoopField
			this.SelectedText := SubStr(Out, 2) . (Trailing ? "`n" : "")
			
			; Move the selection start forward
			this.Selection[1] := Min + IndentLen
		}
		
		this.Highlight()
		
		; Restore previous settings
		Critical, %PrevCritical%
		this.EventMask := PrevEventMask
		
		; When content changes cause the horizontal scrollbar to disappear,
		; unfreezing causes the scrollbar to jump. To solve this, jump back
		; after unfreezing. This will cause a flicker when that edge case
		; occurs, but it's better than the alternative.
		VarSetCapacity(POINT, 8, 0)
		this.SendMsg(0x4DD, 0, &POINT) ; EM_GETSCROLLPOS
		this.Frozen := PrevFrozen
		this.SendMsg(0x4DE, 0, &POINT) ; EM_SETSCROLLPOS
	}
	
	; --- Helper/Convenience Methods ---
	
	SendMsg(Msg, wParam, lParam)
	{
		SendMessage, Msg, wParam, lParam,, % "ahk_id" this.hWnd
		return ErrorLevel
	}
}
