#Requires AutoHotKey v2.0-beta.3
; #SingleInstance Force


; ; Testing Toolbar
; myGui := Gui()

; myGui.OnEvent("Close", GuiEscape)
; myGui.OnEvent("Escape", GuiEscape)
; myGui.SetFont("s9", "Segoe UI")
; myGui.Title := "Window"


; oToolbar2 := Toolbar()
; oButton := oToolbar2.Add("", "Button1", (*)=>(MsgBox("Text")), "shell32.dll", 4)

; oToolbar2.Add("", "Button2", Callback1, "shell32.dll", 20)
; oToolbar2.Add()
; oToolbar2.Add("", "Button3", Callback2, "shell32.dll", 24)
; oToolbar2.Add("", "Button4", Callback2, "shell32.dll", 22)

; AddToolbar(oToolbar2, myGui,,"x10 Y10")
; myGui.Show("w620 h420")


; callBack1(p*){
;     MsgBox("Calback1")
; }
; callBack2(p*){
;     MsgBox("Calback2")
; }


class Toolbar {
    __New(genOptions:="Flat List Tooltips") {
        this.aButtons := Array()
        this.options := genOptions
    }
    Add(options:="", buttontext:="", callback:="", iconFile:="", iconNumber:=1) {
        EnabledState := 0=InStr(options,"disabled")
        oButton := {options: options, text: buttontext, callback: callback, iconFile: iconFile, iconNumber: iconNumber, enabled:EnabledState ,parent:this}
        this.aButtons.Push(oButton)
        return oButton
    }
}
AddToolbar(Toolbar, GuiObj, Extra := "", Pos := "", Padding := "", ExStyle := 0x9){
    Toolbar.ImageList := IL_Create(Toolbar.aButtons.length)
    aButtons := Array()
    for Index, oButton in Toolbar.aButtons{
        IL_Add(Toolbar.ImageList, oButton.iconFile, oButton.iconNumber)
        aButtons.Push(oButton.text)
    }

    options := Toolbar.options

    Local fShowText, fTextOnly, Styles, TBB_Size, cButtons, TBBUTTONS
    , Index, Button, iBitmap, idCommand, fsState, fsStyle, iString, Offset, SIZE
    Static TOOLTIPS := 0x100, WRAPABLE := 0x200, FLAT := 0x800, LIST := 0x1000, TABSTOP := 0x10000
    , BORDER := 0x800000, TEXTONLY := 0, BOTTOM := 0x3
    , ADJUSTABLE := 0x20, NODIVIDER := 0x40, VERTICAL := 0x80
    , CHECKED := 1, HIDDEN := 8, WRAP := 32, DISABLED := 0
    , CHECK := 2, CHECKGROUP := 6, DROPDOWN := 8, AUTOSIZE := 16
    , NOPREFIX := 32, SHOWTEXT := 64, WHOLEDROPDOWN := 128

    StrReplace(Options, "SHOWTEXT", "", , &fShowText, 1)
    fTextOnly := InStr(Options, "TEXTONLY")

    Styles := 0
    Loop Parse, Options, A_Tab "" A_Space, A_Tab "" A_Space	; Parse toolbar styles
    {
        if (A_LoopField = "")
            Continue
        Else Styles |= IsNumber(A_LoopField) ? A_LoopField : %A_LoopField%
    }
    If (Pos != "") {
        Styles |= 0x4C	; CCS_NORESIZE | CCS_NOPARENTALIGN | CCS_NODIVIDER
    }

    ogc := GuiObj.Add("Custom", "ClassToolbarWindow32  -Tabstop " . Pos . " " . Styles . " " . Extra)

    NM_Codes := { Click: -2, RightClick: -5, LDown: -20, Hot: -713, DropDown: -710 }
    ogc.DefineProp('OnEvent', { call: ((this, Event, Callback) => (this.CallBack := CallBack.Name, this.OnNotify(NM_Codes.%Event%, Toolbar_Callback))) })

    hWnd := ogc.hwnd

    TBB_Size := A_PtrSize == 8 ? 32 : 20
    cButtons := aButtons.Length
    TBBUTTONS := Buffer(TBB_Size * cButtons, 0)

    strings := Array()
    Index := 0
    for Key, oButton in Toolbar.aButtons {

        If (oButton.text == "" && oButton.iconFile == "") {
            iBitmap := 0
            idCommand := 0
            fsState := 0
            fsStyle := 1	; BTNS_SEP
            iString := buffer(StrPut(-1))
            StrPut(-1, iString)
        } Else {
            Index++
            iBitmap := (fTextOnly) ? -1 : ((oButton.HasProp("iBitmap") and oButton.iBitmap != "") ? oButton.iBitmap - 1 : Index - 1)
            
            idCommand := (oButton.HasProp("idCommand") and oButton.idCommand != "") ? oButton.idCommand : 10000 + Index

            fsState := (oButton.HasProp("enabled") and oButton.enabled = true) ? 4 : 0 	; TBSTATE_ENABLED

            Loop Parse, ParseVar := (oButton.HasProp("States") ? oButton.States : ""), A_Tab "" A_Space, A_Tab "" A_Space	; Parse button states
                if (A_LoopField = "")
                    Continue
                Else fsState |= %A_LoopField%

            fsStyle := fTextOnly || fShowText ? SHOWTEXT : 0
            Loop Parse, ParseVar := (oButton.HasProp("Styles") ? oButton.Styles : ""), A_Tab "" A_Space, A_Tab "" A_Space	; Parse button styles
                if (A_LoopField = "")
                    Continue
                Else fsStyle |= %A_LoopField%

            iString := buffer(StrPut(oButton.text))
            StrPut(oButton.text, iString)
            strings.push(iString)	; create the array strings before the loop. put buffers here to avoid them being freed.
        }

        Offset := (A_Index - 1) * TBB_Size
        NumPut("Int", iBitmap, TBBUTTONS, Offset)
        NumPut("Int", idCommand, TBBUTTONS, Offset + 4)
        NumPut("UChar", fsState, TBBUTTONS, Offset + 8)
        NumPut("UChar", fsStyle, TBBUTTONS, Offset + 9)
        NumPut("Ptr", iString.Ptr, TBBUTTONS, Offset + (A_PtrSize == 8 ? 24 : 16))
    }

    If (Padding) {
        ErrorLevel := SendMessage(0x457, 0, Padding, , "ahk_id " hWnd)	; TB_SETPADDING
    }

    If (ExStyle) {	; 0x9 = TBSTYLE_EX_DRAWDDARROWS | TBSTYLE_EX_MIXEDBUTTONS
        ErrorLevel := SendMessage(0x454, 0, ExStyle, , "ahk_id " hWnd)	; TB_SETEXTENDEDSTYLE
    }

    ErrorLevel := SendMessage(0x430, 0, Toolbar.ImageList, , "ahk_id " hWnd)	; TB_SETIMAGELIST
    ErrorLevel := SendMessage(1 ? 0x444 : 0x414, cButtons, TBBUTTONS, , "ahk_id " hWnd)	; TB_ADDBUTTONS

    If (InStr(Options, "VERTICAL")) {
        SIZE := Buffer(8, 0)
        ErrorLevel := SendMessage(0x453, 0, SIZE, , "ahk_id " hWnd)	; TB_GETMAXSIZE
    } Else {
        ErrorLevel := SendMessage(0x421, 0, 0, , "ahk_id " hWnd)	; TB_AUTOSIZE
    }

    ogc.aButtons := Toolbar.aButtons
    ogc.OnEvent("Click", OnToolbar)
    return ogc
}

GuiEscape(*) {
    ExitApp()
}

OnToolbar(hWnd, EventName, Text, Pos, Id, Left, Bottom) {
    If (EventName != "Click") {
        Return
    }

    If (Text == "test1") {
        MsgBox("test")
    } Else If (Text == "test2") {
        MsgBox("test2")
    }
}

; Toolbar.ahk
; Converted by AHK_user, thanks to Helgef for the support


Toolbar_Callback(GuiCtrlObj, lParam) {
    Static n := Map(-2, "Click", -5, "RightClick", -20, "LDown", -713, "Hot", -710, "DropDown")

    Local Callback, Code, ButtonId, Pos, Text, EventName, RECT, Left, Bottom
    hWnd := GuiCtrlObj.hwnd
    CallBack := GuiCtrlObj.CallBack
    Code := NumGet(lParam + 0, A_PtrSize * 2, "Int")

    If (Code != -713) {
        ButtonId := NumGet(lParam + (3 * A_PtrSize), "UPtr")
    } Else {
        ButtonId := NumGet(lParam, A_PtrSize == 8 ? 28 : 16, "Int")	; NMTBHOTITEM idNew
    }

    ErrorLevel := SendMessage(0x419, ButtonId, , , "ahk_id " hWnd)	; TB_COMMANDTOINDEX
    Pos := ErrorLevel + 1

    Text := Buffer(128, 0)
    ErrorLevel := SendMessage("0x44B", ButtonId, Text, , "ahk_id " hWnd)	; TB_GETBUTTONTEXT
    Text := StrGet(Text)

    EventName := (n.Has(Code)) ? n[Code] : Code

    RECT := Buffer(16, 0)
    ErrorLevel := SendMessage(0x433, ButtonId, RECT, , "ahk_id " hWnd)	; TB_GETRECT
    DllCall("MapWindowPoints", "Ptr", hWnd, "Ptr", 0, "Ptr", RECT, "UInt", 2)
    Left := NumGet(RECT, 0, "Int")
    Bottom := NumGet(RECT, 12, "Int")

    if GuiCtrlObj.HasProp("aButtons"){
        for Index, oButton in GuiCtrlObj.aButtons{
            if (text = oButton.text and oButton.HasProp("CallBack")){
                oButton.Callback.Call(hWnd , EventName, Text, Pos, ButtonId, Left, Bottom)
                return
            }
        }
    }

    %Callback%(hWnd, EventName, Text, Pos, ButtonId, Left, Bottom)
}