; Title:
; Link:		https://raw.githubusercontent.com/482F/flax_ahk/80e53e49f3a4a5d81b06335a15e14a66dfe0e36a/includes/.flax_func.ahk
; Author:
; Date:
; for:     	AHK_L

/*


*/

RevStr(Str){
    RetStr := ""
	Loop,Parse,Str
	{
		RetStr := A_LoopField . RetStr
	}
	return,RetStr
}
EvalLogic(Formula){
	Formula := RegExReplace(Formula,"\s","")
	BP := RetCorBracket(Formula)
	if (BP["S"] != "")
	{
		BV := RetCorBracketSplit(Formula)
		return EvalLogic(BV[0] . EvalLogic(BV[1]) . BV[2])
	}
	StringGetPos,K,Formula,not
	if K != -1
	{
		if (SubStr(Formula,K + 4,1) == 1)
			L = 0
		else
			L = 1
		return EvalLogic(SubStr(Formula,1,K) . L . SubStr(Formula,K + 5,StrLen(Formula)))
	}
	StringGetPos,K,Formula,imp
	if K != -1
	{
		return EvalLogic(SubStr(Formula,1,K - 1) . "not" . SubStr(Formula,K,1) . "or" . SubStr(Formula,K + 4, StrLen(Formula)))
	}
	StringGetPos,K,Formula,and
	if K != -1
	{
		StringMid,K1,Formula,K,,L
		StringMid,K2,Formula,K+4
		return (EvalLogic(K1) == 1 and EvalLogic(K2) == 1)
	}
	StringGetPos,K,Formula,or
	if K != -1
	{
		StringMid,K1,Formula,K,,L
		StringMid,K2,Formula,K+3
		return (EvalLogic(K1) == 1 or EvalLogic(K2) == 1)
	}
	return Formula
}
EvalForm(Formula,mode="normal"){
	Formula := RegExReplace(Formula,"\s","")
	StringLeft,K,Formula,1
	if (K == "f")
	{
		StringTrimLeft,Formula,Formula,1
		return EvalForm(Formula,"frac")
	}
	if (mode == "normal")
	{
		if Formula is number
		{
			return Formula
		}
		BP := RetCorBracket(Formula)
		BV := RetCorBracketSplit(Formula)
		If (BV[1] != "")
		{
			return EvalForm(BV[0] . EvalForm(BV[1]) . BV[2])
		}
		StringGetPos,K,Formula,+
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) + EvalForm(K2)
		}
		StringGetPos,K,Formula,-
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) - EvalForm(K2)
		}
		StringGetPos,K,Formula,*
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) * EvalForm(K2)
		}
		StringGetPos,K,Formula,/
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) / EvalForm(K2)
		}
		StringGetPos,K,Formula,^
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) ** EvalForm(K2)
		}
		return Error
	}
	else if(mode == "frac")
	{
		sign = 0
		K := RegExMatch(Formula,"^\d*\/\d*$")
		if (K == 1)
		{
			K := RetAoT(Formula,"/",0)
			G := RetGCF(K[0],K[1])
			return round(K[0] / G) . "/" . round(K[1] / G)
		}
		StringGetPos,K,Formula,+
		if (K != -1)
		{
			L := RetAoT(Formula,"+",0)
			sign := 1
		}
		StringGetPos,K,Formula,-
		if (K != -1)
		{
			L := RetAoT(Formula,"-",0)
			sign := -1
		}
		if (sign == 1 or sign == -1)
		{
			K1 := RetAoT(EvalForm(L[0],mode),"/",0)
			K2 := RetAoT(EvalForm(L[1],mode),"/",0)
			L := RetLCM(K1[1], K2[1])
			K1[0] := K1[0] / K1[1] * L
			K2[0] := K2[0] / K2[1] * L
			K1[0] := K1[0] + K2[0] * sign
			return EvalForm(round(K1[1]) . "/" . L,mode)
		}
		StringGetPos,K,Formula,*
		if (K != -1)
		{
			L := RetAoT(Formula,"*",0)
			K1 := RetAoT(EvalForm(L[0],mode),"/",0)
			K2 := RetAoT(EvalForm(L[1],mode),"/",0)
			return EvalForm(round(K1[0] * K2[0]) . "/" . round(K1[1] * K2[1]),mode)
		}
	}
	return
}
proofreadingratwikireg(Text,Rule){
	StringGetPos,BR,Text,\begin{flaxconstant}
	StringGetPos,ER,Text,\end{flaxconstant}
	msgjoin(text)
	If (BR != -1 and ER != -1)
	{
		StringLen,Len,Text
		StringMid,TText,Text,1,% BR
		StringMid,MText,Text,% BR + 21,% ER - (BR + 20)
		StringMid,BText,Text,% ER + 19,% Len
		TText := proofreadingratwikireg(TText,Rule)
		BText := proofreadingratwikireg(BText,Rule)
		Text := TText . MText . BText
		return Text
	}
	else
	{
		;msgbox,% Text
		Loop,Parse,Rule,`n
		{
			LoopField = %A_LoopField%:::flaxdelimiter:::
			StringReplace,LoopField,LoopField,`n,:::flaxnewline:::,All
			StringReplace,LoopField,LoopField,:::flaxdelimiter:::,`n,All
			StringSplit,NowRule,LoopField,`n
			NowRule1 := "S)" . NowRule1
			StringReplace,NowRule2,NowRule2,\n,`n,All
			StringReplace,LoopField,LoopField,:::flaxnewline:::,`n,All
			Text := RegExReplace(Text,NowRule1,NowRule2)
			;msgbox,% Text "`n" NowRule1 "`n" NowRule2
		}
		return Text
	}
	return
}
screenshot_full(dest_path){
    screenshot(dest_path, 0, 0, A_ScreenWidth, A_ScreenHeight)
    return
}
screenshot(dest_path, sx, sy, ex, ey){
    w := ex - sx
    h := ey - sy
    CmdRun("tools\nircmd.exe savescreenshot """ . dest_path . """ " . sx . " " . sy . " " . w . " " . h, 0)
    return
}
NumToAlp(Num){
	if (26 < Num)
	{
		return "ERROR"
	}
	return Chr(Num + 96)
}
RetCorBracket(Str,Index=1,Offset=0, Target="()"){
	Target_B := SubStr(Target, 1, 1)
	Target_E := SubStr(Target, 2, 1)
	StringGetPos,BSP,Str,%Target_B%,L%Index%,%Offset%
	SSP := BSP
	Index = 1
	while (True)
	{
		StringGetPos,BEP,Str,%Target_E%,,% SSP + 1
		StringGetPos,SSP,Str,%Target_B%,,% SSP + 1
		if (SSP < BEP and SSP != -1)
		{
			Index += 1
			continue
		}
		else if (BEP != -1)
		{
			Index -= 1
			SSP := BEP
			if (Index = 0)
			{
				return Object("S", BSP, "E", BEP)
			}
			continue
		}
		return
	}
}
RetCorBracketSplit(Str,Index=1,Offset=0, Target="()"){
	BP := RetCorBracket(Str, Index, Offset, Target)
	return Object(0, SubStr(Str,1,BP["S"]), 1, SubStr(Str,BP["S"] + 2, BP["E"] - BP["S"] - 1), 2, SubStr(Str,BP["E"] + 2,StrLen(Str)))
}
JoinStr(params*){
    str := ""
	for index,param in params
		str .= AlignDigit(A_Index, 3) . "  :  " . param . "`n"
	return SubStr(str, 1, -StrLen("`n"))
}
AlignDigit(Value, NoD){
	Loop,% NoD - StrLen(Value)
	{
		Value := "0" . Value
	}
	return Value
}
MsgJoin(Strs*){
	Msg := JoinStr(Strs*)
	Msgbox,% Msg
}
RetFuncArgument(Str,FuncName,Index=1,Offset=0){
	StringGetPos,FP,Str,%FuncName%,L%Index%,%Offset%
	AP := RetCorBracket(Str,Index,FP)
	if (FP + StrLen(FuncName) == AP["S"])
	{
		AV := RetCorBracketSplit(Str,Index,FP)
		return StrSplit(AV[1],"`,")
	}
	return
}
RetAoT(Str,Target,Length=1,Index=1,Offset=0){
	StringGetPos,TP,Str,%Target%,L%Index%,%Offset%
	FSP := TP - Length + 1
	LengthB := Length
	if ((TP + 1 < Length) or (Length == 0))
	{
		Length := TP
		LengthB := StrLen(Str)
	}
	return Object(0,SubStr(Str,TP - Length + 1,Length),1,SubStr(Str,TP + StrLen(Target) + 1,LengthB))
}
RetObjIndex(Value, Obj*){
	for K in Obj
	{
		if (K == Value)
			return A_Index
	}
	return "Error"
}
SearchPrime(Limit){
	Primes := Object()
	if (2 <= Limit)
		Primes[1] := 2
	if (3 <= Limit)
		Primes[2] := 3
	NN = 3
	IoP = 3
	while True
	{
		NN += 2
		if (Limit < NN)
			break
		for K, Prime in Primes
		{
			if ((NN ** 2 < Prime) or (Mod(NN,Prime) == 0))
			{
				NF = 1
				break
			}
		}
		if (NF)
		{
			NF = 0
			continue
		}
		Primes[IoP] := NN
		IoP += 1
	}
	return Primes
}
RetGCF(K, L){
	if (K < L)
	{
		Swap := K
		K := L
		L := Swap
	}
	if (K - L == 0)
	{
		return K
	}
	else
	{
		return RetGCF(K - L, L)
	}
	return
}
RetLCM(K, L){
	G := RetGCF(K, L)
	SetFormat,Float,0.0
	G := K * L / G
	SetFormat,Float,0.5
	return G
}
FillStr(Str, NoD, Char, RL="L"){
	if (RL == "L")
	{
		Loop,% NoD - StrLen(Str)
			Str := Char . Str
	}
	else (RL == "R")
	{
		Loop,% NoD - StrLen(Str)
			Str := Str . Char
	}
	return Str
}
Hex2Dec(Value, NoD=0){
	K := Object(0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, "A", 10, "B", 11, "C", 12, "D", 13, "E", 14, "F", 15)
	L := 0
	Loop,Parse,Value
	{
		RMN := StrLen(Value) - A_Index
		L +=  K[A_LoopField] * 16 ** RMN
	}
	return FillStr(L, NoD, 0)
}
Dec2Hex(Value, NoD=0){
	K := Object(0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, "A", 11, "B", 12, "C", 13, "D", 14, "E", 15, "F")
    if (Value == "")
        return
	else if (Value != 0)
		return FillStr(Dec2Hex(Value // 16, 0) . K[mod(Value, 16)], NoD, 0)
	return
}
MsgVars(VarList){
	Str := ""
	Loop,Parse,VarList,`,
	{
		Str .= A_Index . " : " . A_LoopField . " > " . %A_LoopField% . "`n"
	}
	msgbox,%Str%
	return
}
CmdRun(Command,msg=1, auth="normal"){
    global number_of_cmd
    number_of_cmd += 1
    filepath := A_ScriptDir . "\cmdtemp\" . A_NowUTC . A_MSec . number_of_cmd
	if (auth = "normal")
		auth := ""
	else if (auth = "admin")
		auth := "*RunAs "
	runwait,% auth . comspec . " /c " . Command . " > " . filepath . " 2>&1",, Hide
    result_file := new AFile(filepath, "CP932")
    result_file.read()
    result := result_file.text
    result_file.delete()
	if (ErrorLevel and msg)
		msgjoin("Error", result)
	else if (not(ErrorLevel)){
		return result
	}
	return
}
RetMousePos(){
	MouseGetPos,X,Y
	return Object("X", X, "Y", Y)
}
RetPointsDist(M1, M2){
	return ((M1["X"] - M2["X"]) ** 2 + (M1["Y"] - M2["Y"]) ** 2) ** (1/2)
}
RetKeyState(KeyName,Mode="P"){
	GetKeyState,K,%KeyName%,%Mode%
	return K == "D" ? 1 : 0
}
atan2(X1, Y1, X2, Y2){
	if (X1 == X2)
	{
		if (Y1 < Y2)
			K := Pi / 2
		else if (Y2 < Y1)
			K := 3 * Pi / 2
		else
			K := 0
	}
	else
	{
		K := ATan((Y2 - Y1) / (X2 - X1))
		if (X2 < X1)
		{
			K += Pi
		}
		else if (Y2 < Y1)
		{
			K += 2 * Pi
		}
	}
	return K
}
ToolSplash(Text=""){
	if (Text == ""){
		SplashImage,Off
		return
	}
	MouseGetPos,X,Y
	WinGetPos,WX,WY,,,a
	X += WX
	Y += WY
	SplashImage,,B FM10 X%X% Y%Y%,,%Text%
	return
}
JoinObj(Obj, Depth=0){
	if not(IsObject(Obj))
		return Obj
    Str := ""
	for Key, Value in Obj{
		IoI := A_Index
		Loop,% Depth{
			if (IoI == 1)
				continue
			Str .= "     "
		}
		Str .= Key . " : " . JoinObj(Value, Depth + 1) . "`n"
	}
	return Str
}
RetAllMatch(Target, Pattern){
	AllMatch := Object()
	Pos := 0
	while (True){
		CurMatch := Object()
        RegExReplace(Pattern, "\(", "", NoR)
        NoR += 1
        Loop, %NoR%
        {
            Match%A_Index% := ""
        }
		Pos := RegExMatch(Target, Pattern, Match)
        if (ErrorLevel != 0 or Match == ""){
            break
        }
		if (Pos == 0)
			break
		while (Match%A_Index% != ""){
			CurMatch[A_Index] := Match%A_Index%
		}
		AllMatch[A_index] := CurMatch
		Target := RegExReplace(Target, ".*?" . Pattern,"" , , 1)
	}
	return AllMatch
}
KeyDown(Key, Second){
	send,{%Key% down}
	CalledTime := A_TickCount
	EscFlag := False
	while (True){
		if ((Second * 1000) < (A_TickCount - CalledTime) or RetKeyState("Esc"))
			break
		sleep 1000
	}
	send,{%Key% up}
	return
}
RetNCKey(Obj, Key){
	if (Obj[Key] == "")
		return Key
	while (True){
		if (Obj[Key . A_Index] == "")
			return Key . A_Index
	}
}
RetMaxDepth(Obj, Depth=1){
	MaxDepth := Depth
	for Key, Value in Obj{
		if (IsObject(Value)){
			K := RetMaxDepth(Value, Depth + 1)
			if MaxDepth < K
				MaxDepth := K
		}
	}
	return MaxDepth
}
SolveObj(Obj){
	msgbox,% JoinObj(Obj)
	if (IsObject(Obj))
		return Obj
	RObj := Object()
	for Key, Value in Obj{
			RObj[RetNCKey(RObj, Key)] := Value
	}
	return SolveObj(RObj)
}
JudgePath(Path){
	return RegExMatch(Path, "^([a-zA-Z]:\\([^\\/:?*""<>|]+\\)*)([^\\/:?*""<>|]+)?$")
}
SolvePath(Path){
	RegExMatch(Path, "([a-zA-Z]:\\([^\\/:?*""<>|]+\\)*)([^\\/:?*""<>|]+)?", APath)
	K := Object()
	K["Path"] := APath1
	K["Name"] := APath3
	return K
}
RapidButton(Button){
	while (not RetKeyState("Esc"))
		send, %Button%
}
RetCopy(param="Value", SecondsToWait=""){
	Clip := ClipboardAll
	Clipboard := ""
	send,^c
	ClipWait, %SecondsToWait%
	if (param = "Text")
		Clipboard := Clipboard
	Var := Clipboard
	Clipboard := Clip
	return Var
}
GetCurrentDirectory(){
	WinGetTitle, CDPath, A
	if (JudgePath(CDPath) == 0){
		return "Error"
	}
	return CDPath
}
JudgeDir(Path){
	return (InStr(FileExist(Path), "D") != 0)
}
PythonRun(Path, msg=1, auth="normal", args*){
	command := "python " . Path . " "
	for arg in args
	{
		command .= arg . " "
	}
	return CmdRun(command, msg, auth)
}
Follow_a_Link(Path){
	While (RegExMatch(Path, "\.lnk$") != 0){
		FileGetShortcut, %Path%, FilePath
		Path := FilePath
	}
	return Path
}
DeepCopy(Array, Objs=0){
	if !Objs
		Objs := Object()
	Obj := Array.Clone()
	Objs[&Array] := Obj
	For Key, Value in Obj{
		if (IsObject(Value))
			Obj[Key] := Objs[&Value] ? Objs[&Value] : DeepCopy(Value, Objs)
	}
	return Obj
}
msgobj(obj){
	msgjoin(joinobj(obj))
	return
}
RetRLDU(Radian){
	if (15/8 < Radian or Radian <= 1/8)
		return "R"
	if (1/8 < Radian and Radian <= 3/8)
		return "BDR"
	if (3/8 < Radian and Radian <= 5/8)
		return "D"
	if (5/8 < Radian and Radian <= 7/8)
		return "BDL"
	if (7/8 < Radian and Radian <= 9/8)
		return "L"
	if (9/8 < Radian and Radian <= 11/8)
		return "BUL"
	if (11/8 < Radian and Radian <= 13/8)
		return "U"
	if (13/8 < Radian and Radian <= 15/8)
		return "BUR"
	return
}
RetMPatan2(MP1, MP2){
	return atan2(MP1["X"], MP1["Y"], MP2["X"], MP2["Y"])
}
GestureCandidate(MR, gFD){
	route := MR.route
	reg := MR.Reg
	CommandCandidate := ""
	For Key, Value in gFD.dict{
		if (InStr(Key, route) == 1 and gFD.dict[Key]["label"] != "" and gFD.dict[Key]["command"] != ""){
			CommandLabel := gFD.dict[Key]["label"]
			CandiName := SubStr(Key, StrLen(route) + 1, StrLen(Key))
			CandiValue := CandiName == "" ? "" : " : "
			CandiValue .= CommandLabel
			For, Pattern, Replacement in reg
				CandiName := RegExReplace(CandiName, Pattern, Replacement)
			CommandCandidate .= CandiName . CandiValue . "`n"
		}
	}
	CommandCandidate := CommandCandidate == "" ? "None" : CommandCandidate
	return CommandCandidate
}
EvalConfig(cFD){
	for Key, Value in cFD.dict["ChangeHotkey"]{
		HotKey, IfWinActive
		for SubCommand, Parameter in Value{
			if (SubCommand == "Key")
				continue
			HotKey, %SubCommand%, %Parameter%
		}
		Value := Value["Key"]
		if (Value != "Off")
			HotKey, %Value%, %Key%
		HotKey, %Key%, Off
	}
	return
}
GetMP3TagsFunc(FilePath){
	command := """""" . A_ScriptDir . "\tools\go_id3.exe"" get """ . FilePath . """"""
	Tags := CmdRun(command)
    StringReplace, Tags, Tags, `r, , A
	Tags := StrSplit(Tags, "`n")
	return Tags
}
EditMP3TagsFunc(FilePath, data_dict, new_name){
	SplitPath, FilePath, FileName, FileDir
    is_same := 0
    NoK := 0
    for key, value in data_dict{
        if (key == "title" or key == "album" or key == "artist"){
            NoK += 1
        }
    }
    while (is_same != NoK){
        is_same := 0
        command := """""" . A_ScriptDir . "\tools\go_id3.exe"" set """ . FilePath . """ "
        ntags := GetMP3TagsFunc(FilePath)
        tags := Object()
        tags["title"] := ntags[1]
        tags["artist"] := ntags[2]
        tags["album"] := ntags[3]
        for key, value in data_dict{
            if (key != "title" and key != "album" and key != "artist"){
                continue
            }
            if (tags[key] == value){
                is_same += 1
            }
            command .= key . " """ . value . """ "
        }
        command .= """"
        result := CmdRun(command)
    }
	FileMove, %FilePath%, %FileDir%\%new_name%
	return result
}
GetLastUpdate(FilePath){
	FileGetTime, LU, %FilePath%, M
	return LU
}
CheckLastUpdate(FilePath, LastUpdate){
	FileGetTime, LU, %FilePath%, M
	if (LU == LastUpdate)
		return 0
	return LU
}
MakeSymbolicLink(Source, Dest){
	SplitPath, FilePath, FileName
	param := ""
	if (JudgeDir(Source))
		param := "/d"
	command := "mklink " . param . " """ . Dest . """ """ . Source . """"
	msgjoin(CmdRun(command, 0, "admin"))
	return
}
GetProcessName(){
	WinGet,AWPN,ProcessName,A
	return AWPN
}
GetProcessPath(){
	WinGet,AWPP,ProcessPath,A
	return AWPP
}
AGUIClose(GuiHwnd){
	AGui.HwndDict[GuiHwnd].close()
	return
}
AGUIEscape(GuiHwnd){
	AGui.HwndDict[GuiHwnd].escape()
	return true
}
AGuiSize(GuiHwnd){
    AGui.HwndDict[GuiHwnd].size()
    return
}
AGuiDropFiles(GuiHwnd){
    AGui.HwndDict[GuiHwnd].dropfiles()
    return
}
AGuiContextMenu(GuiHwnd){
    AGui.HwndDict[GuiHwnd].contextmenu()
    return
}
testmsg(strs*){
	Msg := "line: " . A_LineNumber . "`n`n" .  JoinStr(Strs*)
	Msgbox,% Msg
}
nircmd_mute(process_name, mode){
    CmdRun("tools\nircmd.exe muteappvolume """ . process_name . """ " . mode, 0)
    return
}
reg_test(){
    global configFD
    global reg_test_gui
    configFD.read()
    reg_test_gui := new AGui()
    reg_test_gui.Font("S" . configFD.dict["Font"]["Size"], configFD.dict["Font"]["Name"])
    reg_test_gui.add_agc("Text", "target_text", "section", "target")
    reg_test_gui.add_agc("Edit", "target", "multi w300 r10")
    reg_test_gui.add_agc("Text", "pattern_text", , "pattern")
    reg_test_gui.add_agc("Edit", "pattern", "multi w300 r10")
    reg_test_gui.add_agc("Text", "replacement_text", , "replacement")
    reg_test_gui.add_agc("Edit", "replacement", "multi w300 r10")
    reg_test_gui.add_agc("Text", "startingpos_text", , "startingpos")
    reg_test_gui.add_agc("Edit", "startingpos")
    reg_test_gui.add_agc("Text", "limit_text", , "limit")
    reg_test_gui.add_agc("Edit", "limit")

    reg_test_gui.add_agc("Text", "rem_ret_text", "section ys xs+310", "RegExMatch return value")
    reg_test_gui.add_agc("Edit", "rem_ret", "multi w300 r10")
    reg_test_gui.add_agc("Text", "rem_opv_text", , "RegExMatch OutputVar")
    reg_test_gui.add_agc("Edit", "rem_opv", "multi w300 r10")
    reg_test_gui.add_agc("Text", "rem_err_text", , "RegExMatch ErrorLevel")
    reg_test_gui.add_agc("Edit", "rem_err", "multi w300 r10")
    reg_test_gui.add_agc("Text", "rer_ret_text", "section ys xs+310", "RegExReplace return value")
    reg_test_gui.add_agc("Edit", "rer_ret", "multi w300 r10")
    reg_test_gui.add_agc("Text", "rer_opv_text", , "RegExReplace OutputVarCount")
    reg_test_gui.add_agc("Edit", "rer_opv", "multi w300 r10")
    reg_test_gui.add_agc("Text", "rer_err_text", , "RegExReplace ErrorLevel")
    reg_test_gui.add_agc("Edit", "rer_err", "multi w300 r10")
    reg_test_gui.add_agc("Text", "ram_ret_text", "ys xs+310", "RetAllMatch return value")
    reg_test_gui.add_agc("Edit", "ram_ret", "multi w300 r10")

    reg_test_gui.target.method := "reg_test_edit_changed"
    reg_test_gui.pattern.method := "reg_test_edit_changed"
    reg_test_gui.replacement.method := "reg_test_edit_changed"
    reg_test_gui.startingpos.method := "reg_test_edit_changed"
    reg_test_gui.limit.method := "reg_test_edit_changed"
    reg_test_gui.show("autosize")
    return
}
reg_test_edit_changed(){
    global reg_test_gui
    reg_test_gui.submit("nohide")
    target := reg_test_gui.target.value
    pattern := reg_test_gui.pattern.value
    replacement := reg_test_gui.replacement.value
    startingpos := reg_test_gui.startingpos.value
    if (startingpos == ""){
        startingpos := 1
    }
    limit := reg_test_gui.limit.value
    if (limit == ""){
        limit := -1
    }
    rer_opv := ""
    rem_opv := ""
    rer_ret := RegExReplace(target, pattern, replacement, rer_opv, limit, startingpos)
    rer_err := ErrorLevel
    rem_ret := RegExMatch(target, pattern, rem_opv, startingpos)
    rem_err := ErrorLevel
    ram_ret := ""
    ram_ret := joinobj(RetAllMatch(target, pattern))
    reg_test_gui.rer_ret.Text(rer_ret)
    reg_test_gui.rer_opv.Text(rer_opv)
    reg_test_gui.rer_err.Text(rer_err)
    reg_test_gui.rem_ret.Text(rem_ret)
    reg_test_gui.rem_opv.Text(rem_opv)
    reg_test_gui.rem_err.Text(rem_err)
    reg_test_gui.ram_ret.Text(ram_ret)
    return
}
push_key(key, time=100){
    send, {%key% down}
    sleep, %time%
    send, {%key% up}
    return
}
read_font_from_config(name=""){
    global configFD
    configFD.read()
    font := configFD.dict["Font"]
    if (name != "" and configFD.dict.font.haskey(name)){
        font := configFD.dict["Font", name]
    }
    return font
}
is_zero(target){
    return True ? target == 0 : False
}
is_not_minus_one(target){
    return True ? target != -1 : False
}
switch_key(key){
    if retkeystate(key, ""){
        send, {%key% up}
    }else{
        send, {%key% down}
    }
}