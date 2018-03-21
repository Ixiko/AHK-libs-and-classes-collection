/* Title:	Dlg
			*Common Operating System Dialogs*
 */

/*
 Function:		Color
				(See Dlg_color.png)

 Parameters: 
				Color	- Initial color and output in RGB format.
				hGui	- Optional handle to parents Gui. Affects dialog position.
  
 Returns:	
				False if user canceled the dialog or if error occurred	
 */ 
Dlg_Color(ByRef Color, hGui=0){ 
  ;covert from rgb
    clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF)

    VarSetCapacity(CHOOSECOLOR, 0x24, 0), VarSetCapacity(CUSTOM, 64, 0)
     ,NumPut(0x24,		CHOOSECOLOR, 0)      ; DWORD lStructSize 
     ,NumPut(hGui,		CHOOSECOLOR, 4)      ; HWND hwndOwner (makes dialog "modal"). 
     ,NumPut(clr,		CHOOSECOLOR, 12)     ; clr.rgbResult 
     ,NumPut(&CUSTOM,	CHOOSECOLOR, 16)     ; COLORREF *lpCustColors
     ,NumPut(0x00000103,CHOOSECOLOR, 20)     ; Flag: CC_ANYCOLOR || CC_RGBINIT 

    nRC := DllCall("comdlg32\ChooseColorA", str, CHOOSECOLOR)  ; Display the dialog. 
    if (errorlevel <> 0) || (nRC = 0) 
       return  false 

    clr := NumGet(CHOOSECOLOR, 12) 
    
    oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

 ;convert to rgb 
    Color := (clr & 0xff00) + ((clr & 0xff0000) >> 16) + ((clr & 0xff) << 16) 
    StringTrimLeft, Color, Color, 2 
    loop, % 6-strlen(Color) 
		Color=0%Color% 
    Color=0x%Color% 
    SetFormat, integer, %oldFormat% 
	return true
}

/*

 Function:     Find / Replace
				(See Dlg_find.png)
				(See Dlg_replace.png)

 Parameters: 
               hGui    - Handle to the parent.
               Handler - Notification handler, see below.
               Flags   - Creation flags, see below.
               FindText - Default text to be displayed at the start of the dialog box in find edit box.
               ReplaceText - Default text to be displayed at the start of the dialog box in replace edit box.

 Flags:        
				String containing list of creation flags. You can use "-" prefix to hide that GUI field.

                d - down radio button selected in Find dialog.
                w - whole word selected.
                c - match case selected.

 Handler:
				Dialog box is not modal, so it communicates with the script while it is active. Both Find & Replace use 
				the same prototype of notification function.

 >				Handler(Event, Flags, FindText, ReplaceText)

                   Event    - C (Close), F (Find), R (Replace), A (replace All)
                   Flags    - String containing flags about user selection; each letter means user has selected that particular GUI element.
                   FindText - Current find text.
                ReplaceText - Current replace text.
   
 Returns:      
				Handle of the dialog or 0 if the dialog can't be created. Returns error code on invalid handler.
 */ 
Dlg_Find( hGui, Handler, Flags="d", FindText="") {
	static FINDMSGSTRING = "commdlg_FindReplace"
	static FR_DOWN=1, FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000
	static buf, FR, len

	if len =
		VarSetCapacity(FR, 40, 0), VarSetCapacity(buf, len := 256)

	ifNotEqual, FindText, , SetEnv, buf, %FindText%
	
	f := 0
	 ,InStr(flags, "d")  ? f |= FR_DOWN			 : ""
	 ,InStr(flags, "c")  ? f |= FR_MATCHCASE	 : ""
	 ,InStr(flags, "w")  ? f |= FR_WHOLEWORD	 : ""
	 ,InStr(flags, "-d") ? f |= FR_HIDEUPDOWN	 : ""
	 ,InStr(flags, "-w") ? f |= FR_HIDEWHOLEWORD : ""
	 ,InStr(flags, "-c") ? f |= FR_HIDEMATCHCASE : ""

	NumPut(40,		FR, 0)	;size
	 ,NumPut( hGui,	FR, 4)	;hwndOwner
	 ,NumPut( f,	FR, 12)	;Flags
	 ,NumPut( &buf,	FR, 16)	;lpstrFindWhat
	 ,NumPut( len,	FR, 24) ;wFindWhatLen

	if !IsFunc(Handler)
		return A_ThisFunc ">Invalid handler: " Handler

	Dlg_callback(Handler,"","","")
	OnMessage( DllCall("RegisterWindowMessage", "str", FINDMSGSTRING), "Dlg_callback" )

	return DllCall("comdlg32\FindTextA", "str", FR)
}

Dlg_Replace( hGui, Handler, Flags="", FindText="", ReplaceText="") {
	static FINDMSGSTRING = "commdlg_FindReplace"
	static FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000
	static buf_f, buf_r, FR, len

	if len =
		len := 256, VarSetCapacity(FR, 40, 0), VarSetCapacity(buf_f, len), VarSetCapacity(buf_r, len)

	f := 0
	f |= InStr(flags, "c")  ? FR_MATCHCASE : 0
	f |= InStr(flags, "w")  ? FR_WHOLEWORD : 0
	f |= InStr(flags, "-w") ? FR_HIDEWHOLEWORD :0 
	f |= InStr(flags, "-c") ? FR_HIDEMATCHCASE :0


	ifNotEqual, FindText, ,SetEnv, buf_f, %FindText%
	ifNotEqual, ReplaceText, ,SetEnv, buf_r, %ReplaceText%

	
	NumPut( 40,		  FR, 0)	;size
	 ,NumPut( hGui,	  FR, 4)	;hwndOwner
	 ,NumPut( f,	  FR, 12)	;Flags
	 ,NumPut( &buf_f, FR, 16)	;lpstrFindWhat
	 ,NumPut( &buf_r, FR, 20)	;lpstrReplaceWith
	 ,NumPut( len,	  FR, 24)	;wFindWhatLen
	 ,NumPut( len,	  FR, 26)	;wReplaceWithLen


	Dlg_callback(Handler,"","","")
	OnMessage( DllCall("RegisterWindowMessage", "str", FINDMSGSTRING), "Dlg_callback" )
	return DllCall("comdlg32\ReplaceTextA", "str", FR)
}

/*
 Function:  Font
			 (See Dlg_font.png)				

 Parameters:
            Name	- Initial font,  output.
            Style	- Initial style, output.
            Color	- Initial text color, output.
			Effects	- Set to false to disable effects (strikeout, underline, color).
            hGui	- Parent's handle, affects position.

  Returns:
            False if user canceled the dialog or if error occurred.
 */
Dlg_Font(ByRef Name, ByRef Style, ByRef Color, Effects=true, hGui=0) {

   LogPixels := DllCall("GetDeviceCaps", "uint", DllCall("GetDC", "uint", hGui), "uint", 90)	;LOGPIXELSY
   VarSetCapacity(LOGFONT, 128, 0)

   Effects := 0x041 + (Effects ? 0x100 : 0)  ;CF_EFFECTS = 0x100, CF_SCREENFONTS=1, CF_INITTOLOGFONTSTRUCT = 0x40

   ;set initial name
   DllCall("RtlMoveMemory", "uint", &LOGFONT+28, "Uint", &Name, "Uint", 32)

   ;convert from rgb  
   clr := ((Color & 0xFF) << 16) + (Color & 0xFF00) + ((Color >> 16) & 0xFF) 

   ;set intial data
   if InStr(Style, "bold")
      NumPut(700, LOGFONT, 16)

   if InStr(Style, "italic")
      NumPut(255, LOGFONT, 20, 1)

   if InStr(Style, "underline")
      NumPut(1, LOGFONT, 21, 1)
   
   if InStr(Style, "strikeout")
      NumPut(1, LOGFONT, 22, 1)

   if RegExMatch(Style, "s[1-9][0-9]*", s){
      StringTrimLeft, s, s, 1      
      s := -DllCall("MulDiv", "int", s, "int", LogPixels, "int", 72)
      NumPut(s, LOGFONT, 0, "Int")			; set size
   }
   else  NumPut(16, LOGFONT, 0)         ; set default size

   VarSetCapacity(CHOOSEFONT, 60, 0)
    ,NumPut(60,		 CHOOSEFONT, 0)		; DWORD lStructSize
    ,NumPut(hGui,    CHOOSEFONT, 4)		; HWND hwndOwner (makes dialog "modal").
    ,NumPut(&LOGFONT,CHOOSEFONT, 12)	; LPLOGFONT lpLogFont
    ,NumPut(Effects, CHOOSEFONT, 20)	
    ,NumPut(clr,	 CHOOSEFONT, 24)	; rgbColors

   r := DllCall("comdlg32\ChooseFontA", "uint", &CHOOSEFONT)  ; Display the dialog.
   if !r
      return false

  ;font name
	VarSetCapacity(Name, 32)
	DllCall("RtlMoveMemory", "str", Name, "Uint", &LOGFONT + 28, "Uint", 32)
	Style := "s" NumGet(CHOOSEFONT, 16) // 10

  ;color
	old := A_FormatInteger
	SetFormat, integer, hex                      ; Show RGB color extracted below in hex format.
	Color := NumGet(CHOOSEFONT, 24)
	SetFormat, integer, %old%

  ;styles
	Style =
	VarSetCapacity(s, 3)
	DllCall("RtlMoveMemory", "str", s, "Uint", &LOGFONT + 20, "Uint", 3)

	if NumGet(LOGFONT, 16) >= 700
	  Style .= "bold "

	if NumGet(LOGFONT, 20, "UChar")
      Style .= "italic "
   
	if NumGet(LOGFONT, 21, "UChar")
      Style .= "underline "

	if NumGet(LOGFONT, 22, "UChar")
      Style .= "strikeout "

	s := NumGet(LOGFONT, 0, "Int")
	Style .= "s" Abs(DllCall("MulDiv", "int", abs(s), "int", 72, "int", LogPixels))

 ;convert to rgb 
	oldFormat := A_FormatInteger 
    SetFormat, integer, hex  ; Show RGB color extracted below in hex format. 

    Color := (Color & 0xff00) + ((Color & 0xff0000) >> 16) + ((Color & 0xff) << 16) 
    StringTrimLeft, Color, Color, 2 
    loop, % 6-strlen(Color) 
		Color=0%Color% 
    Color=0x%Color% 
    SetFormat, integer, %oldFormat% 

   return 1
}

/*
 Function:	Icon 
			(See Dlg_icon.png)

 Parameters:
			Icon	- Default icon resource, output.
			Index	- Default index within resource, output.
			hGui	- Optional handle of the parent GUI.

 Returns:
			False if user canceled the dialog or if error occurred 
		
 Remarks:
			This is simple and non-flexible dialog. If you need more features, use <IconEx> instead.
 */
Dlg_Icon(ByRef Icon, ByRef Index, hGui=0) {      
    VarSetCapacity(wIcon, 1025, 0) 
    If (Icon) && !DllCall("MultiByteToWideChar", "UInt", 0, "UInt", 0, "Str", Icon, "Int", StrLen(Icon), "UInt", &wIcon, "Int", 1025) 
		return false

	r := DllCall(DllCall("GetProcAddress", "Uint", DllCall("LoadLibrary", "str", "shell32.dll"), "Uint", 62), "uint", hGui, "uint", &wIcon, "uint", 1025, "intp", --Index)
	Index++
	IfEqual, r, 0, return false

	VarSetCapacity(Icon, len := DllCall("lstrlenW", "UInt", &wIcon) ) 
	r := DllCall("WideCharToMultiByte" , "UInt", 0, "UInt", 0, "UInt", &wIcon, "Int", len, "Str", Icon, "Int", len, "UInt", 0, "UInt", 0) 
	IfEqual, r, 0, return false
    Return True 
}

/*
 Function:  Open / Save 
			 (See Dlg_open.png)

 Parameters: 
            hGui            - Parent's handle, positive number by default 0 (influences dialog position).
            Title			- Dialog title.
            Filter          - Specify filter as with FileSelectFile. Separate multiple filters with "|". For instance "All Files (*.*)|Audio (*.wav; *.mp2; *.mp3)|Documents (*.txt)"
            DefaultFilter   - Index of default filter (1 based), by default 1.
            Root			- Specifies startup directory and initial content of "File Name" edit. 
							  Directory must have trailing "\".
            DefaultExt      - Extension to append when none given .
            Flags           - White space separated list of flags, by default "FILEMUSTEXIST HIDEREADONLY".
  
  Flags:
			allowmultiselect	- Specifies that the File Name list box allows multiple selections 
			createprompt		- If the user specifies a file that does not exist, this flag causes the dialog box to prompt the user for permission to create the file
			dontaddtorecent		- Prevents the system from adding a link to the selected file in the file system directory that contains the user's most recently used documents. 
			extensiondifferent	- Specifies that the user typed a file name extension that differs from the extension specified by defaultExt
			filemustexist		- Specifies that the user can type only names of existing files in the File Name entry field
			forceshowhidden		- Forces the showing of system and hidden files, thus overriding the user setting to show or not show hidden files. However, a file that is marked both system and hidden is not shown.
			hidereadonly		- Hides the Read Only check box.
			nochangedir			- Restores the current directory to its original value if the user changed the directory while searching for files.
			nodereferencelinks	- Directs the dialog box to return the path and file name of the selected shortcut (.LNK) file. If this value is not specified, the dialog box returns the path and file name of the file referenced by the shortcut.
			novalidate			- Specifies that the common dialog boxes allow invalid characters in the returned file name
			overwriteprompt		- Causes the Save As dialog box to generate a message box if the selected file already exists. The user must confirm whether to overwrite the file.
			pathmustexist		- Specifies that the user can type only valid paths and file names.
			readonly			- Causes the Read Only check box to be selected initially when the dialog box is created
			showhelp			- Causes the dialog box to display the Help button. The hGui receives the HELPMSGSTRING registered messages that the dialog box sends when the user clicks the Help button. 
			noreadonlyreturn	- Specifies that the returned file does not have the Read Only check box selected and is not in a write-protected directory.
			notestfilecreate	- Specifies that the file is not created before the dialog box is closed. This flag should be specified if the application saves the file on a create-nonmodify network share.
 
  Returns: 
            Selected FileName or nothing if cancelled. If more then one file is selected they are separated by new line character.


  Remarks:
		    Those functions will change the working directory of the script. Use SetWorkingDir afterwards to restore working directory if needed.
 */	
Dlg_Open( hGui=0, Title="", Filter="", DefaultFilter="", Root="", DefaultExt="", Flags="FILEMUSTEXIST HIDEREADONLY" ) { 
	static OFN_S:=0, OFN_ALLOWMULTISELECT:=0x200, OFN_CREATEPROMPT:=0x2000, OFN_DONTADDTORECENT:=0x2000000, OFN_EXTENSIONDIFFERENT:=0x400, OFN_FILEMUSTEXIST:=0x1000, OFN_FORCESHOWHIDDEN:=0x10000000, OFN_HIDEREADONLY:=0x4, OFN_NOCHANGEDIR:=0x8, OFN_NODEREFERENCELINKS:=0x100000, OFN_NOVALIDATE:=0x100, OFN_OVERWRITEPROMPT:=0x2, OFN_PATHMUSTEXIST:=0x800, OFN_READONLY:=0x1, OFN_SHOWHELP:=0x10, OFN_NOREADONLYRETURN:=0x8000, OFN_NOTESTFILECREATE:=0x10000

	IfEqual, Filter, ,SetEnv, Filter, All Files (*.*)
	SplitPath, Root, rootFN, rootDir

	hFlags := 0x80000								;OFN_ENABLEXPLORER always set
	loop, parse, Flags,%A_TAB%%A_SPACE%,%A_TAB%%A_SPACE%
		if A_LoopField !=
			hFlags |= OFN_%A_LoopField%

	ifEqual, hFlags, , return A_ThisFunc "> Some of the flags are invalid: " Flags
	VarSetCapacity( FN, 0xffff ), VarSetCapacity( lpstrFilter, 2*StrLen(filter))

	if rootFN !=
		  DllCall("lstrcpyn", "str", FN, "str", rootFN, "int", StrLen(rootFN)+1) 

	; Contruct FilterText seperate by \0 
	delta := 0										;Used by Loop as Offset
	loop, Parse, Filter, |                
	{ 
		desc := A_LoopField,  ext := SubStr(A_LoopField, InStr( A_LoopField,"(" )+1, -1) 
		lenD := StrLen(A_LoopField)+1,	lenE := StrLen(ext)+1				;including /0

		DllCall("lstrcpyn", "uint", &lpstrFilter + delta, "uint", &desc, "int", lenD) 
		DllCall("lstrcpyn", "uint", &lpstrFilter + delta + lenD, "uint", &ext, "int", lenE)
		delta += lenD + lenE
	} 
	NumPut(0, lpstrFilter, delta, "UChar" )		  ; Double Zero Termination 

	; Contruct OPENFILENAME Structure   
	VarSetCapacity( OFN ,90, 0)
	 ,NumPut( 76,			 OFN, 0,  "UInt" )    ; Length of Structure 
	 ,NumPut( hGui,			 OFN, 4,  "UInt" )    ; HWND 
	 ,NumPut( &lpstrFilter,	 OFN, 12, "UInt" )    ; Pointer to FilterStruc 
	 ,NumPut( DefaultFilter, OFN, 24, "UInt" )    ; DefaultFilter Pair 
	 ,NumPut( &FN,			 OFN, 28, "UInt" )    ; lpstrFile / InitialisationFileName 
	 ,NumPut( 0xffff,		 OFN, 32, "UInt" )    ; MaxFile / lpstrFile length 
	 ,NumPut( &rootDir,		 OFN, 44, "UInt" )    ; StartDir 
	 ,NumPut( &Title,		 OFN, 48, "UInt" )	  ; DlgTitle
	 ,NumPut( hFlags,		 OFN, 52, "UInt" )    ; Flags 
	 ,NumPut( &DefaultExt,	 OFN, 60, "UInt" )    ; DefaultExt 

	res := SubStr(Flags, 1, 1)="S" ? DllCall("comdlg32\GetSaveFileNameA", "Uint", &OFN ) : DllCall("comdlg32\GetOpenFileNameA", "Uint", &OFN )
	IfEqual, res, 0, return

	adr := &FN,  f := d := DllCall("MulDiv", "Int", adr, "Int",1, "Int",1, "str"), res := ""
	if StrLen(d) != 3			;windows adds \ when in root of the drive and doesn't do that otherwise
		d.="\"		
	if ms := InStr(Flags, "ALLOWMULTISELECT")
		loop 
			if f := DllCall("MulDiv", "Int", adr += StrLen(f)+1, "Int",1, "Int",1, "str") 
				res .= d f "`n"
			else {
				 IfEqual, A_Index, 1, SetEnv, res, %d%		;if user selects only 1 file with multiselect flag, windows ignores this flag.... 
				 break
			}
	
	return ms ? SubStr(res, 1, -1) : SubStr(d, 1, -1)
}


Dlg_Save( hGui=0, Title="", Filter="", DefaultFilter="", Root="", DefaultExt="", Flags="" ) {
	return Dlg_Open( hGui, Title, Filter, DefaultFilter, Root, DefaultExt, "S " Flags )
}


;=========================================== PRIVATE ===============================================

Dlg_callback(wparam, lparam, msg, hwnd) {
	static FR_DIALOGTERM = 0x40, FR_DOWN=1, FR_MATCHCASE=4, FR_WHOLEWORD=2, FR_HIDEMATCHCASE=0x8000, FR_HIDEWHOLEWORD=0x10000, FR_HIDEUPDOWN=0x4000, FR_REPLACE=0x10, FR_REPLACEALL=0x20, FR_FINDNEXT=8
	static handler 
	ifEqual, hwnd, ,return handler := wparam
	
	hFlags := NumGet(lparam+12)
	if (hFlags & FR_DIALOGTERM)
		return %handler%("C", "", "", "")

 	flags .= (hFlags & FR_MATCHCASE) && !(hFlags & FR_HIDEMATCHCASE)? "c" :
	flags .= (hFlags & FR_WHOLEWORD) && !(hFlags & FR_HIDEWHOLEWORD)? "w" :
	findText := DllCall("MulDiv", "Int", NumGet(lparam+16), "Int",1, "Int",1, "str")

	if (hFlags & FR_FINDNEXT) {
		flags .= (hFlags & FR_DOWN) && !(hFlags & FR_HIDEUPDOWN) ? "d" :
		return %handler%("F", flags, findText, "")
	}

	if (hFlags & FR_REPLACE) || (hFlags & FR_REPLACEALL) {
		event := (hFlags & FR_REPLACEALL) ? "A" : "R"
		replaceText := DllCall("MulDiv", "Int", NumGet(lparam+20), "Int",1, "Int",1, "str") 
		return %handler%(event, flags, findText, replaceText)
	}
}

/* Group: Examples

	Example1: 
	(start code)

	  ;basic usage

	  if Dlg_Icon(icon, idx := 4) 
		   msgbox Icon:   %icon%`nIndex:  %idx% 

	   if Dlg_Color( color := 0xFF00AA ) 
		  msgbox Color:  %color% 

	   if Dlg_Font( font := "Courier New", style := "s16 bold underline italic", color:=0x80) 
			msgbox Font:  %font%`nStyle:  %style%`nColor:  %color%

	   res := Dlg_Open("", "Select several files", "", "", "c:\Windows\", "", "ALLOWMULTISELECT FILEMUSTEXIST HIDEREADONLY")
	   IfNotEqual, res, , MsgBox, %res%
	return
	(end code)

	Example2:
	(start code)
		;create gui and set text color 

		Dlg_Font( font := "Courier New", style := "s16 bold italic", color:=0xFF) 

		Gui Font, %Style% c%Color%, %Font% 
		Gui, Add, Text, ,Hello world.....  :roll: 
		Gui, Show, Autosize 
	return
	(end code)
 */

/* Group: About
		o Ver 5.02 by majkinetor. See http://www.autohotkey.com/forum/topic17230.html
		o Licenced under BSD <http://creativecommons.org/licenses/BSD/>
 */