; LintaList Include
; Purpose: Ask & set Desktop & Startup shortcuts
;          Used at startup and can be used via Configuration
; Version: 1.0
; Date:    20101010

SetShortcuts:
Gui, Startup:Add, Text, ,This seems to be the first time you start Lintalist.`nDo you want to:`n
Gui, Startup:Add, Checkbox, vSetStartup, Automatically start Lintalist at start up?
Gui, Startup:Add, Checkbox, vSetDesktop checked, Create a Shortcut on your Desktop?
Gui, Startup:Add, Button, xp+120 yp+40 w100 gStartup, Continue
Gui, Startup:show, , Lintalist setup
ControlFocus, Button3, Lintalist setup
Return

Startup:
Gui, Startup:Submit
Gui, Startup:Destroy
SetStartup_Start:=SetStartup
SetDesktop_Start:=SetDesktop
;IniWrite, %SetStartup%   , %IniFile%, Settings, SetStartup
;IniWrite, %SetDesktop%   , %IniFile%, Settings, SetDesktop

CheckShortcuts:
SplitPath, A_AhkPath, SP_ScriptName
If (SP_ScriptName = "lintalist.exe")
	{
	 FP_Script:=A_AhkPath
	 FP_Args:=""
	} 
Else
	{
	 FP_Script:=A_AhkPath
	 FP_Args:=Chr(34) A_ScriptDir "\lintalist.ahk" Chr(34)
	}

If (SetDesktop = 1)
	{
	 FP_Dir:=A_Desktop
	 Gosub, SetShortcut
	}
else
	FileDelete, %A_Desktop%\lintalist.lnk
If (SetStartup = 1)
	{
	 FP_Dir:=A_Startup
	 Gosub, SetShortcut
	}
else
	FileDelete, %A_Startup%\lintalist.lnk
Return

SetShortcut:
IfExist, %FP_Dir%\lintalist.lnk
 	Return
FileCreateShortcut, %FP_Script%, %FP_Dir%\Lintalist.lnk , %A_ScriptDir%, %FP_Args%, Lintalist, %A_ScriptDir%\icons\lintalist.ico, , , 1
Return