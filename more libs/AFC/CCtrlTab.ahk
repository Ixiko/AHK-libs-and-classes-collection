;
; GUI Tab Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlTab
		Tab control (equivalent to `Gui, Add, Tab2`).
	Inherits: CControl
	@UseShortForm
*/

class CCtrlTab extends CControl
{
	static __CtrlName := "Tab2"
	
	/*!
		Constructor: (oGui, tabs, options := "")
			Creates the control.
		Parameters:
			oGui - The window in which to create the control.
			tabs - Pipe-delimited string containing the names of the tabs to create.
			options - (Optional) Options (including positioning) to apply to the control.
				See the AutoHotkey help file for more details.
	*/
	
	__New(oGui, tabs, options := "")
	{
		base.__New(oGui, tabs, options)
		this.__TabId := oGui._GetTabId()
	}
	
	/*!
		Method: BeginDef(tabN := 1, exactMatch := false)
			This method instructs the tab control's parent GUI to add any subsequent controls
			to this tab control's Nth tab. Equivalent to `Gui, Tab` with parameters.
		Parameters:
			tabN - (Optional) Tab index or name to use. If omitted it defaults to the first tab.
			exactMatch - (Optional) Specifies case-sensitive exact tab text matching. Defaults to `false`.
	*/
	
	BeginDef(tabN := 1, exactMatch := false)
	{
		this.__Gui()._InternalTab(this.__TabId, tabN, exactMatch)
	}
	
	/*!
		Method: EndDef()
			This method instructs the tab control's parent GUI to stop adding new controls to tabs.
			Equivalent to `Gui, Tab` with no parameters.
	*/
	
	EndDef()
	{
		this.__Gui()._InternalEndTabDef()
	}
}

/*!
	End of class
*/
