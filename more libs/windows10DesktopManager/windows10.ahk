#SingleInstance

Menu, Tray, icon, %A_ScriptDir%\virtualDesktopManager.ico, 1

if(! A_IsAdmin)
{
    ;dll calls window movers will not work without admin
    Run *RunAs "%A_ScriptFullPath%"  ; Requires v1.0.92.01+
    ExitApp
}
 /*
  * Alternatively you can use the hotkeyManager to set the hotkeys after the JPGIncDesktopManagerClass has been
  * constructed like this
  */
globalDesktopManager := new JPGIncDesktopManagerClass()
globalDesktopManager.setGoToDesktop("Capslock")
    .setMoveWindowToDesktop("+#")
    .afterGoToDesktop("turnCapslockOff")
    .afterMoveWindowToDesktop("turnCapslockOff")
    .setGoToNextDesktop("Capslock & w")
    .setGoToPreviousDesktop("Capslock & q")
    .setMoveWindowToNextDesktop("Capslock & s")
    .setMoveWindowToPreviousDesktop("Capslock & a")
    ;~ .followToDesktopAfterMovingWindow(true)
	;~ .setCloseDesktop("Capslock & x")
	;~ .setNewDesktop("Capslock & n")

return

#c::ExitApp

#Include desktopManager.ahk
#Include desktopChanger.ahk
#Include windowMover.ahk
#Include desktopMapper.ahk
#include virtualDesktopManager.ahk
#Include monitorMapper.ahk
#Include hotkeyManager.ahk
#Include commonFunctions.ahk
#Include dllWindowMover.ahk
