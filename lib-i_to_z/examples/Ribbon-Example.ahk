#NoEnv
#Include %A_ScriptDir%\..\Ribbon.ahk
SetWorkingDir, %A_ScriptDir%

; Initialize the ribbon library
Ribbon()

; Hook WM_CREATE and WM_DESTROY
OnMessage(0x01, "OnCreate")
OnMessage(0x02, "OnDestroy")

; Create our GUI
Gui, +Resize
Gui, Show, w640 h480, AutoHotkey ribbon example
return

GuiClose:
; This is needed in order to do a cleanup
Gui, Destroy
ExitApp

; WM_CREATE
OnCreate(wParam, lParam, msg, hwnd)
{
	Global
	hGUI := hwnd
	
	; Create a ribbon "application" object
	hApp := RibbonApp_Create("OnView", "OnProperty", "OnExecute")
	; Create a ribbon
	hRibbon := Ribbon_Create(hwnd, hApp)
	
	; If succeeded
	if(hRibbon)
	{
		; Load the ribbon binary markup from our DLL (which is actually an .exe from the Windows SDK examples renamed to DLL :P)
		if(Ribbon_Load(hRibbon, DllCall("LoadLibraryEx", "str", "PreviewRibbon.dll", "uint", 0, "uint", 0x00000002, "uint"), "APPLICATION_RIBBON") < 0)
		{
			MsgBox, 16, Title, Failed to load ribbon!
			Ribbon_Free(hRibbon)
			RibbonApp_Free(hApp)
			ExitApp
		}
	}else
	{
		MsgBox, 16, Title, Failed to create ribbon! Make sure you're running Windows 7.
		RibbonApp_Free(hApp)
		ExitApp
	}
}

; OnView() - fired when the ribbon wants to tell us about something
OnView(this, viewId, typeId, pView, verb, uReasonCode)
{
	if(typeId = 1)
	{
		ToolTip, Layout change
		SetTimer, popup, -1000
	}
	
	return 0 ; S_OK
	
	popup:
	; Clear the tooltip
	ToolTip
	return
}

; OnProperty() - fired when a property changes
OnProperty(this, nCmdID, key, ppropvarCurrentValue, ppropvarNewValue)
{
	return 0x80004001 ; E_NOTIMPL
}

; OnExecute() - fired when the user clicks on a button
OnExecute(this, nCmdID, verb, key, ppropvarValue, pCommandExecutionProperties)
{
	MsgBox, Command: %nCmdId%
	return 0 ; S_OK
}

; WM_DESTROY
OnDestroy(wParam, lParam, msg, hwnd)
{
	Global
	if(hwnd = hGUI)
	{
		; Free the ribbon and the application object
		Ribbon_Free(hRibbon)
		RibbonApp_Free(hApp)
		return 0
	}
}
