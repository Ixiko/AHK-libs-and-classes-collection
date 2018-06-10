;
; GUI Wrapper Class
;

#include <CPropImpl>

/*!
	Class: CWindow
		Main GUI window class.
	@UseShortForm
*/

class CWindow
{
	static __Instances := []
	__Controls := []
	__TabCount := 0
	
	/*!
		Constructor: (title := "", options := "")
			Creates a window. Analogous to `Gui, New`.
		Parameters:
			title - (Optional) The title of the window. If blank it defaults to `A_ScriptName`.
			options - (Optional) Options to apply to the window. See the AutoHotkey help file for more details.
	*/
	
	__New(title := "", options := "")
	{
		Gui, New, hwndhWnd label__CWindow -E0x10 %options%, %title%
		this.__Handle := hWnd
		CWindow.__Instances[hWnd] := &this
	}
	
	/*!
		Method: Close()
			Closes the window, destroying it in the process. Equivalent to `Gui, Destroy`.
	*/
	
	Close()
	{
		h := this.__Handle
		this.OnDestroy()
		Gui %h%:Destroy
		CWindow.__Instances.Remove(h, "")
		this.Closed := true
		this.__Handle := "<DESTROYED>"
	}
	
	__Delete()
	{
		if !this.Closed
			this.Close()
	}
	
	_InternalAdd(oCtrl, options := "", value := "")
	{
		static
		local h, pCtrl, ctrlName, glabelAttr
		h := this.__Handle
		pCtrl := &oCtrl, ctrlName := oCtrl.__CtrlName, glabelAttr := "g__CWindowGlabel"
		; Undocumented gotcha: an error msg is thrown out if these control types are
		; assigned a g-label - so we have to work around it by not doing it :p
		if ctrlName in Progress,GroupBox
			glabelAttr := ""
		Gui %h%:Add, %ctrlName%, hwndctrlHwnd %glabelAttr% v#%pCtrl% %options%, % value
		#%pCtrl% := "" ; Clear out the associated variable
		this.__Controls[ctrlHwnd] := oCtrl
		return ctrlHwnd
	}
	
	_InternalGuiControl(ctrlID, cmd := "", value := "")
	{
		h := this.__Handle
		GuiControl %h%:%cmd%, %ctrlID%, % value
	}
	
	_InternalGuiControlGet(ctrlID, cmd := "", value := "")
	{
		h := this.__Handle
		GuiControlGet, ov, %h%:%cmd%, %ctrlID%, % value
		return ov
	}
	
	_GetTabId()
	{
		return ++this.__TabCount
	}
	
	_InternalTab(tabCtrlId, tabN, exactMatch := false)
	{
		h := this.__Handle
		Gui %h%:Tab, %tabN%, %tabCtrlId%, % exactMatch ? "Exact" : ""
	}
	
	_InternalEndTabDef()
	{
		h := this.__Handle
		Gui %h%:Tab
	}
	
	/*!
		Method: SetFont(options := "", face := "")
			Sets the font to be used when creating new controls. Equivalent to `Gui, Font`.
		Parameters:
			options - (Optional) As in `Gui, Font`.
			face - (Optional) As in `Gui, Font`.
	*/
	
	SetFont(options := "", face := "")
	{
		h := this.__Handle
		if face !=
			Gui %h%:Font, %options%, %face%
		else
			Gui %h%:Font, %options%
	}
	
	/*!
		Method: SetColor(winColor := "", ctrlColor := "")
			Sets the colors to be used when creating new controls. Equivalent to `Gui, Color`.
		Parameters:
			winColor - (Optional) As in `Gui, Color`.
			ctrlColor - (Optional) As in `Gui, Color`.
	*/
	
	SetColor(winColor := "", ctrlColor := "")
	{
		h := this.__Handle
		Gui %h%:Color, %winColor%, %ctrlColor%
	}
	
	/*!
		Method: SetMargin(x := "", y := "")
			Sets the margins to be used when creating new controls. Equivalent to `Gui, Margin`.
		Parameters:
			x - (Optional) As in `Gui, Margin`.
			y - (Optional) As in `Gui, Margin`.
	*/
	
	SetMargin(x := "", y := "")
	{
		h := this.__Handle
		Gui %h%:Margin, %x%, %y%
	}
	
	/*!
		Method: SetOptions(options)
			Adds and/or removes options. Equivalent to `Gui, +/-Option1 +/-Option2...`.
		Parameters:
			options - See "Options and styles for a window" in the AutoHotkey documentation for more details.
	*/
	
	SetOptions(options)
	{
		h := this.__Handle
		Gui %h%:%options%
	}
	
	/*!
		Method: Show(options := "", title := "")
			Displays the window. Equivalent to `Gui, Show`.
		Parameters:
			options - (Optional) As in `Gui, Show`.
			title - (Optional) As in `Gui, Show`.
	*/
	
	Show(options := "", title := "")
	{
		h := this.__Handle
		if title !=
			Gui %h%:Show, %options%, % title
		else
			Gui %h%:Show, %options%
	}
	
	/*!
		Method: Hide()
			Hides the window. Equivalent to `Gui, Hide`.
	*/
	
	Hide()
	{
		h := this.__Handle
		Gui %h%:Hide
	}
	
	/*!
		Method: Minimize()
			Minimizes the window. Equivalent to `Gui, Minimize`.
	*/
	
	Minimize()
	{
		h := this.__Handle
		Gui %h%:Minimize
	}
	
	/*!
		Method: Maximize()
			Maximizes the window. Equivalent to `Gui, Maximize`.
	*/
	
	Maximize()
	{
		h := this.__Handle
		Gui %h%:Maximize
	}
	
	/*!
		Method: Restore()
			Restores the window. Equivalent to `Gui, Restore`.
	*/
	
	Restore()
	{
		h := this.__Handle
		Gui %h%:Restore
	}
	
	/*!
		Method: Flash(state := true)
			Flashes the window. Equivalent to `Gui, Flash`.
		Parameters:
			state - (Optional) Whether to begin or end flashing. Defaults to `true`.
	*/
	
	Flash(state := true)
	{
		h := this.__Handle
		if state
			Gui %h%:Flash
		else
			Gui %h%:Flash, Off
	}
	
	/*!
		Method: OnClose()
			Called when the window is closed. Logical equivalent of `GuiClose:`.
		Remarks:
			`CWindow`'s default `OnClose()` handler performs `ExitApp` if there are no more non-destroyed
			`CWindow` objects. This behaviour is adequate in most situations.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	; Default OnClose handler
	OnClose()
	{
		this.Close()
		if !CWindow.__Instances.MaxIndex()
			ExitApp
	}
	
	/*!
		Method: OnEscape()
			Called when the user presses Escape. Logical equivalent of `GuiEscape:`.
		Remarks:
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnSize(w, h)
			Called when the window is resized.
		Parameters:
			w - The new width of the window.
			h - The new height of the window.
		Remarks:
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnMinimize()
			Called when the window is minimized.
		Remarks:
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnMaximize(w, h)
			Called when the window is maximized.
		Parameters:
			w - The new width of the window.
			h - The new height of the window.
		Remarks:
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	_OnSize(w, h, info)
	{
		if info = 0
			this.OnSize(w, h)
		else if info = 1
			this.OnMinimize()
		else if info = 2
			this.OnMaximize(w, h)
	}

	/*!
		Method: OnContextMenu(isRightClick, extraInfo)
			Called when a context menu is requested to be shown. Logical equivalent of `GuiContextMenu:`.
		Parameters:
			isRightClick - `true` if the event was called due to a right-click, `false` if it was due
				to a keyboard event.
			extraInfo - an object containing the following fields:
				* **oCtrl**: reference to the control that received the event.
				* **eventInfo**: the value of `A_EventInfo` when the event was received.
				* **x**: the value of `A_GuiX` when the event was received.
				* **y**: the value of `A_GuiY` when the event was received.
		Remarks:
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnDropFiles(files, extraInfo)
			Called when the user drops files into the window. Logical equivalent of `GuiDropFiles:`.
		Parameters:
			files - array containing the filenames the user dropped.
			extraInfo - same as in `OnContextMenu()`.
		Remarks:
			File dropping is disabled by default. In order to enable it, use the following code:
			> obj.SetOptions("+E0x10")
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	_Default()
	{
		h := this.__Handle
		Gui %h%:Default
	}
	
	_SelectLV(oCtrl)
	{
		this._Default()
		Gui, ListView, % oCtrl.__Handle
	}
	
	_SelectTV(oCtrl)
	{
		this._Default()
		Gui, ListView, % oCtrl.__Handle
	}
	
	;---------------------
	
	/*!
		Method: OwnDialogs()
			Call this method to make the current thread own all MsgBoxes/InputBoxes/etc. Equivalent
			to `CWindow.SetOptions("+OwnDialogs")`.
	*/
	
	OwnDialogs()
	{
		this.SetOptions("+OwnDialogs")
	}
	
	GetFocusedControl()
	{
		focusv := this._InternalGuiControlGet("", "FocusV")
		return focusv ? Object(SubStr(focusv, 2)) : ""
	}
}

/*!
	End of class
*/

/*!
	Class: COwnedWindow
		Represents a GUI that is owned by another window.
	Inherits: CWindow
	@UseShortForm
*/

class COwnedWindow extends CWindow
{
	/*!
		Constructor: (owner, title := "", options := "")
			Creates a window owned by another.
		Parameters:
			owner - The window that is to own the new window (can be either an object or a raw HWND).
			title - (Optional) Same as in CWindow.
			options - (Optional) Same as in CWindow.
	*/
	
	__New(owner, title := "", options := "")
	{
		if IsObject(owner)
			pOwner := owner.__Handle
		else if (owner > 0)
			pOwner := owner
		else
			throw Exception("Invalid owner", "", -1)
		base.__New(title, options " +Owner" pOwner)
		this.Owner := owner
	}
}

/*!
	End of class
*/

__CWindow_GetGuiControl()
{
	return Object(SubStr(A_GuiControl, 2))
}

__CWindow_CreateExtraInfoObj()
{
	return { oCtrl: __CWindow_GetGuiControl(), eventInfo: A_EventInfo+0, x: A_GuiX+0, y: A_GuiY+0 }
}

__CWindow_GetGui()
{
	return Object(CWindow.__Instances[A_Gui])
}

__CWindow_GuiHandler()
{
	__CWindowClose:
	__CWindow_GetGui().OnClose()
	return
	
	__CWindowEscape:
	__CWindow_GetGui().OnEscape()
	return
	
	__CWindowSize:
	__CWindow_GetGui()._OnSize(A_GuiWidth+0, A_GuiHeight+0, A_EventInfo+0)
	return
	
	__CWindowContextMenu:
	__CWindow_GetGui().OnContextMenu(A_GuiEvent = "RightClick", __CWindow_CreateExtraInfoObj())
	return
	
	__CWindowDropFiles:
	files := []
	Loop, Parse, A_GuiEvent, `n
		files.Insert(A_LoopField)
	__CWindow_GetGui().OnDropFiles(files, __CWindow_CreateExtraInfoObj())
	return
	
	__CWindowGlabel:
	oCtrl := __CWindow_GetGuiControl()
	oCtrl.OnEvent.(__CWindow_GetGui(), oCtrl, A_GuiEvent, A_EventInfo)
	return
}
