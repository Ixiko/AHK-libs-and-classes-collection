; Link:   	https://raw.githubusercontent.com/TheArkive/CallTipsForAll/master/LibV2/_Font_Picker_Dialog_v2.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; AHK v2
; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; ======================================================================
; Example
; ======================================================================

; Global fontObj

; oGui := Gui.New("","Change Font Example")
; oGui.OnEvent("close","gui_exit")
; ctl := oGui.AddEdit("w500 h200 vMyEdit1","Sample Text")
; ctl.SetFont("bold underline italic strike c0xFF0000")
; oGui.AddEdit("w500 h200 vMyEdit2","Sample Text")
; oGui.AddButton("Default","Change Font").OnEvent("click","button_click")
; oGui.Show()

; button_click(ctl,info) {
	; If (!isSet(fontObj))
		; fontObj := ""
	; fontObj := Map("name","Terminal","size",14,"color",0xFF0000,"strike",1,"underline",1,"italic",1,"bold",1) ; init font obj (optional)
	
	; fontObj := FontSelect(fontObj,ctl.gui.hwnd) ; shows the user the font selection dialog
	
	; If (!fontObj)
		; return ; to get info from fontObj use ... bold := fontObj["bold"], fontObj["name"], etc.
	
	; ctl.gui["MyEdit1"].SetFont(fontObj["str"],fontObj["name"]) ; apply font+style in one line, or...
	; ctl.gui["MyEdit2"].SetFont(fontObj["str"],fontObj["name"])
; }

; gui_exit(oGui) {
	; ExitApp
; }

; ======================================================================
; END Example
; ======================================================================

; to initialize fontObj (not required):
; ============================================
; fontObj := Map("name","Tahoma","size",14,"color",0xFF0000,"strike",1,"underline",1,"italic",1,"bold",1)

; ==================================================================
; fntName		= name of var to store selected font
; fontObj	    = name of var to store fontObj object
; hwnd			= parent gui hwnd for modal, leave blank for not modal
; effects		= allow selection of underline / strike out / italic
; ==================================================================
; fontObj output:
;
;	fontObj["str"]	= string to use with AutoHotkey to set GUI values - see examples
;	fontObj["hwnd"]	= handle of the font object to use with SendMessage - see examples
; ==================================================================
FontSelect(fontObject:="",hwnd:=0,Effects:=1) {
	fontObject := (fontObject="") ? Map() : fontObject
	logfont := BufferAlloc((A_PtrSize = 4) ? 60 : 92,0)
	uintVal := DllCall("GetDC","uint",0)
	LogPixels := DllCall("GetDeviceCaps","uint",uintVal,"uint",90)
	Effects := 0x041 + (Effects ? 0x100 : 0)
	
	fntName := fontObject.Has("name") ? fontObject["name"] : ""
	fontBold := fontObject.Has("bold") ? fontObject["bold"] : 0
	fontBold := fontBold ? 700 : 400
	fontItalic := fontObject.Has("italic") ? fontObject["italic"] : 0
	fontUnderline := fontObject.Has("underline") ? fontObject["underline"] : 0
	fontStrikeout := fontObject.Has("strike") ? fontObject["strike"] : 0
	fontSize := fontObject.Has("size") ? fontObject["size"] : 10
	fontSize := fontSize ? Floor(fontSize*LogPixels/72) : 16
	c := fontObject.Has("color") ? fontObject["color"] : 0
	
	c1 := Format("0x{:02X}",(c&255)<<16)	; convert RGB colors to BGR for input
	c2 := Format("0x{:02X}",c&65280)
	c3 := Format("0x{:02X}",c>>16)
	fontColor := Format("0x{:06X}",c1|c2|c3)
	
	NumPut "uint", fontSize, logfont
	NumPut "uint", fontBold, "char", fontItalic, "char", fontUnderline, "char", fontStrikeout, logfont, 16
	
	choosefont := BufferAlloc(A_PtrSize=8?104:60,0), cap := choosefont.size
	NumPut "UPtr", hwnd, choosefont, A_PtrSize
	offset1 := (A_PtrSize = 8) ? 24 : 12
	offset2 := (A_PtrSize = 8) ? 36 : 20
	offset3 := (A_PtrSize = 4) ? 6 * A_PtrSize : 5 * A_PtrSize
	
	fontArray := Array([cap,0,"Uint"],[logfont.ptr,offset1,"UPtr"],[effects,offset2,"Uint"],[fontColor,offset3,"Uint"])
	
	for index,value in fontArray
		NumPut value[3], value[1], choosefont, value[2]
	
	if (A_PtrSize=8) {
		strput(fntName,logfont.ptr+28,"UTF-16")
		r := DllCall("comdlg32\ChooseFont","UPtr",CHOOSEFONT.ptr) ; cdecl 
		fntName := strget(logfont.ptr+28,"UTF-16")
	} else {
		strput(fntName,logfont.ptr+28,32,"UTF-8")
		r := DllCall("comdlg32\ChooseFontA","UPtr",CHOOSEFONT.ptr) ; cdecl
		fntName := strget(logfont.ptr+28,32,"UTF-8")
	}
	
	if !r
		return false
	
	fontObj := Map("bold",16,"italic",20,"underline",21,"strike",22)
	for a,b in fontObj
		fontObject[a] := NumGet(logfont,b,"UChar")
	
	fontObject["bold"] := (fontObject["bold"] < 188) ? 0 : 1
	
	c := NumGet(choosefont,(A_PtrSize=4)?6*A_PtrSize:5*A_PtrSize,"UInt") ; convert from BGR to RBG for output
	c1 := Format("0x{:02X}",(c&255)<<16), c2 := Format("0x{:02X}",c&65280), c3 := Format("0x{:02X}",c>>16)
	c := Format("0x{:06X}",c1|c2|c3)
	fontObject["color"] := c
	
	fontSize := NumGet(choosefont,A_PtrSize=8?32:16,"UInt") / 10 ; 32:16
	fontObject["size"] := fontSize
	fontHwnd := DllCall("CreateFontIndirect","uptr",logfont.ptr) ; last param "cdecl"
	fontObject["name"] := fntName
	
	logfont := "", choosefont := ""
	
	If (!fontHwnd) {
		fontObject := ""
		return 0
	} Else {
		fontObject["hwnd"] := fontHwnd
		b := fontObject["bold"] ? "bold" : ""
		i := fontObject["italic"] ? "italic" : ""
		s := fontObject["strike"] ? "strike" : ""
		c := fontObject["color"] ? "c" fontObject["color"] : ""
		z := fontObject["size"] ? "s" fontObject["size"] : ""
		u := fontObject["underline"] ? "underline" : ""
		fullStr := b "|" i "|" s "|" c "|" z "|" u
		str := ""
		Loop Parse fullStr, "|"
			If (A_LoopField)
				str .= A_LoopField " "
		fontObject["str"] := "norm " Trim(str)
		
		return fontObject
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


; typedef struct tagCHOOSEFONTW {
  ; DWORD        lStructSize;               |4        / 0
  ; HWND         hwndOwner;                 |[4|8]    / [ 4| 8]  A_PtrSize * 1
  ; HDC          hDC;                       |[4|8]    / [ 8|16]  A_PtrSize * 2
  ; LPLOGFONTW   lpLogFont;                 |[4|8]    / [12|24]  A_PtrSize * 3
  ; INT          iPointSize;                |4        / [16|32]  A_PtrSize * 4
  ; DWORD        Flags;                     |4        / [20|36]
  ; COLORREF     rgbColors;                 |4        / [24|40]
  ; LPARAM       lCustData;                 |[4|8]    / [28|48]
  ; LPCFHOOKPROC lpfnHook;                  |[4|8]    / [32|56]
  ; LPCWSTR      lpTemplateName;            |[4|8]    / [36|64]
  ; HINSTANCE    hInstance;                 |[4|8]    / [40|72]
  ; LPWSTR       lpszStyle;                 |[4|8]    / [44|80]
  ; WORD         nFontType;                 |2        / [48|88]
  ; WORD         ___MISSING_ALIGNMENT__;    |2        / [50|92]
  ; INT          nSizeMin;                  |4        / [52|96]
  ; INT          nSizeMax;                  |4        / [56|100] -- len: 60 / 104
; } CHOOSEFONTW;
