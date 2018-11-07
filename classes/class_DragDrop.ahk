/*
*************************************************************************************
***************************** Drag n Drop Like a Boss *****************************
*************************************************************************************

	This class supports Drag n Drop from EXPLORER windows to AutoHotKey GUIs -- that's it.
	I recommend having your GUI still retain the label for GUIDropFiles for 2 reasons:
		1. Win7 and earlier natively support DnD. It's better to NOT use this class when you don't need to.
		2. The mouse becomes a No/X icon when you try to drag & drop onto the AutoHotKey GUI
			In this case, drag & drop *does* still work, but that's unintuitive to the user.

	Highlights: 
		This uses a global mouse hook. This isn't common, but if you have one set, there may be performance issues.
		DragDrop.ShouldUseDD() -- call this to determine whether or not you need to use this class.
		This class std lib compliant.

	How to use:
		_DragDrop() ; Init stb lib.
		if (DragDrop.ShouldUseDD())
			g_vDD := new DragDrop("SimulateDragNDrop", g_hQL)
		...when you're done with the object...
		g_vDD := ; Delete this object to unregister it from the super class and release it from the mouse hook.

	Credits:
		Joshua A. Kinnison for great Explorer functions.

	License:
		Attribution 3.0 -- just give Verdlin credit
*/

_DragDrop()
{ } ; for stb lib

class DragDrop
{
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: __New(0
			Purpose: Initialize DragDrop object
		Parameters
			sCallback: String of callback function. Callback function takes a COM object of selected items from the dragged explorer window.
			hDropWnd: Target hWnd. IMPORTANT: Must be a window handle! Also used to attach class to hWnd.
	*/
	__New(sCallback, hDropWnd)
	{
		this.m_hCallback := Func(sCallback)
		if (!IsFunc(this.m_hCallback))
		{
			Msgbox 8256,, Error: %sCallback% is not a valid function.
			return false
		}

		global g_hMouseHook
		if (!g_hMouseHook) ; Only set hook once.
			g_hMouseHook := DllCall("SetWindowsHookEx", "int", WH_MOUSE_LL:=14 , "uint", RegisterCallback("DD_MouseProc", "Fast"), "uint", 0, "uint", 0)

		sPrev := A_DetectHiddenWindows ; Preserve existing setting.
		DetectHiddenWindows, on ; So we can get this script's hWnd.
		this.m_hScriptWnd := WinExist("Ahk_PID " DllCall("GetCurrentProcessId"))
		DetectHiddenWindows, %sPrev% ; Restore existing setting.

		; Override obscure window message.
		OnMessage(WM_CAP_SET_CALLBACK_ERRORW:=1126, "DragDropProc")

		; Register this instance in super class.
		this.m_hDropWnd := hDropWnd
		DragDrop.ForHwnd[hDropWnd] := &this ; for DD_MouseProc
		return this
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: __Delete()
			Purpose: Properly delete object
		Parameters
			
	*/
	__Delete()
	{
		global g_hMouseHook

		; Unregister instance from super class.
		DragDrop.ForHwnd.Remove(this.m_hDropWnd)
		; Apparently MaxIndex() doesn't work :\
		for k, v in DragDrop.ForHwnd
			iClassCnt++

		; If that was the last DD, unhook
		if (!iClassCnt)
			DllCall("UnhookWindowsHookEx", "Uint", g_hMouseHook)

		return
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: ShouldUseDD
			Purpose: Help to conditionally use DragDrop
				You can call using the super class instantiator like this: DragDrop.ShouldUseDD()
		Parameters
			
	*/
	ShouldUseDD()
	{
		return A_OSVersion != "WIN_7" && A_OSVersion != "WIN_VISTA" && A_OSVersion != "WIN_XP"
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Verdlin
		Function: GetExplorerDDContents
			Purpose: To get the contents (if any) of explorer's DD.
				Returns COM object of explorer contents or else false if empty.
		Parameters
			hExplorerWnd: Explorer wnd to get contents from
	*/
	GetExplorerDDContents(hExplorerWnd)
	{
		; This prevents the code from firing if you simply click on the QL.
		vSelItems := this.Explorer_GetWindow(hExplorerWnd).Document.SelectedItems

		if (vSelItems.Count < 1)
			return false
		return vSelItems
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	/*
		Author: Joshua A. Kinnison 2011-04-27, 16:12
		Function: Explorer_GetWindow
			Purpose: Get explorer window COM object
		Parameters
			hWnd=""
	*/
	Explorer_GetWindow(hwnd="")
	{
		hwnd := hwnd ? hwnd : WinExist("A")
		WinGetClass class, ahk_id %hwnd%

		if (class="CabinetWClass" or class="ExploreWClass" or class="Progman")
			for window in ComObjCreate("Shell.Application").Windows
			{
				if (window.hwnd==hwnd)
					return window
			}
	}
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: DragDropProc
		Purpose: To simulate do Drag n Drop!
	Parameters
		hExplorerWnd: Explorer window to grab selection from
		pDragDrop: Pointer to DragDrop class object.
*/
DragDropProc(hExplorerWnd, pDragDrop)
{
	; Get the DD contents out of explorer now.
	vDragDrop := Object(pDragDrop)
	vDDContents := vDragDrop.GetExplorerDDContents(hExplorerWnd)

	; Is there something to drag and drop?
	if (vDDContents.Count)
		vDragDrop.m_hCallback.(vDDContents) ; Do it!

	return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
/*
	Author: Verdlin
	Function: DD_MouseProc
		Purpose: Global mouse hook to detect click n drag and trigger Drag n Drop event.
	Parameters
		nCode:
		wParam: Window message WM_
		lParam:
*/
DD_MouseProc(nCode, wParam, lParam)
{
	; Variables used to filter out clicks.
	static s_hWndOnClick := 0, s_bTrackingClickNDrag := false, s_bIsDragging := false, s_iPrevMouseX, s_iPrevMouseY

	static WM_MOUSEMOVE := 0x200
	static WM_LBUTTONDOWN := 0x201
	static WM_LBUTTONUP := 0x202

	CoordMode, Mouse, Screen
	MouseGetPos, iMouseX, iMouseY, hMouseWnd

	if (wParam == WM_LBUTTONDOWN)
		s_hWndOnClick := hMouseWnd

	vDragDrop := Object(DragDrop.ForHwnd[hMouseWnd]) ; DragDrop is a super class or super global or something...it just works, OK?
	bMouseOverDropWnd := IsObject(vDragDrop)

	; If we started clicking ON the drop wnd, there's nothing to click n drag.
	bDraggingDropWnd := (s_hWndOnClick == vDragDrop.m_hDropWnd)
	if (bDraggingDropWnd)
		return DD_CallNextHookEx(nCode, wParam, lParam)

	bMouseMove := (wParam == WM_MOUSEMOVE)
	bLButtonUp := (wParam == WM_LBUTTONUP)
	bLButtonDown := (wParam == WM_LBUTTONDOWN)
	bLButtonDown_P := GetKeyState("LButton", "P")
	bLButtonDown_Valid := (bLButtonDown_P && !bMouseOverDropWnd)

	; If the LButton is down or the mouse is moving AND click n drag did NOT start on a drop hwnd...
	if (bLButtonDown_Valid && (bLButtonDown || bMouseMove))
	{
		; If we are clicking and dragging...
		if (bLButtonDown_P && bMouseMove)
		{
			; X delta
			if (s_iPrevMouseX == "")
				iXDelta := 0
			else iXDelta := abs(iMouseX-s_iPrevMouseX)

			; Y delta
			if (s_iPrevMouseY == "")
				iYDelta := 0
			else iYDelta := abs(iMouseY-s_iPrevMouseY)

			; Detect if we are dragging uses delta.
			s_bIsDragging := (s_bIsDragging || iXDelta || iYDelta)
		}

		s_bTrackingClickNDrag := s_bTrackingClickNDrag || s_bIsDragging

		s_iPrevMouseX := iMouseX
		s_iPrevMouseY := iMouseY
	}
	else if (bMouseOverDropWnd && s_bTrackingClickNDrag && s_bIsDragging && bLButtonUp)
	{
		s_bTrackingClickNDrag := false
		s_bIsDragging := false

		; PostMessage because we can't call GetExplorerDDContents while dispatching an input-synchronous call.
		PostMessage, WM_CAP_SET_CALLBACK_ERRORW:=1126, s_hWndOnClick, &vDragDrop,, % "ahk_id" vDragDrop.m_hScriptWnd
	}
	else if (bLButtonUp)
	{
		; Reset click n drag vars.
		s_bTrackingClickNDrag := s_bIsDragging := false
		s_hWndOnClick := s_iPrevMouseX := s_iPrevMouseY := ""
	}

	return DD_CallNextHookEx(nCode, wParam, lParam)
}

DD_CallNextHookEx(nCode, wParam, lParam)
{
	global g_hMouseHook
	return DllCall("CallNextHookEx", "uint", g_hMouseHook, "int", nCode, "uint", wParam, "uint", lParam)
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;