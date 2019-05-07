# Class LV_Rows

## Additional functions for AHK ListView controls

AHK version: 1.1.23.01

This class provides an easy way to add functionalities to ListViews that are not supported by AutoHotkey built-in functions such as Copy, Cut, Paste, Drag and more.

### Credits
[LV_EX functions](https://github.com/AHK-just-me/LV_EX) by just me

## Edit Functions
* Copy()
* Cut()
* Paste([Row, Multiline])
* Duplicate()
* Delete()
* Move([Up])
* Drag([DragButton, AutoScroll, ScrollDelay, LineThick, Color])

## History Functions
* Add()
* Undo()
* Redo()
* ClearHistory()

## Group Functions
* EnableGroups([Enable, FirstName, Collapsible, StartCollapsed])
* InsertGroup([Row, GroupName])
* RemoveGroup([Row])
* InsertAtGroup([Count, Rows*])
* RemoveAtGroup([Count, Rows*])
* SetGroups(Groups)
* GetGroups([AsObject])
* SetGroupCollapisable([Collapsible])
* RemoveAllGroups([FirstName])
* CollapseAll([Collapse])
* RefreshGroups([Collapsed])

## Management Functions
* InsertHwnd(Hwnd)
* RemoveHwnd(Hwnd)
* SetHwnd(Hwnd [, NewData])
* GetData([Hwnd])
* SetCallback(Func)

- - -

## Usage
You can call the function by preceding them with LV_Rows. For example:
LV_Rows.Copy() <-- Calls function on active ListView.

Or with a handle initialized via New meta-function. For example:
MyListHandle := New LV_Rows() <-- Creates a new handle.
MyListHandle.Add() <-- Calls function for that Handle.

Like AutoHotkey built-in functions, these functions operate on the default gui, and active ListView control. When usingle handles, SetHwnd will attempt to set the selected ListView as active, but it's recommend to call Gui, Listview on your script too.

Initializing is required for History and Group functions and in case your ListView has icons to be moved during Drag().
Gui, Add, ListView, hwndhLV, Columns
MyListHandle := New LV_Rows(hLV) <-- Creates a new handle with Hwnd.

Gui, Add, ListView, hwndhLV1, Columns
Gui, Add, ListView, hwndhLV2, Columns
MyListHandle := New LV_Rows(hLV1, hLV2)

You can also use the same handle for the Edit functions.
You can create more handles or pass the ListView's Hwnd to operate on different lists with the same handle.

In order to keep row's icons you need to initialize the class passing the ListView's Hwnd. For example:
Gui, Add, ListView, hwndhLV, Columns
MyListHandle := New LV_Rows(hLV)

- - -

## Management Functions
Set, Insert and Remove ListView Hwnd's.

## Handle.InsertHwnd()
Inserts one or more ListView Hwnd's to be managed.

### Return
No return value.

### Parameters
* **Hwnd** - One or more ListView Hwnd's.

## Handle.RemoveHwnd()
Removes a ListView Hwnd.

### Return
No return value.

### Parameters
* **Hwnd** - Hwnd of the ListView to be removed.

## Handle.SetHwnd()
Selects a previously inserted ListView or adds it to the handle and selects it, optionally copying the data, history and groups from another Hwnd.

### Return
No return value.

### Parameters
* **Hwnd** - Hwnd of a ListView to be selected. If the hwnd is not found, it will be added to the handle and selected.
* **NewData** - Hwnd of a previously inserted ListView whose data, history and groups will be copied to the one being selected.

## Handle.GetData()
Retrieves the data, history and groups of a previously inserted ListView.

### Return
An object with data, history and groups of a ListView.

### Parameters
* **Hwnd** - Hwnd of a previously inserted ListView. If left blank, the current active ListView will be returned.

## LV_Rows.SetCallback()
Sets a callback function where the user can take actions based on the function being called called. The Callback function must return true for the operation to be completed.

### Return
No return value.

### Parameters
* **Func** - Name of a user-defined function that should receive 2 parameters** - The name of the function being called and the Hwnd of the current set ListView.

## Edit Functions
Edit ListView rows.

## LV_Rows.Copy()
Copy selected rows to memory.

### Return
Number of copied rows.

## LV_Rows.Cut()
Copy selected rows to memory and delete them.

### Return
Number of copied rows.

## LV_Rows.Paste()
Paste copied rows at selected position.

### Return
True if memory contains data or false if not.

### Parameters
* **Row** - If non-zero pastes memory contents at the specified row.
* **Multiline** - If true pastes the contents at every selected row.

## LV_Rows.Duplicate()
Duplicates selected rows.

### Return
Number of duplicated rows.

## LV_Rows.Delete()
Delete selected rows.

### Return
Number of removed rows.

## LV_Rows.Move()
Move selected rows down or up.

### Return
Number of rows moved.

### Parameters
* **Up** - If false or omitted moves rows down. If true moves rows up.

## LV_Rows.Drag()
Drag-and-Drop selected rows showing a destination bar. Must be called in the ListView G-Label subroutine when A_GuiEvent returns "D" or "d".

### Return
The destination row number.

### Parameters
* **DragButton** - If it is a lower case "d" it will be recognized as a Right-Click drag and won't actually move any row, only return the destination, otherwise it will be recognized as a Left-Click drag. You may pass A_GuiEvent as the parameter.
* **AutoScroll** - If true or omitted the ListView will automatically scroll up or down when the cursor is above or below the control.
* **ScrollDelay** - Delay in miliseconds for AutoScroll. Default is 100ms.
* **LineThick** - Thickness of the destination bar in pixels. Default is 2px.
* **Color** - Color of destination bar. Default is "Black".

## History Functions
Keep a history of ListView changes and allow Undo and Redo. These functions operate on the currently selected ListView.

## Handle.Add()
Adds an entry on History. This function requires initializing: MyListHandle := New LV_Rows()

### Return
The total number of entries in history.

## Handle.Undo()
Replaces ListView contents with previous entry state, if any.

### Return
New entry position or false if it's already the first entry.

## Handle.Redo()
Replaces ListView contents with next entry state, if any.

### Return
New entry position or false if it's already the last entry.

## Handle.ClearHistory()
Removes all history entries from the ListView.

### Return
New entry position or false if it's already the last entry.

## Group Functions
Set, add and remove Listview Groups. These functions are based on just me's [LV_EX library](http://autohotkey.com/boards/viewtopic.php?t=1256)

## Handle.EnableGroups()
Enables or disables Groups in the currently selected ListView initializing: MyListHandle := New LV_Rows()

### Return
No return value.

### Parameters
* **Enable** - If TRUE enables GroupView in the selected ListView. If FALSE disables it.
* **FirstName** - Name for the first (mandatory) group at row 1.
* **Collapsible** - If TRUE makes the groups collapsible.
* **StartCollapsed** - If TRUE starts all groups collapsed.

## Handle.InsertGroup()
Inserts or renames a group on top of the specified row.

### Return
TRUE if Row is bigger than 0 or FALSE otherwise.

### Parameters
* **Row** - Number of the row for the group to be inserted. If left blank the first selected row will be used.
* **GroupName** - Name of the new group or new name for an existing group.

## Handle.RemoveGroup()
Removes the group the indicated row belongs to.

### Return
TRUE if Row is bigger than 0 or FALSE otherwise.

### Parameters
* **Row** - Number of a row the group belongs to. If left blank the first selected row will be used.

## Handle.InsertAtGroup()
Inserts a row at indicated position, moving groups after it one row down.

### Return
No return value.

### Parameters
* **Row** - Number of the row where to insert.

## Handle.RemoveAtGroup()
Removes a row from indicated position, moving groups after it one row up.

### Return
No return value.

### Parameters
* **Row** - Number of the row where to insert.

## Handle.SetGroups()
Sets one or more groups in the selected ListView.

### Return
No return value.

### Parameters
* **Groups** - A list of groups in the format "GroupName:RowNumber" separated by comma. You can use GetGroups() to save a valid String or Object to be used with this function.

## Handle.GetGroups()
Returns a string or object representing the current groups in the selected ListView.

### Return
No return value.

### Parameters
* **AsObject** - If TRUE returns an object with the groups, otherwise an string. Both can be used with SetGroups().

## Handle.SetGroupCollapisable()
Enables or disables Groups Collapsible style.

### Return
No return value.

### Parameters
* **Collapsible** - If TRUE enables Collapsible style in the selected ListView. If FALSE disables it.

## Handle.RemoveAllGroups()
Removes all groups in the selected ListView.

### Return
No return value.

### Parameters
* **FirstName** - Name for the first (mandatory) group at row 1.

## Handle.CollapseAll()
Collapses or expands all groups.

### Return
No return value.

### Parameters
* **Collapse** - If TRUE collapses all groups in the selected ListView. If FALSE expands all groups in the selected ListView.

## Handle.RefreshGroups()
Reloads the ListView to update groups. This function is called automatically in from other functions, usually it's not necessary to use it in your script.

### Return
No return value.

### Parameters
* **Collapsed** - If TRUE collapses all groups in the selected ListView.

