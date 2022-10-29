; Title:   	[module] RemoteBuffer 2.0
; Link:     	autohotkey.com/board/topic/11173-module-remotebuffer-20/
; Author:	
; Date:   	
; for:     	AHK_L

/*


*/

;------------------------------------------------------------------------------------------------
; Iterate through controls with the same class, find the one with ctrlID and return its handle
; Used for finding a specific control
;
FindWindowExID(dlg, className, ctrlId)
{
	local ctrl, id

	ctrl = 0
	Loop
	{
		ctrl := DllCall("FindWindowEx", "uint", dlg, "uint", ctrl, "str", className, "uint", 0 )
		if (ctrlId = "0")
		{
			return ctrl
		}

		if (ctrl != "0")
		{
			id := DllCall( "GetDlgCtrlID", "uint", ctrl )
			if (id = ctrlId) 
				return ctrl				
		}
		else 
			return 0
	}

}