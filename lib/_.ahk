/* Title:	_
			Useful stdlib functions.
 */

/*	
	Function:	_
				StdLib loader and script initializer.
	
	Parameters:
				opt	- Space separated list of script options.
	
	Options:
				m	- Affects how <m> function works: mm makes it use MsgBox (default), mo OutputDebug, m alone disables it.
					  Anything else will use FileAppend; for instance mout.txt! writes to out.txt file. ! at the end is optional and if present
					  it will mark the file for deletition on scripts startup. ! can also be used with o mode to clear the DebugView log.
					  DebugView will be started if it doesn't run, make sure its on the system PATH (there will be no error message if Run fails).
				d	- Detect hidden windows.
				e	- Escape exits the script. Use ea to exit the script only if its window is active.
				wd	- SetWorkingDir %A_ScriptDir%
				wN	- SetWinDelay. If N is omitted, it defaults to -1.
				cN	- SetControlDelay. If N is omitted, it defaults to -1.
				sN	- Speed, always active, defaults to -1
				t?	- Title match mode: t1 (or ts), t2 (or tc), t3 (or te), tr (regular expression).

	Example:	
		(start code)
			_("s100 d e")	;set speed to 100ms, detect hiden windows, exit on ESC.
			_("mo wd tc)	;set m to use OutputDebug, set working directory to A_ScriptDir, set title match mode to c (c=2="contain").
			_("mout.txt!")	;set m to use File out.txt and to clear it each time script is started.
	
		
			_("m")			;disable m for the script
			....
			m( x, y )	    ;will not trigger
			...
			if x = 1
				_("mm")		;enable m after this point and use msgbox.
				....
				m(x, y)		;will trigger	
				...
				_("m")		;disable it again
		(end code)

	Remarks:
				Includes #NoEnv and #SingleInstance force always.
				Registers global variable _ to contain A_Space.
 */

_(opt="") {
	global _
	_ := A_Space

	#NoEnv
	#Singleinstance, force

	s := -1
	loop, parse, opt, %A_Space%
		f := SubStr(A_LoopField,1,1), %f% := SubStr(A_LoopField, 2), %f% .= %f% = "" ? 1 : ""

	ifEqual, w, 1, SetEnv, w, -1
	ifEqual, c, 1, SetEnv, w, -1

	ifEqual, d, 1, DetectHiddenWindows, on
	ifEqual, w, d, SetWorkingDir %A_ScriptDir%
	SetBatchLines, %s%
	ifNotEqual, w,,SetWinDelay, %w%
	ifNotEqual, c,,SetControlDelay, %c%

	if m != 
	{
		if SubStr(m,0) = "!" {
			m := SubStr(m, 1, -1)
			if m = o
				 bClear := true
			else FileDelete, %m%
		}

		if (m="o") {
			if !WinExist("ahk_class dbgviewClass")
				 Run, DbgView.exe,, UseErrorLevel, PID
			else WinRestore, ahk_class dbgviewClass
			ifNotEqual, PID,, WinWaitActive, ahk_pid %PID%
			if bClear
				ControlSend, , ^x, ahk_class dbgviewClass
		} 

		m("~`a" (m = 1 ? "" : m))
	}

	if e 
	{
		Process, Exist
		ifEqual, e, a, Hotkey, IfWinActive, ahk_pid %ErrorLevel%
		HotKey, Esc, __HotkeyEsc
		ifEqual, e, a, Hotkey, IfWinActive
	}

	if t !=
	{	
		ts := 1, tc := 2, te := 3, tr := "RegEx"
		if t not in 1,2,3
			t := t%t%

		SetTitleMatchMode, %t%
	}
}

__HotkeyEsc:
	WinMinimize, ahk_class dbgviewClass
	Sleep 100
	ExitApp
return
	
/*	
	Function: m
			  Debug function.
	
	Parameters:
			  o1..o8	- Arguments to display.
	
	Remarks:
			  m can use MsgBox (m mode), OutputDebug (o mode) or FileAppend to write messages. See <_> function for details.
			  In o mode, all arguments will be joined in single line.

	Returns: 
			  o1.

	Examples:
	>		 if (x - m(y) = z)	; Use m inside expressions for debugging.			
*/
m(o1="~`a", o2="~`a", o3="~`a", o4="~`a", o5="~`a", o6="~`a", o7="~`a", o8="~`a") {
	static mode="m"
	if InStr(o1, "~`a")
		return mode := SubStr(o1, 3)
	ifEqual, mode,,return o1

	loop, 8
		ifEqual, o%A_Index%,~`a,break
		else s .= "'" o%A_Index% "'"  (mode="o" ? " " : "`n")

	if mode=m
			MsgBox %s%
	else if mode=o
			OutputDebug %s%
	else	FileAppend, %s%, %mode%

	return o1
}

/*
	Function: S
			  Struct function. With S, you define structure, then you can put or get values from it.
			  It also allows you to create your own library of structures that can be included at the start of the program.
	
	Define:
			  S	- Struct definition. First word is struct name followed by : and a space, followed by space separated list of field definitions.
				   Field definition consists of field *name*, optionally followed by = sign and decimal number representation of *offset* and *type*. 
				   For instance, "left=4.1" means that field name is "left", field offset is 4 bytes and field type is 1 (UChar). 
				   You can omit field decimal in which case "Uint" is used as default type and offset is calculated from previous one (or it defaults to 0 if it is first field in the list).
				   Precede type number with 0 to make it *signed type* or with 00 to make it *Float* or *Double*. For instance, .01 is "Char" and .004 is Float. 
				   S will calculate the size of the struct for you based on the input fields. If you don't define entire struct (its perfectly valid to declare only parts of the struct you are interested in)
				   you can still define struct size by including = and *size* after structs name. This allows you to use ! mode later.

	Define Syntax:
 >			pQ		 :: StructName[=[Size]]: FieldDef1 FieldDef2 ... FieldDefN	
 >			FieldDef :: FieldName[=[Def]
 >			Def		 :: offset.[0][0]Type
 >			Type	 :: [0]1 | [0]2 | [0]4 | [0]8 | 004 | 008

	Put & Get:
			  S		 - Pointer to struct data.
			  pQ	 - Query parameter. First word is struct name followed by the *mode char* and a space, followed by the space separated list of field names.
					   If the first char after struct name is "<" or ")" function will work in Put mode, if char is ">" or ")" it works in "Get" mode.
					   If char is "!" function works in IPut mode (Initialize & Put). For ! to work, you must define entire struct, not just part of it.
					   The difference between < and ( is that < works on binary data contained in S, while ( works on binary data pointed to by S. 
					   The same difference applies to > and ) modes.

			  o1..o8 - Reference to output variables (Get) or input variables (Put)

	Put & Get Syntax:
 >			pQ :: StructName[>)<(!]: FieldName1 FieldName2 ... FieldNameN

	Returns:
			 o In Define mode function returns struct size.
			 o In Get/Put mode function returns o1.

			 Otherwise the result contains description of the error.
	
	Examples:
	(start code)
	Define Examples:
			S("RECT=16: left=0.4 top=4.4 right=8.4 bottom=12.4")		;Define RECT explicitly.
			S("RECT: left top right bottom")	; Define RECT struct with auto struct size and auto offset increment. Returns 16. The same as above.
			S("RECT: right=8 bottom")			; Define only 2 fields of RECT struct. Since the fields are last one, ! can be used afterwards. Returns 16.
			S("RECT: top=4)					    ; Defines only 1 field of the RECT. Returns 8, so ! can't be used.
			S("RECT=16: top=4)					; Defines only 1 field of the RECT and overrides size. Returns 16, so ! can be used.
			S("R: x=.1 y=.02 k z=28.004")		; Define R, size don't care. R.x is UChar at 0, R.y is Short at 1, R.k is Uint at 3 and  R.z is Float at 28.
			S("R=48: x=.1 y=.02 k z=28.004")	; Override struct size. Returns user size (48 in this case).
												;  This is not the same as above as it states that z is not the last field of the R struct and that actual size is 48.
			
	Get & Put Examples:
			S(b, "RECT< left right", x,y)		; b.left := x, b.right := y (b must be initialized)
			S(b, "RECT> left right", x,y)		; x := b.left, y := b.right
			S(b, "RECT! left right", x,y)		; VarSetCapacity(b, SizeOf(RECT)), b.left = x, b.right=y
			S(b:=&buf,"RECT) left right", x,y)	; *b.left = x, *b.right=y
			S(b:=&buf,"RECT( left right", x,y)	; x := *b.left , y := *b.right
	(end code)
 */
S(ByRef S,pQ,ByRef o1="~`a ",ByRef o2="",ByRef o3="",ByRef  o4="",ByRef o5="",ByRef  o6="",ByRef o7="",ByRef  o8=""){
	static
	static 1="UChar", 2="UShort", 4="Uint", 004="Float", 8="Uint64", 008="Double", 01="Char", 02="Short", 04="Int", 08="Int64"
	local last_offset:=-4, last_type := 4, i, j, R

	if (o1 = "~`a ")
	{		
		j := InStr(pQ, ":"), R := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+2)
		if i := InStr(R, "=")
			_ := SubStr(R, 1, i-1), _%_% := SubStr(R, i+1, j-i), R:=_		

		IfEqual, R,, return A_ThisFunc "> Struct name can't be empty"
		loop, parse, pQ, %A_Space%, %A_Space%
		{
			j := InStr(A_LoopField, "=")
			If j
				 field := SubStr(A_LoopField, 1, j-1), offset := SubStr(A_LoopField, j+1)
			else field := A_LoopField, offset := last_offset + last_type 

			d := InStr(offset, ".")
			if d
				 type := SubStr(offset, d+1), offset := SubStr(offset, 1, d-1)
			else type := 4
			IfEqual, offset, , SetEnv, offset, % last_offset + last_type

			%R%_%field% := offset "." type,  last_offset := offset,  last_type := type
		}
		return _%R%!="" ? _%R% : _%R% := last_offset + last_type
	}
	j := InStr(pQ, A_Space)-1,  i := SubStr(pQ, j, 1), R := SubStr(pQ, 1, j-1), pQ := SubStr(pQ, j+2)
	IfEqual, R,, return A_ThisFunc "> Struct name can't be empty"
	if (i = "!") 
		 VarSetCapacity(s, _%R%)
	loop, parse, pQ, %A_Space%, %A_Space%
	{	
		field := A_LoopField, data := %R%_%field%, offset := floor(data), type := SubStr(data, StrLen(offset)+2), type := %type%
		ifEqual, data, , return A_ThisFunc "> Field or struct isn't recognised :  " R "." field 
		if i in >,)
			  o%A_Index% := NumGet(i=")" ? S+0 : &S+0, offset,type)
		else  NumPut(o%A_Index%, i=")" ? S : &S+0, offset,type)
	}
	return o1	
}

/*
	Function:	v
				Storage function, designed to use as stdlib or copy and enhance.
			  	
	Parameters:
			  var		- Variable name to retrieve. To get up several variables at once (up to 6), omit this parameter.
			  value		- Optional variable value to set. If var is empty value contains list of vars to retrieve with optional prefix
			  o1 .. o6	- If present, reference to variables to receive values.
	
	Returns:
			  o	if _value_ is omitted, function returns the current value of _var_
			  o	if _value_ is set, function sets the _var_ to _value_ and returns previous value of the _var_
			  o if _var_ is empty, function accepts list of variables in _value_ and returns values of those variables in o1 .. o5

    Remarks:
			  To use multiple storages, copy *v* function and change its name. 
			  			  
			  You can choose to initialize storage from additional ahk script containing only list of assignments to storage variables,
			  to do it internally by adding the values to the end of the your own copy of the function, or to do both, by accepting user values on startup,
			  and checking them afterwards.
  			  If you use stdlib module without including it directly, just make v.ahk script and put variable definitions there.

			  Don't use storage variables that consist only of _ character as those are used to regulate inner working of function.

	Examples:
	(start code)			
 			v(x)		; returns value of x or value of x from v.ahk inside scripts dir.
 			v(x, v)		; set value of x to v and return previous value
 			v("", "x y z", x, y, z)				; get values of x, y and z into x, y and z
 			v("", "prefix_)x y z", x, y, z)	; get values of prefix_x, prefix_y and prefix_z into x, y and z
	(end code)
 */
v(var="", value="~`a ", ByRef o1="", ByRef o2="", ByRef o3="", ByRef o4="", ByRef o5="", ByRef o6="") { 
	static
	ifEqual,___, ,gosub %A_ThisFunc%

	if (var = "" ){
		if ( _ := InStr(value, ")") )
			__ := SubStr(value, 1, _-1), value := SubStr(value, _+1)
		loop, parse, value, %A_Space%
			_ := %__%%A_LoopField%,  o%A_Index% := _ != "" ? _ : %A_LoopField%
		return
	} else _ := %var%
	ifNotEqual, value,~`a , SetEnv, %var%, %value%
	return _
v:
	;Initialize externally, try several places
	   #include *i %A_ScriptDir%\v.ahk
	   #include *i %A_ScriptDir%\inc\v.ahk
	;   ...
	;
	;AND/OR initialize internally:
	;		var1 .= var1 != "" ? "" : 1			;if user set it externally, dont change it
	;		var2 := value						;initialize always
	___ := 1
return
}

/*
	Function:	t
				Timer
			  	
	Parameters:
				v - Reference to output variable. Omit to reset timer.
	
	Returns:
				v
	
	Example:
			(start code)
				t()
				loop, 10000
					f1()
				p := t()

				loop, 10000
					f2()
				t(k)
				m(p, k)
			(end code)
			
 */
t(ByRef v="~`a "){
	static t
	ifEqual, v, ~`a ,SetEnv, t, %A_TickCount%
	return v := A_TickCount - t
}
/*
Function:	d
			Delay/Thread function. Thread is not OS thread, but AHK thread.
			  	
	Parameters:
				fun - Function to be executed.
				delay - Delay in ms.
				a1, a2 - Parameters.
	
	Example:
			(start code)
				d("fun1", "",  1)	;execute asap in new thread with param 1
				d("fun2", 500, "abc")   ;execute after 500ms in new thread with param "abc"
			(end code)
 */
d(fun, delay="", a1="", a2="" ) {
	static adrSetTimer, adrTimerProc

	if !adrSetTimer
	{
		adrSetTimer := DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "SetTimer")
		adrTimerProc := RegisterCallback("d_","", 4)
		d_( "adrKillTimer", DllCall("GetProcAddress", uint, DllCall("GetModuleHandle", str, "user32"), str, "KillTimer"))
	}

	Old_IsCritical := A_IsCritical 
	critical 1000
	id := DllCall(adrSetTimer, "uint", 0, "uint", 0, "uint", delay, "uint", adrTimerProc)
	d_(id, fun), d_(id "_1", a1), d_(id "_2", a2)
	Critical %Old_IsCritical%
}

d_(hwnd, msg, id="", time=""){
	static 
	ifEqual, id, , return %hwnd% := msg
	DllCall(adrKillTimer, "uint", 0, "uint", id)
	fun := %id%, %fun%( %id%_1, %id%_2 )
}

/*
	Function:	Fatal
				Exits the script with the message.

	Parameters:
				E			- Expression. By default 1. The function will exit the script only when E is True.
				Message		- Message to show.
				ExitCode	- Exit code to return to the caller.
 */
Fatal(Message, E=1, ExitCode="") {
	if !E
		return
	MsgBox, 16, Fatal Error, %Message%
	ExitApp, %ExitCode%
}



/* Group: About
	o 0.43 by majkinetor
	o Licenced under GNU GPL <http://creativecommons.org/licenses/GPL/2.0/> 
 */