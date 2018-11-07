global WM_USER:=1024
global UM_ADDMESSAGE := WM_USER + 0x100
global WH_CALLWNDPROC:=4
global WH_GETMESSAGE:=3
global WM_COMMAND:=273
global hWndTarget
global iThreadIdTarget, hWndLocal, hModule

hook(hWndTarget) {
iThreadIdTarget := DllCall("GetWindowThreadProcessId", "Int", hWndTarget, "Int", 0)
; Install Filter(s)
hModule := DllCall("LoadLibrary", "Str", "hook.dll", "Ptr")
hook := DllCall("hook.dll\InstallFilterDLL", "Int", WH_CALLWNDPROC, "Int", iThreadIdTarget, "Int", hWndTarget) ; 0 = Ok
hookG := DllCall("hook.dll\InstallFilterDLL", "Int", WH_GETMESSAGE, "Int", iThreadIdTarget, "Int", hWndTarget) ; 0 = Ok
if (!hook || !hookG)
{
; Register WM_COMMAND
GUI, +LASTFOUND
;Gui, show
hWndLocal := WinExist()
DllCall("SendMessage", "Int", hWndTarget, "Int" , UM_ADDMESSAGE, "Int", WM_COMMAND, "Int", hWndLocal)
}
else
{
MsgBox failed hook : %hook% hookG %hookG%
DllCall("hook.dll\UnInstallFilterDLL", "Int", iThreadIdTarget, "Int", hWndTarget, "Int", hWndLocal)
DllCall("FreeLibrary" , "Ptr", hModule)
}
}
unhook(hWndTarget)
{
DllCall("hook.dll\UnInstallFilterDLL", "Int", iThreadIdTarget, "Int", hWndTarget, "Int", hWndLocal)
DllCall("FreeLibrary" , "Ptr", hModule)
}