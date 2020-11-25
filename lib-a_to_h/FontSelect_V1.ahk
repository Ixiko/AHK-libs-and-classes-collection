; Link:   	https://raw.githubusercontent.com/TheArkive/CallTipsForAll/master/LibV1/_Font_Picker_Dialog_v1.ahk
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

; originally posted by maestrith 
; https://autohotkey.com/board/topic/94083-ahk-11-font-and-color-dialogs/

; to initialize fontObject object (not required):
; ============================================
; fontObject := Object("name","Tahoma","size",14,"color",0xFF0000,"strike",1,"underline",1,"italic",1,"bold",1)

; ==================================================================
; fntName		= name of var to store selected font
; fontObject	= name of var to store fontObject
; hwnd			= parent gui hwnd for modal, leave blank for not modal
; effects		= allow selection of underline / strike out / italic
; ==================================================================
; fontObject output:
;
;	fontObject["str"]	= string to use with AutoHotkey to set GUI values - see examples
;	fontObject["hwnd"]	= handle of the font object to use with SendMessage - see examples
; ==================================================================
FontSelect(fontObject:="",hwnd:=0,effects:=1) {
	fontObject := (fontObject="") ? Object() : fontObject
	VarSetCapacity(logfont,60)
	uintVal := DllCall("GetDC","uint",0)
	LogPixels := DllCall("GetDeviceCaps","uint",uintVal,"uint",90)
	Effects := 0x041 + (Effects ? 0x100 : 0)
	
	fntName := fontObject.HasKey("name") ? fontObject["name"] : ""
	fontBold := fontObject.HasKey("bold") ? fontObject["bold"] : 0
	fontBold := fontBold ? 700 : 400
	fontItalic := fontObject.HasKey("italic") ? fontObject["italic"] : 0
	fontUnderline := fontObject.HasKey("underline") ? fontObject["underline"] : 0
	fontStrikeout := fontObject.HasKey("strike") ? fontObject["strike"] : 0
	fontSize := fontObject.HasKey("size") ? fontObject["size"] : 10
	fontSize := fontSize ? Floor(fontSize*LogPixels/72) : 16
	c := fontObject.HasKey("color") ? fontObject["color"] : 0
	
	c1 := Format("0x{:02X}",(c&255)<<16)	; convert RGB colors to BGR for input
	c2 := Format("0x{:02X}",c&65280)
	c3 := Format("0x{:02X}",c>>16)
	fontColor := Format("0x{:06X}",c1|c2|c3)
	
	fontval := Object(16,fontBold,20,fontItalic,21,fontUnderline,22,fontStrikeout,0,fontSize)
	
	for a,b in fontval
		NumPut(b,logfont,a)
	
	cap:=VarSetCapacity(choosefont,A_PtrSize=8?103:60,0)
	NumPut(hwnd,choosefont,A_PtrSize)
	offset1 := (A_PtrSize = 8) ? 24 : 12
	offset2 := (A_PtrSize = 8) ? 36 : 20
	offset3 := (A_PtrSize = 4) ? 6 * A_PtrSize : 5 * A_PtrSize
	
	fontArray := Array([cap,0,"Uint"],[&logfont,offset1,"Uptr"],[effects,offset2,"Uint"],[fontColor,offset3,"Uint"])
	
	for index,value in fontArray
		NumPut(value[1],choosefont,value[2],value[3])
	
	if (A_PtrSize=8) {
		strput(fntName,&logfont+28)
		r := DllCall("comdlg32\ChooseFont","uptr",&CHOOSEFONT,"cdecl")
		fntName := strget(&logfont+28)
	} else {
		strput(fntName,&logfont+28,32,"utf-8")
		r := DllCall("comdlg32\ChooseFontA","uptr",&CHOOSEFONT,"cdecl")
		fntName := strget(&logfont+28,32,"utf-8")
	}
	
	if !r
		return false
	
	fontObj := Object("bold",16,"italic",20,"underline",21,"strike",22)
	for a,b in fontObj
		fontObject[a] := NumGet(logfont,b,"UChar")
	
	fontObject["bold"] := (fontObject["bold"] < 188) ? 0 : 1
	
	c := NumGet(choosefont,A_PtrSize=4?6*A_PtrSize:5*A_PtrSize) ; convert from BGR to RBG for output
	c1 := Format("0x{:02X}",(c&255)<<16)
	c2 := Format("0x{:02X}",c&65280)
	c3 := Format("0x{:02X}",c>>16)
	c := Format("0x{:06X}",c1|c2|c3)
	fontObject["color"] := c
	
	fontObject["size"] := NumGet(choosefont,A_PtrSize=8?32:16,"UInt")//10
	fontHwnd := DllCall("CreateFontIndirect","uptr",&logfont) ; last param "cdecl"
	fontObject["name"] := fntName
	
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
		Loop Parse, fullStr, |
			If (A_LoopField) 
				str .= A_LoopField " "
		fontObject["str"] := "norm " Trim(str)
		
		return fontObject
	}
}