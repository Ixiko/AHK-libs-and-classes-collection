; AHK v2
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; ===============================================================
; Example
; ===============================================================

; global cc, defColor
; cc := 0x00FF00 ; green
; defColor := [0xAA0000,0x00AA00,0x0000AA]

; oGui := Gui("-MinimizeBox -MaximizeBox","Choose Color")
; oGui.OnEvent("close",close_event)
; oGui.OnEvent("escape",close_event)
; oGui.AddButton("w150","Choose Color").OnEvent("click",choose_event)
; oGui.BackColor := cc
; oGui.Show("")
; return


; choose_event(ctl,info) {
    ; Global cc, defColor
    
    ; hwnd := ctl.gui.hwnd ; grab hwnd
    ; cc := "0x" ctl.gui.BackColor ; pre-select color from gui background (optional)
    
    ; cc := ColorSelect(cc,hwnd,&defColor,0) ; specifying start color, parent window, starting custom colors, and basic display
    
    ; If (cc = -1)
        ; return
    
    ; colorList := ""
    ; For k, v in defColor ; if user changes Custom Colors, they will be stored in defColor array
        ; If v
            ; colorList .= "Index: " k " / Color: " Format("0x{:06X}",v) "`r`n"
    
    ; ctl.gui.BackColor := cc ; set gui background color
    
    ; If cc
        ; msgbox "Output color: " cc "`r`n`r`nCustom colors saved:`r`n`r`n" Trim(colorList,"`r`n")
; }

; close_event(guiObj) {
    ; ExitApp
; }

; ===============================================================
; END Example
; ===============================================================

; =============================================================================================
; Parameters
; =============================================================================================
; Color           = Start color (0 = black) - Format = 0xRRGGBB
; hwnd            = Parent window
; custColorObj    = Array() to load/save custom colors, must be &VarRef
; disp            = 1=full / 0=basic ... full displays custom colors panel, basic does not
; =============================================================================================
; All params are optional.  With no hwnd the dialog will show at top left of screen.  Use an
; object serializer (like JSON) to save/load custom colors to/from disk.
; =============================================================================================

ColorSelect(Color := 0, hwnd := 0, &custColorObj := "",disp:=false) {
    Static p := A_PtrSize
    disp := disp ? 0x3 : 0x1 ; init disp / 0x3 = full panel / 0x1 = basic panel
    
    If (custColorObj.Length > 16)
        throw Error("Too many custom colors.  The maximum allowed values is 16.")
    
    Loop (16 - custColorObj.Length)
        custColorObj.Push(0) ; fill out custColorObj to 16 values
    
    CUSTOM := Buffer(16 * 4, 0) ; init custom colors obj
    CHOOSECOLOR := Buffer((p=4)?36:72,0) ; init dialog
    
    If (IsObject(custColorObj)) {
        Loop 16 {
            custColor := RGB_BGR(custColorObj[A_Index])
            NumPut "UInt", custColor, CUSTOM, (A_Index-1) * 4
        }
    }
    
    NumPut "UInt", CHOOSECOLOR.size, CHOOSECOLOR, 0             ; lStructSize
    NumPut "UPtr", hwnd,             CHOOSECOLOR, p             ; hwndOwner
    NumPut "UInt", RGB_BGR(color),   CHOOSECOLOR, 3 * p         ; rgbResult
    NumPut "UPtr", CUSTOM.ptr,       CHOOSECOLOR, 4 * p         ; lpCustColors
    NumPut "UInt", disp,             CHOOSECOLOR, 5 * p         ; Flags
    
    if !DllCall("comdlg32\ChooseColor", "UPtr", CHOOSECOLOR.ptr, "UInt")
        return -1
    
    custColorObj := []
    Loop 16 {
        newCustCol := NumGet(CUSTOM, (A_Index-1) * 4, "UInt")
        custColorObj.InsertAt(A_Index, RGB_BGR(newCustCol))
    }
    
    Color := NumGet(CHOOSECOLOR, 3 * A_PtrSize, "UInt")
    return Format("0x{:06X}",RGB_BGR(color))
    
    RGB_BGR(c) {
        return ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }
}

; typedef struct tagCHOOSECOLORW {  offset      size    (x86/x64)
  ; DWORD        lStructSize;       |0      |   4
  ; HWND         hwndOwner;         |4 / 8  |   8 /16
  ; HWND         hInstance;         |8 /16  |   12/24
  ; COLORREF     rgbResult;         |12/24  |   16/28
  ; COLORREF     *lpCustColors;     |16/28  |   20/32
  ; DWORD        Flags;             |20/32  |   24/36
  ; LPARAM       lCustData;         |24/40  |   28/48 <-- padding for x64
  ; LPCCHOOKPROC lpfnHook;          |28/48  |   32/56
  ; LPCWSTR      lpTemplateName;    |32/56  |   36/64
  ; LPEDITMENU   lpEditInfo;        |36/64  |   40/72
; } CHOOSECOLORW, *LPCHOOSECOLORW;