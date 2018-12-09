/*
class: TaskbarList4
wraps the *ITaskbarList4* interface and provides a method that allows the caller to control two property values for the tab thumbnail and peek feature.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TaskbarList4)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd562040)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7, Windows Server 2008 R2 or higher
	Base classes - _CCF_Error_Handler_, Unknown, TaskbarList, TaskbarList2, TaskbarList3
	Constant classes - STPFLAG
*/
class TaskbarList4 extends TaskbarList3
{
	/*
	Field: CLSID
	This is CLSID_TaskbarList. It is required to create an instance.
	*/
	static CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"

	/*
	Field: IID
	This is IID_ITaskbarList4. It is required to create an instance.
	*/
	static IID := "{c43dc798-95d1-4bea-9030-bb99e2983a1a}"

	/*
	Method: SetTabProperties
	Allows a tab to specify whether the main application frame window or the tab window should be used as a thumbnail or in the peek feature.

	Parameters:
		HWND hTab - the handle of the tab to work on.
		UINT properties - the properties to set. You may use the fields of the STPFLAG class for convenience.

	Returns:
		BOOL success - true on success, false otherwise.

	Example:
		(start code)
		ITBL4 := new TaskbarList4()
		ITBL4.HrInit()
		ITBL4.SetTabProperties(WinExist(), STPFLAG.USEAPPTHUMBNAILALWAYS|STPFLAG.USEAPPPEEKALWAYS)
		(end code)

	Remarks:
		Read the flag documentation carefully to avoid flag combinations that cause errors.
	*/
	SetTabProperties(hTab, properties)
	{
		return this._Error(DllCall(NumGet(this.vt+21*A_PtrSize), "Ptr", this.ptr, "UInt", hTab, "UInt", properties))
	}
}