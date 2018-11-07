/*
class: SW
an enumeration class containing flags that control how a window is to be shown.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/SW)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/ms633548)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows 2000 Server or higher
*/
class SW
{
	/*
	Field: FORCEMINIMIZE
	Minimizes a window, even if the thread that owns the window is not responding. This flag should only be used when minimizing windows from a different thread.
	*/
	static FORCEMINIMIZE := 11

	/*
	Field: HIDE
	Hides the window and activates another window.
	*/
	static HIDE := 0

	/*
	Field: MAXIMIZE
	Maximizes the specified window.
	*/
	static MAXIMIZE := 3

	/*
	Field: MINIMIZE
	Minimizes the specified window and activates the next top-level window in the Z order.
	*/
	static MINIMIZE := 6

	/*
	Field: RESTORE
	Activates and displays the window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when restoring a minimized window.
	*/
	static RESTORE := 9

	/*
	Field: SHOW
	Activates the window and displays it in its current size and position.
	*/
	static SHOW := 5

	/*
	Field: SHOWDEFAULT
	Sets the show state based on the SW_ value specified in the STARTUPINFO structure passed to the CreateProcess function by the program that started the application. 
	*/
	static SHOWDEFAULT := 10

	/*
	Field: SHOWMAXIMIZED
	Activates the window and displays it as a maximized window.
	*/
	static SHOWMAXIMIZED := 3

	/*
	Field: SHOWMINIMIZED
	Activates the window and displays it as a minimized window.
	*/
	static SHOWMINIMIZED := 2

	/*
	Field: SHOWMINNOACTIVE
	Displays the window as a minimized window. This value is similar to <SHOWMINIMIZED>, except the window is not activated.
	*/
	static SHOWMINNOACTIVE := 7

	/*
	Field: SHOWNA
	Displays the window in its current size and position. This value is similar to <SHOW>, except that the window is not activated.
	*/
	static SHOWNA := 8

	/*
	Field: SHOWNOACTIVATE
	Displays a window in its most recent size and position. This value is similar to <SHOWNORMAL>, except that the window is not activated.
	*/
	static SHOWNOACTIVATE := 4

	/*
	Field: SHOWNORMAL
	Activates and displays a window. If the window is minimized or maximized, the system restores it to its original size and position. An application should specify this flag when displaying the window for the first time.
	*/
	static SHOWNORMAL := 1
}