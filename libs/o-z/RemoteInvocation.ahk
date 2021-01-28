; Link:   	https://www.autohotkey.com/boards/viewtopic.php?f=6&t=55165
; Author:	Capn Odin
; Date:
; for:     	AHK_L

; Introduction[hr][/hr]
; I believe this already exists as I thought I would try making it after hearing of a similar library.
; The script can call functions and set global variable in other scripts that also includes RemoteInvocation.
; Limitations: only strings are supported as arguments. Additionally a script that includes this will be persistent.

/* example

	DetectHiddenWindows, On
	SetTitleMatchMode, 2

	Sleep, 1000

	lorem_ipsum =
	(
	Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean fermentum risus id tortor. Integer pellentesque quam vel velit. Praesent id justo in neque elementum ultrices. Nunc tincidunt ante vitae massa. Etiam sapien elit, consequat eget, tristique non, venenatis quis, ante. Duis ante orci, molestie vitae vehicula venenatis, tincidunt ac pede. Maecenas lorem. Nam sed tellus id magna elementum tincidunt. Integer pellentesque quam vel velit. Nullam dapibus fermentum ipsum. Phasellus rhoncus. Etiam dui sem, fermentum vitae, sagittis id, malesuada in, quam.
	)

	loop 30 {
		str .= lorem_ipsum
	}

	InvokeFunction("Function.ahk", "fun", str)

*/

InvokeVariable(title, variable, value) {
	text := variable "=" value
	RemotePost(0x1fe0, text, title)
}

InvokeFunction(title, function, parameters*) {
	text := function "("
	if(parameters.Length()) {
		for i, parameter in parameters {
			text .= StrReplace(parameter, ",", "#¤#") ","
		}
		text := SubStr(text, 1, -1)
	}
	text .= ")"
	RemotePost(0x1fe1, text, title)
}

RemoteInvocationVariable(pID, lParam, msg, hwnd) {
	Critical
	Static __ := OnMessage(0x1fe0, "RemoteInvocationVariable")
	expression := ReadPointer(pID, lParam)
	if(InStr(expression, "=")) {
		args := StrSplit(expression, "=", 2)
		if(args[1] != "") {
			var := RegExReplace(args[1], "\s", "")
			%var% := args[2]
		} else {
			RemotePostError("Can't set a variable without a name", "ahk_pid " pID)
		}
	} else {
		RemotePostError("Malformed argument, lacking an equal sign", "ahk_pid " pID)
	}
}

RemoteInvocationFunction(pID, lParam, msg, hwnd) {
	Critical
	Static __ := OnMessage(0x1fe1, "RemoteInvocationFunction")
	expression := ReadPointer(pID, lParam)
	args := StrSplit(expression, "(", 2)
	if(IsFunc(args[1])) {
		fun := Func(args[1])
		arguments := __RestoreCommas(StrSplit(SubStr(args[2], 1, -1), ","))
		if(fun.MinParams <= arguments.Length() && (fun.IsVariadic || fun.MaxParams >= arguments.Length())) {
			fun.Call(arguments*)
		} else {
			RemotePostError(__FunctionErrorMessage(fun, arguments), "ahk_pid " pID)
		}
	} else {
		RemotePostError("Function """ args[1] """ does not exist", "ahk_pid " pID)
	}
}

__RestoreCommas(arguments) {
	loop % arguments.Length() {
		arguments[A_Index] := StrReplace(arguments[A_Index], "#¤#", ",")
	}
	return arguments
}

__FunctionErrorMessage(fun, arguments) {
	return (arguments.Length() < fun.MinParams ? "Only " : "") arguments.Length() " argument(s) passed to function """ fun.Name """, which expects " fun.MinParams " arguments" (fun.MaxParams - fun.MinParams ? " with additional " fun.MaxParams - fun.MinParams " (optional) argument(s)." : ".")
}

RemoteInvocationError(pID, lParam, msg, hwnd) {
	Critical
	Static __ := OnMessage(0x1fe2, "RemoteInvocationError")
	msg := ReadPointer(pID, lParam)
	DetectHiddenWindows, On
	WinGetTitle, title, % "ahk_pid " pID
	RegExMatch(title, "\\\K[^\\]+.ahk", file)
	MsgBox, 0x30, % "Remote Invocation Error - " A_ScriptName, % "Error: " msg "`nin """ (file ? file : title) """"
}

ReadPointer(pID, lpBaseAddress){
	Static PROCESS_ALL_ACCESS := 0x1F0FFF, nSize := 50
	hProcess := DllCall("OpenProcess", "UInt", PROCESS_ALL_ACCESS, "UInt", True, "UInt", pID)

	VarSetCapacity(lpBuffer, nSize)
	VarSetCapacity(lpNumberOfBytesRead, 8)

	DllCall("ReadProcessMemory", "UPtr", hProcess, "UPtr", lpBaseAddress, "UPtr", &lpBuffer, "UInt", nSize, "UPtr", &lpNumberOfBytesRead)
	msgobj := StrSplit(StrGet(&lpBuffer, "UTF-16"), "#")

	VarSetCapacity(lpBuffer, msgobj[1]+0, 0)
	DllCall("ReadProcessMemory", "UPtr", hProcess, "UPtr", msgobj[2]+0, "UPtr", &lpBuffer, "UInt", msgobj[1]+0, "UPtr", &lpNumberOfBytesRead)
	Return StrGet(&lpBuffer, "UTF-16")
}

RemotePostError(text, title) {
	RemotePost(0x1fe2, text, title)
}

RemotePost(msgNum, text, title) {
	Static mem := "", mem2 := ""
	mem2 := text
	mem := VarSetCapacity(mem2, -1) "#" &mem2
	PostMessage, % msgNum, % GetPID(), % &mem, , % title
}

GetPID() {
	Process, Exist
	return ErrorLevel
}