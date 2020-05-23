SetBatchlines, -1
MyWindow := new CBasicWindow("Demo") ;Create an instance of this window class
return

#include <CGUI>
Class CBasicWindow Extends CGUI
{
	;Controls can be defined as class variables at the top of the class like this:
	btnButton := this.AddControl("Button", "btnButton", "", "button") 
	
	;Another way to define a control is by creating a subclass with some static properties. 
	;The name of the control will be the name of the subclass and it can be accessed by this name through the GUI object.
	Class MyEdit
	{
		;All variables defined in the class need to be static. 
		;They won't be static during runtime though since a shallow copy of this class is created, 
		;so it's possible to use custom variables and modify them in each instance of this window.
		
		;The three variables below define the options that are used to create this control. They correspond to their parameters in CGUI.AddControl()
		static Type := "Edit"
		static Options := ""
		static Text := "hallo"
		
		;A custom property. It also needs to be static but it won't be during runtime.
		static t := 5
		
		;This will be called before the __New constructor of this window class and allows to init the contents of the control
		__New()
		{
			this.Text := "Test"
		}
		
		;If a control is defined in a subclass it can handle its own events inside the subclass, using only the event name.
		;An additional GUI parameter is supplied to access the GUI and other controls.
		TextChanged(GUI)
		{
			this.t := this.t + 1
			GUI.editField.Text := this.t
		}
	}
	
	;This constructor is called when the window is instantiated. It's used to setup window properties and also control properties. It's also common that the window shows itself.
	__New(Title)
	{
		;Set some window properties
		this.Title := Title
		this.Resize := true
		this.MinSize := "200x150"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		;Add a control dynamically
		this.editField := this.AddControl("Edit", "editField", "w100", "Some data")
		
		;Show the window
		this.Show("")
	}
	
	;Called when the button is clicked. Note the naming scheme "ControlName_EventName"
	btnButton_Click()
	{
		;Set text of the edit control
		this.editField.Text := "Button was clicked"
	}
	
	;Called after the window was destroyed
	PostDestroy()
	{
		;Exit when all instances of this window are closed
		if(!this.Instances.MaxIndex())
			ExitApp
	}
}