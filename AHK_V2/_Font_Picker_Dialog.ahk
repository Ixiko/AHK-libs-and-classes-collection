; AHK v2
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; ======================================================================
; Example
; ======================================================================

; Global fontObj := {}

; oGui := Gui("","Change Font Example")
; oGui.OnEvent("close",gui_exit)
; ctl := oGui.AddEdit("w500 h200 vMyEdit1","Sample Text")
; ctl.SetFont("bold underline italic strike c0xFF0000")
; oGui.AddEdit("w500 h200 vMyEdit2","Sample Text")
; oGui.AddButton("vBtn Default","Change Font").OnEvent("click",button_click)
; oGui["Btn"].Focus()
; oGui.Show()

; button_click(ctl,info) {
    ; Global fontObj
    
    ; If (!fontObj.HasProp("name")) ; init font obj and pre-populate settings
        ; fontObj := {name:"Verdana", size:14, color:0xFF0000, strike:1, underline:1, italic:1, bold:1} ; init font obj (optional)
    
    ; fontObj := FontSelect(fontObj,ctl.gui.hwnd) ; shows the user the font selection dialog
    
    ; If (!fontObj)
        ; return ; to get info from fontObj use ... bold := fontObj.bold, fontObj.name, etc.
    
    ; ctl.gui["MyEdit1"].SetFont(fontObj.str,fontObj.name) ; use fontObj.str for the AHK compatible string to set all selected styles
    ; ctl.gui["MyEdit2"].SetFont(fontObj.str,fontObj.name) ; then, use fontObj.name to get the font name
; }

; gui_exit(oGui) {
    ; ExitApp
; }

; ======================================================================
; END Example
; ======================================================================

; ==================================================================
; Parameters
; ==================================================================
; fObj           = Initialize the dialog with specified values.
; hwnd           = Parent gui hwnd for modal, leave blank for not modal
; effects        = Allow selection of underline / strike out / italic
; ==================================================================
; fontObj output:
;
;    fontObj.str        = string to use with AutoHotkey to set GUI values - see examples
;    fontObj.size       = size of font
;    fontObj.name       = font name
;    fontObj.bold       = true/false
;    fontObj.italic     = true/false
;    fontObj.strike     = true/false
;    fontObj.underline  = true/false
;    fontObj.color      = 0xRRGGBB
; ==================================================================
FontSelect(fObj:="", hwnd:=0, Effects:=true) {
    Static _temp := {name:"", size:10, color:0, strike:0, underline:0, italic:0, bold:0}
    Static p := A_PtrSize, u := StrLen(Chr(0xFFFF)) ; u = IsUnicode
    
    fObj := (fObj="") ? _temp : fObj
    
    If (StrLen(fObj.name) > 31)
        throw Error("Font name length exceeds 31 characters.")
        
    LOGFONT := Buffer(!u ? 60 : 96,0) ; LOGFONT size based on IsUnicode, not A_PtrSize
    hDC := DllCall("GetDC","UPtr",0)
    LogPixels := DllCall("GetDeviceCaps","UPtr",hDC,"Int",90)
    Effects := 0x041 + (Effects ? 0x100 : 0)
    DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC) ; release DC
    
    fObj.bold := fObj.bold ? 700 : 400
    fObj.size := Floor(fObj.size*LogPixels/72)
    
    NumPut "uint", fObj.size, LOGFONT
    NumPut "uint", fObj.bold, "char", fObj.italic, "char", fObj.underline, "char", fObj.strike, LOGFONT, 16
    StrPut(fObj.name,LOGFONT.ptr+28)
    
    CHOOSEFONT := Buffer((p=8)?104:60,0)
    NumPut "UInt", CHOOSEFONT.size,     CHOOSEFONT
    NumPut "UPtr", hwnd,                CHOOSEFONT, p
    NumPut "UPtr", LOGFONT.ptr,         CHOOSEFONT, (p*3)
    NumPut "UInt", effects,             CHOOSEFONT, (p*4)+4
    NumPut "UInt", RGB_BGR(fObj.color), CHOOSEFONT, (p*4)+8
    
    r := DllCall("comdlg32\ChooseFont","UPtr",CHOOSEFONT.ptr) ; Font Select Dialog opens
    
    if !r
        return false
    
    fObj.Name := StrGet(LOGFONT.ptr+28)
    fObj.bold := ((b := NumGet(LOGFONT,16,"UInt")) <= 400) ? 0 : 1
    fObj.italic := !!NumGet(LOGFONT,20,"Char")
    fObj.underline := NumGet(LOGFONT,21,"Char")
    fObj.strike := NumGet(LOGFONT,22,"Char")
    fObj.size := NumGet(CHOOSEFONT,p*4,"UInt") / 10
    
    c := NumGet(CHOOSEFONT,(p=4)?6*p:5*p,"UInt") ; convert from BGR to RBG for output
    fObj.color := Format("0x{:06X}",RGB_BGR(c))
    
    str := ""
    str .= fObj.bold      ? "bold" : ""
    str .= fObj.italic    ? " italic" : ""
    str .= fObj.strike    ? " strike" : ""
    str .= fObj.color     ? " c" fObj.color : ""
    str .= fObj.size      ? " s" fObj.size : ""
    str .= fObj.underline ? " underline" : ""
    
    fObj.str := "norm " Trim(str)
    return fObj
    
    RGB_BGR(c) {
        return ((c & 0xFF) << 16 | c & 0xFF00 | c >> 16)
    }
}

; typedef struct tagLOGFONTW {
  ; LONG  lfHeight;                 |4        / 0
  ; LONG  lfWidth;                  |4        / 4
  ; LONG  lfEscapement;             |4        / 8
  ; LONG  lfOrientation;            |4        / 12
  ; LONG  lfWeight;                 |4        / 16
  ; BYTE  lfItalic;                 |1        / 20
  ; BYTE  lfUnderline;              |1        / 21
  ; BYTE  lfStrikeOut;              |1        / 22
  ; BYTE  lfCharSet;                |1        / 23
  ; BYTE  lfOutPrecision;           |1        / 24
  ; BYTE  lfClipPrecision;          |1        / 25
  ; BYTE  lfQuality;                |1        / 26
  ; BYTE  lfPitchAndFamily;         |1        / 27
  ; WCHAR lfFaceName[LF_FACESIZE];  |[32|64]  / 28  ---> size [60|92] -- 32 TCHARs [UTF-8|UTF-16]
; } LOGFONTW, *PLOGFONTW, *NPLOGFONTW, *LPLOGFONTW;


;                                           size        offset [32|64]
; typedef struct tagCHOOSEFONTW {
  ; DWORD        lStructSize;               |4        / 0
  ; HWND         hwndOwner;                 |[4|8]    / [ 4| 8]  A_PtrSize * 1
  ; HDC          hDC;                       |[4|8]    / [ 8|16]  A_PtrSize * 2
  ; LPLOGFONTW   lpLogFont;                 |[4|8]    / [12|24]  A_PtrSize * 3
  ; INT          iPointSize;                |4        / [16|32]  A_PtrSize * 4
  ; DWORD        Flags;                     |4        / [20|36]
  ; COLORREF     rgbColors;                 |4        / [24|40] --- this lines up with code
  ; LPARAM       lCustData;                 |[4|8]    / [28|48]
  ; LPCFHOOKPROC lpfnHook;                  |[4|8]    / [32|56]
  ; LPCWSTR      lpTemplateName;            |[4|8]    / [36|64]
  ; HINSTANCE    hInstance;                 |[4|8]    / [40|72]
  ; LPWSTR       lpszStyle;                 |[4|8]    / [44|80]
  ; WORD         nFontType;                 |2        / [48|88]
  ; WORD         ___MISSING_ALIGNMENT__;    |2        / [50|90]
  ; INT          nSizeMin;                  |4        / [52|92]
  ; INT          nSizeMax;                  |4        / [56|96] -- len: 60 / 104
; } CHOOSEFONTW;

