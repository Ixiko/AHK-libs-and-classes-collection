/*
class: TaskbarList2
wraps the *ITaskbarList2* interface and exposes a method to mark a window as a full-screen display.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/TaskbarList2)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb774638)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows XP, Windows 2000 Server or higher
	Base classes - _CCF_Error_Handler_, Unknown, TaskbarList
*/
class TaskbarList2 extends TaskbarList
{
	/*
	Field: CLSID
	This is CLSID_TaskbarList. It is required to create an instance.
	*/
	static CLSID := "{56FDF344-FD6D-11d0-958A-006097C9A090}"

	/*
	Field: IID
	This is IID_ITaskbarList2. It is required to create an instance.
	*/
	static IID := "{602D4995-B13A-429b-A66E-1935E44F4317}"

	/*
	Method: MarkFullScreen
	Marks a window as full-screen.

	Parameters:
		HWND hGui - the window handle of your gui
		BOOL ApplyRemove - determines whether to apply or remove fullscreen property

	Returns:
		BOOL success - true on success, false otherwise.

	Example:
		(start code)
		ITBL2 := new TaskbarList2()
		ITBL2.HrInit()
		Gui 2: +LastFound
		ITBL2.MarkFullScreen(WinExist())
		(end code)
	*/
	MarkFullScreen(hWin, ApplyRemove)
	{
		return this._Error(DllCall(NumGet(this.vt+08*A_PtrSize), "Ptr", this.ptr, "Uint", hWin, "UInt", ApplyRemove))
	}
}