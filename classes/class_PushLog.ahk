;
; AutoHotkey Version: 1.1.30.03
; Language:       English
; Platform:       Optimized for Windows 10
; Author:         Sam.
;

;;;;;	Reference Documents	;;;;;
; https://autohotkey.com/docs/commands/FileOpen.htm
; https://docs.microsoft.com/en-us/windows/console/allocconsole
; https://docs.microsoft.com/en-us/windows/console/attachconsole
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;            PushLog             ;;;;;
;;;;;  Copyright (c) 2018-2019 Sam.  ;;;;;
;;;;;     Last Updated 20190502      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;///////////////////////////////////////////////
;//////////////// Class PushLog ////////////////
;///////////////////////////////////////////////
;;; Allows the currently running script to attach to a console window in order to 
;;; 	display debug information including errors, warnings, and other info.
;;; Also has the ability to save this log to a file.
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; New PushLog() ;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Creates a new instance of the class which attaches the script to a console window
;;; 	and opens the SavePath for writing, if applicable.
;;; Syntax:  Instance := New PushLog([AboutInfo="", SavePath="", DebugLevel=1])
;;; AboutInfo defaults to blank but can contain some basic information about the
;;; 	program, its version, copyright info, etc. to display initially.
;;; 	I recommend something like:  "Program v0.00a, Copyright (c) 2019 YourName"
;;; SavePath is the path and file name where anything sent to PushLog can
;;; 	be saved to a log file on disk.  Default is blank (do not save to a file).
;;; DebugLevel specifies what classifications of the information sent to PushLog
;;; 	should be pushed to the console (or saved to file).  Default is 1.
;;; 		Debug Levels:
;;; 		  -1 = very silent (no log)
;;; 		  0 = Silent  (errors only)
;;; 		  1 = Normal  (errors and warnings)
;;; 		  2 = Verbose (errors, warnings, extra info)
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;; Send ;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Pushes strings to the console and/or saves them to a file.
;;; Syntax:  Instance.Send([data="`r`n", DebugClass="", WriteToFile=1])
;;; data is the textual data to push to the console and/or save to a file.
;;; 	Default is a blank line.
;;; DebugClass is the classification of information being pushed.  A
;;; 	DebugClass >= the current DebugLevel will be displayed/saved.
;;; 	The accepted values for DebugClass are:
;;; 		"" (blank) has the highest priority and will be sent if DebugLevel >=0
;;; 		E (Error) will be sent if DebugLevel >=0
;;; 		W (Warning) will be sent if DebugLevel >=1
;;; 		I (Information) will be sent if DebugLevel >=2
;;; 		[any other value] will be sent if DebugLevel >=2
;;; 	If DebugClass is E, W, I, or [any other value], data will be prepended
;;; 		with a classification specifier in the form "  x: " where 'x'
;;; 		is the given DebugClass.  DebugClass may additionally contain a
;;; 		dash (-) to omit this prepended classification specifier.
;;; WriteToFile determines where pushed data that meets or exceeds the DebugLevel
;;; 	is sent.  Default is 1.  Valid values are:
;;; 		0 Displayed on console but not saved to file.
;;; 		1 Displayed on console and saved to file (if specified).
;;; 	   -1 Not displayed on console but saved to file (if specified).
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; ModifySavePath ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Modify the path to where the data sent to PushLog will be saved to disk.
;;; Syntax:  Instance.ModifySavePath([SavePath])
;;; SavePath is the path and file name where anything sent to PushLog can
;;; 	be saved to a log file on disk.  Default is blank (do not save to a file).
;;; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

/*
;Usage syntax is as follows:
Console:=New PushLog("Blank v0.00a, Copyright (c) 2019 me",A_ScriptDir "\log.txt",2)
Console.Send("Some Text`r`nHere...`r`n")
Console.Send("Error:  An Error Occurred`r`n","E")
Console.Send("Warning:  I wanted to warn you`r`n","W")
Console.Send("This has the same DebugClass as a warning, but doesn't include the " Chr(34) "  W: " Chr(34) ".`r`n","-W")
Console.Send("Some extra/verbose info for you.`r`n","I")
Console.DebugLevel:=0 ; Modify the Instance's DebugLevel to that of "Errors Only".
Console.Send("This would have been a warning, but the DebugClass does not meet or exceed the DebugLevel.  Therefore, it will not be sent to the console or saved!`r`n","W")
Console.Send("This text will be displayed in the console but not saved to file.`r`n","-E",0)
Console:=""
*/


class PushLog{
	__New(AboutInfo:="",SavePath:="",DebugLevel:=1){	; AboutInfo:="Blank v0.00a, Copyright (c) 2019 me"
		this.DebugLevel:=DebugLevel
		If (this.DebugLevel<0)
			Return
		this.PushLogNewConsole:=DllCall("AttachConsole","UInt",-1)	; Attaches the calling process to the console of the parent process, if one exists.
		DllCall("AllocConsole")	; Otherwise, allocates a new console for the calling process.
		;~ this.stdin:=FileOpen("*","r `n")	; Open the application's stdin stream in newline-translated mode.
		this.stdout:=FileOpen("*","w `n")	; Open the application's stdout stream in newline-translated mode.
		this.ModifySavePath(SavePath)
		FormatTime, TimeString, ,MMMM dd, yyyy 'at' h:mm.ss tt
		this.Send("`r`n" AboutInfo "`r`nInitializing logging of errors and warnings on " TimeString ".`r`n")	; Send initial info to console
	}
	Send(data:="`r`n",DebugClass:="",WriteToFile:=1){
		If (this.DebugLevel<0)
			Return
		Else If (DebugClass="")
			data:=data ;(this.DebugLevel<>0?data:"")
		Else If InStr(DebugClass,"E")
			data:=(this.DebugLevel>=0?(!InStr(DebugClass,"-")?A_Space A_Space "E:" A_Space data:data):"")
		Else If InStr(DebugClass,"W")
			data:=(this.DebugLevel>=1?(!InStr(DebugClass,"-")?A_Space A_Space "W:" A_Space data:data):"")
		Else If InStr(DebugClass,"I")
			data:=(this.DebugLevel>=2?(!InStr(DebugClass,"-")?A_Space A_Space "I:" A_Space data:data):"")
		Else
			data:=(this.DebugLevel>=2?(!InStr(DebugClass,"-")?A_Space A_Space DebugClass ":" A_Space data:data):"")
		If (data<>"")
			{
			If (WriteToFile>=0)
				{
				this.stdout.Write(data)
				this.stdout.Read(0) ; Flush the write buffer.
				}
			If (this.SavePath<>"") AND (WriteToFile<>0)
				{
				this._OSavePath.Write(data)	; was FileAppend, %data%, % (this.SavePath)
				this._OSavePath.Read(0) ; Flush the write buffer.
				}
			}
	}
	ModifySavePath(SavePath:=""){
		If (SavePath<>this.SavePath) ; It is changing
			{
			this._OSavePath.Close()
			If (this.SavePath:=SavePath)
				{
				try {
					this._OSavePath:=FileOpen(this.SavePath,"a-wd`n")
				} catch e {
					this._OSavePath:=""
					this.Send("`r`n","E")
					this.Send("Error:  Log will not be saved to file because '" SavePath "' could not be opened.`r`n","E")
					}
				}
			}
	}
	__Delete(){
		FormatTime, TimeString, ,MMMM dd, yyyy 'at' h:mm.ss tt
		Log:="Logging terminated on " TimeString ".`r`n"
		If (this.SavePath<>"")
			Log.="A copy of this information has been saved to " Chr(34) (this.SavePath) Chr(34) "." ; Chr(34)="
		this.Send(Log "`r`n`r`n")
		If this.PushLogNewConsole
			this.Send("Press Enter to continue . . .","",0)
		;~ If (this.PushLogNewConsole=1)
			;~ query:=RTrim(this.stdin.ReadLine(), "`n")
		this.stdout.Read(0) ; Flush the write buffer.
		If this.PushLogNewConsole
			this.Send("`r`n`r`n","",0)
		;~ this.stdin.Close()
		this.stdout.Close()
		DllCall("FreeConsole")
		If IsObject(this._OSavePath)
			this._OSavePath.Close()
	}
}
