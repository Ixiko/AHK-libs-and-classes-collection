SetBatchLines, -1
Window := new CActiveXDemo("ActiveXDemo")
#include <CGUI>
Class CActiveXDemo Extends CGUI
{
	;Add an ActiveX control, subclass style!
	Class ie
	{
		static Type := "ActiveX"
		static Options := "w800 h600"
		static Text := "Shell.Explorer"
		__New(GUI)
		{
			this.Navigate("D:\Eigene Dateien\Eigene Bilder\Praxis\PraxisWebSeite\index.html")
		}
		NavigateComplete2(GUI, pDisp, URL)
		{
			if(InStr(URL, "google")) ;Prohibit using google :D
				this.Navigate("http://www.microsoft.com")
		}
	}
	
	;Alternatively, define it as class property. Comment subclass above and uncomment code below then
	;~ ie := this.AddControl("ActiveX", "ie", "w800 h600", "Shell.Explorer")
	__New(title)
	{
		this.Title := Title
		
		;Calling functions of the ActiveX control is done directly on the control object.
		;~ this.ie.Navigate("http://www.google.com")
		
		this.DestroyOnClose := true
		this.Show()
	}
	
	;ActiveX control events are implemented like regular events of other controls
	;~ ie_NavigateComplete2(pDisp, URL)
	;~ {
		;~ if(InStr(URL, "google")) ;Prohibit using google :D
			;~ this.ie.Navigate("http://www.microsoft.com")
	;~ }
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
}