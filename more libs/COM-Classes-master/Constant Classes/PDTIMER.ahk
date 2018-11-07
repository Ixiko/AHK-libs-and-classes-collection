/*
class: PDTIMER
an enumeration class containing flags that indicate the action to be taken by the timer.

Authors:
	- maul.esel (https://github.com/maul-esel)

License:
	- *LGPL* (http://www.gnu.org/licenses/lpgl-2.1.txt)

Documentation:
	- *class documentation* (http://maul-esel.github.com/COM-Classes/master/PDTIMER)
	- *msdn* (http://msdn.microsoft.com/en-us/library/windows/desktop/bb775266)

Requirements:
	AutoHotkey - AHK v2 alpha
	OS - Windows 2000 Professional / Windows XP / Windows Server 2003 or higher
*/
class PDTimer
{
	/*
	Field: RESET
	Resets the timer to zero. Progress will be calculated from the time this method is called.
	*/
	static RESET := 0x00000001

	/*
	Field: PAUSE
	Progress has been suspended.
	*/
	static PAUSE := 0x00000002

	/*
	Field: RESUME
	Progress has been resumed.
	*/
	static RESUME := 0x00000003
}