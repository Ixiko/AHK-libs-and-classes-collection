;
; GUI Status Bar Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlStatusBar
		Status bar control (equivalent to `Gui, Add, StatusBar`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlStatusBar extends CControl
{
	static __CtrlName := "StatusBar"
	
	/*!
		Constructor: (oGui, options := "")
			Creates the control.
		Parameters:
			oGui - The window in which to create the control.
			options - (Optional) Options (including positioning) to apply to the control.
				See the AutoHotkey help file for more details.
	*/
	
	__New(oGui, options := "")
	{
		base.__New(oGui, "", options)
	}
	
	_SelectSB()
	{
		this.__Gui()._Default()
	}
	
	/*!
		Method: SetPartWidths([width1, width2...])
			Sets the widths of the parts. Equivalent to `SB_SetParts`.
		Remarks:
			Refer to the `SB_SetParts` documentation.
	*/
	
	SetPartWidths(w*)
	{
		this._SelectSB()
		if !SB_SetParts(w*)
			throw Exception("SB_SetParts()", -1) ; Short msg since so rare.
	}
	
	/*!
		Method: SetPartText(text [, partNumber, style])
			Changes the text of a part. Equivalent to `SB_SetText`.
		Remarks:
			Refer to the `SB_SetText` documentation.
	*/
	
	SetPartText(text, part := 1, style := 0)
	{
		this._SelectSB()
		if !SB_SetText(text, part, style)
			throw Exception("SB_SetText()", -1) ; Short msg since so rare.
	}
	
	/*!
		Method: SetPartIcon(filename [, iconNumber, partNumber])
			Changes the icon of a part. Equivalent to `SB_SetIcon`.
		Remarks:
			Refer to the `SB_SetIcon` documentation.
	*/
	
	SetPartIcon(file, p*)
	{
		this._SelectSB()
		if !SB_SetIcon(file, p*)
			throw Exception("Failed to set the icon!", -1)
	}
	
	/*!
		Method: OnClick(oCtrl, part, isRightClick)
			Called when the user clicks a part.
		Parameters:
			oCtrl - The control that fired the event.
			part - The part number.
			isRightClick - `true` if the user right-clicked the part, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	/*!
		Method: OnDoubleClick(oCtrl, part, isRightClick)
			Called when the user double-clicks a part.
		Parameters:
			oCtrl - The control that fired the event.
			part - The part number.
			isRightClick - `true` if the user double-right-clicked the part, `false` otherwise.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.
			
			**Note**: This is an event handler; in order to receive events override it in your class.
	*/
	
	OnEvent(oCtrl, guiEvent, eventInfo)
	{
		if (guiEvent = "Normal" || guiEvent = "RightClick")
			return oCtrl.OnClick.(this, oCtrl, eventInfo, InStr(guiEvent, "R"))
		if (guiEvent = "DoubleClick" || guiEvent = "R")
			return oCtrl.OnDoubleClick.(this, oCtrl, eventInfo, InStr(guiEvent, "R"))
	}
}

/*!
	End of class
*/
