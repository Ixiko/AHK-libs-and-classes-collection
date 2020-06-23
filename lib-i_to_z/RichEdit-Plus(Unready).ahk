
RichEdit_ATOU( ByRef Unicode, Ansi ) { ; Ansi to Unicode
 VarSetCapacity( Unicode, (Len:=StrLen(Ansi))*2+1, 0 )
 Return DllCall( "MultiByteToWideChar", Int,0,Int,0,Str,Ansi,UInt,Len, Str,Unicode, UInt,Len )
}

RichEdit_UTOA( pUnicode )  {           ; Unicode to Ansi
  VarSetCapacity( Ansi,(nSz:=DllCall( "lstrlenW", UInt,pUnicode )+1) )
  DllCall( "WideCharToMultiByte", Int,0, Int,0, UInt,pUnicode, UInt,nSz+1
                                , Str,Ansi, UInt,nSz+1, Int,0, Int,0 )
Return Ansi
}

EM_GETEVENTMASK(hCtrl)  {
  static EM_GETEVENTMASK=59,WM_USER=0x400
  SendMessage, WM_USER | EM_GETEVENTMASK, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; This message returns the event mask for the rich edit control.
}

;========================================== PRIVATE ===============================================================


;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------
;--------------------------------------------------------------------------------

/*
--Messages--
; http://msdn.microsoft.com/en-us/library/cc656557(VS.85).aspx
EM_DISPLAYBAND
EM_EXGETSEL
EM_EXLIMITTEXT
EM_EXLINEFROMCHAR
EM_EXSETSEL -
EM_FINDTEXTEX
EM_FINDTEXTEXW
EM_FINDTEXTW
EM_FINDWORDBREAK
EM_FORMATRANGE
				   ;----------------- RE_Get()
EM_GETBIDIOPTIONS
EM_GETCHARFORMAT
EM_GETCTFMODEBIAS     *** ??? constant?
EM_GETCTFOPENSTATUS   *** ??? constant?
EM_GETEDITSTYLE
EM_GETEVENTMASK
EM_GETHYPHENATEINFO   *** ??? constant?
EM_GETIMECOLOR
EM_GETIMECOMPMODE
EM_GETIMECOMPTEXT   *** ??? constant?
EM_GETIMEMODEBIAS
EM_GETIMEOPTIONS
EM_GETIMEPROPERTY   *** ??? constant?
EM_GETLANGOPTIONS
EM_GETOLEINTERFACE
EM_GETPAGEROTATE   *** ??? constant?
EM_GETPARAFORMAT
EM_GETPUNCTUATION
EM_GETREDONAME
EM_GETSCROLLPOS
EM_GETSELTEXT
EM_GETTEXTEX
EM_GETTEXTLENGTHEX
EM_GETTEXTMODE
EM_GETTEXTRANGE
EM_GETTYPOGRAPHYOPTIONS
EM_GETUNDONAME
EM_GETWORDBREAKPROCEX
EM_GETWORDWRAPMODE
		      ;----------------- end RE_Get()

EM_HIDESELECTION
EM_ISIME
EM_PASTESPECIAL
EM_RECONVERSION
EM_REQUESTRESIZE

				;----------------- RE_Set()
EM_SETBIDIOPTIONS
EM_SETBKGNDCOLOR
EM_SETCHARFORMAT
EM_SETCTFMODEBIAS     *** ??? constant?
EM_SETCTFOPENSTATUS   *** ??? constant?
EM_SETEDITSTYLE
EM_SETHYPHENATEINFO   *** ??? constant?
EM_SETIMECOLOR
EM_SETIMEMODEBIAS
EM_SETIMEOPTIONS
EM_SETLANGOPTIONS
EM_SETOLECALLBACK
EM_SETPAGEROTATE   *** ??? constant?
EM_SETPALETTE
EM_SETPARAFORMAT
EM_SETPUNCTUATION
EM_SETSCROLLPOS
EM_SETTARGETDEVICE
EM_SETTEXTEX
EM_SETTEXTMODE
EM_SETTYPOGRAPHYOPTIONS
EM_SETUNDOLIMIT
EM_SETWORDBREAKPROCEX
EM_SETWORDWRAPMODE
EM_SHOWSCROLLBAR
EM_STOPGROUPTYPING    ;----------------- end RE_Set()
EM_STREAMIN
EM_STREAMOUT


http://msdn.microsoft.com/en-us/library/cc656458(VS.85).aspx

EM_FMTLINES
EM_GETCUEBANNER
EM_GETFIRSTVISIBLELINE
EM_GETHANDLE
EM_GETHILITE
EM_GETIMESTATUS
EM_GETLIMITTEXT
EM_GETMARGINS
EM_GETPASSWORDCHAR
EM_GETRECT
EM_GETTHUMB
EM_GETWORDBREAKPROC
EM_HIDEBALLOONTIP
EM_LIMITTEXT
EM_SCROLL
EM_SETCUEBANNER
EM_SETHANDLE
EM_SETHILITE
EM_SETIMESTATUS
EM_SETLIMITTEXT
EM_SETMARGINS
EM_SETMODIFY
EM_SETPASSWORDCHAR
EM_SETREADONLY
EM_SETRECT
EM_SETRECTNP
EM_SETTABSTOPS
EM_SETWORDBREAKPROC
EM_SHOWBALLOONTIP
*/


EM_DISPLAYBAND(hCtrl)  {
  static EM_DISPLAYBAND=51,WM_USER=0x400

  VarSetCapacity(RECT, 16, 0)
  left := 10, top := 10, right := 70, bottom := 100
    NumPut(left, RECT, 0, "Int")
    NumPut(top, RECT, 4, "Int")
    NumPut(right, RECT, 8, "Int")
    NumPut(bottom, RECT, 12, "Int")

  SendMessage, WM_USER | EM_DISPLAYBAND, 0,&RECT,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is TRUE.
}

;Whats the benefit of this functions from non-ex ones? -- majinetor
EM_FINDTEXTEX(hCtrl, lpstrText)  {
  static EM_FINDTEXTEX=79,WM_USER=0x400
  VarSetCapacity(FINDTEXTEX, 20, 0)
;   FINDTEXTEX_chrg := NumGet(FINDTEXTEX, 0, "UInt")
;   FINDTEXTEX_lpstrText := NumGet(FINDTEXTEX, 8, "UInt")
;   FINDTEXTEX_chrgText := NumGet(FINDTEXTEX, 12, "UInt")
  ;--
;   NumPut(FINDTEXTEX_chrg, FINDTEXTEX, 0, "UInt")
  NumPut(lpstrText, FINDTEXTEX, 8, "UInt")
;   NumPut(FINDTEXTEX_chrgText, FINDTEXTEX, 12, "UInt")

  SendMessage, WM_USER | EM_FINDTEXTEX, 1,&FINDTEXTEX,, ahk_id %hCtrl%
  MsgBox, % NumGet(FINDTEXTEX, 12, "UInt") " | " NumGet(FINDTEXTEX, 16, "UInt")
;   MSGBOX, % ERRORLEVEL
}

EM_FINDTEXTEXW(hCtrl)  {
;   static EM_FINDTEXTEXW=124,WM_USER=0x400
;   SendMessage, WM_USER | EM_FINDTEXTEXW, 0,&@??,, ahk_id %hCtrl%
}

EM_FINDTEXTW(hCtrl)  {
;   static EM_FINDTEXTW=123,WM_USER=0x400
;   SendMessage, WM_USER | EM_FINDTEXTW, 0,&@??,, ahk_id %hCtrl%
}

;This message returns the index of the last character that fits in the region, plus 1.
EM_FORMATRANGE(hCtrl, HDC = 0, W = 0, H = 0, X=0, Y=0)  {
	static EM_FORMATRANGE=1081

	VarSetCapacity(FORMATRANGE, 48, 0)

	NumPut(HDC, FORMATRANGE, 0, "UInt") ;FORMATRANGE_hdc
    NumPut(HDC, FORMATRANGE, 4, "UInt") ;FORMATRANGE_hdcTarget (use EM_SETTARGETDEVICE() )

    NumPut(X, FORMATRANGE, 8, "Int") ;FORMATRANGE_rc_left
    NumPut(Y, FORMATRANGE, 12, "Int") ;FORMATRANGE_rc_top
    NumPut(W, FORMATRANGE, 16, "Int") ; FORMATRANGE_rc_right
    NumPut(H, FORMATRANGE, 20, "Int") ; FORMATRANGE_rc_bottom

	NumPut(X, FORMATRANGE, 24, "Int") ; FORMATRANGE_rcPage_left
    NumPut(Y, FORMATRANGE, 28, "Int") ; FORMATRANGE_rcPage_top
    NumPut(W, FORMATRANGE, 32, "Int") ; FORMATRANGE_rcPage_right
    NumPut(H, FORMATRANGE, 36, "Int") ; FORMATRANGE_rcPage_bottom

	NumPut(0, FORMATRANGE, 40, "UInt") ; CHARRANGE-min
    NumPut(-1, FORMATRANGE, 44, "UInt") ; ; CHARRANGE-max
	SendMessage, EM_FORMATRANGE 1,&FORMATRANGE,, ahk_id %hCtrl%
	res := ErrorLevel

  ; It is very important to free cached information after the last time you use this message by
  ; specifying NULL in lParam. In addition, after using this message for one device, you must free
  ; cached information before using it again for a different device.
	SendMessage, EM_FORMATRANGE,,,, ahk_id %hCtrl%
	return res
}

EM_GETBIDIOPTIONS(hCtrl)  {
  static EM_GETBIDIOPTIONS=201,WM_USER=0x400

  VarSetCapacity(BIDIOPTIONS, 8, 0), cbSize := 8

  ; typedef struct _bidioptions {
     NumPut(cbSize, BIDIOPTIONS, 0, "UInt")
  ;   NumPut(BIDIOPTIONS_wMask, BIDIOPTIONS, 4, "UShort")
  ;   NumPut(BIDIOPTIONS_wEffects, BIDIOPTIONS, 6, "UShort")
  ; }

  SendMessage, WM_USER | EM_GETBIDIOPTIONS, 0,&BIDIOPTIONS,, ahk_id %hCtrl%
;   MsgBox, % errorlevel    ; This message does not return a value.

  ; typedef struct _bidioptions {
  ;   BIDIOPTIONS_cbSize := NumGet(BIDIOPTIONS, 0, "UInt")
  ;   BIDIOPTIONS_wMask := NumGet(BIDIOPTIONS, 4, "UShort")
  MsgBox, % wEffects := NumGet(BIDIOPTIONS, 6, "UShort")
  ; }

  static BOE_RTLDIR=0x1,BOE_PLAINTEXT=0x2,BOE_NEUTRALOVERRIDE=0x4,BOE_CONTEXTREADING=0x8,BOE_CONTEXTALIGNMENT=0x10,BOE_LEGACYBIDICLASS=0x00000040
; RTLDIR - Default paragraph direction—implies alignment (obsolete).
; PLAINTEXT - Uses plain text layout (obsolete).
; NEUTRALOVERRIDE - Overrides neutral layout.
; CONTEXTREADING - Context reading order.
; CONTEXTALIGNMENT - Context alignment.
; LEGACYBIDICLASS - Causes the plus and minus characters to be treated as neutral characters with no implied direction. Also causes the slash character to be treated as a common separator.
}

EM_SETBIDIOPTIONS(hCtrl)  {
  static EM_SETBIDIOPTIONS=200,WM_USER=0x400
  static BOM_DEFPARADIR=0x1,BOM_PLAINTEXT=0x2,BOM_NEUTRALOVERRIDE=0x4,BOM_CONTEXTREADING=0x8,BOM_CONTEXTALIGNMENT=0x10,BOM_LEGACYBIDICLASS=0x0040
  static BOE_RTLDIR=0x1,BOE_PLAINTEXT=0x2,BOE_NEUTRALOVERRIDE=0x4,BOE_CONTEXTREADING=0x8,BOE_CONTEXTALIGNMENT=0x10,BOE_LEGACYBIDICLASS=0x00000040

  VarSetCapacity(BIDIOPTIONS, 8, 0), cbSize := 8
  wMask := wEffects := 0
  ;   Loop, Parse, effects,
  ;     If A_LoopField In PLAINTEXT,NEUTRALOVERRIDE,CONTEXTREADING,CONTEXTALIGNMENT
  ;       wMask := wEffects |= BOE_%A_LoopField%

  wMask := wEffects |= BOE_RTLDIR
  ; typedef struct _bidioptions {
     NumPut(cbSize, BIDIOPTIONS, 0, "UInt")
     NumPut(wMask, BIDIOPTIONS, 4, "UShort")
     NumPut(wEffects, BIDIOPTIONS, 6, "UShort")
  ; }1
  SendMessage, WM_USER | EM_SETBIDIOPTIONS, 0,&BIDIOPTIONS,, ahk_id %hCtrl%
;   MsgBox, % errorlevel    ; This message does not return a value.
}

EM_GETCTFMODEBIAS(hCtrl)  {
  static EM_GETCTFMODEBIAS=237,WM_USER=0x400
  SendMessage, WM_USER | EM_GETCHARFORMAT, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; The current Text Services Framework mode bias value.
}

EM_GETCTFOPENSTATUS(hCtrl)  {
  static EM_GETCTFOPENSTATUS=240,WM_USER=0x400
  SendMessage, WM_USER | EM_GETCTFOPENSTATUS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; If the TSF keyboard is open, the return value is TRUE. Otherwise, it is FALSE.
}

EM_GETEDITSTYLE(hCtrl)  {
  static EM_GETEDITSTYLE=205,WM_USER=0x400
  SendMessage, WM_USER | EM_GETEDITSTYLE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; The return value can be one or more of the following values...
}

EM_GETHYPHENATEINFO(hCtrl)  {   ; richedit 4.1 only (msftedit.dll)
  static EM_GETHYPHENATEINFO=230,WM_USER=0x400

  pfnHyphenate := RegisterCallback( "RichEdit_hyphenateProc" )
  VarSetCapacity(HYPHENATEINFO, 12, 0), cbSize := 12

  ; typedef struct tagHyphenateInfo {
  ;   HYPHENATEINFO_cbSize := NumGet(HYPHENATEINFO, 0, "Short")
  ;   HYPHENATEINFO_dxHyphenateZone := NumGet(HYPHENATEINFO, 2, "Short")
  ;   HYPHENATEINFO_pfnHyphenate := NumGet(HYPHENATEINFO, 4, "UInt")
  ; }

  ; typedef struct tagHyphenateInfo {
     NumPut(cbSize, HYPHENATEINFO, 0, "Short")
  ;   NumPut(HYPHENATEINFO_dxHyphenateZone, HYPHENATEINFO, 2, "Short")
     NumPut(pfnHyphenate, HYPHENATEINFO, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_GETHYPHENATEINFO, &HYPHENATEINFO,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; There is no return value.
}

EM_SETHYPHENATEINFO(hCtrl)  {
  static EM_SETHYPHENATEINFO=231,WM_USER=0x400

  pfnHyphenate := RegisterCallback( "RichEdit_hyphenateProc" )
  VarSetCapacity(HYPHENATEINFO, 12, 0), cbSize := 12

  ; typedef struct tagHyphenateInfo {
  ;   HYPHENATEINFO_cbSize := NumGet(HYPHENATEINFO, 0, "Short")
  ;   HYPHENATEINFO_dxHyphenateZone := NumGet(HYPHENATEINFO, 2, "Short")
  ;   HYPHENATEINFO_pfnHyphenate := NumGet(HYPHENATEINFO, 4, "UInt")
  ; }

  ; typedef struct tagHyphenateInfo {
     NumPut(cbSize, HYPHENATEINFO, 0, "Short")
  ;   NumPut(HYPHENATEINFO_dxHyphenateZone, HYPHENATEINFO, 2, "Short")
     NumPut(pfnHyphenate, HYPHENATEINFO, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_SETHYPHENATEINFO, &HYPHENATEINFO,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel    ; There is no return value.

  ;To enable hyphenation, the client must call EM_SETTYPOGRAPHYOPTIONS, specifying TO_ADVANCEDTYPOGRAPHY
}

RichEdit_hyphenateProc( pszWord, langid, ichExceed, phyphresult )  {
  ToolTip, pszWord = %pszWord% `nlangid = %langid% `nichExceed = %ichExceed% `nphyphresult = %phyphresult%
}

EM_GETIMECOMPMODE(hCtrl)  {
  static EM_GETIMECOMPMODE=122,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMECOMPMODE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The return value is one of the following values...

  static ICM_NOTOPEN=0x0,ICM_LEVEL3=0x1,ICM_LEVEL2=0x2,ICM_LEVEL2_5=0x3,ICM_LEVEL2_SUI=0x4
; ICM_NOTOPEN	- Input Method Editor (IME) is not open.
; ICM_LEVEL3 - 	True inline mode.
; ICM_LEVEL2 - 	Level 2.
; ICM_LEVEL2_5 - 	Level 2.5
; ICM_LEVEL2_SUI - Special user interface (UI).
}

EM_GETIMECOMPTEXT(hCtrl)  {
  static EM_GETIMECOMPTEXT=242,WM_USER=0x400

  VarSetCapacity(IMECOMPTEXT, 8, 0)

  ; typedef struct _imecomptext {
  ;   IMECOMPTEXT_cb := NumGet(IMECOMPTEXT, 0, "Int")
  ;   IMECOMPTEXT_flags := NumGet(IMECOMPTEXT, 4, "UInt")
  ; }

  ; typedef struct _imecomptext {
  ;   NumPut(IMECOMPTEXT_cb, IMECOMPTEXT, 0, "Int")
  ;   NumPut(IMECOMPTEXT_flags, IMECOMPTEXT, 4, "UInt")
  ; }
  SendMessage, WM_USER | EM_GETIMECOMPTEXT, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If successful, # of Unicode characters copied to the buffer. Otherwise, zero.
}

EM_GETIMEMODEBIAS(hCtrl)  {
  static EM_GETIMEMODEBIAS=127,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMEMODEBIAS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns the current IME mode bias setting.
}

EM_GETIMEOPTIONS(hCtrl)  {
  static EM_GETIMEOPTIONS=107,WM_USER=0x400
  SendMessage, WM_USER | EM_GETIMEOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message returns one or more of the IME option flag values described in the EM_SETIMEOPTIONS message..
}

EM_GETIMEPROPERTY(hCtrl)  {
  static EM_GETIMEPROPERTY=244,WM_USER=0x400
  static IGP_PROPERTY=0x4,IGP_CONVERSION=0x8,IGP_SENTENCE=0xC,IGP_UI=0x10,IGP_SETCOMPSTR=0x14,IGP_SELECT=0x18,IGP_GETIMEVERSION=-4

  type := IGP_PROPERTY  ;one of the following values..
  ; IGP_PROPERTY - Property information.
  ; IGP_CONVERSION - Conversion capabilities.
  ; IGP_SENTENCE - Sentence mode capabilities.
  ; IGP_UI - User interface capabilities.
  ; IGP_SETCOMPSTR - Composition string capabilities.
  ; IGP_SELECT - Selection inheritance capabilities.
  ; IGP_GETIMEVERSION - Retrieves the system version number for which the specified IME was created.

  SendMessage, WM_USER | EM_GETIMEPROPERTY, type,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Returns the property or capability value, depending on the value of the lParam
}

EM_GETLANGOPTIONS(hCtrl)  {
  static EM_GETLANGOPTIONS=121,WM_USER=0x400
  SendMessage, WM_USER | EM_GETLANGOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; one or more of the following values, which indicate the current language option settings.

  static IMF_AUTOFONT=0x2,IMF_AUTOFONTSIZEADJUST=0x10,IMF_AUTOKEYBOARD=0x1,IMF_DUALFONT=0x80,IMF_IMEALWAYSSENDNOTIFY=0x8,IMF_IMECANCELCOMPLETE=0x4,IMF_UIFONTS=0x20
}

EM_GETPAGEROTATE(hCtrl)  {

; EPR_0 - Text flows from left to right and from top to bottom.
; EPR_90 - Text flows from left to right and from bottom to top.
; EPR_180 - Reserved.
; EPR_270 - Reserved.

  static EM_GETPAGEROTATE=235,WM_USER=0x400
  SendMessage, WM_USER | EM_GETPAGEROTATE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Gets the current text layout.
}

EM_GETPARAFORMAT(hCtrl)  {
;   static EM_GETPARAFORMAT=61,WM_USER=0x400
;   SendMessage, WM_USER | EM_GETPARAFORMAT, 0,&PARAFORMAT,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
}

EM_GETPUNCTUATION(hCtrl)  {
  static EM_GETPUNCTUATION=101,WM_USER=0x400
  static PC_LEADING=2,PC_FOLLOWING=1,PC_DELIMITER=4,PC_OVERFLOW=3

;This structure is used only in Asian-language versions of the operating system.
    nType:=PC_FOLLOWING
  VarSetCapacity(PUNCTUATION, 8, 0)
  NumPut(4, PUNCTUATION, 0, "UInt") ; PUNCTUATION_iSize
  NumPut(&szPunctuation, PUNCTUATION, 4, "UInt")
  SendMessage, WM_USER | EM_GETPUNCTUATION, nType,&PUNCTUATION,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
  PUNCTUATION_iSize := NumGet(PUNCTUATION, 0, "UInt")
  szPunctuation:=NumGet(PUNCTUATION, 4, "UInt")
  msgbox, % DllCall("MulDiv", "Int",szPunctuation, "Int",1, "Int",1, "str")
}

EM_SETPUNCTUATION(hCtrl)  {
  static EM_SETPUNCTUATION=100,WM_USER=0x400
  static PC_LEADING=2,PC_FOLLOWING=1,PC_DELIMITER=4,PC_OVERFLOW=3
;This structure is used only in Asian-language versions of the operating system.
    nType:=PC_LEADING
  VarSetCapacity(PUNCTUATION, 8, 0)
  NumPut(PUNCTUATION_iSize, PUNCTUATION, 0, "UInt")
  NumPut(PUNCTUATION_szPunctuation, PUNCTUATION, 4, "UInt")
  SendMessage, WM_USER | EM_SETPUNCTUATION, nType,&PUNCTUATION,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If the operation succeeds, the return value is a nonzero value.
}

EM_GETTYPOGRAPHYOPTIONS(hCtrl)  {   ; Rich Edit 3.0
  static EM_GETTYPOGRAPHYOPTIONS=203,WM_USER=0x400
  SendMessage, WM_USER | EM_GETTYPOGRAPHYOPTIONS, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The return value can be one of the following values.

  static TO_ADVANCEDTYPOGRAPHY=1,TO_SIMPLELINEBREAK=2
}

EM_GETWORDBREAKPROCEX(hCtrl)  {
  static EM_GETWORDBREAKPROCEX=80,WM_USER=0x400
  SendMessage, WM_USER | EM_GETWORDBREAKPROCEX, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; The message returns the address of the current procedure.
}

EM_HIDESELECTION(hCtrl, value=true)  {
  static EM_HIDESELECTION=63,WM_USER=0x400
  SendMessage, WM_USER | EM_HIDESELECTION, (value ? true : false),0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; This message does not return a value.
}

EM_ISIME(hCtrl)  {  ; richedit 4.1 only (msftedit.dll)
  static EM_ISIME=243,WM_USER=0x400
  SendMessage, WM_USER | EM_ISIME, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Returns TRUE if it is an East Asian locale. Otherwise, it returns FALSE.
}

EM_RECONVERSION(hCtrl)  {
  static EM_RECONVERSION=125,WM_USER=0x400
  SendMessage, WM_USER | EM_RECONVERSION, 0,0,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; This message always returns zero.
}

EM_REQUESTRESIZE(hCtrl)  {
  static EM_REQUESTRESIZE=65,WM_USER=0x400
;This message is useful during WM_SIZE processing for the parent of a bottomless rich edit control.

  SendMessage, WM_USER | EM_REQUESTRESIZE, 0,0,, ahk_id %hCtrl%
;   MsgBox, % errorlevel  ; This message does not return a value.
}

EM_SETCTFMODEBIAS(hCtrl, mode)  {
  static EM_SETCTFMODEBIAS=238,WM_USER=0x400

  ;set the Text Services Framework (TSF) mode bias
  static CTFMODEBIAS_DEFAULT=0x0000,CTFMODEBIAS_FILENAME=0x0001,CTFMODEBIAS_NAME=0x0002,CTFMODEBIAS_READING=0x0003
        ,CTFMODEBIAS_DATETIME=0x0004,CTFMODEBIAS_CONVERSATION=0x0005,CTFMODEBIAS_NUMERIC=0x0006
        ,CTFMODEBIAS_HIRAGANA=0x0007,CTFMODEBIAS_KATAKANA=0x0008,CTFMODEBIAS_HANGUL=0x0009
        ,CTFMODEBIAS_HALFWIDTHKATAKANA=0x000A,CTFMODEBIAS_FULLWIDTHALPHANUMERIC=0x000B,CTFMODEBIAS_HALFWIDTHALPHANUMERIC=0x000C
  mode := CTFMODEBIAS_FILENAME    ; one of the following values.
  ; CTFMODEBIAS_DEFAULT -There is no mode bias.
  ; CTFMODEBIAS_FILENAME - The bias is to a filename.
  ; CTFMODEBIAS_NAME - The bias is to a name.
  ; CTFMODEBIAS_READING - The bias is to the reading.
  ; CTFMODEBIAS_DATETIME - The bias is to a date or time.
  ; CTFMODEBIAS_CONVERSATION - The bias is to a conversation.
  ; CTFMODEBIAS_NUMERIC - The bias is to a number.
  ; CTFMODEBIAS_HIRAGANA - The bias is to hiragana strings.
  ; CTFMODEBIAS_KATAKANA - The bias is to katakana strings.
  ; CTFMODEBIAS_HANGUL - The bias is to Hangul characters.
  ; CTFMODEBIAS_HALFWIDTHKATAKANA - The bias is to half-width katakana strings.
  ; CTFMODEBIAS_FULLWIDTHALPHANUMERIC - The bias is to full-width alphanumeric characters.
  ; CTFMODEBIAS_HALFWIDTHALPHANUMERIC - The bias is to half-width alphanumeric characters.

  SendMessage, EM_SETCTFMODEBIAS | WM_USER, mode,0,, ahk_id %hCtrl%
  MsgBox, % ERRORLEVEL ; If successful, the return value is the new TSF mode bias value. If unsuccessful, the return value is the old TSF mode bias value.
}

EM_SETCTFOPENSTATUS(hCtrl)  {
;Text Services Framework (TSF)
  static EM_SETCTFOPENSTATUS=241,WM_USER=0x400
  tsfKeyboard := true
  SendMessage, EM_SETCTFMODEBIAS | WM_USER, (tsfKeyboard ? true : false),0,, ahk_id %hCtrl%
  MsgBox, % ERRORLEVEL ; If successful, this message returns TRUE.
}

EM_SETIMEMODEBIAS(hCtrl)  {
;   static EM_SETIMEMODEBIAS=126,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETIMEMODEBIAS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETIMEOPTIONS(hCtrl)  {
;   static EM_SETIMEOPTIONS=106,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETIMEOPTIONS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETLANGOPTIONS(hCtrl)  {
;   static EM_SETLANGOPTIONS=120,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETLANGOPTIONS, 0,&@??,, ahk_id %hCtrl%

}

EM_SETPAGEROTATE(hCtrl)  {


  static EM_GETPAGEROTATE=236,WM_USER=0x400
  SendMessage, WM_USER | EM_GETPAGEROTATE, 0,0,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; Gets the current text layout.
}

EM_SETPALETTE(hCtrl)  {
;   static EM_SETPALETTE=93,WM_USER=0x400
;
;   SendMessage, WM_USER | EM_SETPALETTE, 0,&@??,, ahk_id %hCtrl%

}

EM_SETTARGETDEVICE(hCtrl, width)  {

  ; http://www.codeproject.com/KB/printing/richeditprint.aspx?display=Print
  ; http://msdn.microsoft.com/en-us/library/ms646940(VS.85).aspx

  static hModule,PD_RETURNDC=0x100,PD_RETURNDEFAULT=0x400
  static EM_SETTARGETDEVICE=72,WM_USER=0x400

  If !hModule
    hModule := DllCall("LoadLibrary","str","comdlg32.dll")
  VarSetCapacity(PRINTDIALOG_STRUCT,66,0), NumPut(66,PRINTDIALOG_STRUCT)
  NumPut( PD_RETURNDC | PD_RETURNDEFAULT, PRINTDIALOG_STRUCT,20)
  If !DllCall("comdlg32\PrintDlgA","uint",&PRINTDIALOG_STRUCT)  {
    DllCall("FreeLibrary", "UInt", hModule), hModule := ""
    return false, errorlevel := "ERROR: Couldn't retrieve default printer."
  }

;   hDC := NumGet(PRINTDIALOG_STRUCT,16) ; default printers device context hwnd

  hDC := DllCall("GetDC","uint",hCtrl)
  SendMessage, WM_USER | EM_SETTARGETDEVICE, hdc,width*1440,, ahk_id %hCtrl%  ; line width in twips (1440 twips/inch)
  MsgBox, % errorlevel  ; The return value is zero if the operation fails, or nonzero if it succeeds.
;   DllCall("DeleteDC","uint",hDC)
}

EM_SETTYPOGRAPHYOPTIONS(hCtrl)  {
  static EM_SETTYPOGRAPHYOPTIONS=202,WM_USER=0x400,TO_ADVANCEDTYPOGRAPHY=1,TO_SIMPLELINEBREAK=2
  SendMessage, WM_USER | EM_SETTYPOGRAPHYOPTIONS, TO_ADVANCEDTYPOGRAPHY,TO_ADVANCEDTYPOGRAPHY,, ahk_id %hCtrl%
  MsgBox, % errorlevel  ; If wParam is valid, the return value is TRUE.
}

EM_STOPGROUPTYPING(hCtrl)  {
  static EM_STOPGROUPTYPING=88,WM_USER=0x400
  SendMessage, WM_USER | EM_STOPGROUPTYPING, 0,0,, ahk_id %hCtrl%
}

EM_STREAMIN(hCtrl)  {
  static EM_STREAMIN=73,WM_USER=0x400
  static SF_RTF=0x2,SF_RTFNOOBJS=0x3,SF_TEXT=0x1,SF_TEXTIZED=0x4
  static SFF_PLAINRTF=0x4000,SFF_SELECTION=0x8000,SF_UNICODE=0x10,SF_USECODEPAGE=0x20

  wbProc := RegisterCallback("RichEdit_editStreamCallBack")
  VarSetCapacity(EDITSTREAM, 16, 0)
  NumPut(&dwCookie, EDITSTREAM, 0, "UInt") ; dwCookie
  NumPut(wbProc, EDITSTREAM, 8, "UInt")
  SendMessage, WM_USER | EM_STREAMIN, SF_TEXT,&EDITSTREAM,, ahk_id %hCtrl%
  MsgBox, % errorlevel
}

EM_GETIMECOLOR(hCtrl)  {
; This message is available only in Asian-language versions of the operating system.
;   static EM_GETIMECOLOR=105,WM_USER=0x400
;   SendMessage, WM_USER | EM_GETIMECOLOR, 0,&@??,, ahk_id %hCtrl%
}

EM_SETIMECOLOR(hCtrl)  {
; This message is available only in Asian-language versions of the operating system.
;   static EM_SETIMECOLOR=104,WM_USER=0x400
;   SendMessage, WM_USER | EM_SETIMECOLOR, 0,&@??,, ahk_id %hCtrl%
}

RichEdit_wordBreakProc(lpch, ichCurrent, cch, code) {
  ;   LPTSTR lpch    - A pointer to the text of the edit control.
  ;   int ichCurrent - An index to a character position in the buffer of text that identifies the point
  ;                    at which the function should begin checking for a word break.
  ;   int cch        - An index to a character position in the buffer of text that identifies the point
  ;                    at which the function should begin checking for a word break.
  ;   int code       - The action to be taken by the callback function. This parameter can be one of the
  ;                    following values:
  ;                   WB_CLASSIFY      - Retrieves the character class and word break flags of the
  ;                                      character at the specified position. This value is for use with
  ;                                      rich edit controls.
  ;                   WB_ISDELIMITER   - Checks whether the character at the specified position is a
  ;                                      delimiter.
  ;                   WB_LEFT          - Finds the beginning of a word to the left of the specified
  ;                                      position.
  ;                   WB_LEFTBREAK     - Finds the end-of-word delimiter to the left of the specified
  ;                                      position. This value is for use with rich edit controls.
  ;                   WB_MOVEWORDLEFT  - Finds the beginning of a word to the left of the specified
  ;                                      position. This value is used during CTRL+LEFT key processing.
  ;                                      This value is for use with rich edit controls.
  ;                   WB_MOVEWORDRIGHT - Finds the beginning of a word to the right of the specified
  ;                                      position. This value is used during CTRL+RIGHT key processing.
  ;                                      This value is for use with rich edit controls.
  ;                   WB_RIGHT         - Finds the beginning of a word to the right of the specified
  ;                                      position. This is useful in right-aligned edit controls.
  ;                   WB_RIGHTBREAK    - Finds the end-of-word delimiter to the right of the specified
  ;                                      position. This is useful in right-aligned edit controls. This
  ;                                      value is for use with rich edit controls.
  static WB_CLASSIFY=3,WB_ISDELIMITER=2,WB_LEFT=0,WB_LEFTBREAK=6,WB_MOVEWORDLEFT=4,WB_MOVEWORDRIGHT=5,WB_RIGHT=1,WB_RIGHTBREAK=7

	exp=(s|c| )
   Loop, % cch * 2 ; build the string:
      str .= Chr(*(lpch - 1 + A_Index))

 ;       StringReplace, str,str, %a_space%,_,A
 ;   str := DllCall("MulDiv", "Int",lpch, "Int",1, "Int",1, "str")
	tooltip, lpch=%lpch% `nichCurrent=%ichCurrent% `ncch=%cch% `ncode=%code% `nstr=%str%
 ; If (code = WB_LEFT)
 ;   return RegExMatch( str, "s[^s]*\Z.*s.*" )
	If (code = WB_MOVEWORDLEFT)
      Return, RegExMatch(   SubStr(str, 1, ichCurrent = cch ? cch : ichCurrent - (ichCurrent > 1))
                          , exp . "[^" . exp . "]*\Z")
	If (code = WB_MOVEWORDRIGHT)
     Return, ichCurrent = cch or !(z := RegExMatch(str, exp, "", ichCurrent + 1)+1) ? cch : z - 1


 ;   str= especially
 ; msgbox, %  RegExMatch( str, "s[^s]*\Z.*s.*" )
 ;    static exp = "\W" ; treat any non alphanumeric character as a delimiter with this regex
 ;    Loop, % cch * 2 ; build the string:
 ;       str .= Chr(*(lpch - 1 + A_Index))
 ;    If code = 0 ; WB_LEFT
 ;       Return, RegExMatch(SubStr(str, 1, ichCurrent = cch
 ;          ? cch : ichCurrent - (ichCurrent > 1)), exp . "[^" . exp . "]*\Z")
 ;    Else If code = 1 ; WB_RIGHT
 ;     ToolTip, right
 ; ;       Return, ichCurrent = cch or !(z := RegExMatch(str, exp, "", ichCurrent + 1)) ? cch : z - 1
 ;    Else If code = 2 ; WB_ISDELIMITER
 ;       Return, RegExMatch(SubStr(str, ichCurrent + 1, 1), exp)
}

; EM_GETWORDBREAKPROC
EM_SETWORDBREAKPROCEX(hCtrl)  {     ; *** no longer used after re2.0.  use  EM_SETWORDBREAKPROC to set EditWordBreakProc instead
 ;   static EM_SETWORDBREAKPROCEX=81,WM_USER=0x400
 ;
 ;   SendMessage, WM_USER | EM_SETWORDBREAKPROCEX, 0,&@??,, ahk_id %hCtrl%

}

 ; *** WIP-  http://msdn.microsoft.com/en-us/library/bb774252(VS.85).aspx
__RichEdit_OleInterface(hCtrl)  {
  static EM_GETOLEINTERFACE:=60,EM_SETOLECALLBACK:=70,WM_USER:=0x400

  ; Retrieve an IRichEditOle object to access a rich edit control's COM functionality.
  VarSetCapacity(pointer, 4)
  SendMessage, WM_USER | EM_GETOLEINTERFACE, 0,&pointer,, ahk_id %hCtrl%
  If !pointer := NumGet(pointer, 0)
    return "ERROR:  Couldn't retrieve an IRichEditOle object for control."
 ; COM methods: http://msdn.microsoft.com/en-us/library/bb774306(VS.85).aspx


  ; gives a rich edit control an IRichEditOleCallback object that the control uses to
  ; get OLE-related resources and information from the client.
  SendMessage, WM_USER | EM_SETOLECALLBACK, 0,pointer,, ahk_id %hCtrl%

 ;   com_init()
 ;   msgbox, % pipa := COM_QueryInterface(pointer)
 ;   msgbox, % COM_Invoke(pipa, "GetClipboardData")
  ;   msgbox, KEEP GOING: "%pointer%"
}

EM_GETCHARFORMAT222(hCtrl, ByRef face="", ByRef style="", ByRef color="")  {
  static EM_GETCHARFORMAT=58,WM_USER=0x400
  static SCF_DEFAULT=0x0,SCF_SELECTION=0x1

  VarSetCapacity(CHARFORMAT, 60, 0), NumPut(60, CHARFORMAT)
  SendMessage, WM_USER | EM_GETCHARFORMAT, SCF_SELECTION,&CHARFORMAT,, ahk_id %hCtrl%

  ; dwMask - Members containing valid information or attributes to set. This member can be zero, one, or more than one of the following values.
   static CFM_BOLD=0x1,CFM_CHARSET=0x8000000,CFM_COLOR=0x40000000,CFM_FACE=0x20000000,CFM_ITALIC=0x2,CFM_OFFSET=0x10000000,CFM_PROTECTED=0x10,CFM_SIZE=0x80000000,CFM_STRIKEOUT=0x8,CFM_UNDERLINE=0x4

  ; dwEffects - Character effects. This member can be a combination of the following values.
  static CFE_AUTOCOLOR=0x40000000,CFE_BOLD=0x1,CFE_ITALIC=0x2,CFE_STRIKEOUT=0x8,CFE_UNDERLINE=0x4,CFE_PROTECTED=0x10
  cfe := NumGet(CHARFORMAT, 8, "UInt")
  dwEffects=PROTECTED,UNDERLINE,STRIKEOUT,ITALIC,BOLD,AUTOCOLOR
  Loop, parse, dwEffects,`,
    cfe >= CFE_%a_loopfield%  ?  (style.=(style ? " " a_loopfield : a_loopfield), cfe-=CFE_%a_loopfield%)  :  ""
     cfe >= CFE_%a_loopfield%  ?  (cfeDesc.=(cfeDesc ? " " a_loopfield : a_loopfield), cfe-=CFE_%a_loopfield%)  :  ""

  ; color
  old := A_FormatInteger
  SetFormat, integer, hex
  RegExMatch( NumGet(CHARFORMAT,20,"UInt")+0x1000000, "(?P<R>..)(?P<G>..)(?P<B>..)$", _ ) ; BGR2RGB
  crTextColor := "0x" _B _G _R

  ; font size
  SetFormat, float, 1.0
  style .= (style ? " s" : "s") . NumGet(CHARFORMAT,12,"Int")/20
   cfeDesc .= (cfeDesc ? " s" : "s") . NumGet(CHARFORMAT,12,"Int")/20
  SetFormat, integer, %old%

  ; face
  VarSetCapacity(szFaceName, 32)
  DllCall("RtlMoveMemory", "str", szFaceName, "Uint", &CHARFORMAT + 26, "Uint", 32)
  ;-
   face:=szFaceName, style:=cfeDesc, color:=crTextColor
}

EM_SETWORDBREAKPROC(hCtrl)  {
  static EM_SETWORDBREAKPROC=0xD0
        ,wbProc

    if !wbProc
      wbProc := RegisterCallback("RichEdit_wordBreakProc")
 ;       DllCall("GlobalFree", "UInt", wbProc)
  SendMessage, 208, 0,wbProc,, ahk_id %hCtrl%
 ;   SendMessage, EM_SETWORDBREAKPROC, 0,wbProc,, ahk_id %hCtrl%
  MsgBox, % errorlevel " - " wbProc . " - " . hCtrl
 ; Return Value - This message does not return a value.
 ;   msgbox, hold..
 ;       DllCall("GlobalFree", "UInt", wbProc)
}

/*
 Function:	StreamOut
			Returns rich edit control data in various formats.

 Parameters:
			Out	- Reference to the output variable.
			Flags - <http://msdn.microsoft.com/en-us/library/bb774304(VS.85).aspx>

 Returns:
			Number of characters.
 */
; problem is the size of RTF data.
RichEdit_StreamOut(hCtrl, ByRef Out, Flags="RTF")  {
	static EM_STREAMOUT=0x44A
		, SF_RTF=0x2,SF_RTFNOOBJS=0x3,SF_TEXT=0x1,SF_TEXTIZED=0x4
		, SF_PLAINRTF=0x4000,SF_SELECTION=0x8000,SF_UNICODE=0x10,SF_USECODEPAGE=0x20

	hFlag := 0
	Loop, parse, Flags, %A_Tab%%A_Space%
		IfEqual, A_LoopField, ,continue
		else hFlag |= SF_%A_LoopField%
	ifEqual, hFlag,, return A_ThisFunc "> Some of the flags are invalid: " Flags

	wbProc := RegisterCallback("RichEdit_editStreamCallBack", "F")

	len := RichEdit_GetTextLength(hCtrl, "NUMBYTES")
	VarSetCapacity(out, len*10)	;!!! meh....
	VarSetCapacity(EDITSTREAM, 16, 0)
	NumPut(&out,   EDITSTREAM, 0, "UInt") ; dwCookie
	NumPut(wbProc, EDITSTREAM, 8, "UInt")

	SendMessage, EM_STREAMOUT, hFlag, &EDITSTREAM,, ahk_id %hCtrl%
	VarSetCapacity(out, -1)
	return ErrorLevel
}