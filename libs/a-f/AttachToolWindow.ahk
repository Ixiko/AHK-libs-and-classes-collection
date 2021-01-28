AttachToolWindow(hParent, GUINumber, AutoClose)
{
		global ToolWindows
		if(!IsObject(ToolWindows))
			ToolWindows := Object()
		if(!WinExist("ahk_id " hParent))
			return false
		Gui %GUINumber%: +LastFoundExist
		if(!(hGui := WinExist()))
			return false
		;SetWindowLongPtr is defined as SetWindowLong in x86
		if(A_PtrSize = 4)
			DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
		else
			DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", hParent) ;This line actually sets the owner behavior
		ToolWindows.Insert(Object("hParent", hParent, "hGui", hGui,"AutoClose", AutoClose))
		Gui %GUINumber%: Show, NA
		return true
}

DeAttachToolWindow(GUINumber)
{
	global ToolWindows
	Gui %GUINumber%: +LastFoundExist
	if(!(hGui := WinExist()))
		return false
	Loop % ToolWindows.MaxIndex()
	{
		if(ToolWindows[A_Index].hGui = hGui)
		{
			;SetWindowLongPtr is defined as SetWindowLong in x86
			if(A_PtrSize = 4)
				DllCall("SetWindowLong", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
			else
				DllCall("SetWindowLongPtr", "Ptr", hGui, "int", -8, "PTR", 0) ;Remove tool window behavior
			ToolWindows.Remove(A_Index)
		}
	}
}
ToolWindow_ShellMessage(wParam, lParam, msg, hwnd)
{
	global ToolWindows
	if(wParam = 2) ;Window Destroyed
	{
		Loop % ToolWindows.MaxIndex()
		{
			if(ToolWindows[A_Index].hParent = lParam && ToolWindows[A_Index].AutoClose)
			{
				WinClose % "ahk_id " ToolWindows[A_Index].hGui
				ToolWindows.Remove(A_Index)
				if(ToolWindows.MaxIndex() = "") ;No more tool windows, remove shell hook
				{
					if(ToolWindows.Monitor)
						OnMessage(msg, ToolWindows.Monitor)
					else
						DllCall("DeRegisterShellHookWindow", "Ptr", ToolWindows.hAHK)
				}
				break
			}
		}
	}
	if(ToolWindows.Monitor)
	{
		Monitor := ToolWindows.Monitor
		%Monitor%(wParam, lParam, msg, hwnd) ;This is allowed even if the function uses less parameters
	}
}