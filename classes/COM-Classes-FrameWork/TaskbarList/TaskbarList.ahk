/*
class: TaskbarList
wraps the *ITaskbarList* interface and exposes methods that control the taskbar. It allows you to dynamically add, remove, and activate items on the taskbar.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TaskbarList)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774652)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional, Windows XP, Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown
*/
class TaskbarList extends Unknown
{
	/*
	Field: CLSID
	This is CLSID_TaskbarList. It is required to create an instance.
	*/
	static CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"

	/*
	Field: IID
	This is IID_ITaskbarList. It is required to create an instance.
	*/
	static IID := "{56FDF342-FD6D-11d0-958A-006097C9A090}"

	/*
	Method: HrInit
	initializes the interface. You should call this before doing anything else.

	Returns:
		BOOL success - true on success, false otherwise.
	*/
	HrInit()
	{
		return this._Error(DllCall(NumGet(this.vt+03*A_PtrSize), "ptr", this.ptr))
	}

	/*
	Method: AddTab
	adds a new item to the taskbar

	Parameters:
		HWND hWin - the handle to the window to add.

	Returns:
		BOOL success - true on success, false otherwise.

	Example:
		(start code)
		ITBL := new TaskbarList()
		ITBL.HrInit()
		Gui +LastFound
		ITBL.AddTab(WinExist())
		(end code)
	*/
	AddTab(hWin)
	{
		return this._Error(DllCall(NumGet(this.vt+04*A_PtrSize), "Ptr", this.ptr, "UInt", hWin))
	}

	/*
	Method: DeleteTab
	deletes an item from the taskbar

	Parameters:
		HWND hWin - the handle to the window to remove.

	Returns:
		BOOL success - true on success, false otherwise.

	Example:
		(start code)
		ITBL := new TaskbarList()
		ITBL.HrInit()
		ITBL.DeleteTab(WinExist("Notepad"))
		(end code)
	*/
	DeleteTab(hWin)
	{
		return this._Error(DllCall(NumGet(this.vt+05*A_PtrSize), "Ptr", this.ptr, "UInt", hWin))
	}

	/*
	Method: ActivateTab
	Activates an item on the taskbar.

	Parameters:
		HWND hWin - the handle to the window whose item should be activated.

	Returns:
		BOOL success - true on success, false otherwise.

	Remarks:
		- The window is not actually activated; the window's item on the taskbar is merely displayed as active.

	Example:
		(start code)
		ITBL := new TaskbarList()
		ITBL.HrInit()
		ITBL.ActivateTab(WinExist("Mozilla Firefox"))
		(end code)
	*/
	ActivateTab(hWin)
	{
		return this._Error(DllCall(NumGet(this.vt+06*A_PtrSize), "Ptr", this.ptr, "UInt", hWin))
	}

	/*
	Method: SetActiveAlt
	Marks a taskbar item as active but does not visually activate it.

	Parameters:
		HWND hWin - the handle to the window that should be marked as active.

	Returns:
		BOOL success - true on success, false otherwise.

	Remarks:
		SetActiveAlt marks the item associated with hWin as the currently active item for the window's process without changing the pressed state of any item. Any user action that would activate a different tab in that process will activate the tab associated with hWin instead. The active state of the window's item is not guaranteed to be preserved when the process associated with hwnd is not active. To ensure that a given tab is always active, call SetActiveAlt whenever any of your windows are activated. Calling SetActiveAlt with a NULL HWND clears this state.

	Example:
		(start code)
		ITBL := new TaskbarList()
		ITBL.HrInit()
		ITBL.SetActiveAlt(WinExist())
		(end code)
	*/
	SetActiveAlt(hWin)
	{
		return this._Error(DllCall(NumGet(this.vt+07*A_PtrSize), "Ptr", this.ptr, "UInt", hWin))
	}
}