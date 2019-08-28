Funcs() {
	Return, true
	}

CoMode(p1,p2=""){
	static prev:={}
	(p2=""?p2:=prev["A_CoordMode" p1]:prev["A_CoordMode" p1]:=A_CoordMode%p1%)
	return CoordMode(p1,p2) prev["A_CoordMode" p1]
	}
CMODE(p1,p2=""){ ; t(cmode("tooltip","Screen")) t(cmode("all","Client"))
	static prev:={},last:={ToolTip:A_CoordModeToolTip,Pixel:A_CoordModePixel,Mouse:A_CoordModeMouse,Caret:A_CoordModeCaret,Menu:A_CoordModeMenu}
	if (p1="all") and ret:={} { ; Screen|Window|Client
	for k,v in ["Tooltip","Pixel","Mouse","Menu","Caret"]
	ret[(v)]:=cmode(v,p2)
	return ret
	}CM:="A_CoordMode" P1,!p2?(p2:=prev[CM],prev[CM]:=last[CM]):p2!=last[CM]?prev[CM]:=A_CoordMode%p1%:""
	return CoordMode(p1,p2) CM " : " prev[CM] " --> " (last[CM]:=A_CoordMode%p1%)
	}CoordMode(p1,p2=""){
	CoordMode, % p1, % p2
	}

Q(v=""){
	static Freq:=false,app,linenum,Q:={},I
	Freq?"":DllCall("QueryPerformanceFrequency","Int64*",Freq)
	DllCall("QueryPerformanceCounter","Int64*",BEF),q.push(bef)
	if !(v="END")
	return
	el:="elapsed=" ((bef-(LB:=q.remove(1)))*1000)/Freq
	if q.MaxIndex()>1
	for k,bef in q
	a.=k " elapsed " ((bef-LB)*1000)/Freq "`n",LB:=bef
	q:=[]
	return a "`n" el
	}

StrPutVar(string, ByRef var, encoding){
	VarSetCapacity(var, StrPut(string, encoding) ; Ensure capacity.
	; StrPut returns char count, but VarSetCapacity needs bytes.
	* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1))
	; Copy or convert the string.
	return StrPut(string, &var, encoding)
	}
DHW(V=""){
	static DHW
	DHW:=A_DetectHiddenWindows,NDHW:=V="Off" or V="ON"?V:V="" AND DHW="Off"?"On":V="" AND DHW="On"?"Off":"Failed"
	if (NDHW!=DHW)
	DetectHiddenWindows, % NDHW
	return A_DetectHiddenWindows
	}
SplitPath(I,ByRef name="",ByRef dir="",ByRef ext="", ByRef name_no_ext="",ByRef Drive=""){
	SplitPath, I, name, dir, ext, name_no_ext, drive
	return {"I":I,"name":name,"dir":dir,"ext":ext,"NNO":name_no_ext,"drive":drive}
	}
SPath(I,name="name",dir="dir",ext="ext",name_no_ext = "name_no_ext",Drive = "Drive"){
	SplitPath,I, name, dir, ext, name_no_ext, drive
	return {"I":i,"name":name,"dir":dir,"ext":ext,"NNO":name_no_ext,"name_no_ext":name_no_ext,"drive":drive}
	}
RegKeyType(FullPathOfKey, ValueName) {
	Loop, Reg, %FullPathOfKey%
		if (A_LoopRegName = ValueName)
			return A_LoopRegType
	return "Error"
	}

IR(Section="ML",Key="",Filename="ini.ini",Def=""){
	IniRead, Out, %Filename%, %Section%, %Key%, %Def%
	return Out
	}
IW(K="",V="",Section="",Filename="ini.ini"){
	IniWrite, %V%, %Filename%, %Section%, %K%
	}
ini(var,section,filename="ini.ini"){
	IniWrite, %var%,% filename,% section ; IniRead, var,% filename,% section ; IniWrite, %var%,% filename,% section
	return var
	}

runclose(target,extitle=""){
	dhw:=A_DetectHiddenWindows,DHW("On")
	if contains(target,".ahk") AND !instr(target,"ahk_class")
	addtotarget:=" ahk_class AutoHotkey" ; extitle=Sublime
	if winf:=win(target addtotarget,,extitle) ; winexist(target addtotarget,,extitle)
	close(),t("closing target : " target "`nwin found: '" winf.title "'")
	else, t("run " target "  " "".PID:=run(target) )
	DHW(DHW)
}wclose(){
winclose
}close(){
winclose
}WA(v=""){
	winactivate %v%
	winwaitactive %v%
}
sub(var){
	if islabel(var)
	gosub %var%
	else,t(var " is not a label")
}click(){
click
}sleep(ms){
	sleep %ms%
return
}reload(){
	reload
}pause(){
	pause
}exit(){
	exit
	}

ifequal(x,y*){
	for k,v in y
	if (x=v)
	return true
}Between(ByRef var, LowerBound, UpperBound){
	If var between %LowerBound% and %UpperBound%
		Return, true
}NotBetween(ByRef var, LowerBound, UpperBound){
	If var not between %LowerBound% and %UpperBound%
		Return, true
}In(ByRef var, MatchList){
	If var in %MatchList%
		Return, true
}NotIn(ByRef var, MatchList){
	If var not in %MatchList%
		Return, true
}Contains(ByRef var, MatchList){
	If var contains %MatchList%
		Return, true
}NotContains(ByRef var, MatchList){
	If var not contains %MatchList%
	Return, true
	}
Is(ByRef var, types*){
	for k,type in types
	if istype(var,type)
	ret.="is " type "`n"
	return ret?var " " trim(ret,"`n"):""
	}
IsType(ByRef var, type) {
	If var is %type% ; "integer,float,number,digit,xdigit,alpha,upper,lower,alnum,space"
	Return, true
	}
oddeven(n){
	return mod(n,2)=0?"even":mod(n,2)=1?"odd":""
	}odd(n){
	return mod(n,2)
	}even(n){
	return mod(n,2)=0?"Even":""
	}
IsNot(ByRef var, type) {
	If var is not %type%
		Return, true
	}

Read(Filename){
	fileread, out, %filename%
	return out
	}
CG(Cmd, Value = "", Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	ControlGet, v, %Cmd%, %Value%, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}ControlGetFocus(WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	ControlGetFocus, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}ControlGetText(Control = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	ControlGetText, v, %Control%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}DriveGet(Cmd, Value = ""){
	DriveGet, v, %Cmd%, %Value%
	Return, v
}DriveSpaceFree(Path){
	DriveSpaceFree, v, %Path%
	Return, v
}EnvGet(EnvVarName){
	EnvGet, v, %EnvVarName%
	Return, v
}FileGetAttrib(Filename = ""){
	FileGetAttrib, v, %Filename%
	Return, v
}FileGetShortcut(LinkFile,ByRef OutTarget ="",ByRef OutDir="",ByRef OutArgs="",ByRef OutDescription="",ByRef OutIcon="",ByRef OutIconNum="",ByRef OutRunState=""){
	FileGetShortcut, %LinkFile%, OutTarget, OutDir, OutArgs, OutDescription, OutIcon, OutIconNum, OutRunState
	}FileGetSize(Filename = "", Units = "") {
	FileGetSize, v, %Filename%, %Units%
	Return, v
}FileGetVersion(Filename = "") {
	FileGetVersion, v, %Filename%
	Return, v
}FileRead(Filename){
	FileRead, v, %Filename%
	Return, v
}FileReadLine(Filename, LineNum){
	FileReadLine, v, %Filename%, %LineNum%
	Return, v
}FileSelectFile(Options = "", RootDir = "", Prompt = "", Filter = "") {
	FileSelectFile, v, %Options%, %RootDir%, %Prompt%, %Filter%
	Return, v
}FileSelectFolder(StartingFolder = "", Options = "", Prompt = "") {
	FileSelectFolder, v, %StartingFolder%, %Options%, %Prompt%
	Return, v
}FormatTime(YYYYMMDDHH24MISS = "", Format = "") {
	FormatTime, v, %YYYYMMDDHH24MISS%, %Format%
	Return, v
}GuiControlGet(Subcommand = "", ControlID = "", Param4 = "") {
	GuiControlGet, v, %Subcommand%, %ControlID%, %Param4%
	Return, v
}ImageSearch(ByRef OutputVarX, ByRef OutputVarY, X1, Y1, X2, Y2, ImageFile) {
	ImageSearch, OutputVarX, OutputVarY, %X1%, %Y1%, %X2%, %Y2%, %ImageFile%
}Input(Options = "", EndKeys = "", MatchList = "") {
	Input, v, %Options%, %EndKeys%, %MatchList%
	Return, v
}InputBox(Title = "", Prompt = "", HIDE = "", Width = "", Height = "", X = "", Y = "", Font = "", Timeout = "", Default = "") {
	InputBox, v, %Title%, %Prompt%, %HIDE%, %Width%, %Height%, %X%, %Y%, , %Timeout%, %Default%
	Return, v
}PixelGetColor(X, Y, RGB = "") {
	PixelGetColor, v, %X%, %Y%, %RGB%
	Return, v
}Random(Min = "", Max = "") {
	Random, v, %Min%, %Max%
	Return, v
}RegRead(RootKey, SubKey, ValueName = "") {
	RegRead, v, %RootKey%, %SubKey%, %ValueName%
	Return, v
}RegWrite(ValueType,rootkey,k,v){
	RegWrite,%ValueType%,%rootkey%,%k%,%Test%,%v%
	}SoundGet(ComponentType = "", ControlType = "", DeviceNumber = "") {
	SoundGet, v, %ComponentType%, %ControlType%, %DeviceNumber%
	Return, v
}SoundGetWaveVolume(DeviceNumber = "") {
	SoundGetWaveVolume, v, %DeviceNumber%
	Return, v
}StatusBarGetText(Part = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	StatusBarGetText, v, %Part%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}StringGetPos(ByRef InputVar, SearchText, Mode = "", Offset = "") {
	StringGetPos, v, InputVar, %SearchText%, %Mode%, %Offset%
	Return, v
}StringLeft(ByRef InputVar, Count) {
	StringLeft, v, InputVar, %Count%
	Return, v
}StringLen(ByRef InputVar) {
	StringLen, v, InputVar
	Return, v
}StringLower(ByRef InputVar, T = "") {
	StringLower, v, InputVar, %T%
	Return, v
}StringMid(ByRef InputVar, StartChar, Count , L = "") {
	StringMid, v, InputVar, %StartChar%, %Count%, %L%
	Return, v
}StringReplace(ByRef InputVar, SearchText, ReplaceText = "", All = "") {
	StringReplace, v, InputVar, %SearchText%, %ReplaceText%, %All%
	Return, v
}StringRight(ByRef InputVar, Count) {
	StringRight, v, InputVar, %Count%
	Return, v
}StringTrimLeft(ByRef InputVar, Count) {
	StringTrimLeft, v, InputVar, %Count%
	Return, v
}StringTrimRight(ByRef InputVar, Count) {
	StringTrimRight, v, InputVar, %Count%
	Return, v
}StringUpper(ByRef InputVar, T = "") {
	StringUpper, v, InputVar, %T%
	Return, v
	}
SysGet(Subcommand, Param3 = ""){
 SysGet, v, %Subcommand%, %Param3%
 Return, v
	}
Transform(Cmd, Value1, Value2 = "") {
	Transform, v, %Cmd%, %Value1%, %Value2%
	Return, v
	}
WinGet(Cmd = "", WinTitle = "", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGet, v, %Cmd%, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}WinGetClass(WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetClass, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
}WinGetText(WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetText, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
	}
WGT(WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetTitle, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
	}
WinGetTitle(WinTitle = "A", WinText = "", ExcludeTitle = "", ExcludeText = "") {
	WinGetTitle, v, %WinTitle%, %WinText%, %ExcludeTitle%, %ExcludeText%
	Return, v
	}
WGAT(byref Atitle=""){
	WinGetActiveTitle, v
	return Atitle and !(Atitle=v)?false:v
	}


MM(X,Y="",speed=1,P=""){
	MouseMove, %X%, %Y% , %Speed%, %p%
	speed=c?click():""
	}

GKS(KEY,mode=""){
	GetKeyState, Var, %KEY%, %mode%
	return (var="U")?"":var
	}
KeyWait(KeyName,Opt=""){
	KeyWait,% KeyName ,% Opt
	}
KeyDown(HK,M=""){
	HK:=R(HK,"\{|\}")
	IF !(m="up"){
	t(hk)
	send {%hk% down}
	keywait(a_thishotkey)
	send {%HK% up}
	}else,send {%HK% up}
	; HK:=R(HK,"\{|\}")
	; send {%hk% down}
	; sleep(sleep)
	; send {%hk% up}
	; }
	; SendDU(hk,sleep=10){
	; SR(HK,"{"
	; send {%hk% down}
	; sleep(sleep)
	; send {%hk% up}
	; }
	}
KWait(HK=""){
	static modi:={"#":"LWIN","^":"Ctrl","!":"Alt","+":"Shift"}
	(HK=""?HK:=A_ThisHotkey:""),ret:=r(HK,"i)[#!^+&<>*~$@]|LControl|RControl|LAlt|RAlt|AppsKey|Lwin|Rwin")
	mod:=r(hk,"i)[^(LControl|RControl|LAlt|RAlt|AppsKey|Lwin|Rwin)]","$1")
	Sym:=(r(HK,"i)[^#!^+<>*~$@]")) ;,t(showvars(HK,ret,Sym,mod))
	for k, v in strsplit(Sym){
		if modi.haskey(v)
			v:=modi[v]
	keywait(v,"L")
	}keywait(mod,"L"),keywait(ret)
	}

SendInput(Keys){
	Sendinput % Keys
	return Keys
	}
send(hk,sleep=""){
	send % hk
	}

Callout(Match,CalloutNumber, FoundPos, Haystack, NeedleRegEx){
	version           := NumGet(A_EventInfo,  0, "Int")
	callout_number    := NumGet(A_EventInfo,  4, "Int")
	offset_vector     := NumGet(A_EventInfo,  8)
	subject           := NumGet(A_EventInfo,  8 + A_PtrSize)
	subject_length    := NumGet(A_EventInfo,  8 + A_PtrSize*2, "Int")
	start_match       := NumGet(A_EventInfo, 12 + A_PtrSize*2, "Int")
	current_position  := NumGet(A_EventInfo, 16 + A_PtrSize*2, "Int")
	capture_top       := NumGet(A_EventInfo, 20 + A_PtrSize*2, "Int")
	capture_last      := NumGet(A_EventInfo, 24 + A_PtrSize*2, "Int")
	pad := A_PtrSize=8 ? 4 : 0  ; Compensate for 64-bit data alignment.
	; callout_data      := NumGet(A_EventInfo, 28 + pad + A_PtrSize*2)
	pattern_position  := NumGet(A_EventInfo, 28 + pad + A_PtrSize*3, "Int")
	next_item_length  := NumGet(A_EventInfo, 32 + pad + A_PtrSize*3, "Int")
	if version >= 2
	mark   := StrGet(NumGet(A_EventInfo, 36 + pad + A_PtrSize*3, "Int"), "UTF-8")
	LV()
	LISTVARS
	for k,v in SS(LV2(),"`n"){
	V:=substr(V,1,instr(v,"[")-1)
	if ifequal(V,"O","k","v","") ; if (V="O") or (V="k") or (V="v")
	continue
	O[V]:=(%v%)
	}
	return 1
	}
GetAhkStats(Section=""){
	DetectHiddenWindows, On
	IfEqual Section,, SetEnv Section, Key
	HidWin := WinExist(A_ScriptFullPath " - AutoHotkey v")
	OldPar := DllCall("GetParent", UInt,HidWin)
	GUI +LastFound
	DllCall("SetParent", UInt,HidWin, UInt,WinExist())
	WinMenuSelectItem ahk_id %HidWin%,,View, %Section%
	Sleep 50
	ControlGetText Out1, Edit1, ahk_id %HidWin%
	WinHide ahk_id %HidWin%
	DllCall("SetParent", UInt,HidWin, UInt,OldPar)
	if (section="lines")
	m(out1, ".*`r`n`r`n\K[\s\S]*(?=----.*GetAhkStats.ahk.*)", out1)
	Return Out1
	}
IsNeg(v){
	return mod(v,2)!="" and abs(v)=-v?v " is negative":false
	}

FF_RetrievePageName()
	{
	DllCall("DdeInitializeW","UPtrP",idInst,"Uint",0,"Uint",0,"Uint",0) ; CP_WINANSI = 1004   CP_WINUNICODE = 1200
	hServer := DllCall("DdeCreateStringHandleW","UPtr",idInst,"Str","firefox","int",1200)
	hTopic  := DllCall("DdeCreateStringHandleW","UPtr",idInst,"Str","WWW_GetWindowInfo","int",1200)
	hItem   := DllCall("DdeCreateStringHandleW","UPtr",idInst,"Str","0xFFFFFFFF","int",1200)
	hConv := DllCall("DdeConnect","UPtr",idInst,"UPtr",hServer,"UPtr",hTopic,"Uint",0) ; CF_TEXT = 1 CF_UNICODETEXT = 13
	hData := DllCall("DdeClientTransaction","Uint",0,"Uint",0,"UPtr",hConv,"UPtr",hItem,"UInt",1,"Uint",0x20B0,"Uint",10000,"UPtrP",nResult)
	sData := DllCall("DdeAccessData","Uint",hData,"Uint",0,"str")
	DllCall("DdeFreeStringHandle","UPtr",idInst,"UPtr",hServer)
	DllCall("DdeFreeStringHandle","UPtr",idInst,"UPtr",hTopic)
	DllCall("DdeFreeStringHandle","UPtr",idInst,"UPtr",hItem)
	DllCall("DdeUnaccessData","UPtr",hData)
	DllCall("DdeFreeDataHandle","UPtr",hData)
	DllCall("DdeDisconnect","UPtr",hConv)
	DllCall("DdeUninitialize","UPtr",idInst)
	result:=StrGet(&sData,"cp0")
	return result
	}
MS(var*){
	if !var.MaxIndex() or !var.GetCapacity() or (var[1]="")
	return t(a_thisfunc "fail")
	for i,v in var {
	; if v.list
	; add:=v.list
	; else, if isobject(v)
	; add:=strobj(v)
	; else,{
	add:="",LL:=listlines(a_thisfunc,250),Pos:=1,Ass:="(:=|=|:)"
	RegExMatch(pat,"\((([^()]*+)(?:(?R)(?2))*)\)",M)
	if (Pos:=instr(LL,a_thisfunc "(",0,2)) && (Pos:=RegExMatch(LL,"i)" A_ThisFunc "\((.*)\)",M,pos))
	p:=ss(m1)
	; if !instr(p[i],V) && instr(p[i],"(") && !m(K,Ass V)
	if instr(M1,V) && (regexmatch(m1,"i)([^,]*)" V "[^,]*",K))
	add.="`n" K1 " " (!m(K,Ass V)?":=" V:V)
	else,if !instr(p[i],"(")
	add.="`nP" i " " p[i] ":=" V
	if (foundv:=instr(LL,p[i],0,2)) and (regexmatch(LL,"i)[[:print:]]*" p[i] "[^,\n]*",vmatch,foundv))
	add.="`n" vmatch
	add:=trim(add,"`r`n")
	try msgBox,3, ,% instr(add,V)?ADD:ADD " " V
	IfmsgBox, yes
	continue
	exit
	}}

; WinGetPos( X="X", Y="Y", Width="Width", Height="Height", Title="A", WinText="", ExcludeTitle="", ExcludeText=""){
; WinGetPos,% X,% Y,% Width,% Height,% Title,% WinText,% ExcludeTitle,% ExcludeText
; return
