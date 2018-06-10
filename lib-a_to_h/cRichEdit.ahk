/* 
*****************************************************************************************

cRichEdit.ahk

Version 0.09 beta
April 19, 2008
by corrupt <apps4apps(a)gmail.com> http://apps4apps.filetap.com

*****************************************************************************************
- help documentation coming soon. Until then, please see the comments at the beginning 
  of each _action for a brief description of each command and params. required
- AutoHotkey v1.0.47 or greater required
*****************************************************************************************
*/


/* 
*****************************************************************************************
RICHEDIT features - cRichEdit function
*****************************************************************************************
*/
cRichEdit(_ctrlID, _action, opt1="", opt2="", opt3="", opt4="", opt5="", opt6="")
{
  Static _predef := "000000|Black|008000|Green|C0C0C0|Silver|00FF00|Lime|808080|Gray|808000|Olive|FFFFFF|White|FFFF00|Yellow|800000|Maroon|000080|Navy|FF0000|Red|0000FF|Blue|800080|Purple|008080|Teal|FF00FF|Fuchsia|00FFFF|Aqua|"
  
  If (!_ctrlID)
    Return "ERROR: control not specified"
;  DetectHiddenWindows, On
;   WinWait, ahk_id %_ctrlID%
/* 
*****************************************************************************************
Text - set the text in the control to the contents in the opt1 variable

_action	= Text (or SetText)
opt1	= Text to replace the current text in the control with
*****************************************************************************************
*/
  If (_action = "Text" OR _action = "SETTEXT")
  {
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x461, "Str", "", "Str", opt1) ; EM_SETTEXTEX
    Return
  }
/* 
*****************************************************************************************
FileOpen - open a txt or rtf file

_action	= FileOpen
opt1	= File to open 
*****************************************************************************************
*/
  Else If _action = FileOpen
  {
    If (FileExist(opt1)) {
      FileRead, _tmp1, %opt1%
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x461, "Str", "", "Str", _tmp1) ; EM_SETTEXTEX
    }
    Return
  }
/* 
*****************************************************************************************
ReplaceSel - Replace the currently selected text or insert text at the current location

_action	= ReplaceSel
opt1 	= Text to replace the current selection with
opt2	= allow undo (1 - yes, 0 - no), Default = false
*****************************************************************************************
*/
  Else If _action = ReplaceSel
  { 
  ; EM_REPLACESEL := 0xC2
  If (opt2)
    _tmp2 := true
  Else
    _tmp2 := false
  Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0xC2, "UInt", _tmp2, "UInt", &opt1) 
  }
/* 
*****************************************************************************************
ExGetSel - retrieves the starting and ending character positions of the selection
[contributed by Daniel2][merged/modified by corrupt]

_action	= ExGetSel
*****************************************************************************************
*/
  Else If _action = ExGetSel 
  { 
    VarSetCapacity(_tmp1, 8, 0)
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x434, "UInt", "0", "UInt", &_tmp1)
    VarSetCapacity(_tmp1, -1)  
    Return NumGet(_tmp1, 0, "Int") . "|" . NumGet(_tmp1, 4, "Int") 
    ; Return Value: returns CHARRANGE Structure (cpMin|cpMax) 
  }
/* 
*****************************************************************************************
ExSetSel - set the current selection

_action	= ExSetSel 
opt1 = start position
opt2 = end position
*****************************************************************************************
*/
  Else If _action = ExSetSel 
  { 
    VarSetCapacity(_tmp1, 8, 0)
    NumPut(opt1, _tmp1, 0, "Int")
    NumPut(opt2, _tmp1, 4, "Int")
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x437, "UInt", "0", "UInt", &_tmp1)
  Return
  }
/* 
*****************************************************************************************
GetSelText - get the current text that is selected in the control

_action	= GetSelText
*****************************************************************************************
*/
  Else If _action = GetSelText
  { 
    VarSetCapacity(_tmp1, 8, 0)
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x434, "UInt", "0", "UInt", &_tmp1)
    VarSetCapacity(_tmp1, -1)
    _tmpBufLength := NumGet(_tmp1, 4, "Int") - NumGet(_tmp1, 0, "Int") + 1
    If (_tmpBufLength < 1)
      Return
    VarSetCapacity(_buf1, _tmpBufLength, 0)  
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x43E, "UInt", "0", "UInt", &_buf1)
    VarSetCapacity(_buf1, -1)
  Return _buf1
  }
/* 
*****************************************************************************************
GetTextLength - get the number of characters in the control

_action	= GetTextLength
opt1 = (1 - unicode, 0 - ANSI) Default ANSI
opt2 = Flags (optional - the number of characters will be returned by default. See 
              http://msdn2.microsoft.com/en-us/library/ms651879.aspx for additional details)
*****************************************************************************************
*/
  Else If _action = GetTextLength
  { 
    If (opt1)
      _tmp2 = 1200
    Else 
      _tmp2 = 1252
    If !(opt2)
      opt2 = 0
    VarSetCapacity(_tmp1, 8, 0)
    NumPut(opt2, _tmp1, 0)
    NumPut(_tmp2, _tmp1, 4)
    Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45F, "UInt", &_tmp1, "UInt", "0")
  }
/* 
*****************************************************************************************
GetText - get the text in the control

_action	= GetText
opt1 = (1 - unicode, 0 - ANSI) Default ANSI 
*****************************************************************************************
*/
  Else If _action = GetText
  { 
    VarSetCapacity(_tmp3, 20, 0)
    If (opt1)
      _tmp2 = 1200
    Else 
      _tmp2 = 1252
    VarSetCapacity(_tmp1, 8, 0)
    NumPut(0, _tmp1, 0)
    NumPut(_tmp2, _tmp1, 4)
    _tmpSize := DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45F, "UInt", &_tmp1, "UInt", "0")
    If (_tmpSize) {
      NumPut(_tmpSize, _tmp3, 0, "Int")    
      NumPut(_tmp2, _tmp3, 8, "Int")    
      VarSetCapacity(_tmp4, _tmpSize + 1, 0)
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45E, "UInt", &_tmp3, "UInt", &_tmp4)
      VarSetCapacity(_tmp4, -1)
    }
  Return _tmp4
  }
/* 
*****************************************************************************************
FontStyle - apply the specified attributes to the current selection or for text at
            the current position

_action	= FontStyle
opt1 	= B I U S T (apply the specified attributes)
          (B = Bold, I = Italic, U = Underline, S = Strikethrough, T = Toggle mode)
opt2 	= (specify custom dwMask value | opt1) 
opt3	= (specify custom dwEffects value | opt1)

Example: cGui_RICHEDIT(hwnd, "FontStyle", "BT") 
         ; Toggle Bold for the current selection or for new text at the current location
*****************************************************************************************
*/
  Else If _action = FontStyle
  { 
    If (InStr(opt1, "B"))
      xopt1 := 1  			; CFM_BOLD, CFE_BOLD
    Else 
      xopt1 := 0
    If (InStr(opt1, "I"))
      xopt2 := 2			; CFM_ITALIC, CFE_ITALIC
    Else
      xopt2 := 0
    If (InStr(opt1, "U"))
      xopt3 := 4			; CFM_UNDERLINE, CFE_UNDERLINE
    Else 
      xopt3 := 0
    If (InStr(opt1, "S"))
      xopt4 := 8			; CFM_STRIKEOUT, CFE_STRIKEOUT
    Else
      xopt4 := 0
    If (opt2 = "")
      opt2 := 0
    If (opt3 = "") 
      opt3 := opt2	; custom dwMask, dwEffects values
    _tmp2 := xopt1 | xopt2 | xopt3 | xopt4 | opt2 ; resulting dwMask

    ; ** test point 1/2
    ; MsgBox % "dwMask: " . xopt1 | xopt2 | xopt3 | xopt4 | opt2 

    VarSetCapacity(_tmp1, 60, 0)			 							; CHARFORMAT struct
    NumPut(60, _tmp1)			 							; cbSize
    NumPut(xopt1 | xopt2 | xopt3 | xopt4 | opt2, _tmp1, 4)	; dwMask
    NumPut(xopt1 | xopt2 | xopt3 | xopt4 | opt2, _tmp1, 8)	; dwEffects


    If (InStr(opt1, "T")) {
      ; ** Get current state if specified to toggle
      ; ** SendMessage(hwnd, EM_GETCHARFORMAT, SCF_SELECTION, &CHARFORMATstruct)
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x43A, "UInt", "1", "UInt", &_tmp1) 

      ; ** Check what is applied to the current selection
      VarSetCapacity(_tmp1, -1)
      If (xopt1)
        If ((NumGet(_tmp1, 4) & 1) & (NumGet(_tmp1, 8) & 1))
          xopt1 := 0
      If (xopt2)
        If ((NumGet(_tmp1, 4) & 2) & (NumGet(_tmp1, 8) & 2))
          xopt2 := 0
      If (xopt3)
        If ((NumGet(_tmp1, 4) & 4) & (NumGet(_tmp1, 8) & 4))
          xopt3 := 0
      If (xopt4)
        If ((NumGet(_tmp1, 4) & 8) & (NumGet(_tmp1, 8) & 8))
          xopt4 := 0
      If (opt2)
        If ((NumGet(_tmp1, 4) & opt2) & (NumGet(_tmp1, 8) & opt3))
          opt3 := 0
    }

    ; ** test point 2/2
    ; MsgBox % "B: " . xopt1 "  I: " . xopt2 . "  U: " . xopt3 . "  S: " . xopt4 . "  c: " . xopt2 
    ; MsgBox %  "dwEffects: " . xopt1 | xopt2 | xopt3 | xopt4 | opt3 . " dwMask: " . _tmp2  

    ; ** SendMessage(hwnd, EM_SETCHARFORMAT, SCF_SELECTION, &CHARFORMATstruct)	; reverse the current effect
    VarSetCapacity(_tmp1, 60, Chr(0))											; CHARFORMAT struct
    NumPut(60, _tmp1, 0, "Int")													; cbSize
    NumPut(_tmp2, _tmp1, 4)														; dwMask
    NumPut(xopt1 | xopt2 | xopt3 | xopt4 | opt3, _tmp1, 8)						; dwEffects

  ; ** apply the FontStyle(s)
  Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x444, "UInt", "1", "UInt", &_tmp1)
  }
/* 
*****************************************************************************************
FontName - Change the font for the current selection or for text at the current location.

_action	= FontName
opt1 	= specify the name of the font to apply (max. 32 characters)
*****************************************************************************************
*/
  Else If _action = FontName
  {
    ; CFM_FACE := 0x20000000, CFM_SIZE := 0x80000000, LF_FACESIZE := 0x20
    ; EM_GETCHARFORMAT 0x43A, EM_SETCHARFORMAT := 0x444

  If (opt1 != "" AND (StrLen(opt1) < 33)) { 
    VarSetCapacity(_tmp1, 60, Chr(0))											; CHARFORMAT struct
    VarSetCapacity(_tmp2, 32 + 1, Chr(0))										; szFaceName
    _tmp2 := opt1
    NumPut(60, _tmp1, 0, "Int")													; cbSize
    NumPut(0x20000000, _tmp1, 4)												; dwMask
    NumPut(0x20000000, _tmp1, 8)												; dwEffects
    DllCall("lstrcpy", "UInt", &_tmp1 + 26, "Str", opt1)						; szFaceName
    Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x444, "UInt", "1", "UInt", &_tmp1)
  }
  Return 
  }
/* 
*****************************************************************************************
FontColor - Change the font colour for the current selection or for text at the current 
            location. 

_action	= FontColor
opt1 	= specify an RRGGBB value or the text for one of the following colours:
          Black, Green, Silver, Lime, Gray, Olive, White, Yellow, Maroon, Navy, Red, Blue, 
          Purple, Teal, Fuchsia, Aqua
*****************************************************************************************
*/
  Else If _action = FontColor
  {
    _cnt1 := Instr(_predef, opt1 . "|")
    If (_cnt1)
      opt1 := SubStr(_predef, (_cnt1 - 7), 6)
    If (SubStr(opt1, 1, 2) = "0x")
      StringTrimLeft, opt1, opt1, 2
    opt1 := "0x" . SubStr(opt1, 5, 2) . SubStr(opt1, 3, 2) . SubStr(opt1, 1, 2) 

    VarSetCapacity(_tmp1, 60, Chr(0))											; CHARFORMAT struct
    NumPut(60, _tmp1, 0, "Int")													; cbSize
    NumPut(0x40000000, _tmp1, 4)												; dwMask
    NumPut(opt1, _tmp1, 20)														; crTextColor

  ; ** apply the colour
  Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x444, "UInt", "1", "UInt", &_tmp1)
  }
/* 
*****************************************************************************************
SetFontSize - set the font size of the current selection or position

_action	= SetFontSize
opt1 	= size to set ( <160 assumes point size, otherwise specifies character height, 
		  in twips (1/1440 of an inch or 1/20 of a printer's point)
*****************************************************************************************
*/
  Else If _action = SetFontSize
  {
    ; CFM_SIZE := 0x80000000, EM_SETCHARFORMAT := 0x444
    If (opt1 < 160)
      opt1 := opt1 * 20
    VarSetCapacity(_tmp1, 60, Chr(0))											; CHARFORMAT struct
    NumPut(60, _tmp1, 0, "Int")													; cbSize
    NumPut(0x80000000, _tmp1, 4)												; dwMask
    NumPut(0x80000000, _tmp1, 8)												; dwEffects
    NumPut(opt1, _tmp1, 12, "Int")												; yHeight
  Return DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x444, "UInt", "1", "UInt", &_tmp1)
  }
/* 
*****************************************************************************************
GetFontSize - get the font size of the current selection or position

_action	= GetFontSize 

Return value = character height, in twips (1/1440 of an inch or 1/20 of a printer's point)
*****************************************************************************************
*/
  Else If _action = GetFontSize
  {
    ; CFM_SIZE := 0x80000000, EM_SETCHARFORMAT := 0x43A
    VarSetCapacity(_tmp1, 60, Chr(0))											; CHARFORMAT struct
    NumPut(60, _tmp1, 0, "Int")													; cbSize
    NumPut(0x80000000, _tmp1, 4)												; dwMask
    NumPut(0x80000000, _tmp1, 8)												; dwEffects
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x43A, "UInt", "1", "UInt", &_tmp1)
    VarSetCapacity(_tmp1, -1)
  Return NumGet(_tmp1, 12, "Int")												; yHeight
  }
/* 
*****************************************************************************************
BackColor - change the background colour of the RichEdit control

_action	= BackColor
opt1 	= specify an RRGGBB value or the text for one of the following colours:
          Black, Green, Silver, Lime, Gray, Olive, White, Yellow, Maroon, Navy, Red, Blue, 
          Purple, Teal, Fuchsia, Aqua
*****************************************************************************************
*/
  Else If _action = BackColor
  {
    _cnt1 := Instr(_predef, opt1 . "|")
    If (_cnt1)
      opt1 := SubStr(_predef, (_cnt1 - 7), 6)
    If (SubStr(opt1, 1, 2) = "0x")
      StringTrimLeft, opt1, opt1, 2
    opt1 := "0x" . SubStr(opt1, 5, 2) . SubStr(opt1, 3, 2) . SubStr(opt1, 1, 2) 
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x443, "UInt", "0", "UInt", opt1)
  Return
  }
/* 
*****************************************************************************************
SETSCROLLPOS - scroll to a specific position in the control

_action	= SETSCROLLPOS
opt1 = x position
opt2 = y position 
*****************************************************************************************
*/
  Else If _action = SETSCROLLPOS
  { 
    VarSetCapacity(_tmp1, 8, 0)
    NumPut(opt1, _tmp1, 0, "Int")
    NumPut(opt2, _tmp1, 4, "Int")
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x4DE, "UInt", "0", "UInt", &_tmp1)
  Return
  }
/* 
*****************************************************************************************
GETSCROLLPOS - get the current scroll position in the control

_action	= SETSCROLLPOS
*****************************************************************************************
*/
  Else If _action = GETSCROLLPOS
  { 
    VarSetCapacity(_tmp1, 8, 0)
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x4DD, "UInt", "0", "UInt", &_tmp1)
    VarSetCapacity(_tmp1, -1)
    Return NumGet(_tmp1, 0, "Int") . "|" . NumGet(_tmp1, 4, "Int") 
    ; Return Value: returns POINT Structure (x|y) 
  }
/* 
*****************************************************************************************
Align - Paragraph justification (Left, Center, Right)

_action	= Align
opt1	= Left, Center, or Right otherwise the current value will be returned instead 
*****************************************************************************************
*/
  Else If _action = Align
  { 
  If opt1 = left
    opt1 := 0x1
  Else If opt1 = right
    opt1 := 0x2
  Else If opt1 = center
  opt1 := 0x3

  ; PFA_CENTER  :=  0x3,  PFA_LEFT  :=  0x1, PFA_RIGHT  :=  0x2, PFM_ALIGNMENT  :=  0x8
  ; EM_SETPARAFORMAT := 0x447 ; EM_GETPARAFORMAT := 0x43D

    VarSetCapacity(_tmp1, 156, Chr(0))											; PARAFORMAT struct
    NumPut(156, _tmp1, 0, "Int")												; cbSize
    NumPut(0x8, _tmp1, 4)														; dwMask
    NumPut(opt1, _tmp1, 24, "UShort")											; wAlignment
    DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x447, "UInt", "0", "UInt", &_tmp1)
    VarSetCapacity(_tmp1, -1)
  Return
  }
/* 
*****************************************************************************************
GetRTF - Get the RTF code for the current selection or current contents of the RichEdit
control

_action	= GetRTF
opt1	:= True (optional) Retrieve the code for the current selection instead of the code
           for the entire control (the entire control is the default if not specified)
opt2	:= formatting flags (optional) 
           - will default to SF_TEXT|SF_RTF|SF_RTFNOOBJS|SFF_PLAINRTF if not specified  
*****************************************************************************************
*/
  Else If _action = GetRTF
  {  
  ; editstream struct - DWORD_PTR dwCookie;DWORD dwError;EDITSTREAMCALLBACK pfnCallback;
  ; SF_TEXT = 0x1; SF_RTF = 0x2; SF_RTFNOOBJS = 0x3; SFF_PLAINRTF = 0x4000; SFF_SELECTION = 0x8000
  ; SF_UNICODE = 0x10
  ; EM_STREAMOUT = 0x44A; EM_STREAMIN = 0x449
  ; wparam = flags;  lparam = editstream struct
  If (opt1)
    opt1 := 0x8000
  Else 
    opt1 = 0
  If (opt2)
    opt1 := opt1|opt2
  Else
    opt1 := opt1|0x4006
  GetRTFAddress := RegisterCallback("cRichEdit_RTFout")
  VarSetCapacity(editstream, 12, 0)
  NumPut(_ctrlID, editstream)
  NumPut(GetRTFAddress, editstream, 8)
  RetSize := DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x44A, "UInt", opt1, "UInt", &editstream)
  DllCall("GlobalFree", "UInt", GetRTFAddress)
  Return cRichEdit_RTFout("GetResult", 0, 0, 0)
  }
/* 
*****************************************************************************************
GetLineNum

_action	= GetLineNum
opt1 = character index to get the line number of or...
       or... specify C to get the line number of the current position (or start of selection)
       or... omit this option (or specify "") to get the number of lines in the control 
       instead (ANSI). 
*****************************************************************************************
*/
  Else If _action = GetLineNum
  { 
    If (opt1="") {
      VarSetCapacity(_tmp1, 8, 0)
      NumPut(0, _tmp1, 0)
      NumPut(1252, _tmp1, 4)
      opt1 := DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45F, "UInt", &_tmp1, "UInt", "0")
    }
    Else If (opt1 = "c") {
      VarSetCapacity(_tmp1, 8, 0)
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x434, "UInt", "0", "UInt", &_tmp1)
      VarSetCapacity(_tmp1, -1)  
      opt1 := NumGet(_tmp1, 0, "Int")
    }
  Return (DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x436, "UInt", 0, "UInt", opt1) + 1) ; EM_EXLINEFROMCHAR
  }
/* 
*****************************************************************************************
AutoURLDetect - automatic detection of URLs 

_action	= AutoURLDetect
opt1	= (1 = on, 0 = off) 
*****************************************************************************************
*/
  Else If _action = AutoURLDetect
  {
    If (opt1) {
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45B, "UInt", 1, "UInt", 0) ; EM_AUTOURLDETECT
    }
    Else
      DllCall("user32.dll\SendMessage", "UInt", _ctrlID, "UInt", 0x45B, "UInt", 0, "UInt", 0) ; EM_AUTOURLDETECT
    Return
  }
/* 
*****************************************************************************************


_action	= WordWrap
opt1 = True - on, False = Off
*****************************************************************************************
*/
  Else If _action = WordWrap
  { 
  DllCall("SendMessage", "UInt", _ctrlID, "UInt", 0x448, "UInt", "0", "Int", !(opt1)) ; EM_SETTARGETDEVICE

  Return
  }
/*
*****************************************************************************************
Add your own RICHEDIT features to the function below

Please submit additional features if you think that others may find
them useful so that I can update the current version posted 

Much more to come soon...
*****************************************************************************************
*/
  Else If _action = YourNewFeature
  {
    ; Do something here
    Return
  }
/* 
*****************************************************************************************


_action	= 
*****************************************************************************************
*/
  Else If _action = 
  { 


  Return
  }
/* 
*****************************************************************************************


_action	= 
*****************************************************************************************
*/
  Else If _action = 
  { 


  Return
  }
/* 
*****************************************************************************************
Destroy - destroy the RICHEDIT control

_action = Destroy
*****************************************************************************************
*/
  Else If _action = Destroy
  {
    DllCall("DestroyWindow", "UInt", _crtlID)
    Return
  }
; ***************************************************************************************
Return
}

; ***************************************************************************************
; Callback function for receiving RTF code
; ***************************************************************************************
cRichEdit_RTFout(dwCookie, pbBuff, cb, pcb)
{
Static TextOut := ""
  If (cb > 0) {
    VarSetCapacity(TText, cb + 1, Chr(0))
    DllCall("lstrcpy", "Str", TText, "UInt", pbBuff)
    TextOut .= TText
    Return 0
  } 
  If (dwCookie = "GetResult"){
    retout = %TextOut%
    VarSetCapacity(TextOut, 0)
    Return retout
  }
Return 1
}
