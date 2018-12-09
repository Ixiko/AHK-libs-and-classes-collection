/*
class: THUMBBUTTONFLAGS
an enumeration class containing flags to control specific states and behaviours of a thumbbar button.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lgpl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/THUMBBUTTONFLAGS)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/dd562321)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 7 / Windows Server 2008 R2 or higher
*/
class THUMBBUTTONFLAGS
{
	/*
	Field: ENABLED
	The button is active and available to the user.
	*/
	static ENABLED := 0x00000000

	/*
	Field: DISABLED
	The button is disabled. It is present, but has a visual state that indicates that it will not respond to user action.
	*/
	static DISABLED := 0x00000001

	/*
	Field: DISMISSONCLICK
	When the button is clicked, the taskbar button's flyout closes immediately.
	*/
	static DISMISSONCLICK := 0x00000002

	/*
	Field: NOBACKGROUND
	Do not draw a button border, use only the image.
	*/
	static NOBACKGROUND := 0x00000004

	/*
	Field: HIDDEN
	The button is not shown to the user.
	*/
	static HIDDEN := 0x00000008

	/*
	Field: NONINTERACTIVE
	The button is enabled but not interactive; no pressed button state is drawn. This value is intended for instances where the button is used in a notification.
	*/
	static NONINTERACTIVE := 0x00000010
}