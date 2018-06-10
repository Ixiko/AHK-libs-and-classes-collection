/*
stealFunc v0.12
	by Avi Aryan (http://avi.uco.im)
DOC - http://avi.uco.im/ahk/tools/stealfunc.html
steals only the needed functions from a function library or script
EXAMPLE USAGE-
	Clipboard := stealFunc("Gdip_Startup`nGdip_SetBitmaptoClipboard`nGdip_CreateBitmapFromFile`nGdip_DisposeImage`nGdip_Shutdown", "<path_to_gdip_lib>", 1)
Changelog:-
	v0.12
	* added `r to the output
	* little bug fix with block comments
	* fixed bugs with nested functions
	v0.1
	* added option to input script in addition to list
	v0.01
	* init
*/


; gui function is at the very last - remove if not needed
stealFunc_gui()
return


stealFunc(funcs, file, islist=1){
	; islist parameter should be 1 if funcs is a list of functions as in the above example
	; and should be 0 (false) if funcs is a snippet containing a working script.
	; The snippet should be a valid script for which 'stealing' is to be done.

	flist := stealFunc_listfunc(file, z)
	included := " " , stolen := ""

	if !islist
	{
		flines := " " , stealFunc_listfunc(funcs, snippet, flines) 	; get lines having function
		loop, parse, snippet, `n
			if !Instr(flines, " " A_index " ") 		; remove those lines
				snippetN .= A_LoopField "`n"
		snippet := Substr(snippetN, 1, -1)
		stealFunc_extractUsedfunc( stealFunc_compactFile(file), snippet, flist, stolen, included )
	}
	else
		loop, parse, funcs, `n, `r
			stealFunc_extractfunc(z, A_LoopField, flist, stolen, included)
	StringReplace, stolen, stolen, `n, `r`n, All
	return stolen
}

stealFunc_IsDefault(func){ ; not using IsFunc()
	static l := " Abs ACos Asc ASin ATan Ceil Chr Cos DllCall Exception Exp FileExist Floor GetKeyState IL_Add IL_Create IL_Destroy InStr IsFunc IsLabel Ln Log LV_Add "
	. "LV_Delete LV_DeleteCol LV_GetCount LV_GetNext LV_GetText LV_Insert LV_InsertCol LV_Modify LV_ModifyCol LV_SetImageList Mod NumGet NumPut OnMessage RegExMatch "
	. "RegExReplace RegisterCallback Round SB_SetIcon SB_SetParts SB_SetText Sin Sqrt StrLen SubStr Tan TV_Add TV_Delete TV_GetChild TV_GetCount TV_GetNext TV_Get "
	. "TV_GetParent TV_GetPrev TV_GetSelection TV_GetText TV_Modify TV_SetImageList VarSetCapacity WinActive WinExist Trim LTrim RTrim FileOpen StrGet StrPut StrPut "
	. "GetKeyName GetKeyVK GetKeySC IsByRef IsObject ObjInsert ObjInsert ObjInsert ObjRemove ObjMinIndex ObjMaxIndex ObjSetCapacity ObjSetCapacity "
	. "ObjGetCapacity ObjGetAddress ObjNewEnum ObjAddRef ObjRelease ObjHasKey ObjClone "
	return Instr(l, A_Space func A_Space)
}

stealFunc_listfunc(file, byref compactfile="", byref function_lines="")
{
	z := compactfile := stealFunc_compactFile(file)
	z := RegExReplace(z, "mU)""[^`n]*""", "") ; strings
	z := RegExReplace(z, "m);[^`n]*", "")  ; single line comments
	z := RegExReplace(z, "`n( |`t)+", "`n") 	; trim
	z := RegExReplace(z, "if [^`n\)]{", "") 	; remove to not match cases like    	if var = {   -  idea is safe as funcs dont contain spaces
	z := RegExReplace(z, "[^:]=[^`n\)]{", "") 		; var={somethind} - not match obj := {something}
	p:=1 , z := "`n" z
	while q:=RegExMatch(z, "iU)`n[^ `t`n,;``\(\):=\?]+\([^`n]*\)(\s)*\{", o, p)
	{
		if Instr(o, "while(") = 2
		{ ; while is not a func - 2 as while will be after `n
			p := q+Strlen(o)-1
			continue
		}

		str := Substr(z, 1, q) 		; get part before func
		StringReplace, str, str, `n, `n, UseErrorLevel
		start_lineno := ErrorLevel 		; get func start line no
		str := Substr(z, q+1) 		; part after func
		ob := {} , ob["{"] := ob["}"] := 0 	; obj to store {} counts
		loop, parse, str
		{
			if A_LoopField in {,}
			{
				ob[A_LoopField] += 1
				if ob["{"] == ob["}"]
				{
					cp := A_index
					break
				}
			}
		}
		str2 := Substr(str, 1, cp) 		; string containing the function
		cb_pos := Instr(str2, "`n", 0, 0) 		; pos of `n closing the function
		str2 := Substr(str2, 1, cb_pos) 	; string till the linefeed
		StringReplace, str2, str2, `n, `n, UseErrorLevel 		; count `n in string
		end_lineno_rel := ErrorLevel 	; relative ending point
		end_lineno := start_lineno + end_lineno_rel 		; real ending point

		lst .= "`n" Substr( RegExReplace(o, "\(.*", ""), 2) " " start_lineno " " end_lineno
		, p := q+Strlen(o)-1

		function_lines .= start_lineno " " end_lineno " " 		; lines having func decl in the compacted script file
	}
	return lst "`n" 		; append `n to make a systematic strcuture
}

; compacts file - removes comments
; set file as "some text" to make the function take it as file content
stealFunc_compactFile(file){
	if FileExist(file)
		FileRead, z, % file
	else z := file
	StringReplace, z, z, `r, , All
	return z := RegExReplace(z, "iU)`n[ `t]*?/\*.*`n[ `t]*?\*/", "") ; block comments
}

; extracts functions from compact file
stealFunc_extractfunc(compactfile, fname, flist, byref stolen, byref included){
	if (Instr(included, " " fname " ")) or (!Instr(flist, "`n" fname " ")) or (stealFunc_IsDefault(fname))		; if func is added
		return

	coords := Substr(flist, Instr(flist, "`n" fname " ")+1) , coords := Substr(coords, Instr(coords, " ")+1, Instr(coords, "`n")-Instr(coords, " ")-1) 	; get func line nos
	s := Substr(coords, 1, Instr(coords, " ")-1) 	; start line no
	e := Substr(coords, Instr(coords, " ")+1) 	; end line no
	r := Substr(compactfile, sp:=Instr(compactfile, "`n", 0, 1, s-1)+1, Instr(compactfile, "`n", 0, 1, e-1)-sp+2) 	; the func extracted between line numbers
	stolen := stolen "`n" r , included .= fname " "
	; recursive processing
	rs := Substr(r, Instr(r,"`n")+1)
	stealFunc_extractUsedfunc(compactfile, rs, flist, stolen, included)
}

; extracts used functions from a AutoHotkey script snippet
stealFunc_extractUsedfunc(compactfile, snippet, flist, byref stolen, byref included){
	p := 1

	snippet := RegExReplace(snippet, "mU)""[^`n]*""", "") ; strings
	snippet := RegExReplace(snippet, "m);[^`n]*", "")  ; single line comments  -- block comment should be already removed

	while q:=RegExMatch(snippet, "iU)[^ !`t`n,;``\(\):=\?]+\(.*\)", o, p)
	{
		fn := Trim(RegExReplace(o, "\(.*", ""))
		p := q+( Instr(o, "(") ? Instr(o, "(")+1 : Strlen(o) )-1
		if ( fn == "" ) or stealFunc_IsDefault(fn)
			Continue
		stealFunc_extractfunc(compactfile, fn, flist, stolen, included)
	}
}

;-------------------------------- GUI -----------------------------------
; remove if not needed

stealFunc_gui(){
	global gui_list, gui_file, gui_out, gui_islist

	w := A_ScreenWidth / 2
	Gui, stealFunc:new
	Gui, font, s12 Bold
	Gui, Add, Text, x0 y0, StealFunc v0.12
	Gui, font, s10 Normal
	Gui, Add, Text, y+20 x7 w150, List of functions OR`nsnippet to extract for
	Gui, Add, Checkbox, xp yp+60 vgui_islist, Input is List
	Gui, font, s7
	Gui, Add, Edit, % "x167 yp-60 w" w-200 " vgui_list +multi r5",
	Gui, font, s10
	Gui, Add, Text, y+30 x7 w150, Input script file (Drop)
	Gui, Add, Edit, % "x+10 w" w-200 " vgui_file"
	Gui, Add, Text, y+30 x7 w150, Output
	Gui, font, s7
	Gui, Add, Edit, % "x+10 w" w-200 " vgui_out +multi r10"
	Gui, font, s10
	Gui, Add, Button, x7 y+40, Start
	Gui, font, s9, Consolas
	Gui, Show, w%w%, stealFunc
	return

stealFuncGuiClose:
	Exitapp
	return

stealFuncButtonStart:
	Gui, stealFunc:submit, nohide
	if FileExist(gui_file)
	{
		gui_out := stealFunc(gui_list, gui_file, gui_islist)
		GuiControl, stealFunc:, gui_out, % gui_out
	}
	else Msgbox, Enter a valid script file path
	return

stealFuncGuiDropFiles:
	loop, parse, A_GuiEvent, `n
	{
		file := A_loopfield
		break
	}
	GuiControl, stealFunc:, gui_file, % file
	return


}