rename(NewName := "", addMenu := true, reloading:=0) {
	; Original from: https://autohotkey.com/boards/viewtopic.php?f=6&t=21817
	; This version: https://autohotkey.com/boards/viewtopic.php?f=6&t=50183
	; NewName, the new name to use.
	; addMenu, specify true to add a menu item to the tray menu to reload the script. (Makes script persistent)
	; reloading, internal use only, do not pass a value.
	local
	if a_iscompiled
		throw exception(a_thisfunc " doesn't support compiled scripts.")
	if NewName
		NewName .= RegExMatch(NewName,"\.exe$") ? "":".exe"
	else
		NewName := RegExReplace(A_ScriptName,"\.ahk$",".exe") ;-- Grabs current script name (script.ahk)
		
	SplitPath A_AHKPath, Name, AHKDir
	AHKDir .= "\"
	AHK_CB_Dir := AHKDir . NewName 				;-- Appends the current script's name with EXE extension to the AHK path
	AHK_EXE := "AutoHotkey" . (a_ptrsize == 4 ? "U32" : "U64") .  ".exe"
	AHK_AH_Dir := AHKDir . AHK_EXE 				;-- Build default AHK path
	
 	if (Name != NewName || reloading) {			;-- Tests to see if script name matches AHK name
 	
 		FileMove AHK_AH_Dir, AHK_CB_Dir 		;-- Renames AutoHotkey(U32/U64).exe to current script.exe
 		if ErrorLevel { 						;-- Unable to rename?
 			MsgBox  "Unable to rename AutoHotkey.exe"
 			ExitApp
 		}
		if fileExist(AHK_CB_Dir) {												;-- Verifies new AHK executable is in place
 			Run AHK_CB_Dir " " RegExReplace(A_ScriptFullPath,"([ ]+)",'"$1"')	;-- Reloads script via new AHK name
  		} else { 	;-- Unable to run new ahk name? 
  			MsgBox  "Error running " A_ScriptFullPath
  			FileMove AHK_CB_Dir, AHK_AH_Dir
		}
		ExitApp ;-- Ensures rest of code does not run after 
	} else { ;-- AHK path matches script name
		FileMove A_AHKPath, AHKDir . AHK_EXE ;-- Renames AHK back to AutoHotkey(U32/U64).exe
		if ErrorLevel { ;-- Unable to rename?
			; If this happens, you will need to manually rename back your AutoHotkey(U32/U64).exe.
			MsgBox "Unable to rename " NewName
			ExitApp
		}
		reload NewName, addMenu ; Set static variables in reload function.
		; Adds a working reload option to the tray menu.
		if addMenu
			A_TrayMenu.Add("Reload renamed script", func("reload"))
  	}
	return
}
reload(name := "", addMenu := ""){
	; Normal reload does not work.
	static n, a
	if !n {
		n := name, a :=addMenu
		return
	}
	rename(n, a, true)
}