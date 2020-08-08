;
; AutoHotkey Version: 1.1.30.01
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; https://autohotkey.com/docs/commands/Try.htm
; https://autohotkey.com/docs/commands/Throw.htm
; https://autohotkey.com/docs/commands/OnError.htm
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=58389
; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=63130
; utility could be expanded using - https://github.com/Kalamity/classMemory
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;       PS_ExceptionHandler      ;;;;;
;;;;;    Copyright (c) 2019 Sam.     ;;;;;
;;;;;     Last Updated 20190328      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; Include the following line in the auto-execute section of your script ;;;
; OnError("Traceback")

;;; When throwing an exception, it is best to format it as follows:
; throw Exception("We threw an exception",,"Things went wrong...`n`n" Traceback())

;;; Your try/catch blocks should look something like:
;~ try {
	;~ ; Do Stuff
;~ } catch e {
	;~ ExceptionErrorDlg(e)
;~ }


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Here is an example of usage ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
OnError("Traceback")

try {
	func()
} catch e {
	ExceptionErrorDlg(e)
}
ExitApp



func(){
	func2()
}
func2(){
	throw Exception("We threw an exception",,"Things went wrong...`n`n" Traceback())
}


#Include <PS_ExceptionHandler>
*/



;;;;; Core Functions ;;;;;

Traceback(exception:="",actual:=0){
	Local
	i:=0, trace:="", hdr:="Traceback (most recent call last):`n",  n:=actual?0:A_AhkVersion<"2"?1:2
	Loop {
		e:=Exception(".",offset:=-(A_Index+n))
		If (e.What=offset)
			Break
		trace:="  File " Chr(34) e.File Chr(34) ", line " e.Line " called " e.What "()`n" trace
	}
	;MsgBox % trace
	If IsObject(exception)
		{
		If !InStr(exception["Extra"],"Traceback (most recent call last):")
			exception.Extra.="`n`n" hdr trace
		ExceptionErrorDlg(exception)
		Return 1
		}
	Return (hdr trace)
}

ExceptionErrorDlg(Content){
	Local
	Gui, ExcErrDlg:Color, White
	If !IsObject(Content)	; Content is plain text
		Gui, ExcErrDlg:Add, Text, , %Content%
	Else	; Content is an exception object
		{
		Content.Extra.=(!InStr(Content["Extra"],(Str:="Traceback (most recent call last):"))?"`n`n" Str "`n":"") "  File " Chr(34) Content.File Chr(34) ", line " Content.Line  (Content.What<>":="?(Content.What<>""?" in " Content.What:""):"") ":`n"
		;~ Content.Extra.= "  File " Chr(34) Content.File Chr(34) ", line " Content.Line  (Content.What<>":="?" in " Content.What:"") ":`n"
		Contents:="Error: " Content.Message "`n`nSpecifically: " Content.Extra "`n`tLine#`n--->`t" GetScriptLine(Content.Line,Content.File) "`n`nThe current thread will exit."
		Global ExcErrDlgGuiText
		Gui, ExcErrDlg:Add, Text, vExcErrDlgGuiText, %Contents%
		}
	Gui, ExcErrDlg:Add, Button,w100 gExcErrDlgGuiClose, OK
	Gui, ExcErrDlg:Add, Button,w100 x+m yp gExcErrDlgGuiCopyClipboard, Copy to Clipboard
	Gui, ExcErrDlg:+ToolWindow +AlwaysOnTop
	Gui, ExcErrDlg:+HWNDhExcErrDlg
	Gui, ExcErrDlg:Show, , Error!
	WinWaitClose, % "ahk_id " hExcErrDlg
	Return % Contents
}
ExcErrDlgGuiCopyClipboard(){
	Global ExcErrDlgGuiText
	GuiControlGet, tmp, ExcErrDlg:, ExcErrDlgGuiText
	Clipboard:=StrReplace(StrReplace(tmp,"`r",""),"`n","`r`n")
}
ExcErrDlgGuiClose:
	Gui,  ExcErrDlg:Destroy
Return


GetScriptLine(LineNum,LineFile){
	Local
	Line:=""
	If !A_IsCompiled
		FileReadLine, Line, %LineFile%, %LineNum%
	Else
		{
		SourceCode:=GetSourceCode()
		Loop, Parse, SourceCode, `n, `r
			{
			If (A_Index=LineNum+1)
				{
				Line:=A_LoopField
				Break
				}
			}
		}
	Return LineNum ": " Trim(Line," `t")
}

; EXE2AHK by garry
; https://autohotkey.com/boards/viewtopic.php?f=6&t=59015
GetSourceCode(){
	fileObj2:=scanFileForString(A_ScriptFullPath,"; <COMPILER","")
	If IsObject(fileObj2)
		{
		aah:=fileObj2.Read()
		fileObj2.Close()
		}
	Return aah
}

scanFileForString(filePath,searchString,stringEncoding:="UTF-8"){
	VarSetCapacity(pBin,StrPut(searchString,stringEncoding)*((stringEncoding="UTF-16"||stringEncoding="cp1200")?2:1),0)
	searchBinaryLength:=StrPut(searchString,&pBin,StrLen(searchString),stringEncoding)*((stringEncoding="UTF-16"||stringEncoding="cp1200")?2:1)
	Return scanFileForBinary(filePath,pBin,searchBinaryLength,stringEncoding)
}

scanFileForBinary(filePath,ByRef searchBinary,searchBinarylength,FileEncoding:="UTF-8"){
	If !FileExist(filePath)
		Return
	Offset:=0
	fileObj:=FileOpen(filePath,"r")
	Loop
	{
		If (fileObj.ReadUChar()=NumGet(searchBinary,Offset,"UChar"))
			{
			Offset++
			If (Offset=searchBinarylength)
				{
				fileObj.pos-=Offset
				Return fileObj
				}
			}
		Else If (offset)
			fileObj.pos-=(Offset-1), Offset:=0
	}Until fileObj.AtEOF
}
