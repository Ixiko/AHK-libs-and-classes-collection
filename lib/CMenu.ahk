/*
 Function:		CMenu
				Sets context menu for the control.

 Dependencies:
				<ShowMenu> 1.2, <Win> 1.2

 Parameters:
				HCtrl	 - Handle of the control.
				MenuName - Name of the menu, optional.
				Sub		 - Subroutine to be launched, optional.
 
 Globals:
				CMenu	- Holds the menu definitions.
 
 Remarks:
				Parameters and variables of this function are equal to those
				required by Showmenu. The menu for the control is launched as:

 > ShowMenu(CMenu, %Hwnd%_menuName, %Hwnd%_sub)

 About:
		o Version 1.0 by majkinetor.
		o Licensed under BSD <http://creativecommons.org/licenses/BSD/>.
 */
CMenu(HCtrl, MenuName="", Sub="") { 
	oldTrim := A_AutoTrim
	AutoTrim, on
	Sub = %Sub%
	AutoTrim, %oldTrim%

	Win_SubClass(HCtrl, "CMenu_wndProc")
	return CMenu_wndProc(0, Sub, MenuName, HCtrl+0)
} 

CMenu_wndProc(Hwnd, UMsg, WParam, LParam) {
	static 
	global CMenu
	static WM_RBUTTONUP = 0x205

	if !Hwnd  {
		%LParam%_menuName := WParam, %LParam%_sub := Umsg
	}

	If (UMsg = WM_RBUTTONUP) {
		return ShowMenu(CMenu, %Hwnd%_menuName, %Hwnd%_sub)
	}

	return DllCall("CallWindowProcA", "UInt", A_EventInfo, "UInt", hwnd, "UInt", uMsg, "UInt", wParam, "UInt", lParam)
} 

#include *i ShowMenu.ahk
#include *i Win.ahk