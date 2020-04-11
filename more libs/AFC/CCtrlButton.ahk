;
; GUI Button Control Wrapper Class
;

#include %A_ScriptDir%\CControl.ahk

/*!
	Class: CCtrlButton
		Button control (equivalent to `Gui, Add, Button`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlButton extends CControl
{
	static __CtrlName := "Button"
}

/*!
	End of class
*/
