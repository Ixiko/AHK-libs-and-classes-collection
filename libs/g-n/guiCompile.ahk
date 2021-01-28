/*
Func: guiCompile
    Provides a GUI for scriptCompile()

Parameters:
	SourceScriptFile	-	Optionally specify a script to fill out fields with

Returns:
	Compiled script

Examples:
	guiCompile("e:\myScript.ahk")
*/
guiCompile(SourceScriptFile="") {
	global c_SourceFile, c_DestFile, c_SourceIcon, c_IncludeDir, c_IncludeDirTarget
	
	gui compile: Default
	gui compile: +Hwnd_guiCompile
	
	gui compile: add, groupbox, w470 h125, Required Parameters
	
	gui compile: add, text, xp+5 yp+20 section, Source (.ahk script file)
	gui compile: add, edit, w400 r1 -vscroll -hscroll -wrap -multi vc_SourceFile
	gui compile: add, button, x+5 yp-1 w20 gguiCompile_btnSourceFile, Browse
	
	gui compile: add, text, xs, Destination (.exe file) - Containing directory will be deleted and recreated!
	gui compile: add, edit, w400 r1 -vscroll -hscroll -wrap -multi vc_DestFile
	gui compile: add, button, x+5 yp-1 w20 gguiCompile_btnDestDir, Browse
	
	gui compile: add, groupbox, x10 w470 h170, Optional Parameters
	
	gui compile: add, text, xp+5 yp+20 section, Custom Icon (.ico file)
	gui compile: add, edit, w400 r1 -vscroll -hscroll -wrap -multi vc_SourceIcon
	gui compile: add, button, x+5 yp-1 w20 gguiCompile_btnSourceIcon, Browse
	
	gui compile: add, text, xs, Include Directory
	gui compile: add, edit, w400 r1 -vscroll -hscroll -wrap -multi vc_IncludeDir
	gui compile: add, button, x+5 yp-1 w20 gguiCompile_btnIncludeDir, Browse
	
	gui compile: add, text, xs, Include Directory Target (Directory the compiled script will save the included directory into)
	gui compile: add, ComboBox, w400 vc_IncludeDirTarget, A_ScriptDir|A_Temp
	gui compile: add, button, x+5 yp-1 w20 gguiCompile_btnIncludeDirTarget, Browse
	
	gui compile: add, button, x10 w471 gguiCompile_btnCompile, Compile
	
	If !(SourceScriptFile = "") ; fill out 
		Gosub guiCompile_btnSourceFile
	
	gui compile: show

	WinWaitClose, % "ahk_id " _guiCompile
	gui compile: Destroy
	return
	
	guiCompile_btnSourceFile:
		gui compile: +OwnDialogs
		
		If (SourceScriptFile = "") ; ScriptFile parameter not specified
		{
			FileSelectFile, c_SourceFile, 3, , Open, AutoHotkey files (*.ahk) ; select ScriptFile
			If (c_SourceFile = "")
				return
		}
		else
		{
			c_SourceFile := SourceScriptFile ; use scriptfile from parameter
			SourceScriptFile := "" ; and empty the parameter so the user can manually select a script when _btnSourceFile is clicked
		}
		
		SplitPath, c_SourceFile, , c_SourceFileDir, , c_SourceFileName
			
		GuiControl compile:, c_SourceFile, % c_SourceFile
		GuiControl compile:, c_DestFile, % c_SourceFileDir "\bin" "\" c_SourceFileName ".exe"
		
		If ( InStr( FileExist(c_SourceFileDir "\res"), "D") )
		{
			GuiControl compile:, c_IncludeDir, % c_SourceFileDir "\res"
			GuiControl compile: choose, c_IncludeDirTarget, A_ScriptDir
		}
		else
		{
			GuiControl compile:, c_IncludeDir
			GuiControl compile: choose, c_IncludeDirTarget, |
		}
	return
	
	guiCompile_btnDestDir:
		FileSelectFile, c_DestFile, S3, , Save As, Executable files (*.exe) ; s3 = save button and file+path must exist
		If (c_DestFile = "")
			return
		
		GuiControl compile:, c_DestFile, % c_DestFile ".exe"
	return
	
	guiCompile_btnSourceIcon:
		FileSelectFile, c_SourceIcon, 3, , Open, Icon files (*.ico)
		If (c_SourceIcon = "")
			return
			
		GuiControl compile:, c_SourceIcon, % c_SourceIcon
	return
	
	guiCompile_btnIncludeDir:
		FileSelectFolder, c_IncludeDir, , , Include Directory
		If (c_IncludeDir = "")
			return

		GuiControl compile:, c_IncludeDir, % c_IncludeDir
	return
	
	guiCompile_btnIncludeDirTarget:
		FileSelectFolder, c_IncludeDirTarget, , , Include Directory Target
		If (c_IncludeDirTarget = "")
			return

		GuiControl compile:, c_IncludeDirTarget, % c_IncludeDirTarget
	return
	
	guiCompile_btnCompile:
		gui compile: Submit, Nohide
		
		scriptCompile(c_SourceFile, c_DestFile, c_SourceIcon, c_IncludeDir, c_IncludeDirTarget)
		If (ErrorLevel = 0)
			gui compile: Destroy
	return
}