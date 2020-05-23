SetBatchlines, -1
MyWindow := new CWindowMessageDemo() ;Create an instance of this window class
MySecondWindow := new CWindowMessageDemo() ;Create a second instance of this window class
return

#include <CGUI>
Class CWindowMessageDemo Extends CGUI
{
	;Add some controls
	txtX 		:= this.AddControl("Text", "txtX", "x10", "X:")
	editX 	:= this.AddControl("Edit", "editX", "x+10", "")
	txtY		:= this.AddControl("Text", "txtY", "x10", "Y:")
	editY	:= this.AddControl("Edit", "editY", "x+10", "")
	__New()
	{
		this.Title := "Window message demo"
		this.Resize := true
		this.MinSize := "400x300"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		;Register the mouse move message. It will be forwarded to MouseMove() in this class.
		this.OnMessage(0x200, "MouseMove")
		this.Show("")
		return this
	}
	
	;Called when MouseMove message is received
	MouseMove(Msg, wParam, lParam)
	{
		this.editX.text := lParam & 0xFFFF
		this.editY.text := (lParam & 0xFFFF0000) >> 16
		return 0
	}
	
	PostDestroy()
	{
		if(!this.Instances.MaxIndex())
			ExitApp
	}
}