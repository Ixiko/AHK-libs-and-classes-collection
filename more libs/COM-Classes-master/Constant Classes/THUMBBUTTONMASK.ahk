/*
class: THUMBBUTTONMASK
an enumeration class containing flags to specify which members of a THUMBBUTTON structure contain valid data.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/THUMBBUTTONMASK)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd562322)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 2008 or higher
*/
class THUMBBUTTONMASK
{
	/*
	Field: BITMAP
	The iBitmap member contains valid information.
	*/
	static BITMAP := 0x00000001

	/*
	Field: ICON
	The hIcon member contains valid information.
	*/
	static ICON := 0x00000002

	/*
	Field: TOOLTIP
	The szTip member contains valid information.
	*/
	static TOOLTIP := 0x00000004

	/*
	Field: FLAGS
	The dwFlags member contains valid information.
	*/
	static FLAGS := 0x00000008
}