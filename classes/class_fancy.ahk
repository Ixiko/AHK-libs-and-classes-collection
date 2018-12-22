/* Fancy(er) control when an unhandled exception is thrown

Link: https://autohotkey.com/boards/viewtopic.php?t=8818
Author: Springwight
Date: 16.07.2015

I wanted my script to show the call stack and some other information when an unhandled exception is thrown (a printout of surrounding lines 
is usually irrelevant for me). Unfortunately, there is no way to override the default message box.

I asked in the Ask For Help forum, and lexikos suggested using a message hook to capture the message box that AHK creates (actually, he suggested 
not to do it ). I did it in the end, and got the behavior I wanted. The result is definitely a hack, but it's a fairly simple one and should work in most situations. 
I'm kind of a novice in this, so any suggestions are welcome. Note that there will be no visible stack trace if the script is compiled.

It's not really possible to have the fancy window pop up if any unhandled exception is thrown, since I have to get the stack trace at the time of the throw, 
so you have to use FancyEx.Throw(...) or FancyEx.ThrowObj(...). 

#include FancyEx.ahk
#SingleInstance, Force

try {
	FancyEx.Throw("No fancy box here.")
}
catch ex {
	MsgBox, % "If you see this box, it means the test passed. This is supposed to throw the hack off a bit: " ex.InstanceGuid
}

Function1() {
	inner := Exception("This is an inner exception that was wrapped")
	FancyEx.Throw("You should see a fancy exception box here.", inner, "Just a regular ol' exception", "This is some extra data!")
}

Function2() {
	Function1()
}

Function3() {
	Function2()
}

Function3()

*/

; Represents an entry in a stack trace.
class StackTraceEntry {
	__New(file, line, function, offset) {
		this.File := File
		this.Line := line
		this.Function := function
		this.Offset := offset
	}
}

; Class primarily for reference, demonstrating the fields FancyEx supports/cares about for exceptions.
; The Extra field is used internally and you shouldn't use it.
; Any additional fields are also printed, using 
class FancyException {
	__New(type, message, innerEx := "", data := "") {
		this.Message := message
		this.InnerException := innerEx
		this.Data := data
		this.Type := type
	}
}

class FancyEx {
	; The default handler for unhandled exceptions, mainly stored here so you can reference it.
	static DefaultUnhandledExceptionHandler := this._openExceptionViewerFor.Bind(this)
	; You can set this to your own handler. Must be a function object that takes 1 parameter, which is the unhandled exception.
	static UnhandledExceptionHandler := FancyEx.DefaultUnhandledExceptionHandler 
	; Turn this off if the fancy form doesn't appear.
	static CheckGwlUserData := true
	static _lastThrownException := ""
	static _isHandlingMessage := false
	static _myPid := ""
	GetStackTrace(ignoreLast := 0) {
		; from Coco in http://ahkscript.org/boards/viewtopic.php?f=6&t=6001
		r := [], i := 0, n := 0
		Loop
		{
			e := Exception(".", offset := -(A_Index + n))
			if (e.What == offset)
				break
			r[++i] := new StackTraceEntry(e.File, e.Line, e.What, offset + n)
		}
		lastEntry:= r[1]
		for ix, entry in r ; I want each entry to contain the *exit location*, not entry location, so it corresponds to part of the function.
		{
			if (ix = 1) {
				continue	
			}
			tmp := lastEntry
			lastEntry := entry.Clone()
			entry.File := tmp.File
			entry.Line := tmp.Line
			entry.Offset := tmp.Offset
		}
		
		r.Insert(new StackTraceEntry(lastEntry.File, lastEntry.Line, " ", lastEntry.Offset))
		
		Loop, % ignoreLast + 1
		{
			r.Remove(1)
		}
		
		return r
	}
	
	; Modifies the specified exception object with stack trace, etc, and then throws it
	; ignoreLastInTrace - don't show the last N callers in the stack trace. Note that FancyEx methods don't appear..
	ThrowObj(ex, ignoreLastInTrace := 0) {
		if (!IsObject(ex)) {
			this.Throw(ex, , , , ignoreLastInTrace + 1)  
			return
		}
		ex.StackTrace := this.GetStackTrace(ignoreLastInTrace + 1)
		ex.What := ex.StackTrace[1].Function
		ex.Offset := ex.StackTrace[1].Offset
		; We're planting a GUID inside the exception to identify its unhandled exception message box later on.
		ex.InstanceGuid := this._getGuid()
		ex.Extra := "FancyException GUID - " ex.InstanceGuid
		ex.Line := ex.StackTrace[1].Line
		
		this._lastThrownException := ex
		Throw ex
	}
	
	; Constructs a new exception with the specified arguments, and throws it. 
	; ignoreLastInTrace - don't show the last N callers in the stack trace. Note that FancyEx methods don't appear.
	Throw(message := "An exception has been thrown.", innerException := "", type := "Unspecified", data := "", ignoreLastInTrace := 0) {
		this.ThrowObj(new FancyException(type, message, innerException, data), ignoreLastInTrace + 1)
	}
	
	; You can use this to print a FancyException
	PrintException(ex) {
		msg:=ex.Message, type:=ex.Type
		type:=type ? type : "Generic"
		msg:=this._indentLines(msg, "`t", 1)
		stackTrace:=""
		if (ex.StackTrace) {
			for ix, entry in ex.StackTrace
			{
				stackTrace.="• " entry.Function " [" entry.File " ln#" entry.Line "]" "`r`n"
			}
		}
		else {
			stackTrace:="Unknown"
		}
		stackTrace:=this._indentLines(stackTrace, "`t", 1)
		data:=""
		if (IsObject(ex.Data)) {
			if (ex.Data.Length() > 0) {
				for key, value in ex.Data
				{
					data.="• " key " = """ value """`r`n"
				}
			}
			else {
				data:="None"
			}
		} else if (ex.Data) {
			data:=ex.Data
		} else {
			data:="None"
		}
		data:=this._indentLines(data, "`t", 1)
		props:=""
		for key, value in ex
		{
			if (key = "StackTrace" || key = "Data" || key = "InnerException" || key = "Message" || key = "Type") {
				continue
			}
			props.="• " key " = """ value """`r`n"
		}
		props:=this._indentLines(props, "`t", 1)
		innerEx:=""
		if (IsObject(ex.InnerException)) {
			innerEx:=this.PrintException(ex.InnerException)
		} else if (ex.InnerException) {
			innerEx:=ex.InnerException
		} else {
			innerEx:="None"
		}
		innerEx:=this._indentLines(innerEx, "`t", 1)
		
		text=
(
Type: %type%
Message: 
%msg%
Stack Trace:
%stackTrace%
Additional Data:
%data%
Other Properties:
%props%
Inner Exception:
%innerEx%
)
	return text
	}
		
	; methods starting with '_' should not be invoked from user code.
	
	_indentLines(str, indent, count) {
		if (!str) {
			return str
		}
		indentStr := ""
		Loop, % count
		{
			indentStr.=indent
		}
		indented := ""
		
		StringReplace, indented, str, `n, `n%indentStr%, All
		indented:=indentStr indented
		return indented
	}
		
	
	_getGuid()
	{ 
		; from https://gist.github.com/ijprest/3845947
	   format = %A_FormatInteger%       ; save original integer format 
	   SetFormat Integer, Hex           ; for converting bytes to hex 
	   VarSetCapacity(A,16) 
	   DllCall("rpcrt4\UuidCreate","Str",A) 
	   Address := &A 
	   Loop 16 
	   { 
		  x := 256 + *Address           ; get byte in hex, set 17th bit 
		  StringTrimLeft x, x, 3        ; remove 0x1 
		  h = %x%%h%                    ; in memory: LS byte first 
		  Address++ 
	   } 
	   SetFormat Integer, %format%      ; restore original format 
	   h := SubStr(h,1,8) . "-" . SubStr(h,9,4) . "-" . SubStr(h,13,4) . "-" . SubStr(h,17,4) . "-" . SubStr(h,21,12)
	   return h
	} 
		
	_openExceptionViewerFor(ex) {
		Gui, FancyEx_ErrorBox: New, , An error has occurred!
		Gui, FancyEx_ErrorBox: +AlwaysOnTop
		Gui, FancyEx_ErrorBox: Font, S10 CDefault, Verdana
		
		Gui, FancyEx_ErrorBox: Add, Text, x12 y9 w240 h20 , An error has occurred in the script:
		Gui, FancyEx_ErrorBox: Add, Edit, x272 y9 w190 h20 ReadOnly, %A_ScriptName%
		
		Gui, FancyEx_ErrorBox: Add, Text, x13 y33 w82 h20 , Error Type:
		Gui, FancyEx_ErrorBox: Add, Edit, x101 y34 w361 h20 ReadOnly, % ex.Type
		
		Gui, FancyEx_ErrorBox: Add, Text, x12 y56 w68 h16 , Message:
		Gui, FancyEx_ErrorBox: Add, Edit, x11 y76 w453 h103 ReadOnly, % ex.Message
		
		Gui, FancyEx_ErrorBox: Add, Text, x11 y183 w180 h18 , Inner Exception Message:
		
		innerExContent := "(No inner exception)"
		
		if (IsObject(ex.InnerException)) {
			innerExContent := ex.InnerException.Message
		} else if (ex.InnerException) {
			innerExContent := ex.InnerException
		}
		Gui, FancyEx_ErrorBox: Add, Edit, x12 y203 w452 h87 ReadOnly, % innerExContent
		
		Gui, FancyEx_ErrorBox: Add, Button, x375 y466 w89 h25 gFancyEx_PressedOk Default, OK
		
		stackTraceLabel:="Stack Trace:"
		if (A_IsCompiled) {
			stackTraceLabel.= " (probably empty because the script is compiled)"
		}
		Gui, FancyEx_ErrorBox: Add, Text, x12 y293 w500 h17 , % stackTraceLabel
		Gui, FancyEx_ErrorBox: Add, ListView, x12 y313 w453 h146 , Pos|Function|File|Ln#|Offset
		Gui, Add, Button, x12 y466 w89 h25 gFancyEx_CopyDetails, Copy Details

		for ix, entry in ex.StackTrace
		{
			SplitPath, % entry.File, filename
			LV_Add("", ix, entry.Function, filename, entry.Line, entry.Offset)
		}
		Loop, 5
		{
			LV_ModifyCol(A_Index, "AutoHdr")
		}
		Gui, FancyEx_ErrorBox: Show, w477 h505
		
		return
	FancyEx_ErrorBoxGuiClose:
	FancyEx_PressedOk:
		Gui, FancyEx_ErrorBox: Cancel
		return
	FancyEx_CopyDetails:
		Clipboard:=FancyEx.PrintException(FancyEx._lastThrownException)
		return
	}
	
	_handleMessage(wParam, lParam) {

		old := A_DetectHiddenWindows
		DetectHiddenWindows, On
		WinGet, pid, PID, ahk_id %lParam%
		if (wParam = 1 && pid = this._myPid) { ; HSHELL_WINDOWCREATED = 1
			if (this._isHandlingMessage) {
				return ; we don't want to process more than one message at a time...
			}
			this._isHandlingMessage := true
			; Means our process opened a window. We gotta check if the window text contains the GUID we planted inside the exception, 
			; and if its GWL_USERDATA attribute equals the empirically determined value 0x0000436F.			
			gwlp_userData:= DllCall("GetWindowLongPtr", "Ptr", lParam, "Int", -21, "Int64") ; -21 = GWLP_USERDATA, gets GWL_USERDATA
			gwlp_userDataInitial:=gwlp_userData >> 8
			WinGetText, text, ahk_id %lParam%
			if (FancyEx._lastThrownException && InStr(text, FancyEx._lastThrownException.InstanceGuid, true) && (!this.CheckGwlUserData || gwlp_userDataInitial = 0x0000436F)) {
				; This HAS to be a correct error window...
				if (this.UnhandledExceptionHandler) {
					; If there is no registered UnhandledExceptionHandler, we don't do anything.
					WinClose, ahk_id %lParam%	
					this.UnhandledExceptionHandler.Call(FancyEx._lastThrownException)
				}
			}
		}
		this._isHandlingMessage := false
		DetectHiddenwindows, % old
	}
	
	_initialize() {
		; the message hook is from: http://www.autohotkey.com/board/topic/32628-tool-shellhook-messages/
		this._myPid:=DllCall("GetCurrentProcessId")
		old := A_DetectHiddenWindows
		DetectHiddenWindows, On
		Hwnd := WinExist("ahk_pid " this._myPid)
		DllCall( "RegisterShellHookWindow", UInt,Hwnd )
		MsgNum := DllCall( "RegisterWindowMessage", Str,"SHELLHOOK" )
		OnMessage( MsgNum, this._handleMessage.Bind(this) )
		DetectHiddenWindows, % old
		this.UnhandledExceptionHandler := this._openExceptionViewerFor.Bind(this)
	}
}

FancyEx._initialize()