;
; GUI ActiveX Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlActiveX
		ActiveX control (equivalent to `Gui, Add, ActiveX`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlActiveX extends CControl
{
	static __CtrlName := "ActiveX"
	
	/*!
		Constructor: (oGui, clsid, options := "")
			Creates the control.
		Parameters:
			oGui - The window in which to create the control.
			clsid - ActiveX class name or CLSID.
			options - (Optional) Options (including positioning) to apply to the control.
				See the AutoHotkey help file for more details.
	*/
	__New(oGui, clsid, options := "")
	{
		base.__New(oGui, clsid, options)
		this.Obj := this.Value
	}
	
	/*!
		Property: Obj [get]
			This property retrieves the ActiveX control's underlying COM object.
	*/
}

/*!
	End of class
*/
