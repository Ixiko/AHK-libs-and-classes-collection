;
; GUI Image Control Wrapper Class
;

#include <CControl>

/*!
	Class: CCtrlImage
		Image control (equivalent to `Gui, Add, Pic`).
		
		**Note**: Image controls internally always have a g-label. This means that if you want to
		use one as a background image, you need to create it AFTER the other controls, and set the
		`0x4000000` (WS_CLIPSIBLINGS) style. This is stated in the AutoHotkey documentation.
	Inherits: CControl
	@UseShortForm
*/

class CCtrlImage extends CControl
{
	static __CtrlName := "Pic"
}

/*!
	End of class
*/
