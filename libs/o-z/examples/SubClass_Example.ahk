#Include, Subclass.ahk

WM_Copy := 0x301

Gui, Add, Edit, hwndEdithWnd
Gui, Show
Subclass.AddListener(EdithWnd, WM_Copy, "WM_Copy")
return

esc::ExitApp

WM_Copy(Hwnd, Message, wParam, lParam)
{
	ToolTip, % Clipboard
	Exit
}

F1::
Subclass.RemoveListener(MyhWnd, 0x301)
return
