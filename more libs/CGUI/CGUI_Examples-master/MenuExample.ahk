SetBatchlines, -1
MyWindow := new CMenuExample("Menu Example") ;Create an instance of this window class
return

#include <CGUI>
Class CMenuExample Extends CGUI
{
	BtnTest := this.AddControl("Button", "BtnTest", "", "Button1 with static menu")
	BtnTest2 := this.AddControl("Button", "BtnTest2", "", "Button2 with dynamic menu")
	
	__New(Title)
	{
		this.Title := Title
		this.Resize := true
		this.MinSize := "200x100"
		this.CloseOnEscape := true
		this.DestroyOnClose := true
		
		;Creating a menu
		Menu1 := new CMenu("Main")
		
		;Adding a menu item
		Menu1.AddMenuItem("hello", "test")
		
		;Accessing a menu item and setting some of its properties
		Menu1[1].Text := "Test"
		Menu1[1].Checked := true
		Menu1[1].Enabled := false
		
		;Adding a submenu
		Menu1.AddSubMenu("sub1", "Test")
		
		
		Menu1[2].AddMenuItem("blup", "blup")
		sub2 := New CMenu("sub2")
		sub2.AddMenuItem("blah", "blah")
		;Adding an existing menu as submenu
		Menu1.AddSubMenu("sub2", sub2)
		
		;Setting a menu's icon
		sub2.Icon := A_AHKPath
		
		;Deleting a menu item
		Menu1.DeleteMenuItem(1)
		
		;By setting the Menu property of a CGUI or CControl instance this menu will be shown as context menu automatically.
		this.BtnTest.Menu := Menu1
		
		;~ this.Menu(this.Menu1) ;Menu can't be used for context and menu bar at once!
		this.Show("")
	}
	
	;Called when the context menu of the edit control is to be invoked. Functions like this are used if the menu needs to be dynamically generated.
	BtnTest2_ContextMenu()
	{
		;Make sure that we don't try to create the same menu twice by deleting an old instance
		if(IsObject(this.DynamicMenu))
			this.DynamicMenu.DisposeMenu()
		
		;Create the menu and show it
		this.DynamicMenu := New CMenu("test2")
		this.DynamicMenu.AddMenuItem("MenuItem", "MenuItem")
		this.ShowMenu(this.DynamicMenu)
	}
	
	BtnTest_Click()
	{
		MsgBox % "You left-clicked Button1`nTry right click!"
	}
	
	BtnTest2_Click()
	{
		MsgBox % "You left-clicked Button2`nTry right click!"
	}
	
	;The functions below are called when the matching menu item was selected.
	blup()
	{
		MsgBox blup
	}
	test()
	{
		MsgBox hello
	}
	blah()
	{
		MsgBox blah
	}
	MenuItem()
	{
		MsgBox MenuItem
	}
	PostDestroy()
	{
		if(!this.Instances.MaxIndex()) ;Exit when all instances of this window are closed
			ExitApp
	}
}