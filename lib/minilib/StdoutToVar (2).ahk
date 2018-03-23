;------------------------------------------------------------------------------
; StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")
; by Sean
;------------------------------------------------------------------------------

/*	Example1
MsgBox % sOutput := StdoutToVar_CreateProcess("ipconfig.exe /all")
*/

/*	Example2 with Streaming
MsgBox % sOutput := StdoutToVar_CreateProcess("ping.exe www.autohotkey.com", True)
*/

/*	Example3 with Streaming and Calling Custom Function	; Custom Function Name must not consist solely of numbers!
MsgBox % sOutput := StdoutToVar_CreateProcess("ping.exe www.autohotkey.com", "Stream")	; Custom Function Name is "Stream" in this example!

Stream(sString)
{
;	Custom Routine here! For example,
;	OutputDebug %sString%
}
*/

/*	Example4 with Working Directory
MsgBox % sOutput := StdoutToVar_CreateProcess("cmd.exe /c dir /a /o", "", A_WinDir)
*/

/*	Example5 with Input String
MsgBox % sOutput := StdoutToVar_CreateProcess("sort.exe", "", "", "abc`r`nefg`r`nhijk`r`n0123`r`nghjki`r`ndflgkhu`r`n")
*/

StdoutToVar_CreateProcess(sCmd, bStream = "", sDir = "", sInput = "")
{
	DllCall("CreatePipe", "UintP", hStdInRd , "UintP", hStdInWr , "Uint", 0, "Uint", 0)
	DllCall("CreatePipe", "UintP", hStdOutRd, "UintP", hStdOutWr, "Uint", 0, "Uint", 0)
	DllCall("SetHandleInformation", "Uint", hStdInRd , "Uint", 1, "Uint", 1)
	DllCall("SetHandleInformation", "Uint", hStdOutWr, "Uint", 1, "Uint", 1)
	VarSetCapacity(pi, 16, 0)
	NumPut(VarSetCapacity(si, 68, 0), si)	; size of si
	NumPut(0x100	, si, 44)		; STARTF_USESTDHANDLES
	NumPut(hStdInRd	, si, 56)		; hStdInput
	NumPut(hStdOutWr, si, 60)		; hStdOutput
	NumPut(hStdOutWr, si, 64)		; hStdError
	If Not	DllCall("CreateProcess", "Uint", 0, "Uint", &sCmd, "Uint", 0, "Uint", 0, "int", True, "Uint", 0x08000000, "Uint", 0, "Uint", sDir ? &sDir : 0, "Uint", &si, "Uint", &pi)	; bInheritHandles and CREATE_NO_WINDOW
		ExitApp
	DllCall("CloseHandle", "Uint", NumGet(pi,0))
	DllCall("CloseHandle", "Uint", NumGet(pi,4))
	DllCall("CloseHandle", "Uint", hStdOutWr)
	DllCall("CloseHandle", "Uint", hStdInRd)
	If	sInput <>
	DllCall("WriteFile", "Uint", hStdInWr, "Uint", &sInput, "Uint", StrLen(sInput), "UintP", nSize, "Uint", 0)
	DllCall("CloseHandle", "Uint", hStdInWr)
	bStream+0 ? (bAlloc:=DllCall("AllocConsole"),hCon:=DllCall("CreateFile","str","CON","Uint",0x40000000,"Uint",bAlloc ? 0 : 3,"Uint",0,"Uint",3,"Uint",0,"Uint",0)) : ""
	VarSetCapacity(sTemp, nTemp:=bStream ? 64-nTrim:=1 : 4095)
	Loop
		If	DllCall("ReadFile", "Uint", hStdOutRd, "Uint", &sTemp, "Uint", nTemp, "UintP", nSize:=0, "Uint", 0)&&nSize
		{
			NumPut(0,sTemp,nSize,"Uchar"), VarSetCapacity(sTemp,-1), sOutput.=sTemp
			If	bStream
				Loop
					If	RegExMatch(sOutput, "[^\n]*\n", sTrim, nTrim)
						bStream+0 ? DllCall("WriteFile", "Uint", hCon, "Uint", &sTrim, "Uint", StrLen(sTrim), "UintP", 0, "Uint", 0) : %bStream%(sTrim), nTrim+=StrLen(sTrim)
					Else	Break
		}
		Else	Break
	DllCall("CloseHandle", "Uint", hStdOutRd)
	bStream+0 ? (DllCall("Sleep","Uint",1000),hCon+1 ? DllCall("CloseHandle","Uint",hCon) : "",bAlloc ? DllCall("FreeConsole") : "") : ""
	Return	sOutput
}
/*
StdoutToVar_CreateProcessCOM(sCmd, bStream = False, sDir = "", sInput = "")
{
	COM_Init()
	pwsh :=	COM_CreateObject("WScript.Shell")
	sDir ?	COM_Invoke(pwsh, "CurrentDirectory", sDir) : ""
	pexec:=	COM_Invoke(pwsh, "Exec", sCmd)
	pid  :=	COM_Invoke(pexec, "ProcessID")
		WinWait, ahk_pid %pid%,,3
	If	bStream
		bAttach:=DllCall("AttachConsole","Uint",pid),pcon:=COM_Invoke(pfso:=COM_CreateObject("Scripting.FileSystemObject"),"GetStandardStream",1),COM_Release(pfso)
	Else	WinHide
	If	sInput <>
	pin  :=	COM_Invoke(pexec, "StdIn"), COM_Invoke(pin, "Write", sInput), COM_Invoke(pin, "Close"), COM_Release(pin)
	pout :=	COM_Invoke(pexec, "StdOut")	; perr := COM_Invoke(pexec, "StdErr")
	Loop
		If	COM_Invoke(pout, "AtEndOfStream")=0
			sOutput.=sTrim:=COM_Invoke(pout, "ReadLine") . "`r`n", bStream ? COM_Invoke(pcon, "Write", sTrim) : ""
		Else	Break
	COM_Invoke(pout, "Close"), COM_Release(pout)
	bStream ? (COM_Invoke(pcon,"Close"),COM_Release(pcon),DllCall("Sleep","Uint",1000),bAttach ? DllCall("FreeConsole") : "") : ""
	Loop
		If	COM_Invoke(pexec, "Status")=0
			Sleep,	100
		Else	Break
;	COM_Invoke(pexec, "Terminate")
	COM_Release(pexec)
	COM_Release(pwsh)
	COM_Term()
	Return	sOutput
}
*/
