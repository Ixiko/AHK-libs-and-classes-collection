/*
Class: CMenu
CMenu represents a menu which can contain other menus and <CMenu.CMenuItem>
*/
Class CMenu
{
	static Menus := [] ;All menu objects are stored statically in CMenu for easier callback routing. This means that all submenus must have unique names.
	_ := {Checked : 0, Enabled : 1, Default : 0}
	
	/*
	Function: __New
	Creates a new Menu object. Name must be unique through the whole application.
	*/
	__New(Name)
	{
		this.Name := Name
		if(!CGUI_Assert(!this.Menus.HasKey(Name), "Menu Name" Name " is not unique! Submenus must have unique names!"))
			return
		this.Menus[Name] := this
		;Add a temporary menu entry and delete it again to create an empty menu
		Menu, % this.Name, Add, Test, CMenu_Callback
		Menu, % this.Name, Delete, Test
	}
	
	/*
	Function: AddSubMenu
	Adds a submenu to this menu.
	
	Parameters:
		Text - The name under which the submenu will appear in this menu
		NameOrMenuObject - Either the name of a new menu or an existing CMenu instance.
	*/
	AddSubMenu(Text, NameOrMenuObject)
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is disposed and nothing can be added to it anymore."))
			return
		if(CGUI_TypeOf(NameOrMenuObject) = "CMenu")
			Menu := NameOrMenuObject
		else if(!IsObject(NameOrMenuObject))
			Menu := new this(NameOrMenuObject)
		else
			CGUI_Assert(0, "Invalid parameter NameOrMenuObject: " NameOrMenuObject " in CMenu.AddSubmenu()", -1)
		if(CGUI_TypeOf(Menu) = "CMenu")
		{
			Menu._.Insert("Text", Text)
			Menu.Insert("Parent", this.Name)
			this.Insert(Menu)
			Menu, % this.Name, Add, %Text%, % ":" Menu.Name
		}
		else
			CGUI_Assert(0, "Failed to create submenu")
	}
	
	/*
	Function: AddMenuItem
	Adds a menu item to this menu. The menu item object is <CMenu.CMenuItem>
	
	Parameters:
		Text - The text of the menu item in this menu.
		Callback - A function that will be called when the menu item is clicked. This function is usually located within a derived class of CGUI. If the Menu is shown through CGUI.ShowMenu() or added as menu bar to a window this parameter can simply be the name of the function contained in the derived class of CGUI.
	*/
	AddMenuItem(Text, Callback = "")
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is disposed and nothing can be added to it anymore."))
			return
		this.Insert(new this.CMenuItem(Text, this.Name, Callback))
	}
	
	/*
	Function: AddSeparator
	Adds a separator to the menu
	*/
	AddSeparator()
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is disposed and nothing can be added to it anymore."))
			return
		Menu, % this.Name, Add
	}
	
	/*
	Function: DeleteMenuItem
	Deletes a menu item from the menu. ObjectIndexOrName can either be a menu/submenu object, the index of the item in this menu or its name.
	If ObjectIndexOrName is a menu item, it will be disposed. If it is a submenu, it will not be disposed so it can be reused elsewhere.
	
	Returns: The deleted menu item
	*/
	DeleteMenuItem(ObjectIndexOrName)
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is disposed and it's no longer possible to delete menu items from it."))
			return
		if(IsObject(CGUI_TypeOf(ObjectIndexOrName)))
			Menu := ObjectIndexOrName
		else if ObjectIndexOrName is Integer
			Menu := this[ObjectIndexOrName]
		else
			Loop % this.MaxIndex()
				if(A_Index = ObjectIndexOrName)
				{
					Menu := this[A_Index]
					break
				}
		if(CGUI_TypeOf(Menu) = "CMenu")
		{
			Menu.Remove("Text")
			Menu, % this.Name, Delete, % Menu.Text
			this.Remove(CGUI_IndexOf(this, Menu))
		}
		else if(CGUI_TypeOf(Menu) = "CMenu.CMenuItem")
		{
			Menu, % this.Name, Delete, % Menu.Text
			this.Remove(CGUI_IndexOf(this, Menu))
			Menu.IsDisposed := true
		}
	}
	
	/*
	Function: DisposeMenu()
	Disposes the menu so that it can be deleted and its resources are freed. After calling this function the menu won't be usable anymore.
	*/
	DisposeMenu()
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is already disposed."))
			return
		this.Menus.Remove(this.Name)
		Menu, % this.Name, Delete
		this.IsDisposed := true
	}
	RouteCallback()
	{
		Item := this.Menus[A_ThisMenu][A_ThisMenuItemPos]
		if(IsObject(Item) && Item.HasKey("Callback"))
		{
			GUI := CGUI.GUIList[A_GUI ? A_GUI : this.LastGUI]
			if(GUI)
				GUI[Item.Callback]()
			else
			{
				func := Item.Callback
				%func%()
			}
		}
	}
	
	/*
	Function: Show
	Shows the menu. For most cases, this function is not called directly. Instead, use <CGUI.ShowMenu>.
	
	Parameters:
	GUINum - The GUI number of the window owning this menu. This is required if the callback functions are contained in a class deriving from CGUI. Leave it empty to use global callback functions
	X - X position of the menu.
	Y - Y position of the menu.
	*/
	Show(GUINum, X="", Y="")
	{
		if(!CGUI_Assert(!this.IsDisposed, "This menu is disposed and can not be shown anymore."))
			return
		this.Base.LastGUI := GUINum
		Menu,% this.Name, Show, %X%, %Y%
	}
	
	/*
	Function: SetIcon
	Sets the icon of this menu item.
	
	Parameters:
	Icon - The path to the icon file.
	IconNumber - The number of the icon in a group
	IconWidth - The width of an icon (>0), a resource identifier (<0) or the actual size of the icon (=0). Use the latter if you have transparency issues.
	*/
	SetIcon(Icon, IconNumber = 1, IconWidth = 0)
	{
		this._.Icon := Icon
		this._.IconNumber := IconNumber
		this._.IconWidth := IconWidth
		Menu, % this.Parent, Icon, % this.Name, %Icon%, %IconNumber%, %IconWidth%
	}
		
	/*
	Property: Text
	The text under which this menu appears as a submenu in another menu.
	
	Property: Enabled
	Sets whether this submenu is enabled/disabled.
	
	Property: Checked
	Sets whether this submenu has a checkmark.
	
	Property: Default
	Sets whether this submenu is rendered with bold font.
	
	Property: Icon
	The path to the icon of the menu item.
	
	Property: IconNumber
	The number of the menu item icon in a grouped icon file.
	
	Property: IconWidth
	The width of an icon (>0), a resource identifier (<0) or the actual size of the icon (=0). Use the latter if you have transparency issues.
	*/
	__Set(Name, Value)
	{
		Handled := true
		if(Name = "Text")
		{
			if(CGUI_Assert(CGUI_TypeOf(this.Menus[this.Parent]) = "CMenu", "Can't set Text on a menu object that is no submenu.") && CGUI_Assert(!this.IsDisposed, "This menu is disposed and can not be changed anymore."))
			{
				Menu, % this.Parent, Rename, % this.Text, %Value%
				this.Insert("Text", Value)
			}
		}
		else if(Name = "Enabled")
		{
			this._.Enabled := Value
			if(Value)
				Menu, % this.Parent, Enable, % this.Text
			else
				Menu, % this.Parent, Disable, % this.Text
		}
		else if(Name = "Checked")
		{
			this._.Checked := Value
			if(Value)
				Menu, % this.Parent, Check, % this.Text
			else
				Menu, % this.Parent, UnCheck, % this.Text
		}
		else if(Name = "Default")
		{
			if(Value)
			{
				Menu, % this.Parent, Default, % this.Text
				Loop % this.Menus[this.Parent].MaxIndex() ;Set all other default properties in this menu to false
					if(this.Menus[this.Parent][A_Index]._.Default)
						this.Menus[this.Parent][A_Index]._.Default := false
			}
			else
				Menu, % this.Menu, NoDefault
			this._.Insert("Default", Value)
		}
		else if(Name = "Icon")
			this.SetIcon(Value)
		else if(Name = "IconNumber")
			this.SetIcon(this.Icon, Value, this._.HasKey("IconWidth") ? this._.IconWidth : 0)
		else if(Name = "IconWidth")
			this.SetIcon(this.Icon,  this._.HasKey("IconNumber") ? this._.IconNumber : 1, Value)
		else
			Handled := false
		if(Handled)
			return Value
	}
	
	/*
	Class: CMenu.CMenuItem
	A menu item in a <CMenu>. This class is not instantiated directly. Instead, use <CMenu.AddMenuItem>.
	*/
	Class CMenuItem
	{
		_ := {Checked : 0, Enabled : 1, Default : 0}
		__New(Text, Menu, Callback="")
		{
			this._.Insert("Text", Text)
			this.Callback := Callback
			this.Menu := Menu
			Menu, % this.Menu, Add, %Text%, CMenu_Callback
		}
		__Get(Name)
		{
			if(this._.HasKey(Name))
				return this._[Name]
		}
		
		/*
		Function: SetIcon
		Sets the icon of this menu item.
		
		Parameters:
		Icon - The path to the icon file.
		IconNumber - The number of the icon in a group
		IconWidth - The width of an icon (>0), a resource identifier (<0) or the actual size of the icon (=0). Use the latter if you have transparency issues.
		*/
		SetIcon(Icon, IconNumber = 1, IconWidth = 0)
		{
			this._.Icon := Icon
			this._.IconNumber := IconNumber
			this._.IconWidth := IconWidth
			Menu, % this.Menu, Icon, % this.Text, %Icon%, %IconNumber%, %IconWidth%
		}
		/*
		Property: Text
		The text of this menu item.
		
		Property: Enabled
		Sets whether this menu item is enabled/disabled.
		
		Property: Checked
		Sets whether this menu item has a checkmark.
		
		Property: Default
		Sets whether this menu item is rendered with bold font.
		
		Property: Icon
		The path to the icon of the menu item.
		
		Property: IconNumber
		The number of the menu item icon in a grouped icon file.
		
		Property: IconWidth
		The width of an icon (>0), a resource identifier (<0) or the actual size of the icon (=0). Use the latter if you have transparency issues.
		*/
		__Set(Name, Value)
		{
			Handled := true
			if(Name = "Text")
			{
				if(CGUI_Assert(!this.IsDisposed, "This menu is disposed and can not be changed anymore."))
				{
					Menu, % this.Menu, Rename, % this.Text, %Value%
					this._.Insert("Text", Value)
				}
			}
			else if(Name = "Enabled")
			{
				this._.Insert("Enabled", Value)
				if(Value)
					Menu, % this.Menu, Enable, % this.Text
				else
					Menu, % this.Menu, Disable, % this.Text
			}
			else if(Name = "Checked")
			{
				this._.Insert("Checked", Value)
				if(Value)
					Menu, % this.Menu, Check, % this.Text
				else
					Menu, % this.Menu, UnCheck, % this.Text
			}
			else if(Name = "Default")
			{
				if(Value)
				{
					Menu, % this.Menu, Default, % this.Text
					Loop % CMenu.Menus[this.Menu].MaxIndex() ;Set all other default properties in this menu to false
						if(CMenu.Menus[this.Menu][A_Index]._.Default)
							CMenu.Menus[this.Menu][A_Index]._.Default := false
				}
				else
					Menu, % this.Menu, NoDefault
				this._.Insert("Default", Value)
			}
			else if(Name = "Icon")
				this.SetIcon(Value)
			else if(Name = "IconNumber")
				this.SetIcon(this.Icon, Value, this._.HasKey("IconWidth") ? this._.IconWidth : 0)
			else if(Name = "IconWidth")
				this.SetIcon(this.Icon,  this._.HasKey("IconNumber") ? this._.IconNumber : 1, Value)
			else
				Handled := false
			if(Handled)
				return Value
		}
	}
}

CMenu_Callback:
CMenu.RouteCallback()
return