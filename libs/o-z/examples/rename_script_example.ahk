#include %A_ScriptDir%\..\lib-i_to_z\rename.ahk
rename("AHK_Rename_Test")
openTaskManager := false
if openTaskManager
	run "taskmgr.exe"

msgbox "Hello, you can reload the script from the tray menu or by pressing 'f1'"

f1::reload