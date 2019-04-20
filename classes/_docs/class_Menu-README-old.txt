MENU Class Reference

I. Objects/Interfaces
MENU [Class Object] - Represents the class
MENU [Instance]     - Represents a menu
MENU._menuitems_    - Represents the menu items in the menu
MENU._item_         - Represents a single menu item. MENU._item_ is the base
                      interface for accessing a menu item's properties and methods.
MENU._trayicon_     - Represents the Tray menu icon.

II. PROPERTIES
================================================================================
name                - Returns the name of the menu or the menu item.
                      If the target object is a menu item object, setting this
                      property renames the menu item.
                      ** Applies to MENU (Read-only) , MENU._item_ (Read/write)
Example(s):
MenuName := menuObj.name          ; retrieve the menu's name
ItemName := itemObj.name          ; retrieve the menu item's name
itemObj.name := "New item name"   ; renames the menu item
================================================================================
handle              - Returns the handle/hMenu of the menu.
                      ** Applies to MENU (Read-only)
Example(s):
hMenu := menuObj.handle           ; retrieve the menu's handle
================================================================================
count               - Returns the number of items in the menu.
                      ** Applies to MENU (Read-only)
Example(s):
ItemCount := menuObj.count        ; retrieve the number of items in the menu
================================================================================
default             - If the target object is a MENU object, this property
                      contains the MENU._item_ object representing the
                      default(if any) menu item. Assign a menu item object or
                      the menu item's name to this property to make that menu
                      item the default menu item.
                      If the target object is a MENU._item_ object, this
                      property returns True(1) if the item is currently the
                      default item, otherwise, it returns False(0). Set this
                      property to True(1) to make the target menu item object the
                      default menu item, otherwise, set it to False(0).
                      ** Applies to MENU (Read/write) , MENU._item_ (Read/write)
Example(s):
defaultItem := menuObj.default   ; Returns the default menu item (Object)
isDefault := itemObj.default     ; Contains 1 if the 'itemObj' is the default item
menuObj.default := itemObj       ; Sets 'itemObj' as the default menu item
itemObj.default := 1             ; Same as above
================================================================================
target              - Gets or sets the menu item's target label or function or submenu.
                      Valid values:
                      LabelName     - String specifying the target label's name
                      FunctionName  - String specifying the target function's name
                      FuncObject    - A refernce to a Func object.
                      SubmenuName   - String specifying the name of the menu to be
                                      attached as submenu. Precede it with a ":"
                      SubmenuObj    - a MENU object derived from this class that
                                      represents a menu to be attached as a submenu                 
                      If the assigned value exists as both a Label and a Function
                      in the script, the target Label will be called every time
                      the item is selected. To have it call the function instead,
                      assign a FuncObject. To have an item open a submenu,
                      specify the menu's name preceded by a ":" or assign a
                      MENU object. 
                      ** Applies to MENU._item_ (Read/write)
Example(s):
itemObj.target := "LabelName"         ; Sets LabelName as the item's event handler
itemObj.target := "FunctionName"      ; Sets FunctionName in this case
itemObj.target := Func("MyFunction")  ; Value is a FuncObject
itemObj.target := ":AnotherMenu"      ; Item opens a submenu
itemObj.target := SubmenuObj          ; Submenu, assigned value is another MENU object
================================================================================
icon                - If the target object is a MENU._item_ object, this property
                      sets the menu item's icon (file) and/or icon number(if any).
                      Specify a string containing the path to the icon file or
                      resource. To specify the icon number, separate it with a
                      comma(there must be no spaces in between, see example).
                      For the tray icon, target object must be a MENU object
                      whose name property is "Tray". If the target object is a
                      MENU (Tray) object, this property returns a MENU._trayicon_
                      object with the following fields: "file", "number", "tip", and "click".
                      -see property description for the specified fields-
                      ** Applies to MENU(tray; Read/write) , MENU._item_ (Read/write)
Example(s):
Menu item object
itemObj.icon := "Shell32.dll,15"     ; Note comma in between

Menu(tray) object
; You can omit unneeded fields
trayObj.icon := {file: "Shell32", number: 15, tip: "Tray tip", click: 2}
; You can also assign a comma delimited string in this order: [file, number, click, tip]
trayObj.icon := "Shell32.dll,15,2,Tray tip"
; leave blank to omit a field. Here "click" is not specified
trayObj.icon := "Shell32.dll,15,,Tray tip"
================================================================================
file                - Sets or gets the tray menu icon's file. Specify a string
                      containing the path to the icon file or resource. Target
                      object must be a MENU object whose name property is "Tray".
                      Default value returns A_AhkPath.
                      ** Applies to MENU._trayicon_ (Read/write)
Example(s):
trayObj.icon.file := "Shell32.dll"
================================================================================
number              - Sets or gets the tray menu icon number. Default is 1
                      ** Applies to MENU._trayicon_ (Read/write)
Example(s):
trayObj.icon.number := 15
================================================================================
tip                 - Sets or gets the tray menu icon's tooltip.
                      Default value is A_ScriptName.
                      ** Applies to MENU._trayicon_ (Read/write)
Example(s):
trayObj.icon.tip := "This is a tray tip."
================================================================================
click               - Specify 1 to allow a single-click to activate the tray
                      menu's default menu item. Specify 2 to return to the
                      default behavior (double-click). 
                      ** Applies to MENU._trayicon_ (Read/write)
Example(s):
trayObj.icon.click := 1
================================================================================
check               - Gets or sets the menu item's check state. Specify 1 to
                      put a checkmark, 0 to uncheck and 2 to toggle. This property
                      returns True(1) if the item is checked, otherwise, False(0)
                      if there is no checkmark.
                      ** Applies to MENU._item_ (Read/write)
Example(s):
itemObj.check := 1  ; 1=check , 0=uncheck , 2=togglecheck
================================================================================
enable              - Enables or disables(grays out) a menu item. Specify 1 to
                      enable, 0 to disable and 2 to toggle. This property
                      returns True(1) if the item is enabled, otherwise, False(0)
                      if the item is disabled.
                      ** Applies to MENU._item_ (Read/write)
Example(s):
itemObj.enable := 1  ; 1=enable , 0=disable , 2=toggleenable
================================================================================
pos                 - Returns the menu item's one-based position in the menu.
                      Setting this property moves the menu item at the specified
                      position. Value must not be less than 1 and not be greater
                      than the total menu item count.
                      ** Applies to MENU._item_ (Read/write)
Example(s):
ItemPos := itemObj.pos   ; Retrieves the menu item's position
itemObj.pos := 3         ; Moves the item to the 3rd position in the menu
================================================================================
type                - Returns the menu item's type.
                      Return values(string):
                      Normal     - Normal menu item
                      Separator  - Menu item is a separator
                      Submenu    - Menu item opens a submenu
                      Standard   - Item is part of the AHK standard menu items
                      ** Applies to MENU._item_ (Read-only)
Example(s):
ItemType := itemObj.type
================================================================================
id                  - Returns the menu item identifier of the menu item.
                      This property returns 0 for menu items of the type "Separator",
                      -1 for items that open a submenu.
                      ** Applies to MENU._item_ (Read-only)
Example(s):
ItemID := itemObj.id
================================================================================
color               - Sets the menu's background color. Specify a string indicating
                      the ColorValue which is one of the 16 primary HTML color
                      names or a 6-digit RGB color value. Delimit with a comma and
                      specify either "1", "true" or "Single" to have any submenus
                      attached to this menu retain their default color. Otherwise,
                      specify either "0" or "false" or omit to change the color
                      of any attached submenus as well. You can also assign an
                      object. When specifying an object, object can be an associative
                      array with the following fields:
                      value   - the color value
                      single  - indicates whether attached submenus should
                                retain or change their background color.
                      Alternatively, you can assign a simple array. First field
                      must be the color value and second field must be the value of the
                      "single" property/attribute. -SEE EXAMPLES FOR DETAILS-
                      This property returns an object with the ff fields:
                      value   - contains the color value.
                                Blank if not previously altered.
                      single  - contains either "single","1","true" or "0","false"
                      ** Applies to MENU (Read/write)
Example(s):
; Here we assign a string
; instead of the word "single", you can also specify "1" or "true" or "0" or "false"
menuObj.color := "White,single" ; Attached submenus retain their background colors.
menuObj.color := "White,false"  ; Attached submenus change their background colors as well.
menuObj.color := "White"        ; Same as above, "single" is omitted. Defaults to False(0)

; Here we assign an object. There are two ways to do this.
; The value of "single" can be either of the ff: "1" or "true" or "single" or "0" or "false"
menuObj.color := {value: "White", single: 1} ; associative array
menuObj.color := ["White", 1]                ; simple array

; Retrieve the menu's background color.
BackColor := menuObj.color.value
================================================================================
standard            - Specify True(1) to insert the standard menu items at the
                      bottom of the menu (if they are not already present).
                      Setting the value to False(0), removes all standard (non-custom)
                      menu items from the menu (if they are present).
                      Returns the one-based index or position of the first standard
                      menu item if set to True(1), otherwise, returns False(0).
                      ** Applies to MENU
Example(s):
; Returns the first standard menu item's index if the menu contains the standard items.
IsStandard := menuObj.standard
; Inserts the standard menu items at the bottom of the menu
menuObj.standard := true
================================================================================
menu                - Represents the menu from which the menu item belongs to.
                      Returns a MENU object.
                      ** Applies to MENU._item_ (Read-only)
Example(s):
menuObj := itemObj.menu
================================================================================
isMenu              - Returns True(1) if the menu exists, otherwise, False(0).
                      This property is not for general use.
                      ** Applies to MENU (Read-only)
Example(s):
IsMenu := menuObj.isMenu
================================================================================
item                - Represents a MENU._menuitems_ object containg a list of
                      all menu items for this menu. This is the base interface to
                      access/retrieve each menu item object. You can access a
                      menu item object via its pos/index or name property.
                      ** Applies to MENU (Read-only)
Example(s):
; Retrieve the first menu item in the menu. Returns a menu item object.
; Here we specify its index
itemObj := menuObj.item[1] ; or menuObj.item.1
; You can then access the menu item's properties via the returned object
ItemName := itemObj.name
itemObj.name := "New menu item name" ; rename the item

; Retrieve/access a menu item object by name
itemObj := menuObj.item["First menu item"]

; Here are some examples on how to access a menu item object's property
ItemName := menuObj.item[1].name    ; Retrieve the name of the first menu item
menuObj.item[1].pos := 3            ; Moves the first menu item to the 3rd position

; Here we remove/delete the item from the menu by assigning a blank value
menuObj.item[1] := ""               ; Deletes the first menu item from the menu
menuObj.item["Open`tCtrl+O"] := ""  ; Deletes the menu item with the specified name
================================================================================
thisItem            - Represents the most recently selected menu item.
                      Target object must be the Class object itself which is
                      the super-global varaible "Menu"(ClassName). This property
                      is similar to the built-in variable A_ThisMenuItem. But
                      instead of containing the menu item's name, this property
                      contains a menu item object. This property is useful when
                      you have a common label or function that handles all menu
                      events. The menu item object representing the most recently
                      selected item is accessible even within local scope.
                      ** Applies to MENU[Class object]
Example(s):
; Here we have a common label assigned to handle all events for a specific menu.
MyMenuHandler: ; Label is triggered every time a menu item is selected
itemObj := menu.thisItem
if (itemObj.pos = 1)
	MsgBox, % itemObj.name
return

; Here we have a function assigned to handle events.
; Since the target object is the Class object itself, the menu item object is
; accessible even witihin local scope
MyMenuHandler() { ; Function gets called every time a menu item is selected
	itemObj := menu.thisItem
	if (itemObj.pos = 1)
		MsgBox, % itemObj.name
}
================================================================================
thisMenu            - Represents the menu from which the most recently selected
                      menu item belongs to. This is similar to the built-in
                      varaible A_ThisMenu. It contains a MENU object. Just like
                      the 'thisMenu' property, target object must be the Class
                      object itself.
                      ** Applies to MENU[Class object]
Example(s):
; Here we have common label assigned to handle all events for all created menus
CommonMenuHandler:
menuObj := menu.thisMenu ; retrieve the MENU object
itemObj := menu.thisItem ; retrieve the menu item object
if (menuObj.name == "MyMenu") {
	if (itemObj.pos == 1)
		; some code if it's the first item
	else if (itemObj.pos == 2)
		; some code if it's the second item
} else if (menuObj.name == "AnotherMenu") {
	; some code for "AnotherMenu"
}
return
================================================================================


III. METHODS
================================================================================
__New               - Constructor for the class. Use the 'new' keyword to create
                      an instance of the class. Returns a MENU object that
                      represents the newly created custom menu.

Parameter(s):
arg(required)       - Pass a string containing the name of the menu. Specify the
                      word "Tray" to create an object instance that represents
                      the Tray menu. By default (if 'name' is "Tray"), the
                      'standard' property's value is set to True(1). You can
                      bypass this by passing an object(see below) and setting the
                      'standard' property's value to False(0).
                      You can also specify an object/array containing the
                      properties of the menu to be created. Object key(s) must
                      be the name of the properties and should contain the
                      appropriate value. The 'name' property should be present.
                      Valid value(s): (see Properties for details)
                      name      - String containing the name of the menu to be
                                  created. This property is required.
                      color     - The background color of the menu.
                      standard  - Indicates whether the menu contains the standard
                                  menu items or not.

Remark(s):
The menu's name must be unique.

Example(s):
; Create a menu named 'MyMenu'.
menuObj := new menu("MyMenu")
; Same as above but this one adds the standard menu items. An object is passed.
menuObj := new menu({name: "MyMenu", standard: true})
; Creates a menu object that represents the Tray menu. Setting 'standard' to
; False(0) removes the standard menu items from the the Tray menu.
trayObj := new menu({name: "Tray", standard: false})
================================================================================
add                 - Appends a new item to the end of the menu.
                      ** Applies to MENU

Parameter(s):
item(optional)      - Pass an object/array containing the properties of the item
                      to be appended. Object key(s) must be the name of the
                      properties and should contain the appropriate value.
                      The 'name' property should be present when appending a normal
                      menu item. To append a separator, omit this parameter.
                      Valid properties: (see Properties for details)
                      name    - String containing the name of the item to be appended
                                This property is required.
                      target  - The target label, function or submenu. If omiited,
                                'name' is used.
                      icon    - The icon to assign to the menu item
                      check   - Specifies wheteher to check or uncheck the item
                      enable  - Specifies wheteher to enable or disbale the item
                      default - Specifies wheteher to set the item as the default or not.

Example(s):
menuObj.add({name: "Item one", target: "MyLabel", icon: "Shell32.dll,25"})
================================================================================
insert              - Inserts a new menu item at the specified position in a menu.
                      ** Applies to MENU

Parameter(s):
item(optional)      - See 'item' parameter description for the 'add' method.
pos(optional)       - The position in which to insert the new menu item.
                      If position is not specified, the item is appended to the
                      end of the menu.

Remark(s):
When inserting a separator, just pass the 'pos' parameter.

Example(s):
; Inserts a new menu item at position 2 in the menu
menuObj.insert({name: "Item one", target: "MyLabel"}, 2)
; Here we insert a separator at position 2
menuObj.insert(2)
; This is the same as appending a separator
menuObj.insert()  ; Note: no passed parameter
================================================================================
delete              - Deletes/removes a menu item from the menu.
                      ** Applies to MENU

Parameter(s):
item(optional)      - The position or name of the item to be deleted. If omitted,
                      all menu items will be deleted. It does not destroy the menu.

Example(s):
menuObj.delete(3)           ; Removes the 3rd item from the menu
menuObj.delete("Some item") ; Removes the item with the specified name
menuObj.delete()            ; Removes all menu items from the menu, leaving the menu empty
================================================================================
show                - Displays the menu.
                      ** Applies to MENU

Parameter(s):
x(optional)         - The 'x' position at which the menu is shown. If omitted,
                      the current mouse cursor's 'x' position is used. This is
                      affected the by 'CoordMode' setting.
y(optional)         - The 'y' position at which the menu is shown. If omitted,
                      the current mouse cursor's 'y' position is used. This is
                      affected by the 'CoordMode' setting.
coordmode(optional) - Specify any of the following value(s):
                      Screen   - Coordinates are relative to the desktop
                      Relative - Coordinates are relative to the active window
                      Window   - Synonymous with Relative and recommended for clarity
                      Client   - Coordinates are relative to the active window's
                                 client area, which excludes the window's title bar,
                                 menu (if it has a standard one) and borders.

Remark(s):
If no parameter is passed, the menu is displayed at the current position of the
mouse cursor.

Example(s):
menuObj.show()                 ; Display menu at current mouse cursor position
menuObj.show(10, 10)           ; By default, menu is displayed relative to the active window
menuObj.show(10, 10, "Screen") ; Make it relative to the screen/desktop
================================================================================


IV. ADDITIONAL FUNCTIONS
================================================================================
MENU_from           - Allows creation of menu(s) by passing an XML string.
                      The return value depends on the structure of the XML. If
                      the XML contains data that indicates multiple menus to be
                      created, this function returns an object containing a list
                      of menus. You can access each MENU object by specifying its
                      name as key. Otherwise, if the data indicates a single menu
                      to be created, the return value is a MENU object representing
                      the menu. The purpose of this function is to enable rapid
                      creation of menu(s) via markup and less coding.

Parameter(s):
src                 - An XML string containing data that describes the menu(s)
                      to be created.

Remark(s):
The XML Structure: Below are some examples on how to compose the XML
A. Multiple menus
 --start of XML--
<MENU_Class>
	<Menu name="File">
		<Item name="Open`tCtrl+O" target="MyLabel" icon="Shell32.dll,15"/>
		<Item name="Save`tCtrl+S" target="MyLabel" default="1"/>
		<Item name="Open submenu" target=":Edit"/>
		<Item/>
		<Item name="Close`tAlt+F4" target="MyLabel"/>
	<Menu/>
	<Menu name="Edit" color="White,single">
		<Item name="Copy`tCtrl+C" target="MyLabel"/>
		<Item name="Cut`tCtrl+X" target="MyLabel"/>
		<Item name="Paste`tCtrl+V" target="MyLabel"/>
		<Item/>
		<Item name="Undo`tCtrl+Z" target="MyLabel"/>
	<Menu/>
<MENU_Class/>
--end of XML--

B. Single menu
 --start of XML--
<Menu name="Edit" color="White,single">
	<Item name="Copy`tCtrl+C" target="MyLabel"/>
	<Item name="Cut`tCtrl+X" target="MyLabel"/>
	<Item name="Paste`tCtrl+V" target="MyLabel"/>
	<Item/>
	<Item name="Undo`tCtrl+Z" target="MyLabel"/>
<Menu/>
--end of XML--
OR
 --start of XML--
<MENU_Class>
	<Menu name="Edit" color="White,single">
		<Item name="Copy`tCtrl+C" target="MyLabel"/>
		<Item name="Cut`tCtrl+X" target="MyLabel"/>
		<Item name="Paste`tCtrl+V" target="MyLabel"/>
		<Item/>
		<Item name="Undo`tCtrl+Z" target="MyLabel"/>
	<Menu/>
<MENU_Class/>
--end of XML--

The attribute(s) of the 'Menu' element should be valid MENU object properties.
Same goes for the 'Item' element, should be valid MENU._item_ properties. To
specify a separator, omit the 'Item' element's attributes. See 'Properties' above
and see '__New' method.
The name of the root node can be anything as long as it conforms with XML's syntax.

Example(s):
; Let's say that the 'src' variable contains an XML string indicating multiple
; menus to be created.
mList := MENU_from(src)
return
; mList contains a list of MENU objects, you can access a menu object by specifying
; its name as key.
^LButton:: mList.File.show() ; show the menu whose name is 'File'

; Here the 'src' variable contains XML data that indicates a single menu to be created.
myMenu := MENU_from(src)
return
; The function returned a MENU object, you can access its properties and methods.
^LButton:: myMenu.show()
================================================================================
MENU_json           - This function acts the same as MENU_from. But instead of
                      an XML string, a JSON string is passed.

Parameter(s):
src                 - A JSON string containing data describing the menu(s) to be
                      created.

Remark(s):
The JSON Structure: Below are some examples on how to compose the JSON
A. Multiple menus
--start of JSON--
[
	{
		'name': 'File',
		'items': [
			{'name': 'Open\tCtrl+O', 'target': 'Test', 'icon': 'Shell32.dll,15'},
			{'name': 'Save\tCtrl+S', 'target': 'Test', 'default': 1},
			{'name': 'Open submenu', 'target': ':Edit'},
			{},
			{'name': 'Exit\tAlt+F4', 'target': 'Test'}
		]
	},
	{
		'name': 'Edit',
		'color': 'White',
		'items': [
			{'name': 'Copy\tCtrl+C', 'target': 'Test'},
			{'name': 'Cut\tCtrl+X', 'target': 'Test'},
			{'name': 'Paste\tCtrl+V', 'target': 'Test'},
			{},
			{'name': 'Undo\tCtrl+Z', 'target': 'Test'}
		]
	}
]
--end of JSON--

B. Single menu
--start of JSON--
{
	'name': 'Edit',
	'color': 'White',
	'items': [
		{'name': 'Copy\tCtrl+C', 'target': 'Test'},
		{'name': 'Cut\tCtrl+X', 'target': 'Test'},
		{'name': 'Paste\tCtrl+V', 'target': 'Test'},
		{},
		{'name': 'Undo\tCtrl+Z', 'target': 'Test'}
	]
}
--end of JSON--

See MENU_from for example(s) on usage.
================================================================================
MENU_to             - Converts a MENU object or objects to an IXMLDOMDocument
                      object. This function is useful if you want to save/store
                      the menu(s) configuration in an XML file for later reuse.

Parameter(s):
mobj(variadic*)     - Specify a MENU object or objects derived from the class.
                      Atleast one parameter is required.

Remark(s):
This function returns an IXMLDOMDocument object. For reference on its properties
and methods, see: http://msdn.microsoft.com/en-us/library/ms764730(v=vs.85).aspx

Example(s):
xMenus := MENU_to(menuObj1, menuObj2)
MsgBox, % xMenus.xml             ; Display the XML representation
xMenus.save("MenuConfig.xml")    ; Save menus as XML in working directory.
return
================================================================================

