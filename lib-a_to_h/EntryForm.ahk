/* Function: EntryForm
 *     Create custom InputBox, data entry forms
 * License: WTFPL (http://www.wtfpl.net/)
 * AutoHotkey Version: AHK v1.1+ OR v2.0-a049+
 * Syntax:
 *     ef := EntryForm( form, fields* )
 * Return Value:
 *     ef := {
 *         "event":  [ OK, Cancel, Close, Escape, Timeout ],
 *         "output": [ field1, field2 ... ]
 *     }
 * Parameter(s):
 *     form               [in] - EntryForm window options
 *     fields*  [in, variadic] - Input field's options
 * Parameter(s) Details:
 *     Space-delimited string contianing one or more of the following
 *     options + argument(s). Arguments are passed in command line-like syntax.
 *     Arguments containing spaces must be enclosed in single quotes. Multiple
 *     arguments are separated by a comma.
 * Form parameter options:
 *     -cap | -c <caption>                 - window title/caption
 *     -fnt | -f <options,name>            - window font
 *     -ico | -i <icon,icon-no>            - window icon
 *     -t <timeout> OR Tn                  - timeout in milliseconds
 *     -F <function> OR Ffunction          - callback function
 *     -pos | -p <pos> OR [Xn, Yn, Wn]     - window position when shown
 *     -opt | -o <options> OR [options...] - standard GUI options
 * Fields* parameter options:
 *     -p <prompt>                         - prompt
 *     -d <default>                        - default text
 *     -fnt <options,name;options,name>    - font, [prompt-font;input-font]
 *     -in <input_ctrl> OR *INPUT_CTRL     - input field control type
 *     -cb <cuebanner>                     - cuebanner
 *     -tt <tooltip>                       - field tooltip
 *     -ud <updown-ctrl-options>           - attaches an UpDown control
 *     -fs <fileselect-args>               - browse file(s) button
 *     -ds <dirselect-args>                - browse folder button
 *     -opt | -o <options> OR [options...] - standard Edit control options
 * Link(s):
 *     Forum post  (http://ahkscript.org/boards/viewtopic.php?f=6&t=4559)
 *     GitHub repo (https://github.com/cocobelgica/AutoHotkey-EntryForm)
 */
EntryForm(form, fields*) {
	;// assume static mode for GUI controls variable(s)
	static

	;// During script's exit, __Delete is invoked to release resources used
	;   by the function such as image list(s), etc.
	static ef := { "__Delete": Func("EntryForm") }
	     , _  := new ef ;// static vars are released alphabetically

	;// Misc variables
	static is_v2 := A_AhkVersion >= "2"
	     , is_xp := ( is_v2 ? (A_OSVersion < "6") : (A_OSVersion == "WIN_XP") )
	     , end   := ( is_v2 ? -1 : 0 )

	;// Object built-in functions (v1.1 and v2.0-a049 compatibility)
	static del  := Func( is_v2 ? "ObjRemoveAt" : "ObjRemove" )
	     , push := Func( is_v2 ? "ObjPush"     : "ObjInsert" )

	static args := { "c":"caption", "f":"font", "fnt":"font", "i":"icon"
	               , "p":"pos", "t":"timeout", "o":"options"
	               ;// fields* parameter options
	               , "-p":"prompt", "-d":"default", "-fnt":"font", "-in":"input"
	               , "-cb":"cue", "-cue":"cue", "-fs":"file", "-ds":"dir", "-tt":"tip"
	               , "-ud":"updown", "-o":"options", "-opt":"options" }
	     , delims := [ " ", ":", "`t", "`r", "`n" ]

	;// for DllCall()
	static ExtractIconEx := "shell32\ExtractIconEx" . (A_IsUnicode ? "W" : "A")
	     , GetWindowLong := A_Is64bitOS ? "GetWindowLongPtr" : "GetWindowLong"

	;// Control types for input field(s)
	static input_ctrls := { "E":"Edit", "CB":"ComboBox", "DDL":"DDL", "LB":"ListBox", "DT":"DateTime" }

	static btn_size := 0, himl := 0
	     ; , ndl := ( is_v2 ? "i)" : "Oi)" ) . "(?<=^|,)\s*\K.*?(?=(?<!\\),|$)" ;// not used

	;// Constants for TOOLINFO & OPENFILENAME structs
	static TTM_ADDTOOL     := A_IsUnicode ? 0x0432 : 0x0404
	     , sizeof_TOOLINFO := 24 + (6 * A_PtrSize)
	     , sizeof_OFN      := 36 + (13 * A_PtrSize)

	;// static variable(s) for EF_SelectFile subroutine
	;   1 = OFN_FILEMUSTEXIST, 2 = OFN_PATHMUSTEXIST, 8 = OFN_CREATEPROMPT
	;   16 = OFN_OVERWRITEPROMPT, 32 = OFN_NODEREFERENCELINKS
	static fs_flags := { 1: 0x1000, 2: 0x800, 8: 0x2000, 16: 0x2, 32: 0x100000 }

	;// static variable(s) for EF_SelectDir subroutine
	;   BIF_NONEWFOLDERBUTTON = 0x200, BIF_NEWDIALOGSTYLE = 0x40
	;   BIF_EDITBOX = 0x10, BIF_USENEWUI = 0x10|0x40
	;   0 = 0x200, 1 = 0x40, 2 = 0x200|0x10, 3 = 0x40|0x10, 4 and 5 = ??
	static ds_flags := { 0: 0x200, 1: 0x40, 2: 0x210, 3: 0x50, 4: 0x200, 5: 0x200 }
	     , shell    := 0 ;// ComObjCreate("Shell.Application") -> just set if used/needed

	;// Used for EntryForm(s) with defined callback function
	static cb_forms := {}

	;// local variables (main function body)
	local s_opt, quoted, opt, i, j, str, key, hForm, hIconL := hIconS := 0
	    , RECT, width, idx, field, ctrl, font, is_input, ftype, hPrompt, hInput
	    , is_mline, input_pos, btn, wd, hBtn, vBtn, BTN_IMGLIST, btns := {}, ii
	    , jj, b_arg, k, dhw, flds := [], callback := 0, ret

	;// local variables for EF_SelectFile subroutine(local label)
	;   opt, i, is_mline -> declared above
	local dlg_args, prompt, filter, lpstrFile, init_dir, init_file, flags, flag
	    , lpstrFilter, ext, flen1, flen2, OPENFILENAME, addr, sel, dir, files

	;// local variables for EF_SelectDir subroutine(local label)
	;   dlg_args, prompt, init_dir, flags, flag -> declared above
	local folder

	;// local variables for EF_SetToolTip subroutine(local label)
	local tt := {}, hTip := 0, tt_tmp


	;// __Delete - This routine is called during script script's exit
	if (form.base == ef)
	{
		if himl
			IL_Destroy(himl.file), IL_Destroy(himl.dir)
		return
	}

	;// ROUTINE STARTS HERE
	;   Extract quoted strings from params to make parsing easier
	s_opt := [], quoted := []
	for i, opt in [form, fields*]
	{
		if IsObject(opt)
			continue
		i := 0 ;// just recycle variable above, not so sure about side effects
		while ( i := InStr(opt, "'",, i+1) ) {
			j := i
			while ( j := InStr(opt, "'",, j+1) ) {
				str := SubStr(opt, i+1, j-i-1)
				if ( SubStr(str, end) != "\" )
					break
			}
			opt := SubStr(opt, 1, i) . SubStr(opt, j+1)
			%push%(quoted, str)
		}
		%push%(s_opt, opt)
	}

	if !IsObject(form)
	{
		form := {}, key := ""
		for i, opt in StrSplit( %del%(s_opt, 1), delims )
		{
			if (opt == "")
				continue

			if (opt ~= "^-(f|(?i)[cipto]|cap|fnt|ico|pos|to|opt)$")
				form[ key := args[SubStr(opt, 2, 1)] ] := ""

			else if (opt == "-F") ;// case-sensitive
				form[ key := "callback" ] := ""

			else if ( opt ~= (is_v2? "i)^f[a-z_]\w*$" : "i)^f[a-z0-9_@]+$") )
				form.callback := Func(SubStr(opt, 2))

			else if (opt == "'")
				form[key] := %del%(quoted, 1), key := ""

			else if (opt ~= "i)^[xyw](\d+|Center)$")
				form.pos .= " " . opt

			else if (opt ~= "i)^t\d+$")
				form.timeout := SubStr(opt, 2) + 0

			else
				key? ( form[key] := opt, key := "" ) : form.options .= " " . opt
		}
	}

	;// Create EntryForm window
	Gui New, % "+HwndhForm +LabelEF_ " . form.options

	;// Initialize font, InputBox uses 's10, MS Shell Dlg 2' on OS >= WIN_7??
	form.font := form.HasKey("font") ? StrSplit(form.font, ",", " `t`r`n")
	                                 : ["s10", "MS Shell Dlg 2"]
	Gui Font, % form.font[1], % form.font[2]
	Gui Margin, 10, 10

	;// Initialize window position
	if !InStr(form.pos, "w")
		form.pos .= " w375"    ;// same default width as InputBox
	if !InStr(form.pos, "x")
		form.pos .= " xCenter"
	if !InStr(form.pos, "y")
		form.pos .= " yCenter"

	;// Show hidden
	Gui Show, % "Hide " form.pos, % form.caption

	;// Set window icon if specified
	;   Small icon for the caption | large icon for Alt+Tab and taskbar(v2 only??)
	if form.HasKey("icon")
	{
		form.icon := StrSplit(form.icon, ",", " `t`r`n")
		DllCall(ExtractIconEx, "Str", form.icon[1], "Int", form.icon[2] + 0
		      , "UIntP", hIconL, "UIntP", hIconS, "UInt", 2)

		;// WM_SETICON = 0x0080
		DllCall("SendMessage", "Ptr", hForm, "Int", 0x0080, "Ptr", 0, "Ptr", hIconS)
		DllCall("SendMessage", "Ptr", hForm, "Int", 0x0080, "Ptr", 1, "Ptr", hIconL)
	}

	;// Get GUI width-(left+right) margin, controls are confined within this width
	VarSetCapacity(RECT, 16, 0)
	, DllCall("GetClientRect", "Ptr", hForm, "Ptr", &RECT)
	, width := NumGet(RECT, 8, "UInt")-20

	;// Add the EntryForm fields
	for idx, field in fields
	{
		;// Parse arguments/options
		if !IsObject(field)
		{
			field := {}, key := ""
			for i, opt in StrSplit( %del%(s_opt, 1), delims )
			{
				if (opt == "")
					continue

				if (opt ~= "^-([pdo]|fnt|in|cb|[fd]s|tt|ud|opt)$")
					field[ key := args[opt] ] := ""

				else if (opt == "'")
					field[key] := %del%(quoted, 1), key := ""

				else if (opt ~= "i)^\*(E|CB|DDL|LB|DT)$")
					field.input := SubStr(opt, 2)

				else
					key? ( field[key] := opt, key := "" ) : field.options .= " " . opt
			}
		}

		;// Input field control type, defaults to Edit(E). The ff are allowed:
		;   ComboBox(CB), DropDownList(DDL), ListBox(LB), DateTime(DT)
		ctrl := input_ctrls[ field.HasKey("input") ? field.input : "E" ]

		;// Set font
		if field.HasKey("font")
		{
			field.font := StrSplit(field.font, ";", " `t`r`n")
			if ( (font := %del%(field.font, 1)) != "" )
				field.font.prompt := StrSplit(font, ",", " `t`r`n")
			if ( (font := %del%(field.font, 1)) != "" )
				field.font.input := StrSplit(font, ",", " `t`r`n")
		}

		for is_input, ftype in { 0: "prompt", 1: "input" }
		{
			if ( font := field.font[ftype] ) {
				Gui Font
				Gui Font, % font[1], % font[2]
			}

			Gui Add, % is_input ? ctrl : "Text"
			       , % "xm w" width " Hwndh" ftype . ( is_input
			         ? " y+5 " field.options
			         : " Wrap y" ( idx == 1 ? 10 : input_posY+input_posH+10 ) )
			       , % field[ is_input ? "default" : "prompt" ]

			if !font
				continue

			Gui Font
			Gui Font, % form.font[1], % form.font[2]
		}

		flds[idx] := hInput
		GuiControlGet input_pos, Pos, %hInput%

		;// ToolTip
		if field.HasKey("tip")
		{
			tt.ctrl := hInput, tt.text := field.tip
			gosub EF_SetToolTip
		}

		if (ctrl != "Edit") ;// skip rest of loop for other control types
			continue

		;// ES_MULTILINE := 0x0004
		is_mline := DllCall(GetWindowLong, "Ptr", hInput, "Int", -16, "Ptr") & 0x0004

		;// Cue banner | EM_SETCUEBANNER = 0x1501
		if field.HasKey("cue")
			SendMessage 0x1501, 0, % ObjGetAddress(field, "cue"),, ahk_id %hInput%

		;// Buddy UpDown control
		if field.HasKey("updown")
			Gui Add, Updown, % field.updown

		;// Add browse file AND/OR folder buttons if specified
		j := 0
		for i, btn in ["file", "dir"]
		{
			if !field.HasKey(btn)
				continue

			;// Get default button size based on system's default font
			if !btn_size ;// static variable
			{
				Gui New
				; Gui Font, s10, MS Shell Dlg 2 ;// Used by InputBox??
				Gui Add, Button, r1
				GuiControlGet, btn_size, Pos, Button1
				Gui Destroy
				btn_size := btn_sizeH
				Gui %hForm%:Default
			}

			j += 1
			GuiControl, Move, %hInput%, % "w" wd := width - ( (btn_size + 3) * (is_mline? 1 : j) )
			; GuiControlGet input_pos, Pos, %hInput%
			if (j > 1)
				GuiControl Move, %hBtn%, % "x" wd + 13 ;// 13 = margin + padding
			Gui Add, Button, % "w" btn_size " h" btn_size
			                 . " y" ( j > 1 && is_mline ? "+3" : input_posY )
			                 . " xm+" width - btn_size
			                 . " HwndhBtn gEF_Select" btn
			GuiControl % "+v" ( vBtn := "ef_btn_" . hBtn ), %hBtn%

			/*
			Create BUTTON_IMAGELIST structure -> http://goo.gl/RVQsnM
			typedef struct {
			    HIMAGELIST himl;
			    RECT       margin;
			    UINT       uAlign;
			} BUTTON_IMAGELIST, *PBUTTON_IMAGELIST;
			sizeof BUTTON_IMAGELIST = Ptr(A_PtrSize) + RECT(16) + UInt(4)
			*/
			VarSetCapacity(BTN_IMGLIST, A_PtrSize + 20, 0)

			;// Image list for select file/folder buttons
			if !himl
			{
				himl := { "file": IL_Create(1, 5), "dir": IL_Create(1, 5) }
				, IL_Add(himl.file, "shell32.dll", 56)  ;// 56  = 1-based index
				, IL_Add(himl.dir, "imageres.dll", 205) ;// 205 = 1-based index
			}

			;// Set himl member of struct
			NumPut(himl[btn], BTN_IMGLIST, 0, "Ptr")

			;// Set margin member | 1px??
			Loop 4
				NumPut(1, BTN_IMGLIST, A_PtrSize+A_Index*4-4, "UInt")

			;// Set uAlign member | BUTTON_IMAGELIST_ALIGN_CENTER := 4
			NumPut(4, BTN_IMGLIST, A_PtrSize+16, "UInt")

			;// BCM_SETIMAGELIST = 0x1602
			SendMessage 0x1602, 0, % &BTN_IMGLIST,, ahk_id %hBtn%

			btns[vBtn] := { "input": hInput, "args": [] }

			;// Parse option arguments, comma-delimited
			ii := jj := 0
			while (ii := InStr(field[btn] . ",", ",",, ii+1))
			{
				b_arg := SubStr(field[btn], jj+1, ii-jj-1)
				k := -1
				while (k := InStr(b_arg, "\,",, k+2))
					b_arg := SubStr(b_arg, 1, k-1) . SubStr(b_arg, k+1)
				if (SubStr(b_arg, end) != "\")
					%push%(btns[vBtn].args, b_arg), jj := ii
			}

			tt.ctrl := hBtn, tt.text := "Browse " . (btn != "file" ? "folder" : btn)
			gosub EF_SetToolTip
		}

	}

	;// Add OK and Cancel buttons
	Gui Add, Button, % "w100 r1 gEF_OK xm+" (width/2)-110 " y" input_posY + input_posH + 20, OK
	Gui Add, Button, x+20 yp wp hp gEF_Cancel, Cancel

	;// Show the EntryForm and wait for it to close / gets destroyed
	Gui Show, % "AutoSize " form.pos, % form.caption

	;// Caller has defined a callback function
	;   However, if Tn(timeout) is specified, callback function is ignored
	if ( form.timeout ? 0 : form.callback )
	{
		;// Store some values needed by Gui/GuiControl event(s) routine
		;   v1.1+: GUI handles(+HwndhGui) are stored as string(hex format),
		;   convert to integer for consistency with v2.0-a050+
		cb_forms[hForm+0] := { "callback": form.callback, "flds": flds, "hTip": hTip
		                     , "hIconS": hIconS, "hIconL": hIconL, "btns": btns }

		;// return, on event, the callback function is called passing the
		;   output as the first parameter.
		return true
	}

	dhw := A_DetectHiddenWindows
	DetectHiddenWindows On
	WinWaitClose ahk_id %hForm%,, % form.timeout/1000
	if ErrorLevel
		gosub EF_Timeout ;// WinClose ahk_id %hForm% -> triggers EF_CLose
	DetectHiddenWindows %dhw%

	;// { "event": [ OK, Cancel, Close, Escape, Timeout ], "output": [ field1, field2 ... ] }
	return ret

/* Event handlers and helper subroutines
*/
EF_OK:
EF_Cancel:
EF_Close:
EF_Escape:
	if ( callback := cb_forms.HasKey(hForm := A_Gui+0) ) ;// Regardless of AHK version, A_Gui is in hex format
		callback := cb_forms[hForm].callback
		, flds   := cb_forms[hForm].flds
		, hTip   := cb_forms[hForm].hTip
		, hIconS := cb_forms[hForm].hIconS
		, hIconL := cb_forms[hForm].hIconL
		;// Make sure remaining integer keys are not affected/adjusted
		;   v2.0-a049+: ObjRemove does not affect remaining integer keys
		, ObjRemove( cb_forms, ( is_v2? [hForm] : [hForm, ""] )* )

EF_Timeout:
	ret := { "event": SubStr(A_ThisLabel, 4), "output": [] } ;// return value
	for i, hInput in flds
	{
		GuiControlGet text,, %hInput%
		ret.output[A_Index] := text
	}
	if ( NumGet( &(ret.output) + 4*A_PtrSize ) <= 1 ) ;// ObjCount()
		ret.output := ret.output[1]

	;// Destroy tooltip
	if hTip
		DllCall("DestroyWindow", "Ptr", hTip)

	Gui Destroy

	;// Destroy window icon(s) (if any)
	if hIconL
		DllCall("DestroyIcon", "Ptr", hIconL)
	if hIconS
		DllCall("DestroyIcon", "Ptr", hIconS)

	if callback
		%callback%(ret) ;// call the callback function and pass output

	return

/* FileSelectFile(v1.1) / FileSelect(v2.0-a) workaround
 */
EF_SelectFile: ;// [Options, RootDir\Filename, Prompt, Filter]
	if cb_forms.HasKey(A_Gui + 0)
		btns := cb_forms[A_Gui + 0].btns
	hInput     := btns[A_GuiControl].input ;// handle of asscoiated Edit control
	, dlg_args := btns[A_GuiControl].args
	, opt      := dlg_args[1]
	if ( (prompt := dlg_args[3]) == "" )
		prompt := "Select File - " . A_ScriptName
	if ( (filter := dlg_args[4]) == "" )
		filter := "All Files (*.*)"

	;// Initialize lpstrFile, output goes here
	VarSetCapacity(lpstrFile, 0xffff)

	;// Get initial dir and/or initial file name
	GuiControlGet init_dir,, %hInput%
	if (init_dir == "")
		init_dir := dlg_args[2]
	if !InStr(FileExist(init_dir), "D")
	{
		init_file := is_v2 ? init_dir : "init_dir"
		SplitPath %init_file%, init_file, init_dir
		if (init_file != "")
			StrPut(init_file, &lpstrFile + 0), init_file := ""
	}

	;// Flags member of OPENFILENAME struct
	flags := 0x80000|0x4 ;// OFN_EXPLORER|OFN_HIDEREADONLY
	flag  := SubStr(opt, InStr( "MS", SubStr(opt, 1, 1) ) ? 2 : 1) + 0
	for i in flag ? fs_flags : 0
		if (flag & i)
			flags |= fs_flags[i]

	if InStr(opt, "M")
		flags |= 0x200 ;// OFN_ALLOWMULTISELECT = 0x200

	;// Setup lpstrFilter member of OPENFILENAME struct
	VarSetCapacity( lpstrFilter, 2*StrLen(filter) * (A_IsUnicode ? 2 : 1), 0 )
	, ext   := SubStr(filter, InStr( filter,"(" )+1, -1)
	, flen1 := (StrLen(filter) + 1) * (A_IsUnicode ? 2 : 1)
	, flen2 := (StrLen(ext) + 1) * (A_IsUnicode ? 2 : 1)
	, StrPut(filter, &lpstrFilter + 0, flen1)
	, StrPut(ext, &lpstrFilter + flen1, flen2)
	, NumPut(0, lpstrFilter, flen1 + flen2, A_IsUnicode ? "UShort" : "UChar")

	;// Create OPENFILENAME struct and set members
	VarSetCapacity(OPENFILENAME, sizeof_OFN, 0)
	, NumPut(sizeof_OFN,   OPENFILENAME, 0,                "UInt") ;// lStructSize
	, NumPut(A_Gui,        OPENFILENAME, 4,                "Ptr")  ;// hwndOwner
	, NumPut(&lpstrFilter, OPENFILENAME, 4 + 2*A_PtrSize,  "Ptr")  ;// lpstrFilter
	, NumPut(1,            OPENFILENAME, 8 + 4*A_PtrSize,  "UInt") ;// nFilterIndex
	, NumPut(&lpstrFile,   OPENFILENAME, 12 + 4*A_PtrSize, "Ptr")  ;// lpstrFile
	, NumPut(0xffff,       OPENFILENAME, 12 + 5*A_PtrSize, "UInt") ;// nMaxFile
	, NumPut(&init_dir,    OPENFILENAME, 20 + 6*A_PtrSize, "Ptr")  ;// lpstrInitialDir
	, NumPut(&prompt,      OPENFILENAME, 20 + 7*A_PtrSize, "Ptr")  ;// lpstrTitle
	, NumPut(flags,        OPENFILENAME, 20 + 8*A_PtrSize, "UInt") ;// Flags

	;// GetFileName := "comdlg32\" . ( InStr(opt, "S") ? "GetSaveFileName" : "GetOpenFileName" )
	if !DllCall("comdlg32\" . ( InStr(opt, "S") ? "GetSaveFileName" : "GetOpenFileName" ), "Ptr", &OPENFILENAME)
		return

	;// Extract selected file name(s) from buffer
	;   dir := DllCall("MulDiv", "Int", &lpstrFile, "Int", 1, "Int", 1, "Str")
	addr := &lpstrFile, sel := dir := StrGet(addr), files := "" ;// initialize blank
	if ( StrLen(dir) != 3 )
		dir .= "\"
	if (flags & 0x200) ;// OFN_ALLOWMULTISELECT
		while (sel := StrGet( addr += (StrLen(sel) + 1) * (A_IsUnicode ? 2 : 1) ))
			files .= dir . sel . "`n"

	GuiControl,, %hInput%, % SubStr(files ? files : dir, 1, -1)
	return

/* FileSelectFolder(v1.1) / DirSelect(v2.0-a) workaround
 */
EF_SelectDir: ;// [StartingFolder, Options, Prompt]
	if cb_forms.HasKey(A_Gui + 0)
		btns := cb_forms[A_Gui + 0].btns
	hInput     := btns[A_GuiControl].input
	, dlg_args := btns[A_GuiControl].args
	if ( (prompt := dlg_args[3]) == "" )
		prompt := "Select Folder - " . A_ScriptName

	flags := 0x1 ;// BIF_RETURNONLYFSDIRS = 0x1
	if ( (flag := ds_flags[dlg_args[2] + 0]) != "" )
		flags |= flag

	;// Get starting folder
	GuiControlGet init_dir,, %hInput%
	if !InStr(FileExist(init_dir), "D")
		if ( (init_dir := dlg_args[1]) == "" )
			init_dir := "*" . A_MyDocuments

	if !shell ;// this is a static variable, we don't initialize it unless needed
		shell := ComObjCreate("Shell.Application")
	if !( folder := shell.BrowseForFolder(A_Gui + 0, prompt, flags, init_dir) )
		return

	GuiControl,, %hInput%, % folder.self.Path
	return

/* Create/attach tooltip routine
 */
EF_SetToolTip:
	if !NumGet( &tt + 4 * A_PtrSize ) ;// no arguments
		return

	if !hTip ;// this is a static variable
	{
		;// WS_EX_TOPMOST = 0x8, CW_USEDEFAULT = 0x80000000
		hTip := DllCall("CreateWindowEx", "UInt", 0x8, "Str", "tooltips_class32"
		     ,  "Ptr", 0, "UInt", 0x80000002 ;// WS_POPUP:=0x80000000|TTS_NOPREFIX:=0x02
		     ,  "Int", 0x80000000, "Int",  0x80000000, "Int", 0x80000000, "Int", 0x80000000
		     ,  "Ptr", hForm, "Ptr", 0, "Ptr", 0, "Ptr", 0, "Ptr")

		;// TTM_SETMAXTIPWIDTH = 0x0418
		DllCall("SendMessage", "Ptr", hTip, "Int", 0x0418, "Ptr", 0, "Ptr", 0)

		;// for Windows XP issues
		if is_xp
		{
			tt_tmp := tt, tt := { "ctrl": hForm, "text": "" }
			gosub EF_SetToolTip ;// attach empty tip to GUI
			tt := tt_tmp, tt_tmp := ""
		}
	}

	;// Create TOOLINFO struct and set members
	VarSetCapacity(TOOLINFO, sizeof_TOOLINFO, 0)
	, NumPut(sizeof_TOOLINFO, TOOLINFO, 0, "UInt")
	, NumPut(0x11, TOOLINFO, 4, "UInt") ;// TTF_IDISHWND:=0x0001|TTF_SUBCLASS:=0x0010
	, NumPut(hForm, TOOLINFO, 8, "Ptr")
	, NumPut(tt.ctrl, TOOLINFO, 8 + A_PtrSize, "Ptr")
	, NumPut(ObjGetAddress(tt, "text"), TOOLINFO, 24 + (3 * A_PtrSize), "Ptr")

	;// TTM_ADDTOOL := A_IsUnicode ? 0x0432 : 0x0404
	DllCall("SendMessage", "Ptr", hTip, "Int", TTM_ADDTOOL, "Ptr", 0, "Ptr", &TOOLINFO)
	tt := {}
	return
}