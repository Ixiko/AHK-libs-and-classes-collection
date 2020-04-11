;
; GUI Control Wrapper Base Class
;

#include %A_ScriptDir%\CWindow.ahk

/*!
	Class: CControl
		Main GUI control wrapper class. This class implements basic functionality which all
		control classes inherit and is not intended to be instanciated with `new` directly. In
		order to create a control use the appropriate control class (they are prefixed with `CCtrl`).
	@UseShortForm
*/

class CControl
{
	; Overriden:
	static __CtrlName := "INVALID"

	/*!
		Constructor: (oGui, value := "", options := "")
			Creates a control.
		Parameters:
			oGui - The window in which to create the control.
			value - (Optional) The value to give the control. Refer to `Gui, Add`'s `Text`
				parameter for more details.
			options - (Optional) Options (including positioning) to apply to the control.
				See the AutoHotkey help file for more details.
	*/

	__New(oGui, value := "", options := "")
	{
		this.__Handle := oGui._InternalAdd(this, options, value)
		this.__GuiPtr := &oGui
	}

	__Gui()
	{
		return Object(this.__GuiPtr)
	}

	_InternalGuiControl(cmd := "", value := "")
	{
		this.__Gui()._InternalGuiControl(this.__Handle, cmd, value)
	}

	_InternalGuiControlGet(cmd := "", value := "")
	{
		return this.__Gui()._InternalGuiControlGet(this.__Handle, cmd, value)
	}

	/*!
		Method: SetOptions(options)
			Adds and/or removes options. Equivalent to `GuiControl, +/-Option1 +/-Option2...`.
		Parameters:
			options - See "Options and styles for controls" in the AutoHotkey documentation for more details.
	*/

	SetOptions(options)
	{
		this._InternalGuiControl(options)
	}

	/*!
		Method: Move(pos)
			Moves and/or resizes the control. Equivalent to `GuiControl, Move`.
		Parameters:
			pos - As in `GuiControl, Move`.
	*/

	Move(pos)
	{
		this._InternalGuiControl("Move", pos)
	}

	/*!
		Method: MoveDraw(pos)
			Moves and/or resizes the control (avoids painting artifacts). Equivalent to `GuiControl, MoveDraw`.
		Parameters:
			pos - As in `GuiControl, MoveDraw`.
	*/

	MoveDraw(pos)
	{
		this._InternalGuiControl("MoveDraw", pos)
	}

	/*!
		Method: Focus()
			Sets keyboard focus to the control. Equivalent to `GuiControl, Focus`.
	*/

	Focus()
	{
		this._InternalGuiControl("Focus")
	}

	/*!
		Method: Choose(n)
			In the case of an appropriate control type, this method sets the selection
			to be the Nth item. Equivalent to `GuiControl, Choose`.
		Parameters:
			n - The item position or leading text part.
	*/

	Choose(n)
	{
		this._InternalGuiControl("Choose", n)
	}

	/*!
		Method: ChooseString(text)
			In the case of an appropriate control type, this method sets the selection
			to be the item which begins with *text*. Equivalent to `GuiControl, ChooseString`.
		Parameters:
			text - The text to match.
	*/

	ChooseString(text)
	{
		this._InternalGuiControl("Choose", text)
	}

	/*!
		Method: OnEvent(oCtrl, guiEvent, eventInfo)
			Called when an event related to the control is triggered (equivalent to g-labels).
		Parameters:
			oCtrl - The control that fired the event.
			guiEvent - The value of `A_GuiEvent` when the event was fired.
			eventInfo - The value of `A_EventInfo` when the event was fired.
		Remarks:
			The hidden `this` parameter contains a reference to the window object the control belongs to.

			Several control classes capture this event in order to separate the different kinds of
			events the control can fire. Examples of this include `CCtrlListView` and `CCtrlTreeView`.
			If otherwise indicated by the presence of other event handlers in the corresponding control
			class' documentation, control classes do not capture this event.

			**Note**: This is an event handler; in order to receive events override it in your class.
	*/

	; Property getters
	class __Get extends CPropImpl
	{
		/*!
			Property: Value [get/set]
				Represents the value of the control. Equivalent to `GuiControl(Get)` with a blank sub-command.
		*/
		Value()
		{
			return this._InternalGuiControlGet()
		}

		/*!
			Property: Text [get/set]
				Represents the text of the control. Equivalent to `GuiControl(Get)`'s `Text` sub-command.
		*/
		Text()
		{
			return this._InternalGuiControlGet("", "Text")
		}

		/*!
			Property: Enabled [get/set]
				Specifies whether the user can interact with the control (if `false` the control is "grayed-out").
		*/
		Enabled()
		{
			return this._InternalGuiControlGet("Enabled")
		}

		/*!
			Property: Visible [get/set]
				Specifies whether the control is visible. Equivalent to `GuiControlGet, ov, Visible`.
		*/
		Visible()
		{
			return this._InternalGuiControlGet("Visible")
		}

		/*!
			Property: Focused [get]
				This property is `true` when the control has keyboard focus.
		*/
		Focused()
		{
			return this.__Gui().GetFocusedControl() == this
		}

		/*!
			Property: Position [get]
				Retrieves a control's position and size. Logical equivalent of `GuiControlGet, ov, Pos`.
			Returns:
				An object which contains `x`, `y`, `w` and `h`.
		*/
		Position()
		{
			gh := this.__Gui().__Handle
			GuiControlGet, p, %gh%:Pos, % this.__Handle
			return { x: px, y: py, w: pw, h: ph }
		}
	}

	; Property setters
	class __Set extends CPropImpl
	{
		Value(v)
		{
			this._InternalGuiControl("", v)
			return v
		}

		Text(v)
		{
			this._InternalGuiControl("Text", v)
			return v
		}

		Enabled(v)
		{
			this._InternalGuiControl(v ? "Enable" : "Disable")
			return !!v
		}

		Visible(v)
		{
			this._InternalGuiControl(v ? "Show" : "Hide")
			return !!v
		}
	}
}

/*!
	End of class
*/
