/*
Func: scriptCompile
    Optionally creates include file "fileInstallList.ahk" in "c_SourceFile"'s dir
	and compiles script by running autohotkey's compiler

Parameters:
	c_SourceFile		-	Path to .ahk script to be compiled
	c_DestFile			-	Path for compiled script.exe to be saved to
	c_SourceIcon		-	.icon file for compiled script to use
	c_IncludeDir		-	Directory to be included in the script. Requires line in script: #Include, *i %A_ScriptDir%\fileInstallList.ahk
	c_IncludeDirTarget	-	The directory the compiled script moves the included directory into
							Can also be a path using a built-in autohotkey variable starting with A_ such as
							A_ScriptDir, A_Temp. eg: A_ScriptDir "\myScriptName" or A_ScriptDir

Returns:
	Compiled script

Examples:
    > c_SourceFile := c:\myScript.ahk
    > c_DestFile := c:\myScript\myFolder\myScript.exe
	> c_SourceIcon := d:\images\myScriptIcon.ico
	> c_IncludeDir := c:\myScript\res
	> c_IncludeDirTarget := A_ScriptDir
	
	> scriptCompile(c_SourceFile, c_DestFile, c_SourceIcon, c_IncludeDir, c_IncludeDirTarget)
	=	Folder "c:\myScript\bin" gets deleted if it exists, then recreated
		c:\myScript\fileInstallList.ahk gets deleted if it exists, then recreated with "c:\myScript\res"'s contents
		All instances of AutoHotkey except this one get closed
		Script gets compiled into c:\myScript\myFolder\myScript.exe
		c:\myScript\fileInstallList.ahk gets deleted
*/
scriptCompile(c_SourceFile, c_DestFile, c_SourceIcon="", c_IncludeDir="", c_IncludeDirTarget="") {
	SplitPath, A_AhkPath, , AhkDir
	If !( InStr( FileExist(AhkDir), "D") )
	{
		msgbox compile(): Could not find AutoHotkey installation folder `n`nClosing
		exitapp
	}
	
	If (c_SourceFile = "") or (c_DestFile = "")
	{
		msgbox compile(): One of the required parameter fields is empty
		return ErrorLevel := 1
	}
	
	If !FileExist(c_SourceFile)
	{
		msgbox compile(): Source does not exist
		return ErrorLevel := 1
	}
	
	If !(c_SourceIcon = "")
		If !FileExist(c_SourceIcon)
		{
			msgbox compile(): Custom icon does not exist
			return ErrorLevel := 1
		}
	
	If !(c_IncludeDir = "")
	{
		If !( InStr( FileExist(c_IncludeDir), "D") )
		{
			msgbox compile(): Included directory does not exist
			return ErrorLevel := 1
		}
		
		If (c_IncludeDirTarget = "")
		{
			msgbox compile(): Include Directory Target not specified
			return ErrorLevel := 1
		}
		
		If !InStr(c_IncludeDirTarget, "A_") and !( InStr( FileExist(c_IncludeDirTarget), "D") ) ; c_IncludeDirTarget interpreted as folder
		{
			msgbox compile(): Invalid included directory target
			return ErrorLevel := 1
		}
	}
	
	SplitPath, c_SourceFile, , c_SourceFileDir
	SplitPath, c_DestFile, , c_DestFileDir
	SplitPath, c_IncludeDir, , , , c_IncludeDirName
	SplitPath, c_IncludeDirTarget, , , , , c_IncludeDirTargetDrive
	
	If ( InStr( FileExist(c_DestFileDir), "D") ) ; if destination folder exists
		FileRemoveDir, % c_DestFileDir, 1 ; delete destination folder
	FileCreateDir, % c_DestFileDir ; create destination folder
	
	If !(c_IncludeDir = "") ; create include file from c_IncludeDir
	{
		If FileExist(c_SourceFileDir "\fileInstallList.ahk") ; if fileInstallList.ahk already exists
			FileDelete, % c_SourceFileDir "\fileInstallList.ahk" ; delete it

		If InStr(c_IncludeDirTarget, "A_") and !( InStr( FileExist(c_IncludeDirTargetDrive), "D") ) ; c_IncludeDirTarget interpreted as ahk variable
			FileAppend, % FileInstallList(c_IncludeDir, "`% " c_IncludeDirTarget " ""\" c_IncludeDirName "", 0), % c_SourceFileDir "\fileInstallList.ahk"
		else ; c_IncludeDirTarget interpreted as folder
			FileAppend, % FileInstallList(c_IncludeDir, c_IncludeDirTarget " ""\" c_IncludeDirName "", 0), % c_SourceFileDir "\fileInstallList.ahk"
	}
	
	If !(c_IncludeDir = "") and !FileExist(c_SourceFileDir "\fileInstallList.ahk")
		msgbox % "scriptCompile.ahk: Does not exist:" c_SourceFileDir "\fileInstallList.ahk"
	
	; close all other autohotkey scripts
	DetectHiddenWindows On ; List all running instances of this script:
	WinGet instances, List, ahk_class AutoHotkey
	if (instances > 1) { ; There are 2 or more instances of this script.
		this_pid := DllCall("GetCurrentProcessId"),  closed := 0
		Loop % instances { ; For each instance,
			WinGet pid, PID, % "ahk_id " instances%A_Index%
			if (pid != this_pid) { ; If it's not THIS instance,
				WinClose % "ahk_id " instances%A_Index% ; close it.
				closed += 1
			}
		}
	}
	
	If !(c_SourceIcon = "") ; run ahk compiler
		run "%AhkDir%\Compiler\ahk2exe.exe" /in %c_SourceFile% /out %c_DestFile% /icon "%c_SourceIcon%", , , ahkCompilerPID
	else
		run "%AhkDir%\Compiler\ahk2exe.exe" /in %c_SourceFile% /out %c_DestFile%, , , ahkCompilerPID
	
	WinWaitClose, % "ahk_pid " ahkCompilerPID ; wait till compiler is finished

	If !(c_IncludeDir = "") and FileExist(c_SourceFileDir "\fileInstallList.ahk") ; and if a folder was included
		FileDelete, % c_SourceFileDir "\fileInstallList.ahk" ; cleanup include file
		
	return ErrorLevel := 0
}