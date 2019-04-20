#include <Parse>
#include <CCompoundControl>
Class CPathPickerControl extends CCompoundControl
{
	static registration := CGUI.RegisterControl("PathPicker", CPathPickerControl)

	__New(Name, Options, InitialPath, GUINum)
	{
		GUI := CGUI.GUIList[GUINum]
		Parse(Options, "x* y* w*", x, y, w)
		if(!w)
			w := 200
		this.AddContainerControl(GUI, "Edit", "Edit", (x ? "x" x " " : "") (y ? "y" y " " : "") "w" (w-60), InitialPath)
		this.AddContainerControl(GUI, "Button", "Button", "x+10 w50", "Browse")
		return Name
	}
	__Get(Key)
    {
        if (Key = "Path")
            return this.Container.Edit.Text
    }
     
    __Set(Key, Value)
    {
        if (Key = "Path")
            return this.Container.Edit.Text := Value
    }
}