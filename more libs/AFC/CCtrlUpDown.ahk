;
; GUI UpDown Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlUpDown
		UpDown control (equivalent to `Gui, Add, UpDown`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlUpDown extends CControl
{
	static __CtrlName := "UpDown"
	
	/*!
		Constructor: (oBuddy, value := "", options := "")
			Creates an UpDown control.
		Parameters:
			oBuddy - The control to use as the UpDown's buddy.
			value - (Optional) As always.
			options - (Optional) As always.
	*/
	
	__New(oBuddy, value := "", options := "")
	{
		oGui := oBuddy.__Gui()
		base.__New(oGui, "", options " xp yp+" oBuddy.Position.h " w0 h0 -16") ; 16 = UDS_AUTOBUDDY
		
		; SendMessage(hwndUpDown, UDM_SETBUDDY, hwndBuddy, 0)
		SendMessage, 1129, oBuddy.__Handle, 0,, % "ahk_id " this.__Handle
		
		if value !=
			this.Value := value
	}
}

/*!
	End of class
*/
