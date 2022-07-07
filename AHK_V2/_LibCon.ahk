;
; AutoHotkey (Tested) Version: 1.1.13.01
; Author:         Joe DF  |  http://joedf.co.nr  |  joedf@users.sourceforge.net
; Date:           December 13th, 2014
; Library Version: 1.0.6.2
;
;	LibCon - AutoHotkey Library For Console Support
;
;///////////////////////////////////////////////////////

;Default settings
	SetKeyDelay, 0
	SetWinDelay, 0
	SetBatchLines,-1

;Get Arguments
	if 0 > 0
	{
		argc=%0%
		args:=[]
		args[0]:=argc
		
		Loop, %0%
		{
			args.Insert(%A_Index%)
			args["CSV"]:=args["CSV"] """" %A_Index% "" ((A_Index==args[0]) ? """" : """,")
		}
	}	

;Console Constants ;{
	LibConVersion := "1.0.6.1" ;Library Version
	LibConDebug := 0 ;Enable/Disable DebugMode
	LibConErrorLevel := 0 ;Used For DebugMode
	
	;Type sizes // http://msdn.microsoft.com/library/aa383751 // EXAMPLE: SHORT is 2 bytes, etc..
	sType := Object("SHORT", 2, "COORD", 4, "WORD", 2, "SMALL_RECT", 8, "DWORD", 4, "LONG", 4, "BOOL", 4, "RECT", 16, "CHAR", 1)

	;Console Color Constants
	Black:=0x0
	DarkBlue:=0x1
	DarkGreen:=0x2
	Turquoise:=0x3
	;GreenBlue:=0x3
	;BlueGreen:=0x3
	DarkRed:=0x4
	Purple:=0x5
	Brown:=0x6
	Gray:=0x7
	;Grey:=0x7
	DarkGray:=0x8
	;DarkGrey:=0x8
	Blue:=0x9
	Green:=0xA
	Cyan:=0xB
	Red:=0xC
	Magenta:=0xD
	Pink:=0xD
	Yellow:=0xE
	White:=0xF
;}

/* CmdPaste
	
	#IfWinActive ahk_class ConsoleWindowClass
	^v::SendInput {Raw}%clipboard% ; LibConConsolePaste
	#IfWinActive
*/

;Console Functions + More... ;{
SmartStartConsole() { ;will run accordingly
	if (A_IsCompiled) {
		winget,x,ProcessName,A
		if (x="explorer.exe")
			return StartConsole()
		else
			return AttachConsole()
	} else {
		return StartConsole()
	}
}

StartConsole() {
	global Stdout
	global Stdin
	global LibConErrorLevel
	
	ERROR_INVALID_PARAMETER := 87 ;see http://msdn.microsoft.com/library/ms683150
	if (!DllCall("FreeConsole")) {
		LibConErrorLevel:=ErrorLevel
		if (A_LastError!=ERROR_INVALID_PARAMETER) ;if was attached and error occured..
			return LibConError("FreeConsole") ;return error
	} ;otherwise means no console was attached
	
	x:=AllocConsole()
	Stdout:=getStdoutObject()
	Stdin:=getStdinObject()
	return x
}
	
;AttachConsole() http://msdn.microsoft.com/library/ms681952
;Defaults to calling process... ATTACH_PARENT_PROCESS = (DWORD)-1
AttachConsole(cPID:=-1) {
	global LibConErrorLevel
	global Stdout
	global Stdin
	x:=DllCall("AttachConsole", "UInt", cPID, "Cdecl int")
	if ((!x) or (LibConErrorLevel:=ErrorLevel)) and (cPID!=-1) ;reject error if ATTACH_PARENT_PROCESS is set
		return LibConError("AttachConsole",cPID) ;Failure
	Stdout:=getStdoutObject()
	Stdin:=getStdinObject()
	return x
}
	
;AllocConsole() http://msdn.microsoft.com/library/ms681944
AllocConsole() {
	global LibConErrorLevel
	x:=DllCall("AllocConsole")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("AllocConsole") ;Failure
	return x
}

;FreeConsole() http://msdn.microsoft.com/library/ms683150
FreeConsole() {
	global LibConErrorLevel
	x:=DllCall("FreeConsole")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("FreeConsole") ;Failure
	return x
}

;GetStdHandle() http://msdn.microsoft.com/library/ms683231
GetStdinObject() {
	global LibConErrorLevel
	x:=FileOpen(DllCall("GetStdHandle", "int", -10, "ptr"), "h `n")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getStdinObject") ;Failure
	return x
}

GetStdoutObject() {
	global LibConErrorLevel
	x:=FileOpen(DllCall("GetStdHandle", "int", -11, "ptr"), "h `n")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getStdoutObject") ;Failure
	return x
}
	
;Get the console's window Handle
;GetConsoleWindow() http://msdn.microsoft.com/library/ms683175
GetConsoleHandle() {
	global LibConErrorLevel
	hConsole := DllCall("GetConsoleWindow","UPtr") ;or WinGet, hConsole, ID, ahk_pid %cPID%
	if (!hConsole) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getConsoleHandle") ;Failure
	else
		return %hConsole% ;Success
}

NewLine(x=1) {
	loop %x%
		puts()
}

;New Method - Supports Both Unicode and ANSI
;------------------
Print(string=""){
	global Stdout
	global LibConErrorLevel
	
	if (!StrLen(string))
		return 1
	
	e:=DllCall("WriteConsole" . ((A_IsUnicode) ? "W" : "A")
			, "UPtr", Stdout.__Handle
			, "Str", string
			, "UInt", strlen(string)
			, "UInt*", Written
			, "uint", 0)

	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("print",string) ;Failure
	Stdout.Read(0)
	return e
}

Puts(string="") {
	global Stdout
	r:=print(string . "`n")
	Stdout.Read(0)
	return r
}
	
;fork of 'formatprint' :  http://www.autohotkey.com/board/topic/60731-printf-the-ahk-way/#entry382968
Printf(msg, vargs*) {
	for each, varg in vargs
		StringReplace,msg,msg,`%s, % varg ;msg:=RegExReplace(msg,"i)`%.",varg)
	return print(msg)
}

Putsf(msg, vargs*) {
	for each, varg in vargs
		StringReplace,msg,msg,`%s, % varg ;msg:=RegExReplace(msg,"i)`%.",varg)
	return puts(msg)
}

;New Method using WinAPI - Way Faster, better performance
;Implementation from: http://msdn.microsoft.com/library/ms682022
ClearScreen() {
	global LibConErrorLevel
	GetConsoleSize(dwSize_X,dwSize_Y)
	dwConSize:=dwSize_X*dwSize_Y
	x:=FillConsoleOutputCharacter(" ",dwConSize,0,0,lpNumberOfCharsWritten)
	y:=FillConsoleOutputAttribute(GetColor(),dwConSize,0,0,lpNumberOfAttrsWritten)
	SetConsoleCursorPosition(0,0)
	if (!x) or (LibConErrorLevel:=ErrorLevel) or (!y)
		return LibConError("ClearScreen") ;Failure
	return 1
}

cls() {
	return ClearScreen()
}

Clear() {
	return ClearScreen()
}
	
; New Method - Supports Both Unicode and ANSI
;Forked from the German CMD Lib
;http://www.autohotkey.com/de/forum/topic8517.html
Gets(ByRef str="") {
	global StdIn
	global LibConErrorLevel
	
	BufferSize:=8192 ;65536 bytes is the maximum
	charsRead:=0
	Ptr := (A_PtrSize) ? "uptr" : "uint"
	
	VarSetCapacity(str,BufferSize)
	e:=DllCall("ReadConsole" . ((A_IsUnicode) ? "W" : "A")
			,Ptr,stdin.__Handle
			,Ptr,&str
			,"UInt",BufferSize
			,Ptr "*",charsRead
			,Ptr,0
			,UInt)
	LibConErrorLevel:=ErrorLevel
	
	if (e) and (!charsRead)
		return ""
	if (!e) or (LibConErrorLevel)
		return LibConError("gets",str)
	
	Loop, % charsRead
		msg .= Chr(NumGet(str, (A_Index-1) * ((A_IsUnicode) ? 2 : 1), (A_IsUnicode) ? "ushort" : "uchar"))
	StringSplit, msg, msg,`r`n
	str:=msg1
	flushInput()
	
	return str
}

;FlushConsoleInputBuffer() http://msdn.microsoft.com/library/ms683147
FlushInput() {
	global LibConErrorLevel
	global stdin
	x:=DllCall("FlushConsoleInputBuffer", uint, stdin.__Handle)
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("flushInput") ;Failure
	return x
}

;_getch() http://msdn.microsoft.com/library/078sfkak
_getch(Lock=1) {
	return DllCall("msvcrt.dll\_getch" (lock?"":"_nolock"),"int")
}

_getchW(Lock=1) {
	return DllCall("msvcrt.dll\_getwch" (lock?"":"_nolock"),"int")
}

;_ungetch() http://msdn.microsoft.com/library/yezzac74
_ungetch(c,Lock=1) {
	return DllCall("msvcrt.dll\_ungetch" (lock?"":"_nolock"),"int",c,"int")
}

_ungetchW(c,Lock=1) {
	return DllCall("msvcrt.dll\_ungetwch" (lock?"":"_nolock"),"int",c,"int")
}

Getch(ByRef keyname="") {
	;the comments with ;//   are from my original c function
	;this is an AutoHotkey port of that function...
	FlushInput()
	
	If (A_IsUnicode) { ;enable unicode "getch" => _getchW()
		key:=_getchw()
		if (key==224) or (key==0) ; 'à' in Unicode is 224 or 0xE0
		{
			_ungetch(key) ;ungetch twice is neccessary...
			_ungetchW(key) ;we're using a "sort-of bug" at our advantage
			skey:=_getchW()
		}
	} else {
		key:=_getch()
		if (key==224) or (key==0)
			skey:=_getch()
	}
	
	if (key==1) ;//note 'a' is 0x61
		keyname:="Ctrl+a"
	else if (key==3) ;//note 'c' is 0x63
		keyname:="Ctrl+c"
	else if (key==4) ;//note 'd' is 0x64
		keyname:="Ctrl+d"
	else if (key==5)  ;//therefore "Ctrl+c" = 0x63 - 0x60 = 3
		keyname:="Ctrl+e" ;//and so on...
	else if (key==6)
		keyname:="Ctrl+f"
	else if (key==7)
		keyname:="Ctrl+g"
	else if (key==8) ;//case  8: *keyname ="Ctrl+h 8"; break;
		keyname:="Backspace"
	else if (key==9) ;//case  9: *keyname ="Ctrl+i 9"; break;
		keyname:="Tab"
	else if (key==13)
		keyname:="Return"
	else if (key==24)
		keyname:="Ctrl+x" ;etc..
	else if (key==25)
		keyname:="Ctrl+y" ;and so on...
	else if (key==26)
		keyname:="Ctrl+z" ;future key support will be added...
	else if (key==27)
		keyname:="Esc"
	else if (key==32)
		keyname:="Space"
	else if (key==224) ;//or FFFFFFE0 or 4294967264 ;*keyname ="Special";
	{
		if (skey==71)
			keyname:="Home"
		else if (skey=72)
			keyname:="Up"
		else if (skey=73)
			keyname:="PgUp"
		else if (skey=75)
			keyname:="Left"
		else if (skey=77)
			keyname:="Right"
		else if (skey=79)
			keyname:="End"
		else if (skey=80)
			keyname:="Down"
		else if (skey=81)
			keyname:="PgDn"
		else if (skey=82)
			keyname:="Ins"
		else if (skey=83)
			keyname:="Del"
		else if (skey=133)
			keyname:="F11"
		else if (skey=134)
			keyname:="F12"
		else if (skey=224) and (A_IsUnicode)
		{
			keyname:=chr(224) ; 'à' in Unicode is 224 or 0xE0
			return 224
		}
		else
			keyname:="Special"
	}
	else if (key==0) ;Function Keys?!  code: '0' (value)
	{
		keyname:="FunctionKey"
		if (skey>=59) && (skey<=68)
			keyname:="F" (skey-58)
	}
	else
	{
		keyname:=chr(key)
	}
	
	flushInput() ;Flush the input buffer
	
	if (key==224)
		return "224+" skey
	else if (key==0)
		return "0+" skey
	else
		return key
}

Wait(timeout=0) {
	opt:=""
	if (!timeout=0)
		opt=T%timeout%
	Input, SingleKey, L1 %opt%, {LControl}{RControl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}{AppsKey}{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}{Del}{Ins}{BS}{Capslock}{Numlock}{PrintScreen}{Pause}
	return %SingleKey%
}

/*
;from gwarble
;http://www.autohotkey.com/board/topic/96304-real-console-applications-command-line-apps/?hl=console
WaitAction() {
	global Stdin
	VarSetCapacity(INPUT_RECORD, 24, 0)
	DllCall("ReadConsoleInput", uint, stdin.__Handle, uint, &INPUT_RECORD, uint, 1, "ptr*", 0)
	key := NumGet(INPUT_RECORD,14,"Short")
	flushInput() ;Flush the input buffer	
	return key
}
*/

;fork see AHK-Console-Class : https://github.com/NickMcCoy/AHK-Console-Class
ReadConsoleInput()
{
	global Stdin
	global LibConErrorLevel
	Event := {}
	Event.EventList[0x0001] := "4|8|10|12|14|16"
	Event.EventList[0x0002] := "4|6|8|12|16"
	
	VarSetCapacity(InputRecord, 2000)
	VarSetCapacity(s, 4)
	e:=DllCall("ReadConsoleInput", "int", Stdin.__Handle, "int", &InputRecord, "int", 100, "int", &s)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("ReadConsoleInput")
	Event.EventType := NumGet(InputRecord, 0, "short")
	Dummy := Event.EventList[Event.EventType]
	Loop, Parse, Dummy, |
		Event.EventInfo[A_Index] := NumGet(InputRecord, A_LoopField, "short")
	Event.s := NumGet(s)
	return, Event
}

Pause(show=1) {
	global LibConErrorLevel
	n:=""
	if (!show)
		n:=">NUL"
	runwait %ComSpec% /c pause.exe %n%,,UseErrorLevel
	if (LibConErrorLevel:=ErrorLevel)
		return LibConError("pause",show)
	return 1
}

Dec2Hex(var) {
	OldFormat := A_FormatInteger
	SetFormat, Integer, Hex
	var += 0
	SetFormat, Integer, %OldFormat%
	return var
}

;from Laszlo : http://www.autohotkey.com/board/topic/15951-base-10-to-base-36-conversion/#entry103624
ToBase(n,b) { ; n >= 0, 1 < b <= 36
	Loop {
		d := mod(n,b), n //= b
		m := (d < 10 ? d : Chr(d+55)) . m
		IfLess n,1, Break
	}
	Return m
}

;Fork of http://www.autohotkey.com/board/topic/90674-ascii-progress-bar/
sProgressBar(Length, Current, Max, Unlock = 0, fixed=1, lp="|", lba="[", lbb="]") {
	;Original Made by Bugz000 with assistance from tidbit, Chalamius and Bigvent
	Progress:=""
	Percent := (Current / Max) * 100
	if (unlock = 0)
			length := length > 97 ? 97 : length < 4 ? 4 : length
	percent := percent > 100 ? 100 : percent < 0 ? 0 : percent
	Loop % round(((percent / 100) * length), 0)
			Progress .= lp
	if (fixed)
	{
		loop % Length - round(((percent / 100) * length), 0)
				Progress .= A_Space
	}
	return lba progress lbb A_space round(percent, 2) "% Complete"
}

;SetConsoleTextAttribute() http://msdn.microsoft.com/library/ms686047
SetColor(FG="",BG="") { ;Sets the color (int Hexadecimal number)
	global LibConErrorLevel
	global Stdout
	if FG is not integer
		FG:=getFgColor()
	if BG is not integer
		BG:=getBgColor()
	FG:=abs(FG)
	BG:=abs(BG)*16
	x:=DllCall("SetConsoleTextAttribute","UPtr",Stdout.__Handle,"Int",(BG+FG))
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("setColor",FG,BG) ;Failure
	return x
}

SetFgColor(c) {
	return setcolor(c)
}

SetBgColor(c) {
	return setColor("",c)
}

setColorPos(c,x,y) {
	return FillConsoleOutputAttribute(c,1,x,y)
}

;GetConsoleScreenBufferInfo() http://msdn.microsoft.com/library/ms683171
GetColor(ByRef FgColor="", ByRef BgColor="") { ;Returns the current color (int Hexadecimal number)
	global LibConErrorLevel
	global Stdout
	global sType
	VarSetCapacity(consoleInfo,(3*sType.COORD)+sType.WORD+sType.SMALL_RECT,0)
	x:=DllCall("GetConsoleScreenBufferInfo","UPtr",Stdout.__Handle,"Ptr",&consoleInfo)
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getColor") ;Failure
	c:=dec2hex(NumGet(&consoleInfo,(2*sType.COORD),"Short"))
	FgColor:=dec2hex(c-(16*(c >> 4)))
	BgColor:=dec2hex(c >> 4)
	return c
}

GetFgColor() {
	getColor(fg)
	return fg
}

GetBgColor() {
	getColor("",bg)
	return bg
}

getColorPos(x,y) {
	ReadConsoleOutputAttribute(c,1,x,y)
	return c
}

PrintColorTable() {
	
	OldFormat := A_FormatInteger
	SetFormat, Integer, Hex
	var += 0
	
	f:=0
	b:=0
	cf:=getFGColor()
	cb:=getBGColor()
	
	puts("`n`t1st Digit: Background 2nd Digit: Foreground")
	puts("_______________________________________________________________")
	
	Loop, 16 
	{
		b:=(A_Index-1)
		print("`t" . "")
		Loop, 16 
		{
			setColor(f:=(A_Index-1), b)
			;print(dec2shex(b) . dec2shex(f) . ((f=15 or f="F") ? "`n" : " "))
			;print(RegExReplace(k:=((b*16)+f),"0x",(k<16?"0":"")) . ((f=15)?"`n":" "))
			print((((b*16)+f)<16?"0":"") . SubStr(((b*16)+f),3) . ((f=15)?"`n":" "))
		}
		setColor(cf,cb)
	}
	puts("_______________________________________________________________")
	puts("Current Color: " . getColor())
	
	SetFormat, Integer, %OldFormat%
}

;see "Code Page Identifiers" (CP) - http://msdn.microsoft.com/library/dd317756

;SetConsoleOutputCP() http://msdn.microsoft.com/library/ms686036
SetConsoleOutputCP(codepage) {
	global LibConErrorLevel
	e:=DllCall("SetConsoleOutputCP","UInt",codepage)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("SetConsoleOutputCP",codepage) ;Failure
	return 1
}

;GetConsoleOutputCP() http://msdn.microsoft.com/library/ms683169
GetConsoleOutputCP() {
	global LibConErrorLevel
	codepage:=DllCall("GetConsoleOutputCP","Int")
	if (!codepage) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleOutputCP") ;Failure
	return codepage
}

;SetConsoleCP() http://msdn.microsoft.com/library/ms686013
SetConsoleInputCP(codepage) {
	global LibConErrorLevel
	e:=DllCall("SetConsoleCP","UInt",codepage)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("SetConsoleInputCP",codepage) ;Failure
	return 1
}

;GetConsoleCP() http://msdn.microsoft.com/library/ms683162
GetConsoleInputCP() {
	global LibConErrorLevel
	codepage:=DllCall("GetConsoleCP","Int")
	if (!codepage) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleInputCP") ;Failure
	return codepage
}

;GetConsoleMode() http://msdn.microsoft.com/library/ms683167
GetConsoleMode(ByRef Mode) {
	global LibConErrorLevel
	global stdout
	e:=DllCall("GetConsoleMode","UInt",stdout.__handle,"UInt*",Mode)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleMode",Mode) ;Failure
	return 1
}

;SetConsoleMode() http://msdn.microsoft.com/library/ms686033
SetConsoleMode(Mode) {
	global LibConErrorLevel
	global stdin
	e:=DllCall("SetConsoleMode","UInt",stdin.__handle,"UInt",Mode)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("SetConsoleMode",Mode) ;Failure
	return 1
}

;GetConsoleOriginalTitle() http://msdn.microsoft.com/library/ms683168
GetConsoleOriginalTitle(byRef Title) {
	global LibConErrorLevel
	VarSetCapacity(title,6400,0)
	e:=DllCall("GetConsoleOriginalTitle","Str",Title,"UInt",6400)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleTitle",Title) ;Failure
	return 1
}

;GetConsoleTitle() http://msdn.microsoft.com/library/ms683174
GetConsoleTitle(byRef Title) {
	global LibConErrorLevel
	VarSetCapacity(title,6400,0)
	e:=DllCall("GetConsoleTitle","Str",Title,"UInt",6400)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleTitle",Title) ;Failure
	return 1
}

;SetConsoleTitle() http://msdn.microsoft.com/library/ms686050
SetConsoleTitle(title="") {
	global LibConErrorLevel
	if !(title=="")
	{
		string:=title
		if strlen(string) >= 6400
			StringTrimRight,string,string,% strlen(string) - (strlen(string)-6400)
		e:=DllCall("SetConsoleTitle","Str",string)
		if (!e) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("SetConsoleTitle",title) ;Failure
		return 1
	}
	return 0
}

;fork see AHK-Console-Class : https://github.com/NickMcCoy/AHK-Console-Class
SetConsoleIcon(Path)
{
	global LibConErrorLevel
	if (FileExist(Path))
	{
		hIcon := DllCall("LoadImage", "uint", 0, "str", Path, "uint", 1, "int", 0, "int", 0, "uint", 0x00000010)
		e:=DllCall("SetConsoleIcon", "int", hIcon)
		if (!e) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("SetConsoleIcon",Path) ;Failure
		return 1
	}
	return 0
}

;GetCurrentDirectory() http://msdn.microsoft.com/library/aa364934
GetCurrentDirectory() {
	global LibConErrorLevel
	VarSetCapacity(cdir,cdir_size:=260*(A_IsUnicode?6:1)+1,0)
	e:=DllCall("GetCurrentDirectory" (A_IsUnicode?"W":"A"),"UInt",cdir_size,"Str",cdir)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetCurrentDirectory") ;Failure
	return cdir
}

;SetCurrentDirectory() http://msdn.microsoft.com/library/aa365530
SetCurrentDirectory(dir) {
	global LibConErrorLevel
	;StringReplace,dir,dir,\,\\,All  ; Not necessary?
	if (dir!="") {
		e:=DllCall("SetCurrentDirectory" (A_IsUnicode?"W":"A"),"Str",dir,"int")
		if (!e) or (LibConErrorLevel:=ErrorLevel)
			return LibConError("SetCurrentDirectory",dir) ;Failure
	}
	return 1
}

;GetConsoleCursorInfo() http://msdn.microsoft.com/library/ms683163
GetConsoleCursorInfo(ByRef Size="", ByRef Shown="") {
	global LibConErrorLevel
	global stdout
	global sType
	VarSetCapacity(s,sType.DWORD+sType.BOOL,0)
	e:=DllCall("GetConsoleCursorInfo","UInt",stdout.__handle,"Ptr",&s)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleCursorInfo",Shown,Size) ;Failure
	Size:=NumGet(&s,"UInt")
	Shown:=NumGet(&s,sType.DWORD,"Int")
	return 1
}

;SetConsoleCursorInfo() http://msdn.microsoft.com/library/ms686019
SetConsoleCursorInfo(Size="", Shown="") {
	global LibConErrorLevel
	global stdout
	global sType
	if size is not Integer
	{ ;and 
		if Shown is not Integer
			return 0
	}
	if size is not Integer
		GetConsoleCursorInfo(size)
	if size not between 1 and 100
		GetConsoleCursorInfo(size)
	if Shown is not Integer
		GetConsoleCursorInfo("",Shown)
	VarSetCapacity(s,sType.DWORD+sType.BOOL,0)
	NumPut(Size,s,"UInt")
	NumPut(Shown,s,sType.DWORD,"Int")
	e:=DllCall("SetConsoleCursorInfo","UInt",stdout.__handle,"Ptr",&s)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("SetConsoleCursorInfo",Shown,Size) ;Failure
	return 1
}

;For the Cursor of CLI -> Caret
;getConsoleCursorPosition, GetConsoleScreenBufferInfo() http://msdn.microsoft.com/library/ms683171
GetConsoleCursorPosition(ByRef x, ByRef y) {
	global LibConErrorLevel
	global Stdout
	global sType
	hStdout := Stdout.__Handle
	VarSetCapacity(struct,(sType.COORD*3)+sType.WORD+sType.SMALL_RECT,0)
	e:=DllCall("GetConsoleScreenBufferInfo","UPtr",hStdout,"Ptr",&struct)
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getConsoleCursorPosition",x,y) ;Failure
	x:=NumGet(&struct,sType.COORD,"UShort")
	y:=NumGet(&struct,sType.COORD+sType.SHORT,"UShort")
	return 1
}

;SetConsoleCursorPosition() http://msdn.microsoft.com/library/ms686025
SetConsoleCursorPosition(x="",y="") {
	global LibConErrorLevel
	global Stdout
	global sType
	hStdout:=Stdout.__Handle
	getConsoleCursorPosition(ox,oy)
	if x is not Integer
		x:=ox
	if y is not Integer
		y:=oy
	VarSetCapacity(struct,sType.COORD,0)
	Numput(x,struct,"UShort")
	Numput(y,struct,sType.SHORT,"UShort")
	e:=DllCall("SetConsoleCursorPosition","Ptr",hStdout,"uint",Numget(struct,"uint"))
	if (!e) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("SetConsoleCursorPosition",x,y) ;Failure
	return 1
}

GetConsoleCursorPos(ByRef x, ByRef y) {
	return getConsoleCursorPosition(x,y)
}

SetConsoleCursorPos(x="",y="") {
	return SetConsoleCursorPosition(x,y)
}

;Get BufferSize, GetConsoleScreenBufferInfo() http://msdn.microsoft.com/library/ms683171
GetConsoleSize(ByRef bufferwidth, ByRef bufferheight) {
	global LibConErrorLevel
	global Stdout
	global sType
	hStdout := Stdout.__Handle
	VarSetCapacity(struct,(sType.COORD*3)+sType.WORD+sType.SMALL_RECT,0)
	x:=DllCall("GetConsoleScreenBufferInfo","UPtr",hStdout,"Ptr",&struct)
	LibConErrorLevel:=ErrorLevel
	bufferwidth:=NumGet(&struct,"UShort")
	bufferheight:=NumGet(&struct,sType.SHORT,"UShort")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getConsoleSize",bufferwidth,bufferheight) ;Failure
	return 1
}

GetConsoleWidth() {
	if (!getConsoleSize(bufferwidth,bufferheight))
		return 0 ;Failure
	else
		return %bufferwidth% ;Success
}

GetConsoleHeight() {
	if (!getConsoleSize(bufferwidth,bufferheight))
		return 0 ;Failure
	else
		return %bufferheight% ;Success
}

;GetCurrentConsoleFont() http://msdn.microsoft.com/library/ms683176
GetFontSize(Byref fontwidth, ByRef fontheight) {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
	;CONSOLE_FONT_INFO cmdft;
	;GetCurrentConsoleFont(hStdout,FALSE,&cmdft);
	;COORD fontSize = GetConsoleFontSize(hStdout,cmdft.nFont);
	;return fontSize.X;
	
	;typedef struct _CONSOLE_FONT_INFO {
	;	DWORD nFont;
	;	COORD dwFontSize;
	; } CONSOLE_FONT_INFO, *PCONSOLE_FONT_INFO;
	
	VarSetCapacity(struct,sType.DWORD+sType.COORD,0)
	x:=DllCall("GetCurrentConsoleFont","Ptr",hStdout,"Int",0,"Ptr",&struct)
	LibConErrorLevel:=ErrorLevel
	;VarSetCapacity(structb,sType.COORD,0)
	;structb:=DllCall("GetConsoleFontSize","Ptr",hStdout,"UInt",NumGet(&struct,"Int"))
	
	fontwidth:=NumGet(&struct,sType.DWORD,"UShort")
	fontheight:=NumGet(&struct,sType.DWORD+sType.SHORT,"UShort")
	
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("getFontSize",fontwidth,fontheight) ;Failure
	return 1
}

GetFontWidth() {
	if (!getFontSize(fontwidth,fontheight))
		return 0 ;Failure
	else
		return %fontwidth% ;Success
}

GetFontHeight() {
	if (!getFontSize(fontwidth,fontheight))
		return 0 ;Failure
	else
		return %fontheight% ;Success
}

;SetConsoleScreenBufferSize() http://msdn.microsoft.com/library/ms686044
;set Console window size ; - Width in Columns and Lines : (Fontheight and Fontwidth)
SetConsoleSize(width,height,SizeHeight=0) {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
	hConsole:=getConsoleHandle()
	
	getConsoleSize(cW,cH) ;buffer size
	WinGetPos,wX,wY,,wH,ahk_id %hConsole% ;window size
	getFontSize(fW,fH) ;font size
	
	;MsgBox % "rqW: " width "`nrqH: " height
	
	newBuffer := Object("w",(width*fW),"h",(height*fH))
	oldBuffer := Object("w",(cW*fW),"h",(cH*fH))
	
	VarSetCapacity(bufferSize,sType.COORD,0)
	NumPut(width,bufferSize,"UShort")
	NumPut(height,bufferSize,sType.SHORT,"UShort")
	
	if ( (newBuffer.w >= oldBuffer.w) and (newBuffer.h >= oldBuffer.h) )
	{
		if (DllCall("SetConsoleScreenBufferSize","Ptr",hStdout,"uint",Numget(bufferSize,"uint"))
			and DllCall("MoveWindow","Ptr",hConsole,"Int",wX,"Int",wY,"Int",newBuffer.w,"Int",newBuffer.h,"Int",1))
		{
			if (SizeHeight)
				WinMove,ahk_id %hConsole%,,,,,wH
			return 1
		}
		else
		{
			LibConErrorLevel := ErrorLevel
			return LibConError("setConsoleSize",width,height,SizeHeight) ;Failure
		}
	}
	else
	{
		if (DllCall("MoveWindow","Ptr",hConsole,"Int",wX,"Int",wY,"Int",newBuffer.w,"Int",newBuffer.h,"Int",1)
			and DllCall("SetConsoleScreenBufferSize","Ptr",hStdout,"uint",Numget(bufferSize,"uint")))
		{
			if (SizeHeight)
				WinMove,ahk_id %hConsole%,,,,,wH
			return 1
		}
		else
		{
			LibConErrorLevel := ErrorLevel
			return LibConError("setConsoleSize",width,height,SizeHeight) ;Failure
		}
	}
}

SetConsoleWidth(w) {
	return SetConsoleSize(w,GetConsoleHeight())
}

SetConsoleHeight(h) {
	return SetConsoleSize(GetConsoleWidth(),h)
}

GetConsoleClientSize(ByRef width, ByRef height) {
	global LibConErrorLevel
	global sType
	VarSetCapacity(s,sType.RECT,0)
	x:=DllCall("GetClientRect","UInt",getConsoleHandle(),"UInt",&s)
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("GetConsoleClientSize",width,height) ;Failure
	width:=NumGet(s,2*(sType.LONG),"Int")
	height:=NumGet(s,3*(sType.LONG),"Int")
	return 1
}

GetConsoleClientWidth() {
	if (!GetConsoleClientSize(width,height))
		return 0 ;Failure
	else
		return %width% ;Success
}

GetConsoleClientHeight() {
	if (!GetConsoleClientSize(width,height))
		return 0 ;Failure
	else
		return %height% ;Success
}

;http://msdn.microsoft.com/library/ms682663
FillConsoleOutputCharacter(cCharacter,nLength,x,y,ByRef lpNumberOfCharsWritten="") {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
/*	
	BOOL WINAPI FillConsoleOutputCharacter(
		_In_   HANDLE hConsoleOutput,
		_In_   TCHAR cCharacter,
		_In_   DWORD nLength,
		_In_   COORD dwWriteCoord,
		_Out_  LPDWORD lpNumberOfCharsWritten
	);
*/
	VarSetCapacity(dwWriteCoord,sType.COORD,0)
		NumPut(x,dwWriteCoord,"UShort")
		NumPut(y,dwWriteCoord,sType.SHORT,"UShort")
	
	x:=DllCall("FillConsoleOutputCharacter"
				,"UInt",hStdOut
				,"UChar",asc(cCharacter)
				,"UInt",nLength
				,"uint",Numget(dwWriteCoord,"uint")
				,"UInt*",lpNumberOfCharsWritten,"Int")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("FillConsoleOutputCharacter",cCharacter,nLength,x,y,lpNumberOfCharsWritten) ;Failure
	return 1
}

;http://msdn.microsoft.com/library/ms682662
FillConsoleOutputAttribute(wAttribute,nLength,x,y,ByRef lpNumberOfAttrsWritten="") {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
/*
	BOOL WINAPI FillConsoleOutputAttribute(
		_In_   HANDLE hConsoleOutput,
		_In_   WORD wAttribute,
		_In_   DWORD nLength,
		_In_   COORD dwWriteCoord,
		_Out_  LPDWORD lpNumberOfAttrsWritten
	);
*/
	VarSetCapacity(dwWriteCoord,sType.COORD,0)
		NumPut(x,dwWriteCoord,"UShort")
		NumPut(y,dwWriteCoord,sType.SHORT,"UShort")
	
	x:=DllCall("FillConsoleOutputAttribute"
				,"UInt",hStdOut
				,"UShort",wAttribute
				,"UInt",nLength
				,"uint",Numget(dwWriteCoord,"uint")
				,"UInt*",lpNumberOfAttrsWritten,"Int")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("FillConsoleOutputAttribute",wAttribute,nLength,x,y,lpNumberOfAttrsWritten) ;Failure
	return 1
}

;http://msdn.microsoft.com/library/ms684968
ReadConsoleOutputAttribute(ByRef lpAttribute, nLength, x, y, ByRef lpNumberOfAttrsRead="") {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
/*
	BOOL WINAPI ReadConsoleOutputAttribute(
		_In_   HANDLE hConsoleOutput,
		_Out_  LPWORD lpAttribute,
		_In_   DWORD nLength,
		_In_   COORD dwReadCoord,
		_Out_  LPDWORD lpNumberOfAttrsRead
	);
*/
	VarSetCapacity(dwWriteCoord,sType.COORD,0)
		NumPut(x,dwWriteCoord,"UShort")
		NumPut(y,dwWriteCoord,sType.SHORT,"UShort")
	
	x:=DllCall("ReadConsoleOutputAttribute"
				,"UInt",hStdOut
				,"UInt*",lpAttribute
				,"UInt",nLength
				,"uint",Numget(dwWriteCoord,"uint")
				,"UInt*",lpNumberOfAttrsRead,"Int")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("ReadConsoleOutputAttribute",lpAttribute,nLength,x,y,lpNumberOfAttrsRead) ;Failure
	return 1
}

;http://msdn.microsoft.com/library/ms684969
; could not get it work with more than 1 char... so i decided to just coords of one char
ReadConsoleOutputCharacter(x, y) {
	global LibConErrorLevel
	global sType
	global Stdout
	hStdout:=Stdout.__Handle
/*	
	BOOL WINAPI ReadConsoleOutputCharacter(
		_In_   HANDLE hConsoleOutput,
		_Out_  LPTSTR lpCharacter,
		_In_   DWORD nLength,
		_In_   COORD dwReadCoord,
		_Out_  LPDWORD lpNumberOfCharsRead
	);
*/
	VarSetCapacity(dwWriteCoord,sType.COORD,0)
		NumPut(x,dwWriteCoord,"UShort")
		NumPut(y,dwWriteCoord,sType.SHORT,"UShort")
		
	VarSetCapacity(lpCharacter,2,0)
	
	x:=DllCall("ReadConsoleOutputCharacter" (A_IsUnicode?"W":"A")
				,"UInt",hStdOut
				,"UChar*",lpCharacter
				,"UInt",1
				,"uint",Numget(dwWriteCoord,"uint")
				,"UInt*",lpNumberOfCharsRead,"Int")
	if (!x) or (LibConErrorLevel:=ErrorLevel)
		return LibConError("ReadConsoleOutputCharacter",x,y) ;Failure
	return chr(lpCharacter)
}

;http://msdn.microsoft.com/library/ms684965
; pseudo function to replace the Original/real function
ReadConsoleOutput(x, y, w, h) {
	str:=""
	Loop % h
	{
		z:=(A_Index-1)+y
		Loop % w
		{
			k:=(A_Index-1)+x
			str .= ReadConsoleOutputCharacter(k,z)
		}
		if (h!=A_Index)
			str .= "`n"
	}
	return str
}

;Msgbox for Errors (DebugMode Only)
LibConError(fname:="",ByRef arg1:="", ByRef arg2:="",arg3:="",arg4:="", ByRef arg5:="") {
	global LibConDebug
	global LibConErrorLevel
	
	static LibConErrorsIgnoreList
	
	;calling function name: msgbox % Exception("",-2).what ; from jethrow
	;http://www.autohotkey.com/board/topic/95002-how-to-nest-functions/#entry598796
	if !IsFunc(fname) ;or fname is space
		fname := Exception("",-2).what
	if !IsFunc(fname) ;try again since sometime it return -2() meaning not found...
		fname := "Undefined"
	
	;Fallback to Classic/Deprecated Old Methods
	;If the new methods failed
	global Stdout
	global Stdin
	if (fname="print") and (A_LastError=6)
	{
		if strlen(arg1) > 0
			x:=Stdout.write(arg1)
		Stdout.Read(0)
		return x
	}
	if (fname="puts") and (A_LastError=6)
	{
		Stdout.WriteLine(string) ;Stdout.write(string . "`n")
		Stdout.Read(0)
		return x
	}
	if (fname="gets") and (A_LastError=6)
	{
		return arg1:=RTrim(Stdin.ReadLine(), "`n")
		;flushInput() ;Flush the input buffer
	}
	if (fname="ClearScreen") and (A_LastError=6)
	{
		runwait %ComSpec% /c cls.exe %n%,, UseErrorLevel
		return LibConErrorLevel:=ErrorLevel
	}
	
	if (LibConDebug)
	{
		
		if fname in %LibConErrorsIgnoreList%
			return 0
		
		MsgBox, 262194, LibConError, %fname%() Failure`nErrorlevel: %LibConErrorLevel%`nA_LastError: %A_LastError%`n`nWill now Exit.
		IfMsgBox, Abort
			ExitApp
		IfMsgBox, Ignore
		{
			LibConErrorsIgnoreList:=fname "," LibConErrorsIgnoreList
			return 0
		}
		IfMsgBox, Retry
		{
			return %fname%(arg1,arg2,arg3,arg4,arg5)
		}
	}
	return 0
}
;}