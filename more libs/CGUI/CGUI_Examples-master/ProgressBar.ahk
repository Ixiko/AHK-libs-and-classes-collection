SetBatchlines, -1
MyWindow := new CBasicWindow("Demo") ;Create an instance of this window class

Loop 1000
{
	MyWindow.progBar.Value := A_Index
	sleep 10
}
ExitApp

return

;#include %A_ScriptDir%\lib
#include <CGUI>

Class CBasicWindow Extends CGUI
{
	progBar	  := this.AddControl("Progress", "progBar", "", "Progress")
	__New(Title)
	{
		;Set some window properties
		this.Title := Title
		this.Resize := true
		this.MinSize := "200x50"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
			
		this.progBar.Min := 0
		this.progBar.Max := 1000
		this.progBar.Value := 0
		this.progBar.Width := 160
		;Show the window
		this.Show("")
	}
	
	PostDestroy()
	{
		;Exit when all instances of this window are closed
		if(!this.Instances.MaxIndex())
			ExitApp
	}
}