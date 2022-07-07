/*

########################
talk v0.6			   #
by Avi Aryan		   #
##################################
Thanks to Autohotkey help file   #
================================ #
Licensed Under MIT License	     #
##################################

Points #

* See the examples to understand better.
  https://dl.dropboxusercontent.com/u/116215806/Products/MoreAHK/talk_examples.7z

* If a script using this function is running as exe, use		script := new talk("ScriptName.exe")	and not just the Scriptname.
* Note that script names are case - sensitive.		For a script named "MyScript" , use   new talk("MyScript")  and not  new talk("myscript")
* setvar() will create the variable in the client script if it does not exist.

*/

/*

Class talk
	Methods
		setVar(var, value, wait:=true)	-	Sets the var in a client script. Optionally waits for the variable to be set
		getVar(var)	-	Gets the value of var in a client script
		runlabel(label, wait:=true)	-	runs a label in a client script. Optionally waits for the label to finish if wait = 1
		suspend(timeinms)	-	suspends a client script for timeinms
		terminate()	-	terminates or exits a client script

	Return Values
		Except getVar() which returns the value, all other function returns whether they were successful or not.
		Values
			Successful = 1
			Communication Request not accepted = 0
			(Client) Script not found = FAIL

*/

class talk
{
	__New(Client){
		if ( Substr(Client, -2) == "exe" )
			this.Script := Client
		else
			this.Script := ( Substr(Client, -2) == "ahk" ) ? Client : Client ".ahk"
		OnMessage(0x4a, "talk_reciever")
	}

	setVar(Var, value, wait:=true){
		StringReplace,value,value,\,\\,All
		T := talk_send(value " \ " A_ScriptName " \ " "setvar" " \ " Var (wait ? "*" : ""), this.Script)
		;uses * as a wait identifier
		if wait
		{
			while !talk.recieved
				sleep, 50
			talk.recieved := ""
		}
		return T
	}
	
	getVar(Var){
		global
		talk_send(var " \ " A_ScriptName " \ " "getvar", this.Script)

		while !talk.recieved
			sleep, 50
		talk.recieved := ""
		return talk.talk
	}

	runlabel(label, wait:=true){
		global
		StringReplace, label, label,\,\\,All
		T := talk_send(label " \ " A_scriptname " \ " "runlabel" " \ " wait, this.Script)
		if wait
		{
			while !talk.recieved
				sleep, 50
			talk.recieved := ""
		}
		return T
	}
	
	suspend(timeinms){
		return talk_send(timeinms " \ " A_scriptname " \ " "suspend", this.Script)
	}
	
	terminate(){
		return talk_send("terminate" " \ " A_scriptname " \ " "terminate", this.Script)
	}
}

talk_reciever(wParam, lParam){
	global
	local Data, Params, ScriptName, What, Param1, tosend, T
	
    Data := StrGet( NumGet(lParam + 2*A_PtrSize) )
	;Structure... Data \ SenderScriptName \ What \ Param1

	Params := Substr(Data, Instr(Data, " \ ")+3) , ScriptName := Substr(Params, 1, Instr(Params, " \ ")-1)
	What := Substr(Params, Instr(Params, " \ ")+3, Instr(Params, " \ ",false,1,2) - Instr(Params, " \ ") - 3)
	Param1 := Substr(Params, -(Strlen(Params) - Instr(Params, " \ ",false,0))+3)

	if what = 
		what := Param1		;incase of getvar
		
	Data := Substr(Data, 1, Instr(Data, " \ ")-1)

	if What = setvar
	{
		StringReplace,Data,Data,\\,\,All
		if Instr(Param1, "*")
			Param1 := Substr(Param1, 1, -1) , T := 1
		%Param1% := Data
		if T
			talk_send("setvar" " \ " A_ScriptName " \ " "talk", ScriptName)
		return
	}
	else if What = getvar
	{
		tosend := %Data%
		StringReplace,tosend,tosend,\,\\,All
		talk_send(tosend " \ " A_ScriptName " \ " "talk", ScriptName)
		return
	}
	else if What = talk
	{
		StringReplace,Data,Data,\\,\,All
		talk.recieved := 1 , talk.talk := Data
		return
	}
	else if What = runlabel
	{
		StringReplace, Data, Data,\\,\,All
		if islabel(Data)
			gosub, %Data%
		if Param1
			talk_send("runlabel" " \ " A_ScriptName " \ " "talk", ScriptName)
		return
	}
	else if What = suspend
	{
		Suspend
		sleep,% Data
		Suspend
		return
	}
	else if What = terminate
		ExitApp
}

talk_send(ByRef StringToSend, ByRef TargetScriptTitle){
    VarSetCapacity(CopyDataStruct, 3*A_PtrSize, 0)
	SizeInBytes := (StrLen(StringToSend) + 1) * (A_IsUnicode ? 2 : 1)
	NumPut(SizeInBytes, CopyDataStruct, A_PtrSize)
	NumPut(&StringToSend, CopyDataStruct, 2*A_PtrSize)
	Prev_DetectHiddenWindows := A_DetectHiddenWindows
	Prev_TitleMatchMode := A_TitleMatchMode
	DetectHiddenWindows On
	SetTitleMatchMode 2
    SendMessage, 0x4a, 0, &CopyDataStruct,, %TargetScriptTitle%
    DetectHiddenWindows %Prev_DetectHiddenWindows%
    SetTitleMatchMode %Prev_TitleMatchMode%
    return ErrorLevel
}